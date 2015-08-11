import SimpleOpenNI.*;
import java.util.Map;
import java.util.Iterator;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
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


void setup()
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

void draw()
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
      println("ngetrack "+ userList[i]);
    }      
  }
  
  
  if (userList.length == 0){
    text("User are not registered, move your body, baby!", 10,30);
  }else if(userList.length >= 1){
    text("Raise your hand to show the menu, dude!", 10, 30);
    //check hand position

    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, leftHandPos);
    context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, torsoPos);

    context.convertRealWorldToProjective(rightHandPos, rightHandPos2d);
    context.convertRealWorldToProjective(leftHandPos, leftHandPos2d);
    context.convertRealWorldToProjective(torsoPos, torsoPos2d);

    //play and pause action
    if(showPlayPauseAnimation == 1){
      drawPlayPause(torsoPos2d);
    }
    
    
    
    println("left : "+ leftHandPos);
    println("right : "+ rightHandPos);
    println("torso : " + torsoPos);
    
    if(leftHandPos2d.y <= torsoPos2d.y && rightHandPos2d.y <= torsoPos2d.y){
      //two hands menu
      println("Show Menu 2");
      updateMenu2();

    }else if(leftHandPos2d.y <= torsoPos2d.y ^ rightHandPos2d.y <= torsoPos2d.y){
      //single hand menu
      if(leftHandPos2d.y <= torsoPos2d.y){
        tangan = KIRI;      
      }else if(rightHandPos2d.y <= torsoPos2d.y){
        tangan = KANAN;
      }
      updateMenu1();
      println("Show Menu 1");
    }else{
      //state = 0;
    }
  
  
  
}


  
  
  println("Jumlah User: " + userList.length);

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



void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
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

void onLostHand(SimpleOpenNI curContext,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
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


void drawPlayPause(PVector torso2d){
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



void drawSkeleton(int userId)
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
