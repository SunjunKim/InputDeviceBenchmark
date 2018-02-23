// Serial-to-Wooting Round Trip Time (RTT) tester, Arduino Side.
// Target device: Arduino family
// Goal: response as soon as possible.
// Attach LED to pin #16 and #14

// mimimal boot HID keyboard implementation. Look https://github.com/NicoHood/HID/wiki/Keyboard-API#boot-keyboard
// Worked for HID-project 2.4.4.
//#include "HID-Project.h"
#include <Keyboard.h>

#define LED 14 // PB3

// macro for the high speed operation
#define LED_ON  bitSet(PORTB, 3);
#define LED_OFF bitClear(PORTB, 3);

enum testMode {LOOPBACK, LEDTEST};

testMode mode = LOOPBACK;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);

  Keyboard.begin();
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0)
  {
    // print as soon as possible.
    char ch = Serial.read();

    // trigger a test keystroke
    if (ch == 'r')
    {

      switch (mode)
      {
        case LOOPBACK:
          Serial.print('r');
          Serial.flush();
          delay(10);
          Keyboard.press('a');
          delay(50);
          Keyboard.releaseAll();
          break;
        case LEDTEST:
          Serial.print('r');
          Serial.flush();
          delay(10);
          LED_ON;
          delay(50);
          LED_OFF;
          break;
      }
      return;
    }

    // change the mode with a command 'L' or 'T'
    switch (ch)
    {
      case 'L':
        mode = LOOPBACK;
        Serial.println("Loopback mode");
        break;
      case 'T':
        mode = LEDTEST;
        Serial.println("LED (or photocoupler) test mode");
        break;
    }
  }
}
