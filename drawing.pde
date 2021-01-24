/*
    Drawing class
    Subclass for players
    Contains all drawing options for players
*/
class Drawing {
  PVector obsCentroid;
  int lastVal, prevSat;
  PVector pen, lastPen, jump;
  char id, lastDir;
  PGraphics target;
  color lineColor;
  Player parent;
  boolean wasInObs;
  
  Drawing (char _id, PGraphics _target, Player _parent) {
    id = _id;
    pen = new PVector(0,0);
    jump = new PVector(0,0);
    lastPen = new PVector(0,0);
    obsCentroid = new PVector(0,0);
    lastDir = 'x';
    target = _target;
    lineColor = LineColor();
    parent = _parent;
    prevSat = 0;
    wasInObs = false;
  }
  
  void trace() {
    // called in draw loop to update
    // do the job only if new value for the line
    // osc message to ableton
    //drawing
    if (dist(lastPen.x, lastPen.y, pen.x, pen.y) > 0) {
      // use distance between last and new pen to know if pen has moved
      color co = controledColor ();
      // we draw a black rectangle with variable amount of alpha
      // this will "fade" the trace according to "tracesLifeDuration" variable
      target.noStroke();
      target.fill(0,0,0,tracesLifeDuration);
      target.rect(0,0,width,height);
      //
      target.pushMatrix();
      target.translate(jump.x, jump.y);
        target.stroke(co);
        target.strokeWeight(penSize);
        target.line(lastPen.x, lastPen.y, pen.x, pen.y);
        lastPen.set(pen);
      target.popMatrix();
    }
  }
  
  void update (char dir, int value) {
    // store position before new move
    jump.set(0,0);
    PVector newPos = new PVector (0,0);
    newPos = lastPen.copy();
    
    // update last position with new values from serial
    if (dir == 'x') newPos.add(new PVector (value*penStep, 0));
    if (dir == 'y') newPos.add(new PVector (0, value*penStep));
    
    // check obstacle
    boolean isInObs = false;
    isInObs = checkTouch(newPos);
    if (isInObs == true) { 
      newPos = lastPen;
      parent.sendSerialMessage('s'); // send shake message to parent -> to arduino
    }
    if (isInObs != wasInObs){
      // if state of collision changed, we send osc message to sound software
      parent.collisionsToOSC(int(isInObs)); 
    }
    wasInObs = isInObs;
    
    // check border
    if ((newPos.x) < 0) {
      jump.x = width;
      newPos.x = width;
    }
    if ((newPos.x) > width) {
      jump.x = -width;
      newPos.x = 0;
    }
    if ((newPos.y) < 0) {
      jump.y = height;
      newPos.y = height;
    }
    if ((newPos.y) > height) {
      jump.y = -height;
      newPos.y = 0;
    }
    // update values for drawing
    pen = newPos.copy();
    
    
    if (touchLuciole(pen)) {
      // we touched a luciole
      // send message to ableton
      
      // shake
      parent.sendSerialMessage('e');
    }
    if (pen != lastPen) {
      // if change in position, we update ableton
      parent.penToOSC (pen, dir);
    }
  }
  
  void isShaked () {
    // function to be called when shake is detected
    parent.sendSerialMessage('s'); //add buzzer answer if player shakes the remote
    
  }
  
  boolean checkTouch(PVector pos) {
    boolean asTouched = false;
    for (Obstacle obs : obstacles) {
      asTouched = obs.containsPoint(pos.x, pos.y, true);
      if (asTouched) {
         obsCentroid = PVector.sub(pos, obs.centroid);
         break;
      }
    }
    return asTouched;
  }
  
  boolean touchLuciole(PVector _p) {
    boolean _t = false;
    for (Luciole _l : lucioles) {
      float dist = _p.dist(_l.position);
      if (dist <= _l.rad) {
        _t = true;
        _l.explode();
        break;
      }
    }
    return _t;
  }
  color LineColor () {
    /*
      this function define color of lines according to number of players
      at startup
    */
    color customColor = color(255,255,255);
    
    switch (id) {
      case 'r' :
        customColor = color(255,0,0);
        break;
      case 'g' :
        customColor = color(0, 255, 0);
        break;
      case 'b' :
        customColor = color(0, 0, 255);
        break;
    }
    /*
    if (numPlayers == 2) {
      for (Player pl : players) {
        if (pl != this.parent) {
          colorMode(HSB, 255);
          float rHue = hue(pl.drawing.lineColor);
          float newHue = rHue+122;
          float curHue = hue(lineColor);
          if (newHue > 255) newHue = newHue - 255;
          if (newHue < 0) newHue = 255 - newHue;
          customColor = color(newHue, saturation(255),brightness(255));
          colorMode(RGB);
          if (newHue == curHue) RandomWalkColor(customColor);
        }
      }
    }
    else {
      // randomize color
      colorMode(HSB,255);
      customColor = color(hue(125),saturation(255),brightness(255));
      colorMode(RGB);
    }
    */
    return customColor;
  }
  
  color controledColor () {
    /*
      this function is used for a global color change defined by orientation of one player's remote's orientation
      -> the orientation of this remote changes the brightness of all player's color
    */
    colorMode(HSB,255);
      color _c = color(hue(lineColor), saturation(lineColor), brightness(brightness));
    colorMode(RGB);
    return _c;
  }
  
  
  // --------------- END OF DRAWING CLASS ----------------//
}


color RandomWalkColor (color _basecolor) {
    /*
        called only if in random color mode
        updated each time line is updated (cf update function)
        random only on HUE value of given color
    */
    colorMode(HSB,255);
    float curHue = hue(_basecolor);
    float newHue = curHue+random(-10,10);
    color myColor = color(newHue, saturation(_basecolor), brightness(_basecolor));
    colorMode(RGB);
    return myColor;
  }
