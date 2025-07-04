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
for dir in /etc /var/lib/pve-cluster /var/lib/pve-manager /var/lib/rrdcached/db /var/log $PERSIST_DIRS; do
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

# Create loop devices
for i in $(seq 0 29); do
  [[ ! -e /dev/loop$i ]] && mknod /dev/loop$i b 7 $i
done

# Run systemd init
exec /sbin/init
