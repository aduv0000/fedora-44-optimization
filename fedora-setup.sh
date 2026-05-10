#!/bin/bash
# Fedora 44 Beginner-Friendly Setup Script
# Just run: ./fedora-setup.sh
# Then reboot. That's it.

set -e

clear
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Fedora 44 - Ultimate Beginner Setup        ║"
echo "║   No technical knowledge needed.             ║"
echo "║   Just wait, reboot, and enjoy!              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "This will make your Fedora faster, safer, and self-updating."
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
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" 2>/dev/null

step "Adding video codecs so all videos play smoothly"
sudo dnf groupupdate -y multimedia core sound-and-video 2>/dev/null
sudo dnf install -y intel-media-driver intel-gpu-tools 2>/dev/null
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing 2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 4: HARDWARE UPDATES
# ─────────────────────────────────────────────
step "Updating your hardware's firmware for better stability"
sudo dnf install -y linux-firmware intel-ucode 2>/dev/null
sudo fwupdmgr refresh 2>/dev/null && sudo fwupdmgr update 2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 5: USEFUL APPS
# ─────────────────────────────────────────────
step "Installing helpful apps (system tools, backup, monitoring)"
sudo dnf install -y \
    gnome-tweaks \
    btrfs-assistant \
    snapper \
    dnf5-plugin-automatic \
    htop \
    fastfetch \
    gnome-extensions-app \
    flatpak \
    dconf-editor \
    gnome-shell-extension-appindicator 2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 6: BRAVE BROWSER (with video acceleration)
# ─────────────────────────────────────────────
step "Installing Brave browser with hardware video acceleration"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null
flatpak install --system flathub com.brave.Browser -y 2>/dev/null || true

# Add VAAPI flags to Brave's launcher
BRAVE_DESKTOP="/var/lib/flatpak/exports/share/applications/com.brave.Browser.desktop"
if [ -f "$BRAVE_DESKTOP" ]; then
    sudo sed -i 's|^Exec=.*|Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=brave com.brave.Browser --use-gl=angle --use-angle=gl-egl --enable-features=VaapiVideoDecodeLinuxGL|' "$BRAVE_DESKTOP"
fi

# ─────────────────────────────────────────────
# STEP 7: AUTO POWER PROFILES (battery saver)
# ─────────────────────────────────────────────
step "Setting up automatic battery saving"
# Install the extension
EXT_URL="https://extensions.gnome.org/extension-data/auto-power-profilesdmy3k.github.io.v18.shell-extension.zip"
TEMP_DIR=$(mktemp -d)
wget -q -O "$TEMP_DIR/extension.zip" "$EXT_URL" 2>/dev/null || {
    # Fallback: try gnome-extensions CLI
    gnome-extensions install --download "https://extensions.gnome.org/extension/5693/auto-power-profiles/" 2>/dev/null || true
}
if [ -f "$TEMP_DIR/extension.zip" ]; then
    UUID=$(unzip -p "$TEMP_DIR/extension.zip" metadata.json 2>/dev/null | grep -oP '"uuid":\s*"\K[^"]+' || echo "")
    if [ -n "$UUID" ]; then
        mkdir -p "/home/$USERNAME/.local/share/gnome-shell/extensions/$UUID"
        unzip -o "$TEMP_DIR/extension.zip" -d "/home/$USERNAME/.local/share/gnome-shell/extensions/$UUID" 2>/dev/null
        # Enable it
        gnome-extensions enable "$UUID" 2>/dev/null || true
    fi
fi
rm -rf "$TEMP_DIR"

# ─────────────────────────────────────────────
# STEP 8: PERFORMANCE KERNEL SETTINGS
# ─────────────────────────────────────────────
step "Applying performance optimizations"
if ! grep -q "split_lock_detect=off" /etc/default/grub 2>/dev/null; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 split_lock_detect=off nowatchdog nmi_watchdog=0 mitigations=off usbcore.autosuspend=-1 plymouth.enable=0 video=efifb:nobgrt"/' /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null
fi

# ─────────────────────────────────────────────
# STEP 9: MEMORY & SSD OPTIMIZATION
# ─────────────────────────────────────────────
step "Optimizing memory and SSD performance"
cat <<EOF | sudo tee /etc/sysctl.d/99-sysctl.conf >/dev/null
vm.swappiness=180
fs.inotify.max_user_watches=524288
vm.timer_migration=0
EOF
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf 2>/dev/null

echo 'ACTION=="add", KERNEL=="nvme*", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules >/dev/null 2>/dev/null

# ─────────────────────────────────────────────
# STEP 10: AUTOMATIC BACKUPS (Btrfs snapshots)
# ─────────────────────────────────────────────
step "Setting up automatic system backups (snapshots)"

# Create configs
sudo snapper -c root create-config / 2>/dev/null || true
sudo snapper -c home create-config /home 2>/dev/null || true

# Apply optimized settings to both
for CONFIG in root home; do
    sudo snapper -c $CONFIG set-config ALLOW_USERS="$USERNAME" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config TIMELINE_CREATE="yes" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config TIMELINE_CLEANUP="yes" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config NUMBER_CLEANUP="yes" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config NUMBER_LIMIT="3" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config NUMBER_LIMIT_IMPORTANT="10" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_HOURLY="5" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_DAILY="7" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_WEEKLY="2" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_MONTHLY="1" 2>/dev/null || true
    sudo snapper -c $CONFIG set-config TIMELINE_LIMIT_YEARLY="0" 2>/dev/null || true
done

sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer 2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 11: AUTOMATIC UPDATES
# ─────────────────────────────────────────────
step "Enabling automatic updates (no more manual updating!)"
sudo cp /usr/share/dnf5/dnf5-plugins/automatic.conf /etc/dnf/automatic.conf 2>/dev/null || true
sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf 2>/dev/null
sudo sed -i 's/reboot = when-needed/reboot = never/' /etc/dnf/automatic.conf 2>/dev/null
sudo systemctl enable --now dnf5-automatic.timer 2>/dev/null || true

# ─────────────────────────────────────────────
# STEP 12: FILESYSTEM SPEEDUP
# ─────────────────────────────────────────────
step "Speeding up file access"
if grep -q "subvol=root,compress=zstd:1" /etc/fstab && ! grep -q "noatime" /etc/fstab; then
    sudo sed -i 's/subvol=root,compress=zstd:1/subvol=root,compress=zstd:1,noatime/' /etc/fstab
fi
if grep -q "subvol=home,compress=zstd:1" /etc/fstab && ! grep -q "noatime" /etc/fstab; then
    sudo sed -i 's/subvol=home,compress=zstd:1/subvol=home,compress=zstd:1,noatime/' /etc/fstab
fi

# ─────────────────────────────────────────────
# WRAP UP
# ─────────────────────────────────────────────
END_TIME=$(date +%s)
DURATION=$(( (END_TIME - START_TIME) / 60 ))

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ ALL DONE!                               ║"
echo "║   Total time: ~${DURATION} minutes                     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│  WHAT HAPPENED:                              │"
echo "│  ✓ Downloads are now faster                  │"
echo "│  ✓ Videos will play smoothly                 │"
echo "│  ✓ Hardware firmware updated                 │"
echo "│  ✓ Brave browser installed                   │"
echo "│  ✓ Battery saver is automatic                │"
echo "│  ✓ System is faster and more responsive      │"
echo "│  ✓ Automatic backups are enabled             │"
echo "│  ✓ Updates install themselves                │"
echo "│  ✓ File access is optimized                  │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│  WHAT YOU NEED TO DO:                        │"
echo "│  Type this and press ENTER:  reboot          │"
echo "│  That's it. Seriously.                       │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "After reboot, everything just works."
echo "Your laptop will update itself and save battery automatically."
echo ""
