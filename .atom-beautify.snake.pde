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

import processing.dxf.*;
import uibooster.*;

boolean record;
int punktAbstand_x = 65, punktAbstand_y = 65;
int globalVerboseLevel = 0;

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
