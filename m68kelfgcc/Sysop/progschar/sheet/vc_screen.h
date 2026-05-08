/* vc_screen.h */

#ifndef VC_SCREEN_H
#define VC_SCREEN_H

#define VC_COLOR_FG      15
#define VC_COLOR_BG      1

#define VC_COLOR_INV_FG  VC_COLOR_BG
#define VC_COLOR_INV_BG  VC_COLOR_FG

extern unsigned char vc_fgcolor;
extern unsigned char vc_bgcolor;
extern int curscr;

void vc_cls(void);
void vc_gotoxy(int x, int y);
void vc_getmaxyx(int screen, int *max_y, int *max_x);
int  vc_getkey(void);
void vc_refresh(void);
void vc_attron(int attr);
void vc_attroff(int attr);

#define A_REVERSE  1
#define COLOR_PAIR(n)  (n)

#define clear()         vc_cls()
#define refresh()       vc_refresh()
#define move(y,x)       vc_gotoxy((x),(y))
#define getmaxyx(scr,y,x) vc_getmaxyx((scr), &(y), &(x))
#define getch()         vc_getkey()
#define printw          mprintf
#define attron(a)       vc_attron((a))
#define attroff(a)      vc_attroff((a))

#endif