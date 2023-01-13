#!/bin/bash

set -eo pipefail

for package in *; do
  [[ ! -d "$package" ]] && continue

  if [[ -f "$package/.cargo/config" ]]; then
    rm -v "$package/.cargo/config"
  fi

  while read debian_control; do
    echo "Stripping '$debian_control'..."

    # remove ex.: librust-anyhow-1+default-dev (when it ends with `,`)
    sed -i '/^\s*librust-.*-dev[^,]*,/d' "$debian_control"

    # in some cases just replace to `libstd-rust-dev`
    sed -i 's/^\s*librust-.*-dev[^,]*/ libstd-rust-dev/g' "$debian_control"

    # change `cargo:native (>= 0.65.0-1),` to `cargo:native <!nocheck>`
    sed -i 's/cargo:native\s*(>=.*)/cargo:native <!nocheck>/g' "$debian_control"

    # change `dh-cargo (>= 25),` to `dh-cargo`
    sed -i 's/dh-cargo\s*(>=.*)/dh-cargo/g' "$debian_control"
  done < <(find "$package" -wholename '*/debian/control')

  find "$package" -wholename '*/debian/cargo_home/config' -delete

  git -C "$package" add .
  if ! git -C "$package" diff --cached --exit-code --quiet; then
    git -C "$package" diff --cached | cat
    git -C "$package" commit -m "strip-cargo.bash"
  fi
done
