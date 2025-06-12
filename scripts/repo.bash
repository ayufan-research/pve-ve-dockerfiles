#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <name> [operations...]"
  exit 1
fi

set -xeo pipefail
export DEBIAN_FRONTEND=noninteractive

REPO="$1"
shift

mkdir -p build
cd build

../scripts/git-clone.bash ../repos/versions "$REPO"
../scripts/strip-cargo.bash "$REPO"
../scripts/apply-patches.bash "../repos/patches/$REPO"
../scripts/resolve-dependencies.bash "$REPO"
../scripts/experimental-cargo.bash "$REPO"

do_dpkg_build() {
  local d="${1:-.}"
  cd "$d/"
  git clean -ffdx
  [[ -e "debian/control" ]] && apt-get -y build-dep "$PWD"
  mkdir -p .build
  cp -av * .build/
  cd .build/
  DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -uc -us -b
  do_archive
}

do_dpkg_install() {
  find "." -name "*.deb" | xargs -r apt -y install
}

run_until_broken() {
  for i in $(seq 1 10); do
    if eval "$@"; then
      return 0
    fi

    if apt-get check >/dev/null 2>&1; then
      echo "Build failure."
      return 1
    fi

    echo "APT reports broken dependencies."
    apt-get install -f -y
  done

  return 1
}

do_make_dinstall() {
  local d="${1:-.}"
  local p="${2:-.}"
  shift || true
  shift || true

  cd "$d/"
  git clean -ffdx -e '*.deb'
  [[ -e "$p/debian/control" ]] && apt-get -y build-dep "$PWD/$p"
  run_until_broken make dinstall "$@"
  do_archive
}

do_make_deb() {
  local d="${1:-.}"
  local p="${2:-.}"
  shift 2 || true

  cd "$d/"
  git clean -ffdx -e '*.deb'
  [[ -e "$p/debian/control" ]] && apt-get -y build-dep "$PWD/$p"
  run_until_broken make deb "$@"
  do_archive
}

do_rm() {
  cd ..
  rm -rf "$REPO"
}

do_archive() {
  mkdir -p "../../release/$REPO"
  find "." -name "*.deb" | xargs -r -I{} cp -v "{}" "../../release/$REPO"
}

cd "$REPO"
for arg; do
  ( eval "do_$arg" )
done
