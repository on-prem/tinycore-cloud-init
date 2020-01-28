# Cloud-init for On-Prem appliances using TinyCore Linux

![Build status](https://github.com/on-prem/tinycore-cloud-init/workflows/Extensions/badge.svg?branch=master)

This repo contains custom scripts to prepare [cloud-init](https://cloud-init.io/) for standard [TinyCore Linux](http://tinycorelinux.net) virtual appliances and cloud servers.

![tinycore-cloud-init](https://user-images.githubusercontent.com/153401/73237408-66da5400-418d-11ea-8498-691371e10d87.png)

It is split into 3 sub-directories:

  1. **extensions**: Build scripts for creating the required TinyCore `.tcz` extensions
  2. **overlay**: File and directory structure which should be copied directly into the rootfs
  3. **.github/workflows**: GitHub Actions workflow to automatically build each `.tcz` extension, and publish them to [Bintray](https://bintray.com/on-prem/tinycore-extensions)

## Cloud-init on TinyCore Linux

The current version of _cloud-init_ (`v19.x`) does not support TinyCore Linux. It is designed for systems such as Debian, CentOS, FreeBSD, etc. Lack of support for TinyCore leads us to two options:

  * Modify _cloud-init_ and its _Python_ code to work with TinyCore Linux
  * Create custom scripts for operations specific to TinyCore Linux

Our use-case is to support immutable [On-Prem](https://on-premises.com) TinyCore appliances, which presents another set of problems since the system state is reset at every boot. The _Python_ interpreter is slow and the programming language is less than ideal, so tweaking it to work for TinyCore was not a good choice.

For this reason, we've created a set of simple custom _Shell_ scripts to handle most initialization tasks, while leveraging the few tasks _cloud-init_ handles well, such as detecting metadata and userdata from various cloud providers.

## Requirements

  * TinyCore Linux 10.x x86-64
  * **overlay** directory structure added to rootfs
  * **python3.6.tcz** extension
  * **ifupdown.tcz**, **cloud-init.tcz**, **cloud-init-deps.tcz** extensions

## How it works

![rootfs](https://user-images.githubusercontent.com/153401/73244995-1bcb3b80-41a3-11ea-9d27-151d58bb1cdf.png)

Once the overlay is added into the rootfs, only 3 extensions (and their dependencies) need to be loaded on boot:

  * [ifupdown.tcz](https://dl.bintray.com/on-prem/tinycore-extensions/10.0-x86_64/:ifupdown.tcz)
  * [cloud-init.tcz](https://dl.bintray.com/on-prem/tinycore-extensions/10.0-x86_64/:cloud-init.tcz)
  * [cloud-init-deps.tcz](https://dl.bintray.com/on-prem/tinycore-extensions/10.0-x86_64/:cloud-init-deps.tcz)

![boot](https://user-images.githubusercontent.com/153401/73244997-1bcb3b80-41a3-11ea-9841-b73644287c4f.png)

The `/opt/bootsync.sh` will run `cloud-init` and then try to setup networking through `/opt/network.sh`, which is simply calling `cloud-init` once more with different arguments. The reason for this is to provide backward compatibility for existing On-Prem TinyCore deployments.

**Note:** If there is no usage of the [network.tcz](https://github.com/on-prem/tinycore-network), [jidoteki-admin.tcz](https://github.com/on-prem/jidoteki-admin), or [jidoteki-admin-api.tcz](https://github.com/on-prem/jidoteki-admin-api) extensions, `/opt/network.sh` can be removed from `/opt/bootsync.sh` and replaced with:

```
/usr/local/bin/cloud-init modules --mode config
```

Each step in the _cloud-init_ runs can be found in `/etc/cloud/cloud.cfg`.

The `config` modules are `bootcmd` which are the actual _Shell_ scripts found in `/etc/cloud/scripts`.

Customizations can and _should_ be added to `custom.sh` and `custom-once.sh`. If it's not immediately obvious, the `once.sh` and `custom-once.sh` scripts will only run **once per boot**. Unlike typical _cloud-init_ installations, the _once_ scripts will **run again on reboot** (because the OS is immutable).

## What do these scripts configure

The scripts will configure the `NTP server` address, `DNS` nameservers, the `hostname` and `hosts` file, the `network` config for `eth0`, the `iptables` firewall, and additional `storage` (disk2) via `LVM, NFS, or AoE`.

The additional `storage` will not be configured unless the `xfsprogs.tcz`, `lvm2.tcz`, and `nfs-utils.tcz` extensions are loaded.

## Backups and restoring data

The data stored in `/var/lib/cloud` and `/run/cloud-init` should **not be backed up**, as it will prevent userdata and metadata from being altered on the Host OS, and any customized settings will not be retained on reboot.

The following files **can be backed up** (added to `/opt/.filetool.lst`):

  * `etc/hosts`
  * `etc/sysconfig/network-config`
  * `etc/sysconfig/ntpserver`
  * `etc/sysconfig/storagetype`
  * `etc/hostname`
  * `etc/resolv.conf`

If they are backed up, on reboot they will overwrite any values from `userdata`, `metadata`, and `vendordata`, and will help speed up the boot process. Customizations to values (ex: `etc/hostname`) will also be retained.

If they are not backed up, the initial config will take a bit more time.

## Userdata, Metadata, Vendordata

The _Shell_ scripts provided for this _cloud-init_ deployment will read settings from various files on the system, including any userdata or vendordata provided to the system.

![precedence](https://user-images.githubusercontent.com/153401/73244998-1bcb3b80-41a3-11ea-8dce-1fbf0b57dd88.png)

The order of precendence for reading configuration values are:

  1. backed up files from `/opt/.filetool.lst`
  2. userdata from `/var/lib/cloud/instance/user-data.txt`
  3. vendordata from `/var/lib/cloud/seed/nocloud-net/vendor-data`

**Note:** Metadata is only currently used by _cloud-init_ to configure `SSH public-keys`. All other metadata is ignored, but still accessible to applications running on the TinyCore Linux appliance.

### Userdata

Tested with `EC2, Proxmox, and NoCloud`, the userdata will be discovered by _cloud-init_ and read directly from `/var/lib/cloud/instance/user-data.txt`. From testing, it appears _cloud-init_ handles Base64 decoding of userdata automatically provided by EC2.

**Note:** Userdata is **not parsed** by _cloud-init_, but rather read manually by various _Shell_ scripts. This means it is not possible for `userdata` to overwrite values from `/etc/cloud/cloud.cfg`, and it is not possible to provide `userdata` which contains a shell script or other malicious features. Userdata should only contain `key: value` pairs.

### Vendordata

The `vendor-data` should be added to the `/var/lib/cloud/seed/nocloud-net/` directory on the rootfs. It is also possible to add a `network-config` (v1 config) to that directory for pre-configuring the network.

**Note:** Similar to `userdata`, the `vendor-data` is **not parsed** by _cloud-init_ and should only contain `key: value` pairs (except for `network-config`, which is parsed by _cloud-init_'s `net-convert` tool).

## Extensions

All extensions are built from a `Makefile` under their respective directory. The extension's config values are stored in `config.make` (ex: version number, source URL). The extension's Open Source LICENSE file is also included.

The `Makefile` will load the `build.make` file which performs generic tasks such as adjusting file permissions, creating the `.tcz` squashfs file, and cleaning up.

**ifupdown.tcz** is taken directly from the Debian repositories, and built with a patch to remove the need for `run-parts`. This provides the `ifup, ifdown, ifquery` commands to TinyCore Linux, working with the typical Debian `/etc/network/interfaces` file, however it **can not run scripts**, for security reasons.

**cloud-init.tcz** is fetched from the official Canonical Cloud-Init repository, and built with standard Python 3 commands with no changes or patches. It contains the entire `cloud-init` installation without its dependencies.

**cloud-init-deps.tcz** is built similarly to `cloud-init.tcz` and contains all the dependencies for `cloud-init.tcz`.

### Building extensions

First, it is important to load the required _build_ tools in a TinyCore Linux environment:

```
tce-load -wicl git compiletc coreutils
```

To manually build an extension, `cd` into the directory of the extension and type:

```
make TC_VERSION=10.0-x86_64
````

The default `TC_VERSION` is `9.0-x86_64`, if that variable is omitted.

The files should be output to `$HOME/artifacts` in a subdirectory with the name of the extension and version of TinyCore. It will contain a simple `.info` file, the `md5 and sha256` hashes, the `.dep` files, and of course the `.tcz` extension file.

## GitHub workflow

The GitHub workflow runs three concurrent builds, one for each extension. It downloads the JFrog CLI tool if the extension was built correctly, and uploads the files to Bintray for further review (they are not published automatically).

# License

Everything in this repository is licensed under the MIT License, except for the `LICENSE` file of each individual extension.

[MIT License](LICENSE)

Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
