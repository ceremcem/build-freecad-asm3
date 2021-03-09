#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

cd $_sdir/.. && . config.sh && cd $OLDPWD

### Netgen 5.3.1
#----------------
cd $HOME
[[ -d netgen ]] \
	|| git clone https://github.com/luvres/netgen.git \
	&& ( cd netgen && git pull )
cd netgen

#OCC_DIR=$build_dir
OCC_DIR=/usr

# building Netgen
./configure \
	--prefix=$build_dir \
	--enable-occ \
	--with-occ=$OCC_DIR \
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
set -x
cp -fR libsrc $build_dir/libsrc
