{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.programs.hermes;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.modules.home.programs.hermes = {
    enable = lib.mkEnableOption "Enable Hermes CLI configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.hermes-agent.packages.${system}.default
    ];
  };
}
