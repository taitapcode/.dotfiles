{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.home.app.neovide;

  textTypes = [
    "application/json"
    "application/x-shellscript"
    "application/xml"
    "text/english"
    "text/markdown"
    "text/plain"
    "text/x-c"
    "text/x-c++"
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-csrc"
    "text/x-java"
    "text/x-lua"
    "text/x-makefile"
    "text/x-markdown"
    "text/x-moc"
    "text/x-nix"
    "text/x-pascal"
    "text/x-python"
    "text/x-rust"
    "text/x-tcl"
    "text/x-tex"
    "text/x-yaml"
  ];
in
{
  options.modules.home.app.neovide.enable =
    lib.mkEnableOption "Enable Neovide, the GUI frontend for Neovim";

  config = lib.mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = lib.genAttrs textTypes (_: "neovide.desktop");

    programs.neovide = {
      enable = true;

      settings = {
        font = {
          normal = [ "CaskaydiaCove Nerd Font" ];
          size = 17.0;
        };
      }
      // lib.optionalAttrs config.modules.home.programs.neovim.enable {
        # Spawn the Home Manager-wrapped Neovim, so the plugins, LSP servers
        # and keymaps from modules.home.programs.neovim are loaded.
        neovim-bin = lib.getExe config.programs.neovim.finalPackage;
      };
    };

    programs.neovim.initLua = lib.mkIf config.modules.home.programs.neovim.enable ''
      vim.g.neovide_cursor_trail_size = 0.1
      vim.g.neovide_cursor_animation_length = 0.05
      vim.g.neovide_cursor_short_animation_length = 0.02
    '';
  };
}
