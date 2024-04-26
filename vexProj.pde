int startX = 100;
int startY = 100;
int tileSize = 100;
ArrayList<Action> actionlist;
ArrayList<APoint> p;
boolean undo = false;
PrintWriter out;
boolean lastActionWasMove = false;
APoint mousePoint;
boolean spaceDown = false;
boolean rDown = false;

float startAngle = 0; // 0 rad is facing to the right, rotations are counter clockwise (radians)
int InchesPerTile = 18;




void setup() {
  size(800,800);
  background(255);
  strokeWeight(5);
  actionlist = new ArrayList<Action>();
  p = new ArrayList<APoint>();
  
  out = createWriter("output.txt");
  addPointToPath(250,530); // inital start point of robot

}
// FIRST ACTION MUST BE A MOVE ACTION OR CODE BREAKS
void draw() {
  if(undo) {
    undo = false;
    if(p.size() != 0) {
      p.remove(p.size()-1);
    }
  }
  translate(startX, startY);
  rect(0,0,tileSize * 6,tileSize * 6);
  updateMousePoint();
  
  drawTiles();
  drawBars();
  drawBlueGoal();
  drawRedGoal();
  drawCorners();
  
  drawHover();
  drawPoints();
}

void updateMousePoint() {
  if(spaceDown && p.size() > 0) {
    APoint lastPt = p.get(p.size()-1);
    int x = mouseX - startX;
    int y = mouseY - startY;
    
    int xDist = abs(lastPt.x - x);
    int yDist = abs(lastPt.y - y);
    if(xDist > yDist) {
      mousePoint = new APoint(x, lastPt.y);
    } else {
      mousePoint = new APoint(lastPt.x, y);
    }
    
    
  } else {
    mousePoint = new APoint(mouseX - startX, mouseY - startY);
  }
  
}

void drawHover() {
  push();
  noStroke();
  fill(253, 215, 150);
  int x = mousePoint.x;
  int y = mousePoint.y;
  if(x > 0 && x < tileSize * 6 && y > 0 && y < tileSize * 6) {
      circle(x,y, 10);
  }

  pop();
}

void drawTiles() {
  push();
  strokeWeight(2);
  for(int i = 0; i < 6; i++) {
    for(int j = 0; j < 6; j++) {
      rect(tileSize * i, tileSize * j, tileSize, tileSize);
    }
  }
  pop();
}

void drawBars() {
  push();
  strokeWeight(10);
  lineC(2, 1, 4, 1);
  lineC(2, 5, 4, 5);
  lineC(3, 1, 3, 5);
  pop();
}

void drawRedGoal() {
  push();
  stroke(240,15,123);
  strokeWeight(8);
  lineC(0,2,1,2);
  lineC(0,4,1,4);
  lineC(1,2,1,4);
  pop();
}

void drawBlueGoal() {
  push();
  stroke(15,123,240);
  strokeWeight(8);
  lineC(5,2,6,2);
  lineC(5,4,6,4);
  lineC(5,2,5,4);
  pop();
}

void lineC(int a, int b, int c, int d) {
  line(tileSize*a, tileSize*b, tileSize * c, tileSize*d);
}

void drawCorners() {
  push();
  stroke(15,123,240);
  strokeWeight(8);
  lineC(0,1,1,0);
  lineC(0,5,1,6);
  stroke(240,15,123);
  lineC(5,6,6,5);
  lineC(5,0,6,1);

  pop();
}

void drawPoints() {
  push();
  noStroke();
  fill(253, 161,0);
  for(int i = 0; i < p.size(); i++) {
    APoint point = p.get(i);
    circle(point.x, point.y, 10);
  }
  pop();
}

void mousePressed() {
  addPointToPath(mousePoint.x, mousePoint.y);  
}

void addPointToPath(int x, int y) {
  p.add(new APoint(x,y));
  if(p.size() > 1) {
    APoint coord = screenToWorld(new APoint(mousePoint.x, mousePoint.y));
    actionlist.add(new AMove(coord, !rDown, 127));
  } else {
    print("start point on screen: x: " + x +  " y: " + y);
  }
}

void keyReleased() {
  if(key == 32) {
    spaceDown = false;
  }
  if(key == 114) {
    rDown = false;
  }
}

void keyPressed() { 
  if(key == 32) { // space
    spaceDown = true;
  } 
  if(key == 114) { // r
    rDown = true;
  }
  if(key == 122) { // z
    if(actionlist.size() != 0) {
      if(actionlist.get(actionlist.size()-1).id == 0) {
        undo = true;
      }
      actionlist.remove(actionlist.size()-1);
    }

  }
  if(key == 99) { // c
    actionlist.add(new Comment("// add stuff here"));
  }
  if(key == 113) { // q (left wing)
    actionlist.add(new Wings(3));
  }
  if(key == 101) { // e (right wing)
    actionlist.add(new Wings(2));
  }
  
  if(key == 119) { // w
    actionlist.add(new Wings(0));  
  }
  if(key == 120) { // x (wings off)
  actionlist.add(new Wings(1));
  }
  if(key == 105) { // i (intake)
   actionlist.add(new Intake(1));
  }
  if(key == 111) { // o (set 0 volts)
   actionlist.add(new Intake(0));
  }
  
  if(key == 117) { // u (outtake)
    actionlist.add(new Intake(2));
  }
  
  
  if(key == 27) { // esc
    out.flush();
    out.close();
    exit();
  }
  if(key == 112) { // p
  
    for(int i = 0; i < actionlist.size(); i++) {
      boolean lastAction = (i == actionlist.size()-1);
      Action curr = actionlist.get(i);
      if(curr.id == 0) {
        AMove m = (AMove) curr;
        if(!lastActionWasMove) {
          lastActionWasMove = true;
          out.print("chassis.pid_odom_smooth_pp_set({");
          out.print("{{" + m.pos.x + ", " + m.pos.y + "}, " + ((m.fwd) ? "fwd" : "rev") + ", 127}"); // add other parts of command instead of string
        } else {
          out.print(",{{" + m.pos.x + ", " + m.pos.y + "}, " + ((m.fwd) ? "fwd" : "rev") + ", 127}");
        }
        if(lastAction) {
          out.println("});");
          out.println("chassis.pid_wait();");
          lastActionWasMove = false;
        }
        
      } else if(curr.id == 1) {
        Intake intake = (Intake) curr;
        if(lastActionWasMove) {
          lastActionWasMove = false;
          out.println("});");
          out.println("chassis.pid_wait();");
        }
        if(intake.mode == 0) {
          out.println("intakeOff();");
        } else if(intake.mode == 1) {
          out.println("intakeOn();");
        } else if(intake.mode == 2) {
          out.println("intakeRev();");
        }
      } else if(curr.id == 2) {
        Wings wings = (Wings) curr;
        if(lastActionWasMove) {
          lastActionWasMove = false;
          out.println("});");
          out.println("chassis.pid_wait();");
        }
        if(wings.mode == 0) {
           out.println("wingsOn();");
        }
        if(wings.mode == 1) {
          out.println("wingsOff();");
        }
        if(wings.mode == 2) {
          out.println("rightWingOn();");
        }
        if(wings.mode == 3) {
          out.println("leftWingOn();");
        }
      } else if(curr.id == 3) {
        if(lastActionWasMove) {
          lastActionWasMove = false;
          out.println("});");
          out.println("chassis.pid_wait();");
        }
        Comment comment = (Comment) curr;
        out.println(comment.txt);
      }
    }
    out.println("// end of code segment");
    out.flush();
  }
}

APoint screenToWorld(APoint pt) {
  APoint ref = p.get(0);
  float xd = pt.x - ref.x;
  float yd = pt.y - ref.y;
  float tx = xd*cos(startAngle) - yd*sin(startAngle);
  float ty = xd * sin(startAngle) + yd * cos(startAngle);
  int newx = (int)(tx/tileSize * InchesPerTile);
  int newy = (int)(ty/tileSize * InchesPerTile);
  
  
  return new APoint(newy,newx); // y and x are switched because screen coord system is different than robot coord system
  
}
