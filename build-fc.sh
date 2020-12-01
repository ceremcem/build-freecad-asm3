#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh

### LinkStage3 latest Github commit
#----------------------------------
cd $HOME
branch=LinkStage3
#git fetch origin LinkDev:LinkDev
git clone --single-branch -b $branch https://github.com/realthunder/FreeCAD.git || { cd FreeCAD; git checkout $branch; git pull; }

echo "-------------------------------"
echo "Building in $build_dir"
echo "-------------------------------"
echo
sleep 3

mkdir -p $build_dir
cd $build_dir
t0=$SECONDS

cmake ../../FreeCAD \
	-DFREECAD_USE_OCC_VARIANT="Official Version" \
	-DCMAKE_BUILD_TYPE=$build_type \
	-DBUILD_QT5=ON \
	-DPYTHON_EXECUTABLE=/usr/bin/python3 
#	-DOpenCASCADE_DIR=$FREECAD/lib/cmake/opencascade \
#	-DOCC_INCLUDE_DIR=$FREECAD/include/opencascade 
# 	-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD 
#	-DNETGEN_ROOT=$FREECAD \
#	-DBUILD_FEM_NETGEN=ON

t1=$SECONDS
echo "-----------------------------------------------"
echo "Configuration done in $((t1 - t0))s"
echo "-> Compiling"
echo "-----------------------------------------------"
make -j${CPU}
t2=$SECONDS
echo "-----------------------------------------------"
echo "FreeCAD is compiled in $(( (t2 - t1) / 60 ))m"
echo "-----------------------------------------------"

# Install Assembly3 Workbench
$_sdir/install-asm3.sh
