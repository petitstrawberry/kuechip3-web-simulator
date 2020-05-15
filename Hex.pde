HexConverter hexConverter = new HexConverter();

class HexConverter
{
  String decimal2hex(Integer value, int digit) {

    String pad = "";
    for(int i = 0; i < digit; i++) { pad += "0"; }
    
    String buf = pad + hex(value);
    return buf.substring(buf.length() - digit);
  }
}
