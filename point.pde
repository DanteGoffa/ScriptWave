class point
{
  public int id;
  public int position;
  public String note = "";
  boolean opened = false;
  public boolean auto = false;
  
  point(int i, int pos)
  {
    position = pos;

    id = i;

    markerExist = true;
    
    if(automatic)
    {
      auto = true; 
    }
  }

  void draw()
  {
    fill(uniFill);
    if(idOn)
    {
      text(id, bx + (position / divide * scale), by - bW);
    }
    
    stroke(255);
    line(bx + (position / divide * scale), by, bx + (position / divide * scale), by + bh);
    imageMode(CENTER);
    image(bookMark, bx + (position / divide * scale), by, bW / 2, bW);
    
    if(auto)
    {
      fill(uniFill);
      noStroke();
      ellipse(bx + (position / divide * scale), by - 20, 5, 5);
    }
  }

  void selectedM()
  {
    fill(255);
    rect(35, 20, width - 75, by - 100);
    fill(0);
    textAlign(CORNER);
    text(note, 45, 30, width - 85, 300);
    image(bookMark, bx + (position / divide * scale), by, bW, bW * 2);
  }

  void check()
  {    
    if (mousePressed && mouseButton == LEFT)
    {
      if (mouseX > (bx + (position / divide * scale)) - (bW / 2) && mouseX < (bx + (position / divide * scale)) + (bW / 2) && mouseY > by - (bW / 2) && mouseY < by + (bW / 2) && !mOpened)
      {
        selectedM = id;
        opened = true;
        mOpened = true;
        player.pause();
      }
    }

    if (mousePressed && mouseButton == RIGHT)
    {
      opened = false;
      mOpened = false;
    }
  }

  void marker()
  {
    if (player.position() / divide == position / divide)
    {
      stroke(255);
    }
  }

  int get()
  {
    return position;
  }
  void set()
  {
     ++id;
  }

  void write()
  {
    String minutes;
    String seconds;

    if (position / 60000 < 10)
    {
      minutes = "0" + position / 60000;
    } else
    {
      minutes = str(position / 60000);
    }

    if (position / 1000 < 10)
    {
      seconds = "0" + position / 1000;
    } else
    {
      seconds = str(position / 1000);
    }

    script.println(position + " ; " + minutes + ":" + seconds + " ; " + note);
  }
  
  void Export()
  {
     String minutes;
     String seconds;

    if (position / 60000 < 10)
    {
      minutes = "0" + position / 60000;
    } else
    {
      minutes = str(position / 60000);
    }

    if (position / 1000 < 10)
    {
      seconds = "0" + position / 1000;
    } else
    {
      seconds = str(position / 1000);
    }

    script.println(minutes + ":" + seconds + "   " + note);
  }
}