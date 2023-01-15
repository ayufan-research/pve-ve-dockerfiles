#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <out>"
  exit 1
fi

find "." -name '*.deb' | xargs -r -I{} cp {} "$1/"
find "$1" -name '*-dev_*.deb' | xargs -r rm
find "$1" -name '*-dbgsym_*.deb' | xargs -r rm
find "$1" -name '*-dbg_*.deb' | xargs -r rm
find "$1" -name 'proxmox-backup-server_*.deb' | xargs -r rm
