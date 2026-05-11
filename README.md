# Fedora 44 - One-Click Optimization 🚀

Transform a fresh **Fedora 44 Workstation** install into a lightning-fast, self-maintaining, and beginner-friendly system with a single command.

No Linux knowledge required. Just run the script, reboot, and enjoy.

**Created and tested by the community, for the community.**

## ✨ What This Script Does

| Category | Optimizations Included |
| :--- | :--- |
| **Speed** | Faster DNF downloads, hardware-aware memory & SSD optimization, kernel performance tweaks |
| **Media** | Full multimedia codecs via RPM Fusion + GPU-specific hardware video acceleration (Intel/AMD) |
| **Battery** | Automatic power profiles (switches between Performance, Balanced, Power Saver) |
| **Backups** | Automatic system snapshots with Btrfs Assistant & Snapper (Btrfs-only) |
| **Updates** | Daily automatic security updates (no reboots without your permission) |
| **Privacy** | Brave browser pre-installed with hardware acceleration ready |
| **Compatibility** | Auto-detects Intel/AMD CPU, GPU type, RAM amount, and VM status |

## ⚡ One-Command Install

Copy the command below and paste it into your terminal:
```
git clone https://github.com/aduv0000/fedora-44-optimization.git && cd fedora-44-optimization && chmod +x fedora-setup.sh && ./fedora-setup.sh
```

**After it finishes, reboot your computer.** That is the only manual step.

## 📋 What to Expect After Reboot

- Your system will feel faster and more responsive.
- Videos and streams will play smoothly with less CPU usage.
- Your laptop battery will last longer and switch power modes automatically.
- System updates will install quietly in the background, daily.
- If an update ever causes a problem, you can roll back using Btrfs snapshots.

## 🧠 Smart Hardware Detection

The script automatically detects your hardware and adjusts accordingly:

| Hardware | Script Behavior |
| :--- | :--- |
| **Intel CPU** | Installs Intel microcode + Intel media driver |
| **AMD CPU** | Installs AMD microcode + Mesa VA drivers |
| **≤16GB RAM + no dGPU** | Aggressive zram tuning (`vm.swappiness=180`) for better responsiveness |
| **>16GB RAM or gaming GPU** | Conservative swappiness to avoid stuttering |
| **Virtual Machine** | Skips firmware updates automatically |
| **Btrfs filesystem** | Sets up automatic snapshots |
| **Non-Btrfs filesystem** | Skips snapshot setup gracefully |

## ⚙️ For Advanced Users

Want to see exactly what the script does or modify it for your needs?
The entire script is contained in [`fedora-setup.sh`](fedora-setup.sh). It is thoroughly commented so you can easily understand each section or disable specific tweaks.

Key features you can customize:
- Memory optimization (zram swappiness)
- Kernel boot parameters
- Snapshot retention policy
- Auto-update schedule

## 🤝 How to Contribute

Found a bug or want to suggest a new tweak? We welcome all contributions!
Please read our [CONTRIBUTING.md](CONTRIBUTING.md) guide to get started. No coding experience is required to open an issue.

### Help Us Test on More Hardware!
If you run this script on a system with different specs (AMD GPU, gaming laptop, desktop with 32GB+ RAM, etc.), please open an issue and let us know how it went. Your feedback helps make this script safer for everyone.

## ⚠️ Important Notes

- **This script is designed for Fedora 44 Workstation.** Other editions (Silverblue, KDE Spin) may not be fully compatible.
- **A reboot is required** for kernel parameters and GNOME extensions to take effect.
- **Btrfs snapshots** are only configured if your system already uses Btrfs (Fedora's default).
- **No security features are disabled.** The script prioritizes safety — `mitigations=off` is intentionally excluded.

## 📜 License

This project is open-source and available for anyone to use, modify, and share freely.
