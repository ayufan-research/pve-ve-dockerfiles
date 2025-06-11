#!/bin/bash

set -xeo pipefail

package="$1"
out="$PWD/../repos/patches/$package/"
shift

MSG="$@"

ls -al "$(dirname "$out")"

if git -C "$package" commit -am "$MSG"; then
  git -C "$package" show | cat
  git -C "$package" format-patch --output-directory "$out" HEAD~1
fi
