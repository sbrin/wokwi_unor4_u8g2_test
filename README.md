# Arduino Uno / Uno R4 U8g2 Test Project

This project contains a test sketch (`unor4_u8g2_test.ino`) that uses the **U8g2** library to draw on an SSD1306 128x64 I2C OLED screen. It includes helper scripts to watch for file changes and automatically compile the sketch, which integrates perfectly with Wokwi's auto-restart feature when local binaries change.

## Prerequisites

Before running the compile-on-save scripts, you need to install the Arduino CLI:

1. **Install arduino-cli**:
   - Follow the instructions on the [Arduino CLI Installation Page](https://arduino.github.io/arduino-cli/latest/installation/).
   - Ensure `arduino-cli` is added to your system's `PATH`.

2. **Install Board Core**:
   - For Arduino Uno (Classic):
     ```bash
     arduino-cli core install arduino:avr
     ```
   - For Arduino Uno R4 Minima / WiFi:
     ```bash
     arduino-cli core install arduino:renesas_uno
     ```

3. **Install U8g2 Library**:
   ```bash
   arduino-cli lib install U8g2
   ```

---

## Running the Auto-Compile Watcher

Choose the script appropriate for your operating system:

### 1. Windows (PowerShell - Recommended)
A native PowerShell script is provided to watch and build without needing Bash.

* **Default Run** (compiles for Arduino Uno by default):
  ```powershell
  .\watch.ps1
  ```
* **Bypassing Execution Policy** (if PowerShell prevents running scripts):
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\watch.ps1
  ```
* **Compile for Arduino Uno R4 Minima**:
  ```powershell
  .\watch.ps1 -Fqbn "arduino:renesas_uno:minima"
  ```

### 2. Windows (Git Bash / MSYS2 / WSL)
If you prefer using Bash on Windows:

* **Default Run**:
  ```bash
  ./watch.sh
  ```
* **Compile for Arduino Uno R4 Minima**:
  ```bash
  FQBN=arduino:renesas_uno:minima ./watch.sh
  ```

### 3. macOS & Linux (Terminal)
Use the standard bash watcher script.

1. **Make the script executable** (first-time setup):
   ```bash
   chmod +x watch.sh
   ```
2. **Run the watcher**:
   - For Arduino Uno (Default):
     ```bash
     ./watch.sh
     ```
   - For Arduino Uno R4 Minima:
     ```bash
     FQBN=arduino:renesas_uno:minima ./watch.sh
     ```

---

## How It Works

* The script monitors the `unor4_u8g2_test.ino` sketch for changes.
* Upon detecting a change, it compiles the sketch using `arduino-cli` and outputs the resulting binaries (`.hex` / `.elf`) into the `build/` directory.
* The [wokwi.toml](file:///Users/sun/Documents/Arduino/unor4_u8g2_test/wokwi.toml) configuration points to these build outputs, causing the Wokwi simulator to automatically restart and load the fresh firmware.
