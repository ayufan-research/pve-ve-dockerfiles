#!/bin/bash

set -xeo pipefail

NAME="pve-ve-release"
IMAGE="pve-ve-release"

arg="$1"
[[ -n "$arg" ]] && shift

case "$arg" in
  "")
    docker rm -f "$NAME"
    docker run --name="$NAME" --cgroupns=host \
      --privileged \
      --shm-size=256m \
      --hostname pve-ve \
      --publish 8006:8006 \
      -e ROOT_PASSWORD=root1 \
      --volume "$PWD/tmp/proxmox/etc:/var/lib/proxmox-etc" \
      --volume "$PWD/tmp/proxmox/vz:/var/lib/vz" \
      --volume "$PWD:/src" \
      --rm \
      -t "$IMAGE"
    ;;

  kill)
    docker kill "$NAME"
    ;;

  enter)
    exec docker exec -it "$NAME" /bin/bash
    ;;
esac
