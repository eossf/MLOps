void setup() {
  size(400, 400, P3D);  
  noLoop();
}

void draw() {
  background(255, 0, 0);
  translate(width/2, height/2);
  rotate(PI/3.0);
  rect(-26, -26, 52, 52);
}

void keyPressed(){
  redraw();
}
