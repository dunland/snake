class GitterPunkt
{
int x, y;
int x_toleranz = 10, y_toleranz = 10;
boolean unter_mouse;
boolean aktiv = false;

GitterPunkt(int x_, int y_)
{
        x = x_;
        y = y_;
}

void render()
{
        // weißen Gitterpunkt malen:
        stroke(255);
        point(x, y);

        // grauen Kreis malen, wenn Maus in der Nähe:
        if (unter_mouse)
        {
                noStroke();
                fill(185, 185, 185, 80);
                ellipse(x,y,20, 20);
        }

        // weißen Kreis malen, wenn aktiv:
        if (aktiv)
        {
                fill(255);
                ellipse(x,y,20,20);
        }
}

// schauen, ob die Maus in der Nähe ist:
void checkMouseOverlap()
{
        if ((mouseX > x - x_toleranz && mouseX < x + x_toleranz) && mouseY > y - y_toleranz && mouseY < y + y_toleranz)
        {
                unter_mouse = true;
        }
        else
        {
                unter_mouse = false;
        }
}

}
