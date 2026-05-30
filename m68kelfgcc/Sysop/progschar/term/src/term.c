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

static void termDiscardPendingSerial(void)
{
    serRxTail = serRxHead;
    serRxLost = 0;
    telPushValid = 0;
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
            printChar(termBuf[y][viewX + x], 0);
        }
    }

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
    printChar(termBuf[y][x], 0);
}

static void termScroll(void)
{
    unsigned char y;
    unsigned char x;

    for (y = 0; y < TERM_ROWS - 1; y++)
    {
        for (x = 0; x < TERM_COLS; x++)
            termBuf[y][x] = termBuf[y + 1][x];
    }

    for (x = 0; x < TERM_COLS; x++)
        termBuf[TERM_ROWS - 1][x] = ' ';

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
        for (x = 0; x < TERM_COLS; x++)
            termBuf[y][x] = ' ';

    curX = 0;
    curY = 0;
    viewX = 0;

    termRender();
}

static void termClearLine(char y)
{
    unsigned char x;

    for (x = 0; x < TERM_COLS; x++)
        termBuf[y][x] = ' ';

    curX = 0;
    curY = y;

    vdp_set_cursor(0, y);
    for (x = 0; x < VIEW_COLS; x++)
    {
        vdp_set_cursor(x, y);
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

static void telnetSkipSubneg(void)
{
    unsigned char c;
    unsigned char last;

    last = 0;

    while (1)
    {
        while (!serialBufGet(&c));

        if (last == TEL_IAC && c == TEL_SE)
            return;

        last = c;
    }
}

static void handleTelnet(unsigned char cmd)
{
    unsigned char opt;

    switch (cmd)
    {
        case 0xFB: /* WILL */
            if (!termReadSerial(&opt))
                return;

            if (opt == 0xFF)
            {
                termUnreadSerial(opt);
                return;
            }

            telnetSend3(0xFF, 0xFE, opt); /* DONT */
            break;

        case 0xFD: /* DO */
            if (!termReadSerial(&opt))
                return;

            if (opt == 0xFF)
            {
                termUnreadSerial(opt);
                return;
            }

            telnetSend3(0xFF, 0xFC, opt); /* WONT */
            break;

        case 0xFC: /* WONT */
        case 0xFE: /* DONT */
            if (!termReadSerial(&opt))
                return;

            if (opt == 0xFF)
                termUnreadSerial(opt);

            break;

        case 0xFA: /* SB */
            telnetSkipSubneg();
            break;

        case 0xFF:
            termPutChar(0xFF);
            break;

        default:
            break;
    }
}

static void termSendCursorReport(void)
{
    char buf[20];

    /* ANSI usa base 1, não base 0 */
    writeLongSerial("\x1B[24;80R");
    //msprintf(buf, "\x1B[%d;%dR", curY + 1, curX + 1);
    //writeLongSerial(buf);
}

static void handleEscSeq(void)
{
    unsigned char c;
    char parm[16];
    int ix;

    while (!serialBufGet(&c));

    if (c == 's')
    {
        savedX = curX;
        savedY = curY;
        return;
    }

    if (c == 'u')
    {
        termSetCursor(savedX, savedY);
        return;
    }

    if (c != '[')
        return;

    ix = 0;

    while (1)
    {
        while (!serialBufGet(&c));

        if ((c >= '0' && c <= '9') ||
             c == ';' || c == '!' ||
             c == '?' || c == '>')
        {
            if (ix < 15)
                parm[ix++] = c;
        }
        else
        {
            parm[ix] = 0;

            switch (c)
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
                    writeLongSerial("\x1B[?1;2c");
                    //writeLongSerial("\x1B[?6c");
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
                    /* por enquanto ignora */
                    break;
                case '_':
                    /* ESC[!_ aparece na BBS; pode ignorar */
                    break;
                default:
                    break;
            }

            return;
        }
    }
}

//-----------------------------------------------------------------------------
static unsigned char serialReadByteTimeout(unsigned char *pByte, unsigned long pTimeoutSpin)
{
    while (pTimeoutSpin)
    {
        if (readChar() == 0x1B)  // ESC
            return 0;

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
                if (c == 0xFF)
                {
                    if (termReadSerial(&c))
                        handleTelnet(c);
                }
                else if (c == 0x1B)
                {
                    handleEscSeq();
                }
                else
                {
                    termPutChar(c);
                }
            }

            c = readChar();

            if (c != 0)
            {
                if (c == 0x1B)
                {
                    writeLongSerial("+++");
                    writeSerial('\r');
                    break;
                }
                else if (c == KEY_RIGHT)
                {
                    viewX = 40;
                    termRender();
                    continue;
                }
                else if (c == KEY_LEFT)
                {
                    viewX = 0;
                    termRender();
                    continue;
                }

                writeSerial(c);
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
