/* envoyer des message à intervalle regulier (3sec) */
int intervalTime = 3000;
int prevTime = 0;
 
void sendIntervalTime()
{
  if(millis() > prevTime + intervalTime)
  {
    //send the OSC message
    prevTime = millis();
  }
}


// Float.toString(f)

      /*
      if (id == 'r') {
          colorMode(HSB,255);
          customColor = color(random(0,255),saturation(255),brightness(255));
          colorMode(RGB);
      }
      else {
          colorMode(HSB, 255);
          float curHue = hue(players[0].drawing.lineColor);
          float newHue = curHue+122;
          if (newHue > 255) newHue = newHue - 255;
          if (newHue < 0) newHue = 255 - newHue;
          customColor = color(newHue, saturation(255),brightness(255));
          colorMode(RGB);
      }
      */

/*

if (pen != lastPen) {
      // first define direction and remap value
      String _value = "";
      Float v = .0;
      if (dir == 'x')  {
        v = map(pen.x, 0, width, 0, 1); // range to be defined according to Ableton parameters
        _value = Float.toString(v); // convert to string
      }
      else {
        v = map(pen.y, 0, height, 0, 1); // range to be defined according to Ableton parameters
         _value = Float.toString(v); // convert to string
      }
      // send osc message
      parent.sendOSCMessage(dir+"", _value); // send message
      
      // color check for drawing superposition
      color c = get(int(pen.x), int(pen.y));
      colorMode(HSB, 255);
      float pixelSaturation = saturation(c);
      float vSat = map(pixelSaturation, 0, 255, 0, 1); // range to be defined according to Ableton parameters
      colorMode(RGB);
      int sat = round(vSat);
      if (sat != prevSat) {
        // change in saturation of new pixel... we need to send message to ableton
        if (sat == 1) {
          println(parent.id+" --> superposition de tracé");
          // send osc message
          parent.sendOSCMessage("s", "1");
        }
        else {
          parent.sendOSCMessage("s", "0");          
        }
      }
      prevSat = sat;
    }
  }
  
  
  */
      
      
      
      