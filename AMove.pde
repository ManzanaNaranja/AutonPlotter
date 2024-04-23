class AMove extends Action {
  int speed;
  boolean fwd;
  APoint pos;
  public AMove(APoint pos,boolean fwd,int speed) {
    super(0);
    this.pos = pos;
    this.fwd = fwd;
    this.speed = speed;
  }
}
