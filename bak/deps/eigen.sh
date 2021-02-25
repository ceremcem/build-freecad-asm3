#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/../config.sh

### Eigen 3.3.4
#---------------
# http://eigen.tuxfamily.org/index.php?title=Main_Page
eigen_VERSION=3.3.4 \
  \
	&& MAKEDIR=eigen \
	&& cd \
	&& mkdir -p $MAKEDIR \
	&& cd $MAKEDIR

eigen_dir="eigen-${eigen_VERSION}"
eigen_tgz="${eigen_VERSION}.tar.gz"
if [[ ! -d $eigen_dir ]]; then
	[[ -f $eigen_tgz ]] || wget -c http://bitbucket.org/eigen/eigen/get/$eigen_tgz
	tar zxf $eigen_tgz
	mv eigen-* $eigen_dir
fi

mkdir -p eigen-build && cd eigen-build
cmake ../$eigen_dir \
        -DCMAKE_INSTALL_PREFIX=$FREECAD \
        -DCMAKE_C_FLAGS_RELEASE=-DNDEBUG \
        -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
  \
    && make install 

