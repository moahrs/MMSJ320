/* vc_screen.c */

#include "vc_screen.h"

/* suas funções reais */
void vc_cls(void)
{
    clearScrW();
}

void vc_gotoxy(int x, int y)
{
    vdp_set_cursor(x, y);
}

void vc_put_text(int x, int y, char *text, int invert)
{
    if (invert)
        writexy(x, y, text, 1, VC_COLOR_INV_FG, VC_COLOR_INV_BG);
    else
        writexy(x, y, text, 1, VC_COLOR_FG, VC_COLOR_BG);
}

int vc_getkey(void)
{
    return readChar();
}

void vc_refresh(void)
{
    /* no G2 provavelmente não precisa fazer nada */
}
