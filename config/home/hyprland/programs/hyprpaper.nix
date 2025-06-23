{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.az.desktop.environment.hyprland;
  wallpapers = ../../wallpapers;
in {
  options.az.desktop.environment.hyprland.services.hyprpaper = {
    preload = mkOption {
      type = with types; listOf str;
      default = attrsets.mapAttrsToList (n: v: "${wallpapers}/${v.wallpaper}") cfg.services.hyprpaper.monitors;
    };
    monitors = mkOption {
      type = with types;
        attrsOf (submodule ({name, ...}: {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
            };
            wallpaper = mkOption {type = types.str;};

            mode = mkOption {
              type = types.str;
              default = "";
            };
          };
        }));
      default = {};
    };
  };

  config = mkIf cfg.enable {
    home-manager.users =
      attrsets.mapAttrs (name: _: {
        services.hyprpaper = {
          enable = true;
          settings = {
            inherit (cfg.services.hyprpaper) preload;
            wallpaper = attrsets.mapAttrsToList (n: v: "${n},${v.mode}${wallpapers}/${v.wallpaper}") cfg.services.hyprpaper.monitors;
          };
        };
      })
      config.az.core.users;
  };
}
