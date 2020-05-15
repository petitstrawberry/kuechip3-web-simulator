class Pos
{
  int x, y;

  public Pos() {
    this(0, 0);
  }

  public Pos(int ax, int ay) {
    x = ax;  y = ay;
  }

  public Pos(Pos pos) {
    this(pos.x, pos.y);
  }
}
