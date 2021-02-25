#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

cd $_sdir
# install required dependencies
# Created by: ./debian-notes/package-control/create-virtual-deps.sh -f packages.txt --name freecad-deps
sudo apt install ./freecad-deps_1.0_all.deb

# Build FreeCAD (and then Assembly3 Workbench)
./build-fc.sh
