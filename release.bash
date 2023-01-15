#!/bin/bash

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
  echo "$0: usage <version> [tag]"
  exit 1
fi

VERSION="$1"
TAG="${2:-pve-ve-release}"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -xeo pipefail
docker build -f Dockerfile.env -t pve-ve-build-env "."
docker build -f Dockerfile.release \
  --build-arg "VERSION=$VERSION" \
  --build-arg "IMAGE=pve-ve-build-env" \
  -t "${TAG}" "."
