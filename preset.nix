{lib, ...}:
with lib; {
  security.unprivilegedUsernsClone = mkForce true; # steam, firefox, etc
  az.core = {
    hardening.malloc = mkDefault "libc"; # lots of desktop stuff breaks with hardened allocators
    hardening.enabledModules = mkDefault ["ntfs"];
    hardening.enabledWrappers = [
      "unix_chkpwd" # password logins

      # setcap, not setuid/gid + required for functionality
      "gnome-keyring-daemon"
      "sunshine"
    ];

    users.main = {
      wheel = mkDefault true;
    };
    # per-host: boot.loader.<name>.enable = mkDefault true;
  };

  az.svc.endlessh.enable = mkDefault true;
  az.svc.usbguard.allowIO = mkDefault "first";

  az.desktop = {
    programs.enable = mkDefault true;
    sound.enable = mkDefault true;
    bluetooth.enable = mkDefault true;
    fonts.enable = mkDefault true;
    home.enable = mkDefault true;

    printing.enable = mkDefault false;

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
