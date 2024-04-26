class Wings extends Action {
  public int mode; // 0 = out, 1 = in
  public Wings(int mode) {
    super(2);
    this.mode = mode;
  }
  
}
