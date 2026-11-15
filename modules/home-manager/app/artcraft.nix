{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.app.artcraft;
in
{
  options.modules.home.app.artcraft = {
    enable = lib.mkEnableOption "Enable the ArtCraft app suite";

    apps = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "cadcraft"
          "deckcraft"
          "gridcraft"
          "lightcraft"
          "pdfcraft"
          "photocraft"
          "soundcraft"
          "vectorcraft"
          "wordcraft"
        ]
      );
      default = [
        "deckcraft"
        "gridcraft"
        "pdfcraft"
        "photocraft"
        "wordcraft"
      ];
      description = "ArtCraft apps to install from nixpkgs.";
    };

    pinUpdates = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Pin every installed app to the version nixpkgs ships, which stops its built-in
        startup check from offering an upstream release: updates then only arrive through
        the flake. `craft-update` reads the pin from
        `$XDG_DATA_HOME/ArtCraft/versions/versions.json` (the file the ArtCraft Launcher
        writes when it keeps an app on a chosen version).
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { home.packages = map (app: pkgs.${app}) cfg.apps; }

      (lib.mkIf cfg.pinUpdates {
        xdg.dataFile."ArtCraft/versions/versions.json" = {
          # The ArtCraft Launcher writes a regular file here; take it over instead of
          # failing the switch ("existing file is in the way").
          force = true;
          text = builtins.toJSON {
            apps = builtins.listToAttrs (
              map (app: {
                name = app;
                value = {
                  Pinned = "v${pkgs.${app}.version}";
                };
              }) cfg.apps
            );
          };
        };
      })
    ]
  );
}
