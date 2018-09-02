# Build FreeCAD Assembly3

To be able to use Assembly3 workbench, it's necessary to build LinkStage3 branch first and then install Assembly3 workbench. 

These scripts automates the building process, installs the binaries to `/opt/FreeCAD`. 

# Status 

Works for me, but needs some improvements

# Usage 

Main intention of these scripts is to run them in a clean virtual machine, where Debian 9 or upwards is preferred. 

### 1. Setup a clean Debian installation 

Setup a clean installation by using VirtualBox (this is preferred for the first time) or LXC (for advanced/daily usage)

### 2. Download the builder scripts

```
cd /root
git clone https://github.com/ceremcem/build-freecad-asm3
```

### 3. Install or Update FreeCAD-Asm3


```console
# ./build-freecad-asm3/install-fc.sh
```

### Run the FreeCAD

If you used VirtualBox, you can run FreeCAD directly within the VirtualBox: 

```
freecad-git
```

If you use LXC (or optionally this might be use in any cases): 

```
ssh -XC freecad-machine freecad-git
```

> Preferably add `.bashrc` the following line: 
> 
>     alias freecad-asm3-remote='ssh -XC freecad-machine freecad-git'
> 
> and then run FreeCAD-Asm3 by simply issuing: 
> 
>     local$ freecad-asm3-remote 
> 
