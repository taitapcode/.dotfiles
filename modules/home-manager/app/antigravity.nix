{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.modules.home.app.antigravity;
  antigravityPkg = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  wrappedAntigravity = pkgs.symlinkJoin {
    name = "antigravity";
    paths = [ antigravityPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/antigravity \
        --add-flags "--enable-wayland-ime --wayland-text-input-version=3"
    '';
    meta = (antigravityPkg.meta or { }) // {
      mainProgram = "antigravity";
    };
  };
in
{
  options.modules.home.app.antigravity = {
    enable = lib.mkEnableOption "Enable Google Antigravity";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ wrappedAntigravity ];
  };
}
