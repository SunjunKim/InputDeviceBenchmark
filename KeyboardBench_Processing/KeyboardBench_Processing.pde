import processing.serial.*;
import java.util.*;
import java.lang.reflect.Method;

Serial port;  
char c = 'r';

PrintWriter output; 

long pingTime, pongTime;

long pressed = 0;
int cnt = 0;

TimerTask SendTrigger;
Timer timer;

void setup()
{
  // List all the available serial ports:
  printArray(Serial.list());
  // connect to the last port in the list;
  String portName = Serial.list()[Serial.list().length - 1];

  output = createWriter("log.txt");  
  port = new Serial(this, portName, 115200);

  // set port to the loopback mode
  port.write('L');



  SendTrigger = new SendTrigger(this);
  timer = new Timer();
  timer.scheduleAtFixedRate(SendTrigger, 0, 300); // every 0.3 second

  noLoop();
}

void onTrigger()
{
  cnt++;

  if (cnt < 10)
    return;

  // flush evertying in the serial buffer
  while (port.available() > 0)
    port.readChar();

  // ping!
  port.write(c);
  pingTime = System.nanoTime();
}

void serialEvent(Serial somePort) {
  char response = port.readChar();
  if (response == 'r')
  {
    pongTime = System.nanoTime();
  }
}

void stop() {
  timer.cancel();
  output.flush();
  output.close();
  super.stop();
}

void exit() {
  timer.cancel();
  output.flush();
  output.close();
  super.exit();
}

void draw()
{
  background(0);
  text("Measured "+(cnt-10), 10, 30);
}

void mousePressed()
{
  processPress();
}

void keyPressed()
{
  processPress();
}

void processPress()
{
  long newTime = System.nanoTime();

  long RTT = newTime - pingTime;
  long RTT_serial = pongTime - pingTime;
  pressed = newTime;


  double micro = (double)RTT / 1000000;  
  double micro_serial = (double)RTT_serial / 1000000;

  //println(cnt);
  //println(key+"\tP\t"+micro);  
  if (cnt > 10)
  {
    output.print(micro_serial+","+micro);
  }
}

void keyReleased()
{
  processRelease();
}

void mouseReleased()
{
  processRelease();
}

void processRelease()
{
  long newTime = System.nanoTime();

  long RTT = newTime - pingTime;
  long duration = newTime - pressed;

  double microRTT = (double)RTT / 1000000;
  double microDur = (double)duration / 1000000;

  //println(key+"\tR\t"+microRTT+"\t"+microDur);
  if (cnt > 10)
  {
    output.println(","+microRTT+","+microDur);
    output.flush();
  }

  redraw();
}


// Invoke onTrigger() meaathod
class SendTrigger extends TimerTask {
  PApplet parent;
  private static final String ON_TRIGGER_EVENT = "onTrigger";
  private Method onTriggerEvent;
  boolean Debug = false;

  public SendTrigger(PApplet parent)
  {
    this.parent = parent;

    try {
      onTriggerEvent = parent.getClass().getMethod(ON_TRIGGER_EVENT);
    } 
    catch (NoSuchMethodException e) {
      e.printStackTrace();
    }
  }

  private void invokeMethod(Method method, Object... args) {
    if (method != null) {
      try {
        method.invoke(parent, args);
      } 
      catch (Exception e) {
        if (Debug) {
          System.err.println("failed to call method " + method.toString() + " inside main app");
          e.printStackTrace();
        }
      }
    }
  }

  @Override
    public void run() {
    invokeMethod(onTriggerEvent);
  }
}