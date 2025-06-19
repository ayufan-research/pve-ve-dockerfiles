#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -eo pipefail

TAG=pve-ve-build-env
TARGET=build

if [[ "$1" == "release" ]]; then
  TAG=pve-ve-release-env
  TARGET=release
  shift
fi

if [[ "$1" == "new" ]]; then
  echo ">> Removing old"
  docker rm -f "$TAG-run" &>/dev/null || true
  docker rmi -f "$TAG" &> /dev/null || true
  shift
fi

if [[ "$1" == "kill" ]]; then
  echo ">> Recycling old"
  docker rm -f "$TAG-run" &>/dev/null || true
  shift
fi

if ! docker inspect "$TAG" &>/dev/null; then
  echo ">> Building..."
  docker build -f "dockerfiles/Dockerfile.$TARGET" -t "$TAG" --target toolchain "."
fi

if [[ $(docker inspect -f '{{.State.Status}}' "$TAG-run" 2>/dev/null) == "running" ]]; then
  echo ">> Re-using..."
  if [[ $# -eq 0 ]]; then
    set -- "bash"
  fi
  docker exec -it "$TAG-run" "$@" || true
else
  docker rm -f "$TAG-run" &>/dev/null || true

  echo ">> Starting..."
  if [[ "$TARGET" == "release" ]]; then
    docker run -it \
      --cgroupns=host \
      --privileged \
      --shm-size=256m \
      --hostname pve-ve \
      --publish 8006:8006 \
      -w "/src" \
      --tmpfs /run \
      -v "$PWD:/src" \
      -v "$PWD/tmp/root:/root" \
      -v "$PWD/tmp/pve-cluster:/var/lib/pve-cluster" \
      -v "$PWD/tmp/pve-manager:/var/lib/pve-manager" \
      -v "$PWD/tmp/vz:/var/lib/vz" \
      --name="$TAG-run" \
      "$TAG" "$@" || true
  else
    docker run -it \
      -w "/src" \
      -v "$PWD:/src" \
      -v "$PWD/tmp/root:/root" \
      --name="$TAG-run" "$TAG" "$@" || true
  fi

  echo ">> Committing..."
  docker commit "$TAG-run" "$TAG"
fi

echo ">> Done."
