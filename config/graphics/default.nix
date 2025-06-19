{
  config,
  lib,
  azLib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.az.desktop.graphics;
in {
  imports = azLib.scanPath ./.;

  options.az.desktop.graphics = with azLib.opt; {
    nvidia.enable = optBool false;
    amdgpu.enable = optBool false;
  };

  config.hardware = optionalAttrs (cfg.nvidia.enable || cfg.amdgpu.enable) {
    # 24.05 uses hardware.opengl, unstable uses hardware.graphics
    graphics.enable = true;
    graphics.enable32Bit = true;
  };
}
