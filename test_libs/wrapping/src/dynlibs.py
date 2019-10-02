# License: BSD 3-Clause

# The code to introspect dynamically loaded libraries on POSIX systems is
# adapted from code by Intel developper @anton-malakhov available at
# https://github.com/IntelPython/smp (Copyright (c) 2017, Intel Corporation)
# and also published under the BSD 3-Clause license
import os
import sys
import ctypes
from ctypes.util import find_library

# Cache for libc under POSIX and a few system libraries under Windows
_system_libraries = {}

# Cache for calls to os.path.realpath on system libraries to reduce the
# impact of slow system calls (e.g. stat) on slow filesystem
_realpaths = dict()

# Structure to cast the info on dynamically loaded library. See
# https://linux.die.net/man/3/dl_iterate_phdr for more details.

_SYSTEM_UINT = ctypes.c_uint64 if sys.maxsize > 2**32 else ctypes.c_uint32
_SYSTEM_UINT_HALF = ctypes.c_uint32 if sys.maxsize > 2**32 else ctypes.c_uint16


class _dl_phdr_info(ctypes.Structure):
    _fields_ = [
        ("dlpi_addr",  _SYSTEM_UINT),       # Base address of object
        ("dlpi_name",  ctypes.c_char_p),   # path to the library
        ("dlpi_phdr",  ctypes.c_void_p),   # pointer on dlpi_headers
        ("dlpi_phnum",  _SYSTEM_UINT_HALF)  # number of element in dlpi_phdr
    ]


def _realpath(filepath, cache_limit=10000):
    """Small caching wrapper around os.path.realpath to limit system calls"""
    rpath = _realpaths.get(filepath)
    if rpath is None:
        rpath = os.path.realpath(filepath)
        if len(_realpaths) < cache_limit:
            # If we drop support for Python 2.7, we could use
            # functools.lru_cache with maxsize=10000 instead.
            _realpaths[filepath] = rpath
    return rpath


def load_modules(prefixes=None):
    """Loop through loaded libraries and return supported ones."""
    if prefixes is None:
        prefixes = []
    if sys.platform == "darwin":
        return _find_modules_with_dyld(prefixes=prefixes)
    elif sys.platform == "win32":
        return _find_modules_with_enum_process_module_ex(prefixes=prefixes)
    else:
        return _find_modules_with_dl_iterate_phdr(prefixes=prefixes)


def _make_module_info(filepath, real_filepath, filename):
    """Make a dict with the information from the module."""
    filepath = os.path.normpath(filepath)
    real_filepath = os.path.normpath(real_filepath)

    module_info = {"name": filename,
                   "path": filepath,
                   "realpath": real_filepath}
    # dynlib = ctypes.CDLL(filepath)
    # set_func = getattr(dynlib,
    #                    "<func_name>",
    #                    <func signature (as a lambda)>)
    return module_info


def _get_module_info_from_path(filepath, prefixes, modules):
    # Required to resolve symlinks
    real_filepath = _realpath(filepath)
    # `lower` required to take account of OpenMP dll case on Windows
    # (vcomp, VCOMP, Vcomp, ...)
    filename = os.path.basename(filepath).lower()
    modules.append(_make_module_info(filepath, real_filepath, filename))


def _find_modules_with_dl_iterate_phdr(prefixes):
    """Loop through loaded libraries and return binders on supported ones

    This function is expected to work on POSIX system only.
    This code is adapted from code by Intel developper @anton-malakhov
    available at https://github.com/IntelPython/smp

    Copyright (c) 2017, Intel Corporation published under the BSD 3-Clause
    license
    """
    libc = _get_libc()
    if not hasattr(libc, "dl_iterate_phdr"):  # pragma: no cover
        return []

    _modules = []

    # Callback function for `dl_iterate_phdr` which is called for every
    # module loaded in the current process until it returns 1.
    def match_module_callback(info, size, data):
        # Get the path of the current module
        filepath = info.contents.dlpi_name
        if filepath:
            filepath = filepath.decode("utf-8")

            # Store the module in cls_thread_locals._module if it is
            # supported and selected
            _get_module_info_from_path(filepath, prefixes, _modules)
        return 0

    c_func_signature = ctypes.CFUNCTYPE(
        ctypes.c_int,  # Return type
        ctypes.POINTER(_dl_phdr_info), ctypes.c_size_t, ctypes.c_char_p)
    c_match_module_callback = c_func_signature(match_module_callback)

    data = ctypes.c_char_p(b'')
    libc.dl_iterate_phdr(c_match_module_callback, data)

    return _modules


def _find_modules_with_dyld(prefixes):
    """Loop through loaded libraries and return binders on supported ones

    This function is expected to work on OSX system only
    """
    libc = _get_libc()
    if not hasattr(libc, "_dyld_image_count"):  # pragma: no cover
        return []

    _modules = []

    n_dyld = libc._dyld_image_count()
    libc._dyld_get_image_name.restype = ctypes.c_char_p

    for i in range(n_dyld):
        filepath = ctypes.string_at(libc._dyld_get_image_name(i))
        filepath = filepath.decode("utf-8")

        # Store the module in cls_thread_locals._module if it is supported and
        # selected
        _get_module_info_from_path(filepath, prefixes, _modules)

    return _modules


def _find_modules_with_enum_process_module_ex(prefixes):
    """Loop through loaded libraries and return binders on supported ones

    This function is expected to work on windows system only.
    This code is adapted from code by Philipp Hagemeister @phihag available
    at https://stackoverflow.com/questions/17474574
    """
    from ctypes.wintypes import DWORD, HMODULE, MAX_PATH

    PROCESS_QUERY_INFORMATION = 0x0400
    PROCESS_VM_READ = 0x0010

    LIST_MODULES_ALL = 0x03

    ps_api = _get_windll('Psapi')
    kernel_32 = _get_windll('kernel32')

    h_process = kernel_32.OpenProcess(
        PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
        False, os.getpid())
    if not h_process:  # pragma: no cover
        raise OSError('Could not open PID %s' % os.getpid())

    _modules = []
    try:
        buf_count = 256
        needed = DWORD()
        # Grow the buffer until it becomes large enough to hold all the
        # module headers
        while True:
            buf = (HMODULE * buf_count)()
            buf_size = ctypes.sizeof(buf)
            if not ps_api.EnumProcessModulesEx(
                    h_process, ctypes.byref(buf), buf_size,
                    ctypes.byref(needed), LIST_MODULES_ALL):
                raise OSError('EnumProcessModulesEx failed')
            if buf_size >= needed.value:
                break
            buf_count = needed.value // (buf_size // buf_count)

        count = needed.value // (buf_size // buf_count)
        h_modules = map(HMODULE, buf[:count])

        # Loop through all the module headers and get the module path
        buf = ctypes.create_unicode_buffer(MAX_PATH)
        n_size = DWORD()
        for h_module in h_modules:

            # Get the path of the current module
            if not ps_api.GetModuleFileNameExW(
                    h_process, h_module, ctypes.byref(buf),
                    ctypes.byref(n_size)):
                raise OSError('GetModuleFileNameEx failed')
            filepath = buf.value

            # Store the module in cls_thread_locals._module if it is
            # supported and selected
            _get_module_info_from_path(filepath, prefixes, _modules)
    finally:
        kernel_32.CloseHandle(h_process)

    return _modules


def _get_libc():
    """Load the lib-C for unix systems."""
    libc = _system_libraries.get("libc")
    if libc is None:
        libc_name = find_library("c")
        if libc_name is None:  # pragma: no cover
            return None
        libc = ctypes.CDLL(libc_name)
        _system_libraries["libc"] = libc
    return libc


def _get_windll(dll_name):
    """Load a windows DLL"""
    dll = _system_libraries.get(dll_name)
    if dll is None:
        dll = ctypes.WinDLL("{}.dll".format(dll_name))
        _system_libraries[dll_name] = dll
    return dll
