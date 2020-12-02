# Build FreeCAD Assembly3

To be able to use Assembly3 workbench, it's necessary to build LinkStage3 branch first and then install Assembly3 workbench. 

These scripts automates the building process, creates the FreeCAD binary in `~/fc-build/Release/bin/`. 

### Advantages 

Main intention of these scripts is to run them in a clean virtual machine, just like Docker. 

Using a virtual build/run environment has invaluable advantages for a bleeding edge application:

1. Build process won't be affected by any unintentional system upgrades. 
2. You can be perfectly in sync with the developers' environment conditions (eg. specific version of a specific dependency) without affecting rest of your system.
3. If any app updates break your build process or there are *some* commits that cause frequent crashes, just report the problem and return to a previous VM snapshot in seconds and continue your work. When the problem is fixed, optionally roll forward (to save build time), do a code update, build and use the new version. 
4. In case of an event described in step 2, you had done a rollback and you have been continuing your work. Then developer responded and requested some more information. Just boot the crashing vm, provide the information, close the crashing vm, continue your work from where you left. 
5. Maintain a complex build process in one place and use it on any distro (even on non-Linux machines with a moderate performance penalty). 
6. A VM provides a natural security layer for malicious or accidental harms that uses potential holes of the software (such as a poorly designed workbench or macro).
7. Make the non-portable application portable: On another operating system, just start the container and use your app as usual. 
8. You can host and run multiple versions/builds simultaneously. 

# Usage 

### 1. Setup a Debian VM 

Setup a clean installation:
* either on VirtualBox (or similar) (easier to setup)
  * Use debian.iso from https://www.debian.org/
      
* or on LXC (for advanced/daily usage in terms of performance)

        sudo lxc-create -n fc -t debian [-B btrfs] -- -r buster --packages xbase-clients nano sudo tmux git
        sudo lxc-start fc

        # add user "freecad" if necessary
        sudo lxc-attach fc
        useradd freecad
        usermod -a -G sudo freecad

### 2. Login to your FreeCAD Machine 

> Assuming your VM has an IP of `10.0.10.3`

```console
local$ ssh -XC freecad@10.0.10.3
freecad@fc:~$ 
```

### 3. Download the builder scripts

```console
freecad@fc:~$ git clone https://github.com/ceremcem/build-freecad-asm3
```

### 4. Install or Update FreeCAD-Asm3

```console
freecad@fc:~$ ./build-freecad-asm3/install.sh 
```

>     ./build-freecad-asm3/build-fc.sh  # to build only LinkStage3 and Asm3

### 5. Run FreeCAD-Asm3

Run `freecad-git` over SSH by `X Forwarding`:

```
ssh -XC freecad@10.0.10.3 fc-build/Release/bin/FreeCAD
```

### Debug Friendly Run 

If you need to provide more detailed backtrace, see [debug-friendly-run](./debug-friendly-run.md).

# Tips 

### Add command line shortcut

Preferably add `.bashrc` the following line: 
 
  ```bash
  alias fc-asm3-remote='ssh -XC freecad@10.0.10.3 fc-build/Release/bin/FreeCAD'
  ```
 
and then run FreeCAD-Asm3 by simply issuing: 
 
   ```console
   local$ fc-asm3-remote 
   ```
   
