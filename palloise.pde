int columns, rows;
float colOffset, rowOffset, noise1, noise2, noiseScale1, noiseScale2, xseed1, yseed2, seed1, seed2, noiseOffset1, noiseOffset2, noiseInc1, noiseInc2, radiusFactor, radiusMax;
color bkgCol, fillCol, strokeCol;

void setup() {
  //frameRate(1);
  size(1024,1024);
  colorMode(HSB, 255, 255, 255, 255);
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  bkgCol = color(255, 0, 255); //white
  fillCol = color(0, 0, 1, 48); //black
  strokeCol = color(0, 0, 1, 128); //black-invisible
  background(bkgCol);
  columns = 15;
  rows = columns;
  colOffset = width/(columns*2);
  rowOffset = height/(rows*2);
  radiusFactor = 2;
  radiusMax = colOffset * radiusFactor;
  //println("colOffset:", colOffset, " radiusMax:",radiusMax);
  seed1 = random(1000);
  seed2 = random(1000);
  noiseOffset1 = 0;
  noiseOffset2 = 0;
  noiseScale1 = 3;
  noiseScale2 = 3;
  noiseInc1 = 0.005;
  noiseInc2 = 0.005;
}

void draw() {
  background(bkgCol);
  for(int col = 0; col<columns; col++) {
    for(int row = 0; row<rows; row++) {
      float x = map (col, 0, columns, 0, width) + colOffset;
      float y = map (row, 0, rows, 0, height) + rowOffset;
      float xseed1 = map (x, 0, width, 0, noiseScale1);
      float yseed1 = map (y, 0, width, 0, noiseScale1);
      noise1 = noise(xseed1 + seed1 + noiseOffset1, yseed1 + seed1 + noiseOffset1); // value in range 0-1
      noise2 = noise(x + seed2 + noiseOffset2, y + seed2 + noiseOffset2); // value in range 0-1
      float r = map(noise1, 0, 1, 0, radiusMax);
      //println("noise1: ",noise1, " radiusMax:", radiusMax, " r:", r);
      fill(fillCol);
      stroke(strokeCol);
      ellipse(x, y, r, r);
    }
  } 
  noiseOffset1 += noiseInc1;
  noiseOffset2 += noiseInc2;
}
