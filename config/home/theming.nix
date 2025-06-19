{
  pkgs,
  lib,
  azLib,
  config,
  ...
}:
with lib; let
  cfg = config.az.desktop.home;
in {
  options.az.desktop.home.theming.enable = azLib.opt.optBool cfg.enable;

  config = mkIf cfg.theming.enable {
    environment.systemPackages = with pkgs; [
      andromeda-gtk-theme
      dracula-icon-theme
    ];

    home-manager.users =
      attrsets.mapAttrs (name: _: {
        home.sessionVariables.GTK_THEME = "Andromeda";
        gtk = {
          enable = true;
          theme.name = "Andromeda";
          iconTheme.name = "Dracula";
        };
      })
      (config.az.core.users // {root = {};});
  };
}
