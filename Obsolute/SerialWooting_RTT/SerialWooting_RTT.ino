// Serial-to-Wooting Round Trip Time (RTT) tester, Arduino Side.
// Target device: Arduino family
// Goal: response as soon as possible.
// Attach LED to pin #9

#define LED  9

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available() > 0)
  {     
    // print as soon as possible.
    char c = Serial.read();
    digitalWrite(LED, HIGH);
    delay(50);
    digitalWrite(LED, LOW);
  }
}
