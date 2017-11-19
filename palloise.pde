int columns, rows;
float colOffset, rowOffset, noiseScale1, noiseScale2, xseed1, yseed2, seed1, seed2, noiseOffset1, noiseOffset2, noiseInc1, noiseInc2, radiusFactor, radiusMax;
color bkgCol, fillCol, strokeCol;

void setup() {
  //frameRate(1);
  //size(512,512);
  //size(1024,1024);
  fullScreen();
  colorMode(HSB, 360, 255, 255, 255);
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  bkgCol = color(240, 255, 255);
  fillCol = color(0, 0, 1, 48);
  strokeCol = color(0, 0, 1, 32);
  background(bkgCol);
  columns = 9;
  rows = columns;
  //rows = 25;
  colOffset = width/(columns*2);
  rowOffset = height/(rows*2);
  radiusFactor = 1.2;
  radiusMax = colOffset * radiusFactor;
  //println("colOffset:", colOffset, " radiusMax:",radiusMax);
  seed1 = random(1000);
  seed2 = random(1000);
  noiseOffset1 = 0;
  noiseOffset2 = 0;
  noiseScale1 = 2;
  noiseScale2 = 2;
  noiseInc1 = 0.002;
  noiseInc2 = 0.003;
}

void draw() {
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
      float fillH = 0;
      //float fillS = map(noise3, 0, 1, 0, 255);
      float fillS = 255; 
      float fillB = map(noise3, 0.25, 0.75, 0, 255);
      //float fillA = map(noise1, 0, 1, 0, 255);
      float fillA = 255;
      fillCol = color(fillH, fillS, fillB,fillA);
      fill(fillCol);
      stroke(strokeCol);
      pushMatrix();
      translate(x, y);
      float angle = map(noise3, 0, 1, 0, TWO_PI);
      rotate(angle);
      ellipse(0, 0, rx, ry);
      //rect(0, 0, rx, ry);
      popMatrix();
    }
  } 
  noiseOffset1 += noiseInc1;
  noiseOffset2 += noiseInc2;
}