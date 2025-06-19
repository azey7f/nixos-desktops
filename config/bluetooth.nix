{
  config,
  lib,
  azLib,
  ...
}:
with lib; {
  options.az.desktop.bluetooth.enable = azLib.opt.optBool false;

  config = mkIf config.az.desktop.bluetooth.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    #services.blueman.enable = true;
  };
}
