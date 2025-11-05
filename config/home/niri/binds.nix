{
  lib,
  pkgs,
  config,
  inputs,
  ...
} @ args: let
  tofi = import ../scripts/tofi.nix pkgs;
  functionKeys = import ../scripts/function-keys.nix pkgs;
  cfg = config.az.desktop.binds;
  vlockCfg = config.az.desktop.programs.vlock;

  # TODO: for some reason just doing `with config.lib.niri.actions;` doesn't work
  actions = (inputs.niri.homeModules.config args).config.lib.niri.actions;
in
  with actions; {
    # exit
    "Mod+M".action = quit;
    "Mod+K".action = spawn "fish" "-c" "set -Ux NIRI_SHELL_EXIT 1; niri msg action quit"; # quit to shell
    # consume/expel
    "Mod+W".action = consume-window-into-column;
    "Mod+Shift+W".action = expel-window-from-column;
    # window control
    "Mod+Q".action = close-window;
    "Mod+A".action = expand-column-to-available-width;
    "Mod+F".action = maximize-column;
    "Mod+Shift+F".action = fullscreen-window;
    "Mod+Ctrl+F".action = toggle-window-floating;
    # niri stuff
    "Mod+Shift+Slash".action = show-hotkey-overlay;
    "Mod+Tab".action = toggle-overview;

    # system
    "Print".action.screenshot = []; # https://github.com/sodiboo/niri-flake/issues/1380
    "Mod+X".action = let
      # lock
      message = lib.removeSuffix "\n" "${vlockCfg.ascii}${vlockCfg.message}";
    in
      spawn "sh" "-c" ''VLOCK_MESSAGE="`echo -e \\\033[H\\\033[J`${message}" ${config.security.wrapperDir}/vlock-main all new nosysrq'';

    # tofi & clipboard
    "Mod+R".action = spawn "sh" "-c" "tofi-drun | xargs niri msg action spawn --";
    "Mod+Z".action = spawn "sh" "${tofi.powermenu}";
    "Mod+C".action = spawn "bash" "${tofi.calc}";
    "Mod+V".action = spawn "kitty" "-1" "--class=clipse" "-e" "clipse";

    # programs
    "Mod+T".action = spawn "kitty" "-1";
    "Mod+B".action = spawn "librewolf";

    # brightness
    "XF86MonBrightnessDown".action = spawn "sh" "${functionKeys.brightness}" "${cfg.brightnessSteps.normal}-";
    "XF86MonBrightnessUp".action = spawn "sh" "${functionKeys.brightness}" "+${cfg.brightnessSteps.normal}";
    "Shift+XF86MonBrightnessDown".action = spawn "sh" "${functionKeys.brightness}" "${cfg.brightnessSteps.small}-";
    "Shift+XF86MonBrightnessUp".action = spawn "sh" "${functionKeys.brightness}" "+${cfg.brightnessSteps.small}";
    "Mod+XF86MonBrightnessDown".action = spawn "sh" "${functionKeys.brightness}" "${cfg.brightnessSteps.large}-";
    "Mod+XF86MonBrightnessUp".action = spawn "sh" "${functionKeys.brightness}" "+${cfg.brightnessSteps.large}";
    "Ctrl+XF86MonBrightnessDown".action = spawn "sh" "${functionKeys.brightness}" "${cfg.brightnessSteps.precise}-";
    "Ctrl+XF86MonBrightnessUp".action = spawn "sh" "${functionKeys.brightness}" "+${cfg.brightnessSteps.precise}";

    # volume
    "XF86AudioMute".action = spawn "fish" "${functionKeys.mute}";
    "Shift+XF86AudioMute".action = spawn "fish" "${functionKeys.volumeLimit}";
    "XF86AudioLowerVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.normal}-";
    "XF86AudioRaiseVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.normal}+";
    "Shift+XF86AudioLowerVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.small}-";
    "Shift+XF86AudioRaiseVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.small}+";
    "Mod+XF86AudioLowerVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.large}-";
    "Mod+XF86AudioRaiseVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.large}+";
    "Ctrl+XF86AudioLowerVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.precise}-";
    "Ctrl+XF86AudioRaiseVolume".action = spawn "fish" "${functionKeys.volume}" "${cfg.volumeSteps.precise}+";

    # media
    "Mod+space".action = spawn "sh" "-c" "playerctl play-pause & sh ${functionKeys.media}";
    "XF86AudioPlay".action = spawn "sh" "-c" "playerctl play-pause & sh ${functionKeys.media}";
    "XF86AudioNext".action = spawn "sh" "-c" "playerctl next & sh ${functionKeys.media}";
    "XF86AudioPrev".action = spawn "sh" "-c" "playerctl previous & sh ${functionKeys.media}";
    "Shift+XF86AudioNext".action = spawn "sh" "-c" "playerctl position 10+ & dunstify 'Skipped 10s'";
    "Shift+XF86AudioPrev".action = spawn "sh" "-c" "playerctl position 10- & dunstify 'Skipped 10s'";

    # scroll through columns & ctrl-scroll through workspaces
    "Mod+WheelScrollDown".action = focus-column-right;
    "Mod+WheelScrollUp".action = focus-column-left;
    "Mod+Ctrl+WheelScrollDown".action = focus-workspace-down;
    "Mod+Ctrl+WheelScrollUp".action = focus-workspace-up;

    # move by shift-scrolling/ctrl-shift-scrolling
    "Mod+Shift+WheelScrollDown".action = move-column-right;
    "Mod+Shift+WheelScrollUp".action = move-column-left;
    "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-to-workspace-down {focus = true;};
    "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-to-workspace-up {focus = true;};

    # focus with arrows, move with shift-arrows
    "Mod+Right".action = focus-column-right;
    "Mod+Left".action = focus-column-left;
    "Mod+Down".action = focus-window-or-workspace-down;
    "Mod+Up".action = focus-window-or-workspace-up;
    "Mod+Shift+Right".action = move-column-right;
    "Mod+Shift+Left".action = move-column-left;
    "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;
    "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;

    # focus monitors with ctrl-arrows or move workspaces to monitors with ctrl-shift-arrows
    "Mod+Ctrl+Right".action = focus-monitor-right;
    "Mod+Ctrl+Left".action = focus-monitor-left;
    "Mod+Ctrl+Down".action = focus-monitor-down;
    "Mod+Ctrl+Up".action = focus-monitor-up;
    "Mod+Ctrl+Shift+Right".action = move-workspace-to-monitor-right;
    "Mod+Ctrl+Shift+Left".action = move-workspace-to-monitor-left;
    "Mod+Ctrl+Shift+Down".action = move-workspace-to-monitor-down;
    "Mod+Ctrl+Shift+Up".action = move-workspace-to-monitor-up;
  }
