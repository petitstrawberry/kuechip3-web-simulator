class KueSim {
  // public
  KueSim() {
    sysLog.Append("Start Kuechip3 Simulater.\n");
    state = new KueState();
  }

  Boolean Update() {
    if( fInstDone ) {
      fInstDone = false;
      inst = instFactory.CreateInstFromBin( state );
    }

    switch( inst.Exec( state ) ) {
	    case RT_HLT:
          return false;
    	case RT_DONE:
          fInstDone = true;
          break;
	    case RT_CONTINUE:
          break;                    
	    case RT_ERROR:
          Error("ERROR is returned by current instruction");
          return false;
	    default:
          Error("Invalid return message is found.");
          return false;
    }
    return true;
  }

  void Dump() {
    TextArea regArea = new TextArea(LEFT_OFFSET, TOP_OFFSET);
    regArea.Append( "[ count ]" );
    regArea.Append( "" + count );

    regArea.Append("");
    regArea.Append("");
    regArea.Append("[ registers ] ");
    regArea.Append("PC  : 0x" + hexConverter.decimal2hex(state.GetPc(), 4));
    regArea.Append("IR  : 0x" + hexConverter.decimal2hex(state.ir     , 2));
    regArea.Append("ACC : 0x" + hexConverter.decimal2hex(state.acc    , 4));
    regArea.Append("IX  : 0x" + hexConverter.decimal2hex(state.ix     , 4));
    regArea.Append("MAR : 0x" + hexConverter.decimal2hex(state.mar    , 4));

    regArea.Append("");
    regArea.Append("");
    regArea.Append("[ flags ]");
    regArea.Append("Carry    : " + state.flagCf);
    regArea.Append("Overflow : " + state.flagVf);
    regArea.Append("Negative : " + state.flagNf);
    regArea.Append("Zero     : " + state.flagZf);

    regArea.Append("");
    regArea.Append("");
    regArea.Append( "[ instruction ]" );
    regArea.Append( "Asm");
    regArea.Append( "  " + ((inst != null) ?   inst.GetAsmStr()           : "no instruction"));
    regArea.Append( "Phase");
    regArea.Append( "  " + ((inst != null) ? ((inst.NextPhase() + 4) % 5) : "no instruction"));

    regArea.Print();
    

    // memory
    TextArea memArea = new TextArea(LEFT_OFFSET + BASE_COLUMN_WIDTH, TOP_OFFSET);
    memArea.Append("[ memory ]");

    final int NUM_COLUMNS = 16;

    String header = "        ";
    for(int col = 0; col < NUM_COLUMNS; col++) {
      Integer addr   = (col * 2) & 0xff;
      String hexAddr = hexConverter.decimal2hex(addr, 2);
      header += ((col % 4 == 0 ? "  0x" : " 0x") + hexAddr);
    }
    memArea.Append(header);

    for(int lin = 0; !memArea.IsFull(); lin++) { // instead of 'line' (reserved)
      String buf = "";

      Integer baseAddr = printStartAddress + NUM_COLUMNS * lin * 2;
      buf += ("0x" + hexConverter.decimal2hex(baseAddr, 4) + " :");
      
      for(int col = 0; col < NUM_COLUMNS; col++) {
        Integer addr = baseAddr + col * 2;
        String data  = hexConverter.decimal2hex(state.GetMem(addr), 4);
        buf += ((col % 4 == 0 ? "  " : " ") + data);
      }
      memArea.Append(buf);
    }
    memArea.Print();

  }

  
  // private
  private InstBase inst;
  private KueState state;
  private Boolean  fInstDone = true;

  private int ExecStep(){ return RT_DONE; }
  private int ExecInst(){ return RT_DONE; }
  private int ExecAll() { return RT_DONE; }
  private void Reset(){}
}
