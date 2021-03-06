//Ranz des Vaches Kevin MacLeod (incompetech.com)
//Licensed under Creative Commons: By Attribution 3.0 License
//http://creativecommons.org/licenses/by/3.0/

import moonlander.library.*;

// Minim must be imported when using Moonlander with soundtrack.
import ddf.minim.*;

Moonlander moonlander;

float increment = 0.01;
float zoff = 0.0;
int BPM = 56;
float beat = BPM / 60.0;
float[][] height_map;
Tree[] forest;
int num_trees = 100;
int ground_dim_x = 1000;
int ground_dim_y = 1000;
PImage grass_image;
PShape ground;
PShader texShader;
class Tree {
  int x;
  int y;
  float orientation;
  float h; // height
  float s; // size;
  
  void draw() {
    pushMatrix();
    fill(color(120, 70, 50));
    //scale(s);
    //scale(1, h, 1);
    //rotateX(PI/2);
    translate(x, y, height_map[x][y]);
    rotateZ(orientation);
    sphere(s);
    
    popMatrix();
  }
}

void setup() {
    // Parameters: PApplet, filename (file should be in sketch's folder), 
    // beats per minute, rows per beat
    moonlander = Moonlander.initWithSoundtrack(this, "Ranz des Vaches_clipped.mp3", BPM, 4);

    size(600, 400, P3D);
    frameRate(30);
    // .. other initialization code ...

    moonlander.start();
    noStroke();
    background(200);
    colorMode(HSB, 360, 100, 100);
    
    
    
    grass_image = loadImage("grass.jpg");
    computeHeightMap();
    ground = createGround(grass_image);
    texShader = loadShader("tex.frag", "tex.vert");
    createForest();
}
void computeHeightMap() {
  height_map = new float[ground_dim_x][ground_dim_y];
  float level = 0;
  float amplitude = 0.7;
  float roughness = 0.004;
  for (int x = 0; x < ground_dim_x; ++x) {
    for (int y = 0; y < ground_dim_y; ++y) {
      height_map[x][y] = (noise(x * roughness, y * roughness) - 0.5 + level) * amplitude;
    }
  }
}

void createForest() {
  forest = new Tree[num_trees];
  for (int i = 0; i < num_trees; ++i) {
    forest[i] = new Tree();
    forest[i].x = (int)random(0, ground_dim_x - 1);
    forest[i].y = (int)random(0, ground_dim_y - 1);
//    forest[i].x = constrain((int)(randomGaussian() * ground_dim_x), 0, ground_dim_x - 1);
//    forest[i].y = constrain((int)(randomGaussian() * ground_dim_y), 0, ground_dim_y - 1);
    forest[i].orientation = random(0, TAU);
    forest[i].h = 4;
    forest[i].s = 2;
  }
}

PShape createGround(PImage tex) {
  int repeat_grid = 2;
  float area_size = 10;
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD);
  sh.noStroke();
  sh.texture(tex);
  
  for (int x = 0; x < ground_dim_x - 1; ++x) {
    for (int y = 0; y < ground_dim_y - 1; ++y) {
      float per_u =  1.0 / ((ground_dim_x - 1) / (float)repeat_grid);
      float per_v =  1.0 / ((ground_dim_y - 1) / (float)repeat_grid);
      float per_x = (float)area_size / (ground_dim_x - 1);
      float per_y = (float)area_size / (ground_dim_y - 1);
      float xx = x * per_x;
      float xx1 = xx + per_x;
      float yy = y * per_y;
      float yy1 = yy + per_y;
      float u = x * per_u % 1;
      float uu = u + per_u % 1;
      float v = y * per_v % 1;
      float vv = v + per_v % 1;
      sh.normal(0, 1, 0);
      sh.vertex(xx  , yy , height_map[x][y]    , u , v);
      sh.vertex(xx1 , yy , height_map[x+1][y]  , uu, v);
      sh.vertex(xx1 , yy1, height_map[x+1][y+1], uu, vv);
      sh.vertex(xx  , yy1, height_map[x][y+1]  , u , vv);
    }
  }
  
  sh.endShape();
  return sh;
}



void coordinateSpaceArrows() {
  fill(color(0, 100, 100));
  translate(0.5, 0, 0);
  box(1, 0.2, 0.2);
  
  fill(color(120, 100, 100));
  translate(-0.5, 0.5, 0);
  box(0.2, 1, 0.2);
  
  fill(color(240, 100, 100));
  translate(0, -0.5, 0.5);
  box(0.2, 0.2, 1);
}

void draw() {
  
  float cameraZ =((height/2.0) / tan(PI*60.0/360.0)) * 0.08; 
  perspective(PI/3.0, width/height, cameraZ/10.0, cameraZ*10.0);
  background(210, 100, 100);
  lights();
  
  // Handles communication with Rocket
  moonlander.update();
  float t = (float)moonlander.getCurrentTime();
  
  float c_pos_x = (float)moonlander.getValue("c_pos_x");
  float c_pos_y = (float)moonlander.getValue("c_pos_y");
  float c_pos_z = (float)moonlander.getValue("c_pos_z");
  float v_pos_x = (float)moonlander.getValue("v_pos_x");
  float v_pos_y = (float)moonlander.getValue("v_pos_y");
  float v_pos_z = (float)moonlander.getValue("v_pos_z");
  
  float s = (float)moonlander.getValue("scale");
  float gx = (float)moonlander.getValue("gx");
  float gy = (float)moonlander.getValue("gy");
  float gz = (float)moonlander.getValue("gz");
 
  
  
  pushMatrix();
  fill(color(180,0,50));
  scale(10);
  coordinateSpaceArrows();
  popMatrix();
    
  
  pushMatrix();
  scale (s);
  rotateX(PI/2);
  translate(gx, gy, gz);
  shader(texShader);
  //shape(ground);
  resetShader();
  //coordinateSpaceArrows();
  popMatrix();
  
  for (int tree = 0; tree < num_trees; ++tree) {
    forest[tree].draw();
  }      
  
  camera(c_pos_x, c_pos_y, c_pos_z, v_pos_x, v_pos_y, v_pos_z, 
         0.0, 1.0, 0.0);
         
  
  

  
  if (keyPressed) {
    if (key == 's' || key == 'S' || key == 'q' || key == 'Q') {
      exit();
    }
  }
}
