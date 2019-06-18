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

RUN sudo apt-get update

ENV PATH /usr/local/clang-7.0.0/bin:$PATH

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

