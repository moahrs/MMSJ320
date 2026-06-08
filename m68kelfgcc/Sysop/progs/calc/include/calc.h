#ifndef CALC_H
#define CALC_H

#define CALC_SCALE 10000L

#define CALC_X 53
#define CALC_Y 10
#define CALC_W 150
#define CALC_H 180

#define CALC_DISP_X (CALC_X + 8)
#define CALC_DISP_Y (CALC_Y + 18)
#define CALC_DISP_W 134
#define CALC_DISP_H 18

#define CALC_BTN_W 30
#define CALC_BTN_H 16
#define CALC_BTN_GAP 5
#define CALC_BTN_X (CALC_X + 8)
#define CALC_BTN_Y (CALC_Y + 44)

typedef struct
{
    unsigned char *label;
    unsigned char code;
    unsigned short x;
    unsigned short y;
    unsigned short w;
    unsigned short h;
} CALC_BUTTON;

#endif
