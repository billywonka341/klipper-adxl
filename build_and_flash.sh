#!/usr/bin/env bash
# ==============================================================================
# Build & Flash Script for Klipper ESP32-S2 Secondary MCU
# ==============================================================================
set -e

echo "=== Klipper ESP32-S2 Firmware Setup ==="

# 1. Check for ESP-IDF
if [ -z "$IDF_PATH" ]; then
    if [ -f "$HOME/esp/esp-idf/export.sh" ]; then
        echo "Loading ESP-IDF environment from $HOME/esp/esp-idf..."
        . "$HOME/esp/esp-idf/export.sh"
    else
        echo "ERROR: ESP-IDF not found!"
        echo "Please install ESP-IDF v5.2 or run: . path/to/esp-idf/export.sh before running this script."
        exit 1
    fi
fi

# 2. Clone repository if not present
REPO_DIR="$HOME/klipper_esp32"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning nikhil-robinson/klipper_esp32 (recursive)..."
    git clone --recursive https://github.com/nikhil-robinson/klipper_esp32.git "$REPO_DIR"
fi

cd "$REPO_DIR"

# 3. Set target to ESP32-S2
echo "Setting target to esp32s2..."
idf.py set-target esp32s2

# 4. Prompt for menuconfig or build directly
echo ""
echo "Target configured for ESP32-S2."
echo "If you need to change USB console settings (e.g. Native USB vs UART), run: idf.py menuconfig"
echo "Otherwise, building now..."
echo ""

idf.py build

echo ""
echo "=== Build Complete! ==="
echo "To flash your ESP32-S2, run:"
echo "  idf.py -p /dev/ttyUSB0 flash"
echo "(Replace /dev/ttyUSB0 with your actual device port, e.g. /dev/ttyACM0 or /dev/cu.usbserial-...)"

