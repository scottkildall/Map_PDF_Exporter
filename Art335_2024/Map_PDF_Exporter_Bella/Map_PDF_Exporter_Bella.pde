/*
  Map_PDF_Exporter
  Written by Scott Kildall
  September 2017
  
  Renders out a simple CSV file to (x,y) points on the screen
  Looks for 2 header columns: "Latitude" and "Longitude"
  
  This version includes a "Size" field
  
  Output file is: data_output.pdf
  Input file is: data_input.csv
  
  Spacebar will save the file
  
*/

//-- this is a build in PDF library for Processing that allows for export 
import processing.pdf.*;

//---------------------------------------------------------------------------
//-- DEFAULT VARIABLES
final float defaultSize = 15;
final int defaultCategoryNum = 0;
final float  margin = 50;

final int startYear = 1967;
final int endYear = 2013;
int numYears;


final float homeLat = 37.777133;
final float homeLon = -122.452745;
float homeX;
float homeY;

//---------------------------------------------------------------------------
//-- this is a flag. When you press the SPACE bar, it will set to TRUE
//-- then, in the draw() functon we will record 
boolean recordToPDF = false;

//-- this is our table of data
Table table;

//---------------------------------------------------------------------------
//-- these are all variables for doing accurate mapping
float minLon = 9999;
float maxLon = -9999;
float minLat = 9999;
float maxLat = -9999;

float lonRange;
float latRange;

float lonAdjust;
float latAdjust;
//---------------------------------------------------------------------------


//
void setup() {
  //-- right now width and height have to be the same, otherwise it won't map properly
  //-- set to something like (2400,2400) for a large image
  size(800,800);
  
 
  loadData(sketchPath() + "/" +  "data_input.csv");
  
  numYears = endYear - startYear;
  
  homeX = map(homeLon, (minLon - lonAdjust), (maxLon + lonAdjust), margin, width - margin);
  homeY = map(homeLat, (minLat - latAdjust), (maxLat + latAdjust), height - margin, margin) * 1.3333 - 100;
  
  println(homeX);
  println(homeY);
  
}

void draw() {
  //-- draw background elements
  background(0);
  
  
  //-- respond to flag for recording
  if( recordToPDF )
    beginRecord(PDF, "data_output.pdf");
  
  
  // use various strokes and weights to respond to size here
  fill(0,0,255);
  noStroke();
  //stroke(127,127,127);
  strokeWeight(0);
  
  //-- draw data
  drawAllData();
  
  rectMode(CENTER);
  ellipseMode(CENTER);
  
  //-- done recording to PDF, set flag to false and flash white to indicate that we have recorded
  if( recordToPDF ) {
    endRecord();
    recordToPDF = false;
    background(255);    // flash to white
  } 
}

//-- loads the data into the table variable, does some testing for the output
void loadData(String filename) {
  //-- this loads the actual table into memory
  table = loadTable(filename, "header");

  println(table.getRowCount() + " total rows in table"); 

  
  //-- go though table and deterime min and max lat/lon for mapping to the screen
  for (TableRow row : table.rows()) {
    
    float x = row.getFloat("Longitude");
    float y = row.getFloat("Latitude");
    
     if( x < minLon )
      minLon = x;
    else if( x > maxLon )
      maxLon = x;
    
    if( y < minLat )
      minLat = y;
    else if( y > maxLat )
      maxLat = y;
  }  
  
  //-- determine various ranges and make simple math adjustments for plotting on the screen
  println("min X =" + minLon );
  println("min Y =" + minLat );
  println("max X =" + maxLon );
  println("max Y =" + maxLat );
  
  lonRange = maxLon-minLon;
  latRange = maxLat-minLat;
  
  
  println("lon range = " + lonRange );
  println("lat range = " + latRange );
  
  //-- we do this so that we don't have skewed maps
  latAdjust = 0;
  lonAdjust = 0;
  if( lonRange > latRange )
    latAdjust = (lonRange-latRange)/2;
  else if( latRange > lonRange )
    lonAdjust = (latRange-lonRange)/2;
  
    
  println("lon adjust = " + lonAdjust );
  println("lat adjust = " + latAdjust );
  
  // total lat should be = total lon
  println("total lat = " + ((maxLat + latAdjust) - (minLat - latAdjust))  );
  println("total lon = " + ((maxLon + lonAdjust) - (minLon - lonAdjust))  );
}


//-- draw each data
void drawAllData() {
  for (TableRow row : table.rows()) {
    
    float x = row.getFloat("Longitude");
    float y = row.getFloat("Latitude");
    
    //-- OUR CUSTOM ROTUINES GO HERE
    float s = getSizeData(row);       // size
    String m = getModelData(row);
    
    //-- draw data point here
    // MODIFY THIS FUNCTION
    drawDatum(x,y, s,m);
  }
  
  //-- draw home
  //fill(255,0,0);
  //ellipse(homeX, homeY, 10,10);
}

//-- read .size column, if there is none, then we use a default size variable (global)
float getSizeData(TableRow row) {
   float s = defaultSize;

   //-- Process size column
    try {
      //-- there IS size column
      s = row.getFloat("t_cap");
      
    } catch (Exception e) {
      //-- there is NO size column in this data set
      //-- no size coulumn, set s to plottable value
      
    }
    
    return s;
}

//-- read .size column, if there is none, then we use a default size variable (global)
String getModelData(TableRow row) {
   String s = "";

   //-- Process size column
    try {
      //-- there IS size column
      s = row.getString("t_model");
      
    } catch (Exception e) {
      //-- there is NO size column in this data set
      //-- no size coulumn, set s to plottable value
      
    }
    
    return s;
}



void drawDatum(float x, float y, float dataSize, String model) {
  //println(dataSize);
  float drawX = map(x, (minLon - lonAdjust), (maxLon + lonAdjust), margin, width - margin);
  float drawY = map(y, (minLat - latAdjust), (maxLat + latAdjust), height - margin, margin) * 1.3333 - 100;
  
  //stroke(192);
  //strokeWeight(2);
  //fill(100,250,50);
  
  //-- This is the stroke weight
  //strokeWeight(0);
  
  //-- This is the color
  //stroke(128,128,128);
  
  // adjust our size 
   dataSize = dataSize / 1000;
  
  
  //-- change color based on model name
  // default
  fill(128);
  if (model.equals("V136-3.6")) {
    fill(255,0,0);
  }
  else if (model.equals("GE1.5-77")) {
    fill(255,255,0);
  }
  //-- draw reactangle
  //rect(drawX, drawY, dataSize, dataSize); // Constraint of where circles appear and size of circles 
  
  // draw circle
  ellipse(drawX, drawY, dataSize, dataSize); // Constraint of where circles appear and size of circles 
}

void keyPressed() {
  if( key == ' ' )
    recordToPDF = true;
}
