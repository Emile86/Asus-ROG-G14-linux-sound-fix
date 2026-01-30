#!/usr/bin/env bash
set -e

### ========= CONFIG ========= ###
LOG_FILE="/var/log/asus-g14-sound-fix.log"
SERVICE_NAME="asus-g14-volume-fix"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
WP_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
WP_FILE="$WP_DIR/99-alsasoftvol.conf"
GITHUB_URL="https://github.com/Emile86/Asus-ROG-G14-linux-sound-fix"
ALSA_CARD_INDEX=1  # Hardcoded, will use card index 1
DEVICE_NAME="alsa_card.pci-0000_65_00.6" # Hardcoded working card
### =========================== ###

### Colors ###
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"
BLUE="\e[34m"; CYAN="\e[36m"; BOLD="\e[1m"; RESET="\e[0m"

log() {
  echo "$(date '+%F %T') | $1" | sudo tee -a "$LOG_FILE" >/dev/null
}

line() { echo -e "${BLUE}------------------------------------------------------------${RESET}"; }
title() { line; echo -e "${BOLD}${CYAN}$1${RESET}"; line; }
ok() { echo -e "${GREEN}✔ $1${RESET}"; log "OK: $1"; }
warn() { echo -e "${YELLOW}⚠ $1${RESET}"; log "WARN: $1"; }
die() { echo -e "${RED}✖ $1${RESET}"; log "ERROR: $1"; exit 1; }

### Sudo upfront ###
sudo -v

### Detect distro ###
. /etc/os-release 2>/dev/null || true
DISTRO="${ID:-unknown}"

SUPPORTED_DISTROS=("ubuntu" "debian" "fedora" "arch" "cachyos")

clear
title "Asus ROG Zephyrus G14 – Linux Sound Fix"

echo "GitHub:"
echo -e "${BOLD}$GITHUB_URL${RESET}"
echo
echo "Detected distro: ${BOLD}$DISTRO${RESET}"

[[ " ${SUPPORTED_DISTROS[*]} " =~ " $DISTRO " ]] || warn "Distro not officially supported"

### Menu ###
echo
line
echo "1) Install / Apply sound fix"
echo "2) Uninstall / Rollback"
echo "3) Exit"
line
read -rp "Select [1-3]: " MENU

case "$MENU" in
  1) MODE="install" ;;
  2) MODE="uninstall" ;;
  3) exit 0 ;;
  *) die "Invalid selection" ;;
esac

DEVICE_REGEX="~${DEVICE_NAME}"
ok "Using hardcoded ALSA device: $DEVICE_NAME"

### INSTALL ###
if [[ "$MODE" == "install" ]]; then
  title "Installing sound fix"

  mkdir -p "$WP_DIR"
  cat > "$WP_FILE" <<EOF
monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "$DEVICE_REGEX"
      }
    ]
    actions = {
      update-props = {
        api.alsa.soft-mixer = true
      }
    }
  }
]
EOF
  ok "WirePlumber soft-mixer enabled"

  sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=Asus G14 Speaker + Subwoofer Volume Fix
After=pipewire.service wireplumber.service
Wants=pipewire.service wireplumber.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c "sleep 8; \
  amixer -c $ALSA_CARD_INDEX set Master 100% && \
  amixer -c $ALSA_CARD_INDEX set 'AMP1 Speaker' 100% && \
  amixer -c $ALSA_CARD_INDEX set 'AMP2 Speaker' 100% && \
  amixer -c $ALSA_CARD_INDEX set PCM 100% && \
  amixer -c $ALSA_CARD_INDEX set Speaker 100%"
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now "$SERVICE_NAME"
  ok "Service installed and started"
fi

### UNINSTALL ###
if [[ "$MODE" == "uninstall" ]]; then
  title "Uninstalling"

  sudo systemctl disable --now "$SERVICE_NAME" 2>/dev/null || true
  sudo rm -f "$SERVICE_FILE"
  rm -f "$WP_FILE"
  sudo systemctl daemon-reload

  ok "Rollback complete"
fi

title "Finished"
echo "Log file: $LOG_FILE"
echo
read -rp "Reboot now to apply changes? (y/N): " RB
if [[ "$RB" =~ ^[Yy]$ ]]; then
  sudo reboot
else
  warn "Reboot skipped — please reboot later"
fi
