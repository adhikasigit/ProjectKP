float time = 0;
int timeNol;
int transparency;
PImage playIcon;
PImage pauseIcon;
void setup(){
  
  size(640,480);
  playIcon = loadImage("play.png");
  pauseIcon = loadImage("pause.png");
  timeNol = millis();
}

void draw(){
  clear();
  background(255,255,255);
  time = millis() - timeNol;
  if(time < 500){
      transparency = round(time * 255 / 500);
      println(transparency);
  }else if(time >= 500 && time < 1000){
      transparency = round(255 * (2 - (time/500)));
      println(transparency);
  }else{
    timeNol = millis();
    println("timenol");    
  }
        
        tint(255, transparency);
        image(pauseIcon, 0, 0);
        
}
