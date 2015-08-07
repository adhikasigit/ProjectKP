

import javax.swing.*; 
import controlP5.*;

ControlP5 cp5;

PFrame f = null;
SecondApplet s;


int LIMPbackground = color(30, 30, 30);
int volumeValue = 100;
int panningValue = 25;
int songLength = 100;
int songId = 0;
boolean playId = false;
String namaFile = "lorem ipsum";

int progState = 0;
PShape handle, panL, panR, eq, menu2, hand, slider;
float diameter = 200;
float thickness = 30;
float step = 0.1;
float theta = 75;
color cHandle = 0xCC006699;
float menu2X = width/2, menu2Y= height/2;
float panWidth = 30, panPos = 45;
boolean overPanL, overPanR;
float tolerance = 10;
int startMs, currentMs;
float timeIn = 3000, timeOut = 3000;
float handX, handY;
float sliderPosX, sliderPosY;
float startPosX, startPosY;
//Status status;

Knob volume;
Slider panning, seek;
DropdownList equalizer;
Button play, next, prev, kinect, open;
Textlabel judul;
File file;

void setup() {
  size(480, 200);
  if (f==null) f = new PFrame(640, 480);
  frame.setTitle("LIMP");
  f.setTitle("Kinect");

  
  cp5 = new ControlP5(this);


  judul = cp5.addTextlabel("Judul")
                    .setText(namaFile)
                    .setPosition(20,40)
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",20))
                    ;

  volume = cp5.addKnob("Volume")
    .setRange(0, 100)
      .setValue(volumeValue)
        .setPosition(400, 130)
          .setRadius(20)
            .setColorValueLabel(0) 
              .setColorForeground(color(50, 50, 50))
                .setColorBackground(color(245))
                  .setColorActive(color(90, 90, 90))
                    .setDragDirection(Knob.VERTICAL)
                      .setDecimalPrecision(0)
                        ;

  panning = cp5.addSlider("Panning")
    .setPosition(20, 150)
      .setRange(-100, 100)
        .setWidth(50) 
          .setValue(panningValue)
            .setNumberOfTickMarks(9)
              .showTickMarks(false) 
                .setColorForeground(color(50, 50, 50))
                  .setColorBackground(color(245))
                    .setColorActive(color(90, 90, 90))
                      .setSliderMode(Slider.FLEXIBLE)
                        .setDecimalPrecision(0)
                          ;
  cp5.getController("Panning").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(23).setPaddingY(-20);
  cp5.getController("Panning").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(4);

  seek = cp5.addSlider("Seek")
    .setPosition(35, 110)
      .setRange(0, songLength)
        .setWidth(400) 
          .setHeight(5)
            .setColorForeground(color(50, 50, 50))
              .setColorBackground(color(245))
                .setColorActive(color(90, 90, 90))
                  .setSliderMode(Slider.FLEXIBLE)
                    .setDecimalPrecision(0)
                      .setHandleSize(20)
                        ;
  cp5.getController("Seek").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(-15).setPaddingY(-8);

  PImage[] playImg = {
    loadImage("play1.png"), loadImage("play2.png"), loadImage("play3.png"), loadImage("pause2.png")
  };
  play = cp5.addButton("Play")
    .setPosition(195, 125)
      .setSize(20, 20)
        .setImages(playImg)
          .updateSize()
            .setSwitch(true)
              ;

  PImage[] nextImg = {
    loadImage("next1.png"), loadImage("next2.png"), loadImage("next3.png")
  };
  next = cp5.addButton("Next")
    .setPosition(265, 131)
      .setSize(20, 20)
        .setImages(nextImg)
          .updateSize()
            ;

  PImage[] prevImg = {
    loadImage("prev1.png"), loadImage("prev2.png"), loadImage("prev3.png")
  };
  prev = cp5.addButton("Prev")
    .setPosition(135, 131)
      .setSize(20, 20)
        .setImages(prevImg)
          .updateSize()
            ;

  equalizer = cp5.addDropdownList("Equalizer")
    .setPosition(400, 20)
      ;
  customize(equalizer); 
  //equalizer.setIndex(0);

  kinect = cp5.addButton("Kinect")
    .setPosition(350, 20)
      .setSize(40, 20)
        .setColorBackground(color(50, 50, 50))
          .setColorActive(color(90, 90, 90))
            .setColorForeground(color(90, 90, 90))
              .update()
                .setSwitch(true)
                  ;

  open = cp5.addButton("Open")
    .setPosition(300, 20)
      .setSize(40, 20)
        .setColorBackground(color(50, 50, 50))
          .setColorActive(color(90, 90, 90))
            .setColorForeground(color(90, 90, 90))
              .update()
                .setSwitch(true)
                  ;
}

void customize(DropdownList eq) {
  // a convenience function to customize a DropdownList
  eq.setBackgroundColor(color(255));
  eq.setItemHeight(15);
  eq.setWidth(60);
  eq.setBarHeight(20);
  eq.setColorBackground(color(50, 50, 50));
  eq.setColorActive(color(90, 90, 90));
  eq.setColorForeground(color(90, 90, 90));
  eq.addItem("Pop", 0);
  eq.addItem("Rock", 1);
  eq.addItem("Jazz", 2);
}

void draw() {
  background(LIMPbackground);

  if (play.isPressed()) {
    if (playId) {
      
      playId = true;
    } else {
      
      playId = false;
    }
    delay(100);
  }
  if (next.isPressed()) {
    
    songId+=1;
    delay(100);
  } 

  if (prev.isPressed()) {
    
    songId-=1;
    delay(100);
  }

  if (kinect.isOn()) f.show();
  if (!kinect.isOn()) f.hide();

  if (open.isOn()) {
    selectInput("Select a file to process:", "fileSelected", file);
    open.setOff();
  }

  println(equalizer.getValue());
  println(songId);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
  }
}

public class PFrame extends JFrame {
  public PFrame(int width, int height) {
    setBounds(100, 100, width, height);
    s = new SecondApplet();
    add(s);
    s.init();
  }
}
public class SecondApplet extends PApplet {
  public void setup() {
    size(640, 480, P2D);
    menu2X = width/2;
    menu2Y = height/2;
    setupHandle();  
    setupPanR();
    setupPanL();
    setupMenu2();
    setupSlider();
    background(100);
    //hand = loadShape("hand.svg");
  }

  public void draw() {
    if (overPanL)
      background(0);
    else if (overPanR)
      background(255);
    else 
      background(122);
    shape(menu2, menu2X, menu2Y);
    update();
    //shape(handle, width/2, height/2);
    //shape(panL, width/2, height/2);
    //shape(panR, width/2, height/2);
    //shape(hand,width/2,height/2);
  }
  public void setupHandle() {
    float xpos = 0;
    float ypos = 0;
    float point1 = xpos - (diameter/2)*sin(radians(theta));
    float point2 = xpos + (diameter/2)*sin(radians(theta));
    float point3 = xpos + (diameter/2 - thickness)*sin(radians(theta));
    float point4 = xpos - (diameter/2 - thickness)*sin(radians(theta));
    fill(100, 100, 0, 100);
    handle = createShape();
    handle.beginShape();
    // Calculate the handle as a sine wave
    for (float a = point1; a < point2; a += step) {
      handle.vertex(a, sqrt(sq(diameter/2)-sq(a-xpos)) + ypos);
    }
    for (float a = point3; a > point4; a -= step) {
      handle.vertex(a, sqrt(sq(diameter/2 - thickness)-sq(a-xpos)) + ypos);
    }
    handle.vertex(point1, sqrt(sq(diameter/2)-sq(point1-xpos)) + ypos);
    handle.endShape();
    //handle.rotate(radians(180));
  }

  public void setupPanR() {
    float xpos = 0;
    float ypos = 0;
    float point1 = xpos - (diameter/2)*sin(radians(panPos + panWidth/2));
    float point2 = xpos - (diameter/2)*sin(radians(panPos - panWidth/2));
    float point3 = xpos - (diameter/2 - thickness)*sin(radians(panPos - panWidth/2));
    float point4 = xpos - (diameter/2 - thickness)*sin(radians(panPos + panWidth/2));
    fill(100, 200, 0, 50);
    panR = createShape();
    panR.beginShape();
    // Calculate the handle as a sine wave
    for (float a = point1; a < point2; a += step) {
      panR.vertex(a, sqrt(sq(diameter/2)-sq(a-xpos)) + ypos);
    }
    for (float a = point3; a > point4; a -= step) {
      panR.vertex(a, sqrt(sq(diameter/2 - thickness)-sq(a-xpos)) + ypos);
    }
    panR.vertex(point1, sqrt(sq(diameter/2)-sq(point1-xpos)) + ypos);
    panR.endShape();
    //panR.rotate(radians(180));
  }

  public void setupPanL() {
    float xpos = 0;
    float ypos = 0;
    float point1 = xpos + (diameter/2)*sin(radians(panPos + panWidth/2));
    float point2 = xpos + (diameter/2)*sin(radians(panPos - panWidth/2));
    float point3 = xpos + (diameter/2 - thickness)*sin(radians(panPos - panWidth/2));
    float point4 = xpos + (diameter/2 - thickness)*sin(radians(panPos + panWidth/2));
    fill(100, 200, 0, 50);
    panL = createShape();
    panL.beginShape();
    // Calculate the handle as a sine wave
    for (float a = point1; a > point2; a -= step) {
      panL.vertex(a, sqrt(sq(diameter/2)-sq(a-xpos)) + ypos);
    }
    for (float a = point3; a < point4; a += step) {
      panL.vertex(a, sqrt(sq(diameter/2 - thickness)-sq(a-xpos)) + ypos);
    }
    panL.vertex(point1, sqrt(sq(diameter/2)-sq(point1-xpos)) + ypos);
    panL.endShape();
    // panL.rotate(radians(180));
  }

  public void setupSlider() {
  }

  public void setupMenu2() {
    menu2 = createShape(GROUP);
    menu2.addChild(panL);
    menu2.addChild(panR);
    menu2.addChild(handle);
    menu2.rotate(radians(180));
  }

  public void update() {
    overPanL = isInsidePanL(mouseX, mouseY, tolerance);
    overPanR = isInsidePanR(mouseX, mouseY, tolerance);
    checkState();
    print("current State = ");
    println(progState);
  }

  public boolean isInsidePanL(float x, float y, float rad) {
    float phi = radians(panPos);
    float r = (diameter/2) - (thickness/2);
    float a = menu2X - r*sin(phi);
    float b = menu2Y - r*cos(phi);
    if (sq(a-x)+sq(b-y) <= sq(rad+(thickness/2)))
      return true;
    return false;
    /*
    float D = (sq(x-a)+sq(y-b));
     if (D < sq(thickness/2))
     return true;
     return false;
     */
  }

  public boolean isInsidePanR(float x, float y, float rad) {
    float phi = radians(panPos);
    float r = (diameter/2) - (thickness/2);
    float a = menu2X + r*sin(phi);
    float b = menu2Y - r*cos(phi);
    if (sq(a-x)+sq(b-y) <= sq(rad+(thickness/2)))
      return true;
    return false;
    /*
    float D = (sq(x-a)+sq(y-b));
     if (D < sq(thickness/2))
     return true;
     return false;
     */
  }

  public void checkState() {
    if (progState == 0)
    {
      if (overPanR | overPanL)
      {
        progState = 1;
        startMs = millis();
      }
    } else if (progState == 1)
    {
      if (overPanL | overPanR)
      {
        if (millis() - startMs > timeIn)
        {
          progState = 2;
          startPosX = mouseX;
          startPosY = mouseY;
        }
      } else
      {
        progState = 0;
      }
    } else if (progState == 2)
    {
    }
  }

  public boolean still(float x, float y, float rad)
  {
    return true;
  }
}

