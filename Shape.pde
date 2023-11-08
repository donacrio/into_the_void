public class Shape {
  public LineString geom;
  public Growable growable;
  public Drawable drawable;
  public boolean isGrowing;
  
  public Shape(Growable growable, Drawable drawable) {
    this.geom = GEOMETRY_FACTORY.createLineString();
    this.growable = growable;
    this.drawable = drawable;
    this.isGrowing = true;
  }
  
  public Shape(LineString geom, Growable growable, Drawable drawable, boolean isGrowing) {
    this.geom = geom;
    this.growable = growable;
    this.drawable = drawable;
    this.isGrowing = isGrowing;
  }
  
  public void grow(int t) {
    this.geom = this.growable.grow(t);
  }
  
  public void stop() {
    this.isGrowing = false;
  }
  
  public boolean intersects(Shape other) {
    return this.geom.intersects(other.geom);
  }
  
  public void draw() {
    this.drawable.draw(this.geom);
  }
  
  public boolean canGrow(int t, List<Shape> others, HashMap<Shape, HashSet<Shape>> intersections) {
    return this.isGrowing && this.growable.canGrow(t) && !this.hasNewIntersection(others, intersections);
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
