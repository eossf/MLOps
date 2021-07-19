class Ball{
  private float x,y,vx,vy,diameter,radius;
  private boolean mv;
  public Ball(){
    init(20);
  }
  public Ball(float pdiameter){
    diameter = pdiameter;
    init(pdiameter);
  }
 
  public void init(float pdiameter){
    diameter = pdiameter;
    radius = diameter / 2;
    x = width / 2;
    y = height - diameter - 1;
    vy = -10;
    vx = random(-5,5);
    mv = false;
  }
 
  public void bounceY(int pvx){
    vy *= -1;
    vx *= -pvx;
  }
  
  public void bounceY(){
    vy *= -1;
  }
  
  public void display(){
    fill(#FFF80D);
    ellipse(x,y,diameter,diameter);
    if (mv) {
      x += vx;
      y += vy;
      if (x > width - radius || x < radius){
        vx *= -1;
      }
      if (y < radius){
        vy *= -1;
      }
      if (y > height + diameter){
        init(diameter);
      }
    } else {
      x = mouseX;
    }
  }

  public void setY(float py){
    y = py;
  }
  
  public void setVY(float pvy){
    vy = pvy;
  }
  
  public float getY(){
    return y;
  }
  
  public float getX(){
    return x;
  }
  
  public float getRadius(){
    return radius;
  }
  
  public float getVX(){
    return vx;
  }
}
