import controlP5.*;

ControlP5 cp5;

int LIMPbackground = color(30, 30, 30);
int volumeValue = 100;
int panningValue = 25;
int songLength = 100;
boolean playId = false;

Knob volume;
Slider panning, seek;
DropdownList equalizer;
Button play, next, prev;

void setup() {
  size(480, 360);
  
  
  cp5 = new ControlP5(this);
 
  
     
  volume = cp5.addKnob("Volume")
               .setRange(0,100)
               .setValue(volumeValue)
               .setPosition(400,280)
               .setRadius(20)
               .setColorValueLabel(0) 
               .setColorForeground(color(50, 50, 50))
               .setColorBackground(color(245))
               .setColorActive(color(90, 90, 90))
               .setDragDirection(Knob.VERTICAL)
               .setDecimalPrecision(0)
               ;
     
  panning = cp5.addSlider("Panning")
               .setPosition(20,300)
               .setRange(-100,100)
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
               .setPosition(35,250)
               .setRange(0,songLength)
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
  
  PImage[] playImg = {loadImage("play1.png"),loadImage("play2.png"),loadImage("play3.png"),loadImage("pause2.png")};
  play = cp5.addButton("Play")
               .setPosition(195,275)
               .setSize(20, 20)
               .setImages(playImg)
               .updateSize()
               .setSwitch(true)
               ;
     
  PImage[] nextImg = {loadImage("next1.png"),loadImage("next2.png"),loadImage("next3.png")};
  next = cp5.addButton("Next")
               .setPosition(265,281)
               .setSize(20, 20)
               .setImages(nextImg)
               .updateSize()
               ;
     
  PImage[] prevImg = {loadImage("prev1.png"),loadImage("prev2.png"),loadImage("prev3.png")};
  prev = cp5.addButton("Prev")
               .setPosition(135,281)
               .setSize(20, 20)
               .setImages(prevImg)
               .updateSize()
               ;
     
  equalizer = cp5.addDropdownList("Equalizer")
          .setPosition(420, 190)
          ;
  customize(equalizer); 
  equalizer.setIndex(0);
    
     
}

void customize(DropdownList eq) {
  // a convenience function to customize a DropdownList
  eq.setBackgroundColor(color(255));
  eq.setItemHeight(15);
  eq.setWidth(40);
  eq.setBarHeight(15);
  eq.captionLabel().set("Equalizer");
  eq.captionLabel().style().marginTop = 3;
  eq.captionLabel().style().marginLeft = 3;
  eq.valueLabel().style().marginTop = 3;
  eq.setColorBackground(color(50, 50, 50));
  eq.setColorActive(color(90, 90, 90));
  eq.setColorForeground(color(90, 90, 90));
  
  eq.addItem("Pop", 0);eq.addItem("Rock", 1);eq.addItem("Jazz", 2);
}

void draw() {
  background(LIMPbackground);
  
 if(play.isPressed()){
   
 }
 if(next.isPressed()){
   
 } 
 if(prev.isPressed()){
   
 }
 
 println(equalizer.getValue());
 
}





