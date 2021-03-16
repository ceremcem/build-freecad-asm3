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

You can automatically initiate whole setup by: 

```bash
git clone https://github.com/ceremcem/build-freecad-asm3
cd build-freecad-asm3/tools
for i in 1 2; do ./auto.sh; done # yes, you need to run twice, see: https://unix.stackexchange.com/q/627262/65781
```

If you have FreeCAD source already cloned, pass the location as a parameter:

```bash
for i in 1 2; do ./auto.sh --freecad-src /path/to/FreeCAD; done
```

For manual installation, see [manual-install.md](./manual-install.md).

# Run 

```bash
./freecad.sh
```

If you need to provide more detailed backtrace in case of a crash, see [debug-friendly-run](./debug-friendly-run.md).

# Out Of Memory situations 

You may run into out of memory (oom) situations while compiling FreeCAD.

In order to prevent a total freeze, you are adviced to install `earlyoom` before the computer freezes: https://github.com/rfjakob/earlyoom

# Accessing your local files 

You can create bind mounts within the LXC config file (`/var/lib/lxc/fc/config`): 

```
lxc.mount.entry = /home/ceremcem/.FreeCAD home/fc/.FreeCAD none bind,create=dir 0 0
lxc.mount.entry = /home/ceremcem/projects home/fc/projects none bind,create=dir 0 0
```

# Tools 

See also [./tools](./tools)

