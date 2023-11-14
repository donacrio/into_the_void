class Brush {
  private LineString geom;
  private float brushWidth;
  private float maxTheta;
  private color strokeColor;


  Brush(LineString geom, float brushWidth, color strokeColor) {
    this.geom = (LineString) Densifier.densify(geom, 0.5); // TODO: use constant or param here
    this.brushWidth = brushWidth;
    this.maxTheta = 0.3; // TODO: constructor arg? based on constant
    this.strokeColor = strokeColor;
  }

void render() {
  Coordinate[] coords = this.geom.getCoordinates();
  float theta = random(0.01, 0.1); // TODO: constructor arg? based on random gen, maks, etc
  for(int i=1; i<coords.length-1; i++) {
    float x = (float) coords[i].x;
    float y = (float) coords[i].y;
    theta += random(-0.042, 0.042); // TODO: constructor arg? based on constant
    theta = constrain(theta, -maxTheta, maxTheta);
    // TODO: if dWidth small, switch color?
    stroke(strokeColor, 22); // TODO: alpha base on variable or constant
    point(x, y);
    
    float scatterNum = 200; // TODO: use constant here
    //float directionAngle = (float) Angle.normalizePositive(new Vector2D(coords[i-1], coords[i+1]).angle());
    float directionAngle = (float) new Vector2D(coords[i-1], coords[i+1]).angle();
    for (int j=0; j<scatterNum; j++) {
      float alpha = 255*0.1*(1-j/scatterNum);
      stroke(strokeColor, alpha);
      float w = this.brushWidth*sin(j*theta*0.005); // TODO: angle constant
      point(x - w*cos(directionAngle), y + w*sin(directionAngle)); 
      point(x + w*cos(directionAngle), y - w*sin(directionAngle));
      }
    }
  }
}
