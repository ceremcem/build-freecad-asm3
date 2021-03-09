build_type="Release"	# Options: "Release" or "Debug"
build_dir=$(readlink -m "../fc-build/$build_type")
src="$HOME/FreeCAD"
CPU=$(nproc)
