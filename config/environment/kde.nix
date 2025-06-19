{
  config,
  lib,
  azLib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.az.desktop.environment.kde;
in {
  options.az.desktop.environment.kde = with azLib.opt; {
    session = optStr "plasma";
    autoLogin = {
      enable = optBool (cfg.autoLogin.user != null);
      user = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.xkb.variant = "colemak";
    services.xserver.enable = true;

    # per-host: services.xserver.videoDrivers = ["nvidia"];
    services.desktopManager.plasma6.enable = true;

    services.displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;

      defaultSession = cfg.session;

      # autoLogin.user = "main";
      sddm.settings.Autologin = lib.mkIf cfg.autoLogin.enable {
        Session = "${cfg.session}.desktop";
        User = cfg.autoLogin.user;
      };
    };

    environment.sessionVariables.NIXOS_OZONE_WL = 1;

    /*
      qt = { #TODO: styling?
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    */
  };
}
