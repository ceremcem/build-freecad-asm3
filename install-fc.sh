#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/config.sh

### LinkStage3 latest Github commit
#----------------------------------
cd
git clone --single-branch -b LinkStage3 https://github.com/realthunder/FreeCAD.git || { cd FreeCAD && git pull; }

echolog(){
	echo $@ | tee -a build.log
}


# build
build(){
	local build_dir=$1
	local build_type=$2
	local CPU=$3
	local do_install=$4

	[[ $CPU -gt $(nproc) ]] && CPU=$(nproc)

	echo
	echo "-------------------------------"
	echolog "Building in $build_dir"
	echo "-------------------------------"
	echo
	sleep 3

	mkdir -p $build_dir && cd $build_dir
	t0=$SECONDS
	cmake ../../FreeCAD \
	 	-DCMAKE_INSTALL_PREFIX:PATH=$FREECAD \
		-DOCC_INCLUDE_DIR=$FREECAD/include/opencascade \
		-DFREECAD_USE_OCC_VARIANT="Official Version" \
		-DOpenCASCADE_DIR=$FREECAD/lib/cmake/opencascade \
		-DCMAKE_BUILD_TYPE=$build_type \
		-DNETGEN_ROOT=$FREECAD \
		-DBUILD_FEM_NETGEN=ON

	t1=$SECONDS
	echolog "-----------------------------------------------"
	echolog "Configuration done in $((t1 - t0))s"
	echolog "-> Compiling"
	echo "-----------------------------------------------"
	make -j${CPU}
	t2=$SECONDS
	echolog "-----------------------------------------------"
	echolog "FreeCAD is compiled in $(( (t2 - t1) / 60 ))m"
	echolog "-> Installing Asm3"
	echo "-----------------------------------------------"

	# Install
	if [[ $do_install = true ]]; then
		make install
		ln -sf $FREECAD/bin/FreeCAD /usr/bin/freecad-git
	fi
}

build_root="/root/fc-build"

debug_build(){
	local do_install=$1
	build "${build_root}/Debug" Debug $DEBUG_CPU $do_install
}

release_build(){
	local do_install=$1
	build "${build_root}/Release" Release $RELEASE_CPU $do_install
}

if [[ $DEBUG_CPU -ge $RELEASE_CPU ]]; then
	# Build debug target first and install it
	debug_build true

	# Build release target, do not install it
	[[ $RELEASE_CPU -gt 0 ]] && release_build false
else
	release_build true

	# Build release target, do not install it
	[[ $DEBUG_CPU -gt 0 ]] && debug_build false
fi


# Install Assembly3 Workbench
$_sdir/install-asm3.sh
