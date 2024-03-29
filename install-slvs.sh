#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

# Usage
asm3=${1:-}
if [[ ! -d $asm3 ]]; then
    cat << EOL

    Error: "$asm3" is not a directory.

    Usage: $(basename $0) path/to/asm3/freecad/asm3

EOL
	exit 1
fi

git_clone_or_update (){
    local url=$1
    local dir=$2
    if [[ -d $dir/.git ]]; then
	echo "+ cd $dir"
        ( cd $dir; git pull)
    else
        git clone $url $dir
    fi
}

py_slvs_dir="$asm3/py3_slvs"
echo "Clone (or update) $(basename $py_slvs_dir)"
echo "-------------------------------------"
git_clone_or_update https://github.com/realthunder/solvespace.git $asm3/slvs
cd $asm3/slvs
git submodule update --init extlib/libdxfrw
mkdir -p build && cd build
cmake -DBUILD_PYTHON=1 -DPYTHON_EXECUTABLE:FILEPATH='/usr/bin/python3' -Wno-dev ..
make
#sudo make install # In order not to use "sudo", we do "make local-install"
# start "make local-install"
set -x
mkdir -p $py_slvs_dir
cp $asm3/slvs/build/src/swig/python/{slvs.py,_slvs.so} $py_slvs_dir
touch $py_slvs_dir/__init__.py
set +x
# end of "make local-install"
echo "$(basename $py_slvs_dir) is compiled."
