#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")
set -u

show_help(){
    cat <<HELP

    $(basename $0) [options] [command]

    Options:

        -n, --name      : Name of your LXC container
        -u, --user      : Login as user
        --verbose       : Verbose mode
        --help          : Shows this info
        --umount        : unmount folders on exit regardless of
                          mounted by this PID
        --unattended    : Run unattended scripts within the target rootfs
                          (no interactive mode)
HELP
}

die(){
    >&2 echo
    >&2 echo "$@"
    >&2 echo
    exit 1
}

help_die(){
    >&2 echo
    >&2 echo "$@"
    show_help
    exit 1
}

# Parse command line arguments
# ---------------------------
# Initialize parameters
name=
user=root
verbose=false
cmd=
_umount=false
unattended=false
# ---------------------------
args_backup=("$@")
args=()
_count=1
while [ $# -gt 0 ]; do
    key="${1:-}"
    case $key in
        -h|-\?|--help|'')
            show_help    # Display a usage synopsis.
            exit
            ;;
        # --------------------------------------------------------
        -n|--name) shift
            name="$1"
            ;;
        -u|--user) shift
            user="$1"
            ;;
        --verbose)
            verbose=true
            ;;
        --umount)
            _umount=true
            ;;
        --unattended)
            unattended=true
            ;;
        --) shift
            args=("$@")
            break
            ;;
        # --------------------------------------------------------
        -*) # Handle unrecognized options
            help_die "Unknown option: $1"
            ;;
        *)  # Generate the new positional arguments: $arg1, $arg2, ... and ${args[@]}
            if [[ ! -z ${1:-} ]]; then
                declare arg$((_count++))="$1"
                args+=("$1")
            fi
            ;;
    esac
    [[ -z ${1:-} ]] && break || shift
done; set -- "${args_backup[@]-}"
# Use $arg1 in place of $1, $arg2 in place of $2 and so on, 
# "$@" is in the original state,
# use ${args[@]} for new positional arguments  


# Empty argument checking
# -----------------------------------------------
[[ -z ${name:-} ]] && die "Name can not be empty"
cpath="/var/lib/lxc/$name"
[[ ! -d $cpath ]] && [[ -d $name ]] && cpath=$name
[[ -d $cpath ]] || die "Container does not exist in: $cpath or ./$name"

# run this script as root
[[ $(whoami) = "root" ]] || { sudo "$0" "$@"; exit 0; }

config="$cpath/config"
rootfs=$(cat $config | grep "^lxc.rootfs.path" | sed -r 's/^[^=]+=\s*//' | rev | cut -d: -f1 | rev)
_mounts=$(cat $config | grep "^lxc.mount.entry" | sed -r 's/^[^=]+=\s*//' | awk '{print $1 " " $2}')

[[ -z $rootfs ]] && die "lxc.rootfs.path should not be empty."

mounts=()
mounts+=("/proc     $rootfs/proc")
mounts+=("/sys      $rootfs/sys")
mounts+=("/dev      $rootfs/dev")
mounts+=("/dev/pts  $rootfs/dev/pts")
mounts+=("/run      $rootfs/run")
if [[ -n $_mounts ]]; then 
    while read -r src tgt; do
        $verbose && echo "Checking if $rootfs/$tgt exists"
        if [[ ! -d $rootfs/$tgt ]]; then 
            # create the target dir regardless of `create=dir` directive 
            mkdir -p $rootfs/$tgt
            ownership=$(stat -c "%u:%g" $(dirname $rootfs/$tgt))
            chown $ownership $rootfs/$tgt
        fi
        if [[ -d $src ]]; then 
            mounts+=("$src $rootfs/$tgt")
        else
            # Skip non-existent targets
            >&2 echo "SKIPPING: No such source directory exists: $src"
        fi
    done <<< $_mounts
fi

if [[ ${args[@]} || -n $user ]]; then
    tmp_file=/tmp/cmd.sh
    if $unattended; then
        cmd="-f $tmp_file"
    else
        cmd="--rcfile $tmp_file"
    fi
    echo '#/bin/bash' > $rootfs/$tmp_file
    echo "cd" >> $rootfs/$tmp_file
    echo "[[ -f .bashrc ]] && . .bashrc" >> $rootfs/$tmp_file
    commands=$(printf "%s " "${args[@]}")
    echo $commands >> $rootfs/$tmp_file
    echo >> $rootfs/$tmp_file
    [[ -n ${commands# } ]] && echo "exit 0" >> $rootfs/$tmp_file
    if $verbose; then 
        echo "--- $rootfs/$tmp_file ---"
        cat $rootfs/$tmp_file
        echo "---------------------------"
    fi
    chmod +x $rootfs/$tmp_file
fi

# Necessary for X applications
xhost +local: > /dev/null

$verbose && echo chrooting into $rootfs

cat << RESOLV > $rootfs/etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
RESOLV

if ! grep $(hostname) $rootfs/etc/hosts -q; then
    # prevent "sudo: unable to resolve host erik3: Name or service not known" errors. 
    echo "127.0.0.1 $(hostname)" >> $rootfs/etc/hosts
fi

mounted=()
cleanup(){
    # unmount in reverse sequence
    for (( idx=${#mounted[@]}-1 ; idx>=0 ; idx-- )) ; do
        for i in `seq 10`; do
            m="${mounted[idx]}"
            if ! mountpoint "$m" > /dev/null; then 
                $verbose && echo "Skipping unmounting $m (not mounted)"
                break
            fi
            $verbose && echo "+ umount $m"
            umount "$m" && break
            echo "Retrying unmounting $m"
            sleep 2
        done
    done

    rm $rootfs/var/lib/dbus/machine-id 2> /dev/null

    $verbose && echo "Cleaned up chroot."
}
trap cleanup EXIT

$verbose && echo "Creating mountpoints"

mkdir -p $rootfs/proc
mkdir -p $rootfs/sys
mkdir -p $rootfs/dev
mkdir -p $rootfs/run

for m in "${mounts[@]}"; do 
    target=$(echo "$m" | awk '{print $2}')
    if mountpoint "$target" > /dev/null; then 
        $verbose && echo "Skipping (already mounted): $target"
        if $_umount; then
            echo "Info: $target will be umounted anyway"
            mounted+=("$target") # umount on exit anyway
        fi
        continue
    fi
    $verbose && echo "Mounting $target"
    mount --bind $m && mounted+=("$target")
done

[[ "$user" != "root" ]] && use_sudo="/usr/bin/sudo -u $user" || use_sudo=""

$verbose && echo "Performing chroot commad"
(chroot $rootfs $use_sudo /bin/bash $cmd)
