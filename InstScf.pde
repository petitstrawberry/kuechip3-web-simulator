//**************************************************
// @classname  InstScf
// @brief      implementation of phase 2-4 of 'SCF'
// @概要       SCF 命令のフェイズ 2-4 の実装
//**************************************************

class InstScf extends InstBase {

  protected int Exec_P2(KueState state) {
    state.flagCf = true;
    return RT_DONE;
  }
  protected int Exec_P3(KueState state) { return RT_ERROR; }
  protected int Exec_P4(KueState state) { return RT_ERROR; }

  protected String GetAsmStr() {
    return "SCF"; //   " + strOperandA + " " + strOperandB;
  }
}