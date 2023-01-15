#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "$0: usage <version>"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

if [[ -n "$BUILD" ]]; then
  set -xeo pipefail

  cd "/src/tmp/$VERSION"
  /src/scripts/clone.bash "/src/versions/$VERSION/versions"
  /src/scripts/strip-cargo.bash
  /src/scripts/apply-patches.bash "/src/versions/$VERSION/pbs"
  /src/scripts/resolve-dependencies.bash
  "/src/versions/$VERSION/build.bash"
  /src/scripts/export-deb.bash "/src/deb/$VERSION"
  exit
fi

set -xeo pipefail
ls "versions/$VERSION"

mkdir -p "tmp/$VERSION"
mkdir -p "deb/$VERSION"

docker build -f Dockerfile.env -t pve-ve-build-env "."

if [[ -n "$DEBUG" ]]; then
  docker run -it -v "$PWD:/src" -w "$PWD/src" -e BUILD=1 pve-ve-build-env /bin/bash
else
  docker run -it -v "$PWD:/src" -e BUILD=1 pve-ve-build-env /src/build.bash "$VERSION"
fi
