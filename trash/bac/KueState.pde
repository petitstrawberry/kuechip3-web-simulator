class KueState {
  public Integer PC;
  public Integer IR;
  public Integer ACC;
  public Integer IX;
  public Integer MAR;
  public boolean FLAG_CF;
  public boolean FLAG_VF;
  public boolean FLAG_NF;
  public boolean FLAG_ZF;  
  public Integer imem[];
  public Integer dmem[];

  public Integer ReadMem(Integer addr) {
    return imem[addr];
  }
  
  public void WriteMem(Integer addr, Integer data) {
    imem[addr] = data;
  }

  public static final int memSize = 1024;
  
  public KueState() {
    PC  = 0;
    IR  = 0;
    ACC = 0;
    IX  = 0;
    MAR = 0;
    FLAG_CF = false;
    FLAG_VF = false;
    FLAG_NF = false;
    FLAG_ZF = false;
    imem = new Integer[memSize]; // size ??
    dmem = new Integer[memSize]; // size ??

    for(int i = 0; i < memSize; i++) {
      imem[i] = new Integer(i);
      dmem[i] = new Integer(i);
    }
  }
}
