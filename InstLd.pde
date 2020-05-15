//**************************************************
// @classname  InstLd
// @brief      implementation of phase 2-4 of 'LD'
// @概要       LD 命令のフェイズ 2-4 の実装
//**************************************************

abstract class InstLd extends InstBase {
  protected int operandIdA = -1; // specify which register to use
  protected int operandIdB = -1; // specify which operand (register or memory) to use
  String strOperandA, strOperandB;

  protected InstLd(final int A_OPERAND, final int B_OPERAND, String asm) { // ctor
    super(asm);

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

  abstract protected int Exec_P3(KueState state);
  abstract protected int Exec_P4(KueState state);

  protected void MakeAsmStr() {
    if     ( operandIdA == OPERAND_ACC ) { strOperandA = "ACC"; }
    else if( operandIdA == OPERAND_IX  ) { strOperandA = "IX";  }
    else {
      Error("[internal error] Found an invalid operand A in LD");
    }

    if     ( operandIdB == OPERAND_ACC )    { strOperandB = "ACC"; }
    else if( operandIdB == OPERAND_IX  )    { strOperandB = "IX";  }
    else if( operandIdB == OPERAND_IMM )    { strOperandB = "IMM"; }
    else if( operandIdB == OPERAND_ABS )    { strOperandB = "ABS"; }
    else if( operandIdB == OPERAND_IDX_IX ) { strOperandB = "IX(x)"; }
    else {
      Error("[internal error] Found an invalid operand B in LD");
    }
  }

  protected String GetAsmStr() {
    return "LD   " + strOperandA + " " + strOperandB;
  }
}


//**************************************************
// @classname  InstLd_AccIx
// @brief      instructions of LD
//               -- 1st operand: ACC / IX / SP
//               -- 2nd operand: ACC / IX / SP
// @概要       ACC / IX / SP がオペランドの LD 命令
//**************************************************

class InstLd_AccIx extends InstLd {
  public InstLd_AccIx(final int A_OPERAND, final int B_OPERAND, String asm) {
    super(A_OPERAND, B_OPERAND, asm);
  }

  protected int Exec_P2 (KueState state) {
    int operandB = -1;
    if     (operandIdB == OPERAND_ACC) { operandB = state.acc; }
    else if(operandIdB == OPERAND_IX ) { operandB = state.ix;  }
    else if(operandIdB == OPERAND_SP ) { operandB = state.sp;  }
    else {
      Error("[internal error] Found an invalid operand A in InstLd_IccIx.");
      return RT_ERROR;
    }

    if     (operandIdA == OPERAND_ACC) { state.acc = operandB; }
    else if(operandIdA == OPERAND_IX ) { state.ix  = operandB; }
    else if(operandIdA == OPERAND_SP ) { state.sp  = operandB; }
    else {
      Error("[internal error] Found an invalid operand B in InstLd_IccIx.");
      return RT_ERROR;
    }

    return RT_DONE;
  }

  protected int Exec_P3 (KueState state) { return RT_ERROR; }
  protected int Exec_P4 (KueState state) { return RT_ERROR; }
}


//**************************************************
// @classname  InstLd_Imm
// @brief      instructions of LD
//               -- 1st operand: ACC / IX / SP
//               -- 2nd operand: immediate address
// @概要       第一引数が ACC / IX / SP レジスタ
//             第二オペランドが即値アドレスの LD 命令
//**************************************************

class InstLd_Imm extends InstLd {

  public InstLd_Imm(final int A_OPERAND, final int B_OPERAND, String asm) {
    super(A_OPERAND, B_OPERAND, asm);
  }

  protected int Exec_P3 (KueState state) {
    if     (operandIdA == OPERAND_ACC)  state.acc = state.GetMem(state.mar);
    else if(operandIdA == OPERAND_IX )  state.ix  = state.GetMem(state.mar);
    else if(operandIdA == OPERAND_SP )  state.sp  = state.GetMem(state.mar);
    else {
      Error("[internal error] Found an invalid operand A in InstLd_Imm.");
      return RT_ERROR;
    }

    return RT_DONE;
  }

  protected int Exec_P4 (KueState state) { return RT_ERROR; }
}

//**************************************************
// @classname  InstLd_Abs
// @brief      instructions of LD
//               -- 1st operand: ACC / IX register
//               -- 2nd operand: absolute address
// @概要       第一オペランドが ACC / IX レジスタ
//             第二オペランドが絶対アドレスの LD 命令
//**************************************************

class InstLd_Abs extends InstLd {

  public InstLd_Abs(final int A_OPERAND, final int B_OPERAND, String asm) {
    super(A_OPERAND, B_OPERAND, asm);
  }

  protected int Exec_P3 (KueState state) {
    state.mar = state.GetMem(state.mar);
    return RT_CONTINUE;
  }

  protected int Exec_P4 (KueState state) {
    if     (operandIdA == OPERAND_ACC) { state.acc = state.GetMem(state.mar); }
    else if(operandIdA == OPERAND_IX ) { state.ix  = state.GetMem(state.mar); }
    else {
      Error("[internal error] Found an invalid operand A in InstLd_Abs.");
      return RT_ERROR;
    }
    return RT_DONE;
  }
}


//**************************************************
// @classname  InstLd_Idx
// @brief      instructions of LD
//               -- 1st operand: ACC / IX register
//               -- 2nd operand: index addressing
// @概要       第一オペランドが ACC / IX レジスタ
//             第二オペランドがインデックス修飾アドレスの命令
//**************************************************

class InstLd_Idx extends InstLd {

  public InstLd_Idx(final int A_OPERAND, final int B_OPERAND , String asm) {
    super(A_OPERAND, B_OPERAND, asm);
  }

  protected int Exec_P3 (KueState state) {
    // TODO: switch by operand (OPERAND_IDX_IX or OPERAND_IDX_SP)
    Integer base = null;
    if      ( operandIdB == OPERAND_IDX_IX ) { base = state.ix; }
    else if ( operandIdB == OPERAND_IDX_SP ) { base = state.sp; }
    else {
      Error("[internal error] Found an invalid base register in InstLd_Idx.");
      return RT_ERROR;
    }

    state.mar = alu.exec(base, state.GetMem(state.mar), state, CMD_ADD);
    return RT_CONTINUE;
  }
  protected int Exec_P4 (KueState state) {
    if     (operandIdA == OPERAND_ACC) { state.acc = state.GetMem(state.mar); }
    else if(operandIdA == OPERAND_IX ) { state.ix  = state.GetMem(state.mar); }
    else {
      Error("[internal error] Found an invalid operand A in InstLd_Idx.");
      return RT_ERROR;
    }
    return RT_DONE;
  }
}