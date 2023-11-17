// IMPORTS JTS
import org.locationtech.jts.*;
import org.locationtech.jts.algorithm.*;
import org.locationtech.jts.algorithm.construct.*;
import org.locationtech.jts.algorithm.distance.*;
import org.locationtech.jts.algorithm.hull.*;
import org.locationtech.jts.algorithm.locate.*;
import org.locationtech.jts.algorithm.match.*;
import org.locationtech.jts.awt.*;
import org.locationtech.jts.densify.*;
import org.locationtech.jts.dissolve.*;
import org.locationtech.jts.edgegraph.*;
import org.locationtech.jts.geom.*;
import org.locationtech.jts.geom.impl.*;
import org.locationtech.jts.geom.prep.*;
import org.locationtech.jts.geom.util.*;
import org.locationtech.jts.geomgraph.*;
import org.locationtech.jts.geomgraph.index.*;
import org.locationtech.jts.index.*;
import org.locationtech.jts.index.bintree.*;
import org.locationtech.jts.index.chain.*;
import org.locationtech.jts.index.hprtree.*;
import org.locationtech.jts.index.intervalrtree.*;
import org.locationtech.jts.index.kdtree.*;
import org.locationtech.jts.index.quadtree.*;
import org.locationtech.jts.index.strtree.*;
import org.locationtech.jts.index.sweepline.*;
import org.locationtech.jts.io.*;
import org.locationtech.jts.io.gml2.*;
import org.locationtech.jts.io.kml.*;
import org.locationtech.jts.linearref.*;
import org.locationtech.jts.math.*;
import org.locationtech.jts.noding.*;
import org.locationtech.jts.noding.snap.*;
import org.locationtech.jts.noding.snapround.*;
import org.locationtech.jts.operation.*;
import org.locationtech.jts.operation.buffer.*;
import org.locationtech.jts.operation.buffer.validate.*;
import org.locationtech.jts.operation.distance.*;
import org.locationtech.jts.operation.distance3d.*;
import org.locationtech.jts.operation.linemerge.*;
import org.locationtech.jts.operation.overlay.*;
import org.locationtech.jts.operation.overlay.snap.*;
import org.locationtech.jts.operation.overlay.validate.*;
import org.locationtech.jts.operation.overlayng.*;
import org.locationtech.jts.operation.polygonize.*;
import org.locationtech.jts.operation.predicate.*;
import org.locationtech.jts.operation.relate.*;
import org.locationtech.jts.operation.union.*;
import org.locationtech.jts.operation.valid.*;
import org.locationtech.jts.planargraph.*;
import org.locationtech.jts.planargraph.algorithm.*;
import org.locationtech.jts.precision.*;
import org.locationtech.jts.shape.*;
import org.locationtech.jts.shape.fractal.*;
import org.locationtech.jts.shape.random.*;
import org.locationtech.jts.simplify.*;
import org.locationtech.jts.triangulate.*;
import org.locationtech.jts.triangulate.polygon.*;
import org.locationtech.jts.triangulate.quadedge.*;
import org.locationtech.jts.triangulate.tri.*;
import org.locationtech.jts.util.*;

import java.util.HashSet;
import java.util.List;

// CONSTANTS
int DIMENSION = 1080;
int SHAPES_PER_STEP = 15; // TODO: randomGaussian
int N_STEPS = 200;
double ARC_PROPORTION = 0.2; // TODO: randomGaussian

// RENDERING
int REFRESH_RATE = 1000;

// GLOBALS
GeometryFactory GF;
ShapeFactory SF;
ArrayList<ArrayList<Shape>> steps_shapes;
ArrayList<float[]> points; // TODO: use javafx pair

void setup() {
  // SETUP
  size(1080, 1080);
  
  GF = new GeometryFactory();
  SF = new ShapeFactory();
  
  steps_shapes = new ArrayList<ArrayList<Shape>>();
  
  steps_shapes.add(new ArrayList<Shape>() {{add(new Boundary());}});
  
  // GROW MODEL
  for(int step=0; step<=N_STEPS; step++) {
    println(String.format("Step %d/%d: creating shapes...", step, N_STEPS));
    ArrayList<Shape> shapes = new ArrayList<Shape>();
    if(step == 0) {
      for(int i=0; i<SHAPES_PER_STEP; i++) {
      shapes.add(SF.createInitialShape());
      }
    } else {
      for(int i=0; i<SHAPES_PER_STEP; i++) {
          shapes.add(SF.createRandomShape());
      }
    }
    steps_shapes.add(shapes);
    
    println(String.format("Step %d/%d: growing shapes...", step, N_STEPS));
    growShapes(shapes);
  }
  
  points = new ArrayList<float[]>();
  // Drawing backwards to get first shapes drawn on top (?)
  for(int i=steps_shapes.size()-1; i>=0; i--) {
    println(String.format("Creating shape points for step %d/%d...", steps_shapes.size()-i, steps_shapes.size())); 
    ArrayList<Shape> shapes = steps_shapes.get(i);
    for(Shape shape : shapes) {
      points.addAll(shape.create_points());
    }
    
  }  
}

int curr = 0;

void draw() {
  colorMode(HSB, 360, 100, 100);
  noFill();
  background(45, 7, 92);
  translate(DIMENSION/2, DIMENSION/2);
  while(curr < points.size()) {
    for(int i=0; i<REFRESH_RATE; i++) {
      float[] p = points.get(curr + i);
      point(p[0], p[1]);
    }
  }
  curr += REFRESH_RATE;
}

void growShapes(List<Shape> shapes) {
  println(shapes);
  boolean stillGrowing = true;
  while(stillGrowing) {
    stillGrowing = false;
    for(Shape shape : shapes) { //<>//
      println(shape);
      shape.grow(shapes);
      stillGrowing |= shape.growStart | shape.growEnd;
    }
  }
}
