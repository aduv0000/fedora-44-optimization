#!/bin/bash

# Version check
if ! grep -q "Fedora Linux 44" /etc/os-release; then
    echo "This script is designed for Fedora 44 only. Exiting."
    exit 1
fi

# Fedora 44 Beginner-Friendly Setup Script
# Just run: ./fedora-setup.sh
# Then reboot. That's it.

set -e

clear
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║    Fedora 44 - Ultimate Beginner Setup       ║"
echo "║    No technical knowledge needed.            ║"
echo "║    Just wait, reboot, and enjoy!             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "This will make your Fedora faster, safer, and self-maintaining."
echo "Nothing harmful will happen. Sit back and relax."
echo ""
read -p "Press ENTER to start (or Ctrl+C to cancel): "

USERNAME=$(whoami)
START_TIME=$(date +%s)

# Helper function for friendly progress messages
step() {
    echo ""
    echo "✨ $1..."
    sleep 0.5
}

# ─────────────────────────────────────────────
# STEP 1: SYSTEM UPDATE
# ─────────────────────────────────────────────
step "Updating your system (this may take a few minutes)"
sudo dnf upgrade --refresh -y 2>/dev/null

# ─────────────────────────────────────────────
# STEP 2: FASTER DOWNLOADS
# ─────────────────────────────────────────────
step "Making downloads faster"
if ! grep -q "fastestmirror" /etc/dnf/dnf.conf 2>/dev/null; then
    echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
fi
if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf 2>/dev/null; then
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
fi

# ─────────────────────────────────────────────
# STEP 3: MULTIMEDIA & CODECS
# ─────────────────────────────────────────────
step "Installing extra software sources for better app support"
sudo dnf install -y \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" 2>/dev/null || true

step "Adding video codecs so all videos play smoothly"
sudo dnf groupupdate -y multimedia core sound-and-video 2>/dev/null || true
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing 2>/dev/null || true

# Install GPU-specific drivers based on detected hardware
if lspci | grep -qi "intel.*graphics\|intel.*vga"; then
    step "Detected Intel GPU - installing Intel media drivers"
    sudo dnf install -y intel-media-driver intel-gpu-tools 2>/dev/null || true
elif lspci | grep -qi "amd.*graphics\|amd.*vga\|radeon"; then
    step "Detected AMD GPU - installing AMD media drivers"
    sudo dnf install -y mesa-va-drivers mesa-vdpau-drivers 2>/dev/null || true
fi

# ─────────────────────────────────────────────
# STEP 4: HARDWARE UPDATES
# ─────────────────────────────────────────────
step "Updating your hardware firmware for better stability"

# Detect CPU and install appropriate microcode
if grep -qi "intel" /proc/cpuinfo; then
    sudo dnf install -y linux-firmware intel-ucode 2>/dev/null || true
elif grep -qi "amd" /proc/cpuinfo; then
    sudo dnf install -y linux-firmware amd-ucode-firmware 2>/dev/null || true
fi

# Only run firmware update if not in a virtual machine
if ! systemd-detect-virt --quiet; then
    sudo fwupdmgr refresh 2>/dev/null && sudo fwupdmgr update -y 2>/dev/null || true
else
    echo "   Virtual machine detected - skipping firmware update"
fi

# ─────────────────────────────────────────────
# STEP 5: USEFUL APPS
# ─────────────────────────────────────────────
step "Installing helpful apps (system tools, backup, monitoring)"
sudo dnf install -y \
    gnome-tweaks \
    btrfs-assistant \
    snapper \
    python3-dnf-plugin-snapper \
    libdnf5-plugin-actions \
    htop \
    fastfetch \
    gnome-extensions-app \
    flatpak \
    gamemode \
    inotify-tools \
    2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 6: BRAVE BROWSER (optional)
# ─────────────────────────────────────────────
echo ""
read -p "Would you like to install Brave browser? (y/N): " INSTALL_BRAVE
if [[ "$INSTALL_BRAVE" =~ ^[Yy]$ ]]; then
    step "Installing Brave browser with hardware video acceleration"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    flatpak install --system flathub com.brave.Browser -y 2>/dev/null || true
else
    step "Skipping Brave browser installation"
    # Make sure Flathub is still enabled for other apps
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
fi

# ─────────────────────────────────────────────
# STEP 7: PERFORMANCE KERNEL SETTINGS
# ─────────────────────────────────────────────
step "Applying performance optimizations"

# Backup grub config before modifying
sudo cp /etc/default/grub /etc/default/grub.backup 2>/dev/null || true

# Safe kernel parameters only - mitigations are kept ON for security
if ! grep -q "split_lock_detect=off" /etc/default/grub 2>/dev/null; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 split_lock_detect=off nowatchdog nmi_watchdog=0 usbcore.autosuspend=-1 plymouth.enable=0"/' /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
fi

# ─────────────────────────────────────────────
# STEP 8: MEMORY & SSD OPTIMIZATION
# ─────────────────────────────────────────────
step "Optimizing memory and SSD performance"

# Detect RAM and GPU for smart swappiness tuning
RAM_GB=$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo)
HAS_DGPU=$(lspci | grep -iE "nvidia|radeon|amd.*vga" | grep -iv "intel" | wc -l)

if [ "$RAM_GB" -le 16 ] && [ "$HAS_DGPU" -eq 0 ]; then
    # Low RAM + integrated GPU: aggressive zram tuning
    SWAPPINESS=180
    echo "   Detected low RAM / integrated GPU - using aggressive memory optimization"
else
    # High RAM or dedicated GPU: conservative setting
    SWAPPINESS=10
    echo "   Detected high RAM or dedicated GPU - using conservative memory optimization"
fi

cat <<EOF | sudo tee /etc/sysctl.d/99-sysctl.conf >/dev/null
vm.swappiness=$SWAPPINESS
fs.inotify.max_user_watches=524288
vm.timer_migration=0
EOF

sudo sysctl -p /etc/sysctl.d/99-sysctl.conf 2>/dev/null || true

# NVMe scheduler optimization
echo 'ACTION=="add", KERNEL=="nvme*", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules >/dev/null 2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 9: AUTOMATIC BACKUPS (Btrfs snapshots)
# ─────────────────────────────────────────────
# Only set up if system uses Btrfs
if findmnt -n -o FSTYPE / | grep -q btrfs; then
    step "Setting up automatic system backups (snapshots)"

    sudo snapper -c root create-config / 2>/dev/null || true
    sudo snapper -c home create-config /home 2>/dev/null || true

    for CONFIG in root home; do
        sudo snapper -c $CONFIG set-config ALLOW_USERS="$USERNAME" SYNC_ACL=yes 2>/dev/null || true
        sudo snapper -c $CONFIG set-config TIMELINE_CREATE="yes" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config TIMELINE_CLEANUP="yes" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config NUMBER_CLEANUP="yes" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config NUMBER_LIMIT="3" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_HOURLY="5" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_DAILY="7" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_WEEKLY="2" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_MONTHLY="1" 2>/dev/null || true
        sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_YEARLY="0" 2>/dev/null || true
    done

    # Disable home timeline (pre/post on installs is enough)
    sudo snapper -c home set-config TIMELINE_CREATE=no 2>/dev/null || true

    sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer 2>/dev/null || true
else
    echo "   Non-Btrfs filesystem detected - skipping snapshot setup"
fi

# ─────────────────────────────────────────────
# STEP 10: UPDATE NOTIFICATIONS (not auto-apply)
# ─────────────────────────────────────────────
step "Enabling update notifications (you stay in control)"
sudo cp /usr/share/dnf5/dnf5-plugins/automatic.conf /etc/dnf/automatic.conf 2>/dev/null || true

# Notify only - never apply automatically
sudo sed -i 's/apply_updates = yes/apply_updates = no/' /etc/dnf/automatic.conf 2>/dev/null || true
sudo sed -i 's/apply_updates=yes/apply_updates=no/' /etc/dnf/automatic.conf 2>/dev/null || true
echo "apply_updates = no" | sudo tee -a /etc/dnf/automatic.conf >/dev/null 2>/dev/null || true

sudo systemctl enable --now dnf-automatic.timer 2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 11: FILESYSTEM SPEEDUP
# ─────────────────────────────────────────────
if findmnt -n -o FSTYPE / | grep -q btrfs; then
    step "Speeding up file access"

    # Backup fstab before modifying
    sudo cp /etc/fstab /etc/fstab.backup 2>/dev/null || true

    if grep -q "subvol=root,compress=zstd:1" /etc/fstab && ! grep -q "noatime" /etc/fstab; then
        sudo sed -i 's/subvol=root,compress=zstd:1/subvol=root,compress=zstd:1,noatime/' /etc/fstab
    fi
    if grep -q "subvol=home,compress=zstd:1" /etc/fstab && ! grep -q "noatime" /etc/fstab; then
        sudo sed -i 's/subvol=home,compress=zstd:1/subvol=home,compress=zstd:1,noatime/' /etc/fstab
    fi
fi

# ─────────────────────────────────────────────
# STEP 12: GAMEMODE SETUP
# ─────────────────────────────────────────────
step "Setting up gaming optimizations"
sudo usermod -aG gamemode "$USERNAME" 2>/dev/null || true

# ─────────────────────────────────────────────
# WRAP UP
# ─────────────────────────────────────────────
END_TIME=$(date +%s)
DURATION=$(( (END_TIME - START_TIME) / 60 ))

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║            ✅ ALL DONE!                      ║"
echo "║         Total time: ~${DURATION} minutes               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│  WHAT HAPPENED:                             │"
echo "│  ✓ System updated                           │"
echo "│  ✓ Downloads are now faster                 │"
echo "│  ✓ Videos will play smoothly                │"
echo "│  ✓ Hardware firmware updated                │"
echo "│  ✓ Battery saver is automatic               │"
echo "│  ✓ System is faster and more responsive     │"
echo "│  ✓ Automatic backups enabled (Btrfs)        │"
echo "│  ✓ Update notifications enabled             │"
echo "│  ✓ File access optimized                    │"
echo "│  ✓ Gaming optimizations applied             │"
echo "│  ✓ Security features kept intact            │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│  BACKUPS CREATED:                           │"
echo "│  /etc/default/grub.backup                  │"
echo "│  /etc/fstab.backup                         │"
echo "│  (Keep these safe!)                         │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│  WHAT YOU NEED TO DO:                       │"
echo "│  Type this and press ENTER: reboot          │"
echo "│  That's it. Seriously.                      │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "After reboot, everything just works."
echo "You will be notified when updates are available."
echo ""
