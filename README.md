# 🚀 Klipper ADXL345 Input Shaping on ESP32 / S2 / S3 / C3

Transform any affordable ESP32 microcontroller into a dedicated secondary Klipper MCU for **ADXL345 accelerometer input shaping** and resonance calibration.

```
                    +-----------------------------+
                    |      Linux Host (Klippy)    |
                    | (Raspberry Pi / Mini PC)    |
                    +--------------+--------------+
                                   | USB Serial / Native USB
                                   v
                    +-----------------------------+
                    |     ESP32 Secondary MCU     |
                    |   (ESP32 / S2 / S3 / C3)    |
                    +--------------+--------------+
                                   | SPI Bus (4-wire)
                                   v
                    +-----------------------------+
                    |     ADXL345 Accelerometer   |
                    +-----------------------------+
```

---

## ❤️ Credits & Acknowledgments

This project is made possible thanks to the remarkable work of:

* **[Nikhil Robinson](https://github.com/nikhil-robinson)** for creating **[klipper_esp32](https://github.com/nikhil-robinson/klipper_esp32)**, the foundation port bridging the Klipper firmware protocol to Espressif's ESP-IDF ecosystem. A huge thank you for making ESP32 Klipper nodes a reality!
* **[Kevin O'Connor](https://github.com/KevinOConnor)** and the **[Klipper](https://github.com/Klipper3d/klipper)** team for building the world's most versatile 3D printer firmware.

---

## 📌 Supported Boards & Pinout Guide

Choose your board below. All pin assignments are chosen to avoid boot-strapping conflicts and native USB lines.

| ADXL345 Pin | Classic ESP32 (WROOM/DevKit) | ESP32-S2 (S2 Mini) | ESP32-S3 (S3 Mini/Zero) | ESP32-C3 (SuperMini) |
| :--- | :--- | :--- | :--- | :--- |
| **VCC** | **3.3V** | **3.3V** | **3.3V** | **3.3V** |
| **GND** | **GND** | **GND** | **GND** | **GND** |
| **CS (Chip Select)** | **GPIO 5** | **GPIO 10** | **GPIO 10** | **GPIO 7** |
| **SCL / SCK (Clock)**| **GPIO 18** | **GPIO 12** | **GPIO 12** | **GPIO 4** |
| **SDA / MOSI (Data In)**| **GPIO 23** | **GPIO 11** | **GPIO 11** | **GPIO 6** |
| **SDO / MISO (Data Out)**| **GPIO 19** | **GPIO 13** | **GPIO 13** | **GPIO 5** |
| **USB Connection Mode**| USB-to-UART (CP2102/CH340) | Native USB-OTG CDC | Native USB-Serial-JTAG | Native USB-Serial-JTAG |
| **Config File** | [`configs/adxl_esp32_classic.cfg`](configs/adxl_esp32_classic.cfg) | [`configs/adxl_esp32_s2.cfg`](configs/adxl_esp32_s2.cfg) | [`configs/adxl_esp32_s3.cfg`](configs/adxl_esp32_s3.cfg) | [`configs/adxl_esp32_c3.cfg`](configs/adxl_esp32_c3.cfg) |

> ⚠️ **Important Wiring Warnings:**
> * **ESP32-S2 & S3**: Avoid GPIO 19 and GPIO 20 (they are internally wired to USB D- and D+).
> * **ESP32-C3**: Avoid GPIO 18 and GPIO 19 (USB D- and D+).
> * Keep wire length under 50 cm with flexible ribbon cable to avoid SPI signal attenuation during motion.

---

## ⚡ Option 1: Download Pre-Built Firmware (No Compilation Needed!)

Every commit and tag automatically compiles pre-built firmware for all four chip families via **GitHub Actions**.

1. Go to the **[Releases](../../releases)** or **[Actions](../../actions)** tab in this repository.
2. Download the ZIP file matching your microcontroller:
   * `klipper_esp32.zip` (for classic WROOM / DevKit v1)
   * `klipper_esp32s2.zip` (for ESP32-S2 / S2 Mini)
   * `klipper_esp32s3.zip` (for ESP32-S3 / S3 Zero)
   * `klipper_esp32c3.zip` (for ESP32-C3 / SuperMini)
3. Extract the ZIP. It includes `bootloader.bin`, `partition-table.bin`, `klipper.bin`, and a ready-to-use flashing script (`flash.sh` for Linux/macOS and `flash.bat` for Windows).

### Flashing with `esptool.py`

Put your board into bootloader mode (**Hold `BOOT`, press and release `RESET`, release `BOOT`**), then run:

```bash
# Linux / macOS
./flash.sh /dev/ttyUSB0   # (or /dev/cu.usbmodem... on Mac)

# Windows
flash.bat COM3
```

Or manually with Python:
```bash
python -m esptool --chip <esp32|esp32s2|esp32s3|esp32c3> -p PORT -b 460800 \
  --before default_reset --after hard_reset write_flash \
  --flash_mode dio --flash_freq 80m \
  0x1000 bootloader.bin 0x10000 klipper.bin 0x8000 partition-table.bin
```

---

## 🛠️ Option 2: Build Locally from Source

If you prefer building the binaries yourself:

### 1. Install ESP-IDF v5.2
```bash
sudo apt update
sudo apt install -y git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0
mkdir -p ~/esp && cd ~/esp
git clone -b release/v5.2 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
./install.sh esp32,esp32s2,esp32s3,esp32c3
. ./export.sh
```

### 2. Build All Targets Simultaneously
```bash
chmod +x scripts/build_all_targets.sh
./scripts/build_all_targets.sh
```
All binaries will be packaged into the `binaries/` directory.

---

## ⚙️ Klipper Host Setup (`printer.cfg`)

### Step 1: Plug ESP32 into Your Linux Machine
Connect your flashed ESP32 to a free USB port on your Raspberry Pi / Linux host. Run:
```bash
ls /dev/serial/by-id/*
```
You will see your ESP32 device ID (e.g. `/dev/serial/by-id/usb-Espressif_...`).

### Step 2: Include the Matching Config
Copy the appropriate config file from the `configs/` folder to your Klipper config directory (e.g. `~/printer_data/config/`):
* `adxl_esp32_classic.cfg`
* `adxl_esp32_s2.cfg`
* `adxl_esp32_s3.cfg`
* `adxl_esp32_c3.cfg`

Add the include line to the top of your `printer.cfg`:
```ini
[include configs/adxl_esp32_s2.cfg]
```
Update the `serial:` path inside the included `.cfg` with your board's serial ID.

### Step 3: Install Math Dependencies
On your Linux host, install numpy and matplotlib for frequency analysis:
```bash
sudo apt update
sudo apt install -y python3-numpy python3-matplotlib libatlas-base-dev
~/klippy-env/bin/pip install -v numpy matplotlib
```

Restart Klipper with `FIRMWARE_RESTART`.

---

## 📈 Resonance Testing & Calibration

From Mainsail, Fluidd, or KlipperScreen console:

1. **Verify Accelerometer Communication:**
   ```text
   TEST_ACCEL
   ```
   *(Expected output: `// adxl345 values (x, y, z): ...`)*

2. **Check Noise Floor:**
   ```text
   TEST_NOISE
   ```

3. **Measure Resonances:**
   * Mount ADXL345 securely to your toolhead:
     ```text
     TEST_RESONANCE_X
     ```
   * Mount ADXL345 securely to your print bed (or toolhead on CoreXY):
     ```text
     TEST_RESONANCE_Y
     ```

4. **Generate Frequency Graphs:**
   On your Linux host terminal:
   ```bash
   ~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_*.csv -o /tmp/shaper_calibrate_x.png
   ~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_*.csv -o /tmp/shaper_calibrate_y.png
   ```

5. **Apply Shaper Values:**
   Add the suggested shaper types and frequencies into your `printer.cfg`:
   ```ini
   [input_shaper]
   shaper_freq_x: 52.4
   shaper_type_x: mzv
   shaper_freq_y: 38.6
   shaper_type_y: mzv
   ```

---

## 📄 License & Attribution
* Based on [`nikhil-robinson/klipper_esp32`](https://github.com/nikhil-robinson/klipper_esp32) under the GNU General Public License v3.0 (GPLv3).
* Klipper is Copyright (C) Kevin O'Connor and contributors under GNU GPLv3.
