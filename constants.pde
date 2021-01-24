/* custom vars */
float penSize = 2; // default 2
float penStep = 2; // default 2
int brightness = 255; // default 255
int numOfLucioles = 20;
boolean debug = true;
boolean obstacleKillLuciole = false;
float tracesLifeDuration = 1.1;

/*  OSC COM PORTS */
static final int BAUDS = 115200; // defined in arduino sketch
static final int listeningPort = 3000; // to get news from external softwares
static final int AbletonPort = 1337;
static final int ReaperPort = 8000;
static final String MusicComputer = "127.0.0.1"; // ip adress of computer with music softwares

/* display & output vars */
boolean credits = false;
boolean recording = false;
boolean showOutput = true;
boolean syphonOutput = false;

/* global vars
 *  --> not to be modified
*/
PFont font;
PGraphics console, edit, extra, luciolesCanvas, output;
PVector lastClic;
int numPlayers = 0;
String osmatch, osType;

/* syphon */
import codeanticode.syphon.*;
int nServers = 1;
SyphonServer[] servers;
