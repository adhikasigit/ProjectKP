// The message to be displayed
String message_prev = "prev";
String message_volume = "volume";
String message_equalizer = "equalizer";
String message_volume = "volume";
String message_next = "next";

float ARC_CENTER_X = 320; //set 320 first, so the circle is centered on the screen
float ARC_CENTER_Y = 240; //set 240 first, so the circle is centered on the screen
float ARC_WIDTH = 400;
float ARC_HEIGHT = 400;
float ARC_START_ANGLE = 0; //in radian
float ARC_STOP_ANGLE = PI; //in radian

PFont f;
// The radius of a circle
float r = 200;

void setup() {
  size(640, 480);
  f = createFont("Georgia",20,true);
  textFont(f);
  // The text must be centered!
  textAlign(CENTER);
  smooth();
  int ms = millis();
}

void draw() {
  background(255);
  noFill();
  //arc(ARC_CENTER_X, ARC_CENTER_Y, ARC_WIDTH, ARC_HEIGHT, ARC_START_ANGLE, ARC_STOP_ANGLE);
  
  // Start in the center and draw the circle
  translate(width / 2, height / 2);
  noFill();
  stroke(0);
  ellipse(0, 0, r*2, r*2);

  // We must keep track of our position along the curve
  
  draw_message(message_prev, )

  if(handPositionOnMenu()){
    drawBaseMenu();
    selectedMenuCache = selectedMenu;
    selectedMenu = isHoverOnMenu();
    drawHovering(selectedMenu);
    if(selectedMenu != selectedMenuCache){
      start_time = millis();
    }else{
      if(millis() - start_time >= WAIT_TIME){
        executeOscCommand(selectedMenu);
      }
    }
  }else{
    selectedMenu = 0;
  }


  float arclength = 0;
  // For every box
  /*

  void drawBaseMenu(){
    for (int i = 0; i < message.length(); i++)
    {
      // Instead of a constant width, we check the width of each character.
      char currentChar = message.charAt(i);
      float w = textWidth(currentChar);

      // Each box is centered so we move half the width
      arclength += w/2;
      // Angle in radians is the arclength divided by the radius
      // Starting on the left side of the circle by adding PI
      float theta = (PI*3/2) + arclength / r;    

      pushMatrix();
      // Polar to cartesian coordinate conversion
      translate(r*cos(theta), r*sin(theta));
      // Rotate the box
      rotate(theta+PI/2); // rotation is offset by 90 degrees
      // Display the character
      fill(0);
      text(currentChar,0,0);
      popMatrix();
      // Move halfway again
      arclength += w/2;
    }
  }

}
