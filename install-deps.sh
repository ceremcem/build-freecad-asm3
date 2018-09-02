#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

## References:
# https://gist.github.com/berndhahnebach/38d5bfe73134928c0a1ad001a94df05f
# https://github.com/berndhahnebach/Netgen
# https://sourceforge.net/p/netgen-mesher/wiki/Home/
# https://aur.archlinux.org/packages
# http://www.boost.org/doc/libs/1_64_0/more/getting_started/unix-variants.html

safe_source $_sdir/config.sh

pack_dev=" \
		doxygen \
		libpyside-dev \
		libqtcore4 \
		libshiboken-dev \
		libxerces-c-dev \
		libxmu-dev \
		libxmu-headers \
		libxmu6 \
		libxmuu-dev \
		libxmuu1 \
		libqtwebkit-dev \
		pyside-tools \
		python-pivy \
		python-pyside \
		python-matplotlib \
		swig " 

libBoost_dev=" \
		libboost-filesystem1.62-dev \
		libboost-program-options1.62-dev \
		libboost-python1.62-dev \
		libboost-regex1.62-dev \
		libboost-signals1.62-dev \
		libboost-system1.62-dev \
		libboost-thread1.62-dev " 

pack_tools=" \
		automake \
		dictionaries-common \
		git \
		wget \
		g++ \
		tcl8.5-dev \
		tk8.5-dev \
		libcoin80-dev \
		libhdf5-dev \
		libfreetype6-dev \
		python-dev \
		qt4-dev-tools \
		qt4-qmake " 

pack_netgen=" \
		openmpi-bin \
		libopenmpi-dev \
		libtogl-dev " 

pack_occt=" \
		libfreeimage-dev \
		libtbb-dev " 

pack_calculix=" \
		gfortran \
		cpio " 

# Enable backports (cmake 3.6.2) "cmake 3.3 or higher" required by VTK 8
echo 'deb http://deb.debian.org/debian jessie-backports main' \
			>/etc/apt/sources.list.d/backports.list \
	&& apt-get update \
	&& apt-get install -y \
		$pack_dev \
		$libBoost_dev \
		$pack_tools \
		$pack_netgen \
		$pack_occt \
		$pack_calculix \
  \
  `# cmake 3.6.2` \
	&& apt-get -t jessie-backports install -y cmake \
  \
  `### libMED 3.2.0` \
  `#----------------` \
	&& MAKEDIR=med \
	&& cd \
	&& mkdir -p $MAKEDIR \
	&& cd $MAKEDIR 
	git clone https://github.com/luvres/libMED.git || { cd libMED && git pull && cd ..; }

  # building MED
	mkdir build \
	&& cd build \
  \
	&& cmake ../libMED \
		-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
  \
	&& make -j$(nproc) \
	&& make install \
  \
  `### OCCT 7.1.0p1 -> libfreeimage-dev libfreeimage3 libtbb-dev libtbb2` \
  `#----------------` \
	&& MAKEDIR=occt \
	&& cd \
	&& mkdir -p $MAKEDIR \
	&& cd $MAKEDIR 
	git clone https://github.com/luvres/occt71.git || { cd occt71 && git pull && cd ..; }
	mkdir build \
	&& cd build \
  \
	&& cmake \
		../occt71 \
		-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
		-DUSE_VTK:BOOL=OFF \
		-DUSE_TBB:BOOL=ON \
		-DUSE_FREEIMAGE:BOOL=ON \
		-DCMAKE_BUILD_TYPE=Release \
  \
	&& make -j$(nproc) \
	&& make install \
  \
  `### Netgen 5.3.1` \
  `#----------------` \
	&& cd \
	&& git clone https://github.com/luvres/netgen.git || { cd netgen && git pull && cd ..; } \
	&& cd netgen \
  \
	`# building Netgen` \
	&& ./configure \
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
		CXXFLAGS="-DNGLIB_EXPORTS -std=gnu++11" \
  \
	&& make -j$(nproc) \
	&& make install \
  \
	&& cp -fR libsrc $FREECAD/libsrc \
  \
  `### Eigen 3.3.4` \
  `#---------------` \
  `# http://eigen.tuxfamily.org/index.php?title=Main_Page` \
	&& eigen_VERSION=3.3.4 \
  \
	&& MAKEDIR=eigen \
	&& cd \
	&& mkdir $MAKEDIR \
	&& cd $MAKEDIR \
	&& wget -c http://bitbucket.org/eigen/eigen/get/${eigen_VERSION}.tar.gz \
	&& tar zxf ${eigen_VERSION}.tar.gz \
	&& rm ${eigen_VERSION}.tar.gz \
	&& mv eigen-* eigen-${eigen_VERSION} \
	&& mkdir build \
	&& cd build \
  \
    && cmake ../eigen-${eigen_VERSION} \
        -DCMAKE_INSTALL_PREFIX=$FREECAD \
        -DCMAKE_C_FLAGS_RELEASE=-DNDEBUG \
        -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
  \
    && make install \
  `### VTK 8.1.0` \
  `#-------------` \
	&& vtk_VERSION_MAJOR=8.1 \
	&& vtk_VERSION_MINOR=8.1.0 \
  \
	&& MAKEDIR=vtk \
	&& cd \
	&& mkdir $MAKEDIR \
	&& cd $MAKEDIR \
	&& wget http://www.vtk.org/files/release/${vtk_VERSION_MAJOR}/VTK-${vtk_VERSION_MINOR}.tar.gz \
	&& gunzip VTK-${vtk_VERSION_MINOR}.tar.gz \
	&& tar xf VTK-${vtk_VERSION_MINOR}.tar \
	&& rm VTK-${vtk_VERSION_MINOR}.tar \
  `# building VTK` \
	&& mkdir build \
	&& cd build \
  \
	&& cmake ../VTK-${vtk_VERSION_MINOR} \
			-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
			-DVTK_Group_Rendering:BOOL=OFF \
			-DVTK_Group_StandAlone:BOOL=ON \
			-DVTK_RENDERING_BACKEND=None \
  \
	&& make -j$(nproc) \
	&& make install \
  \
  `### Calculix and CGX` \
  `#-------------------------` \
	&& cd
	git clone https://github.com/luvres/calculix.git || { cd calculix && git pull && cd ..; }
	cd calculix/ \
        && ccx_VERSION=`cat ./install | grep "export PROGSDIR=" | sed 's/^.*CalculiX-//'` \
	&& ./install \
	&& cp $HOME/CalculiX-${ccx_VERSION}/bin/ccx_${ccx_VERSION} /usr/bin/ccx \
	&& cp $HOME/CalculiX-${ccx_VERSION}/bin/cgx /usr/bin/cgx \
  `# Clean` \
	&& cd && rm CalculiX-${ccx_VERSION} calculix -fR \
  \
	&& apt-get install -y \
	  \
		libfreeimage3 \
		libtbb2 \
		libhdf5-8 \
		libfreetype6 \
		openssh-client \
		libhdf5-cpp-8 libjpeg-dev libjpeg62-turbo-dev zlib1g-dev \
  \
  `# gmsh 2.11.0` \
	&& apt-get install -y gmsh 
