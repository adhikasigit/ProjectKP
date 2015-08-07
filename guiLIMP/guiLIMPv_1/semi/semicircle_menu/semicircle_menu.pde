static final float step = 0.1;
static final float tolerance = 10;
static final float timeIn = 2000, timeOut = 2000;
static final int PAN_DIVISION = 4;

PShape handle2, panL, panR, menu2, hand, slider2, menu1, prev, next, volume;
boolean overPanL, overPanR;
int progState = 0;
int startMs, currentMs;
int panRightAlpha = 122, slider2Alpha = 255, panLeftAlpha = 122, handle2Alpha = 255, menu2Alpha = 255, menu1Alpha = 255, prevAlpha = 255, nextAlpha = 255, volumeAlpha = 255;
float diameterMenu2 = 200;
float thicknessMenu2 = 30;
float thetaMenu2 = 75;
float menu2X, menu2Y;
float menu2Angle;
float panWidth = 30, panPos = 45;
float handX, handY;
float slider2PosX, slider2PosY;
float slider2StartPosX, slider2StartPosY;
float slider2Angle, slider2Width = panWidth;


void setup()
{
  size(640, 480, P2D);
  menu2X = width/2;
  menu2Y = height/2;
  setupHandleMenu2();  
  setupPanR();
  setupPanL();
  setupMenu2();
  setupSlider();
  slider2.scale(0);
  background(100);
}
void draw()
{
  shape(menu2, menu2X, menu2Y);
  update();
}

void setupHandleMenu2()
{
  float point1 = -(diameterMenu2/2)*sin(radians(thetaMenu2));
  float point2 = (diameterMenu2/2)*sin(radians(thetaMenu2));
  float point3 = (diameterMenu2/2 - thicknessMenu2)*sin(radians(thetaMenu2));
  float point4 = -(diameterMenu2/2 - thicknessMenu2)*sin(radians(thetaMenu2));
  fill(100, 100, 0, handle2Alpha * menu2Alpha / 255);
  handle2 = createShape();
  handle2.beginShape();
  // Calculate the handle2 as a sine wave
  for (float a = point1; a < point2; a += step) {
    handle2.vertex(a, sqrt(sq(diameterMenu2/2)-sq(a)));
  }
  for (float a = point3; a > point4; a -= step) {
    handle2.vertex(a, sqrt(sq(diameterMenu2/2 - thicknessMenu2)-sq(a)));
  }
  handle2.vertex(point1, sqrt(sq(diameterMenu2/2)-sq(point1)));
  handle2.endShape();
  //handle2.rotate(radians(180));
}

void setupPanR()
{
  float point1 = -(diameterMenu2/2)*sin(radians(panPos + panWidth/2));
  float point2 = -(diameterMenu2/2)*sin(radians(panPos - panWidth/2));
  float point3 = -(diameterMenu2/2 - thicknessMenu2)*sin(radians(panPos - panWidth/2));
  float point4 = -(diameterMenu2/2 - thicknessMenu2)*sin(radians(panPos + panWidth/2));
  fill(100, 200, 0, panRightAlpha * menu2Alpha / 255);
  panR = createShape();
  panR.beginShape();
  // Calculate the handle2 as a sine wave
  for (float a = point1; a < point2; a += step) {
    panR.vertex(a, sqrt(sq(diameterMenu2/2)-sq(a)));
  }
  for (float a = point3; a > point4; a -= step) {
    panR.vertex(a, sqrt(sq(diameterMenu2/2 - thicknessMenu2)-sq(a)));
  }
  panR.vertex(point1, sqrt(sq(diameterMenu2/2)-sq(point1)));
  panR.endShape();
}

void setupPanL()
{

  float point1 = (diameterMenu2/2)*sin(radians(panPos + panWidth/2));
  float point2 = (diameterMenu2/2)*sin(radians(panPos - panWidth/2));
  float point3 = (diameterMenu2/2 - thicknessMenu2)*sin(radians(panPos - panWidth/2));
  float point4 = (diameterMenu2/2 - thicknessMenu2)*sin(radians(panPos + panWidth/2));
  fill(100, 200, 0, panLeftAlpha * menu2Alpha / 255);
  panL = createShape();
  panL.beginShape();
  // Calculate the handle2 as a sine wave
  for (float a = point1; a > point2; a -= step) {
    panL.vertex(a, sqrt(sq(diameterMenu2/2)-sq(a)));
  }
  for (float a = point3; a < point4; a += step) {
    panL.vertex(a, sqrt(sq(diameterMenu2/2 - thicknessMenu2)-sq(a)));
  }
  panL.vertex(point1, sqrt(sq(diameterMenu2/2)-sq(point1)));
  panL.endShape();
} 

void setupSlider()
{
  float point1 = (diameterMenu2/2)*sin(radians(0 + slider2Width/2));
  float point2 = (diameterMenu2/2)*sin(radians(0 - slider2Width/2));
  float point3 = (diameterMenu2/2 - thicknessMenu2)*sin(radians(0 - slider2Width/2));
  float point4 = (diameterMenu2/2 - thicknessMenu2)*sin(radians(0 + slider2Width/2));
  slider2Angle = 0;
  fill(200, 100, 10, slider2Alpha * menu2Alpha / 255);
  slider2 = createShape();
  slider2.beginShape();
  // Calculate the handle2 as a sine wave
  for (float a = point1; a > point2; a -= step) {
    slider2.vertex(a, sqrt(sq(diameterMenu2/2)-sq(a)));
  }
  for (float a = point3; a < point4; a += step) {
    slider2.vertex(a, sqrt(sq(diameterMenu2/2 - thicknessMenu2)-sq(a)));
  }
  slider2.vertex(point1, sqrt(sq(diameterMenu2/2)-sq(point1)));
  slider2.endShape();
  menu2.addChild(slider2);
}

void setupMenu2()
{
  menu2 = createShape(GROUP);
  menu2.addChild(handle2);
  menu2.addChild(panL);
  menu2.addChild(panR);
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
    slider2.scale(0);
  }
}

boolean isInsidePanL(float x, float y, float rad)
{
  float phi = radians(panPos);
  float r = (diameterMenu2/2) - (thicknessMenu2/2);
  float a = menu2X - r*sin(phi);
  float b = menu2Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu2/2)))
    return true;
  return false;
}

boolean isInsidePanR(float x, float y, float rad)
{
  float phi = radians(panPos);
  float r = (diameterMenu2/2) - (thicknessMenu2/2);
  float a = menu2X + r*sin(phi);
  float b = menu2Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu2/2)))
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
        slider2StartPosX = mouseX;
        slider2StartPosY = mouseY;
        slider2PosY = slider2StartPosY;
        slider2PosX = slider2StartPosX;
        setupSlider();
      }
      panL.setFill(color(100, 200, 0, 255));
      panR.setFill(color(100, 200, 0, 255));
    } else
    {
      panL.setFill(color(100, 200, 0, 122));
      panR.setFill(color(100, 200, 0, 122));
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
  float slider2ToAngle;
  if(meanY < menu2Y)
    slider2ToAngle = atan((meanX - menu2X) / (meanY - menu2Y));
  else
    slider2ToAngle = -atan((meanX - menu2X) / (meanY - menu2Y));
  float smoothness = 10;
  
  if ((slider2ToAngle < slider2Angle ) && (slider2Angle > (-radians(thetaMenu2 - slider2Width/2))) )
  {
    slider2.rotate(-(slider2ToAngle - slider2Angle)/smoothness);
    slider2Angle += (slider2ToAngle - slider2Angle)/smoothness;
  } else if ((slider2ToAngle > slider2Angle) && (slider2Angle < (radians(thetaMenu2 - slider2Width/2))))
  {
    slider2.rotate((-slider2ToAngle + slider2Angle)/smoothness);
    slider2Angle -= (-slider2ToAngle + slider2Angle)/smoothness;
  }
  print(radians(thetaMenu2-slider2Width/2));
  print(" ");
  print(degrees(slider2Angle));
  print(" ");
  println(degrees(slider2ToAngle));
  sendPanMessage();
}

void sendPanMessage()
{
   int panning = (int)(degrees(slider2Angle)/(thetaMenu2-slider2Width/2)*PAN_DIVISION); 
   println(panning);
}
