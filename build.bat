set SRC_DIR=F:\openmeeg\
set BUILD_DIR=E:\openmeeg\build_pr_368_win
set INSTALL_DIR=%BUILD_DIR%\simulate_install_dir
set MY_CONDA_PATH="C:\conda\envs\matio-cmake\Library\lib\cmake"
set CMAKE_CONFIG="Release"

set matio_dir="C:\conda\envs\matio-cmake\Library\"

rem "C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.0.124\windows\bin\compilervars_arch.bat" intel64 vs2015
rem "C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018\windows\mkl\bin\mklvars" intel64 ilp64 vs2015
rem conda activate matio-cmake

del /q %BUILD_DIR%\*
cd %BUILD_DIR%

cmake -LAH -G "NMake Makefiles"  ^
      -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%   ^
      -DCMAKE_CXX_STANDARD=11                ^
      -DBLA_VENDOR=Intel10_64lp              ^
      -DBLA_STATIC=ON                        ^
      -DCMAKE_PREFIX_PATH=%MY_CONDA_PATH%    ^
      -DCMAKE_VERBOSE_MAKEFILE=ON            ^
      %SRC_DIR% 


cmake --build . --config %CMAKE_CONFIG% 
nmake . VERBOSE=1
nmake install

rem ctest -R test_foo -V
set PATH=%INSTALL_DIR%;%PATH%
ctest -v .

cd -
