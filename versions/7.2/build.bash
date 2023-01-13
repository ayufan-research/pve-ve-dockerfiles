#!/bin/bash

set -xeo pipefail

apt-get install -y devscripts rsync patchelf
cargo install debcargo

dinstall() {
  [[ -z "$1" ]] && set -- "dinstall"

  (
    cd "$1/"
    git clean -ffdx
    apt-get -y build-dep "$PWD"
    make dinstall || apt-get -f -y install && make dinstall
  )
}

#( cd dh-cargo && dpkg-buildpackage -uc -us -b && dpkg -i ../dh-cargo*.deb )
#( cd proxmox-perl-rs && git clean -fdx && apt-get -y build-dep $PWD/pve-rs && make common-deb pve-deb )

dpkg -s pve-eslint || dinstall pve-eslint
dpkg -s libpve-common-perl || dinstall pve-common
dpkg -s libproxmox-acme-perl libproxmox-acme-plugins || dinstall proxmox-acme
dpkg -s vncterm || dinstall vncterm
dpkg -s libproxmox-backup-qemu0-dev || dinstall proxmox-backup-qemu
dpkg -s pve-qemu-kvm || dinstall pve-qemu
dpkg -s spiceterm || dinstall spiceterm
dpkg -s proxmox-widget-toolkit || dinstall proxmox-widget-toolkit
dpkg -s libpve-apiclient-perl || dinstall pve-apiclient
dpkg -s libpve-storage-perl || dinstall pve-storage
dpkg -s pve-doc-generator || dinstall pve-docs
dpkg -s libpve-access-control-perl || dinstall pve-access-control
dpkg -s libpve-cluster-perl || dinstall pve-cluster
dpkg -s libpve-guest-common-perl || dinstall pve-guest-common
dpkg -s qemu-server || dinstall qemu-server
dpkg -s pve-manager || dinstall pve-manager
