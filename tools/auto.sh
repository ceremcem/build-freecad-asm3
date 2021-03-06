#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")
set -u

LXC_PATH="/var/lib/lxc"
container_name="fc"

show_help(){
    cat <<HELP

    $(basename $0) [options] 

    Options:

        --name          : Container name (default: $container_name)
        --lxc-path      : LXC Path (default: $LXC_PATH)
        --freecad-src   : Path to existing FreeCAD git source (skip for a new clone)

HELP
}

die(){
    >&2 echo
    >&2 echo "$@"
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
support_ssh_x=false
user="fc"
freecad_src=
# Initialize parameters
# ---------------------------
args_backup=("$@")
args=()
_count=1
while [ $# -gt 0 ]; do
    key="${1:-}"
    case $key in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        # --------------------------------------------------------
        --name) shift
            container_name="$1"
            ;;
        --lxc-path) shift
            LXC_PATH="$1"
            ;;
        --freecad-src) shift
            freecad_src="$1"
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

[[ "$(whoami)" == "root" ]] || { sudo "$0" "$@"; exit 0; }

is_on_btrfs(){
    stat -f --format=%T "$1" | grep -q btrfs
}

is_on_btrfs "$LXC_PATH" && bdev="-B btrfs" || bdev=""

CHROOT="$_sdir/run-in-chroot.sh -n $container_name"

if [[ ! -d $LXC_PATH/$container_name ]]; then 
    set -x 
    apt-get install debian-keyring debian-archive-keyring
    lxc-create -n $container_name -t debian $bdev -- -r buster # might not work: --packages 
    set +x
    if lxc-start -n $container_name; then 
        echo "$container_name successfully created."
        while :; do
            timeout 3 lxc-stop -n $container_name && break
            echo "Retrying stopping $container_name"
            sleep 2
        done
    else
        die "Couldn't start $container_name."
    fi

    # install basic packages
    packages="nano sudo git"   # tmux
    $support_ssh_x && packages="$packages xbase-clients"

    password=$user
    $CHROOT -- "apt-get update && apt-get install -y $packages; \
        grep $user /etc/passwd -q || { \
            echo 'adding user $user'; \
            useradd -m $user; \
            usermod -a -G sudo $user; \
            echo "$user:$password" | chpasswd; \
        }"

    echo "Exiting for a workaround, see: https://unix.stackexchange.com/q/627262/65781"
    echo "Manually restart this script once more."
    exit 2
else 
    echo "Container $container_name seems to be already created."
fi
# LXC container is created. 

builder_scripts="$LXC_PATH/$container_name/rootfs/home/$user/$(basename $(dirname $_sdir))"
if [[ ! -d "$builder_scripts" ]]; then
    cp -a "$(dirname "$_sdir")" "$builder_scripts"
    chown 1000:1000 "$builder_scripts" -R
fi

freecad_src_target="$LXC_PATH/$container_name/rootfs/home/$user/FreeCAD"
if [[ -n "$freecad_src" && ! -d "$freecad_src_target" ]]; then 
    echo "Provided FreeCAD git source, copying."
    is_on_btrfs $LXC_PATH && opt="--reflink=always" || opt=""
    cp -a $opt "$freecad_src" "$freecad_src_target"
    chown 1000:1000 "$freecad_src_target" -R
fi

$CHROOT -- "cd /home/$user; $(basename $builder_scripts)/install-fc-deps.sh || dpkg --configure -a \
    && sudo -u $user $(basename $builder_scripts)/build-fc.sh"

cat <<EOL
FreeCAD is successfully compiled.

Run anytime with: 

    ./freecad.sh

EOL
