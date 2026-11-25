{
  imports = [
    ../common/home.nix
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "zen-beta.desktop";
    "x-scheme-handler/https" = "zen-beta.desktop";
    "text/html" = "zen-beta.desktop";

    "application/msword" = "ai.storyteller.wordcraft.desktop";
    "application/vnd.ms-word.document.macroEnabled.12" = "ai.storyteller.wordcraft.desktop";
    "application/vnd.oasis.opendocument.text" = "ai.storyteller.wordcraft.desktop";
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
      "ai.storyteller.wordcraft.desktop";
    "application/rtf" = "ai.storyteller.wordcraft.desktop";

    "application/vnd.ms-excel.sheet.macroEnabled.12" = "ai.storyteller.gridcraft.desktop";
    "application/vnd.oasis.opendocument.spreadsheet" = "ai.storyteller.gridcraft.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
      "ai.storyteller.gridcraft.desktop";
    "text/csv" = "ai.storyteller.gridcraft.desktop";
    "text/tab-separated-values" = "ai.storyteller.gridcraft.desktop";

    "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
      "ai.storyteller.deckcraft.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
      "ai.storyteller.deckcraft.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.template" =
      "ai.storyteller.deckcraft.desktop";
    "application/x-deckcraft" = "ai.storyteller.deckcraft.desktop";

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
      hermes = {
        enable = true;
        desktop.enable = true;
      };
      sops.enable = true;
      opencode.enable = true;
      look.enable = true;
    };
    app = {
      zen-browser.enable = true;
      ghostty.enable = true;
      anki.enable = true;
      zathura.enable = true;
      helium.enable = true;
      obs.enable = true;
      artcraft.enable = true;
    };
    desktop.niri.enable = true;
  };
}
