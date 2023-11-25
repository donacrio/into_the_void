public class ShapeFactory {
  public Shape createInitialShape() {
    if(random(1) < ARC_PROPORTION) {
      return this.createArc();
    }
    return this.createInitialSegment();
  }
  
  public Shape createRandomShape() {
    if(random(1) < ARC_PROPORTION) {
      return this.createArc();
    }
    return this.createSegment();
  }
  
  private Shape createInitialSegment() {
    Coordinate start = new Coordinate(0, 0);
    return this.createSegment(start);
  }
  
  private Shape createSegment() {
    float radius = random(1) * DIMENSION/2;
    float angle = randomGaussian() * PI/3;
    float x = radius * cos(angle);
    float y = radius * sin(angle);
    Coordinate start = new Coordinate(x, y);
    return this.createSegment(start);
  }
  
  private Shape createSegment(Coordinate start) {
    Coordinate end = new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2));
    Coordinate direction = new Vector2D(start, end).normalize().toCoordinate();
    return new Segment(start, new Vector2D(start).translate(direction));
  }
  
  
  
  private Shape createArc() {
    float radius = random(1) * DIMENSION/2;
    float angle = randomGaussian() * PI/3;
    return new Arc(radius, angle, PI/DIMENSION);
  }
}
