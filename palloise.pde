import processing.pdf.*; // For exporting output as a .pdf file
import com.hamoid.*;     // For creating .mp4 animations from output images

VideoExport videoExport; // A VideoExport object called 'videoExport' (used when exporting video)

int columns, rows;
float colOffset, rowOffset, noiseScale1, noiseScale2, noiseRadius1, noiseRadius2, radiusFactor, radiusMax;
color bkgCol, fillCol, strokeCol, fillCol2;

int batch = 1;

String applicationName = "palloise";

String pngFile;       // Name & location of saved output (.png final image)
String pdfFile;       // Name & location of saved output (.pdf file)
String framedumpPath; // Name & location of saved output (individual frames) NOT IN USE
String mp4File;       // Name & location of video output (.mp4 file)

boolean makePDF = false;
boolean savePNG = true;
boolean makeMPEG = false;
boolean runOnce = false;

int maxFrames = 800; //Total number of frames before exiting/making video, also equals the number of steps taken in one circular path
int frameCounter;    //Starts at maxFrames and counts down

PrintWriter logFile;    // Object for writing to the settings logfile

void setup() {
  //frameRate(30);
  //size(512,512);
  size(1024,1024);
  //fullScreen();
  colorMode(HSB, 360, 255, 255, 255);
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  bkgCol = color(240, 255, 255);
  fillCol = color(0, 0, 1, 48);
  //strokeCol = color(0, 0, 1, 32);
  noStroke();
  background(bkgCol);
  columns = 13;
  rows = columns;
  //rows = 25;
  colOffset = width/(columns*2);
  rowOffset = height/(rows*2);
  radiusFactor = 1.50; // last:1.2
  radiusMax = colOffset * radiusFactor;
  //println("colOffset:", colOffset, " radiusMax:",radiusMax);
  noiseScale1 = 1;
  noiseScale2 = 2;
  noiseRadius1 = 10;
  noiseRadius2 = 50;
  getReady();
  if (makeMPEG) {
    videoExport = new VideoExport(this, mp4File);
    videoExport.setFrameRate(30);
    videoExport.setQuality(70, 128);
    //videoExport.setDebugging(false);
    videoExport.startMovie();
  }
}

void draw() {
  if (frameCounter >= maxFrames && runOnce) {shutdown();} // Comment this out to run forever or leave in to run once
  int currStep = frameCount%maxFrames;
  float stepAngle = map(currStep, 0, maxFrames, 0, TWO_PI);
  float bkgCycle = 1000;
  float sineWave = sin(map(frameCount % bkgCycle, 0, bkgCycle, 0, TWO_PI));
  float cosWave = cos(map(frameCount % bkgCycle, 0, bkgCycle, 0, TWO_PI));
  radiusMax = colOffset * radiusFactor * map(sineWave, -1, 1, 2.5, 4.0);
  noiseScale1 = map(sineWave, -1, 1, 0.5, 1);
  noiseScale2 = map(sineWave, -1, 1, 2, 1);
  float bkgS = map(sineWave, -1, 1, 128, 255);
  bkgCol = color (240, 255, bkgS);
  background(bkgCol);
  for(int col = 0; col<columns; col++) {
    for(int row = 0; row<rows; row++) {
      float x = map (col, 0, columns, 0, width) + colOffset;
      float y = map (row, 0, rows, 0, height) + rowOffset;
      float xCycle1 = x + noiseRadius1 * cos(stepAngle); //x-coord for circular noise path 1
      float yCycle1 = y + noiseRadius1 * sin(stepAngle); //y-coord for circular noise path 1
      float xCycle2 = x + noiseRadius2 * cos(stepAngle); //x-coord for circular noise path 2
      float yCycle2 = y + noiseRadius2 * sin(stepAngle); //y-coord for circular noise path 2
      float xseed1 = map (xCycle1, -noiseRadius1, width+noiseRadius1, 0, noiseScale1);
      float yseed1 = map (yCycle1, -noiseRadius1, width+noiseRadius1, 0, noiseScale1);
      float xseed2 = map (xCycle2, -noiseRadius2, height+noiseRadius2, 0, noiseScale2);
      float yseed2 = map (yCycle2, -noiseRadius2, height+noiseRadius2, 0, noiseScale2);
      float noise1 = noise(xseed1*noiseScale1, yseed1*noiseScale1); // value in range 0-1
      float noise2 = noise(xseed2*noiseScale2, yseed2*noiseScale2); // value in range 0-1
      float noise3 = noise(xseed1*noiseScale1, yseed2*noiseScale2); // Bonus noise!
      float rx = map(noise1, 0, 1, 0, radiusMax);
      float ry = map(noise2, 0, 1, 0, radiusMax);
      //float fillH = map(noise1, 0, 1, 0, 255);
      float fillH = (240 +  map(noise3, 0, 1, 110, 130))%360;
      //float fillH = 0;
      //float fillS = map(noise3, 0, 1, 0, 255);
      //float fillS = 255; 
      float fillS = map(noise3, 1, 0, 128, 255);
      float fillB = map(noise3, 1, 0, 192, 255);
      //float fillA = map(noise1, 0, 1, 0, 255);
      //float fillB = 255;
      float fillA = 255;
      fillCol = color(fillH, fillS, fillB,fillA);
      fillCol2 = color(fillH+120, fillS, fillB,fillA);
      
      fill(fillCol);
      //if (noise2 > 0.5) {fill(fillCol2);} else {fill(fillCol);}
      //stroke(strokeCol);
      pushMatrix();
      translate(x, y);
      float angle = map(noise3, 0, 1, 0, TWO_PI);
      rotate(angle);
      //ellipse(0, 0, rx, ry);
      triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5));
      //if (noise1 > 0.3) {fill(fillCol2);} else {fill(fillCol);} 
      //if (noise1 > 0.6) {ellipse(0, 0, rx, ry);} else {triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5));}
      //noStroke();
      //triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5));
      //rect(0, 0, rx, ry);
      //ellipse(0, 0, ry*0.5, ry*0.5);
      popMatrix();
    }
  }
  frameCounter ++;
  println(frameCounter);
  if (makeMPEG) {videoExport.saveFrame();} // If in MPEG mode, save one frame per draw cycle to the file
}

// prepares pathnames for various file outputs
void getReady() {
  frameCounter = 0;
  String batchName = String.valueOf(nf(batch,3));
  String timestamp = timeStamp();
  String pathName = "../../output/" + applicationName + "/" + batchName + "/" + String.valueOf(width) + "x" + String.valueOf(height) + "/"; //local
  pngFile = pathName + "/png/" + applicationName + "-" + batchName + "-" + timestamp + ".png";
  //screendumpPath = "../output.png"; // For use when running from local bot
  pdfFile = pathName + "/pdf/" + applicationName + "-" + batchName + "-" + timestamp + ".pdf";
  mp4File = pathName + applicationName + batchName + ".mp4";
  logFile = createWriter(pathName + "/settings/" + applicationName + "-" + batchName + "-" + timestamp + ".log"); //Open a new settings logfile
  logStart();
  if (makePDF) {beginRecord(PDF, pdfFile);}
}

void logStart() {
  logFile.println(pngFile);
  logFile.println("maxFrames = " + maxFrames);
  logFile.println("columns = " + columns);
  logFile.println("rows = " + rows);
  logFile.println("radiusFactor = " + radiusFactor);
  logFile.println("noiseScale1 = " + noiseScale1);
  logFile.println("noiseScale2 = " + noiseScale2);
}

void logEnd() {
  logFile.flush();
  logFile.close(); //Flush and close the settings file
}


// saves an image of the final frame, closes any pdf & mpeg files and exits
void shutdown() {
  logEnd();
  if (savePNG) {saveFrame(pngFile);} // Save an image of how the colony looked when it was terminated
  if (makePDF) {endRecord();} // If I'm in PDF-mode, complete & close the file
  if (makeMPEG) {videoExport.endMovie();} // If in MPEG mode, complete & close the file
  exit();
}

//returns a string with the date & time in the format 'yyyymmdd-hhmmss'
String timeStamp() {
  String s = String.valueOf(nf(second(),2));
  String m = String.valueOf(nf(minute(),2));
  String h = String.valueOf(nf(hour(),2));
  String d = String.valueOf(nf(day(),2));
  String mo = String.valueOf(nf(month(),2));
  String y = String.valueOf(nf(year(),4));
  String timestamp = y + mo + d + "-" + h + m + s;
  return timestamp;
}