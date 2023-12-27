#!/bin/sh

set -e

git clone https://github.com/uit-anhvuk13/VulDetImp
cd VulDetImp
mkdir -p DATA/{FUN,CFG,RAW,WFG}
for i in DATA/*; do mkdir -p $i/{APP,VUL,PAT}; done
git clone https://github.com/leontsui1987/VulDetector
rm -rf VulDetector/.git*
cp -r src/DataPrepare VulDetector/
