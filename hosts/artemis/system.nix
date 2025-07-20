{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.hostName = "artemis";
  networking.hostId = "9f3afe64";
  networking.domain = "azey.net";
  system.stateVersion = config.system.nixos.release; # / is on tmpfs, so this should be fine

  az.core = {
    firmware.enable = false;
    boot.loader.grub.enable = true;
    net.systemdDefault = true;
  };

  az.desktop = {
    graphics.nvidia.enable = true;
    #boot.plymouth.enable = true;

    binds.volumeSteps = {
      large = "10%";
      normal = "2%";
      small = "0.5%";
    };

    environment = {
      kde = lib.mkIf (config.specialisation != {}) {
        enable = true;
        session = "plasmax11";
      };
      autoLogin.user = "main";
    };
  };

  specialisation.Niri.configuration.az.desktop.environment.niri = let
    primaryM = "PNP(AOC) 32G1WG4 0x00001165";
    secondaryM = "Microstep MSI MAG275R 0x0000037E";
  in {
    enable = true;
    monitors = {
      ${primaryM} = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.001;
        };
        position.x = 1920;
        position.y = 0;
        focus-at-startup = true;
      };
      ${secondaryM} = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        position.x = 0;
        position.y = 0;
      };
    };
    swaybg."DP-1" = "space.jpg";
    swaybg."HDMI-A-1" = "abstract.jpg";
  };

  specialisation.Hyprland.configuration.az.desktop.environment.hyprland = let
    primaryM = "desc:AOC 32G1WG4 0x00001165";
    secondaryM = "desc:Microstep MSI MAG275R 0x0000037E";
  in {
    enable = true;

    services.hyprpaper.monitors.${primaryM}.wallpaper = "space.jpg";
    services.hyprpaper.monitors.${secondaryM}.wallpaper = "abstract.jpg";

    monitors = {
      ${primaryM} = {
        resolution = "1920x1080@144";
        position = "1920x0";
        #position = "1080x400";
      };
      ${secondaryM} = {
        position = "0x0";
        #extraArgs = ", transform, 3"; # 270deg
      };
    };
  };

  az.svc = {
    ssh = {
      enable = true;
      openFirewall = true;
      ports = [443];
    };

    sunshine = {
      enable = true;
      openFirewall = true;
      monitor = 1;
    };
  };

  environment.systemPackages = with pkgs; [
    androidStudioPackages.canary
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
}
