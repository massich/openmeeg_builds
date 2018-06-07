set SRC_DIR=F:\openmeeg\
set BUILD_DIR=E:\openmeeg\build_massich
set INSTALL_DIR=%BUILD_DIR%\simulate_install_dir
set MY_CONDA_PATH="C:\conda\envs\matio-cmake\Library\lib\cmake"
set CMAKE_CONFIG="Release"

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
      --trace-source=Findmatio.cmake         ^
      %SRC_DIR% 

rem cmake --build . --config %CMAKE_CONFIG% 
rem nmake . VERBOSE=1
rem nmake install

cd -
