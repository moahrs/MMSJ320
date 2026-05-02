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

    //OSTaskSuspend(TASK_MMSJOS_MAIN);

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

    strcpy(edFileName, (char*)vParamName);
    edDirty = 0;

    vworkbase = noteAlign4(0x00880000 + vprogsize + 256);
    
    edFileBuf = EDIT_FILE_ADDR;

    if (vParamName[0] == 0x00)
    {
        strcpy((char*)vParamName, "NONAME.TXT");
        edFileSize = 0;
        edFileBuf[0] = 0;
        edDirty = 0;
    }
    else
    {
        ret = loadFile((char*)vParamName, edFileBuf);

        if (ret == 0)
        {
            printText("Erro carregando arquivo\r\n");
            return;
        }

        edFileSize = ret;

        if (edFileSize >= EDIT_MAX_FILE)
            edFileSize = EDIT_MAX_FILE - 1;

        edFileBuf[edFileSize] = 0;
        edDirty = 0;
    }

    edCurLine = 0;
    edCurCol = 0;
    edVScroll = 0;
    edHScroll = 0;

    edBuildLines();
    edLoop((char*)vParamName);

    clearScr();

    //OSTaskResume(TASK_MMSJOS_MAIN);

    return;
}

//-------------------------------------------------------------------
int edGetCursorOffset(void)
{
    return (int)((edLinePtr[edCurLine] + edCurCol) - edFileBuf);
}

//-------------------------------------------------------------------
int edInsertChar(char c)
{
    int i;
    int pos;

    if (edFileSize >= EDIT_MAX_FILE - 2)
        return -1;

    pos = edGetCursorOffset();

    for (i = edFileSize; i >= pos; i--)
        edFileBuf[i + 1] = edFileBuf[i];

    edFileBuf[pos] = c;
    edFileSize++;
    edDirty = 1;

    edBuildLines();
    edCurCol++;

    return 0;
}

//-------------------------------------------------------------------
void edPrintSpaces(int qtd)
{
    int i;

    for (i = 0; i < qtd; i++)
        printChar(' ', 1);
}

//-------------------------------------------------------------------
void edClearToEndLine(int used)
{
    int i;

    if (used < 0)
        used = 0;

    if (used > EDIT_COLS)
        used = EDIT_COLS;

    for (i = used; i < EDIT_COLS; i++)
        printChar(' ', 1);
}

//-------------------------------------------------------------------
void edDrawLine(int y,char c)
{
    int i;

    vdp_set_cursor(0, y);

    for (i = 0; i < EDIT_COLS; i++)
        printChar(c, 1);
}

//-------------------------------------------------------------------
void edDrawHeader(char *filename)
{
    int used;

    vdp_set_cursor(0, EDIT_TOP_MENU);

    printText(" EDIT  ");
    printText(filename);

    used = 7 + strlen(filename);
    edClearToEndLine(used);

    edDrawLine(EDIT_TOP_LINE, '-');
}

//-------------------------------------------------------------------
void edDrawStatus(void)
{
    char buf[80];
    char numbuf[12];

    edDrawLine(EDIT_STATUS_LINE, '-');

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
    if (textToFind[0] != 0)
        strcat(buf, "  ^L=Next");

    printText(buf);

    /* espaço entre status e mensagem */
    printText("  ");

    /* mensagem dinâmica */
    printText(edMessage);

    edClearToEndLine(strlen(buf) + 2 + strlen(edMessage));
    //edClearToEndLine(strlen(buf));    
}

//-------------------------------------------------------------------
int edLineLen(int line)
{
    char *p;
    char *end;
    int len;

    if (line < 0 || line >= edNumLines)
        return 0;

    p = edLinePtr[line];
    end = edFileBuf + edFileSize;
    len = 0;

    while (p < end && *p != 13 && *p != 10 && *p != 0)
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
    char *end;

    edNumLines = 0;
    p = edFileBuf;
    end = edFileBuf + edFileSize;

    if (edFileSize <= 0)
    {
        edLinePtr[0] = edFileBuf;
        edNumLines = 1;
        return;
    }

    edLinePtr[edNumLines] = p;
    edNumLines++;

    while (p < end && edNumLines < EDIT_MAX_LINES)
    {
        if (*p == 13)
        {
            p++;

            if (p < end && *p == 10)
                p++;

            if (p < end)
            {
                edLinePtr[edNumLines] = p;
                edNumLines++;
            }
        }
        else if (*p == 10)
        {
            p++;

            if (p < end)
            {
                edLinePtr[edNumLines] = p;
                edNumLines++;
            }
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
                if (p < edFileBuf + edFileSize && *p != 0 && *p != 13 && *p != 10)
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
int edBackspace(void)
{
    int i;
    int pos;

    if (edCurLine == 0 && edCurCol == 0)
        return 0;

    edMoveLeft();

    pos = edGetCursorOffset();

    for (i = pos; i < edFileSize; i++)
        edFileBuf[i] = edFileBuf[i + 1];

    edFileSize--;
    edDirty = 1;

    edBuildLines();

    return 0;
}

//-------------------------------------------------------------------
int edDelete(void)
{
    int i;
    int pos;

    pos = edGetCursorOffset();

    if (pos >= edFileSize)
        return 0;

    for (i = pos; i < edFileSize; i++)
        edFileBuf[i] = edFileBuf[i + 1];

    edFileSize--;
    edDirty = 1;

    edBuildLines();

    return 0;
}

//-------------------------------------------------------------------
int edInsertEnter(void)
{
    edInsertChar(13);   /* CR */

    /* opcional: LF também */
    edInsertChar(10);

    edCurCol = 0;
    edCurLine++;

    return 0;
}

//-------------------------------------------------------------------
void edDrawCommandHelp(void)
{
    edDrawLine(0, '=');

    if (edCmdModeK)
    {
        vdp_set_cursor(14, 0);
        printText(" File / Block ");

        edClearLine(1);
        vdp_set_cursor(0, 1);
        printText("  S=Save   A=SaveAs |  B=Begin   K=End ");

        edClearLine(2);
        vdp_set_cursor(0, 2);
        printText("  Q=Abandon  O=Open |  C=Copy    V=Move");

        edClearLine(3);
        vdp_set_cursor(0, 3);
        printText("  X=Save & Exit     |  D=Delete    ");
    }
    if (edCmdModeQ)
    {
        vdp_set_cursor(11, 0);
        printText(" Search / Quick ");

        edClearLine(1);
        vdp_set_cursor(0, 1);
        printText("  F Find           |");

        edClearLine(2);
        vdp_set_cursor(0, 2);
        printText("  A Find & Replace |");

        edClearLine(3);
        vdp_set_cursor(0, 3);
        printText("  G Goto Line      |");
    }

    edDrawLine(4, '=');
}

//-------------------------------------------------------------------
void edRestoreNormalTop(char *filename)
{
    edDrawHeader(filename);
    edDrawText();
    edDrawStatus();
    edDrawCursor(1);
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
    int changedText;
    char logBlinkCursor;
    MMSJ_KEYEVENT k;

    clearScr();

    edDrawHeader(filename);
    edDrawText();
    edDrawStatus();
    edPlaceCursor();
    tick = 0;
    cursorOn = 1;
    logBlinkCursor = 1;

    while (1)
    {
        key = KEY_NONE;
        
        if (mmsjKeyGet(&k))
        {            
            if (k.flags & KEY_CTRL)
            {
                if (k.code == 'K')  // Files & Block
                {
                    edCmdModeK = 1;
                    logBlinkCursor = 0;
                    //edSetMessage("^K...");
                }
                else if (k.code == 'Q')    // Search
                {
                    edCmdModeQ = 1;
                    logBlinkCursor = 0;
                    //edSetMessage("^Q...");
                }
                else if (k.code == 'L')    // Find Next
                {                    
                    // procura proxima ocorrencia da palavra
                    edCmdModeL = 1;
                    key = 'L';
                }

                if (edCmdModeK || edCmdModeQ)
                {
                    edDrawStatus();

                    cursorOn = 1;
                    edDrawCursor(1);

                    edHelpMode = 1;
                    edDrawCommandHelp();

                    if (!edCmdModeL)
                        continue;
                }
            }
            else if (k.flags == KEY_NONE)
                key = k.ascii;
        }

        if (key != KEY_NONE)
        {
            edDrawCursor(0);   /* restaura char antes de mover */
            cursorOn = 0;
            changedText = 0;

            /* =========================
            BLOCO WORDSTAR (^K ^Q)
            ========================= */
            if (edCmdModeK || edCmdModeQ || edCmdModeL)
            {
                if (edCmdModeK)
                {
                    if (key == 'S' || key == 's')   // Save
                    {
                        if (strcmp(filename, "NONAME.TXT") == 0)
                            edSaveFileAs((unsigned char*)filename);
                        else
                            edSaveFile();
                    }
                    if (key == 'A' || key == 'a')   // Save As
                    {
                        edSaveFileAs((unsigned char*)filename);
                    }
                    else if (key == 'Q' || key == 'q')  // Abandon
                    {
                        if (edCanExit())
                            break;
                    }
                    else if (key == 'O' || key == 'o')  // Open
                    {
                        edOpenFile((unsigned char*)filename);
                    }
                    else if (key == 'X' || key == 'x')  // Save & Exit
                    {
                        if (edSaveFile())
                            break;
                    }
                    else if (key == KEY_ESC)
                    {
                        edCmdModeK = 0;
                        edHelpMode = 0;
                    }
                    else {
                        // Nenhuma tecla util foi usada, continua esperando
                        continue;   
                    }

                    edCmdModeK = 0;
                }
                else if (edCmdModeQ)
                {
                    if (key == 'F' || key == 'f')   // Find
                    {
                        edSetMessage(" ");
                        edDrawStatus();

                        edFindFromCursor(0);                        
                    }
                    else if (key == 'A' || key == 'a')  // Find & Replace
                    {
                    }
                    else if (key == 'G' || key == 'g')  // Goto Line
                    {
                    }
                    else if (key == KEY_ESC)
                    {
                        edCmdModeQ = 0;
                        edHelpMode = 0;
                    }
                    else {
                        // Nenhuma tecla util foi usada, continua esperando
                        continue;   
                    }

                    edCmdModeQ = 0;
                }
                else if (edCmdModeL)    // procura proxima ocorrencia da palavra
                {                    
                    edFindFromCursor(1);
                    edCmdModeL = 0;
                }

                logBlinkCursor = 1;

                edDrawHeader(filename);
                edDrawText();
                edDrawStatus();

                cursorOn = 1;
                edDrawCursor(1);

                edHelpMode = 0;

                edRestoreNormalTop(filename);

                continue;   /* IMPORTANTÍSSIMO */
            }

            /*if (key == KEY_ESC)
                break;*/

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
            else if (key == KEY_BACKSPACE)
            {
                edBackspace();
                changedText = 1;
            }
            else if (key == KEY_DELETE)
            {
                edDelete();
                changedText = 1;
            }
            else if (key == KEY_ENTER)
            {
                edInsertEnter();
                changedText = 1;
            }
            else if (key >= 32 && key <= 126)
            {
                edInsertChar((char)key);
                changedText = 1;
            }  

            edAdjustScroll();

            if (changedText || oldV != edVScroll || oldH != edHScroll)
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

            if (logBlinkCursor && tick >= CURSOR_DELAY)
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

//-------------------------------------------------------------------
int edSaveFileAs(unsigned char* vParamName)
{
    unsigned char newFileName[128];

    newFileName[0] = 0;

    edInputStatus("Save Name:", newFileName, sizeof(newFileName));
    edToUpperCase(newFileName);
    if (!edSaveToFile((char*)newFileName, edFileBuf, edFileSize))
    {
        edDirty = 0;
        strcpy((char*)vParamName, (char*)newFileName);
        return 1;
    }

    return 0;
}

//-------------------------------------------------------------------
int edSaveFile(void)
{
    if (!edSaveToFile((char*)edFileName, edFileBuf, edFileSize))
    {
        edDirty = 0;
        return 1;
    }

    return 0;
}

//-------------------------------------------------------------------
int edOpenFile(unsigned char* vParamName)
{
    unsigned char openFileName[128];
    long ret;

    openFileName[0] = 0;
    edSetMessage(" ");
    edDrawStatus();

    edInputStatus("Open Name:", openFileName, sizeof(openFileName));
    edToUpperCase(openFileName);

    ret = loadFile((char*)openFileName, edFileBuf);

    if (ret == 0)
    {
        edSetMessage("Open Error!");
        edDrawStatus();

        strcpy((char*)vParamName, "NONAME.TXT");
        edFileSize = 0;
        edFileBuf[0] = 0;
        edDirty = 0;

        return 0;
    }

    edFileSize = ret;

    if (edFileSize >= EDIT_MAX_FILE)
        edFileSize = EDIT_MAX_FILE - 1;

    edFileBuf[edFileSize] = 0;
    edDirty = 0;

    strcpy((char*)vParamName, (char*)openFileName);
    
    edCurLine = 0;
    edCurCol = 0;
    edVScroll = 0;
    edHScroll = 0;

    edBuildLines();

    return 1;
}

//-------------------------------------------------------------------
int edCanExit(void)
{
    char vresp[2];

    if (edDirty)
    {
        edInputStatus("Exit without saving? (Y/N)", vresp, sizeof(vresp));
        if (vresp[0] == 'Y' || vresp[0] == 'y')
            return 1;
    }
    else
        return 1;

    return 0;
}

//-------------------------------------------------------------------
void edSetMessage(char *msg)
{
    strncpy(edMessage, msg, sizeof(edMessage) - 1);
    edMessage[sizeof(edMessage) - 1] = 0;
}

//-------------------------------------------------------------------
void edClearLine(int y)
{
    int i;

    vdp_set_cursor(0, y);

    for (i = 0; i < EDIT_COLS; i++)
        printChar(' ', 1);
}

//-------------------------------------------------------------------
int edInputStatus(char *prompt, char *out, int maxLen)
{
    int key;
    int len;
    int pos;
    int hscroll;
    int fieldX;
    int fieldW;
    int i;
    MMSJ_KEYEVENT k;

    len = strlen(out);
    pos = len;
    hscroll = 0;

    fieldX = strlen(prompt);
    fieldW = EDIT_COLS - fieldX;

    if (fieldW < 1)
        fieldW = 1;

    edClearLine(EDIT_STATUS_Y);
    vdp_set_cursor(0, EDIT_STATUS_Y);
    printText(prompt);

    while (1)
    {
        if (pos < hscroll)
            hscroll = pos;

        if (pos >= hscroll + fieldW)
            hscroll = pos - fieldW + 1;

        /*
           Redesenha SOMENTE o campo, nao o prompt
        */
        vdp_set_cursor(fieldX, EDIT_STATUS_Y);

        for (i = 0; i < fieldW; i++)
        {
            if (hscroll + i < len)
                printChar(out[hscroll + i], 1);
            else
                printChar(' ', 1);
        }

        /*
           Cursor dentro do campo
        */
        vdp_set_cursor(fieldX + pos - hscroll, EDIT_STATUS_Y);
        printChar(CURSOR_CHAR, 0);

        key = KEY_NONE;
        
        if (mmsjKeyGet(&k))
        {            
            if (k.flags == KEY_NONE)
                key = k.ascii;
        }

        if (key == KEY_NONE)
            continue;

        /*
           Apaga cursor restaurando o caractere correto
        */
        vdp_set_cursor(fieldX + pos - hscroll, EDIT_STATUS_Y);

        if (pos < len)
            printChar(out[pos], 0);
        else
            printChar(' ', 0);

        if (key == KEY_ESC)
            return 0;

        if (key == KEY_ENTER)
            return 1;

        if (key == KEY_LEFT)
        {
            if (pos > 0)
                pos--;
        }
        else if (key == KEY_RIGHT)
        {
            if (pos < len)
                pos++;
        }
        else if (key == KEY_BACKSPACE)
        {
            if (pos > 0)
            {
                for (i = pos - 1; i < len; i++)
                    out[i] = out[i + 1];

                pos--;
                len--;
            }
        }
        else if (key == KEY_DELETE)
        {
            if (pos < len)
            {
                for (i = pos; i < len; i++)
                    out[i] = out[i + 1];

                len--;
            }
        }
        else if (key >= 32 && key <= 126)
        {
            if (len < maxLen - 1)
            {
                for (i = len; i >= pos; i--)
                    out[i + 1] = out[i];

                out[pos] = (char)key;
                pos++;
                len++;
            }
        }
    }

    edDrawStatus();
    edDrawCursor(1);
}

//-------------------------------------------------------------------
int edMatchAt(int pos, char *txt)
{
    int i;
    int len;

    len = strlen(txt);

    if (len <= 0)
        return 0;

    if (pos + len > edFileSize)
        return 0;

    for (i = 0; i < len; i++)
    {
        if (edToUpper(edFileBuf[pos + i]) != edToUpper(txt[i]))
            return 0;
    }

    return 1;
}

//-------------------------------------------------------------------
int edFindFromCursor(int repeat)
{
    int pos;
    int i;
    int found;
    int line;
    int col;
    char *p;

    if (!repeat)
    {
        edSearchText[0] = 0;

        edDrawCursor(0);

        if (!edInputStatus("Find: ", edSearchText, ED_INPUT_MAX))
        {
            edDrawStatus();
            return 0;
        }
    }

    if (edSearchText[0] == 0)
        return 0;

    pos = edGetCursorOffset();

    if (repeat)
        pos++;

    found = -1;

    for (i = pos; i < edFileSize; i++)
    {
        if (edMatchAt(i, edSearchText))
        {
            found = i;
            break;
        }
    }

    if (found < 0)
    {
        edSetMessage("Not found");
        edDrawStatus();
        return 0;
    }

    line = 0;
    col = 0;

    for (i = 0; i < edNumLines; i++)
    {
        p = edLinePtr[i];

        if (p <= edFileBuf + found)
            line = i;
        else
            break;
    }

    col = (int)((edFileBuf + found) - edLinePtr[line]);

    edCurLine = line;
    edCurCol = col;

    edAdjustScroll();
    edDrawText();
    edDrawStatus();

    return 1;
}

//-------------------------------------------------------------------
static char edToUpper(char c)
{
    if (c >= 'a' && c <= 'z')
        return c - 32;

    return c;
}

//-------------------------------------------------------------------
int edSaveToFile(char* vfilename, unsigned char* buf, int size)
{
    unsigned int ix, vChunkSize, iy;
    unsigned char vBuffer[128];

    edSetMessage("Saving...");                  
    edDrawStatus();

    // Tenta Abrir Arquivo
    if (fsOpenFile(vfilename) != RETURN_OK)
    {
        // Se nao conseguir, cria o Arquivo
        if (fsCreateFile(vfilename) != RETURN_OK)
        {
            edSetMessage("Save Error!");                  
            edDrawStatus();
            return ERRO_B_CREATE_FILE;
        }
    }

    // Grava no Arquivo
    for (ix = 0; ix < size; ix += 128)
    {
        vChunkSize = (unsigned short)(size - ix);
        if (vChunkSize > 128)
            vChunkSize = 128;

        for (iy = 0; iy < 128; iy++)
        {
            if (iy < vChunkSize)
            {
                vBuffer[iy] = *buf;
                buf += 1;
            }
        }

        if (fsWriteFile(vfilename, ix, vBuffer, (unsigned char)vChunkSize) != RETURN_OK)
        {
            edSetMessage("Save Error!");                  
            edDrawStatus();

            return ERRO_B_WRITE_FILE;
        }
    }

    // Fecha Arquivo e atualiza metadata de escrita
    fsCloseFile(vfilename, 1);

    edSetMessage(" ");                  
    edDrawStatus();

    edDirty = 0;
    return 0;
}   

//-------------------------------------------------------------------
void edToUpperCase(char* str) 
{
    if (str == '\0') return; // Basic safety check
    
    while (*str) 
    {
        *str = edToUpper((unsigned char)*str); // Convert each char
        str++; // Move to the next character
    }
}
