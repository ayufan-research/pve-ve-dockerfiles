#!/bin/bash

set -xeo pipefail

apt-get install -y devscripts rsync
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
dpkg -s pve-qemu-kvm || dinstall pve-qemu
dpkg -s spiceterm || dinstall spiceterm
