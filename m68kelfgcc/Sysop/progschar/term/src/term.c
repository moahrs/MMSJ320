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
#include "netcomm_runtime.h"

#include "term.h"

typedef int (*termSetFontUseG2Type)(unsigned char vpos);
#define termSetFontUseG2 ((termSetFontUseG2Type *)(unsigned long)MMSJOS_FUNC_TABLE)[33]
#define TERM_VDP_DATA (*(volatile unsigned char *)0x00400041)

static void termWriteG2CharAt(unsigned char col, unsigned char row, unsigned char chr, unsigned char color);

static void termDiscardPendingKeys(void)
{
    MMSJ_KEYEVENT k;

    while (mmsjKeyGet(&k))
    {
    }
}

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
    if (!p)
        p = strchr(s, ',');

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
    setColorVideoG2((unsigned char)((color >> 4) & 0x0F), (unsigned char)(color & 0x0F));
}

static void termLocate(unsigned char col, unsigned char row)
{
    vdp_set_cursor((unsigned char)(col * termFontW), (unsigned char)(row * termFontH));
}

static void termFillCellRect(unsigned char col, unsigned char row, unsigned char cols, unsigned char rows, unsigned char color)
{
    FillRect((unsigned char)(col * termFontW),
             (unsigned char)(row * termFontH),
             (unsigned short)(cols * termFontW),
             (unsigned char)(rows * termFontH),
             (unsigned char)(color & 0x0F));
}

static void termWriteTextG2(unsigned char col, unsigned char row, char *text, unsigned char color)
{
    termLocate(col, row);
    termApplyColor(color);
    mprintf("%s", text);
}

static void termWriteCharG2(unsigned char col, unsigned char row, unsigned char c, unsigned char color)
{
    termCharBuf[0] = (char)c;
    termCharBuf[1] = 0;
    termWriteTextG2(col, row, termCharBuf, color);
}

static void termRenderLine(unsigned char y)
{
    unsigned char x;
    unsigned char srcX;
    unsigned char runStart;
    unsigned char runLen;
    unsigned char runColor;

    if (termUseFastG2)
    {
        for (x = 0; x < VIEW_COLS; x++)
            termWriteG2CharAt(x, y, termBuf[y][viewX + x], termColorBuf[y][viewX + x]);
        return;
    }

    termFillCellRect(0, y, VIEW_COLS, 1, termBg);

    x = 0;
    while (x < VIEW_COLS)
    {
        srcX = viewX + x;
        runColor = termColorBuf[y][srcX];
        runStart = x;
        runLen = 0;

        while (x < VIEW_COLS && runLen < VIEW_COLS)
        {
            srcX = viewX + x;
            if (termColorBuf[y][srcX] != runColor)
                break;

            termLineBuf[runLen++] = termBuf[y][srcX];
            x++;
        }

        termLineBuf[runLen] = 0;
        termWriteTextG2(runStart, y, termLineBuf, runColor);
    }
}

static void termFastClear(unsigned char color)
{
    /* Clear the complete 256x192 G2 screen using the tested MGUI routine. */
    clearScrW((unsigned char)(color & 0x0F));
}

static void termWriteG2CharAt(unsigned char col, unsigned char row, unsigned char chr, unsigned char color)
{
    unsigned short i;
    unsigned short glyphW;
    unsigned short glyphH;
    unsigned short firstCount;
    unsigned short secondCount;
    unsigned short srcIndex;
    unsigned short posX;
    unsigned short posY;
    unsigned short modX;
    unsigned short modY;
    unsigned short offset;
    unsigned short offset2;
    unsigned short charIndex;
    unsigned short px;
    unsigned short py;
    unsigned int firstMask;
    unsigned int secondMask;
    unsigned int src16;
    unsigned int shifted;
    unsigned int lineChar;
    unsigned char pixel;
    unsigned char pixel2;
    unsigned char colorByte;

    if (!termFontAddr)
    {
        termLocate(col, row);
        termApplyColor(color);
        printChar(chr, 0);
        termApplyColor(termColor);
        return;
    }

    glyphW = termFontW;
    glyphH = termFontH;
    if (glyphW == 0 || glyphW > 8)
        glyphW = 6;
    if (glyphH == 0 || glyphH > 8)
        glyphH = 8;

    if (chr < termFontFirst || chr > termFontLast)
        chr = ' ';

    charIndex = (unsigned short)(chr - termFontFirst);
    px = (unsigned short)(col * glyphW);
    py = (unsigned short)(row * glyphH);

    modX = (unsigned short)(px & 0x07);
    firstCount = (unsigned short)(8 - modX);
    if (firstCount > glyphW)
        firstCount = glyphW;
    secondCount = (unsigned short)(glyphW - firstCount);

    if (firstCount == 8)
        firstMask = 0xFF;
    else
        firstMask = (((1U << firstCount) - 1U) << (8 - modX - firstCount));

    if (secondCount == 0)
        secondMask = 0;
    else if (secondCount == 8)
        secondMask = 0xFF;
    else
        secondMask = (((1U << secondCount) - 1U) << (8 - secondCount));

    colorByte = (unsigned char)((color & 0x0F) | (color & 0xF0));

    for (i = 0; i < glyphH; i++)
    {
        srcIndex = (unsigned short)((charIndex << 3) + i);
        lineChar = *((unsigned char *)(termFontAddr + srcIndex));
        lineChar &= (0xFFU << (8 - glyphW));

        src16 = (lineChar << 8);
        shifted = (src16 >> modX);

        posX = (unsigned short)(8 * (px / 8));
        posY = (unsigned short)(256 * ((py + i) / 8));
        modY = (unsigned short)((py + i) % 8);
        offset = (unsigned short)(posX + modY + posY);

        setReadAddress(termPatternTable + offset);
        setReadAddress(termPatternTable + offset);
        pixel = TERM_VDP_DATA;

        pixel = (unsigned char)((pixel & (unsigned char)(~firstMask)) |
                               (((shifted >> 8) & 0xFFU) & firstMask));

        setWriteAddress(termPatternTable + offset);
        TERM_VDP_DATA = pixel;
        setWriteAddress(termColorTable + offset);
        TERM_VDP_DATA = colorByte;

        if (secondMask)
        {
            offset2 = (unsigned short)(offset + 8);

            setReadAddress(termPatternTable + offset2);
            setReadAddress(termPatternTable + offset2);
            pixel2 = TERM_VDP_DATA;

            pixel2 = (unsigned char)((pixel2 & (unsigned char)(~secondMask)) |
                                    ((shifted & 0xFFU) & secondMask));

            setWriteAddress(termPatternTable + offset2);
            TERM_VDP_DATA = pixel2;
            setWriteAddress(termColorTable + offset2);
            TERM_VDP_DATA = colorByte;
        }
    }
}

static void termInitVideoG2(void)
{
    MGUI_SET_FONT fontInfo;

    if (*startBasic == 1)
    {
        termOldVideoMode = getModeVideoOS();

        setModeVideoOS(VDP_MODE_G2);

        termFontLoadMem = (unsigned long *)msmalloc(4096);
        termFontSaveMem = (unsigned long *)msmalloc(4096);

        if (termFontLoadMem && termFontSaveMem)
            loadFontUseG2(0, "/MGUI/FONTS/EVE5X8.FON", (unsigned char *)termFontLoadMem, (unsigned char *)termFontSaveMem);

        if (!termSetFontUseG2(0))
            termSetFontUseG2(99);
    }
    else
        clearScrW(VDP_BLACK);

    termPatternTable = 0x0000;
    termColorTable = 0x2000;

    if (getFontUseG2(&fontInfo))
    {
        termFontFirst = fontInfo.fc;
        termFontLast = fontInfo.lc;
        termFontAddr = fontInfo.addr;
        if (fontInfo.w > 0 && fontInfo.w <= 8)
            termFontW = fontInfo.w;
        if (fontInfo.h > 0 && fontInfo.h <= 8)
            termFontH = fontInfo.h;
    }
    else
    {
        termFontFirst = 32;
        termFontLast = 255;
        termFontAddr = getVideoFontes();
        termFontW = 6;
        termFontH = 8;
    }

    setColorVideoG2(VDP_WHITE, VDP_BLACK);
}

static void termRestoreVideo(void)
{
    if (*startBasic == 1)
    {
        setColorVideoG2(VDP_WHITE, VDP_BLACK);
        setModeVideoOS(termOldVideoMode);

        if (termFontLoadMem)
        {
            msfree(termFontLoadMem);
            termFontLoadMem = 0;
        }

        if (termFontSaveMem)
        {
            msfree(termFontSaveMem);
            termFontSaveMem = 0;
        }
    }
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

    if (*parm == 0)
    {
        termBold = 0;
        termSetColor(VDP_WHITE, VDP_BLACK);
        return;
    }

    p = parm;

    while (1)
    {
        n = atoi(p);

        if (n == 0)
        {
            termBold = 0;
            termSetColor(VDP_WHITE, VDP_BLACK);
        }
        else if (n == 1)
        {
            termBold = 1;
        }
        else if (n == 22)
        {
            termBold = 0;
        }
        else if (n == 39)
        {
            termSetColor(VDP_WHITE, termBg);
        }
        else if (n == 49)
        {
            termSetColor(termFg, VDP_BLACK);
        }
        else if (n >= 30 && n <= 37)
        {
            if (termBold)
                termSetColor(termAnsiBrightColor(n - 30), termBg);
            else
                termSetColor(termAnsiColor(n - 30), termBg);
        }
        else if (n >= 40 && n <= 47)
        {
            termSetColor(termFg, termAnsiColor(n - 40));
        }
        else if (n >= 90 && n <= 97)
        {
            termSetColor(termAnsiBrightColor(n - 90), termBg);
        }
        else if (n >= 100 && n <= 107)
        {
            termSetColor(termFg, termAnsiBrightColor(n - 100));
        }
        else if (n == 7)
        {
            unsigned char fg;
            fg = termFg;
            termSetColor(termBg, fg);
        }

        p = strchr(p, ';');
        if (!p)
            break;
        p++;
    }
}

static void termRender(void)
{
    unsigned char y;

    termDrawBusy = 1;

    if (termUseFastG2)
        termFastClear(termBg);

    for (y = 0; y < TERM_ROWS; y++)
        termRenderLine(y);

    termApplyColor(termColor);
    if (curX >= viewX && curX < viewX + VIEW_COLS)
        termLocate(curX - viewX, curY);

    termDrawBusy = 0;
    termDiscardPendingKeys();
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
        termLocate(curX - viewX, curY);
}

static void termDrawChar(unsigned char x, unsigned char y)
{
    if (!termIsVisible(x))
        return;

    if (termUseFastG2)
    {
        termWriteG2CharAt(x - viewX, y, termBuf[y][x], termColorBuf[y][x]);
    }
    else
    {
        termWriteCharG2(x - viewX, y, termBuf[y][x], termColorBuf[y][x]);
    }
}

static void termScroll(void)
{
    unsigned char y;
    unsigned char x;
    unsigned short visibleWidth;
    unsigned short scrollPixels;
    MGUI_SAVESCR scrollSave;
    unsigned char savedOk;

    termDrawBusy = 1;
    savedOk = 0;

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

    visibleWidth = (unsigned short)(VIEW_COLS * termFontW);
    if (visibleWidth > 256)
        visibleWidth = 256;

    scrollPixels = (unsigned short)((TERM_ROWS - 1) * termFontH);
    if (visibleWidth > 0 && scrollPixels > 0)
    {
        scrollSave.pat = 0;
        scrollSave.cor = 0;
        scrollSave.size = 0;
        SaveScreenNew(&scrollSave,
                      0,
                      termFontH,
                      (unsigned short)(visibleWidth - 1),
                      (unsigned short)(scrollPixels - 1));

        if (scrollSave.pat && scrollSave.cor && scrollSave.size != 0)
        {
            scrollSave.yi = 0;
            scrollSave.yf = (unsigned short)(scrollPixels - 1);
            RestoreScreen(&scrollSave);
            savedOk = 1;
        }
    }

    if (!savedOk)
    {
        for (y = 0; y < TERM_ROWS - 1; y++)
            termRenderLine(y);
    }

    termFillCellRect(0, TERM_ROWS - 1, VIEW_COLS, 1, termBg);
    termSetVideoCursor();

    termDrawBusy = 0;
    termDiscardPendingKeys();
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

    if (c == 9)
    {
        do {
            termPutChar(' ');
        } while ((curX & 7) != 0 && curX < TERM_COLS - 1);

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

    termDrawBusy = 1;

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

    if (termUseFastG2)
    {
        termFastClear(termBg);
        termSetVideoCursor();
    }
    else
    {
        termFillCellRect(0, 0, VIEW_COLS, TERM_ROWS, termBg);
        termSetVideoCursor();
    }

    termDrawBusy = 0;
    termDiscardPendingKeys();
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

    if (!termUseFastG2)
    {
        termFillCellRect(0, y, VIEW_COLS, 1, termBg);
    }
    else
    {
        for (x = 0; x < VIEW_COLS; x++)
            termWriteG2CharAt(x, y, ' ', termColor);
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
    termCprEchoArmed = 1;
    termCprEchoState = TERM_CPR_NONE;
}

static unsigned char termDropCursorReportEcho(unsigned char c)
{
    if (!termCprEchoArmed)
        return 0;

    if (termCprEchoState == TERM_CPR_NONE)
    {
        if (c == ';')
        {
            termCprEchoState = TERM_CPR_WAIT_DIGIT;
            return 1;
        }

        termCprEchoArmed = 0;
        return 0;
    }

    if (termCprEchoState == TERM_CPR_WAIT_DIGIT)
    {
        if (c >= '0' && c <= '9')
        {
            termCprEchoState = TERM_CPR_DIGITS;
            return 1;
        }

        termCprEchoArmed = 0;
        termCprEchoState = TERM_CPR_NONE;
        return 0;
    }

    if (c >= '0' && c <= '9')
        return 1;

    termCprEchoArmed = 0;
    termCprEchoState = TERM_CPR_NONE;
    if (c == 'R')
        return 1;

    return 0;
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
            if (!strcmp(parm, "0") || !strcmp(parm, "2") || parm[0] == 0)
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
        case 'G': /* horizontal absolute */
        {
            int n = ansiGetNum(parm, 1);
            termSetCursor((unsigned char)(n - 1), curY);
            break;
        }
        case 'd': /* vertical absolute */
        {
            int n = ansiGetNum(parm, 1);
            termSetCursor(curX, (unsigned char)(n - 1));
            break;
        }            
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

static unsigned char termIsBareCsiFinal(unsigned char c)
{
    if (c == 'H' || c == 'f' || c == 'J' || c == 'K' || c == 'A')
        return 1;
    if (c == 'B' || c == 'C' || c == 'D' || c == 'm')
        return 1;
    if (c == 's' || c == 'u')
        return 1;
    return 0;
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

    if (!termCp437)
    {
        if (c >= 0x80 && c <= 0x9F)
            return;
    }

    if (termDropCursorReportEcho(c))
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
            else if (c == 'D') /* Index */
            {
                if (curY < TERM_ROWS - 1) curY++;
                else termScroll();
                termEscReset();
            }
            else if (c == 'M') /* Reverse Index */
            {
                if (curY > 0) curY--;
                termEscReset();
            }
            else if (c == 'E') /* Next line */
            {
                curX = 0;
                if (curY < TERM_ROWS - 1) curY++;
                else termScroll();
                termEscReset();
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
            if ((c >= '0' && c <= '9') || c == ';' || c == ',' || c == '?' || c == '!')
            {
                termEscState = TERM_ESC_CSI;
                termEscAdd(c);
            }
            else if (termIsBareCsiFinal(c))
            {
                termHandleCsi(c, termEscBuf);
                termEscReset();
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

static void readResponseProc(unsigned char *s)
{
    unsigned char c;
    unsigned char line[128];
    unsigned char pos;
    unsigned long idleTimeout;
    unsigned long charTimeout;

    s[0] = 0;
    idleTimeout = 800000L;   /* espera primeira resposta */
    pos = 0;

    while (1)
    {
        if (serialReadByteTimeout(&c, idleTimeout))
            break;

        return;
    }

    while (1)
    {
        if (c == '\r')
        {
        }
        else if (c == '\n' || c == 0x04)
        {
            line[pos] = 0;
            if (!strncmp(line, "OK;", 3) || !strncmp(line, "ERROR", 5))
            {
                strcpy(s, line);
                return;
            }
            pos = 0;
        }
        else
        {
            if (pos < sizeof(line) - 1)
                line[pos++] = c;
        }

        charTimeout = 120000L;   /* timeout entre chars */

        if (!serialReadByteTimeout(&c, charTimeout))
            break;
    }

    line[pos] = 0;
    if (!strncmp(line, "OK;", 3) || !strncmp(line, "ERROR", 5))
        strcpy(s, line);
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
        termProcessByte(c);

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

    if (termDrawBusy)
    {
        termDiscardPendingKeys();
        return 0;
    }

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
static void termTrimParamPathPrefix(void)
{
    unsigned int ix;
    unsigned int src;

    src = 0;
    ix = 0;
    while (paramBasic[ix] != 0x00)
    {
        if (paramBasic[ix] == '/' || paramBasic[ix] == '\\')
            src = ix + 1;
        ix++;
    }

    if (src != 0)
    {
        ix = 0;
        while (paramBasic[src] != 0x00)
        {
            paramBasic[ix++] = paramBasic[src++];
        }
        paramBasic[ix] = 0x00;
    }

    if (paramBasic[0] == ' ')
    {
        ix = 0;
        while (paramBasic[ix] != 0x00)
        {
            paramBasic[ix] = paramBasic[ix + 1];
            ix++;
        }
    }

    ix = 0;
    while (paramBasic[ix] != 0x00)
    {
        if (paramBasic[ix] == ',')
        {
            paramBasic[ix] = 0x00;
            break;
        }
        ix++;
    }
}

static unsigned char termUpperChar(unsigned char c)
{
    if (c >= 'a' && c <= 'z')
        return (unsigned char)(c - 'a' + 'A');

    return c;
}

static unsigned char termIsNoCp437Token(char *s, unsigned int len)
{
    char opt[] = "NOCP437";
    unsigned int ix;

    if (len != 7)
        return 0;

    for (ix = 0; ix < 7; ix++)
    {
        if (termUpperChar((unsigned char)s[ix]) != opt[ix])
            return 0;
    }

    return 1;
}

static void termParseOptions(void)
{
    unsigned int src;
    unsigned int dst;
    unsigned int start;
    unsigned int len;
    unsigned int ix;

    termCp437 = 1;
    src = 0;
    dst = 0;

    while (paramBasic[src] != 0x00)
    {
        while (paramBasic[src] == ' ' || paramBasic[src] == '\t')
            src++;

        if (paramBasic[src] == 0x00)
            break;

        start = src;
        while (paramBasic[src] != 0x00 && paramBasic[src] != ' ' && paramBasic[src] != '\t')
            src++;

        len = src - start;
        if (termIsNoCp437Token((char *)&paramBasic[start], len))
        {
            termCp437 = 0;
            continue;
        }

        if (dst != 0)
            paramBasic[dst++] = ' ';

        for (ix = 0; ix < len; ix++)
            paramBasic[dst++] = paramBasic[start + ix];
    }

    paramBasic[dst] = 0x00;
}

int main(void)
{
    unsigned char c;
    unsigned char cCmd[128];
    long vTimeOut = 8;
    char listenOn = 1;

    if (*paramBasic != 0x00)
    {
        //tstIntsOff();

        termTrimParamPathPrefix();
        termParseOptions();

        netCommEnable();
        termDiscardPendingSerial();

        // Verifica se esta em modo Listen, se sim, tira
        while(vTimeOut--)
        {
            netCommResetInput();
            writeLongSerial("ATLISTEN?");
            writeSerial('\r');
            
            readResponseProc(&cCmd);

            if (!strncmp(cCmd,"OK;",3))
            {
                if (strncmp(cCmd,"OK;OFF",6))  // se nao bater, esta no Listen
                {
                    // Desliga
                    netCommResetInput();
                    writeLongSerial("ATLISTEN");
                    writeSerial('\r');                    
                    readResponseProc(&cCmd);
                }
                else
                {
                    listenOn = 0;
                    break;
                }
            }
        }

        if (listenOn)
        {
            if (*startBasic == 1)
                mprintf("Unable to unset Listen");

            return 1;
        }

        termInitVideoG2();
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
        termRestoreVideo();
    }
    else
    {
        if (*startBasic == 1)
        {
            mprintf("Usage: TERM <destino>[:port]\r\n");
            mprintf("  Ex: TERM bbs.utilityinf.com.br:6522\r\n");
            mprintf("      :port = default 23 if not used");
        }
    }

    if (*startBasic == 1)
    {
        setModeVideoOS(VDP_MODE_TEXT);
        clearScr();
    }

    return 0;
}
