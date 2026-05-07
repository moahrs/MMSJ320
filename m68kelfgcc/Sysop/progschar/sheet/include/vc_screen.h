/* vc_screen.h */

#ifndef VC_SCREEN_H
#define VC_SCREEN_H

#define VC_COLOR_FG      15
#define VC_COLOR_BG      1

#define VC_COLOR_INV_FG  VC_COLOR_BG
#define VC_COLOR_INV_BG  VC_COLOR_FG

void vc_cls(void);
void vc_gotoxy(int x, int y);
void vc_put_text(int x, int y, char *text, int invert);
int  vc_getkey(void);
void vc_refresh(void);

#define clear()         vc_cls()
#define refresh()       vc_refresh()
#define move(y,x)       vc_gotoxy((x),(y))
#define getch()         vc_getkey()

#endif