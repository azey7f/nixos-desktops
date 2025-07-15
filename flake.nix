{
  inputs = {
    self.submodules = true;
    core.url = "./core";

    # laptop hw stuff
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # pretty cursor for hyprland (!!)
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    # niri
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "core/nixpkgs-unstable";

    # ff extensions
    ff-addons.url = "github:osipog/nix-firefox-addons";
    ff-addons.inputs.nixpkgs.follows = "core/nixpkgs-unstable";
  };

  outputs = {
    self,
    core,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in rec {
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
        inputs.niri.nixosModules.niri
        inputs.ff-addons.nixosModules.default
        ./config
        ./services
        ./preset.nix
      ];
    };

    hydraJobs = core.mkHydraJobs nixosConfigurations;
  };
}
