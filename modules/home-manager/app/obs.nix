{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.app.obs;
in
{
  options.modules.home.app.obs.enable = lib.mkEnableOption "Enable OBS Studio";

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;

      # NVIDIA hardware acceleration
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
      ];
    };
  };
}
