#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh

### LinkStage3 latest Github commit
#----------------------------------
cd $HOME
branch=LinkStage3
remote=origin
src="$HOME/FreeCAD"
[[ -d $src ]] || git clone --single-branch -b $branch https://github.com/realthunder/FreeCAD.git
cd $src
git checkout $branch
git reset --hard $remote/$branch
git pull
#git branch --set-upstream-to $remote # do not forcefully track the origin, create a warning instead.

for patch in *.patch; do
    echo "Trying to apply patch: $patch"
    git apply --stat $patch && git apply --check $patch && git am < $patch
done

echo "-------------------------------"
echo "Building in $build_dir"
echo "-------------------------------"
echo
sleep 3
build_dir=$(readlink -f $build_dir)

mkdir -p $build_dir
cd $build_dir
t0=$SECONDS

(cd $build_dir && cmake ../../FreeCAD \
	-DFREECAD_USE_OCC_VARIANT="Official Version" \
	-DCMAKE_BUILD_TYPE=$build_type \
	-DBUILD_QT5=ON \
	-DPYTHON_EXECUTABLE=/usr/bin/python3 \
)
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

mkdir -p $_sdir/latest-build
cp $build_dir/src/Build/Version.h $_sdir/latest-build/Version.h

# Install Assembly3 Workbench
$_sdir/install-asm3.sh $build_dir
