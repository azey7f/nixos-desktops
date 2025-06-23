{
  lib,
  azLib,
  config,
  ...
}: let
  cfg = config.az.desktop.programs.dunst;
in {
  options.az.desktop.programs.dunst.enable = azLib.opt.optBool false;
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
