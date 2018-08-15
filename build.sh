SRC_DIR=/home/sik/code/openmeeg/
BUILD_DIR=/home/sik/Workspace/openmeeg/build_linux_db
INSTALL_DIR=$BUILD_DIR/simulate_install_dir

cd $BUILD_DIR
rm $BUILD_DIR/* -Rf
cmake $SRC_DIR -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR  \
               -DCMAKE_CXX_STANDARD=11 \
               -DBLA_VENDOR=Intel10_64lp \
               -DCMAKE_BUILD_TYPE=Debug \
               -DCMAKE_C_FLAGS_DEBUG="-g -O0" \
               -DCMAKE_CXX_FLAGS_DEBUG="-g -O0" \

make VERBOSE=1
make install

cd -
