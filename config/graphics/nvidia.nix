{
  config,
  lib,
  azLib,
  ...
}:
with lib; let
  cfg = config.az.desktop.graphics.nvidia;
in {
  options.az.desktop.graphics.nvidia = with azLib.opt; {
    prime = {
      enable = mkEnableOption "";

      # prime config
      amdgpuBusId = optStr "";
      intelBusId = optStr "";
      nvidiaBusId = optStr "";
    };
  };

  config = mkIf cfg.enable {
    az.core.programs.config.btop.cudaSupport = mkDefault true;

    boot.initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    boot.blacklistedKernelModules = ["nouveau"];

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = false;
      powerManagement.finegrained = false; #TODO?
      nvidiaSettings = true;

      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      prime = mkIf cfg.prime.enable {
        inherit (cfg.prime) amdgpuBusId intelBusId nvidiaBusId;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
