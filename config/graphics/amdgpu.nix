{
  config,
  lib,
  ...
}:
with lib; {
  config = lib.mkIf config.az.desktop.graphics.amdgpu.enable {
    az.core.programs.config.btop.rocmSupport = mkDefault true;

    boot.initrd.kernelModules = ["amdgpu"];
    services.xserver.videoDrivers = ["amdgpu"];
  };
}
