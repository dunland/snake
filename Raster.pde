///////////////////////////////////////////////////////////////////////
/////////////////////////////////// RASTER ////////////////////////////
///////////////////////////////////////////////////////////////////////

class Raster {

  Raster() {}

  ArrayList<GitterPunkt> gitterpunkte = new ArrayList<GitterPunkt>();

  boolean scaling_mode_is_on = true;
  int choose_point_index = 0;
  PVector[] scale_line = new PVector[2];

  float scale_x = 1;
  color _color = color(255,255,255);

  ////////////////////////////// FUNCTIONS /////////////////////////////
  // --------------------------------------------
  void enable_scaling_mode() {
    scaling_mode_is_on = true;
    choose_point_index = 0;
  }

  // --------------------------------------------
  void set_scaling_point(int point_x, int point_y) {
    if (scaling_mode_is_on) {
      raster.scale_line[raster.choose_point_index] =
          new PVector(point_x, point_y);
      if (choose_point_index < 1) {
        choose_point_index++;
      } else {
        try {
          float input = float(ui.showTextInputDialog(
              "Maße in [cm] eingeben (als float mit Dezimal-Punkt)"));
          float v_diff = scale_line[0].dist(scale_line[1]);
          scale_x = v_diff / input;
          println("scale_x = ", v_diff, "px /", input, "cm =", scale_x,
                  "px/cm");

          // neue Gitterpunkte erstellen:
          gitterpunkte.clear();
          liniensegmente.clear();
          for (int x = 0; x < width; x += punktAbstand_x * raster.scale_x) {
            for (int y = 0; y < width; y += punktAbstand_y * raster.scale_x) {
              raster.gitterpunkte.add(new GitterPunkt(x, y));
            }
          }

        } catch (Exception e) {
          println("keine Länge eingegeben oder Länge mit falschem Format ",
                  "(Dezimalstellen-Punkt statt Komma verwenden!)");
        }
        scaling_mode_is_on = false;
      }
    }
  }

}
/////////////////////////////////////////// /////////////////////////////
////////////////////////////// GITTERPUNKTE /////////////////////////////
/////////////////////////////////////////// /////////////////////////////
class GitterPunkt {
  int x, y;
  int x_toleranz = 10, y_toleranz = 10;
  boolean unter_mouse;
  boolean aktiv = false;

  GitterPunkt(int x_, int y_) {
    x = x_;
    y = y_;
  }

  void render() {
    // weißen Gitterpunkt malen:
    stroke(255);
    point(x, y);

    // grauen Kreis malen, wenn Maus in der Nähe:
    if (unter_mouse) {
      noStroke();
      fill(185, 185, 185, 80);
      ellipse(x, y, rastermass / 3, rastermass / 3);
    }

    // weißen Kreis malen, wenn aktiv:
    if (aktiv) {
      fill(255);
      ellipse(x, y, rastermass / 3, rastermass / 3);
    }
  }

  // schauen, ob die Maus in der Nähe ist:
  void checkMouseOverlap() {
    if ((mouseX > x - x_toleranz && mouseX < x + x_toleranz) &&
        mouseY > y - y_toleranz && mouseY < y + y_toleranz) {
      unter_mouse = true;
    } else {
      unter_mouse = false;
    }
  }
}
