Boolean fFinished = false;

// @input : memory image
// @brief : an interface of setting binary data
void SetBinary(String bin []) {
  // initialize momory
  for(int addr = 0; addr < MAX_MEM_ADDR; addr += 2) {
    kuesim.state.SetMem(addr, null);
  }

  // parse memory image
  for (int i = 0; i < bin.length; i++) {

    if (bin[i].length() == 0) { continue; } // skip blank lines

    // parse (instruction)
    //   ex. 0010: 0030 0018
    //       -> state.mem[16]  = 48 (0x0030)
    //          state.mem[17]  = 24 (0x0018)
    String [] captured = match(bin[i], "([A-Fa-f0-9]{4}): +([A-Fa-f0-9]{4})( +[A-Fa-f0-9]{4})?");
    // only commentout (EQU instruction)
    if (captured == null) { continue; }
    String addr = captured[1];
    String inst = captured[2];

    // check opcode and oprand (skip macro line)
    //   ex. 0056:        # TEST: EQU  CA
    if (inst.length() == 0) { continue; }

    // set instruction
    kuesim.state.SetMem(unhex(addr), unhex(inst));

    // parse (operand)
    if (captured.length == 4 && captured[3]) {
      String operand = captured[3];
      kuesim.state.SetMem(unhex(addr)+2, parseInt(operand, 16));
   // kuesim.state.SetMem(unhex(addr)+2, unhex(operand));  // 'unhex' does not work
    }
  }
}


// @input : registers data, mode specification
// @brief : an interface of updating
int Update(KueState regsAndFlags, String mode) {
  // mode is "phase", "inst" or "all"

  if( fFinished ) { return RT_HLT; }

  UpdateRegsAndFlags(regsAndFlags); // set regs and flags
  state = kuesim.state;             // just an alias

  do {
    // generate inst
    if( state.inst == null ) {
      state.inst = instFactory.CreateInstFromBin( state );
      state.currentInstAddr = state.pc;
    }

    state.phase = state.inst.NextPhase();  // save current phase
    int rtCode = state.inst.Exec( state ); // execute

    // error check
    if ( rtCode == RT_ERROR ) {
      Error("ERROR is returned by current instruction");
      return RT_ERROR;
    }
    else if ( rtCode == RT_DONE ) { state.inst = null; }
    else if ( rtCode == RT_HLT  ) { fFinished  = true; }

    // continuation check
    switch( mode ) {
      case "phase":             // finish always
        return rtCode;
      case "inst":              // finish if returned DONE or HLT
        if (rtCode == RT_DONE || rtCode == RT_HLT) { return rtCode; }
        break;
      case "all":               // finish only if returned HLT
        println(state.GetPc());
        if (rtCode == RT_HLT) { println("all"); }
        break;
      default:                  // error : invalid mode
        Error("Invalid mode");
        return rtCode;
    }
  } while (true);
}


void ResetKueSim() {
  fFinished = false;
  kuesim = new KueSim();
}


// @input : register data
// @brief : a setter of registers
void UpdateRegsAndFlags(KueState regsAndFlags) {
  state = kuesim.state;         // just an alias

  // set data
  state.pc           = regsAndFlags.pc;
  state.ir           = regsAndFlags.ir;
  state.sp           = regsAndFlags.sp;
  state.acc          = regsAndFlags.acc;
  state.ix           = regsAndFlags.ix;
  state.mar          = regsAndFlags.mar;
  
  state.flagCf       = regsAndFlags.flagCf;
  state.flagVf       = regsAndFlags.flagVf;
  state.flagNf       = regsAndFlags.flagNf;
  state.flagZf       = regsAndFlags.flagZf;

  state.ibuf         = regsAndFlags.ibuf;
  state.obuf         = regsAndFlags.obuf;
  state.ibuf_re      = regsAndFlags.ibuf_re;
  state.obuf_we      = regsAndFlags.obuf_we;
  state.ibuf_flg_clr = regsAndFlags.ibuf_flg_clr;
}
