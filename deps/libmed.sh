#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/../config.sh

### libMED 3.2.0
#----------------

MAKEDIR=med \
	&& cd \
	&& mkdir -p $MAKEDIR \
	&& cd $MAKEDIR 
	git clone https://github.com/luvres/libMED.git || { cd libMED && git pull && cd ..; }

  # building MED
	mkdir -p build \
	&& cd build \
  \
	&& cmake ../libMED \
		-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
  \
	&& make -j$(nproc) \
	&& make install
