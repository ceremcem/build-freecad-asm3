rootfs="/var/lib/lxc/fc4/rootfs"

# script to be run on startup
read -r -d '' script <<-'EOF'
    sudo -u aea /home/aea/fc-build/Release/bin/FreeCAD
    exit
EOF

# mountpoints
read -r -d '' mounts <<-'EOF'
    /home/ceremcem/tmp              home/aea/tmp
    /home/ceremcem/curr-projects    home/aea/curr-projects
    /home/ceremcem/projects         home/aea/projects
EOF

