# Bell Labs — Home Manager module.
#
#   imports = [ bell-labs.homeManagerModules.default ];
#   theme.bell-labs.enable = true;
#   theme.bell-labs.variant = "night";   # or "light"
#   theme.bell-labs.prompt = "rc";       # "bell", "rc" or "term"
#
# Every file is rendered from ../templates with ../palettes/*.toml at eval time,
# so the same templates serve Nix and render.sh.
{ config, lib, pkgs, ... }:

let
  cfg = config.theme.bell-labs;

  paletteFile = {
    light = ../palettes/bell-labs.toml;
    night = ../palettes/bell-labs-night.toml;
  }.${cfg.variant};
  palette = lib.filterAttrs (_: builtins.isString) (builtins.fromTOML (builtins.readFile paletteFile));

  # "{{key}}" is the value, "{{key.hex}}" drops the '#', "{{key.rgb}}" is "r;g;b".
  isHex = v: builtins.match "#[0-9A-Fa-f]{6}" v != null;
  channel = v: i: toString (lib.fromHexString (builtins.substring i 2 v));
  substitutions = lib.concatLists (lib.mapAttrsToList (k: v:
    [ { from = "{{${k}}}"; to = v; } ]
    ++ lib.optionals (isHex v) [
      { from = "{{${k}.hex}}"; to = lib.removePrefix "#" v; }
      { from = "{{${k}.rgb}}"; to = "${channel v 1};${channel v 3};${channel v 5}"; }
    ]) palette);
  render = name:
    builtins.replaceStrings (map (s: s.from) substitutions) (map (s: s.to) substitutions)
      (builtins.readFile (../templates + "/${name}"));

  has = app: builtins.elem app cfg.apps;
  file = path: name: { ${path}.text = render name; };
in
{
  options.theme.bell-labs = {
    enable = lib.mkEnableOption "the Bell Labs theme";

    variant = lib.mkOption {
      type = lib.types.enum [ "light" "night" ];
      default = "light";
      description = "light: acme paper. night: the same Plan 9 inks on Bell navy.";
    };

    prompt = lib.mkOption {
      type = lib.types.enum [ "bell" "rc" "term" ];
      default = "bell";
      description = ''
        Starship prompt style. bell: `[user@host:dir]$` (Bourne shell).
        rc: `; ` (Plan 9). term: `term% ` (Plan 9 terminal).
      '';
    };

    apps = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "alacritty" "foot" "ghostty" "kitty" "niri" "hyprland" "waybar" "mako"
        "fuzzel" "btop" "starship" "neovim" "fastfetch"
      ]);
      default = [ "alacritty" "foot" "ghostty" "kitty" "niri" "waybar" "mako" "fuzzel" "btop" "starship" "neovim" "fastfetch" ];
      description = "Applications to theme. Unlisted ones are left alone.";
    };

    palette = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      default = palette;
      description = "The palette, for use elsewhere in your configuration.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      fonts.fontconfig.enable = true;
      home.packages = [ pkgs.nerd-fonts.go-mono pkgs.go-font ];
    }

    # Terminals: a separate theme file, imported from the main config when
    # Home Manager manages that program.
    (lib.mkIf (has "alacritty") {
      xdg.configFile = file "alacritty/bell-labs.toml" "alacritty.toml";
      programs.alacritty.settings.general.import = [ "${config.xdg.configHome}/alacritty/bell-labs.toml" ];
    })
    (lib.mkIf (has "foot") {
      xdg.configFile = file "foot/bell-labs.ini" "foot.ini";
      programs.foot.settings.main.include = "${config.xdg.configHome}/foot/bell-labs.ini";
    })
    (lib.mkIf (has "ghostty") {
      xdg.configFile = file "ghostty/bell-labs.conf" "ghostty.conf";
      programs.ghostty.settings.config-file = "bell-labs.conf";
    })
    (lib.mkIf (has "kitty") {
      xdg.configFile = file "kitty/bell-labs.conf" "kitty.conf";
      programs.kitty.extraConfig = "include bell-labs.conf";
    })

    # Compositors: include the snippet from your own config (see README).
    (lib.mkIf (has "niri") { xdg.configFile = file "niri/bell-labs.kdl" "niri.kdl"; })
    (lib.mkIf (has "hyprland") { xdg.configFile = file "hypr/bell-labs.conf" "hyprland.conf"; })

    # Whole-file configs.
    (lib.mkIf (has "waybar") {
      xdg.configFile = file "waybar/style.css" "waybar/style.css" // file "waybar/config.jsonc" "waybar/config.jsonc";
    })
    (lib.mkIf (has "mako") { xdg.configFile = file "mako/config" "mako.conf"; })
    (lib.mkIf (has "fuzzel") { xdg.configFile = file "fuzzel/fuzzel.ini" "fuzzel.ini"; })
    (lib.mkIf (has "btop") {
      xdg.configFile = file "btop/themes/bell-labs.theme" "btop.theme";
      programs.btop.settings.color_theme = "bell-labs";
    })
    (lib.mkIf (has "starship") {
      programs.starship.settings = lib.mkDefault (builtins.fromTOML (render "starship/${cfg.prompt}.toml"));
    })
    (lib.mkIf (has "neovim") { xdg.configFile = file "nvim/colors/bell-labs.lua" "nvim/bell-labs.lua"; })
    (lib.mkIf (has "fastfetch") {
      xdg.configFile = file "fastfetch/config.jsonc" "fastfetch/config.jsonc"
        // file "fastfetch/bell-labs-logo.txt" "fastfetch/bell-labs-logo.txt";
    })
  ]);
}
