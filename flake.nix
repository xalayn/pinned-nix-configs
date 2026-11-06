{
  description = "Common flake to unify nixpkgs for system + home";

  inputs = {
    # Include the git submodules (system-config, home-config) in this flake's source
    self.submodules = true;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Pinned via git submodules: the commit each submodule points at is what gets built.
    # Bump with: git submodule update --remote && git commit -am "Bump configs"
    system.url = "path:./system-config";
    home.url = "path:./home-config";

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