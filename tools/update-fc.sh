#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")

$_sdir/attach.sh 'build-freecad-asm3/build-fc.sh'

