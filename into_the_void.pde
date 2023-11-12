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
int RESOLUTION = 10;
int REFRESH_RATE = 4;
int SHAPES_PER_STEP = 10;

// GLOBALS
GeometryFactory GF;
List<Shape> shapes;
int nPoints = 0;

void setup() {
  size(720, 720);
  
  GF = new GeometryFactory();
  shapes = new ArrayList<Shape>();
  
  shapes.add(new Boundary());
  
  // TODO: random shape
  for(int i=0; i<SHAPES_PER_STEP; i++) {
    Coordinate start = new Coordinate(0, 0);
    Coordinate end = new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2));
    Coordinate direction = new Vector2D(start, end).normalize().toCoordinate();
    shapes.add(new Segment(start, new Vector2D(start).translate(direction)));
  }
  
  for(int i=0; i<SHAPES_PER_STEP; i++) {
    double radius = random(DIMENSION/2);
    double startAngle = random(2*PI);
    shapes.add(new Arc(radius, startAngle, 2*PI/DIMENSION));
  }
}

void draw() {
  noFill();
  background(255);
  translate(DIMENSION/2, DIMENSION/2);

  boolean stillGrowing = false;
  for(int i=0; i<REFRESH_RATE; i++) {
    for(Shape shape : shapes) {
      shape.grow(shapes);
      stillGrowing |= shape.growStart | shape.growEnd;
    }
  }
  for(Shape shape : shapes) {
        shape.draw();
  }
  
  if(!stillGrowing) {
    // New random shapes
    for(int i=0; i<SHAPES_PER_STEP; i++) {
      Coordinate start = new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2));
      Coordinate end = new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2));
      Coordinate direction = new Vector2D(start, end).normalize().toCoordinate();
      shapes.add(new Segment(start, new Vector2D(start).translate(direction)));
    }
    for(int i=0; i<SHAPES_PER_STEP; i++) {
      double radius = random(DIMENSION/2);
      double startAngle = random(2*PI);
      shapes.add(new Arc(radius, startAngle, 2*PI/DIMENSION));
    }
  }
}
