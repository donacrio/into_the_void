public interface Growable {
  public LineString grow(int t);
  public boolean canGrow(int t);
  public Growable createChild(LineString geom);
}

public class GrowableFactory {
  public Growable createGrowable(Coordinate start) {
    if(random(1) < 0.5) {
      return this.createSegment(start);
    }
    return this.createArc(start);
  }
  
  public Growable createSegment(Coordinate start) {
    float angle = random(2*PI);
    Vector2D direction = new Vector2D(new Coordinate(cos(angle), sin(angle)));
    return new Segment(start, direction);
  }
  
  public Growable createArc(Coordinate start) {
    Coordinate center = new Coordinate(0, 0);
    Vector2D radial = new Vector2D(start);
    boolean clockwise = random(1) > .5;
    return new Arc(center, radial, clockwise);
  }
}

public class Segment implements Growable {
  private final Coordinate start;
  private final Vector2D direction;
  
  public Segment(Coordinate start, Vector2D direction) {
    this.start = start;
    this.direction = direction;
  }
  
  public LineString grow(int t) {
    Coordinate end = direction.multiply(t).toCoordinate();
    return GEOMETRY_FACTORY.createLineString(new Coordinate[] {this.start, end});
  }
  
  public boolean canGrow(int t) {
    return true;
  }
  
  public Growable createChild(LineString geom) {
    LineString densified = (LineString) Densifier.densify(geom, 1.0);
    Point start = densified.getPointN(int(random(densified.getNumPoints())));
    return GROWABLE_FACTORY.createGrowable(start.getCoordinate());
  }
}

public class Arc implements Growable {
  private GeometricShapeFactory gsf;
  private final Vector2D radial;
  private final boolean clockwise;
  
  public Arc(Coordinate center, Vector2D radial, boolean clockwise) {
    this.gsf = new GeometricShapeFactory(GEOMETRY_FACTORY);
    this.gsf.setCentre(center);
    this.gsf.setSize(radial.length());
    this.radial = radial;
    this.clockwise = clockwise;
  }
  
  public LineString grow(int t) {
    double angle = PI / DIMENSION * t;
    LineString arc = gsf.createArc(radial.angle(), angle);
    if(this.clockwise) {
      arc = arc.reverse();
    }
    return arc;
  }
  
  public boolean canGrow(int t) {
    return  t / DIMENSION < 2;
  }
  
  public Growable createChild(LineString geom) {
    LineString densified = (LineString) Densifier.densify(geom, 1.0);
    Point start = densified.getPointN(int(random(densified.getNumPoints())));
    return GROWABLE_FACTORY.createSegment(start.getCoordinate());
  }
}
