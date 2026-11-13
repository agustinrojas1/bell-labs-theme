#!/usr/bin/env bash
# Build the Omarchy themes into ~/.config/omarchy/themes/:
#   bell-labs        acme paper (light)
#   bell-labs-night  Plan 9 inks on Bell navy (dark)
#
# Prompt style per variant (bell, rc or term). Defaults: bell for light, rc for night.
#   BELL_LABS_PROMPT=term ./install-omarchy.sh      # same style for both
#
# Then: omarchy theme set bell-labs   (or bell-labs-night)
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
themes=${OMARCHY_THEMES_DIR:-"$HOME/.config/omarchy/themes"}
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT

for palette in "$root"/palettes/*.toml; do
  name=$(basename "$palette" .toml)
  dest="$themes/$name"
  mode=$(sed -n 's/^mode *= *"\(.*\)".*/\1/p' "$palette")
  if [[ $mode == dark ]]; then prompt=${BELL_LABS_PROMPT:-rc}; else prompt=${BELL_LABS_PROMPT:-bell}; fi

  "$root/render.sh" "$palette" "$build/$name" >/dev/null
  b="$build/$name"

  rm -rf "$dest"
  mkdir -p "$dest/backgrounds" "$dest/nvim/colors" "$dest/fastfetch"
  cp "$b"/omarchy/{colors.toml,neovim.lua,ghostty.conf,shell.toml} "$dest/"
  cp "$b/hyprland.lua" "$b/btop.theme" "$dest/"
  cp "$b/nvim/bell-labs.lua" "$dest/nvim/colors/bell-labs.lua"
  # linked into ~/.config by extras/omarchy-theme-dotfiles.sh while the theme is active
  cp "$b"/fastfetch/* "$dest/fastfetch/"
  cp "$b/starship/$prompt.toml" "$dest/starship.toml"
  cp "$root/wallpapers/$name"/*.png "$dest/backgrounds/"
  [[ -f "$root/omarchy/preview-$name.png" ]] && cp "$root/omarchy/preview-$name.png" "$dest/preview.png"
  if [[ $mode == dark ]]; then echo "Yaru-blue-dark"; else echo "Yaru-blue"; fi >"$dest/icons.theme"

  echo "installed $name ($mode, prompt: $prompt) into $dest"
done

hook="$HOME/.config/omarchy/hooks/theme-set.d/omarchy-theme-dotfiles.sh"
if command -v omarchy >/dev/null && ! cmp -s "$root/extras/omarchy-theme-dotfiles.sh" "$hook"; then
  rm -f "$hook"
  omarchy hook install theme-set "$root/extras/omarchy-theme-dotfiles.sh"
fi
