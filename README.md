## 🔊 Asus ROG Zephyrus G14/G16 (2024/2025) – Linux Sound Fix

This repository contains a Linux sound normalization script for the Asus ROG Zephyrus G14/16 (2024/20025 edition).

The script is designed for systems using PipeWire, WirePlumber, and ALSA, and fixes several common audio issues on this laptop — including a major one where system volume controls do not affect the subwoofers.

<br>
❗ Problems this script fixes
<br>
<br>
On many Linux installations, the Asus ROG Zephyrus G14 and G16 suffers from the following audio problems:
<br>
<br>
🔈 System volume slider does not control subwoofer volume
<br>
<br>
🔊 Subwoofers remain loud even when overall volume is lowered
<br>
<br>
🎚️ Hardware speaker amplifiers (AMP1 / AMP2) are not synchronized with system volume
<br>
<br>
🔄 PipeWire ignores ALSA hardware mixer limits
<br>
<br>
🔥 Sudden volume spikes after boot or resume
<br>
<br>
⚠️ Inconsistent sound quality between reboots
<br>

As a result, lowering the system volume does not properly reduce bass output, leading to unbalanced or overly loud sound.
<br>
<br>
## ✅ What this script does
<br>
<br>
Enables ALSA soft-mixer support in WirePlumber
<br>
<br>
Increased volume by 20db compared to Windows
<br>
<br>
Allows PipeWire to correctly control ALSA hardware mixers
<br>
<br>
Forces sane hardware amplifier levels on boot:
<br>
<br>
Master
<br>
<br>
AMP1 Speaker
<br>
<br>
AMP2 Speaker
<br>
<br>
Ensures subwoofer volume follows the system volume

Normalizes sound output for better balance and clarity

Provides a clean install and full rollback option
<br>
<br>
## Tested on:

✅ Kubuntu 25.10

✅ Ubuntu 25.10

✅ Debian

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
▶ Usage
<br>
<br>

```sh
chmod +x asus-g14-sound-fix.sh

./asus-g14-sound-fix.sh
```
<br>
<br>
Follow the on-screen menu to install or uninstall the fix.
<br>
<br>
🔁 Reboot is required after installation!
<br>
<br>
📌 Why this is needed

On the Asus ROG Zephyrus G14 and G16, subwoofers are controlled by separate hardware amplifiers.

By default, Linux does not correctly bind these amplifiers to the main system volume, which results in:
<br>
“The volume slider moves, but the bass stays loud.”
<br>
<br>
This script fixes that by synchronizing ALSA hardware controls with PipeWire volume management, making volume behavior consistent, predictable, and safe.
