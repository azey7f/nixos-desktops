{
  config,
  lib,
  azLib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.az.desktop.programs;
in {
  options.az.desktop.programs = with azLib.opt; {
    enable = optBool false;
    excludedPackages = mkOption {
      type = with types; listOf package;
      default = [];
    };

    steam.enable = optBool true;
    steam.openFirewall = optBool false;
    zerotier.enable = optBool false;
    mullvad.enable = optBool true;

    dev.enable = optBool true;
  };

  config = mkIf cfg.enable {
    ### PROGRAMS ###
    programs.adb.enable = cfg.dev.enable;

    services.mullvad-vpn.enable = cfg.mullvad.enable;
    services.mullvad-vpn.enableExcludeWrapper = false;

    programs.steam = mkIf cfg.steam.enable {
      enable = true;
      remotePlay.openFirewall = cfg.steam.openFirewall;
      dedicatedServer.openFirewall = cfg.steam.openFirewall;
      gamescopeSession.enable = true;
      extraPackages = with pkgs; [xorg.libSM.out];
    };
    programs.gamescope = {
      enable = true;
      # https://github.com/ValveSoftware/gamescope/issues/1622#issuecomment-2508182530
      package = pkgs.gamescope.overrideAttrs (_: {
        NIX_CFLAGS_COMPILE = ["-fno-fast-math"];
      });
    };

    programs.virt-manager.enable = true;
    services.zerotierone.enable = cfg.zerotier.enable;

    services.tor.enable = true;
    services.tor.client.enable = true;

    ### PACKAGES ###
    environment.systemPackages = with pkgs;
      lists.subtractLists cfg.excludedPackages (
        (
          lib.optionals cfg.dev.enable
          [
            gh
            #git-credential-manager
            cargo
            rustc
            yarn-berry
            nodejs
            arduino-ide
            arduino-cli
            screen
            (python3.withPackages (python-pkgs: [
              python-pkgs.pyserial
            ]))
            gcc
            bintools
            zig
            # (cutter.withPlugins (ps: with ps; [jsdec rz-ghidra sigdb]))
          ]
        )
        ++ [
          # misc
          tor

          # desktop
          #sage
          kitty
          vivaldi
          vivaldi-ffmpeg-codecs
          discord
          mullvad-browser
          tor-browser-bundle-bin
          obs-studio
          qbittorrent
          firefox
          vlc
          #qalculate-qt
          speedcrunch
          onlyoffice-bin
          moonlight-qt
          obsidian
          tenacity
          prismlauncher
          element-desktop
          # TODO: https://github.com/NixOS/nixpkgs/issues/437865
          # jellyfin-media-player
          feishin
          arma3-unix-launcher
          winetricks
          protontricks
          wineWowPackages.waylandFull
          brightnessctl
          playerctl
          kdePackages.xwaylandvideobridge
          nexusmods-app-unfree
          _7zz
          pinta
        ]
      );
  };
}
