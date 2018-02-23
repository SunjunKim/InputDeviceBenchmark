// Serial Round Trip Time (RTT) tester, Arduino Side.
// Target device: Arduino family
// Goal: response as soon as possible.

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available() > 0)
  {     
    // print as soon as possible.
    char c = Serial.read();
    Serial.print(c);
  }
}
