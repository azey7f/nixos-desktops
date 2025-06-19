{
  config,
  lib,
  azLib,
  ...
}:
with lib; {
  options.az.desktop.sound.enable = azLib.opt.optBool false;

  config = mkIf config.az.desktop.sound.enable {
    # sound.enable = true; # shouldn't be used with pw
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
