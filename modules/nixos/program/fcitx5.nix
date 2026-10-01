{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixos.program.fcitx5;
in
{
  options.modules.nixos.program.fcitx5 = {
    enable = lib.mkEnableOption "Enable Fcitx5 with Lotus input method";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "tai" ];
      description = "Linux users to start system-level fcitx5-lotus-server instances for.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "uinput" ];
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = [ pkgs.fcitx5-lotus ];
      };
    };

    users.users.uinput_proxy = {
      isSystemUser = true;
      group = "input";
      description = "Fcitx5 Lotus uinput daemon user";
    };

    services.udev.packages = [ pkgs.fcitx5-lotus ];

    systemd.packages = [ pkgs.fcitx5-lotus ];
    systemd.services = lib.listToAttrs (
      map (user: {
        name = "fcitx5-lotus-server@${user}";
        value = {
          wantedBy = [ "multi-user.target" ];
          overrideStrategy = "asDropin";
        };
      }) cfg.users
    );

    # NOTE: In Wayland/Niri, GTK_IM_MODULE must NOT be set to fcitx; GTK natively uses text-input-v3.
    environment.sessionVariables = {
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
    };
  };
}
