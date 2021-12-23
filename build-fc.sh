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

show_help(){
    cat <<HELP
    $(basename $0) [options]

    Fetches changes from the remote and then compiles it accordingly.
    Uses config.sh/\$src as FreeCAD git source directory.

    Options:
        --only-fetch    : Only fetch from remote, do not compile.
                          Useful for preparation to offline compilation.
        --only-compile  : Do not fetch from git remote, only compile.
                          Useful for local hacks.
        --disable-fem   : Disable FEM Module
HELP
}

die(){
    >&2 echo
    >&2 echo "$@"
    >&2 echo
    exit 1
}

help_die(){
    >&2 echo
    >&2 echo "$@"
    show_help
    exit 1
}

# Parse command line arguments
# ---------------------------
# Initialize parameters
only_compile=false
only_fetch=false
disable_fem=false
# ---------------------------
args_backup=("$@")
args=()
_count=1
while [ $# -gt 0 ]; do
    key="${1:-}"
    case $key in
        -h|-\?|--help|'')
            show_help    # Display a usage synopsis.
            exit
            ;;
        # --------------------------------------------------------
        --only-compile)
            only_compile=true
            ;;
        --only-fetch)
            only_fetch=true
            ;;
        --disable-fem)
            disable_fem=true
            ;;
        # --------------------------------------------------------
        -*) # Handle unrecognized options
            help_die "Unknown option: $1"
            ;;
        *)  # Generate the new positional arguments: $arg1, $arg2, ... and ${args[@]}
            if [[ ! -z ${1:-} ]]; then
                declare arg$((_count++))="$1"
                args+=("$1")
            fi
            ;;
    esac
    [[ -z ${1:-} ]] && break || shift
done; set -- "${args_backup[@]-}"
# Use $arg1 in place of $1, $arg2 in place of $2 and so on, 
# "$@" is in the original state,
# use ${args[@]} for new positional arguments

cd $_sdir
. config.sh
build_dir=$(readlink -m $build_dir)
cd $OLDPWD

if ! $only_compile; then
    ### LinkStage3 latest Github commit
    #----------------------------------
    [[ -z "${branch:-}" ]] && die "\$branch variable must be set within config.sh."
    remote=${remote:-origin}
    cd "$(dirname "$src")"
    [[ -d $src ]] || git clone --single-branch -b $branch https://github.com/realthunder/FreeCAD.git
    cd $src
    if git checkout $branch 2> /dev/null; then
        echo "Branch \"$branch\" exists."
        echo "Pulling new commits"
        git fetch $remote $branch
        git --no-pager diff --stat HEAD FETCH_HEAD
        git reset --hard FETCH_HEAD
    else
        echo "Branch \"$branch\" does not exist, fetching."
        git fetch $remote $branch
        git --no-pager diff --stat HEAD FETCH_HEAD
        git checkout FETCH_HEAD -b $branch
    fi
    [[ -n ${commit:-} ]] && git checkout $commit

    #git branch --set-upstream-to $remote # do not forcefully track the origin, create a warning instead.
    $only_fetch && exit 0
else
    cd $src
fi

# Apply any available patches
if ls *.patch &> /dev/null; then
    for patch in *.patch; do
        echo "Trying to apply patch: $patch"
        git apply --stat $patch && git apply --check $patch && git am < $patch
    done
fi

echo "-------------------------------"
echo "Building in $build_dir"
echo "-------------------------------"
echo

mkdir -p $build_dir
cd $build_dir
t0=$SECONDS

opts=
$disable_fem || opts="$opts -DBUILD_FEM_NETGEN=1"

(cd $build_dir && cmake ../../FreeCAD \
	-DFREECAD_USE_OCC_VARIANT="Official Version" \
	-DCMAKE_BUILD_TYPE=$build_type \
	-DBUILD_QT5=ON \
	-DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DBUILD_ENABLE_CXX_STD:STRING=C++17 \
    $opts \
)

t1=$SECONDS
echo "-----------------------------------------------"
echo "Configuration done in $((t1 - t0))s"
echo "-> Compiling"
echo "-----------------------------------------------"
make -j${CPU}
t2=$SECONDS
echo "-----------------------------------------------"
echo "FreeCAD is compiled in $(( (t2 - t1) / 60 ))m"
echo "-----------------------------------------------"

cp $build_dir/src/Build/Version.h $_sdir/latest-build-Version.h

# Install Assembly3 Workbench
$_sdir/install-asm3.sh $build_dir
