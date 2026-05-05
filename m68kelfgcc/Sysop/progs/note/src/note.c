/********************************************************************************
*    Programa    : note.c
*    Objetivo    : Visualizador de Texto Simples para MMSJOS com MGUI
*    Criado em   : 26/04/2026
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 26/04/2026  0.1     Moacir Jr.   Criacao - Visualizacao somente, scroll mouse/teclado
*--------------------------------------------------------------------------------
*
* Uso: chamar com paramBasic = nome do arquivo a abrir
*
* Teclas:
*   Cursor Cima    (0x18) : Rola texto para cima  1 linha
*   Cursor Baixo   (0x20) : Rola texto para baixo 1 linha
*   Cursor Esquerda(0x17) : Rola texto para esquerda 1 coluna
*   Cursor Direita (0x19) : Rola texto para direita  1 coluna
*   ESC            (0x1B) : Fecha o visualizador
*
* Mouse:
*   Clique na barra de rolagem vertical : pula para a posicao proporcional
*   Clique no botao Close               : fecha o visualizador
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
#define NOTE_LOAD_ADDR     0x00880000UL
#define NOTE_WORK_GAP      256UL
#define NOTE_DEFAULT_PROG_SIZE 5096UL

static unsigned char noteCfgColor[16];
static unsigned long noteLineStorage[NOTE_MAX_LINES];

static unsigned long noteAlign4(unsigned long value)
{
    return (value + 3UL) & 0xFFFFFFFCUL;
}

//-----------------------------------------------------------------------------
// Principal
//-----------------------------------------------------------------------------
void main(void)
{
    MGUI_SAVESCR windowScr;
    MGUI_MOUSE mouseData;
    VDP_COLOR vdpcolor;
    unsigned char vcont, vtec;
    unsigned short clickLine;
    unsigned short range;
    unsigned long voffset, vch;
    unsigned long vsizefile;
    unsigned long vprogsize;
    unsigned short vReadSize;
    unsigned char vParamName[128];
    unsigned char ix;
    unsigned char *vComma;
    unsigned long vaddress;
    unsigned char winFound;

    memset(vParamName, 0x00, sizeof(vParamName));
    if (*paramBasic != 0x00)
        strcpy((char*)vParamName, (char*)paramBasic);

    vComma = (unsigned char *)strrchr((char*)vParamName, ',');

    if (vComma)
    {
        *vComma = 0x00;
        vaddress = atol((char*)(vComma + 1));
    }

    // Define o ID do window
    windowsId = 0xFF;
    winFound = 0;
    for(ix = 0; ix < MGUI_APP_WINDOW_SLOTS; ix++)
    {
        if (mguiListWindows[ix].active && mguiListWindows[ix].loadAddress == vaddress)
        {
            windowsId = ix;
            winFound = 1;
            break;
        }
    }

    if (!winFound)
        return;

    // --- Inicializa variaveis ---
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

    noteTopLine   = 0;
    noteHOffset   = 0;
    noteLineCount = 0;
    noteBufSize   = 0;
    vprogsize     = NOTE_DEFAULT_PROG_SIZE;

    noteTextBuf = msmalloc(NOTE_MAX_FILE_SIZE + 1);
    noteLines = noteLineStorage;

    memset(noteTextBuf, 0x00, NOTE_MAX_FILE_SIZE + 1);
    memset((unsigned char *)noteLines, 0x00, sizeof(noteLineStorage));

    TrocaSpriteMouse(MOUSE_HOURGLASS);
    SaveScreenNew(&windowScr, 0, 0, 255, 191);

    // --- Carrega o arquivo indicado em paramBasic ---
    if (*vParamName != 0x00)
    {
        vsizefile = fsInfoFile(vParamName, INFO_SIZE);

        if (vsizefile > 0 && vsizefile != ERRO_D_NOT_FOUND)
        {
            if (vsizefile > NOTE_MAX_FILE_SIZE)
                vsizefile = NOTE_MAX_FILE_SIZE;

            noteBufSize = vsizefile;

            vsizefile = loadFile(vParamName, (unsigned char *)noteTextBuf);
            if (vsizefile > 0 && vsizefile <= NOTE_MAX_FILE_SIZE)
                noteBufSize = vsizefile;

            // Garante terminador nulo
            *(noteTextBuf + noteBufSize) = 0x00;
        }
    }

    // --- Indexa as linhas do arquivo ---
    if (noteTextBuf && noteLines && noteBufSize > 0)
    {
        calcNoteMaxLineLen(noteBufSize);

        // Primeira linha comeca no offset 0
        noteLines[0] = 0;
        noteLineCount = 1;

        voffset = 0;
        while (voffset < noteBufSize && noteLineCount < NOTE_MAX_LINES)
        {
            vch = *(noteTextBuf + voffset);

            if (vch == 0x0A)        // LF (Unix)
            {
                voffset++;
                if (voffset < noteBufSize)
                {
                    noteLines[noteLineCount] = voffset;
                    noteLineCount++;
                }
            }
            else if (vch == 0x0D)   // CR (Mac) ou CR+LF (Windows)
            {
                voffset++;
                if (voffset < noteBufSize && *(noteTextBuf + voffset) == 0x0A)
                    voffset++;      // Consome o LF do par CR+LF
                if (voffset < noteBufSize)
                {
                    noteLines[noteLineCount] = voffset;
                    noteLineCount++;
                }
            }
            else
            {
                voffset++;
            }
        }
    }

    // --- Desenha janela inicial ---
    drawNote();

    TrocaSpriteMouse(MOUSE_POINTER);

    // --- Loop Principal ---
    vcont = 1;
    while (vcont)
    {
        setPosPressed(0, 0);

        while (1)
        {
            *mguiIdRequest = windowsId;
            getMouseData(0, &mouseData);    // Mouse
            getMouseData(1, &mouseData);    // Teclado
            vtec = mguiListWindows[windowsId].keyTec;

            // --- Tratamento de Teclado ---
            if (vtec == 0x1B)               // ESC: fecha
            {
                vcont = 0;
                break;
            }
            else if (vtec == 0x18)          // Cursor Cima: rola 1 linha para cima
            {
                if (noteTopLine > 0)
                {
                    noteTopLine--;
                    displayNotePage();
                    drawScrollBarV();
                }
            }
            else if (vtec == 0x20)          // Cursor Baixo: rola 1 linha para baixo
            {
                if (noteLineCount > NOTE_VISIBLE &&
                    noteTopLine < noteLineCount - NOTE_VISIBLE)
                {
                    noteTopLine++;
                    displayNotePage();
                    drawScrollBarV();
                }
            }
            else if (vtec == 0x17)          // Cursor Esquerda: rola 1 coluna para esquerda
            {
                if (noteHOffset > 0)
                {
                    noteHOffset--;
                    displayNotePage();
                    drawScrollBarH();
                }
            }
            else if (vtec == 0x19)          // Cursor Direita: rola 1 coluna para direita
            {
                noteHOffset++;
                displayNotePage();
                drawScrollBarH();
            }

            // --- Tratamento de Mouse ---
            if (mouseData.mouseButton == 0x01)   // Botao esquerdo
            {
                // Clique no botao Close
                if (mouseData.vpostx >= NOTE_CLOSE_X &&
                    mouseData.vpostx <= NOTE_CLOSE_X + NOTE_CLOSE_W &&
                    mouseData.vposty >= NOTE_CLOSE_Y &&
                    mouseData.vposty <= NOTE_CLOSE_Y + NOTE_CLOSE_H)
                {
                    vcont = 0;
                    break;
                }

                // Clique na barra de rolagem vertical
                if (mouseData.vpostx >= NOTE_SCRL_X &&
                    mouseData.vpostx <= NOTE_SCRL_X + NOTE_SCRL_W &&
                    mouseData.vposty >= NOTE_SCRL_Y &&
                    mouseData.vposty <= NOTE_SCRL_Y + NOTE_SCRL_H &&
                    noteLineCount > NOTE_VISIBLE)
                {
                    // Mapeia a posicao do click para o numero de linha
                    range = noteLineCount - NOTE_VISIBLE;
                    clickLine = (unsigned short)(
                        (unsigned long)(mouseData.vposty - NOTE_SCRL_Y) * range / NOTE_SCRL_H
                    );

                    if (clickLine >= noteLineCount - NOTE_VISIBLE)
                        clickLine = noteLineCount - NOTE_VISIBLE - 1;

                    noteTopLine = clickLine;
                    displayNotePage();
                    drawScrollBarV();
                }

                // Clique na barra de rolagem horizontal
                if (mouseData.vpostx >= NOTE_SCRL_H_X &&
                    mouseData.vpostx <= NOTE_SCRL_H_X + NOTE_SCRL_H_W &&
                    mouseData.vposty >= NOTE_SCRL_H_Y &&
                    mouseData.vposty <= NOTE_SCRL_H_Y + NOTE_SCRL_H_H &&
                    noteMaxLineLen > NOTE_CHARS_LINE)
                {
                    // Mapeia a posicao do click para o numero de coluna
                    range = noteMaxLineLen - NOTE_CHARS_LINE;
                    clickLine = (unsigned short)(
                        (unsigned long)(mouseData.vpostx - NOTE_SCRL_H_X) * range / NOTE_SCRL_H_W
                    );

                    if (clickLine >= noteMaxLineLen - NOTE_CHARS_LINE)
                        clickLine = noteMaxLineLen - NOTE_CHARS_LINE - 1;

                    noteHOffset = clickLine;
                    displayNotePage();
                    drawScrollBarH();
                }
            }

            OSTimeDlyHMSM(0, 0, 0, 50);
        } // while(1) inner

        if (vcont)
            OSTimeDlyHMSM(0, 0, 0, 50);
    } // while(vcont)

    // --- Encerra ---
    TrocaSpriteMouse(MOUSE_HOURGLASS);

    RestoreScreen(&windowScr);

    TrocaSpriteMouse(MOUSE_POINTER);
}

//-----------------------------------------------------------------------------
// Desenha a janela completa (titulo, area de texto, botao, scrollbar)
//-----------------------------------------------------------------------------
#ifdef USE_REALOCABLE_CODE
void drawNoteDef(void)
#else
void drawNote(void)
#endif
{
    unsigned char titleBuf[32];
    unsigned char *pParam;
    unsigned char ix;
    unsigned char vbuttonmess[16];
    unsigned char bbutton = BTCLOSE;

    // Janela cheia
    showWindow("Note Viewer v0.1\0", 0, 0, 255, 191, BTNONE);

    // Linha separadora acima do botao
    DrawLine(0, NOTE_CLOSE_Y - 4, 255, NOTE_CLOSE_Y - 4, nvcorfg);

    // Botao Close
    vbuttonmess[15] = NOTE_CLOSE_Y;
    drawButtonsnew(&vbuttonmess, &bbutton, NOTE_CLOSE_X, NOTE_CLOSE_Y);

//    button("Close", NOTE_CLOSE_X, NOTE_CLOSE_Y, NOTE_CLOSE_W, NOTE_CLOSE_H, WINDISP);

    // Se nao ha arquivo, exibe mensagem na area de texto
    if (!noteTextBuf || noteLineCount == 0)
    {
        writesxy(NOTE_TEXT_X, NOTE_Y_TEXT + 20, 8, "No file to display.\0", nvcorfg, nvcorbg);
        return;
    }

    // Exibe conteudo e scrollbar
    displayNotePage();
    drawScrollBarV();
    drawScrollBarH();
}

//-----------------------------------------------------------------------------
// Exibe as linhas visiveis a partir de noteTopLine com offset noteHOffset
//-----------------------------------------------------------------------------
#ifdef USE_REALOCABLE_CODE
void displayNotePageDef(void)
#else
void displayNotePage(void)
#endif
{
    unsigned char linebuf[42];  // NOTE_CHARS_LINE + 2 de margem
    unsigned char *p;
    unsigned char vch;
    unsigned short line, col, ly, ix;
    unsigned long lpos;

    if (!noteTextBuf || noteLineCount == 0)
        return;

    noteMaxLineLen = 0;

    for (line = 0; line < NOTE_VISIBLE; line++)
    {
        ly = NOTE_Y_TEXT + (line * NOTE_LINE_H);

        // Preenche linha inteira com espacos para sobrescrever lixo residual
        for (ix = 0; ix < NOTE_CHARS_LINE; ix++)
            linebuf[ix] = 0x20;
        linebuf[NOTE_CHARS_LINE] = 0x00;

        if ((noteTopLine + line) >= noteLineCount)
        {
            writesxy(NOTE_TEXT_X, ly, 8, linebuf, nvcorfg, nvcorbg);
            continue;
        }

        // Ponteiro para inicio desta linha no buffer
        lpos = noteLines[noteTopLine + line];
        p    = noteTextBuf + lpos;

        // Calcula tamanho REAL da linha
        col = 0;
        while (1)
        {
            vch = p[col];

            if (!vch || vch == 0x0A || vch == 0x0D)
                break;

            col++;
        }

        if (col > noteMaxLineLen)
            noteMaxLineLen = col;

        // Avanca noteHOffset colunas (scroll horizontal)
        col = 0;
        while (col < noteHOffset)
        {
            vch = *p;
            if (!vch || vch == 0x0A || vch == 0x0D)
                break;
            col++;
            p++;
        }

        // Copia ate NOTE_CHARS_LINE caracteres para o buffer de linha
        col = 0;
        while (col < NOTE_CHARS_LINE)
        {
            vch = *p;
            if (!vch || vch == 0x0A || vch == 0x0D)
                break;

            if (vch == 0x09)            // TAB -> espaco
                vch = 0x20;
            else if (vch < 0x20 || vch >= 0x7F)
                vch = 0x20;             // Nao imprimivel -> espaco

            linebuf[col] = vch;

            col++;
            p++;
        }

        writesxy(NOTE_TEXT_X, ly, 8, linebuf, nvcorfg, nvcorbg);
    }
}

//-----------------------------------------------------------------------------
// Desenha a barra de rolagem vertical com indicador de posicao (thumb)
//-----------------------------------------------------------------------------
#ifdef USE_REALOCABLE_CODE
void drawScrollBarVDef(void)
#else
void drawScrollBarV(void)
#endif
{
    unsigned short thumbY, thumbH;
    unsigned short range;
    unsigned long ltmp;
    unsigned int noteVisibleAux = NOTE_VISIBLE;
    unsigned int noteScrlHAux = NOTE_SCRL_H;
    unsigned int noteScrlWAux = NOTE_SCRL_W;
    unsigned int noteScrlXAux = NOTE_SCRL_X;
    unsigned int noteScrlYAux = NOTE_SCRL_Y;    
    unsigned char sqtdtam[10];

    // Trilha da barra de rolagem
    FillRect(noteScrlXAux, noteScrlYAux, noteScrlWAux, noteScrlHAux, nvcorbg);
    DrawRect(noteScrlXAux, noteScrlYAux, noteScrlWAux, noteScrlHAux, nvcorfg);

    // Sem scrollbar se todo o conteudo e visivel
    if (noteLineCount <= noteVisibleAux)
        return;

    range = noteLineCount - noteVisibleAux;
    if (range == 0 || noteLineCount == 0)
        return;

    if (noteTopLine > range)
        noteTopLine = range;

    // --- Calcula altura do thumb ---
    thumbH = (noteVisibleAux * noteScrlHAux) / noteLineCount;
    if (thumbH < 8)
        thumbH = 8;
    if (thumbH > noteScrlHAux)
        thumbH = noteScrlHAux;

    // --- Calcula posicao Y do thumb ---
    ltmp   = noteTopLine;
    ltmp   = ltmp * (noteScrlHAux - thumbH);
    ltmp   = ltmp / range;
    thumbY = noteScrlYAux + (unsigned short)ltmp;

    // Garante que nao ultrapassa o limite da trilha
    if (thumbY + thumbH > noteScrlYAux + noteScrlHAux)
        thumbY = noteScrlYAux + noteScrlHAux - thumbH;

    // Desenha o thumb
    FillRect(noteScrlXAux + 1, thumbY, noteScrlWAux - 2, thumbH, nvcorfg);
}

//-----------------------------------------------------------------------------
// Desenha a barra de rolagem horizontal com indicador de posicao (thumb)
//-----------------------------------------------------------------------------
#ifdef USE_REALOCABLE_CODE
void drawScrollBarHDef(void)
#else
void drawScrollBarH(void)
#endif
{
    unsigned short thumbX;
    unsigned short thumbW;
    unsigned short range;
    unsigned long ltmp;

    unsigned int noteVisibleAux;
    unsigned int noteScrlHAux;
    unsigned int noteScrlWAux;
    unsigned int noteScrlXAux;
    unsigned int noteScrlYAux;

    noteVisibleAux = NOTE_CHARS_LINE;

    noteScrlHAux = NOTE_SCRL_H_H;
    noteScrlWAux = NOTE_SCRL_H_W;
    noteScrlXAux = NOTE_SCRL_H_X;
    noteScrlYAux = NOTE_SCRL_H_Y;

    FillRect(noteScrlXAux, noteScrlYAux, noteScrlWAux, noteScrlHAux, nvcorbg);
    DrawRect(noteScrlXAux, noteScrlYAux, noteScrlWAux, noteScrlHAux, nvcorfg);

    if (noteMaxLineLen <= noteVisibleAux)
    {
        noteHOffset = 0;
        return;
    }

    range = noteMaxLineLen - noteVisibleAux;

    if (noteHOffset > range)
        noteHOffset = range;

    thumbW = (noteVisibleAux * noteScrlWAux) / noteMaxLineLen;

    if (thumbW < 8)
        thumbW = 8;

    if (thumbW > noteScrlWAux)
        thumbW = noteScrlWAux;

    ltmp = noteHOffset;
    ltmp = ltmp * (noteScrlWAux - thumbW);
    ltmp = ltmp / range;

    thumbX = noteScrlXAux + (unsigned short)ltmp;

    if (thumbX + thumbW > noteScrlXAux + noteScrlWAux)
        thumbX = noteScrlXAux + noteScrlWAux - thumbW;

    FillRect(thumbX, noteScrlYAux + 1, thumbW, noteScrlHAux - 2, nvcorfg);
}

//-----------------------------------------------------------------------------
// Calcula linha mais longa do arquivo (em caracteres) para determinar
//necessidade de scroll horizontal
//-----------------------------------------------------------------------------
void calcNoteMaxLineLen(unsigned long fileSize)
{
    unsigned long i;
    unsigned short col;
    unsigned char vch;

    noteMaxLineLen = 0;
    col = 0;

    for (i = 0; i < fileSize; i++)
    {
        vch = noteTextBuf[i];

        if (vch == 0x0D || vch == 0x0A || vch == 0x00)
        {
            if (col > noteMaxLineLen)
                noteMaxLineLen = col;

            col = 0;

            /*
               Se arquivo for CRLF, pula o LF depois do CR
            */
            if (vch == 0x0D && (i + 1) < fileSize)
            {
                if (noteTextBuf[i + 1] == 0x0A)
                    i++;
            }
        }
        else
        {
            col++;
        }
    }

    /*
       Última linha pode não terminar com CR/LF
    */
    if (col > noteMaxLineLen)
        noteMaxLineLen = col;
}
