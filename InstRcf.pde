//**************************************************
// @classname  InstRcf
// @brief      implementation of phase 2-4 of 'RCF'
// @概要       RCF 命令のフェイズ 2-4 の実装
//**************************************************

class InstRcf extends InstBase {

  protected int Exec_P2(KueState state) {
    state.flagCf = false;
    return RT_DONE;
  }
  protected int Exec_P3(KueState state) { return RT_ERROR; }
  protected int Exec_P4(KueState state) { return RT_ERROR; }

  protected String GetAsmStr() {
    return "RCF"; //   " + strOperandA + " " + strOperandB;
  }
}