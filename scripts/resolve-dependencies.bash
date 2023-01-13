get_deps() {
  sed -n -e '/^\[dep/,/^\[/{//!p}' "$1" | sed -n -e 's/^\([a-z0-9_-]*\)\s*=.*$/\1/p'
}

replace_patch_crates_io() {
  sed -i -e '/^\[patch\.crates-io\]/,/^\[/d' "$1"
  echo "[patch.crates-io]" >> "$1"
}

declare -A not_found_deps

update_deps() {
  local cargo_toml="$1"
  local cargo_package=$(basename $(dirname "$cargo_toml"))

  replace_patch_crates_io "$cargo_toml"

  while read cargo_dep; do
    [[ -n "${not_found_deps[$cargo_dep]}" ]] && continue

    cargo_path=$(find "$PWD" -wholename "*/$cargo_dep/Cargo.toml" -o -wholename "*/$cargo_dep-rs/Cargo.toml" | tail -n 1)
    if [[ -z "$cargo_path" ]]; then
      echo "$cargo_package: Cargo dep: $cargo_dep => not found"
      not_found_deps[$cargo_dep]=1
      continue
    fi

    cargo_path=$(dirname "$cargo_path")

    echo "$cargo_package: Cargo dep: $cargo_dep => found => $cargo_path"
    echo "$cargo_dep = { path = \"$cargo_path\" }" >> "$cargo_toml"
  done < <(get_deps "$cargo_toml")
}

while read CARGO_TOML; do
  update_deps "$CARGO_TOML"
done < <(find $1 -name Cargo.toml)
