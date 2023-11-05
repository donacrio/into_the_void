// IMPORTS JTS //<>//
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

// CONSTANTS
int DIMENSION = 720;
int RESOLUTION = 10;

// GLOBALS
GeometryFactory GF;
ArrayList<Shape> shapes;
ArrayList<Shape> drawables;
ArrayList<Shape> growables;
int nPoints = 0;

Geometry box; // TODO add to shapes

void setup() {
  size(720, 720);
  
  GF = new GeometryFactory();
  shapes = new ArrayList<Shape>();
  drawables = new ArrayList<Shape>();
  growables = new ArrayList<Shape>();
  
  // Create sketch boudaries
  GeometricShapeFactory gsf = new GeometricShapeFactory(GF);
  gsf.setCentre(new Coordinate(0, 0));
  gsf.setSize(DIMENSION);
  box = gsf.createRectangle();
  
  for(int i=0; i<10; i++) {
    Coordinate start = new Coordinate(0, 0);
    float angle = random(2*PI);
    Vector2D direction = new Vector2D(new Coordinate(cos(angle), sin(angle)));
    Shape shape = new Segment(start, direction);
    shapes.add(shape);
    drawables.add(shape);
    growables.add(shape);
  }
  
  for(int i=0; i<10; i++) {
    Coordinate center = new Coordinate(0, 0);
    float angle = random(2*PI);
    Vector2D radial = (new Vector2D(new Coordinate(cos(angle), sin(angle)))).multiply(random(DIMENSION));
    boolean clockwise = random(1) > .5;
    Shape shape = new Arc(center, radial, clockwise);
    shapes.add(shape);
    drawables.add(shape);
    growables.add(shape);
  }
  
  background(255);
}

int t=0;

void draw() {
  noFill();
  background(255);
  translate(DIMENSION/2, DIMENSION/2);

  t+=1;
  ArrayList<Shape> toRemove = new ArrayList<Shape>();
  for(Shape growable : growables) {
    boolean wasIntersectingBefore = isIntersecting(growable, shapes);
    
    growable.grow(t);    
    
    boolean isIntersectingAfter = isIntersecting(growable, shapes);
    if(!wasIntersectingBefore && isIntersectingAfter) {
      toRemove.add(growable);
    }
    //} else if (growable.geom.intersects(box)) {
    //  toRemove.add(growable);
    //}
  }
  growables.removeAll(toRemove);

  for(Shape drawable : drawables) {
    drawable.draw();
  }
}

boolean isIntersecting(Shape shape, ArrayList<Shape> others) {
  for(Shape other : others) {
    if(shape != other && shape.intersects(other)) {
        Geometry intersection = shape.geom.intersection(other.geom);
        if(intersection.compareTo(GF.createPoint(new Coordinate(0,0))) != 0) {
          return true;
        }
      }
    }
  return false;
}
