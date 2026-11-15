{ ... }:

{
  imports = [
    ../common/home.nix
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "zen-beta.desktop";
    "x-scheme-handler/https" = "zen-beta.desktop";
    "text/html" = "zen-beta.desktop";

    "application/msword" = "libreoffice-writer.desktop";
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
      "libreoffice-writer.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
      "libreoffice-impress.desktop";

    "application/pdf" = "org.pwmt.zathura.desktop";
    "application/epub+zip" = "org.pwmt.zathura.desktop";
  };

  modules.home = {
    programs = {
      fish.enable = true;
      opencode.enable = true;
      eza.enable = true;
      bat.enable = true;
    };
    app = {
      zen-browser.enable = true;
      ghostty.enable = true;
      anki.enable = true;
      zathura.enable = true;
      libreoffice.enable = true;
    };
    desktop.niri.enable = true;
  };
}
