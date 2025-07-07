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
DEB_TAG="$TAG-deb"

for i; do
  case "$i" in
    build)
      docker build --file=dockerfiles/Dockerfile.build --target="build_env" --tag="$BUILD_TAG" "."
      ;;

    builddeb)
      docker build --file=dockerfiles/Dockerfile.build --target="deb_env" --tag="$DEB_TAG" "."
      ;;

    archivedeb)
      docker run --rm -v "$PWD":/dest "$DEB_TAG" cp -rv /release /dest
      ;;

    release)
      RELEASE_OPTS=
      if docker inspect "$DEB_TAG" &>/dev/null; then
        RELEASE_OPTS="--build-arg=IMAGE=$DEB_TAG"
      fi
      docker build --file=dockerfiles/Dockerfile.release $RELEASE_OPTS --target="release_env" --tag="$TAG" "."
      ;;

    push)
      docker push "$TAG"
      ;;

    manifest)
      docker manifest create "$TAG" "$TAG-"{arm64v8}
      docker manifest push "$TAG"
      ;;

    *)
      echo "Unsure what to do with '$1'."
      exit 1
      ;;
  esac
done
