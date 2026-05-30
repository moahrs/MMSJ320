#ifndef TESTES_H
#define TESTES_H

/* -------------------------------------------------- */
/* HOOKS                                              */
/* -------------------------------------------------- */

#define HOOK_MAGIC      0x4D4A

#define HOOKF_ACTIVE    0x0001

#define HOOK_TIMER_BEFORE      0
#define HOOK_TIMER_AFTER       1
#define HOOK_KEYBOARD_BEFORE   2
#define HOOK_KEYBOARD_AFTER    3

#define MAX_HOOKS              4

#define TERM_COLS 80
#define TERM_ROWS 24
#define VIEW_COLS 40

#define TEL_IAC  0xFF
#define TEL_SE   0xF0
#define TEL_SB   0xFA
#define TEL_WILL 0xFB
#define TEL_WONT 0xFC
#define TEL_DO   0xFD
#define TEL_DONT 0xFE

#include "netapi.h"

#define SER_RX_SIZE NETAPI_RX_SIZE

#define MFP_RX_FULL_BIT  0x10

static char termBuf[TERM_ROWS][TERM_COLS];
static unsigned char curX = 0;
static unsigned char curY = 0;
static unsigned char viewX = 0;   /* 0 ou 40 */
static unsigned char savedX = 0;
static unsigned char savedY = 0;

static unsigned char telPushValid = 0;
static unsigned char telPushByte = 0;

/* -------------------------------------------------- */
/* CONTEXTOS                                          */
/* -------------------------------------------------- */

typedef struct
{
    unsigned short consumed;
    unsigned short status;
    unsigned long  tick;

} TIMER_CTX;


typedef struct
{
    unsigned short consumed;
    unsigned short status;
    unsigned short raw;
    unsigned short ascii;

} KEY_CTX;

extern void tstIntsOff(void);
extern void tstIntsOn(void);

#endif

