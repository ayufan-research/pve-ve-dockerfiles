#!/bin/bash

set -xeo pipefail

package="$1/"
out="../versions/7.2/pbs/$package/"
shift

MSG="$@"

git -C "$package" add .
if ! git -C "$package" diff --cached --exit-code --quiet; then
  mkdir "$out"
  git -C "$package" diff --cached | cat
  git -C "$package" commit -m "$MSG"
  git -C "$package" format-patch --output-directory "$out" HEAD~1
fi
