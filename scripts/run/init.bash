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

persist() {
  local d="$1"
  local p="${2:-$(basename "$1")}"

  [[ -d "$d" ]] || return

  if [[ -d "/var/lib/proxmox-etc/$p" ]]; then
    rm -r "$d"
  else
    mv -v "$d" "/var/lib/proxmox-etc/$p"
  fi
  ln -sf "/var/lib/proxmox-etc/$p" "$d"
}

persist /etc/network etc-network
persist /var/lib/corosync
persist /var/lib/pve-cluster
persist /var/lib/pve-firewall
persist /var/lib/pve-manager
persist /var/lib/qemu-server

exec /sbin/init
