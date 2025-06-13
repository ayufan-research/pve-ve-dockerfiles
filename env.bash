#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -eo pipefail

TAG=pve-ve-build-env

if [[ "$1" == "new" ]]; then
  echo ">> Removing old"
  docker rmi "$TAG" &> /dev/null || true
  shift
fi

if ! docker inspect "$TAG" &>/dev/null; then
  echo ">> Building..."
  docker build -f dockerfiles/Dockerfile.env -t "$TAG" --target toolchain "."
fi

if [[ $(docker inspect -f '{{.State.Status}}' pve-ve-build-env-run 2>/dev/null) == "running" ]]; then
  echo ">> Re-using..."
  if [[ $# -eq 0 ]]; then
    set -- "bash"
  fi
  docker exec -it "$TAG-run" "$@" || true
else
  docker rm -f "$TAG-run" &>/dev/null || true

  echo ">> Starting..."
  docker run -it -v "$PWD:/src" -w "/src" -v "$PWD/tmp/root:/root" --name="$TAG-run" "$TAG" "$@" || true

  echo ">> Committing..."
  docker commit "$TAG-run" "$TAG"
fi

echo ">> Done."
