{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  cfg = config.modules.home.programs.opencode;
in
{
  options.modules.home.programs.opencode.enable = lib.mkEnableOption "Enable Opencode configuration";

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      extraPackages = with pkgs; [
        lua-language-server
        fish-lsp
        clang-tools
        pyright
        bash-language-server
        nixd
      ];

      settings = {
        lsp = {
          nixd = {
            command = [ "nixd" ];
            extensions = [ ".nix" ];
          };
          lua_ls = {
            command = [ "lua-language-server" ];
            extensions = [ ".lua" ];
          };
          fish_lsp = {
            command = [ "fish-lsp" ];
            extensions = [ ".fish" ];
          };
          clangd = {
            command = [ "clangd" ];
            extensions = [
              ".c"
              ".cpp"
              ".h"
              ".hpp"
            ];
          };
          pyright = {
            command = [
              "pyright-langserver"
              "--stdio"
            ];
            extensions = [ ".py" ];
          };
          bashls = {
            command = [
              "bash-language-server"
              "start"
            ];
            extensions = [
              ".sh"
              ".bash"
            ];
          };
        };
      };
    };

    xdg.configFile = {
      "opencode/command".source = self + "/config/opencode/command";
    };
  };
}
