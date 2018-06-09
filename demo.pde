import moonlander.library.*;

// Minim must be imported when using Moonlander with soundtrack.
import ddf.minim.*;

Moonlander moonlander;

float increment = 0.01;
float zoff = 0.0;
// The noise function's 3rd argument, a global variable that increments once per cycle
int BPM = 95;
float beat = BPM / 60.0;

void setup() {
    // Parameters: PApplet, filename (file should be in sketch's folder), 
    // beats per minute, rows per beat
    moonlander = Moonlander.initWithSoundtrack(this, "Robobozo.mp3", BPM, 4);

    size(1280, 720, P3D);
    frameRate(30);
    // .. other initialization code ...

    moonlander.start("localhost", 9001, "synkkifilu");
    noStroke();
    background(200);
}

void draw() {
  background(200);
  lights();
  
  // Handles communication with Rocket
  moonlander.update();
  float t = (float)moonlander.getCurrentTime();
  
  double camera_pos_x = moonlander.getValue("x_pos");
  double camera_pos_z = moonlander.getValue("z_pos");
     
  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  
  //translate(width/2, height/2);
  
  int n = 30;
  for (int x = 0; x < n; x++) {
    for (int y = 0; y < n; y++) {
      
      float h = noise(x, y, t);
      pushMatrix();
      translate((x- n/2) * 30, h * 20, (y-n/2) * 30);
      box(28 + sin(t*beat*TAU) * 6.0);
      popMatrix();

      
    }
  }
  
  camera((float)camera_pos_x, -100.0, (float)camera_pos_z,  0.0, 0.0, 0.0, 
         0.0, 1.0, 0.0);
  
  if (keyPressed) {
    if (key == 's' || key == 'S') {
      exit();
    }
  }
}
