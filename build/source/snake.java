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

public class snake extends PApplet {

/*
Heizungsauslegungsgenerator v.0.1
dunland, März 2021

TODO:
..vertikale Linien vs horizontale
....Verbindungskurven
..Bezier-Halbkreise mit Radius r
....Radius muss immer 65° haben
..Benennung Maßeinheiten Wand
..Einfügen eines technischen Bildes
..UI:
....Liste aller Punkte, draggable
....Einstellung Maßeinheiten
....export-Button
*/




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

            // Punkte auf gleicher Höhe: Linie zeichnen
            if (gp.y == gp_vorher.y)
            {
                stroke(255);
                line(gp.x,gp.y, gp_vorher.x, gp_vorher.y);
                stroke(255,0,0);
                line(gp.x, gp.y - 10, gp_vorher.x, gp_vorher.y - 10);
                stroke(0,0,255);
                line(gp.x, gp.y + 10, gp_vorher.x, gp_vorher.y + 10);
            }

            // Punkte auf unterschiedlicher Höhe: Kurve zeichnen
            else
            {
                if (i >= 2 && aktive_gitterpunkte.size() > 2)
                {
                    GitterPunkt gp_vorletzter = aktive_gitterpunkte.get(i - 2);

                    noFill();
                    int angle = 180;
                    float radius = (gp.y - gp_vorher.y) / 2;
                    float length = 4 * tan(radians(angle / 4)) / 3;
                    if (gp_vorletzter.x < gp.x)
                    {
                        // rechtsbündig; direkt übereinander:
                        stroke(255);
                        bezier(gp.x, gp.y, gp.x + punktAbstand_x, gp.y, gp_vorher.x + punktAbstand_x, gp_vorher.y, gp_vorher.x, gp_vorher.y);
                        stroke(255,0,0);
                        bezier(gp.x, gp.y - 10, gp.x + punktAbstand_x, gp.y - 10, gp_vorher.x + punktAbstand_x, gp_vorher.y + 10, gp_vorher.x, gp_vorher.y + 10);
                        stroke(255);
                        bezier(gp.x, gp.y + 10, gp.x + punktAbstand_x, gp.y + 10, gp_vorher.x + punktAbstand_x, gp_vorher.y - 10, gp_vorher.x, gp_vorher.y - 10);
                        // PVector start = new PVector(gp.x, gp.y);
                        // PVector ctrl1 = new PVector(gp.x + radius * length, gp.y);
                        // PVector ctrl2 = new PVector(ctrl1.y, ctrl1.x);
                        // PVector end = new PVector(gp_vorher.x, gp_vorher.y);

                        // bezier(start.x, start.y,
                        //     ctrl1.x, ctrl1.y,
                        //     ctrl2.x, ctrl2.y,
                        //     end.x, end.y);

                    }
                    else
                    {
                        // linksbündig; direkt übereinander:
                        bezier(gp.x,gp.y, gp.x - punktAbstand_x, gp.y, gp_vorher.x - punktAbstand_x, gp_vorher.y, gp_vorher.x, gp_vorher.y);
                        // PVector start = new PVector(0, - radius);
                        // PVector ctrl1 = new PVector(radius * length, - radius);
                        // PVector ctrl2 = new PVector(- radius * length, - radius);
                        // PVector end  = new PVector(0, - radius);

                        // ctrl2.rotate(radians(angle));
                        // end.rotate(radians(angle));

                        // // translate(gp_vorher.x, gp_vorher.y + (radius));
                        // bezier(start.x, start.y,
                        //     ctrl1.x, ctrl1.y,
                        //     ctrl2.x, ctrl2.y,
                        //     end.x, end.y);
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
    String[] appletArgs = new String[] { "snake" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
