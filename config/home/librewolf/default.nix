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
  };

  config = mkIf cfg.enable {
    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.librewolf = {
          enable = true;

          settings = {
            "privacy.resistFingerprinting.letterboxing" = cfg.letterboxing;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.downloads" = false;
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
              ];
            };

            settings = {
              "extensions.autoDisableScopes" = 0;
              "browser.startup.page" = 3;
              "browser.tabs.closeWindowWithLastTab " = false;
            };

            extensions = {
              force = true;
              packages = with pkgs.firefoxAddons; [
                # anti-shittification
                ublock-origin
                sponsorblock
                return-youtube-dislikes

                # misc
                bitwarden-password-manager
                darkreader
                floccus
                redirectnixwiki
              ];

              settings = {
                "uBlock0@raymondhill.net".settings = {
                  # medium mode
                  dynamicFilteringString = builtins.readFile ./ublock-rules.txt;
                  #FIXME: gets enabled correctly, but doesn't actually take effect until disabling and re-enabling
		  #advancedUserEnabled = true;
                };
              };
            };
          };
        };
      })
      config.az.core.users;
  };
}
