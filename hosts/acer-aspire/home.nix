{ ... }:

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
      opencode.enable = true;
      eza.enable = true;
      bat.enable = true;
    };
    app = {
      zen-browser.enable = true;
      ghostty.enable = true;
      anki.enable = true;
      zathura.enable = true;
    };
    desktop.niri.enable = true;
  };
}
