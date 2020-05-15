// TODO: !!!!!! OPERAND_ABS check !!!!!!

//*****************************************************
// @classname  InstAlu
// @brief      phase 2-4 of instructions using ALU
// @概要       ALU を使用する命令のフェイズ 2-4 の実装
//*****************************************************

// a list of instructions using ALU
// - SBC
// - ADC
// - SUB
// - ADD
// - EOR
// - OR
// - AND
// - CMP

abstract class InstAlu extends InstBase {
  protected int cmd = -1;
  protected int operandIdA = -1; // specify which register to use
  protected int operandIdB = -1; // specify which operand (register or memory) to use

  InstAlu(final int A_OPERAND, final int B_OPERAND, final int CMD, String ASM) {
    super(ASM);                 // set assembly string to display

    // operand check
    operandIdA = A_OPERAND;
    operandIdB = B_OPERAND;
    cmd = CMD;
  }

  protected int Exec_P2(KueState state) {
    state.mar = state.GetPc();
    state.IncPc();
    return RT_CONTINUE;
  }

  abstract protected int Exec_P3(KueState state);
  abstract protected int Exec_P4(KueState state);
}

// TODO: add explanation of each class

//**************************************************
// @classname  InstAlu_AccIx
// @brief      instructions of ALU
//               -- 1st operand: ACC / IX
//               -- 2nd operand: ACC / IX
// @概要       ACC / IX がオペランドの命令
//**************************************************
class InstAlu_AccIx extends InstAlu {
  public InstAlu_AccIx(int A_OPERAND, int B_OPERAND, int CMD, String ASM) {
    super(A_OPERAND, B_OPERAND, CMD, ASM);
  }


  protected int Exec_P2(KueState state) {
    Integer operandB = null;
    if      ( operandIdB == OPERAND_ACC ) { operandB = state.acc; }
    else if ( operandIdB == OPERAND_IX  ) { operandB = state.ix;  }
    else {
      Error("[internal error] Found an invalid operand B in InstAlu_AccIx.");
      return RT_ERROR;
    }

    // execute the operation
    if      (operandIdA == OPERAND_ACC ) { state.acc = alu.exec(state.acc, operandB, state, cmd); }
    else if (operandIdA == OPERAND_IX  ) { state.ix  = alu.exec(state.ix , operandB, state, cmd); }
    else {
      Error("[internal error] Found an invalid operand A in InstAlu_AccIx.");
      return RT_ERROR;
    }

    return RT_DONE;
  }

  protected int Exec_P3(KueState state) { return RT_ERROR; }
  protected int Exec_P4(KueState state) { return RT_ERROR; }
}


//**************************************************
// @classname  InstAlu_Imm
// @brief      instructions of ALU
//               -- 1st operand: ACC / IX / SP
//               -- 2nd operand: immediate address
// @概要       第一オペランドが ACC / IX / SP レジスタ
//             第二オペランドが即値アドレスの命令
//**************************************************
class InstAlu_Imm extends InstAlu {
  public InstAlu_Imm(int A_OPERAND, int B_OPERAND, int CMD, String ASM) {
    super(A_OPERAND, B_OPERAND, CMD, ASM);
  }


  protected int Exec_P3(KueState state) {
    int operandB = state.GetMem(state.mar);
    if      ( operandIdA == OPERAND_ACC ) { state.acc = alu.exec(state.acc, operandB, state, cmd); }
    else if ( operandIdA == OPERAND_IX  ) { state.ix  = alu.exec(state.ix , operandB, state, cmd); }
    else if ( operandIdA == OPERAND_SP  ) { state.sp  = alu.exec(state.sp , operandB, state, cmd); }
    else {
      Error("[internal error] Found an invalid operand A in InstAlu_Imm.");
      return RT_ERROR;
    }

    return RT_DONE;
  }

  protected int Exec_P4(KueState state) { return RT_ERROR; }
}


//**************************************************
// @classname  InstAlu_Abs
// @brief      instructions of ALU
//               -- 1st operand: ACC / IX register
//               -- 2nd operand: absolute address
// @概要       第一オペランドが ACC / IX レジスタ
//             第二オペランドが絶対アドレスの命令
//**************************************************
class InstAlu_Abs extends InstAlu {
  public InstAlu_Abs(int A_OPERAND, int B_OPERAND, int CMD, String ASM) {
    super(A_OPERAND, B_OPERAND, CMD, ASM);
  }


  protected int Exec_P3(KueState state) {
    state.mar = state.GetMem(state.mar);
    return RT_CONTINUE;
  }


  protected int Exec_P4(KueState state) {

    if     ( operandIdB == OPERAND_ABS ) { operandB = state.GetMem(state.mar); }
    else {
      Error("[internal error] Found an invalid operand B in InstAlu_Abs.");
      return RT_ERROR;
    }

    if     ( operandIdA == OPERAND_ACC ) { state.acc = alu.exec(state.acc, operandB, state, cmd); }
    else if( operandIdA == OPERAND_IX  ) { state.ix  = alu.exec(state.ix , operandB, state, cmd); }
    else {
      Error("[internal error] Found an invalid operand A in InstAlu_Abs.");
      return RT_ERROR;
    }

    return RT_DONE;
  }
}

//**************************************************
// @classname  InstAlu_AbsIx
// @brief      instructions of ALU
//               -- 1st operand: ACC / IX register
//               -- 2nd operand: index addressing
// @概要       第一オペランドが ACC / IX レジスタ
//             第二オペランドがインデックス修飾アドレスの命令
//**************************************************
class InstAlu_AbsIx extends InstAlu {
  public InstAlu_AbsIx(int A_OPERAND, int B_OPERAND, int CMD, String ASM) {
    super(A_OPERAND, B_OPERAND, CMD, ASM);
  }


  protected int Exec_P3(KueState state) {
    Integer operandA = null;
    if     ( operandIdB == OPERAND_IDX_IX ) { operandA = state.ix; }
    else if( operandIdB == OPERAND_IDX_SP ) { operandA = state.sp; }
    else {
      Error("[internal error] Found an invalid operand B in InstAlu_AbsIx.");
      return RT_ERROR;
    }

    state.mar = alu.exec(operandA, state.GetMem(state.mar), state, CMD_ADD);
    return RT_CONTINUE;
  }


  protected int Exec_P4(KueState state) {
    int operandB = state.GetMem(state.mar);

    if     ( operandIdA == OPERAND_ACC ) { state.acc = alu.exec(state.acc, operandB, state, cmd); }
    else if( operandIdA == OPERAND_IX  ) { state.ix  = alu.exec(state.ix , operandB, state, cmd); }
    else {
      Error("[internal error] Found an invalid operand A in InstAlu_AbsIx.");
      return RT_ERROR;
    }

    return RT_DONE;
  }
}