#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")

$_sdir/run-in-chroot.sh -n fc -u fc -- $@
