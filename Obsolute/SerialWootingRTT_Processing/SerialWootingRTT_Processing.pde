import processing.serial.*;

Serial port;  
char c = 'a';

PrintWriter output; 

long timer = 0;
long pressed = 0;
long lastMillis = 0;
int cnt = 0;

void setup()
{
  // List all the available serial ports:
  printArray(Serial.list());
  // connect to the last port in the list;
  String portName = Serial.list()[Serial.list().length - 1];

  output = createWriter("log.txt");  
  port = new Serial(this, portName, 230400);

  frameRate(2000);
  lastMillis = millis();
}

void draw()
{
  long gap = millis() - lastMillis;
  if (gap > 500)
  {
    lastMillis = millis();
    timer = System.nanoTime();
    port.write(c);
  }
}

void keyPressed()
{
  long newTime = System.nanoTime();
  long RTT = newTime - timer;
  pressed = newTime;

  double micro = (double)RTT / 1000000;
  print((cnt++)+"\t"+micro);  
  output.print(micro);
}

void keyReleased()
{
  long RTT = System.nanoTime() - pressed;

  double micro = (double)RTT / 1000000;
  
  println("\t"+micro);
  output.println(","+micro);
  output.flush();
}