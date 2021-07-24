#!/bin/bash
set -eu
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ "$(whoami)" == "root" ]] || { sudo $0 "$@"; exit 0; }

has_warning=
warn(){
	has_warning="(Warning exists)"
	echo "WARNING: $@"
}

cd $_sdir
backup=$1
[[ -d $backup ]] || { echo "No snapshot as $backup exists."; exit 1; }

rootfs_tip="rootfs.tip.ro"
if [[ -d rootfs && ! -d $rootfs_tip ]]; then
	echo "Backing up current rootfs as $rootfs_tip"
	btrfs sub snap -r rootfs $rootfs_tip
fi

name=$(basename $(dirname $(realpath $0)))
container_was_running=false
if [[ $(lxc-info $name | grep State | awk '$0=$2') == "RUNNING" ]]; then
	echo "Stopping $name"
	container_was_running=true
	lxc-stop $name
fi

[[ -d rootfs ]] && btrfs sub del rootfs
btrfs sub snap $backup rootfs

# remove tip backup if we returned to that
[[ "$(realpath "$backup")" == "$(realpath "$rootfs_tip")" ]] && btrfs sub del $rootfs_tip

# verify that we have necessary mountpoints
for m in $(grep lxc.mount.entry config | awk '$0=$4'); do
    [[ -d rootfs/$m ]] || warn "Mountpoint does not exist: $m"
done

echo "`date -u`: Returned to $backup" >> "return-to-backup.log"
echo "Done $has_warning"

if [[ -z $has_warning ]]; then
	if $container_was_running; then
		echo "Starting $name"
		lxc-start $name
	fi
else
	echo "Warnings exist, won't start $name automatically."
fi
