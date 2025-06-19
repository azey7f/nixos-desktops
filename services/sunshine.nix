{
  config,
  lib,
  azLib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.az.svc.sunshine;
in {
  options.az.svc.sunshine = with azLib.opt; {
    enable = optBool false;
    openFirewall = optBool false;
    monitor = mkOpt types.int 0;
  };

  config = mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      openFirewall = cfg.openFirewall;
      settings = {
        wan_encryption_mode = 2; #forced
        lan_encryption_mode = 2;
        output_name = cfg.monitor;
        address_family = "both";
      };
      capSysAdmin = true;
    };
  };
}
