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

# building FreeCAD
cd && mkdir -p fc-build && cd fc-build

cmake 	-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
	-DOCC_INCLUDE_DIR=$FREECAD/include/opencascade \
	-DFREECAD_USE_OCC_VARIANT="Official Version" \
	../FreeCAD
#	-DNETGEN_ROOT=$FREECAD
#	-DBUILD_FEM_NETGEN=ON

cd && cd fc-build
make -j$(nproc)

# Install FreeCAD
make install
ln -sf /opt/FreeCAD/bin/FreeCAD /usr/bin/freecad-git

# Install Assembly3 Workbench
$_sdir/update-asm3.sh
