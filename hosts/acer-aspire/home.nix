{ ... }:

{
  imports = [
    ../common/home.nix
  ];

  modules.home.desktop.niri.enable = true;
}
