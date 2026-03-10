# Changelog

- Changed: Relaxed Firefox privacy settings in `global/home.nix` — replaced `privacy.resistFingerprinting` (which spoofs browser identity and breaks "remember this device" for 2FA) with `privacy.fingerprintingProtection` (granular, less disruptive); changed `network.cookie.cookieBehavior` from `1` (block all third-party) to `5` (Total Cookie Protection — isolates per-site instead of blocking, preserving SSO/OAuth flows); added `network.cookie.lifetimePolicy = 0` to ensure session cookies persist (Jim Hargrave, 2026-03-10)
- Fixed: TLP `CPU_SCALING_GOVERNOR_ON_BAT="schedutil"` error — `schedutil` is unavailable with `amd-pstate-epp` driver; changed to `performance`/`powersave` which are the only supported governors for this driver (Jim Hargrave, 2026-03-08)
- Fixed: AMD XDNA (NPU) firmware probe failure after flake.lock update — upstream `linux-firmware` redirected `amdnpu/1502_00/npu.sbin` to an empty v1.5.2.380 placeholder; added `hardware.firmware` overlay in `laptop/configuration.nix` that provides the real v1.5.5.391 blob uncompressed so the kernel finds it first (Jim Hargrave, 2026-03-08)
- Fixed: `pre-shutdown.service` and `pre-sleep.service` boot errors caused by systemd 259 rejecting empty oneshot stubs from upstream `power-management.nix` — added `powerManagement.powerDownCommands = "true"` in `global/configuration.nix` as a no-op workaround (Jim Hargrave, 2026-03-08)

- Added: `nixpkgs-stable` (nixos-24.11) flake input as a fallback package source for broken unstable packages; threaded `pkgs-stable` through `extraSpecialArgs` for both datalore and laptop hosts (Jim Hargrave, 2026-03-05)
- Changed: Switched `gearlever` to `pkgs-stable.gearlever` in `global/home.nix` — upstream `dwarfs-0.12.4` fails to build with boost 1.89 on nixos-unstable (Jim Hargrave, 2026-03-05)

- Fixed: Home Manager activation failure at boot caused by stale `mimeapps.list.backup` blocking backup of `mimeapps.list` — removed stale backup and added `xdg.configFile."mimeapps.list".force = true` in `global/home.nix` to prevent recurrence (Jim Hargrave, 2026-03-05)

- Fixed: MT7921 WiFi random disconnects — added `power_save=0` modprobe option, udev rule to disable PCI runtime PM for the WiFi adapter, and TLP denylist entries for the MT7921 driver and PCI address (Jim Hargrave, 2026-03-04)

- Changed: Removed TPM kernel module blacklist from `laptop/hardware-configuration.nix` after BIOS reset resolved the field failure (Jim Hargrave, 2026-02-18)
- Changed: Added ROCm `gpuTargets` overlay in `laptop/amd.nix` to restrict builds to `gfx1100` only (from 14 default targets), preventing OOM crashes when building hipblaslt/Tensile on the 13GB RAM laptop (Jim Hargrave, 2026-02-18)
- Fixed: Reverted `flake.lock` to previous committed revision to restore binary cache availability for ROCm/ollama-rocm packages (Jim Hargrave, 2026-02-18)
