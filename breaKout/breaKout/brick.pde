public class Brick {
  private float x = 0, y = 0;
  private float wbrick = 50;
  private float hbrick = 10;
  private float R,G,B;
  private boolean visible = true;

  public Brick(){
  }
 
  public Brick(float px, float py, float pwbrick, float phbrick){
    x = px;
    y = py;
    wbrick = pwbrick; // x
    hbrick = phbrick; // y
    setColor(random(255),random(255),random(255));
  }
  
  public void putBrick(){
    if (visible){
      fill(R,G,B);
      rect(x,y,wbrick,hbrick);
    }
  }

  public float weight(){
    return wbrick;
  }

  public float height(){
    return hbrick;
  }

  public float getX(){
    return x;
  }
  
  public float getY(){
    return y;
  }
  
  public void setColor(float pR, float pG, float pB){
    R=pR;
    G=pG;
    B=pB;
  }
  
  public void hide(){
    visible = false;
  }

}
