#!/usr/bin/env bash
# ==============================================================================
# Multi-Target Build Script for Klipper ESP32 Firmwares
# ==============================================================================
set -e

TARGETS=("esp32" "esp32s2" "esp32s3" "esp32c3")

# Check if ESP-IDF environment is loaded
if [ -z "$IDF_PATH" ]; then
    if [ -f "$HOME/esp/esp-idf/export.sh" ]; then
        echo "Loading ESP-IDF environment from $HOME/esp/esp-idf..."
        . "$HOME/esp/esp-idf/export.sh"
    else
        echo "ERROR: IDF_PATH not set! Please activate ESP-IDF before running."
        exit 1
    fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$ROOT_DIR/klipper_esp32"
OUT_BASE="$ROOT_DIR/binaries"

mkdir -p "$OUT_BASE"

echo "=========================================================="
echo " Starting Multi-Target Build: ${TARGETS[*]}"
echo "=========================================================="

cd "$SRC_DIR"

for TARGET in "${TARGETS[@]}"; do
    echo ""
    echo ">>> Building target: $TARGET ..."
    echo ""
    
    rm -rf build sdkconfig
    idf.py set-target "$TARGET"
    
    # Target-specific config adjustments
    if [ "$TARGET" = "esp32s2" ]; then
        sed -i '' 's/CONFIG_ESP_CONSOLE_UART_DEFAULT=y/# CONFIG_ESP_CONSOLE_UART_DEFAULT is not set/' sdkconfig 2>/dev/null || sed -i 's/CONFIG_ESP_CONSOLE_UART_DEFAULT=y/# CONFIG_ESP_CONSOLE_UART_DEFAULT is not set/' sdkconfig
        echo "CONFIG_ESP_CONSOLE_USB_CDC=y" >> sdkconfig
        echo "CONFIG_KLIPPER_CONSOLE_USB_CDC=y" >> sdkconfig
    elif [ "$TARGET" = "esp32s3" ] || [ "$TARGET" = "esp32c3" ]; then
        echo "CONFIG_KLIPPER_CONSOLE_USB_CDC=y" >> sdkconfig
        echo "CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y" >> sdkconfig
    else
        echo "CONFIG_KLIPPER_CONSOLE_UART=y" >> sdkconfig
        echo "CONFIG_KLIPPER_UART_BAUD_RATE=250000" >> sdkconfig
    fi
    
    idf.py build
    
    TARGET_OUT="$OUT_BASE/$TARGET"
    mkdir -p "$TARGET_OUT"
    cp build/klipper.bin "$TARGET_OUT/"
    cp build/bootloader/bootloader.bin "$TARGET_OUT/"
    cp build/partition_table/partition-table.bin "$TARGET_OUT/"
    
    echo ">>> Successfully built $TARGET -> Output in binaries/$TARGET/"
done

echo ""
echo "=========================================================="
echo " All targets built successfully!"
echo " Binaries stored in: $OUT_BASE"
echo "=========================================================="

