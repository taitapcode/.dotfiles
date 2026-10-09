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

  modules.home = {
    programs = {
      fish.enable = true;
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
      sops.enable = true;
      opencode.enable = true;
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
