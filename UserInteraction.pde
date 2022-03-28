// Tastaturbefehle:
void keyPressed() {
    println(key);
    // exportiere DXF mit Taste 'r':
    if (key ==  'R' || key == 'r') {
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
    // Gitterpunkt an Stelle derMaus auswählen:
    for (int i = 0; i < raster.gitterpunkte.size(); i++) {
        GitterPunkt gp = raster.gitterpunkte.get(i);
        if ((mouseX > gp.x - gp.x_toleranz && mouseX < gp.x + gp.x_toleranz) &&
            mouseY > gp.y - gp.y_toleranz &&  mouseY < gp.y + gp.y_toleranz) {
            gp.aktiv = !gp.aktiv;
            if (gp.aktiv) {
                aktive_gitterpunkte.add(gp);
                // neues Liniensegment:
                if (aktive_gitterpunkte.size() > 1) {
                    GitterPunkt gp_vorher =
                    aktive_gitterpunkte.get(aktive_gitterpunkte.size() - 2);
                    liniensegmente.add(
                        new Liniensegment(gp, gp_vorher));
                    // TODO : gp.linie = zuletzterstelle Linie
                }
            } else {
                aktive_gitterpunkte.remove(gp);
                // entferne Liniensegment:
                // TODO : alle aktiven gps müssen zugeordnete linie haben → entferne
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
