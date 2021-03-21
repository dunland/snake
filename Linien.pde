class Linie {

int x1, y1, x2, y2;

Linie(int x1_in, int y1_in, int x2_in, int y2_in){
        x1 = x1_in;
        y1 = y1_in;
        x2 = x2_in;
        y2 = x2_in;
}

void render()
{
        // Punkte auf gleicher Höhe: Linie zeichnen
        // if (gp.y == gp_vorher.y)
        // {
        stroke(255);
        line(x1, y1, x2, y2);
        stroke(255,0,0);
        line(x1, y1 - 10, x2, y2 - 10);
        stroke(0,0,255);
        line(x1, y1 + 10, x2, y2 + 10);
        // }
}
}
