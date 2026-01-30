## 🔊 Asus ROG Zephyrus G14 (2025) – Linux Sound Fix

This repository contains a Linux sound normalization script for the Asus ROG Zephyrus G14 (2025 edition).

The script is designed for systems using PipeWire, WirePlumber, and ALSA, and fixes several common audio issues on this laptop — including a major one where system volume controls do not affect the subwoofers.

<br>
❗ Problems this script fixes

On many Linux installations, the Asus ROG Zephyrus G14 suffers from the following audio problems:

🔈 System volume slider does not control subwoofer volume

🔊 Subwoofers remain loud even when overall volume is lowered

🎚️ Hardware speaker amplifiers (AMP1 / AMP2) are not synchronized with system volume

🔄 PipeWire ignores ALSA hardware mixer limits

🔥 Sudden volume spikes after boot or resume

⚠️ Inconsistent sound quality between reboots
<br>

As a result, lowering the system volume does not properly reduce bass output, leading to unbalanced or overly loud sound.
<br>
<br>
## ✅ What this script does
<br>
Enables ALSA soft-mixer support in WirePlumber

Allows PipeWire to correctly control ALSA hardware mixers

Forces sane hardware amplifier levels on boot:

Master

AMP1 Speaker

AMP2 Speaker

Ensures subwoofer volume follows the system volume

Normalizes sound output for better balance and clarity

Automatically detects the correct ALSA device

Provides a clean install and full rollback option

🐧 Supported Linux distributions

Officially supported and tested on:

✅ Fedora

✅ Arch Linux

✅ CachyOS

Other distributions may work but are not guaranteed.
<br>

✨ Features

Interactive install / uninstall menu

systemd service installation

Full uninstall / rollback support

Execution logging to:
<br>
/var/log/asus-g14-sound-fix.log
<br>

<br>
▶ Usage
chmod +x asus-g14-sound-fix.sh
<br>
<br>
./asus-g14-sound-fix.sh

<br>
<br>
Follow the on-screen menu to install or uninstall the fix.
<br>
<br>
🔁 A reboot is recommended after installation.
<br>
<br>
📌 Why this is needed

On the Asus ROG Zephyrus G14, subwoofers are controlled by separate hardware amplifiers.

By default, Linux does not correctly bind these amplifiers to the main system volume, which results in:
<br>
“The volume slider moves, but the bass stays loud.”
<br>
<br>
This script fixes that by synchronizing ALSA hardware controls with PipeWire volume management, making volume behavior consistent, predictable, and safe.
