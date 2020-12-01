#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh
#asm3=$build_dir/Ext/freecad/asm3
asm3=$HOME/.FreeCAD/Mod/asm3

echo "Clone (or update) Assembly3 Workbench"
echo "-------------------------------------"
git clone https://github.com/realthunder/FreeCAD_assembly3 $asm3 || { cd $asm3; git pull; } && cd $asm3
git checkout $Asm3_Commit

echo "Installing SolveSpace"
echo "-------------------"
sudo pip install py-slvs
echo "All done."
