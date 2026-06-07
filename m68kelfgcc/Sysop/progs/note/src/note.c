/********************************************************************************
*    Programa    : note.c
*    Objetivo    : Editor de texto MGUI (mouse + teclado)
*    Criado em   : 26/04/2026
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 12/05/2026  1.0     Copilot      Evolucao de viewer para editor com menus
********************************************************************************/

#include <ctype.h>
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
#include "note.h"

#define NOTE_MAX_FILE_SIZE 32768UL
#define NOTE_MAX_LINES     1024
#define NOTE_CLIP_MAX      4096
#define NOTE_INPUT_MAX     120

#define MENU_FILES   0
#define MENU_EDIT    1
#define MENU_SEARCH  2
#define MENU_HELP    3

#define CMD_NONE        0
#define CMD_OPEN        1
#define CMD_SAVE        2
#define CMD_SAVE_AS     3
#define CMD_EXIT        4
#define CMD_COPY        5
#define CMD_PASTE       6
#define CMD_CUT         7
#define CMD_FIND        8
#define CMD_REPLACE     9
#define CMD_FIND_AGAIN 10
#define CMD_ABOUT      11
#define CMD_GOTO_LINE  12
#define CMD_RUN        13

static unsigned char noteCfgColor[16];
static unsigned long noteLineStorage[NOTE_MAX_LINES];
static unsigned char noteFileName[128];
static unsigned char noteStatusMsg[96];
static unsigned char noteSearchText[64];
static unsigned char noteClipBuf[NOTE_CLIP_MAX + 1];

static unsigned short noteCurLine;
static unsigned short noteCurCol;
static unsigned short noteMaxLineLen;
static unsigned short noteSelStartLine;
static unsigned short noteSelStartCol;
static unsigned short noteSelEndLine;
static unsigned short noteSelEndCol;

static unsigned short noteClipSize;
static unsigned short noteMousePrevBtn;
static unsigned char noteDirty;
static unsigned char noteSelActive;
static unsigned char noteSelSelecting;
static unsigned char noteBlockArmed;

static void noteSetMessage(const unsigned char *msg);
static void noteIndexLines(void);
static unsigned short noteLineLen(unsigned short line);
static unsigned long noteOffsetFromLineCol(unsigned short line, unsigned short col);
static void noteCursorFromOffset(unsigned long off);
static void noteEnsureCursorVisible(void);
static void noteClearSelection(void);
static void noteNormalizeSelection(unsigned short *sl, unsigned short *sc, unsigned short *el, unsigned short *ec);
static unsigned char noteInsertChar(unsigned char c);
static unsigned char noteInsertCRLF(void);
static unsigned char noteBackspace(void);
static unsigned char noteDelete(void);
static unsigned char noteDeleteRange(unsigned long start, unsigned long end);
static unsigned char noteCopySelection(void);
static unsigned char noteCutSelection(void);
static unsigned char notePasteClipboard(void);
static int noteFindNext(const unsigned char *txt, unsigned char repeat);
static int noteReplaceNext(void);
static unsigned char notePromptStatus(const unsigned char *label, unsigned char *out, unsigned short outMax);
static unsigned char noteTryLoadCandidate(const unsigned char *candidate);
static unsigned char noteLoadFileByName(const unsigned char *name);
static unsigned char noteSaveFileByName(const unsigned char *name);
static unsigned char noteSaveCurrent(void);
static unsigned char noteSaveAsPrompt(void);
static unsigned char noteOpenPrompt(void);
static unsigned char noteConfirmLoseChanges(void);
static unsigned char noteExitRequest(void);
static unsigned char noteIsBasFile(void);
static unsigned char noteGotoLinePrompt(void);
static unsigned char noteRunBasicFile(void);
static void noteDrawMenuBar(void);
static void noteDrawStatus(void);
static void noteDrawVisibleRow(unsigned short row);
static void noteRedrawVisibleLine(unsigned short line);
static void noteRedrawVisibleRowsFrom(unsigned short line);
static void noteDrawEditorContent(unsigned char drawCursor);
static void noteDrawEditorPage(unsigned char drawCursor);
static void noteScrollVisualStep(signed char dir);
static void noteDrawScrollBarV(void);
static void noteDrawScrollBarH(void);
static void noteRedrawRangeCells(unsigned short sl, unsigned short sc, unsigned short el, unsigned short ec);
static void noteDrawSelectionOverlay(void);
static void noteDrawCursorBar(void);
static void noteDrawTextCell(unsigned short line, unsigned short col);
static unsigned char noteIsCellSelected(unsigned short line, unsigned short col);
static unsigned char noteToUpper(unsigned char c);
static unsigned char noteCharAt(unsigned short line, unsigned short col);
static unsigned char noteGetMouseTextPos(unsigned short mx, unsigned short my, unsigned short *line, unsigned short *col);
static unsigned char noteHandleKey(unsigned int keyRaw);
static unsigned char notePopupMenu(unsigned char menuId);
static unsigned char noteExecCommand(unsigned char cmd);

//-----------------------------------------------------------------------------
void main(void)
{
    MGUI_SAVESCR windowScr;
    MGUI_MOUSE mouseData;
    VDP_COLOR vdpcolor;
    unsigned char running;
    unsigned char vParamName[128];
    unsigned char *vComma;

    if (*startBasic != 2)
        return;

    memset(vParamName, 0x00, sizeof(vParamName));
    if (*paramBasic != 0x00)
        strcpy((char*)vParamName, (char*)paramBasic);

    vComma = (unsigned char *)strrchr((char*)vParamName, ',');
    if (vComma)
        *vComma = 0x00;

    getColorData(&vdpcolor);
    nvcorfg = vdpcolor.fg;
    nvcorbg = vdpcolor.bg;

    memset(noteCfgColor, 0x00, sizeof(noteCfgColor));
    if (mguiCfgGet("START", "COLOR_F", noteCfgColor, sizeof(noteCfgColor)))
        nvcorfg = (unsigned char)atoi((char*)noteCfgColor);

    memset(noteCfgColor, 0x00, sizeof(noteCfgColor));
    if (mguiCfgGet("START", "COLOR_B", noteCfgColor, sizeof(noteCfgColor)))
        nvcorbg = (unsigned char)atoi((char*)noteCfgColor);

    if (nvcorfg == nvcorbg)
        nvcorfg = VDP_WHITE;

    noteTextBuf = (unsigned char *)msmalloc(NOTE_MAX_FILE_SIZE + 1);
    noteLines = noteLineStorage;

    if (!noteTextBuf || !noteLines)
    {
        message("No memory\0", BTCLOSE, 0);
        return;
    }

    memset(noteTextBuf, 0x00, NOTE_MAX_FILE_SIZE + 1);
    memset((unsigned char *)noteLines, 0x00, sizeof(noteLineStorage));

    noteBufSize = 0;
    noteLineCount = 1;
    noteTopLine = 0;
    noteHOffset = 0;
    noteCurLine = 0;
    noteCurCol = 0;
    noteDirty = 0;
    noteSelActive = 0;
    noteSelSelecting = 0;
    noteBlockArmed = 0;
    noteClipSize = 0;
    noteMousePrevBtn = 0;
    noteSearchText[0] = 0;
    noteStatusMsg[0] = 0;

    if (vParamName[0] != 0)
    {
        strncpy((char *)noteFileName, (char *)vParamName, sizeof(noteFileName) - 1);
        noteFileName[sizeof(noteFileName) - 1] = 0;
    }
    else
    {
        strcpy((char *)noteFileName, "NONAME.TXT");
    }

    if (vParamName[0] != 0)
    {
        if (!noteLoadFileByName(vParamName))
            noteSetMessage((unsigned char *)"Open failed");
    }
    else
    {
        noteIndexLines();
    }

    TrocaSpriteMouse(MOUSE_HOURGLASS);
    SaveScreenNew(&windowScr, 0, 0, 255, 191);

    showWindow("Note Editor v1.0\0", 0, 0, 255, 191, BTNONE);
    noteDrawMenuBar();
    noteDrawEditorPage(1);

    TrocaSpriteMouse(MOUSE_POINTER);

    running = 1;

    while (running)
    {
        unsigned int keyRaw;
        unsigned short lpos;
        unsigned short cpos;

        setPosPressed(0, 0);

        getMouseData(0, &mouseData);
        getMouseData(1, &mouseData);
        keyRaw = (unsigned int)mguiListWindows[6].keyTec;

        if (keyRaw != 0)
        {
            unsigned short oldTopLine = noteTopLine;
            unsigned short oldHOffset = noteHOffset;
            unsigned short oldCurLine = noteCurLine;
            unsigned short oldCurCol = noteCurCol;
            unsigned short oldSelStartLine = 0;
            unsigned short oldSelStartCol = 0;
            unsigned short oldSelEndLine = 0;
            unsigned short oldSelEndCol = 0;
            unsigned char oldSelActive = noteSelActive;
            unsigned char oldSelSelecting = noteSelSelecting;
            unsigned long oldBufSize = noteBufSize;
            unsigned short oldLineCount = noteLineCount;
            unsigned char oldDirty = noteDirty;
            unsigned char oldStatusMsg[96];

            strncpy((char *)oldStatusMsg, (char *)noteStatusMsg, sizeof(oldStatusMsg) - 1);
            oldStatusMsg[sizeof(oldStatusMsg) - 1] = 0;

            if (oldSelActive)
                noteNormalizeSelection(&oldSelStartLine, &oldSelStartCol, &oldSelEndLine, &oldSelEndCol);
            
            if (!noteHandleKey(keyRaw))
                running = 0;

            if (oldTopLine != noteTopLine || oldHOffset != noteHOffset)
            {
                if (oldHOffset == noteHOffset &&
                    (noteTopLine == (unsigned short)(oldTopLine + 1) ||
                     oldTopLine == (unsigned short)(noteTopLine + 1)))
                {
                    if (noteTopLine > oldTopLine)
                        noteScrollVisualStep(1);
                    else
                        noteScrollVisualStep(-1);

                    if (noteSelActive)
                        noteDrawSelectionOverlay();

                    noteDrawScrollBarV();
                    noteDrawCursorBar();
                    noteDrawStatus();
                }
                else
                {
                    noteDrawEditorPage(1);
                }
            }
            else
            {
                if (oldBufSize != noteBufSize || oldLineCount != noteLineCount)
                {
                    unsigned short redrawFrom;
                    redrawFrom = (oldCurLine < noteCurLine) ? oldCurLine : noteCurLine;

                    if (oldLineCount != noteLineCount)
                        noteRedrawVisibleRowsFrom(redrawFrom);
                    else
                        noteRedrawVisibleLine(redrawFrom);

                    if (noteSelActive)
                        noteDrawSelectionOverlay();

                    noteDrawCursorBar();
                }
                else
                {
                    if (oldSelActive && !noteSelActive)
                        noteRedrawRangeCells(oldSelStartLine, oldSelStartCol, oldSelEndLine, oldSelEndCol);

                    if (noteSelActive)
                        noteDrawSelectionOverlay();

                    if (oldCurLine != noteCurLine || oldCurCol != noteCurCol)
                        noteDrawTextCell(oldCurLine, oldCurCol);

                    if (oldCurLine != noteCurLine ||
                        oldCurCol != noteCurCol ||
                        oldSelActive != noteSelActive ||
                        oldSelSelecting != noteSelSelecting)
                        noteDrawCursorBar();
                }

                if (oldCurLine != noteCurLine ||
                    oldCurCol != noteCurCol ||
                    oldSelActive != noteSelActive ||
                    oldSelSelecting != noteSelSelecting ||
                    oldDirty != noteDirty ||
                    strcmp((char *)oldStatusMsg, (char *)noteStatusMsg) != 0)
                    noteDrawStatus();
            }
        }

        if (mouseData.mouseButton == 0x01 && noteMousePrevBtn != 0x01)
        {
            if (mouseData.vposty >= NOTE_MENU_Y && mouseData.vposty <= (NOTE_MENU_Y + NOTE_MENU_H))
            {
                unsigned char cmd = CMD_NONE;

                if (mouseData.vpostx >= 4 && mouseData.vpostx <= 44)
                    cmd = notePopupMenu(MENU_FILES);
                else if (mouseData.vpostx >= 46 && mouseData.vpostx <= 82)
                    cmd = notePopupMenu(MENU_EDIT);
                else if (mouseData.vpostx >= 84 && mouseData.vpostx <= 132)
                    cmd = notePopupMenu(MENU_SEARCH);
                else if (mouseData.vpostx >= 134 && mouseData.vpostx <= 170)
                    cmd = notePopupMenu(MENU_HELP);

                if (cmd != CMD_NONE)
                {
                    if (!noteExecCommand(cmd))
                        running = 0;

                    noteDrawEditorPage(1);
                }
            }
            else if (mouseData.vpostx >= NOTE_SCRL_X &&
                     mouseData.vpostx <= NOTE_SCRL_X + NOTE_SCRL_W &&
                     mouseData.vposty >= NOTE_SCRL_Y &&
                     mouseData.vposty <= NOTE_SCRL_Y + NOTE_SCRL_H)
            {
                unsigned short range;
                unsigned short clickLine;
                if (noteLineCount > NOTE_VISIBLE)
                {
                    range = noteLineCount - NOTE_VISIBLE;
                    clickLine = (unsigned short)((unsigned long)(mouseData.vposty - NOTE_SCRL_Y) * range / NOTE_SCRL_H);
                    if (clickLine > range)
                        clickLine = range;
                    noteTopLine = clickLine;
                    noteEnsureCursorVisible();
                    noteDrawEditorPage(1);
                }
            }
            else if (mouseData.vpostx >= NOTE_SCRL_H_X &&
                     mouseData.vpostx <= NOTE_SCRL_H_X + NOTE_SCRL_H_W &&
                     mouseData.vposty >= NOTE_SCRL_H_Y &&
                     mouseData.vposty <= NOTE_SCRL_H_Y + NOTE_SCRL_H_H)
            {
                unsigned short rangeH;
                unsigned short clickCol;

                if (noteMaxLineLen > NOTE_CHARS_LINE)
                {
                    rangeH = noteMaxLineLen - NOTE_CHARS_LINE;
                    clickCol = (unsigned short)((unsigned long)(mouseData.vpostx - NOTE_SCRL_H_X) * rangeH / NOTE_SCRL_H_W);
                    if (clickCol > rangeH)
                        clickCol = rangeH;
                    noteHOffset = clickCol;
                    noteDrawEditorPage(1);
                }
            }
            else if (noteGetMouseTextPos(mouseData.vpostx, mouseData.vposty, &lpos, &cpos))
            {
                unsigned short oldTopLine = noteTopLine;
                unsigned short oldHOffset = noteHOffset;
                unsigned short oldCurLine = noteCurLine;
                unsigned short oldCurCol = noteCurCol;
                unsigned char hadSelection = noteSelActive;
                unsigned short oldSelStartLine = 0;
                unsigned short oldSelStartCol = 0;
                unsigned short oldSelEndLine = 0;
                unsigned short oldSelEndCol = 0;

                if (hadSelection)
                    noteNormalizeSelection(&oldSelStartLine, &oldSelStartCol, &oldSelEndLine, &oldSelEndCol);

                if (noteSelSelecting)
                {
                    noteCurLine = lpos;
                    noteCurCol = cpos;
                    noteSelEndLine = lpos;
                    noteSelEndCol = cpos;
                    noteSelSelecting = 0;

                    if (noteSelStartLine == noteSelEndLine && noteSelStartCol == noteSelEndCol)
                    {
                        noteSelActive = 0;
                        noteSetMessage((unsigned char *)"Block canceled");
                    }
                    else
                    {
                        noteSelActive = 1;
//                        noteSetMessage((unsigned char *)"BEnd");
                    }

                    noteBlockArmed = 0;
                }
                else
                {
                    if (noteSelActive)
                        noteSelActive = 0;

                    if (noteCurLine == lpos && noteCurCol == cpos && noteBlockArmed)
                    {
                        noteSelSelecting = 1;
                        noteSelStartLine = lpos;
                        noteSelStartCol = cpos;
                        noteSelEndLine = lpos;
                        noteSelEndCol = cpos;
                        noteBlockArmed = 0;
//                        noteSetMessage((unsigned char *)"BIni");
                    }
                    else
                    {
                        noteCurLine = lpos;
                        noteCurCol = cpos;
                        noteBlockArmed = 1;
//                        noteSetMessage((unsigned char *)"Click again for BIni");
                    }
                }

                noteEnsureCursorVisible();
                if (oldTopLine != noteTopLine || oldHOffset != noteHOffset)
                {
                    noteDrawEditorPage(1);
                }
                else
                {
                    if (hadSelection && !noteSelActive)
                    {
                        noteRedrawRangeCells(oldSelStartLine, oldSelStartCol, oldSelEndLine, oldSelEndCol);
                    }

                    if (noteSelActive)
                    {
                        noteDrawSelectionOverlay();
                    }

                    if (oldCurLine != noteCurLine || oldCurCol != noteCurCol)
                    {
                        noteDrawTextCell(oldCurLine, oldCurCol);
                    }

                    noteDrawCursorBar();
                    noteDrawStatus();
                }
            }
        }
        else if (mouseData.mouseButton == 0x01 && noteMousePrevBtn == 0x01)
        {
            /* Selecao por dois cliques: sem arrasto continuo para manter fluidez */
        }
        else if (mouseData.mouseButton != 0x01 && noteMousePrevBtn == 0x01)
        {
            /* Nada a fazer no release no modo de selecao por dois cliques */
        }

        noteMousePrevBtn = mouseData.mouseButton;
    }

    TrocaSpriteMouse(MOUSE_HOURGLASS);
    RestoreScreen(&windowScr);
    TrocaSpriteMouse(MOUSE_POINTER);

    msfree(noteTextBuf);
    noteTextBuf = 0;
}

//-----------------------------------------------------------------------------
static void noteSetMessage(const unsigned char *msg)
{
    if (!msg)
    {
        noteStatusMsg[0] = 0;
        return;
    }

    strncpy((char *)noteStatusMsg, (const char *)msg, sizeof(noteStatusMsg) - 1);
    noteStatusMsg[sizeof(noteStatusMsg) - 1] = 0;
}

//-----------------------------------------------------------------------------
static void noteIndexLines(void)
{
    unsigned long i;
    unsigned short count;
    unsigned short col;
    unsigned char ch;

    noteMaxLineLen = 0;
    noteLines[0] = 0;
    count = 1;
    col = 0;

    for (i = 0; i < noteBufSize && count < NOTE_MAX_LINES; i++)
    {
        ch = noteTextBuf[i];

        if (ch == 0x0D || ch == 0x0A)
        {
            if (col > noteMaxLineLen)
                noteMaxLineLen = col;
            col = 0;

            if (ch == 0x0D && (i + 1) < noteBufSize && noteTextBuf[i + 1] == 0x0A)
                i++;

            if ((i + 1) <= noteBufSize)
            {
                noteLines[count] = i + 1;
                count++;
            }
        }
        else
        {
            col++;
        }
    }

    if (col > noteMaxLineLen)
        noteMaxLineLen = col;

    noteLineCount = count;

    if (noteLineCount == 0)
    {
        noteLineCount = 1;
        noteLines[0] = 0;
    }

    if (noteCurLine >= noteLineCount)
        noteCurLine = noteLineCount - 1;

    if (noteCurCol > noteLineLen(noteCurLine))
        noteCurCol = noteLineLen(noteCurLine);

    noteEnsureCursorVisible();
}

//-----------------------------------------------------------------------------
static unsigned short noteLineLen(unsigned short line)
{
    unsigned long pos;
    unsigned short len;

    if (line >= noteLineCount || line >= NOTE_MAX_LINES)
        return 0;

    if (!noteTextBuf || !noteLines)
        return 0;

    pos = noteLines[line];
    len = 0;

    while (pos < noteBufSize && noteTextBuf)
    {
        if (noteTextBuf[pos] == 0x0D || noteTextBuf[pos] == 0x0A || noteTextBuf[pos] == 0)
            break;

        len++;
        pos++;
    }

    return len;
}

//-----------------------------------------------------------------------------
static unsigned long noteOffsetFromLineCol(unsigned short line, unsigned short col)
{
    unsigned long pos;
    unsigned short len;

    if (line >= noteLineCount)
        line = noteLineCount - 1;

    pos = noteLines[line];
    len = noteLineLen(line);

    if (col > len)
        col = len;

    return pos + col;
}

//-----------------------------------------------------------------------------
static void noteCursorFromOffset(unsigned long off)
{
    unsigned short i;
    unsigned long base;

    if (off > noteBufSize)
        off = noteBufSize;

    noteCurLine = 0;

    for (i = 0; i < noteLineCount; i++)
    {
        base = noteLines[i];
        if (base <= off)
            noteCurLine = i;
        else
            break;
    }

    noteCurCol = (unsigned short)(off - noteLines[noteCurLine]);
    if (noteCurCol > noteLineLen(noteCurLine))
        noteCurCol = noteLineLen(noteCurLine);

    noteEnsureCursorVisible();
}

//-----------------------------------------------------------------------------
static void noteEnsureCursorVisible(void)
{
    if (noteCurLine < noteTopLine)
        noteTopLine = noteCurLine;

    if (noteCurLine >= (unsigned short)(noteTopLine + NOTE_VISIBLE))
        noteTopLine = noteCurLine - NOTE_VISIBLE + 1;

    if (noteCurCol < noteHOffset)
        noteHOffset = noteCurCol;

    if (noteCurCol >= (unsigned short)(noteHOffset + NOTE_CHARS_LINE))
        noteHOffset = noteCurCol - NOTE_CHARS_LINE + 1;
}

//-----------------------------------------------------------------------------
static void noteClearSelection(void)
{
    noteSelActive = 0;
    noteSelSelecting = 0;
    noteBlockArmed = 0;
}

//-----------------------------------------------------------------------------
static void noteNormalizeSelection(unsigned short *sl, unsigned short *sc, unsigned short *el, unsigned short *ec)
{
    if (!noteSelActive)
    {
        *sl = *sc = *el = *ec = 0;
        return;
    }

    *sl = noteSelStartLine;
    *sc = noteSelStartCol;
    *el = noteSelEndLine;
    *ec = noteSelEndCol;

    if (*sl > *el || (*sl == *el && *sc > *ec))
    {
        unsigned short tl = *sl;
        unsigned short tc = *sc;
        *sl = *el;
        *sc = *ec;
        *el = tl;
        *ec = tc;
    }
}

//-----------------------------------------------------------------------------
static unsigned char noteInsertChar(unsigned char c)
{
    unsigned long pos;
    unsigned long i;

    if (noteBufSize >= NOTE_MAX_FILE_SIZE - 2)
        return 0;

    pos = noteOffsetFromLineCol(noteCurLine, noteCurCol);

    for (i = noteBufSize; i > pos; i--)
        noteTextBuf[i] = noteTextBuf[i - 1];

    noteTextBuf[pos] = c;
    noteBufSize++;
    noteTextBuf[noteBufSize] = 0;

    noteCurCol++;
    noteDirty = 1;

    noteIndexLines();
    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteInsertCRLF(void)
{
    unsigned long pos;
    unsigned long i;

    if (noteBufSize >= NOTE_MAX_FILE_SIZE - 3)
        return 0;

    pos = noteOffsetFromLineCol(noteCurLine, noteCurCol);

    for (i = noteBufSize; i > pos; i--)
        noteTextBuf[i + 1] = noteTextBuf[i - 1];

    noteTextBuf[pos] = 0x0D;
    noteTextBuf[pos + 1] = 0x0A;

    noteBufSize += 2;
    noteTextBuf[noteBufSize] = 0;

    noteDirty = 1;
    noteIndexLines();
    noteCursorFromOffset(pos + 2);

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteDeleteRange(unsigned long start, unsigned long end)
{
    unsigned long sz;
    unsigned long i;

    if (start >= end || end > noteBufSize)
        return 0;

    sz = end - start;

    for (i = start; i + sz <= noteBufSize; i++)
        noteTextBuf[i] = noteTextBuf[i + sz];

    noteBufSize -= sz;
    noteTextBuf[noteBufSize] = 0;
    noteDirty = 1;

    noteIndexLines();
    noteCursorFromOffset(start);

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteBackspace(void)
{
    unsigned long pos;

    if (noteCurLine == 0 && noteCurCol == 0)
        return 0;

    pos = noteOffsetFromLineCol(noteCurLine, noteCurCol);
    if (pos == 0)
        return 0;

    return noteDeleteRange(pos - 1, pos);
}

//-----------------------------------------------------------------------------
static unsigned char noteDelete(void)
{
    unsigned long pos;

    pos = noteOffsetFromLineCol(noteCurLine, noteCurCol);
    if (pos >= noteBufSize)
        return 0;

    return noteDeleteRange(pos, pos + 1);
}

//-----------------------------------------------------------------------------
static unsigned char noteCopySelection(void)
{
    unsigned short sl;
    unsigned short sc;
    unsigned short el;
    unsigned short ec;
    unsigned long start;
    unsigned long end;
    unsigned long sz;
    unsigned long i;

    if (!noteSelActive)
    {
        noteSetMessage((unsigned char *)"No selection");
        return 0;
    }

    noteNormalizeSelection(&sl, &sc, &el, &ec);
    start = noteOffsetFromLineCol(sl, sc);
    end = noteOffsetFromLineCol(el, ec);

    if (start == end)
    {
        noteSetMessage((unsigned char *)"No selection");
        return 0;
    }

    if (end < start)
    {
        unsigned long t = start;
        start = end;
        end = t;
    }

    sz = end - start;
    if (sz > NOTE_CLIP_MAX)
    {
        noteSetMessage((unsigned char *)"Selection too big");
        return 0;
    }

    for (i = 0; i < sz; i++)
        noteClipBuf[i] = noteTextBuf[start + i];

    noteClipBuf[sz] = 0;
    noteClipSize = (unsigned short)sz;

    noteSetMessage((unsigned char *)"Copied");
    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteCutSelection(void)
{
    unsigned short sl;
    unsigned short sc;
    unsigned short el;
    unsigned short ec;
    unsigned long start;
    unsigned long end;

    if (!noteCopySelection())
        return 0;

    noteNormalizeSelection(&sl, &sc, &el, &ec);
    start = noteOffsetFromLineCol(sl, sc);
    end = noteOffsetFromLineCol(el, ec);

    noteClearSelection();
    if (!noteDeleteRange(start, end))
        return 0;

    noteSetMessage((unsigned char *)"Cut");
    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char notePasteClipboard(void)
{
    unsigned long pos;
    unsigned long i;

    if (noteClipSize == 0)
    {
        noteSetMessage((unsigned char *)"Clipboard empty");
        return 0;
    }

    if ((unsigned long)noteBufSize + (unsigned long)noteClipSize >= NOTE_MAX_FILE_SIZE)
    {
        noteSetMessage((unsigned char *)"No memory");
        return 0;
    }

    pos = noteOffsetFromLineCol(noteCurLine, noteCurCol);

    for (i = noteBufSize; i >= pos && i != 0xFFFFFFFFUL; i--)
    {
        noteTextBuf[i + noteClipSize] = noteTextBuf[i];
        if (i == 0)
            break;
    }

    for (i = 0; i < noteClipSize; i++)
        noteTextBuf[pos + i] = noteClipBuf[i];

    noteBufSize += noteClipSize;
    noteTextBuf[noteBufSize] = 0;

    noteDirty = 1;
    noteIndexLines();
    noteCursorFromOffset(pos + noteClipSize);
    noteSetMessage((unsigned char *)"Pasted");

    return 1;
}

//-----------------------------------------------------------------------------
static int noteFindNext(const unsigned char *txt, unsigned char repeat)
{
    unsigned long start;
    unsigned long i;
    unsigned long j;
    unsigned long tlen;
    unsigned short sl;
    unsigned short sc;
    unsigned short el;
    unsigned short ec;
    unsigned char a;
    unsigned char b;

    if (!txt || txt[0] == 0)
    {
        noteSetMessage((unsigned char *)"Find text empty");
        return 0;
    }

    tlen = strlen((char *)txt);
    start = noteOffsetFromLineCol(noteCurLine, noteCurCol);

    if (repeat)
    {
        if (noteSelActive)
        {
            noteNormalizeSelection(&sl, &sc, &el, &ec);
            start = noteOffsetFromLineCol(sl, sc);
        }

        if (start < noteBufSize)
            start++;
    }

    for (i = start; i + tlen <= noteBufSize; i++)
    {
        j = 0;
        while (j < tlen)
        {
            a = noteTextBuf[i + j];
            b = txt[j];

            if (noteToUpper(a) != noteToUpper(b))
                break;

            j++;
        }

        if (j == tlen)
        {
            noteCursorFromOffset(i);
            noteSelActive = 1;
            noteSelSelecting = 0;
            noteSelStartLine = noteCurLine;
            noteSelStartCol = noteCurCol;
            noteCursorFromOffset(i + tlen);
            noteSelEndLine = noteCurLine;
            noteSelEndCol = noteCurCol;
            noteCursorFromOffset(i);
            noteSetMessage((unsigned char *)"Found");
            return 1;
        }
    }

    noteSetMessage((unsigned char *)"Not found");
    return 0;
}

//-----------------------------------------------------------------------------
static int noteReplaceNext(void)
{
    unsigned char findTxt[NOTE_INPUT_MAX];
    unsigned char replTxt[NOTE_INPUT_MAX];
    unsigned short sl;
    unsigned short sc;
    unsigned short el;
    unsigned short ec;
    unsigned long start;
    unsigned long end;
    unsigned long oldLen;
    unsigned long newLen;
    long diff;
    long i;

    findTxt[0] = 0;
    replTxt[0] = 0;

    if (!notePromptStatus((unsigned char *)"Find: ", findTxt, sizeof(findTxt)))
        return 0;

    if (findTxt[0] == 0)
        return 0;

    if (!notePromptStatus((unsigned char *)"Replace: ", replTxt, sizeof(replTxt)))
        return 0;

    strncpy((char *)noteSearchText, (char *)findTxt, sizeof(noteSearchText) - 1);
    noteSearchText[sizeof(noteSearchText) - 1] = 0;

    if (!noteFindNext(findTxt, 0))
        return 0;

    if (!noteSelActive)
        return 0;

    noteNormalizeSelection(&sl, &sc, &el, &ec);
    start = noteOffsetFromLineCol(sl, sc);
    end = noteOffsetFromLineCol(el, ec);

    oldLen = end - start;
    newLen = strlen((char *)replTxt);
    diff = (long)newLen - (long)oldLen;

    if (diff > 0 && (unsigned long)((long)noteBufSize + diff) >= NOTE_MAX_FILE_SIZE)
    {
        noteSetMessage((unsigned char *)"No memory");
        return 0;
    }

    if (diff > 0)
    {
        for (i = (long)noteBufSize; i >= (long)end; i--)
            noteTextBuf[i + diff] = noteTextBuf[i];
    }
    else if (diff < 0)
    {
        for (i = (long)end; i <= (long)noteBufSize; i++)
            noteTextBuf[i + diff] = noteTextBuf[i];
    }

    for (i = 0; i < (long)newLen; i++)
        noteTextBuf[start + i] = replTxt[i];

    noteBufSize = (unsigned long)((long)noteBufSize + diff);
    noteTextBuf[noteBufSize] = 0;
    noteDirty = 1;
    noteClearSelection();

    noteIndexLines();
    noteCursorFromOffset(start + newLen);

    noteSetMessage((unsigned char *)"Replaced");
    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char notePromptStatus(const unsigned char *label, unsigned char *out, unsigned short outMax)
{
    MGUI_MOUSE m;
    unsigned int keyRaw;
    unsigned short len;
    unsigned char code;
    unsigned char flags;
    unsigned char line[160];
    unsigned char redraw;

    if (!out || outMax < 2)
        return 0;

    out[0] = 0;
    len = 0;
    redraw = 1;

    while (1)
    {
        if (redraw)
        {
            memset(line, 0, sizeof(line));
            strcat((char *)line, (char *)label);
            strcat((char *)line, (char *)out);

            FillRect(1, NOTE_STATUS_Y, 252, 10, nvcorbg);
            writesxy(2, NOTE_STATUS_Y + 1, 1, line, nvcorfg, nvcorbg);
            redraw = 0;
        }

        getMouseData(1, &m);
        keyRaw = (unsigned int)mguiListWindows[6].keyTec;
        if (keyRaw == 0)
            continue;

        flags = (unsigned char)((keyRaw >> 8) & 0xFF);
        code = (unsigned char)(keyRaw & 0xFF);

        if (flags != 0)
            continue;

        if (code == KEY_ESC)
            return 0;

        if (code == KEY_ENTER)
            return 1;

        if (code == KEY_BACKSPACE)
        {
            if (len > 0)
            {
                len--;
                out[len] = 0;
                redraw = 1;
            }
            continue;
        }

        if (code >= 0x20 && code < 0x7F)
        {
            if (len < (unsigned short)(outMax - 1))
            {
                out[len++] = code;
                out[len] = 0;
                redraw = 1;
            }
        }
    }
}

//-----------------------------------------------------------------------------
static unsigned char noteTryLoadCandidate(const unsigned char *candidate)
{
    unsigned long sz;

    if (!candidate || candidate[0] == 0)
        return 0;

    sz = fsInfoFile((char *)candidate, INFO_SIZE);
    if (sz == 0 || sz == ERRO_D_NOT_FOUND)
        return 0;

    if (sz >= NOTE_MAX_FILE_SIZE)
        sz = NOTE_MAX_FILE_SIZE - 1;

    sz = loadFile((unsigned char *)candidate, noteTextBuf);
    if (sz == 0)
        return 0;

    if (sz >= NOTE_MAX_FILE_SIZE)
        sz = NOTE_MAX_FILE_SIZE - 1;

    noteBufSize = sz;
    noteTextBuf[noteBufSize] = 0;
    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteLoadFileByName(const unsigned char *name)
{
    unsigned char rawName[128];
    unsigned char upperName[128];
    unsigned char noSlash[128];
    unsigned char upperNoSlash[128];
    unsigned short i;
    const unsigned char *loadedName;

    if (!name || name[0] == 0)
        return 0;

    strncpy((char *)rawName, (const char *)name, sizeof(rawName) - 1);
    rawName[sizeof(rawName) - 1] = 0;

    strncpy((char *)upperName, (char *)rawName, sizeof(upperName) - 1);
    upperName[sizeof(upperName) - 1] = 0;
    for (i = 0; upperName[i] != 0; i++)
        upperName[i] = (unsigned char)toupper(upperName[i]);

    noSlash[0] = 0;
    upperNoSlash[0] = 0;
    if (rawName[0] == '/' && rawName[1] != 0)
    {
        strncpy((char *)noSlash, (char *)(rawName + 1), sizeof(noSlash) - 1);
        noSlash[sizeof(noSlash) - 1] = 0;

        strncpy((char *)upperNoSlash, (char *)noSlash, sizeof(upperNoSlash) - 1);
        upperNoSlash[sizeof(upperNoSlash) - 1] = 0;
        for (i = 0; upperNoSlash[i] != 0; i++)
            upperNoSlash[i] = (unsigned char)toupper(upperNoSlash[i]);
    }

    loadedName = 0;
    if (noteTryLoadCandidate(rawName))
        loadedName = rawName;
    else if (strcmp((char *)upperName, (char *)rawName) && noteTryLoadCandidate(upperName))
        loadedName = upperName;
    else if (noSlash[0] != 0 && noteTryLoadCandidate(noSlash))
        loadedName = noSlash;
    else if (upperNoSlash[0] != 0 &&
             strcmp((char *)upperNoSlash, (char *)noSlash) &&
             noteTryLoadCandidate(upperNoSlash))
        loadedName = upperNoSlash;

    if (!loadedName)
        return 0;

    strncpy((char *)noteFileName, (const char *)loadedName, sizeof(noteFileName) - 1);
    noteFileName[sizeof(noteFileName) - 1] = 0;

    noteCurLine = 0;
    noteCurCol = 0;
    noteTopLine = 0;
    noteHOffset = 0;
    noteDirty = 0;
    noteClearSelection();

    noteIndexLines();
    noteSetMessage((unsigned char *)"Opened");

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteSaveFileByName(const unsigned char *name)
{
    if (!name || name[0] == 0)
        return 0;

    if (saveFile((unsigned char *)name, noteTextBuf, noteBufSize) != RETURN_OK)
        return 0;

    strncpy((char *)noteFileName, (char *)name, sizeof(noteFileName) - 1);
    noteFileName[sizeof(noteFileName) - 1] = 0;

    noteDirty = 0;
    noteSetMessage((unsigned char *)"Saved");
    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteSaveCurrent(void)
{
    if (noteFileName[0] == 0 || !strcmp((char *)noteFileName, "NONAME.TXT"))
        return noteSaveAsPrompt();

    if (!noteSaveFileByName(noteFileName))
    {
        noteSetMessage((unsigned char *)"Save error");
        return 0;
    }

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteSaveAsPrompt(void)
{
    unsigned char nm[NOTE_INPUT_MAX];

    nm[0] = 0;

    if (!notePromptStatus((unsigned char *)"Save As: ", nm, sizeof(nm)))
        return 0;

    if (nm[0] == 0)
        return 0;

    if (!noteSaveFileByName(nm))
    {
        noteSetMessage((unsigned char *)"Save error");
        return 0;
    }

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteOpenPrompt(void)
{
    unsigned char nm[NOTE_INPUT_MAX];

    if (!noteConfirmLoseChanges())
        return 0;

    nm[0] = 0;
    if (!notePromptStatus((unsigned char *)"Open: ", nm, sizeof(nm)))
        return 0;

    if (nm[0] == 0)
        return 0;

    if (!noteLoadFileByName(nm))
    {
        noteSetMessage((unsigned char *)"Open error");
        return 0;
    }

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteConfirmLoseChanges(void)
{
    unsigned char resp;

    if (!noteDirty)
        return 1;

    resp = message("Unsaved changes. Save?\0", BTYES | BTNO | BTCANCEL, 0);

    if (resp == BTYES)
        return noteSaveCurrent();

    if (resp == BTNO)
        return 1;

    return 0;
}

//-----------------------------------------------------------------------------
static unsigned char noteExitRequest(void)
{
    if (!noteConfirmLoseChanges())
        return 0;

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteIsBasFile(void)
{
    unsigned char *dot;

    dot = (unsigned char *)strrchr((char *)noteFileName, '.');
    if (!dot)
        return 0;

    if (toupper(dot[1]) != 'B')
        return 0;
    if (toupper(dot[2]) != 'A')
        return 0;
    if (toupper(dot[3]) != 'S')
        return 0;
    if (dot[4] != 0x00)
        return 0;

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteGotoLinePrompt(void)
{
    unsigned char lineTxt[NOTE_INPUT_MAX];
    unsigned short lineNo;
    unsigned short len;

    lineTxt[0] = 0;
    if (!notePromptStatus((unsigned char *)"Go to line: ", lineTxt, sizeof(lineTxt)))
        return 0;

    lineNo = (unsigned short)atoi((char *)lineTxt);
    if (lineNo == 0)
    {
        noteSetMessage((unsigned char *)"Invalid line");
        return 0;
    }

    if (lineNo > noteLineCount)
        lineNo = noteLineCount;

    noteCurLine = (unsigned short)(lineNo - 1);
    len = noteLineLen(noteCurLine);
    if (noteCurCol > len)
        noteCurCol = len;

    noteClearSelection();
    noteEnsureCursorVisible();
    noteSetMessage((unsigned char *)"Line");

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteRunBasicFile(void)
{
    unsigned char cmd[160];

    if (!noteIsBasFile())
    {
        noteSetMessage((unsigned char *)"Only .BAS");
        return 1;
    }

    if (noteDirty)
    {
        if (!noteSaveCurrent())
            return 1;
    }

    cmd[0] = 0;
    strcpy((char *)cmd, "BASIC ");
    strncat((char *)cmd, (char *)noteFileName, sizeof(cmd) - 7);
    cmd[sizeof(cmd) - 1] = 0;

    fsOsCommand(cmd);

    vdp_init(VDP_MODE_G2, VDP_BLACK, 0, 0);
    vdp_set_bdcolor(VDP_BLACK);
    if (!setFontUseG2(0))
        setFontUseG2(99);

    showWindow("Note Editor v1.0\0", 0, 0, 255, 191, BTNONE);
    noteDrawMenuBar();
    noteDrawEditorPage(1);

    return 1;
}

//-----------------------------------------------------------------------------
static void noteDrawMenuBar(void)
{
    FillRect(1, NOTE_MENU_Y, 252, NOTE_MENU_H, nvcorbg);
    DrawLine(0, NOTE_MENU_Y - 1, 255, NOTE_MENU_Y - 1, nvcorfg);
    DrawLine(0, NOTE_MENU_Y + NOTE_MENU_H, 255, NOTE_MENU_Y + NOTE_MENU_H, nvcorfg);

    writesxy(4, NOTE_MENU_Y + 1, 1, "Files\0", nvcorfg, nvcorbg);
    writesxy(46, NOTE_MENU_Y + 1, 1, "Edit\0", nvcorfg, nvcorbg);
    writesxy(84, NOTE_MENU_Y + 1, 1, "Search\0", nvcorfg, nvcorbg);
    writesxy(134, NOTE_MENU_Y + 1, 1, "Help\0", nvcorfg, nvcorbg);
}

//-----------------------------------------------------------------------------
static void noteDrawStatus(void)
{
    unsigned char line[160];
    unsigned char tmp[16];

    FillRect(1, NOTE_STATUS_Y - 2, 252, 12, nvcorbg);
    DrawLine(0, NOTE_STATUS_Y - 3, 255, NOTE_STATUS_Y - 3, nvcorfg);

    line[0] = 0;
    strcat((char *)line, " ");
    strcat((char *)line, (char *)noteFileName);
    strcat((char *)line, "  Ln:");
    itoa(noteCurLine + 1, (char *)tmp, 10);
    strcat((char *)line, (char *)tmp);
    strcat((char *)line, " Col:");
    itoa(noteCurCol + 1, (char *)tmp, 10);
    strcat((char *)line, (char *)tmp);

    if (noteDirty)
        strcat((char *)line, " *");

    if (noteSelSelecting)
    {
        strcat((char *)line, "  BIni");
    }
    else if (noteSelActive)
    {
        strcat((char *)line, "  BSel");
    }

    if (noteStatusMsg[0] != 0)
    {
        strcat((char *)line, "  ");
        strcat((char *)line, (char *)noteStatusMsg);
    }

    writesxy(2, NOTE_STATUS_Y, 1, line, nvcorfg, nvcorbg);
}

//-----------------------------------------------------------------------------
static void noteDrawVisibleRow(unsigned short row)
{
    unsigned char linebuf[NOTE_CHARS_LINE + 2];
    unsigned short idx;
    unsigned short col;
    unsigned long pos;
    unsigned char ch;
    unsigned short y;

    if (row >= NOTE_VISIBLE)
        return;

    y = NOTE_Y_TEXT + (row * NOTE_LINE_H);

    for (col = 0; col < NOTE_CHARS_LINE; col++)
        linebuf[col] = ' ';
    linebuf[NOTE_CHARS_LINE] = 0;

    idx = noteTopLine + row;
    if (idx < noteLineCount)
    {
        pos = noteLines[idx];

        col = 0;
        while (col < noteHOffset && pos < noteBufSize)
        {
            ch = noteTextBuf[pos];
            if (ch == 0x0D || ch == 0x0A || ch == 0)
                break;
            col++;
            pos++;
        }

        col = 0;
        while (col < NOTE_CHARS_LINE && pos < noteBufSize)
        {
            ch = noteTextBuf[pos];
            if (ch == 0x0D || ch == 0x0A || ch == 0)
                break;

            if (ch < 0x20 || ch >= 0x7F)
                ch = ' ';
            if (ch == '\t')
                ch = ' ';

            linebuf[col] = ch;
            col++;
            pos++;
        }
    }

    FillRect(NOTE_TEXT_X, y, NOTE_CHARS_LINE * NOTE_CHAR_W, NOTE_LINE_H, nvcorbg);
    writesxy(NOTE_TEXT_X, y, 8, linebuf, nvcorfg, nvcorbg);
}

//-----------------------------------------------------------------------------
static void noteRedrawVisibleLine(unsigned short line)
{
    unsigned short row;

    if (line < noteTopLine)
        return;

    row = (unsigned short)(line - noteTopLine);
    if (row >= NOTE_VISIBLE)
        return;

    noteDrawVisibleRow(row);
}

//-----------------------------------------------------------------------------
static void noteRedrawVisibleRowsFrom(unsigned short line)
{
    unsigned short startRow;
    unsigned short row;

    if (line < noteTopLine)
        startRow = 0;
    else
        startRow = (unsigned short)(line - noteTopLine);

    if (startRow >= NOTE_VISIBLE)
        return;

    for (row = startRow; row < NOTE_VISIBLE; row++)
        noteDrawVisibleRow(row);
}

//-----------------------------------------------------------------------------
static void noteDrawEditorContent(unsigned char drawCursor)
{
    unsigned short row;

    FillRect(NOTE_TEXT_X, NOTE_Y_TEXT, NOTE_CHARS_LINE * NOTE_CHAR_W, NOTE_VISIBLE * NOTE_LINE_H, nvcorbg);

    for (row = 0; row < NOTE_VISIBLE; row++)
        noteDrawVisibleRow(row);

    noteDrawSelectionOverlay();

    if (drawCursor)
        noteDrawCursorBar();
}

//-----------------------------------------------------------------------------
static void noteDrawEditorPage(unsigned char drawCursor)
{
    noteDrawEditorContent(drawCursor);
    noteDrawScrollBarV();
    noteDrawScrollBarH();
    noteDrawStatus();
}

//-----------------------------------------------------------------------------
static void noteScrollVisualStep(signed char dir)
{
    unsigned short row;

    if (dir > 0)
    {
        for (row = 0; row + 1 < NOTE_VISIBLE; row++)
            noteDrawVisibleRow(row);

        noteDrawVisibleRow((unsigned short)(NOTE_VISIBLE - 1));
    }
    else
    {
        row = (unsigned short)(NOTE_VISIBLE - 1);
        while (row > 0)
        {
            noteDrawVisibleRow(row);
            row--;
        }

        noteDrawVisibleRow(0);
    }
}

//-----------------------------------------------------------------------------
static void noteRedrawRangeCells(unsigned short sl, unsigned short sc, unsigned short el, unsigned short ec)
{
    unsigned short ln;
    unsigned short fromCol;
    unsigned short toCol;
    unsigned short visFrom;
    unsigned short visTo;
    unsigned short c;

    if (sl > el || (sl == el && sc > ec))
    {
        unsigned short tl = sl;
        unsigned short tc = sc;
        sl = el;
        sc = ec;
        el = tl;
        ec = tc;
    }

    for (ln = sl; ln <= el; ln++)
    {
        if (ln < noteTopLine || ln >= (unsigned short)(noteTopLine + NOTE_VISIBLE))
            continue;

        if (ln == sl)
            fromCol = sc;
        else
            fromCol = 0;

        if (ln == el)
            toCol = ec;
        else
            toCol = noteLineLen(ln);

        if (toCol <= fromCol)
            continue;

        if (toCol <= noteHOffset)
            continue;

        visFrom = fromCol;
        if (visFrom < noteHOffset)
            visFrom = noteHOffset;

        visTo = toCol;
        if (visTo > (unsigned short)(noteHOffset + NOTE_CHARS_LINE))
            visTo = noteHOffset + NOTE_CHARS_LINE;

        if (visTo <= visFrom)
            continue;

        for (c = visFrom; c < visTo; c++)
            noteDrawTextCell(ln, c);

        if (ln == el)
            break;
    }
}

//-----------------------------------------------------------------------------
static void noteDrawSelectionOverlay(void)
{
    unsigned short sl;
    unsigned short sc;
    unsigned short el;
    unsigned short ec;
    unsigned short ln;
    unsigned short fromCol;
    unsigned short toCol;
    unsigned short visFrom;
    unsigned short visTo;
    unsigned short y;
    unsigned short x;
    unsigned short drawCount;
    unsigned short i;
    unsigned char selBuf[NOTE_CHARS_LINE + 1];

    if (!noteSelActive || noteSelSelecting)
        return;

    noteNormalizeSelection(&sl, &sc, &el, &ec);

    if (noteLineCount == 0 || sl >= noteLineCount || el >= noteLineCount)
        return;

    for (ln = sl; ln <= el; ln++)
    {
        if (ln < noteTopLine || ln >= (unsigned short)(noteTopLine + NOTE_VISIBLE))
            continue;

        if (ln == sl)
            fromCol = sc;
        else
            fromCol = 0;

        if (ln == el)
            toCol = ec;
        else
            toCol = noteLineLen(ln);

        if (toCol <= fromCol)
            continue;

        if (toCol <= noteHOffset)
            continue;

        visFrom = fromCol;
        if (visFrom < noteHOffset)
            visFrom = noteHOffset;

        visTo = toCol;
        if (visTo > (unsigned short)(noteHOffset + NOTE_CHARS_LINE))
            visTo = noteHOffset + NOTE_CHARS_LINE;

        if (visTo <= visFrom)
            continue;

        x = NOTE_TEXT_X + (unsigned short)((visFrom - noteHOffset) * NOTE_CHAR_W);
        y = NOTE_Y_TEXT + (unsigned short)((ln - noteTopLine) * NOTE_LINE_H);

        drawCount = (unsigned short)(visTo - visFrom);
        if (drawCount == 0)
            continue;

        if (drawCount > NOTE_CHARS_LINE)
            drawCount = NOTE_CHARS_LINE;

        for (i = 0; i < drawCount; i++)
            selBuf[i] = noteCharAt(ln, (unsigned short)(visFrom + i));
        selBuf[drawCount] = 0;

        writesxy(x, y, 8, selBuf, nvcorbg, nvcorfg);

        if (ln == el)
            break;
    }
}

//-----------------------------------------------------------------------------
static void noteDrawCursorBar(void)
{
    unsigned short sx;
    unsigned short sy;
    unsigned short cellW;
    unsigned char cursorChar[2];

    if (noteCurLine < noteTopLine || noteCurLine >= (unsigned short)(noteTopLine + NOTE_VISIBLE))
        return;

    if (noteCurCol < noteHOffset || noteCurCol > (unsigned short)(noteHOffset + NOTE_CHARS_LINE))
        return;

    sx = NOTE_TEXT_X + (unsigned short)((noteCurCol - noteHOffset) * NOTE_CHAR_W);
    sy = NOTE_Y_TEXT + (unsigned short)((noteCurLine - noteTopLine) * NOTE_LINE_H);

    if (sx >= 252 || sy >= NOTE_STATUS_Y)
        return;

    cellW = (NOTE_CHAR_W > 1) ? (NOTE_CHAR_W - 1) : NOTE_CHAR_W;
    FillRect(sx, sy, cellW, NOTE_CHAR_H, nvcorfg);
    cursorChar[0] = noteCharAt(noteCurLine, noteCurCol);
    cursorChar[1] = 0;
    writesxy(sx, sy, 8, cursorChar, nvcorbg, nvcorfg);
}

//-----------------------------------------------------------------------------
static void noteDrawTextCell(unsigned short line, unsigned short col)
{
    unsigned short sx;
    unsigned short sy;
    unsigned short cellW;
    unsigned char chbuf[2];
    unsigned char invert;

    if (line < noteTopLine || line >= (unsigned short)(noteTopLine + NOTE_VISIBLE))
        return;

    if (col < noteHOffset || col > (unsigned short)(noteHOffset + NOTE_CHARS_LINE))
        return;

    sx = NOTE_TEXT_X + (unsigned short)((col - noteHOffset) * NOTE_CHAR_W);
    sy = NOTE_Y_TEXT + (unsigned short)((line - noteTopLine) * NOTE_LINE_H);

    if (sx >= 252 || sy >= NOTE_STATUS_Y)
        return;

    chbuf[0] = noteCharAt(line, col);
    chbuf[1] = 0;
    invert = noteIsCellSelected(line, col);
    cellW = (NOTE_CHAR_W > 1) ? (NOTE_CHAR_W - 1) : NOTE_CHAR_W;

    FillRect(sx, sy, cellW, NOTE_CHAR_H, nvcorbg);
    if (invert)
        writesxy(sx, sy, 8, chbuf, nvcorbg, nvcorfg);
    else
        writesxy(sx, sy, 8, chbuf, nvcorfg, nvcorbg);
}

//-----------------------------------------------------------------------------
static unsigned char noteIsCellSelected(unsigned short line, unsigned short col)
{
    unsigned short sl;
    unsigned short sc;
    unsigned short el;
    unsigned short ec;

    if (!noteSelActive || noteSelSelecting)
        return 0;

    noteNormalizeSelection(&sl, &sc, &el, &ec);

    if (line < sl || line > el)
        return 0;

    if (line == sl && col < sc)
        return 0;

    if (line == el && col >= ec)
        return 0;

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteToUpper(unsigned char c)
{
    if (c >= 'a' && c <= 'z')
        return (unsigned char)(c - ('a' - 'A'));

    return c;
}

//-----------------------------------------------------------------------------
static unsigned char noteCharAt(unsigned short line, unsigned short col)
{
    unsigned long pos;
    unsigned short i;
    unsigned char ch;

    if (!noteTextBuf || !noteLines)
        return ' ';

    if (line >= noteLineCount || line >= NOTE_MAX_LINES)
        return ' ';

    pos = noteLines[line];

    for (i = 0; i < col && pos < noteBufSize; i++)
    {
        ch = noteTextBuf[pos];
        if (ch == 0x0D || ch == 0x0A || ch == 0)
            return ' ';
        pos++;
    }

    if (pos >= noteBufSize)
        return ' ';

    ch = noteTextBuf[pos];
    if (ch == 0x0D || ch == 0x0A || ch == 0 || ch == '\t' || ch < 0x20 || ch >= 0x7F)
        return ' ';

    return ch;
}

//-----------------------------------------------------------------------------
static void noteDrawScrollBarV(void)
{
    unsigned short thumbY;
    unsigned short thumbH;
    unsigned short range;
    unsigned long ltmp;

    FillRect(NOTE_SCRL_X, NOTE_SCRL_Y, NOTE_SCRL_W, NOTE_SCRL_H, nvcorbg);
    DrawRect(NOTE_SCRL_X, NOTE_SCRL_Y, NOTE_SCRL_W, NOTE_SCRL_H, nvcorfg);

    if (noteLineCount <= NOTE_VISIBLE)
        return;

    range = noteLineCount - NOTE_VISIBLE;

    thumbH = (unsigned short)(((unsigned long)NOTE_VISIBLE * NOTE_SCRL_H) / noteLineCount);
    if (thumbH < 8)
        thumbH = 8;
    if (thumbH > NOTE_SCRL_H)
        thumbH = NOTE_SCRL_H;

    ltmp = noteTopLine;
    ltmp = ltmp * (NOTE_SCRL_H - thumbH);
    ltmp = ltmp / range;
    thumbY = NOTE_SCRL_Y + (unsigned short)ltmp;

    FillRect(NOTE_SCRL_X + 1, thumbY, NOTE_SCRL_W - 2, thumbH, nvcorfg);
}

//-----------------------------------------------------------------------------
static void noteDrawScrollBarH(void)
{
    unsigned short thumbX;
    unsigned short thumbW;
    unsigned short range;
    unsigned long ltmp;

    FillRect(NOTE_SCRL_H_X, NOTE_SCRL_H_Y, NOTE_SCRL_H_W, NOTE_SCRL_H_H, nvcorbg);
    DrawRect(NOTE_SCRL_H_X, NOTE_SCRL_H_Y, NOTE_SCRL_H_W, NOTE_SCRL_H_H, nvcorfg);

    if (noteMaxLineLen <= NOTE_CHARS_LINE)
        return;

    range = noteMaxLineLen - NOTE_CHARS_LINE;

    thumbW = (unsigned short)(((unsigned long)NOTE_CHARS_LINE * NOTE_SCRL_H_W) / noteMaxLineLen);
    if (thumbW < 8)
        thumbW = 8;
    if (thumbW > NOTE_SCRL_H_W)
        thumbW = NOTE_SCRL_H_W;

    ltmp = noteHOffset;
    ltmp = ltmp * (NOTE_SCRL_H_W - thumbW);
    ltmp = ltmp / range;
    thumbX = NOTE_SCRL_H_X + (unsigned short)ltmp;

    FillRect(thumbX, NOTE_SCRL_H_Y + 1, thumbW, NOTE_SCRL_H_H - 2, nvcorfg);
}

//-----------------------------------------------------------------------------
static unsigned char noteGetMouseTextPos(unsigned short mx, unsigned short my, unsigned short *line, unsigned short *col)
{
    unsigned short row;
    unsigned short c;
    unsigned short ln;
    unsigned short ll;

    if (mx < NOTE_TEXT_X || mx >= NOTE_TEXT_X + (NOTE_CHARS_LINE * NOTE_CHAR_W))
        return 0;

    if (my < NOTE_Y_TEXT || my >= NOTE_Y_TEXT + (NOTE_VISIBLE * NOTE_LINE_H))
        return 0;

    if (!noteTextBuf || !noteLines || noteLineCount == 0)
        return 0;

    row = (unsigned short)((my - NOTE_Y_TEXT) / NOTE_LINE_H);
    ln = noteTopLine + row;
    
    if (ln >= noteLineCount)
        ln = noteLineCount - 1;
    
    if (ln >= NOTE_MAX_LINES)
        ln = NOTE_MAX_LINES - 1;

    c = (unsigned short)((mx - NOTE_TEXT_X) / NOTE_CHAR_W);
    c = c + noteHOffset;

    ll = noteLineLen(ln);
    if (c > ll)
        c = ll;

    if (line)
        *line = ln;
    if (col)
        *col = c;
    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char noteHandleKey(unsigned int keyRaw)
{
    unsigned char code;
    unsigned char flags;
    unsigned short len;

    flags = (unsigned char)((keyRaw >> 8) & 0xFF);
    code = (unsigned char)(keyRaw & 0xFF);

    if (flags == KEY_CTRL || flags == KEY_CTRL_SHIFT || flags == KEY_CTRL_ALT)
    {
        code = (unsigned char)toupper(code);

        if (code == 'O')
            return noteExecCommand(CMD_OPEN);

        if (code == 'S')
        {
            if (flags == KEY_CTRL_ALT)
                return noteExecCommand(CMD_SAVE_AS);
            return noteExecCommand(CMD_SAVE);
        }

        if (code == 'C')
            return noteExecCommand(CMD_COPY);

        if (code == 'V')
            return noteExecCommand(CMD_PASTE);

        if (code == 'X')
            return noteExecCommand(CMD_EXIT);

        if (code == 'F')
            return noteExecCommand(CMD_FIND);

        if (code == 'G')
            return noteExecCommand(CMD_GOTO_LINE);

        if (code == 'H')
            return noteExecCommand(CMD_REPLACE);

        if (code == 'L')
            return noteExecCommand(CMD_FIND_AGAIN);

        if (code == 'R')
            return noteExecCommand(CMD_RUN);

        return 1;
    }

    if (flags == KEY_ALT)
    {
        code = (unsigned char)toupper(code);
        if (code == 'X')
            return noteExecCommand(CMD_EXIT);

        return 1;
    }

    if (flags != 0)
        return 1;

    if (code == KEY_ESC)
    {
        if (noteSelSelecting || noteSelActive || noteBlockArmed)
        {
            noteClearSelection();
            noteSetMessage((unsigned char *)"Block canceled");
            return 1;
        }

        return noteExecCommand(CMD_EXIT);
    }

    if (code == KEY_LEFT)
    {
        if (noteCurCol > 0)
            noteCurCol--;
        else if (noteCurLine > 0)
        {
            noteCurLine--;
            noteCurCol = noteLineLen(noteCurLine);
        }

        noteEnsureCursorVisible();
        return 1;
    }

    if (code == KEY_RIGHT)
    {
        len = noteLineLen(noteCurLine);
        if (noteCurCol < len)
            noteCurCol++;
        else if (noteCurLine + 1 < noteLineCount)
        {
            noteCurLine++;
            noteCurCol = 0;
        }

        noteEnsureCursorVisible();
        return 1;
    }

    if (code == KEY_UP)
    {
        if (noteCurLine > 0)
            noteCurLine--;

        len = noteLineLen(noteCurLine);
        if (noteCurCol > len)
            noteCurCol = len;

        noteEnsureCursorVisible();
        return 1;
    }

    if (code == KEY_DOWN)
    {
        if (noteCurLine + 1 < noteLineCount)
            noteCurLine++;

        len = noteLineLen(noteCurLine);
        if (noteCurCol > len)
            noteCurCol = len;

        noteEnsureCursorVisible();
        return 1;
    }

    if (code == KEY_HOME)
    {
        noteCurCol = 0;
        noteEnsureCursorVisible();
        return 1;
    }

    if (code == KEY_BACKSPACE)
    {
        if (noteSelActive)
        {
            noteCutSelection();
            noteClearSelection();
        }
        else
            noteBackspace();
        return 1;
    }

    if (code == KEY_DELETE)
    {
        if (noteSelActive)
        {
            noteCutSelection();
            noteClearSelection();
        }
        else
            noteDelete();
        return 1;
    }

    if (code == KEY_ENTER)
    {
        if (noteSelActive)
        {
            noteCutSelection();
            noteClearSelection();
        }
        noteInsertCRLF();
        return 1;
    }

    if (code >= 0x20 && code < 0x7F)
    {
        if (noteSelActive)
        {
            noteCutSelection();
            noteClearSelection();
        }

        noteInsertChar(code);
        return 1;
    }

    return 1;
}

//-----------------------------------------------------------------------------
static unsigned char notePopupMenu(unsigned char menuId)
{
    MGUI_SAVESCR pop;
    MGUI_MOUSE m;
    unsigned char prevBtn;
    unsigned short x;
    unsigned short y;
    unsigned short w;
    unsigned short h;
    unsigned short i;
    unsigned short itemY;
    unsigned short count;
    unsigned char cmd;
    const unsigned char *items[6];

    prevBtn = 0;
    cmd = CMD_NONE;

    if (menuId == MENU_FILES)
    {
        items[0] = (unsigned char *)"Open     Ctrl+O";
        items[1] = (unsigned char *)"Save     Ctrl+S";
        items[2] = (unsigned char *)"Save As  Ctrl+Alt+S";
        items[3] = (unsigned char *)"Exit     Ctrl+X";
        count = 4;
        x = 4;
    }
    else if (menuId == MENU_EDIT)
    {
        items[0] = (unsigned char *)"Copy     Ctrl+C";
        items[1] = (unsigned char *)"Paste    Ctrl+V";
        items[2] = (unsigned char *)"Cut";
        items[3] = (unsigned char *)"Go Line  Ctrl+G";
        count = 4;
        if (noteIsBasFile())
        {
            items[4] = (unsigned char *)"Run      Ctrl+R";
            count = 5;
        }
        x = 46;
    }
    else if (menuId == MENU_SEARCH)
    {
        items[0] = (unsigned char *)"Find      Ctrl+F";
        items[1] = (unsigned char *)"Replace   Ctrl+H";
        items[2] = (unsigned char *)"FindAgain Ctrl+L";
        count = 3;
        x = 84;
    }
    else
    {
        items[0] = (unsigned char *)"About";
        count = 1;
        x = 134;
    }

    y = NOTE_MENU_Y + NOTE_MENU_H + 2;
    w = 126;
    h = (unsigned short)(count * 10 + 6);

    SaveScreenNew(&pop, x, y, w, h);

    FillRect(x, y, w, h, nvcorbg);
    DrawRect(x, y, w, h, nvcorfg);

    for (i = 0; i < count; i++)
    {
        itemY = (unsigned short)(y + 3 + (i * 10));
        writesxy((unsigned short)(x + 4), itemY, 1, (unsigned char *)items[i], nvcorfg, nvcorbg);
    }

    while (1)
    {
        unsigned int keyRaw;
        unsigned char keyCode;

        getMouseData(0, &m);
        getMouseData(1, &m);
        keyRaw = (unsigned int)mguiListWindows[6].keyTec;
        keyCode = (unsigned char)(keyRaw & 0xFF);

        if (keyCode == KEY_ESC)
            break;

        if (m.mouseButton == 0x01 && prevBtn != 0x01)
        {
            if (m.vpostx >= x && m.vpostx <= x + w && m.vposty >= y && m.vposty <= y + h)
            {
                i = (unsigned short)((m.vposty - y - 3) / 10);
                if (i < count)
                {
                    if (menuId == MENU_FILES)
                    {
                        if (i == 0) cmd = CMD_OPEN;
                        if (i == 1) cmd = CMD_SAVE;
                        if (i == 2) cmd = CMD_SAVE_AS;
                        if (i == 3) cmd = CMD_EXIT;
                    }
                    else if (menuId == MENU_EDIT)
                    {
                        if (i == 0) cmd = CMD_COPY;
                        if (i == 1) cmd = CMD_PASTE;
                        if (i == 2) cmd = CMD_CUT;
                        if (i == 3) cmd = CMD_GOTO_LINE;
                        if (i == 4) cmd = CMD_RUN;
                    }
                    else if (menuId == MENU_SEARCH)
                    {
                        if (i == 0) cmd = CMD_FIND;
                        if (i == 1) cmd = CMD_REPLACE;
                        if (i == 2) cmd = CMD_FIND_AGAIN;
                    }
                    else if (menuId == MENU_HELP)
                    {
                        if (i == 0) cmd = CMD_ABOUT;
                    }

                    break;
                }
            }
            else
            {
                break;
            }
        }

        prevBtn = m.mouseButton;
    }

    RestoreScreen(&pop);
    return cmd;
}

//-----------------------------------------------------------------------------
static unsigned char noteExecCommand(unsigned char cmd)
{
    unsigned char findTxt[NOTE_INPUT_MAX];

    if (cmd == CMD_OPEN)
    {
        noteOpenPrompt();
        return 1;
    }

    if (cmd == CMD_SAVE)
    {
        noteSaveCurrent();
        return 1;
    }

    if (cmd == CMD_SAVE_AS)
    {
        noteSaveAsPrompt();
        return 1;
    }

    if (cmd == CMD_EXIT)
        return noteExitRequest() ? 0 : 1;

    if (cmd == CMD_COPY)
    {
        noteCopySelection();
        return 1;
    }

    if (cmd == CMD_PASTE)
    {
        notePasteClipboard();
        return 1;
    }

    if (cmd == CMD_CUT)
    {
        noteCutSelection();
        return 1;
    }

    if (cmd == CMD_FIND)
    {
        findTxt[0] = 0;
        if (notePromptStatus((unsigned char *)"Find: ", findTxt, sizeof(findTxt)))
        {
            if (findTxt[0] != 0)
            {
                strncpy((char *)noteSearchText, (char *)findTxt, sizeof(noteSearchText) - 1);
                noteSearchText[sizeof(noteSearchText) - 1] = 0;
                noteFindNext(noteSearchText, 0);
            }
        }
        return 1;
    }

    if (cmd == CMD_REPLACE)
    {
        noteReplaceNext();
        return 1;
    }

    if (cmd == CMD_FIND_AGAIN)
    {
        noteFindNext(noteSearchText, 1);
        return 1;
    }

    if (cmd == CMD_GOTO_LINE)
    {
        noteGotoLinePrompt();
        return 1;
    }

    if (cmd == CMD_RUN)
    {
        noteRunBasicFile();
        return 1;
    }

    if (cmd == CMD_ABOUT)
    {
        message("Note Editor MGUI v1.0\0", BTCLOSE, 0);
        return 1;
    }

    return 1;
}
