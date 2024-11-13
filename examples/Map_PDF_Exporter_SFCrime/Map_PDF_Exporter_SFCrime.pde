/*
  Map_PDF_ExporterSFCrome
 
  Based on Map_
  
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
    
    //-- OUR CUSTOM DATA-FETCHING ROUTINES GO HERE
    String crimeType = getCrimeTypeData(row);
     
    //-- draw data point here
    drawDatum(x,y, crimeType);
  }
}

//-- read .size column, if there is none, then we use a default size variable (global)
float getSizeData(TableRow row) {
   float s = defaultSize;

   //-- Process size column
    try {
      //-- there IS size column
      s = row.getFloat("Size");
      
    } catch (Exception e) {
      //-- there is NO size column in this data set
      //-- no size coulumn, set s to plottable value
      
    }
    
    return s;
}


String getCrimeTypeData(TableRow row) {
   String s = "";
   
   //-- Process size column
    try {
       // this is the name of the string
      s = row.getString("Types of crime");
    } catch (Exception e) {
      
    }
    
    return s;   
}



void drawDatum(float x, float y, String crimeType) {
  // adjust drawX and drawY for latlong
  float drawX = map(x, (minLon - lonAdjust), (maxLon + lonAdjust), margin, width - margin);
  float drawY = map(y, (minLat - latAdjust), (maxLat + latAdjust), height - margin, margin) * 1.3333 - 100;
  
   //-- This is the stroke weight
  strokeWeight(0);
  
  //-- This is the color
  stroke(128,128,128);
  
  //-- This is our fill color, based on the type of crime
  if( crimeType.equals("Violent Crime") ) {
    fill(255,50,50);
  }
  else if( crimeType.equals("Misdemeanors") ) {
    fill(50,255,50);
  }
  else if( crimeType.equals("Other") ) {
    fill(50,255,255);
  }
  else if( crimeType.equals("General Accidents (Not Crimes)") ) {
    fill(50,50,255);
  }
  else if( crimeType.equals("Felonies") ) {
    fill(255,255,50);
  }
  else {
    fill(128,128,128);
  }
  
   
  //-- draw reactangle
  //rect(drawX, drawY, dataSize, dataSize); // Constraint of where circles appear and size of circles 
  
  // draw circle with 5 pixels in diameter
  ellipse(drawX, drawY, 5, 5); // Constraint of where circles appear and size of circles 
}

void keyPressed() {
  if( key == ' ' )
    recordToPDF = true;
}
