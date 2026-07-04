# NixOS Configuration

Personal NixOS flake configuration managing two hosts with shared modules.

## Hosts

- **datalore** — Desktop workstation with AMD display GPU + NVIDIA compute GPU (CUDA)
- **laptop** — IdeaPad Slim 5 with AMD iGPU (ROCm)

## Usage

```bash
# Rebuild (from either host)
sudo nixos-rebuild switch --keep-going --flake /home/jimh/nixos#<hostname>

# Update flake inputs
sudo nix flake update --flake /home/jimh/nixos

# Check flake validity
nix flake check --verbose --show-trace /home/jimh/nixos
```

## Structure

See [docs/overview.md](docs/overview.md) for full architecture diagram and documentation index.

## Key Design Decisions

- **Shared baseline** in `global/` with host-specific overrides in `datalore/` and `laptop/`
- **Reusable modules** in `modules/` for services (networking, PIA VPN, flatpak, display manager) and programs (kitty, vscode, oxygen)
- **Shared nixpkgs config** in `config/nixpkgs-config.nix` to avoid duplication between NixOS and Home Manager evaluations
- **`mkHost` helper** in `flake.nix` eliminates per-host boilerplate
