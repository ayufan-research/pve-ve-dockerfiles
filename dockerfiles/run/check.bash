#!/bin/bash

packages=(
  ceph-fuse
  corosync
  glusterfs-client
  libjs-extjs
  libknet1
  libproxmox-acme-perl
  libproxmox-backup-qemu0
  libproxmox-rs-perl
  libpve-access-control
  libpve-cluster-api-perl
  libpve-cluster-perl
  libpve-common-perl
  libpve-guest-common-perl
  libpve-http-server-perl
  livpve-notify-perl
  libpve-rs-perl
  libpve-storage-perl
  libqb0
  libspice-server1
  lvm2
  lxc-pve
  lxcfs
  novnc-pve
  proxmox-backup-client
  proxmox-backup-restore-image
  proxmox-mail-forward
  proxmox-mini-journalreader
  proxmox-widget-toolkit
  pve-cluster
  pve-container
  pve-docs
  pve-edk2-firmware
  pve-firewall
  pve-firmware
  pve-ha-manager
  pve-i18n
  pve-qemu-kvm
  pve-xtermjs
  qemu-server
  smartmontools
  spiceterm
  swtpm
  vncterm
)

printf "%-30s %s\n" "Package" "Status"
printf "%-30s %s\n" "-------" "------"

for pkg in "${packages[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    status="OK"
  else
    status="Missing"
  fi
  printf "%-30s %s\n" "$pkg" "$status"
done
