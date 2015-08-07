int time = millis() - playPauseTimer;

  if(time < 500){
    
  }else if(time >= 500 && time < 1000){

  }else{
    //set showPlayPauseAnimation to 0
    showPlayPauseAnimation = 0;
  }
