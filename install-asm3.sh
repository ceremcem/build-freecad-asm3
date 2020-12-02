#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh
asm3=$build_dir/Mod/asm3
#asm3=$HOME/.FreeCAD/Mod/asm3

echo "Clone (or update) Assembly3 Workbench"
echo "-------------------------------------"

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

git_clone_or_update https://github.com/realthunder/FreeCAD_assembly3 $asm3
cd $asm3
git checkout $Asm3_Commit

echo "Installing SolveSpace"
echo "-------------------"

echo "FIXME! Solvespace is not found"
exit 1
#[ -f $asm3/slvs/.git ] && mv $asm3/slvs $asm3/slvs.old-version
#git_clone_or_update https://github.com/realthunder/solvespace.git $asm3/slvs
#cd $asm3/slvs
#git submodule update --init extlib/libdxfrw
#mkdir -p build && cd build
#cmake -DBUILD_PYTHON=1 -DPYTHON_EXECUTABLE:FILEPATH='/usr/bin/python2' ..
#make _slvs
#mkdir -p $asm3/py_slvs
#cp $asm3/slvs/build/src/swig/python/{slvs.py,_slvs.so} $asm3/py_slvs
#touch $asm3/py_slvs/__init__.py

echo "All done."
