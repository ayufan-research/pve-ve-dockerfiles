#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -xeo pipefail
docker build -f Dockerfile.env -t pve-ve-build-env "."
docker run -it -v "$PWD:/src" -w "/src" pve-ve-build-env "$@"
