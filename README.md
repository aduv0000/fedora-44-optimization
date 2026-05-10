# Fedora 44 - One-Click Optimization 🚀

Transform a fresh **Fedora 44 Workstation** install into a lightning-fast, self-maintaining, and beginner-friendly system with a single command.

No Linux knowledge required. Just run the script, reboot, and enjoy.

**Created and tested by the community, for the community.**

## ✨ What This Script Does

| Category | Optimizations Included |
| :--- | :--- |
| **Speed** | Faster DNF downloads, optimized memory & SSD, kernel performance tweaks |
| **Media** | Full multimedia codecs via RPM Fusion + hardware video acceleration |
| **Battery** | Automatic power profiles (switches between Performance, Balanced, Power Saver) |
| **Backups** | Automatic system snapshots with Btrfs Assistant & Snapper |
| **Updates** | Daily automatic security updates (no reboots without your permission) |
| **Privacy** | Brave browser pre-installed with hardware acceleration ready |

## ⚡ One-Command Install

Copy the command below and paste it into your terminal:

```
git clone https://github.com/aduv0000/fedora-44-optimization.git && cd fedora-44-optimization && chmod +x fedora-setup.sh && ./fedora-setup.sh
```

**After it finishes, reboot your computer.** That is the only manual step.

📋 What to Expect After Reboot
Your system will feel faster and more responsive.

Videos and streams will play smoothly with less CPU usage.

Your laptop battery will last longer and switch power modes automatically.

System updates will install quietly in the background, daily.

If an update ever causes a problem, you can roll back using Btrfs snapshots.

⚙️ For Advanced Users
Want to see exactly what the script does or modify it for your needs?
The entire script is contained in fedora-setup.sh. It is thoroughly commented so you can easily understand each section or disable specific tweaks.

🤝 How to Contribute
Found a bug or want to suggest a new tweak? We welcome all contributions!
Please read our CONTRIBUTING.md guide to get started. No coding experience is required to open an issue.

⚠️ Hardware Compatibility Note
This script applies a zram optimization (vm.swappiness=180) that is ideal for systems with 16GB of RAM or less. If you are running a high-end desktop or a gaming laptop with dedicated graphics and more than 16GB of RAM, you may want to skip that specific section or adjust the value. Check the script comments for details.

📜 License
This project is open-source and available for anyone to use, modify, and share freely.
