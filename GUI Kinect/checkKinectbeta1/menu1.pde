boolean overPrev, overNext, overVolume;
float diameterMenu1 = 200;
float thicknessMenu1 = 30;
float thetaMenu1 = 75;
float menu1X, menu1Y;
float menu1Angle;
float nextWidth = 30, nextPos = 45;
float prevWidth = 30, prevPos = 45;
float volWidth = 60, volPos = 0;
float slider1PosX, slider1PosY;
float slider1StartPosX, slider1StartPosY;
float slider1Angle, slider1Width = 30;
float scaleTemp1 = 1;

int timer3, timerHold;


PVector leftHandPositionTemp = new PVector();
PVector rightHandPositionTemp = new PVector();

void setupHandleMenu1()
{
  float point1 = -(diameterMenu1/2)*sin(radians(thetaMenu1));
  float point2 = (diameterMenu1/2)*sin(radians(thetaMenu1));
  float point3 = (diameterMenu1/2 - thicknessMenu1)*sin(radians(thetaMenu1));
  float point4 = -(diameterMenu1/2 - thicknessMenu1)*sin(radians(thetaMenu1));
  fill(100, 100, 0, handle1Alpha * menu1Alpha / 255);
  handle1 = createShape();
  handle1.beginShape();
  // Calculate the handle1 as a sine wave
  for (float a = point1; a < point2; a += step) {
    handle1.vertex(a, sqrt(sq(diameterMenu1/2)-sq(a)));
  }
  for (float a = point3; a > point4; a -= step) {
    handle1.vertex(a, sqrt(sq(diameterMenu1/2 - thicknessMenu1)-sq(a)));
  }
  handle1.vertex(point1, sqrt(sq(diameterMenu1/2)-sq(point1)));
  handle1.endShape();
  //handle1.rotate(radians(180));
}

void setupNext()
{
  float point1 = -(diameterMenu1/2)*sin(radians(nextPos + nextWidth/2));
  float point2 = -(diameterMenu1/2)*sin(radians(nextPos - nextWidth/2));
  float point3 = -(diameterMenu1/2 - thicknessMenu1)*sin(radians(nextPos - nextWidth/2));
  float point4 = -(diameterMenu1/2 - thicknessMenu1)*sin(radians(nextPos + nextWidth/2));
  fill(100, 200, 0, nextAlpha * menu1Alpha / 255);
  next = createShape();
  next.beginShape();
  // Calculate the handle1 as a sine wave
  for (float a = point1; a < point2; a += step) {
    next.vertex(a, sqrt(sq(diameterMenu1/2)-sq(a)));
  }
  for (float a = point3; a > point4; a -= step) {
    next.vertex(a, sqrt(sq(diameterMenu1/2 - thicknessMenu1)-sq(a)));
  }
  next.vertex(point1, sqrt(sq(diameterMenu1/2)-sq(point1)));
  next.endShape();
}

void setupVol()
{
  float point1 = -(diameterMenu1/2)*sin(radians(volPos + volWidth/2));
  float point2 = -(diameterMenu1/2)*sin(radians(volPos - volWidth/2));
  float point3 = -(diameterMenu1/2 - thicknessMenu1)*sin(radians(volPos - volWidth/2));
  float point4 = -(diameterMenu1/2 - thicknessMenu1)*sin(radians(volPos + volWidth/2));
  fill(100, 200, 0, volAlpha * menu1Alpha / 255);
  vol = createShape();
  vol.beginShape();
  // Calculate the handle1 as a sine wave
  for (float a = point1; a < point2; a += step) {
    vol.vertex(a, sqrt(sq(diameterMenu1/2)-sq(a)));
  }
  for (float a = point3; a > point4; a -= step) {
    vol.vertex(a, sqrt(sq(diameterMenu1/2 - thicknessMenu1)-sq(a)));
  }
  vol.vertex(point1, sqrt(sq(diameterMenu1/2)-sq(point1)));
  vol.endShape();
}

void setupPrev()
{

  float point1 = (diameterMenu1/2)*sin(radians(prevPos + prevWidth/2));
  float point2 = (diameterMenu1/2)*sin(radians(prevPos - prevWidth/2));
  float point3 = (diameterMenu1/2 - thicknessMenu1)*sin(radians(prevPos - prevWidth/2));
  float point4 = (diameterMenu1/2 - thicknessMenu1)*sin(radians(prevPos + prevWidth/2));
  fill(100, 200, 0, prevAlpha * menu1Alpha / 255);
  prev = createShape();
  prev.beginShape();
  // Calculate the handle1 as a sine wave
  for (float a = point1; a > point2; a -= step) {
    prev.vertex(a, sqrt(sq(diameterMenu1/2)-sq(a)));
  }
  for (float a = point3; a < point4; a += step) {
    prev.vertex(a, sqrt(sq(diameterMenu1/2 - thicknessMenu1)-sq(a)));
  }
  prev.vertex(point1, sqrt(sq(diameterMenu1/2)-sq(point1)));
  prev.endShape();
} 

void setupSlider1()
{
  float point1 = (diameterMenu1/2)*sin(radians(0 + slider1Width/2));
  float point2 = (diameterMenu1/2)*sin(radians(0 - slider1Width/2));
  float point3 = (diameterMenu1/2 - thicknessMenu1)*sin(radians(0 - slider1Width/2));
  float point4 = (diameterMenu1/2 - thicknessMenu1)*sin(radians(0 + slider1Width/2));
  slider1Angle = 0;
  fill(200, 100, 10, slider1Alpha * menu1Alpha / 255);
  slider1 = createShape();
  slider1.beginShape();
  // Calculate the handle1 as a sine wave
  for (float a = point1; a > point2; a -= step) {
    slider1.vertex(a, sqrt(sq(diameterMenu1/2)-sq(a)));
  }
  for (float a = point3; a < point4; a += step) {
    slider1.vertex(a, sqrt(sq(diameterMenu1/2 - thicknessMenu1)-sq(a)));
  }
  slider1.vertex(point1, sqrt(sq(diameterMenu1/2)-sq(point1)));
  slider1.endShape();
  menu1.addChild(slider1);
}

void setupMenu1(float x, float y, float s)
{
  strokeWeight(0);
  setupHandleMenu1();
  setupNext();
  setupPrev();
  setupVol();
  menu1 = createShape(GROUP);
  menu1.addChild(handle1);
  menu1.addChild(prev);
  menu1.addChild(next);
  menu1.addChild(vol);
  menu1.rotate(radians(180));
  menu1X = x;
  menu1Y = y; 
  setupSlider1();
  slider1.scale(0);
  menu1.scale(s);
  leftHandPositionTemp = torsoPos2d;
  rightHandPositionTemp = torsoPos2d;
}

void updateMenu1(float x, float y, float z)
{
  strokeWeight(0);
  shape(menu1, x, y);
  //println("kedraw kok");
  menu1.scale(Z_DEFAULT/(z*scaleTemp1)) ;
  scaleTemp1 = Z_DEFAULT / z;
  println("Scale: " + scaleTemp1);
  menu1X = x;
  menu1Y = y;
  //println("Program State : " + progState);
  if (progState != 4)
  {
    if (tangan == KIRI) {
      overVolume = isInsideVol(leftHandPos2d.x, leftHandPos2d.y, tolerance);
      overPrev = isInsidePrev (leftHandPos2d.x, leftHandPos2d.y, tolerance);
      overNext = isInsideNext (leftHandPos2d.x, leftHandPos2d.y, tolerance);
    } else if (tangan == KANAN) {
      overVolume = isInsideVol(rightHandPos2d.x, rightHandPos2d.y, tolerance);
      overPrev = isInsidePrev (rightHandPos2d.x, rightHandPos2d.y, tolerance);
      overNext = isInsideNext (rightHandPos2d.x, rightHandPos2d.y, tolerance);
    }
  }
  checkStateMenu1();
  if (progState == 4)
  {
    prev.scale(0);
    next.scale(0);
    vol.scale(0);
  } else
  {
    slider1.scale(0);
  }
}

boolean isInsidePrev(float x, float y, float rad)
{
  float phi = radians(prevPos);
  float r = (diameterMenu1/2) - (thicknessMenu1/2);
  float a = menu1X - r*sin(phi);
  float b = menu1Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu1/2)))
    return true;
  return false;
}

boolean isInsideNext(float x, float y, float rad)
{
  float phi = radians(nextPos);
  float r = (diameterMenu1/2) - (thicknessMenu1/2);
  float a = menu1X + r*sin(phi);
  float b = menu1Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu1/2)))
    return true;
  return false;
}

boolean isInsideVol(float x, float y, float rad)
{
  float phi = radians(volPos);
  float r = (diameterMenu1/2) - (thicknessMenu1/2);
  float a = menu1X + r*sin(phi);
  float b = menu1Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu1/2)))
    return true;
  return false;
}

void checkStateMenu1()
{
  if (progState == 0)
  {
    if (overNext)
    {
      progState = 1;
      startMs = millis();
    } else if (overPrev)
    {
      progState = 2;
      startMs = millis();
    } else if (overVolume)
    {
      progState = 3;
      startMs = millis();
    }
  } else if (progState == 1)
  {
    if (overNext)
    {
      if (millis() - startMs > timeIn)
      {
        println("NEXT");
        progState = 0;
        sendNextMessage();
      }
      next.setFill(color(100, 200, 0, 255));
    } else
    {
      next.setFill(color(100, 200, 0, 122));
      progState = 0;
    }
  } else if (progState == 2)
  {
    if (overPrev)
    {
      if (millis() - startMs > timeIn)
      {
        println("PREV");
        progState = 0;
        sendPrevMessage();
      }
      prev.setFill(color(100, 200, 0, 255));
    } else
    {
      prev.setFill(color(100, 200, 0, 122));
      progState = 0;
    }
  } else if (progState == 3)
  {
    if (overVolume)
    {
      if (millis() - startMs > timeIn)
      {
        progState = 4;
        if (tangan == KIRI)
        {
          slider1StartPosX = leftHandPos2d.x;
          slider1StartPosY = leftHandPos2d.y;
        } else if (tangan == KANAN)
        {
          slider1StartPosX = rightHandPos2d.x;
          slider1StartPosY = rightHandPos2d.y;
        }
        slider1PosY = slider1StartPosY;
        slider1PosX = slider1StartPosX;
        setupSlider1();
        leftHandPositionTemp = new PVector(leftHandPos2d.x,leftHandPos2d.y);
        rightHandPositionTemp = new PVector(rightHandPos2d.x,rightHandPos2d.y);
        timer3 = millis();
        timerHold = timer3;
      }
      vol.setFill(color(100, 200, 0, 255));
    } else
    {
      vol.setFill(color(100, 200, 0, 122));
      progState = 0;
    }
  } else if (progState == 4)
  {
    //println("Delta Position Ref : " + rightHandPositionTemp+  " R : " +  rightHandPos2d);
    if (tangan == KIRI)
    {
      updateSlider1Position(leftHandPos2d.x, leftHandPos2d.y, leftHandPos2d.x, leftHandPos2d.y);
    } else if (tangan == KANAN) {
      updateSlider1Position(rightHandPos2d.x, rightHandPos2d.y, rightHandPos2d.x, rightHandPos2d.y);
    }
    if (millis()-timerHold > 100) {
      timerHold = millis();
       
      if (tangan == KIRI) {
        if ((abs(leftHandPositionTemp.x - leftHandPos2d.x) >= HOLD_TOLERANCE) || (abs(leftHandPositionTemp.y - leftHandPos2d.y) >= HOLD_TOLERANCE)) {
          timer3 = millis();
          leftHandPositionTemp = new PVector(leftHandPos2d.x,leftHandPos2d.y);
        } else {
          if (millis() - timer3 >= timeOut) {
            setupPrev();
            menu1.addChild(prev);
            setupNext();
            menu1.addChild(next);
            setupVol();
            menu1.addChild(vol);
            menu1.rotate(-menu1Angle);
            progState = 0;
          }
        }
      } else if (tangan == KANAN) {

        if ((abs(rightHandPositionTemp.x - rightHandPos2d.x) >= HOLD_TOLERANCE) || (abs(rightHandPositionTemp.y - rightHandPos2d.y) >= HOLD_TOLERANCE)) {
          timer3 = millis();
          rightHandPositionTemp = new PVector(rightHandPos2d.x,rightHandPos2d.y);
        } else {
          if (millis() - timer3 >= timeOut) {
            setupPrev();
            menu1.addChild(prev);
            setupNext();
            menu1.addChild(next);
            setupVol();
            menu1.addChild(vol);
            menu1.rotate(-menu1Angle);
            progState = 0;
          }
        }
      }
    }
  }
}

void updateSlider1Position(float x, float y, float x2, float y2)
{
  float meanX = (x + x2)/2;
  float meanY = (y + y2)/2;
  boolean lock = false;
  float acceptance = 0.01;
  float slider1ToAngle;
  if (meanY < menu1Y)
    slider1ToAngle = atan((meanX - menu1X) / (meanY - menu1Y));
  else
    slider1ToAngle = -atan((meanX - menu1X) / (meanY - menu1Y));
  float smoothness = 1;

  // harus ditambah constraint supaya slider ga lebih dari handle
  if ((slider1ToAngle < slider1Angle ) && (slider1Angle > (-radians(thetaMenu1 - slider1Width/2))) )
  {
    slider1.rotate(-(slider1ToAngle - slider1Angle)/smoothness);
    slider1Angle += (slider1ToAngle - slider1Angle)/smoothness;
  } else if ((slider1ToAngle > slider1Angle) && (slider1Angle < (radians(thetaMenu2 - slider1Width/2))))
  {
    slider1.rotate((-slider1ToAngle + slider1Angle)/smoothness);
    slider1Angle -= (-slider1ToAngle + slider1Angle)/smoothness;
  }
  //print(radians(thetaMenu2-slider1Width/2));
  //print(" ");
  //print(degrees(slider1Angle));
  //print(" ");
  //println(degrees(slider1ToAngle));
  sendVolumeMessage();
}

void sendVolumeMessage()
{
  int volume = (int)(degrees(slider1Angle)/(thetaMenu2-slider1Width/2)*VOLUME_DIVISION); 
  //print("Volume ");
  //println(volume);
}

void sendPrevMessage()
{
  println("PREV!");
  //OscMessage myOscMessage = new OscMessage("/limp/prev");
  //oscP5.send(myOscMessage, myRemoteLocation);
  delay(100);
}

void sendNextMessage()
{
  //OscMessage myOscMessage = new OscMessage("/limp/next");
  //oscP5.send(myOscMessage, myRemoteLocation);
  println("NEXT!");
  delay(100);
}

