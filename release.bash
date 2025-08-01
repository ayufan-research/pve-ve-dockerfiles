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

ARCHS="arm64 amd64"
VERSION="${VERSION:-$(cat VERSION)}"

if [[ -z "$ARCH" ]]; then
  case "$(dpkg --print-architecture)" in
    arm64) ARCH="arm64" ;;
    amd64) ARCH="amd64" ;;
    *) echo "Unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;;
  esac
fi

case "$ARCH" in
  arm64)
    IMAGE_PREFIX="arm64v8/"
    TARGET_PLATFORM="linux/arm64/v8"
    CROSS_ARCH=""
    ;;
  amd64)
    IMAGE_PREFIX="amd64/"
    TARGET_PLATFORM="linux/amd64"
    CROSS_ARCH=""
    ;;
  arm32)
    IMAGE_PREFIX="arm64v8/"
    TARGET_PLATFORM="linux/arm64/v8"
    CROSS_ARCH="arm32"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

RELEASE_TAG="$TAG-${CROSS_ARCH:-$ARCH}"
BUILD_TAG="$TAG-build-${CROSS_ARCH:-$ARCH}"
DEB_TAG="$TAG-deb-${CROSS_ARCH:-$ARCH}"

docker_build() {
  docker build \
    --build-arg=ARCH="$ARCH" \
    --build-arg=CROSS_ARCH="$CROSS_ARCH" \
    --build-arg=VERSION="$VERSION" \
    --build-arg=IMAGE_PREFIX="$IMAGE_PREFIX" \
    --platform="$TARGET_PLATFORM" \
    "$@"
}

for i; do
  case "$i" in
    build-deb)
      docker_build --file=dockerfiles/Dockerfile.build --target="deb_env" --tag="$DEB_TAG" "."
      docker run --rm -v "$PWD":/dest "$DEB_TAG" sh -c 'cp -rv /release /dest'
      ;;

    build-tgz)
      docker_build --file=dockerfiles/Dockerfile.build --target="deb_env" --tag="$DEB_TAG" "."
      mkdir -p release/
      docker run --rm -v "$PWD":/dest "$DEB_TAG" sh -c 'cp -rv /*.tgz /dest/release/'
      ;;

    build-image)
      docker_build --file=dockerfiles/Dockerfile.build --target="deb_env" --tag="$DEB_TAG" "."
      docker_build --file=dockerfiles/Dockerfile.release --build-arg=IMAGE="$DEB_TAG" --target="release_env" --tag="$RELEASE_TAG" "."
      ;;

    push-image)
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
