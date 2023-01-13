#!/bin/bash

set -xeo pipefail

apt-get -y build-dep $PWD/pve-eslint && make -C pve-eslint dinstall
apt-get -y build-dep $PWD/proxmox-perl-rs/pve-rs && make -C proxmox-perl-rs pve-deb