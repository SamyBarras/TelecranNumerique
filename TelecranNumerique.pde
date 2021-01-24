/*
    code developped by Samy Barras
    samy.barras@gmail.com
    
    for Mamatus Collective
    2020.11 - http://mamatus.fr
        
    Dependencies :
    - Syphon
    - oscP5
*/

void settings() {
  size(640, 480, P2D);//2560, 1600 // 1280 / 800
  //fullScreen(P2D, 1);
  //noSmooth(); // remove anti-aliasing to speed up rendering
}
void setup() {
  //
  frameRate(60);
  //
  font = createFont("Avenir", 20);
  // obstacles
  obstacles = new ArrayList<Obstacle>();
  thread("loadObstaclesData");
  // 
  console = createGraphics(width, height);
  edit = createGraphics(width, height);
  extra = createGraphics(width, height);
  luciolesCanvas = createGraphics(width, height);
  output = createGraphics(width, height); // this is main Pgraphics which will contains all other
  
  /* serial and players setup */
  osType = osSetup(); // define os to search proper match (tty / COM) in port name
  // build players array list, to fill with valid serial ports
  players = new ArrayList<Player>();
  players.clear();
  // load players external json datas
  thread("playersLoading");
  //
  lucioles = new ArrayList<Luciole>();
  _l = new ArrayList<Luciole>();
  // setup OSC com
  thread("createOSCCom");  // osc com on separated thread --> check if communication works well
  /* syphon server */
  if (syphonOutput == true) {
    servers = new SyphonServer[nServers];
    for (int i = 0; i < nServers; i++) { 
      servers[i] = new SyphonServer(this, "Telecran.Syphon."+i);
    }
  }
  // end of setup
  
}

void draw() {
  background(0);
  if (oscP5 == null) return;
  // start final output layer drawing
  output.beginDraw();
  output.clear();
  //
  if (editMode) { 
    // edit layer constructors
    edit.smooth();
    edit.beginDraw();
    edit.clear();
    edit.background(color(125,125,125));
    // draw obstacles
    edit.strokeWeight(1);
    edit.stroke(255,0,0);
    drawObstacles (edit, true, true);
    //
    if (!recording) {
      edit.fill(255);
      edit.textFont(font,12);
      edit.text("shape's creation mode", 20, height-60);
      edit.text("press \"n\" to create an obstacle and \"enter\" to save it", 20, height-40);
      edit.text("press \"r\" to save gabarit", 20, height-20);
      if (is_drawing_obs) {
        edit.noFill();
        edit.stroke(255);
        // draw a cross for mouse position
        edit.line(mouseX-10, mouseY, mouseX+10, mouseY); // x
        edit.line(mouseX, mouseY-10, mouseX, mouseY+10); // y
        /* draw temp shape during creation */
        edit.beginShape();
        for (PVector p : tempShape)  edit.vertex( p.x, p.y);
        edit.endShape(CLOSE);
        /* draw line between last point of temp shape and current mouse position */
        if (lastClic != null && clic_count > 0) edit.line(lastClic.x, lastClic.y, mouseX, mouseY);
      }
    }
    edit.endDraw();
    output.image(edit, 0, 0);
  }
  else {
    // not in edit mode
    /* extras */
    thread("updateObstacles");
    extra.smooth();
    extra.beginDraw();
    extra.clear();
    // show credits
    if (credits) {
      String credit = "Created by Mamatus Collective";
      int csize = 12;
      extra.fill(255);
      extra.textFont(font, csize);
      extra.text(credit, (width-(credit.length()*(csize/2)))/2, height-10);
    }
    // show obstacles shapes
    if (showObstacles) {
      extra.stroke(0,255,0);
      extra.noFill();
      drawObstacles (extra, true, false);
    }
    extra.endDraw();
    
    /* lucioles */
    thread("createLuciole"); // spawn new lucioles
    luciolesCanvas.beginDraw();
    luciolesCanvas.clear();
    for (int l=0; l < lucioles.size(); l++) {
      Luciole _l = lucioles.get(l);
      _l.update();
    }
    luciolesCanvas.endDraw();
    
    // assembling layers to output image
    output.blendMode(ADD);
    if (lucioles.size() > 0) output.image(luciolesCanvas, 0,0);
    if (credits || showObstacles) output.image(extra, 0, 0);
    if (players.size() > 0) {
      /*  players canvas  */
      for (Player pl : players) {
        pl.canvas.beginDraw();
        pl.drawing.trace();
        pl.canvas.endDraw();
        output.image(pl.canvas, 0,0);
      }
    }

  }
  /* DISPLAY OUTPUT */
  output.endDraw(); // end of drawing for output
  if (showOutput) image(output, 0 ,0); // display output or not
  if (syphonOutput) servers[0].sendImage(output);
  
  
  // record animation --> to be tested / debugged
  if (recording) {
    if (!editMode) saveFrame("output/telecran_####.png");
    else saveFrame("output/telecran_gabarit.png");
    recording = false;
  }
  
  /* CONSOLE to show custom infos */
  console.smooth();
  console.beginDraw();
  console.clear();
  if (UIActive && !recording) {
    console.textFont(font, 12);
    console.noFill();
    console.stroke(255);
    console.text("fps : "+int(frameRate),20,20);
    console.text("players : " + players.size(), 20,40);
    console.text("obstacles : " + obstacles.size(), 20,60);
    console.text("shortcuts :", 20, 80);
    console.text("e > edit mode\ni > console\nr > save frame\n", 40, 100);
    console.text("pen size : " + Math.round(penSize), 20, 180);
    console.text("pen step : " + Math.round(penStep), 20, 200);
  }
  console.endDraw();
  image(console, 0, 0);
  
  // end of draw
  //Runtime.getRuntime().gc();
}
