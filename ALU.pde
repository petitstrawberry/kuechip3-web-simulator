// TODO: Check Flags

final int CMD_SBC = 0;
final int CMD_ADC = 1;
final int CMD_SUB = 2;
final int CMD_ADD = 3;
final int CMD_EOR = 4;
final int CMD_OR  = 5;
final int CMD_AND = 6;
final int CMD_CMP = 7;


ALU alu = new ALU();


//*****************************************************
// @classname  Alu
// @brief      a class working as ALU.
// @概要       ALU の働きをするクラス.
//*****************************************************

class ALU {

  int exec(final int OPERAND_A, final int OPERAND_B, KueState state, final int CMD) {
    int res;
    switch( CMD ) {
      case CMD_SBC:
        res = OPERAND_A - OPERAND_B - (state.flagCf ? 1 : 0);
        state.flagCf = GetFlagCf(res);
        state.flagVf = GetFlagVfSub(OPERAND_A, OPERAND_B, res);
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        res &= 0xffff;
        return res;

      case CMD_ADC:
        res = OPERAND_A + OPERAND_B + (state.flagCf ? 1 : 0);
        state.flagCf = GetFlagCf(res);
        state.flagVf = GetFlagVf(OPERAND_A, OPERAND_B, res);
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        res &= 0xffff;
        return res;

      case CMD_SUB:
        res  = OPERAND_A - OPERAND_B;
        res &= 0xffff;
        state.flagVf = GetFlagVfSub(OPERAND_A, OPERAND_B, res);
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        return res;

      case CMD_ADD:
        res  = OPERAND_A + OPERAND_B;
        res &= 0xffff;
        state.flagVf = GetFlagVf(OPERAND_A, OPERAND_B, res);
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        return res;

      case CMD_EOR:
        res = OPERAND_A ^ OPERAND_B;
        state.flagVf = false;
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        return res;
        
      case CMD_OR :
        res = OPERAND_A | OPERAND_B;
        state.flagVf = false;
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        return res;
        
      case CMD_AND:
        res = OPERAND_A & OPERAND_B;
        state.flagVf = false;
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        return res;
        
      case CMD_CMP:

        res = OPERAND_A - OPERAND_B;
        res &= 0xffff;
        state.flagVf = GetFlagVfSub(OPERAND_A, OPERAND_B, res);
        state.flagNf = GetFlagNf(res);
        state.flagZf = GetFlagZf(res);
        return OPERAND_A;
    }
    return 0;
  }
}

int Not(int value) {
  return (value + 1) % 2;
}


// calc flag value
Boolean GetFlagCf(int result) {
  return (GetMsb(result, 17) == 1);
}

Boolean GetFlagVf(int operandA, int operandB, int result) {
  return
    (( (     GetMsb16(operandA)  &     GetMsb16(operandB)  & Not(GetMsb16(result)) )  |
      ( Not(GetMsb16(operandA)) & Not(GetMsb16(operandB)) &     GetMsb16(result)  )  )
    == 1);
}

Boolean GetFlagVfSub(int operandA, int operandB, int result) {
  return
    (( (     GetMsb16(operandA) &  Not(GetMsb16(operandB)) & Not(GetMsb16(result)) )  |
      ( Not(GetMsb16(operandA)) &      GetMsb16(operandB)  &     GetMsb16(result)  )  )
    == 1);
}

Boolean GetFlagNf(int result) {
  return (GetMsb16(result) == 1);
}

Boolean GetFlagZf(int result) {
  return (result == 0);
}


int GetMsb(int value, int digit) {
  // specify the number of variable whose msb you need
  return value >>> (digit - 1) & 0x1;
}

int GetMsb16(int value) {
  return GetMsb(value, 16);
}