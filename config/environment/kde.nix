{
  config,
  lib,
  azLib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.az.desktop.environment;
in {
  options.az.desktop.environment.kde = with azLib.opt; {
    session = optStr "plasma";
  };

  config = lib.mkIf cfg.kde.enable {
    services.xserver.xkb.variant = "colemak";
    services.xserver.enable = true;

    # per-host: services.xserver.videoDrivers = ["nvidia"];
    services.desktopManager.plasma6.enable = true;

    services.displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;

      defaultSession = cfg.kde.session;

      # autoLogin.user = "main";
      sddm.settings.Autologin = lib.mkIf cfg.autoLogin.enable {
        Session = "${cfg.kde.session}.desktop";
        User = cfg.autoLogin.user;
      };
    };

    systemd.services."getty@tty1" = lib.mkIf cfg.autoLogin.enable (lib.mkForce {}); # don't autologin on TTY

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
