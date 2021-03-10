# Host Tools

These tools are intended to be used on the host machine that runs on BTRFS filesystem. You can 

* Backup your LCX container
* Restore from any backup
* List backups against containing FreeCAD versions

# Install 

Copy these scripts to the root of your LXC container:

```
cp lxc/*.sh /var/lib/lxc/your-container
```

# LXC Network Configuration

See [lxc-to-the-future/network-configuration.md](https://github.com/aktos-io/lxc-to-the-future/blob/master/network-configuration.md). "NAT Configuration" is recommended.

