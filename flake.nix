{
  description = "My NixOS dotfiles flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      scanModules =
        path:
        builtins.filter (p: baseNameOf p != "default.nix" && nixpkgs.lib.hasSuffix ".nix" (toString p)) (
          nixpkgs.lib.filesystem.listFilesRecursive path
        );

      nixosModulesList = scanModules ./modules/nixos;
      homeModulesList = scanModules ./modules/home-manager;
    in
    {
      packages = forAllSystems (system: import ./scripts nixpkgs.legacyPackages.${system});

      overlays.default = final: prev: {
        myScripts = import ./scripts final;
      };

      nixosConfigurations = {
        acer-aspire = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/acer-aspire/configuration.nix
            home-manager.nixosModules.default
            {
              nixpkgs.overlays = [ self.overlays.default ];
              home-manager.users.tai.imports = homeModulesList;
            }
          ]
          ++ nixosModulesList;
        };
        asus-tuf = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/asus-tuf/configuration.nix
            home-manager.nixosModules.default
            nixos-hardware.nixosModules.asus-fa506nc
            {
              nixpkgs.overlays = [ self.overlays.default ];
              home-manager.users.tai.imports = homeModulesList;
            }
          ]
          ++ nixosModulesList;
        };
      };
    };
}
