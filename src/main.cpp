#include <Arduino.h>
#include <U8g2lib.h>
#include <Wire.h>

constexpr uint8_t OLED_SDA_PIN = 21;
constexpr uint8_t OLED_SCL_PIN = 22;

U8G2_SSD1306_128X64_NONAME_1_HW_I2C u8g2(U8G2_R0, U8X8_PIN_NONE);

// [BEGIN lopaka generated]
void drawScreen_1(void) {
  u8g2.setFont(u8g2_font_6x10_tf);
  u8g2.drawFrame(0, 0, 128, 64);
  u8g2.drawStr(4, 14, "ESP32 + SSD1306");
  u8g2.drawStr(4, 30, "Lorem ipsum dolor");
  u8g2.drawStr(4, 44, "sit amet");
}

void setup() {
  Wire.begin(OLED_SDA_PIN, OLED_SCL_PIN);
  u8g2.begin();
}

void loop() {
  u8g2.firstPage();
  do {
    drawScreen_1();
  } while (u8g2.nextPage());
}
// [END lopaka generated]
