//**************************************************
// @classname  InstNop
// @brief      implementation of phase 2-4 of 'NOP'
// @概要       NOP 命令のフェイズ 2-4 の実装
//**************************************************

class InstNop extends InstBase {
  public InstNop(String asm) { super(asm); }
  protected int Exec_P2(KueState state) { return RT_DONE; }
  protected int Exec_P3(KueState state) { return RT_ERROR; }
  protected int Exec_P4(KueState state) { return RT_ERROR; }
}
