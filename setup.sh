#!/bin/sh

set -e

git clone https://github.com/uit-anhvuk13/VulDetImp code
cd code
mkdir -p input output
git clone https://github.com/leontsui1987/VulDetector
rm -rf VulDetector/.git*
cp -r src/* VulDetector
cd input
wget https://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2.tar.gz
wget https://ftp.openssl.org/source/openssl-3.2.0.tar.gz
tar -xvf openssl-1.0.2.tar.gz
tar -xvf openssl-3.2.0.tar.gz
