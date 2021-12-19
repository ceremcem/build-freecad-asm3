# Build FreeCAD Assembly3

These scripts automates the `LinkStage3` building process, creates the FreeCAD binary in `~/fc-build/Release/bin/`. 

### Advantages 

Main intention of these scripts is to run them in a clean LXC container, just like Docker. 

Similar to the list on [FreeCAD Docker Wiki](https://wiki.freecadweb.org/Compile_on_Docker), using a virtual build/run environment has many invaluable advantages for a bleeding edge application:

1. Build process won't be affected by any unintentional system/dependency upgrades. 
2. You can perfectly be in sync with the developers' environment conditions (eg. specific version of a specific dependency) without affecting rest of your system.
3. If any app updates break your build process or there are *some* commits that cause frequent crashes, just report the problem, return to a previous VM snapshot in seconds and continue your work. When the problem is fixed, optionally restore the crashing VM/container (to save build time), do a code update, build and use/test the new version. 
4. In case of an event described in the previous step, you had rolled back and have been continuing your work. Then the developer responded and requested some more information. Just boot the crashing VM/container, provide the information, continue your work from where you left. 
5. A VM/container provides a natural security layer for malicious or accidental harms that uses potential holes of the software (such as a poorly designed workbench or macro).
6. Make the non-portable application portable: On another operating system, just start the container and use your app as usual. 
7. You can host and run multiple versions of the application simultaneously that refuses to build in the other's dependency environment (or refuses to install the dependencies because it conflicts with the other's dependencies). 

### Advantages over AppImage

You can always compile: 
* ...the latest version by only fetching a few kB of source code.
* ...any previous version. 
* ...with a different configuration. 

# Setup

> For manual installation steps, see [manual-install.md](./manual-install.md). 

### Dependencies 

1. LXC tools
2. *(Optional)* `earlyoom`: In order to prevent a total freeze during compilation, you are strongly adviced to install https://github.com/rfjakob/earlyoom

### Install FreeCAD inside the Debian container

1. Get the sources:

```bash
git clone https://github.com/ceremcem/build-freecad-asm3
cd build-freecad-asm3/tools
```

2. Create a Debian Buster LXC container: 

  * On a Debian host        : run `./create-container-on-debian-host.sh`
  * On an Arch Linux host   : run `./create-container-on-arch-host.sh`
  * On the other distros    : Manually create a Debian Buster container named `fc`.

3. Setup the LXC container: 

```
./setup-rootfs.sh
```

You can use an existing Debian container and/or an existing FreeCAD git clone on your host. See `./setup-rootfs.sh --help` for more options. 

# Run 

```bash
./tools/freecad.sh
```

If you need to provide more detailed backtrace in case of a crash, see [debug-friendly-run](./debug-friendly-run.md).

# Updating FreeCAD 

When you want to pull new commits and update your FreeCAD binary, issue the following command: 

```bash
./tools/update-fc.sh
```

This command will:

* Pull new commits into the FreeCAD clone at `/var/lib/lxc/fc/rootfs/home/fc/FreeCAD`
* Recompile the source code inside the container

### Using a specific branch, remote or commit

If you need to compile the FreeCAD against a specific branch, remote or commit, edit the configuration file within the container and rebuild FreeCAD:

```console
local:$ ./attach.sh
fc@debian:~$ nano build-freecad-asm3/config.sh   # edit accordingly 
fc@debian:~$ exit 
local:$ ./update-fc.sh
```

# Accessing your local files 

You can create bind mounts within the LXC config file (`/var/lib/lxc/fc/config`): 

```
lxc.mount.entry = /home/ceremcem/.FreeCAD home/fc/.FreeCAD none bind,create=dir 0 0
lxc.mount.entry = /home/ceremcem/projects home/fc/projects none bind,create=dir 0 0
```

# Tools 

See also [./tools](./tools)

