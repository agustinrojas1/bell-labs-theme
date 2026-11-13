-- Bell Labs — Hyprland (Lua config, Hyprland ≥ 0.53 / Omarchy 4).
local active = "rgb({{border_active.hex}})"
local inactive = "rgb({{border_inactive.hex}})"

hl.config({
  general = {
    border_size = 3,
    gaps_in = 3,
    gaps_out = 6,
    col = { active_border = active, inactive_border = inactive },
  },

  decoration = {
    rounding = 0,
    shadow = { enabled = false },
    blur = { enabled = false },
  },

  group = {
    col = { border_active = active, border_inactive = inactive },
    groupbar = {
      font_family = "GoMono Nerd Font",
      text_color = "rgb({{foreground.hex}})",
      text_color_inactive = "rgb({{foreground_dim.hex}})",
      col = {
        active = "rgb({{selection_alt.hex}})",
        inactive = "rgb({{background_alt.hex}})",
      },
      gradients = false,
    },
  },

  misc = {
    background_color = "rgb({{desktop.hex}})",
  },
})
