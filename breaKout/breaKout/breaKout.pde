/** breaKout **/

Ball ball;
Bar bar;
Wall wall;

private int wallCols, wallRows; // x,y
private float diameter, radius;
private float wbar, hbar, miwbar;

void setup() {
  wallCols = 5;
  wallRows = 20;
  diameter = 20;
  radius = diameter/2;
  wbar = 100;
  hbar = 10;
  miwbar = wbar/2;
  size(600, 600);
  ball = new Ball(diameter);
  bar = new Bar(wbar,hbar);
  wall = new Wall(wallCols,wallRows);  // x,y
}

void draw(){
  background(127,0,255);
  ball.display();
  bar.display();
  if (ball.mv){
    is_bounced_with_bar();
    is_collided_with_wall();
  }
  wall.display();
}

void mousePressed(){
  ball.setY(ball.getY()-10);
  ball.setVY(-10);
  ball.mv = true;
}

void is_bounced_with_bar(){
  float Y = ball.getY();
  float X = ball.getX();
  if ( Y + radius > bar.getY() && ( X > bar.getX() - miwbar && X < bar.getX() + miwbar) ){
    if (X < bar.getX()){
      if (ball.getVX() < 0) {
        ball.bounceY();
      } else {
        ball.bounceY(-1);     
      }
    } else {
      if (ball.getVX() >= 0) {
        ball.bounceY(-1);
      } else {
        ball.bounceY();     
      }
    }  
  }
}

void is_collided_with_wall(){
  float Y = ball.getY();
  float X = ball.getX();

  // parse bricks in front
  Brick b = new Brick();
  float x, y, h, w; // brick coordinate, height, weight

  for (int j = wallRows - 1; j >= 0; j--){ // y
    for (int i = 0; i < wallCols; i++){ // x
      b = wall.getBrick(i,j);
      if (b.visible) {
        y = b.getY();
        x = b.getX();
        h = b.height();
        w = b.weight();
        if ( Y - radius < y + h  && X >= x && X <= x + w ) {
          ball.bounceY(-1);
          b.hide();
        }
      }
    }
  }
}
