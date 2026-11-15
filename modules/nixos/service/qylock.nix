{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.nixos.service.qylock;
in
{
  imports = [ inputs.qylock.nixosModules.default ];

  options.modules.nixos.service.qylock = {
    enable = lib.mkEnableOption "Enable the qylock SDDM greeter theme";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "enfield";
      example = "nier-automata";
      description = "qylock theme directory name (a directory under themes/ in Darkkal44/qylock).";
    };
  };

  config = lib.mkIf cfg.enable {
    modules.nixos.service.sddm.enable = true;

    services.displayManager.defaultSession = "niri";

    # catppuccin.autoEnable would otherwise install its own SDDM theme and
    # claim services.displayManager.sddm.theme, conflicting with qylock's.
    catppuccin.sddm.enable = false;

    programs.qylock = {
      enable = true;
      inherit (cfg) theme;
      # qylock-lock is the Quickshell lockscreen, not part of the greeter.
      quickshell.enable = false;
    };
  };
}
