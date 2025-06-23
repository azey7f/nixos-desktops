{
  config,
  pkgs,
  lib,
  azLib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.az.desktop.environment.hyprland;
in {
  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;
    environment.sessionVariables.NIXOS_OZONE_WL = 1;
  };
}
