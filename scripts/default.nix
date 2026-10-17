pkgs: {
  note = pkgs.writeShellApplication {
    name = "note";
    runtimeInputs = with pkgs; [
      git
      neovim
      coreutils
    ];
    text = builtins.readFile ./note.sh;
  };

  rcc = pkgs.writeShellApplication {
    name = "rcc";
    runtimeInputs = with pkgs; [
      gcc
    ];
    text = builtins.readFile ./rcc.sh;
  };

  battery = pkgs.writeShellApplication {
    name = "battery";
    runtimeInputs =
      with pkgs;
      [
        libnotify
        coreutils
        gnugrep
      ]
      ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        asusctl
      ];
    text = builtins.readFile ./battery.sh;
  };

  appimage-install = pkgs.writeShellApplication {
    name = "appimage-install";
    runtimeInputs = with pkgs; [
      coreutils
      desktop-file-utils
      file
      findutils
      gawk
      gnused
      libarchive
      squashfsTools
    ];
    text = builtins.readFile ./appimage-install.sh;
  };

  touchpad = pkgs.writeShellApplication {
    name = "touchpad";
    runtimeInputs =
      with pkgs;
      [
        libnotify
        coreutils
        gnugrep
      ]
      ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        niri
      ];
    text = builtins.readFile ./touchpad.sh;
  };
}
