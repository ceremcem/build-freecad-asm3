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
deps=$_sdir/deps

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

solvespace_0="libgtkmm-2.4-dev"
solvespace_deps="libpng12-0 libjson-c-dev libfreetype6-dev \
                libfontconfig1-dev libpangomm-1.4-dev \
                libgl-dev libglu-dev libglew-dev libspnav-dev"

# Install Dependencies
apt-get update && apt-get install -y \
		$pack_dev \
		$libBoost_dev \
		$pack_tools \
		$pack_netgen \
		$pack_occt \
		$pack_calculix \
		cmake

apt-get install $solvespace_0
apt-get install $solvespace_deps

apt-get install -y \
		libfreeimage3 \
		libtbb2 \
		libhdf5-100 \
		libfreetype6 \
		openssh-client \
		libhdf5-cpp-100 libjpeg-dev libjpeg62-turbo-dev zlib1g-dev \

$deps/libmed.sh
$deps/occt.sh
$deps/netgen.sh
$deps/vtk.sh
$deps/eigen.sh

$_sdir/install-fc.sh

#$deps/calculix.sh # FIXME can not generate `cgx`
$deps/gmsh.sh

