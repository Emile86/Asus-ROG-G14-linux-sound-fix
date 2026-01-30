#!/usr/bin/env bash
set -e

### ========= CONFIG ========= ###
LOG_FILE="/var/log/asus-g14-sound-fix.log"
SERVICE_NAME="alsa-card1-volume-cap"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
WP_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
WP_FILE="$WP_DIR/99-alsasoftvol.conf"
GITHUB_URL="https://github.com/Emile86/Asus-ROG-G14-linux-sound-fix"
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

### Sudo upfront (also required for logging) ###
sudo -v

### Detect distro ###
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

DISTRO=$(detect_distro)

SUPPORTED_DISTROS=("ubuntu" "debian" "fedora" "arch" "cachyos")

### Intro ###
clear
title "Asus ROG Zephyrus G14 – Linux Sound Fix"

echo -e "${BOLD}"
echo "This script is to normalize volume level and sound quality"
echo "for Asus ROG Zephyrus G14 2025 edition"
echo -e "${RESET}"

echo
echo "GitHub:"
echo -e "${BOLD}$GITHUB_URL${RESET}"
echo

echo "Detected distro: ${BOLD}$DISTRO${RESET}"

if [[ ! " ${SUPPORTED_DISTROS[*]} " =~ " $DISTRO " ]]; then
  warn "Distro not officially supported. Proceeding anyway."
else
  ok "Distro supported"
fi

### Menu ###
echo
line
echo "Choose an option:"
echo "  1) Install / Apply sound fix"
echo "  2) Uninstall / Rollback"
echo "  3) Exit"
line
read -rp "Select [1-3]: " MENU

case "$MENU" in
  1) MODE="install" ;;
  2) MODE="uninstall" ;;
  3) exit 0 ;;
  *) die "Invalid selection" ;;
esac

### Detect ALSA device ###
detect_device_name() {
  pactl list cards short | awk '{print $2}' | grep alsa_card | head -n1
}

DEVICE_NAME=$(detect_device_name)
[[ -n "$DEVICE_NAME" ]] || die "Failed to auto-detect ALSA card"

DEVICE_REGEX="~${DEVICE_NAME}.*"
ok "Detected ALSA device: $DEVICE_NAME"

### INSTALL ###
if [[ "$MODE" == "install" ]]; then
  title "Installing sound fix"

  mkdir -p "$WP_DIR"
  ok "Ensured WirePlumber config directory"

  if [[ ! -f "$WP_FILE" ]]; then
    cat > "$WP_FILE" << EOF
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
    ok "Created WirePlumber soft-mixer config"
  else
    warn "WirePlumber config already exists"
  fi

  if [[ ! -f "$SERVICE_FILE" ]]; then
    sudo tee "$SERVICE_FILE" >/dev/null << 'EOF'
[Unit]
Description=Set max volume on ALSA card 1
After=sound.target

[Service]
Type=oneshot
ExecStart=/bin/sleep 10
ExecStart=/usr/bin/amixer -c 1 set Master 100%
ExecStart=/usr/bin/amixer -c 1 set 'AMP1 Speaker' 100%
ExecStart=/usr/bin/amixer -c 1 set 'AMP2 Speaker' 100%

[Install]
WantedBy=multi-user.target
EOF
    ok "Created systemd service"
  else
    warn "Service already exists"
  fi

  sudo systemctl daemon-reload
  sudo systemctl enable "$SERVICE_NAME"
  sudo systemctl start "$SERVICE_NAME"
  ok "Service enabled and started"
fi

### UNINSTALL ###
if [[ "$MODE" == "uninstall" ]]; then
  title "Uninstalling / rollback"

  sudo systemctl disable --now "$SERVICE_NAME" 2>/dev/null || true
  sudo rm -f "$SERVICE_FILE"
  ok "Removed systemd service"

  rm -f "$WP_FILE"
  ok "Removed WirePlumber config"

  sudo systemctl daemon-reload
fi

### Finish ###
title "Finished"

echo "Log file:"
echo -e "${BOLD}$LOG_FILE${RESET}"
echo

read -rp "Reboot now to apply changes? (y/N): " RB
if [[ "$RB" =~ ^[Yy]$ ]]; then
  sudo reboot
else
  warn "Reboot skipped — please reboot later"
fi
