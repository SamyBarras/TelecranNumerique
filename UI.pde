boolean editMode = false;
boolean UIActive = true;
boolean is_drawing_obs = false;
boolean showObstacles = false;
int clic_count;
PVector mousePos;
ArrayList<PVector> tempShape = new ArrayList();

void keyPressed() {
  switch(key) {
    case 'e' :
      editMode = !editMode;
      break;
    case 'i' :
      UIActive = !UIActive;
      break;
    case 'o' :
      showObstacles = !showObstacles;
      break;
    case 'r' :
      recording = !recording;
      break;
    case 'c' :
      credits = !credits;
      break;
    case 's' :
      lastSerialTime = millis();
      println("update serialtime");
      break;
    case 'l':
      showOutput = !showOutput;
      break;
  }
  
  if (editMode == true){
    if(key == 'n') {
      is_drawing_obs = !is_drawing_obs;
      if (is_drawing_obs){
        // start new shape
        clic_count = 0;
      }
    }
    if (is_drawing_obs) {
      if (key == ENTER) {
        // save the shape
        String plist = new String();
        ArrayList newShape = new ArrayList ();
        
        for (int i=0; i < tempShape.size(); i++) {
          newShape.add(tempShape.get(i));
          plist += tempShape.get(i).toString();
        }
        
        tempShape.clear();      
        updateObstaclesData(plist);      
        is_drawing_obs = !is_drawing_obs;
      }
      if (key == BACKSPACE) {
          clic_count = 0;
          tempShape.clear();
      }
    }
    else {
      if (key == BACKSPACE) {
          // may add option to delete last created shape
          deleteLastObstacle ();
        }
    }
  }
}

void mousePressed() {
  lastClic = new PVector(mouseX,mouseY);
  if (editMode == true) {
    // we are in edit mode
    if (is_drawing_obs) {
      clic_count += 1;
      tempShape.add(new PVector(mouseX,mouseY));
    }
  }
}
