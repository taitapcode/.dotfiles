{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.home.programs.kanshi;
in
{
  options.modules.home.programs.kanshi = {
    enable = lib.mkEnableOption "Enable kanshi";
    settings = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Kanshi profile settings";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.wdisplays ];

    services.kanshi = {
      enable = true;
      settings = cfg.settings;
    };
  };
}
