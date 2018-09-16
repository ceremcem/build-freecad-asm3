# Build FreeCAD Assembly3

To be able to use Assembly3 workbench, it's necessary to build LinkStage3 branch first and then install Assembly3 workbench. 

These scripts automates the building process, installs the binaries to `/opt/FreeCAD`. 

# Advantages 

Main intention of these scripts is to run them in a clean virtual machine, just like Docker. 

Using a virtual build/run environment has invaluable advantages for a bleeding edge application:

1. Build process won't be affected by any unintentional system upgrades. You can be perfectly in sync with the developers' environment conditions without affecting rest of your system.
2. If any code updates break your build process or there is *some* commits that causes frequent crashes, just report the problem and return to previous snapshot in seconds to continue your work. When the problem is fixed, optionally roll forward, do a code update and use the new version. 
3. In case of an event described in step 2, you did a rollback and you are continuing your work. Then developer responds and wants some more information. Just switch to the crashing version, provide the information, do a rollback, continue your work from where you left. 
4. Maintain a complex build process in one place and use it on any distro (even on non-Linux machines with a performance penalty). 


# Usage 

### 1. Setup a clean Debian installation 

Setup a clean installation (Debian Stretch or upwards is suggested) by using 
* VirtualBox (or similar) (easier to setup) 
* LXC (for advanced/daily usage in terms of performance)

> **Tip**: You can start with Virtualbox/like for an easy startup and then you may [convert your machine to LXC at any time](https://github.com/aktos-io/lxc-to-the-future/blob/master/README.md#convert-another-vm-to-lxc-container). 

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
