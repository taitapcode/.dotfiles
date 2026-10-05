{ pkgs, self, ... }:

{
  imports = [
    ../common/home.nix
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "zen-beta.desktop";
    "x-scheme-handler/https" = "zen-beta.desktop";
    "text/html" = "zen-beta.desktop";

    "application/pdf" = "org.pwmt.zathura.desktop";
    "application/epub+zip" = "org.pwmt.zathura.desktop";
  };

  xdg.desktopEntries = {
    battery-oneshot = {
      name = "Battery Full Charge (100%)";
      genericName = "Battery Charge Limit";
      comment = "One-shot full charge to 100% for travel";
      icon = "${self}/assets/icons/battery-full.svg";
      exec = "${pkgs.myScripts.battery}/bin/battery oneshot";
      terminal = false;
      categories = [ "Settings" ];
      settings = {
        Keywords = "battery;charge;power;asus;oneshot;full;";
      };
    };

    battery-limit-restore = {
      name = "Battery Limit (70%)";
      genericName = "Battery Charge Limit";
      comment = "Restore battery charge limit to 70%";
      icon = "${self}/assets/icons/battery-limit.svg";
      exec = "${pkgs.myScripts.battery}/bin/battery 70";
      terminal = false;
      categories = [ "Settings" ];
      settings = {
        Keywords = "battery;charge;power;asus;limit;restore;";
      };
    };
  };

  modules.home = {
    programs = {
      fish.enable = true;
      opencode.enable = true;
      eza.enable = true;
      bat.enable = true;
      nix-index.enable = true;
      kanshi = {
        enable = true;
        settings = [
          {
            profile = {
              name = "Asus-TUF-Laptop";
              outputs = [
                {
                  criteria = "Chimei Innolux Corporation 0x1521 Unknown";
                  status = "enable";
                  mode = "1920x1080@144Hz";
                  scale = 1.0;
                  position = "0,0";
                }
              ];
            };
          }
        ];
      };
      hermes.enable = true;
    };
    app = {
      zen-browser.enable = true;
      ghostty.enable = true;
      anki.enable = true;
      zathura.enable = true;
      helium.enable = true;
      obs.enable = true;
      antigravity.enable = true;
    };
    desktop.niri.enable = true;
  };
}
