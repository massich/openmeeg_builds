# Travis second build ends up with the following command
# cmake ..  -DBLA_VENDOR=OpenBLAS -DENABLE_COVERAGE=ON -DENABLE_PYTHON=ON -DUSE_VTK=ON -DBUILD_DOCUMENTATION=ON
PR_NUM=fix_travis
BUILD_ID=0

export SRC_DIR=/home/travis/code/openmeeg/
export BUILD_DIR=/home/travis/openmeeg_build/build_$BUILD_ID_pr_$PR_NUM

# export SRC_DIR=/home/sik/code/openmeeg/
# export BUILD_DIR=/home/sik/Workspace/openmeeg/build_pr_368
INSTALL_DIR=$BUILD_DIR/simulate_install_dir


BACKEND=OpenBLAS
USE_VTK=OFF
# ENABLE_PYTHON=ON
# ANALYSE=ON
# ENABLE_COVERAGE=ON
# BUILD_DOCUMENTATION=ON
BUILD_TYPE=Debug

# Build with analyze
# export CC=$(which clang)
# export CXX=$(which clang++)
export CC=$(which gcc)
export CXX=$(which g++)
# export SCAN_BUILD="scan-build --status-bugs -o scanbuildout"
BUILD_TYPE=Debug

mkdir -p $BUILD_DIR && cd $BUILD_DIR
rm $BUILD_DIR/* -Rf
cmake $SRC_DIR -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR  \
               -DCMAKE_CXX_STANDARD=11 \
               -DBLA_VENDOR=$BACKEND \
               -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
               -DUSE_VTK=$USE_VTK \
               -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
                # -DCMAKE_C_FLAGS_DEBUG="-g -O0" \
                #      -DCMAKE_CXX_FLAGS_DEBUG="-g -O0" \

# cmake --build .
$SCAN_BUILD make
# ctest -VV -R check_geom_dip_outside

# make VERBOSE=1
# make install
# ctest -V . > /tmp/openmeeg_ctest_build_${BUILD_ID}_pr_${PR_NUM}.log

# cd -
