/********************************************************************************
*    Programa    : calc.c
*    Objetivo    : Calculadora basica MGUI
********************************************************************************/

#include <string.h>
#include <stdlib.h>

#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"
#include "mmsj320api.h"
#include "calc.h"

static unsigned char calcDisplay[24];
static long calcAcc;
static unsigned char calcPendingOp;
static unsigned char calcHasAcc;
static unsigned char calcStartNew;
static unsigned char calcError;
static unsigned char calcMousePrev;
static unsigned char calcFg;
static unsigned char calcBg;

static CALC_BUTTON calcButtons[] =
{
    { "C",   'C', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "CE",  'E', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "<",   '<', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "/",   '/', 0, 0, CALC_BTN_W, CALC_BTN_H },

    { "7",   '7', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "8",   '8', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "9",   '9', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "*",   '*', 0, 0, CALC_BTN_W, CALC_BTN_H },

    { "4",   '4', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "5",   '5', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "6",   '6', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "-",   '-', 0, 0, CALC_BTN_W, CALC_BTN_H },

    { "1",   '1', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "2",   '2', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "3",   '3', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "+",   '+', 0, 0, CALC_BTN_W, CALC_BTN_H },

    { "+/-", 'N', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "0",   '0', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { ".",   '.', 0, 0, CALC_BTN_W, CALC_BTN_H },
    { "=",   '=', 0, 0, CALC_BTN_W, CALC_BTN_H },

    { "Close", 'Q', 0, 0, 135, 14 }
};

static void calcLayoutButtons(void)
{
    unsigned char i;
    unsigned char row;
    unsigned char col;

    for (i = 0; i < sizeof(calcButtons) / sizeof(calcButtons[0]); i++)
    {
        if (i < 20)
        {
            row = (unsigned char)(i / 4);
            col = (unsigned char)(i % 4);
            calcButtons[i].x = (unsigned short)(CALC_BTN_X + (col * (CALC_BTN_W + CALC_BTN_GAP)));
            calcButtons[i].y = (unsigned short)(CALC_BTN_Y + (row * (CALC_BTN_H + CALC_BTN_GAP)));
        }
        else
        {
            calcButtons[i].x = CALC_BTN_X;
            calcButtons[i].y = (unsigned short)(CALC_BTN_Y + (5 * (CALC_BTN_H + CALC_BTN_GAP)));
        }
    }
}

static void calcReset(void)
{
    strcpy((char *)calcDisplay, "0");
    calcAcc = 0;
    calcPendingOp = 0;
    calcHasAcc = 0;
    calcStartNew = 1;
    calcError = 0;
}

static long calcParseDisplay(void)
{
    unsigned char *p;
    long sign;
    long value;
    long scale;

    if (calcError)
        return 0;

    p = calcDisplay;
    sign = 1;
    value = 0;

    if (*p == '-')
    {
        sign = -1;
        p++;
    }

    while (*p >= '0' && *p <= '9')
    {
        value = (value * 10) + (*p - '0');
        p++;
    }

    value *= CALC_SCALE;

    if (*p == '.')
    {
        p++;
        scale = CALC_SCALE / 10;
        while (*p >= '0' && *p <= '9' && scale > 0)
        {
            value += ((*p - '0') * scale);
            scale /= 10;
            p++;
        }
    }

    return value * sign;
}

static void calcFixedToDisplay(long value)
{
    long intPart;
    long frac;
    long div;
    unsigned char tmp[16];
    unsigned char fracTxt[6];
    unsigned char ix;

    calcDisplay[0] = 0;

    if (value < 0)
    {
        strcat((char *)calcDisplay, "-");
        value = -value;
    }

    intPart = value / CALC_SCALE;
    frac = value % CALC_SCALE;

    ltoa(intPart, (char *)tmp, 10);
    strcat((char *)calcDisplay, (char *)tmp);

    if (frac != 0)
    {
        strcat((char *)calcDisplay, ".");

        div = CALC_SCALE / 10;
        ix = 0;
        while (div > 0)
        {
            fracTxt[ix++] = (unsigned char)('0' + (frac / div));
            frac = frac % div;
            div /= 10;
        }
        fracTxt[ix] = 0;

        while (ix > 0 && fracTxt[ix - 1] == '0')
        {
            fracTxt[ix - 1] = 0;
            ix--;
        }

        strcat((char *)calcDisplay, (char *)fracTxt);
    }
}

static void calcShowError(void)
{
    strcpy((char *)calcDisplay, "Error");
    calcError = 1;
    calcStartNew = 1;
    calcPendingOp = 0;
    calcHasAcc = 0;
}

static unsigned char calcApply(long rhs)
{
    long long tmp;

    if (!calcHasAcc)
    {
        calcAcc = rhs;
        calcHasAcc = 1;
        return 1;
    }

    if (calcPendingOp == '+')
        calcAcc += rhs;
    else if (calcPendingOp == '-')
        calcAcc -= rhs;
    else if (calcPendingOp == '*')
    {
        tmp = (long long)calcAcc * (long long)rhs;
        calcAcc = (long)(tmp / CALC_SCALE);
    }
    else if (calcPendingOp == '/')
    {
        if (rhs == 0)
        {
            calcShowError();
            return 0;
        }
        tmp = (long long)calcAcc * (long long)CALC_SCALE;
        calcAcc = (long)(tmp / rhs);
    }
    else
        calcAcc = rhs;

    return 1;
}

static void calcAppendDigit(unsigned char d)
{
    unsigned short len;

    if (calcError)
        calcReset();

    if (calcStartNew)
    {
        strcpy((char *)calcDisplay, "0");
        calcStartNew = 0;
    }

    len = (unsigned short)strlen((char *)calcDisplay);
    if (len >= sizeof(calcDisplay) - 1)
        return;

    if (!strcmp((char *)calcDisplay, "0"))
    {
        calcDisplay[0] = d;
        calcDisplay[1] = 0;
        return;
    }

    if (!strcmp((char *)calcDisplay, "-0"))
    {
        calcDisplay[1] = d;
        calcDisplay[2] = 0;
        return;
    }

    calcDisplay[len] = d;
    calcDisplay[len + 1] = 0;
}

static void calcAppendDot(void)
{
    unsigned short len;
    unsigned char ix;

    if (calcError)
        calcReset();

    if (calcStartNew)
    {
        strcpy((char *)calcDisplay, "0");
        calcStartNew = 0;
    }

    ix = 0;
    while (calcDisplay[ix])
    {
        if (calcDisplay[ix] == '.')
            return;
        ix++;
    }

    len = (unsigned short)strlen((char *)calcDisplay);
    if (len >= sizeof(calcDisplay) - 1)
        return;

    calcDisplay[len] = '.';
    calcDisplay[len + 1] = 0;
}

static void calcBackspace(void)
{
    unsigned short len;

    if (calcError || calcStartNew)
    {
        calcReset();
        return;
    }

    len = (unsigned short)strlen((char *)calcDisplay);
    if (len <= 1 || (len == 2 && calcDisplay[0] == '-'))
    {
        strcpy((char *)calcDisplay, "0");
        calcStartNew = 1;
        return;
    }

    calcDisplay[len - 1] = 0;
}

static void calcNegate(void)
{
    unsigned char tmp[24];

    if (calcError)
        return;

    if (!strcmp((char *)calcDisplay, "0"))
        return;

    if (calcDisplay[0] == '-')
    {
        strcpy((char *)tmp, (char *)(calcDisplay + 1));
        strcpy((char *)calcDisplay, (char *)tmp);
    }
    else
    {
        strcpy((char *)tmp, (char *)calcDisplay);
        strcpy((char *)calcDisplay, "-");
        strcat((char *)calcDisplay, (char *)tmp);
    }
}

static void calcOperator(unsigned char op)
{
    long rhs;

    if (calcError)
        return;

    if (calcHasAcc && calcStartNew && calcPendingOp)
    {
        calcPendingOp = op;
        return;
    }

    rhs = calcParseDisplay();
    if (!calcApply(rhs))
        return;

    calcFixedToDisplay(calcAcc);
    calcPendingOp = op;
    calcStartNew = 1;
}

static void calcEquals(void)
{
    long rhs;

    if (calcError)
        return;

    rhs = calcParseDisplay();
    if (!calcApply(rhs))
        return;

    calcFixedToDisplay(calcAcc);
    calcPendingOp = 0;
    calcStartNew = 1;
}

static void calcHandle(unsigned char code)
{
    if (code >= '0' && code <= '9')
    {
        calcAppendDigit(code);
        return;
    }

    if (code == '.' || code == ',')
    {
        calcAppendDot();
        return;
    }

    if (code == '+' || code == '-' || code == '*' || code == '/')
    {
        calcOperator(code);
        return;
    }

    if (code == '=' || code == 0x0D)
    {
        calcEquals();
        return;
    }

    if (code == 'C' || code == 'c')
    {
        calcReset();
        return;
    }

    if (code == 'E' || code == 'e')
    {
        strcpy((char *)calcDisplay, "0");
        calcStartNew = 1;
        calcError = 0;
        return;
    }

    if (code == '<' || code == 0x08)
    {
        calcBackspace();
        return;
    }

    if (code == 'N' || code == 'n')
        calcNegate();
}

static void calcDrawDisplay(void)
{
    unsigned short len;
    unsigned short tx;

    FillRect(CALC_DISP_X, CALC_DISP_Y, CALC_DISP_W, CALC_DISP_H, calcBg);
    DrawRect(CALC_DISP_X, CALC_DISP_Y, CALC_DISP_W, CALC_DISP_H, calcFg);

    len = (unsigned short)strlen((char *)calcDisplay);
    if (len > 20)
        len = 20;

    tx = (unsigned short)(CALC_DISP_X + CALC_DISP_W - 6 - (len * 6));
    writesxy(tx, (unsigned short)(CALC_DISP_Y + 5), 1, calcDisplay, calcFg, calcBg);
}

static void calcDrawButton(CALC_BUTTON *b)
{
    unsigned short len;
    unsigned short tx;

    FillRect((unsigned char)b->x, (unsigned char)b->y, b->w, (unsigned char)b->h, calcBg);
    DrawRoundRect(b->x, b->y, b->w, b->h, 1, calcFg);

    len = (unsigned short)strlen((char *)b->label);
    tx = (unsigned short)(b->x + (b->w / 2) - ((len * 6) / 2));
    writesxy(tx, (unsigned short)(b->y + 4), 1, b->label, calcFg, calcBg);
}

static void calcDrawAll(void)
{
    unsigned char i;

    showWindow("Calculator\0", CALC_X, CALC_Y, CALC_W, CALC_H, BTCLOSE);
    calcDrawDisplay();

    for (i = 0; i < sizeof(calcButtons) / sizeof(calcButtons[0]); i++)
        calcDrawButton(&calcButtons[i]);
}

static unsigned char calcHitButton(unsigned short mx, unsigned short my)
{
    unsigned char i;
    CALC_BUTTON *b;

    for (i = 0; i < sizeof(calcButtons) / sizeof(calcButtons[0]); i++)
    {
        b = &calcButtons[i];
        if (mx >= b->x && mx <= (b->x + b->w) &&
            my >= b->y && my <= (b->y + b->h))
            return b->code;
    }

    return 0;
}

static unsigned char calcHandleMouse(void)
{
    MGUI_MOUSE m;
    unsigned char code;

    getMouseData(0, &m);
    getMouseData(1, &m);

    if (m.mouseButton == 0x01 && calcMousePrev != 0x01)
    {
        if (m.vpostx >= (CALC_X + CALC_W - 13) && m.vpostx <= (CALC_X + CALC_W - 3) &&
            m.vposty >= (CALC_Y + 2) && m.vposty <= (CALC_Y + 12))
            return 2;

        code = calcHitButton(m.vpostx, m.vposty);
        if (code)
        {
            if (code == 'Q')
                return 2;

            calcHandle(code);
            return 1;
        }
    }

    calcMousePrev = m.mouseButton;
    return 0;
}

static unsigned char calcHandleKeyboard(void)
{
    unsigned int keyRaw;
    unsigned char code;
    unsigned char flags;

    keyRaw = (unsigned int)mguiListWindows[6].keyTec;
    if (keyRaw == 0)
        return 0;

    mguiListWindows[6].keyTec = 0;
    code = (unsigned char)(keyRaw & 0xFF);
    flags = (unsigned char)((keyRaw >> 8) & 0xFF);

    if (flags == KEY_CTRL_ALT && (code == 'X' || code == 'x'))
        return 2;

    calcHandle(code);
    return 1;
}

void main(void)
{
    MGUI_SAVESCR save;
    VDP_COLOR color;
    unsigned char running;
    unsigned char ret;

    if (*startBasic != 2)
        return;

    TrocaSpriteMouse(MOUSE_POINTER);

    getColorData(&color);
    calcFg = color.fg;
    calcBg = color.bg;
    if (calcFg == calcBg)
        calcFg = VDP_WHITE;

    calcLayoutButtons();
    calcReset();
    calcMousePrev = 0;

    SaveScreenNew(&save, CALC_X, CALC_Y, CALC_W, CALC_H);
    calcDrawAll();

    running = 1;
    while (running)
    {
        ret = calcHandleMouse();
        if (ret == 2)
            running = 0;
        else if (ret == 1)
            calcDrawDisplay();

        ret = calcHandleKeyboard();
        if (ret == 2)
            running = 0;
        else if (ret == 1)
            calcDrawDisplay();
    }

    RestoreScreen(&save);
}
