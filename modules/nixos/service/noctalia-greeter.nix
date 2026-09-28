{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.service.noctalia-greeter;
in
{
  options.modules.nixos.service.noctalia-greeter = {
    enable = lib.mkEnableOption "Enable Noctalia Greeter (greetd) Display Manager configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      banana-cursor
    ];

    services.displayManager.noctalia-greeter = {
      enable = true;
      passwordlessSyncUsers = [ "tai" ];
      cursorTheme = {
        package = pkgs.banana-cursor;
        name = "Banana";
      };
      settings = {
        output = {
          scale = 1.0;
        };
        user = {
          default = "tai";
        };
        session = {
          default = "Niri";
        };
        cursor = {
          size = 28;
        };
      };
    };
  };
}
