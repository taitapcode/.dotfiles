{
  pkgs,
  ...
}:

{
  imports = [
    ../common/core.nix
    ./hardware.nix
  ];

  boot.kernelParams = [ "acpi_backlight=native" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaPersistenced = true;
  };

  fileSystems."/mnt/Storage" = {
    device = "/dev/disk/by-uuid/1A5E3A2E5E3A02D5";
    fsType = "ntfs3";
    options = [
      "uid=1000"
      "gid=100"
      "exec"
      "rw"
      "nofail"
      "umask=000"
      "force"
    ];
  };

  services.asusd = {
    enable = true;
    asusdConfig.text = ''
      (
        charge_control_end_threshold: 80,
        base_charge_control_end_threshold: 80,
        disable_nvidia_powerd_on_battery: true,
        ac_command: "",
        bat_command: "",
        platform_profile_linked_epp: true,
        platform_profile_on_battery: Quiet,
        change_platform_profile_on_battery: true,
        platform_profile_on_ac: Performance,
        change_platform_profile_on_ac: true,
        profile_quiet_epp: Power,
        profile_balanced_epp: BalancePower,
        profile_custom_epp: Performance,
        profile_performance_epp: Performance,
        ac_profile_tunings: {
          Performance: (
            enabled: false,
            group: {},
          ),
          Quiet: (
            enabled: false,
            group: {},
          ),
          Balanced: (
            enabled: false,
            group: {},
          ),
        },
        dc_profile_tunings: {
          Quiet: (
            enabled: false,
            group: {},
          ),
          Balanced: (
            enabled: false,
            group: {},
          ),
          Performance: (
            enabled: false,
            group: {},
          ),
        },
        armoury_settings: {},
      )
    '';
  };

  powerManagement.powertop.enable = false;

  # Cloudflare Warp VPN
  services.cloudflare-warp.enable = true;

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
      noctalia-greeter.enable = true;
    };
    program = {
      fcitx5.enable = true;
      waydroid.enable = true;
      steam = {
        enable = true;
        useSpecialisation = true;
      };
      localsend.enable = true;
    };
  };

  users.users.tai.packages = with pkgs; [
    gnumake
    cmake
    gcc
    bun
    uv
    mars-mips
  ];

  home-manager.users.tai = import ./home.nix;
}
