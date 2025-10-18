{
  inputs = {
    self.submodules = true;
    core.url = "./core";

    # laptop hw stuff
    nixos-hardware.url = "git+https://git.azey.net/mirrors/nix-community--nixos-hardware?ref=master";

    # niri
    niri.url = "git+https://git.azey.net/mirrors/sodiboo--niri-flake?ref=main";
    niri.inputs.nixpkgs.follows = "core/nixpkgs-unstable";

    # ff extensions
    ff-addons.url = "git+https://git.azey.net/mirrors/osipog--nix-firefox-addons?ref=main";
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
        {nixpkgs.overlays = [inputs.ff-addons.overlays.default];}
        ./config
        ./services
        ./preset.nix
      ];
    };
  };
}
