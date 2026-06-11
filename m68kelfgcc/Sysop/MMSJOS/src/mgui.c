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
* 10/05/2026  0.7a04  Moacir Jr.   Remover uC/OS-II - RTOS
* 16/05/2026  1.0a02  Moacir Jr.   Versao publicacao
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
#define MMSJ320API_DECLARE_ONLY
#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "mmsjos.h"
#include "monitor.h"
#include "monitorapi.h"
#include "mgui.h"
#ifdef USE_MALLOC
#include <malloc.h>
#endif
#if !defined(USE_MALLOC) && !defined(USE_MSMALLOC)
// 2KB Config buffer - 0x0081FFFF
#define ADDR_CFG_FILE   0x0081F800
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

unsigned char mguiFontUseAll = 99;
unsigned char vDateAtuAux[12] = {'1','2','/','3','0','/','1','9','7','2',0x00};
unsigned char vTimeAtuAux[7] = {'0','5',':','0','1',0x00};
volatile unsigned char mguiClockTicks = 0;
volatile unsigned char mguiClockDirty = 1;
static int mguiClockLastMinute = -1;

#define versionMgui "1.0a02"
#define __EM_OBRAS__ 1

unsigned char *vvdgd = 0x00400041; // VDP TMS9118 Data Mode
unsigned char *vvdgc = 0x00400043; // VDP TMS9118 Registers/Address Mode

#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
unsigned char *memPosConfig; // Config file
#else
unsigned char *memPosConfig = (unsigned char*)ADDR_CFG_FILE; // Config file
#endif
unsigned char *imgsMenuSys = 0x00; // Images PBM 16x16 each icone in order (64 Bytes Each)
unsigned char *memVideoFonts = 0x00; // Fontes para Video, formato igual ao do VDP (8 bytes por char, 256 chars = 2048 bytes)
unsigned char *memLoadFileFont = 0x00; // Fontes para Video, formato igual ao do VDP (8 bytes por char, 256 chars = 2048 bytes)
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
unsigned char bufOut[128];
unsigned int timeToDoubleClick = 0xFFFF;

static unsigned char mguiToUpper(unsigned char c);
static void mguiClockPut2(unsigned char *dst, int val);
static void mguiClockDraw(void);
static void mguiClockReadRtc(unsigned char force);

//=============================================================================
// DESKTOP ICONS
//=============================================================================
#define DESK_ICON_MAX    20      /* 5 cols x 4 rows                          */
#define DESK_ICON_COLS   5
#define DESK_ICON_ROWS   4
#define DESK_ICON_W      48      /* pixel width of each icon cell            */
#define DESK_ICON_H      40      /* pixel height of each icon cell           */
#define DESK_ICON_IMG_W  16      /* icon image width in pixels               */
#define DESK_ICON_IMG_H  16      /* icon image height in pixels              */
#define DESK_START_Y     25      /* desktop area starts below menu bar       */
#define DESK_CFG_FILE    "/MGUI/MGUIDESK.CFG"
#define DESK_ICON_BUF_SZ 512    /* temp PBM buffer; avoid header/comment overrun */
#define DESK_CFG_SIZE    1024   /* max MGUIDESK.CFG size                     */

typedef struct {
    char filename[9];   /* up to 8 chars of name, zero-terminated           */
    char ext[4];        /* extension 3 chars + null                         */
    char path[20];      /* directory path, e.g. "/" or "/DOCS"              */
    char askParam;      /* 0 = open direct, 1 = ask parameters before open   */
    char active;        /* 1 = occupied                                     */
} DESK_ICON;

static DESK_ICON  deskIcons[DESK_ICON_MAX];
static unsigned char *memDeskCfg = 0;          /* MGUIDESK.CFG text buffer   */
static unsigned char deskIconBuf[DESK_ICON_BUF_SZ]; /* temp per-icon image   */
static unsigned char deskSelected = 0xFF;      /* selected slot 0..24, 0xFF=none */

#define MGUI_WT_FILLIN   1
#define MGUI_WT_BUTTON   2
#define MGUI_WT_RADIO    3
#define MGUI_WT_TOGGLE   4
#define MGUI_WT_COMBO    5

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
static unsigned short mguiFillinCursor[24];
static unsigned short mguiFillinOffset[24];
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
            result.key = (unsigned char)(mguiListWindows[*mguiIdRequest].keyTec & 0xFF);
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
#define STACKSIZEMGUI  8192
#define STACKSIZEMOUSE  2048
#define STACKSIZEMENU  1024

void mouseFunc (void *pData);
void menuFunc (void *pData);
void messageFunc (void *pData);
void runBin(void);
void redrawScreen(void);
void restoreMGUI(void);

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
    unsigned char pMoveIdX = addrSetFontUseG2.w, pMoveIdY = addrSetFontUseG2.h;
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
    unsigned short vAntY;
    unsigned long fontBase;
    unsigned int firstMask;
    unsigned int secondMask;
    unsigned int color;
    unsigned int src16;
    unsigned int shifted;
    unsigned int lineChar;
    unsigned char pixel;
    unsigned char pixel2;
    VDP_COORD cursor;

    cursor = vdp_get_cursor_safe();

    /* Fonte default (MGUI original): 6x8 iniciando em 0x20 */
    fontBase = (unsigned long)mguiVideoFontes;
    glyphW = 6;
    glyphH = 8;
    charIndex = (chr >= 32) ? (unsigned short)(chr - 32) : 0;

    /* Fonte custom (setFontUseG2): mesmo formato compacto de 8 bytes por char */
    if (addrSetFontUseG2.addr != 0)
    {
        fontBase = addrSetFontUseG2.addr;
        if (addrSetFontUseG2.w > 0 && addrSetFontUseG2.w <= 8)
            glyphW = addrSetFontUseG2.w;
        if (addrSetFontUseG2.h > 0 && addrSetFontUseG2.h <= 8)
            glyphH = addrSetFontUseG2.h;

        if (chr < addrSetFontUseG2.fc)
            charIndex = 0;
        else
            charIndex = (unsigned short)(chr - addrSetFontUseG2.fc);

        if (addrSetFontUseG2.lc >= addrSetFontUseG2.fc && chr > addrSetFontUseG2.lc)
            charIndex = 0;
    }

    modX = (unsigned short)(cursor.x & 0x07);
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

    color = ((unsigned int)(bgcolorMgui & 0x0F)) | (((unsigned int)fgcolorMgui & 0x0F) << 4);

    vAntY = cursor.y;
    for (i = 0; i < glyphH; i++)
    {
        srcIndex = (unsigned short)((charIndex << 3) + i);
        lineChar = *((unsigned char *)(fontBase + srcIndex));
        lineChar &= (0xFFU << (8 - glyphW));

        src16 = (lineChar << 8);
        shifted = (src16 >> modX);

        posX = (unsigned short)(8 * (cursor.x / 8));
        posY = (unsigned short)(256 * (cursor.y / 8));
        modY = (unsigned short)(cursor.y % 8);

        offset = (unsigned short)(posX + modY + posY);

        setReadAddress(mgui_pattern_table + offset);
        setReadAddress(mgui_pattern_table + offset);
        pixel = *vvdgd;

        pixel = (unsigned char)((pixel & (unsigned char)(~firstMask)) |
                               (((shifted >> 8) & 0xFFU) & firstMask));

        setWriteAddress(mgui_pattern_table + offset);
        *vvdgd = pixel;
        setWriteAddress(mgui_color_table + offset);
        *vvdgd = (unsigned char)color;

        if (secondMask)
        {
            offset2 = (unsigned short)(offset + 8);

            setReadAddress(mgui_pattern_table + offset2);
            setReadAddress(mgui_pattern_table + offset2);
            pixel2 = *vvdgd;

            pixel2 = (unsigned char)((pixel2 & (unsigned char)(~secondMask)) |
                                    ((shifted & 0xFFU) & secondMask));

            setWriteAddress(mgui_pattern_table + offset2);
            *vvdgd = pixel2;
            setWriteAddress(mgui_color_table + offset2);
            *vvdgd = (unsigned char)color;
        }

        cursor.y = (unsigned short)(cursor.y + 1);
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
        #if !defined(USE_MALLOC) && !defined(USE_MSMALLOC)
            mguiSave->id = -1;
        #endif
        return;
    }

    bytes_per_row = (((unsigned int)xf - (unsigned int)xi) / 8u) + 1u;
    total_rows = ((unsigned int)yf - (unsigned int)yi) + 1u;
    vsizetotal = bytes_per_row * total_rows;

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #ifdef USE_MALLOC
            saverPat = malloc(vsizetotal);
            saverCor = malloc(vsizetotal);
        #else
            saverPat = msmalloc(vsizetotal);
            saverCor = msmalloc(vsizetotal);
        #endif
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

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        if (!saverPat || !saverCor)
        {
            #ifdef USE_MALLOC            
                if (saverPat) free(saverPat);
                if (saverCor) free(saverCor);
            #else
                if (saverPat) msfree(saverPat);
                if (saverCor) msfree(saverCor);
            #endif
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

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
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

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        saverPat = mguiSave->pat;
        saverCor = mguiSave->cor;
        
        if (!saverPat || !saverCor || mguiSave->size == 0)
            return;
    #else
        slot = ss_find_slot(mguiSave->id);

        if (slot < 0)
            return;   /* slot não encontrado */ 

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

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #ifdef USE_MALLOC
            free(mguiSave->cor);
            free(mguiSave->pat);
        #else
            msfree(mguiSave->cor);
            msfree(mguiSave->pat);
        #endif
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
    unsigned short maxStore;
    unsigned short cursor;
    unsigned short offset;
    unsigned short visibleLen;
    unsigned short srcPos;
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
    if (maxChars == 0)
        maxChars = 1;

    maxStore = 127;
    len = (unsigned short)strlen(vvar);
    if (len > maxStore)
    {
        vvar[maxStore] = 0x00;
        len = maxStore;
    }

    cursor = mguiFillinCursor[thisIdx];
    offset = mguiFillinOffset[thisIdx];

    if (cursor > len)
        cursor = len;
    if (offset > len)
        offset = len;

    if (isFocused && (vtipo == WINOPER || vtipo == WINFULL))
    {
        if (inp.clicked)
        {
            cursor = len;
            vdisp = 1;
        }

        if (inp.key >= 0x20 && inp.key < 0x7F)
        {
            if (len < maxStore)
            {
                cc = len;
                while (cc > cursor)
                {
                    vvar[cc] = vvar[cc - 1];
                    cc--;
                }
                vvar[cursor] = inp.key;
                vvar[len + 1] = 0x00;
                cursor++;
                len++;
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
                    if (cursor > 0)
                    {
                        cursor--;
                        cc = cursor;
                        while (cc < len)
                        {
                            vvar[cc] = vvar[cc + 1];
                            cc++;
                        }
                        len--;
                        vdisp = 1;
                    }
                    break;
                case KEY_DELETE:
                    if (cursor < len)
                    {
                        cc = cursor;
                        while (cc < len)
                        {
                            vvar[cc] = vvar[cc + 1];
                            cc++;
                        }
                        len--;
                        vdisp = 1;
                    }
                    break;
                case KEY_LEFT:
                    if (cursor > 0)
                    {
                        cursor--;
                        vdisp = 1;
                    }
                    break;
                case KEY_RIGHT:
                    if (cursor < len)
                    {
                        cursor++;
                        vdisp = 1;
                    }
                    break;
                case KEY_HOME:
                    if (cursor != 0)
                    {
                        cursor = 0;
                        vdisp = 1;
                    }
                    break;
                case KEY_END:
                    if (cursor != len)
                    {
                        cursor = len;
                        vdisp = 1;
                    }
                    break;
            }
        }
    }

    if (cursor < offset)
        offset = cursor;
    if (cursor > (unsigned short)(offset + maxChars))
        offset = (unsigned short)(cursor - maxChars);
    if (len > maxChars && offset > (unsigned short)(len - maxChars))
    {
        if (cursor < len)
            offset = (unsigned short)(len - maxChars);
    }
    if (len <= maxChars)
        offset = 0;

    mguiFillinCursor[thisIdx] = cursor;
    mguiFillinOffset[thisIdx] = offset;

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
        if (offset > len)
            offset = len;

        visibleLen = (unsigned short)(len - offset);
        if (visibleLen > maxChars)
            visibleLen = maxChars;

        while (cc < visibleLen)
        {
            srcPos = (unsigned short)(offset + cc);
            cchar = vvar[srcPos];
            vtmp[0] = cchar;
            vtmp[1] = 0x00;

            writesxy(x + (cc * 6), y + 1, 6, vtmp, vcorwf, vcorwb);
            cc++;
        }

        if (isFocused)
        {
            if (cursor < offset)
                cursor = offset;
            if (cursor > (unsigned short)(offset + maxChars))
                cursor = (unsigned short)(offset + maxChars);

            cc = (unsigned short)(cursor - offset);
            if ((x + (cc * 6) + 6) < (x + pwidth))
            {
                vtmp[0] = '|';
                vtmp[1] = 0x00;
                writesxy(x + (cc * 6), y + 1, 6, vtmp, borderColor, vcorwb);
            }
        }
    }
}

//-------------------------------------------------------------------------
static unsigned char comboCopyToken(unsigned char *dst, unsigned char *src, unsigned char max)
{
    unsigned char ix;

    ix = 0;
    while (*src && *src != ',' && ix < (unsigned char)(max - 1))
    {
        dst[ix++] = *src++;
    }
    dst[ix] = 0;

    while (*src && *src != ',')
        src++;

    if (*src == ',')
        src++;

    return ix;
}

//-------------------------------------------------------------------------
static unsigned char comboFindLabel(unsigned char *vopt, unsigned char *vvar, unsigned char *label, unsigned char max)
{
    unsigned char key[24];
    unsigned char firstKey[24];
    unsigned char firstLabel[48];
    unsigned char firstSet;
    unsigned char match;

    firstSet = 0;
    label[0] = 0;

    while (*vopt)
    {
        comboCopyToken(key, vopt, sizeof(key));
        while (*vopt && *vopt != ',') vopt++;
        if (*vopt == ',') vopt++;

        comboCopyToken(label, vopt, max);
        while (*vopt && *vopt != ',') vopt++;
        if (*vopt == ',') vopt++;

        if (!firstSet)
        {
            strcpy(firstKey, key);
            strcpy(firstLabel, label);
            firstSet = 1;
        }

        match = 0;
        if (vvar[0] != 0 && strcmp(vvar, key) == 0)
            match = 1;

        if (match)
            return 1;
    }

    if (firstSet)
    {
        if (vvar[0] == 0)
            strcpy(vvar, firstKey);
        strcpy(label, firstLabel);
        return 1;
    }

    return 0;
}

//-------------------------------------------------------------------------
static unsigned char comboPopup(unsigned char *vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned short width)
{
    MGUI_SAVESCR save;
    MGUI_MOUSE m;
    unsigned char *optBase;
    unsigned char key[24];
    unsigned char label[48];
    unsigned char count;
    unsigned char i;
    unsigned char iy;
    unsigned char prevBtn;
    unsigned char changed;
    unsigned short h;

    count = 0;
    optBase = vopt;
    while (vopt[0])
    {
        while (*vopt && *vopt != ',') vopt++;
        if (*vopt == ',') vopt++;
        while (*vopt && *vopt != ',') vopt++;
        if (*vopt == ',') vopt++;
        count++;
    }

    if (count == 0)
        return 0;

    if (count > 8)
        count = 8;

    h = (unsigned short)(count * 10 + 4);
    SaveScreenNew(&save, x, (unsigned short)(y + 12), width, h);

    FillRect(x, (unsigned short)(y + 12), width, h, vcorwb);
    DrawRect(x, (unsigned short)(y + 12), width, h, vcorwf);

    vopt = optBase;
    prevBtn = 0;
    changed = 0;

    i = 0;
    while (i < count)
    {
        comboCopyToken(key, vopt, sizeof(key));
        while (*vopt && *vopt != ',') vopt++;
        if (*vopt == ',') vopt++;

        comboCopyToken(label, vopt, sizeof(label));
        while (*vopt && *vopt != ',') vopt++;
        if (*vopt == ',') vopt++;

        iy = (unsigned char)(y + 15 + (i * 10));
        FillRect((unsigned char)(x + 2), iy, (unsigned short)(width - 4), 8, vcorwb);
        if (strcmp(vvar, key) == 0)
            writesxy((unsigned short)(x + 4), iy, 1, label, vcorwb, vcorwf);
        else
            writesxy((unsigned short)(x + 4), iy, 1, label, vcorwf, vcorwb);

        i++;
    }

    while (1)
    {
        getMouseData(0, &m);
        getMouseData(1, &m);

        if ((mguiListWindows[*mguiIdRequest].keyTec & 0xFF) == 0x1B)
            break;

        if (m.mouseButton == 0x01 && prevBtn != 0x01)
        {
            if (m.vpostx >= x && m.vpostx <= (x + width) &&
                m.vposty >= (y + 12) && m.vposty <= (y + 12 + h))
            {
                i = (unsigned char)((m.vposty - (y + 14)) / 10);
                if (i < count)
                {
                    vopt = optBase;
                    while (i)
                    {
                        while (*vopt && *vopt != ',') vopt++;
                        if (*vopt == ',') vopt++;
                        while (*vopt && *vopt != ',') vopt++;
                        if (*vopt == ',') vopt++;
                        i--;
                    }

                    comboCopyToken(key, vopt, sizeof(key));
                    strcpy(vvar, key);
                    changed = 1;
                }
            }
            break;
        }

        prevBtn = m.mouseButton;
    }

    RestoreScreen(&save);
    return changed;
}

//-------------------------------------------------------------------------
void combobox(unsigned char id, unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo)
{
    unsigned char thisIdx;
    unsigned char isFocused;
    unsigned char borderColor;
    unsigned char label[48];
    unsigned char vdisp;
    MGUI_INPUT inp;

    thisIdx = mguiWidgetRegister(id, MGUI_WT_COMBO);
    inp = mguiWidgetProcess(thisIdx, x, y, pwidth, 12, vtipo);
    isFocused = inp.focused;
    borderColor = isFocused ? VDP_DARK_BLUE : vcorwf;
    vdisp = 0;

    comboFindLabel(vopt, vvar, label, sizeof(label));

    if ((vtipo == WINOPER || vtipo == WINFULL) && (inp.clicked || inp.key == 0x0D))
    {
        if (comboPopup(vopt, vvar, x, y, pwidth))
            vdisp = 1;
        comboFindLabel(vopt, vvar, label, sizeof(label));
    }

    if (vtipo == WINDISP || vtipo == WINFULL || vdisp)
    {
        FillRect(x, y, pwidth, 12, vcorwb);
        DrawRect(x, y, pwidth, 12, borderColor);
        writesxy((unsigned short)(x + 3), (unsigned short)(y + 2), 1, label, vcorwf, vcorwb);
        writesxy((unsigned short)(x + pwidth - 8), (unsigned short)(y + 2), 1, "v", borderColor, vcorwb);
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
    return mguiCfgGetBuf(memPosConfig, section, key, vOutBuf, vOutMax);
}

//-----------------------------------------------------------------------------
// Config INI - Busca direta no buffer de memoria
// Busca 'key' dentro de '[section]' em memPosConfig; copia o valor em vOutBuf como string.
// Retorna vOutBuf em caso de sucesso, NULL se nao encontrado.
// vOutMax: tamanho do vOutBuf incluindo '\0'
//-----------------------------------------------------------------------------
// Like mguiCfgGetBuf but reads from an arbitrary NUL-terminated buffer instead
// of the global memPosConfig.
//-----------------------------------------------------------------------------
static char mguiCfgGetBuf(unsigned char *buf, char *section, char *key, char *vOutBuf, unsigned char vOutMax)
{
    unsigned char slen = (unsigned char)strlen(section);
    unsigned char klen = (unsigned char)strlen(key);
    unsigned char *p = buf;
    unsigned char i;
    unsigned char inSection = 0;

    if (!p || !section || !slen || !key || !klen || !vOutBuf || vOutMax == 0)
        return 0;

    if (p[0] == 0xEF && p[1] == 0xBB && p[2] == 0xBF)
        p += 3;

    while (*p)
    {
        while (*p == ' ' || *p == '\t') p++;

        if (*p == '\r' || *p == '\n' || *p == ';' || *p == '#')
        {
            while (*p == '\r' || *p == '\n') p++;
            continue;
        }

        if (*p == '[')
        {
            unsigned char *q = p + 1;
            inSection = (strncmp((char *)q, section, slen) == 0 && q[slen] == ']') ? 1 : 0;
        }
        else if (inSection)
        {
            if (strncmp((char *)p, key, klen) == 0 &&
                (p[klen] == ' ' || p[klen] == '\t' || p[klen] == '='))
            {
                unsigned char *q = p + klen;
                while (*q == ' ' || *q == '\t') q++;
                if (*q == '=')
                {
                    q++;
                    while (*q == ' ' || *q == '\t') q++;
                    i = 0;
                    while (*q && *q != '\n' && *q != '\r' && i < (unsigned char)(vOutMax - 1))
                        vOutBuf[i++] = (char)*q++;
                    while (i > 0 && (vOutBuf[i-1] == ' ' || vOutBuf[i-1] == '\t'))
                        i--;
                    vOutBuf[i] = '\0';
                    return 1;
                }
            }
        }

        while (*p && *p != '\n' && *p != '\r') p++;
        while (*p == '\n' || *p == '\r') p++;
    }

    return 0;
}

//=============================================================================
// DESKTOP ICON FUNCTIONS
//=============================================================================

//-----------------------------------------------------------------------------
// Translate icon slot (0..19) to pixel (x,y) top-left corner of cell.
//-----------------------------------------------------------------------------
static void deskSlotXY(unsigned char slot, unsigned short *px, unsigned char *py)
{
    *px = (unsigned short)(slot / DESK_ICON_ROWS) * DESK_ICON_W;
    *py = DESK_START_Y + (unsigned char)(slot % DESK_ICON_ROWS) * DESK_ICON_H;
}

//-----------------------------------------------------------------------------
// Parse MGUIDESK.CFG (stored in memDeskCfg) into deskIcons[].
// Entry format in [ICONS]: NN=FILENAME.EXT,/PATH,ASKPARAM
//   e.g.  00=NOTES.TXT,/,0
//         01=HELLO.BAS,/BASIC,1
//-----------------------------------------------------------------------------
static void deskLoadConfig(void)
{
    unsigned char slot;
    char key[3], val[48], *comma, *comma2, *dot, *p;
    unsigned char i;

    memset(deskIcons, 0, sizeof(deskIcons));

    if (!memDeskCfg || !memDeskCfg[0])
        return;

    for (slot = 0; slot < DESK_ICON_MAX; slot++)
    {
        key[0] = (char)('0' + slot / 10);
        key[1] = (char)('0' + slot % 10);
        key[2] = '\0';
        val[0] = '\0';

        if (!mguiCfgGetBuf(memDeskCfg, "ICONS", key, val, sizeof(val)))
            continue;

        /* val = "FILENAME.EXT,/PATH,ASKPARAM" */
        comma = strchr(val, ',');
        if (!comma)
            continue;
        *comma = '\0';

        /* Find extension dot */
        dot = strchr(val, '.');
        if (dot)
        {
            *dot = '\0';
            /* copy extension (up to 3 chars) */
            for (i = 0; i < 3 && dot[1 + i]; i++)
                deskIcons[slot].ext[i] = dot[1 + i];
            deskIcons[slot].ext[i] = '\0';
        }

        /* copy filename (up to 8 chars) */
        for (i = 0; i < 8 && val[i]; i++)
            deskIcons[slot].filename[i] = val[i];
        deskIcons[slot].filename[i] = '\0';

        /* copy path (up to 19 chars) */
        p = comma + 1;
        comma2 = strchr(p, ',');
        if (comma2)
            *comma2 = '\0';

        for (i = 0; i < 19 && p[i]; i++)
            deskIcons[slot].path[i] = p[i];
        deskIcons[slot].path[i] = '\0';
        if (!deskIcons[slot].path[0])
        {
            deskIcons[slot].path[0] = '/';
            deskIcons[slot].path[1] = '\0';
        }

        deskIcons[slot].askParam = 0;
        if (comma2 && comma2[1] == '1')
            deskIcons[slot].askParam = 1;

        deskIcons[slot].active = 1;
    }
}

//-----------------------------------------------------------------------------
// Save deskIcons[] to MGUIDESK.CFG on disk.
//-----------------------------------------------------------------------------
static void deskSaveConfig(void)
{
    unsigned char slot, i, offset;
    unsigned char linebuf[64];
    char *p;
    unsigned char vErro;

    /* Delete and recreate file */
    fsFindInDir(DESK_CFG_FILE, 1 /*TYPE_FILE*/);
    fsDelFile(DESK_CFG_FILE);

    vErro = fsCreateFile(DESK_CFG_FILE);
    if (vErro != 0 /*RETURN_OK*/)
        return;

    vErro = fsOpenFile(DESK_CFG_FILE);
    if (vErro != 0)
        return;

    /* Write [ICONS] header */
    {
        unsigned char hdr[] = "[ICONS]\r\n";
        fsWriteFile(DESK_CFG_FILE, 0, hdr, (unsigned char)(sizeof(hdr) - 1));
    }

    {
        unsigned long fileOffset = 9; /* after header */
        for (slot = 0; slot < DESK_ICON_MAX; slot++)
        {
            if (!deskIcons[slot].active)
                continue;
            /* Format: NN=FILENAME.EXT,/PATH,ASKPARAM\r\n */
            offset = 0;
            linebuf[offset++] = (unsigned char)('0' + slot / 10);
            linebuf[offset++] = (unsigned char)('0' + slot % 10);
            linebuf[offset++] = '=';
            for (i = 0; deskIcons[slot].filename[i] && offset < 40; i++)
                linebuf[offset++] = deskIcons[slot].filename[i];
            if (deskIcons[slot].ext[0])
            {
                linebuf[offset++] = '.';
                for (i = 0; deskIcons[slot].ext[i] && offset < 44; i++)
                    linebuf[offset++] = deskIcons[slot].ext[i];
            }
            linebuf[offset++] = ',';
            for (i = 0; deskIcons[slot].path[i] && offset < 46; i++)
                linebuf[offset++] = deskIcons[slot].path[i];
            linebuf[offset++] = ',';
            linebuf[offset++] = deskIcons[slot].askParam ? '1' : '0';
            linebuf[offset++] = '\r';
            linebuf[offset++] = '\n';

            fsWriteFile(DESK_CFG_FILE, fileOffset, linebuf, offset);
            fileOffset += offset;
        }
    }

    fsCloseFile(DESK_CFG_FILE, 1 /*updated*/);

    /* Refresh memory buffer */
    if (memDeskCfg)
    {
        unsigned long sz = loadFile(DESK_CFG_FILE, (unsigned short*)memDeskCfg);
        if (sz > DESK_CFG_SIZE) sz = DESK_CFG_SIZE;
        memDeskCfg[sz] = '\0';
    }
}

//-----------------------------------------------------------------------------
// Given a file extension (e.g. "TXT"), look up the icon name in MGUI.CFG
// [ICONTYPE] section. Returns the icon name without extension.
// If not found, uses "BLANK" as default.
//-----------------------------------------------------------------------------
static void deskGetIconName(char *name, char *ext, char *outName)
{
    outName[0] = '\0';

    // Procura no ICONTYPE com a Ext
    if (ext[0] && mguiCfgGetBuf(memPosConfig, "ICONTYPE", ext, outName, 9))
        return;

    // Procura no ICONFILE com o Nome
    if (name[0] && mguiCfgGetBuf(memPosConfig, "ICONFILE", name, outName, 9))
            return;

    strcpy(outName, "BLANK");
}

//-----------------------------------------------------------------------------
// Draw a single icon at its grid slot. Clears cell first.
//-----------------------------------------------------------------------------
static void deskDrawIcon(unsigned char slot)
{
    DESK_ICON *d = &deskIcons[slot];
    unsigned short ix;
    unsigned char  iy;
    char iconname[9];
    char iconpath[32];
    unsigned char namebuf[9];
    unsigned char i, nlen;
    unsigned char hlColor;
    unsigned char centerX;

    deskSlotXY(slot, &ix, &iy);

    /* Use a dark highlight; white was polluting the text bands visually. */
    hlColor = (deskSelected == slot) ? VDP_DARK_BLUE : bgcolorMgui;

    /*if (d->active)
        FillRect((unsigned char)ix, iy, DESK_ICON_W, DESK_ICON_H, hlColor);
    else
        return;*/

    if (!d->active)
        return;

    /* Load icon image from /MGUI/ICONS/<NAME>.PBM */
    deskGetIconName(d->filename, d->ext, iconname);
    strcpy(iconpath, "/MGUI/ICONS/");
    strcat(iconpath, iconname);
    strcat(iconpath, ".PBM");

    if (loadFile((unsigned char*)iconpath, (unsigned short*)deskIconBuf) > 0)
        putImagePbmP4((unsigned long*)deskIconBuf, ix + (DESK_ICON_W - DESK_ICON_IMG_W) / 2, iy);

    /* Name (up to 8 chars) centred in 48px cell */
    nlen = 0;
    for (i = 0; d->filename[i] && nlen < 8; i++)
        namebuf[nlen++] = d->filename[i];

    namebuf[nlen] = '\0';

    /* 5px/char: row of 8 chars = 40px; left pad = (48-40)/2 = 4px */
    centerX = (((8 * addrSetFontUseG2.w) - (strlen(namebuf) * addrSetFontUseG2.w)) / 2);
    writesxy(ix + centerX + 4, iy + DESK_ICON_IMG_H + 1, 1, (unsigned char*)namebuf, vcorwf, hlColor);

    /* Extension (up to 3 chars) – centred: 3*5=15px, pad=(48-15)/2=16px*/
    if (d->ext[0] && strcmp(d->ext,"EXE"))  // qdo EXE nao imprime
        writesxy(ix + 16, iy + DESK_ICON_IMG_H + 9, 1, (unsigned char*)d->ext, vcorwf, hlColor);
}

//-----------------------------------------------------------------------------
// Redraw all desktop icons.
//-----------------------------------------------------------------------------
static void deskDrawAll(void)
{
    unsigned char i;
    for (i = 0; i < DESK_ICON_MAX; i++)
        deskDrawIcon(i);
}

//-----------------------------------------------------------------------------
// Return the icon slot (0..DESK_ICON_MAX-1) at pixel (hx,hy), or 0xFF if none.
//-----------------------------------------------------------------------------
static unsigned char deskHitTest(unsigned char hx, unsigned char hy)
{
    unsigned char slot;

    if (hy < DESK_START_Y)
        return 0xFF;

    if (hy > DESK_START_Y && hy < (DESK_START_Y + DESK_ICON_H))   
    {
        if (hx < DESK_ICON_W) slot = 0;
        else if (hx < (DESK_ICON_W * 2)) slot = 4;
        else if (hx < (DESK_ICON_W * 3)) slot = 8;
        else if (hx < (DESK_ICON_W * 4)) slot = 12;
        else if (hx < (DESK_ICON_W * 5)) slot = 16;
        else return 0xFF;
    } 
    else if (hy > (DESK_START_Y + DESK_ICON_H) && hy < (DESK_START_Y + (DESK_ICON_H * 2)))   
    {
        if (hx < DESK_ICON_W) slot = 1;
        else if (hx < (DESK_ICON_W * 2)) slot = 5;
        else if (hx < (DESK_ICON_W * 3)) slot = 9;
        else if (hx < (DESK_ICON_W * 4)) slot = 13;
        else if (hx < (DESK_ICON_W * 5)) slot = 17;
        else return 0xFF;
    } 
    else if (hy > (DESK_START_Y + (DESK_ICON_H * 2)) && hy < (DESK_START_Y + (DESK_ICON_H * 3)))   
    {
        if (hx < DESK_ICON_W) slot = 2;
        else if (hx < (DESK_ICON_W * 2)) slot = 6;
        else if (hx < (DESK_ICON_W * 3)) slot = 10;
        else if (hx < (DESK_ICON_W * 4)) slot = 14;
        else if (hx < (DESK_ICON_W * 5)) slot = 18;
        else return 0xFF;
    } 
    else if (hy > (DESK_START_Y + (DESK_ICON_H * 3)) && hy < (DESK_START_Y + (DESK_ICON_H * 4)))   
    {
        if (hx < DESK_ICON_W) slot = 3;
        else if (hx < (DESK_ICON_W * 2)) slot = 7;
        else if (hx < (DESK_ICON_W * 3)) slot = 11;
        else if (hx < (DESK_ICON_W * 4)) slot = 15;
        else if (hx < (DESK_ICON_W * 5)) slot = 19;
        else return 0xFF;
    } 

/*    unsigned char col, row, slot;
    unsigned char DESKICONROWS = DESK_ICON_ROWS;
    if (hy < DESK_START_Y) 
        return 0xFF;

    row = (hy - DESK_START_Y) / DESK_ICON_H;
    col = hx / DESK_ICON_W;
    
    if (row >= DESK_ICON_ROWS || col >= DESK_ICON_COLS) 
        return 0xFF;

    slot = col * DESKICONROWS + row;

    if (slot >= DESK_ICON_MAX) 
        return 0xFF;*/

    return slot;
}

//-----------------------------------------------------------------------------
// Open the file represented by deskIcons[slot] using the same EXEC rules as
// files.c: look up [EXEC] in MGUI.CFG, set paramBasic, then run the program.
//-----------------------------------------------------------------------------
static void deskOpenIcon(unsigned char slot)
{
    DESK_ICON *d = &deskIcons[slot];
    char execProg[64];
    char vnomefile[48];
    char vtmpparam[128];
    unsigned char *vEndExec;
    unsigned long vsizefile;
    MGUI_SAVESCR vsavescr;

    if (!d->active) return;

    vtmpparam[0] = '\0';
    execProg[0] = '\0';

    SaveScreenNew(&vsavescr, 0, 0, 255, 192);

    /* Build full path: path + "/" + filename + "." + ext */
    strcpy(vnomefile, d->path);
    if (d->path[0] != '\0' && !(d->path[0] == '/' && d->path[1] == '\0'))
        strcat(vnomefile, "/");
    strcat(vnomefile, d->filename);
    if (d->ext[0])
    {
        strcat(vnomefile, ".");
        strcat(vnomefile, d->ext);
    }

    /* Lookup [EXEC] association for this extension */
    if (d->ext[0])
        mguiCfgGetBuf(memPosConfig, "EXEC", d->ext, execProg, sizeof(execProg));

    if (d->askParam)
    {
        askParamToExec(&vtmpparam);
        mguiClockDirty = 1;
    }

    TrocaSpriteMouse(MOUSE_HOURGLASS);

    if (!execProg[0])
    {
        /* No association – if it looks like an EXE just run it */
        if (strcmp(d->ext, "EXE") == 0)
        {
            #ifdef USE_RELOC_LOAD_PROGS
                paramBasic[0] = '\0';
                if (vtmpparam[0])
                    strcpy(paramBasic,vtmpparam);

                if (loadMbinAndRun(vnomefile, 2) != 0)
                {
                    TrocaSpriteMouse(MOUSE_POINTER);
                    message("Error Executing File\0", BTCLOSE, 0);
                }
                mguiClockDirty = 1;
            #else
                vsizefile = loadFile((unsigned char*)vnomefile,
                                     (unsigned short*)ADDR_EXEC_PROG);
                if (vsizefile > 0 && vsizefile < ERRO_D_START)
                {
                    paramBasic[0] = '\0';
                    runFromMGUI((unsigned long)ADDR_EXEC_PROG);
                }
                else
                    message("Loading Error...\0", BTCLOSE, 0);
            #endif
        }
        else if (strcmp(vnomefile, "BASIC") == 0)
        {
            /* Special case: if the file is literally "BASIC" with no path or extension, just run BASIC */
            char bascmd[] = "BASIC";
            fsOsCommand((unsigned char*)bascmd);
            restoreMGUI(); // in case BASIC doesn't return to caller
        }
        else
            message("No association for this file type.\0", BTCLOSE, 0);
    }
    else if (strcmp(execProg, "BASIC") == 0)
    {
        /* Run BASIC with file as argument */
        char bascmd[48];
        strcpy(bascmd, "BASIC ");
        strcat(bascmd, vnomefile);
        fsOsCommand((unsigned char*)bascmd);
        restoreMGUI(); // in case BASIC redraw mgui (basic exit in text mode)
    }
    else
    {
        /* execProg is a full path to an EXE/BIN that should open this file */
        strcpy(paramBasic, d->path);
        if (d->path[0] != '\0' && !(d->path[0] == '/' && d->path[1] == '\0'))
            strcat(paramBasic, "/");
        strcat(paramBasic, d->filename);
        if (d->ext[0])
        {
            strcat(paramBasic, ".");
            strcat(paramBasic, d->ext);
        }

        #ifdef USE_RELOC_LOAD_PROGS
            if (loadMbinAndRun(execProg, 2) != 0)
            {
                TrocaSpriteMouse(MOUSE_POINTER);
                message("Error Executing File\0", BTCLOSE, 0);
            }
            mguiClockDirty = 1;
        #else
            vsizefile = loadFile((unsigned char*)execProg,
                                 (unsigned short*)ADDR_EXEC_PROG);
            if (vsizefile > 0 && vsizefile < ERRO_D_START)
                runFromMGUI((unsigned long)ADDR_EXEC_PROG);
            else
                message("Loading Error...\0", BTCLOSE, 0);
        #endif
    }

    RestoreScreen(&vsavescr);

    TrocaSpriteMouse(MOUSE_POINTER);
    deskSelected = 0xFF;
    deskDrawAll();
}

//-----------------------------------------------------------------------------
// Dialog to add a new icon.  Prompts for filename (with path) and writes to
// deskIcons[] into the first free slot, then saves config.
//-----------------------------------------------------------------------------
static void deskAddIconDialog(void)
{
    MGUI_SAVESCR vsavescr;
    unsigned char vstring[40];
    unsigned char wmode = WINFULL;
    unsigned char vwb = BTCANCEL;
    unsigned char slot, i;
    char *dot, *slash;
    char vpath[20], vname[9], vext[4];
    unsigned char namelen;

    /* Find a free slot */
    slot = 0xFF;
    for (i = 0; i < DESK_ICON_MAX; i++)
    {
        if (!deskIcons[i].active) { slot = i; break; }
    }
    if (slot == 0xFF)
    {
        message("Desktop is full (25 icons max).\0", BTCLOSE, 0);
        return;
    }

    SaveScreenNew(&vsavescr, 10, 40, 236, 60);
    showWindow((unsigned char*)"Add Desktop Icon", 10, 40, 236, 60, BTNONE);
    writesxy(12, 57, 1, (unsigned char*)"File (full path):", vcorwf, vcorwb);

    vstring[0] = '\0';
    wmode = WINFULL;

    while (1)
    {
        fillin(0, vstring, 120, 57, 120, wmode);

        if (button(1, (unsigned char*)"OK",     18, 78, 44, 10, wmode)) { vwb = BTOK;     break; }
        if (button(2, (unsigned char*)"CANCEL",  66, 78, 44, 10, wmode)) { vwb = BTCANCEL; break; }

        wmode = WINOPER;
    }

    RestoreScreen(&vsavescr);

    if (vwb != BTOK || !vstring[0])
        return;

    /* Convert to uppercase */
    for (i = 0; vstring[i]; i++)
        vstring[i] = (unsigned char)toupper(vstring[i]);

    /* Parse path, name, extension from vstring */
    /* Last '/' separates path from filename */
    slash = strrchr((char*)vstring, '/');
    if (slash)
    {
        /* path = everything up to (and including) slash */
        i = (unsigned char)(slash - (char*)vstring);
        if (i == 0) { vpath[0] = '/'; vpath[1] = '\0'; }
        else
        {
            if (i > 19) i = 19;
            strncpy(vpath, (char*)vstring, i);
            vpath[i] = '\0';
        }
        slash++;
    }
    else
    {
        vpath[0] = '/'; vpath[1] = '\0';
        slash = (char*)vstring;
    }

    /* extension after last '.' */
    dot = strrchr(slash, '.');
    if (dot)
    {
        for (i = 0; i < 3 && dot[1 + i]; i++)
            vext[i] = dot[1 + i];
        vext[i] = '\0';
        namelen = (unsigned char)(dot - slash);
    }
    else
    {
        vext[0] = '\0';
        namelen = (unsigned char)strlen(slash);
    }
    if (namelen > 8) namelen = 8;
    strncpy(vname, slash, namelen);
    vname[namelen] = '\0';

    /* Write to slot */
    strncpy(deskIcons[slot].filename, vname, 8);
    deskIcons[slot].filename[8] = '\0';
    strncpy(deskIcons[slot].ext, vext, 3);
    deskIcons[slot].ext[3] = '\0';
    strncpy(deskIcons[slot].path, vpath, 19);
    deskIcons[slot].path[19] = '\0';
    deskIcons[slot].askParam = 0;
    deskIcons[slot].active = 1;

    deskSaveConfig();
    deskDrawIcon(slot);
}

//-----------------------------------------------------------------------------
// Delete the icon at 'slot' (with confirmation), save config, redraw.
//-----------------------------------------------------------------------------
static void deskDeleteIcon(unsigned char slot)
{
    unsigned char mpos;
    char mbuf[40];

    if (!deskIcons[slot].active) return;

    strcpy(mbuf, "Remove icon\n");
    strcat(mbuf, deskIcons[slot].filename);
    if (deskIcons[slot].ext[0])
    {
        strcat(mbuf, ".");
        strcat(mbuf, deskIcons[slot].ext);
    }
    strcat(mbuf, " ?");

    mpos = message((char*)mbuf, BTYES | BTNO, 0);
    if (mpos != BTYES) return;

    memset(&deskIcons[slot], 0, sizeof(DESK_ICON));
    if (deskSelected == slot) deskSelected = 0xFF;

    deskSaveConfig();
    deskDrawIcon(slot);
}

//-----------------------------------------------------------------------------
// Right-click context menu for the desktop.
// If 'slot' is valid (0..DESK_ICON_MAX-1) and active, shows Add/Delete.
// If 'slot' is empty, shows only Add.
//-----------------------------------------------------------------------------
static void deskContextMenu(unsigned char slot)
{
    MGUI_SAVESCR vsavescr;
    unsigned short mx_m, my_m;
    unsigned char vopc = 0xFF;
    unsigned char showDel;

    /* Position menu near click */
    mx_m = (vpostx + 60 > 256) ? (unsigned short)(vpostx - 60) : vpostx;
    my_m = (vposty + 30 > 189) ? (unsigned char)(vposty - 30) : vposty;

    showDel = (slot < DESK_ICON_MAX && deskIcons[slot].active) ? 1 : 0;

    SaveScreenNew(&vsavescr, (unsigned short)mx_m, my_m, 60, showDel ? 26 : 14);

    FillRect((unsigned char)mx_m, (unsigned char)my_m, 60, showDel ? 24 : 12, vcorwb);
    DrawRect((unsigned short)mx_m, my_m, 60, showDel ? 24 : 12, vcorwf);

    writesxy(mx_m + 4, my_m + 2, 1, (unsigned char*)"Add Icon", vcorwf, vcorwb);
    if (showDel)
        writesxy(mx_m + 4, my_m + 12, 1, (unsigned char*)"Delete Icon", vcorwf, vcorwb);

    while (1)
    {
        MGUI_MOUSE md;
        getMouseData(0, &md);

        if (md.mouseButton == 0x01) /* left click inside menu */
        {
            if (md.vpostx >= mx_m && md.vpostx <= mx_m + 59)
            {
                if (md.vposty >= my_m + 2 && md.vposty <= my_m + 10)
                    { vopc = 0; break; }
                if (showDel && md.vposty >= my_m + 12 && md.vposty <= my_m + 21)
                    { vopc = 1; break; }
            }
            break; /* click outside = dismiss */
        }
    }

    RestoreScreen(&vsavescr);

    if (vopc == 0)
        deskAddIconDialog();
    else if (vopc == 1)
        deskDeleteIcon(slot);
}

//-----------------------------------------------------------------------------
void restoreMGUI(void)
{
    vdp_init(VDP_MODE_G2, vcorwb2, 0, 0);
    vdp_set_bdcolor(vcorwb2);

    TrocaSpriteMouse(MOUSE_POINTER);
    spthdlmouse = vdp_sprite_init(0, 0, VDP_DARK_RED);
    statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);

    vIndicaDialog = 0;

    if (!setFontUseG2(mguiFontUseAll) )   // Seta fonte 0 = 5x8 
        setFontUseG2(99);    // Fonte default 6x8, caso nao tenha conseguido carregar a fonte 0
}

//-----------------------------------------------------------------------------
void redrawScreen(void)
{
    char tmp[32];

    memset(tmp, 0x00, sizeof(tmp));
    if (mguiCfgGetBuf(memPosConfig, "START", "COLOR_F", tmp, sizeof(tmp)))
        vcorwf = atoi(tmp);
    memset(tmp, 0x00, sizeof(tmp));
    if (mguiCfgGetBuf(memPosConfig, "START", "COLOR_B", tmp, sizeof(tmp)))
        vcorwb = atoi(tmp);
    memset(tmp, 0x00, sizeof(tmp));
    if (mguiCfgGetBuf(memPosConfig, "START", "COLOR_B2", tmp, sizeof(tmp)))
        vcorwb2 = atoi(tmp);

    vdp_init(VDP_MODE_G2, vcorwb2, 0, 0);
    vdp_set_bdcolor(vcorwb2);

    if (!setFontUseG2(mguiFontUseAll) )   // Seta fonte 0 = 5x8 
        setFontUseG2(99);    // Fonte default 6x8, caso nao tenha conseguido carregar a fonte 0

    mouseX = 128;
    mouseY = 96;
    redrawMain();

    TrocaSpriteMouse(MOUSE_POINTER);
    spthdlmouse = vdp_sprite_init(0, 0, VDP_DARK_RED);
    statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);
    
    vIndicaDialog = 0;

    mouseBtnPresDouble = 0; 
}

//-----------------------------------------------------------------------------
void startMGI(void) {
    unsigned char vnomefile[13], vnomeall[32];
    unsigned char lc, ll, *ptr_ico, *ptr_prg, *ptr_pos;
    unsigned char* vLoadImage = 0x00;
    unsigned long cfgSize;
    int percent, ixx, iyy, iz;
    long ix, isizelastfont;
    char errorMalloc;
    VDP_COLOR cores;
    VDP_COORD cursor;
    int iy;
    char tmp[32];
    char bufOut[128];
    FILES_DIR *pDir;

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
    vcorwb2 = VDP_BLACK;

    vdp_init(VDP_MODE_G2, VDP_BLACK, 0, 0);
    vdp_set_bdcolor(VDP_BLACK);
    vdp_mode = VDP_MODE_G2;

    fgcolorMgui = VDP_WHITE; // cores.fg;
    bgcolorMgui = VDP_BLACK; // cores.bg;
    
    errorMalloc = 0;

    setFontUseG2(99);    // Fonte default 6x8 = 99

    vdp_get_cfg(&mgui_pattern_table, &mgui_color_table);
    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #ifdef USE_MALLOC
            vLoadImage = malloc(SIZE_LOAD_IMAGE_MEM);
        #else
            vLoadImage = msmalloc(SIZE_LOAD_IMAGE_MEM);
        #endif
    #else
        vLoadImage = (unsigned char*)ADDR_LOAD_FILE;   // Endereco fixo para carregar a imagem, nao vem de malloc. 
    #endif
    if (vLoadImage)
    {
        loadFile("/MGUI/IMAGES/UTILITY.PBM", (unsigned long*)vLoadImage);
        putImagePbmP4((unsigned long*)vLoadImage, 8, 1);
            
        #ifdef USE_MALLOC
            free(vLoadImage);
        #else
            msfree(vLoadImage);
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

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #ifdef USE_MALLOC
            memPosConfig = malloc(SIZE_LOAD_CFG_MEM);
        #else
            memPosConfig = msmalloc(SIZE_LOAD_CFG_MEM);
        #endif
    #endif

    if (memPosConfig)
    {
        cfgSize = loadFile("/MGUI/MGUI.CFG", (unsigned short*)memPosConfig);
        if (cfgSize > SIZE_LOAD_CFG_MEM)
            cfgSize = SIZE_LOAD_CFG_MEM;
        memPosConfig[cfgSize] = 0x00;
    }
    else
    {
        errorMalloc = 1;
        memPosConfig = 0;
    }

    /* Load MGUIDESK.CFG (desktop icon layout) */
    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #ifdef USE_MALLOC
            memDeskCfg = malloc(DESK_CFG_SIZE + 1);
        #else
            memDeskCfg = msmalloc(DESK_CFG_SIZE + 1);
        #endif
    #else
        memDeskCfg = msmalloc(DESK_CFG_SIZE + 1);
    #endif

    if (memDeskCfg)
    {
        unsigned long deskSz = loadFile(DESK_CFG_FILE, (unsigned short*)memDeskCfg);
        if (deskSz > DESK_CFG_SIZE) deskSz = DESK_CFG_SIZE;
        memDeskCfg[deskSz] = '\0';
        deskLoadConfig();
    }
    deskSelected = 0xFF;

    writesxy(53,170,1,"Loading Icons ",vcorwf,vcorwb);

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #ifdef USE_MALLOC
            imgsMenuSys = malloc(SIZE_LOAD_ICONS_MEM);
        #else
            imgsMenuSys = msmalloc(SIZE_LOAD_ICONS_MEM);
        #endif
    #else
        imgsMenuSys = (unsigned char*)ADDR_LOAD_ICONS;   // Endereco fixo para carregar as imagens, nao vem de malloc.
    #endif

    if (imgsMenuSys)
    {
        writesxy(137,170,1,"ICOFOLD.PBM",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOFOLD.PBM", imgsMenuSys);
        writesxy(137,170,1,"ICORUN.PBM ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICORUN.PBM", (imgsMenuSys + 64));
        writesxy(137,170,1,"ICOOFF.PBM ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOOFF.PBM", (imgsMenuSys + 128));
        writesxy(137,170,1,"ICOOS.PBM  ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOOS.PBM", (imgsMenuSys + 192));
        writesxy(137,170,1,"ICOSET.PBM ",vcorwf,vcorwb);
        loadFile("/MGUI/IMAGES/ICOSET.PBM", (imgsMenuSys + 256));
    }
    else
    {
        errorMalloc = 1;
        imgsMenuSys = 0;
    }

    writesxy(53,170,1,"Loading Font's ",vcorwf,vcorwb);
    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #ifdef USE_MALLOC
            memVideoFonts = malloc(SIZE_LOAD_FONTS_MEM);
            memLoadFileFont = malloc(SIZE_LOAD_FILE_FONT_MEM);
        #else
            memVideoFonts = msmalloc(SIZE_LOAD_FONTS_MEM);
            memLoadFileFont = msmalloc(SIZE_LOAD_FILE_FONT_MEM);
        #endif
    #else
        memVideoFonts = (unsigned char*)ADDR_LOAD_FONTS;   // Endereco fixo para carregar as fontes, nao vem de malloc.
        memLoadFileFont = (unsigned char*)ADDR_LOAD_FILE_FONT;   // Endereco fixo para carregar as fontes, nao vem de malloc.
    #endif

    if (memVideoFonts && memLoadFileFont)
    {
        // Ler todas as fontes da pasta (ateh 4)
        pDir = (FILES_DIR*)msmalloc(sizeof(FILES_DIR) * 128);
        fsListDir(pDir, "/MGUI/FONTS/*.FON");
        ixx = 0;
        isizelastfont = 0;

        for (iyy=0; iyy < 4; iyy++)
            listFontsUseG2[iyy].name[0] = 0x00;

        iyy = 0;

        memset(tmp, 0x00, sizeof(tmp));
        mguiCfgGetBuf(memPosConfig, "START", "FONT", tmp, sizeof(tmp));

        // Loop de carregamento das fontes, lendo o nome do arquivo para mostrar na tela e depois carregar a fonte usando o nome completo (com caminho) para carregar a fonte na memoria. O loop para quando encontra
        while (pDir[ixx].Name[0] != 0)
        {
            strcpy(vnomefile, pDir[ixx].Name);
            strcat(vnomefile, ".");
            strcat(vnomefile, pDir[ixx].Ext);
            writesxy(140,170,1,vnomefile,vcorwf,vcorwb);
            strcpy(vnomeall, "/MGUI/FONTS/");
            strcat(vnomeall, vnomefile);

            ixx++;

            if (loadFontUseG2(iyy, vnomeall, memLoadFileFont, memVideoFonts))
                continue;

            if (tmp[0] != 0x00 && !strcmp(pDir[ixx - 1].Name,tmp))
                mguiFontUseAll = iyy;

            iyy++;

            if (iyy >= 4) // Limite de 4 fontes
                break;
        }

        msfree(pDir);
        msfree(memLoadFileFont);
    }
    else
    {
        errorMalloc = 1;
        memVideoFonts = 0;
        memLoadFileFont = 0;
    }

    writesxy(53,170,1,"      Please Wait...       ",vcorwf,vcorwb);

    if (!errorMalloc)
    {
        redrawScreen();        

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

        // Inicializa o MFP e configura o pino SQW para 1Hz
        if (rtc_init_with_sqw() == 0) 
        {
            *(vmfp + Reg_IMRB) &= (unsigned char)~MFP_GPIO2;
            *(vmfp + Reg_IERB) &= (unsigned char)~MFP_GPIO2;

            hookTable[HOOK_GPIO2].addr   = &mguiClockHook1Hz;
            hookTable[HOOK_GPIO2].flags  = HOOKF_ACTIVE | HOOKF_SKIP_OS;
            hookTable[HOOK_GPIO2].magic  = HOOK_MAGIC;

            *(vmfp + Reg_IERB) |= MFP_GPIO2;
            *(vmfp + Reg_IMRB) |= MFP_GPIO2;
        }

        // Inicia Controles de Tela (Mouse e Teclado)
        while(1)
        {
            mouseFunc(NULL);

            if (!editortela())
                break;
        }

        *(vmfp + Reg_IMRB) &= (unsigned char)~MFP_GPIO2;
        *(vmfp + Reg_IERB) &= (unsigned char)~MFP_GPIO2;

        hookTable[HOOK_GPIO2].magic  = 0x00;
        hookTable[HOOK_GPIO2].addr   = 0x00;
        hookTable[HOOK_GPIO2].flags  = 0x00;

        #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
            #ifdef USE_MALLOC
                free(imgsMenuSys);
                free(memVideoFonts);
            #else
                msfree(imgsMenuSys);
                msfree(memVideoFonts);
            #endif
            imgsMenuSys = 0;
            memVideoFonts = 0;
        #endif
        if (memDeskCfg)
        {
            #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
                #ifdef USE_MALLOC
                    free(memDeskCfg);
                #else
                    msfree(memDeskCfg);
                #endif
            #else
                msfree(memDeskCfg);
            #endif
            memDeskCfg = 0;
        }
    }

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        if (imgsMenuSys)
        {
            #ifdef USE_MALLOC
                free(imgsMenuSys);
            #else
                msfree(imgsMenuSys);
            #endif
            imgsMenuSys = 0;
        }

        if (memVideoFonts)
        {
            #ifdef USE_MALLOC
                free(memVideoFonts);
            #else
                msfree(memVideoFonts);
            #endif
            memVideoFonts = 0;
        }

        if (memPosConfig)
        {
            #ifdef USE_MALLOC
                free(memPosConfig);
            #else
                msfree(memPosConfig);
            #endif
            memPosConfig = 0;
        }
    #endif

    if (memDeskCfg)
    {
        #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
            #ifdef USE_MALLOC
                free(memDeskCfg);
            #else
                msfree(memDeskCfg);
            #endif
        #else
            msfree(memDeskCfg);
        #endif
        memDeskCfg = 0;
    }

    vdp_init(VDP_MODE_TEXT, VDP_BLACK, 0, 0);
    vdp_textcolor(VDP_WHITE, VDP_BLACK);
    vdp_mode = VDP_MODE_TEXT;

    clearScr();

    if (errorMalloc)
        printText("Error allocating memory. Process aborted.\r\n\0");

    printText("\r\n\0");

    showCursor();

    *startBasic = 1;    // Inicia Basic vindo do MMSJOS com mensagens e textos
}

//-------------------------------------------------------------------------
void mouseFunc (void *pData)
{
    unsigned char valter;

    if (readMouse(&mouseStat, &mouseMoveX, &mouseMoveY))
    {
        VerifyMouse();

        if (mouseBtnPres == 0x01 && timeToDoubleClick == 0xFFFF)
        {
            mouseBtnPresDouble = 0;
            timeToDoubleClick = 0;
        }

        if (mouseBtnPres == 0x01 && timeToDoubleClick > 0 && timeToDoubleClick <= 5000)
        {
            mouseBtnPresDouble = 1;
        }
    }

    if (mouseBtnPres == 0x00 && timeToDoubleClick != 0xFFFF)
        timeToDoubleClick = timeToDoubleClick + 1;

    if (timeToDoubleClick > 5000 && timeToDoubleClick != 0xFFFF)
    {
        timeToDoubleClick = 0xFFFF;
        mouseBtnPresDouble = 0;
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

    mguiClockReadRtc(1);

    clearScrW(bgcolorMgui);

    // Desenhar Barra Menu Principal / Status
    desenhaMenu();

    // Desenhar icones do desktop
    deskDrawAll();

    TrocaSpriteMouse(MOUSE_POINTER);
}

//-----------------------------------------------------------------------------
static void mguiClockPut2(unsigned char *dst, int val)
{
    unsigned char tens;

    tens = 0;
    while (val >= 10)
    {
        val -= 10;
        tens++;
    }

    dst[0] = (unsigned char)('0' + tens);
    dst[1] = (unsigned char)('0' + val);
}

//-----------------------------------------------------------------------------
static void mguiClockDraw(void)
{
    unsigned int vx, vy;

    vx = COLMENU + 48;
    vy = LINMENU;

    FillRect(vx, vy, 20, 16, vcorwf);
    vx += 24;
    writesxy(vx, vy, 5, vDateAtuAux, vcorwf, vcorwb2);
    writesxy(vx, vy + 8, 5, vTimeAtuAux, vcorwf, vcorwb2);
    FillRect(vx + 54, vy, 10, 16, vcorwf);

    mguiClockDirty = 0;
}

//-----------------------------------------------------------------------------
static void mguiClockReadRtc(unsigned char force)
{
    DateTimeData system_clock;

    if (rtc_read_datetime(&system_clock) != 0)
        return;

    if (!force && system_clock.minutes == mguiClockLastMinute)
        return;

    mguiClockLastMinute = system_clock.minutes;

    mguiClockPut2(&vDateAtuAux[0], system_clock.month);
    vDateAtuAux[2] = '/';
    mguiClockPut2(&vDateAtuAux[3], system_clock.day);
    vDateAtuAux[5] = '/';
    vDateAtuAux[6] = '2';
    vDateAtuAux[7] = '0';
    mguiClockPut2(&vDateAtuAux[8], system_clock.year);
    vDateAtuAux[10] = 0x00;

    mguiClockPut2(&vTimeAtuAux[0], system_clock.hours);
    vTimeAtuAux[2] = ':';
    mguiClockPut2(&vTimeAtuAux[3], system_clock.minutes);
    vTimeAtuAux[5] = 0x00;

    mguiClockDirty = 1;
}

//-----------------------------------------------------------------------------
void mguiClockHook1Hz(void)
{
    if (mguiClockTicks < 60)
        mguiClockTicks++;
}

//-----------------------------------------------------------------------------
void mguiClockRefresh(void)
{
    if (!mguiListWindows[6].active)
        return;

    if (vIndicaDialog)
        return;

    if (*mguiRunTask)
        return;

    if (mguiClockTicks >= 60)
    {
        mguiClockTicks = 0;
        mguiClockReadRtc(0);
    }

    if (mguiClockDirty)
    {
        mguiClockDirty = 0;
        mguiClockDraw();
    }
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

    // Icone de menu e run
    for (lc = 0; lc <= 1; lc++)
    {
        idx = lc * 64;
        putImagePbmP4((imgsMenuSys + idx), vx, vy);
        vx += 24;

        /*MostraIcone(vx, vy, lc,vcorwf, vcorwb);
        vx += 16;*/
    }

    // Data e Hora
    mguiClockDraw();

    // Nome e Versao
    writesxy(150 , vy, 5, "MMC-320   MGUI", vcorwf, vcorwb2);
    writesxy(170 , vy + 8, 5, versionMgui, vcorwf, vcorwb2);

    // Icone de Sair
    FillRect(226,vy,10,16,vcorwf);
    lc = 2;
    idx = lc * 64;
    vx = 240;
    putImagePbmP4((imgsMenuSys + idx), vx, vy);

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

    mguiClockRefresh();

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
/*    if (*mguiRunTask)
        runFromMGUI(*mguiRunTask);*/

    // Verifica mouse e teclado
    if (mguiListWindows[6].active)  // Mgui ativo
    {
        *mguiIdRequest = 6;

        key = KEY_NONE;
        
        if (mmsjKeyGet(&k))
        {
            if (k.flags == KEY_CTRL_ALT && k.code == 'X')  // CTRL+ALT+X
                vresp = 0x00;
        }

        if (mouseBtnPres == 0x01)  // Esquerdo
        {
            if (vposty <= 22)
                vresp = new_menu();
            else
            {
                /* Desktop area */
                unsigned char hit = deskHitTest(vpostx, (unsigned char)vposty);

                if (mouseBtnPresDouble)
                {
                    /* Double-click: open icon */
                    if (hit < DESK_ICON_MAX && deskIcons[hit].active)
                        deskOpenIcon(hit);
                }
                else
                {
                    // Single-click: select icon
                /*    unsigned char prev = deskSelected;
                    deskSelected = (hit < DESK_ICON_MAX) ? hit : 0xFF;
                    if (prev != deskSelected)
                    {
                        if (prev < DESK_ICON_MAX) deskDrawIcon(prev);
                        if (deskSelected < DESK_ICON_MAX) deskDrawIcon(deskSelected);
                    }*/
                }
            }
        }
        else if (mouseBtnPres == 0x02)  // Direito
        {
            if (vposty > 22)
            {
                unsigned char hit = deskHitTest(vpostx, (unsigned char)vposty);
                deskContextMenu(hit);
            }
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

    ix = 6;
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

    if (ptipo == 0x01)  // Apenas Teclado
    {
        key = KEY_NONE;
        
        if (mmsjKeyGet(&k))
        {
            key = k.raw;
        }

        mguiListWindows[*mguiIdRequest].keyTec = key;
    }
    else if (ptipo == 0x00)
    {
        mouseFunc(NULL);

        pmouseData->mouseButton = mouseBtnPres;
        pmouseData->mouseBtnDouble = mouseBtnPresDouble;
        pmouseData->vpostx = vpostx;
        pmouseData->vposty = vposty;
        pmouseData->mouseX = mouseX;
        pmouseData->mouseY = mouseY;
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
        vbuttonmess[14] = 0;
        vbuttonmess[15] = vbty;

        TrocaSpriteMouse(MOUSE_POINTER);

        vIndicaDialog = 1;

        messageFunc((void *)&vbuttonmess);  // Executa a task de mensagem diretamente, sem criar uma nova task, para evitar overhead de criar task e suspender a task chamadora. A task de mensagem vai rodar no contexto da task chamadora, e quando terminar, vai retornar para a task chamadora.

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
void messageFunc(void *pData)
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
        mouseFunc(NULL);        
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
    }

    vbutton[0] = ii;

    vIndicaDialog = 0;
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
    spthdlmouse = vdp_sprite_init(0, 0, VDP_DARK_RED);
    statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);
}

//-------------------------------------------------------------------------
unsigned char new_menu(void)
{
    unsigned short lc;
    unsigned char vresp, mpos, mtqresp;

    vresp = 1;

    if (vpostx >= COLMENU && vpostx <= (COLMENU + 16))
    {
        menuFunc(NULL);
    }
    else if (vpostx >= 238 && vpostx <= 255)
    {
        mpos = message("Do you want to exit ?\0", BTYES | BTNO, 0);
        if (mpos == BTYES)
            vresp = 0;
    }
    else 
    {
        for (lc = 1; lc <= 1; lc++) 
        {
            mx = COLMENU + (24 * lc);
            if (vpostx >= mx && vpostx <= (mx + 16)) 
            {
/*                InvertRect( mx, 4, 8, 8);
                InvertRect( mx, 4, 8, 8);*/
                break;
            }
        }

        switch (lc) {
            case 1: // RUN
                runBin();
                break;
            /*case 2: // EXIT
                mpos = message("Do you want to exit ?\0", BTYES | BTNO, 0);
                if (mpos == BTYES)
                    vresp = 0;
                break;
            case 3: // MMSJOS
                break;
            case 4: // SETUP
                configMgui();
                break;*/
        }
    }

    return vresp;
}

//-----------------------------------------------------------------------------
void menuFunc(void *pData)
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

    SaveScreenNew(&endSaveMenu, mx,my,128,36);

    FillRect(mx,my,128,34,vcorwb);
    DrawRect(mx,my,128,34,vcorwf);

    mpos += 2;
    menyi[0] = my + mpos;
    writesxy(mx + 8,my + mpos,1,"Import File",vcorwf,vcorwb);
    mpos += 12;
    menyf[0] = my + mpos;
    DrawLine(mx,my + mpos,mx+128,my + mpos,vcorwf);
    mpos += 2;
    menyi[1] = my + mpos;
    writesxy(mx + 8,my + mpos,1,"About",vcorwf,vcorwb);

    TrocaSpriteMouse(MOUSE_POINTER);

    while (1)
    {
        mouseFunc(NULL);
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
                    /*case 0: // Call "Files" Program from Disk
                        #ifdef USE_RELOC_LOAD_PROGS
                            TrocaSpriteMouse(MOUSE_HOURGLASS);
                            paramBasic[0] = '\0';
                            TrocaSpriteMouse(MOUSE_POINTER);
                            if (loadMbinAndRun("/MGUI/PROGS/FILES.EXE", 2) != 0)
                                message("Error Executing File\0", BTCLOSE, 0);
                        #else
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
                        #endif

                        break;*/
                    case 0: // Import File via Serial
                        importFile();
                        break;
                    case 1: // About
                        message("MGUI v"versionMgui"\nGraphical User Interface\n \nwww.utilityinf.com.br\0", BTCLOSE, 0);
                        break;
                }
            }

            break;
        }
    }

    RestoreScreen(&endSaveMenu);
}

//-----------------------------------------------------------------------------
void configMgui (void)
{
/*    unsigned short ix;
    unsigned char vwb, vresp;
    MGUI_SAVESCR vsavescr;

    vnamein[0] = '\0';
    vfilename[0] = '\0';
    vfullpath[0] = '\0';

    SaveScreenNew(&vsavescr, 10,40,240,60);
    showWindow("Config",10,40,240,50,BTOK | BTCANCEL);

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
        }
    }

    RestoreScreen(&vsavescr);

    if (vwb != BTOK)
        return;
*/
}

//-----------------------------------------------------------------------------
void askParamToExec(unsigned char *vParam)
{
    unsigned short ix;
    unsigned char vwb, vresp;
    MGUI_SAVESCR vsavescr;

    vParam[0] = '\0';

    SaveScreenNew(&vsavescr, 10,40,240,60);
    showWindow("Parameter",10,40,240,50,BTOK | BTCANCEL);

    writesxy(12,57,8,"Param:",vcorwf,vcorwb);

    {
        unsigned char wmode = WINFULL;
        while (1)
        {
            fillin(0, vParam, 78, 57, 130, wmode);
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

    RestoreScreen(&vsavescr);

    if (vwb != BTOK)
        vParam[0] = '\0';
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
    char vProgIsMgui = 1;
    char vProgIsBasic = 0;

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

    strcpy(vfullpath, vfilename);

    if (strncmp(vfullpath, "BASIC", 5) == 0)
    {
        vProgIsMgui = 0;
        vProgIsBasic = 1;
    }

    if (vfilename[0] == '/')
    {
        // Verifica se arquivo existe
        vsizefilemalloc = fsInfoFile(vfullpath, INFO_SIZE);
        if (vsizefilemalloc == ERRO_D_NOT_FOUND)
        {
            vProgIsMgui = 0;
            message("File not found...\0", BTCLOSE, 0);
            return;
        }
    }
    else if (!vProgIsBasic)
    {
        strcpy(vfullpath, "/MGUI/PROGS/");
        strcat(vfullpath, vfilename);

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

        #ifdef USE_RELOC_LOAD_PROGS
            strcat(vfilename, ".EXE");
        }
        else if (strcmp(vdot, ".EXE") != 0)
        {
            message("Only .EXE files are allowed\0", BTCLOSE, 0);
            return;
        }
        #else
            strcat(vfilename, ".BIN");
        }
        else if (strcmp(vdot, ".BIN") != 0)
        {
            message("Only .BIN files are allowed\0", BTCLOSE, 0);
            return;
        }
        #endif        

        // Verifica se arquivo existe
        vsizefilemalloc = fsInfoFile(vfullpath, INFO_SIZE);
        if (vsizefilemalloc == ERRO_D_NOT_FOUND)
        {
            vProgIsMgui = 0;
            strcpy(vfullpath, vfilename);
        }
    }

    TrocaSpriteMouse(MOUSE_HOURGLASS);
    vUseFixedAddr = 1;

    SaveScreenNew(&vsavescr, 0,0,255,191);

    if (vProgIsBasic)
    {
        /* Run BASIC with file as argument */
        fsOsCommand((unsigned char*)vfullpath);
        restoreMGUI(); // in case BASIC redraw mgui (basic exit in text mode)
    }
    else if (vProgIsMgui)
    {
        /* execProg is a full path to an EXE/BIN that should open this file */
        #ifdef USE_RELOC_LOAD_PROGS
            if (loadMbinAndRun(vfullpath, 2) != 0)
            {
                TrocaSpriteMouse(MOUSE_POINTER);
                message("Error Executing File\0", BTCLOSE, 0);
            }
            mguiClockDirty = 1;
        #else
            vsizefile = loadFile((unsigned char*)execProg,
                                 (unsigned short*)ADDR_EXEC_PROG);
            if (vsizefile > 0 && vsizefile < ERRO_D_START)
                runFromMGUI((unsigned long)ADDR_EXEC_PROG);
            else
                message("Loading Error...\0", BTCLOSE, 0);
        #endif
    }
    else    // se nao eh nenhum dos 2, vai tentar encontrar no MMSJOS 
    {
        /* Run OS Command with argument */
        fsOsCommand((unsigned char*)vfullpath);
        restoreMGUI(); // in case OS Command, redraw mgui (MMSJOS exit in text mode)
    }

    RestoreScreen(&vsavescr);

    return;
}

//-----------------------------------------------------------------------------
void importFile(void)
{
    unsigned long vStep, ix;
    unsigned char *xaddress = 0x00840000;
    unsigned char *xaddressStart = 0;
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

                #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
                    #ifdef USE_MALLOC
                        xaddress = malloc(128UL * 1024UL); // Aloca 128KB para receber o arquivo via serial
                    #else
                        xaddress = msmalloc(128UL * 1024UL); // Aloca 128KB para receber o arquivo via serial
                    #endif
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
                        xaddress = xaddressStart;
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

                #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
                    if (xaddressStart)
                    {
                        #ifdef USE_MALLOC
                            free(xaddressStart); 
                        #else
                            msfree(xaddressStart);
                        #endif
                        xaddressStart = 0;
                    }
                #endif
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

//-----------------------------------------------------------------------------
static unsigned char mguiToUpper(unsigned char c)
{
    if (c >= 'a' && c <= 'z')
        return (unsigned char)(c - ('a' - 'A'));

    return c;
}

#ifndef __EM_OBRAS__
#endif
