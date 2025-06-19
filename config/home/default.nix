{azLib, ...}: {
  imports = azLib.scanPath ./.;
  options.az.desktop.home.enable = azLib.opt.optBool false;
}
