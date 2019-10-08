# https://docs.travis-ci.com/user/common-build-problems/#Running-a-Container-Based-Docker-Image-Locally

# Using tag from https://hub.docker.com/r/travisci/ci-garnet/tags/ because tag 'latest' not found
# (see issue https://github.com/travis-ci/travis-ci/issues/7518)

# Environment analyze:
# * https://travis-ci.org/travis-ci-tester/travis-trusty-env/builds/279929194

# FROM travisci/ci-garnet:packer-1515445631-7dfb2e1
FROM travisci/ci-ubuntu-1804:packer-1566551110-e45a2919

LABEL maintainer="Joan Massich <mailsik@gmail.com>"

USER travis

# From '.travis.yml':
# sources:
#   - ubuntu-toolchain-r-test
RUN sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN sudo apt-get update

# From '.travis.yml':
# packages:
#   - libopenblas-dev
#   - liblapacke-dev
#   - swig
#   - python-numpy
#   - doxygen
#   - graphviz
#   - libmatio4
#   - libmatio-dev
#   - libvtk6-dev
RUN sudo apt-get -y install libopenblas-dev liblapacke-dev swig python3-numpy doxygen graphviz libmatio4 libmatio-dev libvtk6-dev
RUN sudo apt-get -y install cmake

# From '.travis.yml':
# before_install:
# RUN sudo dpkg --add-architecture i386
# RUN sudo apt-get update
# RUN sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
# RUN sudo apt-get install -y lcov
# RUN sudo apt-get install binutils-2.26
# ENV PATH="/usr/lib/binutils-2.26/bin:${PATH}"

# Setup Travis variables
WORKDIR /home/travis
ENV BACKEND=OpenBLAS
ENV USE_VTK=ON
ENV ENABLE_PYTHON=ON
ENV ANALYSE=ON
ENV ENABLE_COVERAGE=ON
ENV BUILD_DOCUMENTATION=OFF

# # Missing things for debugging using LLDB
# RUN sudo add-apt-repository ppa:jonathonf/llvm
# RUN sudo apt-get update
# RUN sudo apt-get install clang-3.8 lldb-3.8
# RUN sudo update-alternatives --install /usr/bin/lldb-server lldb-server /usr/bin/lldb-server-3.8 100


# Set up HOST variables to access local repo from the container
RUN mkdir -p /home/travis/code/openmeeg
RUN mkdir -p /home/travis/openmeeg_build/
# RUN conda install hdf5
WORKDIR /home/travis/openmeeg_build/
# ENV SRC_DIR=/home/travis/code/openmeeg/
# RUN cmake $SRC_DIR -DCMAKE_CXX_STANDARD=11 \
#                    -DBLA_VENDOR=$BACKEND \
#                    -DCMAKE_BUILD_TYPE=Debug \
#                    -DUSE_VTK=$USE_VTK \
#                    -DCMAKE_C_FLAGS_DEBUG="-g -O0" \
#                    -DCMAKE_CXX_FLAGS_DEBUG="-g -O0" 

# ADD /home/sik/code/openmeeg /home/travis/code/openmeeg

# docker run -it --privileged -v /home/sik/code/openmeeg:/home/travis/code/openmeeg replicate_368 /bin/bash