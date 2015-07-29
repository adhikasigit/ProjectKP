import controlP5.*;

ControlP5 cp5;

int LIMPbackground = color(30, 30, 30);
int volumeValue = 100;
int panningValue = 25;
int songLength = 100;

Knob volume;

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
               .setColorActive(color(70, 70, 70))
               .setDragDirection(Knob.VERTICAL)
               .setDecimalPrecision(0)
               ;
     
  cp5.addSlider("Panning")
     .setPosition(20,295)
     .setRange(-100,100)
     .setWidth(50) 
     .setValue(panningValue)
     .setNumberOfTickMarks(9)
     .showTickMarks(false) 
     .setColorForeground(color(50, 50, 50))
     .setColorBackground(color(245))
     .setColorActive(color(70, 70, 70))
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(0)
     ;
  cp5.getController("Panning").getValueLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(-20);
  cp5.getController("Panning").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(4);
     
  cp5.addSlider("Seek")
     .setPosition(35,250)
     .setRange(0,songLength)
     .setWidth(400) 
     .setHeight(5)
     .setColorForeground(color(50, 50, 50))
     .setColorBackground(color(245))
     .setColorActive(color(70, 70, 70))
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(0)
     .setHandleSize(20)
     ;
  cp5.getController("Seek").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(-15).setPaddingY(-8);
}

void draw() {
  background(LIMPbackground);
  
 
}






