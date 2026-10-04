{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.app.hermes-desktop;
  system = pkgs.stdenv.hostPlatform.system;
  hermesDesktopPkg = inputs.hermes-agent.packages.${system}.desktop;
  hermesCliPkg = inputs.hermes-agent.packages.${system}.default;
in
{
  options.modules.home.app.hermes-desktop = {
    enable = lib.mkEnableOption "Enable Hermes Desktop application";

    withCli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Also include the Hermes CLI binary on PATH.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      hermesDesktopPkg
    ]
    ++ lib.optional cfg.withCli hermesCliPkg;
  };
}
