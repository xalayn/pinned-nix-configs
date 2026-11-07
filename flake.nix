{
  description = "Common flake to unify nixpkgs for system + home";

  inputs = {
    # Include the git submodules (system-config, home-config) in this flake's source
    self.submodules = true;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pinned nixpkgs used only for Hyprland + the ScrollOverview plugin (see system-config/flake.nix)
    nixpkgs-hyprland.url = "github:nixos/nixpkgs/1d060086d60cb76a40cf37109f979d88a5bd6396";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Pinned via git submodules: the commit each submodule points at is what gets built.
    # After editing them, run `just sync` (see justfile).
    system.url = "path:./system-config";
    home.url = "path:./home-config";

    system.inputs.nixpkgs.follows = "nixpkgs";
    system.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    system.inputs.nixpkgs-hyprland.follows = "nixpkgs-hyprland";
    home.inputs.nixpkgs.follows = "nixpkgs";
    home.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    home.inputs.nixpkgs-hyprland.follows = "nixpkgs-hyprland";
    home.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, home-manager, system, home, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = system.nixosConfigurations;
    homeConfigurations = home.homeConfigurations;

    # `nix develop` gives the tools the justfile needs
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [
        pkgs.just
        pkgs.git
        home-manager.packages.x86_64-linux.home-manager
      ];
    };
  };
}