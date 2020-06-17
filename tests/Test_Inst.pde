class Test_Inst {
  InstBase inst;
  KueState state, ev2, ev3, ev4;
  int currPhase, lastPhase;

  public Test_Inst(InstBase inst_a, KueState state_a,
                   KueState ev2_a,  KueState ev3_a, KueState ev4_a,
                   int lastPhase_a )
  {
    inst = inst_a;
    state = state_a;
    ev2 = ev2_a;
    ev3 = ev3_a;
    ev4 = ev4_a;
    lastPhase = lastPhase_a;
    currPhase = 0;
  }


  public Boolean Run()
  {
    int res = -1;
  
    // P0 (NO_CHECK)
    rtcode = inst.Exec( state );

    // P1 (NO_CHECK)
    currPhase++;
    rtcode = inst.Exec( state ); 

    // P2
    currPhase++;
    rtcode = inst.Exec( state );
    if ( ! CheckRtcode(rtcode)  ) return false;
    if ( ! CheckState()         ) return false;
    if ( currPhase == lastPhase ) return true;

    // P3
    currPhase++;
    rtcode = inst.Exec( state );
    if ( ! CheckRtcode(rtcode)  ) return false;
    if ( ! CheckState()         ) return false;
    if ( currPhase == lastPhase ) return true;

    // P4
    currPhase++;
    rtcode = inst.Exec( state );
    if ( ! CheckRtcode(rtcode)  ) return false;
    if ( ! CheckState()         ) return false;
    if ( currPhase == lastPhase ) return true;
  
    return false;
  }


  private Boolean CheckState() {
    // select current ev
    KueState ev;
    if      ( currPhase == 2 ) { ev = ev2; }
    else if ( currPhase == 3 ) { ev = ev3; }
    else if ( currPhase == 4 ) { ev = ev4; }
    else {
      Print("'currPhase' is invalid.");
      return false;
    }

    // null check
    if ( ev == null ) {
      Print("The expected value is not defined.");
      return false;
    }
    
    // compare state and ev


    return true;
  }


  private Boolean CheckRtcode(int rtcode) {
    // check RT_ERROR
    if ( rtcode == RT_ERROR ) {
      Print("Find 'RT_ERROR'.");
      return false;
    }

    // check RT_CONTINUE and RT_DONE
    if ( currPhase < lastPhase ) {
      if ( rtcode == RT_CONTINUE ) { return true; }
      else {
        Print("Find an invalid return code.");
        return false;
      }
    }
    else if ( currPhase == lastPhase ) {
      if ( rtcode == RT_DONE ) { return true; }
      else {
        Print("Find an invalid return code.");
        return false;
      }
    }
    else {
      Print("Current phase is invalid");
      return false;
    }
  }
}
