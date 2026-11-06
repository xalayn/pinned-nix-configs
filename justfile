# Run `just` to list recipes. After making changes in the configs, run `just sync`.

set shell := ["bash", "-euo", "pipefail", "-c"]

host := "alex-laptop"
home := "alex"
configs := "system-config home-config"
# Explicit URL so uncommitted edits inside the submodules are always built
# (plain `.#` can reuse a stale copy when only submodule contents changed).
flake := "git+file://" + justfile_directory() + "?submodules=1"

# List recipes
default:
    @just --list

# Rebuild, then commit and push the configs and pin them here
sync msg="Update": switch (commit msg)

# Update the flake lock (nixpkgs etc.), rebuild, then commit and push
upgrade msg="Update flake.lock": update switch (commit msg)

# Rebuild the system and Home Manager (uses uncommitted edits too)
switch: system home

# Rebuild only the NixOS system configuration
system:
    sudo nixos-rebuild switch --flake "{{ flake }}#{{ host }}"

# Rebuild only the Home Manager configuration
home:
    home-manager switch --flake "{{ flake }}#{{ home }}"

# Update the flake lock (nixpkgs, home-manager, ...)
update:
    nix flake update

# Pull the latest config commits from GitHub into the submodules
pull:
    #!/usr/bin/env bash
    set -euo pipefail
    git pull --ff-only
    git submodule update --init
    for repo in {{ configs }}; do
        git -C "$repo" checkout --quiet main
        git -C "$repo" pull --ff-only --quiet
    done
    just status

# Commit and push changes in each config, then commit and push the pinned repo
commit msg="Update":
    #!/usr/bin/env bash
    set -euo pipefail
    msg={{ quote(msg) }}
    for repo in {{ configs }}; do
        if ! git -C "$repo" symbolic-ref --quiet HEAD >/dev/null; then
            echo "$repo is not on a branch; run: git -C $repo checkout main" >&2
            exit 1
        fi
        if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
            echo "📝 Committing $repo"
            git -C "$repo" add -A
            git -C "$repo" commit --quiet -m "$msg"
        fi
        git -C "$repo" pull --rebase --quiet
        if [[ "$(git -C "$repo" rev-list --count '@{u}..HEAD')" -gt 0 ]]; then
            echo "⬆️  Pushing $repo"
            git -C "$repo" push --quiet
        fi
    done
    # Pin the new config commits (and any flake.lock change) here
    git add -A
    if ! git diff --cached --quiet; then
        echo "📌 Committing pinned-nix-configs"
        git commit --quiet -m "$msg"
    fi
    git pull --rebase --quiet
    if [[ "$(git rev-list --count '@{u}..HEAD')" -gt 0 ]]; then
        echo "⬆️  Pushing pinned-nix-configs"
        git push --quiet
    fi
    echo "✅ Everything committed and pushed."

# Show git status of the pinned repo and both configs
status:
    #!/usr/bin/env bash
    for repo in {{ configs }}; do
        echo "== $repo"
        git -C "$repo" status -sb
    done
    echo "== pinned-nix-configs"
    git status -sb
