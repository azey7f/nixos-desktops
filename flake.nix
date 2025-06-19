{
  inputs = {
    self.submodules = true;
    core.url = "./core";

    ### Globally auto-updated ###
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "desktop";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "desktop";

    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor"; # auto-update becacause I really can't be bothered typing the whole thing

    ### Manually updated ###

    # Desktops
    desktop.url = "nixpkgs/nixos-unstable";

    home-manager-desktop.url = "github:nix-community/home-manager/master";
    home-manager-desktop.inputs.nixpkgs.follows = "desktop";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    core,
    home-manager,
    desktop,
    home-manager-desktop,
    nixos-hardware,
    nur,
    rose-pine-hyprcursor,
  } @ inputs: let
    inherit (self) outputs;
  in {
    formatter.x86_64-linux = core.inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.aarch64-linux = core.inputs.nixpkgs.legacyPackages.aarch64-linux.alejandra;

    ### Hosts ###

    nixosConfigurations = core.mkHostConfigurations {
      path = ./hosts;

      channels.nixpkgs.ref = desktop;
      channels.nixpkgs.config.allowUnfree = true;
      channels.nixpkgs.config.cudaSupport = true;

      channels.home-manager.ref = home-manager-desktop;

      specialArgs = {inherit inputs outputs;};

      modules = [
        ./config
        nur.modules.nixos.default
        ./preset.nix
      ];
    };
  };
}
