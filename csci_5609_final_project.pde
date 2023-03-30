
// Imports to support the filter function.
import java.util.List;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import java.util.Comparator;
import java.util.Collections;
import java.util.function.Function;


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
  
  
  public boolean mouseOverOrbit;
  
  public String toString() {
    return name;
  }
  
  

}

ArrayList<Comet> comets = new ArrayList<Comet>();

PanZoomPage page = new PanZoomPage();
 

void setup() {
  size(1600,900);
  
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
    c.mouseOverOrbit = false;
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

void drawOrbit(Comet comet) {
  PShape s = createShape();
  
  s.beginShape();
  
  if(comet.mouseOverOrbit){
     s.stroke(color(255, 0, 0));
  }
  else{
     s.stroke(color(255, 255, 255));
  }
 
  s.noFill();
  final float a = comet.q + comet.Q;
  
  boolean mouseOverOrbit = false;
  
  for(float i=0; i<=360; i+=.25) {
    final float theta = radians(i);
    final float r = a * (1-comet.e*comet.e) / (1 + comet.e * cos(theta));
    final float x = r * cos(theta);
    final float y = r * sin(theta);
    
    final float xx = x*cos(comet.w) - y*sin(comet.w);
    final float yy = x*sin(comet.w) + y*cos(comet.w);
    
    final float screen_x = page.pageXtoScreenX(xx);
    final float screen_y = page.pageYtoScreenY(yy);
    
    s.vertex(screen_x, screen_y);
    
    if((Math.abs(mouseX - screen_x) < 5) && (Math.abs(mouseY - screen_y) < 5)){
        mouseOverOrbit = true;
    }
    
  }
  if(mouseOverOrbit){
    comet.mouseOverOrbit = true;
  }
  else{
    comet.mouseOverOrbit = false;
  }
  s.endShape();
  
  //s.rotate(w);
  
  shape(s);
}
  


void draw() {
  background(10);
  
  //drawOrbit(1.0, 0.0, 0.0, color(0, 0, 255));
  noFill();
  stroke(0,0,255);
  circle(page.pageXtoScreenX(0), page.pageYtoScreenY(0), page.pageLengthToScreenLength(1));
  
  for (final Comet comet : comets) {
    drawOrbit(comet);
  }
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
