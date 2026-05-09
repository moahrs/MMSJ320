/* vc_screen.c */

#include "vc_screen.h"

unsigned char vc_fgcolor = VC_COLOR_FG;
unsigned char vc_bgcolor = VC_COLOR_BG;
int curscr = 1;
static unsigned char vc_reverse_on = 0;

/* suas funções reais */
void vc_cls(void)
{
    clearScrW();
}

void vc_gotoxy(int x, int y)
{
    vdp_set_cursor(x, y);
}

void vc_getmaxyx(int screen, int *max_y, int *max_x)
{
    (void)screen;

    if (max_y)
        *max_y = 191;
    if (max_x)
        *max_x = 255;
}

int vc_getkey(void)
{
    return readChar();
}

void vc_refresh(void)
{
    /* no G2 provavelmente não precisa fazer nada */
}

void vc_attron(int attr)
{
    (void)attr;

    if (!vc_reverse_on)
    {
        vdp_textcolor(vc_bgcolor, vc_fgcolor);
        vc_reverse_on = 1;
    }
}

void vc_attroff(int attr)
{
    (void)attr;

    if (vc_reverse_on)
    {
        vdp_textcolor(vc_fgcolor, vc_bgcolor);
        vc_reverse_on = 0;
    }
}
