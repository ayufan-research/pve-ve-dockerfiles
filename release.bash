#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "$0: usage <version>"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -xeo pipefail
docker build -f Dockerfile.env -t pve-ve-build-env "."
docker build -f Dockerfile.release \
  --build-arg "VERSION=$VERSION" \
  --build-arg "IMAGE=pve-ve-build-env" \
  -t pve-ve-release "."
