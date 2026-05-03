/********************************************************************************
*    Programa    : mgui.c
*    Objetivo    : MMSJ300 Graphical User Interface
*    Criado em   : 25/07/2023
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 25/07/2023  0.1     Moacir Jr.   Criacao Versao Beta
*    ...       ...       ...            ...
* 03/01/2025  0.5a    Moacir Jr.   Troca de cores e ajustes de tela
* 19/01/2025  0.6     Moacir Jr.   Adaptar para rodar junto com o MMSJOS
* 13/04/2026  0.7a03  Moacir Jr.   Ajustes para o mouse e o sprite do ponteiro
*--------------------------------------------------------------------------------
*
*--------------------------------------------------------------------------------
* To do
*
*--------------------------------------------------------------------------------
*
*********************************************************************************/
//#define USE_MALLOC
#include <ucos_ii.h>
#include <ctype.h>
#include <string.h>
#ifdef USE_MALLOC
#include <malloc.h>
#endif
#ifndef USE_MALLOC
// 128KB Save Screen - 0x0083FFFF
#define ADDR_SAVE_SCR   0x00820000 
// 128KB Load Files Diversos - 0x0085FFFF
#define ADDR_LOAD_FILE  0x00840000
// 64KB Diversos - 0x0086FFFF
#define ADDR_LOAD_ICONS 0x00860000
// 64KB Load Files.bin - 0x0087FFFF
#define ADDR_EXEC_FILES 0x00870000
// 256KB Load App's - 0x008CFFFF
#define ADDR_EXEC_PROG  0x00880000
#endif
#include <stdlib.h>
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "mmsjos.h"
#include "monitor.h"
#include "monitorapi.h"
#include "mgui.h"

// Variaveis definidas em mmsj320api.h (incluido pelo mmsjos.c).
// Declaradas aqui como extern para evitar multipla definicao.
extern unsigned char *startBasic;
extern unsigned long *startBasic0;
extern unsigned long *startBasic1;
extern unsigned long *startBasic2;
extern unsigned long *startBasic3;
extern unsigned long *startBasic4;
extern unsigned long *startBasic5;
extern unsigned char *paramBasic;

SaveScreenSlot ssSlots[SS_MAX_BLOCKS];
unsigned int ssNextId = 1;

typedef struct LIST_WINDOWS
{
    int id;
    unsigned long loadAddress;
    char zOrder;
    char active;
    int keyTec;
} LIST_WINDOWS; 

extern unsigned char *mguiIdRequest;
extern unsigned long *mguiRunTask;
extern LIST_WINDOWS *mguiListWindows;

#define versionMgui "0.7a03"
#define __EM_OBRAS__ 1

unsigned char *vvdgd = 0x00400041; // VDP TMS9118 Data Mode
unsigned char *vvdgc = 0x00400043; // VDP TMS9118 Registers/Address Mode

unsigned char *memPosConfig = 0x008EF800; // Config file
unsigned char *imgsMenuSys = 0x00; // Images PBM 16x16 each icone in order (64 Bytes Each)
unsigned char vFinalOS; // Atualizar sempre que a compilacao passar desse valor
unsigned char vcorwf; //
unsigned char vcorwb; //
unsigned char vcorwb2; //
unsigned long mousePointer;
unsigned int spthdlmouse;
unsigned int mouseX;
unsigned char mouseY;
unsigned char mouseStat;
char mouseMoveX;
char mouseMoveY;
unsigned char mouseBtnPres;
unsigned char mouseBtnPresDouble;
unsigned char statusVdpSprite;
unsigned long mouseHourGlass;
unsigned long iconesMenuSys;
unsigned char vbbutton;
unsigned short vpostx;
unsigned short vposty;
unsigned short pposx;
unsigned short pposy;
unsigned short vxgmax;
unsigned char vbuttonwin[32];
unsigned short vbuttonwiny;
unsigned int mgui_pattern_table;
unsigned int mgui_color_table;
unsigned long mguiVideoFontes;
unsigned char fgcolorMgui;
unsigned char bgcolorMgui;
unsigned short mx, my, menyi[8], menyf[8];
MGUI_SAVESCR endSaveMenu;
unsigned char vIndicaDialog = 0;

#define MGUI_WT_FILLIN   1
#define MGUI_WT_BUTTON   2
#define MGUI_WT_RADIO    3
#define MGUI_WT_TOGGLE   4

typedef struct
{
    unsigned char id;
    unsigned char type;
} MGUI_WIDGET_FOCUS;

static MGUI_WIDGET_FOCUS mguiWidgetFocus[24];
static unsigned char mguiWidgetCount = 0;
static unsigned char mguiWidgetOnFocusIdx = 0;
static unsigned char mguiWidgetLeaveFocusIdx = 255;
static unsigned char mguiWidgetTabLatch = 0;
//static unsigned char mguiWidgetWinfullLatch = 0;

static void mguiWidgetFocusReset(void)
{
    mguiWidgetCount = 0;
    mguiWidgetOnFocusIdx = 0;
    mguiWidgetLeaveFocusIdx = 255;
    mguiWidgetTabLatch = 0;
}

static char mguiWidgetRegister(unsigned char id, unsigned char type)
{
/*    unsigned char i;

    for (i = 0; i < mguiWidgetCount; i++)
    {
        if (mguiWidgetFocus[i].id == id)
            return i;
    }

    if (mguiWidgetCount < 24)
    {
        if (mguiWidgetCount == 0)
            mguiWidgetOnFocusIdx = 0;  // primeiro widget registrado e o foco default*/

        if (id > mguiWidgetCount)
            mguiWidgetCount = id;

        mguiWidgetFocus[id].id = id;
        mguiWidgetFocus[id].type = type;

        return (id);
    //}

    return -1;
}

//-------------------------------------------------------------------------
// Estrutura retornada por mguiWidgetProcess
//   key     : tecla ASCII pressionada (KEY_NONE se nenhuma; TAB ja consumido)
//   clicked : 1 se houve clique do mouse dentro do widget
//   focused : 1 se este widget esta com o foco apos o processamento
//-------------------------------------------------------------------------
typedef struct {
    unsigned char key;
    unsigned char clicked;
    unsigned char focused;
} MGUI_INPUT;

static MGUI_INPUT mguiWidgetProcess(unsigned char thisIdx,
                                    unsigned short wx, unsigned short wy,
                                    unsigned short ww,  unsigned short wh,
                                    unsigned char vtipo)
{
    MGUI_INPUT result;
    MMSJ_KEYEVENT k;
    MGUI_MOUSE vmouseData;
    unsigned char reqWin;
    unsigned char stqdtam[20];

    result.key     = KEY_NONE;
    result.clicked = 0;
    result.focused = 0;

    // Mouse: clique dentro do widget => toma o foco
    getMouseData(0, &vmouseData);   // Pega Mouse
    if (vmouseData.mouseButton == 0x01 &&
        vmouseData.vpostx >= wx && vmouseData.vpostx <= (wx + ww) &&
        vmouseData.vposty >= wy && vmouseData.vposty <= (wy + wh))
    {
        mguiWidgetOnFocusIdx = thisIdx;
        result.clicked = 1;
    }

    result.focused = (thisIdx == mguiWidgetOnFocusIdx) ? 1 : 0;

    if (result.clicked)
        return result;

    if (result.focused)
        getMouseData(1, &vmouseData);   // Pega Teclado

    if ((vtipo == WINOPER || vtipo == WINFULL) && result.focused)
    {
        // Leitura de tecla: tenta mmsjKeyGet primeiro, depois keyTec da janela
        if (result.key == KEY_NONE)
        {
            reqWin = *mguiIdRequest;
            if (reqWin > 6) 
                reqWin = 6;
            result.key = (unsigned char)(mguiListWindows[reqWin].keyTec & 0xFF);

        }

        // TAB: avanca foco e consome a tecla
        if (result.key == 0x09 && mguiWidgetCount > 0)
        {
            if (!mguiWidgetTabLatch)
            {
                mguiWidgetOnFocusIdx++;
                if (mguiWidgetOnFocusIdx > mguiWidgetCount)
                    mguiWidgetOnFocusIdx = 0;
                mguiWidgetTabLatch = 1;
            }
            result.key    = KEY_NONE;
            result.focused = 0;
        }
        else if (result.key == 0x0D && mguiWidgetCount > 0)
        {
            if (mguiWidgetFocus[thisIdx].type != MGUI_WT_FILLIN)
            {
                result.clicked = 1;
            }
        }
        else
        {
            mguiWidgetTabLatch = 0;
        }
    }

    return result;
}

extern HEADER *_allocp;

#define STACKSIZE  1024
#define STACKSIZEMGUI  2048
#define STACKSIZEMOUSE  2048
#define STACKSIZEMENU  1024

extern OS_STK StkInput[STACKSIZE];
OS_STK StkFiles[STACKSIZEMGUI];
OS_STK StkMouse[STACKSIZEMOUSE];
OS_STK StkMenu[STACKSIZEMENU];
OS_STK StkMessage[STACKSIZE];   // Dialog, só pode ter uma por vez

extern OS_EVENT *shared_sem;

void mouseTask (void *pData);
void menuTask (void *pData);
void messageTask (void *pData);
void runBin(void);

//-----------------------------------------------------------------------------
void clearScrW(unsigned char color)
{
    unsigned int ix, iy;

    color &= 0x0F;

    setWriteAddress(mgui_pattern_table);
    for (iy = 0; iy < 192; iy++)
    {
        for (ix = 0; ix < 32; ix++)
            *vvdgd = 0x00;
    }
    setWriteAddress(mgui_color_table);
    for (iy = 0; iy < 192; iy++)
    {
        for (ix = 0; ix < 32; ix++)
            *vvdgd = color;
    }
}

//-----------------------------------------------------------------------------
// VDP Functions
//-----------------------------------------------------------------------------
void vdp_set_cursor_pos_gui(unsigned char direction)
{
    unsigned char pMoveIdX = 6, pMoveIdY = 8;
    VDP_COORD vcursor;

    vcursor = vdp_get_cursor_safe();

    switch (direction)
    {
        case VDP_CSR_UP:
            vdp_set_cursor(vcursor.x, vcursor.y - pMoveIdY);
            break;
        case VDP_CSR_DOWN:
            vdp_set_cursor(vcursor.x, vcursor.y + pMoveIdY);
            break;
        case VDP_CSR_LEFT:
            vdp_set_cursor(vcursor.x - pMoveIdX, vcursor.y);
            break;
        case VDP_CSR_RIGHT:
            vdp_set_cursor(vcursor.x + pMoveIdX, vcursor.y);
            break;
    }
}

//-----------------------------------------------------------------------------
void vdp_write_gui(unsigned char chr)
{
    unsigned int name_offset; // Position in name table
    unsigned int pattern_offset;                    // Offset of pattern in pattern table
    unsigned short i, ix, iy, xf;
    unsigned short vAntX, vAntY;
    unsigned char *tempFontes = mguiVideoFontes;
    unsigned long vEndFont, vEndPart;
    unsigned short posX, posY, modX, modY, offset, offsetmodX, posmodX;
    unsigned char lineChar, pixel, color;
    VDP_COORD cursor;

    cursor = vdp_get_cursor_safe();

    name_offset = cursor.y * (cursor.maxx + 1) + cursor.x; // Position in name table
    pattern_offset = name_offset << 3;

    vEndPart = chr - 32;
    vEndPart = vEndPart << 3;
    vAntY = cursor.y;
    for (i = 0; i < 8; i++)
    {
        vEndFont = mguiVideoFontes;
        vEndFont += vEndPart + i;
        tempFontes = vEndFont;
        lineChar = *tempFontes;
        lineChar = (lineChar & 0xFC);

        ix = cursor.x;
        iy = cursor.y;
        xf = ix + 6;
        offsetmodX = 0;

        while (ix < xf)
        {
            posX = (int)(8 * (ix / 8));
            posY = (int)(256 * (iy / 8));
            modX = (int)(ix % 8);
            modY = (int)(iy % 8);

            offset = posX + modY + posY;

            setReadAddress(mgui_pattern_table + offset);
            setReadAddress(mgui_pattern_table + offset);
            pixel = *vvdgd;
            setReadAddress(mgui_color_table + offset);
            setReadAddress(mgui_color_table + offset);
            color = *vvdgd;

            if (modX > 2 || (modX == 0 && ix > cursor.x))   // Parcial com bits dos 6 bits no proximo Byte
            {
                if (ix == cursor.x)  // Posicao inicial
                {
                    posmodX = (8 - modX);
                    pixel = ((pixel & (0xFF << posmodX)) | (lineChar >> modX));
                    offsetmodX = posmodX;
                }
                else
                {
                    posmodX = (6 - offsetmodX);
                    pixel = ((pixel & (0xFF >> posmodX)) | (lineChar << offsetmodX));
                }

                ix += posmodX;
            }
            else    // Total, com 6 bits no mesmo Byte
            {
                lineChar = lineChar >> modX;

                switch (modX)
                {
                    case 0:
                        pixel = pixel & 0x03;
                        break;
                    case 1:
                        pixel = pixel & 0x81;
                        break;
                    case 2:
                        pixel = pixel & 0xC0;
                        break;
                }

                pixel = pixel | lineChar;

                ix += 6;
            }

            color = (bgcolorMgui & 0x0F) | (fgcolorMgui << 4);

            setWriteAddress(mgui_pattern_table + offset);
            *vvdgd = (pixel);
            setWriteAddress(mgui_color_table + offset);
            *vvdgd = (color);
        }

        cursor.y = cursor.y + 1;
    }

    cursor.y = vAntY;
    vdp_set_cursor(cursor.x, cursor.y);
}

//-----------------------------------------------------------------------------
// Graphic Interface Functions
//-----------------------------------------------------------------------------
void writesxy(unsigned short x, unsigned short y, unsigned char sizef, unsigned char *msgs, unsigned short pcolor, unsigned short pbcolor)
{
    unsigned char ix = 10, xf;
    unsigned char antfg, antbg;

    vdp_set_cursor(x,y);

    antfg = fgcolorMgui;
    antbg = bgcolorMgui;

    fgcolorMgui = pcolor;
    bgcolorMgui = pbcolor;

    while (*msgs) {
        if (*msgs >= 0x20 && *msgs < 0x7F)
        {
            vdp_write_gui(*msgs);
            vdp_set_cursor_pos_gui(VDP_CSR_RIGHT);
        }
        *msgs++;
    }

    fgcolorMgui = antfg;
    bgcolorMgui = antbg;
}

//-----------------------------------------------------------------------------
void writecxy(unsigned char sizef, unsigned char pbyte, unsigned short pcolor, unsigned short pbcolor)
{
    vdp_set_cursor(pposx, pposy);
    vdp_write_gui(pbyte);

    pposx = pposx + sizef;

    if ((pposx + sizef) > vxgmax)
        pposx = pposx - sizef;
}

//-----------------------------------------------------------------------------
void locatexy(unsigned short xx, unsigned short yy) {
    pposx = xx;
    pposy = yy;
}

//-----------------------------------------------------------------------------
int ss_alloc_slot(void)
{
    int i;

    for (i = 0; i < SS_MAX_BLOCKS; i++)
    {
        if (!ssSlots[i].used)
            return i;
    }

    return -1;
}

void SaveScreenNew(MGUI_SAVESCR *mguiSave, unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight)
{
    unsigned short xf, yf, xiant;
    unsigned int ix, iy, vsizetotal;
    unsigned int bytes_per_row, total_rows;
    unsigned int offset, posX, posY, modY, saveOffSet, saveOffSetAnt;
    unsigned char *saverPat;
    unsigned char *saverCor;
    int slot;
    
    // Manter leitura rapida de 8 pixels (1 pixel por Byte)
    xiant = xi;

    if ((xi & 0x0F) < 0x08)
        xi = xi - (xi & 0x0F);
    else
        xi = (xi - (xi & 0x0F)) + 0x08;

    pwidth += (xiant - xi);

    // Define Final
    xf = (xi + pwidth);
    yf = (yi + pheight);

    if (xf > 255)
        xf = 255;

    if (yf > 191)
        yf = 191;
        
    if (xf < xi || yf < yi)
    {
        mguiSave->id = -1;
        return;
    }

    bytes_per_row = (((unsigned int)xf - (unsigned int)xi) / 8u) + 1u;
    total_rows = ((unsigned int)yf - (unsigned int)yi) + 1u;
    vsizetotal = bytes_per_row * total_rows;

    #ifdef USE_MALLOC
        saverPat = malloc(vsizetotal);
        saverCor = malloc(vsizetotal);
    #else
        slot = ss_alloc_slot();

        if (slot < 0)
            return 0;   /* sem espaço */

        saverPat = ADDR_SAVE_SCR + ((unsigned long)slot * SS_BLOCK_SIZE);
        saverCor = saverPat + SS_PAT_SIZE;

        ssSlots[slot].used    = 1;
        ssSlots[slot].id      = ssNextId++;
        ssSlots[slot].addrPat = saverPat;
        ssSlots[slot].addrCol = saverCor;

        mguiSave->id = ssSlots[slot].id;
        mguiSave->xi = xi;
        mguiSave->yi = yi;
        mguiSave->xf = xf;
        mguiSave->yf = yf;
    #endif

    #ifdef USE_MALLOC
        if (!saverPat || !saverCor)
        {
            if (saverPat) free(saverPat);
            if (saverCor) free(saverCor);
            mguiSave->pat = 0;
            mguiSave->cor = 0;
            mguiSave->size = 0;
            mguiSave->xi = xi;
            mguiSave->yi = yi;
            mguiSave->xf = xf;
            mguiSave->yf = yf;
            return;
        }
    #endif

    saveOffSet = 0;

    for (iy = yi; iy <= yf; iy++)
    {
        ix = xi;
        saveOffSetAnt = saveOffSet;
        while (ix <= xf)
        {
            posX = (int)(8 * (ix / 8));
            posY = (int)(256 * (iy / 8));
            modY = (int)(iy % 8);
            offset = posX + modY + posY;

            setReadAddress(mgui_pattern_table + offset);
            setReadAddress(mgui_pattern_table + offset);

            *(saverPat + saveOffSet) = *vvdgd;
            saveOffSet = saveOffSet + 1;
            ix += 8;
        }

        ix = xi;
        saveOffSet = saveOffSetAnt;
        while (ix <= xf)
        {
            posX = (int)(8 * (ix / 8));
            posY = (int)(256 * (iy / 8));
            modY = (int)(iy % 8);
            offset = posX + modY + posY;

            setReadAddress(mgui_color_table + offset);
            setReadAddress(mgui_color_table + offset);

            *(saverCor + saveOffSet) = *vvdgd;
            saveOffSet = saveOffSet + 1;

            ix += 8;
        }
    }

    #ifdef USE_MALLOC
        mguiSave->pat = saverPat;
        mguiSave->cor = saverCor;
        mguiSave->size = vsizetotal;
        mguiSave->xi = xi;
        mguiSave->yi = yi;
        mguiSave->xf = xf;
        mguiSave->yf = yf;
    #endif
}

//-----------------------------------------------------------------------------
// SEM USO PRA NAO DAR PAU NO COMPILADOR. NAO ME PERGUNTE POR QUE
//-----------------------------------------------------------------------------
MGUI_SAVESCR SaveScreen(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight)
{
    MGUI_SAVESCR mguiSave;

    return mguiSave;
}

//-----------------------------------------------------------------------------
int ss_find_slot(unsigned int id)
{
    int i;

    for (i = 0; i < SS_MAX_BLOCKS; i++)
    {
        if (ssSlots[i].used && ssSlots[i].id == id)
            return i;
    }

    return -1;
}

void RestoreScreen(MGUI_SAVESCR *mguiSave) {
    unsigned short xi,yi,xf, yf;
    unsigned int ix, iy;
    unsigned int offset, posX, posY, modY, saveOffSet, saveOffSetAnt;
    unsigned char pixel;
    unsigned char color;
    unsigned char *saverPat;
    unsigned char *saverCor;
    int slot;

    slot = ss_find_slot(mguiSave->id);

    if (slot < 0)
        return;   /* slot não encontrado */ 

    #ifdef USE_MALLOC
        saverPat = mguiSave->pat;
        saverCor = mguiSave->cor;
        
        if (!saverPat || !saverCor || mguiSave->size == 0)
            return;
    #else
        saverPat = ssSlots[slot].addrPat;
        saverCor = ssSlots[slot].addrCol;    
        ssSlots[slot].used = 0; /* libera slot */
    #endif

    xi = mguiSave->xi;
    xf = mguiSave->xf;
    yi = mguiSave->yi;
    yf = mguiSave->yf;

    saveOffSet = 0;

    for (iy = yi; iy <= yf; iy++)
    {
        ix = xi;
        while (ix <= xf)
        {
            posX = (int)(8 * (ix / 8));
            posY = (int)(256 * (iy / 8));
            modY = (int)(iy % 8);
            offset = posX + modY + posY;

            pixel = *(saverPat + saveOffSet);
            color = *(saverCor + saveOffSet);
            saveOffSet = saveOffSet + 1;

            setWriteAddress(mgui_pattern_table + offset);
            *vvdgd = pixel;
            setWriteAddress(mgui_color_table + offset);
            *vvdgd = color;

            ix += 8;
        }
    }

    #ifdef USE_MALLOC    
        free(mguiSave->cor);
        free(mguiSave->pat);
    #endif
}

//-----------------------------------------------------------------------------
void SetDot(unsigned short x, unsigned short y, unsigned short color) {
    vdp_plot_hires(x, y, color, bgcolorMgui);
}

//-----------------------------------------------------------------------------
void SetByte(unsigned short ix, unsigned short iy, unsigned char pByte, unsigned short pfcolor, unsigned short pbcolor)
{
    unsigned int offset, offsetByte, posX, posY, modX, modY, xf, ixAnt;
    unsigned char pixel;
    unsigned char color;

    xf = ix + 8;
    if (xf > 255)
        xf = 255;

    ixAnt = ix;
    while (ix < xf)
    {
        posX = (int)(8 * (ix / 8));
        posY = (int)(256 * (iy / 8));
        modX = (int)(ix % 8);
        modY = (int)(iy % 8);

        offset = posX + modY + posY;

        if (modX > 0 || (modX == 0 && ((ix + 8) > xf)))
        {
            setReadAddress(mgui_pattern_table + offset);
            setReadAddress(mgui_pattern_table + offset);
            pixel = *vvdgd;
            setReadAddress(mgui_color_table + offset);
            setReadAddress(mgui_color_table + offset);
            color = *vvdgd;

            if (ix == ixAnt)
            {
                offsetByte = (8 - modX);
                pByte = pByte >> modX;
                pixel |= pByte;

                ix += (8 - modX);
            }
            else
            {
                pByte = pByte << offsetByte;
                pixel |= pByte;

                ix += (8 - offsetByte);
            }

            color = (color & 0x0F) | (pfcolor << 4);
        }
        else
        {
            pixel = pByte;
            color = (pbcolor & 0x0F) | (pfcolor << 4);

            ix += 8;
        }

        setWriteAddress(mgui_pattern_table + offset);
        *vvdgd = (pixel);
        setWriteAddress(mgui_color_table + offset);
        *vvdgd = (color);
    }
}

//-----------------------------------------------------------------------------
void FillRect(unsigned char xi, unsigned char yi, unsigned short pwidth, unsigned char pheight, unsigned char pcor) {
    unsigned short xf, yf;
    unsigned int ix, iy;
    unsigned int offset, posX, posY, modX, modY;
    unsigned char pixel;
    unsigned char color;

    xf = (xi + pwidth);
    yf = (yi + pheight);

    if (xf > 255)
        xf = 255;

    if (yf > 191)
        yf = 191;

    for (iy = yi; iy <= yf; iy++)
    {
        ix = xi;
        while (ix <= xf)
        {
            posX = (int)(8 * (ix / 8));
            posY = (int)(256 * (iy / 8));
            modX = (int)(ix % 8);
            modY = (int)(iy % 8);

            offset = posX + modY + posY;

            if (modX > 0 || (modX == 0 && ((ix + 8) > xf)))
            {
                setReadAddress(mgui_pattern_table + offset);
                setReadAddress(mgui_pattern_table + offset);
                pixel = *vvdgd;
                setReadAddress(mgui_color_table + offset);
                setReadAddress(mgui_color_table + offset);
                color = *vvdgd;

                if (pcor != 0x00)
                {
                    pixel |= 0x80 >> modX; //Set a "1"
                    color = (color & 0x0F) | (pcor << 4);
                }
                else
                {
                    pixel &= ~(0x80 >> modX); //Set bit as "0"
                    color = (color & 0xF0) | (bgcolorMgui & 0x0F);
                }

                ix++;
            }
            else
            {
                if (pcor != 0x00)
                {
                    pixel = 0xFF;
                    color = (bgcolorMgui & 0x0F) | (pcor << 4);
                }
                else
                {
                    pixel = 0x00;
                    color = (bgcolorMgui & 0x0F);
                }

                ix += 8;
            }

            setWriteAddress(mgui_pattern_table + offset);
            *vvdgd = (pixel);
            setWriteAddress(mgui_color_table + offset);
            *vvdgd = (color);
        }
    }
}

//-----------------------------------------------------------------------------
void DrawLine(unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2, unsigned short color) {
    int ix, iy;
    int zz,x,y,addx,addy,dx,dy;
    long P;

    if (y1 == y2)       // Horizontal
        FillRect(x1,y1,(x2 - x1),1,color);
    else if (x1 == x2)  // Vertical
    {
        for (iy = y1; iy <= y2; iy++)
            vdp_plot_hires(x1, iy, color, bgcolorMgui);
    }
    else    // Torta
    {
        dx = (x2 - x1);
        dy = (y2 - y1);

        if (dx < 0)
            dx = dx * (-1);

        if (dy < 0)
            dy = dy * (-1);

        x = x1;
        y = y1;

        if(x1 > x2)
            addx = -1;
        else
            addx = 1;

        if(y1 > y2)
            addy = -1;
        else
            addy = 1;

        if(dx >= dy)
        {
            P = (2 * dy) - dx;

            for(ix = 1; ix <= (dx + 1); ix++)
            {
                vdp_plot_hires(x, y, color, bgcolorMgui);

                if (P < 0)
                {
                    P = P + (2 * dy);
                    zz = x + addx;
                    x = zz;
                }
                else
                {
                    P = P + (2 * dy) - (2 * dx);
                    x = x + addx;
                    zz = y + addy;
                    y = zz;
                }
            }
        }
        else
        {
            P = (2 * dx) - dy;

            for(ix = 1; ix <= (dy +1); ix++)
            {
                vdp_plot_hires(x, y, color, bgcolorMgui);

                if (P < 0)
                {
                    P = P + (2 * dx);
                    y = y + addy;
                }
                else
                {
                    P = P + (2 * dx) - (2 * dy);
                    x = x + addx;
                    y = y + addy;
                }
            }
        }
    }
}

//-----------------------------------------------------------------------------
void DrawRect(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight, unsigned short color) {
    unsigned short xf, yf;

    xf = (xi + pwidth);
    yf = (yi + pheight);

    DrawLine(xi,yi,xf,yi,color);
    DrawLine(xi,yf,xf,yf,color);
    DrawLine(xi,yi,xi,yf,color);
    DrawLine(xf,yi,xf,yf,color);
}

//-----------------------------------------------------------------------------
void DrawRoundRect(unsigned int xi, unsigned int yi, unsigned int pwidth, unsigned int pheight, unsigned char radius, unsigned char color) {
	unsigned short tSwitch, x1 = 0, y1, xt, yt, wt;

    y1 = radius;

	tSwitch = 3 - 2 * radius;

	while (x1 <= y1) {
	    xt = xi + radius - x1;
	    yt = yi + radius - y1;
	    vdp_plot_hires(xt, yt, color, 0);

	    xt = xi + radius - y1;
	    yt = yi + radius - x1;
	    vdp_plot_hires(xt, yt, color, 0);

        xt = xi + pwidth-radius + x1;
	    yt = yi + radius - y1;
	    vdp_plot_hires(xt, yt, color, 0);

        xt = xi + pwidth-radius + y1;
	    yt = yi + radius - x1;
	    vdp_plot_hires(xt, yt, color, 0);

        xt = xi + pwidth-radius + x1;
        yt = yi + pheight-radius + y1;
	    vdp_plot_hires(xt, yt, color, 0);

        xt = xi + pwidth-radius + y1;
        yt = yi + pheight-radius + x1;
	    vdp_plot_hires(xt, yt, color, 0);

	    xt = xi + radius - x1;
        yt = yi + pheight-radius + y1;
	    vdp_plot_hires(xt, yt, color, 0);

	    xt = xi + radius - y1;
        yt = yi + pheight-radius + x1;
	    vdp_plot_hires(xt, yt, color, 0);

	    if (tSwitch < 0) {
	    	tSwitch += (4 * x1 + 6);
	    } else {
	    	tSwitch += (4 * (x1 - y1) + 10);
	    	y1--;
	    }
	    x1++;
	}

    xt = xi + radius;
    yt = yi + pheight;
    wt = pwidth - (2 * radius);
	DrawHoriLine(xt, yi, wt, color);		// top
	DrawHoriLine(xt, yt, wt, color);	// bottom

    xt = xi + pwidth;
    yt = yi + radius;
    wt = pheight - (2 * radius);
	DrawVertLine(xi, yt, wt, color);		// left
	DrawVertLine(xt, yt, wt, color);	// right
}

//-----------------------------------------------------------------------------
void DrawCircle(unsigned short x0, unsigned short y0, unsigned char r, unsigned char pfil, unsigned short pcor) {
  int f = 1 - r;
  int ddF_x = 1;
  int ddF_y = -2 * r;
  int x = 0;
  int y = r;

  vdp_plot_hires(x0  , y0+r, pcor, 0);
  vdp_plot_hires(x0  , y0-r, pcor, 0);
  vdp_plot_hires(x0+r, y0  , pcor, 0);
  vdp_plot_hires(x0-r, y0  , pcor, 0);

  while (x<y) {
    if (f >= 0) {
      y--;
      ddF_y += 2;
      f += ddF_y;
    }
    x++;
    ddF_x += 2;
    f += ddF_x;

    vdp_plot_hires(x0 + x, y0 + y, pcor, 0);
    vdp_plot_hires(x0 - x, y0 + y, pcor, 0);
    vdp_plot_hires(x0 + x, y0 - y, pcor, 0);
    vdp_plot_hires(x0 - x, y0 - y, pcor, 0);
    vdp_plot_hires(x0 + y, y0 + x, pcor, 0);
    vdp_plot_hires(x0 - y, y0 + x, pcor, 0);
    vdp_plot_hires(x0 + y, y0 - x, pcor, 0);
    vdp_plot_hires(x0 - y, y0 - x, pcor, 0);
  }
}

//-----------------------------------------------------------------------------
void InvertRect(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight) {
    unsigned short xf, yf;
    unsigned int ix, iy;
    unsigned int offset, posX, posY, modX, modY;
    unsigned char pixel;
    unsigned char color, color1, color2, vprim = 0;

    xf = (xi + pwidth);
    yf = (yi + pheight);

    if (xf > 255)
        xf = 255;

    if (yf > 191)
        yf = 191;

    for (iy = yi; iy <= yf; iy++)
    {
        ix = xi;
        while (ix <= xf)
        {
            posX = (int)(8 * (ix / 8));
            posY = (int)(256 * (iy / 8));
            modX = (int)(ix % 8);
            modY = (int)(iy % 8);

            offset = posX + modY + posY;

            setReadAddress(mgui_pattern_table + offset);
            setReadAddress(mgui_pattern_table + offset);
            pixel = *vvdgd;
            setReadAddress(mgui_color_table + offset);
            setReadAddress(mgui_color_table + offset);
            color = *vvdgd;

            if (modX == 0)
                vprim = 0;

            if (modX > 0 || (modX == 0 && ((ix + 8) > xf)))
            {
                pixel &= ~(0x80 >> modX);

                if (!vprim)
                {
                    vprim = 1;
                    color1 = (color & 0xF0) >> 4;
                    color2 = (color & 0x0F) << 4;
                    color = (color1 | color2);
                }

                ix++;
            }
            else
            {
                pixel = ~pixel;
                color1 = (color & 0xF0) >> 4;
                color2 = (color & 0x0F) << 4;
                color = (color1 | color2);

                ix += 8;
            }

            setWriteAddress(mgui_pattern_table + offset);
            *vvdgd = (pixel);
            setWriteAddress(mgui_color_table + offset);
            *vvdgd = (color);
        }
    }
}

//-------------------------------------------------------------------------
unsigned char button(unsigned char id, unsigned char *title, unsigned short xib, unsigned short yib, unsigned short width, unsigned short height, unsigned char vtipo)
{
    unsigned char vRet = 0;
    unsigned char vPosTxt;
    unsigned char thisIdx;
    unsigned char isFocused;
    unsigned char borderColor;
    char vdisp = 0;
    unsigned char oldFocusIdx;
    MGUI_INPUT inp;

    if (vtipo == WINFULL)
        thisIdx = mguiWidgetRegister(id, MGUI_WT_BUTTON);
    else
        thisIdx = id;

    oldFocusIdx = mguiWidgetOnFocusIdx;
    inp = mguiWidgetProcess(thisIdx, xib, yib, width, height, vtipo);
    isFocused = inp.focused;

/*    if (!isFocused && vtipo != WINFULL)
        return 0;*/

    if (oldFocusIdx != mguiWidgetOnFocusIdx || (mguiWidgetOnFocusIdx == thisIdx && mguiWidgetLeaveFocusIdx != mguiWidgetOnFocusIdx))
    {
        if (oldFocusIdx == thisIdx || mguiWidgetOnFocusIdx == thisIdx)
            vdisp = 1;
    }

    if (vtipo == WINOPER || vtipo == WINFULL)
    {
        if (inp.clicked) vRet = 1;         // clique do mouse ativa o botao
        if (inp.key == 0x0D) vRet = 1;    // ENTER ativa o botao
    }

    if (vtipo == WINDISP || vtipo == WINFULL || vdisp)
    {
        if (mguiWidgetOnFocusIdx == thisIdx)
            mguiWidgetLeaveFocusIdx = mguiWidgetOnFocusIdx;

        vdisp = 0;
        borderColor = isFocused ? VDP_DARK_BLUE : vcorwf;
        vPosTxt = (width / 2) - ((strlen(title) / 2) * 6);
        DrawRoundRect(xib,yib,width,height,1,borderColor);
        writesxy(xib + vPosTxt, yib + 2,1,title,vcorwf,vcorwb);
    }

    return vRet;
}

//-------------------------------------------------------------------------
void fillin(unsigned char id, unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo)
{
    unsigned short cc = 0;
    unsigned short len;
    unsigned short maxChars;
    unsigned char cchar;
    unsigned char vdisp = 0;
    unsigned char vtmp[2];
    unsigned char thisIdx;
    unsigned char oldFocusIdx;
    unsigned char isFocused;
    unsigned char borderColor;
    unsigned char stqdtam[20];
    MGUI_INPUT inp;

    if (vtipo == WINFULL)
        thisIdx = mguiWidgetRegister(id, MGUI_WT_BUTTON);
    else
        thisIdx = id;
        
    oldFocusIdx = mguiWidgetOnFocusIdx;    
    // area de clique inclui a borda desenhada (y-2, altura 13)
    inp = mguiWidgetProcess(thisIdx, x, (unsigned short)(y - 2), pwidth, 13, vtipo);
    isFocused = inp.focused;
        
    /*if (!isFocused && vtipo != WINFULL)
        return;*/

    if (oldFocusIdx != mguiWidgetOnFocusIdx || (mguiWidgetOnFocusIdx == thisIdx && mguiWidgetLeaveFocusIdx != mguiWidgetOnFocusIdx))
    {
        if (oldFocusIdx == thisIdx || mguiWidgetOnFocusIdx == thisIdx)
            vdisp = 1;
    }

    maxChars = (unsigned short)(pwidth / 6);
    if (maxChars > 0)
        maxChars = (unsigned short)(maxChars - 1);

    if (isFocused && (vtipo == WINOPER || vtipo == WINFULL))
    {
        len = (unsigned short)strlen(vvar);

        if (inp.key >= 0x20 && inp.key < 0x7F)
        {
            if (len < maxChars)
            {
                vvar[len] = inp.key;
                vvar[len + 1] = 0x00;
                vdisp = 1;
            }
        }
        else
        {
            switch (inp.key)
            {
                case 0x0D:  // Enter
                    break;
                case 0x08:  // BackSpace
                    if (len > 0)
                    {
                        vvar[len - 1] = 0x00;
                        vdisp = 1;
                    }
                    break;
            }
        }
    }

    if (vtipo == WINDISP || vtipo == WINFULL || vdisp)
    {
        if (mguiWidgetOnFocusIdx == thisIdx)
            mguiWidgetLeaveFocusIdx = mguiWidgetOnFocusIdx;

        vdisp = 0;

        borderColor = isFocused ? VDP_DARK_BLUE : vcorwf;

        FillRect(x-2,y-2,pwidth+4,13,vcorwb);
        DrawRect(x-2,y-2,pwidth+4,13,borderColor);

        cc = 0;
        len = (unsigned short)strlen(vvar);
        if (len > maxChars)
            len = maxChars;

        while (cc < len)
        {
            cchar = vvar[cc];
            vtmp[0] = cchar;
            vtmp[1] = 0x00;

            writesxy(x + (cc * 6), y + 1, 6, vtmp, vcorwf, vcorwb);
            cc++;
        }

        if (isFocused)
        {
            if ((x + (len * 6) + 6) < (x + pwidth))
            {
                vtmp[0] = '|';
                vtmp[1] = 0x00;
                writesxy(x + (len * 6), y + 1, 6, vtmp, borderColor, vcorwb);
            }
        }
    }
}

//-------------------------------------------------------------------------
void radioset(unsigned char id, unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo)
{
    unsigned char cc, xc;
    unsigned char cchar, vdisp = 0;
    unsigned char thisIdx, isFocused, borderColor;
    unsigned short pheight;
    MGUI_INPUT inp;

    pheight = 10;
    cc = 0;
    while (vopt[cc] != '\0')
    {
        if (vopt[cc] == ',')
            pheight += 10;
        cc++;
    }

    thisIdx = mguiWidgetRegister(id, MGUI_WT_RADIO);
    inp = mguiWidgetProcess(thisIdx, x, y, 140, pheight, vtipo);
    isFocused = inp.focused;
    borderColor = isFocused ? VDP_DARK_BLUE : vcorwf;

  xc = 0;
  cc = 0;
  cchar = ' ';

  while((vtipo == WINOPER || vtipo == WINFULL) && cchar != '\0') {
    cchar = vopt[cc];
    if (cchar == ',') {
      if (cchar == ',' && cc != 0)
        xc++;

      if (vpostx >= x && vpostx <= x + 8 && vposty >= (y + (xc * 10)) && vposty <= ((y + (xc * 10)) + 8)) {
        vvar[0] = xc;
        vdisp = 1;
      }
    }

    cc++;
  }

  xc = 0;
  cc = 0;

  while(vtipo == WINDISP || vtipo == WINFULL || vdisp) {
        if (isFocused)
            DrawRect(x - 2, y - 2, 146, pheight + 2, borderColor);

    cchar = vopt[cc];

    if (cchar == ',') {
      if (cchar == ',' && cc != 0)
        xc++;

            FillRect(x, y + (xc * 10), 8, 8, vcorwb);
            DrawCircle(x + 4, y + (xc * 10) + 2, 4, 0, borderColor);

      if (vvar[0] == xc)
                DrawCircle(x + 4, y + (xc * 10) + 2, 3, 1, borderColor);
      else
                DrawCircle(x + 4, y + (xc * 10) + 2, 3, 0, borderColor);

      locatexy(x + 10, y + (xc * 10));
    }

    if (cchar != ',' && cchar != '\0')
      writecxy(6, cchar, vcorwf, vcorwb);

    if (cchar == '\0')
      break;

    cc++;
  }
}

//-------------------------------------------------------------------------
void togglebox(unsigned char id, unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo)
{
  unsigned char cc = 0;
    unsigned char cchar, vdisp = 0;
    unsigned char thisIdx, isFocused, borderColor;
    unsigned short twidth;
    MGUI_INPUT inp;

    twidth = 10 + (unsigned short)(strlen(bstr) * 6);
    thisIdx = mguiWidgetRegister(id, MGUI_WT_TOGGLE);
    inp = mguiWidgetProcess(thisIdx, x, y, twidth, 8, vtipo);
    isFocused = inp.focused;
    borderColor = isFocused ? VDP_DARK_BLUE : vcorwf;

    if (isFocused && inp.key == 0x0D)
    {
        if (vvar[0])
            vvar[0] = 0;
        else
            vvar[0] = 1;
        vdisp = 1;
    }

  if ((vtipo == WINOPER || vtipo == WINFULL) && vpostx >= x && vpostx <= x + 4 && vposty >= y && vposty <= y + 4)
  {
    if (vvar[0])
      vvar[0] = 0;
    else
      vvar[0] = 1;

    vdisp = 1;
  }

  if (vtipo == WINDISP || vtipo == WINFULL || vdisp)
  {
        if (isFocused)
            DrawRect(x - 2, y - 1, twidth + 4, 10, borderColor);

    FillRect(x, y + 2, 4, 4, vcorwb);
        DrawRect(x, y + 2, 4, 4, borderColor);

    if (vvar[0]) {
            DrawLine(x, y + 2, x + 4, y + 6, borderColor);
            DrawLine(x, y + 6, x + 4, y + 2, borderColor);
    }

    if (vtipo == WINDISP || vtipo == WINFULL) {
      x += 6;
      locatexy(x,y);
      while (bstr[cc] != 0)
      {
        cchar = bstr[cc];
        cc++;

        writecxy(6, cchar, vcorwf, vcorwb);
        x += 6;
      }
    }
  }
}

//-----------------------------------------------------------------------------
void SelRect(unsigned short x, unsigned short y, unsigned short pwidth, unsigned short pheight)
{
    DrawRect((x - 1), (y - 1), (pwidth + 2), (pheight + 2), VDP_DARK_RED);
}

//-----------------------------------------------------------------------------
void PutIcone(unsigned int* vimage, unsigned short x, unsigned short y, unsigned char numSprite)
{
    // TBD
}

//-----------------------------------------------------------------------------
void PutImage(unsigned char* cimage, unsigned short x, unsigned short y)
{
    // TBD
}

//-----------------------------------------------------------------------------
void LoadIconLib(unsigned char* cfile)
{
    // TBD
}

void vdp_read_data_gui(unsigned int addr, unsigned int startaddr, unsigned int qtd)
{
    int ix;

    setReadAddress(addr);
    setReadAddress(addr);

    /**(tempDataBase + startaddr) = addr;

    for (ix = 0; ix < qtd; ix++)
        *(tempDataMgui2 + startaddr + ix) = *vvdgd;*/
}

//-----------------------------------------------------------------------------
unsigned char read_status_reg_gui(void)
{
    unsigned char memByte;

    memByte = *vvdgc;

    return memByte;
}

//-----------------------------------------------------------------------------
// Config INI - Busca direta no buffer de memoria
// Busca 'key' dentro de '[section]' em memPosConfig; copia o valor em vOutBuf como string.
// Retorna vOutBuf em caso de sucesso, NULL se nao encontrado.
// vOutMax: tamanho do vOutBuf incluindo '\0'
//-----------------------------------------------------------------------------
char mguiCfgGet(char *section, char *key, char *vOutBuf, unsigned char vOutMax)
{
    unsigned char slen = (unsigned char)strlen(section);
    unsigned char klen = (unsigned char)strlen(key);
    unsigned char *p = memPosConfig;
    unsigned char i;
    unsigned char inSection = 0;
    unsigned char sqtdtam[20];

    if (!p || !section || !slen || !key || !klen || !vOutBuf || vOutMax == 0)
        return 0;

    // Ignore UTF-8 BOM no inicio do arquivo, se existir.
    if (p[0] == 0xEF && p[1] == 0xBB && p[2] == 0xBF)
        p += 3;

    while (*p)
    {
        // Pula espacos e tabulacoes no inicio da linha
        while (*p == ' ' || *p == '\t') p++;

        // Ignora linhas vazias e comentarios
        if (*p == '\r' || *p == '\n' || *p == ';' || *p == '#')
        {
            while (*p == '\r' || *p == '\n') p++;
            continue;
        }

        // Verifica cabecalho de secao [NOME]
        if (*p == '[')
        {
            unsigned char *q = p + 1;

            inSection = (strncmp((char *)q, section, slen) == 0 && q[slen] == ']') ? 1 : 0;
        }
        else if (inSection)
        {
            // Verifica se a chave bate nessa linha
            if (strncmp((char *)p, key, klen) == 0 &&
                (p[klen] == ' ' || p[klen] == '\t' || p[klen] == '='))
            {
                unsigned char *q = p + klen;
                // Pula espacos antes do '='
                while (*q == ' ' || *q == '\t') q++;
                if (*q == '=')
                {
                    q++;
                    // Pula espacos apos o '='
                    while (*q == ' ' || *q == '\t') q++;

                    i = 0;
                    while (*q && *q != '\n' && *q != '\r' && i < (unsigned char)(vOutMax - 1))
                        vOutBuf[i++] = (char)*q++;
                    // Remove espacos no final
                    while (i > 0 && (vOutBuf[i-1] == ' ' || vOutBuf[i-1] == '\t'))
                        i--;
                    vOutBuf[i] = '\0';
                    return 1;
                }
            }
        }

        // Avanca ate o proximo fim de linha (aceita CR, LF e CRLF)
        while (*p && *p != '\n' && *p != '\r') p++;
        while (*p == '\n' || *p == '\r') p++;
    }

    return 0;
}

//-----------------------------------------------------------------------------
void startMGI(void) {
    unsigned char vnomefile[12];
    unsigned char lc, ll, *ptr_ico, *ptr_prg, *ptr_pos;
    unsigned char* vLoadImage = 0x00;
    unsigned long cfgSize;
    int percent;
    long ix;
    char errorMalloc;
    VDP_COLOR cores;
    VDP_COORD cursor;
    unsigned int error_code = OS_ERR_NONE;
    int iy;
    char tmp[32];

    OSTaskSuspend(TASK_MMSJOS_MAIN);

    *startBasic = 2;    // Inicia Basic vindo do MGUI sem mensagens e textos
    *mguiRunTask = 0x00;

    // Limpar slots de SaveScreen
    for (iy = 0; iy < SS_MAX_BLOCKS; iy++)
        ssSlots[iy].used = 0;

    cursor = vdp_get_cursor_safe();
    mguiVideoFontes = getVideoFontes();

    vxgmax = cursor.maxx;

    vcorwf = VDP_WHITE;
    vcorwb = VDP_TRANSPARENT;
    vcorwb2 = VDP_DARK_BLUE;

    vdp_init(VDP_MODE_G2, VDP_DARK_BLUE, 0, 0);
    vdp_set_bdcolor(VDP_DARK_BLUE);

    fgcolorMgui = VDP_WHITE; // cores.fg;
    bgcolorMgui = VDP_DARK_BLUE; // cores.bg;
    
    errorMalloc = 0;

    vdp_get_cfg(&mgui_pattern_table, &mgui_color_table);
    #ifdef USE_MALLOC
        vLoadImage = malloc(SIZE_LOAD_IMAGE_MEM);
    #else
        vLoadImage = (unsigned char*)ADDR_LOAD_FILE;   // Endereco fixo para carregar a imagem, nao vem de malloc. 
    #endif
    if (vLoadImage)
    {
        loadFile("/MGUI/IMAGES/UTILITY.PBM", (unsigned long*)vLoadImage);
        putImagePbmP4((unsigned long*)vLoadImage, 8, 1);
        #ifdef USE_MALLOC
            free(vLoadImage);
        #endif
    }
    else 
    {
        errorMalloc = 1;
        vLoadImage = 0;
    }

    writesxy(116,130,2,"MGUI",vcorwf,vcorwb);
    writesxy(71,140,1,"Graphical",vcorwf,vcorwb);
    writesxy(131,140,1,"Interface",vcorwf,vcorwb);
    writesxy(105,150,1,"v"versionMgui,vcorwf,vcorwb);

    writesxy(86,170,1,"Loading Config",vcorwf,vcorwb);
    cfgSize = loadFile("/MGUI/MGUI.CFG", (unsigned short*)memPosConfig);
    if (cfgSize > SIZE_LOAD_CFG_MEM)
        cfgSize = SIZE_LOAD_CFG_MEM;
    memPosConfig[cfgSize] = 0x00;

    writesxy(53,170,1,"Loading Icons ",vcorwf,vcorwb);

    #ifdef USE_MALLOC
        imgsMenuSys = malloc(SIZE_LOAD_ICONS_MEM);
    #else
        imgsMenuSys = (unsigned char*)ADDR_LOAD_ICONS;   // Endereco fixo para carregar as imagens, nao vem de malloc.
    #endif

    if (imgsMenuSys)
    {
        writesxy(137,170,1,"ICOFOLD.PBM",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOFOLD.PBM", imgsMenuSys);
        writesxy(137,170,1,"ICORUN.PBM ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICORUN.PBM", (imgsMenuSys + 64));
        writesxy(137,170,1,"ICOOS.PBM  ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOOS.PBM", (imgsMenuSys + 128));
        writesxy(137,170,1,"ICOSET.PBM ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOSET.PBM", (imgsMenuSys + 192));
        writesxy(137,170,1,"ICOOFF.PBM ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOOFF.PBM", (imgsMenuSys + 256));
    }
    else
    {
        errorMalloc = 1;
        imgsMenuSys = 0;
    }

    writesxy(53,170,1,"      Please Wait...       ",vcorwf,vcorwb);

    if (!errorMalloc)
    {
        memset(tmp, 0x00, sizeof(tmp));
        if (mguiCfgGet("START", "COLOR_F", tmp, sizeof(tmp)))
            vcorwf = atoi(tmp);
        memset(tmp, 0x00, sizeof(tmp));
        if (mguiCfgGet("START", "COLOR_B", tmp, sizeof(tmp)))
            vcorwb = atoi(tmp);
        memset(tmp, 0x00, sizeof(tmp));
        if (mguiCfgGet("START", "COLOR_B2", tmp, sizeof(tmp)))
            vcorwb2 = atoi(tmp);

        vdp_init(VDP_MODE_G2, vcorwb2, 0, 0);
        vdp_set_bdcolor(vcorwb2);

        mouseX = 128;
        mouseY = 96;
        redrawMain();

        TrocaSpriteMouse(MOUSE_POINTER);
        spthdlmouse = vdp_sprite_init(0, 0, VDP_DARK_RED);
        statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);
        
        for (iy = 0; iy <= 6; iy++)
        {
            mguiListWindows[iy].id = 0;
            mguiListWindows[iy].loadAddress = 0;
            mguiListWindows[iy].zOrder = 0;
            mguiListWindows[iy].active = 0;
        }

        mguiListWindows[6].id = 99;
        mguiListWindows[6].zOrder = 0;
        mguiListWindows[6].active = 1;

        OSTaskCreate(mouseTask, OS_NULL, &StkMouse[STACKSIZEMOUSE], TASK_MGUI_MOUSE);

        vIndicaDialog = 0;

        // Inicia Controles de Tela (Mouse e Teclado)
        while(1)
        {
            if (vIndicaDialog)
                OSTaskSuspend(OS_PRIO_SELF);

            if (!editortela())
                break;

            OSTimeDlyHMSM(0, 0, 0, 15);
        }

        #ifdef USE_MALLOC
            free(imgsMenuSys);
        #endif
        /* memPosConfig usa buffer fixo (0x008EF800), nao vem de malloc. */
    }

    vdp_init(VDP_MODE_TEXT, VDP_BLACK, 0, 0);
    vdp_textcolor(VDP_WHITE, VDP_BLACK);

    clearScr();

    OSTaskDel(TASK_MGUI_MOUSE);

    if (errorMalloc)
        printText("Error allocating memory. Process aborted.\r\n\0");

    printText("Ok\r\n\0");
    printText("#>");

    showCursor();

    *startBasic = 1;    // Inicia Basic vindo do MMSJOS com mensagens e textos

    OSTaskResume(TASK_MMSJOS_MAIN);
}

//-------------------------------------------------------------------------
void mouseTask (void *pData)
{
    unsigned char valter;
    unsigned char timeToDoubleClick = 0xFF;

    mouseBtnPresDouble = 0;

    while(1)
    {
        if (readMouse(&mouseStat, &mouseMoveX, &mouseMoveY))
        {
            VerifyMouse();

            if (mouseBtnPres == 0x01 && timeToDoubleClick == 0xFF)
            {
                mouseBtnPresDouble = 0;
                timeToDoubleClick = 0;
            }

            if (mouseBtnPres == 0x01 && timeToDoubleClick > 0 && timeToDoubleClick <= 34)
                mouseBtnPresDouble = 1;
        }

        if (mouseBtnPres == 0x00 && timeToDoubleClick != 0xFF)
            timeToDoubleClick = timeToDoubleClick + 1;

        if (timeToDoubleClick > 34 && timeToDoubleClick != 0xFF)
        {
            timeToDoubleClick = 0xFF;
            mouseBtnPresDouble = 0;
        }

        OSTimeDlyHMSM(0, 0, 0, 15);
    }
}

//-------------------------------------------------------------------------
void showWindow(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton)
{
	unsigned short i, ii, xib, yib;
    unsigned char cc = 0;
    unsigned char vbbutton;
    unsigned char vbuttonwin[32];
    unsigned short vbuttonwiny;

    // Desenha a Janela
    DrawRect(x1, y1, pwidth, pheight, vcorwf);
	FillRect(x1 + 1, y1 + 1, pwidth - 2, pheight - 2, vcorwb);

    if (*bstr) {
        DrawRect(x1, y1, pwidth, 12, vcorwf);
        writesxy(x1 + 2, y1 + 3,1,bstr,vcorwf,vcorwb);
    }

    mguiWidgetFocusReset();

    /*i = 1;
    for (ii = 0; ii <= 7; ii++)
        vbuttonwin[ii] = 0;

	// Desenha Botoes
    vbbutton = bbutton;
	while (vbbutton)
	{
		xib = x1 + 8 + (34 * (i - 1));
		yib = (y1 + pheight) - 12;
        vbuttonwiny = yib;
		i++;

        drawButtonsnew(&vbuttonwin, &vbbutton, xib, yib);
	}*/
}

//-------------------------------------------------------------------------
void drawButtonsnew(unsigned char *vbuttonswin, unsigned char *pbbutton, unsigned short xib, unsigned short yib)
{
    // Desenha Bot?
	//FillRect(xib, yib, 42, 10, VDP_WHITE);
	DrawRoundRect(xib,yib,32,10,1,vcorwf);  // rounded rectangle around text area

	// Escreve Texto do Bot?
	if (*pbbutton & BTOK)
	{
		writesxy(xib + 16 - 6, yib + 2,1,"OK",vcorwf,vcorwb);
        *pbbutton = *pbbutton & 0xFE;    // 0b11111110
        vbuttonswin[1] = xib;
	}
	else if (*pbbutton & BTSTART)
	{
		writesxy(xib + 16 - 15, yib + 2,1,"START",vcorwf,vcorwb);
        *pbbutton = *pbbutton & 0xDF;    // 0b11011111
        vbuttonswin[6] = xib;
	}
	else if (*pbbutton & BTCLOSE)
	{
		writesxy(xib + 16 - 15, yib + 2,1,"CLOSE",vcorwf,vcorwb);
        *pbbutton = *pbbutton & 0xBF;    // 0b10111111
        vbuttonswin[7] = xib;
	}
	else if (*pbbutton & BTCANCEL)
	{
		writesxy(xib + 16 - 12, yib + 2,1,"CANC",vcorwf,vcorwb);
        *pbbutton = *pbbutton & 0xFD;    // 0b11111101
        vbuttonswin[2] = xib;
	}
	else if (*pbbutton & BTYES)
	{
		writesxy(xib + 16 - 9, yib + 2,1,"YES",vcorwf,vcorwb);
        *pbbutton = *pbbutton & 0xFB;    // 0b11111011
        vbuttonswin[3] = xib;
	}
	else if (*pbbutton & BTNO)
	{
		writesxy(xib + 16 - 6, yib + 2,1,"NO",vcorwf,vcorwb);
        *pbbutton = *pbbutton & 0xF7;    // 0b11110111
        vbuttonswin[4] = xib;
	}
	else if (*pbbutton & BTHELP)
	{
		writesxy(xib + 16 - 12, yib + 2,1,"HELP",vcorwf,vcorwb);
        *pbbutton = *pbbutton & 0xEF;    // 0b11101111
        vbuttonswin[5] = xib;
	}
}

//-------------------------------------------------------------------------
void drawButtons(unsigned short xib, unsigned short yib) {
    // Desenha Bot?
	//FillRect(xib, yib, 42, 10, VDP_WHITE);
	DrawRoundRect(xib,yib,32,10,1,vcorwf);  // rounded rectangle around text area

	// Escreve Texto do Bot?
	if (vbbutton & BTOK)
	{
		writesxy(xib + 16 - 6, yib + 2,1,"OK",vcorwf,vcorwb);
        vbbutton = vbbutton & 0xFE;    // 0b11111110
        vbuttonwin[1] = xib;
	}
	else if (vbbutton & BTSTART)
	{
		writesxy(xib + 16 - 15, yib + 2,1,"START",vcorwf,vcorwb);
        vbbutton = vbbutton & 0xDF;    // 0b11011111
        vbuttonwin[6] = xib;
	}
	else if (vbbutton & BTCLOSE)
	{
		writesxy(xib + 16 - 15, yib + 2,1,"CLOSE",vcorwf,vcorwb);
        vbbutton = vbbutton & 0xBF;    // 0b10111111
        vbuttonwin[7] = xib;
	}
	else if (vbbutton & BTCANCEL)
	{
		writesxy(xib + 16 - 12, yib + 2,1,"CANC",vcorwf,vcorwb);
        vbbutton = vbbutton & 0xFD;    // 0b11111101
        vbuttonwin[2] = xib;
	}
	else if (vbbutton & BTYES)
	{
		writesxy(xib + 16 - 9, yib + 2,1,"YES",vcorwf,vcorwb);
        vbbutton = vbbutton & 0xFB;    // 0b11111011
        vbuttonwin[3] = xib;
	}
	else if (vbbutton & BTNO)
	{
		writesxy(xib + 16 - 6, yib + 2,1,"NO",vcorwf,vcorwb);
        vbbutton = vbbutton & 0xF7;    // 0b11110111
        vbuttonwin[4] = xib;
	}
	else if (vbbutton & BTHELP)
	{
		writesxy(xib + 16 - 12, yib + 2,1,"HELP",vcorwf,vcorwb);
        vbbutton = vbbutton & 0xEF;    // 0b11101111
        vbuttonwin[5] = xib;
	}
}

//-----------------------------------------------------------------------------
void redrawMain(void) {
    TrocaSpriteMouse(MOUSE_HOURGLASS);

    bgcolorMgui = VDP_BLACK; // cores.bg;

    clearScrW(bgcolorMgui);

    // Desenhar Barra Menu Principal / Status
    desenhaMenu();

    TrocaSpriteMouse(MOUSE_POINTER);
}

//-----------------------------------------------------------------------------
void desenhaMenu(void)
{
    unsigned long lc, idx;
    unsigned int vx, vy;
    VDP_COORD cursor;

    cursor = vdp_get_cursor_safe();

    vx = COLMENU;
    vy = LINMENU;

    for (lc = 0; lc <= 4; lc++)
    {
        idx = lc * 64;
        putImagePbmP4((imgsMenuSys + idx), vx, vy);
        vx += 24;

        /*MostraIcone(vx, vy, lc,vcorwf, vcorwb);
        vx += 16;*/
    }

    DrawLine(0, 20 /*10*/, cursor.maxx, 20 /*10*/, vcorwf);

/*    DrawCircle((*vdpMaxCols - 5), (*vdpMaxRows - 6), 3, 1, VDP_WHITE);
    DrawLine((*vdpMaxCols - 5), (*vdpMaxRows - 10), (*vdpMaxCols - 5), (*vdpMaxRows - 6), VDP_WHITE);*/
}

//--------------------------------------------------------------------------
unsigned char editortela(void)
{
    unsigned char vresp = 1, vwb;
    unsigned char vx, cc, vpos, vposiconx, vposicony, mpos;
    unsigned char *ptr_prg;
    int key;
    MMSJ_KEYEVENT k;

    // Verifica se clicou no simbolo de sair
    if (mouseBtnPres == 0x04) // Meio - Para reiniciar o sprite do mouse que as vezes nao aparece assim que roda o prog
    {
        //DrawRoundRect(mouseX - 10,mouseY - 10,20,20,2,vcorwf);
        spthdlmouse = vdp_sprite_init(0, 0, VDP_DARK_RED);
        statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);
        TrocaSpriteMouse(MOUSE_POINTER);
    }

    /**(vmfp + Reg_IERA) = 0x60;
    *(vmfp + Reg_IMRA) = 0x60;    */

    // Verifica se tem algum prog pra executar pelo run
    if (*mguiRunTask)
        runFromMGUI(*mguiRunTask);

    // Verifica mouse e teclado
    if (mguiListWindows[6].active)  // Mgui ativo
    {
        *mguiIdRequest = 6;

        key = KEY_NONE;
        
        if (mmsjKeyGet(&k))
        {
            if (k.flags == KEY_CTRL_ALT && k.code == "X")  // CTRL+ALT+X
                vresp = 0x00;
        }

        if (mouseBtnPres == 0x01)  // Esquerdo
        {
            if (vposty <= 22)
                vresp = new_menu();
        }
    }

    return vresp;
}

//-------------------------------------------------------------------------
void VerifyMouse(void)
{
    if (mouseMoveX < -2)
        mouseMoveX = -2;

    if (mouseMoveX > 2)
        mouseMoveX = 2;

    if ((mouseMoveX == -2 && mouseX > 1) || (mouseMoveX == 2 && mouseX < 254))
        mouseX = mouseX + mouseMoveX;

    if (mouseX <= 1)
        mouseX = 2;

    if (mouseX >= 254)
        mouseX = 253;

    if (mouseMoveY < -2)
        mouseMoveY = -2;

    if (mouseMoveY > 2)
        mouseMoveY = 2;

    if ((mouseMoveY == -2 && mouseY > 1) || (mouseMoveY == 2 && mouseY < 190))
        mouseY = mouseY - mouseMoveY;

    if (mouseY <= 1)
        mouseY = 2;

    if (mouseY >= 190)
        mouseY = 189;

    mouseBtnPres = mouseStat & 0x07;

    statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);

    if (mouseBtnPres)
    {
        vpostx = mouseX;
        vposty = mouseY;
    }
}

//-------------------------------------------------------------------------
void setPosPressed(unsigned char vppostx, unsigned char vpposty)
{
    vpostx = vppostx;
    vposty = vpposty;
}

//-------------------------------------------------------------------------
// ptipo = 0 mouse, ptipo = 1 keyboard
//-------------------------------------------------------------------------
#define MGUI_LOCAL_MAX_SLOT 6

void getMouseData(char ptipo, MGUI_MOUSE *pmouseData)
{
    unsigned char ix;
    int key;
    MMSJ_KEYEVENT k;

    ix = *mguiIdRequest;
    if (ix > MGUI_LOCAL_MAX_SLOT)
    {
        if (ptipo == 0x01)
            return;

        pmouseData->mouseButton = 0;
        pmouseData->mouseBtnDouble = 0;
        pmouseData->vpostx = 0;
        pmouseData->vposty = 0;
        pmouseData->mouseX = 0;
        pmouseData->mouseY = 0;
        return;
    }

    if (mguiListWindows[ix].active)
    {
        if (ptipo == 0x01)  // Apenas Teclado
        {
            key = KEY_NONE;
            
            if (mmsjKeyGet(&k))
            {
                key = k.raw;
            }

            mguiListWindows[ix].keyTec = key;
        }
        else if (ptipo == 0x00)
        {
            pmouseData->mouseButton = mouseBtnPres;
            pmouseData->mouseBtnDouble = mouseBtnPresDouble;
            pmouseData->vpostx = vpostx;
            pmouseData->vposty = vposty;
            pmouseData->mouseX = mouseX;
            pmouseData->mouseY = mouseY;
        }
    }
    else
    {
        if (ptipo == 0x01)  // Apenas Teclado
            mguiListWindows[ix].keyTec = 0x00;
        else if (ptipo == 0x00)
        {
            pmouseData->mouseButton = 0;
            pmouseData->mouseBtnDouble = 0;
            pmouseData->vpostx = 0;
            pmouseData->vposty = 0;
            pmouseData->mouseX = 0;
            pmouseData->mouseY = 0;
        }
    }
}

//-------------------------------------------------------------------------
void getColorData(MGUI_COLOR *pColor)
{
    pColor->fg = vcorwf;
    pColor->bg = vcorwb;
}

//-------------------------------------------------------------------------
unsigned char waitButton(void)
{
  unsigned char i, ii, iii;
  ii = 0;

  if (mouseBtnPres == 0x01)  // Esquerdo
  {
    for (i = 1; i <= 7; i++) {
        if (vbuttonwin[i] != 0 && vpostx >= vbuttonwin[i] && vpostx <= (vbuttonwin[i] + 32) && vposty >= vbuttonwiny && vposty <= (vbuttonwiny + 10)) {
        ii = 1;

        for (iii = 1; iii <= (i - 1); iii++)
            ii *= 2;

        break;
        }
    }
  }

  return ii;
}

//-------------------------------------------------------------------------
unsigned char message(char* bstr, unsigned char bbutton, unsigned short btime)
{
	unsigned short i, ii, iii, xi, yi, xf, xm, yf, ym, pwidth, pheight, xib, yib, xic, yic;
	unsigned char qtdnl, maxlenstr;
	unsigned char qtdcstr[8], poscstr[8], cc, dd, vbty = 0;
	unsigned char *bstrptr;
    VDP_COORD cursor;
    unsigned char slinha[7][26];
    MGUI_SAVESCR vsavescr;
    unsigned char vbuttonmess[16];
    unsigned int error_code = OS_ERR_NONE;
    OS_TCB *ptcb;

    cursor = vdp_get_cursor_safe();

    TrocaSpriteMouse(MOUSE_HOURGLASS);

	qtdnl = 1;
	maxlenstr = 0;
	qtdcstr[1] = 0;
	poscstr[1] = 0;
	i = 0;
    iii = 0;

    for (ii = 0; ii <= 7; ii++)
        vbuttonwin[ii] = 0;

    for (ii = 0; ii <= 15; ii++)
        vbuttonmess[ii] = 0;

    bstrptr = bstr;
	while (*bstrptr)
	{
		qtdcstr[qtdnl]++;

		if (qtdcstr[qtdnl] > 26)
			qtdcstr[qtdnl] = 26;

		if (qtdcstr[qtdnl] > maxlenstr)
			maxlenstr = qtdcstr[qtdnl];

		if (*bstrptr == '\n')
		{
            slinha[qtdnl][iii] = '\0';

			qtdcstr[qtdnl]--;
			qtdnl++;

			if (qtdnl > 6)
				qtdnl = 6;

			qtdcstr[qtdnl] = 0;
			poscstr[qtdnl] = i + 1;
            iii = 0;
		}

        slinha[qtdnl][iii] = *bstrptr;

        iii++;
        bstrptr++;
        i++;
	}

	if (maxlenstr > 26)
		maxlenstr = 26;

	if (qtdnl > 6)
		qtdnl = 6;

	pwidth = (maxlenstr + 1) * 6;
	pwidth = pwidth + 2;
	xm = pwidth / 2;
	xi = ((cursor.maxx) / 2) - xm + 1;
	xf = ((cursor.maxx) / 2) + xm - 1;

	pheight = 10 * qtdnl;
	pheight = pheight + 20;
	ym = pheight / 2;
	yi = ((cursor.maxy) / 2) - ym - 1;
	yf = ((cursor.maxy) / 2) + ym - 1;

	// Desenha Linha Fora
    SaveScreenNew(&vsavescr, xi,yi,pwidth + 5,pheight + 5);

    FillRect(xi,yi,pwidth,pheight,vcorwb);
	DrawRoundRect(xi,yi,pwidth,pheight,2,vcorwf);  // rounded rectangle around text area

	// Escreve Texto Dentro da Caixa de Mensagem
	for (i = 1; i <= qtdnl; i++)
	{
		xib = xi + xm;
		xib = xib - ((qtdcstr[i] * 6) / 2);
		yib = yi + 2 + (10 * (i - 1));

        writesxy(xib,yib,2,slinha[i],vcorwf,vcorwb);
	}

	// Desenha Botoes
    i = 1;
	while (bbutton)
	{
		xib = xi + 2 + (34 * (i - 1));
		yib = yf - 12;
        vbty = yib;
		i++;

        drawButtonsnew(&vbuttonmess, &bbutton, xib, yib);
	}

    ii = 0;

    if (!btime)
    {
        vbuttonmess[14] = OSTCBCur->OSTCBPrio;
        vbuttonmess[15] = vbty;

        TrocaSpriteMouse(MOUSE_POINTER);

        OSTaskCreate(messageTask, (void *)&vbuttonmess, &StkMessage[STACKSIZE], TASK_MGUI_MESSAGE);

        vIndicaDialog = 1;

        OSTaskSuspend(OS_PRIO_SELF);

        ii = vbuttonmess[0];

        TrocaSpriteMouse(MOUSE_HOURGLASS);
    }
    else {
        for (dd = 0; dd <= 10; dd++)
        for (cc = 0; cc <= btime; cc++);
    }

    RestoreScreen(&vsavescr);

    TrocaSpriteMouse(MOUSE_POINTER);

    return ii;
}

//-----------------------------------------------------------------------------
void messageTask(void *pData)
{
    unsigned char i, ii = 0, iii;
    unsigned char key = KEY_NONE;
    unsigned char tabLatch = 0;
    unsigned char focusCount = 0;
    unsigned char focusPos = 0;
    unsigned char focusedButton = 0;
    unsigned char prevFocusedButton = 0;
    unsigned char orderedButtons[7];
    unsigned char vbty;
    unsigned char callerPrio;
    MMSJ_KEYEVENT k;
    unsigned char *vbutton = (unsigned char *)pData;
    OS_TCB *ptcb;

    vbty = vbutton[15];
    callerPrio = vbutton[14];

    for (i = 0; i < 7; i++)
        orderedButtons[i] = 0;

    for (i = 1; i <= 7; i++)
    {
        if (vbutton[i] == 0)
            continue;

        for (iii = 0; iii < focusCount; iii++)
        {
            if (vbutton[i] < vbutton[orderedButtons[iii]])
                break;
        }

        for (; focusCount > iii; focusCount--)
            orderedButtons[focusCount] = orderedButtons[focusCount - 1];

        orderedButtons[iii] = i;
        focusCount++;
    }

    if (focusCount)
    {
        focusedButton = orderedButtons[0];
        DrawRoundRect(vbutton[focusedButton], vbty, 32, 10, 1, VDP_DARK_BLUE);
    }

    while (!ii) {
        if (mouseBtnPres == 0x01)  // Esquerdo
        {
            for (i = 1; i <= 7; i++) {
                if (vbutton[i] != 0 && vpostx >= vbutton[i] && vpostx <= (vbutton[i] + 32) && vposty >= vbty && vposty <= (vbty + 10))
                {
                    ii = 1;

                    for (iii = 1; iii <= (i - 1); iii++)
                        ii *= 2;

                    break;
                }
            }
        }

        key = KEY_NONE;
        if (mmsjKeyGet(&k))
        {
            if (k.flags == 0x00)
                key = k.ascii;
        }

        if (focusCount)
        {
            if (key == 0x09 && focusCount > 1)
            {
                if (!tabLatch)
                {
                    prevFocusedButton = focusedButton;
                    focusPos++;
                    if (focusPos >= focusCount)
                        focusPos = 0;

                    focusedButton = orderedButtons[focusPos];

                    DrawRoundRect(vbutton[prevFocusedButton], vbty, 32, 10, 1, vcorwf);
                    DrawRoundRect(vbutton[focusedButton], vbty, 32, 10, 1, VDP_DARK_BLUE);

                    tabLatch = 1;
                }
            }
            else
            {
                tabLatch = 0;
            }

            if (key == 0x0D)
            {
                ii = 1;

                for (iii = 1; iii <= (focusedButton - 1); iii++)
                    ii *= 2;
            }
        }

        OSTimeDlyHMSM(0, 0, 0, 30);
    }

    vbutton[0] = ii;

    // Resume task chamadora e a tela do MGUI, sem despertar tasks alheias.
    if (callerPrio < (OS_LOWEST_PRIO + 1u))
    {
        ptcb = OSTCBPrioTbl[callerPrio];
        if (ptcb != (OS_TCB *)0 && ptcb != OS_TCB_RESERVED)
        {
            if ((ptcb->OSTCBStat & OS_STAT_SUSPEND) != 0u)
                OSTaskResume(callerPrio);
        }
    }

    ptcb = OSTCBPrioTbl[TASK_MGUI_TELA];
    if (ptcb != (OS_TCB *)0 && ptcb != OS_TCB_RESERVED)
    {
        if ((ptcb->OSTCBStat & OS_STAT_SUSPEND) != 0u)
            OSTaskResume(TASK_MGUI_TELA);
    }

    vIndicaDialog = 0;

    OSTaskDel(OS_PRIO_SELF);
}

//-----------------------------------------------------------------------------
void MostraIcone(unsigned short xi, unsigned short yi, unsigned char vicone, unsigned char colorfg, unsigned char colorbg)
{
    unsigned short yf;
    unsigned int ix, iy;
    unsigned int offset, posX, posY, modY, offsetIcon;
    unsigned char pixel, color = ((colorfg << 4) + colorbg);
    unsigned char* vTempIcones = iconesMenuSys;

    // Define Final
    yf = (yi + 8);
    ix = 0;
    offsetIcon = (vicone * 8);

    for (iy = yi; iy <= yf; iy++)
    {
        posX = (int)(8 * (xi / 8));
        posY = (int)(256 * (iy / 8));
        modY = (int)(iy % 8);
        offset = posX + modY + posY;

        pixel = *(vTempIcones + offsetIcon + ix);
        setWriteAddress(mgui_pattern_table + offset);
        *vvdgd = pixel;
        setWriteAddress(mgui_color_table + offset);
        *vvdgd = color;

        ix++;
    }
}

//-----------------------------------------------------------------------------
//  vicone: 1 - Ponteiro, 2 - Ampulheta
//-----------------------------------------------------------------------------
void TrocaSpriteMouse(unsigned char vicone)
{
    long ix;
    unsigned char tempPtrMouse[8];
    unsigned char* vTempSpritePointer = mousePointer;
    unsigned char* vTempSpriteHourGlass = mouseHourGlass;

    // Inicializa ponteiro Mouse
    switch (vicone)
    {
        case 1:
            for (ix = 0; ix < 8; ix++)
                tempPtrMouse[ix] = *(vTempSpritePointer + ix);
            break;
        case 2:
            for (ix = 0; ix < 8; ix++)
                tempPtrMouse[ix] = *(vTempSpriteHourGlass + ix);
            break;
    }

    vdp_set_sprite_pattern(0, tempPtrMouse);
}

//-------------------------------------------------------------------------
unsigned char new_menu(void)
{
    unsigned short lc;
    unsigned char vresp, mpos, mtqresp;
    OS_TCB tcb;

    vresp = 1;

    if (vpostx >= COLMENU && vpostx <= (COLMENU + 16))
    {
        // Verifica se a Task ja existe. Se nao, cria
        mtqresp = OSTaskQuery(20, &tcb);
        if (mtqresp != OS_ERR_NONE)
        {
            OSTaskCreate(menuTask, OS_NULL, &StkMenu[STACKSIZEMENU], 20);
        }
    }
    else {
        for (lc = 1; lc <= 4; lc++) {
            mx = COLMENU + (24 * lc);
            if (vpostx >= mx && vpostx <= (mx + 16)) {
/*                InvertRect( mx, 4, 8, 8);
                InvertRect( mx, 4, 8, 8);*/
                break;
            }
        }

        switch (lc) {
            case 1: // RUN
                runBin();
                break;
            case 2: // MMSJOS
                break;
            case 3: // SETUP
                break;
            case 4: // EXIT
                mpos = message("Do you want to exit ?\0", BTYES | BTNO, 0);
                if (mpos == BTYES)
                    vresp = 0;

                break;
        }
    }

    return vresp;
}

//-----------------------------------------------------------------------------
void menuTask(void *pData)
{
    unsigned char vpos = 0, mpos;
    unsigned short vx, vy, vposicony;
    unsigned char *vEndExec;
    unsigned long vsizefilemalloc;
    unsigned char tmp[16];

    mx = 0;
    my = LINHAMENU;
    mpos = 0;

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    SaveScreenNew(&endSaveMenu, mx,my,128,44);

    FillRect(mx,my,128,42,vcorwb);
    DrawRect(mx,my,128,42,vcorwf);

    mpos += 2;
    menyi[0] = my + mpos;
    writesxy(mx + 8,my + mpos,1,"Files",vcorwf,vcorwb);
    mpos += 12;
    menyf[0] = my + mpos;
    DrawLine(mx,my + mpos,mx+128,my + mpos,vcorwf);

    mpos += 2;
    menyi[1] = my + mpos;
    writesxy(mx + 8,my + mpos,1,"Import File",vcorwf,vcorwb);
    mpos += 12;
    menyf[1] = my + mpos;
    mpos += 2;
    menyi[2] = my + mpos;
    writesxy(mx + 8,my + mpos,1,"About",vcorwf,vcorwb);
    mpos += 12;
    menyf[2] = my + mpos;
    DrawLine(mx,my + mpos,mx+128,my + mpos,vcorwf);

    TrocaSpriteMouse(MOUSE_POINTER);

    while (1)
    {
        if (mouseBtnPres == 0x01)  // Esquerdo
        {
            if ((vposty >= my && vposty <= my + 42) && (vpostx >= mx && vpostx <= mx + 128))
            {
                vpos = 0;
                vposicony = 0;

                for(vy = 0; vy <= 1; vy++)
                {
                    if (vposty >= menyi[vy] && vposty <= menyf[vy])
                    {
                        vposicony = menyi[vy];
                        break;
                    }

                    vpos++;
                }

                switch (vpos)
                {
                    case 0: // Call "Files" Program from Disk
                        vsizefilemalloc = fsInfoFile("/MGUI/PROGS/FILES.BIN", INFO_SIZE);
                        if (vsizefilemalloc != ERRO_D_NOT_FOUND)
                        {
                            TrocaSpriteMouse(MOUSE_HOURGLASS);
                            vEndExec = (unsigned char*)ADDR_EXEC_FILES; // endereco fixo FILES
                            loadFile("/MGUI/PROGS/FILES.BIN", (unsigned long*)vEndExec);
                            paramBasic[0] = '\0';
                            strcpy(paramBasic, ",");
                            ltoa(vsizefilemalloc, tmp, 10);
                            strcat(paramBasic, tmp);
                            TrocaSpriteMouse(MOUSE_POINTER);
                            if (!verro)
                                runFromMGUI(vEndExec);
                            else
                                message("Loading Error...\0", BTCLOSE, 0);
                        }
                        else
                            message("File not found...\n/MGUI/PROGS/FILES.BIN\0", BTCLOSE, 0);

                        break;
                    case 1: // Import File via Serial
                        importFile();
                        break;
                    case 2: // About
                        message("MGUI v"versionMgui"\nGraphical User Interface\n \nwww.utilityinf.com.br\0", BTCLOSE, 0);
                        break;
                }
            }

            break;
        }

        OSTimeDlyHMSM(0, 0, 0, 50);
    }

    RestoreScreen(&endSaveMenu);

    OSTaskDel(OS_PRIO_SELF);
}

//-----------------------------------------------------------------------------
void runBin(void)
{
    unsigned short ix;
    unsigned char vwb, vresp;
    unsigned char vnamein[64], vfilename[64], vfullpath[96];
    unsigned char *vEndExec;
    unsigned char vUseFixedAddr;
    unsigned long vsizefilemalloc;
    char *vdot;
    MGUI_SAVESCR vsavescr;

    vnamein[0] = '\0';
    vfilename[0] = '\0';
    vfullpath[0] = '\0';

    SaveScreenNew(&vsavescr, 10,40,240,60);
    showWindow("Run",10,40,240,50,BTOK | BTCANCEL);

    writesxy(12,57,8,"File Name:",vcorwf,vcorwb);

    {
        unsigned char wmode = WINFULL;
        while (1)
        {
            fillin(0, vnamein, 78, 57, 130, wmode);
            if (button(1, "OK", 18, 78, 44, 10, wmode))
            {
                vwb = BTOK;
                break;
            }

            if (button(2, "CANCEL", 66, 78, 44, 10, wmode))
            {
                vwb = BTCANCEL;
                break;
            }

            wmode = WINOPER;

            if (vwb == BTOK || vwb == BTCANCEL)
                break;

            OSTimeDlyHMSM(0, 0, 0, 30);
        }
    }

    RestoreScreen(&vsavescr);

    if (vwb != BTOK)
        return;

    if (vnamein[0] == '\0')
    {
        message("Error, file name must be provided!!\0", BTCLOSE, 0);
        return;
    }

    for (ix = 0; ix < 63 && vnamein[ix] != '\0'; ix++)
        vfilename[ix] = toupper(vnamein[ix]);

    vfilename[ix] = '\0';

    vdot = 0;
    for (ix = 0; vfilename[ix] != '\0'; ix++)
    {
        if (vfilename[ix] == '.')
            vdot = &vfilename[ix];
    }

    if (!vdot)
    {
        if (strlen(vfilename) > 59)
        {
            message("Invalid file name length\0", BTCLOSE, 0);
            return;
        }

        strcat(vfilename, ".BIN");
    }
    else if (strcmp(vdot, ".BIN") != 0)
    {
        message("Only .BIN files are allowed\0", BTCLOSE, 0);
        return;
    }

    if (vfilename[0] == '/')
        strcpy(vfullpath, vfilename);
    else
    {
        strcpy(vfullpath, "/MGUI/PROGS/");
        strcat(vfullpath, vfilename);
    }

    vresp = message("Run selected file ?\0",(BTYES | BTNO), 0);
    if (vresp != BTYES)
        return;

    vsizefilemalloc = fsInfoFile(vfullpath, INFO_SIZE);
    if (vsizefilemalloc == ERRO_D_NOT_FOUND)
    {
        message("File not found...\0", BTCLOSE, 0);
        return;
    }

    TrocaSpriteMouse(MOUSE_HOURGLASS);
    vUseFixedAddr = 1;
    if (!strcmp(vfullpath, "/MGUI/PROGS/FILES.BIN"))
    {
        vEndExec = (unsigned char*)ADDR_EXEC_FILES;
    }
    else
    {
        vEndExec = (unsigned char*)ADDR_EXEC_PROG;
    }

    if (!vEndExec)
    {
        TrocaSpriteMouse(MOUSE_POINTER);
        message("No memory to load .BIN\0", BTCLOSE, 0);
        return;
    }

    loadFile(vfullpath, (unsigned long*)vEndExec);
    TrocaSpriteMouse(MOUSE_POINTER);
    if (!verro)
        runFromMGUI(vEndExec);
    else
    {
        message("Loading Error...\0", BTCLOSE, 0);
    }

    return;
}

//-----------------------------------------------------------------------------
void importFile(void)
{
    unsigned long vStep, ix;
    unsigned char *xaddress = 0x00840000;
    unsigned char *xaddressStart;
    unsigned char vErro, vPerc;
    char vfilename[64], vstring[64];
    unsigned char vwb, vresp, vBuffer[128];
    int iy;
    unsigned char sqtdtam[10];
    unsigned long vSizeTotalRec;
    unsigned short vChunkSize;
    MGUI_SAVESCR vsavescr;

    vstring[0] = '\0';

    vSizeTotalRec = lstmGetSize();

    SaveScreenNew(&vsavescr, 10,40,240,60);
    showWindow("Import File",10,40,240,50,BTOK | BTCANCEL);

    writesxy(12,57,8,"File Name:",vcorwf,vcorwb);

    vErro = RETURN_OK;

    {
        unsigned char wmode = WINFULL;
        while (1)
        {
            fillin(0,vstring, 78, 57, 130, wmode);
            if (button(1, "OK", 18, 78, 44, 10, wmode))
            {
                vwb = BTOK;
                break;
            }

            if (button(2, "CANCEL", 66, 78, 44, 10, wmode))
            {
                vwb = BTCANCEL;
                break;
            }

            wmode = WINOPER;

            if (vwb == BTOK || vwb == BTCANCEL)
                break;

            OSTimeDlyHMSM(0, 0, 0, 30);
        }
    }

    RestoreScreen(&vsavescr);

    if (vwb == BTOK)
    {
        if (vstring == 0)
        {
            message("Error, file name must be provided!!\0", BTCLOSE, 0);
            return;
        }

        for(ix = 0; ix < 12 && toupper(vstring[ix]) != 0x00; ix++)
            vfilename[ix] = toupper(vstring[ix]);

        vfilename[ix] = 0x00;

        vresp = message("Confirm serial Connected.\nImport File ?\0",(BTYES | BTNO), 0);
        if (vresp == BTYES)
        {
            TrocaSpriteMouse(MOUSE_HOURGLASS);

            SaveScreenNew(&vsavescr, 10,40,240,70);
            showWindow("Status Import File",10,40,240,70, BTCLOSE);

            // Verifica se o arquivo existe
            if (fsFindInDir(vfilename, TYPE_FILE) < ERRO_D_START)
            {
                writesxy(12,55,8,"Deleting File...",vcorwf,vcorwb);

                // Se existir, apaga
                fsDelFile(vfilename);
            }

            // Cria o Arquivo
            writesxy(12,55,8,"Creating File...",vcorwf,vcorwb);

            vErro = fsCreateFile(vfilename);
            if (vErro == RETURN_OK)
            {
                // Recebe os dados via Serial
                writesxy(12,55,8,"Reading Serial...",vcorwf,vcorwb);

                #ifdef USE_MALLOC
                    xaddress = malloc(128UL * 1024UL); // Aloca 128KB para receber o arquivo via serial
                #else
                    xaddress = (unsigned char*)ADDR_LOAD_FILE; // Endereço fixo
                #endif
                xaddressStart = xaddress;

                if (!loadSerialToMem2(xaddressStart, 0))
                {
                    // Abre Arquivo
                    writesxy(12,55,8,"Opening File...",vcorwf,vcorwb);

                    vErro = fsOpenFile(vfilename);
                    if (vErro != RETURN_OK)
                    {
                        #ifdef USE_MALLOC                        
                            free(xaddressStart);
                        #endif
                    }
                    else
                    {
                        // Grava no Arquivo
                        writesxy(12,55,8,"Writing File...",vcorwf,vcorwb);

                        DrawRect(18,68,203,14,vcorwf);

                        vStep = vSizeTotalRec / 20;
                        vPerc = 0;

                        for (ix = 0; ix < vSizeTotalRec; ix += 128)
                        {
                            vChunkSize = (unsigned short)(vSizeTotalRec - ix);
                            if (vChunkSize > 128)
                                vChunkSize = 128;

                            for (iy = 0; iy < 128; iy++)
                            {
                                if (ix > 0 && ((ix + iy) % vStep) == 0)
                                {
                                    FillRect((21 + vPerc), 71, 8, 8, VDP_DARK_BLUE);
                                    vPerc += 10;
                                }

                                if (iy < vChunkSize)
                                {
                                    vBuffer[iy] = *xaddress;
                                    xaddress += 1;
                                }
                            }

                            vErro = fsWriteFile(vfilename, ix, vBuffer, (unsigned char)vChunkSize);
                            if (vErro != RETURN_OK)
                            {
                                #ifdef USE_MALLOC
                                    free(xaddressStart);
                                #endif
                                break;
                            }
                        }

                        // Fecha Arquivo
                        writesxy(12,55,8,"Closing File...",vcorwf,vcorwb);

                        fsCloseFile(vfilename, 0);
                    }

                    if (vErro == RETURN_OK)
                        writesxy(12,55,8,"Done !         ",vcorwf,vcorwb);
                    else
                    {
                        writesxy(12,55,8,"Writing File Error !",vcorwf,vcorwb);
                        itoa(vErro, sqtdtam, 16);
                        writesxy(12,65,8,sqtdtam,vcorwf,vcorwb);
                    }
                }
                else
                    writesxy(12,55,8,"Serial Load Error...",vcorwf,vcorwb);
            }
            else
            {
                writesxy(12,55,8,"Create File Error...",vcorwf,vcorwb);
                itoa(vErro, sqtdtam, 16);
                writesxy(12,65,8,sqtdtam,vcorwf,vcorwb);
                writesxy(12,75,8,vfilename,vcorwf,vcorwb);
            }

            TrocaSpriteMouse(MOUSE_POINTER);

            while (1)
            {
                vwb = waitButton();

                if (vwb == BTCLOSE)
                    break;

                OSTimeDlyHMSM(0, 0, 0, 30);
            }

            RestoreScreen(&vsavescr);
        }
    }

    return;
}

//-----------------------------------------------------------------------------
void putImagePbmP4(unsigned char* cursor, unsigned short ix, unsigned short iy)
{
    char tipo[3], cnum[5];
    int largura = 0, altura = 0;
    int bytes_por_linha,x,y,ixx;
    unsigned char* dados = cursor;
    unsigned char* linha = dados;

    // Ler o tipo do formato (P4)
    tipo[0] = cursor[0];
    tipo[1] = cursor[1];
    tipo[2] = '\0';
    cursor += 3;

    if (strcmp(tipo, "P4") != 0)
    {
        message("Invalid or unsupported PBM format\nexpected P4",BTCLOSE,0);
        return;
    }

    // Ignorar comentários
    while (*cursor == '#') {
        while (*cursor != '\n') cursor++; // Ignorar até o final da linha
        cursor++; // Pular o '\n'
    }

    // Ler largura e altura
    x = 0;
    y = 0;
    while(y < 8)
    {
        if (*cursor != ' ' && *cursor != '\n')
        {
            cnum[x] = *cursor;
            x++;
            cursor++;
            y++;
        }
        else
        {
            cnum[x] = '\0';
            x = 0;

            if (*cursor == ' ')
                largura = atoi(cnum);
            else
            {
                altura = atoi(cnum);
                cursor++;
                break;
            }

            cursor++;
        }
    }

    // Dados de pixels começam após o cabeçalho
    dados = cursor;

    // Calcular o número de bytes por linha (cada byte representa 8 pixels)
    bytes_por_linha = (largura + 7) / 8;

    // Processar os dados de pixels
    for (y = 0; y < altura; y++)
    {
        linha = dados + y * bytes_por_linha;

        // Enviar cada byte da linha para o vídeo
        ixx = ix;
        for (x = 0; x < bytes_por_linha; x++)
        {
            SetByte(ixx, (iy + y), linha[x], vcorwf, vcorwb2);
            ixx += 8;
        }
    }
}

#ifndef __EM_OBRAS__
//-----------------------------------------------------------------------------
void desenhaIconesUsuario(void) {
  unsigned short vx, vy;
  unsigned char lc, lcok, *ptr_ico, *ptr_prg, *ptr_pos;

  // COLOCAR ICONSPERLINE = 10
  // COLOCAR SPACEICONS = 8

  *next_pos = 0;

  ptr_pos = vFinalOS + (MEM_POS_MGICFG + 16);
  ptr_ico = ptr_pos + 32;
  ptr_prg = ptr_ico + 320;

  for(lc = 0; lc <= (ICONSPERLINE * 4 - 1); lc++) {
    ptr_pos = ptr_pos + lc;
    ptr_ico = ptr_ico + (lc * 10);
    ptr_prg = ptr_prg + (lc * 10);

    if (*ptr_prg != 0 && *ptr_ico != 0) {
      if (*ptr_pos <= (ICONSPERLINE - 1)) {
        vx = COLINIICONS + (24 + SPACEICONS) * *ptr_pos;
        vy = 40;
      }
      else if (*ptr_pos <= (ICONSPERLINE * 2 - 1)) {
        vx = COLINIICONS + (24 + SPACEICONS) * (*ptr_pos - ICONSPERLINE);
        vy = 72;
      }
      else if (*ptr_pos <= (ICONSPERLINE * 3 - 1)) {
        vx = COLINIICONS + (24 + SPACEICONS) * (*ptr_pos - ICONSPERLINE);
        vy = 104;
      }
      else {
        vx = COLINIICONS + (24 + SPACEICONS) * (*ptr_pos - ICONSPERLINE * 2);
        vy = 136;
      }

      lcok = lc + 20;

      SendIcone(lcok);
      MostraIcone(vx, vy, lcok);

      *next_pos = *next_pos + 1;
    }
  }
}

//-----------------------------------------------------------------------------
void SendIcone_24x24(unsigned char vicone)
{
    unsigned char vnomefile[12];
    unsigned char *ptr_prg;
    unsigned long *ptr_viconef;
    unsigned short ix, iy, iz, pw, ph;
    unsigned char* pimage;
    unsigned char ic;

    ptr_prg = vFinalOS + (MEM_POS_MGICFG + 16) + 32 + 320;

    // Procura Icone no Disco se Nao for Padrao
    if (vicone >= 20)
    {
        vicone -= 20;
        ptr_prg = ptr_prg + (vicone * 10);
        _strcat(vnomefile,*ptr_prg,".ICO");
        loadFile(vnomefile, (unsigned long*)0x00FF9FF8);   // 12K espaco pra carregar arquivo. Colocar logica pra pegar tamanho e alocar espaco
        vicone += 20;
        if (*verro)
            vicone = 9;
        else
            ptr_viconef = viconef;
    }

    if (vicone < 20)
        ptr_viconef = vFinalOS + (MEM_POS_ICONES + (1152 * vicone));

    ic = 0;
    iz = 0;
    pw = 24;
    ph = 24;
    pimage = ptr_viconef;

    // Acumula dados, enviando em 9 vezes de 64 x 16 bits
    *vpicg = 0x04;
    *vpicg = 0xDE;
    *vpicg = pw;
    *vpicg = ph;
    *vpicg = vicone;

    *vpicg = 130;
    *vpicg = 0xDE;
    *vpicg = ic;

    for (ix = 0; ix < 576; ix++)
    {
        *vpicg = *pimage++ & 0x00FF;
        *vpicg = *pimage++ & 0x00FF;
        iz++;

        if (iz == 64 && ic < 8)
        {
            ic++;

            *vpicg = 130;
            *vpicg = 0xDE;
            *vpicg = ic;

            iz = 0;
        }
    }
}

//-----------------------------------------------------------------------------
void SendIcone(unsigned char vicone)
{
    unsigned char vnomefile[12];
    unsigned char *ptr_prg;
    unsigned long *ptr_viconef;
    unsigned short ix, iy, iz, pw, ph;
    unsigned char* pimage;
    unsigned char ic;

    ptr_prg = vFinalOS + (MEM_POS_MGICFG + 16) + 32 + 320;

    // Procura Icone no Disco se Nao for Padrao
    if (vicone >= 20)
    {
        vicone -= 20;
        ptr_prg = ptr_prg + (vicone * 10);
        _strcat(vnomefile,*ptr_prg,".ICO");
        loadFile(vnomefile, (unsigned long*)0x00FF9FF8);   // 12K espaco pra carregar arquivo. Colocar logica pra pegar tamanho e alocar espaco
        vicone += 20;
        if (*verro)
            vicone = 9;
        else
            ptr_viconef = viconef;
    }

    if (vicone < 20)
        ptr_viconef = vFinalOS + (MEM_POS_ICONES + (4608 * vicone));

    ic = 0;
    iz = 0;
    pw = 48;
    ph = 48;
    pimage = ptr_viconef;

    // Acumula dados, enviando em 36 vezes de 64 x 16 bits
    *vpicg = 0x04;
    *vpicg = 0xDE;
    *vpicg = pw;
    *vpicg = ph;
    *vpicg = vicone;

    *vpicg = 130;
    *vpicg = 0xDE;
    *vpicg = ic;

    for (ix = 0; ix < 2304; ix++)
    {
        *vpicg = *pimage++ & 0x00FF;
        *vpicg = *pimage++ & 0x00FF;
        iz++;

        if (iz == 64 && ic < 35)
        {
            ic++;

            *vpicg = 130;
            *vpicg = 0xDE;
            *vpicg = ic;

            iz = 0;
        }
    }
}

//------------------------------------------------------------------------
void VerifyMouse(unsigned char vtipo) {
}

//-------------------------------------------------------------------------
void new_icon(void) {
}

//-------------------------------------------------------------------------
void del_icon(void) {
}

//-------------------------------------------------------------------------
void mgi_setup(void) {
}

//-------------------------------------------------------------------------
void executeCmd(void) {
    unsigned char vstring[64], vwb;

    vstring[0] = '\0';

    strcpy(vparamstr,"Execute");
    vparam[0] = 10;
    vparam[1] = 40;
    vparam[2] = 280;
    vparam[3] = 50;
    vparam[4] = BTOK | BTCANCEL;
    showWindow();

    writesxy(12,55,1,"Execute:",vcorwf,vcorwb);

    {
    unsigned char wmode = WINFULL;
    while (1) {
        fillin(0,vstring, 84, 55, 160, wmode);
        if (button(1, "OK", 18, 78, 44, 10, wmode))
        {
            vwb = BTOK;
            break;
        }

        if (button(2, "CANCEL", 66, 78, 44, 10, wmode))
        {
            vwb = BTCANCEL;
            break;
        }
        wmode = WINOPER;

        if (vwb == BTOK || vwb == BTCANCEL)
            break;
    }
    }

    if (vwb == BTOK) {
        strcpy(vbuf, vstring);

        MostraIcone(144, 104, ICON_HOURGLASS);  // Mostra Ampulheta

        // Chama processador de comandos
        processCmd();

        while (*vxmaxold != 0) {
            vwb = waitButton();

            if (vwb == BTCLOSE)
                break;
        }

        if (*vxmaxold != 0) {
            *vxmax = *vxmaxold;
            *vymax = *vymaxold;
            *vcol = 0;
            *vlin = 0;
            *voverx = 0;
            *vovery = 0;
            *vxmaxold = 0;
            *vymaxold = 0;
        }

        *vbuf = 0x00;  // Zera Buffer do teclado
    }
}

//-------------------------------------------------------------------------
void combobox(unsigned char* vopt, unsigned char *vvar,unsigned char x, unsigned char y, unsigned char vtipo) {
}

//-------------------------------------------------------------------------
void editor(unsigned char* vtexto, unsigned char *vvar,unsigned char x, unsigned char y, unsigned char vtipo) {
}
#endif