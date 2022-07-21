// ID of operand A and B
final int OPERAND_ACC     = 0;  // reg ACC
final int OPERAND_IX      = 1;  // reg IX
final int OPERAND_SP      = 10; // reg SP
final int OPERAND_IMM     = 2;  // immidiate
final int OPERAND_IDX_SP  = 3;  // index
final int OPERAND_ABS     = 4;  // absolute
// final int OPERAND_ABS     = 5;  // not in use
final int OPERAND_IDX_IX  = 6;  // index (program area)


//**************************************************
// @classname  InstSt
// @brief      implementation of phase 2-4 of 'ST'
// @概要       ST 命令のフェイズ 2-4 の実装
//**************************************************

class InstSt extends InstBase {
  protected int operandIdA = -1; // specify which register to use
  protected int operandIdB = -1; // specify which operand (register or memory) to use
  String strOperandA, strOperandB;

  InstSt(final int A_OPERAND, final int B_OPERAND) { // ctor

    // operand check
    operandIdA = A_OPERAND;
    operandIdB = B_OPERAND;

    MakeAsmStr();
  }


  protected int Exec_P2(KueState state) {
    state.mar = state.GetPc();
    state.IncPc();
    return RT_CONTINUE;
  }


  protected int Exec_P3(KueState state){
    if     ( operandIdB == OPERAND_ABS    ) {
      state.mar = state.GetMem(state.mar);
    }
    else if( operandIdB == OPERAND_IDX_IX ) {
   // state.mar = alu.exec(state.ix, state.GetMem(state.mar), state, CMD_ADD);
      state.mar = (state.ix + state.GetMem(state.mar)) & 0xffff;
    }
    else if( operandIdB == OPERAND_IDX_SP ) {
   // state.mar = alu.exec(state.sp, state.GetMem(state.mar), state, CMD_ADD);
      state.mar = (state.sp + state.GetMem(state.mar)) & 0xffff;
    }
    else {
      Error("[internal error] Found an invalid operand B in InstSt.");
      return RT_ERROR;
    }

    return RT_CONTINUE;
  }


  protected int Exec_P4(KueState state){
    if     (operandIdA == OPERAND_ACC) { state.SetMem(state.mar, state.acc); }
    else if(operandIdA == OPERAND_IX ) { state.SetMem(state.mar, state.ix);  }
    else {
      Error("[internal error] Found an invalid operand A in InstSt.");
      return RT_ERROR;
    }
    return RT_DONE;
  }

  protected void MakeAsmStr() {
    if     ( operandIdA == OPERAND_ACC ) { strOperandA = "ACC"; }
    else if( operandIdA == OPERAND_IX  ) { strOperandA = "IX";  }
    else {
      Error("[internal error] Found an invalid operand A in MakeAsm of InstSt.");
      return;
    }

    if     ( operandIdB == OPERAND_ACC    ) { strOperandB = "ACC"; }
    else if( operandIdB == OPERAND_IX     ) { strOperandB = "IX";  }
    else if( operandIdB == OPERAND_IMM    ) { strOperandB = "IMM"; }
    else if( operandIdB == OPERAND_ABS    ) { strOperandB = "ABS"; }
    else if( operandIdB == OPERAND_IDX_IX ) { strOperandB = "IX(x)"; }
    else if( operandIdB == OPERAND_IDX_SP ) { strOperandB = "SP(x)"; }
    else {
      Error("[internal error] Found an invalid operand B in MakeAsm of InstSt.");
      return;
    }
  }


  protected String GetAsmStr() {
    return "ST   " + strOperandA + " " + strOperandB;
  }

}
