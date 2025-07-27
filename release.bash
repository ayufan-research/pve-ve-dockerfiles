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

if [[ -z "$VERSION" ]]; then
  source repos/version.mk
fi

ARCH=""
ARCHS="arm64 amd64"
DPKG_ARCH="${DPKG_ARCH:-$(dpkg --print-architecture)}"

case "$DPKG_ARCH" in
  arm64)
    ARCH="arm64"
    IMAGE_PREFIX="arm64v8/"
    TARGET_PLATFORM="linux/arm64/v8"
    ;;
  amd64)
    ARCH="amd64"
    IMAGE_PREFIX="amd64/"
    TARGET_PLATFORM="linux/amd64"
    ;;
  *)
    echo "Unsupported architecture: $DPKG_ARCH"
    exit 1
    ;;
esac

RELEASE_TAG="$TAG-$ARCH"
BUILD_TAG="$TAG-build-$ARCH"
DEB_TAG="$TAG-deb-$ARCH"

docker_build() {
  docker build \
    --build-arg=ARCH="$ARCH" \
    --build-arg=DPKG_ARCH="$DPKG_ARCH" \
    --build-arg=VERSION="$VERSION" \
    --build-arg=IMAGE_PREFIX="$IMAGE_PREFIX" \
    --platform="$TARGET_PLATFORM" \
    "$@"
}

for i; do
  case "$i" in
    build)
      docker_build --file=dockerfiles/Dockerfile.build --target="build_env" --tag="$BUILD_TAG" "."
      ;;

    builddeb)
      docker_build --file=dockerfiles/Dockerfile.build --target="deb_env" --tag="$DEB_TAG" "."
      ;;

    archivedeb)
      docker run --rm -v "$PWD":/dest "$DEB_TAG" sh -c 'cp -rv /release /dest'
      ;;

    archivetgz)
      docker run --rm -v "$PWD":/dest "$DEB_TAG" sh -c 'cp -rv /proxmox-ve-server*.tgz /dest'
      ;;

    releasedeb)
      RELEASE_OPTS=
      if docker inspect "$DEB_TAG" &>/dev/null; then
        RELEASE_OPTS="--build-arg=IMAGE=$DEB_TAG"
      fi
      docker_build --file=dockerfiles/Dockerfile.release $RELEASE_OPTS --target="release_env" --tag="$RELEASE_TAG" "."
      ;;

    push)
      docker push "$RELEASE_TAG"
      ;;

    manifest)
      MANIFEST_ARCHS=""
      for i in $ARCHS; do
        if docker manifest inspect "$TAG-$i" &>/dev/null; then
          MANIFEST_ARCHS="$MANIFEST_ARCHS $TAG-$i"
        else
          echo "Manifest for $TAG-$i does not exist, skipping."
        fi
      done
      docker manifest create "$TAG" $MANIFEST_ARCHS
      docker manifest push "$TAG"
      ;;

    manifest-latest)
      semver_names() {
        local repo="${1%%:*}"
        local version="${1##*:}"
        while [[ "$version" == *.* ]]; do
          echo "$repo:$version"
          version="${version%.*}"
        done
        echo "$repo:$version"
        echo "$repo:latest"
      }

      MANIFEST_ARCHS=""
      for i in $ARCHS; do
        if docker manifest inspect "$TAG-$i" &>/dev/null; then
          MANIFEST_ARCHS="$MANIFEST_ARCHS $TAG-$i"
        else
          echo "Manifest for $TAG-$i does not exist, skipping."
        fi
      done

      for i in $(semver_names "$TAG"); do
        docker manifest create "$i" $MANIFEST_ARCHS
        docker manifest push "$i"
      done
      ;;

    *)
      echo "Unsure what to do with '$1'."
      exit 1
      ;;
  esac
done
