import processing.serial.*;

Serial port;  
char c = 'a';

long timer = 0;
long lastMillis = 0;

void setup()
{
  // List all the available serial ports:
  printArray(Serial.list());
  // connect to the last port in the list;
  String portName = Serial.list()[Serial.list().length - 1];

  port = new Serial(this, portName, 115200);
  

  randomSeed(0);
  frameRate(2000);
  lastMillis = millis();
}

void draw()
{
  long gap = millis() - lastMillis;
  if(gap > 500)
  {
    lastMillis = millis();
    timer = System.nanoTime();
    port.write(c);
  }
}

void keyPressed()
{
  if(key == c)
  {
    long newTime = System.nanoTime();
    long RTT = newTime - timer;
    
    double micro = (double)RTT / 1000000;
    println(micro);
  }
  c++;
  
  if (c == 'z')
    c = 'a';  
}