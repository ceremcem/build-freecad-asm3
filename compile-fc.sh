#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh

echo "-------------------------------"
echo "Building in $build_dir"
echo "-------------------------------"
echo
build_dir=$(readlink -f $build_dir)

mkdir -p $build_dir
cd $build_dir
t0=$SECONDS

(cd $build_dir && cmake ../../FreeCAD \
	-DFREECAD_USE_OCC_VARIANT="Official Version" \
	-DCMAKE_BUILD_TYPE=$build_type \
	-DBUILD_QT5=ON \
	-DPYTHON_EXECUTABLE=/usr/bin/python3)
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
