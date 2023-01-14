#!/bin/bash

set -xeo pipefail

apt-get install -f -y
dpkg --get-selections | grep deinstall | awk '{print $1}' | xargs -r apt-get purge -y || true
apt-get install -y devscripts rsync patchelf xmlto
apt-get install -t bullseye-backports -y meson
cargo install debcargo

dinstall() {
  local d="$1"
  shift
  [[ -z "$1" ]] && set -- . dinstall
  local p="$1"
  shift

  (
    cd "$d/"
    git clean -ffdx
    [[ -e "$p/debian/control" ]] && apt-get -y build-dep "$PWD/$p"
    if ! make "$@"; then
      [[ -e "$p/debian/control" ]] && apt-get -y build-dep "$PWD/$p"
      apt-get -f -y install
      make "$@"
    fi
    find -name '*.deb' | xargs -r dpkg -i
  )
}

if_installed() {
  dpkg -S "$@" &> /dev/null
}

# copy all PVE into `/usr/share/perl5`
if [[ ! -e pve-perl5.done ]]; then
  for i in $(find -name PVE); do
    rsync -a $i /usr/share/perl5/
  done

  make -C pve-docs gen-install
  apt-get build-dep -y "$PWD/pve-docs"

  touch pve-perl5.done
fi

if_installed dh-cargo || ( cd dh-cargo && git clean -ffdx && dpkg-buildpackage -uc -us -b && dpkg -i ../dh-cargo*.deb )
#( cd proxmox-perl-rs && git clean -fdx && apt-get -y build-dep $PWD/pve-rs && make common-deb pve-deb )

if_installed pve-eslint || dinstall pve-eslint
if_installed libpve-rs-perl || dinstall proxmox-perl-rs pve-rs pve-deb
if_installed libproxmox-rs-perl || dinstall proxmox-perl-rs pve-rs common-deb
if_installed libpve-common-perl || dinstall pve-common
if_installed libproxmox-acme-perl libproxmox-acme-plugins || dinstall proxmox-acme
if_installed vncterm || dinstall vncterm
if_installed libproxmox-backup-qemu0-dev || dinstall proxmox-backup-qemu
if_installed pve-qemu-kvm || dinstall pve-qemu
if_installed spiceterm || dinstall spiceterm
if_installed proxmox-widget-toolkit || dinstall proxmox-widget-toolkit
if_installed libpve-apiclient-perl || dinstall pve-apiclient
if_installed libpve-u2f-server-perl || dinstall libpve-u2f-server-perl
if_installed libpve-u2f-server-perl || dinstall libpve-u2f-server-perl
if_installed pve-cluster || make -C pve-cluster/data install
if_installed libpve-access-control || dinstall pve-access-control
if_installed pve-cluster || dinstall pve-cluster
if_installed librados2-perl || dinstall librados2-perl
if_installed libpve-storage-perl || dinstall pve-storage
# broken: if_installed proxmox-websocket-tunnel || dinstall proxmox-websocket-tunnel
if_installed libpve-guest-common-perl || dinstall pve-guest-common
if_installed libpve-http-server-perl || dinstall pve-http-server
if_installed pve-edk2-firmware || dinstall pve-edk2-firmware
if_installed pve-firewall || dinstall pve-firewall
if_installed pve-ha-manager || dinstall pve-ha-manager
# broken: if_installed criu || dinstall criu criu dinstall
if_installed lxc-pve || dinstall lxc
# broken: if_installed pve-lxc-syscalld || dinstall pve-lxc-syscalld
#if_installed pve-container || dinstall pve-container . dinstall DEB_BUILD_OPTIONS=nocheck

exit
if_installed qemu-server || dinstall qemu-server
if_installed pve-manager || dinstall pve-manager
if_installed pve-doc-generator || dinstall pve-docs dinstall
