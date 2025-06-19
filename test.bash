#!/bin/bash

set -xeo pipefail

NAME="pve-ve-release-run"
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
      -v "$PWD/tmp/pve-cluster:/var/lib/pve-cluster" \
      -v "$PWD/tmp/pve-manager:/var/lib/pve-manager" \
      -v "$PWD/tmp/vz:/var/lib/vz" \
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
