#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/../config.sh

### OCCT 7.3
#----------------
MAKEDIR=occt \
	&& cd \
	&& mkdir -p $MAKEDIR \
	&& cd $MAKEDIR

git clone https://github.com/ceremcem/occt73.git || { cd occt73 && git pull && cd ..; }
mkdir -p build \
	&& cd build \
  \
	&& cmake \
		../occt73 \
		-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
		-DUSE_VTK:BOOL=OFF \
		-DUSE_TBB:BOOL=ON \
		-DUSE_FREEIMAGE:BOOL=ON \
		-DCMAKE_BUILD_TYPE=Release \
  \
	&& make -j$(nproc) \
	&& make install

