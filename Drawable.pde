public interface Drawable {
  public void draw(Geometry geom);
}

public class Visible implements Drawable {
  public void draw(Geometry geom){
    beginShape();
    for(Coordinate coord : geom.getCoordinates()) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
  };
}

public class Invisible implements Drawable {
  public void draw(Geometry geom){};
}
