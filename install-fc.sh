#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh

### LinkStage3 latest Github commit
#----------------------------------
cd
git clone --single-branch -b LinkStage3 https://github.com/realthunder/FreeCAD.git || { cd FreeCAD && git pull; }

[[ $DEBUG = true ]] && build_type="Debug" || build_type="Release"

echo
echo "-------------------------------"
echo "Building for $build_type target"
echo "-------------------------------"
echo
sleep 3

build_dir="fc-build-${build_type}"

# build
cd
mkdir -p $build_dir && cd $build_dir
t0=$SECONDS
cmake ../FreeCAD \
 	-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
	-DOCC_INCLUDE_DIR=$FREECAD/include/opencascade \
	-DFREECAD_USE_OCC_VARIANT="Official Version" \
	-DOpenCASCADE_DIR=$FREECAD/lib/cmake/opencascade \
	-DCMAKE_BUILD_TYPE=$build_type \
	-DNETGEN_ROOT=$FREECAD \
	-DBUILD_FEM_NETGEN=ON

t1=$SECONDS
echo "-----------------------------------------------"
echo "Configuration done in $((t1 - t0))s"
echo "-> Compiling"
echo "-----------------------------------------------"
make -j${CPU}

# Install
make install
ln -sf $FREECAD/bin/FreeCAD /usr/bin/freecad-git

t2=$SECONDS
echo "-----------------------------------------------"
echo "FreeCAD is built in $(( (t2 - t1) / 60 ))m"
echo "-> Installing Asm3"
echo "-----------------------------------------------"

# Install Assembly3 Workbench
$_sdir/install-asm3.sh
