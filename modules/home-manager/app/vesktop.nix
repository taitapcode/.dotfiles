{ config, lib, ... }:
let
  cfg = config.modules.home.app.vesktop;
in
{
  options.modules.home.app.vesktop.enable = lib.mkEnableOption "Enable vesktop";

  config = lib.mkIf cfg.enable {
    programs.vesktop = {
      enable = true;

      settings = {
        discordBranch = "stable";
        tray = true;
        spellCheckLanguages = false;
        hardwareAcceleration = true;
        hardwareVideoAcceleration = true;
      };

      vencord = {
        useSystem = true;
        settings = {

          cloud = {
            authenticated = true;
            url = "https://api.vencord.dev/";
            settingsSync = true;
          };
          plugins = {
            AlwaysTrust.enabled = true;
            CallTimer.enabled = true;
            NoF1.enabled = true;
            WhoReacted.enabled = true;
            WebScreenShareFixes.enabled = true;
            CrashHandler.enabled = true;
            ClearURLs.enabled = true;
            FakeNitro.enabled = true;
          };
        };
      };
    };
  };
}
