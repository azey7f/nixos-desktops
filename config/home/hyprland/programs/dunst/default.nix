{
  lib,
  config,
  ...
}: let
  cfg = config.az.desktop.environment.hyprland;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        services.dunst = {
          enable = true;
          configFile = "${./dunstrc}";
        };
      })
      config.az.core.users;
  };
}
