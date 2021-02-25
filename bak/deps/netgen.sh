#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/../config.sh

### Netgen 5.3.1
#----------------
cd \
	&& git clone https://github.com/luvres/netgen.git || { cd netgen && git pull && cd ..; } \
	&& cd netgen

# building Netgen
./configure \
	--prefix=$FREECAD \
	--enable-occ \
	--with-occ=$FREECAD \
	--with-tcl=/usr/lib/tcl8.5 \
	--with-tk=/usr/lib/tk8.5 \
	--with-togl=/usr/lib/ \
	--enable-shared \
	--enable-nglib \
	--disable-gui \
	--disable-dependency-tracking \
	CXXFLAGS="-DNGLIB_EXPORTS -std=gnu++11"

make -j$(nproc)
make install
cp -fR libsrc $FREECAD/libsrc

