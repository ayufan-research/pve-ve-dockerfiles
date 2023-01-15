#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "$0: usage <version>"
  exit 1
fi

VERSION="$1"

set -xeo pipefail

mkdir -p "/src/tmp/$VERSION"
mkdir -p "/src/deb/$VERSION"
cd "/src/tmp/$VERSION"

[[ -x /src/scripts/run/install.bash ]] && /src/scripts/run/install.bash "/src/tmp/$VERSION"
/src/scripts/build/clone.bash "/src/versions/$VERSION/versions"
/src/scripts/build/strip-cargo.bash
/src/scripts/build/apply-patches.bash "/src/versions/$VERSION/pbs" || [[ -n "$FORCE" ]]
/src/scripts/build/apply-patches.bash "/src/versions/$VERSION/pbs-$(dpkg --print-architecture)" || [[ -n "$FORCE" ]]
/src/scripts/build/resolve-dependencies.bash
/src/versions/"$VERSION"/build.bash
/src/scripts/build/export-deb.bash "/src/deb/$VERSION"
