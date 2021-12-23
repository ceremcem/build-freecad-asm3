#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")

[[ -f $_sdir/config.sh ]] && source $_sdir/config.sh

$_sdir/run-in-chroot.sh -n ${container_name:-fc} -u ${container_user:-fc} -- $@
