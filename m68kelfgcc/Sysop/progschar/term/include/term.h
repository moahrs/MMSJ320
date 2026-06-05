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
#define TEL_OPT_BINARY 0
#define TEL_OPT_ECHO 1
#define TEL_OPT_SGA 3
#define TEL_OPT_TTYPE 24
#define TEL_OPT_NAWS 31
#define TEL_TTYPE_IS 0
#define TEL_TTYPE_SEND 1

#define TERM_ESC_NORMAL 0
#define TERM_ESC_ESC    1
#define TERM_ESC_CSI    2
#define TERM_ESC_OSC    3
#define TERM_ESC_IGNORE 4
#define TERM_ESC_BARE   5

#define TERM_CPR_NONE       0
#define TERM_CPR_WAIT_DIGIT 1
#define TERM_CPR_DIGITS     2

#define TERM_TEL_NORMAL 0
#define TERM_TEL_IAC    1
#define TERM_TEL_CMD    2
#define TERM_TEL_SB_OPT 3
#define TERM_TEL_SB     4
#define TERM_TEL_SB_IAC 5

#include "netapi.h"

#define SER_RX_SIZE NETAPI_RX_SIZE

#define MFP_RX_FULL_BIT  0x10

static char termBuf[TERM_ROWS][TERM_COLS];
static unsigned char termColorBuf[TERM_ROWS][TERM_COLS];
static unsigned char curX = 0;
static unsigned char curY = 0;
static unsigned char viewX = 0;   /* 0 ou 40 */
static unsigned char savedX = 0;
static unsigned char savedY = 0;
static unsigned char termFontW = 6;
static unsigned char termFontH = 8;
static unsigned char termFontFirst = 32;
static unsigned char termFontLast = 255;
static unsigned long termFontAddr = 0;
static unsigned int termPatternTable = 0;
static unsigned int termColorTable = 0;
static unsigned char termUseFastG2 = 0;
static unsigned long *termFontLoadMem = 0;
static unsigned long *termFontSaveMem = 0;
static char termLineBuf[VIEW_COLS + 1];
static char termCharBuf[2];
static unsigned char termOldVideoMode = VDP_MODE_TEXT;
static unsigned char termFg = VDP_WHITE;
static unsigned char termBg = VDP_BLACK;
static unsigned char termColor = (VDP_WHITE << 4) | VDP_BLACK;
static unsigned char termBold = 0;
static unsigned char termCtrlK = 0;
static unsigned char termEscState = TERM_ESC_NORMAL;
static unsigned char termEscLen = 0;
static char termEscBuf[32];
static unsigned char termTelState = TERM_TEL_NORMAL;
static unsigned char termTelCmd = 0;
static unsigned char termTelSbOpt = 0;
static unsigned char termTelSbFirst = 0;
static unsigned char termTelTTypeSend = 0;
static unsigned char termUtf8BomState = 0;
static unsigned char termCprEchoArmed = 0;
static unsigned char termCprEchoState = TERM_CPR_NONE;

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

