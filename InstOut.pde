//**************************************************
// @classname  InstOut
// @brief      implementation of phase 2-4 of 'OUT'
// @概要       OUT 命令のフェイズ 2-4 の実装
//**************************************************

class InstOut extends InstBase {
  protected int Exec_P2(KueState state) {
    state.obuf = state.acc;
    return RT_CONTINUE;
  }
  protected int Exec_P3(KueState state) {
    sysLog.Append("0x" + hexConverter.decimal2hex(state.acc, 4));
    state.obuf = state.acc;
    state.obuf_we = 0;

    println( "OUT: " + hexConverter.decimal2hex(state.acc, 4) );
    
    return RT_DONE;
  }
  protected int Exec_P4(KueState state) { return RT_ERROR; }
}
