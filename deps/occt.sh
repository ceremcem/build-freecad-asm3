#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

cd $_sdir/.. && . config.sh && cd $OLDPWD
occt_dir=$HOME/occt
url="https://github.com/Open-Cascade-SAS/OCCT/archive/V7_3_0.zip"

mkdir -p $occt_dir
cd $occt_dir

$_sdir/download.sh $url --unzip
src=$(basename $url .zip)

mkdir -p "build/$src"
cd "build/$src"

cmake \
	../../$src \
	-DCMAKE_INSTALL_PREFIX:PATH=$build_dir \
	-DUSE_VTK:BOOL=OFF \
	-DUSE_TBB:BOOL=ON \
	-DUSE_FREEIMAGE:BOOL=ON \
	-DCMAKE_BUILD_TYPE=Release

make -j$(nproc)
make install

