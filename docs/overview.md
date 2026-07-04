# NixOS Configuration — Documentation Index

## Architecture

Multi-host NixOS flake managing two machines (`datalore` desktop, `laptop`) with shared configuration layers.

```
flake.nix                          # Entry point — mkHost helper, user variables
├── global/configuration.nix       # Shared NixOS baseline (boot, packages, services, browsers)
├── global/home.nix                # Shared Home Manager baseline (git, bash, programs)
├── config/
│   ├── nixpkgs-config.nix         # Shared nixpkgs config (BLAS/LAPACK, allowUnfree)
│   └── files.nix                  # Static home files (starship, fastfetch, fonts, ollama-correct)
├── modules/
│   ├── services/
│   │   ├── displaymanager.nix     # Shared Plasma 6 + SDDM + Wayland display manager
│   │   ├── networking.nix         # NetworkManager, WireGuard, firewall, systemd-resolved
│   │   ├── flatpak.nix            # Flatpak + Flathub repo + Speech Note overrides
│   │   └── pia.nix                # Custom PIA VPN module (FHS wrappers, systemd service)
│   └── programs/
│       ├── distrobox.nix          # Podman + Distrobox
│       ├── kitty.nix              # Kitty terminal configuration
│       ├── oxygen.nix             # Oxygen XML Developer custom derivation
│       └── vscode.nix             # VS Code with extensions
├── overlays/
│   └── default.nix                # nixpkgs overlays (aocl-utils pin)
├── datalore/                      # Desktop workstation (AMD display + NVIDIA compute)
│   ├── configuration.nix          # Host-specific NixOS (btrfs scrub, power, bluetooth)
│   ├── hardware-configuration.nix # Disk layout, kernel modules, modprobe
│   ├── amd.nix                    # AMDGPU + ROCm ICD
│   ├── nvidia.nix                 # NVIDIA compute (CUDA, ollama-cuda, container toolkit)
│   ├── displaymanager.nix         # Dual GPU video drivers
│   └── home.nix                   # Host-specific aliases
└── laptop/                        # IdeaPad Slim 5 (AMD iGPU only)
    ├── configuration.nix          # TLP power management, ollama-rocm, fingerprint
    ├── hardware-configuration.nix # Disk layout, kernel modules, amd_pstate
    ├── amd.nix                    # AMDGPU + VA-API + ROCm tools
    ├── displaymanager.nix         # Wacom, touchscreen, iio sensors
    └── home.nix                   # Host-specific aliases + packages
```

## Host Comparison

| Aspect | `datalore` | `laptop` |
|--------|-----------|----------|
| GPU | AMD display + NVIDIA compute | AMD iGPU only (gfx1103) |
| Ollama | `ollama-cuda` | `ollama-rocm` + HSA overrides |
| Power | cpufreq ondemand | TLP (AC/BAT profiles) |
| Filesystem | btrfs (subvols) | ext4 |
| `system.stateVersion` | `23.11` | `24.05` |

## Documents

- [Changelog](changelog.md) — Chronological record of all configuration changes
