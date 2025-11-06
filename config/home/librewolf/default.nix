{
  pkgs,
  lib,
  azLib,
  config,
  ...
}:
with lib; let
  top = config.az.desktop.home;
  cfg = top.librewolf;
in {
  options.az.desktop.home.librewolf = with azLib.opt; {
    enable = optBool top.enable;
    letterboxing = optBool true;

    searxngUrl = optStr "https://search.${config.networking.domain}";

    ublockPackage = lib.mkPackageOption pkgs.nur.repos.rycee.firefox-addons "ublock-origin-upstream" {
      example = "adnauseam"; # NOTE: https://github.com/dhowe/AdNauseam/issues/1109
    };
  };

  config = mkIf cfg.enable {
    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.librewolf = {
          enable = true;
          package = pkgs.librewolf.overrideAttrs {
            nixExtensions = [
              # statically fetched extensions, since auto-updates aren't needed/wanted
              (pkgs.fetchFirefoxAddon {
                name = "redirect-nix-wiki";
                url = "https://addons.mozilla.org/firefox/downloads/file/4373121/redirectnixwiki-1.0.xpi";
                hash = "sha256-ygnfXIv5bW7TTuh1PezvGICZq3fCSQ+G7hclRSNv0D8=";
              })
            ];
          };

          settings = {
            "privacy.resistFingerprinting.letterboxing" = cfg.letterboxing;
            #"privacy.clearOnShutdown.history" = false;
            #"privacy.clearOnShutdown.downloads" = false;
            #"identity.fxaccounts.enabled" = true;
          };

          profiles.default = {
            search = {
              force = true;

              default = "searxng";
              privateDefault = "searxng";

              engines = {
                searxng = {
                  name = "searxng";
                  definedAliases = ["@s"];
                  urls = [{template = "${cfg.searxngUrl}?q={searchTerms}";}];
                };
                reddit = {
                  name = "reddit";
                  definedAliases = ["@r"];
                  urls = [{template = "${cfg.searxngUrl}?q={searchTerms}+site:reddit.com";}];
                };

                nixpkgs = {
                  name = "nixpkgs";
                  definedAliases = ["@np"];
                  urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
                };
                nixos-options = {
                  name = "nixos-options";
                  definedAliases = ["@nx"];
                  urls = [{template = "https://search.nixos.org/options?query={searchTerms}";}];
                };
                nixpkgs-issues = {
                  name = "nixpkgs-issues";
                  definedAliases = ["@npi" "@nixpkgs"];
                  urls = [{template = "https://github.com/NixOS/nixpkgs/issues?q={searchTerms}";}];
                };
              };

              order = [
                "searxng"
                "reddit"
                "nixpkgs"
                "nixos-options"
                "nixpkgs-issues"
              ];
            };

            settings = {
              "extensions.autoDisableScopes" = 0;
              "browser.startup.page" = 3;
              "browser.tabs.closeWindowWithLastTab" = false;
            };

            extensions = {
              force = true;
              packages = with pkgs.nur.repos.rycee.firefox-addons; [
                # anti-shittification - high impact
                cfg.ublockPackage
                privacy-badger

                # anti-shittification - misc
                sponsorblock
                return-youtube-dislikes
                unpaywall

                # misc
                bitwarden
                # darkreader
                # TODO: floccus
              ];

              settings = {
                ${cfg.ublockPackage.addonId}.settings = {
                  # medium mode
                  dynamicFilteringString = builtins.readFile ./ublock-rules.txt;

                  advancedUserEnabled = true;
                  popupPanelSections = 31; # show advanced filtering stuff by default
                };
              };
            };
          };
        };
      })
      config.az.core.users;
  };
}
