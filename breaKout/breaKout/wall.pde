public class Wall{
  private int rows;  // y
  private int cols;  // x
  private Brick[][] aBricks;   // x,y
  private float wbrick, hbrick;
  
  public Wall(int pcols, int prows ) { // x,y
    rows = prows;
    cols = pcols;
    aBricks = new Brick[cols][rows]; // x,y
    Brick b = new Brick();
    wbrick = b.weight(); // x
    hbrick = b.height(); // y
    buildWall();
  }

  public void display(Ball ball){
    for (int j = 0; j < rows; j++){ // y
      for (int i = 0; i < cols; i++){ // x
        aBricks[i][j].putBrick(ball);
      }
    }
  }

  public void buildWall(){
    for (int j = 0; j < rows; j++){ // y
      for (int i = 0; i < cols; i++){ // x
        aBricks[i][j] = new Brick(i*wbrick+1,j*hbrick+1, wbrick,hbrick); // x,y
      }
    }
  }
  
  public Brick getBrick(int px, int py){
    return aBricks[px][py];
  }

}
