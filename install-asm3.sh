#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate


safe_source $_sdir/config.sh

asm3=$FREECAD/Ext/freecad/asm3

echo "Clone (or update) Assembly3 Workbench"
echo "-------------------------------------"
git clone https://github.com/realthunder/FreeCAD_assembly3 $asm3 || { cd $asm3; git pull; } && cd $asm3

echo "Building SolveSpace"
echo "-------------------"
git submodule update --init slvs
cd $asm3/slvs
mkdir -p build && cd build
cmake -DBUILD_PYTHON=1 ..
make _slvs
cp $asm3/slvs/build/src/swig/python/{slvs.py,_slvs.so} $asm3/py_slvs
touch $asm3/py_slvs/__init__.py

