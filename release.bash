#!/bin/bash

if [[ $# -le 1 ]]; then
  echo "$0: usage <tag> [build] [release]"
  exit 1
fi

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

TAG="$1"
shift

set -xeo pipefail

export DOCKER_BUILDKIT=1
BUILD_TAG="pve-ve-build-env"

for i; do
  case "$1" in
    build)
      docker build -f dockerfiles/Dockerfile.build --tag="$BUILD_TAG" "."
      docker run --rm -v "$PWD":/dest "$BUILD_TAG" cp -rv /src/release /dest
      ;;

    release)
      docker build -f dockerfiles/Dockerfile.release --tag="$TAG" "."
      ;;

    *)
      echo "Unsure what to do with '$1'."
      exit 1
      ;;
  esac
done
