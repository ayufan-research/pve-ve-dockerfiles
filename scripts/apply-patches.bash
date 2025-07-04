#!/bin/bash

set -eo pipefail

for dir; do
  while read patch; do
    repo_name=$(basename $(dirname "$patch"))
    [[ ! -d "$repo_name" ]] && continue

    if [[ "$patch" == *.{arm64,amd64}.patch ]] && [[ "$patch" != *.$(dpkg --print-architecture).patch ]]; then
      continue
    fi
    
    echo "$patch => $repo_name..."
    if ! git -C "$repo_name" apply --index "$(realpath "$patch")"; then
      patch -p1 -d "$repo_name" < "$patch"
      find "$repo_name" -name '*.orig' -delete
      find "$repo_name" -name '*.rej' -delete
      git -C "$repo_name" add .
    fi

    if [[ -z "$(git -C "$repo_name" diff --cached)" ]]; then
      echo "Patch applied, but is in a submodule?"
      continue
    fi

    git -C "$repo_name" diff --cached > "$patch"
    git -C "$repo_name" commit -m "$(basename $patch)"
  done < <(find "$dir" -name "*.patch")
done
