#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

git_clone_or_update (){
    local url=$1
    local dir=$2
    if [[ -d $dir/.git ]]; then
	echo "changing to $dir"
        ( cd $dir; git pull)
    else
        git clone $url $dir
    fi
}

asm3=${1:-}
[[ -e $asm3 ]] || \
	{ echo "Usage: $(basename $0) path/to/asm3/freecad/asm3 ($asm3 is not a directory.)"; exit 1; }

echo "Clone (or update) py_slvs"
echo "-------------------------------------"
py_slvs_dir="$asm3/py3_slvs"

git_clone_or_update https://github.com/realthunder/solvespace.git $asm3/slvs
cd $asm3/slvs
git submodule update --init extlib/libdxfrw
mkdir -p build && cd build
cmake -DBUILD_PYTHON=1 -DPYTHON_EXECUTABLE:FILEPATH='/usr/bin/python3' ..
make _slvs
mkdir -p $py_slvs_dir
cp $asm3/slvs/build/src/swig/python/{slvs.py,_slvs.so} $py_slvs_dir
touch $py_slvs_dir/__init__.py

echo "All done."
