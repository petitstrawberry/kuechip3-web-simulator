// constants
//   instead of enum (not available in processing.js)

final int P0 = 0;
final int P1 = 1;
final int P2 = 2;
final int P3 = 3;
final int P4 = 4;

public static final int MAX_MEM_ADDR = 65535;
public static final int MEM_SIZE     = (MAX_MEM_ADDR + 1) / 2;

class KueState {
  // !!!! Don't access private field directly !!!!
  // !!!! In procesing, access qualifiers don't work correct.
  // !!!! (So you can access them ...)
  private Integer pc;
  public Integer sp;
  public Integer ir;
  public Integer acc;
  public Integer ix;
  public Integer mar;
  public boolean flagCf;
  public boolean flagVf;
  public boolean flagNf;
  public boolean flagZf;  
  private Integer mem[];

  public InstBase inst;
  public int phase;

  public Integer ibuf;
  public Integer obuf;
  public boolean ibuf_re;       // read enable
  public boolean obuf_we;       // write enable
  public boolean ibuf_flg_clr;  // flag_clear

  public Integer currentInstAddr;
  
  public KueState() {
    // registers
    pc  = 0;
    sp  = 0;
    ir  = 0;
    acc = 0;
    ix  = 0;
    mar = 0;
    flagCf = false;
    flagVf = false;
    flagNf = false;
    flagZf = false;

    // memory
    mem  = new Integer[MEM_SIZE];

    // current step of executing inst
    phase = P0;

    // for inst 'IN' and 'OUT'
    ibuf = 0;
    obuf = 0;
    ibuf_re      = false;
    obuf_we      = false;
    ibuf_flg_clr = false;

    currentInstAddr = pc;
    
    // init (for debug)
    for(int addr = 0; addr < MAX_MEM_ADDR; addr += 2) { SetMem(addr, null); }
    // for(int addr = 0; addr < MAX_MEM_ADDR; addr += 2) { SetMem(addr, 0xFFFF); }

    // int insts[] = pg_memtest; // select test program    
    // for(int i = 0; i < insts.length; i++) {
    //   SetMem(i * 2, insts[i]);
    // }
  }


  public void init(
    Integer pc_, Integer pc, Integer ir_, Integer acc_, Integer ix_, Integer mar_,
    Boolean flagCf_, Boolean flagVf_, Boolean flagNf_, Boolean flagZf_,
    int mem_[] )
  {
    pc     = pc_;
    ir     = ir_;
    acc    = acc_;
    ix     = ix_;
    mar    = mar_;
    flagCf = flagCf_;
    flagVf = flagVf_;
    flagNf = flagNf_;
    flagZf = flagZf_;

    for(int i = 0; i < MEM_SIZE; i++) { mem[i] = mem_[i]; }
  }
  

  // accessor methods (Overloading functions is unavailable in javascript.)
  public void SetMem(Integer addr, Integer data) {
    if( ! IsValidAddress(addr) ) {
      Error("Fatal error.");
      return;
    }

    addr = FixAddressToEven(addr);
    mem[addr / 2] = data;
  }

  public Integer GetMem(Integer addr) {
    if( ! IsValidAddress(addr) ) {
      Error("Fatal error.");
      return null;
    }

    addr = FixAddressToEven(addr);
    return mem[addr / 2];
  }

  private Integer FixAddressToEven(Integer addr) {
    // illegal address check
    if ( addr % 2 != 1 ) {
      return addr;
    }
      
    String strHex = (hexConverter != null
                     ? hexConverter.decimal2hex(addr, 4) // convert to Hex
                     : "" + addr);                       // only cast to String
    sysLog.Append("[warning] 0x" + strHex + " is not aligned in 2byte.");
    println("[warning] 0x" + strHex + " is not aligned in 2byte.");
    return addr - 1;
  }

    
  
  private boolean IsValidAddress(Integer addr) {
    // range check
    if ( addr < 0 || MAX_MEM_ADDR < addr ) {
      sysLog.Append("Failed to set data in memory (out of range 0x0000-0xFFFF)");
      return false;
    }

    return true;
  }

  public void IncPc() { pc += 2; }  // increment : use instead of pc++
  public void SetPc(Integer data) { pc = data; }
  public Integer GetPc() { return pc; }
  

  // Sample programs of kuechip 3
  //   note) invalid instructions are : 0x77, 0xf7, 0xff

  int pg_sum[] = new int[] {
    0x74, 0x15, 0xc0, 0xb4, 0x15, 0xaa, 0x01, 0x31, 0x03, 0x0f
  };

  int pg_memtest[] = new int[] {
      // PLOG: 0x0000
      0x00c0,
      0x006a, 0x0054,  // TEST, 0x47
   // 0x006a, 0xffff,  // TEST, 0x47
      // LP0: 0x0003
      0x0076, 0x0000,   
      0x00ba, 0x0002,  // 0x01,
      0x00fa, 0x0000,  // PLOG:
      0x0031, 0x0006,  // LP0:
   // 0x00c9,
   // 0x0077, 0x0000,
   // 0x00ba, 0x0001,
   // 0x0031, 0x000c,
      // LP2:
      0x006a, 0x0054,  // 0x47, TEST:
      // LP3:
      0x00f6, 0x0000,
      0x0031, 0x0052,  // 0x46, ERR:
      0x00c2, 0x8000,
      0x0047,
      0x0076, 0x0000,
      0x0039, 0x0038,  // NX3: 0x23,
      0x00f2, 0xffff,
      0x0031, 0x001a,  // LP3: 0x14
      // NX3:
      0x00c2, 0xffff,  // 0xff,
      0x00ba, 0x0002,
      0x00fa, 0x0000,
      0x0031, 0x001a,  // LP3:
   // 0x00c9,
   // 0x00f7, 0x0000,
   // 0x0031, 0x0046,
   // 0x00c2, 0x0080,
   // 0x0047,
   // 0x0077, 0x0000,
   // 0x0039, 0x003b,
   // 0x00f2, 0x00ff,
   // 0x0031, 0x002c,
      // NX4:
   // 0x00c2, 0x00ff,  // 0x00ff,
   // 0x00ba, 0x0001,
   // 0x0031, 0x002c,  // 0x2c LP4
      0x00c2, 0xffff,  // 0x00ff,
      0x0010,
      0x0030, 0x0016,  // 0x0012,
      // ERR: = 0x0092
      0x000f
  };

}
