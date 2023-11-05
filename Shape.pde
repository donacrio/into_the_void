
public abstract class Shape {
  public Point start;
  protected LineString geom;
  
  public Shape(Coordinate start) {
    this.start = GF.createPoint(start);
    this.geom = GF.createLineString();
  }
  
  public void grow(int t) {
    this.geom = this.updateGeom(t);
  };
    
  public abstract LineString updateGeom(int y);
  
  public void draw(){
    beginShape();
    for(Coordinate coord : this.geom.getCoordinates()) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  };
  
  public boolean intersects(Shape other) {
    return this.geom.intersects(other.geom);
  }
}

public class Segment extends Shape {
  private Coordinate start;
  private Vector2D direction;
  
  public Segment(Coordinate start, Vector2D direction) {
    super(start);
    this.start = start;
    this.direction = direction;
  }
  
  public LineString updateGeom(int t) {
    Coordinate end = direction.multiply(t).toCoordinate();
    return GF.createLineString(new Coordinate[] {this.start, end});
  }
}


public class Arc extends Shape {
  private Coordinate center;
  private Vector2D radial;
  private boolean clockwise;
  
  public Arc(Coordinate center, Vector2D radial, boolean clockwise) {
    super(radial.toCoordinate());
    this.center = center;
    this.radial = radial;
    this.clockwise = clockwise;
  }
  
  public LineString updateGeom(int t) {
    GeometricShapeFactory gsf = new GeometricShapeFactory(GF);
    gsf.setCentre(this.center);
    gsf.setSize(radial.length());
    double angle = 4*PI / DIMENSION * t;
    LineString arc = gsf.createArc(radial.angle(), angle);
    if(this.clockwise) {
      arc = arc.reverse();
    }
    return arc;
  }
}
