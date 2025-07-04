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

BUILD_TAG="$TAG-build"

for i; do
  case "$1" in
    build)
      docker build --file=dockerfiles/Dockerfile.build --tag="$BUILD_TAG" "."
      docker run --rm -v "$PWD":/dest "$BUILD_TAG" cp -rv /src/release /dest
      ;;

    release)
      RELEASE_OPTS=
      if docker inspect "$BUILD_TAG" &>/dev/null; then
        RELEASE_OPTS="--build-arg=DEB_ENV=$BUILD_TAG"
      fi
      docker build --file=dockerfiles/Dockerfile.release $RELEASE_OPTS --tag="$TAG" "."
      ;;

    *)
      echo "Unsure what to do with '$1'."
      exit 1
      ;;
  esac
done
