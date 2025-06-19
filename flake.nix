{
  inputs = {
    self.submodules = true;
    core.url = "./core";

    # laptop hw stuff
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # pretty cursor for hyprland (!!)
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
  };

  outputs = {
    self,
    core,
    nixos-hardware,
    nur,
    rose-pine-hyprcursor,
  } @ inputs: let
    inherit (self) outputs;
  in {
    formatter.x86_64-linux = core.inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.aarch64-linux = core.inputs.nixpkgs.legacyPackages.aarch64-linux.alejandra;

    nixosConfigurations = core.mkHostConfigurations {
      path = ./hosts;

      channels.nixpkgs.ref = core.inputs.nixpkgs-unstable;
      channels.nixpkgs.config.allowUnfree = true;
      channels.nixpkgs.config.cudaSupport = true;

      channels.home-manager.ref = core.inputs.home-manager-unstable;

      specialArgs = {inherit inputs outputs;};

      modules = [
        ./config
        ./services
        ./preset.nix
      ];
    };
  };
}
