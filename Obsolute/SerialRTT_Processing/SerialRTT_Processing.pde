import processing.serial.*;

Serial port;  
char c = 'a';

long timer = 0;
PrintWriter output; 

void setup()
{
  // List all the available serial ports:
  printArray(Serial.list());
  // connect to the last port in the list;
  String portName = Serial.list()[Serial.list().length - 1];

  output = createWriter("log.txt");
  port = new Serial(this, portName, 115200);

  randomSeed(0);
  frameRate(10);
}

void draw()
{
  timer = System.nanoTime();
  port.write(c);
  port.buffer(1);
}


void serialEvent(Serial myPort) {
  char inByte = (char)myPort.read();

  if (inByte == c)
  {
    long newTime = System.nanoTime();
    long RTT = newTime - timer;

    double micro = (double)RTT / 1000000;
    println(micro);
    output.println(micro);
    output.flush();    
  }

  c++;
  if (c == 'z')
    c = 'a';
}