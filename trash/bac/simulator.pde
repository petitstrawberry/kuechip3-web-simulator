// main

// global variables
KueSim kuesim = new KueSim();
InstFactory instFactory = new InstFactory();
int count = 0;

void setup() {
  size(640, 480);
  noLoop();
}


void draw() {
  println("----- count : " + count++ + " -----");
  
  Boolean fContinue = kuesim.Update();
  kuesim.Dump();
  
  if( !fContinue ) {
    exit();
  }
}


void keyPressed()  {
  redraw();
}