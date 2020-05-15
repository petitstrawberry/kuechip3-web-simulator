//**************************************************
// @classname  InstIn
// @brief      implementation of phase 2-4 of 'In'
// @概要       In 命令のフェイズ 2-4 の実装
//**************************************************

class InstIn extends InstBase {
  protected int Exec_P2(KueState state) {
    state.acc = state.ibuf;
    state.ibuf_re = 0;
    return RT_CONTINUE;
  }
  protected int Exec_P3(KueState state) {
    state.ibuf_flg_clr = 0;
    return RT_DONE;
  }
  protected int Exec_P4(KueState state) { return RT_ERROR; }
}
