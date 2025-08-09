#!/bin/bash

set -eo pipefail

CUR=$(pwd)
DIR=tmp/pve-backup-server-dockerfiles

OPTS=
if [[ -n "$1" ]]; then
  OPTS="--branch $1"
fi

rm -rf "$DIR"
git clone https://github.com/ayufan/pve-backup-server-dockerfiles.git "$DIR" $OPTS
cd "$DIR"
trap 'rm -rf "$DIR"' EXIT

COPY=( packages/* scripts/* repos/patches/* repos/*.deps )

for i in ${COPY[*]}; do
  rm -rf "$CUR/$i"
  cp -av "$i" "$CUR/$i"
done

while read REPO REST; do
  if ! grep "^$REPO " "repos/deps"; then
    echo "$REPO $REST"
  fi
done < "$CUR/repos/deps" > "deps.tmp"

mv "deps.tmp" "$CUR/repos/deps"

echo Done.
