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
  void typ_zuordnung() {

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

  void set_type(String type_) {
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

  void render() {

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
