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
}

public class Segment extends Shape {
  public Segment(Coordinate start, Coordinate end) {
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
  
  void draw(color c, float strokeWidth) {
    strokeWeight(strokeWidth);
    stroke(c);
    Coordinate start = this.geom.getStartPoint().getCoordinate();
    Coordinate end = this.geom.getEndPoint().getCoordinate();
    line((float) start.x, (float) start.y, (float) end.x, (float) end.y);
  }
}

public class Arc extends Shape {
  private GeometricShapeFactory gsf;
  private double angleIncr;
  private double angleExtent;
  // TODO: set angleExtent & clockwise/anto-clockwise
  
  public Arc(double radius, double startAngle, double angleIncr) {
    this.gsf = new GeometricShapeFactory(GF);
    this.gsf.setCentre(new Coordinate(0,0));
    this.gsf.setSize(2*radius);
    this.angleIncr = angleIncr;
    this.angleExtent = angleIncr;
    this.geom = gsf.createArc(startAngle, angleIncr);
    this.growStart = true;
    this.growEnd = true;
  }
  
  public void updateStart(List<Shape> shapes) {
    Vector2D start = new Vector2D(this.geom.getStartPoint().getCoordinate());
    Vector2D end = new Vector2D(this.geom.getEndPoint().getCoordinate());
    
    this.angleExtent += this.angleIncr;
    if(this.angleExtent >= 2*PI) {
        this.growStart = false;
        this.geom = gsf.createArc(start.angle(), 2*PI);
    } else {
      LineString newSegment = gsf.createArc(start.angle() - this.angleIncr, this.angleIncr);
      for(Shape shape : shapes) {
        if(this != shape && newSegment.intersects(shape.geom)) {
          this.growStart = false;
        }
      }
      // TODO: clip to intersection
      this.geom =  gsf.createArc(
        Angle.normalizePositive(start.angle()- this.angleIncr),
        Angle.normalizePositive(start.angleTo(end)) + this.angleIncr
      );
    }
  }
  
  public void updateEnd(List<Shape> shapes) {
    Vector2D start = new Vector2D(this.geom.getStartPoint().getCoordinate());
    Vector2D end = new Vector2D(this.geom.getEndPoint().getCoordinate());
    
    this.angleExtent += this.angleIncr;
    if(this.angleExtent >= 2*PI) {
        this.growEnd = false;
        this.geom = gsf.createArc(start.angle(), 2*PI);
    } else {
      LineString newSegment = gsf.createArc(end.angle(), this.angleIncr);
      for(Shape shape : shapes) {
        if(this.angleExtent >= 2*PI || (this != shape && newSegment.intersects(shape.geom))) {
          this.growEnd = false;
        }
      }
      
      // TODO: clip to intersection
      this.geom =  gsf.createArc(
        Angle.normalizePositive(start.angle()),
        Angle.normalizePositive(start.angleTo(end)) + this.angleIncr
      );
    }
  }
}
