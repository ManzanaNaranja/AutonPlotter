class Wings extends Action {
  public int mode; // 0 = out, 1 = in, 2 = rightOn, 3 = leftOn
  public Wings(int mode) {
    super(2);
    this.mode = mode;
  }
  
}
