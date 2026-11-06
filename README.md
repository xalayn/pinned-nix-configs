NOTE: Make sure to change hardware config and set boot to efi in virtual box!!!

NOTE: If running in a vm, make sure 3D acceleration is enabled in the vm settings, otherwise Niri wont work and will just show a black screen!


First, run:

nix-shell -p gh --command "gh auth login"

Then, run:

nix-shell -p git --command "git clone --recurse-submodules https://github.com/alex-kumpula/pinned-nix-configs.git ~/Documents"

(If you already cloned without `--recurse-submodules`, run `git submodule update --init`.)

Then, run:

nix-shell -p git --command "sudo nixos-rebuild switch --flake .#your-host-name-here"

Then, run:

nix-shell -p home-manager --command "home-manager switch --flake .#your-home-name-here"

## Updating the pinned configs

`system-config` and `home-config` are git submodules; the commit each one points at is what gets built.

To bump both to the latest `main`:

git submodule update --remote
git add system-config home-config
git commit -m "Bump configs"
