#!/bin/bash

if [[ $# -ne 0 ]]; then
  echo "$0: usage"
  exit 1
fi

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/"

set -xeo pipefail

docker build -f dockerfiles/Dockerfile.release -t pve-ve-release --target release_env "."

