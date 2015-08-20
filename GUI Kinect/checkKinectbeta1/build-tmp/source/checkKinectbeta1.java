import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import java.util.Map; 
import java.util.Iterator; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class checkKinectbeta1 extends PApplet {





SimpleOpenNI  context;
int[]       userClr = new int[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
int handVecListSize = 20;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();

PVector rightHandPos = new PVector();
PVector rightHandPos2d = new PVector();
PVector leftHandPos = new PVector();
PVector leftHandPos2d = new PVector();
PVector torsoPos = new PVector();
PVector torsoPos2d = new PVector();

int showPlayPauseAnimation = 0;
int state;
int playPauseTimer;
int play;
float time;
int transparency;
int tangan;
static final int KIRI = 0;
static final int KANAN = 1;


PImage playIcon;
PImage pauseIcon;


public void setup()
{
  size(640,480, P3D);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
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

  setupMenu2(width/2,height/2,1);
  setupMenu1(width/2,height/2,1);
  
  
  
  stroke(0,0,255);
  strokeWeight(10);
  smooth();

  playIcon = loadImage("play.png");
  pauseIcon = loadImage("pause.png");

}

public void draw()
{
  clear();
  background(255,255,255);
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  //image(context.userImage(),0,0);
  image(context.rgbImage(),0,0);

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
      //println("ngetrack "+ userList[i]);
    }      
  }
  
  
  if (userList.length == 0){
    text("User are not registered, move your body, baby!", 10,30);
  }else if(userList.length >= 1){
    text("Raise your hand to show the menu, dude!", 10, 30);
    //check hand position

    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, torsoPos);

    context.convertRealWorldToProjective(rightHandPos, rightHandPos2d);
    context.convertRealWorldToProjective(leftHandPos, leftHandPos2d);
    context.convertRealWorldToProjective(torsoPos, torsoPos2d);

    //play and pause action
    if(showPlayPauseAnimation == 1){
      drawPlayPause(torsoPos2d);
    }
    
    if(leftHandPos2d.y <= torsoPos2d.y && rightHandPos2d.y <= torsoPos2d.y){
      //two hands menu
      println("Show Menu 2");
      updateMenu2(torsoPos2d.x,torsoPos2d.y - 150);

    }else if(leftHandPos2d.y <= torsoPos2d.y || rightHandPos2d.y <= torsoPos2d.y){
      //single hand menu
      if(leftHandPos2d.y <= torsoPos2d.y){
        tangan = KIRI;      
      }else if(rightHandPos2d.y <= torsoPos2d.y){
        tangan = KANAN;
      }
      updateMenu1(torsoPos2d.x, torsoPos2d.y - 150);
      println("Show Menu 1: " + tangan);
    }else{
      //state = 0;
    }
  
  
  
}


  
  
  //println("Jumlah User: " + userList.length);

}

public void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

public void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

public void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}



public void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

public void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1); 
  }  
}

public void onLostHand(SimpleOpenNI curContext,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

public void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
{
  if(gestureType == 0){
    println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
    int handId = context.startTrackingHand(pos);
  }else if (gestureType == 1){
    //toggle play and pause
    if(play == 1){
      //execute pause command
      showPlayPauseAnimation = 1;
      play = 0;
      println("Execute Command Pause");
      //executeOSCCommand();
      playPauseTimer = millis();
    }else if(play == 0){
      //execute play command
      showPlayPauseAnimation  = 1;
      play = 1;
      println("Execute Command Play");
      //executeOSCCommand();
      playPauseTimer = millis();
    }
  }
}


public void drawPlayPause(PVector torso2d){
  time = millis() - playPauseTimer;
  if(time < 500){
      transparency = round(time * 255 / 500);
      println(transparency);
  }else if(time >= 500 && time < 1000){
      transparency = round(255 * (2 - (time/500)));
      println(transparency);
  }else{
    playPauseTimer = millis();
    showPlayPauseAnimation = 0;
  }
  tint(255, transparency);
  if(play == 1){
    image(pauseIcon, torso2d.x, torso2d.y);
  }else if(play == 0){
    image(playIcon, torso2d.x, torso2d.y);
  }
 
  
  tint(255, 255);
}



public void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
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
static final float step = 0.1f;
static final float tolerance = 10;
static final float timeIn = 1000, timeOut = 1000;
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


public void setupHandleMenu2()
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

public void setupPanR()
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

public void setupPanL()
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

public void setupSlider2()
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

public void setupMenu2(float x, float y, float s)
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

public void updateMenu2(float x, float y)
{
  shape(menu2, x, y);
  menu2X = x;
  menu2Y = y;
  if (progState != 2)
  {
    overPanL = isInsidePanL(leftHandPos.x, leftHandPos.y, tolerance);
    overPanR = isInsidePanR(rightHandPos.x, rightHandPos.y, tolerance);
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

public boolean isInsidePanL(float x, float y, float rad)
{
  float phi = radians(panPos);
  float r = (diameterMenu2/2) - (thicknessMenu2/2);
  float a = menu2X - r*sin(phi);
  float b = menu2Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu2/2)))
    return true;
  return false;
}

public boolean isInsidePanR(float x, float y, float rad)
{
  float phi = radians(panPos);
  float r = (diameterMenu2/2) - (thicknessMenu2/2);
  float a = menu2X + r*sin(phi);
  float b = menu2Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu2/2)))
    return true;
  return false;
}

public void checkStateMenu2()
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
        slider2StartPosX = (leftHandPos2d.x + rightHandPos2d.x) / 2; 
        slider2StartPosY = (leftHandPos2d.y + rightHandPos2d.y) / 2;
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
    updateSlider2Position(leftHandPos2d.x, leftHandPos2d.y, rightHandPos2d.x, rightHandPos2d.y);
    
      if((leftHandPositionTemp.x - leftHandPos2d.x >= tolerance) && (leftHandPositionTemp.y - leftHandPos2d.y >= tolerance) && (rightHandPositionTemp.x - rightHandPos2d.x >= tolerance) && (rightHandPositionTemp.y - rightHandPos2d.y >= tolerance)){
        timer3 = millis();
      }else{
        if(millis() - timer3 >= timeIn){
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

public void updateSlider2Position(float x, float y, float x2, float y2)
{
  float meanX = (x + x2)/2;
  float meanY = (y + y2)/2;
  boolean lock = false;
  float acceptance = 0.01f;
  float slider2ToAngle;
  if(meanY < menu2Y)
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

public void sendPanMessage()
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

int timer3;


PVector leftHandPositionTemp;
PVector rightHandPositionTemp;

public void setupHandleMenu1()
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

public void setupNext()
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

public void setupVol()
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

public void setupPrev()
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

public void setupSlider1()
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

public void setupMenu1(float x, float y, float s)
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
  leftHandPositionTemp = torsoPos2d;
  rightHandPositionTemp = torsoPos2d;
}

public void updateMenu1(float x, float y)
{
  shape(menu1, x, y);
  menu1X = x;
  menu1Y = y;
  println(progState);
  if (progState != 4)
  {
    if(tangan == KIRI){
      overVolume = isInsideVol(leftHandPos2d.x, leftHandPos2d.y, tolerance);
      overPrev = isInsidePrev (leftHandPos2d.x, leftHandPos2d.y, tolerance);
      overNext = isInsideNext (leftHandPos2d.x, leftHandPos2d.y, tolerance);
    }else if(tangan == KANAN){
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

public boolean isInsidePrev(float x, float y, float rad)
{
  float phi = radians(prevPos);
  float r = (diameterMenu1/2) - (thicknessMenu1/2);
  float a = menu1X - r*sin(phi);
  float b = menu1Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu1/2)))
    return true;
  return false;
}

public boolean isInsideNext(float x, float y, float rad)
{
  float phi = radians(nextPos);
  float r = (diameterMenu1/2) - (thicknessMenu1/2);
  float a = menu1X + r*sin(phi);
  float b = menu1Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu1/2)))
    return true;
  return false;
}

public boolean isInsideVol(float x, float y, float rad)
{
  float phi = radians(volPos);
  float r = (diameterMenu1/2) - (thicknessMenu1/2);
  float a = menu1X + r*sin(phi);
  float b = menu1Y - r*cos(phi);
  if (sq(a-x)+sq(b-y) <= sq(rad+(thicknessMenu1/2)))
    return true;
  return false;
}

public void checkStateMenu1()
{
  if (progState == 0)
  {
    if (overNext)
    {
      progState = 1;
      startMs = millis();
    }
    else if(overPrev)
    {
      progState = 2;
      startMs = millis();
    }
    else if(overVolume)
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

    if(tangan == KIRI)
    {
      updateSlider1Position(leftHandPos2d.x, leftHandPos2d.y, leftHandPos2d.x, leftHandPos2d.y);  
    }else if(tangan == KANAN){
      updateSlider1Position(rightHandPos2d.x, rightHandPos2d.y, rightHandPos2d.x, rightHandPos2d.y);
    }
    
    if(tangan == KIRI){
      if((leftHandPositionTemp.x - leftHandPos2d.x >= tolerance) && (leftHandPositionTemp.y - leftHandPos2d.y >= tolerance)){
        timer3 = millis();
      }else{
        if(millis() - timer3 >= timeIn + 1000){
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

    }else if(tangan == KANAN){
      
      if((rightHandPositionTemp.x - rightHandPos2d.x >= tolerance) && (rightHandPositionTemp.y - rightHandPos2d.y >= tolerance)){
        timer3 = millis();
      }else{
        if(millis() - timer3 >= timeIn+1000){
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

    leftHandPositionTemp = leftHandPos2d;
    rightHandPositionTemp = rightHandPos2d;

  }
}

public void updateSlider1Position(float x, float y, float x2, float y2)
{
  float meanX = (x + x2)/2;
  float meanY = (y + y2)/2;
  boolean lock = false;
  float acceptance = 0.01f;
  float slider1ToAngle;
  if(meanY < menu1Y)
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

public void sendVolumeMessage()
{
  int volume = (int)(degrees(slider1Angle)/(thetaMenu2-slider1Width/2)*VOLUME_DIVISION); 
  print("Volume ");
  println(volume);
}

public void sendPrevMessage()
{
  println("PREV!");
  //OscMessage myOscMessage = new OscMessage("/limp/prev");
  //oscP5.send(myOscMessage, myRemoteLocation);
  delay(100);
}

public void sendNextMessage()
{
  //OscMessage myOscMessage = new OscMessage("/limp/next");
  //oscP5.send(myOscMessage, myRemoteLocation);
  println("NEXT!");
  delay(100);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "checkKinectbeta1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
