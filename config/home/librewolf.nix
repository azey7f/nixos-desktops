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
            "browser.tabs.closeWindowWithLastTab " = false;
            "privacy.resistFingerprinting.letterboxing" = cfg.letterboxing;
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
                  urls = [{template = "https://search.nixos.org/packages?q={searchTerms}";}];
                };
                nixos-options = {
                  name = "nixos-options";
                  definedAliases = ["@nx"];
                  urls = [{template = "https://search.nixos.org/options?q={searchTerms}";}];
                };
              };

              order = [
                "searxng"
                "reddit"
                "nixpkgs"
                "nixos-options"
              ];
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
                  advancedUserEnabled = true;
                  dynamicFilteringString = ''
                    * * 3p-frame block
                    * * 3p-script block
                  '';
                };
              };
            };
            settings."extensions.autoDisableScopes" = 0;
          };
        };
      })
      config.az.core.users;
  };
}
