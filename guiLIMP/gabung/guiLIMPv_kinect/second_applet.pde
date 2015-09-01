
public class PFrame extends JFrame {
  public PFrame(int width, int height) {
    setBounds(100, 100, width, height);
    s = new SecondApplet();
    add(s);
    s.init();
  }
}
public class SecondApplet extends PApplet {
 SimpleOpenNI  context;
color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
  };
int handVecListSize = 20;
Map<Integer, ArrayList<PVector>>  handPathList = new HashMap<Integer, ArrayList<PVector>>();

PShape s;

PVector rightHandPos = new PVector();
PVector rightHandPos2d = new PVector();
PVector leftHandPos = new PVector();
PVector leftHandPos2d = new PVector();
PVector torsoPos = new PVector();
PVector torsoPos2d = new PVector();
PVector neckPos = new PVector();
PVector neckPos2d = new PVector();

int showPlayPauseAnimation = 0;
int state;
int playPauseTimer;
int play = 0;
int songId;
float time;
int transparency;
int tangan;

static final int Z_MAX = 5250;
static final int Z_DEFAULT = 2000;
static final int KIRI = 0;
static final int KANAN = 1;


PImage playIcon;
PImage pauseIcon;


  void setup()
  {
     size(640, 480, P3D);
  //s = loadShape("next.svg");
  context = new SimpleOpenNI(this);
  
  
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  //enable generating RGB Image
  context.enableRGB();

  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
  context.startGesture(SimpleOpenNI.GESTURE_CLICK);

  setupMenu2(width/2, height/2, 1);
  setupMenu1(width/2, height/2, 1);



  stroke(0, 0, 255);
  strokeWeight(10);
  smooth();

  playIcon = loadImage("play.png");
  pauseIcon = loadImage("pause.png");
  }
  void draw()
 {
  clear();
  background(255, 255, 255);
  // update the cam
  context.update();

  // draw depthImageMap
  //image(context.depthImage(),0,0);
  //image(context.userImage(),0,0);
  image(context.rgbImage(), 0, 0);

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  strokeWeight(2);
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
      //println("ngetrack "+ userList[i]);
    }
  }


  if (userList.length == 0) {
    text("User are not registered, move your body, baby!", 10, 30);
  } else if (userList.length >= 1) {
    text("Raise your hand to show the menu, dude!", 10, 30);
    //check hand position

    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, torsoPos);
    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_NECK, neckPos);

    context.convertRealWorldToProjective(rightHandPos, rightHandPos2d);
    context.convertRealWorldToProjective(leftHandPos, leftHandPos2d);
    context.convertRealWorldToProjective(torsoPos, torsoPos2d);
    context.convertRealWorldToProjective(neckPos, neckPos2d);

    //play and pause action
    if (showPlayPauseAnimation == 1) {
      drawPlayPause(torsoPos);
    }

    if (leftHandPos2d.y <= torsoPos2d.y && rightHandPos2d.y <= torsoPos2d.y) {
      //two hands menu
      //println("Show Menu 2");
      updateMenu2(neckPos2d.x, neckPos2d.y, neckPos.z);
    } else if (leftHandPos2d.y <= torsoPos2d.y || rightHandPos2d.y <= torsoPos2d.y) {
      //single hand menu
      if (leftHandPos2d.y <= torsoPos2d.y) {
        tangan = KIRI;
      } else if (rightHandPos2d.y <= torsoPos2d.y) {
        tangan = KANAN;
      }
      updateMenu1(neckPos2d.x, neckPos2d.y, neckPos.z);
      // println("Show Menu 1: " + tangan);
    } else {
      
    }
    //println("Program State " + progState);
    //shape(s,10,10,80,80);
  }




  //println("Jumlah User: " + userList.length);
}

  void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}



void onNewHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);

  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);

  handPathList.put(handId, vecList);
}

void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );

  ArrayList<PVector> vecList = handPathList.get(handId);
  if (vecList != null)
  {
    vecList.add(0, pos);
    if (vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1);
  }
}

void onLostHand(SimpleOpenNI curContext, int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos)
{
  if (gestureType == 0) {
    println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
    int handId = context.startTrackingHand(pos);
  } else if (gestureType == 1) {
    //toggle play and pause
    if (play == 1) {
      //execute pause command
       OscMessage myOscMessage = new OscMessage("/limp/pause");
       oscP5.send(myOscMessage, port1);
       play = 0;
      showPlayPauseAnimation = 1;
      play = 0;
      println("Execute Command Pause");
      //executeOSCCommand();
      playPauseTimer = millis();
    } else if (play == 0) {
      //execute play command
      if(!start){
        start = true;
        OscMessage myOscMessage4 = new OscMessage("/playlist");
        oscP5.send(myOscMessage4, port4);
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
        play = 1;
      }
      else{
         OscMessage myOscMessage = new OscMessage("/limp/play");
        oscP5.send(myOscMessage, port1);
        play = 1;
        
    }
      showPlayPauseAnimation  = 1;
      play = 1;
      println("Execute Command Play");
      //executeOSCCommand();
      playPauseTimer = millis();
    }
  }
}


void drawPlayPause(PVector torso) {
  PVector torsotemp2d = new PVector();
  context.convertRealWorldToProjective(torso, torsotemp2d);
  time = millis() - playPauseTimer;
  if (time < 500) {
    transparency = round(time * 255 / 500);
    //println(transparency);
  } else if (time >= 500 && time < 1000) {
    transparency = round(255 * (2 - (time/500)));
    //println(transparency);
  } else {
    playPauseTimer = millis();
    showPlayPauseAnimation = 0;
  }
  tint(255, transparency);
  if (play == 1) {
    pauseIcon.resize(0, round(Z_MAX * 30 / torso.z));
    image(pauseIcon, torsotemp2d.x - (pauseIcon.width/2), torsotemp2d.y - (playIcon.height/2));
  } else if (play == 0) {
    playIcon.resize(0, round(Z_MAX * 30 / torso.z));
    image(playIcon, torsotemp2d.x - (playIcon.width/2), torsotemp2d.y - (playIcon.height/2) );
  }

  tint(255, 255);
}



void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,jointPos);
   println(jointPos);*/


  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
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
  float volume = (degrees(slider1Angle)/(thetaMenu2-slider1Width/2)); 
  volume = (volume + 1) / 2;
  OscMessage myOscMessage3 = new OscMessage("/volume");
  myOscMessage3.add(volume);
  print("Volume ");
  println(volume);
  
}

void sendPrevMessage()
{
  println("PREV!");
    songId-=1;
    OscMessage myOscMessage = new OscMessage("/songid");
    myOscMessage.add((int)songId);
    oscP5.send(myOscMessage,port2);
    OscMessage myOscMessage1 = new OscMessage("/limp/start");
    oscP5.send(myOscMessage1, port1);
    delay(500);
}

void sendNextMessage()
{
   songId+=1;
    OscMessage myOscMessage = new OscMessage("/songid");
    myOscMessage.add((int)songId);
    oscP5.send(myOscMessage,port2);
    OscMessage myOscMessage1 = new OscMessage("/limp/start");
    oscP5.send(myOscMessage1, port1);
    delay(500);
  println("NEXT!");
  delay(100);
}

static final float step = 0.1;
static final float tolerance = 25, HOLD_TOLERANCE = 20;
static final float timeIn = 1500, timeOut = 1000;
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
float scaleTemp2 = 1;

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
  strokeWeight(0);
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

void updateMenu2(float x, float y, float z)
{
  strokeWeight(0);
  shape(menu2, x, y);
  menu2.scale(Z_DEFAULT/(z*scaleTemp2)) ;
  scaleTemp2 = Z_DEFAULT / z;
  menu2X = x;
  menu2Y = y;
  if (progState != 2)
  {
    overPanL = isInsidePanL(leftHandPos2d.x, leftHandPos2d.y, tolerance);
    println("Hand Position X : " + leftHandPos2d.x + " Y : " + leftHandPos2d.y );
    overPanR = isInsidePanR(rightHandPos2d.x, rightHandPos2d.y, tolerance);
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
  println("Menu Position X : " + a + " Y : " + b ); 
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
    println("Pan Left : " + overPanL + " Pan Right : " + overPanR);
    if (overPanL | overPanR)
    {
      if (millis() - startMs > timeIn)
      {
        progState = 2;
        slider2StartPosX = (leftHandPos2d.x + rightHandPos2d.x) / 2; 
        slider2StartPosY = (leftHandPos2d.y + rightHandPos2d.y) / 2;
        slider2PosY = slider2StartPosY;
        slider2PosX = slider2StartPosX;
        setupSlider2();
        timer3 = millis();
        timerHold = timer3;
        leftHandPositionTemp = new PVector(leftHandPos2d.x, leftHandPos2d.y);
        rightHandPositionTemp = new PVector(rightHandPos2d.x, rightHandPos2d.y);
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
    updateSlider2Position(leftHandPos2d.x, leftHandPos2d.y, rightHandPos2d.x, rightHandPos2d.y);
    if (millis()-timerHold > 100) {
      timerHold = millis();
      if ((abs(leftHandPositionTemp.x - leftHandPos2d.x) >= HOLD_TOLERANCE) || (abs(leftHandPositionTemp.y - leftHandPos2d.y) >= HOLD_TOLERANCE) || (abs(rightHandPositionTemp.x - rightHandPos2d.x) >= HOLD_TOLERANCE) || (abs(rightHandPositionTemp.y - rightHandPos2d.y )>= HOLD_TOLERANCE)) {
        timer3 = millis();
        leftHandPositionTemp = new PVector(leftHandPos2d.x, leftHandPos2d.y);
        rightHandPositionTemp = new PVector(rightHandPos2d.x, rightHandPos2d.y);
      } else {
        if (millis() - timer3 >= timeOut) {
          setupPanL();
          menu2.addChild(panL);
          setupPanR();
          menu2.addChild(panR);
          menu2.rotate(-menu2Angle);
          progState = 0;
        }
      }
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
  float smoothness = 1;

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
  float panning = (degrees(slider2Angle)/(thetaMenu2-slider2Width/2)); 
  println(panning);
}


}

