// Serial-to-Keyboard Round Trip Time (RTT) tester, Arduino Side.
// Target device: Arduino Leonardo family
// Goal: response as soon as possible.

#include "Keyboard.h"

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Keyboard.begin();
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available() > 0)
  {     
    // print as soon as possible.
    char c = Serial.read();
    Keyboard.print(c);
  }
}
