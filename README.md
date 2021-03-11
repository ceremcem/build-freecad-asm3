# Build FreeCAD Assembly3

These scripts automates the `LinkStage3` building process, creates the FreeCAD binary in `~/fc-build/Release/bin/`. 

### Advantages 

Main intention of these scripts is to run them in a clean LXC container, just like Docker. 

Similar to the list on [FreeCAD Docker Wiki](https://wiki.freecadweb.org/Compile_on_Docker), using a virtual build/run environment has many invaluable advantages for a bleeding edge application:

1. Build process won't be affected by any unintentional system/dependency upgrades. 
2. You can perfectly be in sync with the developers' environment conditions (eg. specific version of a specific dependency) without affecting rest of your system.
3. If any app updates break your build process or there are *some* commits that cause frequent crashes, just report the problem, return to a previous VM snapshot in seconds and continue your work. When the problem is fixed, optionally restore the crashing VM/container (to save build time), do a code update, build and use/test the new version. 
4. In case of an event described in the previous step, you had rolled back and have been continuing your work. Then the developer responded and requested some more information. Just boot the crashing VM/container, provide the information, continue your work from where you left. 
5. Maintain a complex build process in one place and use it on any distro (even on non-Linux machines with a moderate performance penalty). 
6. A VM/container provides a natural security layer for malicious or accidental harms that uses potential holes of the software (such as a poorly designed workbench or macro).
7. Make the non-portable application portable: On another operating system, just start the container and use your app as usual. 
8. You can host and run multiple versions that refuses to build in the other's dependency environment (or refuses to install the dependencies because it conflicts with the other's dependencies) simultaneously. 

### Advantages over AppImage

You can always compile: 
* the latest version by only fetching a few kB of source code.
* any previous version. 
* with a different configuration. 

Like AppImage, "Setup once, run everywhere".

# Setup

### 1. Setup a Debian LXC container 

Setup a clean installation (minimum required version is Debian Buster. Ubuntu Bionic may also work.):

    sudo apt-get install debian-keyring debian-archive-keyring
    sudo lxc-create -n fc -t debian [-B btrfs] -- -r buster --packages xbase-clients nano sudo tmux git
    sudo lxc-start fc

    # add user "freecad" if necessary
    sudo lxc-attach fc
    adduser freecad
    usermod -a -G sudo freecad

See also [lxc-to-the-future/network-configuration](https://github.com/aktos-io/lxc-to-the-future/blob/master/network-configuration.md) for network configuration. "NAT Configuration" is recommended.

For external mounts, use `lxc.mount.entry` within the `/var/lib/lxc/fc/config`: 

```
lxc.mount.entry = /path/to/folder home/freecad/folder none bind 0 0
```

### 2. Login to your FreeCAD Machine 

> Assuming your container has an IP of `10.0.10.3`

```console
local$ ssh -X freecad@10.0.10.3
freecad@fc:~$ 
```

> **TIP**: You can also completely skip the `ssh` usage and just use `run-in-chroot.sh -n fc` to both perform the below steps and run the compiled application on your host.

### 3. Download the builder scripts

```console
freecad@fc:~$ git clone https://github.com/ceremcem/build-freecad-asm3
```

### 4. Install or Update FreeCAD-Asm3

```console
freecad@fc:~$ ./build-freecad-asm3/build.sh 
```

>     ./build-freecad-asm3/build-fc.sh  # to build only LinkStage3 and Asm3

### 5. Run FreeCAD-Asm3

Run `FreeCAD` over SSH by `X Forwarding`:

```
ssh -X freecad@10.0.10.3 fc-build/Release/bin/FreeCAD
```

You may encounter performance issues with complex models, probably due to `ssh -X`. Running the application inside the `chroot` instead of LXC provides a native-like performance, just like an AppImage: 

```bash
local$ ./tools/run-in-chroot.sh --name fc --user freecad 'fc-build/Release/bin/FreeCAD'
```

### Debug Friendly Run 

If you need to provide more detailed backtrace, see [debug-friendly-run](./debug-friendly-run.md).


# Tools 

See also [./tools](./tools)

   
