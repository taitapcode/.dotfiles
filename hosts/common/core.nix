{
  pkgs,
  inputs,
  self,
  ...
}:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    inputs.sops-nix.nixosModules.sops
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  services.upower.enable = true;
  hardware.bluetooth.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      ubuntu-classic
      liberation_ttf
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Liberation Serif"
          "Times New Roman"
        ];
        sansSerif = [
          "Ubuntu"
          "Noto Sans"
          "Arial"
        ];
        monospace = [
          "CaskaydiaCove Nerd Font"
          "JetBrainsMono Nerd Font"
        ];
      };
    };
  };

  # Define base user settings
  users.users.tai = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "power"
    ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs self; };
    backupFileExtension = "backup";
  };

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";
  };

  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
    ];
    config.common = {
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support.
  services.libinput.enable = true;

  # Allow proprietary/unfree packages to be installed
  nixpkgs.config.allowUnfree = true;

  # Base programs
  programs.nix-ld.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
