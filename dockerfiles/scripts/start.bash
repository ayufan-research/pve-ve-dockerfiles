#!/bin/bash

if [[ -n "$TZ" ]]; then
  echo "$TZ" > /etc/timezone
fi

# systemd breaks otherwise
umount /sys/fs/cgroup

# Create loop devices
for i in $(seq 0 29); do
  [[ ! -e /dev/loop$i ]] && mknod /dev/loop$i b 7 $i
done

# Copy initial configs
if [[ ! -e /.first ]]; then
  pmxcfs

  while ! mountpoint /etc/pve; do
    sleep 1s
  done

  if [[ ! -e /etc/pve/priv/shadow.cfg ]]; then
    echo "DAEMON: Initial copy!"
    cp -av ../pve/. /etc/pve
    touch /.first
  fi

  kill $(cat /run/pve-cluster.pid)
fi

# Run systemd init
exec /sbin/init
