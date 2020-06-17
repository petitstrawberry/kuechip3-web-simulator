// テスト対象のクラス InstXXXX 毎に 1 ファイルのテストを作成
// (予定. 規模を見て変更する可能性あり)


// このテストプログラムのメイン関数
Boolean Test_sample() {

  // テスト項目並べる → エラーチェック
  if ( ! Test_Add()  ) return false;
  if ( ! Test_Sub()  ) return false;
  if ( ! Test_HOGE() ) // ...

  // 最後まで通ると OK
  return true;
}


// テスト項目
Boolean Test_Add() {

  // 1. 対象の命令のオブジェクトを生成
  InstBase inst      = new InstAlu(OPERAND_ACC, OPERAND_ACC, CMD_ADD, "hoge");

  // 2. 初期 state および 期待値 state を作成 (チェック不要な値は null)
  KueState initState = new KueState();
  initState.init(/*0,0,0,0,0.....*/);
  KueState ev2       = new KueState();
  ev2.init(/*0,0,0,0,0.....*/);
  KueState ev3       = new KueState();
  ev3.init(/*0,0,0,0,0.....*/);
  KueState ev4       = new KueState();
  ev4.init(/*0,0,0,0,0.....*/);

  // 3. 最終フェイズの番号と, 1, 2 で生成したオブジェクトで Test_Inst を作成
  int lastPhase = 4;
  Test_Inst test = new Test_Inst(inst, initState, ev2, ev3, ev4, lastPhase);

  // 4. テスト実行
  test.run();
}


