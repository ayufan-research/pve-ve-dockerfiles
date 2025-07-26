# DRAFT: Proxmox VE in a Container

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/ayufan-research/pve-ve-dockerfiles?label=GitHub%20STABLE)](https://github.com/ayufan-research/pve-ve-dockerfiles/releases) [![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/ayufan-research/pve-ve-dockerfiles?include_prereleases&color=red&label=GitHub%20BETA)](https://github.com/ayufan-research/pve-ve-dockerfiles/releases/latest)

[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/ayufan/proxmox-ve/latest?label=Docker%20LATEST)](https://hub.docker.com/r/ayufan/proxmox-ve/tags) [![Docker Image Version (latest semver)](https://img.shields.io/docker/v/ayufan/proxmox-ve?sort=semver&color=red&label=Docker%20BETA)](https://hub.docker.com/r/ayufan/proxmox-ve/tags)

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
docker pull ayufan/proxmox-ve:latest
```

## Run

```bash
docker-compose up -d
```

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

## Changelog

See [Releases](https://github.com/ayufan-research/pve-ve-dockerfiles/releases).

## Author

This is just built by Kamil Trzciński, 2025.
from the sources found on http://git.proxmox.com/.
