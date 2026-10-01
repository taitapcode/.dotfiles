{
  ...
}:

{
  imports = [
    ../common/core.nix
    ./hardware.nix
  ];

  services.power-profiles-daemon.enable = true;

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/88B408DEB408D09C";
    fsType = "ntfs3";
    options = [
      "uid=1000"
      "gid=100"
      "rw"
      "exec"
      "nofail"
      "force"
    ];
  };

  # Programs
  programs = {
    fish.enable = true;
    niri = {
      enable = true;
      useNautilus = true;
    };
  };

  modules.nixos = {
    service = {
      keyd.enable = true;
      sddm.enable = true;
    };
    program = {
      fcitx5 = {
        enable = true;
        users = [ "tai" ];
      };
      waydroid.enable = true;
      steam.enable = true;
    };
  };

  # Ensure hardware acceleration / graphics drivers are active
  hardware.graphics.enable = true;

  home-manager.users.tai = import ./home.nix;
}
