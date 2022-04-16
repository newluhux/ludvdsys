#!/bin/sh

set -e
set -u

# 这里
POS=$(dirname $(realpath $0))

# 词典
cd $POS/dict/
wget https://github.com/skywind3000/ECDICT/releases/download/1.0.28/ecdict-stardict-28.zip
unzip ecdict-stardict-28.zip
rm ecdict-stardict-28.zip

# 源码
cd $POS/src/
git clone https://github.com/9fans/plan9port.git
cp -r `guix build -S drawterm` ./
cp -r `guix build -S busybox` ./
cp -r `guix build s9fes` ./
