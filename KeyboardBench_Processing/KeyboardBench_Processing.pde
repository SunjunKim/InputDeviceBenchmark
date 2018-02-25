import processing.serial.*;
import java.util.*;
import java.lang.reflect.Method;

// How many times to measure?
int numMeasures = 100;
// periodic event interval time (in ms)
int eventInterval = 250;
// initial delay before measurement start
int initialDelay = 10000;

Serial port;  
char c = 'r';

PrintWriter output; 

long pingTime, pongTime;

long pressed = 0;
int cnt = 0;

TimerTask SendTrigger;
Timer timer;

FloatList valRTT, valPress, valRelease, valDuration;
boolean isMeasuring = false;

PFont font;

void setup()
{
  // List all the available serial ports:
  printArray(Serial.list());
  // connect to the last port in the list;
  String portName = Serial.list()[Serial.list().length - 1];

  output = createWriter("log.txt");  
  port = new Serial(this, portName, 115200);
  port.clear();

  // set the scan mode 'L': loopback / 'T': test (with probe)
  port.write('T');

  size(1000, 500);
  font = loadFont(dataPath("Consolas-24.vlw"));
  textFont(font, 24);
}

void draw()
{
  textAlign(LEFT, BOTTOM);

  background(0);
  fill(255);
  if (!isMeasuring)
  {
    text("Press [s] to start the meausre", 10, 30);

    if (valRTT != null && valRTT.size() == numMeasures)
    {
      translate(100, 40);

      // draw graph lines

      textAlign(RIGHT, CENTER);
      textSize(18);

      // Duration graph frame
      for (int i=0; i<=50; i+=10)
      {
        noStroke();
        fill(255);
        text((i-20+50)+" ms", -10, 120 - i*2);

        noFill();
        stroke(80);
        line(0, 120 - i*2, 400, 120 - i*2);
      }
      strokeWeight(1);
      stroke(255);
      line(0, 120, 400, 120);

      text("Keystroke durations", 400, 135);

      // distribution graph frame
      for (int i=0; i<=120; i+=10)
      {
        noStroke();
        fill(255);
        text(i+" ms", -10, 400 - i*2);

        noFill();
        stroke(80);
        line(0, 400 - i*2, 400, 400 - i*2);
      }
      strokeWeight(1);
      stroke(255);
      line(0, 400, 400, 400);
      text("RTT(Red), Press (Green), Release (Blue)", 400, 415);


      textSize(24);

      // plot values as scatter plot
      for (int i=0; i<valRTT.size(); i++)
      {
        float RTT = valRTT.get(i);
        float press = valPress.get(i);
        float release = valRelease.get(i);
        float duration = valDuration.get(i);
        
        noStroke();
        fill(255, 0, 0);
        ellipse(i*4+2, 400-RTT*2-2, 4, 4);  

        fill(0, 255, 0);
        ellipse(i*4+2, 400-press*2-2, 4, 4);  

        fill(0, 0, 255);
        ellipse(i*4+2, 400-release*2-2, 4, 4);

        fill(255, 0, 255);
        ellipse(i*4+2, 120-(duration-30)*2-2, 4, 4);

      }

      // print statistics
      fill(255);
      noStroke();

      float RTT_avg = round4(average(valRTT));
      float RTT_std = round4(stdev(valRTT));
      float press_avg = round4(average(valPress));
      float press_std = round4(stdev(valPress));
      float release_avg = round4(average(valRelease));
      float release_std = round4(stdev(valRelease));
      float dur_avg = round4(average(valDuration));
      float dur_std = round4(stdev(valDuration));


      float pressLatency = round4(press_avg - 10 - RTT_avg/2);
      float durationErr = round4((release_avg - press_avg) - 50);

      translate(430, 0);

      textAlign(LEFT, TOP);
      int lineN = 0;

      text("Serial   = "+RTT_avg+" ms (SD="+RTT_std+")", 0, lineN++*30);
      text("Press    = "+press_avg+" ms (SD="+press_std+")", 0, lineN++*30);
      text("Release  = "+release_avg+" ms (SD="+release_std+")", 0, lineN++*30);
      text("Duration = "+dur_avg+" ms (SD="+dur_std+")", 0, lineN++*30);
      lineN++;
      text("Press latency  = "+pressLatency+" ms", 0, lineN++*30);
      text("Duration error = "+durationErr+" ms", 0, lineN++*30);

      noLoop();
    }
  } else
  {
    if (cnt-1 < 0)
    {
      text("Waiting for measurement start...", 10, 30);
    } else
    {
      text("Measure count: "+(cnt-1), 10, 30);
    }
    if (cnt-1 >= numMeasures)
    {
      stopMeasure();
    }
  }
}

//################################################### Measuring-related functions

void startMeasure()
{
  cnt = 0;
  noLoop();
  isMeasuring = true;
  valRTT = new FloatList(numMeasures);
  valPress = new FloatList(numMeasures);
  valRelease = new FloatList(numMeasures);
  valDuration = new FloatList(numMeasures);

  // periodic event generation
  timer = new Timer();  
  // registering onTrigger   function (TimerTask instance).
  SendTrigger = new SendTrigger(this);
  timer.scheduleAtFixedRate(SendTrigger, initialDelay, eventInterval);
}

void stopMeasure()
{
  isMeasuring = false;
  timer.cancel();

  println(valRTT.size());
  loop();
}

// onTrigger() is periodially called by the timer.
void onTrigger()
{
  // apply a random delay to prevent synchronizing to a device polling rate.
  delay((int)random(16));
  cnt++;

  // discard the first 1 events
  if (cnt < 1)
    return;

  // claer evertying in the serial buffer
  while (port.available() > 0)
    port.readChar();

  // ping!
  port.write(c);
  pingTime = System.nanoTime();
}

void serialEvent(Serial somePort) {
  // pong!
  char response = port.readChar();
  if (response == 'r')
  {
    pongTime = System.nanoTime();
  }
}

//################################################### 

void mousePressed()
{
  if (isMeasuring)
    processPress();
}

void keyPressed()
{
  if (isMeasuring)
    processPress();
  else if (key == 's' || key == 'S')
  {
    startMeasure();
  }
}

void keyReleased()
{
  if (isMeasuring)
    processRelease();
}

void mouseReleased()
{  
  if (isMeasuring)
    processRelease();
}

//###################################################
// button pressed
void processPress()
{
  long newTime = System.nanoTime();

  long RTT = pongTime - pingTime;
  long press = newTime - pingTime;
  pressed = newTime;

  float micro_rtt = (float)RTT / 1000000;
  float micro_press = (float)press / 1000000;  

  if (cnt > 1)
  {
    valRTT.append(micro_rtt);
    valPress.append(micro_press);

    output.print(micro_rtt+","+micro_press);
  }
}

// button released
void processRelease()
{
  long newTime = System.nanoTime();

  long release = newTime - pingTime;
  long duration = newTime - pressed;

  float micro_release = (float)release / 1000000;
  float micro_duration = (float)duration / 1000000;


  if (cnt > 1)
  {
    valRelease.append(micro_release);
    valDuration.append(micro_duration);
    output.println(","+micro_release+","+micro_duration);
    output.flush();
  }

  redraw();
}

//################################################### Close event handling (clean up the timer)

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

//################################################### Internal methods

float average(FloatList list)
{
  float avg = 0;
  for (int i=0; i<list.size(); i++)
  {
    avg += list.get(i);
  }
  return avg / list.size();
}

float stdev(FloatList list)
{
  float avg = average(list);
  float squares = 0;
  for (int i=0; i<list.size(); i++)
  {
    squares += sq(list.get(i) - avg);
  }

  return sqrt(squares / (list.size()-1));
}

float round4(float value)
{
  return round(value*10000)/10000.0;
}



// Invoke onTrigger() meaathod (periodic evenet generator)
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