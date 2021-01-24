//Player[] players;
ArrayList<Player> players;

class Player {
  Serial remote;
  Drawing drawing;
  PGraphics canvas;
  char id;
  color pcolor;
  JSONObject datas, position, orientation, collisions, superposition;
  int lastOVal, lastOrientationMessage;
  
  Player (String port, Serial _s, int _id, JSONArray _datas) {
    // custom datas
    id = readPlayerDatas(_datas, _id);
    // serial object
    remote = _s;
    remote.bufferUntil(ENTER);
    delay(150);
    remote.clear();
    // setup drawing object (class) and canvas
    canvas = createGraphics (width, height);
    canvas.noSmooth();
    drawing = new Drawing (id, canvas, this); 
    //
    lastOVal = 0; // last orientation value
    lastOrientationMessage = 0;
      // print out creation of player
      print(port + "  ---> ");
      print(id + "  ---> ");
      println("player successfully created");
  }

  char readPlayerDatas (JSONArray _datas, int _id) {
    // we get datas for serial communication
    // the function return the id (r,g,b) of the player
    // the _id define which color will be the player
    datas = _datas.getJSONObject(_id);
    // fill up all objects
    id = datas.getString("id").charAt(0);
    position = datas.getJSONObject("position");
    orientation = datas.getJSONObject("orientation");
    collisions = datas.getJSONObject("obs_collisions");
    superposition = datas.getJSONObject("superposition");
    
    return id;
  }
  
  void Update (String _readString) {
    /*
      this update function is called every time a string "_readString" is received in serial port
    */
    if (_readString.length() > 1) {
      String[] str = _readString.trim().split(",");
      //remote.clear();
      if (str.length >= 1) {
        char dir = str[0].charAt(0);
        // attempt to flush the serial, each time we receive datas
        if (dir == 's') {
          // player shaked the remote
          drawing.isShaked();
          remote.clear();
          return;
        }
        else if (dir == 'x' || dir =='y') {
          // update cursor position
          int value = parseInt(str[1]);
          drawing.update(dir, value);
          remote.clear();
          return;
        }
        else if (dir == 'o') {
          // orientation value from USB serial
          int val = round(parseInt(str[1]));
          if (val != lastOVal) {
            // Send new orientation value to sound software, using OSC
            orientationToOSC(val);
            // update global sketch values based on players orientation values
            switch(id) {
              case 'r': // r 
                if (val <= 0) penStep = int(map(val, -90, 0, 10, 2));
                if (val >= 0) penStep = int(map(val, 0, 90, 2, 10));
                break;
              case 'g' : // g
                //brightness = int(map(val, -90, 90, 125, 255));
                if (val <= 0) brightness = int(map(val, -90, 0, 60, 255));
                if (val >= 0) brightness = int(map(val, 0, 90, 255, 60));
                break;
              case 'b' : // b
                if (val <= 0) penSize = int(map(val, -90, 0, 20, 2));
                if (val >= 0) penSize = int(map(val, 0, 90, 2, 20));
                break;
            }
          }
          remote.clear();
          return;
        }
        else print(id + " --> received datas 1 : " + _readString);
      }
      else print(id + " --> received datas 2 : " + _readString);
    }
    else print(id + " --> error with received datas : " + _readString);
  }
  
  void sendSerialMessage (char _message) {
    // send back a message to player's remote
    remote.write(_message);
  }
  
  /*
  -------- OSC --------
  */
  void penToOSC (PVector _pen, char _dir) {
    /*
        input -> pen position values
        output -> OSC message to be sent
        
        this function is using external json datas to :
        - remap input values according to external datas
        - define osc path and target NetAdress (ableton / reaper)
    */
    
    String _value = "";  // osc value to be constructed
    float v = .0; // float to be  remapped
    NetAddress _port = abletonLocation; // default port is ableton
    String _path = ""; // osc path to be defined
    JSONArray posDatas = new JSONArray(); // temp JSONArray for datas
    
    // define direction of move, to only send new datas to sound software
    switch (_dir) {
      case 'x' :
        v = map(_pen.x, 0, width, 0, 1); // range to 0 1
        posDatas = position.getJSONArray("x");
        break;
     case 'y' :
        v = map(_pen.y, 0, height, 0, 1); // range to 0 1
        posDatas = position.getJSONArray("y");
        break;
    }
    
    for (int i = 0; i < posDatas.size(); i++) {
      JSONObject tmpDatas = posDatas.getJSONObject(i);
      JSONArray f = tmpDatas.getJSONArray("mapping");
      if (v >= f.getFloat(0) && v <= f.getFloat(1)) {
        // remap original 0-1 value to target range defined in json datas
        v = map(v, f.getFloat(0), f.getFloat(1), f.getFloat(2), f.getFloat(3));
        // setup osc port from json datas
        _port = definePort(tmpDatas.getString("port"));
        // get osc path from json datas
        _path = tmpDatas.getString("oscpath");
      }
      // parse to osc message form
      _value = Float.toString(v); // convert to string
      // send osc message
      sendOSCMessage(_path, _value, _port); // send message
    }
    
  }
  
  void orientationToOSC (int _val) {
    /*
        input -> orientation value from USB serial
        output -> OSC message to be sent
        
        this function is using external json datas to :
        - remap input values according to external datas
        - define osc path and target NetAdress (ableton / reaper)
    */
    // remap value using external json datas
    JSONArray f = orientation.getJSONArray("mapping");
    int v = round(map(_val, f.getFloat(0), f.getFloat(1), f.getFloat(2), f.getFloat(3)));
    // we filter new values to reduce amount of messages to send
    if (v != lastOrientationMessage) {
      // get port and path from json external datas
      NetAddress _port = definePort(orientation.getString("port"));
      String _path = orientation.getString("oscpath");
      String _value = Float.toString(v); // convert to string
      sendOSCMessage(_path, _value, _port); // send osc message
      lastOrientationMessage = v;
    }
  }
  
  void collisionsToOSC (int val) {
    /*
        input -> collision value (0/1) if players is in obstacle
        output -> OSC message to be sent to sound software
        
        this function is using external json datas to :
        - remap input values according to external datas
        - define osc path and target NetAdress (ableton / reaper)
    */
    NetAddress _port = definePort(collisions.getString("port"));
    String _path = collisions.getString("oscpath");
    // remap value using external json datas
    JSONArray f = collisions.getJSONArray("mapping");
    int v = (int)map(val, f.getFloat(0), f.getFloat(1), f.getFloat(2), f.getFloat(3));
    String _value = v+""; // convert to string
    // send osc message
    sendOSCMessage(_path, _value, _port); // send message
  }
  
  NetAddress definePort(String p) {
    /*
      this function define target address for OSC message based on string input "port" in json external datas
    */
    NetAddress _port = abletonLocation;  
    switch(p) {
      case "ableton" :
        _port = abletonLocation;
        break;
      case "reaper" :
        _port = reaperLocation;
        break;
    }
    return _port;
  }
    
  void sendOSCMessage (String commandToSend, String valueToSend, NetAddress _port) {
    // final function to send OSC message to sound software
    OscMessage myMessage = new OscMessage(commandToSend);
    myMessage.add(valueToSend);
    oscP5.send(myMessage, _port);
    //println("OSC : " + commandToSend + " -> " + valueToSend);
  }
  
  
  // --------------- END OF PLAYERS CLASS ----------------//  
}

void playersLoading () {
  // list usb ports available
  String[] ports = Serial.list();
  JSONArray d = loadJSONArray("players-datas.json");
    // go through serial ports and keep only valid usb ports
  for (int p=0; p < ports.length; p++) {
    lastSerialTime = 0;
    String[] m = match(ports[p], osmatch);
    if (m != null){
      Serial s = new Serial(this, ports[p], BAUDS);
      Player plyr = new Player(ports[p], s, numPlayers, d);
      players.add(plyr);
      // increment number of active players
      numPlayers +=1;
    }
  }
}
