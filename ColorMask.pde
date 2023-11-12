public class ColorMask {
  
  private int[][] colors;
  private double[][] noise;
  
  public ColorMask(int[][] colors) {
    this.colors = colors;
    int n_row = DIMENSION;
    int n_col = DIMENSION;
    this.noise = new double[n_row][n_col];
      
    float x_off = 0.0;
    for(int i=0; i<n_col; i++) {
      x_off += COLOR_OFFSET_INCREMENT;
      
      float y_off = 0.0;
      for(int j=0; j<n_row; j++) {
        y_off += COLOR_OFFSET_INCREMENT;
        
        this.noise[i][j] = map(noise(x_off, y_off), 0, 1.0, 0, this.colors.length); 
      }
    }
  }
  
  public color getColor(Coordinate coord) {
    int i = (int) map((float) coord.x, (float) -0.6 * DIMENSION, (float) 0.6 * DIMENSION, 0, (float) DIMENSION);
    int j = (int) map((float) coord.y, (float) -0.6 * DIMENSION, (float) 0.6 * DIMENSION, 0, (float) DIMENSION);
    double noiseValue = this.noise[i][j];
    int[] c = this.colors[(int) noiseValue];
    return color(c[0], c[1], c[2]);
  }
}
