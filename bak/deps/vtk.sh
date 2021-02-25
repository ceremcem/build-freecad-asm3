#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/../config.sh

### VTK 8.1.0
#-------------
vtk_VERSION_MAJOR=8.1 \
	&& vtk_VERSION_MINOR=8.1.0 \
  \
	&& MAKEDIR=vtk \
	&& cd \
	&& mkdir -p $MAKEDIR \
	&& cd $MAKEDIR

vtk_dir="VTK-${vtk_VERSION_MINOR}"
vtk_tgz="${vtk_dir}.tar.gz"
if [[ ! -d $vtk_dir ]]; then
	if [[ ! -f ${vtk_tgz%.gz} ]]; then
		wget http://www.vtk.org/files/release/${vtk_VERSION_MAJOR}/VTK-${vtk_VERSION_MINOR}.tar.gz
		gunzip $vtk_tgz
	fi
	tar xf ${vtk_tgz%.gz}
fi

# building VTK
mkdir -p build && cd build
cmake ../$vtk_dir \
	-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
	-DVTK_Group_Rendering:BOOL=OFF \
	-DVTK_Group_StandAlone:BOOL=ON \
	-DVTK_RENDERING_BACKEND=None \
  \
	&& make -j$(nproc) \
	&& make install 


