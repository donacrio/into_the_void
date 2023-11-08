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
int STEPS = 2;
int SHAPES_PER_STEP = 3;

// GLOBALS
GeometryFactory GEOMETRY_FACTORY;
GrowableFactory GROWABLE_FACTORY;
List<Shape> shapes;
HashMap<Shape, HashSet<Shape>> intersections;
int nPoints = 0;

Geometry box; // TODO add to shapes

void setup() {
  size(720, 720);
  
  GEOMETRY_FACTORY = new GeometryFactory();
  GROWABLE_FACTORY = new GrowableFactory();
  shapes = new ArrayList<Shape>();
  intersections = new HashMap<Shape, HashSet<Shape>>();
  
  initShapes(SHAPES_PER_STEP);
  
  // Grow initial shapes
  growShapes(shapes);
    
  // Grow childrens
  for(int i=0; i<STEPS; i++) {
    List<Shape> newShapes = createNewShapes(shapes, intersections, SHAPES_PER_STEP);
    shapes.addAll(newShapes);
    growShapes(shapes);
  }
}

void draw() {
  noFill();
  background(255);
  translate(DIMENSION/2, DIMENSION/2);

  for(Shape shape : shapes) {
        shape.draw();
  }
}

void initShapes(int n) {
  List<Shape> segments = new ArrayList<Shape>();
  List<Shape> arcs = new ArrayList<Shape>();
  for(int i=0; i<n; i++) {
    Drawable visible = new Visible();
    if(random(1) < 0.5) {
        Growable segment = GROWABLE_FACTORY.createSegment(new Coordinate(0,0));
        segments.add(new Shape(segment, visible));
      }
     else {
       Growable arc = GROWABLE_FACTORY.createArc(new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2)));
      arcs.add(new Shape(arc, visible));
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
  LineString geom = GEOMETRY_FACTORY.createLineString(new Coordinate[] {
    new Coordinate(-DIMENSION/2, -DIMENSION/2),
    new Coordinate(-DIMENSION/2, DIMENSION/2),
    new Coordinate(DIMENSION/2, DIMENSION/2),
    new Coordinate(DIMENSION/2, -DIMENSION/2),
    new Coordinate(-DIMENSION/2, -DIMENSION/2),
  });
  Drawable d = new Invisible();
  Shape box = new Shape(geom, null, d, false); 
  shapes.add(box);
  
  // Add shapes to their own intersection shapes to avoid
  // self collision detection
  for(Shape shape : shapes) {
    intersections.putIfAbsent(shape, new HashSet<Shape>());
  }
}

List<Shape> createNewShapes(List<Shape> existing, HashMap<Shape, HashSet<Shape>> intersections, int n) {
  List<Shape> newShapes = new  ArrayList<Shape>();
  for(int i=0; i<n; i++) {
    Shape parent = existing.get(int(random(existing.size())));
    if(parent.growable != null) {
      Growable g = parent.growable.createChild(parent.geom);
      Drawable d = new Visible();
      Shape shape = new Shape(g, d);
      intersections.put(shape, new HashSet<Shape>() {{ add(parent); }});
      newShapes.add(shape);
    }
  }
  return newShapes;
}

void growShapes(List<Shape> shapes) {
  println(String.format("Growing %d shapes", shapes.size()));
  int t = 0;
  boolean keepGrowing = true;
  while(keepGrowing) {
    keepGrowing = false;
    for(Shape shape : shapes) { 
      if(shape.isGrowing) {
        shape.grow(t);    
        if(!shape.canGrow(t, shapes, intersections)) {
          shape.stop();
        } else {
          keepGrowing = true;
        }
      }
    }
    t++;
  }
}
