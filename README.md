# ESP32 U8g2 OLED Test Project

PlatformIO project for an ESP32 DevKit C V4 connected to an SSD1306 128x64 I2C OLED in Wokwi.

## Wiring

The Wokwi diagram uses the standard ESP32 I2C pins:

- `GPIO21` -> OLED `SDA`
- `GPIO22` -> OLED `SCL`
- `3V3` -> OLED `VCC`
- `GND` -> OLED `GND`

## Build

Install PlatformIO Core, then run:

```bash
pio run
```

The firmware used by Wokwi is produced at:

```text
.pio/build/esp32dev/firmware.bin
.pio/build/esp32dev/firmware.elf
```

`wokwi.toml` points to those files, so Wokwi will load the PlatformIO build output.

## Watch Mode

To rebuild automatically when source files change:

```bash
chmod +x watch.sh
./watch.sh
```

For a single build through the watcher:

```bash
ONCE=1 ./watch.sh
```

## Source Layout

- `platformio.ini` configures the ESP32 PlatformIO environment and the U8g2 dependency.
- `src/main.cpp` is the PlatformIO entry point.
- `diagram.json` describes the Wokwi ESP32 + OLED circuit.
- `unor4_u8g2_test.ino` is left as the original Arduino sketch reference and is not used by PlatformIO.
