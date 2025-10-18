{
  pkgs,
  config,
  lib,
  azLib,
  ...
}: let
  cfg = config.az.desktop;
in {
  imports = lib.subtractLists [./scripts ./wallpapers] (azLib.scanPath ./.);

  options.az.desktop = with azLib.opt; {
    home.enable = optBool false;

    # no effect on KDE
    binds = {
      volumeSteps = {
        large = optStr "25%";
        normal = optStr "5%";
        small = optStr "1%";
        precise = optStr "0.1%";
      };
      brightnessSteps = {
        large = optStr "25%";
        normal = optStr "5%";
        small = optStr "1%";
        precise = optStr "1";
      };
    };
  };
}
