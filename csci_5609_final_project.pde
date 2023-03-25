
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
  
  //s.rotate(w);
  
  shape(s);
}

void draw() {
  background(10);
  
  drawOrbit(1.0, 0.0, 0.0, color(0, 0, 255));
  
  for (final Comet comet : comets) {
    final float a = comet.q + comet.Q;
    drawOrbit(a, comet.e, comet.w, color(255, 255, 255));
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
