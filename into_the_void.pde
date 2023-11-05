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
int REFRESH_RATE = 10;

// GLOBALS
GeometryFactory GF;
ShapeFactory SF;
List<Shape> shapes;
HashMap<Shape, HashSet<Shape>> intersections;
int nPoints = 0;

Geometry box; // TODO add to shapes

void setup() {
  size(720, 720);
  
  GF = new GeometryFactory();
  SF = new ShapeFactory();
  shapes = new ArrayList<Shape>();
  intersections = new HashMap<Shape, HashSet<Shape>>();
  
  initShapes();
  background(255);
}

int t=0;

void draw() {
  noFill();
  background(255);
  translate(DIMENSION/2, DIMENSION/2);

  growShapes(t, REFRESH_RATE);
  for(Shape shape : shapes) {    
    shape.draw();
  }
  t += REFRESH_RATE; 
}

void initShapes() {
  List<Shape> segments = new ArrayList<Shape>();
  List<Shape> arcs = new ArrayList<Shape>();
  for(int i=0; i<25; i++) {
    if(random(1)>0.5) {
        segments.add(SF.createRandomSegment(new Coordinate(0,0)));
      }
     else {
      arcs.add(SF.createRandomArc(new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2))));
     }
  }
   
  // Adding initial segments to avoid collision at (0,0)
  for(Shape segment: segments) {
    HashSet<Shape> others = intersections.getOrDefault(segment, new HashSet<Shape>());
    others.addAll(segments);
    intersections.put(segment, others);
  }
  
  shapes.addAll(segments);
  shapes.addAll(arcs);
  
  // sketch box
  Geometry geom = GF.createLineString(new Coordinate[] {
    new Coordinate(-DIMENSION/2, -DIMENSION/2),
    new Coordinate(-DIMENSION/2, DIMENSION/2),
    new Coordinate(DIMENSION/2, DIMENSION/2),
    new Coordinate(DIMENSION/2, -DIMENSION/2),
    new Coordinate(-DIMENSION/2, -DIMENSION/2),
  });
  Growable g = new Inert(geom);
  Drawable d = new Invisible();
  Shape box = new Shape(g, d); 
  box.grow(0);
  shapes.add(box);
  
  // Add shapes to their own intersection shapes to avoid
  // self collision detection
  for(Shape shape : shapes) {
    intersections.putIfAbsent(shape, new HashSet<Shape>());
  }
}

void growShapes(int t, int steps) {
  int i = 0;
  boolean keepGrowing = true;
  while(keepGrowing && i<steps) {
    keepGrowing = false;
    for(Shape shape : shapes) {    
      shape.grow(t+i);    
      if(shape.hasNewIntersection(shapes, intersections)) {
        shape.growable = new Inert(shape.geom);
      }
      if(shape.growable.growing()) {
        keepGrowing = true;
      }
    }
    i++;
  }
  println(keepGrowing);
}
