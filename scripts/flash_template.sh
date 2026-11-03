#!/usr/bin/env bash
CHIP="__CHIP__"
PORT=${1:-/dev/ttyUSB0}
echo "Flashing Klipper firmware to $CHIP on port: $PORT..."
esptool.py --chip "$CHIP" -p "$PORT" -b 460800 \
  --before=default_reset --after=hard_reset write_flash \
  --flash_mode dio --flash_freq 80m \
  0x1000 bootloader.bin 0x10000 klipper.bin 0x8000 partition-table.bin

