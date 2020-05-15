// name        : simulator.pde
// explanation : This program starts with this file...


// global constants
final int FONT_SIZE         = 16;
final int BASE_COLUMN_WIDTH = 180;
final int TOP_OFFSET        = FONT_SIZE * 3;
final int LEFT_OFFSET       = FONT_SIZE * 3;

final int LINE_HEIGHT       = FONT_SIZE + 2;
final int DEFAULT_NUM_LINES = 38;

int DEBUG_ACCEL             = 1;


// global variables
TextArea sysLog = new TextArea(
                    int(LEFT_OFFSET + BASE_COLUMN_WIDTH * 5.3),
                    TOP_OFFSET + LINE_HEIGHT,
                    DEFAULT_NUM_LINES - 1
                  );
int count          = 0;
KueSim kuesim      = new KueSim();
Boolean fContinue  = true;
Boolean fPause     = false;

int printStartAddress = 0x00;

KueState State() { return kuesim.state; }


// ----- functions -----
void setup() {
  // size(1400, 760);
  size(1, 1);

  PFont fontInconsolata = createFont("Inconsolata", FONT_SIZE);
  if( fontInconsolata != null ) {
    textFont( fontInconsolata );
  } else {
    sysLog.Append("Failed to load font 'Inconsolata.'");
  }

  input.Initialize();
  noLoop();
}


void draw() {                   // main loop in processing
  // MainProcess();

  background(0);                // erase screen
  kuesim.Dump();

  text("[ log ]", sysLog.basePos.x, sysLog.basePos.y - LINE_HEIGHT);
  sysLog.Print();
}


void MainProcess() {
  input.UpdateKey();
  input.ProcessKey();

  for(int i = 0; i < DEBUG_ACCEL; i++)  // MAKE FASTER FOR TEST
  if( !fPause ) {
    // sysLog.Append("----- count : " + ++count + " -----");
    ++count;
    if( !kuesim.Update() ) { Exit(); break; }
  }

  if( sysLog.Size() > 1000000 ) {
    sysLog.FileDump();
    sysLog.Clear();
  }
  
  // if( count == 18800000 ) {
  //   // fPause = true;
  //   DEBUG_ACCEL = 10000;
  // }

  // if( count == 18880000 ) {
  //   // fPause = true;
  //   DEBUG_ACCEL = 1000;
  // }

  // if( count == 18882000 ) {
  //   // fPause = true;
  //   DEBUG_ACCEL = 100;
  // }

  // if( count == 18882800 ) {
  //   fPause = true;
  //   DEBUG_ACCEL = 10;
  // }
}


// key event handler
void keyPressed()  {
  if( key != CODED ) { input.fKeysPressed[int(key)]     = true; }
  else               { input.fCodedKeysPressed[keyCode] = true; }
}


void Error(String msg) {
  sysLog.Append("Error.");
  sysLog.Append(msg);
  Exit();
}


void Exit() {
  sysLog.Append("Exit.");
  sysLog.FileDump();
  sysLog.Clear();
  exit();
}
