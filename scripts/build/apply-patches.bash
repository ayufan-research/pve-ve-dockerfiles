#!/bin/bash

set -eo pipefail

while read p; do
  d=$(basename $(dirname "$p"))

  echo "$d => $p..."
  git -C "$d" apply --reverse --check "$(realpath "$p")" &>/dev/null && continue
  git -C "$d" status &>/dev/null
  git -C "$d" apply --index "$(realpath "$p")"
  git -C "$d" commit -m "$(basename "$p" .patch)"
done < <(find "$1" -name '*.patch' | sort -n)
