{
  config,
  lib,
  azLib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.az.desktop.fonts;
in {
  options.az.desktop.fonts = with azLib.opt; {
    enable = optBool false;
  };

  config = let
    fontPkgs = with pkgs; [
      liberation_ttf
      terminus_font_ttf
      unifont
    ];
  in
    mkIf cfg.enable {
      environment.systemPackages = fontPkgs;
      fonts = {
        #enableDefaultPackages = true;
        packages = fontPkgs;
        fontconfig = {
          defaultFonts = {
            serif = ["Liberation Serif"];
            sansSerif = ["Liberation Sans"];
            monospace = ["Liberation Mono"];
            #monospace = ["TerminusTTF"];
          };
        };
      };
    };
}
