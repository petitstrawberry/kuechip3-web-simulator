final int CMD_BA  = 0;
final int CMD_BNZ = 1;
final int CMD_BZP = 2;
final int CMD_BP  = 3;
final int CMD_BNI = 4;
final int CMD_BNC = 5;
final int CMD_BGE = 6;
final int CMD_BGT = 7;
final int CMD_BVF = 8;
final int CMD_BZ  = 9;
final int CMD_BN  = 10;
final int CMD_BZN = 11;
final int CMD_BNO = 12;
final int CMD_BC  = 13;
final int CMD_BLT = 14;
final int CMD_BLE = 15;

//**************************************************
// @classname  InstBcc
// @brief      implementation of phase 2-4 of 'Bcc'
// @概要       分岐命令のフェイズ 2-4 の実装
//**************************************************

// a list of instructions ob 'Bcc'
// - BA
// - BVF
// - BNZ
// - BZ
// - BP
// - BZN
// - BNI
// - BNO
// - BNC
// - BC
// - BGE
// - BLT
// - BGT
// - BLE

class InstBcc extends InstBase {
  int inst = 0;
  
  public InstBcc(int INST) {
    inst = INST;
  }
  
  protected int Exec_P2(KueState state) {
    state.mar = state.GetPc();
    state.IncPc();
    return RT_CONTINUE;
  }

  protected int Exec_P3(KueState state) {
    // check status flags
    Boolean fBranch = CheckStatus(state, inst);

    if( fBranch ) {
      state.SetPc( state.GetMem(state.mar) );
    }
    return RT_DONE;
  }

  protected int Exec_P4(KueState state) { return RT_ERROR; }
  
  Boolean CheckStatus(KueState state, int inst) {
    switch(inst) {
      case CMD_BA :  return true;
      case CMD_BVF:  return  state.flagVf;
      case CMD_BNZ:  return !state.flagZf;
      case CMD_BZ :  return  state.flagZf;
      case CMD_BZP:  return !state.flagNf;
      case CMD_BN :  return  state.flagNf;
      case CMD_BP :  return !(state.flagNf | state.flagZf);
      case CMD_BZN:  return  (state.flagNf | state.flagZf);
      case CMD_BNI:  return true;
      case CMD_BNO:  return true;
      case CMD_BNC:  return !state.flagCf;
      case CMD_BC :  return  state.flagCf;
      case CMD_BGE:  return !(state.flagVf ^ state.flagNf);
      case CMD_BLT:  return  (state.flagVf ^ state.flagNf);
      case CMD_BGT:  return !((state.flagVf ^ state.flagNf) | state.flagZf);
      case CMD_BLE:  return  ((state.flagVf ^ state.flagNf) | state.flagZf);
      default: // FALL-THROUGH
    }
    Error("[internal error] Found an invalid branch command in InstBcc.");
    return false;
  }

  protected String GetAsmStr() {
    return "BCC"; //   " + strOperandA + " " + strOperandB;
  }
  
}
