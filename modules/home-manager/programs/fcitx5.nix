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
    # Symlink individual files instead of the whole directory.
    # Fcitx5 needs write access to ~/.config/fcitx5/ for runtime state
    # (active IM persistence, user dictionary, crash logs, etc.).
    # A whole-directory symlink into the read-only Nix store breaks this.
    #
    # lotus.conf is read-only-managed on purpose: it only pins the global
    # default typing mode. fcitx5 rewrites it via temp-file + rename() when the
    # settings GUI applies changes or a tray toggle flips, which replaces this
    # symlink with a regular file; the declared value wins again on the next
    # switch. Per-app overrides live in ~/.config/fcitx5/conf/lotus-app-rules.conf
    # (NOT managed here) and therefore survive switches.
    xdg.configFile = {
      "fcitx5/config".source = self + "/config/fcitx5/config";
      "fcitx5/profile".source = self + "/config/fcitx5/profile";
      "fcitx5/conf/classicui.conf".source = self + "/config/fcitx5/conf/classicui.conf";
      "fcitx5/conf/lotus.conf".source = self + "/config/fcitx5/conf/lotus.conf";
      "fcitx5/conf/notifications.conf".source = self + "/config/fcitx5/conf/notifications.conf";
    };
  };
}
