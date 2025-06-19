{lib, ...}:
with lib; {
  az.core = {
    users.main.enable = mkDefault true;
    # per-host: boot.loader.<name>.enable = mkDefault true;
  };

  az.svc.endlessh.enable = mkDefault true;

  az.desktop = {
    programs.enable = mkDefault true;
    sound.enable = mkDefault true;
    bluetooth.enable = mkDefault true;
    fonts.enable = mkDefault true;
    home.enable = mkDefault true;

    # per-host: environment.<name>.enable = true;
    # per-host: graphics.<name>.enable = true;

    environment.hyprland.inputDevices = {
      "logitech-gaming-mouse-g502" = mkDefault {
        accel_profile = "flat";
        sensitivity = -0.35;
      };
    };
  };
}
