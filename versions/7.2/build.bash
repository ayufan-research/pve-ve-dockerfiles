#!/bin/bash

set -xeo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -f -y
dpkg --get-selections | grep deinstall | awk '{print $1}' | xargs -r apt-get purge -y || true

if_installed() {
  dpkg -s "$@" | grep "Status: install ok installed" &> /dev/null
}

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
      apt-get -f -y install
      [[ -e "$p/debian/control" ]] && apt-get -y build-dep "$PWD/$p"
      make "$@"
    fi
    find "$PWD" -name '*.deb' | xargs -r apt -y install
  )
}

dpkg_buildpackage() {
  local d="$1"
  shift

  (
    cd "$d/"
    git clean -ffdx
    [[ -e "debian/control" ]] && apt-get -y build-dep "$PWD"
    mkdir -p .build
    cp -av * .build/
    cd .build/
    dpkg-buildpackage -uc -us -b
    cd ..
    find "$PWD" -name "*.deb" | xargs -r apt -y install
  )
}

if_installed dh-cargo || dpkg_buildpackage dh-cargo
if_installed pve-eslint || dinstall pve-eslint
if_installed proxmox-widget-toolkit || dinstall proxmox-widget-toolkit
if_installed corosync || dinstall corosync-pve
# broken: if_installed corosync-qdevice || dinstall corosync-qdevice
if_installed ksm-control-daemon || dinstall ksm-control-daemon . all
if_installed libproxmox-rs-perl || dinstall proxmox-perl-rs pve-rs pve-deb common-deb
if_installed vncterm || dinstall vncterm
if_installed libjs-extjs || dinstall extjs
if_installed libjs-qrcodejs || dinstall libjs-qrcodejs
if_installed proxmox-mini-journalreader || dinstall proxmox-mini-journalreader
if_installed pve-xtermjs || dpkg_buildpackage pve-xtermjs
if_installed pve-i18n || dinstall proxmox-i18n . deb
if_installed proxmox-backup-client || dinstall proxmox-backup . deb-all
if_installed libproxmox-backup-qemu0-dev || dinstall proxmox-backup-qemu
if_installed pve-qemu-kvm || dinstall pve-qemu || if_installed pve-qemu-kvm
if_installed spiceterm || dinstall spiceterm
if_installed pve-edk2-firmware || dinstall pve-edk2-firmware
if_installed swtpm || dpkg_buildpackage swtpm
if_installed novnc-pve || dinstall novnc-pve
# broken: if_installed criu || dinstall criu criu dinstall
if_installed lxcfs || dinstall lxcfs
if_installed lxc-pve || dinstall lxc
if_installed pve-lxc-syscalld || dinstall pve-lxc-syscalld
if_installed libpve-apiclient-perl || dinstall pve-apiclient
if_installed libpve-u2f-server-perl || dinstall libpve-u2f-server-perl
if_installed proxmox-mail-forward || dinstall proxmox-mail-forward
if_installed proxmox-websocket-tunnel || dpkg_buildpackage proxmox-websocket-tunnel

if_installed libpve-common-perl || dinstall pve-common
if_installed libproxmox-acme-perl libproxmox-acme-plugins || dinstall proxmox-acme

# Fix circular dependencies between pve-access-control and pve-cluster
if [[ ! -e pve-perl5.done ]]; then
  apt-get build-dep -y "$PWD/pve-docs"
  apt-get build-dep -y "$PWD/pve-access-control"
  apt-get build-dep -y "$PWD/pve-cluster"

  # broken: PERL5LIB="$PWD/pve-access-control/src"
  ln -sf "$PWD/pve-access-control/src/PVE" /etc/perl/
  make -C pve-docs gen-install
  make -C pve-cluster/data all check install
  rm /etc/perl/PVE

  touch pve-perl5.done
fi

if_installed libpve-access-control || dinstall pve-access-control
if_installed pve-cluster || dinstall pve-cluster
if_installed librados2-perl || dinstall librados2-perl
if_installed libpve-storage-perl || dinstall pve-storage
if_installed libpve-guest-common-perl || dinstall pve-guest-common
if_installed libpve-http-server-perl || dinstall pve-http-server
if_installed pve-firewall || dinstall pve-firewall
if_installed pve-ha-manager || dinstall pve-ha-manager
if_installed pve-container || dinstall pve-container . dinstall DEB_BUILD_OPTIONS=nocheck
if_installed qemu-server || dinstall qemu-server
if_installed pve-docs || dinstall pve-docs dinstall
if_installed pve-manager || dinstall pve-manager
if_installed proxmox-ve || dinstall proxmox-ve . deb

# libqb0
# pve-zsync
# zfsutils-linux
# ceph-fuse
# criu
# glusterfs-client
# ifupdown

exit
