#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")
set -u

# run this script as root
[[ $(whoami) = "root" ]] || { sudo "$0" "$@"; exit 0; }

xhost +local:

config=$1
source $config
shift

# parameter checking
[[ -z $rootfs ]] && { echo "\$rootfs should not be empty."; exit 1; }

cmd=
if [[ -n ${script:-} ]]; then
    tmp_file=/tmp/cmd.sh
    cmd="--rcfile $tmp_file"
    echo "$script" > $rootfs/$tmp_file
    echo "rm $tmp_file" >> $rootfs/$tmp_file
    chmod +x $rootfs/$tmp_file
fi

echo chrooting into $rootfs
mkdir -p $rootfs/proc
mkdir -p $rootfs/sys
mkdir -p $rootfs/dev
mkdir -p $rootfs/run

cat << RESOLV > $rootfs/etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
RESOLV

mount --bind /proc $rootfs/proc
mount --bind /sys $rootfs/sys
mount --bind /dev $rootfs/dev
mount --bind /dev/pts $rootfs/dev/pts
mount --bind /run $rootfs/run

if [[ -n $mounts ]]; then
    while read -r src tgt; do
        mount --bind $src $rootfs/$tgt
    done <<< $mounts
fi

chroot $rootfs /bin/bash $cmd

if [[ -n $mounts ]]; then
    while read -r src tgt; do
        umount $rootfs/$tgt
    done <<< $mounts
fi

umount $rootfs/run
umount $rootfs/dev/pts
umount $rootfs/dev
umount $rootfs/sys
umount $rootfs/proc

rm $rootfs/var/lib/dbus/machine-id 2> /dev/null

echo "Cleaned up chroot."
