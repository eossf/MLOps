/** breaKout **/

Ball ball;
Bar bar;
Wall wall;
Score score;

private int wallCols, wallRows; // x,y
private float diameter, radius;
private float wbar, hbar, miwbar;
private int currentScore, live;
private int wboard, hboard, wscoreboard;

void setup() {
  live = 3;
  currentScore = 0;
  wallCols = 12;
  wallRows = 10;
  diameter = 20;
  radius = diameter/2;
  wbar = 100;
  hbar = 10;
  miwbar = wbar/2;
  wboard = 800;
  hboard = 600;
  wscoreboard = 100;
  size(800, 600);
  ball = new Ball(diameter, 600, 600, live);
  bar = new Bar(wbar,hbar);
  wall = new Wall(wallCols,wallRows);  // x,y
  score = new Score(wall, ball);
}

void draw(){
  background(127,0,255);
  ball.display();
  bar.display();
  if (ball.mv){
    is_bounced_with_bar();
  }
  wall.display(ball);
  score.display();
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
