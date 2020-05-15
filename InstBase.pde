//*************************************************************
// @classname  InstBase
// @brief      implementation of phase 0-1 of all instructions
// @概要       全命令共通のフェイズ 0-1 の実装
//*************************************************************

abstract class InstBase {
  // -- public --

  // constructors
  InstBase() {
    nextPhase = P0;
  }

  InstBase(String argAsm) {
    nextPhase = P0;
    asm = argAsm;
  }

  // a facade of execution
  public int Exec(KueState state) { 
    switch(nextPhase) {
      case P0:   nextPhase = P1;   return Exec_P0(state);
      case P1:   nextPhase = P2;   return Exec_P1(state);
      case P2:   nextPhase = P3;   return Exec_P2(state);
      case P3:   nextPhase = P4;   return Exec_P3(state);
      case P4:   nextPhase = P0;   return Exec_P4(state);
      default:
    }
    return RT_ERROR;
  }

  // getter
  public int NextPhase() { return nextPhase; }

  
  // -- protected --
  protected int nextPhase;
  protected String asm = "OPCODE  OPERAND1 OPERAND2";

  // a comman processes of all instructions
  private int Exec_P0(KueState state) {
    state.mar = state.GetPc();
    state.IncPc();
    return RT_CONTINUE;
  }
  
  private int Exec_P1(KueState state) {
    state.ir = state.GetMem(state.mar);
    return RT_CONTINUE;
  }


  // implemented in each class 'Inst*'
  abstract protected int Exec_P2(KueState state);
  abstract protected int Exec_P3(KueState state);
  abstract protected int Exec_P4(KueState state);

  // /*abstract*/ protected String GetAsmStr() {
  //   return "OPCODE  OPERAND1 OPERAND2";
  // }

  protected String GetAsmStr() { return asm; }
}
