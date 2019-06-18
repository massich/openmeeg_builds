# https://docs.travis-ci.com/user/common-build-problems/#Running-a-Container-Based-Docker-Image-Locally

# Using tag from https://hub.docker.com/r/travisci/ci-garnet/tags/ because tag 'latest' not found
# (see issue https://github.com/travis-ci/travis-ci/issues/7518)

# Environment analyze:
# * https://travis-ci.org/travis-ci-tester/travis-trusty-env/builds/279929194

FROM travisci/ci-garnet:packer-1515445631-7dfb2e1

MAINTAINER Joan Massich <mailsik@gmail.com>

USER travis

# From '.travis.yml':
# sources:
#   - ubuntu-toolchain-r-test
RUN sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

# From '.travis.yml':
# packages:
#   - libopenblas-dev
#   - liblapacke-dev
#   - swig
#   - python-numpy
#   - doxygen
#   - graphviz
RUN sudo apt-get -y install libopenblas-dev liblapacke-dev swig python-numpy doxygen graphviz

# From '.travis.yml':
# before_install:
RUN sudo dpkg --add-architecture i386
RUN sudo apt-get update
RUN sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
RUN sudo apt-get install -y lcov
RUN sudo apt-get install binutils-2.26
RUN export PATH=/usr/lib/binutils-2.26/bin:${PATH}

# Install cmake v
RUN sudo apt-get purge cmake
ENV CMAKE_VERSION=3.10.1
RUN curl -fsSkL https://raw.githubusercontent.com/openmeeg/ci-utils/master/travis/install_cmake.sh > x.sh && source ./x.sh

# Setup Travis variables
WORKDIR /home/travis
ENV BACKEND=OpenBLAS
ENV USE_VTK=ON
ENV ENABLE_PYTHON=ON
ENV ANALYSE=ON
ENV ENABLE_COVERAGE=ON
ENV BUILD_DOCUMENTATION=ON

