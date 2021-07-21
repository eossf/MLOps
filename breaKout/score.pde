public class Score {

  private Wall w;
  private Ball b;
  
  public Score(Wall pwall, Ball pball) {
    w=pwall;
    b=pball;
  }

  public void display(){
    fill(255);
    stroke(255);
    fill(0);
    rect(600,1,200,600);
    fill(255);
    stroke(0);
    PFont font = createFont("Liberation Sans", 32);
    textFont(font);
    text("Score:" + w.getScore(), 610, 50);
    text("Live:" + b.getLive(), 610, 100);
  }

}
