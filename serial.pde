/* EXTERNAL COMMUNICATION 
*
*  to communicate with players remote and extrenal softwares
*  serial -->  remotes are connected using USB
*
*/


/* serial */
import processing.serial.*;
void serialEvent(final Serial s) {
  // serial receiver
  // update receiver timer
  lastSerialTime = millis();
  //
  for (Player pl : players) {
    if (pl.remote == s) {
      pl.Update(s.readString());
      break;
    }
  }
  s.clear();
}


/* OSC */
import oscP5.*;
import netP5.*;
public OscP5 oscP5;
public NetAddress abletonLocation;
public NetAddress reaperLocation;

void createOSCCom () {
  oscP5 = new OscP5 (this, listeningPort); // osc communication, listening on port 3000
  abletonLocation = new NetAddress(MusicComputer, AbletonPort);
  reaperLocation = new NetAddress(MusicComputer, ReaperPort);
}


String osSetup() {
  String os = System.getProperty("os.name");
  if (os.contains("Windows")) {
    // os-specific setup and config here
    osmatch = "COM";
    return "win";
  } else if (os.contains("Mac")) {
    // ...
    osmatch = "tty.usbmodem";
    return "mac";
  }
 else {
   println("ERROR --> can't define port name according to OS");
   return os;
 }
}
