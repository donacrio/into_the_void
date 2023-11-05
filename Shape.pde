public class Shape {
  public Geometry geom;
  public Growable growable;
  public Drawable drawable;
  
  public Shape(Growable growable, Drawable drawable) {
    this.geom = GF.createEmpty(2);
    this.growable = growable;
    this.drawable = drawable;
  }
  
  public void grow(int t) {
    this.geom = this.growable.grow(t);
  }
  
  public void stop() {
    
  }
  
  public boolean intersects(Shape other) {
    return this.geom.intersects(other.geom);
  }
  
  public void draw() {
    this.drawable.draw(this.geom);
  }
  
  public boolean growing(int t, List<Shape> others, HashMap<Shape, HashSet<Shape>> intersections) {
    return this.growable.growing(t) && !this.hasNewIntersection(others, intersections);
  }
  
  private boolean hasNewIntersection(List<Shape> others, HashMap<Shape, HashSet<Shape>> intersections) {
    for(Shape other : others) {
      HashSet<Shape> shapeIntersections = intersections.getOrDefault(this, new HashSet<Shape>());
      // Shape doesn't already intersect other
      if(this!=other && !shapeIntersections.contains(other) && this.intersects(other)) {
        shapeIntersections.add(other);
        intersections.get(other).add(this);
        return true;
      }
    }
    return false;
  }
}

public class ShapeFactory {
  public Shape createShape(Coordinate start) {
    //Coordinate start = new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2));
    if(random(1)>0.5) {
      return this.createRandomSegment(start);
    }
    return this.createRandomArc(start);
  }
  
  public Shape createRandomSegment(Coordinate start) {
    float angle = random(2*PI);
    Vector2D direction = new Vector2D(new Coordinate(cos(angle), sin(angle)));
    Growable segment = new Segment(start, direction);
    Drawable visible = new Visible();
    return new Shape(segment, visible);
  }
  
  public Shape createRandomArc(Coordinate start) {
    Coordinate center = new Coordinate(0, 0);
    Vector2D radial = new Vector2D(start);
    boolean clockwise = random(1) > .5;
    Growable arc = new Arc(center, radial, clockwise);
    Drawable visible = new Visible();
    return new Shape(arc, visible);
  }
}
