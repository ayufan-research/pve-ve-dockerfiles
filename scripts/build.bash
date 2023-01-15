#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "$0: usage <version>"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/.."

set -xeo pipefail

cd "/src/tmp/$VERSION"
/src/scripts/clone.bash "/src/versions/$VERSION/versions"
/src/scripts/strip-cargo.bash
/src/scripts/apply-patches.bash "/src/versions/$VERSION/pbs"
/src/scripts/resolve-dependencies.bash
/src/versions/"$VERSION"/build.bash
/src/scripts/export-deb.bash "/src/deb/$VERSION"
