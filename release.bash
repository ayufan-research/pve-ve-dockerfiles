#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "$0: usage <version>"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -xeo pipefail
docker build --build-arg "VERSION=$VERSION" -t pve-ve-release "."
