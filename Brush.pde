float MAX_THETA = 0.1;

int[][] HSB_COLORS = new int[][] {
  //{45, 7, 92},
  {190, 100, 36},
  {40, 95, 78},
  {60, 25, 5}
};

//double COLOR_OFFSET_INCREMENT = 0.5;
class Brush {
  private LineString geom;
  private float brushWidth;
  private float maxTheta;
  private color strokeColor;


  Brush(LineString geom, float brushWidth, color strokeColor) {
    this.geom = (LineString) Densifier.densify(geom, 0.5); // TODO: use constant or param here
    this.brushWidth = brushWidth;
    this.maxTheta = MAX_THETA; // TODO: constructor arg? based on constant
    this.strokeColor = strokeColor;
  }

void render() {
  Coordinate[] coords = this.geom.getCoordinates();
  float theta = random(0.003, 0.03); // TODO: constructor arg? based on random gen, maks, etc
  for(int i=1; i<coords.length-1; i++) {
    float x = (float) coords[i].x;
    float y = (float) coords[i].y;
    theta += random(-0.005, 0.005); // TODO: constructor arg? based on constant
    theta = constrain(theta, -this.maxTheta, this.maxTheta);
    // TODO: if dWidth small, switch color?
    stroke(strokeColor, 22); // TODO: alpha base on variable or constant
    point(x, y);
    
    float directionAngle = (float) new Vector2D(coords[i-1], coords[i+1]).angle();
    for (int j=0; j<brushWidth; j++) {
      float alpha = 255*0.1*(1-j/brushWidth);
      stroke(strokeColor, alpha);
      float w = this.brushWidth*sin(j*theta*0.005); // TODO: angle constant
      point(x - w*sin(directionAngle), y + w*cos(directionAngle)); 
      point(x + w*sin(directionAngle), y - w*cos(directionAngle));
      }
    }
  }
}
