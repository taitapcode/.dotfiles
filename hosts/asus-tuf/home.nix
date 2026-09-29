{ ... }:

{
  imports = [
    ../common/home.nix
  ];

  modules.home = {
    programs = {
      nix-index.enable = true;
      kanshi = {
        enable = true;
        settings = [
          {
            profile = {
              name = "Asus-TUF-Laptop";
              outputs = [
                {
                  criteria = "Chimei Innolux Corporation 0x1521 Unknown";
                  status = "enable";
                  mode = "1920x1080@144Hz";
                  scale = 1.0;
                  position = "0,0";
                }
              ];
            };
          }
        ];
      };
    };
    app = {
      helium.enable = true;
      obs.enable = true;
      antigravity.enable = true;
    };
    desktop.niri.enable = true;
  };
}
