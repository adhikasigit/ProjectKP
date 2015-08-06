static final float step = 0.1;
static final float tolerance = 10;
static final float timeIn = 2000, timeOut = 2000;
static final int PAN_DIVISION = 4;

PShape handle, panL, panR, eq, menu2, hand, slider;
boolean overPanL, overPanR;
int progState = 0;
int startMs, currentMs;
float diameter = 200;
float thickness = 30;
float theta = 75;
float menu2X = width/2, menu2Y= height/2;
float menu2Angle;
float panWidth = 30, panPos = 45;
float handX, handY;
float sliderPosX, sliderPosY;
float sliderStartPosX, sliderStartPosY;
float sliderAngle, sliderWidth = panWidth;
void setup()
{
  size(640, 480, P2D);
  menu2X = width/2;
  menu2Y = height/2;
  setupHandle();  
  setupPanR();
  setupPanL();
  setupMenu2();
  setupSlider();
  slider.scale(0);
  background(100);
}
void draw()
{
  shape(menu2, menu2X, menu2Y);
  update();
}

void setupHandle()
{
  float point1 = (diameter/2)*sin(radians(theta));
  float point2 = (diameter/2)*sin(radians(theta));
  float point3 = (diameter/2 - thickness)*sin(radians(theta));
  float point4 = (diameter/2 - thickness)*sin(radians(theta));
  fill(100, 100, 0, 100);
  handle = createShape();
  handle.beginShape();
  // Calculate the handle as a sine wave
  for (float a = point1; a < point2; a += step) {
    handle.vertex(a, sqrt(sq(diameter/2)-sq(a)));
  }
  for (float a = point3; a > point4; a -= step) {
    handle.vertex(a, sqrt(sq(diameter/2 - thickness)-sq(a)));
  }
  handle.vertex(point1, sqrt(sq(diameter/2)-sq(point1)));
  handle.endShape();
  //handle.rotate(radians(180));
}

void setupPanR()
{
  float point1 = (diameter/2)*sin(radians(panPos + panWidth/2));
  float point2 = (diameter/2)*sin(radians(panPos - panWidth/2));
  float point3 = (diameter/2 - thickness)*sin(radians(panPos - panWidth/2));
  float point4 = (diameter/2 - thickness)*sin(radians(panPos + panWidth/2));
  fill(100, 200, 0, 50);
  panR = createShape();
  panR.beginShape();
  // Calculate the handle as a sine wave
  for (float a = point1; a < point2; a += step) {
    panR.vertex(a, sqrt(sq(diameter/2)-sq(a)));
  }
  for (float a = point3; a > point4; a -= step) {
    panR.vertex(a, sqrt(sq(diameter/2 - thickness)-sq(a)));
  }
  panR.vertex(point1, sqrt(sq(diameter/2)-sq(point1)));
  panR.endShape();
}

void setupPanL()
{

  float point1 = (diameter/2)*sin(radians(panPos + panWidth/2));
  float point2 = (diameter/2)*sin(radians(panPos - panWidth/2));
  float point3 = (diameter/2 - thickness)*sin(radians(panPos - panWidth/2));
  float point4 = (diameter/2 - thickness)*sin(radians(panPos + panWidth/2));
  fill(100, 200, 0, 50);
  panL = createShape();
  panL.beginShape();
  // Calculate the handle as a sine wave
  for (float a = point1; a > point2; a -= step) {
    panL.vertex(a, sqrt(sq(diameter/2)-sq(a)));
  }
  for (float a = point3; a < point4; a += step) {
    panL.vertex(a, sqrt(sq(diameter/2 - thickness)-sq(a)));
  }
  panL.vertex(point1, sqrt(sq(diameter/2)-sq(point1)));
  panL.endShape();
} 

void setupSlider()
{
  float point1 = (diameter/2)*sin(radians(0 + sliderWidth/2));
  float point2 = (diameter/2)*sin(radians(0 - sliderWidth/2));
  float point3 = (diameter/2 - thickness)*sin(radians(0 - sliderWidth/2));
  float point4 = (diameter/2 - thickness)*sin(radians(0 + sliderWidth/2));
  fill(200, 100, 10, 50);
  slider = createShape();
  slider.beginShape();
  // Calculate the handle as a sine wave
  for (float a = point1; a > point2; a -= step) {
    slider.vertex(a, sqrt(sq(diameter/2)-sq(a-)));
  }
  for (float a = point3; a < point4; a += step) {
    slider.vertex(a, sqrt(sq(diameter/2 - thickness)-sq(a)));
  }
  slider.vertex(point1, sqrt(sq(diameter/2)-sq(point1)));
  slider.endShape();
  menu2.addChild(slider);
}

void setupMenu2()
{
  menu2 = createShape(GROUP);
  menu2.addChild(panL);
  menu2.addChild(panR);
  menu2.addChild(handle);
  menu2.rotate(radians(180));
}

void update()
{
  if (progState != 2)
  {
    overPanL = isInsidePanL(mouseX, mouseY, tolerance);
    overPanR = isInsidePanR(mouseX, mouseY, tolerance);
  }
  checkState();
  if (progState == 2)
  {
    panL.scale(0);
    panR.scale(0);
  } else
  {
    slider.scale(0);
  }
}

boolean isInsidePanL(float x, float y, float rad)
{
  float phi = radians(panPos);
  float r = (diameter/2) - (thickness/2);
  float a = menu2X - r*sin(phi);
  float b = menu2Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thickness/2)))
    return true;
  return false;
}

boolean isInsidePanR(float x, float y, float rad)
{
  float phi = radians(panPos);
  float r = (diameter/2) - (thickness/2);
  float a = menu2X + r*sin(phi);
  float b = menu2Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thickness/2)))
    return true;
  return false;
}

void checkState()
{
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
        sliderStartPosX = mouseX;
        sliderStartPosY = mouseY;
        sliderPosY = sliderStartPosY;
        sliderPosX = sliderStartPosX;
        setupSlider();
      }
    } else
    {
      progState = 0;
    }
  } else if (progState == 2)
  {
    updateSliderPosition(mouseX, mouseY, mouseX, mouseY);
    if (mousePressed)
    {
      setupPanL();
      menu2.addChild(panL);
      setupPanR();
      menu2.addChild(panR);
      menu2.rotate(-menu2Angle);
      progState = 0;
    }
  }
}

boolean still(float x, float y, float rad)
{
  return true;
}

void updateSliderPosition(float x, float y, float x2, float y2)
{
  float meanX = (x + x2)/2;
  float meanY = (y + y2)/2;
  boolean lock = false;
  float acceptance = 0.01;
  float sliderToAngle;
  if(meanY < menu2Y)
    sliderToAngle = atan((meanX - menu2X) / (meanY - menu2Y));
  else
    sliderToAngle = -atan((meanX - menu2X) / (meanY - menu2Y));
  float smoothness = 10;
  
  if ((sliderToAngle < sliderAngle ) && (sliderAngle > (-radians(theta - sliderWidth/2))) )
  {
    slider.rotate(-(sliderToAngle - sliderAngle)/smoothness);
    sliderAngle += (sliderToAngle - sliderAngle)/smoothness;
  } else if ((sliderToAngle > sliderAngle) && (sliderAngle < (radians(theta - sliderWidth/2))))
  {
    slider.rotate((-sliderToAngle + sliderAngle)/smoothness);
    sliderAngle -= (-sliderToAngle + sliderAngle)/smoothness;
  }
  print(radians(theta-sliderWidth/2));
  print(" ");
  print(degrees(sliderAngle));
  print(" ");
  println(degrees(sliderToAngle));
  sendPanMessage();
}

void sendPanMessage()
{
   int panning = (int)(degrees(sliderAngle)/(theta-sliderWidth/2)*PAN_DIVISION); 
   println(panning);
}
