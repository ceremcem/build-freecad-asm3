#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

# install required dependencies
cat $_sdir/packages.txt \
    | grep -v "^#" \
    | sudo xargs apt-get install -y

# Build FreeCAD Assembly3
$_sdir/build-fc.sh $@
