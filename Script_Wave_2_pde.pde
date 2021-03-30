import java.awt.event.*;

boolean songselectedM = false;
boolean folderselected = false;
boolean importerselected = false;

String path;
String fPath = "";
String tPath;
String[] imported;

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
AudioPlayer backP;
FFT fft;
int[] wave = new int[0];
int backPV = -80;
boolean madeSoundwave = false;

int bar;
float bx;
float bl;
float by;
float bh;

int scale = 2;
int divide = 100;
int scaleLimit = 2000;

float xOffset = 0.0;
boolean locked = false;
boolean overBar = false;

PImage bookMark;
point[] bookmarkers = new point[0];
int treshHold = 30;
int bW = 20;
int selectedM = 0;
boolean markerExist = false;
boolean mOpened = false;

boolean automatic = false;

boolean cancel = false;

PrintWriter script; 

boolean help = false;

boolean reset = false;

boolean idOn = false;

boolean save = false;

boolean intro = true;

boolean tresh = false;

boolean naming = false;
String name = "script";
boolean enter = false;

color uniFill = color(180);
color barC = color(50);

int sizeX = 1280;
int sizeY = 720;

int currentP;
void setup()
{
  size(1920, 1080);
  surface.setResizable(true);
  
  minim = new Minim(this);
  
  bar = width / 2;

  bookMark = loadImage("Bookmark.png");
}

void draw()
{
  background(95, 2, 31);
  fill(uniFill);
  
  if(!intro && !naming && automatic)
  {
    fft.forward( backP.mix );
    wave = (int[]) append(wave, int(fft.getBand(2)/6));
    
    if(int(fft.getBand(2)/6) > treshHold)
    {
      markerExist = true;
      bookmarkers = (point[]) append(bookmarkers, new point(bookmarkers.length, backP.position()));
    }
  }
  
  if(sizeX != width || sizeY != height)
  {
    bar = width / 2;
    sizeX = width;
    sizeY = height;
  }

  if(reset)
  {
     fill(uniFill);
     textAlign(CORNER);
     text("Are you sure you want to reset?\n            Yes [y]    No [n]", (width / 2) - 150, height /2);
  }
  
  else if(naming)
  {
     textAlign(CORNER);
     text("Name of your Project:", 20, 25);
     rect(20, 40, width - 30, 50);
     fill(255);
     text(name, 30, 70);
     text("Press [ENTER] if you've chosen your project name", 20, 120);
  }

  else if (help)
  {
    fill(uniFill);
    textAlign(CORNER);
    text(name + "\n\nSPACE = Play/Pause \nD, F, J, K = Place Marker \nDelete = Delete Marker \nLMB = Open Marker \nR = New project \nS = Save project \nL = Load project \nE = Export script \nArrow UP = Zoom IN \nArrow DOWN = Zoom OUT \nI = Show ID above Markers \n\nWhen in Marker\nRMB = Close Marker \nArrow LEFT = Previous Marker \nArrow RIGHT = Next Marker \n\nAutomatic Marker Placer \nA = Play/Pause Marker Placer \nT = At which amplitude of the Freq band it should place a marker \nBACKSPACE = Delete all automatic placed markers", 10, 20);
    text("F1 = Exit Help", 10, height - 20);
  } 
  
  else if(tresh)
  {
     text("Type your desired amplitude to put markers at:", 20, 25);
     rect(20, 40, width - 30, 50);
     fill(255);
     text(treshHold, 30, 70);
     text("I recommend giving numbers between 20 and 40. You can still go wild with the number though.", 20, 120);
  }
  
  else if(intro)
  {
     textAlign(CENTER);
     textSize(20);
     text("New Project [n]          Open project [o]", width / 2, height / 2);
  }
  
  else
  {
    if (!locked)
    {
      bx = bar - (player.position() / divide * scale);
    }
    bl = (player.length() / divide * scale);
    by = height - bh - 50;
    bh = 80;

    noStroke();
    fill(barC);
    for (int i = 0; i < bookmarkers.length; ++i)
      {
        bookmarkers[i].marker();
      }
    rect(bx, by, bl, bh);

    stroke(uniFill);
    fill(uniFill);
    textAlign(CENTER);
    textSize(20);

    text(player.position() / 100, width / 2, by - 50);
    line(width / 2, by - 20, width/2, by + 80);
    
    fill(255);
    for(int i = 0; i < wave.length; ++i)
    {
       rect( bx + i, by + bh - 2, 1, -wave[i]);
    }

    if (mouseX > bx && mouseX < bx + bl && mouseY > by && mouseY < by + bh)
    {
      overBar = true;
    } else
    {
      overBar = false;
    }
    
    if(markerExist)
    {
      for (int i = 0; i < bookmarkers.length; ++i)
      {
        bookmarkers[i].draw();
        bookmarkers[i].check();
      }
    }

    if (mOpened)
    {
      bookmarkers[selectedM].selectedM();
    }
    fill(uniFill);
    textAlign(CORNER);
    text("F1 = Help", 10, height - 20);
  }
}

void keyPressed()
{
  if (keyCode == 32)
  {
    if (!mOpened && !naming && !intro)
    {
      if (player.isPlaying())
      {
        player.pause();
      } else if (player.position() / divide == player.length() / divide)
      {
        player.rewind();
        player.play();
      } else
      {
        player.play();
      }
    }
  }

  
  if (keyCode == 75 && !mOpened && !naming && player.position() / 100 != currentP || keyCode == 74 && !mOpened && !naming && player.position() / 100 != currentP  || keyCode == 68 && !mOpened && !naming && player.position() / 100 != currentP  || keyCode == 70 && !mOpened && !naming && player.position() / 100 != currentP )
  {
    if (markerExist)
    {
      int tempPosition = 0;
      
      //IF NEW MARKER IS IN FRONT OF ALL
      if (player.position() < bookmarkers[0].get())
      {
        bookmarkers = (point[]) append(bookmarkers, new point(bookmarkers.length, player.position()));

        for (int i = bookmarkers.length - 1; i > 0; --i)
        {
          bookmarkers[i] = bookmarkers[i - 1];
          bookmarkers[i].set();
        }

        bookmarkers[0] = new point(0, player.position());
      } 
      
      
      //IF NEW MARKER IS BEHIND ALL
      else if (bookmarkers[bookmarkers.length - 1].get() < player.position())
      {
        bookmarkers = (point[]) append(bookmarkers, new point(bookmarkers.length, player.position()));
      } 
      
      
      
      //IF NEW MAKER IS IN BETWEEN ALL
      else
      {        
        for (int i = 0; i < bookmarkers.length - 1; ++i)
        {
          if (bookmarkers[i].get() < player.position() && player.position() < bookmarkers[i+1].get())
          {
            tempPosition = i + 1;
            i = bookmarkers.length;
          }          
        }

        bookmarkers = (point[]) append(bookmarkers, new point(bookmarkers.length, player.position()));

        for (int i = bookmarkers.length - 1; i > tempPosition; --i)
        {
          bookmarkers[i] = bookmarkers[i - 1];
          bookmarkers[i].set();
        }

        bookmarkers[tempPosition] = new point(tempPosition, player.position());
      }
    } 
    
    //First marker
    else
    {
      bookmarkers = (point[]) append(bookmarkers, new point(bookmarkers.length, player.position()));
    }
    
    currentP = player.position() / 100;
  }

  if (keyCode == 37 && mOpened && selectedM > 0)
  {
    --selectedM;
  }

  if (keyCode == 39)
  {
    if (!mOpened)
    {
      player.skip(100);
    } else
    {
      if (selectedM < bookmarkers.length - 1)
      {
        ++selectedM;
      }
    }
  }

  if (keyCode == 38)
  {
    if (scale != 1 || scale == 1 && divide == 100)
    {
      scale++;
    } else if (scale == 1)
    {
      divide -= 100;
    }
  }

  if (keyCode == 40)
  {
    if (scale != 1)
    {
      scale--;
    } else if (scale == 1 && divide != scaleLimit)
    {
      divide += 100;
    }
  }

  if (keyCode == 112)
  {
    if (help)
    {
      help = false;
    } else
    {
      help = true;
    }
  }
}

void mousePressed()
{
  if (overBar)
  {
    locked = true;
    xOffset = mouseX-bx;
  } else
  {
    locked = false;
  }
}

void mouseDragged() {
  if (locked) {
    bx = mouseX-xOffset;
  }
}

void mouseReleased()
{
  if(!intro && !naming)
  {
    int newPos = int(-((bx - bar)/scale) *divide);
  
    locked = false;
    player.rewind();
    player.skip(newPos);
  }
}

void keyReleased()
{
  if (markerExist && mOpened)
  {
    if (key == BACKSPACE && bookmarkers[selectedM].note.length() > 0)
    {
      bookmarkers[selectedM].note = bookmarkers[selectedM].note.substring (0, bookmarkers[selectedM].note.length()-1);
    } else if (keyCode != 16 && key != BACKSPACE && keyCode != 127  && keyCode != 112 && keyCode > 46 || keyCode == 32)
    {
      bookmarkers[selectedM].note += key;
    }
  }
  
  if (!mOpened && !naming && key == BACKSPACE)
  {
    wave = new int[0];
    
    backP.rewind();
    
    int autoCount = 0;
    
    for(int i = 0; i < bookmarkers.length - 1; ++i)
    {
      if(bookmarkers[i].auto == true)
      {
        ++autoCount; 
      }
    }
    
    while(autoCount != 0)
    {
      if(bookmarkers.length == 1 && bookmarkers[0].auto == true)
      {
         bookmarkers = new point[0];
         mOpened = false;
         markerExist = false;
         --autoCount;
      }
      else
      {
        int tempSelected = 0;
        
        for(int i = 0; i < bookmarkers.length - 1; ++i)
        {
           if(bookmarkers[i].auto == true)
            {
              tempSelected = i;
            }
        }
        for(int i = tempSelected; i < bookmarkers.length - 1; ++i)
        {
          bookmarkers[i] = bookmarkers[i + 1];
          bookmarkers[i].id--;
        }
        
       bookmarkers = (point[]) shorten(bookmarkers);
       --autoCount;
      }
    }
  }
  
  if(tresh)
  {
    if (key == BACKSPACE && str(treshHold).length() > 0)
    {
      treshHold = int(str(treshHold).substring (0, str(treshHold).length()-1));
    } else if (keyCode > 96 && keyCode < 106)
    {
      treshHold = int(str(treshHold) + key);
    }
  }
  
  if(keyCode == 84 && !intro && !naming && !mOpened)
  {
     tresh = !tresh;
  }
  
  if(keyCode == 65 && !intro && !naming && !mOpened)
  {
    if(!automatic)
    {
      automatic = true;
      fft = new FFT( backP.bufferSize(), backP.sampleRate() );
      backP.play();
      backP.setGain(backPV);
    }
    else
    {
      automatic = false;
      backP.pause();
    }
  }
  
  if (naming)
  {
    if (key == BACKSPACE && name.length() > 0)
    {
      name = name.substring( 0, name.length()-1 );
    } else if (keyCode != 16 && key != BACKSPACE && keyCode != 127  && keyCode != 112 && keyCode > 46 || keyCode == 32)
    {
      name += key;
    }
  }
  
  if (keyCode == 83 && markerExist && !mOpened && !naming)
  {
    enter = false;
    
    save = true;
    folderselected = false;
    selectFolder("Select a folder to process:", "folderSelected");
    interruptF();
    
    if(!cancel)
    {
      script.println(name);
      script.println(path);
      script.println("");
      
      for (int i = 0; i < bookmarkers.length; ++i)
      {
        bookmarkers[i].write();
      }
      script.flush();
      script.close();
    }
    else
    {
      cancel = false;
    }
  }
  
  if(keyCode == 127 && mOpened)
  {
    if(bookmarkers.length == 1)
    {
       bookmarkers = new point[0];
       mOpened = false;
       markerExist = false;
    }
    else
    {
      for(int i = selectedM; i < bookmarkers.length - 1; ++i)
      {
        bookmarkers[i] = bookmarkers[i + 1];
        bookmarkers[i].id--;
      }
     
     selectedM = 0;
     
     bookmarkers = (point[]) shorten(bookmarkers);
    }
  }
  
  if(keyCode ==  78 && intro && !naming)
       {
          songselectedM = false;
          selectInput("Choose a song file", "inputFile");
          interrupt();
          if(!cancel)
          {
            player = minim.loadFile(path);
            backP = minim.loadFile(path);
            
            markerExist = false;
            point[] temp = new point[0];
            bookmarkers = temp;
            reset = false;
            intro = false;
            naming = true;
          }
          else
          {
            cancel = false;
          }
       }
       
       if(keyCode == 79 && intro && !naming)
       {
           importerselected = false;
           selectInput("Select a script", "inputImport");
           interruptI();
           
           if(!cancel)
           {           
             imported = loadStrings(tPath);
             
             markerExist = false;
             
             bookmarkers = new point[0];
             
             name = imported[0];
             player = minim.loadFile(imported[1]);
             backP = minim.loadFile(imported[1]);
             
             for(int i = 3; i < imported.length; ++i)
             {
                String[] tempA = split(imported[i], " ; ");
                
                int tempId = i - 3;
                bookmarkers = (point[]) append(bookmarkers, new point(tempId, player.position()));
                bookmarkers[tempId].position = int(tempA[0]);
                bookmarkers[tempId].note = tempA[2];
             }
             
             markerExist = true;
             intro = false;
           }
           else
           {
             cancel = true; 
           }
           
       }
  
  //PROBLEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEM
  
  if(keyCode == 76 && !mOpened && !naming)
  {
     player.pause();
     importerselected = false;
     selectInput("Select a script", "inputImport");
     interruptI();
     
     if(!cancel)
     {
       println(tPath);
       
       imported = loadStrings(tPath);
       
       markerExist = false;
       
       bookmarkers = new point[0];
       
       name = imported[0];
       player = minim.loadFile(imported[1]);
       backP = minim.loadFile(imported[1]);
       
       for(int i = 3; i < imported.length; ++i)
       {
          String[] tempA = split(imported[i], " ; ");
          
          int tempId = i - 3;
          bookmarkers = (point[]) append(bookmarkers, new point(tempId, player.position()));
          bookmarkers[tempId].position = int(tempA[0]);
          bookmarkers[tempId].note = tempA[2];
       }
       
       markerExist = true;
     }
     else
     {
       cancel = false; 
     }
  }
  
  if(keyCode == 89 && !mOpened && reset)
   {
      player.pause();
      backP.rewind();
      wave = new int[0];
      songselectedM = false;
      selectInput("Choose a song file", "inputFile");
      interrupt();
      player = minim.loadFile(path);
      backP = minim.loadFile(path);
      
      markerExist = false;
      point[] temp = new point[0];
      bookmarkers = temp;
      reset = false;
      naming = true;
   }
   
   if(keyCode == 10 && naming)
   {
      enter = true;
      naming = false;
   }  
   
   if(keyCode == 78 && !mOpened && reset && !intro)
   {
      reset = false;
   }
   
   if(keyCode == 82 && !mOpened && !intro && !naming)
   {
      reset = true;
      player.pause();
   }   
   
   if(keyCode == 73 && !mOpened)
   {
      idOn = !idOn;
   }
   
   if(keyCode == 69 && !mOpened && !naming)
   {    
    save = false;
    folderselected = false;
    selectFolder("Select a folder to process:", "folderSelected");
    interruptF();
    
    if(!cancel)
    {
      for (int i = 0; i < bookmarkers.length; ++i)
      {
        bookmarkers[i].Export();
      }
      script.flush();
      script.close();
    }
    else
    {
      cancel = false; 
    }
  }
}

void interrupt() { 
      while (!songselectedM) delay(200); 
}

void interruptF() { 
      while (!folderselected) delay(200); 
}

void interruptI() { 
      while (!importerselected) delay(200); 
}

void interruptN() { 
      while (!enter) delay(200); 
}

void inputFile(File selection) {         
  if(selection == null)
  {
    cancel = true;
    songselectedM = true;
  }
  else
  {
    path = selection.getAbsolutePath();
    songselectedM = true;
  }
}

void folderSelected(File selection) {
  if (selection == null) {
    cancel = true;
    folderselected = true;
  } else {
    fPath = selection.getAbsolutePath() + "\\";  
    
    if(save)
    {
      script = createWriter(fPath + name + ".dante");
    }
    else
    {
       script = createWriter(fPath + name + ".txt");
    }
    folderselected = true;
  }
}

void inputImport(File selection) {         
  if (selection == null) {
    cancel = true;
    importerselected = true;
  } else {
    tPath = selection.getAbsolutePath();
    importerselected = true;
  }
}