#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")
set -eu

echo "Updating builder scripts inside the container."
$_sdir/attach.sh "cd build-freecad-asm3; git fetch && git reset --hard origin/master && echo "Done." || echo "Failed.""
