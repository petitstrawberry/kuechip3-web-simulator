// TODO: check sp insts : especially, Are LD, ST and ALU fixed?
// TODO: alignment (sp++ -> sp += 2)

//**************************************************
// @classname  InstInc
// @brief      implementation of phase 2-4 of 'INC'
// @概要       INC 命令のフェイズ 2-4 の実装
//**************************************************

class InstInc extends InstBase {
  public InstInc(String asm) { super(asm); }
  
  protected int Exec_P2 (KueState state) {
    state.sp = alu.exec(state.sp, +2, state, CMD_ADD);
    return RT_DONE;
  }
  
  protected int Exec_P3 (KueState state) { return RT_ERROR; }
  protected int Exec_P4 (KueState state) { return RT_ERROR; }
}


//**************************************************
// @classname  InstDec
// @brief      implementation of phase 2-4 of 'DEC'
// @概要       DEC 命令のフェイズ 2-4 の実装
//**************************************************

class InstDec extends InstBase {
  public InstDec(String asm){ super(asm); }

  protected int Exec_P2 (KueState state) {
    state.sp = alu.exec(state.sp, -2, state, CMD_ADD);
    return RT_DONE;
  }

  protected int Exec_P3 (KueState state) { return RT_ERROR; }
  protected int Exec_P4 (KueState state) { return RT_ERROR; }
}


//**************************************************
// @classname  InstPsh
// @brief      implementation of phase 2-4 of 'PSH'
// @概要       PSH 命令のフェイズ 2-4 の実装
//**************************************************

class InstPsh extends InstBase {
  public InstPsh(int r, String asm){ super(asm); reg = r; }

  // protected
  protected int Exec_P2 (KueState state) {
    state.mar = state.sp - 2;
    state.sp -= 2;
    return RT_CONTINUE;
  }

  protected int Exec_P3 (KueState state) {
    if     ( reg == OPERAND_ACC )  state.SetMem(state.mar, state.acc);
    else if( reg == OPERAND_IX  )  state.SetMem(state.mar, state.ix);
    else                           Error("Found a invalid operand in PSH");
    return RT_DONE;
  }
  
  protected int Exec_P4 (KueState state) { return RT_ERROR; }

  // private
  private int reg = -1;
}


//**************************************************
// @classname  InstPop
// @brief      implementation of phase 2-4 of 'POP'
// @概要       POP 命令のフェイズ 2-4 の実装
//**************************************************

class InstPop extends InstBase {
  public InstPop(int r, String asm){ super(asm); reg = r; }

  // protected
  protected int Exec_P2 (KueState state) {
    state.mar = state.sp;
    state.sp += 2;
    return RT_CONTINUE;
  }

  protected int Exec_P3 (KueState state) {
    if     ( reg == OPERAND_ACC )  state.acc = state.GetMem(state.mar);
    else if( reg == OPERAND_IX  )  state.ix  = state.GetMem(state.mar); 
    else                           Error("Found a invalid operand in PSH");
    return RT_DONE;
  }

  protected int Exec_P4 (KueState state) { return RT_ERROR; }

  // private
  private int reg = -1;
}


//**************************************************
// @classname  InstCal
// @brief      implementation of phase 2-4 of 'CAL'
// @概要       CAL 命令のフェイズ 2-4 の実装
//**************************************************

class InstCal extends InstBase {
  public InstCal(String asm){ super(asm); }

  // protected
  protected int Exec_P2 (KueState state) {
    state.mar = state.sp - 2;
    state.sp  = state.sp - 2;
    // state.IncPc();
    return RT_CONTINUE;
  }

  protected int Exec_P3 (KueState state) {
    state.SetMem(state.mar, state.pc + 2);
    state.mar = state.pc;
    return RT_CONTINUE;
  }
  
  protected int Exec_P4 (KueState state) {
    state.pc = state.GetMem(state.mar);
    return RT_DONE;
  }
}


//**************************************************
// @classname  InstRet
// @brief      implementation of phase 2-4 of 'RET'
// @概要       RET 命令のフェイズ 2-4 の実装
//**************************************************

class InstRet extends InstBase {
  public InstRet(String asm){ super(asm); }

  // protected
  protected int Exec_P2 (KueState state) {
    state.mar = state.sp;
    state.sp += 2;
    return RT_CONTINUE;
  }

  protected int Exec_P3 (KueState state) {
    state.pc = state.GetMem(state.mar);
    return RT_DONE;
  }

  protected int Exec_P4 (KueState state) { return RT_ERROR; }
}