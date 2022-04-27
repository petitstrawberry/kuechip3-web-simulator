//**************************************************
// @classname  InstFactory
// @brief      a factory class of instructions
// @概要       命令のオブジェクトを生成するクラス
//**************************************************



// instance of factory
InstFactory instFactory = new InstFactory();

class InstFactory {
  // -- public --
  public InstBase CreateInstFromBin(KueState state) {
    String inst = hexConverter.decimal2hex(state.GetMem( state.GetPc() ), 4);
    String strPc = hexConverter.decimal2hex(state.GetPc(), 4);
    sysLog.Append( "Generate inst 0x" + inst + " (PC : " + strPc + " )" );

    inst = inst.substring(2); // all instructions use only 2 byte
    
    // In javascript mode, switch statement with char value does not work.
    // e.g.)  switch( inst.charAt(1) ) {
    //          case '0':
    //          ...
    //          default:          //  always jump here
    //        }

    // switch by first bit of inst
    switch( "" + inst.substring(0, 1) ) {
      case "0":
        // switch by second bit of inst
        switch( "" + inst.substring(1, 2) ) {
          case "0": return new InstNop("NOP");
          case "1": return new InstLd_AccIx(OPERAND_IX, OPERAND_SP,  "LD IX SP");
          case "2": return new InstLd_Imm  (OPERAND_SP, OPERAND_IMM, "LD SP d" );
          case "3": return new InstLd_AccIx(OPERAND_SP, OPERAND_IX,  "LD SP IX");
          case "4": return new InstInc("INC SP");
          case "5": return new InstDec("DEC SP");
          case "6": return new InstAlu_Imm(OPERAND_SP, OPERAND_IMM, CMD_ADD, "ADD SP d");
          case "7": return new InstAlu_Imm(OPERAND_SP, OPERAND_IMM, CMD_SUB, "SUB SP d");
          case "8": return new InstPsh(OPERAND_ACC, "PSH ACC");
          case "9": return new InstPsh(OPERAND_IX,  "PSH IX" );
          case "A": return new InstPop(OPERAND_ACC, "POP ACC");
          case "B": return new InstPop(OPERAND_IX,  "POP IX" );
          case "C": return new InstCal("CAL");
          case "D": return new InstRet("RET");
          case "F": return new InstHlt("HLT");
          default : break;
        } break;

      // IN OUT
      case "1":
        switch ( "" + inst.substring(1, 2)) {
          case "0" : return new InstOut();
          case "F" : return new InstIn();
          default : break;
        } break;            

      // RCF SCF
      case "2":
        final int cc;
        switch (inst.substring(1, 2)) {
          case "0":
          case "1":
          case "2":
          case "3":
          case "4":
          case "5":
          case "6":
          case "7":
          case "8":
          case "9": cc = int(inst.substring(1, 2)); break;
          case "A": cc = 0xA; break;
          case "B": cc = 0xB; break;
          case "C": cc = 0xC; break;
          case "D": cc = 0xD; break;
          case "E": cc = 0xE; break;
          case "F": cc = 0xF; break;
          default : cc = -1;  break;
        }
        switch ("" + GetMsb(cc, 4)) {
          case "0" : return new InstRcf();
          case "1" : return new InstScf();
          default : break;
        } break;            

      // branch
      case "3": {
        // "A" to "F" can't convert int
        // final int cc = int(inst.substring(1, 2));
        final int cc;
        switch (inst.substring(1, 2)) {
          case "0":
          case "1":
          case "2":
          case "3":
          case "4":
          case "5":
          case "6":
          case "7":
          case "8":
          case "9": cc = int(inst.substring(1, 2)); break;
          case "A": cc = 0xA; break;
          case "B": cc = 0xB; break;
          case "C": cc = 0xC; break;
          case "D": cc = 0xD; break;
          case "E": cc = 0xE; break;
          case "F": cc = 0xF; break;
          default : cc = -1;  break;
        }
        if( 0x0 <= cc && cc <= 0xF ) {
          // pass cmd (specify jump condition)
          return new InstBcc( cc );
        } else {
          Error("Found an invalid 'Bcc' instruction.");
          break;
        }
      }

      // shift
      case "4": {
//        final int cmd = int(inst.substring(1, 2));
        final int cmd;
        switch (inst.substring(1, 2)) {
          case "0":
          case "1":
          case "2":
          case "3":
          case "4":
          case "5":
          case "6":
          case "7":
          case "8":
          case "9": cmd = int(inst.substring(1, 2)); break;
          case "A": cmd = 0xA; break;
          case "B": cmd = 0xB; break;
          case "C": cmd = 0xC; break;
          case "D": cmd = 0xD; break;
          case "E": cmd = 0xE; break;
          case "F": cmd = 0xF; break;
          default : cmd = -1;  break;
        }
        if( 0x0 <= cmd && cmd <= 0x7 ) {
          return new InstShift(OPERAND_ACC, cmd % 8);
        } else if( 0x8 <= cmd && cmd <= 0xf ) {
          return new InstShift(OPERAND_IX,  cmd % 8);
        } else {
          Error("Found an invalid 'Ssm or Rsm' instruction.");
          break;
        }
      }
        
      case "5":                 // no instruction
        break;

      // load
      case "6": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstLd_AccIx (OPERAND_ACC, OPERAND_ACC,    "LD ACC ACC"    );
          case "1":  return new InstLd_AccIx (OPERAND_ACC, OPERAND_IX,     "LD ACC IX"     );
          case "2":  return new InstLd_Imm   (OPERAND_ACC, OPERAND_IMM,    "LD ACC d"      );
          case "3":  return new InstLd_Idx   (OPERAND_ACC, OPERAND_IDX_SP, "LD ACC [SP+d]" );
        //case "3":  return new InstLd_AbsSp (OPERAND_ACC, OPERAND_ABS_SP                  );
          case "4":  return new InstLd_Abs   (OPERAND_ACC, OPERAND_ABS,    "LD ACC [d]"    );
          case "6":  return new InstLd_Idx   (OPERAND_ACC, OPERAND_IDX_IX, "LD ACC [IX+d]" );

          case "8":  return new InstLd_AccIx(OPERAND_IX, OPERAND_ACC,    "LD IX ACC"    );
          case "9":  return new InstLd_AccIx(OPERAND_IX, OPERAND_IX,     "LD IX IX"     );
          case "A":  return new InstLd_Imm  (OPERAND_IX, OPERAND_IMM,    "LD IX d"      );
          case "B":  return new InstLd_Idx  (OPERAND_IX, OPERAND_IDX_SP, "LD IX [SP+d]" );
        //case "B":  return new InstLd_AbsSp(OPERAND_IX, OPERAND_ABS_SP                 );
          case "C":  return new InstLd_Abs  (OPERAND_IX, OPERAND_ABS,    "LD IX [d]"    );
          case "E":  return new InstLd_Idx  (OPERAND_IX, OPERAND_IDX_IX, "LD IX [IX]"   );
            
          default :  Error("Found an invalid 'LD' instruction.");
                     break;
        }
      } break;

      // store
      case "7": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "3":  operandA = OPERAND_ACC;  operandB = OPERAND_IDX_SP;   break;
          case "4":  operandA = OPERAND_ACC;  operandB = OPERAND_ABS;      break;
          case "6":  operandA = OPERAND_ACC;  operandB = OPERAND_IDX_IX;   break;
          case "B":  operandA = OPERAND_IX;   operandB = OPERAND_IDX_SP;   break;
          case "C":  operandA = OPERAND_IX;   operandB = OPERAND_ABS;      break;
          case "E":  operandA = OPERAND_IX;   operandB = OPERAND_IDX_IX;   break;
          default :  Error("Found an invalid 'ST' instruction.");
                     return new InstHlt("HLT");
        }
        return new InstSt(operandA, operandB);
      }

      // sub with carry
      case "8": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_SBC, "SBC ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_SBC, "SBC ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_SBC, "SBC ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_SBC, "SBC ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_SBC, "SBC ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_SBC, "SBC ACC [IX+d]" );

          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_SBC, "SBC IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_SBC, "SBC IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_SBC, "SBC IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_SBC, "SBC IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_SBC, "SBC IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_SBC, "SBC IX [IX+d]"  );
          default :  Error("Found an invalid 'SBC' instruction."                                       );
        }
      } break;

      // add with carry
      case "9": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_ADC, "ADC ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_ADC, "ADC ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_ADC, "ADC ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_ADC, "ADC ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_ADC, "ADC ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_ADC, "ADC ACC [IX+d]" );

          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_ADC, "ADC IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_ADC, "ADC IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_ADC, "ADC IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_ADC, "ADC IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_ADC, "ADC IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_ADC, "ADC IX [IX+d]"  );
          default :  Error("Found an invalid 'ADC' instruction.");
        }
      } break;

      // sub
      case "A": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_SUB, "SUB ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_SUB, "SUB ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_SUB, "SUB ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_SUB, "SUB ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_SUB, "SUB ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_SUB, "SUB ACC [IX+d]" );
                                                                                                         
          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_SUB, "SUB IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_SUB, "SUB IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_SUB, "SUB IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_SUB, "SUB IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_SUB, "SUB IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_SUB, "SUB IX [IX+d]"  );
          default :  Error("Found an invalid 'SUB' instruction.");
        }
      } break;

      // add
      case "B": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_ADD, "ADD ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_ADD, "ADD ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_ADD, "ADD ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_ADD, "ADD ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_ADD, "ADD ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_ADD, "ADD ACC [IX+d]" );
                                                                                                         
          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_ADD, "ADD IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_ADD, "ADD IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_ADD, "ADD IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_ADD, "ADD IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_ADD, "ADD IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_ADD, "ADD IX [IX+d]"  );
          default :  Error("Found an invalid 'ADD' instruction.");
        }
      } break;

      // eor
      case "C": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_EOR, "EOR ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_EOR, "EOR ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_EOR, "EOR ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_EOR, "EOR ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_EOR, "EOR ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_EOR, "EOR ACC [IX+d]" );
                                                                                                         
          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_EOR, "EOR IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_EOR, "EOR IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_EOR, "EOR IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_EOR, "EOR IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_EOR, "EOR IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_EOR, "EOR IX [IX+d]"  );
          default :  Error("Found an invalid 'EOR' instruction.");
        }
      } break;

      // or
      case "D": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_OR, "OR ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_OR, "OR ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_OR, "OR ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_OR, "OR ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_OR, "OR ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_OR, "OR ACC [IX+d]" );
                                                                                                        
          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_OR, "OR IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_OR, "OR IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_OR, "OR IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_OR, "OR IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_OR, "OR IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_OR, "OR IX [IX+d]"  );
          default :  Error("Found an invalid 'OR' instruction.");
        }
      } break;

      // and
      case "E": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_AND, "AND ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_AND, "AND ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_AND, "AND ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_AND, "AND ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_AND, "AND ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_AND, "AND ACC [IX+d]" );
                                                                                                         
          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_AND, "AND IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_AND, "AND IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_AND, "AND IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_AND, "AND IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_AND, "AND IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_AND, "AND IX [IX+d]"  );
          default :  Error("Found an invalid 'AND' instruction.");
        }
      } break;

      // cmp
      case "F": {
        int operandA = -1;
        int operandB = -1;
        switch( "" + inst.substring(1, 2) ) {
          case "0":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_ACC    , CMD_CMP, "CMP ACC ACC"    );
          case "1":  return new InstAlu_AccIx (OPERAND_ACC, OPERAND_IX     , CMD_CMP, "CMP ACC IX"     );
          case "2":  return new InstAlu_Imm   (OPERAND_ACC, OPERAND_IMM    , CMD_CMP, "CMP ACC d"      );
          case "3":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_SP , CMD_CMP, "CMP ACC [SP+d]" );
          case "4":  return new InstAlu_Abs   (OPERAND_ACC, OPERAND_ABS    , CMD_CMP, "CMP ACC [d]"    );
          case "6":  return new InstAlu_AbsIx (OPERAND_ACC, OPERAND_IDX_IX , CMD_CMP, "CMP ACC [IX+d]" );
                                                                                                         
          case "8":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_ACC      , CMD_CMP, "CMP IX ACC"     );
          case "9":  return new InstAlu_AccIx(OPERAND_IX, OPERAND_IX       , CMD_CMP, "CMP IX IX"      );
          case "A":  return new InstAlu_Imm  (OPERAND_IX, OPERAND_IMM      , CMD_CMP, "CMP IX d"       );
          case "B":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_SP   , CMD_CMP, "CMP IX [SP+d]"  );
          case "C":  return new InstAlu_Abs  (OPERAND_IX, OPERAND_ABS      , CMD_CMP, "CMP IX [d]"     );
          case "E":  return new InstAlu_AbsIx(OPERAND_IX, OPERAND_IDX_IX   , CMD_CMP, "CMP IX [IX+d]"  );
          default :  Error("Found an invalid 'CMP' instruction.");
        }
      } break;

      // fail to parse
      default :
        sysLog.Append( "Found an invalid opcode." );
        break;
    }
    // catch error hannpened in inner switch statement and terminal abnormally
    Error("Found an invalid opcode '" + inst + "'.");
    return new InstHlt("HLT");       // generate hlt to exit
  }
}