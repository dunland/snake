/*
   Heizungsauslegungsgenerator v.0.1
   dunland, März 2021

   TODO:
   ..vertikale Linien vs horizontale
   ....Verbindungskurven
   ..Bezier-Halbkreise mit Radius r
   ....Radius muss immer 65cm haben
   ....doppelte Linien: Linienklasse erstellen, vertikaler Versatz der Linien, Vorzeichenwechsel bei Erstellung neuen Bogens
   ..Benennung Maßeinheiten Wand
   ..Einfügen eines technischen Bildes
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
int globalVerboseLevel = 1;

// Punktlisten:
ArrayList<GitterPunkt> gitterpunkte = new ArrayList<GitterPunkt>();
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

// Linien
ArrayList<Linie> linien = new ArrayList<Linie>();


void setup()
{
        // Grafikeinstellungen:
        size(800, 500);

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
        if (aktive_gitterpunkte.size() > 1)
        {

                for (int i = 1; i < aktive_gitterpunkte.size(); i++)
                {
                        linien.get(i-1).render();

                        // Punkte auf unterschiedlicher Höhe: Kurve zeichnen
                        // ein Punkt über dem anderen:
                        // else
                        // {
                        GitterPunkt gp = aktive_gitterpunkte.get(i);
                        GitterPunkt gp_vorher = aktive_gitterpunkte.get(i - 1);
                        if (i >= 2 && aktive_gitterpunkte.size() > 2)
                        {
                                GitterPunkt gp_vorletzter = aktive_gitterpunkte.get(i - 2);

                                noFill();
                                int angle = 180;
                                float radius = 65/2;
                                float length = 4 * tan(radians(angle / 4)) / 3;

                                // Kurve rechts:
                                if (gp_vorletzter.x < gp.x)
                                {
                                        PVector start = new PVector(gp.x, gp.y);
                                        PVector ctrl1 = new PVector(gp.x + (radius * length), gp.y);
                                        PVector ctrl2 = new PVector(gp_vorher.x + (radius * length), gp_vorher.y);
                                        PVector end = new PVector(gp_vorher.x, gp_vorher.y);

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

                                }
                                else
                                {
                                        // Kurve links:
                                        PVector start = new PVector(gp.x, gp.y);
                                        PVector ctrl1 = new PVector(gp.x - (radius * length), gp.y);
                                        PVector ctrl2 = new PVector(gp_vorher.x - (radius * length), gp_vorher.y);
                                        PVector end = new PVector(gp_vorher.x, gp_vorher.y);

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
                                }
                        }
                        // }
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
void keyPressed()
{
        //exportiere DXF mit Taste 'r':
        if (key == 'r')
        {
                record = true;
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

                                if (aktive_gitterpunkte.size() > 1)
                                {
                                        GitterPunkt gp_vorher = gitterpunkte.get(i-1);
                                        linien.add(new Linie(gp_vorher.x, gp_vorher.y, gp.x, gp.y));
                                }
                        }
                        else
                        {
                                aktive_gitterpunkte.remove(gp);
                        }
                }
        }
}
