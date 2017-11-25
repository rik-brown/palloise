import processing.pdf.*; // For exporting output as a .pdf file
import com.hamoid.*;     // For creating .mp4 animations from output images

VideoExport videoExport; // A VideoExport object called 'videoExport' (used when exporting video)

int columns, rows;
float colOffset, rowOffset, noiseScale1, noiseScale2, xseed1, yseed2, seed1, seed2, noiseOffset1, noiseOffset2, noiseInc1, noiseInc2, radiusFactor, radiusMax;
color bkgCol, fillCol, strokeCol, fillCol2;

int batch = 1;

String applicationName = "palloise";
String batchName = String.valueOf(nf(batch,3)); // Used to define the output folder
String pathName;
String screendumpPath; // Name & location of saved output (final image)
String screendumpPathPDF; // Name & location of saved output (pdf file)
String framedumpPath; // Name & location of saved output (individual frames)
String videoPath; // Name & location of video output (.mp4 file)

boolean makePDF = true;
boolean savePNG = true;
boolean makeMPEG = true;

int maxFrames = 10; //Total number of frames before exiting/making video
int frameCounter;    //Starts at maxFrames and counts down

PrintWriter logfile;    // Object for writing to the settings logfile

void setup() {
  //frameRate(1);
  //size(512,512);
  size(1024,1024);
  //fullScreen();
  colorMode(HSB, 360, 255, 255, 255);
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  bkgCol = color(240, 255, 255);
  fillCol = color(0, 0, 1, 48);
  strokeCol = color(0, 0, 1, 32);
  noStroke();
  background(bkgCol);
  columns = 49;
  rows = columns;
  //rows = 25;
  colOffset = width/(columns*2);
  rowOffset = height/(rows*2);
  radiusFactor = 1.5; // last:1.2
  radiusMax = colOffset * radiusFactor;
  //println("colOffset:", colOffset, " radiusMax:",radiusMax);
  seed1 = random(1000);
  seed2 = random(1000);
  noiseOffset1 = 0;
  noiseOffset2 = 0;
  noiseScale1 = 2;
  noiseScale2 = 2;
  noiseInc1 = 0.002;
  noiseInc2 = 0.005;
  getReady();
  if (makeMPEG) {
    videoExport = new VideoExport(this, videoPath + ".mp4");
    videoExport.setFrameRate(30);
    videoExport.setQuality(70, 128);
    videoExport.setDebugging(false);
    videoExport.startMovie();
  }
}

void draw() {
  if (frameCounter <= 0 ) {shutdown();}
  float cycle = 1000;
  float sineWave = sin(map(frameCount % cycle, 0, cycle, 0, TWO_PI));
  float bkgS = map(sineWave, -1, 1, 128, 255);
  bkgCol = color (240, 255, bkgS);
  background(bkgCol);
  for(int col = 0; col<columns; col++) {
    for(int row = 0; row<rows; row++) {
      float x = map (col, 0, columns, 0, width) + colOffset;
      float y = map (row, 0, rows, 0, height) + rowOffset;
      float xseed1 = map (x, 0, width, 0, noiseScale1);
      float yseed1 = map (y, 0, width, 0, noiseScale1);
      float xseed2 = map (x, 0, width, 0, noiseScale2);
      float yseed2 = map (y, 0, width, 0, noiseScale2);
      float noise1 = noise(xseed1 + seed1 + noiseOffset1, yseed1 + seed1 + noiseOffset1); // value in range 0-1
      float noise2 = noise(xseed2 + seed2 + noiseOffset2, yseed2 + seed2 + noiseOffset2); // value in range 0-1
      float noise3 = noise(noise1, noise2); // Bonus noise!
      float rx = map(noise1, 0, 1, 0, radiusMax);
      float ry = map(noise2, 0, 1, 0, radiusMax);
      //float fillH = map(noise1, 0, 1, 0, 255);
      float fillH = map(noise3, 0, 1, 0, 360);
      //float fillH = 0;
      //float fillS = map(noise3, 0, 1, 0, 255);
      float fillS = 255; 
      float fillB = map(noise3, 0.25, 0.75, 64, 255);
      //float fillA = map(noise1, 0, 1, 0, 255);
      float fillA = 255;
      fillCol = color(fillH, fillS, fillB,fillA);
      fillCol2 = color(fillH+120, fillS, fillB,fillA);
      
      //fill(fillCol);
      if (noise2 > 0.5) {fill(fillCol2);} else {fill(fillCol);}
      //stroke(strokeCol);
      pushMatrix();
      translate(x, y);
      float angle = map(noise3, 0, 1, 0, TWO_PI);
      rotate(angle);
      ellipse(0, 0, rx, ry);
      if (noise1 > 0.3) {fill(fillCol2);} else {fill(fillCol);} 
      //noStroke();
      //triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5));
      //rect(0, 0, rx, ry);
      //ellipse(0, 0, ry*0.5, ry*0.5);
      popMatrix();
    }
  } 
  noiseOffset1 += noiseInc1;
  noiseOffset2 += noiseInc2;
  frameCounter --;
  if (makeMPEG) {videoExport.saveFrame();} // If in MPEG mode, save one frame per draw cycle to the file
}

// prepares pathnames for various file outputs
void getReady() {
  frameCounter = maxFrames;
  pathName = "../../output/" + applicationName + "/" + batchName + "/" + String.valueOf(width) + "x" + String.valueOf(height) + "/"; //local
  screendumpPath = pathName + "/png/" + applicationName + "-" + batchName + "-" + timeStamp() + ".png";
  //screendumpPath = "../output.png"; // For use when running from local bot
  screendumpPathPDF = pathName + "/pdf/" + applicationName + "-" + batchName + "-" + timeStamp() + ".pdf";
  videoPath = pathName + "/mpg/" + applicationName + "-" + batchName + "-" + timeStamp();
  logfile = createWriter(pathName + "/settings/" + applicationName + "-" + batchName + timeStamp() + ".settings.log"); //Open a new settings logfile
  logStart();
  if (makePDF) {beginRecord(PDF, screendumpPathPDF);}
}

void logStart() {
  logfile.println(screendumpPath);
  logfile.println("maxFrames = " + maxFrames);
  logfile.println("columns = " + columns);
  logfile.println("rows = " + rows);
  logfile.println("radiusFactor = " + radiusFactor);
  logfile.println("seed1 = " + seed1);
  logfile.println("seed2 = " + seed2 );
  logfile.println("noiseOffset1 = " + noiseOffset1);
  logfile.println("noiseOffset2 = " + noiseOffset2);
  logfile.println("noiseScale1 = " + noiseScale1);
  logfile.println("noiseScale2 = " + noiseScale2);
  logfile.println("noiseInc1 = " + noiseInc1);
  logfile.println("noiseInc2 = " + noiseInc2);  
}

void logEnd() {
  logfile.flush();
  logfile.close(); //Flush and close the settings file
}


// saves an image of the final frame, closes any pdf & mpeg files and exits
void shutdown() {
  if (savePNG) {saveFrame(screendumpPath);} // Save an image of how the colony looked when it was terminated
  if (makePDF) {endRecord();} // If I'm in PDF-mode, complete & close the file
  if (makeMPEG) {videoExport.endMovie();} // If in MPEG mode, complete & close the file
  logEnd();
  exit();
}

//returns a string with the date & time in the format 'yyyymmdd-hhmmss'
String timeStamp() {
  int sec = second();
  int min = minute();
  int hr = hour();
  int day = day();
  int mon = month();
  int yr = year();
  String s = String.valueOf(sec);
  String m = String.valueOf(min);
  String h = String.valueOf(hr);
  String d = String.valueOf(day);
  String mo = String.valueOf(mon);
  String y = String.valueOf(yr);
  String timestamp = y + mo + d + "-" + h + m + s;
  return timestamp;
}