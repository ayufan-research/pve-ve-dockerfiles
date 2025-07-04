#!/bin/bash

if [[ "$1" == "--gen" ]]; then
  GEN=1
  shift
fi

if [[ $# -lt 2 ]]; then
  echo "usage: $0 [--gen] <folder> [package names...]"
  exit 1
fi

DIR=$(realpath "$1")
shift

cd "$DIR"
DIR=.

declare -A PKG_PATHS
declare -A PKG_DEPS

# Index all .deb files by package name
while read deb; do
  pkg=$(dpkg-deb -f "$deb" Package)
  deps=$(dpkg-deb -f "$deb" Depends | sed 's/([^)]*)//g' | tr ',' '\n' | awk '{print $1}' | xargs)
  PKG_PATHS["$pkg"]="$deb"
  PKG_DEPS["$pkg"]="$deps"
done < <(find "$DIR" -name "*.deb")

declare -A VISITED
resolve_deps() {
  local pkg="$1"

  # Process once
  [[ -n "${VISITED[$pkg]}" ]] && return
  VISITED["$pkg"]=1

  # Skip missing
  [[ -z "${PKG_PATHS[$pkg]}" ]] && return

  # Skip installed
  dpkg -s "$pkg" &>/dev/null && return

  # Resolve recursively
  echo "${PKG_PATHS[$pkg]}"
  for dep in ${PKG_DEPS[$pkg]}; do
    resolve_deps "$dep"
  done
}

resolve_all_pkgs() {
  for pkg; do
    resolve_deps "$pkg"
  done
}

if [[ -n "$GEN" ]]; then
  echo apt install -y $(resolve_all_pkgs "$@")
else
  set +x
  apt install -y $(resolve_all_pkgs "$@")
fi
