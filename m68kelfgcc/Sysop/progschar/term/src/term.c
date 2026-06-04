/* sheet.c - fonte consolidado */

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"

#include "term.h"

static int ansiGetNum(char *s, int def)
{
    if (*s == 0)
        return def;

    return atoi(s);
}

static void ansiGet2(char *s, int *a, int *b)
{
    char *p;

    *a = 1;
    *b = 1;

    if (*s == 0)
        return;

    p = strchr(s, ';');

    if (p)
    {
        *p = 0;
        *a = atoi(s);
        *b = atoi(p + 1);
    }
    else
    {
        *a = atoi(s);
    }

    if (*a <= 0) *a = 1;
    if (*b <= 0) *b = 1;
}

/*void serialRxHook(void)
{
    unsigned char c;
    unsigned int next;
    unsigned char *vAddrLog = 0x88000A;

    c = *(vmfp + Reg_UDR);

    next = serRxHead + 1;
    if (next >= SER_RX_SIZE)
        next = 0;

    if (next == serRxTail)
    {
        serRxLost++;
        return;
    }

    serRxBuf[serRxHead] = c;
    serRxHead = next;
}*/

int serialBufGet(unsigned char *c)
{
    if (serRxHead == serRxTail)
        return 0;

    *c = serRxBuf[serRxTail];
  
    serRxTail++;
    if (serRxTail >= SER_RX_SIZE)
        serRxTail = 0;

    return 1;
}

static unsigned char serialReadByte(unsigned char *pByte)
{
    return serialBufGet(pByte);
}

static unsigned char termReadSerial(unsigned char *c)
{
    if (telPushValid)
    {
        *c = telPushByte;
        telPushValid = 0;
        return 1;
    }

    return serialBufGet(c);
}

static void termUnreadSerial(unsigned char c)
{
    telPushByte = c;
    telPushValid = 1;
}

static unsigned char termWaitSerial(unsigned char *c, unsigned long timeoutSpin)
{
    while (timeoutSpin)
    {
        if (termReadSerial(c))
            return 1;

        timeoutSpin--;
    }

    return 0;
}

static void termDiscardPendingSerial(void)
{
    serRxTail = serRxHead;
    serRxLost = 0;
    telPushValid = 0;
}

static unsigned char termMakeColor(unsigned char fg, unsigned char bg)
{
    return (unsigned char)(((fg & 0x0F) << 4) | (bg & 0x0F));
}

static void termSetColor(unsigned char fg, unsigned char bg)
{
    termFg = fg & 0x0F;
    termBg = bg & 0x0F;
    termColor = termMakeColor(termFg, termBg);
}

static void termApplyColor(unsigned char color)
{
    (void)color;
}

static unsigned char termAnsiColor(int n)
{
    switch (n)
    {
        case 0: return VDP_BLACK;
        case 1: return VDP_DARK_RED;
        case 2: return VDP_DARK_GREEN;
        case 3: return VDP_DARK_YELLOW;
        case 4: return VDP_DARK_BLUE;
        case 5: return VDP_MAGENTA;
        case 6: return VDP_CYAN;
        case 7: return VDP_WHITE;
    }

    return VDP_WHITE;
}

static unsigned char termAnsiBrightColor(int n)
{
    switch (n)
    {
        case 0: return VDP_GRAY;
        case 1: return VDP_LIGHT_RED;
        case 2: return VDP_LIGHT_GREEN;
        case 3: return VDP_LIGHT_YELLOW;
        case 4: return VDP_LIGHT_BLUE;
        case 5: return VDP_MAGENTA;
        case 6: return VDP_CYAN;
        case 7: return VDP_WHITE;
    }

    return VDP_WHITE;
}

static void termHandleSgr(char *parm)
{
    char *p;
    int n;
    int first;
    int directFg;
    int directBg;

    if (*parm == 0)
    {
        termSetColor(VDP_WHITE, VDP_BLACK);
        return;
    }

    p = parm;
    first = 1;
    directFg = -1;
    directBg = -1;

    while (1)
    {
        n = atoi(p);

        if (n == 0)
            termSetColor(VDP_WHITE, VDP_BLACK);
        else if (n >= 30 && n <= 37)
            termSetColor(termAnsiColor(n - 30), termBg);
        else if (n >= 40 && n <= 47)
            termSetColor(termFg, termAnsiColor(n - 40));
        else if (n >= 90 && n <= 97)
            termSetColor(termAnsiBrightColor(n - 90), termBg);
        else if (n >= 100 && n <= 107)
            termSetColor(termFg, termAnsiBrightColor(n - 100));
        else if (n >= 1 && n <= 15)
        {
            if (first)
                directFg = n;
            else
                directBg = n;
        }

        first = 0;
        p = strchr(p, ';');
        if (!p)
            break;
        p++;
    }

    if (directFg >= 0)
    {
        if (directBg >= 0)
            termSetColor((unsigned char)directFg, (unsigned char)directBg);
        else
            termSetColor((unsigned char)directFg, termBg);
    }
}

static void termRender(void)
{
    unsigned char y;
    unsigned char x;

    vdp_set_cursor(0, 0);

    for (y = 0; y < TERM_ROWS; y++)
    {
        vdp_set_cursor(0, y);

        for (x = 0; x < VIEW_COLS; x++)
        {
            vdp_set_cursor(x, y);
            termApplyColor(termColorBuf[y][viewX + x]);
            printChar(termBuf[y][viewX + x], 0);
        }
    }

    termApplyColor(termColor);
    if (curX >= viewX && curX < viewX + VIEW_COLS)
        vdp_set_cursor(curX - viewX, curY);
}

static unsigned char termIsVisible(unsigned char x)
{
    if (x < viewX)
        return 0;

    if (x >= viewX + VIEW_COLS)
        return 0;

    return 1;
}

static void termSetVideoCursor(void)
{
    if (termIsVisible(curX))
        vdp_set_cursor(curX - viewX, curY);
}

static void termDrawChar(unsigned char x, unsigned char y)
{
    if (!termIsVisible(x))
        return;

    vdp_set_cursor(x - viewX, y);
    termApplyColor(termColorBuf[y][x]);
    printChar(termBuf[y][x], 0);
    termApplyColor(termColor);
}

static void termScroll(void)
{
    unsigned char y;
    unsigned char x;

    for (y = 0; y < TERM_ROWS - 1; y++)
    {
        for (x = 0; x < TERM_COLS; x++)
        {
            termBuf[y][x] = termBuf[y + 1][x];
            termColorBuf[y][x] = termColorBuf[y + 1][x];
        }
    }

    for (x = 0; x < TERM_COLS; x++)
    {
        termBuf[TERM_ROWS - 1][x] = ' ';
        termColorBuf[TERM_ROWS - 1][x] = termColor;
    }

    curY = TERM_ROWS - 1;
    termRender();
}

static void termPutChar(unsigned char c)
{
    unsigned char oldX;

    if (c == '\r')
    {
        curX = 0;
        termSetVideoCursor();
        return;
    }

    if (c == '\n')
    {
        if (curY < TERM_ROWS - 1)
            curY++;
        else
            termScroll();

        termSetVideoCursor();
        return;
    }

    if (c == 8)
    {
        if (curX > 0)
            curX--;
        termSetVideoCursor();
        return;
    }

    if (c >= 32)
    {
        oldX = curX;
        termBuf[curY][oldX] = c;
        termColorBuf[curY][oldX] = termColor;
        termDrawChar(oldX, curY);

        if (curX < TERM_COLS - 1)
            curX++;

        termSetVideoCursor();
    }
}

static void termClear(void)
{
    unsigned char y;
    unsigned char x;

    for (y = 0; y < TERM_ROWS; y++)
    {
        for (x = 0; x < TERM_COLS; x++)
        {
            termBuf[y][x] = ' ';
            termColorBuf[y][x] = termColor;
        }
    }

    curX = 0;
    curY = 0;
    viewX = 0;

    termRender();
}

static void termClearLine(char y)
{
    unsigned char x;

    for (x = 0; x < TERM_COLS; x++)
    {
        termBuf[y][x] = ' ';
        termColorBuf[y][x] = termColor;
    }

    curX = 0;
    curY = y;

    vdp_set_cursor(0, y);
    for (x = 0; x < VIEW_COLS; x++)
    {
        vdp_set_cursor(x, y);
        termApplyColor(termColor);
        printChar(' ', 0);
    }

    termSetVideoCursor();
}

static void termSetCursor(unsigned char x, unsigned char y)
{
    if (x >= TERM_COLS)
        x = TERM_COLS - 1;

    if (y >= TERM_ROWS)
        y = TERM_ROWS - 1;

    curX = x;
    curY = y;

    termSetVideoCursor();
}

static void telnetSend3(unsigned char a, unsigned char b, unsigned char c)
{
    writeSerial(a);
    writeSerial(b);
    writeSerial(c);
}

static void telnetSendTerminalType(void)
{
    writeSerial(TEL_IAC);
    writeSerial(TEL_SB);
    writeSerial(TEL_OPT_TTYPE);
    writeSerial(TEL_TTYPE_IS);
    writeLongSerial("ANSI");
    writeSerial(TEL_IAC);
    writeSerial(TEL_SE);
}

static void telnetSendNaws(void)
{
    writeSerial(TEL_IAC);
    writeSerial(TEL_SB);
    writeSerial(TEL_OPT_NAWS);
    writeSerial(0);
    writeSerial(80);
    writeSerial(0);
    writeSerial(24);
    writeSerial(TEL_IAC);
    writeSerial(TEL_SE);
}

static void telnetHandleOption(unsigned char cmd, unsigned char opt)
{
    switch (cmd)
    {
        case TEL_WILL:
            if (opt == TEL_OPT_ECHO || opt == TEL_OPT_SGA || opt == TEL_OPT_BINARY)
                telnetSend3(TEL_IAC, TEL_DO, opt);
            else
                telnetSend3(TEL_IAC, TEL_DONT, opt);
            break;

        case TEL_DO:
            if (opt == TEL_OPT_TTYPE || opt == TEL_OPT_SGA || opt == TEL_OPT_BINARY)
            {
                telnetSend3(TEL_IAC, TEL_WILL, opt);
            }
            else if (opt == TEL_OPT_NAWS)
            {
                telnetSend3(TEL_IAC, TEL_WILL, opt);
                telnetSendNaws();
            }
            else
            {
                telnetSend3(TEL_IAC, TEL_WONT, opt);
            }
            break;

        case TEL_WONT:
        case TEL_DONT:
            break;
    }
}

static unsigned char termAppendDec(char *buf, unsigned char ix, unsigned int value)
{
    char tmp[6];
    unsigned char n;

    n = 0;
    if (value == 0)
    {
        buf[ix++] = '0';
        return ix;
    }

    while (value && n < sizeof(tmp))
    {
        tmp[n++] = (char)('0' + (value % 10));
        value /= 10;
    }

    while (n)
        buf[ix++] = tmp[--n];

    return ix;
}

static void termSendCursorReport(void)
{
    char buf[20];
    unsigned char ix;

    /* ANSI usa base 1, não base 0 */
    ix = 0;
    buf[ix++] = 0x1B;
    buf[ix++] = '[';
    ix = termAppendDec(buf, ix, (unsigned int)curY + 1);
    buf[ix++] = ';';
    ix = termAppendDec(buf, ix, (unsigned int)curX + 1);
    buf[ix++] = 'R';
    buf[ix] = 0;

    writeLongSerial(buf);
}

static void termHandleCsi(unsigned char final, char *parm)
{
    switch (final)
    {
        case 'H': /* cursor position */
        case 'f':
        {
            int row, col;
            ansiGet2(parm, &row, &col);
            termSetCursor((unsigned char)(col - 1), (unsigned char)(row - 1));
            break;
        }
        case 'J': /* clear screen */
            if (!strcmp(parm, "2") || parm[0] == 0)
                termClear();
            break;
        case 'n':
            if (!strcmp(parm, "6"))
                termSendCursorReport();
            break;
        case 'c':
            /* ESC[0c - identify terminal */
            writeLongSerial("\x1B[?6c");
            break;
        case 'K': /* clear line */
            termClearLine(curY);
            break;
        case 'A': /* cursor up */
            {
                int n = ansiGetNum(parm, 1);
                while (n-- && curY > 0) curY--;
                termSetVideoCursor();
                break;
            }
        case 'B': /* cursor down */
            {
                int n = ansiGetNum(parm, 1);
                while (n-- && curY < TERM_ROWS - 1) curY++;
                termSetVideoCursor();
                break;
            }
        case 'C': /* cursor right */
            {
                int n = ansiGetNum(parm, 1);
                while (n-- && curX < TERM_COLS - 1) curX++;
                termSetVideoCursor();
                break;
            }
        case 'D': /* cursor left */
            {
                int n = ansiGetNum(parm, 1);
                while (n-- && curX > 0) curX--;
                termSetVideoCursor();
                break;
            }
        case 'm': /* atributos/cor ANSI */
            termHandleSgr(parm);
            break;
        case 's':
            savedX = curX;
            savedY = curY;
            break;
        case 'u':
            termSetCursor(savedX, savedY);
            break;
        default:
            break;
    }
}

static void termEscReset(void)
{
    termEscState = TERM_ESC_NORMAL;
    termEscLen = 0;
    termEscBuf[0] = 0;
}

static void termEscAdd(unsigned char c)
{
    if (termEscLen < sizeof(termEscBuf) - 1)
    {
        termEscBuf[termEscLen++] = c;
        termEscBuf[termEscLen] = 0;
    }
}

static void termProcessByte(unsigned char c)
{
    switch (termTelState)
    {
        case TERM_TEL_NORMAL:
            if (c == TEL_IAC)
            {
                termTelState = TERM_TEL_IAC;
                return;
            }
            break;

        case TERM_TEL_IAC:
            if (c == TEL_IAC)
            {
                termTelState = TERM_TEL_NORMAL;
                termPutChar(TEL_IAC);
                return;
            }

            if (c == TEL_WILL || c == TEL_WONT || c == TEL_DO || c == TEL_DONT)
            {
                termTelCmd = c;
                termTelState = TERM_TEL_CMD;
                return;
            }

            if (c == TEL_SB)
            {
                termTelState = TERM_TEL_SB_OPT;
                return;
            }

            termTelState = TERM_TEL_NORMAL;
            return;

        case TERM_TEL_CMD:
            telnetHandleOption(termTelCmd, c);
            termTelState = TERM_TEL_NORMAL;
            return;

        case TERM_TEL_SB_OPT:
            termTelSbOpt = c;
            termTelSbFirst = 1;
            termTelTTypeSend = 0;
            termTelState = TERM_TEL_SB;
            return;

        case TERM_TEL_SB:
            if (c == TEL_IAC)
            {
                termTelState = TERM_TEL_SB_IAC;
                return;
            }

            if (termTelSbOpt == TEL_OPT_TTYPE && termTelSbFirst)
            {
                termTelSbFirst = 0;
                if (c == TEL_TTYPE_SEND)
                    termTelTTypeSend = 1;
            }
            return;

        case TERM_TEL_SB_IAC:
            if (c == TEL_SE)
            {
                termTelState = TERM_TEL_NORMAL;
                if (termTelTTypeSend)
                {
                    termTelTTypeSend = 0;
                    telnetSendTerminalType();
                }
            }
            else if (c == TEL_IAC)
            {
                termTelState = TERM_TEL_SB;
            }
            else
            {
                termTelState = TERM_TEL_SB;
            }
            return;
    }

    if (termUtf8BomState == 0)
    {
        if (c == 0xEF)
        {
            termUtf8BomState = 1;
            return;
        }
    }
    else if (termUtf8BomState == 1)
    {
        if (c == 0xBB)
        {
            termUtf8BomState = 2;
            return;
        }
        termUtf8BomState = 0;
    }
    else
    {
        termUtf8BomState = 0;
        if (c == 0xBF)
        {
            termPutChar(' ');
            termPutChar(' ');
            termPutChar(' ');
            return;
        }
    }

    if (c >= 0x80 && c <= 0x9F)
        return;

    switch (termEscState)
    {
        case TERM_ESC_NORMAL:
            if (c == 0x1B)
            {
                termEscState = TERM_ESC_ESC;
                termEscLen = 0;
                termEscBuf[0] = 0;
            }
            else if (c == '[')
            {
                termEscState = TERM_ESC_BARE;
                termEscLen = 0;
                termEscBuf[0] = 0;
            }
            else
            {
                termPutChar(c);
            }
            break;

        case TERM_ESC_ESC:
            if (c == '[')
            {
                termEscState = TERM_ESC_CSI;
                termEscLen = 0;
                termEscBuf[0] = 0;
            }
            else if (c == ']')
            {
                termEscState = TERM_ESC_OSC;
            }
            else if (c == 's')
            {
                savedX = curX;
                savedY = curY;
                termEscReset();
            }
            else if (c == 'u')
            {
                termSetCursor(savedX, savedY);
                termEscReset();
            }
            else if (c == '7')
            {
                savedX = curX;
                savedY = curY;
                termEscReset();
            }
            else if (c == '8')
            {
                termSetCursor(savedX, savedY);
                termEscReset();
            }
            else if (c == '(' || c == ')' || c == '*' || c == '+' || c == '#')
            {
                termEscState = TERM_ESC_IGNORE;
            }
            else
            {
                termEscReset();
            }
            break;

        case TERM_ESC_CSI:
            if (c >= 0x40 && c <= 0x7E)
            {
                termHandleCsi(c, termEscBuf);
                termEscReset();
            }
            else if (c >= 0x20 && c <= 0x3F)
            {
                termEscAdd(c);
            }
            else
            {
                termEscReset();
            }
            break;

        case TERM_ESC_OSC:
            if (c == 0x07)
                termEscReset();
            else if (c == 0x1B)
                termEscState = TERM_ESC_IGNORE;
            break;

        case TERM_ESC_IGNORE:
            termEscReset();
            break;

        case TERM_ESC_BARE:
            if ((c >= '0' && c <= '9') || c == ';' || c == '?' || c == '!')
            {
                termEscState = TERM_ESC_CSI;
                termEscAdd(c);
            }
            else
            {
                termEscReset();
                termPutChar('[');
                termPutChar(c);
            }
            break;
    }
}

//-----------------------------------------------------------------------------
static unsigned char serialReadByteTimeout(unsigned char *pByte, unsigned long pTimeoutSpin)
{
    while (pTimeoutSpin)
    {
        if (termReadSerial(pByte))
            return 1;

        pTimeoutSpin--;
    }

    return 0;
}

static void readResponse(void)
{
    unsigned char c;
    unsigned long idleTimeout;
    unsigned long charTimeout;

    idleTimeout = 800000L;   /* espera primeira resposta */

    while (1)
    {
        if (serialReadByteTimeout(&c, idleTimeout))
            break;

        mprintf("Timeout aguardando resposta.\r\n");
        return;
    }

    while (1)
    {
        termPutChar(c);

        charTimeout = 120000L;   /* timeout entre chars */

        if (!serialReadByteTimeout(&c, charTimeout))
            break;
        
        if (c == 0x04)
            break;
    }
}

static unsigned char termHandleKeyboard(void)
{
    MMSJ_KEYEVENT k;
    unsigned char c;

    if (!mmsjKeyGet(&k))
        return 0;

    if (k.flags == KEY_CTRL_ALT && k.code == 'X')
        return 1;

    if (termCtrlK)
    {
        termCtrlK = 0;
        if (k.code == 'X' || k.ascii == 'x' || k.ascii == 'X')
            return 1;

        writeSerial(0x0B);
    }

    if (k.flags & KEY_CTRL)
    {
        if (k.code == 'K')
        {
            termCtrlK = 1;
            return 0;
        }

        if (k.code >= 'A' && k.code <= 'Z')
        {
            writeSerial((unsigned char)(k.code - 'A' + 1));
            return 0;
        }
    }

    if (k.flags == KEY_NONE)
        c = k.ascii;
    else
        c = k.ascii;

    if (c == 0)
        return 0;

    if (c == KEY_RIGHT)
    {
        viewX = 40;
        termRender();
        return 0;
    }

    if (c == KEY_LEFT)
    {
        viewX = 0;
        termRender();
        return 0;
    }

    writeSerial(c);
    return 0;
}

/*void installHook(int hookNum, void (*func)(void))
{
    hookTable[hookNum].addr  = func;
    hookTable[hookNum].flags = HOOKF_ACTIVE | HOOKF_SKIP_OS;
    hookTable[hookNum].magic = HOOK_MAGIC;
}*/

/* -------------------------------------------------- */
/* MAIN                                               */
/* -------------------------------------------------- */
int main(void)
{
    unsigned int ix;
    unsigned char c;

    if (*paramBasic != 0x00)
    {
        //tstIntsOff();

        // Remover o primeiro caracter de paramBasic, e mover tudo pra esquerda 1 caracter
        ix = 0;
        while (paramBasic[ix] != 0x00)
        {
            paramBasic[ix] = paramBasic[ix + 1];
            ix++;
        }

        termDiscardPendingSerial();
        termSetColor(VDP_WHITE, VDP_BLACK);

        // Limpa Tela
        termClear();

        // Envia comando pra conectar no site/bbs
        writeLongSerial("ATTCP=");
        writeLongSerial(paramBasic);
        writeSerial('\r');

        readResponse();

        while (1)
        {
            if (termReadSerial(&c))
            {
                termProcessByte(c);
            }

            if (termHandleKeyboard())
            {
                writeLongSerial("+++");
                writeSerial('\r');

                /* espera e descarta OK;DISCONNECT */
                termWaitSerial(&c, 800000L);
                termDiscardPendingSerial();

                break;
            }
        }   

        //tstIntsOn();
    }
    else
    {
        mprintf("Usage: TERM <destino>[:port]\r\n");
        mprintf("  Ex: TERM bbs.utilityinf.com.br:6522\r\n");
        mprintf("      :port = default 23 if not used");
    }

    return 0;
}
