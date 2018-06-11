set SRC_DIR=F:\openmeeg\
set BUILD_DIR=E:\openmeeg\build_win
set INSTALL_DIR=%BUILD_DIR%\simulate_install_dir
set MY_CONDA_PATH="C:\conda\envs\matio-cmake\Library\lib\cmake"
set CMAKE_CONFIG="Release"
set VCOMP_PATH=" C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\x64\Microsoft.VC140.OpenMP\vcomp140.dll"
set matio_dir="C:\conda\envs\matio-cmake\Library\"

del /q %BUILD_DIR%\*
cd %BUILD_DIR%

cmake -LAH -G "NMake Makefiles"  ^
      -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%   ^
      -DCMAKE_CXX_STANDARD=11                ^
      -DBLA_VENDOR=Intel10_64lp              ^
      -DBLA_STATIC=ON                        ^
      -DCMAKE_PREFIX_PATH=%MY_CONDA_PATH%    ^
      -DCMAKE_VERBOSE_MAKEFILE=ON            ^
      -DVCOMP_PATH=%VCOMP_PATH%              ^
      --trace                       ^
      --trace-expand                ^
      --trace-source=CMakeLists.txt ^
      %SRC_DIR%                     

cmake --build . --config %CMAKE_CONFIG% 
cmake --build . --target install

cd ..
