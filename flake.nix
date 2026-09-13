{
  description = "Common flake to unify nixpkgs for system + home";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    system.url = "github:alex-kumpula/system-config";
    home.url = "github:alex-kumpula/home-config";

    system.inputs.nixpkgs.follows = "nixpkgs";
    system.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    home.inputs.nixpkgs.follows = "nixpkgs";
    home.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    home.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, system, home, ... }: {
    nixosConfigurations = system.nixosConfigurations;
    homeConfigurations = home.homeConfigurations;
  };
}