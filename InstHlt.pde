//**************************************************
// @classname  InstHlt
// @brief      implementation of phase 2-4 of 'HLT'
// @概要       HLT 命令のフェイズ 2-4 の実装
//**************************************************

class InstHlt extends InstBase {
  public InstHlt(String asm) { super(asm); }
  protected int Exec_P2(KueState state) { return RT_HLT; }
  protected int Exec_P3(KueState state) { return RT_ERROR; }
  protected int Exec_P4(KueState state) { return RT_ERROR; }
}
