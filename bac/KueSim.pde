class KueSim {
  // public
  KueSim() {
    println("Start Kuechip3 Simulater.\n");
    state = new KueState();
  }

  Boolean Update() {
    if( inst == null ) {
      inst = instFactory.CreateInst(0);
    }

    switch( inst.Exec( state ) ) {
	    case RT_HLT:
          return false;
    	case RT_DONE:
          inst = null;
          break;
	    case RT_CONTINUE:
          break;                    
	    case RT_ERROR:          // FallThrough
	    default:
          println("internal error");
    	  System.exit(0);
    }
    return true;
  }

  void Dump() {
    println("");
    println("[state dump]");
    println("PC : " + state.PC);
    println("IR : " + state.IR);
    println("ACC: " + state.ACC);
    println("IX : " + state.IX);
    println("MAR: " + state.MAR);
    println("CarryFlag   : " + state.FLAG_CF);
    println("OverflowFlag: " + state.FLAG_VF);
    println("NegativeFlag: " + state.FLAG_NF);
    println("ZeroFlag    : " + state.FLAG_ZF);

    println("imem");
    for(int i = 0; i < 10; i++) {
      // println("  imem[" + i + "]: " + state.imem[i]);
    }

    println("dmem");
    for(Integer i = 0; i < 32; i++) {
      // String strAddr = hexConverter.decimal2hex(i, 4);
      // println("0x" + strAddr + " : 0x" + hexConverter.decimal2hex(state.dmem[i], 16));
    }
    println("");
  }
  
  // private
  private InstBase inst;
  private KueState state;

  private int ExecStep(){ return RT_DONE; }
  private int ExecInst(){ return RT_DONE; }
  private int ExecAll() { return RT_DONE; }
  private void Reset(){}
}