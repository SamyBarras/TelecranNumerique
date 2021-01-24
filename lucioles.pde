/* lucioles */

final int WAIT_TIME = (int) (30 * 1000); // 60 sec before lucioles starts to spawn
final int SPAWN_INTERVAL = (int) (2 * 1000); // 10 sec
int lastSerialTime = -1;
int lastSpawn = 0;
float luciolesSpeed = .3;
ArrayList<Luciole> lucioles, _l;

class Luciole {
  /*
  
    lucioles are independant objects that are created and placed randomly
    they generate extra sound events as soon as a player touch them
    
  */
  PVector position;
  float rad;
  int life;
  color col;
  int mult = 5;
  PGraphics canvas;
  boolean eraticMove = false, killed = false;
  PVector dir;
  int explosionSteps = 10;
  
  PVector newPos = new PVector (0,0);
  int rotationTimer=90;
  
  Luciole (PGraphics _c) {
    position = new PVector (0,0);
    rad = (int) random(3,7);
    col = color (255);
    canvas = _c;
    dir = new PVector(0,0);
    life = 0;
  }
  
  /* functions */
  void spawn() {
    // creation of the luciole
    position = new PVector (random(0, width), random(0,height));
    // check if luciole not spawned in obstacle or outside of sketch's bounds
    if (isInObstacle() || isOutside()) {
      this.spawn();
      return;
    }
    else {
      lastSpawn = millis();
    }
  }
  
  void update() {
    // make frame by frame changes
    if (!killed) {
      if (life%rotationTimer == 0) {
        //frameCount
        // every X frames we update direction
        if (eraticMove) {
          // move luciole randomly every frame
          position.x += random(-1*mult,1*mult);
          position.y += random(-1*mult,1*mult);
        }
        else {
          // try to move it gently but with random goal
          float aTheta = position.heading() + random(-5,5);
          newPos.x = cos(aTheta);
          newPos.y = sin(aTheta);
        }
        rotationTimer = (int) random(60,90);
      }
      newPos.normalize();
      newPos.mult(luciolesSpeed);
      PVector velocity = new PVector (0,0);
      velocity.add(newPos);
      position.add(velocity);
      // should we kill it ?
      if (isInObstacle()) {
        if (obstacleKillLuciole == true) kill("obstacle");
        else showInverted();
      }
      else if (isOutside()){
        kill("boundaries");
      }
      else show();
      life++;
    }
    else {
      showExplosion();
    }
  }
  
  void kill(String s) {
    lucioles.remove(this);
    //println("luciole killed by "+s);
  }
  
  void explode () {
    killed = true;
  }
  
  void show () {
    // draw to its canvas
    canvas.fill(col);
    canvas.noStroke();
    canvas.ellipse(position.x, position.y, rad, rad);
  }
  
  void showExplosion () {
    // draw to its canvas
    if (explosionSteps > 0) {
      canvas.noFill();
      colorMode(HSB,255);
        color _c = color(hue(col), saturation(col), brightness((int)map(explosionSteps, 0, 10, 0, 255)));
      colorMode(RGB);
      canvas.stroke(_c); 
      float _r = rad*explosionSteps;
      canvas.strokeWeight(rad);
      canvas.ellipse(position.x, position.y, _r, _r);
      explosionSteps--;
    }
    else {
      kill("explosion");
    }
  }
  void showInverted () {
    // draw to its canvas
    canvas.fill(255);
    canvas.noStroke();
    canvas.ellipse(position.x, position.y, rad, rad);
  }
  
  /* booleans */
  boolean isOutside(){
    boolean _b = false;
    if (position.x < 0 || position.x > width || position.y < 0 || position.y > height) _b = true;
    return _b;
  }
  
  boolean isInObstacle () {
    boolean inObstacle = false;
    for (Obstacle o : obstacles) {
      if (o.containsPoint(position.x, position.y, false) == true) {
        inObstacle = true;
      }
    }
    return inObstacle;
  }
  
  // --------------- END OF LUCIOLE CLASS ----------------//
}

/* globals for lucioles class */
  
boolean LuciolesTimer() {
  if (lastSerialTime != -1)  return millis() - lastSerialTime < WAIT_TIME; // true if last serial is more recent than 30 sec
  else return false; // no serial com at all  --> no luciole
}

void createLuciole () {
  int spawnElapsedTime = millis()-lastSpawn;
  if (LuciolesTimer() &&  spawnElapsedTime > SPAWN_INTERVAL) {    
    //startTime = millis();
    if (lucioles.size() < numOfLucioles) {
      Luciole l = new Luciole(luciolesCanvas);
      lucioles.add(l);
      l.spawn();
    }
  }
}
