# Manual Installation 

You may manually setup the development environment and modify any step according to your needs.

* Setup an LXC container (Debian).
* Copy this set of scripts to the guest. 
* Install dependenices. 
* Build FreeCAD.

### 1. Setup a Debian LXC container 

Setup a clean installation (minimum required version is Debian Buster. Ubuntu Bionic may also work.):

    sudo apt-get install debian-keyring debian-archive-keyring
    sudo lxc-create -n fc -t debian [-B btrfs] -- -r buster --packages xbase-clients nano sudo tmux git
    sudo lxc-start -n fc

    # add a normal user account
    sudo lxc-attach -n fc
    adduser fc
    usermod -a -G sudo fc
    exit

(See also ../RADME.md#Accessing Files)

### Info about chroot approach

At this point you have 2 options, whether to use `lxc-*` tools and `ssh`, or use `chroot` for the rest of the operations. You can stick to either option or mix them as you like. 

If you want to avoid setting up LXC networking and the runtime overhead of `ssh -X`, you can use `run-in-chroot.sh` script instead. First stop the running container (`lxc-stop -n fc`) and then replace any: 

* `ssh -X fc@10.0.10.3` with `run-in-chroot.sh -n fc -u fc`
* `ssh -X fc@10.0.10.3 some-command params` with `run-in-chroot.sh -n fc -u fc -- some-command params`

Running FreeCAD in `chroot` environment provides native-like performance, just like AppImage:

```console
local$ run-in-chroot.sh -n fc -u fc -- 'fc-build/Release/bin/FreeCAD'
```


### 2. Login to your FreeCAD Machine 

> Assuming your container has an IP of `10.0.10.3`.
> See also [lxc network configuration](https://github.com/aktos-io/lxc-to-the-future/blob/master/network-configuration.md) section. "NAT Configuration" is recommended.

```console
local$ ssh -X fc@10.0.10.3
fc@fc:~$ 
```

### 3. Download the builder scripts

```console
fc@fc:~$ git clone https://github.com/ceremcem/build-freecad-asm3
```

### 4. Create or Update FreeCAD and Asm3 WB

```console
fc@fc:~$ ./build-freecad-asm3/install-fc-deps.sh 
fc@fc:~$ ./build-freecad-asm3/install-fc-deps.sh 
```

> To build only LinkStage3 and Asm3: `./build-freecad-asm3/build-fc.sh  # no root privileges required`

### 5. Run FreeCAD-Asm3

Run `FreeCAD` over SSH by `X Forwarding`:

```console
local$ ssh -X fc@10.0.10.3 fc-build/Release/bin/FreeCAD  # or use run-in-chroot.sh script, see above note.
```
