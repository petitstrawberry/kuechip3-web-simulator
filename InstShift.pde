//**************************************************
// @classname  InstShift
// @brief      implementation of phase 2-4 of 'Ssm & Rsm'
// @概要       Shift & Rotate 命令のフェイズ 2-4 の実装
//**************************************************

// a list of instructions of Ssm & Rsm
// - SRA (Shift Right Arithmetically)
// - SLA (Shift Left Arithmetically)
// - SRL (Shift Right Logically)
// - SLL (Shift Left Logically)
// - RRA (Rotate Right Arithmetically)
// - RLA (Rotate Left Arithmetically)
// - RRL (Rotate Right Logically)
// - RLL (Rotate Left Logically)

final int CMD_SRA = 0;
final int CMD_SLA = 1;
final int CMD_SRL = 2;
final int CMD_SLL = 3;
final int CMD_RRA = 4;
final int CMD_RLA = 5;
final int CMD_RRL = 6;
final int CMD_RLL = 7;

class InstShift extends InstBase {
  int cmd = -1;
  int msb = -1; // bf
  int lsb = -1; // b0
  int cf  = -1;
  Integer res = null;
  Boolean fOperand[] = new Boolean[2];


  InstShift (final int OPERAND, final int CMD) {
    for(int i = 0; i < fOperand.length; i++) {
      fOperand[i] = false;
    }
    fOperand[OPERAND] = true;
    cmd = CMD;
  }
  
  protected int Exec_P2 (KueState state) {
    if(fOperand[OPERAND_ACC]) {
      lsb = state.acc & 0x1;    // prepare for function 'shift'
      msb = (state.acc >> 15) & 0x1;
      state.acc = shift(state.acc, state.flagCf);
      res = state.acc;
      // state.acc = alu.exec(state.acc, -1, state, cmd);
    }
    else if(fOperand[OPERAND_IX]) {
      lsb = state.ix & 0x1;
      msb = (state.ix >> 15) & 0x1;
      state.ix = shift(state.ix, state.flagCf);
      res = state.ix;
      // state.ix = alu.exec(state.ix, -1, state, cmd);
    }
    else {
      sysLog.Append("Found an internal error.");
      return RT_ERROR;
    }

    return RT_CONTINUE;
  }


  protected int Exec_P3 (KueState state) {
    // flag set
    state.flagCf = (cf==1) ? true : false; // 2017.01.04
    state.flagNf = GetFlagNf(res);
    state.flagZf = GetFlagZf(res);
    state.flagVf = false; // overwritten VF in case of SLA and RLA
    switch(cmd) {
      case CMD_SLA:
      case CMD_RLA:
        state.flagVf = state.flagCf;
        break;
      default: break;    
    } // 2017.01.04
/*
    lsb = res & 0x1;
    msb = (res >> 15) & 0x1;
    switch(cmd) {
      case CMD_SRA:
      case CMD_SRL:
      case CMD_RRA:
      case CMD_RRL:
        state.flagCf = (lsb==1) ? true : false;
        break;
      case CMD_SLA:
      case CMD_RLA:
        state.flagVf = state.flagCf;
        // FALLTHROUGH
      case CMD_SLL:
      case CMD_RLL:
        state.flagCf = (msb==1) ? true : false;
        break;
    }
*/
    return RT_DONE;
  }


  protected int Exec_P4 (KueState state) { return RT_ERROR; }
  
  Integer shift (Integer value, Boolean cfP2) {
    switch(cmd) {
      case CMD_SRA:
        cf = lsb; value = value >> 1;
        if (msb == 1) value = value | 0x8000;
        else value = value & 0x7fff;
        break;
      case CMD_SLA:
      case CMD_SLL:
        cf = msb; value = (value << 1) & 0xfffe;
        break;
      case CMD_SRL:
        cf = lsb; value = (value >> 1) & 0x7fff;
        break;
      case CMD_RRA:
        cf = lsb; value = value >> 1;
        if (cfP2 == true) value = value | 0x8000;
        else value = value & 0x7fff;
        break;
      case CMD_RLA:
        cf = msb; value = value << 1;
        value = value | (cfP2 == true ? 1 : 0);
        break;
      case CMD_RRL:
        cf = lsb; value = value >> 1;
        if (lsb == 1) value = value | 0x8000;
        else value = value & 0x7fff;
        break;
      case CMD_RLL:
        cf = msb; value = value << 1;
        value = value | msb;
        break;
      }
    return value & 0xffff;
  }

  protected String GetAsmStr() {
    return "SHIFT / ROTATE"; //   " + strOperandA + " " + strOperandB;
  }
}