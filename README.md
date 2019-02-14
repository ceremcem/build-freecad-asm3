# Build FreeCAD Assembly3

To be able to use Assembly3 workbench, it's necessary to build LinkStage3 branch first and then install Assembly3 workbench. 

These scripts automates the building process, installs the binaries to `/opt/FreeCAD`. 

### Advantages 

Main intention of these scripts is to run them in a clean virtual machine, just like Docker. 

Using a virtual build/run environment has invaluable advantages for a bleeding edge application:

1. Build process won't be affected by any unintentional system upgrades. 
2. You can be perfectly in sync with the developers' environment conditions (eg. specific version of a specific dependency) without affecting rest of your system.
3. If any app updates break your build process or there are *some* commits that cause frequent crashes, just report the problem and return to a previous VM snapshot in seconds and continue your work. When the problem is fixed, optionally roll forward (to save build time), do a code update, build and use the new version. 
4. In case of an event described in step 2, you had done a rollback and you have been continuing your work. Then developer responded and requested some more information. Just boot the crashing vm, provide the information, close the crashing vm, continue your work from where you left. 
5. Maintain a complex build process in one place and use it on any distro (even on non-Linux machines with a moderate performance penalty). 
6. A VM provides a natural security layer for malicious or accidental harms that uses potential holes of the software (such as poorly designed workbench)
7. Make the non-portable application portable: On another operating system, just start the container and use your app as usual. 
8. You can host and run multiple versions/builds simultaneously. 


# Usage 

### 1. Setup a Debian VM 

Setup a clean installation:
* either on VirtualBox (or similar) (easier to setup)
  * Use debian.iso from https://www.debian.org/
      
* or on LXC (for advanced/daily usage in terms of performance)

      sudo lxc-create -n freecad -t debian -- -r stretch

> **Tip #1**: You may [convert your VM to LXC at any time](https://github.com/aktos-io/lxc-to-the-future/blob/master/README.md#convert-another-vm-to-lxc-container). <br />
> **Tip #2**: See [below](#create-lxc-containers-easily) if you use BTRFS file system for additional tips.

### 2. Login to your FreeCAD Machine 

> Assuming your VM has an IP of `10.0.10.3`

```console
local$ ssh -XC 10.0.10.3
fc:~$
```

### 3. Download the builder scripts

```console
fc# cd /root
fc:/root# git clone https://github.com/ceremcem/build-freecad-asm3
```

### 4. Install or Update FreeCAD-Asm3

```console
fc:/root# ./build-freecad-asm3/install.sh 
```

>     ./build-freecad-asm3/install-fc.sh  # to build only LinkStage3 and Asm3

### 5. Run FreeCAD-Asm3

If you used VirtualBox (or a real machine), you can run FreeCAD directly within the machine: 

```
freecad-git
```

Otherwise (or in any case), run `freecad-git` over SSH by `X Forwarding`:

```
ssh -XC 10.0.10.3 freecad-git
```

### Debug Friendly Run 

If you need to provide more detailed backtrace, see [debug-friendly-run](./debug-friendly-run.md).

# Tips 

### Add command line shortcut

Preferably add `.bashrc` the following line: 
 
  ```bash
  alias fc-asm3-remote='ssh -XC 10.0.10.3 freecad-git'
  ```
 
and then run FreeCAD-Asm3 by simply issuing: 
 
   ```console
   local$ fc-asm3-remote 
   ```
   
### Set the appearance 

If visuals look ugly, see [this](https://user-images.githubusercontent.com/6639874/45443660-05b3fc80-b6ce-11e8-91a9-002423f589ad.png):

```
sudo apt-get install qt4-qtconfig kde-style-oxygen
qtconfig
```

# See Also 

### Create LXC Containers easily 
 
If you use BTRFS file system, you can take advantage of [LXC To The Future](https://github.com/aktos-io/lxc-to-the-future) while creating LXC Containers.
