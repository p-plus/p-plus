import processing.video.*;

float panUpFactor = 1.5f;//1.0f;
float rotationFactor = 1.0f;
float zoomFactor = 0.5f;

FileExporter fileExporter;
FileImporter fileImporter;
Environment environment;

PGraphics pgOff;
Movie myMovie;

void setup() {
  size(1280, 720, P3D);
  loadConfigFile();
  initialiseEnvironment();
  fileExporter = new FileExporter();
  fileImporter = new FileImporter();
  fileImporter.loadAllFilesFromFolder();

  //Init Movie File
  myMovie = new Movie(this, "transit.mov");
  myMovie.loop();
  
  //Create an OffScreen PGraphic and add it to the Structure's facets
  pgOff = createGraphics(envXMaxUnits*3,envXMaxUnits*3, P3D);
  environment.getAnimation().addGraphics(FACET.NORTH, pgOff);  
  environment.getAnimation().addGraphics(FACET.SOUTH, pgOff);  
  environment.getAnimation().addGraphics(FACET.EAST, pgOff);  
  environment.getAnimation().addGraphics(FACET.WEST, pgOff);
  environment.getAnimation().addGraphics(FACET.BOTTOM_UP, pgOff);
  environment.getAnimation().addGraphics(FACET.CEILING_DOWN, pgOff);
  
  //Init ArtNetNode
  artnet = new ArtNet();
  try {
    artnet.start();
  } catch (SocketException e) {
    throw new AssertionError(e);
  } catch (ArtNetException e) {
    throw new AssertionError(e);
  }
  println("after");
  
}

void draw() { 
  
  //Draw some example animations on the PGraphics Element
  pgOff.beginDraw();
  pgOff.image(myMovie,0,0,pgOff.width, pgOff.height);
  pgOff.endDraw();

  
  if(!fileImporter.importingFile){
  lights();
  ambientLight(70, 70, 128);
  int concentration = 1000;
  spotLight(255, 255, 255, envXMaxUnits/2, envYMaxUnits, envZMaxUnits/2, 0, 1, 0, PI/16, concentration);
  spotLight(255, 255, 255, envXMaxUnits, envYMaxUnits/2, envZMaxUnits/2, 1, 0, 0, PI/16, concentration);
  spotLight(255, 255, 255, envXMaxUnits/2, envYMaxUnits/2, envZMaxUnits, 0, 0, -1, PI/16, concentration);
  
  spotLight(255, 255, 255, envXMaxUnits/2, 0, envZMaxUnits/2, 0, -1, 0, PI/16, concentration);
  spotLight(255, 255, 255, 0, envYMaxUnits/2, envZMaxUnits/2, -1, 0, 0, PI/16, concentration);
  
  evaluateCamera();
  evaluateControllers();
  environment.drawEnvironment();
  //environment.sendDMX();
  drawAxis(); 
  //environment.getTextRoller().rollText();  
  //environment.getParticipativeTextRoller().rollText();  
  //environment.getMultipleTextRoller().rollText();    
  environment.getAnimation().resizeAnimation();
  
  
  camera(); //resets viewport to 2D equivalent
  noLights();
  fill(255);
  text("X: "+envXMaxSize+", Y:"+envYMaxSize+", Z:"+envZMaxSize, 20, 25);
  text("Cells: "+maxCells, 20, 45);
  if(!runningSimulation){
  text("Name: "+fileName, 20, 65);
  }
  
  if(frameCount%1000==0){
    println(frameRate);
  }
  
  try {
    wait(1000);
  } catch (Exception e) {
  }
  }
}

void initialiseEnvironment() {
  lights();
  background(0);
  noStroke();
  environment = new Environment();
}

void evaluateCamera() {
  float cameraY = height/2.0;
  float fov = PI/3;
  float cameraZ = cameraY / tan(fov / 2.0);
  float aspect = float(width)/float(height);
  perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
  
  if (configMode) {
    camera(width/2, height/2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  } else {
    camera(cos(rotationFactor)*zoomFactor*2.5*height, sin(rotationFactor)*zoomFactor*2.5*height, zoomFactor*((height/2) / panUpFactor*tan(PI/6)), 0, 0, 0, 0, 0, -1);
  }
}
  
void drawAxis() {
  if (!renderLandscape) {
    // Draw x-axis
    stroke(0, 255, 0);
    line(0, 0, 0, 3*height, 0, 0);
    
    // Draw y-axis
    stroke(255, 0, 0);
    line(0, 0, 0, 0, 3*height, 0);
    
    // Draw z-axis
    stroke(0, 0, 255);
    line(0, 0, 0, 0, 0, 3*height);
    
    // Draw space
    stroke(255);
    int OFF = (configMode)?0:DRAW_OFFSET;
    line(OFF+0, OFF+envYMaxSize, 0, OFF+envXMaxSize, OFF+envYMaxSize, 0);
    line(OFF+envXMaxSize, OFF+0, 0, OFF+envXMaxSize, OFF+envYMaxSize, 0);
    line(OFF+0, OFF+0, 0, OFF+envXMaxSize, OFF+0, 0);
    line(OFF+0, OFF+0, 0, OFF+0, OFF+envYMaxSize, 0);
  }
  
}

void movieEvent(Movie m) {
  m.read();
}