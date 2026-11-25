{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.home.programs.look;
in
{
  imports = [ inputs.look.homeModules.default ];

  options.modules.home.programs.look = {
    enable = lib.mkEnableOption "Enable the Look launcher";
  };

  config = lib.mkIf cfg.enable {
    programs.lookapp = {
      enable = true;
      theme = "catppuccin";
      settings = {
        launcher_hotkey = "none";
        # "none" hides the search-bar slot, so running apps and their Alt+1..Alt+9
        # badges no longer show on the home screen.
        bar_slot = "none";
        file_scan_extra_roots = [
          "~/.dotfiles"
          "~/Projects"
        ];
        file_scan_depth = 8;
        text_editor = "nvim";
        code_editor = "nvim";
        terminal = "ghostty";
      };
    };
  };
}
