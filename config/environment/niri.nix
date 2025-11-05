{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.az.desktop.environment.niri;
in {
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [inputs.niri.overlays.niri];

    niri-flake.cache.enable = false;
    programs.niri = {
      enable = true;
      package = pkgs.niri; # force use nixpkgs version instead of the niri flake one
    };
  };
}
