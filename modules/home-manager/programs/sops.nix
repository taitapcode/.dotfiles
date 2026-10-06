{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.modules.home.programs.sops;
in
{
  options.modules.home.programs.sops = {
    enable = lib.mkEnableOption "Enable sops secret management";
    defaultSopsFile = lib.mkOption {
      type = lib.types.path;
      default = self + "/secrets/secrets.yaml";
      description = "Default sops file containing secrets";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sops
      age
    ];

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
    };

    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      defaultSopsFormat = "yaml";
      age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    };
  };
}
