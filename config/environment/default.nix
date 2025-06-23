{
  config,
  azLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.az.desktop.environment;
in {
  imports = azLib.scanPath ./.;

  options.az.desktop.environment = with azLib.opt; {
    kde.enable = optBool false;
    hyprland.enable = optBool false;
    niri.enable = optBool false;

    autoLogin = {
      enable = optBool (cfg.autoLogin.user != null);
      user = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
  };

  config = mkIf (cfg.kde.enable || cfg.hyprland.enable || cfg.niri.enable) {
    # TODO
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    environment.systemPackages = [pkgs.xdg-user-dirs];
    environment.etc."xdg/user-dirs.defaults".text = ''
      DESKTOP=xdg/desktop
      DOWNLOAD=downloads
      TEMPLATES=xdg/templates
      PUBLICSHARE=xdg/public
      DOCUMENTS=xdg/documents
      MUSIC=xdg/music
      PICTURES=xdg/photos
      VIDEOS=xdg/video
    '';

    systemd.services."getty@tty1" = lib.mkIf cfg.autoLogin.enable {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        "" # override upstream default with an empty ExecStart
        "@${pkgs.utillinux}/sbin/agetty agetty --login-program ${pkgs.shadow}/bin/login --autologin ${cfg.autoLogin.user} --noclear %I $TERM"
      ];
    };
  };
}
