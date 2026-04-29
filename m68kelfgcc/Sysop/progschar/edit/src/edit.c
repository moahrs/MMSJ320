/********************************************************************************
*    Programa    : edit.c
*    Objetivo    : Editor caracter de arquivos
*    Criado em   : 24/04/2026
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 28/04/2026  0.1     Moacir Jr.   Criacao Versao Beta
*--------------------------------------------------------------------------------
*
*--------------------------------------------------------------------------------
* To do
*
*--------------------------------------------------------------------------------
*
*********************************************************************************/
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"
#include "edit.h"

//-------------------------------------------------------------------
static unsigned long noteAlign4(unsigned long value)
{
    return (value + 3UL) & 0xFFFFFFFCUL;
}

//-------------------------------------------------------------------
void main(void)
{
    int ret;
    unsigned long vsizefile;
    unsigned long vprogsize;
    unsigned long vworkbase;
    unsigned short vReadSize;
    unsigned char vParamName[128];
    unsigned char *vComma;
    unsigned char ix;

    memset(vParamName, 0x00, sizeof(vParamName));
    if (*paramBasic != 0x00)
        strcpy((char*)vParamName, (char*)paramBasic);

    vComma = (unsigned char *)strrchr((char*)vParamName, ',');
    if (vComma)
    {
        *vComma = 0x00;
        vprogsize = atol((char*)(vComma + 1));

        vComma = (unsigned char *)strchr((char*)vParamName, ',');
        if (vComma)
            *vComma = 0x00;
    }

    vworkbase = noteAlign4(0x00880000 + vprogsize + 256);

    if (vParamName[0] == 0x00)
    {
        printText("Uso: editor <arquivo>\r\n");
        return;
    }

    edFileBuf = EDIT_FILE_ADDR;

    ret = loadFile((char*)vParamName, edFileBuf);

    if (ret < 0)
    {
        printText("Erro carregando arquivo\r\n");
        return;
    }

    /*
       Importante:
       garantir terminador zero no fim.
       Se loadFile retornar tamanho, use isso.
    */
    edFileSize = ret;

    if (edFileSize >= EDIT_MAX_FILE)
        edFileSize = EDIT_MAX_FILE - 1;

    edFileBuf[edFileSize] = 0;

    edCurLine = 0;
    edCurCol = 0;
    edVScroll = 0;
    edHScroll = 0;

    edBuildLines();

    edLoop((char*)vParamName);

    clearScr();

    return;
}

//-------------------------------------------------------------------
void edPrintSpaces(int qtd)
{
    int i;

    for (i = 0; i < qtd; i++)
        printChar(' ', 1);
}

//-------------------------------------------------------------------
void edDrawLine(int y)
{
    int i;

    vdp_set_cursor(0, y);

    for (i = 0; i < EDIT_COLS; i++)
        printChar('-', 1);
}

//-------------------------------------------------------------------
void edDrawHeader(char *filename)
{
    vdp_set_cursor(0, EDIT_TOP_MENU);
    printText(" EDIT  ");
    printText(filename);
    edPrintSpaces(EDIT_COLS);

    edDrawLine(EDIT_TOP_LINE);
}

//-------------------------------------------------------------------
void edDrawStatus(void)
{
    char buf[80];
    char numbuf[12];

    edDrawLine(EDIT_STATUS_LINE);

    vdp_set_cursor(0, EDIT_STATUS_Y);

    buf[0] = 0;
    strcat(buf, " LIN:");
    itoa(edCurLine + 1, numbuf, 10);
    strcat(buf, numbuf);
    strcat(buf, "/");
    itoa(edNumLines, numbuf, 10);
    strcat(buf, numbuf);
    strcat(buf, "  COL:");
    itoa(edCurCol + 1, numbuf, 10);
    strcat(buf, numbuf);
    strcat(buf, "  V:");
    itoa(edVScroll, numbuf, 10);
    strcat(buf, numbuf);
    strcat(buf, "  H:");
    itoa(edHScroll, numbuf, 10);
    strcat(buf, numbuf);
    strcat(buf, "  ESC=sair");

    printText(buf);
    edPrintSpaces(EDIT_COLS);
}

//-------------------------------------------------------------------
int edLineLen(int line)
{
    char *p;
    int len;

    if (line < 0 || line >= edNumLines)
        return 0;

    p = edLinePtr[line];
    len = 0;

    while (*p != 0 && *p != 13 && *p != 10)
    {
        len++;
        p++;
    }

    return len;
}

//-------------------------------------------------------------------
void edBuildLines(void)
{
    char *p;

    edNumLines = 0;
    p = edFileBuf;

    edLinePtr[edNumLines] = p;
    edNumLines++;

    while (*p != 0 && edNumLines < EDIT_MAX_LINES)
    {
        if (*p == 13)
        {
            *p = 0;
            p++;

            if (*p == 10)
            {
                *p = 0;
                p++;
            }

            edLinePtr[edNumLines] = p;
            edNumLines++;
        }
        else if (*p == 10)
        {
            *p = 0;
            p++;

            edLinePtr[edNumLines] = p;
            edNumLines++;
        }
        else
        {
            p++;
        }
    }
}

//-------------------------------------------------------------------
void edDrawText(void)
{
    int row;
    int line;
    int x;
    int len;
    char *p;

    for (row = 0; row < EDIT_TEXT_ROWS; row++)
    {
        line = edVScroll + row;

        vdp_set_cursor(0, EDIT_TEXT_Y + row);

        if (line >= edNumLines)
        {
            edPrintSpaces(EDIT_COLS);
        }
        else
        {
            p = edLinePtr[line];
            len = edLineLen(line);

            if (edHScroll < len)
                p = p + edHScroll;
            else
                p = p + len;

            for (x = 0; x < EDIT_COLS; x++)
            {
                if (*p != 0)
                {
                    if (*p == 9)
                        printChar(' ', 1);   /* TAB simples */
                    else
                        printChar(*p, 1);

                    p++;
                }
                else
                {
                    printChar(' ', 1);
                }
            }
        }
    }
}

//-------------------------------------------------------------------
void edAdjustScroll(void)
{
    if (edCurLine < edVScroll)
        edVScroll = edCurLine;

    if (edCurLine >= edVScroll + EDIT_TEXT_ROWS)
        edVScroll = edCurLine - EDIT_TEXT_ROWS + 1;

    if (edCurCol < edHScroll)
        edHScroll = edCurCol;

    if (edCurCol >= edHScroll + EDIT_COLS)
        edHScroll = edCurCol - EDIT_COLS + 1;

    if (edVScroll < 0)
        edVScroll = 0;

    if (edHScroll < 0)
        edHScroll = 0;
}

//-------------------------------------------------------------------
void edPlaceCursor(void)
{
    int sx;
    int sy;

    sx = edCurCol - edHScroll;
    sy = edCurLine - edVScroll + EDIT_TEXT_Y;

    if (sx < 0)
        sx = 0;

    if (sx >= EDIT_COLS)
        sx = EDIT_COLS - 1;

    if (sy < EDIT_TEXT_Y)
        sy = EDIT_TEXT_Y;

    if (sy >= EDIT_STATUS_LINE)
        sy = EDIT_STATUS_LINE - 1;

    vdp_set_cursor(sx, sy);
}

//-------------------------------------------------------------------
void edMoveLeft(void)
{
    if (edCurCol > 0)
        edCurCol--;
    else if (edCurLine > 0)
    {
        edCurLine--;
        edCurCol = edLineLen(edCurLine);
    }
}

//-------------------------------------------------------------------
void edMoveRight(void)
{
    int len;

    len = edLineLen(edCurLine);

    if (edCurCol < len)
        edCurCol++;
    else if (edCurLine < edNumLines - 1)
    {
        edCurLine++;
        edCurCol = 0;
    }
}

//-------------------------------------------------------------------
void edMoveUp(void)
{
    int len;

    if (edCurLine > 0)
    {
        edCurLine--;

        len = edLineLen(edCurLine);

        if (edCurCol > len)
            edCurCol = len;
    }
}

//-------------------------------------------------------------------
void edMoveDown(void)
{
    int len;

    if (edCurLine < edNumLines - 1)
    {
        edCurLine++;

        len = edLineLen(edCurLine);

        if (edCurCol > len)
            edCurCol = len;
    }
}

//-------------------------------------------------------------------
void edLoop(char *filename)
{
    int key;
    int oldV;
    int oldH;
    int oldLine;
    int oldCol;
    unsigned int cursorOn;
    unsigned int tick;

    clearScr();

    edDrawHeader(filename);
    edDrawText();
    edDrawStatus();
    edPlaceCursor();
    tick = 0;
    cursorOn = 1;
    
    while (1)
    {
        key = readChar();

        if (key != KEY_NONE)
        {
            edDrawCursor(0);   /* restaura char antes de mover */
            cursorOn = 0;

            if (key == KEY_ESC)
                break;

            oldV = edVScroll;
            oldH = edHScroll;
            oldLine = edCurLine;
            oldCol = edCurCol;

            if (key == KEY_LEFT)
                edMoveLeft();
            else if (key == KEY_RIGHT)
                edMoveRight();
            else if (key == KEY_UP)
                edMoveUp();
            else if (key == KEY_DOWN)
                edMoveDown();

            edAdjustScroll();

            if (oldV != edVScroll || oldH != edHScroll)
            {
                edDrawText();
            }

            if (oldLine != edCurLine || oldCol != edCurCol ||
                oldV != edVScroll || oldH != edHScroll)
            {
                edDrawStatus();
                edPlaceCursor();
            }

            cursorOn = 1;
            tick = 0;
            edDrawCursor(1);
        }
        else
        {
            tick++;

            if (tick >= CURSOR_DELAY)
            {
                tick = 0;

                if (cursorOn)
                {
                    edDrawCursor(0);
                    cursorOn = 0;
                }
                else
                {
                    edDrawCursor(1);
                    cursorOn = 1;
                }
            }
        }
    }
}

//-------------------------------------------------------------------
char edGetCharAtCursor(void)
{
    char *p;
    int len;

    if (edCurLine < 0 || edCurLine >= edNumLines)
        return ' ';

    len = edLineLen(edCurLine);

    if (edCurCol >= len)
        return ' ';

    p = edLinePtr[edCurLine];

    return p[edCurCol];
}

//-------------------------------------------------------------------
void edDrawCursor(int show)
{
    int sx;
    int sy;
    char c;

    sx = edCurCol - edHScroll;
    sy = edCurLine - edVScroll + EDIT_TEXT_Y;

    if (sx < 0 || sx >= EDIT_COLS)
        return;

    if (sy < EDIT_TEXT_Y || sy >= EDIT_STATUS_LINE)
        return;

    vdp_set_cursor(sx, sy);

    if (show)
    {
        printChar(CURSOR_CHAR, 0);
    }
    else
    {
        c = edGetCharAtCursor();

        if (c == 0 || c == 13 || c == 10 || c == 9)
            c = ' ';

        printChar(c, 0);
    }

    vdp_set_cursor(sx, sy);
}
