#!/bin/bash
set -eo pipefail
VERSION=1
brew update
brew install git cmake python libtool libusb graphviz automake wget gmp pkgconfig doxygen openssl jq postgres rabbitmq || :
# install clang from source
git clone --single-branch --branch llvmorg-10.0.0 https://github.com/llvm/llvm-project clang10
mkdir clang10/build
cd clang10/build
cmake -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX='/usr/local' -DLLVM_ENABLE_PROJECTS='lld;polly;clang;clang-tools-extra;libcxx;libcxxabi;libunwind;compiler-rt' -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_INCLUDE_DOCS=OFF -DLLVM_TARGETS_TO_BUILD=host -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_Z3_SOLVER=OFF -DCOMPILER_RT_INCLUDE_TESTS=0 -DCOMPILER_RT_BUILD_SANITIZERS=0 -DCOMPILER_RT_BUILD_XRAY=0 ../llvm && \
make -j $(getconf _NPROCESSORS_ONLN)
sudo make install
cd ../..
rm -rf clang10
# set enviroment variables
export LIBRARY_PATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib:$LIBRARY_PATH
export CPLUS_INCLUDE_PATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include:$CPLUS_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1:$CPLUS_INCLUDE_PATH
# install boost from source
curl -LO https://boostorg.jfrog.io/artifactory/main/release/1.72.0/source/boost_1_72_0.tar.bz2
tar -xjf boost_1_72_0.tar.bz2
cd boost_1_72_0
./bootstrap.sh --prefix=/usr/local
sudo -E ./b2 --with-iostreams --with-date_time --with-filesystem --with-system --with-program_options --with-chrono --with-test -q -j$(getconf _NPROCESSORS_ONLN) install
cd ..
sudo rm -rf boost_1_72_0.tar.bz2 boost_1_72_0

# install nvm for ship_test
cd ~ && brew install nvm && mkdir -p ~/.nvm && echo "export NVM_DIR=$HOME/.nvm" >> ~/.bash_profile && echo 'source $(brew --prefix nvm)/nvm.sh' >> ~/.bash_profile && cat ~/.bash_profile && source ~/.bash_profile && echo $NVM_DIR && nvm install --lts=dubnium
# add sbin to path from rabbitmq-server
echo "export PATH=$PATH:/usr/local/sbin" >> ~/.bash_profile
# initialize postgres configuration files
sudo rm -rf /usr/local/var/postgres
initdb --locale=C -E UTF-8 /usr/local/var/postgres