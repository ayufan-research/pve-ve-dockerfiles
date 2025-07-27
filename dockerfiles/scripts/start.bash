#!/bin/bash

if [[ -n "$TZ" ]]; then
  echo "$TZ" > /etc/timezone
fi

# Link some persistent configs
if ! mountpoint -q /persist; then
  echo "The /persist is required mountpoint."
  exit 1
fi

# Persist directories
for dir in /etc /root /var/lib/pve-cluster /var/lib/pve-manager /var/lib/rrdcached/db /var/log $PERSIST_DIRS; do
  mountpoint -q "$dir" && continue

  mkdir -p "$dir"
  upperdir="/persist/$dir"
  workdir="/persist/.work/$dir"
  lowerdir="/base/$dir"

  mkdir -p "$lowerdir" "$upperdir" "$workdir"
  mount --rbind "$dir" "$lowerdir"
  mount -t overlay overlay -o lowerdir="$lowerdir",upperdir="$upperdir",workdir="$workdir" "$dir"
done

# Rebind some common files
for rebind in /etc/{resolv.conf,hosts,hostname}; do
  mount --rbind "/base/$rebind" "$rebind"
done

# Allow to configure tun devices (disable_ipv6?)
mount -o remount,rw /proc/sys

# systemd breaks otherwise
umount /sys/fs/cgroup

# Create necessary device nodes
create_mknod() {
  local dev="$1"
  local type="$2"
  local major="$3"
  local minor="$4"
  local group="${5:-root}"
  local mod="${6:-0660}"

  if [[ ! -e "$dev" ]]; then
    mkdir -p "$(dirname "$dev")"
    mknod "$dev" "$type" "$major" "$minor"
    chmod "$mod" "$dev"
    chown "root:$group" "$dev"
  fi
}

create_mknod /dev/kvm c 10 232 kvm
create_mknod /dev/vhost-net c 10 282 kvm
create_mknod /dev/net/tun c 10 200 root 0666
create_mknod /dev/loop-control c 10 237 disk
create_mknod /dev/fuse c 10 229 root 0666

for i in $(seq 0 29); do
  create_mknod "/dev/loop$i" b 7 $i disk
done

# Run systemd init
exec /sbin/init
