
// Imports to support the filter function.
import java.util.List;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import java.util.Comparator;
import java.util.Collections;
import java.util.function.Function;

import controlP5.*;


// filter() function modified from https://stackoverflow.com/questions/9146224/arraylist-filter
public<T> List<T> filter(List<T> list, Predicate<T> criteria) {
  return list.stream().filter(criteria).collect(Collectors.<T>toList());
}


public<T,U extends Comparable<? super U>> List<T> sort(List<T> list, Function<T,U> func) {
  return list.stream().sorted(Comparator.comparing(func)).collect(Collectors.<T>toList());
}


// TODO: test this one
public<T,U> List<U> map(List<T> list, Function<T,U> func) {
  return list.stream().map(func).collect(Collectors.<U>toList());
}


// Min and max constants for filtering
final float minq = 0.028321056;
final float maxq = 1.297734649;
final float minQ = 4.09;
final float maxQ = 64.27;
final float minP = 3.3;
final float maxP = 185.64;
final float minMOID = 0.000518;
final float maxMOID = 0.515916;

// Current min and max values for filtering
float currMinq = minq;
float currMaxq = maxq;
float currMinQ = minQ;
float currMaxQ = maxQ;
float currMinP = minP;
float currMaxP = maxP;
float currMinMOID = minMOID;
float currMaxMOID = maxMOID;

// Current search term in search box
String searchValue = "";

// Range objects for filtering
Range qRange;
Range QRange;
Range PRange;
Range MOIDRange;

class Comet {
  public String object;
  public int epoch;
  public float TP;
  public float e;
  public float i;
  public float w;
  public float node;
  public float q;
  public float Q;
  public float P;
  public float MOID;
  public float A1;
  public float A2;
  public float A3;
  public float DT;
  public float ref;
  public String name;
  public String searchName;
  
  public String toString() {
    return name;
  }
}

ArrayList<Comet> comets = new ArrayList<Comet>();

PanZoomPage page = new PanZoomPage();
ControlP5 cp5;

void setup() {
  size(1600,900);
  
  // Init ControlP5 objects for filtering UI
  cp5 = new ControlP5(this);
  
  qRange = cp5.addRange("Perihelion")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(1325,110)
             .setSize(220,30)
             .setHandleSize(20)
             .setRange(minq,maxq)
             .setRangeValues(minq,maxq)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(255,100))
             .setColorBackground(color(255,25))  
             ;
             
   QRange = cp5.addRange("Aphelion")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(1325,160)
             .setSize(220,30)
             .setHandleSize(20)
             .setRange(minQ,maxQ)
             .setRangeValues(minQ,maxQ)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(255,100))
             .setColorBackground(color(255,25))  
             ;
             
   PRange = cp5.addRange("Period")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(1325,210)
             .setSize(220,30)
             .setHandleSize(20)
             .setRange(minP,maxP)
             .setRangeValues(minP,maxP)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(255,100))
             .setColorBackground(color(255,25))  
             ;
             
   MOIDRange = cp5.addRange("MOID")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(1325,260)
             .setSize(220,30)
             .setHandleSize(20)
             .setRange(minMOID,maxMOID)
             .setRangeValues(minMOID,maxMOID)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(255,100))
             .setColorBackground(color(255,25))  
             ;
             
   PFont font = createFont("arial",20);

   cp5.addTextfield("search")
     .setPosition(1325,50)
     .setSize(248,35)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,255,255))
     .setLabel("")
     .setText("Search")
     .setColorBackground(color(255,80))
     ;
  
  // Dataset: https://data.nasa.gov/Space-Science/Near-Earth-Comets-Orbital-Elements/b67r-rgxc
  Table table = loadTable("data/Near-Earth_Comets_-_Orbital_Elements.csv", "header");
  
  // Make an ArrayList of Comet objects for easier data manipulation later on
  for (final TableRow row : table.rows()) {
    Comet c = new Comet();
    
    c.object = row.getString("Object");
    c.epoch = row.getInt("Epoch (TDB)");
    c.TP = row.getFloat("TP (TDB)");
    c.e = row.getFloat("e");
    c.i = row.getFloat("i (deg)");
    c.w = row.getFloat("w (deg)");
    c.node = row.getFloat("Node (deg)");
    c.q = row.getFloat("q (AU)");
    c.Q = row.getFloat("Q (AU)");
    c.P = row.getFloat("P (yr)");
    c.MOID = row.getFloat("MOID (AU)");
    c.A1 = row.getFloat("A1 (AU/d^2)");
    c.A2 = row.getFloat("A2 (AU/d^2)");
    c.A3 = row.getFloat("A3 (AU/d^2)");
    c.DT = row.getFloat("DT (d)");
    c.ref = row.getFloat("ref");
    c.name = row.getString("Object_name");
    c.searchName = row.getString("Search name");
    
    comets.add(c);
  }
  
  // Just for testing
  // Print how close the closest comets get
  //List<Comet> filtered = filter(comets, c -> (c.MOID < 0.1));
  //List<Comet> sorted = sort(filtered, c -> c.MOID);
  //for (final Comet c : sorted) {
  //  println(c.MOID);
  //}
}

// Updates current search, min, and max values for filtering
// Adapted from https://sojamo.de/libraries/controlP5/reference
void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("Perihelion")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    currMinq = theControlEvent.getController().getArrayValue(0);
    currMaxq = theControlEvent.getController().getArrayValue(1);
    System.out.format("q range [%f %f] update, done.\n", currMinq, currMaxq);
  }
  else if(theControlEvent.isFrom("Aphelion")) {
    currMinQ = theControlEvent.getController().getArrayValue(0);
    currMaxQ = theControlEvent.getController().getArrayValue(1);
    System.out.format("Q range [%f %f] update, done.\n", currMinQ, currMaxQ);
  }
  else if(theControlEvent.isFrom("Period")) {
    currMinP = theControlEvent.getController().getArrayValue(0);
    currMaxP = theControlEvent.getController().getArrayValue(1);
    System.out.format("P range [%f %f] update, done.\n", currMinP, currMaxP);
  }
  else if(theControlEvent.isFrom("MOID")) {
    currMinMOID = theControlEvent.getController().getArrayValue(0);
    currMaxMOID = theControlEvent.getController().getArrayValue(1);
    System.out.format("MOID range [%f %f] update, done.\n", currMinMOID, currMaxMOID);
  }
  else if (theControlEvent.isAssignableFrom(Textfield.class)) {
    searchValue = theControlEvent.getStringValue();
    System.out.format("Saerch value updated to '%s'\n", searchValue);
  }
}

void drawOrbit(final float a, final float e, final float w, color c) {
  PShape s = createShape();
  
  s.beginShape();
  s.stroke(c);
  s.noFill();
  
  for(int i=0; i<=360; i+=1) {
    final float theta = radians(i);
    final float r = a * (1-e*e) / (1 + e * cos(theta));
    final float x = r * cos(theta);
    final float y = r * sin(theta);
    
    final float xx = x*cos(w) - y*sin(w);
    final float yy = x*sin(w) + y*cos(w);
    
    s.vertex(page.pageXtoScreenX(xx), page.pageYtoScreenY(yy));
  }
  s.endShape();  
  shape(s);
}

void draw() {
  background(10);
  
  drawOrbit(1.0, 0.0, 0.0, color(0, 0, 255));
  
  List<Comet> filteredComets = filter(comets, c -> (c.q <= currMaxq && c.q >= currMinq
                                                 && c.Q <= currMaxQ && c.Q >= currMinQ
                                                 && c.P <= currMaxP && c.P >= currMinP
                                                 && c.MOID <= currMaxMOID && c.MOID >= currMinMOID));
                                                 
  // Filter by value in search bar, do not filter any if search bar is empty
  List<Comet> searchedComets = filter(filteredComets, c -> (searchValue.equals("") || searchValue.toLowerCase().equals(c.searchName.toLowerCase())));
  
  for (final Comet comet : searchedComets) {
    final float a = comet.q + comet.Q;
    drawOrbit(a, comet.e, comet.w, color(255, 255, 255));
  }
  
  // Draw filter and search panel
  fill(150, 150, 150);
  rect(1300, 0, 300, 900);
  
  textSize(24);
  fill(255, 255, 255);
  text("Search and Filter", 1366, 28);
}

void keyPressed() {
  if (key == ' ') {
    println("current scale: ", page.scale, " current translation: ", page.translateX, "x", page.translateY);
  }
}

void mousePressed() {
  page.mousePressed();
}


void mouseDragged() {
  page.mouseDragged();
}


void mouseWheel(MouseEvent e) {
  page.mouseWheel(e);
}
