{
  config,
  lib,
  azLib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.az.desktop.printing;
in {
  options.az.desktop.printing = with azLib.opt; {
    enable = optBool false;
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        epson-escpr
      ];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true; # Unable to locate printer "*.local"
    };
  };
}
