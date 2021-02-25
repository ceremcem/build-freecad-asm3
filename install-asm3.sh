#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

if [[ -z ${1:-} ]]; then
    # eg.:
    # ./install-asm3 ~/fc-build/Release
    echo "Usage: $(basename $0) path/to/freecad/build-dir"
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

asm3="$(readlink -f $1)/Mod/asm3"

echo "Clone (or update) Assembly3 Workbench"
echo "-------------------------------------"
git_clone_or_update https://github.com/realthunder/FreeCAD_assembly3 $asm3
cd $asm3
git checkout master

echo "Installing SolveSpace solver backend"
$_sdir/install-slvs.sh "$asm3/freecad/asm3"

echo "Finished installing Assembly3 Workbench."
