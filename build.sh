PR_NUM=373
BUILD_ID=0

SRC_DIR=/home/sik/code/openmeeg/
BUILD_DIR=/home/sik/Workspace/openmeeg/build_${BUILD_ID}_pr_${PR_NUM}
INSTALL_DIR=$BUILD_DIR/simulate_install_dir


BACKEND=OpenBLAS
USE_VTK=ON
# ENABLE_PYTHON=ON
# ANALYSE=ON
# ENABLE_COVERAGE=ON
# BUILD_DOCUMENTATION=ON

mkdir -p $BUILD_DIR && cd $BUILD_DIR
rm $BUILD_DIR/* -Rf
cmake $SRC_DIR -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR  \
               -DCMAKE_CXX_STANDARD=11 \
               -DBLA_VENDOR=$BACKEND \
               -DCMAKE_BUILD_TYPE=Debug \
               -DUSE_VTK=$USE_VTK \
               -DCMAKE_C_FLAGS_DEBUG="-g -O0" \
               -DCMAKE_CXX_FLAGS_DEBUG="-g -O0" \

make VERBOSE=1
make install
ctest -V . > /tmp/openmeeg_ctest_build_${BUILD_ID}_pr_${PR_NUM}.log

# cd -
