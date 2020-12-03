#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

Asm3_Commit="master"

[[ -z ${1:-} ]] && { echo "Usage: $(basename $0) path/to/freecad/build-dir"; exit 1; }
asm3="$(readlink -f $1)/Mod/asm3"

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

$_sdir/install-slvs.sh "$asm3/freecad/asm3"
echo "All done."
