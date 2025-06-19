#!/bin/bash

if [[ -n "$TZ" ]]; then
  echo "$TZ" > /etc/timezone
fi

if [[ ! -e /.first ]]; then
  pmxcfs

  while ! mountpoint /etc/pve; do
    sleep 1s
  done

  echo "DAEMON: Initial copy!"
  cp -av ../../pve/. /etc/pve
  kill $(cat /run/pve-cluster.pid)
  touch /.first
fi

exec /sbin/init
