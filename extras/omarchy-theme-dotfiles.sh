#!/bin/bash
# Omarchy theme-set hook: let a theme ship its own fastfetch and starship setup.
#
# If the active theme has fastfetch/ or starship.toml, link them into
# ~/.config. Your own files are moved aside to *.pre-theme and put back as soon
# as you switch to a theme that doesn't ship one. Works for any theme.
#
# Install: omarchy hook install theme-set extras/omarchy-theme-dotfiles.sh

theme_dir="$HOME/.config/omarchy/current/theme"

swap() {
  local target=$1 source=$2 backup="$1.pre-theme"

  if [[ -e $source ]]; then
    if [[ -e $target && ! -L $target ]]; then
      mv "$target" "$backup"
    fi
    mkdir -p "$(dirname "$target")"
    ln -sfn "$source" "$target"
  elif [[ -L $target && $(readlink "$target") == "$theme_dir"/* ]]; then
    rm "$target"
    [[ -e $backup ]] && mv "$backup" "$target"
  fi
  return 0
}

swap "$HOME/.config/starship.toml" "$theme_dir/starship.toml"
swap "$HOME/.config/fastfetch" "$theme_dir/fastfetch"
