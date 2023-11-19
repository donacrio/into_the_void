float MAX_THETA = 0.1;

//double COLOR_OFFSET_INCREMENT = 0.5;
class Brush {
  private ArrayList<ColorPoint> colorPoints;
  private LineString geom;
  private float brushWidth;
  private float maxTheta;
  private color strokeColor;


  Brush(LineString geom, float brushWidth, color strokeColor) {
    this.colorPoints = new ArrayList<ColorPoint>();
    this.geom = (LineString) Densifier.densify(geom, 0.5); // TODO: use constant or param here
    this.brushWidth = brushWidth;
    this.maxTheta = MAX_THETA; // TODO: constructor arg? based on constant
    this.strokeColor = strokeColor;
  }

  void createColorPoints() {    
    Coordinate[] coords = this.geom.getCoordinates();
    float theta = random(0.003, 0.03); // TODO: constructor arg? based on random gen, maks, etc
    for(int i=1; i<coords.length-1; i++) {
      float x = (float) coords[i].x;
      float y = (float) coords[i].y;
      theta += random(-0.005, 0.005); // TODO: constructor arg? based on constant
      theta = constrain(theta, -this.maxTheta, this.maxTheta);
      // TODO: if dWidth small, switch color?
      this.colorPoints.add(new ColorPoint(x, y, color(strokeColor), 22));  // TODO: alpha base on variable or constant
      
      float directionAngle = (float) new Vector2D(coords[i-1], coords[i+1]).angle();
      for (int j=0; j<brushWidth; j++) {
        float alpha = 255*0.1*(1-j/brushWidth);
        float w = this.brushWidth*sin(j*theta*0.005); // TODO: angle constant
        this.colorPoints.add(new ColorPoint(x - w*sin(directionAngle), y + w*cos(directionAngle), color(strokeColor), alpha));
        this.colorPoints.add(new ColorPoint(x + w*sin(directionAngle), y - w*cos(directionAngle), color(strokeColor), alpha));
      }
    }
  }
}

class ColorPoint {
  public final float x;
  public final float y;
  public final color c;
  public final float a;
  
  public ColorPoint(float x, float y, color c, float a) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.a = a;
  }
}
