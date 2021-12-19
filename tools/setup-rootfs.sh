#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")
_rel="${_sdir##$PWD}"
set -u

LXC_PATH="/var/lib/lxc"
container_name="fc"

show_help(){
    cat <<HELP

    $(basename $0) [options] 

    Options:

        --name NAME         : Container name (default: $container_name)
        --lxc-path PATH     : LXC Path (default: $LXC_PATH)
        --freecad-src SRC   : Use SRC as path to copy existing FreeCAD git 
                              source into the container

HELP
}

is_on_btrfs(){
    stat -f --format=%T "$1" | grep -q btrfs
}

end_message(){
    cat <<EOL
Run FreeCAD anytime with:

    .$_rel/freecad.sh

To update your FreeCAD binary: 

    .$_rel/update-fc.sh

EOL
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
        --user) shift
            user="$1"
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

[[ -d "$LXC_PATH/$container_name" ]] || die "Please create the container ($container_name) first."

[[ "$(whoami)" == "root" ]] || { sudo "$0" "$@"; exit 0; }

CHROOT="$_sdir/run-in-chroot.sh -n $container_name --unattended"

# install basic packages
packages="nano sudo git"   # tmux
$support_ssh_x && packages="$packages xbase-clients"

password=$user
$CHROOT -- "export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH'; \
    apt-get update --allow-releaseinfo-change && apt-get install -y $packages; \
    grep $user /etc/passwd -q || { \
        echo 'adding user $user'; \
        useradd -m $user; \
        usermod -a -G sudo $user; \
        echo "$user:$password" | chpasswd; \
    } && echo "User $user already exits.""

builder_scripts_on_rootfs="/home/$user/$(basename $(dirname $_sdir))"
builder_scripts="$LXC_PATH/$container_name/rootfs/$builder_scripts_on_rootfs"
if [[ ! -d "$builder_scripts" ]]; then
    cp -a "$(dirname "$_sdir")" "$builder_scripts"
    $CHROOT -- "chown $user $builder_scripts_on_rootfs -R"
fi

freecad_src_target_on_rootfs="/home/$user/FreeCAD"
freecad_src_target="$LXC_PATH/$container_name/rootfs/$freecad_src_target_on_rootfs"
if [[ -n "$freecad_src" && ! -d "$freecad_src_target" ]]; then 
    echo "Provided FreeCAD git source, copying."
    is_on_btrfs $LXC_PATH && opt="--reflink=always" || opt=""
    cp -a $opt "$freecad_src" "$freecad_src_target"
    $CHROOT -- "chown $user $freecad_src_target_on_rootfs -R"
fi

$CHROOT -- "cd /home/$user; $(basename $builder_scripts)/install-fc-deps.sh || dpkg --configure -a \
    && sudo -u $user $(basename $builder_scripts)/build-fc.sh"

echo "FreeCAD is successfully compiled."

end_message
