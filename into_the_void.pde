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
int SHAPES_PER_STEP = 10; // TODO: randomGaussian
int N_STEPS = 25;
double ARC_PROPORTION = 0.2; // TODO: randomGaussian

int[][] HSB_COLORS = new int[][] {
  //{45, 7, 92},
  //{190, 100, 36},
  //{40, 95, 78},
  //{60, 25, 5}
  {0, 100, 0}
};


// RENDERING
int REFRESH_RATE = 10000;

// GLOBALS
GeometryFactory GF;
ShapeFactory SF;
ArrayList<ArrayList<Shape>> stepsShapes;
ArrayList<ArrayList<Brush>> stepsBrushes; // TODO: use javafx pair
ArrayList<ColorPoint> colorPoints;

void setup() {
  // SETUP
  size(1080, 1080);
  colorMode(HSB, 360, 100, 100);
  noFill();
  
  GF = new GeometryFactory();
  SF = new ShapeFactory();
  
  stepsShapes = new ArrayList<ArrayList<Shape>>();
  
  stepsShapes.add(new ArrayList<Shape>() {{add(new Boundary());}});
  
  // GROW MODEL
  for(int step=0; step<=N_STEPS; step++) {
    println(String.format("Creating shapes: %d/%d", step, N_STEPS));
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
    stepsShapes.add(shapes);
    
    ArrayList<Shape> allShapes = new ArrayList<Shape>();
    stepsShapes.forEach(allShapes::addAll);
    growShapes(allShapes);
  }
  
  stepsBrushes = new ArrayList<ArrayList<Brush>>();
  // Skipping boundary
  for(int i=1; i<stepsShapes.size(); i++) {
    println(String.format("Creating color points: %d/%d", i, stepsShapes.size())); 
    ArrayList<Shape> shapes = stepsShapes.get(i);
    ArrayList<Brush> brushes = new ArrayList<Brush>();
    for(Shape shape : shapes) {
      int[] c = HSB_COLORS[(int) random(HSB_COLORS.length-1)];
      Brush brush = new Brush(shape.geom, 100, color(c[0], c[1], c[2])); // TODO: use variable for width
      brush.createColorPoints();
      brushes.add(brush);
    }
    stepsBrushes.add(brushes);
  }
  
  colorPoints = new ArrayList<ColorPoint>();
  for(ArrayList<Brush> brushes : stepsBrushes) {
    int maxIndex = brushes.stream().map(b -> b.colorPoints).mapToInt(List::size).max().getAsInt();
    int i = 0;
    while(i < maxIndex) {
      for(Brush brush : brushes) {
        if(i < brush.colorPoints.size()) {
          colorPoints.add(brush.colorPoints.get(i));
        }
        i++;
      }
    }
  }
  
  background(45, 7, 92);
}

int curr = 0;

void draw() {
  
  translate(DIMENSION/2, DIMENSION/2);    
  for(int i=0; i<REFRESH_RATE; i++) {
    if(curr * REFRESH_RATE + i < colorPoints.size()) {
      ColorPoint colorPoint = colorPoints.get(curr * REFRESH_RATE + i);
      stroke(colorPoint.c, colorPoint.a);
      point(colorPoint.x, colorPoint.y);
    }
  }
  save(String.format("out/animated/%d.tiff", curr));
  curr++;
  println(curr, curr * REFRESH_RATE, colorPoints.size());
  if(curr * REFRESH_RATE >= colorPoints.size()) {
    save("out/animated/final.tiff");
    println("Saved to output!");
    noLoop();
  }
}

void growShapes(List<Shape> shapes) {
  boolean stillGrowing = true;
  while(stillGrowing) {
    stillGrowing = false;
    for(Shape shape : shapes) {
      shape.grow(shapes);
      stillGrowing |= shape.growStart | shape.growEnd;
    }
  }
}

void draw() {}
