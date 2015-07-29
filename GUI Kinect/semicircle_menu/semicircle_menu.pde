PShape handle, panL, panR, eq, menu2, hand;
float diameter = 200;
float thickness = 30;
float step = 0.1;
float theta = 75;
color cHandle = 0xCC006699;
float menu2X = width/2, menu2Y= height/2;
float panWidth = 30;
float panTheta = theta - panWidth;
boolean overPanL, overPanR;
void setup()
{
  size(640, 480, P2D);
  menu2X = width/2;
  menu2Y = height/2;
  setupHandle();  
  setupPanR();
  setupPanL();
  setupMenu2();
  background(100);
  //hand = loadShape("hand.svg");
}
void draw()
{
  if(overPanL)
   background(0);
  if(overPanR)
   background(255);
  shape(menu2, menu2X, menu2Y);
  update();
  //shape(handle, width/2, height/2);
  //shape(panL, width/2, height/2);
  //shape(panR, width/2, height/2);
  //shape(hand,width/2,height/2);
}

void setupHandle()
{
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

void setupPanR()
{

  float xpos = 0;
  float ypos = 0;
  float point1 = xpos - (diameter/2)*sin(radians(theta));
  float point2 = xpos - (diameter/2)*sin(radians(panTheta));
  float point3 = xpos - (diameter/2 - thickness)*sin(radians(panTheta));
  float point4 = xpos - (diameter/2 - thickness)*sin(radians(theta));
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

void setupPanL()
{

  float xpos = 0;
  float ypos = 0;
  float point1 = xpos + (diameter/2)*sin(radians(theta));
  float point2 = xpos + (diameter/2)*sin(radians(panTheta));
  float point3 = xpos + (diameter/2 - thickness)*sin(radians(panTheta));
  float point4 = xpos + (diameter/2 - thickness)*sin(radians(theta));
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
  overPanL = isInsidePanL();
  overPanR = isInsidePanR();
}

boolean isInsidePanL()
{
  float phi = radians(theta - panWidth/2);
  float r = (diameter/2) - (thickness/2);
  float a = menu2X - r*sin(phi);
  float b = menu2Y - r*cos(phi);
  float D = sqrt(sq(mouseX-a)+sq(mouseY-b));
  if(D < (thickness/2))
    return true;
  return false;
}

boolean isInsidePanR()
{
  float phi = radians(theta - panWidth/2);
  float r = (diameter/2) - (thickness/2);
  float a = menu2X + r*sin(phi);
  float b = menu2Y - r*cos(phi);
  float D = sqrt(sq(mouseX-a)+sq(mouseY-b));
  print(a);
  print(" ");
  print(b);
  print(" ");
  print(D);
  print(" ");
  print(thickness/2);
  print(" ");
  print(mouseX);
  print(" ");
  println(mouseY);
  
  if(D < (thickness/2))
    return true;
  return false;
}

