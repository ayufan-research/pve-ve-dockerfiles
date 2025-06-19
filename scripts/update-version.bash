#!/bin/bash

set -eo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 [version-file|version] [sha]"
  exit 1
fi

if [[ -f "$1" ]]; then
  REPOS=$(realpath "$1")
  VERSION=""
elif [[ -f "repos/versions" ]]; then
  REPOS=$(realpath "repos/versions")
  VERSION="${1}"
else 
  echo "Missing 'versions' file."
  exit 1
fi


SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPT_ROOT=$(realpath "$0")
ROOT_SHA="${2:-master}"
ROOT_TS=""

tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
trap 'cd ; rm -rf $tmp_dir' EXIT

perform() {
  git clone "git://git.proxmox.com/git/$1.git" 2>/dev/null
  if [[ -z "$ROOT_TS" ]]; then
    if [[ "$ROOT_SHA" == "last" ]]; then
      ROOT_SHA="$2"
    fi
    REPO_REV=$(git -C "$1" rev-parse "$ROOT_SHA")
    ROOT_TS=$(git -C "$1" log -1 --format=%ct "$ROOT_SHA")
  else
    while read REPO_TS REPO_REV; do
      if [[ $REPO_TS -le $ROOT_TS ]]; then
        break
      fi
    done < <(git -C "$1" log --format="%ct %H")
  fi

  CHANGE_TIME=$(git -C "$1" log -1 --format="%cd" $REPO_REV)

  echo "$1 $REPO_REV # $CHANGE_TIME"
}

cd "$tmp_dir/"

while read REPO COMMIT_SHA REST; do
  echo "$REPO $COMMIT_SHA..." 1>&2
  REPO_TS=
  REPO_REV=
  perform "$REPO" "$COMMIT_SHA"

  if [[ -n "$VERSION" ]] && [[ -n "$REPO_REV" ]]; then
    $SCRIPT_ROOT "$(dirname "$REPOS")/$REPO.deps" "$REPO_REV"
  fi
done < "$REPOS" > "$REPOS.tmp"

mv "$REPOS.tmp" "$REPOS"

if [[ -n "$VERSION" ]]; then
  echo "VERSION := ${VERSION}" > "$REPOS/version.mk"
fi
