# Build type
# Options: "Release" or "Debug"
build_type="Release"

# Directory for the output binary
build_dir="../fc-build/$build_type"

# FreeCAD git clone location:
src="$HOME/FreeCAD"

# Number of CPU to use while compiling
CPU=$(nproc)

# Configure branch
# latest: LinkDaily
# stable: LinkStage3
branch="LinkDaily"

# If you want to compile against a
# specific commit, uncomment below variable
#commit="19bb4c78bc"

# Uncomment to use a different git remote:
#remote="origin"
