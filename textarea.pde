class TextArea
{
  public Pos basePos;
  public int numLine;
  private ArrayList buf = new ArrayList();
  private int fileIndex = 1;
  
  public TextArea(int x, int y) {
    this(x, y, DEFAULT_NUM_LINES);
  }

  public TextArea(int x, int y, int n) {
    basePos = new Pos(x, y);
    numLine = n;
  }

  
  public void Append(String str) {
    // buf.append(str);
    buf.add(str);
  }

  public void Print() {
    // initialize
    Pos pos = new Pos(basePos);
    int i = buf.size() > numLine ? buf.size() - numLine : 0;

    for(; i < buf.size(); i++, pos.y += LINE_HEIGHT) {
      // text(buf.get(i), pos.x, pos.y);
    }
  }

  public Boolean IsFull() {
    return (buf.size() >= numLine);
  }

  public Boolean IsEmpty() {
    return (buf.size() <= 0);
  }

  public int Size() {
    return buf.size();
  }

  public void FileDump() {
    // saveStrings(
    //             "logfile" + nf(fileIndex++, 4),
    //             buf.array(new String[0])
    //             );
  }

  public void Clear() {
    buf.clear();
  }
}
