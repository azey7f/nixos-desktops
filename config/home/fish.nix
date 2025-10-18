{
  lib,
  azLib,
  config,
  ...
}:
with lib; let
  cfg = config.az.desktop.home;
in {
  options.az.desktop.home.fish.enable = azLib.opt.optBool cfg.enable;

  config = mkIf cfg.fish.enable {
    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.fish = {
          enable = true;
          functions = {
            "ccat" = "highlight -O truecolor -s neon $argv";
            "icat" = "kitten icat $argv";
            "iptables" = "sudo iptables $argv";
            "ip6tables" = "sudo ip6tables $argv";
            "nix" = "sudo nix $argv";
            "nixos-rebuild" = "sudo nixos-rebuild $argv";
            "mount" = "sudo mount $argv";
            "umount" = "sudo umount $argv";
          };
        };
      })
      config.az.core.users;
  };
}
