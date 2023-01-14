#!/bin/bash

set -xeo pipefail

apt-get install -y devscripts rsync patchelf xmlto
cargo install debcargo

dinstall() {
  local d="$1"
  shift
  [[ -z "$1" ]] && set -- "dinstall"

  (
    cd "$d/"
    git clean -ffdx
    apt-get -y build-dep "$PWD"
    make "$@" || apt-get -f -y install && make "$@"
    find -name '*.deb' | xargs dpkg -i
  )
}

# copy all PVE into `/usr/share/perl5`
for i in $(find -name PVE); do
  rsync -a $i /usr/share/perl5/
done

which dh-cargo || ( cd dh-cargo && git clean -ffdx && dpkg-buildpackage -uc -us -b && dpkg -i ../dh-cargo*.deb )
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
dpkg -s libpve-u2f-server-perl || dinstall libpve-u2f-server-perl
dpkg -s libpve-u2f-server-perl || dinstall libpve-u2f-server-perl
[[ -e /usr/share/pve-doc-generator/pve-doc-generator.mk ]] || dinstall pve-docs gen-install
dpkg -s pve-cluster || dinstall pve-cluster
dpkg -s libpve-access-control || dinstall pve-access-control
dpkg -s librados2-perl || dinstall librados2-perl
dpkg -s libpve-storage-perl || dinstall pve-storage
# broken: dpkg -s proxmox-websocket-tunnel || dinstall proxmox-websocket-tunnel
dpkg -s libpve-guest-common-perl || dinstall pve-guest-common
dpkg -s libpve-http-server-perl || dinstall pve-http-server
dpkg -s pve-edk2-firmware || dinstall pve-edk2-firmware
dpkg -s qemu-server || dinstall qemu-server
dpkg -s pve-manager || dinstall pve-manager
dpkg -s pve-doc-generator || dinstall pve-docs dinstall
