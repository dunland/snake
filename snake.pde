/*
   Heizungsauslegungsgenerator v.0.1
   dunland, März 2021

   TODO:
   ..Erkennung vertikale vs horizontale Verläufe
   ....Bögen: doppelte Linien
   ..Benennung Maßeinheiten Wand
   ..Einfügen eines technischen Bildes
   ..Segmentierung des dxf-Exportes
   ..UI:
   ....Liste aller Punkte, draggable
   ....Einstellung Maßeinheiten
   ....export-Button
   ..remove liniensegmente with dot removal
   ....dot removal without bugs
 */

import processing.dxf.*;
import uibooster.*;

PImage bild;

boolean record;
int punktAbstand_x = 65, punktAbstand_y = 65;
int globalVerboseLevel = 1;

// Punktlisten:
ArrayList<GitterPunkt> gitterpunkte = new ArrayList<GitterPunkt>();
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

// Liniensegmente:
ArrayList<Liniensegment> liniensegmente = new ArrayList<Liniensegment>();

void setup()
{
        // Grafikeinstellungen:
        size(800, 500, FX2D);

        ellipseMode(CENTER);

        bild = loadImage("beispielbild.jpeg");

        // Gitterpunkte erstellen:
        for (int x = 0; x < width; x += punktAbstand_x)
        {
                for (int y = 0; y < width; y += punktAbstand_y)
                {
                        gitterpunkte.add(new GitterPunkt(x, y));
                }
        }
}

void draw()
{
        background(0);

        image(bild, 0, 0);
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
void keyPressed()
{
        println(key);
        //exportiere DXF mit Taste 'r':
        if (key == 'R')
        {
                record = true;
        }
        if (key == 'W')
                liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_OBEN");
        if (key == 'A')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_LINKS";
        if (key == 'S')
                liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_UNTEN");
        if (key == 'D')
                liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_RECHTS";
        if (key == 'Q')
                liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_OBENLINKS");
        if (key == 'E')
                liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_OBENRECHTS");
        if (key == 'Y')
                liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_UNTENLINKS");
        if (key == 'X')
                liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_UNTENRECHTS");
        if (key == ' ')
        {
                if (liniensegmente.get(liniensegmente.size() - 1).typ == "HORIZONTALE")
                        liniensegmente.get(liniensegmente.size() - 1).typ = "VERTIKALE";
                else if (liniensegmente.get(liniensegmente.size() - 1).typ == "VERTIKALE")
                        liniensegmente.get(liniensegmente.size() - 1).typ = "HORIZONTALE";
                else
                        liniensegmente.get(liniensegmente.size() - 1).typ = "HORIZONTALE";
        }
        if (key == '+' || key == 'ȉ')
        {
                globalVerboseLevel++;
                println(globalVerboseLevel);
        }
        if (key == '-')
        {
                globalVerboseLevel--;
                println(globalVerboseLevel);
        }




}

// Mausklick:
void mouseClicked()
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
