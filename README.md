# DRAFT: Proxmox VE in a Container

- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/ayufan-research/pve-ve-dockerfiles?label=GitHub%20Release)](https://github.com/ayufan-research/pve-ve-dockerfiles/releases) [![Docker Image Version (latest stable (amd64))](https://img.shields.io/docker/v/ayufan/proxmox-ve/latest?arch=amd64&label=Docker:%20latest)](https://hub.docker.com/r/ayufan/proxmox-ve/tags) [![Docker Image Version (latest stable (arm64))](https://img.shields.io/docker/v/ayufan/proxmox-ve/latest?arch=arm64&label=Docker:%20latest)](https://hub.docker.com/r/ayufan/proxmox-ve/tags)
- [![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/ayufan-research/pve-ve-dockerfiles?include_prereleases&color=red&label=GitHub%20Pre-Release)](https://github.com/ayufan-research/pve-ve-dockerfiles/releases/latest) [![Docker Image Version (latest stable (amd64))](https://img.shields.io/docker/v/ayufan/proxmox-ve/beta?arch=amd64&color=red&label=Docker:%20beta)](https://hub.docker.com/r/ayufan/proxmox-ve/tags) [![Docker Image Version (latest stable (arm64))](https://img.shields.io/docker/v/ayufan/proxmox-ve/beta?arch=arm64&color=red&label=Docker:%20beta)](https://hub.docker.com/r/ayufan/proxmox-ve/tags)

This is an unofficial compilation of Proxmox VE
to run it in a container for AMD64 and ARM64.

This seems crazy to run the whole virtualization framework in a container,
but suprisingly it works pretty well. It allows to isolate all dependencies
of PVE in a quite big self-sufficient containers.

It can run both LXC (privileged-only) and QEMU-based machines
with managing networking interfaces and accessing underlying disks
in a form of a files or partitions.

I would not advise to run it in a production, more like a preview.
It might be insecure with some usage patterns.

This is built using git repositories found on https://git.proxmox.com/ with minimal
amount of patches to compile in a container, or for ARM64.
You can find all patches in [repos/patches](repos/patches/) folder.

## Buy me a Coffee

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y8GCP24)

If you found it useful :)

## Common problems

- To run LXC, you need to disable `apparmor`. Add `GRUB_CMDLINE_LINUX_DEFAULT="quiet apparmor=0"` to `/etc/default/grub` and `update-grub`.
- It is best to run `network_mode: host`, and create `br0` with the network interface. Then add the `br0` via Proxmox VE GUI to configuration.
- It is requried to use `extra_hosts: [pve:LOCAL_IP]`. Otherwise container will not start.

## Pre-built images

For starting quickly all images are precompiled and hosted
at https://hub.docker.com/r/ayufan/proxmox-ve.

Or:

```bash
# Latest stable / release tag
docker pull ayufan/proxmox-ve:latest

# Latest pre-release / beta tag
docker pull ayufan/proxmox-ve:beta
```

Each [GitHub Releases](https://github.com/ayufan-research/pve-ve-dockerfiles/releases) includes the following binary assets:

- `proxmox-ve-server-*.tgz` - contains all archived debian installation files with the `./install` script

## Run

```bash
wget https://raw.githubusercontent.com/ayufan-research/pve-ve-dockerfiles/refs/heads/master/docker-compose.yml
docker-compose up -d
```

**Run beta variant:**

```bash
wget https://raw.githubusercontent.com/ayufan-research/pve-ve-dockerfiles/refs/heads/master/docker-compose.yml
TAG=beta docker-compose up -d
```

See the example [docker-compose.yml](./docker-compose.yml).

## Configure container

Create a new file (or merge with existing): `docker-compose.override.yml`:

```yaml
services:
  pve:
    environment:
      TZ: Europe/Warsaw
    extra_hosts:
      - pve:192.168.10.1 # or whatever is your LAN IP

volumes:
  # persist configuration files
  cfg_persist:
    driver: local
    driver_opts:
      type: ''
      o: bind
      device: /srv/pbs/persist

  # persist /var/lib/vz (default space to store disk images and containers)
  data_vz: 
    driver: local
    driver_opts:
      type: ''
      o: bind
      device: /srv/pbs/vz
```

## Configure root password

```bash
docker-compose exec pve passwd
```

Then login to `https://<ip>:8006/` with `root / your password`.

## Features

I tested limited amount of features:

- Running QEMU VMs on ARM64, including MikroTik on Ampere.
- Running LXC containers on ARM64 in privileged mode, the unprivileged fails.

## Install server on bare-metal or virtualized host

Docker is convienient, but in some cases it might be simply better to install natively.

You can pull compiled `*.deb` files from [GitHub Releases](https://github.com/ayufan-research/pve-ve-dockerfiles/releases).

Replace the `v7.4.0` with the latest version.

```bash
wget https://github.com/ayufan-research/pve-ve-dockerfiles/releases/download/v4.0.12/proxmox-ve-v7.4.0-$(dpkg --print-architecture).tgz
tar zxf proxmox-ve-server-*.tgz
proxmox-ve-server-*/install
```

## Changelog

See [Releases](https://github.com/ayufan-research/pve-ve-dockerfiles/releases).

## Author

This is just built by Kamil Trzciński, 2025.
from the sources found on http://git.proxmox.com/.
