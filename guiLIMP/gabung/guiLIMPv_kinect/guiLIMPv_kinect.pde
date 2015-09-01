import oscP5.*;
import netP5.*;
import javax.swing.*; 
import controlP5.*;

import SimpleOpenNI.*;
import java.util.Map;
import java.util.Iterator;

ControlP5 cp5;

PFrame f = null;
SecondApplet s;

OscP5 oscP5;

NetAddress port1;
NetAddress port2;
NetAddress port3;
NetAddress port4;


int LIMPbackground = color(30, 30, 30);
float volumeValue = 0.500;
int panningValue = 25;
int songLength = 100;
int songId = 0;
boolean playId = false;
boolean start = false;
String namaFile = "lorem ipsum";

Knob volume;
Slider panning, seek;
DropdownList equalizer;
Button play, next, prev, kinect;
Textlabel judul;


void setup() {
  size(480, 200);
  if (f==null) f = new PFrame(640, 480);
  frame.setTitle("LIMP");
  f.setTitle("Kinect");

  oscP5 = new OscP5(this,12000);
  
  port1 = new NetAddress("127.0.0.1",12002);
  port2 = new NetAddress("127.0.0.1",12003);
  port3 = new NetAddress("127.0.0.1",12004);
  port4 = new NetAddress("127.0.0.1",12005);
  
  
  oscP5.plug(this,"test","/test");
  
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
    if(!start){
        start = true;
        playId = true;
        //OscMessage myOscMessage4 = new OscMessage("/playlist");
        //oscP5.send(myOscMessage4, port4);
        OscMessage myOscMessage3 = new OscMessage("/volume");
        myOscMessage3.add((float)0.500);
        oscP5.send(myOscMessage3, port3);
        OscMessage myOscMessage2 = new OscMessage("/songid");
        myOscMessage2.add((int)songId);
        oscP5.send(myOscMessage2, port2);
        OscMessage myOscMessage1 = new OscMessage("/limp/play");
        oscP5.send(myOscMessage1, port1);
        OscMessage myOscMessage = new OscMessage("/limp/start");
        oscP5.send(myOscMessage, port1);
    }
    else{
      if (playId) {
        OscMessage myOscMessage = new OscMessage("/limp/play");
        oscP5.send(myOscMessage, port1);
        playId = true;
      } else {
        OscMessage myOscMessage = new OscMessage("/limp/pause");
        oscP5.send(myOscMessage, port1);
        playId = false;
      }
    }
    delay(500);
  }
  if (next.isPressed()) {
    songId+=1;
    OscMessage myOscMessage = new OscMessage("/songid");
    myOscMessage.add((int)songId);
    oscP5.send(myOscMessage,port2);
    OscMessage myOscMessage1 = new OscMessage("/limp/start");
    oscP5.send(myOscMessage1, port1);
    delay(500);
  } 

  if (prev.isPressed()) {
    songId-=1;
    OscMessage myOscMessage = new OscMessage("/songid");
    myOscMessage.add((int)songId);
    oscP5.send(myOscMessage, port2);
     OscMessage myOscMessage1 = new OscMessage("/limp/start");
    oscP5.send(myOscMessage1, port1);
    delay(500);
  }

  if (kinect.isOn()) f.show();
  if (!kinect.isOn()) f.hide();

  println(equalizer.getValue());
  println(songId);
}



