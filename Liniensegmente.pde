class Liniensegment {

int x1, y1, x2, y2;
String typ = ""; // mögliche Typen: "HORIZONTALE", "VERTIKALE", "KURVE_UNTEN", "KURVE_OBEN", "KURVE_LINKS", "KURVE_RECHTS"

Liniensegment(int x1_, int y1_, int x2_, int y2_){
        x1 = x1_;
        y1 = y1_;
        x2 = x2_;
        y2 = y2_;

        if (aktive_gitterpunkte.size() > 1) typ_zuordnung();
        else println("Liniensegment konnte nicht erzeugt werden, da es zu wenig aktive Gitterpunkte gibt.");

}

// Zuordnung des Kurventyps:
void typ_zuordnung()
{

        // gerade Linien:
        if (y1 == y2) typ = "HORIZONTALE";
        else if (x1 == x2) typ = "VERTIKALE";

        // Kurven:
        // if (liniensegmente.size() > 1)
        // {
        //         GitterPunkt gp_vorletzter = aktive_gitterpunkte.get(aktive_gitterpunkte.size() - 3);
        //         Liniensegment linie_vorher = liniensegmente.get(liniensegmente.size() - 2);
        //
        //         if (y1 == y2 && x1 != x2 && gp_vorletzter.y < y2 && linie_vorher.typ.equals("VERTIKALE")) typ = "KURVE_UNTEN";
        //         if (y1 == y2 && x1 != x2 && gp_vorletzter.y > y2 && linie_vorher.typ.equals("VERTIKALE")) typ = "KURVE_OBEN";
        //         if (y1 != y2 && gp_vorletzter.x > x1 && linie_vorher.typ.equals("HORIZONTALE")) typ = "KURVE_LINKS";
        //         if (y1 != y2 && gp_vorletzter.x < x1 && linie_vorher.typ.equals("HORIZONTALE")) typ = "KURVE_RECHTS";
        // }

        println("neue Linie des Typs " + typ + ":\n" + x1 + "|" + y1 + "\t" + x2 + "|" + y2);
}

void render(){
        PVector start, ctrl1, ctrl2, end;
        int angle = 180;
        float radius = 180;
        float length = 4 * tan(radians(angle / 4)) / 3;

        noFill();
        stroke(255);
        switch (typ) {
        case "HORIZONTALE":
                line(x1,y1, x2, y2);
                // obere linie:
                line(x1, y1 - 10, x2, y2 - 10);
                // untere Linie:
                line(x1, y1 + 10, x2, y2 + 10);
                break;
        case "VERTIKALE":
                line(x1,y1, x2, y2);
                // linke linie:
                line(x1- 10, y1, x2 - 10, y2);
                // rechte Linie:
                line(x1+10, y1, x2+10, y2);
                break;
        case "KURVE_OBEN":
                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1, y1 + (radius * length));
                ctrl2 = new PVector(x2, y2 + (radius * length));
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);
                break;
        case "KURVE_UNTEN":
                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1, y1 - (radius * length));
                ctrl2 = new PVector(x2, y2 - (radius * length));
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);
                break;
        case "KURVE_LINKS":

                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                // mittlere Linie:
                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1 - (radius * length), y1);
                ctrl2 = new PVector(x2 - (radius * length), y2);
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // äußere linie:
                radius = (y1 < y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1-10);
                ctrl1 = new PVector(x1 - (radius * length), y1-10);
                ctrl2 = new PVector(x2 - (radius * length), y2+10);
                end = new PVector(x2, y2+10);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // innere linie:
                radius = (y1 > y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1+10);
                ctrl1 = new PVector(x1 - (radius * length), y1+10);
                ctrl2 = new PVector(x2 - (radius * length), y2-10);
                end = new PVector(x2, y2-10);

                // stroke(255,0,0);
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
                break;
        case "KURVE_RECHTS":
                // mittlere Linie:
                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1);
                ctrl1 = new PVector(x1 + (radius * length), y1);
                ctrl2 = new PVector(x2 + (radius * length), y2);
                end = new PVector(x2, y2);

                stroke(255);
                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // äußere Linie:
                radius = (y1 < y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1 - 10);
                ctrl1 = new PVector(x1 + (radius * length), y1 - 10);
                ctrl2 = new PVector(x2 + (radius * length), y2 + 10);
                end = new PVector(x2, y2 + 10);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // innere Linie:
                radius = (y1 > y2) ? 85/2 : 45/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1 + 10);
                ctrl1 = new PVector(x1 + (radius * length), y1 + 10);
                ctrl2 = new PVector(x2 + (radius * length), y2 - 10);
                end = new PVector(x2, y2 - 10);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                // Kontrollpunkte anzeigen:
                if (globalVerboseLevel > 0)
                {
                        noStroke();
                        fill(193, 96, 118);
                        ellipse(ctrl1.x, ctrl1.y, 20, 20);
                        ellipse(ctrl2.x, ctrl2.y, 20, 20);
                }
                break;

        case "KURVE_OBENLINKS":
                angle = 45;
                // mittlere Linie:
                radius = 65/2;
                length = 4 * tan(radians(angle / 4)) / 3;

                start = new PVector(x1, y1 + 10);
                ctrl1 = new PVector(x1 + (radius * length), y1 + 10);
                ctrl2 = new PVector(x2 + (radius * length), y2 - 10);
                end = new PVector(x2, y2 - 10);

                bezier(start.x, start.y,
                       ctrl1.x, ctrl1.y,
                       ctrl2.x, ctrl2.y,
                       end.x, end.y);

                noStroke();
                fill(193, 96, 118);
                ellipse(ctrl1.x, ctrl1.y, 20, 20);
                ellipse(ctrl2.x, ctrl2.y, 20, 20);
                break;
                
        case "KURVE_OBENRECHTS":
                break;
        case "KURVE_UNTENLINKS":
                break;
        case "KURVE_UNTENRECHTS":
                break;
        default:
                break;
        }
}
}
