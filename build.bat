set SRC_DIR=F:\openmeeg\
set BUILD_DIR=E:\openmeeg\build_conda_openmeeg
set INSTALL_DIR=%BUILD_DIR%\simulate_install_dir
set MY_CONDA_PATH="C:\conda\envs\matio-cmake\Library\lib\cmake"
set CMAKE_CONFIG="Release"
set matio_dir="c:\conda\envs\build-openmeeg\Library\bin"


rem "C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.0.124\windows\bin\compilervars_arch.bat" intel64 vs2015
rem "C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018\windows\mkl\bin\mklvars" intel64 ilp64 vs2015
rem conda activate build-openmeeg
rem conda install openblas=0.2.20 libmatio=1.5.12

del /q %BUILD_DIR%\*
cd %BUILD_DIR%

cmake -G "NMake Makefiles"  ^
      -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%   ^
      -DCMAKE_CXX_STANDARD=11                ^
      -DBLA_VENDOR=OpenBLAS                  ^
      -DENABLE_PYTHON=ON                     ^
      -DBLA_STATIC=OFF                       ^
      -DCMAKE_PREFIX_PATH=%MY_CONDA_PATH%    ^
      -DCMAKE_VERBOSE_MAKEFILE=ON            ^
      -DBUILD_DOCUMENTATION=OFF              ^
      %SRC_DIR%                     

cmake --build . --config %CMAKE_CONFIG% 
cmake --build . --target install --config %CMAKE_CONFIG% 

cd ..
