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
}
