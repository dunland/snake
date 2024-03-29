void mode_run() {
  background(0);

  if (bild != null)
    image(bild, 0, 0);

  // Gitter zeichnen:
  for (GitterPunkt gp : raster.gitterpunkte) {
    gp.checkMouseOverlap();
    if (!record)
      gp.render();
  }

  // DXFAufnahme starten:
  if (record) {
    beginRaw(DXF, output_datei);
  }

  // Formen zeichnen:
  // zeichne Linie durch alle aktiven raster.gitterpunkte:
  // if (liniensegmente.size() > 1)
  for (Liniensegment ls : liniensegmente)
    ls.render();

  // DXFAufnahme beenden:
  if (record) {
    endRaw();
    record = false;
    println("record finished.");
  }

  if (raster.scaling_mode_is_on) {
    stroke(raster._color);
    // Kreuzzeichnen:
    if (raster.choose_point_index < 1) {
      line(mouseX - 10, mouseY - 10, mouseX + 10, mouseY + 10);
      line(mouseX + 10, mouseY - 10, mouseX - 10, mouseY + 10);
    } else {
      line(mouseX - 10, raster.scale_line[0].y - 10, mouseX + 10,
           raster.scale_line[0].y + 10);
      line(mouseX + 10, raster.scale_line[0].y - 10, mouseX - 10,
           raster.scale_line[0].y + 10);
    }

    // Linieund Länge einblenden:
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

void mode_setup() {
  background(0);
  textAlign(CENTER, BOTTOM);
  text("Bitte Bilddatei auswählen!", width / 2, height / 2);

  if (FLAG_GET_IMAGE_DIALOG) {
    FLAG_GET_IMAGE_DIALOG = false;
    File file = ui.showFileSelection();
    println(file);
    bild_pfad = file.getParent() + "/" + file.getName();
    println(bild_pfad);

    try {
      bild = loadImage(bild_pfad);
      raster.scaling_mode_is_on = true;
      MODE = "RUNNING";

      settings.setString("bild_pfad", bild_pfad);
      saveJSONObject(settings, "settings.json");

    } catch (Exception e) {
      println(e);
    }
  }
}
