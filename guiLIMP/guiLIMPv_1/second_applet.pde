public class PFrame extends JFrame {
  public PFrame(int width, int height) {
    setBounds(100, 100, width, height);
    s = new SecondApplet();
    add(s);
    s.init();
  }
}
public class SecondApplet extends PApplet {
  static final float step = 0.1;
  static final float tolerance = 10;
  static final float timeIn = 2000, timeOut = 2000;
  static final int PAN_DIVISION = 4, VOLUME_DIVISION = 10;

  PShape handle2, handle1, panL, panR, menu2, hand, slider2, slider1, menu1, prev, next, vol;
  boolean overPanL, overPanR;

  int progState = 0;
  int startMs, currentMs;
  int panRightAlpha = 122, slider2Alpha = 255, slider1Alpha = 255, panLeftAlpha = 122, handle2Alpha = 255, handle1Alpha = 255, menu2Alpha = 255, menu1Alpha = 255, prevAlpha = 122, nextAlpha = 122, volAlpha = 122;
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
    //setupMenu2(width/2,height/2,1);
    setupMenu1(width/2, height/2, 1);
    background(100);
  }
  void draw()
  {
    //updateMenu2();
    updateMenu1();
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

  void setupSlider2()
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

  void setupMenu2(float x, float y, float s)
  {
    setupHandleMenu2();  
    setupPanR();
    setupPanL();
    menu2 = createShape(GROUP);
    menu2.addChild(handle2);
    menu2.addChild(panL);
    menu2.addChild(panR);
    menu2.rotate(radians(180));
    menu2X = width/2;
    menu2Y = height/2;
    setupSlider2();
    slider2.scale(0);
    menu2.scale(s);
  }

  void updateMenu2()
  {
    shape(menu2, menu2X, menu2Y);

    if (progState != 2)
    {
      overPanL = isInsidePanL(mouseX, mouseY, tolerance);
      overPanR = isInsidePanR(mouseX, mouseY, tolerance);
    }
    checkStateMenu2();
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

  void checkStateMenu2()
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
          setupSlider2();
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
      updateSlider2Position(mouseX, mouseY, mouseX, mouseY);
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

  void updateSlider2Position(float x, float y, float x2, float y2)
  {
    float meanX = (x + x2)/2;
    float meanY = (y + y2)/2;
    boolean lock = false;
    float acceptance = 0.01;
    float slider2ToAngle;
    if (meanY < menu2Y)
      slider2ToAngle = atan((meanX - menu2X) / (meanY - menu2Y));
    else
      slider2ToAngle = -atan((meanX - menu2X) / (meanY - menu2Y));
    float smoothness = 10;

    // harus ditambah constraint supaya slider ga lebih dari handle
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
  }

  void updateMenu1()
  {
    shape(menu1, menu1X, menu1Y);
    println(progState);
    if (progState != 4)
    {
      overVolume = isInsideVol(mouseX, mouseY, tolerance);
      overPrev = isInsidePrev(mouseX, mouseY, tolerance);
      overNext = isInsideNext(mouseX, mouseY, tolerance);
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
          slider1StartPosX = mouseX;
          slider1StartPosY = mouseY;
          slider1PosY = slider1StartPosY;
          slider1PosX = slider1StartPosX;
          setupSlider1();
        }
        vol.setFill(color(100, 200, 0, 255));
      } else
      {
        vol.setFill(color(100, 200, 0, 122));
        progState = 0;
      }
    } else if (progState == 4)
    {
      updateSlider1Position(mouseX, mouseY, mouseX, mouseY);
      if (mousePressed)
      {
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
    float smoothness = 10;

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
    print(radians(thetaMenu2-slider1Width/2));
    print(" ");
    print(degrees(slider1Angle));
    print(" ");
    println(degrees(slider1ToAngle));
    sendVolumeMessage();
  }

  void sendVolumeMessage()
  {
    int volume = (int)(degrees(slider1Angle)/(thetaMenu2-slider1Width/2)*VOLUME_DIVISION); 
    print("Volume ");
    println(volume);
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
}

