/*
   Heizungsauslegungsgenerator v.0.1.03a
   dunland, März 2022

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

UiBooster ui;

PImage bild;
String bild_pfad;
File bild_datei;
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

boolean FLAG_GET_IMAGE_DIALOG = false;

void setup() {
    //Grafikeinstellungen:
    size(800, 500, P3D);

    ui = new UiBooster();

    ellipseMode(CENTER);


    // try loading data, otherwise go to SETUP:
    try {
        settings = loadJSONObject("settings.json");
        bild_pfad = settings.getString("bild_pfad");
        if (!bild_pfad.equals(""))
        {
            bild = loadImage(bild_pfad);
            println(bild_pfad);
            println(bild);
            MODE = "RUNNING";
        }
        else
        {
            MODE = "SETUP";
            println("Bild-Dateipfad ist leer.");
            FLAG_GET_IMAGE_DIALOG = true;            
        }

    } catch(Exception e) {
        print(e, "Bitte Eintellungen eigenhändig vornehmen.");
        MODE = "SETUP";
        FLAG_GET_IMAGE_DIALOG = true;
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
