#!/bin/bash
_sdir=$(dirname "$(readlink -f "$0")")
_rel="${_sdir##$PWD}"
set -ue

is_on_btrfs(){
    stat -f --format=%T "$1" | grep -q btrfs
}

LXC_PATH="/var/lib/lxc"
container_name="fc"

show_help(){
    cat <<HELP

    $(basename $0) [options] --host debian|arch 

    Options:

        --name NAME : Container name (default: $container_name)
        --host HOST : Host distro.

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
host=
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
        --host) shift
            host="${1:-}"
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

[[ -d "$LXC_PATH/$container_name" ]] && die "Container $container_name already exists." || true
[[ -z ${host:-} ]] && help_die "Host distro must be declared."

[[ "$(whoami)" == "root" ]] || { sudo "$0" "$@"; exit 0; }

is_on_btrfs "$LXC_PATH" && bdev="-B btrfs" || bdev=""

case $host in
    debian) 
        set -x 
        apt-get install lxc debian-keyring debian-archive-keyring
        lxc-create -n $container_name -t debian $bdev -- -r buster  
        set +x
        ;;
    arch)
        set -x 
        pacman -Sy lxc debootstrap 
        lxc-create --name=$container_name --template=download -- --dist debian --release buster --arch amd64
        set +x
        ;;
    *)
        >&2 echo "Currently LXC container creation on $host host is not automated."
        die "Please manually create a Debian Buster container with name: $container_name"
        ;;
esac

echo "Container $container_name has been setup."