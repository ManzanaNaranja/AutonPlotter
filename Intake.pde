class Intake extends Action {
  public int mode; // 0 = break, 1 = intaking, 2 = outtake
  public Intake(int mode) {
    super(1);
    this.mode = mode;
  }
  
}
