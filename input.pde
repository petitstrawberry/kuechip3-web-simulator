Input input = new Input();

class Input
{
  public final int numKeys   = 256;

  public Boolean fKeysPressed[]      = new Boolean[numKeys];
  public Boolean fCodedKeysPressed[] = new Boolean[numKeys];
  
  public int keysCount[]             = new int[numKeys];
  public int codedKeysCount[]        = new int[numKeys];


  public void Initialize() {
    for(int i = 0; i < numKeys; i++) {
      fKeysPressed[i]      = false;
      fCodedKeysPressed[i] = false;
      keysCount[i]         = 0;
      codedKeysCount[i]    = 0;
    }
  }

  
  public void UpdateKey()
  {
    // for not coded key
    for(int i = 0; i < numKeys; i++) {
      if( fKeysPressed[i] ) {
        keysCount[i]++;
        sysLog.Append("Pressed key" + char(i));
      }
      else {
        keysCount[i] = 0;
      }

      fKeysPressed[i] = false;
    }

    // for coded key
    for(int i = 0; i < numKeys; i++) {
      if( fCodedKeysPressed[i]) {
        codedKeysCount[i]++;
        sysLog.Append("Pressed coded key : " + i);
      }
      else {
        codedKeysCount[i] = 0;
      }

      fCodedKeysPressed[i] = false;
    }
  }


  public void ProcessKey()
  {
    if( keysCount[int('j')] > 0 || codedKeysCount[DOWN] > 0) {
      printStartAddress = min(
                              printStartAddress + 32,
                              65536 - 16 * (DEFAULT_NUM_LINES - 1)
                              );
    }
    if( keysCount[int('k')] > 0 || codedKeysCount[UP]  > 0) {
      printStartAddress = max(printStartAddress - 32, 0);
    }

    if( keysCount[ENTER] == 1 ) { fPause = !fPause; }
  }
}
