@echo off
set CHIP=__CHIP__
set PORT=%1
if "%PORT%"=="" set PORT=COM3
echo Flashing Klipper firmware to %CHIP% on port: %PORT%...
esptool.py --chip %CHIP% -p %PORT% -b 460800 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_freq 80m 0x1000 bootloader.bin 0x10000 klipper.bin 0x8000 partition-table.bin
pause

