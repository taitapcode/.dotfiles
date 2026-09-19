{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.program.steam;

  steamConfig = {
    boot.supportedFilesystems = [ "ntfs3" ];

    nixpkgs.overlays = [
      (final: prev: {
        steam = prev.steam.override {
          extraArgs = "--no-cef-sandbox -cef-disable-gpu-compositing";
        };
      })
    ];

    programs = {
      steam.enable = true;
      steam.gamescopeSession.enable = true;
      gamemode.enable = true;
    };
  };
in
{
  options.modules.nixos.program.steam = {
    enable = lib.mkEnableOption "Enable Steam support";
    useSpecialisation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Isolate Steam into a separate boot entry via specialisation.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (!cfg.useSpecialisation) steamConfig)
      (lib.mkIf cfg.useSpecialisation {
        specialisation.gaming.configuration = steamConfig;
      })
    ]
  );
}
