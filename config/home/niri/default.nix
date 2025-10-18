{
  lib,
  azLib,
  config,
  pkgs,
  inputs,
  ...
} @ args:
with lib; let
  cfg = config.az.desktop.environment.niri;
  wallpapers = ../wallpapers;
in {
  #imports = azLib.scanPaths [./programs];

  options.az.desktop.environment.niri = with azLib.opt; {
    monitors = mkOption {
      type = types.attrs;
      default = {};
    };

    swaybg = mkOption {
      type = with types; attrsOf str;
      default = {};
    };

    windowRules = mkOption {
      type = with types; listOf attrs;
      default = [];
    };

    librewolfDefaultWidth = mkOption {
      type = types.ints.positive;
      default = 1801; # 1800x900 letterboxing for 1080p
    };
  };

  config = mkIf cfg.enable {
    az.desktop.programs = {
      vlock.enable = true;
      clipse.enable = true;
      dunst.enable = true;
      tofi.enable = true;
      waybar = {
        enable = true;
        margin = 5;
        modules.right = [
          #"cava"
          "tray"
          "network"
          "bluetooth"
          "privacy"
          "niri/language"
          "group/backlight"
          "group/audio"
          "battery"
          "niri/workspaces"
        ];
        modules.center = ["niri/window"];
      };
    };

    environment.systemPackages = with pkgs; [
      tofi
      wl-clipboard
      clipse
      iwgtk
      nautilus
      overskride
      swaybg
      xwayland-satellite
    ];

    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.fish = {
          enable = true;
          loginShellInit = ''
            if test (tty) = "/dev/tty1"
              set -Ux NIRI_SHELL_EXIT 0

              niri-session -l

              # see binds.nix, Mod+M logs out while Mod+K exits to shell
              exec fish -c 'if test $NIRI_SHELL_EXIT -eq 1; set -Ux NIRI_SHELL_EXIT 0; exec fish; end'
            end
          '';
        };

        programs.kitty.settings.background_opacity = mkForce 0.9; # compensate for no blur

        programs.niri = {
          settings = rec {
            outputs = cfg.monitors;

            # misc
            screenshot-path = null;
            hotkey-overlay.skip-at-startup = true;

            environment.NIXOS_OZONE_WL = "1";
            environment.DISPLAY = ":0";

            /*
            xwayland-satellite = {
              enable = true;
              path = lib.getExe pkgs.xwayland-satellite-unstable;
            };
            */

            # input
            input = {
              keyboard.xkb = {
                layout = "us";
                variant = "colemak";
              };
              keyboard.numlock = true;

              focus-follows-mouse = {
                enable = true;
                max-scroll-amount = "95%";
              };

              touchpad.natural-scroll = false;

              power-key-handling.enable = false;
            };

            # startup
            spawn-at-startup =
              [
                {command = ["xwayland-satellite"];}
                {command = ["clipse" "-listen"];}
                {command = ["systemctl" "restart" "--user" "waybar"];}
              ]
              ++ (mapAttrsToList (output: wallpaper: {
                  command = ["swaybg" "-o${output}" "-i${wallpapers}/${wallpaper}"];
                })
                cfg.swaybg);

            # binds
            binds = import ./binds.nix args;
            switch-events = {
              lid-close = binds."Mod+X"; # lock
            };

            # rules
            window-rules =
              [
                {
                  matches = [{app-id = "^kitty$";}];
                  draw-border-with-background = false; # enable transparency
                  default-column-width.proportion = 0.5;
                }
                {
                  matches = [{app-id = "^clipse$";}];
                  draw-border-with-background = false; # enable transparency
                  default-window-height.fixed = 652;
                  default-column-width.fixed = 622;
                  open-floating = true;
                  open-focused = true;
                }
                {
                  matches = [{app-id = "^librewolf$";}];
                  default-column-width.fixed = cfg.librewolfDefaultWidth; # match letterboxing
                }
              ]
              ++ cfg.windowRules;

            layer-rules = [
              {
                matches = [
                  {namespace = "waybar";}
                  {namespace = "wallpaper";}
                  {namespace = "swww";}
                ];
                place-within-backdrop = true;
              }
            ];

            # styling
            prefer-no-csd = true;
            layout = {
              gaps = 5;
              background-color = "#00000000"; # transparent
              focus-ring.enable = false;
              border = {
                enable = true;
                width = 1.5;
                active = {
                  gradient = {
                    from = "#33ccff";
                    to = "#cc33ff";
                    angle = 45;
                  };
                };
                inactive = {
                  gradient = {
                    from = "#cc33ff";
                    to = "#33ccff";
                    angle = 45;
                  };
                };
              };
            };
          };
        };
      })
      config.az.core.users;
  };
}
