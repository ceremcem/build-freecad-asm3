#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

get_timestamp () {
    date +%Y%m%dT%H%M
}

backup_name="rootfs-`get_timestamp`"
mkdir -p $_sdir/backups
btrfs sub snap -r $_sdir/rootfs $_sdir/backups/$backup_name

keep_last_n_backups=10


