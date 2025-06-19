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
  };

  config = mkIf (cfg.kde.enable || cfg.hyprland.enable) {
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
  };
}
