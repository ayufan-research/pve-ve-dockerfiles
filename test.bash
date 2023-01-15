#!/bin/bash

if [[ $# -ne 0 ]]; then
  echo "$0: usage <no-args>"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -xeo pipefail
docker build -t pve-ve-build-env --target=build_env "."
docker run -it -v "$PWD:/src" -w "$PWD/src" -e BUILD=1 pve-ve-build-env /bin/bash
