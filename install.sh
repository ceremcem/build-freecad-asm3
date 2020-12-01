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

# install packages
cat packages.txt | grep -v "^#" \
	| sudo xargs apt-get install -y

#deps=$_sdir/deps
#$deps/libmed.sh
#$deps/occt.sh
#$deps/netgen.sh
#$deps/vtk.sh
#$deps/eigen.sh
## disabled: $deps/calculix.sh # FIXME: can not generate `cgx`
#$deps/gmsh.sh

# Build FreeCAD Assembly3
$_sdir/build-fc.sh
