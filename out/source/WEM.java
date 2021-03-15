import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.dxf.*; 
import uibooster.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class WEM extends PApplet {




boolean record;
int punktAbstand_x = 65, punktAbstand_y = 65;

// Punktlisten:
ArrayList<GitterPunkt> gitterpunkte = new ArrayList<GitterPunkt>();
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

public void setup()
{
    //Grafikeinstellungen:
    
    
    ellipseMode(CENTER);
    
    //Gitterpunkte erstellen:
    for (int x = 0; x < width; x += punktAbstand_x)
        {
        for (int y = 0; y < width; y += punktAbstand_y)
        {
            gitterpunkte.add(new GitterPunkt(x, y));
        }
    }
}

public void draw()
{
    background(0);
    //Gitter zeichnen:
    for (GitterPunkt gp : gitterpunkte)
        {
        gp.checkMouseOverlap();
        if (!record) gp.render();
    }
    
    //DXF Aufnahme starten:
    if (record)
        {
        beginRaw(DXF, "output.dxf");
    }
    
    //Formen zeichnen:
    //zeichne Linie durch alle aktiven Gitterpunkte:
    if (aktive_gitterpunkte.size() > 1)
        {
        
        for (int i = 1; i < aktive_gitterpunkte.size(); i++)
        {
            GitterPunkt gp = aktive_gitterpunkte.get(i);
            GitterPunkt gp_vorher = aktive_gitterpunkte.get(i - 1);
            // Punkte auf gleicher Höhe:
            if (gp.y == gp_vorher.y)
            {
                stroke(255);
                line(gp.x,gp.y, gp_vorher.x, gp_vorher.y);
            }
            // Punkte auf unterschiedlicher Höhe:
            else
            {
                // noFill();
                // int diff_x = gp.x - gp_vorher.x;
                // int diff_y = gp.y - gp_vorher.y;
                // println(diff_x);
                // // rechtsbündig; direkt übereinander:
                // if (diff_x > 0)
                // {
                //     bezier(gp.x, gp.y, gp.x + punktAbstand_x + diff_x, gp.y, gp_vorher.x + punktAbstand_x + diff_x, gp_vorher.y, gp_vorher.x, gp_vorher.y);
            // }
                // else
                // {
                //     // linksbündig; direkt übereinander:
                //     bezier(gp.x,gp.y, gp.x - punktAbstand_x - diff_x, gp.y, gp_vorher.x - punktAbstand_x - diff_x, gp_vorher.y, gp_vorher.x, gp_vorher.y);
            // }
                if (i >= 2 && aktive_gitterpunkte.size() > 2)
                {
                    GitterPunkt gp_vorletzter = aktive_gitterpunkte.get(i - 2);
                    if (gp_vorletzter.x < gp.x)
                    {
                        // rechtsbündig; direkt übereinander:
                        if (diff_x > 0)
                        {
                            bezier(gp.x, gp.y, gp.x + punktAbstand_x + diff_x, gp.y, gp_vorher.x + punktAbstand_x + diff_x, gp_vorher.y, gp_vorher.x, gp_vorher.y);
                        }
                    }
                    else
                    {
                        // linksbündig; direkt übereinander:
                        bezier(gp.x,gp.y, gp.x - punktAbstand_x - diff_x, gp.y, gp_vorher.x - punktAbstand_x - diff_x, gp_vorher.y, gp_vorher.x, gp_vorher.y);
                    }
                }
            }
        }
    }
    
    //DXF Aufnahme beenden:
    if (record)
        {
        endRaw();
        record = false;
        println("record finished.");
    }
}

// Tastaturbefehle:
public void keyPressed()
{
    //exportiere DXF mit Taste 'r':
    if (key == 'r')
        {
        record = true;
    }
}

// Mausklick:
public void mouseClicked()
{
    //Gitterpunkt an Stelle der Maus auswählen:
    for (GitterPunkt gp : gitterpunkte)
        {
        if ((mouseX > gp.x - gp.x_toleranz && mouseX < gp.x + gp.x_toleranz) && mouseY > gp.y - gp.y_toleranz && mouseY < gp.y + gp.y_toleranz)
        {
            gp.aktiv = !gp.aktiv;
            if (gp.aktiv)
            {
                aktive_gitterpunkte.add(gp);
            }
            else
            {
                aktive_gitterpunkte.remove(gp);
            }
        }
    }
}
class GitterPunkt
{
    int x, y;
    int x_toleranz = 10, y_toleranz = 10;
    boolean unter_mouse;
    boolean aktiv = false;
    
    GitterPunkt(int x_, int y_)
    {
        x = x_;
        y = y_;
    }
    
    public void render()
    {
        // weißen Gitterpunkt malen:
        stroke(255);
        point(x, y);
        
        // grauen Kreis malen, wenn Maus in der Nähe:
        if (unter_mouse)
        {
            noStroke();
            fill(185, 185, 185, 80);
            ellipse(x,y,20, 20);
        }
        
        // weißen Kreis malen, wenn aktiv:
        if (aktiv)
        {
            fill(255);
            ellipse(x,y,20,20);
        }
    }
    
    // schauen, ob die Maus in der Nähe ist:
    public void checkMouseOverlap()
    {
        if ((mouseX > x - x_toleranz && mouseX < x + x_toleranz) && mouseY > y - y_toleranz && mouseY < y + y_toleranz)
            {
            unter_mouse = true;
        }
        else
            {
            unter_mouse = false;
        }
    }
    
}
  public void settings() {  size(800, 500, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "WEM" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
