Boolean Test_InstAlu() {
  if ( ! Test_Add() ) return false;
//  if ( ! Test_Sub() ) return false;
//  if ( ! Test_Abc() ) return false;
//  if ( ! Test_Sbc() ) return false;

  return true;
}


Boolean Test_Add() {
  InstBase inst      = new InstAlu(OPERAND_ACC, OPERAND_ACC, CMD_ADD, "hoge");
  KueState initState = new KueState();
// state.init(0,0,0,0,0.....);
  KueState ev2       = new KueState();
// ev2.init(0,0,0,0,0.....);
  KueState ev3       = new KueState();
// ev3.init(0,0,0,0,0.....);
  KueState ev4       = new KueState();
// ev4.init(0,0,0,0,0.....);

  int lastPhase = 4;
  
  Test_Inst test = new Test_Inst(inst, initState, ev2, ev3, ev4, lastPhase);
  test.run();
}


