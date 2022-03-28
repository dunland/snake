/*
   Heizungsauslegungsgenerator v.0.1.03
   dunland, Juli 2021

   TODO:
   - [x] Raster bewegen per drag&drop
   - [ ] Raster zerschneiden??
   - [ ] Interaktion:
       - [ ] Liniensegmente rückgängig machen
       - [ ] Liniensegmente an Gitterpunkte binden
       - [ ] Liniensegmente exportieren/speichern
   - [ ] Raster:
       - [ ] Erkennung vertikale vs horizontale Verläufe
       - [ ] Liniensegmente bei Entfernen eines Punkts löschen
       - [ ] Punkte entfernen ‒ ohne Fehler
       - [ ] Benennung Maßeinheiten Wand
       - [x] Einfügen eines technischen Bildes
           - [ ] neu setzen der Rasterpunkte bei Laden des Bildes
           - [ ] Fehler, wenn kein Bild geladen → Popup File Panel
   - [ ] Export
       - [ ] Segmentierung des dxf-Exportes
   - [ ] UI:
       - [ ] Liste aller Punkte, draggable
       - [ ] Buttons:
           - [ ] SVG Export
           - [ ] DXF Export
           - [ ] Bild laden
           - [ ] Rastermaß bestimmen
 */

/*
   Fragen:
   - was für ein Output für FreeCAD benötigt? Eine Linie? zwei? drei?
   - welcher Dateityp? SVG oder DXF?
 */

import processing.dxf.*;
import processing.svg.*;
import uibooster.*;
import drop.*;

UiBooster ui;
SDrop drop;

PImage bild;
String bild_datei;
String output_datei = "output.dxf";
String settings_datei = "settings.json";

JSONObject settings;

boolean record;
float   rastermass = 13; // in cm
float   punktAbstand_x = rastermass, punktAbstand_y = rastermass;
int     globalVerboseLevel = 0;

String MODE; // can be "RUNNING" or "SETUP"

// Punktlisten:
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

// Liniensegmente:
ArrayList<Liniensegment> liniensegmente = new ArrayList<Liniensegment>();
Raster raster                           = new Raster();


void setup() {
    //Grafikeinstellungen:
    size(800, 500, P3D);

    ui = new UiBooster();
    drop = new SDrop(this);

    ellipseMode(CENTER);


    // try loading data, otherwise go to SETUP:
    try {
        settings = loadJSONObject("settings.json");
        bild_datei = settings.getString("bild_datei");
        if (!bild_datei.equals(""))
        {
            bild = loadImage(bild_datei);
            println(bild_datei);
            println(bild);
            MODE = "RUNNING";
        }
        else
        {
            MODE = "SETUP";
            println("Bild-Dateipfad ist leer.");
        }

    } catch(Exception e) {
        print(e, "Bitte Eintellungen eigenhändig vornehmen.");
        MODE = "SETUP";
    }
    println("entering", MODE);



    //Gitterpunkte erstellen:
    //for (int x = 0; x < width; x += punktAbstand_x * raster.scale_x) {
    //for (int y = 0; y < width; y += punktAbstand_y * raster.scale_x) {
    //raster.gitterpunkte.add(new GitterPunkt(x, y));
//   }
// }
}

void draw() {

    if (MODE == "RUNNING") {
        mode_run();
    }
    else if (MODE == "SETUP") {
        mode_setup();
    }
}
