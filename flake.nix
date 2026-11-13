{
  description = "Bell Labs: a Plan 9 / acme-inspired desktop theme";

  outputs = { self }: {
    homeManagerModules.default = import ./nix/home-manager.nix;
    homeManagerModules.bell-labs = self.homeManagerModules.default;
    palettes = {
      light = builtins.fromTOML (builtins.readFile ./palettes/bell-labs.toml);
      night = builtins.fromTOML (builtins.readFile ./palettes/bell-labs-night.toml);
    };
  };
}
