public abstract class Shape {
  public LineString geom;
  public boolean growStart;
  public boolean growEnd;
  
  public void grow(List<Shape> shapes) {
    if(this.growStart) {
      updateStart(shapes);
    }
   if(this.growEnd) {
      updateEnd(shapes);
    }
  }
  
  public abstract void updateStart(List<Shape> shapes);
  public abstract void updateEnd(List<Shape> shapes);
  
  public abstract void draw();
}

public class Boundary extends Shape {
  public Boundary() {
    this.geom = GF.createLineString(new Coordinate[] {
      new Coordinate(-DIMENSION/2, -DIMENSION/2),
      new Coordinate(-DIMENSION/2, DIMENSION/2),
      new Coordinate(DIMENSION/2, DIMENSION/2),
      new Coordinate(DIMENSION/2, -DIMENSION/2),
      new Coordinate(-DIMENSION/2, -DIMENSION/2)
    });
    this.growStart = false;
    this.growEnd = false;
  }
  
  public void updateStart(List<Shape> shapes){};
  public void updateEnd(List<Shape> shapes){};
  public void draw() {}
}

public class Segment extends Shape {
  public Segment(Coordinate start, Coordinate end) {
    super();
    this.geom = GF.createLineString(new Coordinate[] {start, end});
    this.growStart = true;
    this.growEnd = true;
  }
  
  public void updateStart(List<Shape> shapes) {
    Vector2D start = new Vector2D(this.geom.getStartPoint().getCoordinate());
    Vector2D end = new Vector2D(this.geom.getEndPoint().getCoordinate());
    Vector2D direction = start.subtract(end).normalize();
    Vector2D newStart = start.add(direction);
    LineString newSegment = GF.createLineString(new Coordinate[]{ newStart.toCoordinate(), start.toCoordinate()});
    for(Shape shape : shapes) {
      if(this != shape && newSegment.intersects(shape.geom)) {
        this.growStart = false;
      }
    }
    // TODO: clip to intersection
    this.geom = GF.createLineString(new Coordinate[]{ newStart.toCoordinate(), end.toCoordinate()});
  }
  
  public void updateEnd(List<Shape> shapes) {
    Vector2D start = new Vector2D(this.geom.getStartPoint().getCoordinate());
    Vector2D end = new Vector2D(this.geom.getEndPoint().getCoordinate());
    Vector2D direction = end.subtract(start).normalize();
    Vector2D newEnd = end.add(direction);
    LineString newSegment = GF.createLineString(new Coordinate[]{ end.toCoordinate(), newEnd.toCoordinate()});
    for(Shape shape : shapes) {
      if(this != shape && newSegment.intersects(shape.geom)) {
        this.growEnd = false;
      }
    }
    // TODO: clip to intersection
    this.geom = GF.createLineString(new Coordinate[]{ start.toCoordinate(), newEnd.toCoordinate()});
  }
  
  public void draw(){
    beginShape();
    for(Coordinate coord : this.geom.getCoordinates()) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  };
}

public class Arc extends Shape {
  private GeometricShapeFactory gsf;
  // TODO: set angleExtent & clockwise/anto-clockwise
  
  public Arc(double radius, double startAngle) {
    super();
    this.gsf = new GeometricShapeFactory(GF);
    this.gsf.setCentre(new Coordinate(0,0));
    this.gsf.setSize(radius);
    this.geom = gsf.createArc(startAngle, 1 / DIMENSION);
    this.growStart = true;
    this.growEnd = true;
  }
  
  public void updateStart(List<Shape> shapes) {
    Vector2D start = new Vector2D(this.geom.getStartPoint().getCoordinate());
    Vector2D end = new Vector2D(this.geom.getEndPoint().getCoordinate());
    LineString newSegment = gsf.createArc(start.angle(), -1/DIMENSION);
    for(Shape shape : shapes) {
      if(this != shape && newSegment.intersects(shape.geom)) {
        this.growStart = false;
      }
    }
    // TODO: clip to intersection
    Vector2D newStart = start.rotate(-1/DIMENSION);
    double newExtent = end.angleTo(newStart);
    this.geom =  gsf.createArc(newStart.angle(), newExtent);
  }
  
  public void updateEnd(List<Shape> shapes) {
    Vector2D start = new Vector2D(this.geom.getStartPoint().getCoordinate());
    Vector2D end = new Vector2D(this.geom.getEndPoint().getCoordinate());
    LineString newSegment = gsf.createArc(end.angle(), 1/DIMENSION);
    for(Shape shape : shapes) {
      if(this != shape && newSegment.intersects(shape.geom)) {
        this.growStart = false;
      }
    }
    // TODO: clip to intersection
    Vector2D newEnd = end.rotate(1/DIMENSION);
    double newExtent = start.angleTo(newEnd);
    this.geom =  gsf.createArc(newEnd.angle(), newExtent);
  }
  
  public void draw(){
    beginShape();
    for(Coordinate coord : this.geom.getCoordinates()) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  };
}
