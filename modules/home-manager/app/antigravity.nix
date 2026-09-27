{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.modules.home.app.antigravity;
  antigravity = inputs.antigravity-nix.packages.x86_64-linux;
in
{
  options.modules.home.app.antigravity = {
    enable = lib.mkEnableOption "Enable Google Antigravity";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ antigravity.default ];
  };
}
