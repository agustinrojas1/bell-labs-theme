#!/usr/bin/env bash
# Render templates/ with a palette.
#
#   ./render.sh                         every palette in palettes/ -> out/<name>/
#   ./render.sh palettes/x.toml [dir]   one palette -> dir (default out/x/)
#
# Needs only bash, sed and find, so it runs the same on Arch, NixOS or a Mac.
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)

render() {
  local palette=$1 out=$2 script
  script=$(mktemp)

  # palette lines look like: key = "value"  # comment
  while IFS= read -r line; do
    [[ $line =~ ^([a-z_]+)[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]] || continue
    local key=${BASH_REMATCH[1]} value=${BASH_REMATCH[2]}
    printf 's|{{%s}}|%s|g\n' "$key" "$value" >>"$script"
    if [[ $value =~ ^#([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$ ]]; then
      printf 's|{{%s.hex}}|%s|g\n' "$key" "${value#\#}" >>"$script"
      printf 's|{{%s.rgb}}|%d;%d;%d|g\n' "$key" "0x${BASH_REMATCH[1]}" "0x${BASH_REMATCH[2]}" "0x${BASH_REMATCH[3]}" >>"$script"
    fi
  done <"$palette"

  (
    cd "$root/templates"
    find . -type f | while read -r f; do
      mkdir -p "$out/$(dirname "$f")"
      sed -f "$script" "$f" >"$out/$f"
    done
  )
  rm -f "$script"

  if left=$(grep -rnoE '\{\{[a-z_.]+\}\}' "$out"); then
    echo "unknown palette keys:" >&2
    echo "$left" >&2
    exit 1
  fi
  echo "rendered $(basename "$palette" .toml) into $out"
}

if [[ $# -gt 0 ]]; then
  render "$1" "${2:-$root/out/$(basename "$1" .toml)}"
else
  for p in "$root"/palettes/*.toml; do
    render "$p" "$root/out/$(basename "$p" .toml)"
  done
fi
