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
*   Cursor Cima    (0x11) : Rola texto para cima  1 linha
*   Cursor Baixo   (0x13) : Rola texto para baixo 1 linha
*   Cursor Esquerda(0x12) : Rola texto para esquerda 1 coluna
*   Cursor Direita (0x14) : Rola texto para direita  1 coluna
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
#include "monitorapi.h"
#include "mmsjosapi.h"
#include "mmsj320api.h"
#include "note.h"

#ifdef USE_REALOCABLE_CODE
char *itoa(int value, char *str, int base);
char *ltoa(long value, char *str, int base);
#endif
    
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
    unsigned long vMemLines;
    unsigned long voffset, vch;
    unsigned long vsizefile;
    unsigned short vReadSize;

    // --- Atribuicao de ponteiros de funcao locais ---
    #ifdef USE_REALOCABLE_CODE
    drawNote        = drawNoteDef;
    displayNotePage = displayNotePageDef;
    drawScrollBar   = drawScrollBarDef;
    nmystrcpy       = strcpy;
    nmymemset       = memset;
    nmyitoa         = itoa;
    #endif

    // --- Inicializa variaveis ---
    getColorData(&vdpcolor);
    nvcorfg = vdpcolor.fg;
    nvcorbg = vdpcolor.bg;

    noteTopLine   = 0;
    noteHOffset   = 0;
    noteLineCount = 0;
    noteTextBuf   = 0;
    noteLines     = 0;
    noteBufSize   = 0;

    TrocaSpriteMouse(MOUSE_HOURGLASS);
    SaveScreenNew(&windowScr, 0, 0, 255, 191);

    // --- Carrega o arquivo indicado em paramBasic ---
    if (*paramBasic != 0x00)
    {
        vsizefile = fsInfoFile(paramBasic, INFO_SIZE);

        if (vsizefile > 0 && vsizefile != ERRO_D_NOT_FOUND)
        {
            // Limita a 32KB para seguranca
            if (vsizefile > 32768)
                vsizefile = 32768;

            noteBufSize = vsizefile;

            noteTextBuf = fsMalloc(noteBufSize + 1);

            if (noteTextBuf)
            {
                // Le o arquivo em blocos de 512 bytes
                voffset = 0;
                while (voffset < noteBufSize)
                {
                    vReadSize = 512;
                    if (voffset + vReadSize > noteBufSize)
                        vReadSize = (unsigned short)(noteBufSize - voffset);

                    fsReadFile(paramBasic, voffset, noteTextBuf + voffset, vReadSize);
                    voffset = voffset + vReadSize;
                }

                // Garante terminador nulo
                *(noteTextBuf + noteBufSize) = 0x00;
            }
        }
    }

    // --- Aloca array de indices de linhas ---
    vMemLines = fsMalloc(NOTE_MAX_LINES * 4);   // 4 bytes por unsigned long no M68K
    noteLines = vMemLines;

    // --- Indexa as linhas do arquivo ---
    if (noteTextBuf && noteLines && noteBufSize > 0)
    {
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
            getMouseData(&mouseData);
            vtec = readChar();

            // --- Tratamento de Teclado ---
            if (vtec == 0x1B)               // ESC: fecha
            {
                vcont = 0;
                break;
            }
            else if (vtec == 0x11)          // Cursor Cima: rola 1 linha para cima
            {
                if (noteTopLine > 0)
                {
                    noteTopLine--;
                    displayNotePage();
                    drawScrollBar();
                }
            }
            else if (vtec == 0x13)          // Cursor Baixo: rola 1 linha para baixo
            {
                if (noteLineCount > NOTE_VISIBLE &&
                    noteTopLine < noteLineCount - NOTE_VISIBLE)
                {
                    noteTopLine++;
                    displayNotePage();
                    drawScrollBar();
                }
            }
            else if (vtec == 0x12)          // Cursor Esquerda: rola 1 coluna para esquerda
            {
                if (noteHOffset > 0)
                {
                    noteHOffset--;
                    displayNotePage();
                }
            }
            else if (vtec == 0x14)          // Cursor Direita: rola 1 coluna para direita
            {
                noteHOffset++;
                displayNotePage();
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
                    drawScrollBar();
                }
            }

            OSTimeDlyHMSM(0, 0, 0, 50);
        } // while(1) inner

        if (vcont)
            OSTimeDlyHMSM(0, 0, 0, 50);
    } // while(vcont)

    // --- Encerra ---
    TrocaSpriteMouse(MOUSE_HOURGLASS);

    if (noteLines)
        fsFree((unsigned long)noteLines);

    if (noteTextBuf)
        fsFree((unsigned long)noteTextBuf);

    RestoreScreen(windowScr);

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

    // Janela cheia
    showWindow("Note Viewer v0.1\0", 0, 0, 255, 191, BTNONE);

    // Linha separadora acima do botao
    DrawLine(0, NOTE_CLOSE_Y - 4, 255, NOTE_CLOSE_Y - 4, nvcorfg);

    // Botao Close
    button("Close", NOTE_CLOSE_X, NOTE_CLOSE_Y, NOTE_CLOSE_W, NOTE_CLOSE_H, WINDISP);

    // Se nao ha arquivo, exibe mensagem na area de texto
    if (!noteTextBuf || noteLineCount == 0)
    {
        writesxy(NOTE_TEXT_X, NOTE_Y_TEXT + 20, 8, "No file to display.\0", nvcorfg, nvcorbg);
        return;
    }

    // Exibe conteudo e scrollbar
    displayNotePage();
    drawScrollBar();
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
    unsigned short line, col, ly;
    unsigned long lpos;

    // Limpa area de texto (sem tocar a scrollbar)
    FillRect(0, NOTE_Y_TEXT, NOTE_SCRL_X - 1, NOTE_VISIBLE * NOTE_LINE_H, nvcorbg);

    if (!noteTextBuf || noteLineCount == 0)
        return;

    for (line = 0; line < NOTE_VISIBLE; line++)
    {
        ly = NOTE_Y_TEXT + (line * NOTE_LINE_H);

        if ((noteTopLine + line) >= noteLineCount)
            break;

        // Ponteiro para inicio desta linha no buffer
        lpos = noteLines[noteTopLine + line];
        p    = noteTextBuf + lpos;

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
        linebuf[col] = 0x00;

        if (col > 0)
            writesxy(NOTE_TEXT_X, ly, 8, linebuf, nvcorfg, nvcorbg);
    }
}

//-----------------------------------------------------------------------------
// Desenha a barra de rolagem vertical com indicador de posicao (thumb)
//-----------------------------------------------------------------------------
#ifdef USE_REALOCABLE_CODE
void drawScrollBarDef(void)
#else
void drawScrollBar(void)
#endif
{
    unsigned short thumbY, thumbH;
    unsigned short range;
    unsigned long ltmp;

    // Trilha da barra de rolagem
    FillRect(NOTE_SCRL_X, NOTE_SCRL_Y, NOTE_SCRL_W, NOTE_SCRL_H, nvcorbg);
    DrawRect(NOTE_SCRL_X, NOTE_SCRL_Y, NOTE_SCRL_W, NOTE_SCRL_H, nvcorfg);

    // Sem scrollbar se todo o conteudo e visivel
    if (noteLineCount <= NOTE_VISIBLE)
        return;

    range = noteLineCount - NOTE_VISIBLE;

    // --- Calcula altura do thumb ---
    thumbH = NOTE_VISIBLE * NOTE_SCRL_H / noteLineCount;
    if (thumbH < 8)
        thumbH = 8;
    if (thumbH > NOTE_SCRL_H)
        thumbH = NOTE_SCRL_H;

    // --- Calcula posicao Y do thumb ---
    ltmp   = noteTopLine;
    ltmp   = ltmp * (NOTE_SCRL_H - thumbH);
    ltmp   = ltmp / range;
    thumbY = NOTE_SCRL_Y + (unsigned short)ltmp;

    // Garante que nao ultrapassa o limite da trilha
    if (thumbY + thumbH > NOTE_SCRL_Y + NOTE_SCRL_H)
        thumbY = NOTE_SCRL_Y + NOTE_SCRL_H - thumbH;

    // Desenha o thumb
    FillRect(NOTE_SCRL_X + 1, thumbY, NOTE_SCRL_W - 2, thumbH, nvcorfg);
}
