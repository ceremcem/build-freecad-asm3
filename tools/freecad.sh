#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")

$_sdir/attach.sh 'fc-build/Release/bin/FreeCAD'

