#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

set -xeo pipefail

rm -f /etc/apt/sources.list.d/pbs-enterprise.list
echo deb http://deb.debian.org/debian bullseye-backports main > /etc/apt/sources.list.d/backports.list
apt-get -y update
find "$(realpath "${1:-$SCRIPT_DIR}")" -name '*.deb' | xargs -r apt install -y
