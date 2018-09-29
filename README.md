# Build FreeCAD Assembly3

To be able to use Assembly3 workbench, it's necessary to build LinkStage3 branch first and then install Assembly3 workbench. 

These scripts automates the building process, installs the binaries to `/opt/FreeCAD`. 

# Advantages 

Main intention of these scripts is to run them in a clean virtual machine, just like Docker. 

Using a virtual build/run environment has invaluable advantages for a bleeding edge application:

1. Build process won't be affected by any unintentional system upgrades. You can be perfectly in sync with the developers' environment conditions (eg. specific version of a specific dependency) without affecting rest of your system.
2. If any code updates break your build process or there are *some* commits that cause frequent crashes, just report the problem and return to a previous snapshot in seconds to continue your work. When the problem is fixed, optionally roll forward (to save build time), do a code update, build and use the new version. 
3. In case of an event described in step 2, you had done a rollback and you have been continuing your work. Then developer responds and requires some more information. Just boot the crashing vm, provide the information, close, continue your work from where you left. 
4. Maintain a complex build process in one place and use it on any distro (even on non-Linux machines with a moderate performance penalty). 
5. Naturally, provides a security layer for malicious or accidental harms that uses potential holes of the software (such as poorly designed workbench)
6. Make the application portable: On another operating system, just start the container and use your app as usual. 

# Requirements 

1. Use Debian Stretch or upwards 

# Usage 

### 1. Setup a clean Debian installation 

Setup a clean installation:
* either on VirtualBox (or similar) (easier to setup) 
* or on LXC (for advanced/daily usage in terms of performance)

      sudo lxc-create -n freecad -t debian -- -r stretch

> **Tip #1**: You may [convert your VM to LXC at any time](https://github.com/aktos-io/lxc-to-the-future/blob/master/README.md#convert-another-vm-to-lxc-container). <br />
> **Tip #2**: See [below](#create-lxc-containers-easily) if you use BTRFS file system for additional tips.

### 2. Download the builder scripts

```
cd /root
git clone https://github.com/ceremcem/build-freecad-asm3
```

### 3. Install or Update FreeCAD-Asm3


```console
# ./build-freecad-asm3/install.sh 
```

> In order to build only LinkStage3 branch and update Asm3 WB:
> 
>       ./build-freecad-asm3/install-fc.sh
>

### 4. Run FreeCAD-Asm3

If you used VirtualBox (or a real machine), you can run FreeCAD directly within the machine: 

```
freecad-git
```

Otherwise (or in any case), run `freecad-git` over SSH by `X Forwarding`:

```
ssh -XC ip-or-name-of-freecad-machine freecad-git
```

### Debug Friendly Run 

If you need to provide more detailed backtrace, see [debug-friendly-run](./debug-friendly-run.md).

# Tips 

### Add command line shortcut

Preferably add `.bashrc` the following line: 
 
  ```bash
  alias freecad-asm3-remote='ssh -XC ip-or-name-of-freecad-machine freecad-git'
  ```
 
and then run FreeCAD-Asm3 by simply issuing: 
 
   ```console
   local$ freecad-asm3-remote 
   ```
   
### Set the appearance 

Running a Qt application over ssh looks ugly. In order to make FreeCAD [look well over ssh](https://user-images.githubusercontent.com/6639874/45443660-05b3fc80-b6ce-11e8-91a9-002423f589ad.png), you should do:

```
sudo apt-get install qt4-qtconfig kde-style-oxygen
qtconfig
```

# See Also 

### Create LXC Containers easily 
 
If you use BTRFS file system, you can take advantage of [LXC To The Future](https://github.com/aktos-io/lxc-to-the-future) while creating LXC Containers.
