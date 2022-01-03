/*
   Heizungsauslegungsgenerator v.0.1.03
   dunland, Juli 2021

   TODO:
   - [ ] Raster bewegen per drag&drop
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

JSONObject data;

PImage image;
String output_datei = "output";

boolean record;
float   rastermass = 13; // in cm
float   punktAbstand_x = rastermass, punktAbstand_y = rastermass;
int     globalVerboseLevel = 0;

// Punktlisten:
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

// Liniensegmente:
ArrayList<Liniensegment> liniensegmente = new ArrayList<Liniensegment>();

Raster raster = new Raster();

void setup() {
  // Grafikeinstellungen:
  size(800, 500, P3D);
  surface.setTitle("snake");
  surface.setResizable(true);
  ellipseMode(CENTER);

  // Interaktion
  ui = new UiBooster();

  // Lade initiale Daten:
  data = new JSONObject();
  load_data_profile("settings.json", data);

  try {
    image = loadImage(data.getString("image_file"));
  } catch (Exception e) {
    print(e, "please pick image file!");
    try {
      File file = ui.showFileSelection();
      image = loadImage(file.getAbsolutePath());
    } catch (Exception f) {
      print(f, "image could not be loaded.");
    }
  }
  // Gitterpunkte erstellen:
  // for (int x = 0; x < width; x += punktAbstand_x * raster.scale_x) {
  //   for (int y = 0; y < width; y += punktAbstand_y * raster.scale_x) {
  //     raster.gitterpunkte.add(new GitterPunkt(x, y));
  //   }
  // }
}

void draw() {
  background(0);

  image(image, 0, 0);

  // Gitter zeichnen:
  for (GitterPunkt gp : raster.gitterpunkte) {
    gp.checkMouseOverlap();

    if (!record) gp.render();
  }

  // DXF Aufnahme starten:
  if (record) {
    beginRaw(DXF, output_datei+".dxf");
    beginRecord(SVG, output_datei+".svg");
  }

  // Formen zeichnen:
  // zeichne Linie durch alle aktiven raster.gitterpunkte:
  // if (liniensegmente.size() > 1)
  for (Liniensegment ls : liniensegmente) ls.render();

  // DXF Aufnahme beenden:
  if (record) {
    endRaw();
    endRecord();
    record = false;
    println("record finished.");
  }

  if (raster.scaling_mode_is_on) {
    stroke(raster._color);

    // Kreuz zeichnen:
    if (raster.choose_point_index < 1) {
      line(mouseX - 10, mouseY - 10, mouseX + 10, mouseY + 10);
      line(mouseX + 10, mouseY - 10, mouseX - 10, mouseY + 10);
    } else {
      line(mouseX - 10, raster.scale_line[0].y - 10, mouseX + 10,
           raster.scale_line[0].y + 10);
      line(mouseX + 10, raster.scale_line[0].y - 10, mouseX - 10,
           raster.scale_line[0].y + 10);
    }

    // Linie und Länge einblenden:
    if (raster.choose_point_index > 0) {
      line(raster.scale_line[0].x, raster.scale_line[0].y, mouseX,
           raster.scale_line[0].y);
      text(int(raster.scale_line[0].dist(
                 new PVector(mouseX, raster.scale_line[0].y))) +
           " px",
           raster.scale_line[0].x, raster.scale_line[0].y - 10);
    }
  }
}

// Tastaturbefehle:
void keyPressed() {
  println(key);

  // exportiere DXF mit Taste 'r':
  if ((key == 'R') || (key == 'r')) {
    record = true;
  }

  // Kurven einstellen:
  if ((key == 'W') ||
      (key == 'w')) liniensegmente.get(liniensegmente.size() - 1).set_type(
      "KURVE_OBEN");
  else if ((key == 'A') || (key == 'a')) liniensegmente.get(
      liniensegmente.size() - 1).typ = "KURVE_LINKS";
  else if ((key == 'S') || (key == 's')) liniensegmente.get(
      liniensegmente.size() - 1).set_type("KURVE_UNTEN");
  else if ((key == 'D') || (key == 'd')) liniensegmente.get(
      liniensegmente.size() - 1).typ = "KURVE_RECHTS";
  else if ((key == 'Q') || (key == 'q')) liniensegmente.get(
      liniensegmente.size() - 1).set_type("KURVE_OBENLINKS");
  else if ((key == 'E') || (key == 'e')) liniensegmente.get(
      liniensegmente.size() - 1).set_type("KURVE_OBENRECHTS");
  else if ((key == 'Y') || (key == 'y')) liniensegmente.get(
      liniensegmente.size() - 1).set_type("KURVE_UNTENLINKS");
  else if ((key == 'X') || (key == 'x')) liniensegmente.get(
      liniensegmente.size() - 1).set_type("KURVE_UNTENRECHTS");
  else if (key == ' ') {
    if (liniensegmente.get(liniensegmente.size() - 1).typ ==
        "HORIZONTALE") liniensegmente.get(liniensegmente.size() -
                                          1).typ = "VERTIKALE";
    else if (liniensegmente.get(liniensegmente.size() - 1).typ ==
             "VERTIKALE") liniensegmente.get(liniensegmente.size() -
                                             1).typ = "HORIZONTALE";
    else liniensegmente.get(liniensegmente.size() - 1).typ = "HORIZONTALE";
  }


  else if ((key == '+') || (key == 'ȉ')) {
    globalVerboseLevel++;
    println("globalVerboseLevel = ", globalVerboseLevel);
  }
  else if (key == '-') {
    globalVerboseLevel--;
    println("globalVerboseLevel = ", globalVerboseLevel);
  }

  // load image:
  else if ((key == 'l') || (key == 'L')) {
    try {
      File file = ui.showFileSelection();
      image = loadImage(file.getAbsolutePath());
      image.resize(width, image.width/width * image.height);
    } catch (Exception e) {
      print("cannot load file!", e);
    }
  }

  // raster scaling:
  else if ((key == 'n') || (key == 'N')) {
    raster.enable_scaling_mode();
  }
}

// Mausklick:
void mouseClicked() {
  // Gitterpunkt an Stelle der Maus auswählen:
  if (raster.scaling_mode_is_on == false)
  {
    for (int i = 0; i < raster.gitterpunkte.size(); i++) {
      GitterPunkt gp = raster.gitterpunkte.get(i);

      if (((mouseX > gp.x - gp.x_toleranz) && (mouseX < gp.x + gp.x_toleranz)) &&
          (mouseY > gp.y - gp.y_toleranz) && (mouseY < gp.y + gp.y_toleranz)) {
        gp.aktiv = !gp.aktiv;

        if (gp.aktiv) {
          aktive_gitterpunkte.add(gp);

          // neues Liniensegment:
          if (aktive_gitterpunkte.size() > 1) {
            GitterPunkt gp_vorher =
              aktive_gitterpunkte.get(aktive_gitterpunkte.size() - 2);
            liniensegmente.add(
              new Liniensegment(gp, gp_vorher));

            // TODO: gp.linie = zuletzt erstelle Linie
          }
        } else {
          aktive_gitterpunkte.remove(gp);

          // entferne Liniensegment:
          // TODO: alle aktiven gps müssen zugeordnete linie haben → entferne
          // diese linie
        }
      }
    }
  }

  if (raster.scaling_mode_is_on) {
    if (raster.choose_point_index < 1) raster.set_scaling_point(mouseX, mouseY);
    else raster.set_scaling_point(mouseX, int(raster.scale_line[0].y));
  }
}
