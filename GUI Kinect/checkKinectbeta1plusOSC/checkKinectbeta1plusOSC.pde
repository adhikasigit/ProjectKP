import oscP5.*;
import netP5.*;

import SimpleOpenNI.*;
import java.util.Map;
import java.util.Iterator;

OscP5 oscP5;

NetAddress port1;
NetAddress port2;
NetAddress port3;
NetAddress port4;

boolean playId = false;
boolean start = false;

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
  s = loadShape("next.svg");
  context = new SimpleOpenNI(this);
  
   oscP5 = new OscP5(this,12000);
  
  port1 = new NetAddress("127.0.0.1",12002);
  port2 = new NetAddress("127.0.0.1",12003);
  port3 = new NetAddress("127.0.0.1",12004);
  port4 = new NetAddress("127.0.0.1",12005);
  
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

