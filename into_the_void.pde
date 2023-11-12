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
int DIMENSION = 720;
int SHAPES_PER_STEP = 25;
int N_STEPS = 20;
double ARC_PROPORTION = 0.25;

// COLORS
int[] HSB_BACKGROUND_COLOR = new int[] {45, 7, 92};
int[][] HSB_COLORS = new int[][] {
  {190, 100, 36},
  {40, 95, 78},
  {60, 25, 5}
};
double COLOR_OFFSET_INCREMENT = 0.1;
int STROKE_WIDTH = 2;

// ANIMATION
int REFRESH_RATE = 50;

// GLOBALS
GeometryFactory GF;
ShapeFactory SF;
ColorMask CM;
List<Shape> shapes;
int step = 0;

void setup() {
  size(720, 720);
  
  GF = new GeometryFactory();
  SF = new ShapeFactory();
  CM = new ColorMask(HSB_COLORS);
  
  shapes = new ArrayList<Shape>();
  
  shapes.add(new Boundary());
  
  for(int i=0; i<SHAPES_PER_STEP; i++) {
    shapes.add(SF.createInitialShape());
  }
  
  colorMode(HSB, 360, 100, 100);
}

void draw() {
  noFill();
  background(HSB_BACKGROUND_COLOR[0], HSB_BACKGROUND_COLOR[1], HSB_BACKGROUND_COLOR[2]);
  translate(DIMENSION/2, DIMENSION/2);

  boolean stillGrowing = false;
  for(int i=0; i<REFRESH_RATE; i++) {
    for(Shape shape : shapes) {
      shape.grow(shapes);
      stillGrowing |= shape.growStart | shape.growEnd;
    }
  }
  for(int i = shapes.size() -1; i>0; i--) {
    Shape shape = shapes.get(i);
    shape.draw();
  }
  
  if(!stillGrowing) {
    step++;
    if(step <= N_STEPS) {
      // New random shapes
      for(int i=0; i<SHAPES_PER_STEP; i++) {
        shapes.add(SF.createRandomShape());
      }
    }
  }
}
