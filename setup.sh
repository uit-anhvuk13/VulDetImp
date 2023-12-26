#!/bin/sh

set -e

git clone https://github.com/uit-anhvuk13/VulDetImp
cd VulDetImp
mkdir -p DATA/{FUN,CFG,RAW,WFG}
for i in DATA/*; do mkdir -p $i/{APP,VUL,PAT}; done
git clone https://github.com/leontsui1987/VulDetector
rm -rf VulDetector/.git*
cp -r src/* VulDetector
mkdir -p DATA/RAW/APP/OpenSSL && cd DATA/RAW/APP/OpenSSL
wget https://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2.tar.gz
wget https://ftp.openssl.org/source/openssl-3.2.0.tar.gz
tar -xvf openssl-1.0.2.tar.gz
tar -xvf openssl-3.2.0.tar.gz
rm openssl-1.0.2.tar.gz
rm openssl-3.2.0.tar.gz
