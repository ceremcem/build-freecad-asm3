# Build FreeCAD Assembly3

To be able to use Assembly3 workbench, it's necessary to build LinkStage3 branch first and then install Assembly3 workbench. 

These scripts automates the building process, installs the binaries to `/opt/FreeCAD`. 

# Usage 

Main intention of these scripts is to run them in a clean virtual machine.

### 1. Setup a clean Debian installation 

Setup a clean installation (Debian Stretch or upwards is suggested) by using VirtualBox (easier to setup) or LXC (for advanced/daily usage in terms of performance)

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

### 4. Run the FreeCAD

If you used VirtualBox (or a real machine), you can run FreeCAD directly within the machine: 

```
freecad-git
```

Otherwise, run `freecad-git` over SSH by `X Forwarding`:

```
ssh -XC ip-or-name-of-freecad-machine freecad-git
```

### Debug Friendly Run 

If you need to provide more detailed backtrace, see [debug-friendly-run.md](./debug-friendly-run.md).

# Tips 

Preferably add `.bashrc` the following line: 
 
  ```bash
  alias freecad-asm3-remote='ssh -XC ip-or-name-of-freecad-machine freecad-git'
  ```
 
and then run FreeCAD-Asm3 by simply issuing: 
 
   ```console
   local$ freecad-asm3-remote 
   ```
 
