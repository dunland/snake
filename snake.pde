/*
   Heizungsauslegungsgenerator v.0.1.01
   dunland, März-Mai 2021

   TODO:
   ..Raster bewegen per drag&drop
   ..Raster zerschneiden??
   ..Liniensegmente rückgängig machen
   ..Liniensegmente an Gitterpunkte binden
   ..Liniensegmente exportieren/speichern
   ..Erkennung vertikale vs horizontale Verläufe
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
UiBooster ui;

PImage bild;
String output_datei = "output.dxf";

boolean record;
float rastermass = 13; // in cm
float punktAbstand_x = rastermass, punktAbstand_y = rastermass;
int globalVerboseLevel = 0;

// Punktlisten:
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

// Liniensegmente:
ArrayList<Liniensegment> liniensegmente = new ArrayList<Liniensegment>();

Raster raster = new Raster();

void setup() {
  // Grafikeinstellungen:
  size(800, 500, P3D);

  ui = new UiBooster();

  ellipseMode(CENTER);

  bild = loadImage("beispielbild.jpeg");

  // Gitterpunkte erstellen:
  // for (int x = 0; x < width; x += punktAbstand_x * raster.scale_x) {
  //   for (int y = 0; y < width; y += punktAbstand_y * raster.scale_x) {
  //     raster.gitterpunkte.add(new GitterPunkt(x, y));
  //   }
  // }
}

void draw() {
  background(0);

  image(bild, 0, 0);
  // Gitter zeichnen:
  for (GitterPunkt gp : raster.gitterpunkte) {
    gp.checkMouseOverlap();
    if (!record)
      gp.render();
  }

  // DXF Aufnahme starten:
  if (record) {
    beginRaw(DXF, output_datei);
  }

  // Formen zeichnen:
  // zeichne Linie durch alle aktiven raster.gitterpunkte:
  // if (liniensegmente.size() > 1)
  for (Liniensegment ls : liniensegmente)
    ls.render();

  // DXF Aufnahme beenden:
  if (record) {
    endRaw();
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
  if (key == 'R' || key == 'r') {
    record = true;
  }
  if (key == 'W' || key == 'w')
    liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_OBEN");
  if (key == 'A' || key == 'a')
    liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_LINKS";
  if (key == 'S' || key == 's')
    liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_UNTEN");
  if (key == 'D' || key == 'd')
    liniensegmente.get(liniensegmente.size() - 1).typ = "KURVE_RECHTS";
  if (key == 'Q' || key == 'q')
    liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_OBENLINKS");
  if (key == 'E' || key == 'e')
    liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_OBENRECHTS");
  if (key == 'Y' || key == 'y')
    liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_UNTENLINKS");
  if (key == 'X' || key == 'x')
    liniensegmente.get(liniensegmente.size() - 1).set_type("KURVE_UNTENRECHTS");
  if (key == ' ') {
    if (liniensegmente.get(liniensegmente.size() - 1).typ == "HORIZONTALE")
      liniensegmente.get(liniensegmente.size() - 1).typ = "VERTIKALE";
    else if (liniensegmente.get(liniensegmente.size() - 1).typ == "VERTIKALE")
      liniensegmente.get(liniensegmente.size() - 1).typ = "HORIZONTALE";
    else
      liniensegmente.get(liniensegmente.size() - 1).typ = "HORIZONTALE";
  }
  if (key == '+' || key == 'ȉ') {
    globalVerboseLevel++;
    println("globalVerboseLevel = ", globalVerboseLevel);
  }
  if (key == '-') {
    globalVerboseLevel--;
    println("globalVerboseLevel = ", globalVerboseLevel);
  }
  if (key == 'n' || key == 'N') {
    raster.enable_scaling_mode();
  }
}

// Mausklick:
void mouseClicked() {
  // Gitterpunkt an Stelle der Maus auswählen:
  for (int i = 0; i < raster.gitterpunkte.size(); i++) {
    GitterPunkt gp = raster.gitterpunkte.get(i);
    if ((mouseX > gp.x - gp.x_toleranz && mouseX < gp.x + gp.x_toleranz) &&
        mouseY > gp.y - gp.y_toleranz && mouseY < gp.y + gp.y_toleranz) {
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

  if (raster.scaling_mode_is_on) {
    if (raster.choose_point_index < 1)
      raster.set_scaling_point(mouseX, mouseY);
    else
      raster.set_scaling_point(mouseX, int(raster.scale_line[0].y));
  }
}
