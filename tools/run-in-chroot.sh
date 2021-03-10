#!/bin/bash
set -u

rootfs="/var/lib/lxc/fc4/rootfs" # CHANGE_HERE
xhost +local:

[[ -z $rootfs ]] && { echo "\$rootfs should not be empty."; exit 1; }
[[ $(whoami) = "root" ]] || { sudo "$0" "$@"; exit 0; }

ext_cmd='su aea; cd;'
cmd=
if [[ -n ${1:-} ]]; then
    tmp_file=/tmp/cmd.sh
    cmd="--rcfile $tmp_file"
    echo $ext_cmd > $rootfs/$tmp_file
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

mount --bind /home/ceremcem/tmp $rootfs/home/aea/tmp # CHANGE_HERE

chroot $rootfs /bin/bash $cmd

umount $rootfs/home/aea/tmp # CHANGE_HERE

umount $rootfs/run
umount $rootfs/dev/pts
umount $rootfs/dev
umount $rootfs/sys
umount $rootfs/proc

rm $rootfs/var/lib/dbus/machine-id 2> /dev/null

echo "Cleaned up chroot."
