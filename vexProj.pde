int startX = 100;
int startY = 100;
int tileSize = 100;
ArrayList<Action> actionlist;
ArrayList<APoint> p;
boolean undo = false;
PrintWriter out;
boolean lastActionWasMove = false;

int startAngle = 0; // 0 deg is facing to the right, rotations are counter clockwise
void setup() {
  size(800,800);
  background(255);
  strokeWeight(5);
  actionlist = new ArrayList<Action>();
  p = new ArrayList<APoint>();
  
  out = createWriter("output.txt");

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
  drawTiles();
  drawBars();
  drawBlueGoal();
  drawRedGoal();
  drawCorners();
  
  drawPoints();
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

void drawBlueGoal() {
  push();
  stroke(15,123,240);
  strokeWeight(8);
  lineC(0,2,1,2);
  lineC(0,4,1,4);
  lineC(1,2,1,4);
  pop();
}

void drawRedGoal() {
  push();
  stroke(240,15,123);
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
  stroke(240,15,123);
  strokeWeight(8);
  lineC(0,1,1,0);
  lineC(0,5,1,6);
  stroke(15,123,240);
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
  p.add(new APoint(mouseX - startX, mouseY - startY));
  if(p.size() > 1) {
    APoint coord = screenToWorld(new APoint(mouseX - startX, mouseY - startY));
    actionlist.add(new AMove(coord, true, 127));
  }
  

}

void keyPressed() { 
  if(key == 122) { // z
    if(actionlist.size() != 0) {
      if(actionlist.get(actionlist.size()-1).id == 0) {
        undo = true;
      }
      actionlist.remove(actionlist.size()-1);
    }

  }
  if(key == 105) { // i
   actionlist.add(new Intake(1));
  }
  if(key == 111) { // o
   actionlist.add(new Intake(0));
  }
  if(key == 27) { // esc
    out.flush();
    out.close();
    exit();
  }
  if(key == 112) { // p
  
    for(int i = 0; i < actionlist.size(); i++) {
      boolean lastAction = i == actionlist.size()-1;
      Action curr = actionlist.get(i);
      if(curr.id == 0) {
        AMove m = (AMove) curr;
        if(!lastActionWasMove) {
          lastActionWasMove = true;
          out.print("chassis.pid_odom_smooth_pp_set({");
          out.print("{{" + m.pos.x + ", " + m.pos.y + "}, fwd, 110}"); // add other parts of command instead of string
        } else {
          out.print(",{{" + m.pos.x + ", " + m.pos.y + "}, fwd, 110}");
        }
        if(lastAction) {
          out.println("});");
          lastActionWasMove = false;
        }
        
      } else if(curr.id == 1) {
        Intake intake = (Intake) curr;
        if(lastActionWasMove) {
          lastActionWasMove = false;
          out.println("});");
        }
        if(intake.mode == 0) {
          out.println("intakeOff();");
        } else if(intake.mode == 1) {
          out.println("intakeOn();");
        }
      }
    }
    //out.print("chassis.pid_odom_smooth_pp_set({");
  
  
    //for(int i = 1; i < p.size(); i++) {
    //  APoint curr = p.get(i);
    //  APoint worldCoord = screenToWorld(curr);
    //  out.print("{{" + worldCoord.x + ", " + worldCoord.y + "}, fwd, 110}");
    //  if(i != p.size()-1) {
    //    out.print(",");
    //  }
    //}
    //out.println("});");
    out.flush();
  }
}

APoint screenToWorld(APoint pt) {
  APoint ref = p.get(0);
  float xd = pt.x - ref.x;
  float yd = pt.y - ref.y;
  float tx = xd*cos(startAngle) - yd*sin(startAngle);
  float ty = xd * sin(startAngle) + yd * cos(startAngle);
  int newx = (int)(tx/tileSize * 36);
  int newy = (int)(ty/tileSize * 36);
  
  
  return new APoint(newy,newx); // y and x are switched because screen coord system is different than robot coord system
  
}
