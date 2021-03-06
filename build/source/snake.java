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



UiBooster ui;

PImage bild;
String output_datei = "output.dxf";

boolean record;
int rastermass = 13; // in cm
int punktAbstand_x = rastermass, punktAbstand_y = rastermass;
int globalVerboseLevel = 0;

// Punktlisten:
ArrayList<GitterPunkt> aktive_gitterpunkte = new ArrayList<GitterPunkt>();

// Liniensegmente:
ArrayList<Liniensegment> liniensegmente = new ArrayList<Liniensegment>();

Raster raster = new Raster();

public void setup() {
  // Grafikeinstellungen:
  

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

public void draw() {
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
      text(PApplet.parseInt(raster.scale_line[0].dist(
               new PVector(mouseX, raster.scale_line[0].y))) +
               " px",
           raster.scale_line[0].x, raster.scale_line[0].y - 10);
    }
  }
}

// Tastaturbefehle:
public void keyPressed() {
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
public void mouseClicked() {
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
              new Liniensegment(gp.x, gp.y, gp_vorher.x, gp_vorher.y));
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
      raster.set_scaling_point(mouseX, PApplet.parseInt(raster.scale_line[0].y));
  }
}
class Liniensegment {

  int x1, y1, x2, y2;
  String typ = ""; // mögliche Typen: "HORIZONTALE", "VERTIKALE", "KURVE_UNTEN",
                   // "KURVE_OBEN", "KURVE_LINKS", "KURVE_RECHTS"
  PVector start, ctrl1, ctrl2, end;
  int angle = 180;
  float radius = 180;
  float length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

  Liniensegment(int x1_, int y1_, int x2_, int y2_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;

    if (aktive_gitterpunkte.size() > 1)
      typ_zuordnung();
    else
      println(
        "Liniensegment konnte nicht erzeugt werden, da es zu wenig aktive Gitterpunkte gibt.");
  }

  //////////////////////// Zuordnung des Kurventyps ////////////////////////////
  public void typ_zuordnung() {

    // --------------------------- gerade Linien: --------------------------
    if (y1 == y2)
      typ = "HORIZONTALE";
    else if (x1 == x2)
      typ = "VERTIKALE";

    // ------------------------------ Kurven: ------------------------------
    // KURVE OBEN LINKS; nach oben:
    else if (x1 > x2 && y1 < y2) {
      typ = "KURVE_OBENLINKS";
      angle = 90;
      // mittlere Linie:
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1 - (radius * length), y1);
      ctrl2 = new PVector(x2, y2 - (radius * length));
      end = new PVector(x2, y2);
    }

    // KURVE OBEN LINKS; nach unten:
    else if (x1 < x2 && y1 > y2) {
      typ = "KURVE_OBENLINKS";
      angle = 90;
      // mittlere Linie:
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1, y1 - (radius * length));
      ctrl2 = new PVector(x2 - (radius * length), y2);
      end = new PVector(x2, y2);
    }

    // oben rechts, von oben kommend:
    else if (x2 < x1 && y2 < y1) {
      typ = "KURVE_OBENRECHTS";
      println("oben rechts von oben kommend");

      angle = 90;
      // mittlere Linie:
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1, y1 - (radius * length));
      ctrl2 = new PVector(x2 + (radius * length), y2);
      end = new PVector(x2, y2);
    }

    // oben rechts, von unten kommend:
    else if (x2 > x1 && y2 > y1) {
      typ = "KURVE_OBENRECHTS";
      println("oben rechts von unten kommend");

      angle = 90;
      // mittlere Linie:
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1 + (radius * length), y1);
      ctrl2 = new PVector(x2, y2 - (radius * length));
      end = new PVector(x2, y2);
    }

    // unten links, von unten kommend:
    else if (x2 > x1 && y2 > y1) {
      typ = "KURVE_UNTENLINKS";
      println("unten links von unten kommend");

      angle = 90;
      // mittlere Linie:
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1, y1 + (radius * length));
      ctrl2 = new PVector(x2 - (radius * length), y2);
      end = new PVector(x2, y2);
    }

    // unten links, von oben kommend:
    else if (x2 < x1 && y2 < y1) {
      typ = "KURVE_UNTENLINKS";
      println("unten links von oben kommend");

      angle = 90;
      // mittlere Linie:
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1 - (radius * length), y1);
      ctrl2 = new PVector(x2, y2 + (radius * length));
      end = new PVector(x2, y2);
    }

    // unten rechts:
    else if (x1 > x2 && y1 < y2) {
      typ = "KURVE_UNTENRECHTS";
      println("unten rechts von unten kommend");

      angle = 90;
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1 + (radius * length), y1);
      ctrl2 = new PVector(x2, y2 + (radius * length));
      end = new PVector(x2, y2);
    } else if (x1 < x2 && y1 > y2) {
      typ = "KURVE_UNTENRECHTS";
      println("unten rechts von oben kommend");

      angle = 90;
      radius = rastermass;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1 + (radius * length), y1);
      ctrl2 = new PVector(x2, y2 + (radius * length));
      end = new PVector(x2, y2);
    }

    println("neue Linie des Typs " + typ + ":\n" + x1 + "|" + y1 + "\t" + x2 +
            "|" + y2);
  }

  public void set_type(String type_) {
    typ = type_;
    switch (typ) {
    case "KURVE_OBEN":
      radius = rastermass / 2;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1, y1 - (radius * length));
      ctrl2 = new PVector(x2, y2 - (radius * length));
      end = new PVector(x2, y2);
      break;

    case "KURVE_UNTEN":
      radius = rastermass / 2;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1, y1 + (radius * length));
      ctrl2 = new PVector(x2, y2 + (radius * length));
      end = new PVector(x2, y2);
      break;

    case "KURVE_OBENLINKS":

      if (x1 > x2 && y1 < y2) {

        angle = 90;
        // mittlere Linie:
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1 - (radius * length), y1);
        ctrl2 = new PVector(x2, y2 - (radius * length));
        end = new PVector(x2, y2);
      } else if (x1 < x2 && y1 > y2) {

        angle = 90;
        // mittlere Linie:
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1, y1 - (radius * length));
        ctrl2 = new PVector(x2 - (radius * length), y2);
        end = new PVector(x2, y2);
      }
      break;

    case "KURVE_OBENRECHTS":
      // oben rechts, von oben kommend:
      if (x2 < x1 && y2 < y1) {
        println("oben rechts von oben kommend");

        angle = 90;
        // mittlere Linie:
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1, y1 - (radius * length));
        ctrl2 = new PVector(x2 + (radius * length), y2);
        end = new PVector(x2, y2);
      }

      // oben rechts, von unten kommend:
      else if (x2 > x1 && y2 > y1) {
        println("oben rechts von unten kommend");

        angle = 90;
        // mittlere Linie:
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1 + (radius * length), y1);
        ctrl2 = new PVector(x2, y2 - (radius * length));
        end = new PVector(x2, y2);
      }

      break;

    case "KURVE_UNTENLINKS":
      // unten links, von unten kommend:
      if (x2 > x1 && y2 > y1) {
        typ = "KURVE_UNTENLINKS";
        println("unten links von unten kommend");

        angle = 90;
        // mittlere Linie:
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1, y1 + (radius * length));
        ctrl2 = new PVector(x2 - (radius * length), y2);
        end = new PVector(x2, y2);
      }

      // unten links, von oben kommend:
      else if (x2 < x1 && y2 < y1) {
        typ = "KURVE_UNTENLINKS";
        println("unten links von oben kommend");

        angle = 90;
        // mittlere Linie:
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1 - (radius * length), y1);
        ctrl2 = new PVector(x2, y2 + (radius * length));
        end = new PVector(x2, y2);
      }
      break;

    case "KURVE_UNTENRECHTS":
      if (x1 > x2 && y1 < y2) {
        typ = "KURVE_UNTENRECHTS";
        println("unten rechts von unten kommend");

        angle = 90;
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1, y1 + (radius * length));
        ctrl2 = new PVector(x2 + (radius * length), y2);
        end = new PVector(x2, y2);
      } else if (x1 < x2 && y1 > y2) {
        typ = "KURVE_UNTENRECHTS";
        println("unten rechts von oben kommend");

        angle = 90;
        radius = rastermass;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1);
        ctrl1 = new PVector(x1 + (radius * length), y1);
        ctrl2 = new PVector(x2, y2 + (radius * length));
        end = new PVector(x2, y2);
      }

      break;
    }
  }

  public void render() {

    noFill();
    stroke(255);
    switch (typ) {
    case "HORIZONTALE":
      line(x1, y1, x2, y2);
      if (globalVerboseLevel > 1) {
        // obere linie:
        line(x1, y1 - 10, x2, y2 - 10);
        // untere Linie:
        line(x1, y1 + 10, x2, y2 + 10);
      }
      break;
    case "VERTIKALE":
      line(x1, y1, x2, y2);
      if (globalVerboseLevel > 1) {
        // linke linie:
        line(x1 - 10, y1, x2 - 10, y2);
        // rechte Linie:
        line(x1 + 10, y1, x2 + 10, y2);
      }
      break;
    case "KURVE_OBEN":
      stroke(255);
      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);
      break;
    case "KURVE_UNTEN":
      stroke(255);
      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);

      break;

    case "KURVE_LINKS":

      radius = rastermass / 2;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      // mittlere Linie:
      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1 - (radius * length), y1);
      ctrl2 = new PVector(x2 - (radius * length), y2);
      end = new PVector(x2, y2);

      stroke(255);
      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);

      // äußere linie:
      if (globalVerboseLevel > 1) {

        radius = (y1 < y2) ? (rastermass + rastermass/3) / 2 : (rastermass - rastermass/3) / 2;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1 - 10);
        ctrl1 = new PVector(x1 - (radius * length), y1 - 10);
        ctrl2 = new PVector(x2 - (radius * length), y2 + 10);
        end = new PVector(x2, y2 + 10);

        bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
               end.y);

        // innere linie:
        radius = (y1 > y2) ? (rastermass + rastermass/3) / 2 : (rastermass - rastermass/3) / 2;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1 + 10);
        ctrl1 = new PVector(x1 - (radius * length), y1 + 10);
        ctrl2 = new PVector(x2 - (radius * length), y2 - 10);
        end = new PVector(x2, y2 - 10);

        // stroke(255,0,0);
        bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
               end.y);

      }
      break;

    case "KURVE_RECHTS":
      // mittlere Linie:
      radius = rastermass / 2;
      length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

      start = new PVector(x1, y1);
      ctrl1 = new PVector(x1 + (radius * length), y1);
      ctrl2 = new PVector(x2 + (radius * length), y2);
      end = new PVector(x2, y2);

      stroke(255);
      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);

      if (globalVerboseLevel > 1) {

        // äußere Linie:
        radius = (y1 < y2) ? (rastermass + rastermass/3) / 2 : (rastermass - rastermass/3) / 2;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1 - 10);
        ctrl1 = new PVector(x1 + (radius * length), y1 - 10);
        ctrl2 = new PVector(x2 + (radius * length), y2 + 10);
        end = new PVector(x2, y2 + 10);

        bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
               end.y);

        // innere Linie:
        radius = (y1 > y2) ? (rastermass + rastermass/3) / 2 : (rastermass - rastermass/3) / 2;
        length = 4 * tan(radians(angle / 4)) / 3 * raster.scale_x;

        start = new PVector(x1, y1 + 10);
        ctrl1 = new PVector(x1 + (radius * length), y1 + 10);
        ctrl2 = new PVector(x2 + (radius * length), y2 - 10);
        end = new PVector(x2, y2 - 10);

        bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
               end.y);
      }

      break;

    case "KURVE_OBENLINKS":
      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);

      // Kontrollpunkte:
      if (globalVerboseLevel > 0) {
        noStroke();
        fill(193, 96, 118);
        ellipse(ctrl1.x, ctrl1.y, 10, 10);
        fill(62, 147, 101);
        ellipse(ctrl2.x, ctrl2.y, 10, 10);
      }

      break;

    case "KURVE_OBENRECHTS":

      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);

      // Kontrollpunkte:
      if (globalVerboseLevel > 0) {
        noStroke();
        fill(193, 96, 118);
        ellipse(ctrl1.x, ctrl1.y, 10, 10);
        fill(62, 147, 101);
        ellipse(ctrl2.x, ctrl2.y, 10, 10);
      }
      break;

    case "KURVE_UNTENLINKS":
      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);

      // Kontrollpunkte:
      if (globalVerboseLevel > 0) {
        noStroke();
        fill(193, 96, 118);
        ellipse(ctrl1.x, ctrl1.y, 10, 10);
        fill(62, 147, 101);
        ellipse(ctrl2.x, ctrl2.y, 10, 10);
      }

      break;

    case "KURVE_UNTENRECHTS":
      bezier(start.x, start.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, end.x,
             end.y);

      // Kontrollpunkte:
      if (globalVerboseLevel > 0) {
        noStroke();
        fill(193, 96, 118);
        ellipse(ctrl1.x, ctrl1.y, 10, 10);
        fill(62, 147, 101);
        ellipse(ctrl2.x, ctrl2.y, 10, 10);
      }
      break;

    default:
      break;
    }
  }
}
class Raster {

  Raster() {}

  ArrayList<GitterPunkt> gitterpunkte = new ArrayList<GitterPunkt>();

  boolean scaling_mode_is_on = true;
  int choose_point_index = 0;
  PVector[] scale_line = new PVector[2];

  float scale_x = 1;

  public void enable_scaling_mode() {
    scaling_mode_is_on = true;
    choose_point_index = 0;
  }

  public void set_scaling_point(int point_x, int point_y) {
    if (scaling_mode_is_on) {
      raster.scale_line[raster.choose_point_index] =
          new PVector(point_x, point_y);
      if (choose_point_index < 1) {
        choose_point_index++;
      } else {
        try {
          float input = PApplet.parseFloat(ui.showTextInputDialog(
              "Maße in [cm] eingeben (als float mit Dezimal-Punkt)"));
          float v_diff = scale_line[0].dist(scale_line[1]);
            scale_x = v_diff/input;
          println("scale_x = ", v_diff, "px /", input, "cm =", scale_x, "px/cm");

          // neue Gitterpunkte erstellen:
          gitterpunkte.clear();
          liniensegmente.clear();
          for (int x = 0; x < width; x += punktAbstand_x * raster.scale_x) {
            for (int y = 0; y < width; y += punktAbstand_y * raster.scale_x) {
              raster.gitterpunkte.add(new GitterPunkt(x, y));
            }
          }

        } catch (Exception e) {
          println("keine Länge eingegeben oder Länge mit falschem Format (Dezimalstellen-Punkt statt Komma verwenden!)");
        }
        scaling_mode_is_on = false;
      }
    }
  }

}

class GitterPunkt {
  int x, y;
  int x_toleranz = 10, y_toleranz = 10;
  boolean unter_mouse;
  boolean aktiv = false;

  GitterPunkt(int x_, int y_) {
    x = x_;
    y = y_;
  }

  public void render() {
    // weißen Gitterpunkt malen:
    stroke(255);
    point(x, y);

    // grauen Kreis malen, wenn Maus in der Nähe:
    if (unter_mouse) {
      noStroke();
      fill(185, 185, 185, 80);
      ellipse(x, y, rastermass/3, rastermass/3);
    }

    // weißen Kreis malen, wenn aktiv:
    if (aktiv) {
      fill(255);
      ellipse(x, y, rastermass/3, rastermass/3);
    }
  }

  // schauen, ob die Maus in der Nähe ist:
  public void checkMouseOverlap() {
    if ((mouseX > x - x_toleranz && mouseX < x + x_toleranz) &&
        mouseY > y - y_toleranz && mouseY < y + y_toleranz) {
      unter_mouse = true;
    } else {
      unter_mouse = false;
    }
  }
}
  public void settings() {  size(800, 500, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "snake" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
