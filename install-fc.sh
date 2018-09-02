#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh

cd
### FreeCAD latest Github commit
#--------------------------------` \
# get FreeCAD` \
git clone --single-branch -b LinkStage3 https://github.com/realthunder/FreeCAD.git || { cd FreeCAD && git pull; }
#cd FreeCAD/ext/
#https://github.com/realthunder/FreeCAD_assembly3

# building FreeCAD
cd && mkdir -p build && cd build


cmake ../FreeCAD \
	-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
	-DOCC_INCLUDE_DIR=$FREECAD/include/opencascade \
	-DNETGEN_ROOT=$FREECAD \
	-DBUILD_FEM_NETGEN=ON

# Make FreeCAD
cd && cd build
make -j$(nproc)

# Install FreeCAD` \
make install
ln -sf /opt/FreeCAD/bin/FreeCAD /usr/bin/freecad-git

$_sdir/update-asm3.sh
