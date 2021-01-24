ArrayList<Obstacle> obstacles;
Table obs_table;

class Obstacle {
  float x,y;
  PVector[] points;
  PVector centroid;
  int touch_count = 0;
  boolean touched;
  int blinksCount = 0, maxBlinks = 30;
  color blinkColor;
  
  Obstacle(PVector[] p) {
    points = p;
    centroid = findCentroid(points);
    touch_count = 0;
    touched = false;
    blinksCount = 0;
  }
  
  void show (PGraphics targetGraphic/*, color _c*/) {
    targetGraphic.noFill();
    //targetGraphic.stroke(_c);
    targetGraphic.beginShape();
      for (PVector p : points)  targetGraphic.vertex(p.x, p.y);
    targetGraphic.endShape(CLOSE);
  }
  
  void update (PGraphics targetGraphic) {
    if(touched) {
      if (blinksCount <= maxBlinks) {
        if (frameCount%6 == 0) {
          blink(targetGraphic);
          blinksCount += 1;
        }
      }
      else touched = false;
    }
  }
  void blink (PGraphics targetGraphic) {
    targetGraphic.fill(255);
    targetGraphic.strokeWeight(10);
    targetGraphic.stroke(RandomWalkColor(color(255)));
    targetGraphic.beginShape();
      for (PVector p : points)  targetGraphic.vertex( p.x, p.y);
    targetGraphic.endShape(CLOSE);
  }
  /*  */
  // find centroid of obstacle shapes
  PVector findCentroid(PVector[] points) {
    float avgx, avgy;
    float[] x = {};
    float[] y = {};
    for (PVector p : points){
      x = append(x,p.x);
      y = append(y,p.y);
    }
    avgx = findAverage(x);
    avgy = findAverage(y);
    PVector centroid = new PVector(avgx,avgy);
    return centroid;
  }
  
  float findAverage(float [] anyArray) {
    int sum=0;
    for (int i=0; i<anyArray.length; i++){
      sum+=anyArray[i];
    }
    float avg = sum/anyArray.length;
    return avg;
  }
  
  /* globals for Obstacle class */
  boolean containsPoint(float px, float py, boolean blink) {
    /* 
        check if within a shape function taken from: 
        http://hg.postspectacular.com/toxiclibs/src/tip/src.core/toxi/geom/Polygon2D.java
     */
    int num = points.length;
    int i, j = num - 1;
    boolean _t = false;
    for (i = 0; i < num; i++) {
      PVector vi = points[i];
      PVector vj = points[j];
      if (vi.y < py && vj.y >= py || vj.y < py && vi.y >= py) {
        if (vi.x + (py - vi.y) / (vj.y - vi.y) * (vj.x - vi.x) < px) {
          _t = !_t;
        }
      }
      j = i;
    }
    // update boolean value
    if (!_t  || !blink) {
      // !blink --> we don't want to blink obstacle, even if touched by object
      touched = false;
    }
    else {
      touch_count += 1;
      blinksCount = 0;
      touched = true;
    }
    
    return _t;
  }
  
  // --------------- END OF OBSTACLE CLASS ----------------//
}



/* GLOBALS void for Obstacle class */
void loadObstaclesData() {
  // this function load datas file for Speakers
  obs_table = loadTable("data/obstacles.csv", "header"); // header is used because we have an header in the csv (first line)
  obstacles.clear();
  if (obs_table.getRowCount() == 0) {
    // generate clean data obs_table if not existing already
    obs_table = new Table();
    obs_table.addColumn("obs_num");
    obs_table.addColumn("points");
  }
  else{
    for (int i = 0; i < obs_table.getRowCount(); i++) {
      // Iterate over all the rows in a obs_table.
      TableRow row = obs_table.getRow(i);
      // Access the fields via their column name (or index).
      String spoints = row.getString("points").replace("[","");
      String[] points = spoints.split("]");
      PVector[] obs_points = new PVector[points.length];
      for (int p = 0; p < points.length; p++) {
        //println("--" + points[p]);
        String[] values = split(points[p],",");
        PVector newVec = new PVector(float(values[0]),float(values[1]));
        obs_points[p] = newVec;
      }
      //create a obstacle object out of the data from each row.
      obstacles.add(new Obstacle(obs_points));
    }
  }
}

void deleteLastObstacle () {
  //obstacles.remove(obstacles.size()-1);
  obs_table.removeRow(obs_table.getRowCount()-1);
  saveTable(obs_table, "data/obstacles.csv");
  loadObstaclesData();
}
void updateObstaclesData (String points) {
  //println("add row");
  TableRow row = obs_table.addRow();
  row.setInt("obs_num", obstacles.size());
  row.setString("points", points);
  saveTable(obs_table, "data/obstacles.csv");
  loadObstaclesData();
}

void updateObstacles () {
  for (Obstacle o : obstacles) { o.update(extra); } // update obstacles
}

void drawObstacles (PGraphics _p, boolean _centroids, boolean _id) {
  for (int i = 0; i < obstacles.size(); i++) {
    Obstacle o = obstacles.get(i);
    o.show(_p);
    if (_centroids) _p.ellipse(o.centroid.x, o.centroid.y, 2, 2);
    if (_id) _p.text(i, o.centroid.x +10, o.centroid.y+10);
  }
}
