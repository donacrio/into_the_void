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
    Coordinate start = new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2));
    return this.createSegment(start);
  }
  
  private Shape createInitialSegment() {
    Coordinate start = new Coordinate(0, 0);
    return this.createSegment(start);
  }
  
  private Shape createSegment(Coordinate start) {
    Coordinate end = new Coordinate(random(-DIMENSION/2, DIMENSION/2), random(-DIMENSION/2, DIMENSION/2));
    Coordinate direction = new Vector2D(start, end).normalize().toCoordinate();
    return new Segment(start, new Vector2D(start).translate(direction));
  }
  
  private Shape createArc() {
    double radius = random(DIMENSION/2);
    double startAngle = random(2*PI);
    return new Arc(radius, startAngle, PI/DIMENSION);
  }
}
