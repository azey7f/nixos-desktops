{
  lib,
  azLib,
  config,
  ...
}:
with lib; let
  top = config.az.desktop.home;
  cfg = top.mail;
in {
  options.az.desktop.home.mail = with azLib.opt; {
    enable = optBool top.enable;
    addr = optStr "me@${config.networking.domain}";
    key = optStr "2CCB340343FE8A2B91CE7F75F94F4A71C5C21E8F";
  };

  config = mkIf cfg.enable {
    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.msmtp.enable = true;
        programs.neomutt.enable = true;
        /*
        programs.mbsync.enable = true;
        programs.notmuch = {
          enable = true;
          hooks = {
            preNew = "mbsync --all";
          };
        };
        */

        accounts.email.maildirBasePath = "/home/${name}/.mail";
        accounts.email.accounts.main = {
          gpg = {
            inherit (cfg) key;
            signByDefault = true;
          };

          msmtp.enable = true;
          primary = true;

          realName = "azey";
          address = cfg.addr;
          userName = cfg.addr;
          smtp.host = "smtp.zoho.eu";
          smtp.port = 587;
          smtp.tls = {
            enable = true;
            useStartTls = true;
          };
          passwordCommand = "cat /home/${name}/.passwd.mail";

          imap.host = "null.internal";

          neomutt.enable = true;
        };
      })
      config.az.core.users;
  };
}
