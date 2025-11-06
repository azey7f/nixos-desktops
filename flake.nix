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
    nur.url = "git+https://git.azey.net/mirrors/nix-community--NUR";
    nur.inputs.nixpkgs.follows = "core/nixpkgs-unstable";
  };

  outputs = {
    self,
    core,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in rec {
    inherit (core.outputs) formatter;

    nixosConfigurations = core.mkHostConfigurations {
      path = ./hosts;

      channels.nixpkgs.ref = core.inputs.nixpkgs-unstable;
      channels.nixpkgs.config.allowUnfree = true;

      channels.home-manager.ref = core.inputs.home-manager-unstable;

      specialArgs = {inherit inputs outputs;};

      modules = [
        inputs.niri.nixosModules.niri
        {nixpkgs.overlays = [inputs.nur.overlays.default];}
        ./config
        ./services
        ./preset.nix
      ];
    };
  };
}
