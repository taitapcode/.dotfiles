{
  config,
  lib,
  self,
  ...
}:

let
  cfg = config.modules.home.programs.fcitx5;
in
{
  options.modules.home.programs.fcitx5.enable = lib.mkEnableOption "Enable Fcitx5 configuration";

  config = lib.mkIf cfg.enable {
    xdg.configFile."fcitx5".source = self + "/config/fcitx5";
  };
}
