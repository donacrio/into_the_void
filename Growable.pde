public interface Growable {
  public Geometry grow(int t);
  public boolean growing(int t);
}

public class Inert implements Growable {
  private Geometry geom;
  
  public Inert(Geometry geom) {
    this.geom = geom;
  }
  
  public Geometry grow(int t) {
    return this.geom;
  }
  
  public boolean growing(int t) {
    return false;
  }
}

public class Segment implements Growable {
  private final Coordinate start;
  private final Vector2D direction;
  
  public Segment(Coordinate start, Vector2D direction) {
    this.start = start;
    this.direction = direction;
  }
  
  public Geometry grow(int t) {
    Coordinate end = direction.multiply(t).toCoordinate();
    return GF.createLineString(new Coordinate[] {this.start, end});
  }
  
  public boolean growing(int t) {
    return true;
  }
}

public class Arc implements Growable {
  private GeometricShapeFactory gsf;
  private final Vector2D radial;
  private final boolean clockwise;
  
  public Arc(Coordinate center, Vector2D radial, boolean clockwise) {
    this.gsf = new GeometricShapeFactory(GF);
    this.gsf.setCentre(center);
    this.gsf.setSize(radial.length());
    this.radial = radial;
    this.clockwise = clockwise;
  }
  
  public Geometry grow(int t) {
    double angle = PI / DIMENSION * t;
    LineString arc = gsf.createArc(radial.angle(), angle);
    if(this.clockwise) {
      arc = arc.reverse();
    }
    return arc;
  }
  
  public boolean growing(int t) {
    return  t / DIMENSION < 2;
  }
}
