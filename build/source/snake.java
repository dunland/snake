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
   ..Erkennung vertikale vs horizontale Verläufe
   ....vertikale Linien: Verbindungsbögen
   ..Benennung Maßeinheiten Wand
   ..Einfügen eines technischen Bildes
   ..Segmentierung des dxf-Exportes
   ..UI:
   ....Liste aller Punkte, draggable
   ....Einstellung Maßeinheiten
   ....export-Button
   ....globalVerboseLevel keyboard control
 */




boolean record;
int punktAbstand_x = 65, punktAbstand_y = 65;
int globalVerboseLevel = 0;

// Punktlisten:
ArrayList<GitterPunkt> gitterpunkte = new ArrayList<GitterPunkt>();
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

// Liniensegmente:
ArrayList<Liniensegment> liniensegmente = new ArrayList<Liniensegment>();

public void setup()
{
        // Grafikeinstellungen:
        

        ellipseMode(CENTER);

        // Gitterpunkte erstellen:
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
        // Gitter zeichnen:
        for (GitterPunkt gp : gitterpunkte)
        {
                gp.checkMouseOverlap();
                if (!record) gp.render();
        }

        // DXF Aufnahme starten:
        if (record)
        {
                beginRaw(DXF, "output.dxf");
        }

        // Formen zeichnen:
        // zeichne Linie durch alle aktiven Gitterpunkte:
        // if (liniensegmente.size() > 1)
        for (Liniensegment ls : liniensegmente)
                ls.render();


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
        if (key == 'R')
        {
                record = true;
        }
        if (key == 'W')
        {
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_OBEN";
        }
        if (key == 'A')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_LINKS";
        if (key == 'S')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_UNTEN";
        if (key == 'D')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_RECHTS";
        if (key == 'Q')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_OBENLINKS";
        if (key == 'E')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_OBENRECHTS";
        if (key == 'Y')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_UNTENLINKS";
        if (key == 'X')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_UNTENRECHTS";


}

// Mausklick:
public void mouseClicked()
{
        //Gitterpunkt an Stelle der Maus auswählen:
        for (int i = 0; i<gitterpunkte.size(); i++)
        {
                GitterPunkt gp = gitterpunkte.get(i);
                if ((mouseX > gp.x - gp.x_toleranz && mouseX < gp.x + gp.x_toleranz) && mouseY > gp.y - gp.y_toleranz && mouseY < gp.y + gp.y_toleranz)
                {
                        gp.aktiv = !gp.aktiv;
                        if (gp.aktiv)
                        {
                                aktive_gitterpunkte.add(gp);
                                // neues Liniensegment:
                                if (aktive_gitterpunkte.size() > 1)
                                {
                                        GitterPunkt gp_vorher = aktive_gitterpunkte.get(aktive_gitterpunkte.size() - 2);
                                        liniensegmente.add(new Liniensegment(gp.x, gp.y, gp_vorher.x, gp_vorher.y));
                                        // TODO: gp.linie = zuletzt erstelle Linie
                                }
                        }
                        else
                        {
                                aktive_gitterpunkte.remove(gp);
                                // entferne Liniensegment:
                                // TODO: alle aktiven gps müssen zugeordnete linie haben → entferne diese linie
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
class Liniensegment {

int x1, y1, x2, y2;
String typ = ""; // mögliche Typen: "HORIZONTALE", "VERTIKALE", "KURVE_UNTEN", "KURVE_OBEN", "KURVE_LINKS", "KURVE_RECHTS"

Liniensegment(int x1_, int y1_, int x2_, int y2_){
        x1 = x1_;
        y1 = y1_;
        x2 = x2_;
        y2 = y2_;

        if (aktive_gitterpunkte.size() > 1) typ_zuordnung();
        else println("Liniensegment konnte nicht erzeugt werden, da es zu wenig aktive Gitterpunkte gibt.");

}

// Zuordnung des Kurventyps:
public void typ_zuordnung()
{

        // gerade Linien:
        if (y1 == y2) typ = "HORIZONTALE";
        else if (x1 == x2) typ = "VERTIKALE";

        // Kurven:
        // if (liniensegmente.size() > 1)
        // {
        //         GitterPunkt gp_vorletzter = aktive_gitterpunkte.get(aktive_gitterpunkte.size() - 3);
        //         Liniensegment linie_vorher = liniensegmente.get(liniensegmente.size() - 2);
        //
        //         if (y1 == y2 && x1 != x2 && gp_vorletzter.y < y2 && linie_vorher.typ.equals("VERTIKALE")) typ = "KURVE_UNTEN";
        //         if (y1 == y2 && x1 != x2 && gp_vorletzter.y > y2 && linie_vorher.typ.equals("VERTIKALE")) typ = "KURVE_OBEN";
        //         if (y1 != y2 && gp_vorletzter.x > x1 && linie_vorher.typ.equals("HORIZONTALE")) typ = "KURVE_LINKS";
        //         if (y1 != y2 && gp_vorletzter.x < x1 && linie_vorher.typ.equals("HORIZONTALE")) typ = "KURVE_RECHTS";
        // }

        println("neue Linie des Typs " + typ + ":\n" + x1 + "|" + y1 + "\t" + x2 + "|" + y2);
}

public void render(){
        PVector start, ctrl1, ctrl2, end;
        int angle = 180;
        float radius = 180;
        float length = 4 * tan(radians(angle / 4)) / 3;

        noFill();
        stroke(255);
        switch (typ) {
        case "HORIZONTALE":
                line(x1,y1, x2, y2);
                // obere linie:
                line(x1, y1 - 10, x2, y2 - 10);
                // untere Linie:
                line(x1, y1 + 10, x2, y2 + 10);
                break;
        case "VERTIKALE":
                line(x1,y1, x2, y2);
                // linke linie:
                line(x1- 10, y1, x2 - 10, y2);
                // rechte Linie:
                line(x1+10, y1, x2+10, y2);
                break;
        case "KURVE_OBEN":
                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1, y1 + (radius * length));
                ctrl2 = new PVector(x2, y2 + (radius * length));
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);
                break;
        case "KURVE_UNTEN":
                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1, y1 - (radius * length));
                ctrl2 = new PVector(x2, y2 - (radius * length));
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);
                break;
        case "KURVE_LINKS":

                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                // mittlere Linie:
                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1 - (radius * length), y1);
                ctrl2 = new PVector(x2 - (radius * length), y2);
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // äußere linie:
                radius = (y1 < y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1-10);
                ctrl1 = new PVector(x1 - (radius * length), y1-10);
                ctrl2 = new PVector(x2 - (radius * length), y2+10);
                end = new PVector(x2, y2+10);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // innere linie:
                radius = (y1 > y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1+10);
                ctrl1 = new PVector(x1 - (radius * length), y1+10);
                ctrl2 = new PVector(x2 - (radius * length), y2-10);
                end = new PVector(x2, y2-10);

                // stroke(255,0,0);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // Kontrollpunkte:
                if (globalVerboseLevel > 0)
                {
                        noStroke();
                        fill(193, 96, 118);
                        ellipse(ctrl1.x, ctrl1.y, 20, 20);
                        ellipse(ctrl2.x, ctrl2.y, 20, 20);
                }
                break;
        case "KURVE_RECHTS":
                // mittlere Linie:
                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1 + (radius * length), y1);
                ctrl2 = new PVector(x2 + (radius * length), y2);
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // äußere Linie:
                radius = (y1 < y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1 - 10);
                ctrl1 = new PVector(x1 + (radius * length), y1 - 10);
                ctrl2 = new PVector(x2 + (radius * length), y2 + 10);
                end = new PVector(x2, y2 + 10);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // innere Linie:
                radius = (y1 > y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1 + 10);
                ctrl1 = new PVector(x1 + (radius * length), y1 + 10);
                ctrl2 = new PVector(x2 + (radius * length), y2 - 10);
                end = new PVector(x2, y2 - 10);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // Kontrollpunkte anzeigen:
                if (globalVerboseLevel > 0)
                {
                        noStroke();
                        fill(193, 96, 118);
                        ellipse(ctrl1.x, ctrl1.y, 20, 20);
                        ellipse(ctrl2.x, ctrl2.y, 20, 20);
                }
                break;

        case "KURVE_OBENLINKS":
                angle = 90;
                // mittlere Linie:
                radius = 65;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1 - (radius * length), y1 );
                ctrl2 = new PVector(x2, y2 - (radius * length));
                end = new PVector(x2, y2);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                break;

        case "KURVE_OBENRECHTS":
                angle = 90;
                // mittlere Linie:
                radius = 65;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1 + (radius * length), y1 );
                ctrl2 = new PVector(x2, y2 - (radius * length));
                end = new PVector(x2, y2);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);
                break;
        case "KURVE_UNTENLINKS":
                break;
        case "KURVE_UNTENRECHTS":
                break;
        default:
                break;
        }
}
}
  public void settings() {  size(800, 500, FX2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "snake" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
