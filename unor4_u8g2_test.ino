#include <Arduino.h>
#include <U8g2lib.h>
#include <Wire.h>

// Test sketch for U8G2 + SSD1306 128x64 I2C.
// UNO/UNO R4 wiring: SDA -> A4, SCL -> A5, VCC -> 5V, GND -> GND.
// Use page buffer mode to keep SRAM usage low on classic UNO.
U8G2_SSD1306_128X64_NONAME_1_HW_I2C u8g2(U8G2_R0, U8X8_PIN_NONE);


// [BEGIN lopaka generated]
void drawScreen_1(void) {
}

void loop(){
    u8g2.firstPage();
    do {
        drawScreen_1();
    } while (u8g2.nextPage());
};

void setup() {
    u8g2.begin();
}
// [END lopaka generated]

