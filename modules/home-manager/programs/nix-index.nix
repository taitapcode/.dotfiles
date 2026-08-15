{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.home.programs.nix-index;
in
{
  imports = [
    inputs.nix-index-database.homeModules.default
  ];

  options.modules.home.programs.nix-index.enable =
    lib.mkEnableOption "Enable nix-index database and comma";

  config = lib.mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
  };
}
