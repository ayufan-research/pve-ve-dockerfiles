#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "$0: usage <version>"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -xeo pipefail
ls "versions/$VERSION"
mkdir -p "tmp/$VERSION"
mkdir -p "deb/$VERSION"

docker build -t pve-ve-build-env --target=build_env "."
docker run -it -v "$PWD:/src" -e BUILD=1 pve-ve-build-env /src/scripts/build.bash "$VERSION"
