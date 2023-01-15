#!/bin/bash

set -xeo pipefail

if [[ -n "$ADDITIONAL_DEPS" ]]; then
  apt-get -y $ADDITIONAL_DEPS || apt-get -y update || apt-get -y install $ADDITIONAL_DEPS
fi

if [[ -n "$ROOT_PASSWORD" ]]; then
  echo "root:$ROOT_PASSWORD" | chpasswd
  unset ROOT_PASSWORD
fi

if [[ -n "$ROOT_ENC_PASSWORD" ]]; then
  echo "root:$ROOT_ENC_PASSWORD" | chpasswd -e
  unset ROOT_ENC_PASSWORD
fi

for d in /var/lib/{corosync,pve-cluster,pve-firewall,pve-manager,qemu-server}; do
  [[ -d "$d" ]] || continue

  mv -v "$d" /var/lib/proxmox-etc/
  ln -sf "/var/lib/proxmox-etc/$(dirname "$d")" "$d"
done

exec /sbin/init
