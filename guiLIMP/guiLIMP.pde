import controlP5.*;

ControlP5 cp5;

int Volume = 100;
int panning = 100;
//Time Song;

int play_X, play_Y;      
int prev_X, prev_Y;  
int next_X, next_Y; 
int playSize = 70;     
int prevnextSize = 60;   
color playColor, prevnextColor, baseColor;
color playHighlight, prevnextHighlight;
boolean playOver = false;
boolean prevOver = false;
boolean nextOver = false;

void setup() {
  size(480, 360);
  
  playColor = color(77,255,0);
  playHighlight = color(172,255,137);
  prevnextColor = color(77,255,0);
  prevnextHighlight = color(172,255,137);
  baseColor = color(255);

  prev_X = 2*width/8+prevnextSize/2;
  prev_Y = 3*height/4;
  
  next_X = 5*width/8+prevnextSize/2+10;
  next_Y = 3*height/4;
  
  play_X = 4*width/8-prevnextSize/2;
  play_Y = 3*height/4-playSize/2-1;
  ellipseMode(CENTER);
  
  cp5 = new ControlP5(this);
 
  cp5.addSlider("Volume")
     .setPosition(380,265)
     .setRange(0,Volume)
     .setColorCaptionLabel(0) 
     .setWidth(50) 
     ;
     
  cp5.addSlider("Panning")
     .setPosition(20,265)
     .setRange(-Volume,Volume)
     .setWidth(50) 
     .setColorCaptionLabel(0)    
     .setNumberOfTickMarks(9)
     ;
     
  cp5.addSlider("Seek")
     .setPosition(20,205)
     .setRange(0.00,345)
     .setWidth(425) 
     .setHeight(5)
     .setColorCaptionLabel(0)    
     .setColorValueLabel(0) 
     ;
}

void draw() {
  update(mouseX, mouseY);
  background(baseColor);
  
  if (playOver) {
    fill(playHighlight);
  } else {
    fill(playColor);
  }
  stroke(255);
  rect(play_X, play_Y, playSize, playSize);
  
  if (prevOver) {
    fill(prevnextHighlight);
  } else {
    fill(prevnextColor);
  }
  stroke(255);
  ellipse(prev_X, prev_Y, prevnextSize, prevnextSize);
  
  if (nextOver) {
    fill(prevnextHighlight);
  } else {
    fill(prevnextColor);
  }
  stroke(255);
  ellipse(next_X, next_Y, prevnextSize, prevnextSize);
}

void update(int x, int y) {
  if ( overCircle(prev_X, prev_Y, prevnextSize) ) {  //prev
    prevOver = true;
  } else if ( overCircle(next_X, next_Y, prevnextSize) ) {  //next
    nextOver = true;
  } else if ( overRect(play_X, play_Y, playSize, playSize) ) {  //play
    playOver = true;
  } else {
    prevOver = nextOver = playOver = false;
  }
}

void mousePressed() {
  if (prevOver) {
    //prev
  }
  if (nextOver) {
    //next
  }
  if (playOver) {
    //play
  }
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

