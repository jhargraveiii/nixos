# Changelog

- Fixed: MT7921 WiFi random disconnects — added `power_save=0` modprobe option, udev rule to disable PCI runtime PM for the WiFi adapter, and TLP denylist entries for the MT7921 driver and PCI address (Jim Hargrave, 2026-03-04)

- Changed: Removed TPM kernel module blacklist from `laptop/hardware-configuration.nix` after BIOS reset resolved the field failure (Jim Hargrave, 2026-02-18)
- Changed: Added ROCm `gpuTargets` overlay in `laptop/amd.nix` to restrict builds to `gfx1100` only (from 14 default targets), preventing OOM crashes when building hipblaslt/Tensile on the 13GB RAM laptop (Jim Hargrave, 2026-02-18)
- Fixed: Reverted `flake.lock` to previous committed revision to restore binary cache availability for ROCm/ollama-rocm packages (Jim Hargrave, 2026-02-18)
