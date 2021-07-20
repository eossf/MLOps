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
  }
  wall.display(ball);
}

void mousePressed(){
  if (!ball.mv) {
    ball.setY(ball.getY()-10);
    ball.setVY(-10);
    ball.mv = true;
  }
}

void is_bounced_with_bar(){
  float Y = ball.getY();
  float X = ball.getX();
  if ( Y + radius > bar.getY() && ( X > bar.getX() - miwbar && X < bar.getX() + miwbar) ){
    ball.bounceY();
  }
}
