; D:\PROJETOS\MMSJ320\MGUI.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; /********************************************************************************
; *    Programa    : mgui.c
; *    Objetivo    : MMSJ300 Graphical User Interface
; *    Criado em   : 25/07/2023
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 25/07/2023  0.1     Moacir Jr.   Criacao Versao Beta
; *    ...       ...       ...            ...
; * 03/01/2025  0.5a    Moacir Jr.   Troca de cores e ajustes de tela
; * 19/01/2025  0.6     Moacir Jr.   Adaptar para rodar junto com o MMSJOS
; * 13/04/2026  0.7a02  Moacir Jr.   Ajustes para o mouse e o sprite do ponteiro
; *--------------------------------------------------------------------------------
; *
; *--------------------------------------------------------------------------------
; * To do
; *
; *--------------------------------------------------------------------------------
; *
; *********************************************************************************/
; #include <ucos_ii.h>
; #include <ctype.h>
; #include <string.h>
; #include <malloc.h>
; #include <stdlib.h>
; #include "mmsj320vdp.h"
; #include "mmsj320mfp.h"
; #include "mmsjos.h"
; #include "monitor.h"
; #include "monitorapi.h"
; #include "mgui.h"
; #define versionMgui "0.7a02"
; #define __EM_OBRAS__ 1
; unsigned char *vvdgd = 0x00400041; // VDP TMS9118 Data Mode
; unsigned char *vvdgc = 0x00400043; // VDP TMS9118 Registers/Address Mode
; unsigned char memPosConfig; // Config file
; unsigned char *imgsMenuSys = 0x00; // Images PBM 16x16 each icone in order (64 Bytes Each)
; unsigned char vFinalOS; // Atualizar sempre que a compilacao passar desse valor
; unsigned char vcorwf; //
; unsigned char vcorwb; //
; unsigned char vcorwb2; //
; unsigned long mousePointer;
; unsigned int spthdlmouse;
; unsigned int mouseX;
; unsigned char mouseY;
; unsigned char mouseStat;
; char mouseMoveX;
; char mouseMoveY;
; unsigned char mouseBtnPres;
; unsigned char mouseBtnPresDouble;
; unsigned char statusVdpSprite;
; unsigned long mouseHourGlass;
; unsigned long iconesMenuSys;
; unsigned char vbbutton;
; unsigned short vpostx;
; unsigned short vposty;
; unsigned short pposx;
; unsigned short pposy;
; unsigned short vxgmax;
; unsigned char vbuttonwin[32];
; unsigned short vbuttonwiny;
; unsigned int mgui_pattern_table;
; unsigned int mgui_color_table;
; unsigned long mguiVideoFontes;
; unsigned char fgcolorMgui;
; unsigned char bgcolorMgui;
; unsigned short mx, my, menyi[8], menyf[8];
; MGUI_SAVESCR endSaveMenu;
; unsigned char vIndicaDialog = 0;
; extern HEADER *_allocp;
; #define STACKSIZE  1024
; #define STACKSIZEMGUI  2048
; #define STACKSIZEMOUSE  2048
; #define STACKSIZEMENU  1024
; extern OS_STK StkInput[STACKSIZE];
; OS_STK StkFiles[STACKSIZEMGUI];
; OS_STK StkMouse[STACKSIZEMOUSE];
; OS_STK StkMenu[STACKSIZEMENU];
; OS_STK StkMessage[STACKSIZE];   // Dialog, só pode ter uma por vez
; extern OS_EVENT *shared_sem;
; void mouseTask (void *pData);
; void menuTask (void *pData);
; void messageTask (void *pData);
; void runBin(void);
; //-----------------------------------------------------------------------------
; void clearScrW(unsigned char color)
; {
       section   code
       xdef      _clearScrW
_clearScrW:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; unsigned int ix, iy;
; color &= 0x0F;
       and.b     #15,11(A6)
; setWriteAddress(mgui_pattern_table);
       move.l    _mgui_pattern_table.L,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; for (iy = 0; iy < 192; iy++)
       clr.l     D3
clearScrW_1:
       cmp.l     #192,D3
       bhs.s     clearScrW_3
; {
; for (ix = 0; ix < 32; ix++)
       clr.l     D2
clearScrW_4:
       cmp.l     #32,D2
       bhs.s     clearScrW_6
; *vvdgd = 0x00;
       move.l    _vvdgd.L,A0
       clr.b     (A0)
       addq.l    #1,D2
       bra       clearScrW_4
clearScrW_6:
       addq.l    #1,D3
       bra       clearScrW_1
clearScrW_3:
; }
; setWriteAddress(mgui_color_table);
       move.l    _mgui_color_table.L,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; for (iy = 0; iy < 192; iy++)
       clr.l     D3
clearScrW_7:
       cmp.l     #192,D3
       bhs.s     clearScrW_9
; {
; for (ix = 0; ix < 32; ix++)
       clr.l     D2
clearScrW_10:
       cmp.l     #32,D2
       bhs.s     clearScrW_12
; *vvdgd = color;
       move.l    _vvdgd.L,A0
       move.b    11(A6),(A0)
       addq.l    #1,D2
       bra       clearScrW_10
clearScrW_12:
       addq.l    #1,D3
       bra       clearScrW_7
clearScrW_9:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // VDP Functions
; //-----------------------------------------------------------------------------
; void vdp_set_cursor_pos_gui(unsigned char direction)
; {
       xdef      _vdp_set_cursor_pos_gui
_vdp_set_cursor_pos_gui:
       link      A6,#-4
       movem.l   D2/D3/A2,-(A7)
       lea       -4(A6),A2
; unsigned char pMoveIdX = 6, pMoveIdY = 8;
       moveq     #6,D3
       moveq     #8,D2
; VDP_COORD vcursor;
; vcursor = vdp_get_cursor();
       move.l    A2,A0
       move.l    A0,-(A7)
       move.l    1170,A1
       jsr       (A1)
       move.l    (A7)+,A0
       move.l    D0,A1
       move.l    (A1)+,(A0)+
; switch (direction)
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #4,D0
       bhs       vdp_set_cursor_pos_gui_2
       asl.l     #1,D0
       move.w    vdp_set_cursor_pos_gui_3(PC,D0.L),D0
       jmp       vdp_set_cursor_pos_gui_3(PC,D0.W)
vdp_set_cursor_pos_gui_3:
       dc.w      vdp_set_cursor_pos_gui_4-vdp_set_cursor_pos_gui_3
       dc.w      vdp_set_cursor_pos_gui_5-vdp_set_cursor_pos_gui_3
       dc.w      vdp_set_cursor_pos_gui_6-vdp_set_cursor_pos_gui_3
       dc.w      vdp_set_cursor_pos_gui_7-vdp_set_cursor_pos_gui_3
vdp_set_cursor_pos_gui_4:
; {
; case VDP_CSR_UP:
; vdp_set_cursor(vcursor.x, vcursor.y - pMoveIdY);
       move.l    A2,D1
       move.l    D1,A0
       move.b    1(A0),D1
       sub.b     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; break;
       bra       vdp_set_cursor_pos_gui_2
vdp_set_cursor_pos_gui_5:
; case VDP_CSR_DOWN:
; vdp_set_cursor(vcursor.x, vcursor.y + pMoveIdY);
       move.l    A2,D1
       move.l    D1,A0
       move.b    1(A0),D1
       add.b     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; break;
       bra       vdp_set_cursor_pos_gui_2
vdp_set_cursor_pos_gui_6:
; case VDP_CSR_LEFT:
; vdp_set_cursor(vcursor.x - pMoveIdX, vcursor.y);
       move.l    A2,D1
       move.l    D1,A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.b    (A0),D1
       sub.b     D3,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; break;
       bra.s     vdp_set_cursor_pos_gui_2
vdp_set_cursor_pos_gui_7:
; case VDP_CSR_RIGHT:
; vdp_set_cursor(vcursor.x + pMoveIdX, vcursor.y);
       move.l    A2,D1
       move.l    D1,A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.b    (A0),D1
       add.b     D3,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; break;
vdp_set_cursor_pos_gui_2:
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void vdp_write_gui(unsigned char chr)
; {
       xdef      _vdp_write_gui
_vdp_write_gui:
       link      A6,#-40
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -4(A6),A2
       lea       _vvdgd.L,A3
; unsigned int name_offset; // Position in name table
; unsigned int pattern_offset;                    // Offset of pattern in pattern table
; unsigned short i, ix, iy, xf;
; unsigned short vAntX, vAntY;
; unsigned char *tempFontes = mguiVideoFontes;
       move.l    _mguiVideoFontes.L,-24(A6)
; unsigned long vEndFont, vEndPart;
; unsigned short posX, posY, modX, modY, offset, offsetmodX, posmodX;
; unsigned char lineChar, pixel, color;
; VDP_COORD cursor;
; cursor = vdp_get_cursor();
       move.l    A2,A0
       move.l    A0,-(A7)
       move.l    1170,A1
       jsr       (A1)
       move.l    (A7)+,A0
       move.l    D0,A1
       move.l    (A1)+,(A0)+
; name_offset = cursor.y * (cursor.maxx + 1) + cursor.x; // Position in name table
       move.l    A2,D0
       move.l    D0,A0
       move.b    1(A0),D0
       and.w     #255,D0
       move.l    A2,D1
       move.l    D1,A0
       move.b    2(A0),D1
       addq.b    #1,D1
       and.w     #255,D1
       mulu.w    D1,D0
       and.l     #65535,D0
       move.l    A2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       add.l     D1,D0
       move.l    D0,-40(A6)
; pattern_offset = name_offset << 3;
       move.l    -40(A6),D0
       lsl.l     #3,D0
       move.l    D0,-36(A6)
; vEndPart = chr - 32;
       move.b    11(A6),D0
       and.l     #255,D0
       sub.l     #32,D0
       move.l    D0,-16(A6)
; vEndPart = vEndPart << 3;
       move.l    -16(A6),D0
       lsl.l     #3,D0
       move.l    D0,-16(A6)
; vAntY = cursor.y;
       move.l    A2,D0
       move.l    D0,A0
       move.b    1(A0),D0
       and.w     #255,D0
       move.w    D0,-26(A6)
; for (i = 0; i < 8; i++)
       move.w    #0,A5
vdp_write_gui_1:
       move.w    A5,D0
       cmp.w     #8,D0
       bhs       vdp_write_gui_3
; {
; vEndFont = mguiVideoFontes;
       move.l    _mguiVideoFontes.L,-20(A6)
; vEndFont += vEndPart + i;
       move.l    -16(A6),D0
       add.l     A5,D0
       add.l     D0,-20(A6)
; tempFontes = vEndFont;
       move.l    -20(A6),-24(A6)
; lineChar = *tempFontes;
       move.l    -24(A6),A0
       move.b    (A0),D4
; lineChar = (lineChar & 0xFC);
       move.b    D4,D0
       and.w     #255,D0
       and.w     #252,D0
       move.b    D0,D4
; ix = cursor.x;
       move.l    A2,D0
       move.l    D0,A0
       move.b    (A0),D0
       and.w     #255,D0
       move.w    D0,D3
; iy = cursor.y;
       move.l    A2,D0
       move.l    D0,A0
       move.b    1(A0),D0
       and.w     #255,D0
       move.w    D0,-32(A6)
; xf = ix + 6;
       move.w    D3,D0
       addq.w    #6,D0
       move.w    D0,-30(A6)
; offsetmodX = 0;
       move.w    #0,A4
; while (ix < xf)
vdp_write_gui_4:
       cmp.w     -30(A6),D3
       bhs       vdp_write_gui_6
; {
; posX = (int)(8 * (ix / 8));
       move.w    D3,D0
       and.l     #65535,D0
       divu.w    #8,D0
       mulu.w    #8,D0
       and.l     #65535,D0
       move.w    D0,-12(A6)
; posY = (int)(256 * (iy / 8));
       move.w    -32(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       mulu.w    #256,D0
       and.l     #65535,D0
       move.w    D0,-10(A6)
; modX = (int)(ix % 8);
       move.w    D3,D0
       and.l     #65535,D0
       divu.w    #8,D0
       swap      D0
       and.l     #65535,D0
       move.w    D0,D6
; modY = (int)(iy % 8);
       move.w    -32(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       swap      D0
       and.l     #65535,D0
       move.w    D0,-8(A6)
; offset = posX + modY + posY;
       move.w    -12(A6),D0
       add.w     -8(A6),D0
       add.w     -10(A6),D0
       move.w    D0,D5
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       and.l     #65535,D5
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       and.l     #65535,D5
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; pixel = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),D2
; setReadAddress(mgui_color_table + offset);
       move.l    _mgui_color_table.L,D1
       and.l     #65535,D5
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_color_table + offset);
       move.l    _mgui_color_table.L,D1
       and.l     #65535,D5
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; color = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),-5(A6)
; if (modX > 2 || (modX == 0 && ix > cursor.x))   // Parcial com bits dos 6 bits no proximo Byte
       cmp.w     #2,D6
       bhi.s     vdp_write_gui_9
       tst.w     D6
       bne       vdp_write_gui_7
       move.l    A2,D0
       move.l    D0,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     D0,D3
       bls       vdp_write_gui_7
vdp_write_gui_9:
; {
; if (ix == cursor.x)  // Posicao inicial
       move.l    A2,D0
       move.l    D0,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     D0,D3
       bne       vdp_write_gui_10
; {
; posmodX = (8 - modX);
       moveq     #8,D0
       ext.w     D0
       sub.w     D6,D0
       move.w    D0,D7
; pixel = ((pixel & (0xFF << posmodX)) | (lineChar >> modX));
       move.b    D2,D0
       and.w     #255,D0
       move.w    #255,D1
       lsl.w     D7,D1
       and.w     D1,D0
       move.b    D4,D1
       and.w     #255,D1
       lsr.w     D6,D1
       or.w      D1,D0
       move.b    D0,D2
; offsetmodX = posmodX;
       move.w    D7,A4
       bra       vdp_write_gui_11
vdp_write_gui_10:
; }
; else
; {
; posmodX = (6 - offsetmodX);
       moveq     #6,D0
       ext.w     D0
       sub.w     A4,D0
       move.w    D0,D7
; pixel = ((pixel & (0xFF >> posmodX)) | (lineChar << offsetmodX));
       move.b    D2,D0
       and.w     #255,D0
       move.w    #255,D1
       lsr.w     D7,D1
       and.w     D1,D0
       move.b    D4,D1
       and.w     #255,D1
       move.l    D0,-(A7)
       move.w    A4,D0
       lsl.w     D0,D1
       move.l    (A7)+,D0
       or.w      D1,D0
       move.b    D0,D2
vdp_write_gui_11:
; }
; ix += posmodX;
       add.w     D7,D3
       bra       vdp_write_gui_8
vdp_write_gui_7:
; }
; else    // Total, com 6 bits no mesmo Byte
; {
; lineChar = lineChar >> modX;
       move.b    D4,D0
       and.w     #255,D0
       lsr.w     D6,D0
       move.b    D0,D4
; switch (modX)
       and.l     #65535,D6
       cmp.l     #1,D6
       beq.s     vdp_write_gui_15
       bhi.s     vdp_write_gui_17
       tst.l     D6
       beq.s     vdp_write_gui_14
       bra.s     vdp_write_gui_13
vdp_write_gui_17:
       cmp.l     #2,D6
       beq.s     vdp_write_gui_16
       bra.s     vdp_write_gui_13
vdp_write_gui_14:
; {
; case 0:
; pixel = pixel & 0x03;
       and.b     #3,D2
; break;
       bra.s     vdp_write_gui_13
vdp_write_gui_15:
; case 1:
; pixel = pixel & 0x81;
       move.b    D2,D0
       and.w     #255,D0
       and.w     #129,D0
       move.b    D0,D2
; break;
       bra.s     vdp_write_gui_13
vdp_write_gui_16:
; case 2:
; pixel = pixel & 0xC0;
       move.b    D2,D0
       and.w     #255,D0
       and.w     #192,D0
       move.b    D0,D2
; break;
vdp_write_gui_13:
; }
; pixel = pixel | lineChar;
       or.b      D4,D2
; ix += 6;
       addq.w    #6,D3
vdp_write_gui_8:
; }
; color = (bgcolorMgui & 0x0F) | (fgcolorMgui << 4);
       move.b    _bgcolorMgui.L,D0
       and.b     #15,D0
       move.b    _fgcolorMgui.L,D1
       lsl.b     #4,D1
       or.b      D1,D0
       move.b    D0,-5(A6)
; setWriteAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       and.l     #65535,D5
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (pixel);
       move.l    (A3),A0
       move.b    D2,(A0)
; setWriteAddress(mgui_color_table + offset);
       move.l    _mgui_color_table.L,D1
       and.l     #65535,D5
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (color);
       move.l    (A3),A0
       move.b    -5(A6),(A0)
       bra       vdp_write_gui_4
vdp_write_gui_6:
; }
; cursor.y = cursor.y + 1;
       move.l    A2,D0
       move.l    D0,A0
       move.b    1(A0),D0
       addq.b    #1,D0
       move.l    A2,D1
       move.l    D1,A0
       move.b    D0,1(A0)
       addq.w    #1,A5
       bra       vdp_write_gui_1
vdp_write_gui_3:
; }
; cursor.y = vAntY;
       move.w    -26(A6),D0
       move.l    A2,D1
       move.l    D1,A0
       move.b    D0,1(A0)
; vdp_set_cursor(cursor.x, cursor.y);
       move.l    A2,D1
       move.l    D1,A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Graphic Interface Functions
; //-----------------------------------------------------------------------------
; void writesxy(unsigned short x, unsigned short y, unsigned char sizef, unsigned char *msgs, unsigned short pcolor, unsigned short pbcolor)
; {
       xdef      _writesxy
_writesxy:
       link      A6,#-4
       move.l    D2,-(A7)
       move.l    20(A6),D2
; unsigned char ix = 10, xf;
       move.b    #10,-4(A6)
; unsigned char antfg, antbg;
; vdp_set_cursor(x,y);
       move.w    14(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    10(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; antfg = fgcolorMgui;
       move.b    _fgcolorMgui.L,-2(A6)
; antbg = bgcolorMgui;
       move.b    _bgcolorMgui.L,-1(A6)
; fgcolorMgui = pcolor;
       move.w    26(A6),D0
       move.b    D0,_fgcolorMgui.L
; bgcolorMgui = pbcolor;
       move.w    30(A6),D0
       move.b    D0,_bgcolorMgui.L
; while (*msgs) {
writesxy_1:
       move.l    D2,A0
       tst.b     (A0)
       beq       writesxy_3
; if (*msgs >= 0x20 && *msgs < 0x7F)
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       blo.s     writesxy_4
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #127,D0
       bhs.s     writesxy_4
; {
; vdp_write_gui(*msgs);
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _vdp_write_gui
       addq.w    #4,A7
; vdp_set_cursor_pos_gui(VDP_CSR_RIGHT);
       pea       3
       jsr       _vdp_set_cursor_pos_gui
       addq.w    #4,A7
writesxy_4:
; }
; *msgs++;
       move.l    D2,A0
       addq.l    #1,D2
       bra       writesxy_1
writesxy_3:
; }
; fgcolorMgui = antfg;
       move.b    -2(A6),_fgcolorMgui.L
; bgcolorMgui = antbg;
       move.b    -1(A6),_bgcolorMgui.L
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void writecxy(unsigned char sizef, unsigned char pbyte, unsigned short pcolor, unsigned short pbcolor)
; {
       xdef      _writecxy
_writecxy:
       link      A6,#0
       move.l    D2,-(A7)
       move.b    11(A6),D2
       and.w     #255,D2
; vdp_set_cursor(pposx, pposy);
       move.w    _pposy.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _pposx.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; vdp_write_gui(pbyte);
       move.b    15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _vdp_write_gui
       addq.w    #4,A7
; pposx = pposx + sizef;
       and.w     #255,D2
       add.w     D2,_pposx.L
; if ((pposx + sizef) > vxgmax)
       move.w    _pposx.L,D0
       and.w     #255,D2
       add.w     D2,D0
       cmp.w     _vxgmax.L,D0
       bls.s     writecxy_1
; pposx = pposx - sizef;
       and.w     #255,D2
       sub.w     D2,_pposx.L
writecxy_1:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void locatexy(unsigned short xx, unsigned short yy) {
       xdef      _locatexy
_locatexy:
       link      A6,#0
; pposx = xx;
       move.w    10(A6),_pposx.L
; pposy = yy;
       move.w    14(A6),_pposy.L
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void SaveScreenNew(MGUI_SAVESCR *mguiSave, unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight)
; {
       xdef      _SaveScreenNew
_SaveScreenNew:
       link      A6,#-24
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.w    14(A6),D2
       and.l     #65535,D2
       move.l    8(A6),D4
; unsigned short xf, yf, xiant;
; unsigned int ix, iy, vsizetotal;
; unsigned int offset, posX, posY, modY, saveOffSet, saveOffSetAnt;
; unsigned char *saverPat;
; unsigned char *saverCor;
; // Manter leitura rapida de 8 pixels (1 pixel por Byte)
; xiant = xi;
       move.w    D2,-22(A6)
; if ((xi & 0x0F) < 0x08)
       move.w    D2,D0
       and.w     #15,D0
       cmp.w     #8,D0
       bhs.s     SaveScreenNew_1
; xi = xi - (xi & 0x0F);
       move.w    D2,D0
       and.w     #15,D0
       sub.w     D0,D2
       bra.s     SaveScreenNew_2
SaveScreenNew_1:
; else
; xi = (xi - (xi & 0x0F)) + 0x08;
       move.w    D2,D0
       move.w    D2,D1
       and.w     #15,D1
       sub.w     D1,D0
       addq.w    #8,D0
       move.w    D0,D2
SaveScreenNew_2:
; pwidth += (xiant - xi);
       move.w    -22(A6),D0
       sub.w     D2,D0
       add.w     D0,22(A6)
; // Define Final
; xf = (xi + pwidth);
       move.w    D2,D0
       add.w     22(A6),D0
       move.w    D0,A2
; yf = (yi + pheight);
       move.w    18(A6),D0
       add.w     26(A6),D0
       move.w    D0,A3
; if (xf > 255)
       move.w    A2,D0
       cmp.w     #255,D0
       bls.s     SaveScreenNew_3
; xf = 255;
       move.w    #255,A2
SaveScreenNew_3:
; if (yf > 191)
       move.w    A3,D0
       cmp.w     #191,D0
       bls.s     SaveScreenNew_5
; yf = 191;
       move.w    #191,A3
SaveScreenNew_5:
; vsizetotal = (((pwidth + 1) / 8) * (pheight + 1));
       move.w    22(A6),D0
       addq.w    #1,D0
       and.l     #65535,D0
       divu.w    #8,D0
       move.w    26(A6),D1
       addq.w    #1,D1
       mulu.w    D1,D0
       and.l     #65535,D0
       move.l    D0,-20(A6)
; saverPat = malloc(vsizetotal);
       move.l    -20(A6),-(A7)
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,-8(A6)
; saverCor = malloc(vsizetotal);
       move.l    -20(A6),-(A7)
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,-4(A6)
; saveOffSet = 0;
       clr.l     D6
; for (iy = yi; iy < yf; iy++)
       move.w    18(A6),D0
       and.l     #65535,D0
       move.l    D0,D5
SaveScreenNew_7:
       cmp.l     A3,D5
       bhs       SaveScreenNew_9
; {
; ix = xi;
       and.l     #65535,D2
       move.l    D2,D3
; saveOffSetAnt = saveOffSet;
       move.l    D6,-12(A6)
; while (ix <= xf)
SaveScreenNew_10:
       cmp.l     A2,D3
       bhi       SaveScreenNew_12
; {
; posX = (int)(8 * (ix / 8));
       move.l    D3,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       8
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-16(A6)
; posY = (int)(256 * (iy / 8));
       move.l    D5,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       256
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,A5
; modY = (int)(iy % 8);
       move.l    D5,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,A4
; offset = posX + modY + posY;
       move.l    -16(A6),D0
       add.l     A4,D0
       add.l     A5,D0
       move.l    D0,D7
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D7,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D7,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; *(saverPat + saveOffSet) = *vvdgd;
       move.l    _vvdgd.L,A0
       move.l    -8(A6),A1
       move.b    (A0),0(A1,D6.L)
; saveOffSet = saveOffSet + 1;
       addq.l    #1,D6
; ix += 8;
       addq.l    #8,D3
       bra       SaveScreenNew_10
SaveScreenNew_12:
; }
; ix = xi;
       and.l     #65535,D2
       move.l    D2,D3
; saveOffSet = saveOffSetAnt;
       move.l    -12(A6),D6
; while (ix <= xf)
SaveScreenNew_13:
       cmp.l     A2,D3
       bhi       SaveScreenNew_15
; {
; posX = (int)(8 * (ix / 8));
       move.l    D3,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       8
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-16(A6)
; posY = (int)(256 * (iy / 8));
       move.l    D5,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       256
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,A5
; modY = (int)(iy % 8);
       move.l    D5,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,A4
; offset = posX + modY + posY;
       move.l    -16(A6),D0
       add.l     A4,D0
       add.l     A5,D0
       move.l    D0,D7
; setReadAddress(mgui_color_table + offset);
       move.l    _mgui_color_table.L,D1
       add.l     D7,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_color_table + offset);
       move.l    _mgui_color_table.L,D1
       add.l     D7,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; *(saverCor + saveOffSet) = *vvdgd;
       move.l    _vvdgd.L,A0
       move.l    -4(A6),A1
       move.b    (A0),0(A1,D6.L)
; saveOffSet = saveOffSet + 1;
       addq.l    #1,D6
; ix += 8;
       addq.l    #8,D3
       bra       SaveScreenNew_13
SaveScreenNew_15:
       addq.l    #1,D5
       bra       SaveScreenNew_7
SaveScreenNew_9:
; }
; }
; mguiSave->pat = saverPat;
       move.l    D4,A0
       move.l    -8(A6),(A0)
; mguiSave->cor = saverCor;
       move.l    D4,A0
       move.l    -4(A6),4(A0)
; mguiSave->size = vsizetotal;
       move.l    D4,A0
       move.l    -20(A6),8(A0)
; mguiSave->xi = xi;
       move.l    D4,A0
       move.w    D2,12(A0)
; mguiSave->yi = yi;
       move.l    D4,A0
       move.w    18(A6),14(A0)
; mguiSave->xf = xf;
       move.l    D4,A0
       move.w    A2,16(A0)
; mguiSave->yf = yf;
       move.l    D4,A0
       move.w    A3,18(A0)
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // SEM USO PRA NAO DAR PAU NO COMPILADOR. NAO ME PERGUNTE POR QUE
; //-----------------------------------------------------------------------------
; MGUI_SAVESCR SaveScreen(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight)
; {
       xdef      _SaveScreen
_SaveScreen:
       link      A6,#-20
; MGUI_SAVESCR mguiSave;
; return mguiSave;
       lea       -20(A6),A0
       move.l    8(A6),A1
       moveq     #4,D0
       move.l    (A0)+,(A1)+
       dbra      D0,*-2
       move.l    8(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void RestoreScreen(MGUI_SAVESCR pEnderSave) {
       xdef      _RestoreScreen
_RestoreScreen:
       link      A6,#-36
       movem.l   D2/D3/D4/D5/A2,-(A7)
       lea       8(A6),A2
; unsigned short xi,yi,xf, yf;
; unsigned int ix, iy;
; unsigned int offset, posX, posY, modY, saveOffSet, saveOffSetAnt;
; unsigned char pixel;
; unsigned char color;
; unsigned char *saverPat;
; unsigned char *saverCor;
; saverPat = pEnderSave.pat;
       move.l    A2,D0
       move.l    D0,A0
       move.l    (A0),-8(A6)
; saverCor = pEnderSave.cor;
       move.l    A2,D0
       move.l    D0,A0
       move.l    4(A0),-4(A6)
; xi = pEnderSave.xi;
       move.l    A2,D0
       move.l    D0,A0
       move.w    12(A0),-34(A6)
; xf = pEnderSave.xf;
       move.l    A2,D0
       move.l    D0,A0
       move.w    16(A0),-30(A6)
; yi = pEnderSave.yi;
       move.l    A2,D0
       move.l    D0,A0
       move.w    14(A0),-32(A6)
; yf = pEnderSave.yf;
       move.l    A2,D0
       move.l    D0,A0
       move.w    18(A0),-28(A6)
; saveOffSet = 0;
       clr.l     D4
; for (iy = yi; iy < yf; iy++)
       move.w    -32(A6),D0
       and.l     #65535,D0
       move.l    D0,D2
RestoreScreen_1:
       move.w    -28(A6),D0
       and.l     #65535,D0
       cmp.l     D0,D2
       bhs       RestoreScreen_3
; {
; ix = xi;
       move.w    -34(A6),D0
       and.l     #65535,D0
       move.l    D0,D3
; while (ix <= xf)
RestoreScreen_4:
       move.w    -30(A6),D0
       and.l     #65535,D0
       cmp.l     D0,D3
       bhi       RestoreScreen_6
; {
; posX = (int)(8 * (ix / 8));
       move.l    D3,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       8
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-26(A6)
; posY = (int)(256 * (iy / 8));
       move.l    D2,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       256
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-22(A6)
; modY = (int)(iy % 8);
       move.l    D2,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-18(A6)
; offset = posX + modY + posY;
       move.l    -26(A6),D0
       add.l     -18(A6),D0
       add.l     -22(A6),D0
       move.l    D0,D5
; pixel = *(saverPat + saveOffSet);
       move.l    -8(A6),A0
       move.b    0(A0,D4.L),-10(A6)
; color = *(saverCor + saveOffSet);
       move.l    -4(A6),A0
       move.b    0(A0,D4.L),-9(A6)
; saveOffSet = saveOffSet + 1;
       addq.l    #1,D4
; setWriteAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = pixel;
       move.l    _vvdgd.L,A0
       move.b    -10(A6),(A0)
; setWriteAddress(mgui_color_table + offset);
       move.l    _mgui_color_table.L,D1
       add.l     D5,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = color;
       move.l    _vvdgd.L,A0
       move.b    -9(A6),(A0)
; ix += 8;
       addq.l    #8,D3
       bra       RestoreScreen_4
RestoreScreen_6:
       addq.l    #1,D2
       bra       RestoreScreen_1
RestoreScreen_3:
; }
; }
; free(pEnderSave.cor);
       move.l    A2,D1
       move.l    D1,A0
       move.l    4(A0),-(A7)
       jsr       _free
       addq.w    #4,A7
; free(pEnderSave.pat);
       move.l    A2,D1
       move.l    D1,A0
       move.l    (A0),-(A7)
       jsr       _free
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/D5/A2
       unlk      A6
       rts
; /*
; for (iy = yi; iy <= yf; iy++)
; {
; ix = xi;
; posX = (int)(8 * (ix / 8));
; posY = (int)(256 * (iy / 8));
; modY = (int)(iy % 8);
; offset = posX + modY + posY;
; setWriteAddress(mgui_pattern_table + offset);
; saveOffSetAnt = saveOffSet;
; while (ix <= xf)
; {
; pixel = *(saverPat + saveOffSet++);
; *vvdgd = (pixel);
; ix += 8;
; }
; ix = xi;
; setWriteAddress(mgui_color_table + offset);
; saveOffSet = saveOffSetAnt;
; while (ix <= xf)
; {
; color = *(saverCor + saveOffSet++);
; *vvdgd = (color);
; ix += 8;
; }
; }
; */
; }
; //-----------------------------------------------------------------------------
; void SetDot(unsigned short x, unsigned short y, unsigned short color) {
       xdef      _SetDot
_SetDot:
       link      A6,#0
; vdp_plot_hires(x, y, color, bgcolorMgui);
       move.b    _bgcolorMgui.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    18(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    14(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    10(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void SetByte(unsigned short ix, unsigned short iy, unsigned char pByte, unsigned short pfcolor, unsigned short pbcolor)
; {
       xdef      _SetByte
_SetByte:
       link      A6,#-16
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.w    10(A6),D2
       and.l     #65535,D2
       move.b    19(A6),D3
       and.l     #255,D3
       lea       _vvdgd.L,A3
       lea       _mgui_color_table.L,A5
; unsigned int offset, offsetByte, posX, posY, modX, modY, xf, ixAnt;
; unsigned char pixel;
; unsigned char color;
; xf = ix + 8;
       and.l     #65535,D2
       move.l    D2,D0
       addq.l    #8,D0
       move.l    D0,A2
; if (xf > 255)
       move.l    A2,D0
       cmp.l     #255,D0
       bls.s     SetByte_1
; xf = 255;
       move.w    #255,A2
SetByte_1:
; ixAnt = ix;
       and.l     #65535,D2
       move.l    D2,-4(A6)
; while (ix < xf)
SetByte_3:
       and.l     #65535,D2
       cmp.l     A2,D2
       bhs       SetByte_5
; {
; posX = (int)(8 * (ix / 8));
       move.w    D2,D0
       and.l     #65535,D0
       divu.w    #8,D0
       mulu.w    #8,D0
       and.l     #65535,D0
       move.l    D0,-16(A6)
; posY = (int)(256 * (iy / 8));
       move.w    14(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       mulu.w    #256,D0
       and.l     #65535,D0
       move.l    D0,-12(A6)
; modX = (int)(ix % 8);
       move.w    D2,D0
       and.l     #65535,D0
       divu.w    #8,D0
       swap      D0
       and.l     #65535,D0
       move.l    D0,D5
; modY = (int)(iy % 8);
       move.w    14(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       swap      D0
       and.l     #65535,D0
       move.l    D0,-8(A6)
; offset = posX + modY + posY;
       move.l    -16(A6),D0
       add.l     -8(A6),D0
       add.l     -12(A6),D0
       move.l    D0,D4
; if (modX > 0 || (modX == 0 && ((ix + 8) > xf)))
       cmp.l     #0,D5
       bhi.s     SetByte_8
       tst.l     D5
       bne       SetByte_6
       move.w    D2,D0
       addq.w    #8,D0
       and.l     #65535,D0
       cmp.l     A2,D0
       bls       SetByte_6
SetByte_8:
; {
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D4,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D4,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; pixel = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),D7
; setReadAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D4,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D4,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; color = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),D6
; if (ix == ixAnt)
       and.l     #65535,D2
       cmp.l     -4(A6),D2
       bne       SetByte_9
; {
; offsetByte = (8 - modX);
       moveq     #8,D0
       ext.w     D0
       ext.l     D0
       sub.l     D5,D0
       move.l    D0,A4
; pByte = pByte >> modX;
       move.b    D3,D0
       and.l     #255,D0
       lsr.l     D5,D0
       move.b    D0,D3
; pixel |= pByte;
       or.b      D3,D7
; ix += (8 - modX);
       moveq     #8,D0
       ext.w     D0
       ext.l     D0
       sub.l     D5,D0
       add.w     D0,D2
       bra.s     SetByte_10
SetByte_9:
; }
; else
; {
; pByte = pByte << offsetByte;
       move.b    D3,D0
       and.l     #255,D0
       move.l    A4,D1
       lsl.l     D1,D0
       move.b    D0,D3
; pixel |= pByte;
       or.b      D3,D7
; ix += (8 - offsetByte);
       moveq     #8,D0
       ext.w     D0
       ext.l     D0
       sub.l     A4,D0
       add.w     D0,D2
SetByte_10:
; }
; color = (color & 0x0F) | (pfcolor << 4);
       move.b    D6,D0
       and.b     #15,D0
       and.w     #255,D0
       move.w    22(A6),D1
       lsl.w     #4,D1
       or.w      D1,D0
       move.b    D0,D6
       bra.s     SetByte_7
SetByte_6:
; }
; else
; {
; pixel = pByte;
       move.b    D3,D7
; color = (pbcolor & 0x0F) | (pfcolor << 4);
       move.w    26(A6),D0
       and.w     #15,D0
       move.w    22(A6),D1
       lsl.w     #4,D1
       or.w      D1,D0
       move.b    D0,D6
; ix += 8;
       addq.w    #8,D2
SetByte_7:
; }
; setWriteAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D4,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (pixel);
       move.l    (A3),A0
       move.b    D7,(A0)
; setWriteAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D4,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (color);
       move.l    (A3),A0
       move.b    D6,(A0)
       bra       SetByte_3
SetByte_5:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void FillRect(unsigned char xi, unsigned char yi, unsigned short pwidth, unsigned char pheight, unsigned char pcor) {
       xdef      _FillRect
_FillRect:
       link      A6,#-12
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vvdgd.L,A3
       lea       _mgui_color_table.L,A5
; unsigned short xf, yf;
; unsigned int ix, iy;
; unsigned int offset, posX, posY, modX, modY;
; unsigned char pixel;
; unsigned char color;
; xf = (xi + pwidth);
       move.b    11(A6),D0
       and.w     #255,D0
       add.w     18(A6),D0
       move.w    D0,A2
; yf = (yi + pheight);
       move.b    15(A6),D0
       and.w     #255,D0
       move.b    23(A6),D1
       and.w     #255,D1
       add.w     D1,D0
       move.w    D0,A4
; if (xf > 255)
       move.w    A2,D0
       cmp.w     #255,D0
       bls.s     FillRect_1
; xf = 255;
       move.w    #255,A2
FillRect_1:
; if (yf > 191)
       move.w    A4,D0
       cmp.w     #191,D0
       bls.s     FillRect_3
; yf = 191;
       move.w    #191,A4
FillRect_3:
; for (iy = yi; iy <= yf; iy++)
       move.b    15(A6),D0
       and.l     #255,D0
       move.l    D0,D7
FillRect_5:
       cmp.l     A4,D7
       bhi       FillRect_7
; {
; ix = xi;
       move.b    11(A6),D0
       and.l     #255,D0
       move.l    D0,D4
; while (ix <= xf)
FillRect_8:
       cmp.l     A2,D4
       bhi       FillRect_10
; {
; posX = (int)(8 * (ix / 8));
       move.l    D4,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       8
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-12(A6)
; posY = (int)(256 * (iy / 8));
       move.l    D7,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       256
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-8(A6)
; modX = (int)(ix % 8);
       move.l    D4,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,D6
; modY = (int)(iy % 8);
       move.l    D7,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-4(A6)
; offset = posX + modY + posY;
       move.l    -12(A6),D0
       add.l     -4(A6),D0
       add.l     -8(A6),D0
       move.l    D0,D3
; if (modX > 0 || (modX == 0 && ((ix + 8) > xf)))
       cmp.l     #0,D6
       bhi.s     FillRect_13
       tst.l     D6
       bne       FillRect_11
       move.l    D4,D0
       addq.l    #8,D0
       cmp.l     A2,D0
       bls       FillRect_11
FillRect_13:
; {
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; pixel = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),D5
; setReadAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; color = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),D2
; if (pcor != 0x00)
       move.b    27(A6),D0
       beq.s     FillRect_14
; {
; pixel |= 0x80 >> modX; //Set a "1"
       move.w    #128,D0
       ext.l     D0
       lsr.l     D6,D0
       or.b      D0,D5
; color = (color & 0x0F) | (pcor << 4);
       move.b    D2,D0
       and.b     #15,D0
       move.b    27(A6),D1
       lsl.b     #4,D1
       or.b      D1,D0
       move.b    D0,D2
       bra.s     FillRect_15
FillRect_14:
; }
; else
; {
; pixel &= ~(0x80 >> modX); //Set bit as "0"
       move.w    #128,D0
       ext.l     D0
       lsr.l     D6,D0
       not.l     D0
       and.b     D0,D5
; color = (color & 0xF0) | (bgcolorMgui & 0x0F);
       move.b    D2,D0
       and.w     #255,D0
       and.w     #240,D0
       move.b    _bgcolorMgui.L,D1
       and.b     #15,D1
       and.w     #255,D1
       or.w      D1,D0
       move.b    D0,D2
FillRect_15:
; }
; ix++;
       addq.l    #1,D4
       bra.s     FillRect_12
FillRect_11:
; }
; else
; {
; if (pcor != 0x00)
       move.b    27(A6),D0
       beq.s     FillRect_16
; {
; pixel = 0xFF;
       move.b    #255,D5
; color = (bgcolorMgui & 0x0F) | (pcor << 4);
       move.b    _bgcolorMgui.L,D0
       and.b     #15,D0
       move.b    27(A6),D1
       lsl.b     #4,D1
       or.b      D1,D0
       move.b    D0,D2
       bra.s     FillRect_17
FillRect_16:
; }
; else
; {
; pixel = 0x00;
       clr.b     D5
; color = (bgcolorMgui & 0x0F);
       move.b    _bgcolorMgui.L,D0
       and.b     #15,D0
       move.b    D0,D2
FillRect_17:
; }
; ix += 8;
       addq.l    #8,D4
FillRect_12:
; }
; setWriteAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (pixel);
       move.l    (A3),A0
       move.b    D5,(A0)
; setWriteAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (color);
       move.l    (A3),A0
       move.b    D2,(A0)
       bra       FillRect_8
FillRect_10:
       addq.l    #1,D7
       bra       FillRect_5
FillRect_7:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; }
; //-----------------------------------------------------------------------------
; void DrawLine(unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2, unsigned short color) {
       xdef      _DrawLine
_DrawLine:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.w    10(A6),D7
; int ix, iy;
; int zz,x,y,addx,addy,dx,dy;
; long P;
; if (y1 == y2)       // Horizontal
       move.w    14(A6),D0
       cmp.w     22(A6),D0
       bne       DrawLine_1
; FillRect(x1,y1,(x2 - x1),1,color);
       move.w    26(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       move.w    18(A6),D1
       sub.w     D7,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    14(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       jsr       _FillRect
       add.w     #20,A7
       bra       DrawLine_25
DrawLine_1:
; else if (x1 == x2)  // Vertical
       cmp.w     18(A6),D7
       bne       DrawLine_3
; {
; for (iy = y1; iy <= y2; iy++)
       move.w    14(A6),D0
       and.l     #65535,D0
       move.l    D0,-4(A6)
DrawLine_5:
       move.w    22(A6),D0
       and.l     #65535,D0
       cmp.l     -4(A6),D0
       blo       DrawLine_7
; vdp_plot_hires(x1, iy, color, bgcolorMgui);
       move.b    _bgcolorMgui.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    26(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -4(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,-4(A6)
       bra       DrawLine_5
DrawLine_7:
       bra       DrawLine_25
DrawLine_3:
; }
; else    // Torta
; {
; dx = (x2 - x1);
       move.w    18(A6),D0
       and.l     #65535,D0
       and.l     #65535,D7
       sub.l     D7,D0
       move.l    D0,D4
; dy = (y2 - y1);
       move.w    22(A6),D0
       and.l     #65535,D0
       move.w    14(A6),D1
       and.l     #65535,D1
       sub.l     D1,D0
       move.l    D0,D3
; if (dx < 0)
       cmp.l     #0,D4
       bge.s     DrawLine_8
; dx = dx * (-1);
       move.l    D4,-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),D4
       addq.w    #8,A7
DrawLine_8:
; if (dy < 0)
       cmp.l     #0,D3
       bge.s     DrawLine_10
; dy = dy * (-1);
       move.l    D3,-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),D3
       addq.w    #8,A7
DrawLine_10:
; x = x1;
       and.l     #65535,D7
       move.l    D7,D6
; y = y1;
       move.w    14(A6),D0
       and.l     #65535,D0
       move.l    D0,D5
; if(x1 > x2)
       cmp.w     18(A6),D7
       bls.s     DrawLine_12
; addx = -1;
       move.w    #-1,A4
       bra.s     DrawLine_13
DrawLine_12:
; else
; addx = 1;
       move.w    #1,A4
DrawLine_13:
; if(y1 > y2)
       move.w    14(A6),D0
       cmp.w     22(A6),D0
       bls.s     DrawLine_14
; addy = -1;
       move.w    #-1,A3
       bra.s     DrawLine_15
DrawLine_14:
; else
; addy = 1;
       move.w    #1,A3
DrawLine_15:
; if(dx >= dy)
       cmp.l     D3,D4
       blt       DrawLine_16
; {
; P = (2 * dy) - dx;
       move.l    D3,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       sub.l     D4,D0
       move.l    D0,D2
; for(ix = 1; ix <= (dx + 1); ix++)
       move.w    #1,A2
DrawLine_18:
       move.l    D4,D0
       addq.l    #1,D0
       move.l    A2,D1
       cmp.l     D0,D1
       bgt       DrawLine_20
; {
; vdp_plot_hires(x, y, color, bgcolorMgui);
       move.b    _bgcolorMgui.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    26(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; if (P < 0)
       cmp.l     #0,D2
       bge.s     DrawLine_21
; {
; P = P + (2 * dy);
       move.l    D3,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,D2
; zz = x + addx;
       move.l    D6,D0
       add.l     A4,D0
       move.l    D0,A5
; x = zz;
       move.l    A5,D6
       bra       DrawLine_22
DrawLine_21:
; }
; else
; {
; P = P + (2 * dy) - (2 * dx);
       move.l    D2,D0
       move.l    D3,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D4,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,D2
; x = x + addx;
       add.l     A4,D6
; zz = y + addy;
       move.l    D5,D0
       add.l     A3,D0
       move.l    D0,A5
; y = zz;
       move.l    A5,D5
DrawLine_22:
       addq.w    #1,A2
       bra       DrawLine_18
DrawLine_20:
       bra       DrawLine_25
DrawLine_16:
; }
; }
; }
; else
; {
; P = (2 * dx) - dy;
       move.l    D4,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       sub.l     D3,D0
       move.l    D0,D2
; for(ix = 1; ix <= (dy +1); ix++)
       move.w    #1,A2
DrawLine_23:
       move.l    D3,D0
       addq.l    #1,D0
       move.l    A2,D1
       cmp.l     D0,D1
       bgt       DrawLine_25
; {
; vdp_plot_hires(x, y, color, bgcolorMgui);
       move.b    _bgcolorMgui.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    26(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; if (P < 0)
       cmp.l     #0,D2
       bge.s     DrawLine_26
; {
; P = P + (2 * dx);
       move.l    D4,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,D2
; y = y + addy;
       add.l     A3,D5
       bra       DrawLine_27
DrawLine_26:
; }
; else
; {
; P = P + (2 * dx) - (2 * dy);
       move.l    D2,D0
       move.l    D4,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D3,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,D2
; x = x + addx;
       add.l     A4,D6
; y = y + addy;
       add.l     A3,D5
DrawLine_27:
       addq.w    #1,A2
       bra       DrawLine_23
DrawLine_25:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; }
; }
; }
; //-----------------------------------------------------------------------------
; void DrawRect(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight, unsigned short color) {
       xdef      _DrawRect
_DrawRect:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/A2,-(A7)
       move.w    14(A6),D2
       and.l     #65535,D2
       move.w    10(A6),D4
       and.l     #65535,D4
       move.w    26(A6),D6
       and.l     #65535,D6
       lea       _DrawLine.L,A2
; unsigned short xf, yf;
; xf = (xi + pwidth);
       move.w    D4,D0
       add.w     18(A6),D0
       move.w    D0,D5
; yf = (yi + pheight);
       move.w    D2,D0
       add.w     22(A6),D0
       move.w    D0,D3
; DrawLine(xi,yi,xf,yi,color);
       and.l     #65535,D6
       move.l    D6,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       and.l     #65535,D5
       move.l    D5,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       and.l     #65535,D4
       move.l    D4,-(A7)
       jsr       (A2)
       add.w     #20,A7
; DrawLine(xi,yf,xf,yf,color);
       and.l     #65535,D6
       move.l    D6,-(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.l     #65535,D5
       move.l    D5,-(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.l     #65535,D4
       move.l    D4,-(A7)
       jsr       (A2)
       add.w     #20,A7
; DrawLine(xi,yi,xi,yf,color);
       and.l     #65535,D6
       move.l    D6,-(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.l     #65535,D4
       move.l    D4,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       and.l     #65535,D4
       move.l    D4,-(A7)
       jsr       (A2)
       add.w     #20,A7
; DrawLine(xf,yi,xf,yf,color);
       and.l     #65535,D6
       move.l    D6,-(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.l     #65535,D5
       move.l    D5,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       and.l     #65535,D5
       move.l    D5,-(A7)
       jsr       (A2)
       add.w     #20,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void DrawRoundRect(unsigned int xi, unsigned int yi, unsigned int pwidth, unsigned int pheight, unsigned char radius, unsigned char color) {
       xdef      _DrawRoundRect
_DrawRoundRect:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.b    27(A6),D2
       and.l     #255,D2
       move.b    31(A6),D6
       and.l     #255,D6
       move.l    20(A6),A2
       move.l    16(A6),A3
       lea       _FillRect.L,A4
; unsigned short tSwitch, x1 = 0, y1, xt, yt, wt;
       clr.w     D5
; y1 = radius;
       and.w     #255,D2
       move.w    D2,D7
; tSwitch = 3 - 2 * radius;
       moveq     #3,D0
       ext.w     D0
       move.b    D2,D1
       and.w     #255,D1
       mulu.w    #2,D1
       sub.w     D1,D0
       move.w    D0,A5
; while (x1 <= y1) {
DrawRoundRect_1:
       cmp.w     D7,D5
       bhi       DrawRoundRect_3
; xt = xi + radius - x1;
       move.l    8(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D5
       sub.l     D5,D0
       move.w    D0,D4
; yt = yi + radius - y1;
       move.l    12(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D7
       sub.l     D7,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; xt = xi + radius - y1;
       move.l    8(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D7
       sub.l     D7,D0
       move.w    D0,D4
; yt = yi + radius - x1;
       move.l    12(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D5
       sub.l     D5,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; xt = xi + pwidth-radius + x1;
       move.l    8(A6),D0
       add.l     A3,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D5
       add.l     D5,D0
       move.w    D0,D4
; yt = yi + radius - y1;
       move.l    12(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D7
       sub.l     D7,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; xt = xi + pwidth-radius + y1;
       move.l    8(A6),D0
       add.l     A3,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D7
       add.l     D7,D0
       move.w    D0,D4
; yt = yi + radius - x1;
       move.l    12(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D5
       sub.l     D5,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; xt = xi + pwidth-radius + x1;
       move.l    8(A6),D0
       add.l     A3,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D5
       add.l     D5,D0
       move.w    D0,D4
; yt = yi + pheight-radius + y1;
       move.l    12(A6),D0
       add.l     A2,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D7
       add.l     D7,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; xt = xi + pwidth-radius + y1;
       move.l    8(A6),D0
       add.l     A3,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D7
       add.l     D7,D0
       move.w    D0,D4
; yt = yi + pheight-radius + x1;
       move.l    12(A6),D0
       add.l     A2,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D5
       add.l     D5,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; xt = xi + radius - x1;
       move.l    8(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D5
       sub.l     D5,D0
       move.w    D0,D4
; yt = yi + pheight-radius + y1;
       move.l    12(A6),D0
       add.l     A2,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D7
       add.l     D7,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; xt = xi + radius - y1;
       move.l    8(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       and.l     #65535,D7
       sub.l     D7,D0
       move.w    D0,D4
; yt = yi + pheight-radius + x1;
       move.l    12(A6),D0
       add.l     A2,D0
       and.l     #255,D2
       sub.l     D2,D0
       and.l     #65535,D5
       add.l     D5,D0
       move.w    D0,D3
; vdp_plot_hires(xt, yt, color, 0);
       clr.l     -(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; if (tSwitch < 0) {
       move.w    A5,D0
       cmp.w     #0,D0
       bhs.s     DrawRoundRect_4
; tSwitch += (4 * x1 + 6);
       move.w    D5,D0
       mulu.w    #4,D0
       addq.w    #6,D0
       add.w     D0,A5
       bra.s     DrawRoundRect_5
DrawRoundRect_4:
; } else {
; tSwitch += (4 * (x1 - y1) + 10);
       move.w    D5,D0
       sub.w     D7,D0
       mulu.w    #4,D0
       add.w     #10,D0
       add.w     D0,A5
; y1--;
       subq.w    #1,D7
DrawRoundRect_5:
; }
; x1++;
       addq.w    #1,D5
       bra       DrawRoundRect_1
DrawRoundRect_3:
; }
; xt = xi + radius;
       move.l    8(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       move.w    D0,D4
; yt = yi + pheight;
       move.l    12(A6),D0
       add.l     A2,D0
       move.w    D0,D3
; wt = pwidth - (2 * radius);
       move.l    A3,D0
       move.b    D2,D1
       and.w     #255,D1
       mulu.w    #2,D1
       and.l     #255,D1
       sub.l     D1,D0
       move.w    D0,-2(A6)
; DrawHoriLine(xt, yi, wt, color);		// top
       and.l     #255,D6
       move.l    D6,-(A7)
       pea       1
       move.w    -2(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    12(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       jsr       (A4)
       add.w     #20,A7
; DrawHoriLine(xt, yt, wt, color);	// bottom
       and.l     #255,D6
       move.l    D6,-(A7)
       pea       1
       move.w    -2(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       jsr       (A4)
       add.w     #20,A7
; xt = xi + pwidth;
       move.l    8(A6),D0
       add.l     A3,D0
       move.w    D0,D4
; yt = yi + radius;
       move.l    12(A6),D0
       and.l     #255,D2
       add.l     D2,D0
       move.w    D0,D3
; wt = pheight - (2 * radius);
       move.l    A2,D0
       move.b    D2,D1
       and.w     #255,D1
       mulu.w    #2,D1
       and.l     #255,D1
       sub.l     D1,D0
       move.w    D0,-2(A6)
; DrawVertLine(xi, yt, wt, color);		// left
       and.l     #255,D6
       move.l    D6,-(A7)
       move.w    -2(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       and.l     #255,D3
       move.l    D3,-(A7)
       move.l    8(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #20,A7
; DrawVertLine(xt, yt, wt, color);	// right
       and.l     #255,D6
       move.l    D6,-(A7)
       move.w    -2(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       jsr       (A4)
       add.w     #20,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void DrawCircle(unsigned short x0, unsigned short y0, unsigned char r, unsigned char pfil, unsigned short pcor) {
       xdef      _DrawCircle
_DrawCircle:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7)
       move.w    10(A6),D2
       move.w    14(A6),D3
       move.w    26(A6),D4
       move.b    19(A6),D7
       and.l     #255,D7
; int f = 1 - r;
       moveq     #1,D0
       ext.w     D0
       ext.l     D0
       and.l     #255,D7
       sub.l     D7,D0
       move.l    D0,A2
; int ddF_x = 1;
       move.w    #1,A4
; int ddF_y = -2 * r;
       moveq     #-2,D0
       and.w     #255,D0
       and.w     #255,D7
       mulu.w    D7,D0
       and.l     #65535,D0
       move.l    D0,A3
; int x = 0;
       clr.l     D6
; int y = r;
       and.l     #255,D7
       move.l    D7,D5
; vdp_plot_hires(x0  , y0+r, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.w     #255,D7
       add.w     D7,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0  , y0-r, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.w     #255,D7
       sub.w     D7,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0+r, y0  , pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       move.w    D2,D1
       and.w     #255,D7
       add.w     D7,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0-r, y0  , pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       move.w    D2,D1
       and.w     #255,D7
       sub.w     D7,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; while (x<y) {
DrawCircle_1:
       cmp.l     D5,D6
       bge       DrawCircle_3
; if (f >= 0) {
       move.l    A2,D0
       cmp.l     #0,D0
       blt.s     DrawCircle_4
; y--;
       subq.l    #1,D5
; ddF_y += 2;
       addq.w    #2,A3
; f += ddF_y;
       add.l     A3,A2
DrawCircle_4:
; }
; x++;
       addq.l    #1,D6
; ddF_x += 2;
       addq.w    #2,A4
; f += ddF_x;
       add.l     A4,A2
; vdp_plot_hires(x0 + x, y0 + y, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       add.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       add.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0 - x, y0 + y, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       add.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       sub.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0 + x, y0 - y, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       sub.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       add.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0 - x, y0 - y, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       sub.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       sub.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0 + y, y0 + x, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       add.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       add.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0 - y, y0 + x, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       add.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       sub.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0 + y, y0 - x, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       sub.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       add.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires(x0 - y, y0 - x, pcor, 0);
       clr.l     -(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.w    D3,D1
       and.l     #65535,D1
       sub.l     D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       and.l     #65535,D1
       sub.l     D5,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       bra       DrawCircle_1
DrawCircle_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void InvertRect(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight) {
       xdef      _InvertRect
_InvertRect:
       link      A6,#-16
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vvdgd.L,A3
       lea       _mgui_color_table.L,A5
; unsigned short xf, yf;
; unsigned int ix, iy;
; unsigned int offset, posX, posY, modX, modY;
; unsigned char pixel;
; unsigned char color, color1, color2, vprim = 0;
       clr.b     -1(A6)
; xf = (xi + pwidth);
       move.w    10(A6),D0
       add.w     18(A6),D0
       move.w    D0,A2
; yf = (yi + pheight);
       move.w    14(A6),D0
       add.w     22(A6),D0
       move.w    D0,A4
; if (xf > 255)
       move.w    A2,D0
       cmp.w     #255,D0
       bls.s     InvertRect_1
; xf = 255;
       move.w    #255,A2
InvertRect_1:
; if (yf > 191)
       move.w    A4,D0
       cmp.w     #191,D0
       bls.s     InvertRect_3
; yf = 191;
       move.w    #191,A4
InvertRect_3:
; for (iy = yi; iy <= yf; iy++)
       move.w    14(A6),D0
       and.l     #65535,D0
       move.l    D0,D7
InvertRect_5:
       cmp.l     A4,D7
       bhi       InvertRect_7
; {
; ix = xi;
       move.w    10(A6),D0
       and.l     #65535,D0
       move.l    D0,D4
; while (ix <= xf)
InvertRect_8:
       cmp.l     A2,D4
       bhi       InvertRect_10
; {
; posX = (int)(8 * (ix / 8));
       move.l    D4,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       8
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-16(A6)
; posY = (int)(256 * (iy / 8));
       move.l    D7,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       256
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-12(A6)
; modX = (int)(ix % 8);
       move.l    D4,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,D6
; modY = (int)(iy % 8);
       move.l    D7,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-8(A6)
; offset = posX + modY + posY;
       move.l    -16(A6),D0
       add.l     -8(A6),D0
       add.l     -12(A6),D0
       move.l    D0,D3
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; pixel = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),D5
; setReadAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; color = *vvdgd;
       move.l    (A3),A0
       move.b    (A0),D2
; if (modX == 0)
       tst.l     D6
       bne.s     InvertRect_11
; vprim = 0;
       clr.b     -1(A6)
InvertRect_11:
; if (modX > 0 || (modX == 0 && ((ix + 8) > xf)))
       cmp.l     #0,D6
       bhi.s     InvertRect_15
       tst.l     D6
       bne       InvertRect_13
       move.l    D4,D0
       addq.l    #8,D0
       cmp.l     A2,D0
       bls       InvertRect_13
InvertRect_15:
; {
; pixel &= ~(0x80 >> modX);
       move.w    #128,D0
       ext.l     D0
       lsr.l     D6,D0
       not.l     D0
       and.b     D0,D5
; if (!vprim)
       tst.b     -1(A6)
       bne.s     InvertRect_16
; {
; vprim = 1;
       move.b    #1,-1(A6)
; color1 = (color & 0xF0) >> 4;
       move.b    D2,D0
       and.w     #255,D0
       and.w     #240,D0
       asr.w     #4,D0
       move.b    D0,-3(A6)
; color2 = (color & 0x0F) << 4;
       move.b    D2,D0
       and.b     #15,D0
       lsl.b     #4,D0
       move.b    D0,-2(A6)
; color = (color1 | color2);
       move.b    -3(A6),D0
       or.b      -2(A6),D0
       move.b    D0,D2
InvertRect_16:
; }
; ix++;
       addq.l    #1,D4
       bra       InvertRect_14
InvertRect_13:
; }
; else
; {
; pixel = ~pixel;
       move.b    D5,D0
       not.b     D0
       move.b    D0,D5
; color1 = (color & 0xF0) >> 4;
       move.b    D2,D0
       and.w     #255,D0
       and.w     #240,D0
       asr.w     #4,D0
       move.b    D0,-3(A6)
; color2 = (color & 0x0F) << 4;
       move.b    D2,D0
       and.b     #15,D0
       lsl.b     #4,D0
       move.b    D0,-2(A6)
; color = (color1 | color2);
       move.b    -3(A6),D0
       or.b      -2(A6),D0
       move.b    D0,D2
; ix += 8;
       addq.l    #8,D4
InvertRect_14:
; }
; setWriteAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (pixel);
       move.l    (A3),A0
       move.b    D5,(A0)
; setWriteAddress(mgui_color_table + offset);
       move.l    (A5),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = (color);
       move.l    (A3),A0
       move.b    D2,(A0)
       bra       InvertRect_8
InvertRect_10:
       addq.l    #1,D7
       bra       InvertRect_5
InvertRect_7:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; }
; //-------------------------------------------------------------------------
; unsigned char button(unsigned char *title, unsigned short xib, unsigned short yib, unsigned short width, unsigned short height, unsigned char vtipo)
; {
       xdef      _button
_button:
       link      A6,#-4
       movem.l   D2/D3/D4/D5,-(A7)
       move.w    18(A6),D2
       and.l     #65535,D2
       move.w    14(A6),D3
       and.l     #65535,D3
       move.w    22(A6),D4
       and.l     #65535,D4
; unsigned char vRet = 0, xibf = xib + width, yibf = yib + height;
       clr.b     D5
       move.w    D3,D0
       add.w     D4,D0
       move.b    D0,-3(A6)
       move.w    D2,D0
       add.w     26(A6),D0
       move.b    D0,-2(A6)
; unsigned char vPosTxt;
; if (vtipo == WINOPER)
       move.b    31(A6),D0
       cmp.b     #1,D0
       bne       button_5
; {
; if (mouseBtnPres == 0x01)   // Left Mouse Button
       move.b    _mouseBtnPres.L,D0
       cmp.b     #1,D0
       bne.s     button_5
; {
; if (vpostx >= xib && vpostx <= xibf && vposty >= yib && vposty <= yibf)
       cmp.w     _vpostx.L,D3
       bhi.s     button_5
       move.b    -3(A6),D0
       and.w     #255,D0
       cmp.w     _vpostx.L,D0
       blo.s     button_5
       cmp.w     _vposty.L,D2
       bhi.s     button_5
       move.b    -2(A6),D0
       and.w     #255,D0
       cmp.w     _vposty.L,D0
       blo.s     button_5
; vRet = 1;
       moveq     #1,D5
button_5:
; }
; }
; if (vtipo == WINDISP)
       move.b    31(A6),D0
       bne       button_7
; {
; vPosTxt = (width / 2) - ((strlen(title) / 2) * 6);
       move.w    D4,D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.l     #65535,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       2
       jsr       LDIV
       move.l    (A7),D1
       addq.w    #8,A7
       move.l    D1,-(A7)
       pea       6
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.b    D0,-1(A6)
; DrawRoundRect(xib,yib,width,height,1,vcorwf);  // rounded rectangle around text area
       move.b    _vcorwf.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       move.w    26(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D4
       move.l    D4,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       jsr       _DrawRoundRect
       add.w     #24,A7
; writesxy(xib + vPosTxt, yib + 2,1,title,vcorwf,vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    8(A6),-(A7)
       pea       1
       move.w    D2,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       move.l    D0,-(A7)
       move.b    -1(A6),D0
       and.w     #255,D0
       add.w     D0,D1
       move.l    (A7)+,D0
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _writesxy
       add.w     #24,A7
button_7:
; }
; return vRet;
       move.b    D5,D0
       movem.l   (A7)+,D2/D3/D4/D5
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; void fillin(unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo)
; {
       xdef      _fillin
_fillin:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.w    14(A6),D3
       and.l     #65535,D3
       lea       _vcorwf.L,A2
       move.w    18(A6),D6
       and.l     #65535,D6
       move.w    22(A6),D7
       and.l     #65535,D7
       move.l    8(A6),A3
       lea       _writecxy.L,A4
       lea       _locatexy.L,A5
; unsigned short cc = 0;
       clr.w     D4
; unsigned char cchar, vdisp = 0, vtec;
       clr.b     -1(A6)
; unsigned char *vvarptr = vvar;
       move.l    A3,D2
; if (vtipo == WINOPER)
       move.b    27(A6),D0
       cmp.b     #1,D0
       bne       fillin_9
; {
; while (*vvarptr)
fillin_3:
       move.l    D2,A0
       tst.b     (A0)
       beq.s     fillin_5
; {
; cc += 6;
       addq.w    #6,D4
; *vvarptr++;
       move.l    D2,A0
       addq.l    #1,D2
       bra       fillin_3
fillin_5:
; }
; vtec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,D5
; if (vtec >= 0x20 && vtec < 0x7F && (x + cc + 6) < (x + pwidth))
       cmp.b     #32,D5
       blo       fillin_6
       cmp.b     #127,D5
       bhs       fillin_6
       move.w    D3,D0
       add.w     D4,D0
       addq.w    #6,D0
       move.w    D3,D1
       add.w     D7,D1
       cmp.w     D1,D0
       bhs       fillin_6
; {
; *vvarptr++ = vtec;
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D5,(A0)
; *vvarptr = 0x00;
       move.l    D2,A0
       clr.b     (A0)
; locatexy(x+cc,y+1);
       move.w    D6,D1
       addq.w    #1,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     D4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; writecxy(6, vtec, vcorwf, vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       pea       6
       jsr       (A4)
       add.w     #16,A7
; vdisp = 1;
       move.b    #1,-1(A6)
       bra       fillin_9
fillin_6:
; }
; else
; {
; switch (vtec)
       and.l     #255,D5
       cmp.l     #13,D5
       beq.s     fillin_10
       bhi       fillin_9
       cmp.l     #8,D5
       beq.s     fillin_11
       bra       fillin_9
fillin_10:
; {
; case 0x0D:  // Enter
; break;
       bra       fillin_9
fillin_11:
; case 0x08:  // BackSpace
; if (pposx > (x + 10))
       move.w    D3,D0
       add.w     #10,D0
       cmp.w     _pposx.L,D0
       bhs       fillin_12
; {
; *vvarptr = '\0';
       move.l    D2,A0
       clr.b     (A0)
; vvarptr--;
       subq.l    #1,D2
; if (vvarptr < vvar)
       cmp.l     A3,D2
       bhs.s     fillin_14
; vvarptr = vvar;
       move.l    A3,D2
fillin_14:
; *vvarptr = '\0';
       move.l    D2,A0
       clr.b     (A0)
; pposx = pposx - 6;
       subq.w    #6,_pposx.L
; FillRect(pposx, (pposy - 1), 6, 9, vcorwb);
       move.b    _vcorwb.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       9
       pea       6
       move.w    _pposy.L,D1
       subq.w    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _pposx.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; locatexy(pposx,pposy);
       move.w    _pposy.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _pposx.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; writecxy(6, 0xFF, vcorwf, vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       255
       pea       6
       jsr       (A4)
       add.w     #16,A7
; pposx = pposx - 6;
       subq.w    #6,_pposx.L
fillin_12:
; }
; break;
fillin_9:
; }
; }
; }
; if (vtipo == WINDISP || vdisp)
       move.b    27(A6),D0
       beq.s     fillin_18
       move.b    -1(A6),D0
       and.l     #255,D0
       beq       fillin_23
fillin_18:
; {
; if (!vdisp)
       tst.b     -1(A6)
       bne       fillin_19
; {
; FillRect(x-2,y-2,pwidth+4,13,vcorwb);
       move.b    _vcorwb.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       13
       move.w    D7,D1
       addq.w    #4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D6,D1
       subq.w    #2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       subq.w    #2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; DrawRect(x-2,y-2,pwidth+4,13,vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       13
       move.w    D7,D1
       addq.w    #4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D6,D1
       subq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       subq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _DrawRect
       add.w     #20,A7
fillin_19:
; }
; vvarptr = vvar;
       move.l    A3,D2
; cc = 0;
       clr.w     D4
; while (*vvarptr)
fillin_21:
       move.l    D2,A0
       tst.b     (A0)
       beq       fillin_23
; {
; cchar = *vvarptr++;
       move.l    D2,A0
       addq.l    #1,D2
       move.b    (A0),-2(A6)
; cc += 6;
       addq.w    #6,D4
; locatexy(x+cc,y+1);
       move.w    D6,D1
       addq.w    #1,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     D4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; writecxy(6, cchar, vcorwf, vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    -2(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       6
       jsr       (A4)
       add.w     #16,A7
; if (pposx >= x + pwidth)
       move.w    D3,D0
       add.w     D7,D0
       cmp.w     _pposx.L,D0
       bhi.s     fillin_24
; break;
       bra.s     fillin_23
fillin_24:
       bra       fillin_21
fillin_23:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; }
; //-------------------------------------------------------------------------
; void radioset(unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo)
; {
       xdef      _radioset
_radioset:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3,-(A7)
       move.w    22(A6),D5
       and.l     #65535,D5
       move.w    18(A6),D6
       lea       _vcorwf.L,A2
       lea       _DrawCircle.L,A3
; unsigned char cc, xc;
; unsigned char cchar, vdisp = 0;
       moveq     #0,D7
; xc = 0;
       clr.b     D2
; cc = 0;
       clr.b     D4
; cchar = ' ';
       moveq     #32,D3
; while(vtipo == WINOPER && cchar != '\0') {
radioset_1:
       move.b    27(A6),D0
       cmp.b     #1,D0
       bne       radioset_3
       tst.b     D3
       beq       radioset_3
; cchar = vopt[cc];
       move.l    8(A6),A0
       and.l     #255,D4
       move.b    0(A0,D4.L),D3
; if (cchar == ',') {
       cmp.b     #44,D3
       bne       radioset_8
; if (cchar == ',' && cc != 0)
       cmp.b     #44,D3
       bne.s     radioset_6
       tst.b     D4
       beq.s     radioset_6
; xc++;
       addq.b    #1,D2
radioset_6:
; if (vpostx >= x && vpostx <= x + 8 && vposty >= (y + (xc * 10)) && vposty <= ((y + (xc * 10)) + 8)) {
       cmp.w     _vpostx.L,D6
       bhi       radioset_8
       move.w    D6,D0
       addq.w    #8,D0
       cmp.w     _vpostx.L,D0
       blo       radioset_8
       move.w    D5,D0
       move.b    D2,D1
       and.w     #255,D1
       mulu.w    #10,D1
       and.w     #255,D1
       add.w     D1,D0
       cmp.w     _vposty.L,D0
       bhi.s     radioset_8
       move.w    D5,D0
       move.b    D2,D1
       and.w     #255,D1
       mulu.w    #10,D1
       and.w     #255,D1
       add.w     D1,D0
       addq.w    #8,D0
       cmp.w     _vposty.L,D0
       blo.s     radioset_8
; vvar[0] = xc;
       move.l    12(A6),A0
       move.b    D2,(A0)
; vdisp = 1;
       moveq     #1,D7
radioset_8:
; }
; }
; cc++;
       addq.b    #1,D4
       bra       radioset_1
radioset_3:
; }
; xc = 0;
       clr.b     D2
; cc = 0;
       clr.b     D4
; while(vtipo == WINDISP || vdisp) {
radioset_10:
       move.b    27(A6),D0
       beq.s     radioset_13
       and.l     #255,D7
       beq       radioset_12
radioset_13:
; cchar = vopt[cc];
       move.l    8(A6),A0
       and.l     #255,D4
       move.b    0(A0,D4.L),D3
; if (cchar == ',') {
       cmp.b     #44,D3
       bne       radioset_14
; if (cchar == ',' && cc != 0)
       cmp.b     #44,D3
       bne.s     radioset_16
       tst.b     D4
       beq.s     radioset_16
; xc++;
       addq.b    #1,D2
radioset_16:
; FillRect(x, y + (xc * 10), 8, 8, vcorwb);
       move.b    _vcorwb.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       pea       8
       move.w    D5,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #10,D0
       and.w     #255,D0
       add.w     D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; DrawCircle(x + 4, y + (xc * 10) + 2, 4, 0, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       pea       4
       move.w    D5,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #10,D0
       and.w     #255,D0
       add.w     D0,D1
       move.l    (A7)+,D0
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D6,D1
       addq.w    #4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #20,A7
; if (vvar[0] == xc)
       move.l    12(A6),A0
       cmp.b     (A0),D2
       bne       radioset_18
; DrawCircle(x + 4, y + (xc * 10) + 2, 3, 1, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       1
       pea       3
       move.w    D5,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #10,D0
       and.w     #255,D0
       add.w     D0,D1
       move.l    (A7)+,D0
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D6,D1
       addq.w    #4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #20,A7
       bra       radioset_19
radioset_18:
; else
; DrawCircle(x + 4, y + (xc * 10) + 2, 3, 0, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       pea       3
       move.w    D5,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #10,D0
       and.w     #255,D0
       add.w     D0,D1
       move.l    (A7)+,D0
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D6,D1
       addq.w    #4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #20,A7
radioset_19:
; locatexy(x + 10, y + (xc * 10));
       move.w    D5,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #10,D0
       and.w     #255,D0
       add.w     D0,D1
       move.l    (A7)+,D0
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D6,D1
       add.w     #10,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _locatexy
       addq.w    #8,A7
radioset_14:
; }
; if (cchar != ',' && cchar != '\0')
       cmp.b     #44,D3
       beq.s     radioset_20
       tst.b     D3
       beq.s     radioset_20
; writecxy(6, cchar, vcorwf, vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       pea       6
       jsr       _writecxy
       add.w     #16,A7
radioset_20:
; if (cchar == '\0')
       tst.b     D3
       bne.s     radioset_22
; break;
       bra.s     radioset_12
radioset_22:
; cc++;
       addq.b    #1,D4
       bra       radioset_10
radioset_12:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3
       unlk      A6
       rts
; }
; }
; //-------------------------------------------------------------------------
; void togglebox(unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo)
; {
       xdef      _togglebox
_togglebox:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7/A2,-(A7)
       move.w    18(A6),D2
       move.w    22(A6),D3
       and.l     #65535,D3
       lea       _vcorwf.L,A2
       move.l    12(A6),D4
       move.b    27(A6),D6
       and.l     #255,D6
; unsigned char cc = 0;
       clr.b     D5
; unsigned char cchar, vdisp = 0;
       moveq     #0,D7
; if (vtipo == WINOPER && vpostx >= x && vpostx <= x + 4 && vposty >= y && vposty <= y + 4)
       cmp.b     #1,D6
       bne       togglebox_1
       cmp.w     _vpostx.L,D2
       bhi       togglebox_1
       move.w    D2,D0
       addq.w    #4,D0
       cmp.w     _vpostx.L,D0
       blo.s     togglebox_1
       cmp.w     _vposty.L,D3
       bhi.s     togglebox_1
       move.w    D3,D0
       addq.w    #4,D0
       cmp.w     _vposty.L,D0
       blo.s     togglebox_1
; {
; if (vvar[0])
       move.l    D4,A0
       tst.b     (A0)
       beq.s     togglebox_3
; vvar[0] = 0;
       move.l    D4,A0
       clr.b     (A0)
       bra.s     togglebox_4
togglebox_3:
; else
; vvar[0] = 1;
       move.l    D4,A0
       move.b    #1,(A0)
togglebox_4:
; vdisp = 1;
       moveq     #1,D7
togglebox_1:
; }
; if (vtipo == WINDISP || vdisp)
       tst.b     D6
       beq.s     togglebox_7
       and.l     #255,D7
       beq       togglebox_14
togglebox_7:
; {
; FillRect(x, y + 2, 4, 4, vcorwb);
       move.b    _vcorwb.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       4
       pea       4
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; DrawRect(x, y + 2, 4, 4, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       4
       pea       4
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       jsr       _DrawRect
       add.w     #20,A7
; if (vvar[0]) {
       move.l    D4,A0
       tst.b     (A0)
       beq       togglebox_8
; DrawLine(x, y + 2, x + 4, y + 6, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       addq.w    #6,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       addq.w    #4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       jsr       _DrawLine
       add.w     #20,A7
; DrawLine(x, y + 6, x + 4, y + 2, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       addq.w    #4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       addq.w    #6,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       jsr       _DrawLine
       add.w     #20,A7
togglebox_8:
; }
; if (vtipo == WINDISP) {
       tst.b     D6
       bne       togglebox_14
; x += 6;
       addq.w    #6,D2
; locatexy(x,y);
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       jsr       _locatexy
       addq.w    #8,A7
; while (bstr[cc] != 0)
togglebox_12:
       move.l    8(A6),A0
       and.l     #255,D5
       move.b    0(A0,D5.L),D0
       beq       togglebox_14
; {
; cchar = bstr[cc];
       move.l    8(A6),A0
       and.l     #255,D5
       move.b    0(A0,D5.L),-1(A6)
; cc++;
       addq.b    #1,D5
; writecxy(6, cchar, vcorwf, vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    -1(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       6
       jsr       _writecxy
       add.w     #16,A7
; x += 6;
       addq.w    #6,D2
       bra       togglebox_12
togglebox_14:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2
       unlk      A6
       rts
; }
; }
; }
; }
; //-----------------------------------------------------------------------------
; void SelRect(unsigned short x, unsigned short y, unsigned short pwidth, unsigned short pheight)
; {
       xdef      _SelRect
_SelRect:
       link      A6,#0
; DrawRect((x - 1), (y - 1), (pwidth + 2), (pheight + 2), VDP_DARK_RED);
       pea       6
       move.w    22(A6),D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    18(A6),D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    14(A6),D1
       subq.w    #1,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    10(A6),D1
       subq.w    #1,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _DrawRect
       add.w     #20,A7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void PutIcone(unsigned int* vimage, unsigned short x, unsigned short y, unsigned char numSprite)
; {
       xdef      _PutIcone
_PutIcone:
       link      A6,#0
       unlk      A6
       rts
; // TBD
; }
; //-----------------------------------------------------------------------------
; void PutImage(unsigned char* cimage, unsigned short x, unsigned short y)
; {
       xdef      _PutImage
_PutImage:
       link      A6,#0
       unlk      A6
       rts
; // TBD
; }
; //-----------------------------------------------------------------------------
; void LoadIconLib(unsigned char* cfile)
; {
       xdef      _LoadIconLib
_LoadIconLib:
       link      A6,#0
       unlk      A6
       rts
; // TBD
; }
; void vdp_read_data_gui(unsigned int addr, unsigned int startaddr, unsigned int qtd)
; {
       xdef      _vdp_read_data_gui
_vdp_read_data_gui:
       link      A6,#-4
; int ix;
; setReadAddress(addr);
       move.l    8(A6),-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(addr);
       move.l    8(A6),-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
       unlk      A6
       rts
; /**(tempDataBase + startaddr) = addr;
; for (ix = 0; ix < qtd; ix++)
; *(tempDataMgui2 + startaddr + ix) = *vvdgd;*/
; }
; //-----------------------------------------------------------------------------
; unsigned char read_status_reg_gui(void)
; {
       xdef      _read_status_reg_gui
_read_status_reg_gui:
       link      A6,#-4
; unsigned char memByte;
; memByte = *vvdgc;
       move.l    _vvdgc.L,A0
       move.b    (A0),-1(A6)
; return memByte;
       move.b    -1(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void startMGI(void) {
       xdef      _startMGI
_startMGI:
       link      A6,#-40
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _vcorwb.L,A2
       lea       _vcorwf.L,A3
       lea       _writesxy.L,A4
       lea       _imgsMenuSys.L,A5
; unsigned char vnomefile[12];
; unsigned char lc, ll, *ptr_ico, *ptr_prg, *ptr_pos;
; unsigned char* vLoadImage = 0x00;
       clr.l     D2
; int percent;
; long ix;
; VDP_COLOR cores;
; VDP_COORD cursor;
; unsigned int error_code = OS_ERR_NONE;
       clr.l     -4(A6)
; OSTaskSuspend(TASK_MMSJOS_MAIN);
       pea       10
       jsr       _OSTaskSuspend
       addq.w    #4,A7
; cursor = vdp_get_cursor();
       pea       -8(A6)
       move.l    1170,A1
       jsr       (A1)
       move.l    (A7)+,A0
       move.l    D0,A1
       move.l    (A1)+,(A0)+
; //cores = vdp_get_color();
; mguiVideoFontes = getVideoFontes();
       move.l    1202,A0
       jsr       (A0)
       move.l    D0,_mguiVideoFontes.L
; vxgmax = cursor.maxx;
       lea       -8(A6),A0
       move.b    2(A0),D0
       and.w     #255,D0
       move.w    D0,_vxgmax.L
; vcorwf = VDP_WHITE;
       move.b    #15,(A3)
; vcorwb = VDP_TRANSPARENT;
       clr.b     (A2)
; vcorwb2 = VDP_DARK_BLUE;
       move.b    #4,_vcorwb2.L
; vdp_init(VDP_MODE_G2, VDP_DARK_BLUE, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       pea       4
       pea       1
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_set_bdcolor(VDP_DARK_BLUE);
       pea       4
       move.l    1110,A0
       jsr       (A0)
       addq.w    #4,A7
; fgcolorMgui = VDP_WHITE; // cores.fg;
       move.b    #15,_fgcolorMgui.L
; bgcolorMgui = VDP_DARK_BLUE; // cores.bg;
       move.b    #4,_bgcolorMgui.L
; vdp_get_cfg(&mgui_pattern_table, &mgui_color_table);
       pea       _mgui_color_table.L
       pea       _mgui_pattern_table.L
       move.l    1182,A0
       jsr       (A0)
       addq.w    #8,A7
; vLoadImage = malloc(SIZE_LOAD_IMAGE_MEM);
       pea       8192
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,D2
; loadFile("/MGUI/IMAGES/UTILITY.PBM", (unsigned long*)vLoadImage);
       move.l    D2,-(A7)
       pea       @mgui_1.L
       jsr       _loadFile
       addq.w    #8,A7
; putImagePbmP4((unsigned long*)vLoadImage, 8, 1);
       pea       1
       pea       8
       move.l    D2,-(A7)
       jsr       _putImagePbmP4
       add.w     #12,A7
; free(vLoadImage);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
; writesxy(116,130,2,"MGUI",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_2.L
       pea       2
       pea       130
       pea       116
       jsr       (A4)
       add.w     #24,A7
; writesxy(71,140,1,"Graphical",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_3.L
       pea       1
       pea       140
       pea       71
       jsr       (A4)
       add.w     #24,A7
; writesxy(131,140,1,"Interface",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_4.L
       pea       1
       pea       140
       pea       131
       jsr       (A4)
       add.w     #24,A7
; writesxy(105,150,1,"v"versionMgui,vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_5.L
       pea       1
       pea       150
       pea       105
       jsr       (A4)
       add.w     #24,A7
; writesxy(86,170,1,"Loading Config",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_6.L
       pea       1
       pea       170
       pea       86
       jsr       (A4)
       add.w     #24,A7
; loadFile("/MGUI/MGUI.CFG", memPosConfig);
       move.b    _memPosConfig.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mgui_7.L
       jsr       _loadFile
       addq.w    #8,A7
; writesxy(53,170,1,"Loading Icons ",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_8.L
       pea       1
       pea       170
       pea       53
       jsr       (A4)
       add.w     #24,A7
; imgsMenuSys = malloc(SIZE_LOAD_ICONS_MEM);
       pea       8192
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,(A5)
; writesxy(137,170,1,"ICOFOLD.PBM",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_9.L
       pea       1
       pea       170
       pea       137
       jsr       (A4)
       add.w     #24,A7
; loadFile("/MGUI/IMAGES/ICOFOLD.PBM", imgsMenuSys);
       move.l    (A5),-(A7)
       pea       @mgui_10.L
       jsr       _loadFile
       addq.w    #8,A7
; writesxy(137,170,1,"ICORUN.PBM ",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_11.L
       pea       1
       pea       170
       pea       137
       jsr       (A4)
       add.w     #24,A7
; loadFile("/MGUI/IMAGES/ICORUN.PBM", (imgsMenuSys + 64));
       move.l    (A5),D1
       add.l     #64,D1
       move.l    D1,-(A7)
       pea       @mgui_12.L
       jsr       _loadFile
       addq.w    #8,A7
; writesxy(137,170,1,"ICOOS.PBM  ",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_13.L
       pea       1
       pea       170
       pea       137
       jsr       (A4)
       add.w     #24,A7
; loadFile("/MGUI/IMAGES/ICOOS.PBM", (imgsMenuSys + 128));
       move.l    (A5),D1
       add.l     #128,D1
       move.l    D1,-(A7)
       pea       @mgui_14.L
       jsr       _loadFile
       addq.w    #8,A7
; writesxy(137,170,1,"ICOSET.PBM ",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_15.L
       pea       1
       pea       170
       pea       137
       jsr       (A4)
       add.w     #24,A7
; loadFile("/MGUI/IMAGES/ICOSET.PBM", (imgsMenuSys + 192));
       move.l    (A5),D1
       add.l     #192,D1
       move.l    D1,-(A7)
       pea       @mgui_16.L
       jsr       _loadFile
       addq.w    #8,A7
; writesxy(137,170,1,"ICOOFF.PBM ",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_17.L
       pea       1
       pea       170
       pea       137
       jsr       (A4)
       add.w     #24,A7
; loadFile("/MGUI/IMAGES/ICOOFF.PBM", (imgsMenuSys + 256));
       move.l    (A5),D1
       add.l     #256,D1
       move.l    D1,-(A7)
       pea       @mgui_18.L
       jsr       _loadFile
       addq.w    #8,A7
; writesxy(53,170,1,"      Please Wait...       ",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_19.L
       pea       1
       pea       170
       pea       53
       jsr       (A4)
       add.w     #24,A7
; for (ix = 0; ix < 99999; ix++);
       clr.l     D3
startMGI_1:
       cmp.l     #99999,D3
       bge.s     startMGI_3
       addq.l    #1,D3
       bra       startMGI_1
startMGI_3:
; vcorwf = VDP_WHITE;
       move.b    #15,(A3)
; vcorwb = VDP_TRANSPARENT;
       clr.b     (A2)
; vcorwb2 = VDP_BLACK;
       move.b    #1,_vcorwb2.L
; vdp_init(VDP_MODE_G2, VDP_BLACK, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       pea       1
       pea       1
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_set_bdcolor(VDP_BLACK);
       pea       1
       move.l    1110,A0
       jsr       (A0)
       addq.w    #4,A7
; mouseX = 128;
       move.l    #128,_mouseX.L
; mouseY = 96;
       move.b    #96,_mouseY.L
; redrawMain();
       jsr       _redrawMain
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; spthdlmouse = vdp_sprite_init(0, 0, VDP_DARK_RED);
       pea       6
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    1150,A0
       jsr       (A0)
       add.w     #12,A7
       move.l    D0,_spthdlmouse.L
; statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);
       move.b    _mouseY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    _mouseX.L,-(A7)
       move.l    _spthdlmouse.L,-(A7)
       move.l    1154,A0
       jsr       (A0)
       add.w     #12,A7
       move.b    D0,_statusVdpSprite.L
; OSTaskCreate(mouseTask, OS_NULL, &StkMouse[STACKSIZEMOUSE], TASK_MGUI_MOUSE);
       pea       12
       lea       _StkMouse.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _mouseTask.L
       jsr       _OSTaskCreate
       add.w     #16,A7
; vIndicaDialog = 0;
       clr.b     _vIndicaDialog.L
; // Inicia Controles de Tela (Mouse e Teclado)
; while(1)
startMGI_4:
; {
; if (vIndicaDialog)
       tst.b     _vIndicaDialog.L
       beq.s     startMGI_7
; OSTaskSuspend(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskSuspend
       addq.w    #4,A7
startMGI_7:
; if (!editortela())
       jsr       _editortela
       tst.b     D0
       bne.s     startMGI_9
; break;
       bra.s     startMGI_6
startMGI_9:
; OSTimeDlyHMSM(0, 0, 0, 15);
       pea       15
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       startMGI_4
startMGI_6:
; }
; free(imgsMenuSys);
       move.l    (A5),-(A7)
       jsr       _free
       addq.w    #4,A7
; vdp_init(VDP_MODE_TEXT, VDP_BLACK, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       pea       1
       pea       3
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_textcolor(VDP_WHITE, VDP_BLACK);
       pea       1
       pea       15
       move.l    1126,A0
       jsr       (A0)
       addq.w    #8,A7
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; OSTaskDel(TASK_MGUI_MOUSE);
       pea       12
       jsr       _OSTaskDel
       addq.w    #4,A7
; printText("Ok\r\n\0");
       pea       @mgui_20.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("#>");
       pea       @mgui_21.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; showCursor();
       move.l    1082,A0
       jsr       (A0)
; OSTaskResume(TASK_MMSJOS_MAIN);
       pea       10
       jsr       _OSTaskResume
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; void mouseTask (void *pData)
; {
       xdef      _mouseTask
_mouseTask:
       link      A6,#-4
       movem.l   D2/A2,-(A7)
       lea       _mouseBtnPresDouble.L,A2
; unsigned char valter;
; unsigned char timeToDoubleClick = 0xFF;
       move.b    #255,D2
; mouseBtnPresDouble = 0;
       clr.b     (A2)
; while(1)
mouseTask_1:
; {
; if (readMouse(&mouseStat, &mouseMoveX, &mouseMoveY))
       pea       _mouseMoveY.L
       pea       _mouseMoveX.L
       pea       _mouseStat.L
       move.l    1206,A0
       jsr       (A0)
       add.w     #12,A7
       tst.b     D0
       beq       mouseTask_8
; {
; VerifyMouse();
       jsr       _VerifyMouse
; if (mouseBtnPres == 0x01 && timeToDoubleClick == 0xFF)
       move.b    _mouseBtnPres.L,D0
       cmp.b     #1,D0
       bne.s     mouseTask_6
       and.w     #255,D2
       cmp.w     #255,D2
       bne.s     mouseTask_6
; {
; mouseBtnPresDouble = 0;
       clr.b     (A2)
; timeToDoubleClick = 0;
       clr.b     D2
mouseTask_6:
; }
; if (mouseBtnPres == 0x01 && timeToDoubleClick > 0 && timeToDoubleClick <= 34)
       move.b    _mouseBtnPres.L,D0
       cmp.b     #1,D0
       bne.s     mouseTask_8
       cmp.b     #0,D2
       bls.s     mouseTask_8
       cmp.b     #34,D2
       bhi.s     mouseTask_8
; mouseBtnPresDouble = 1;
       move.b    #1,(A2)
mouseTask_8:
; }
; if (mouseBtnPres == 0x00 && timeToDoubleClick != 0xFF)
       move.b    _mouseBtnPres.L,D0
       bne.s     mouseTask_10
       and.w     #255,D2
       cmp.w     #255,D2
       beq.s     mouseTask_10
; timeToDoubleClick = timeToDoubleClick + 1;
       addq.b    #1,D2
mouseTask_10:
; if (timeToDoubleClick > 34 && timeToDoubleClick != 0xFF)
       cmp.b     #34,D2
       bls.s     mouseTask_12
       and.w     #255,D2
       cmp.w     #255,D2
       beq.s     mouseTask_12
; {
; timeToDoubleClick = 0xFF;
       move.b    #255,D2
; mouseBtnPresDouble = 0;
       clr.b     (A2)
mouseTask_12:
; }
; OSTimeDlyHMSM(0, 0, 0, 15);
       pea       15
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       mouseTask_1
; }
; }
; //-------------------------------------------------------------------------
; void showWindow(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton)
; {
       xdef      _showWindow
_showWindow:
       link      A6,#-44
       movem.l   D2/D3/D4/A2,-(A7)
       move.b    15(A6),D2
       and.l     #255,D2
       move.b    19(A6),D3
       and.l     #255,D3
       move.w    22(A6),D4
       and.l     #65535,D4
       lea       _vcorwf.L,A2
; unsigned short i, ii, xib, yib;
; unsigned char cc = 0;
       clr.b     -36(A6)
; unsigned char vbbutton;
; unsigned char vbuttonwin[32];
; unsigned short vbuttonwiny;
; // Desenha a Janela
; DrawRect(x1, y1, pwidth, pheight, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    27(A6),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D4
       move.l    D4,-(A7)
       and.w     #255,D3
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.w     #255,D2
       and.l     #65535,D2
       move.l    D2,-(A7)
       jsr       _DrawRect
       add.w     #20,A7
; FillRect(x1 + 1, y1 + 1, pwidth - 2, pheight - 2, vcorwb);
       move.b    _vcorwb.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    27(A6),D1
       subq.b    #2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    D4,D1
       subq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    D3,D1
       addq.b    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D2,D1
       addq.b    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; if (*bstr) {
       move.l    8(A6),A0
       tst.b     (A0)
       beq       showWindow_1
; DrawRect(x1, y1, pwidth, 12, vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       12
       and.l     #65535,D4
       move.l    D4,-(A7)
       and.w     #255,D3
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.w     #255,D2
       and.l     #65535,D2
       move.l    D2,-(A7)
       jsr       _DrawRect
       add.w     #20,A7
; writesxy(x1 + 2, y1 + 3,1,bstr,vcorwf,vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    8(A6),-(A7)
       pea       1
       move.b    D3,D1
       addq.b    #3,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    D2,D1
       addq.b    #2,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _writesxy
       add.w     #24,A7
showWindow_1:
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; /*i = 1;
; for (ii = 0; ii <= 7; ii++)
; vbuttonwin[ii] = 0;
; // Desenha Botoes
; vbbutton = bbutton;
; while (vbbutton)
; {
; xib = x1 + 8 + (34 * (i - 1));
; yib = (y1 + pheight) - 12;
; vbuttonwiny = yib;
; i++;
; drawButtonsnew(&vbuttonwin, &vbbutton, xib, yib);
; }*/
; }
; //-------------------------------------------------------------------------
; void drawButtonsnew(unsigned char *vbuttonswin, unsigned char *pbbutton, unsigned short xib, unsigned short yib)
; {
       xdef      _drawButtonsnew
_drawButtonsnew:
       link      A6,#0
       movem.l   D2/D3/D4/D5/A2/A3,-(A7)
       move.l    12(A6),D2
       move.w    18(A6),D3
       move.w    22(A6),D4
       and.l     #65535,D4
       move.l    8(A6),D5
       lea       _vcorwb.L,A2
       lea       _writesxy.L,A3
; // Desenha Bot?
; //FillRect(xib, yib, 42, 10, VDP_WHITE);
; DrawRoundRect(xib,yib,32,10,1,vcorwf);  // rounded rectangle around text area
       move.b    _vcorwf.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       pea       10
       pea       32
       and.l     #65535,D4
       move.l    D4,-(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       jsr       _DrawRoundRect
       add.w     #24,A7
; // Escreve Texto do Bot?
; if (*pbbutton & BTOK)
       move.l    D2,A0
       move.b    (A0),D0
       and.b     #1,D0
       beq       drawButtonsnew_1
; {
; writesxy(xib + 16 - 6, yib + 2,1,"OK",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_22.L
       pea       1
       move.w    D4,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     #16,D1
       subq.w    #6,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #24,A7
; *pbbutton = *pbbutton & 0xFE;    // 0b11111110
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #254,D0
       move.l    D2,A0
       move.b    D0,(A0)
; vbuttonswin[1] = xib;
       move.l    D5,A0
       move.b    D3,1(A0)
       bra       drawButtonsnew_13
drawButtonsnew_1:
; }
; else if (*pbbutton & BTSTART)
       move.l    D2,A0
       move.b    (A0),D0
       and.b     #32,D0
       beq       drawButtonsnew_3
; {
; writesxy(xib + 16 - 15, yib + 2,1,"START",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_23.L
       pea       1
       move.w    D4,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     #16,D1
       sub.w     #15,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #24,A7
; *pbbutton = *pbbutton & 0xDF;    // 0b11011111
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #223,D0
       move.l    D2,A0
       move.b    D0,(A0)
; vbuttonswin[6] = xib;
       move.l    D5,A0
       move.b    D3,6(A0)
       bra       drawButtonsnew_13
drawButtonsnew_3:
; }
; else if (*pbbutton & BTCLOSE)
       move.l    D2,A0
       move.b    (A0),D0
       and.b     #64,D0
       beq       drawButtonsnew_5
; {
; writesxy(xib + 16 - 15, yib + 2,1,"CLOSE",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_24.L
       pea       1
       move.w    D4,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     #16,D1
       sub.w     #15,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #24,A7
; *pbbutton = *pbbutton & 0xBF;    // 0b10111111
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #191,D0
       move.l    D2,A0
       move.b    D0,(A0)
; vbuttonswin[7] = xib;
       move.l    D5,A0
       move.b    D3,7(A0)
       bra       drawButtonsnew_13
drawButtonsnew_5:
; }
; else if (*pbbutton & BTCANCEL)
       move.l    D2,A0
       move.b    (A0),D0
       and.b     #2,D0
       beq       drawButtonsnew_7
; {
; writesxy(xib + 16 - 12, yib + 2,1,"CANC",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_25.L
       pea       1
       move.w    D4,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     #16,D1
       sub.w     #12,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #24,A7
; *pbbutton = *pbbutton & 0xFD;    // 0b11111101
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #253,D0
       move.l    D2,A0
       move.b    D0,(A0)
; vbuttonswin[2] = xib;
       move.l    D5,A0
       move.b    D3,2(A0)
       bra       drawButtonsnew_13
drawButtonsnew_7:
; }
; else if (*pbbutton & BTYES)
       move.l    D2,A0
       move.b    (A0),D0
       and.b     #4,D0
       beq       drawButtonsnew_9
; {
; writesxy(xib + 16 - 9, yib + 2,1,"YES",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_26.L
       pea       1
       move.w    D4,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     #16,D1
       sub.w     #9,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #24,A7
; *pbbutton = *pbbutton & 0xFB;    // 0b11111011
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #251,D0
       move.l    D2,A0
       move.b    D0,(A0)
; vbuttonswin[3] = xib;
       move.l    D5,A0
       move.b    D3,3(A0)
       bra       drawButtonsnew_13
drawButtonsnew_9:
; }
; else if (*pbbutton & BTNO)
       move.l    D2,A0
       move.b    (A0),D0
       and.b     #8,D0
       beq       drawButtonsnew_11
; {
; writesxy(xib + 16 - 6, yib + 2,1,"NO",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_27.L
       pea       1
       move.w    D4,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     #16,D1
       subq.w    #6,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #24,A7
; *pbbutton = *pbbutton & 0xF7;    // 0b11110111
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #247,D0
       move.l    D2,A0
       move.b    D0,(A0)
; vbuttonswin[4] = xib;
       move.l    D5,A0
       move.b    D3,4(A0)
       bra       drawButtonsnew_13
drawButtonsnew_11:
; }
; else if (*pbbutton & BTHELP)
       move.l    D2,A0
       move.b    (A0),D0
       and.b     #16,D0
       beq       drawButtonsnew_13
; {
; writesxy(xib + 16 - 12, yib + 2,1,"HELP",vcorwf,vcorwb);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_28.L
       pea       1
       move.w    D4,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D3,D1
       add.w     #16,D1
       sub.w     #12,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #24,A7
; *pbbutton = *pbbutton & 0xEF;    // 0b11101111
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #239,D0
       move.l    D2,A0
       move.b    D0,(A0)
; vbuttonswin[5] = xib;
       move.l    D5,A0
       move.b    D3,5(A0)
drawButtonsnew_13:
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3
       unlk      A6
       rts
; }
; }
; //-------------------------------------------------------------------------
; void drawButtons(unsigned short xib, unsigned short yib) {
       xdef      _drawButtons
_drawButtons:
       link      A6,#0
       movem.l   D2/D3/A2/A3/A4,-(A7)
       move.w    10(A6),D2
       move.w    14(A6),D3
       and.l     #65535,D3
       lea       _vbuttonwin.L,A2
       lea       _vcorwb.L,A3
       lea       _writesxy.L,A4
; // Desenha Bot?
; //FillRect(xib, yib, 42, 10, VDP_WHITE);
; DrawRoundRect(xib,yib,32,10,1,vcorwf);  // rounded rectangle around text area
       move.b    _vcorwf.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       pea       10
       pea       32
       and.l     #65535,D3
       move.l    D3,-(A7)
       and.l     #65535,D2
       move.l    D2,-(A7)
       jsr       _DrawRoundRect
       add.w     #24,A7
; // Escreve Texto do Bot?
; if (vbbutton & BTOK)
       move.b    _vbbutton.L,D0
       and.b     #1,D0
       beq       drawButtons_1
; {
; writesxy(xib + 16 - 6, yib + 2,1,"OK",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_22.L
       pea       1
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       add.w     #16,D1
       subq.w    #6,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #24,A7
; vbbutton = vbbutton & 0xFE;    // 0b11111110
       move.b    _vbbutton.L,D0
       and.w     #255,D0
       and.w     #254,D0
       move.b    D0,_vbbutton.L
; vbuttonwin[1] = xib;
       move.b    D2,1(A2)
       bra       drawButtons_13
drawButtons_1:
; }
; else if (vbbutton & BTSTART)
       move.b    _vbbutton.L,D0
       and.b     #32,D0
       beq       drawButtons_3
; {
; writesxy(xib + 16 - 15, yib + 2,1,"START",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_23.L
       pea       1
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       add.w     #16,D1
       sub.w     #15,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #24,A7
; vbbutton = vbbutton & 0xDF;    // 0b11011111
       move.b    _vbbutton.L,D0
       and.w     #255,D0
       and.w     #223,D0
       move.b    D0,_vbbutton.L
; vbuttonwin[6] = xib;
       move.b    D2,6(A2)
       bra       drawButtons_13
drawButtons_3:
; }
; else if (vbbutton & BTCLOSE)
       move.b    _vbbutton.L,D0
       and.b     #64,D0
       beq       drawButtons_5
; {
; writesxy(xib + 16 - 15, yib + 2,1,"CLOSE",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_24.L
       pea       1
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       add.w     #16,D1
       sub.w     #15,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #24,A7
; vbbutton = vbbutton & 0xBF;    // 0b10111111
       move.b    _vbbutton.L,D0
       and.w     #255,D0
       and.w     #191,D0
       move.b    D0,_vbbutton.L
; vbuttonwin[7] = xib;
       move.b    D2,7(A2)
       bra       drawButtons_13
drawButtons_5:
; }
; else if (vbbutton & BTCANCEL)
       move.b    _vbbutton.L,D0
       and.b     #2,D0
       beq       drawButtons_7
; {
; writesxy(xib + 16 - 12, yib + 2,1,"CANC",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_25.L
       pea       1
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       add.w     #16,D1
       sub.w     #12,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #24,A7
; vbbutton = vbbutton & 0xFD;    // 0b11111101
       move.b    _vbbutton.L,D0
       and.w     #255,D0
       and.w     #253,D0
       move.b    D0,_vbbutton.L
; vbuttonwin[2] = xib;
       move.b    D2,2(A2)
       bra       drawButtons_13
drawButtons_7:
; }
; else if (vbbutton & BTYES)
       move.b    _vbbutton.L,D0
       and.b     #4,D0
       beq       drawButtons_9
; {
; writesxy(xib + 16 - 9, yib + 2,1,"YES",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_26.L
       pea       1
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       add.w     #16,D1
       sub.w     #9,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #24,A7
; vbbutton = vbbutton & 0xFB;    // 0b11111011
       move.b    _vbbutton.L,D0
       and.w     #255,D0
       and.w     #251,D0
       move.b    D0,_vbbutton.L
; vbuttonwin[3] = xib;
       move.b    D2,3(A2)
       bra       drawButtons_13
drawButtons_9:
; }
; else if (vbbutton & BTNO)
       move.b    _vbbutton.L,D0
       and.b     #8,D0
       beq       drawButtons_11
; {
; writesxy(xib + 16 - 6, yib + 2,1,"NO",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_27.L
       pea       1
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       add.w     #16,D1
       subq.w    #6,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #24,A7
; vbbutton = vbbutton & 0xF7;    // 0b11110111
       move.b    _vbbutton.L,D0
       and.w     #255,D0
       and.w     #247,D0
       move.b    D0,_vbbutton.L
; vbuttonwin[4] = xib;
       move.b    D2,4(A2)
       bra       drawButtons_13
drawButtons_11:
; }
; else if (vbbutton & BTHELP)
       move.b    _vbbutton.L,D0
       and.b     #16,D0
       beq       drawButtons_13
; {
; writesxy(xib + 16 - 12, yib + 2,1,"HELP",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_28.L
       pea       1
       move.w    D3,D1
       addq.w    #2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D2,D1
       add.w     #16,D1
       sub.w     #12,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #24,A7
; vbbutton = vbbutton & 0xEF;    // 0b11101111
       move.b    _vbbutton.L,D0
       and.w     #255,D0
       and.w     #239,D0
       move.b    D0,_vbbutton.L
; vbuttonwin[5] = xib;
       move.b    D2,5(A2)
drawButtons_13:
       movem.l   (A7)+,D2/D3/A2/A3/A4
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void redrawMain(void) {
       xdef      _redrawMain
_redrawMain:
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; bgcolorMgui = VDP_BLACK; // cores.bg;
       move.b    #1,_bgcolorMgui.L
; clearScrW(bgcolorMgui);
       move.b    _bgcolorMgui.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _clearScrW
       addq.w    #4,A7
; // Desenhar Barra Menu Principal / Status
; desenhaMenu();
       jsr       _desenhaMenu
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
       rts
; }
; //-----------------------------------------------------------------------------
; void desenhaMenu(void)
; {
       xdef      _desenhaMenu
_desenhaMenu:
       link      A6,#-12
       movem.l   D2/D3,-(A7)
; unsigned long lc, idx;
; unsigned int vx, vy;
; VDP_COORD cursor;
; cursor = vdp_get_cursor();
       pea       -4(A6)
       move.l    1170,A1
       jsr       (A1)
       move.l    (A7)+,A0
       move.l    D0,A1
       move.l    (A1)+,(A0)+
; vx = COLMENU;
       moveq     #8,D3
; vy = LINMENU;
       move.l    #1,-8(A6)
; for (lc = 0; lc <= 4; lc++)
       clr.l     D2
desenhaMenu_1:
       cmp.l     #4,D2
       bhi       desenhaMenu_3
; {
; idx = lc * 64;
       move.l    D2,-(A7)
       pea       64
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-12(A6)
; putImagePbmP4((imgsMenuSys + idx), vx, vy);
       move.l    -8(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       move.l    _imgsMenuSys.L,D1
       add.l     -12(A6),D1
       move.l    D1,-(A7)
       jsr       _putImagePbmP4
       add.w     #12,A7
; vx += 24;
       add.l     #24,D3
       addq.l    #1,D2
       bra       desenhaMenu_1
desenhaMenu_3:
; /*MostraIcone(vx, vy, lc,vcorwf, vcorwb);
; vx += 16;*/
; }
; DrawLine(0, 20 /*10*/, cursor.maxx, 20 /*10*/, vcorwf);
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       20
       lea       -4(A6),A0
       move.b    2(A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       20
       clr.l     -(A7)
       jsr       _DrawLine
       add.w     #20,A7
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; /*    DrawCircle((*vdpMaxCols - 5), (*vdpMaxRows - 6), 3, 1, VDP_WHITE);
; DrawLine((*vdpMaxCols - 5), (*vdpMaxRows - 10), (*vdpMaxCols - 5), (*vdpMaxRows - 6), VDP_WHITE);*/
; }
; //--------------------------------------------------------------------------
; unsigned char editortela(void)
; {
       xdef      _editortela
_editortela:
       link      A6,#-12
       move.l    D2,-(A7)
; unsigned char vresp = 1, vwb;
       moveq     #1,D2
; unsigned char vx, cc, vpos, vposiconx, vposicony, mpos;
; unsigned char *ptr_prg;
; // Verifica se clicou no simbolo de sair
; if (mouseBtnPres == 0x04) // Meio - Para reiniciar o sprite do mouse que as vezes nao aparece assim que roda o prog
       move.b    _mouseBtnPres.L,D0
       cmp.b     #4,D0
       bne       editortela_1
; {
; //DrawRoundRect(mouseX - 10,mouseY - 10,20,20,2,vcorwf);
; spthdlmouse = vdp_sprite_init(0, 0, VDP_DARK_RED);
       pea       6
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    1150,A0
       jsr       (A0)
       add.w     #12,A7
       move.l    D0,_spthdlmouse.L
; statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);
       move.b    _mouseY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    _mouseX.L,-(A7)
       move.l    _spthdlmouse.L,-(A7)
       move.l    1154,A0
       jsr       (A0)
       add.w     #12,A7
       move.b    D0,_statusVdpSprite.L
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
editortela_1:
; }
; /**(vmfp + Reg_IERA) = 0x60;
; *(vmfp + Reg_IMRA) = 0x60;    */
; if (readChar() == 0x1B)  // ESC
       move.l    1074,A0
       jsr       (A0)
       cmp.b     #27,D0
       bne.s     editortela_3
; vresp = 0x00;
       clr.b     D2
editortela_3:
; if (mouseBtnPres == 0x01)  // Esquerdo
       move.b    _mouseBtnPres.L,D0
       cmp.b     #1,D0
       bne.s     editortela_7
; {
; if (vposty <= 22)
       move.w    _vposty.L,D0
       cmp.w     #22,D0
       bhi.s     editortela_7
; vresp = new_menu();
       jsr       _new_menu
       move.b    D0,D2
editortela_7:
; }
; return vresp;
       move.b    D2,D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; void VerifyMouse(void)
; {
       xdef      _VerifyMouse
_VerifyMouse:
       link      A6,#-12
       move.l    A2,-(A7)
       lea       _mouseX.L,A2
; unsigned char sqtdtam[10];
; /*FillRect(10,160,100,30,VDP_BLACK);
; itoa(mouseStat,sqtdtam,10);
; writesxy(10,160,6,sqtdtam,VDP_WHITE,VDP_BLACK);
; itoa(mouseMoveX,sqtdtam,10);
; writesxy(10,170,6,sqtdtam,VDP_WHITE,VDP_BLACK);
; itoa(mouseMoveY,sqtdtam,10);
; writesxy(10,180,6,sqtdtam,VDP_WHITE,VDP_BLACK);*/
; if (mouseMoveX < -2)
       move.b    _mouseMoveX.L,D0
       cmp.b     #-2,D0
       bge.s     VerifyMouse_1
; mouseMoveX = -2;
       move.b    #-2,_mouseMoveX.L
VerifyMouse_1:
; if (mouseMoveX > 2)
       move.b    _mouseMoveX.L,D0
       cmp.b     #2,D0
       ble.s     VerifyMouse_3
; mouseMoveX = 2;
       move.b    #2,_mouseMoveX.L
VerifyMouse_3:
; if ((mouseMoveX == -2 && mouseX > 1) || (mouseMoveX == 2 && mouseX < 254))
       move.b    _mouseMoveX.L,D0
       cmp.b     #-2,D0
       bne.s     VerifyMouse_8
       move.l    (A2),D0
       cmp.l     #1,D0
       bhi.s     VerifyMouse_7
VerifyMouse_8:
       move.b    _mouseMoveX.L,D0
       cmp.b     #2,D0
       bne.s     VerifyMouse_5
       move.l    (A2),D0
       cmp.l     #254,D0
       bhs.s     VerifyMouse_5
VerifyMouse_7:
; mouseX = mouseX + mouseMoveX;
       move.b    _mouseMoveX.L,D0
       ext.w     D0
       ext.l     D0
       add.l     D0,(A2)
VerifyMouse_5:
; if (mouseX <= 1)
       move.l    (A2),D0
       cmp.l     #1,D0
       bhi.s     VerifyMouse_9
; mouseX = 2;
       move.l    #2,(A2)
VerifyMouse_9:
; if (mouseX >= 254)
       move.l    (A2),D0
       cmp.l     #254,D0
       blo.s     VerifyMouse_11
; mouseX = 253;
       move.l    #253,(A2)
VerifyMouse_11:
; if (mouseMoveY < -2)
       move.b    _mouseMoveY.L,D0
       cmp.b     #-2,D0
       bge.s     VerifyMouse_13
; mouseMoveY = -2;
       move.b    #-2,_mouseMoveY.L
VerifyMouse_13:
; if (mouseMoveY > 2)
       move.b    _mouseMoveY.L,D0
       cmp.b     #2,D0
       ble.s     VerifyMouse_15
; mouseMoveY = 2;
       move.b    #2,_mouseMoveY.L
VerifyMouse_15:
; if ((mouseMoveY == -2 && mouseY > 1) || (mouseMoveY == 2 && mouseY < 190))
       move.b    _mouseMoveY.L,D0
       cmp.b     #-2,D0
       bne.s     VerifyMouse_20
       move.b    _mouseY.L,D0
       cmp.b     #1,D0
       bhi.s     VerifyMouse_19
VerifyMouse_20:
       move.b    _mouseMoveY.L,D0
       cmp.b     #2,D0
       bne.s     VerifyMouse_17
       move.b    _mouseY.L,D0
       and.w     #255,D0
       cmp.w     #190,D0
       bhs.s     VerifyMouse_17
VerifyMouse_19:
; mouseY = mouseY - mouseMoveY;
       move.b    _mouseMoveY.L,D0
       sub.b     D0,_mouseY.L
VerifyMouse_17:
; if (mouseY <= 1)
       move.b    _mouseY.L,D0
       cmp.b     #1,D0
       bhi.s     VerifyMouse_21
; mouseY = 2;
       move.b    #2,_mouseY.L
VerifyMouse_21:
; if (mouseY >= 190)
       move.b    _mouseY.L,D0
       and.w     #255,D0
       cmp.w     #190,D0
       blo.s     VerifyMouse_23
; mouseY = 189;
       move.b    #189,_mouseY.L
VerifyMouse_23:
; mouseBtnPres = mouseStat & 0x07;
       move.b    _mouseStat.L,D0
       and.b     #7,D0
       move.b    D0,_mouseBtnPres.L
; statusVdpSprite = vdp_sprite_set_position(spthdlmouse, mouseX, mouseY);
       move.b    _mouseY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    (A2),-(A7)
       move.l    _spthdlmouse.L,-(A7)
       move.l    1154,A0
       jsr       (A0)
       add.w     #12,A7
       move.b    D0,_statusVdpSprite.L
; if (mouseBtnPres)
       tst.b     _mouseBtnPres.L
       beq.s     VerifyMouse_25
; {
; vpostx = mouseX;
       move.l    (A2),D0
       move.w    D0,_vpostx.L
; vposty = mouseY;
       move.b    _mouseY.L,D0
       and.w     #255,D0
       move.w    D0,_vposty.L
VerifyMouse_25:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; }
; //-------------------------------------------------------------------------
; void setPosPressed(unsigned char vppostx, unsigned char vpposty)
; {
       xdef      _setPosPressed
_setPosPressed:
       link      A6,#0
; vpostx = vppostx;
       move.b    11(A6),D0
       and.w     #255,D0
       move.w    D0,_vpostx.L
; vposty = vpposty;
       move.b    15(A6),D0
       and.w     #255,D0
       move.w    D0,_vposty.L
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; void getMouseData(MGUI_MOUSE *pmouseData)
; {
       xdef      _getMouseData
_getMouseData:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; pmouseData->mouseButton = mouseBtnPres;
       move.l    D2,A0
       move.b    _mouseBtnPres.L,(A0)
; pmouseData->mouseBtnDouble = mouseBtnPresDouble;
       move.l    D2,A0
       move.b    _mouseBtnPresDouble.L,1(A0)
; pmouseData->vpostx = vpostx;
       move.w    _vpostx.L,D0
       move.l    D2,A0
       move.b    D0,4(A0)
; pmouseData->vposty = vposty;
       move.w    _vposty.L,D0
       move.l    D2,A0
       move.b    D0,5(A0)
; pmouseData->mouseX = mouseX;
       move.l    _mouseX.L,D0
       move.l    D2,A0
       move.b    D0,2(A0)
; pmouseData->mouseY = mouseY;
       move.l    D2,A0
       move.b    _mouseY.L,3(A0)
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; void getColorData(MGUI_COLOR *pColor)
; {
       xdef      _getColorData
_getColorData:
       link      A6,#0
; pColor->fg = vcorwf;
       move.l    8(A6),A0
       move.b    _vcorwf.L,(A0)
; pColor->bg = vcorwb;
       move.l    8(A6),A0
       move.b    _vcorwb.L,1(A0)
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char waitButton(void)
; {
       xdef      _waitButton
_waitButton:
       movem.l   D2/D3/D4/A2,-(A7)
       lea       _vbuttonwin.L,A2
; unsigned char i, ii, iii;
; ii = 0;
       clr.b     D3
; if (mouseBtnPres == 0x01)  // Esquerdo
       move.b    _mouseBtnPres.L,D0
       cmp.b     #1,D0
       bne       waitButton_5
; {
; for (i = 1; i <= 7; i++) {
       moveq     #1,D2
waitButton_3:
       cmp.b     #7,D2
       bhi       waitButton_5
; if (vbuttonwin[i] != 0 && vpostx >= vbuttonwin[i] && vpostx <= (vbuttonwin[i] + 32) && vposty >= vbuttonwiny && vposty <= (vbuttonwiny + 10)) {
       and.l     #255,D2
       move.b    0(A2,D2.L),D0
       beq       waitButton_6
       and.l     #255,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       cmp.w     _vpostx.L,D0
       bhi       waitButton_6
       and.l     #255,D2
       move.b    0(A2,D2.L),D0
       add.b     #32,D0
       and.w     #255,D0
       cmp.w     _vpostx.L,D0
       blo       waitButton_6
       move.w    _vposty.L,D0
       cmp.w     _vbuttonwiny.L,D0
       blo.s     waitButton_6
       move.w    _vbuttonwiny.L,D0
       add.w     #10,D0
       cmp.w     _vposty.L,D0
       blo.s     waitButton_6
; ii = 1;
       moveq     #1,D3
; for (iii = 1; iii <= (i - 1); iii++)
       moveq     #1,D4
waitButton_8:
       move.b    D2,D0
       subq.b    #1,D0
       cmp.b     D0,D4
       bhi.s     waitButton_10
; ii *= 2;
       lsl.b     #1,D3
       addq.b    #1,D4
       bra       waitButton_8
waitButton_10:
; break;
       bra.s     waitButton_5
waitButton_6:
       addq.b    #1,D2
       bra       waitButton_3
waitButton_5:
; }
; }
; }
; return ii;
       move.b    D3,D0
       movem.l   (A7)+,D2/D3/D4/A2
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char message(char* bstr, unsigned char bbutton, unsigned short btime)
; {
       xdef      _message
_message:
       link      A6,#-268
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -250(A6),A2
; unsigned short i, ii, iii, xi, yi, xf, xm, yf, ym, pwidth, pheight, xib, yib, xic, yic;
; unsigned char qtdnl, maxlenstr;
; unsigned char qtdcstr[8], poscstr[8], cc, dd, vbty = 0;
       clr.b     -231(A6)
; unsigned char *bstrptr;
; unsigned char slinha[7][26];
; VDP_COORD cursor;
; MGUI_SAVESCR vsavescr;
; unsigned char vbuttonmess[16];
; unsigned int error_code = OS_ERR_NONE;
       clr.l     -8(A6)
; OS_TCB *ptcb;
; cursor = vdp_get_cursor();
       pea       -48(A6)
       move.l    1170,A1
       jsr       (A1)
       move.l    (A7)+,A0
       move.l    D0,A1
       move.l    (A1)+,(A0)+
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; qtdnl = 1;
       moveq     #1,D2
; maxlenstr = 0;
       clr.b     -251(A6)
; qtdcstr[1] = 0;
       clr.b     1(A2)
; poscstr[1] = 0;
       clr.b     -242+1(A6)
; i = 0;
       clr.w     D3
; iii = 0;
       move.w    #0,A5
; for (ii = 0; ii <= 7; ii++)
       clr.w     D4
message_1:
       cmp.w     #7,D4
       bhi.s     message_3
; vbuttonwin[ii] = 0;
       and.l     #65535,D4
       lea       _vbuttonwin.L,A0
       clr.b     0(A0,D4.L)
       addq.w    #1,D4
       bra       message_1
message_3:
; bstrptr = bstr;
       move.l    8(A6),A4
; while (*bstrptr)
message_4:
       tst.b     (A4)
       beq       message_6
; {
; qtdcstr[qtdnl]++;
       and.l     #255,D2
       addq.b    #1,0(A2,D2.L)
; if (qtdcstr[qtdnl] > 26)
       and.l     #255,D2
       move.b    0(A2,D2.L),D0
       cmp.b     #26,D0
       bls.s     message_7
; qtdcstr[qtdnl] = 26;
       and.l     #255,D2
       move.b    #26,0(A2,D2.L)
message_7:
; if (qtdcstr[qtdnl] > maxlenstr)
       and.l     #255,D2
       move.b    0(A2,D2.L),D0
       cmp.b     -251(A6),D0
       bls.s     message_9
; maxlenstr = qtdcstr[qtdnl];
       and.l     #255,D2
       move.b    0(A2,D2.L),-251(A6)
message_9:
; if (*bstrptr == '\n')
       move.b    (A4),D0
       cmp.b     #10,D0
       bne       message_11
; {
; slinha[qtdnl][iii] = '\0';
       and.l     #255,D2
       move.l    D2,D0
       muls      #26,D0
       lea       -230(A6),A0
       add.l     D0,A0
       clr.b     0(A0,A5.L)
; qtdcstr[qtdnl]--;
       and.l     #255,D2
       subq.b    #1,0(A2,D2.L)
; qtdnl++;
       addq.b    #1,D2
; if (qtdnl > 6)
       cmp.b     #6,D2
       bls.s     message_13
; qtdnl = 6;
       moveq     #6,D2
message_13:
; qtdcstr[qtdnl] = 0;
       and.l     #255,D2
       clr.b     0(A2,D2.L)
; poscstr[qtdnl] = i + 1;
       move.w    D3,D0
       addq.w    #1,D0
       and.l     #255,D2
       lea       -242(A6),A0
       move.b    D0,0(A0,D2.L)
; iii = 0;
       move.w    #0,A5
message_11:
; }
; slinha[qtdnl][iii] = *bstrptr;
       and.l     #255,D2
       move.l    D2,D0
       muls      #26,D0
       lea       -230(A6),A0
       add.l     D0,A0
       move.b    (A4),0(A0,A5.L)
; iii++;
       addq.w    #1,A5
; bstrptr++;
       addq.w    #1,A4
; i++;
       addq.w    #1,D3
       bra       message_4
message_6:
; }
; if (maxlenstr > 26)
       move.b    -251(A6),D0
       cmp.b     #26,D0
       bls.s     message_15
; maxlenstr = 26;
       move.b    #26,-251(A6)
message_15:
; if (qtdnl > 6)
       cmp.b     #6,D2
       bls.s     message_17
; qtdnl = 6;
       moveq     #6,D2
message_17:
; pwidth = (maxlenstr + 1) * 6;
       move.b    -251(A6),D0
       addq.b    #1,D0
       and.w     #255,D0
       mulu.w    #6,D0
       move.w    D0,D7
; pwidth = pwidth + 2;
       addq.w    #2,D7
; xm = pwidth / 2;
       move.w    D7,D0
       and.l     #65535,D0
       divu.w    #2,D0
       move.w    D0,-264(A6)
; xi = ((cursor.maxx) / 2) - xm + 1;
       lea       -48(A6),A0
       move.b    2(A0),D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.w     #255,D0
       sub.w     -264(A6),D0
       addq.w    #1,D0
       move.w    D0,D6
; xf = ((cursor.maxx) / 2) + xm - 1;
       lea       -48(A6),A0
       move.b    2(A0),D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.w     #255,D0
       add.w     -264(A6),D0
       subq.w    #1,D0
       move.w    D0,-266(A6)
; pheight = 10 * qtdnl;
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #10,D0
       move.w    D0,D5
; pheight = pheight + 20;
       add.w     #20,D5
; ym = pheight / 2;
       move.w    D5,D0
       and.l     #65535,D0
       divu.w    #2,D0
       move.w    D0,-260(A6)
; yi = ((cursor.maxy) / 2) - ym - 1;
       lea       -48(A6),A0
       move.b    3(A0),D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.w     #255,D0
       sub.w     -260(A6),D0
       subq.w    #1,D0
       move.w    D0,-268(A6)
; yf = ((cursor.maxy) / 2) + ym - 1;
       lea       -48(A6),A0
       move.b    3(A0),D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.w     #255,D0
       add.w     -260(A6),D0
       subq.w    #1,D0
       move.w    D0,-262(A6)
; // Desenha Linha Fora
; SaveScreenNew(&vsavescr, xi,yi,pwidth + 5,pheight + 5);
       move.w    D5,D1
       addq.w    #5,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    D7,D1
       addq.w    #5,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    -268(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D6
       move.l    D6,-(A7)
       pea       -44(A6)
       jsr       _SaveScreenNew
       add.w     #20,A7
; FillRect(xi,yi,pwidth,pheight,vcorwb);
       move.b    _vcorwb.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       and.l     #65535,D7
       move.l    D7,-(A7)
       move.w    -268(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; DrawRoundRect(xi,yi,pwidth,pheight,2,vcorwf);  // rounded rectangle around text area
       move.b    _vcorwf.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       2
       and.l     #65535,D5
       move.l    D5,-(A7)
       and.l     #65535,D7
       move.l    D7,-(A7)
       move.w    -268(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D6
       move.l    D6,-(A7)
       jsr       _DrawRoundRect
       add.w     #24,A7
; // Escreve Texto Dentro da Caixa de Mensagem
; for (i = 1; i <= qtdnl; i++)
       moveq     #1,D3
message_19:
       and.w     #255,D2
       cmp.w     D2,D3
       bhi       message_21
; {
; xib = xi + xm;
       move.w    D6,D0
       add.w     -264(A6),D0
       move.w    D0,A3
; xib = xib - ((qtdcstr[i] * 6) / 2);
       and.l     #65535,D3
       move.b    0(A2,D3.L),D0
       and.w     #255,D0
       mulu.w    #6,D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.w     #255,D0
       sub.w     D0,A3
; yib = yi + 2 + (10 * (i - 1));
       move.w    -268(A6),D0
       addq.w    #2,D0
       move.w    D3,D1
       subq.w    #1,D1
       mulu.w    #10,D1
       add.w     D1,D0
       move.w    D0,-258(A6)
; writesxy(xib,yib,2,slinha[i],vcorwf,vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       lea       -230(A6),A0
       and.l     #65535,D3
       move.l    D3,D1
       muls      #26,D1
       add.l     D1,A0
       move.l    A0,-(A7)
       pea       2
       move.w    -258(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A3,-(A7)
       jsr       _writesxy
       add.w     #24,A7
       addq.w    #1,D3
       bra       message_19
message_21:
; }
; // Desenha Botoes
; i = 1;
       moveq     #1,D3
; while (bbutton)
message_22:
       tst.b     15(A6)
       beq       message_24
; {
; xib = xi + 2 + (34 * (i - 1));
       move.w    D6,D0
       addq.w    #2,D0
       move.w    D3,D1
       subq.w    #1,D1
       mulu.w    #34,D1
       add.w     D1,D0
       move.w    D0,A3
; yib = yf - 12;
       move.w    -262(A6),D0
       sub.w     #12,D0
       move.w    D0,-258(A6)
; vbty = yib;
       move.w    -258(A6),D0
       move.b    D0,-231(A6)
; i++;
       addq.w    #1,D3
; drawButtonsnew(&vbuttonmess, &bbutton, xib, yib);
       move.w    -258(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A3,-(A7)
       pea       15(A6)
       pea       -24(A6)
       jsr       _drawButtonsnew
       add.w     #16,A7
       bra       message_22
message_24:
; }
; ii = 0;
       clr.w     D4
; if (!btime)
       tst.w     18(A6)
       bne       message_25
; {
; vbuttonmess[15] = vbty;
       move.b    -231(A6),-24+15(A6)
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; OSTaskCreate(messageTask, (void *)&vbuttonmess, &StkMessage[STACKSIZE], TASK_MGUI_MESSAGE);
       pea       19
       lea       _StkMessage.L,A0
       add.w     #2048,A0
       move.l    A0,-(A7)
       pea       -24(A6)
       pea       _messageTask.L
       jsr       _OSTaskCreate
       add.w     #16,A7
; vIndicaDialog = 1;
       move.b    #1,_vIndicaDialog.L
; OSTaskSuspend(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskSuspend
       addq.w    #4,A7
; ii = vbuttonmess[0];
       move.b    -24+0(A6),D0
       and.w     #255,D0
       move.w    D0,D4
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
       bra.s     message_29
message_25:
; }
; else {
; for (dd = 0; dd <= 10; dd++)
       clr.b     -232(A6)
message_27:
       move.b    -232(A6),D0
       cmp.b     #10,D0
       bhi.s     message_29
; for (cc = 0; cc <= btime; cc++);
       clr.b     -233(A6)
message_30:
       move.b    -233(A6),D0
       and.w     #255,D0
       cmp.w     18(A6),D0
       bhi.s     message_32
       addq.b    #1,-233(A6)
       bra       message_30
message_32:
       addq.b    #1,-232(A6)
       bra       message_27
message_29:
; }
; RestoreScreen(vsavescr);
       lea       -44(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _RestoreScreen
       add.w     #20,A7
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; return ii;
       move.b    D4,D0
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void messageTask(void *pData)
; {
       xdef      _messageTask
_messageTask:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/D7,-(A7)
; unsigned char i, ii = 0, iii;
       clr.b     D5
; unsigned char vbty;
; unsigned char *vbutton = (int *)pData;
       move.l    8(A6),D4
; OS_TCB *ptcb;
; vbty = vbutton[15];
       move.l    D4,A0
       move.b    15(A0),D7
; while (!ii) {
messageTask_1:
       tst.b     D5
       bne       messageTask_3
; if (mouseBtnPres == 0x01)  // Esquerdo
       move.b    _mouseBtnPres.L,D0
       cmp.b     #1,D0
       bne       messageTask_8
; {
; for (i = 1; i <= 7; i++) {
       moveq     #1,D2
messageTask_6:
       cmp.b     #7,D2
       bhi       messageTask_8
; if (vbutton[i] != 0 && vpostx >= vbutton[i] && vpostx <= (vbutton[i] + 32) && vposty >= vbty && vposty <= (vbty + 10))
       move.l    D4,A0
       and.l     #255,D2
       move.b    0(A0,D2.L),D0
       beq       messageTask_9
       move.l    D4,A0
       and.l     #255,D2
       move.b    0(A0,D2.L),D0
       and.w     #255,D0
       cmp.w     _vpostx.L,D0
       bhi       messageTask_9
       move.l    D4,A0
       and.l     #255,D2
       move.b    0(A0,D2.L),D0
       add.b     #32,D0
       and.w     #255,D0
       cmp.w     _vpostx.L,D0
       blo       messageTask_9
       and.w     #255,D7
       cmp.w     _vposty.L,D7
       bhi.s     messageTask_9
       move.b    D7,D0
       add.b     #10,D0
       and.w     #255,D0
       cmp.w     _vposty.L,D0
       blo.s     messageTask_9
; {
; ii = 1;
       moveq     #1,D5
; for (iii = 1; iii <= (i - 1); iii++)
       moveq     #1,D6
messageTask_11:
       move.b    D2,D0
       subq.b    #1,D0
       cmp.b     D0,D6
       bhi.s     messageTask_13
; ii *= 2;
       lsl.b     #1,D5
       addq.b    #1,D6
       bra       messageTask_11
messageTask_13:
; break;
       bra.s     messageTask_8
messageTask_9:
       addq.b    #1,D2
       bra       messageTask_6
messageTask_8:
; }
; }
; }
; OSTimeDlyHMSM(0, 0, 0, 30);
       pea       30
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       messageTask_1
messageTask_3:
; }
; vbutton[0] = ii;
       move.l    D4,A0
       move.b    D5,(A0)
; // Resume todas as tarefas, menos a de messageTask e a mouseTask e a mmsjos (que nao deve ser reiniciada agora)
; for (i = 0; i < OS_LOWEST_PRIO + 1; i++)
       clr.b     D2
messageTask_14:
       cmp.b     #64,D2
       bhs       messageTask_16
; {
; ptcb = &OSTCBTbl[i];
       lea       _OSTCBTbl.L,A0
       and.l     #255,D2
       move.l    D2,D0
       muls      #86,D0
       add.l     D0,A0
       move.l    A0,D3
; if (ptcb != NULL) // Tarefa válida
       clr.b     D0
       and.l     #255,D0
       cmp.l     D0,D3
       beq       messageTask_19
; {
; if (ptcb->OSTCBPrio != TASK_MGUI_MESSAGE && ptcb->OSTCBPrio != TASK_MGUI_MOUSE && ptcb->OSTCBPrio != TASK_MMSJOS_MAIN)
       move.l    D3,A0
       move.b    52(A0),D0
       cmp.b     #19,D0
       beq.s     messageTask_19
       move.l    D3,A0
       move.b    52(A0),D0
       cmp.b     #12,D0
       beq.s     messageTask_19
       move.l    D3,A0
       move.b    52(A0),D0
       cmp.b     #10,D0
       beq.s     messageTask_19
; {
; OSTaskResume(ptcb->OSTCBPrio);
       move.l    D3,A0
       move.b    52(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _OSTaskResume
       addq.w    #4,A7
messageTask_19:
       addq.b    #1,D2
       bra       messageTask_14
messageTask_16:
; }
; }
; }
; vIndicaDialog = 0;
       clr.b     _vIndicaDialog.L
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void MostraIcone(unsigned short xi, unsigned short yi, unsigned char vicone, unsigned char colorfg, unsigned char colorbg)
; {
       xdef      _MostraIcone
_MostraIcone:
       link      A6,#-24
       movem.l   D2/D3/D4,-(A7)
; unsigned short yf;
; unsigned int ix, iy;
; unsigned int offset, posX, posY, modY, offsetIcon;
; unsigned char pixel, color = ((colorfg << 4) + colorbg);
       move.b    23(A6),D0
       lsl.b     #4,D0
       add.b     27(A6),D0
       move.b    D0,-5(A6)
; unsigned char* vTempIcones = iconesMenuSys;
       move.l    _iconesMenuSys.L,-4(A6)
; // Define Final
; yf = (yi + 8);
       move.w    14(A6),D0
       addq.w    #8,D0
       move.w    D0,-24(A6)
; ix = 0;
       clr.l     D4
; offsetIcon = (vicone * 8);
       move.b    19(A6),D0
       and.w     #255,D0
       mulu.w    #8,D0
       and.l     #65535,D0
       move.l    D0,-10(A6)
; for (iy = yi; iy <= yf; iy++)
       move.w    14(A6),D0
       and.l     #65535,D0
       move.l    D0,D2
MostraIcone_1:
       move.w    -24(A6),D0
       and.l     #65535,D0
       cmp.l     D0,D2
       bhi       MostraIcone_3
; {
; posX = (int)(8 * (xi / 8));
       move.w    10(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       mulu.w    #8,D0
       and.l     #65535,D0
       move.l    D0,-22(A6)
; posY = (int)(256 * (iy / 8));
       move.l    D2,-(A7)
       pea       8
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       256
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-18(A6)
; modY = (int)(iy % 8);
       move.l    D2,-(A7)
       pea       8
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-14(A6)
; offset = posX + modY + posY;
       move.l    -22(A6),D0
       add.l     -14(A6),D0
       add.l     -18(A6),D0
       move.l    D0,D3
; pixel = *(vTempIcones + offsetIcon + ix);
       move.l    -4(A6),A0
       move.l    -10(A6),D0
       add.l     D0,A0
       move.b    0(A0,D4.L),-6(A6)
; setWriteAddress(mgui_pattern_table + offset);
       move.l    _mgui_pattern_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = pixel;
       move.l    _vvdgd.L,A0
       move.b    -6(A6),(A0)
; setWriteAddress(mgui_color_table + offset);
       move.l    _mgui_color_table.L,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; *vvdgd = color;
       move.l    _vvdgd.L,A0
       move.b    -5(A6),(A0)
; ix++;
       addq.l    #1,D4
       addq.l    #1,D2
       bra       MostraIcone_1
MostraIcone_3:
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; //  vicone: 1 - Ponteiro, 2 - Ampulheta
; //-----------------------------------------------------------------------------
; void TrocaSpriteMouse(unsigned char vicone)
; {
       xdef      _TrocaSpriteMouse
_TrocaSpriteMouse:
       link      A6,#-16
       movem.l   D2/A2,-(A7)
       lea       -16(A6),A2
; long ix;
; unsigned char tempPtrMouse[8];
; unsigned char* vTempSpritePointer = mousePointer;
       move.l    _mousePointer.L,-8(A6)
; unsigned char* vTempSpriteHourGlass = mouseHourGlass;
       move.l    _mouseHourGlass.L,-4(A6)
; // Inicializa ponteiro Mouse
; switch (vicone)
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #2,D0
       beq.s     TrocaSpriteMouse_4
       bhi       TrocaSpriteMouse_2
       cmp.l     #1,D0
       beq.s     TrocaSpriteMouse_3
       bra.s     TrocaSpriteMouse_2
TrocaSpriteMouse_3:
; {
; case 1:
; for (ix = 0; ix < 8; ix++)
       clr.l     D2
TrocaSpriteMouse_5:
       cmp.l     #8,D2
       bge.s     TrocaSpriteMouse_7
; tempPtrMouse[ix] = *(vTempSpritePointer + ix);
       move.l    -8(A6),A0
       move.b    0(A0,D2.L),0(A2,D2.L)
       addq.l    #1,D2
       bra       TrocaSpriteMouse_5
TrocaSpriteMouse_7:
; break;
       bra.s     TrocaSpriteMouse_2
TrocaSpriteMouse_4:
; case 2:
; for (ix = 0; ix < 8; ix++)
       clr.l     D2
TrocaSpriteMouse_8:
       cmp.l     #8,D2
       bge.s     TrocaSpriteMouse_10
; tempPtrMouse[ix] = *(vTempSpriteHourGlass + ix);
       move.l    -4(A6),A0
       move.b    0(A0,D2.L),0(A2,D2.L)
       addq.l    #1,D2
       bra       TrocaSpriteMouse_8
TrocaSpriteMouse_10:
; break;
TrocaSpriteMouse_2:
; }
; vdp_set_sprite_pattern(0, tempPtrMouse);
       move.l    A2,-(A7)
       clr.l     -(A7)
       move.l    1134,A0
       jsr       (A0)
       addq.w    #8,A7
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char new_menu(void)
; {
       xdef      _new_menu
_new_menu:
       link      A6,#-88
       movem.l   D2/D3/A2/A3,-(A7)
       lea       _vpostx.L,A2
       lea       _mx.L,A3
; unsigned short lc;
; unsigned char vresp, mpos, mtqresp;
; OS_TCB tcb;
; vresp = 1;
       moveq     #1,D3
; if (vpostx >= COLMENU && vpostx <= (COLMENU + 16))
       move.w    (A2),D0
       cmp.w     #8,D0
       blo       new_menu_1
       move.w    (A2),D0
       cmp.w     #24,D0
       bhi       new_menu_1
; {
; // Verifica se a Task ja existe. Se nao, cria
; mtqresp = OSTaskQuery(20, &tcb);
       pea       -86(A6)
       pea       20
       jsr       _OSTaskQuery
       addq.w    #8,A7
       move.b    D0,-87(A6)
; if (mtqresp != OS_ERR_NONE)
       move.b    -87(A6),D0
       beq.s     new_menu_3
; {
; OSTaskCreate(menuTask, OS_NULL, &StkMenu[STACKSIZEMENU], 20);
       pea       20
       lea       _StkMenu.L,A0
       add.w     #2048,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _menuTask.L
       jsr       _OSTaskCreate
       add.w     #16,A7
new_menu_3:
       bra       new_menu_11
new_menu_1:
; }
; }
; else {
; for (lc = 1; lc <= 4; lc++) {
       moveq     #1,D2
new_menu_5:
       cmp.w     #4,D2
       bhi       new_menu_7
; mx = COLMENU + (24 * lc);
       moveq     #8,D0
       ext.w     D0
       move.w    D2,D1
       mulu.w    #24,D1
       add.w     D1,D0
       move.w    D0,(A3)
; if (vpostx >= mx && vpostx <= (mx + 16)) {
       move.w    (A2),D0
       cmp.w     (A3),D0
       blo.s     new_menu_8
       move.w    (A3),D0
       add.w     #16,D0
       cmp.w     (A2),D0
       blo.s     new_menu_8
; /*                InvertRect( mx, 4, 8, 8);
; InvertRect( mx, 4, 8, 8);*/
; break;
       bra.s     new_menu_7
new_menu_8:
       addq.w    #1,D2
       bra       new_menu_5
new_menu_7:
; }
; }
; switch (lc) {
       and.l     #65535,D2
       move.l    D2,D0
       subq.l    #1,D0
       blo       new_menu_11
       cmp.l     #4,D0
       bhs       new_menu_11
       asl.l     #1,D0
       move.w    new_menu_12(PC,D0.L),D0
       jmp       new_menu_12(PC,D0.W)
new_menu_12:
       dc.w      new_menu_13-new_menu_12
       dc.w      new_menu_14-new_menu_12
       dc.w      new_menu_15-new_menu_12
       dc.w      new_menu_16-new_menu_12
new_menu_13:
; case 1: // RUN
; runBin();
       jsr       _runBin
; break;
       bra.s     new_menu_11
new_menu_14:
; case 2: // MMSJOS
; break;
       bra.s     new_menu_11
new_menu_15:
; case 3: // SETUP
; break;
       bra.s     new_menu_11
new_menu_16:
; case 4: // EXIT
; mpos = message("Do you want to exit ?\0", BTYES | BTNO, 0);
       clr.l     -(A7)
       pea       12
       pea       @mgui_29.L
       jsr       _message
       add.w     #12,A7
       move.b    D0,-88(A6)
; if (mpos == BTYES)
       move.b    -88(A6),D0
       cmp.b     #4,D0
       bne.s     new_menu_17
; vresp = 0;
       clr.b     D3
new_menu_17:
; break;
new_menu_11:
; }
; }
; return vresp;
       move.b    D3,D0
       movem.l   (A7)+,D2/D3/A2/A3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void menuTask(void *pData)
; {
       xdef      _menuTask
_menuTask:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       _vcorwf.L,A2
       lea       _menyi.L,A3
       lea       _TrocaSpriteMouse.L,A4
       lea       _message.L,A5
; unsigned char vpos = 0, mpos;
       clr.b     D5
; unsigned short vx, vy, vposicony;
; unsigned char *vEndExec;
; unsigned long vsizefilemalloc;
; mx = 0;
       clr.w     _mx.L
; my = LINHAMENU;
       move.w    #22,_my.L
; mpos = 0;
       clr.b     D2
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       jsr       (A4)
       addq.w    #4,A7
; SaveScreenNew(&endSaveMenu, mx,my,128,44);
       pea       44
       pea       128
       move.w    _my.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       _endSaveMenu.L
       jsr       _SaveScreenNew
       add.w     #20,A7
; FillRect(mx,my,128,42,vcorwb);
       move.b    _vcorwb.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       42
       pea       128
       move.w    _my.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; DrawRect(mx,my,128,42,vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       42
       pea       128
       move.w    _my.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _DrawRect
       add.w     #20,A7
; mpos += 2;
       addq.b    #2,D2
; menyi[0] = my + mpos;
       move.w    _my.L,D0
       and.w     #255,D2
       add.w     D2,D0
       move.w    D0,(A3)
; writesxy(mx + 8,my + mpos,1,"Files",vcorwf,vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_30.L
       pea       1
       move.w    _my.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       addq.w    #8,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _writesxy
       add.w     #24,A7
; mpos += 12;
       add.b     #12,D2
; menyf[0] = my + mpos;
       move.w    _my.L,D0
       and.w     #255,D2
       add.w     D2,D0
       move.w    D0,_menyf.L
; DrawLine(mx,my + mpos,mx+128,my + mpos,vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _my.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       add.w     #128,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _my.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _DrawLine
       add.w     #20,A7
; mpos += 2;
       addq.b    #2,D2
; menyi[1] = my + mpos;
       move.w    _my.L,D0
       and.w     #255,D2
       add.w     D2,D0
       move.w    D0,2(A3)
; writesxy(mx + 8,my + mpos,1,"Import File",vcorwf,vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_31.L
       pea       1
       move.w    _my.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       addq.w    #8,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _writesxy
       add.w     #24,A7
; mpos += 12;
       add.b     #12,D2
; menyf[1] = my + mpos;
       move.w    _my.L,D0
       and.w     #255,D2
       add.w     D2,D0
       move.w    D0,_menyf+2.L
; mpos += 2;
       addq.b    #2,D2
; menyi[2] = my + mpos;
       move.w    _my.L,D0
       and.w     #255,D2
       add.w     D2,D0
       move.w    D0,4(A3)
; writesxy(mx + 8,my + mpos,1,"About",vcorwf,vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_32.L
       pea       1
       move.w    _my.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       addq.w    #8,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _writesxy
       add.w     #24,A7
; mpos += 12;
       add.b     #12,D2
; menyf[2] = my + mpos;
       move.w    _my.L,D0
       and.w     #255,D2
       add.w     D2,D0
       move.w    D0,_menyf+4.L
; DrawLine(mx,my + mpos,mx+128,my + mpos,vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _my.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       add.w     #128,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _my.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _mx.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _DrawLine
       add.w     #20,A7
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       (A4)
       addq.w    #4,A7
; while (1)
menuTask_1:
; {
; if (mouseBtnPres == 0x01)  // Esquerdo
       move.b    _mouseBtnPres.L,D0
       cmp.b     #1,D0
       bne       menuTask_4
; {
; if ((vposty >= my && vposty <= my + 42) && (vpostx >= mx && vpostx <= mx + 128))
       move.w    _vposty.L,D0
       cmp.w     _my.L,D0
       blo       menuTask_14
       move.w    _my.L,D0
       add.w     #42,D0
       cmp.w     _vposty.L,D0
       blo       menuTask_14
       move.w    _vpostx.L,D0
       cmp.w     _mx.L,D0
       blo       menuTask_14
       move.w    _mx.L,D0
       add.w     #128,D0
       cmp.w     _vpostx.L,D0
       blo       menuTask_14
; {
; vpos = 0;
       clr.b     D5
; vposicony = 0;
       clr.w     -2(A6)
; for(vy = 0; vy <= 1; vy++)
       clr.w     D3
menuTask_8:
       cmp.w     #1,D3
       bhi       menuTask_10
; {
; if (vposty >= menyi[vy] && vposty <= menyf[vy])
       and.l     #65535,D3
       move.l    D3,D0
       lsl.l     #1,D0
       move.w    _vposty.L,D1
       cmp.w     0(A3,D0.L),D1
       blo.s     menuTask_11
       and.l     #65535,D3
       move.l    D3,D0
       lsl.l     #1,D0
       lea       _menyf.L,A0
       move.w    _vposty.L,D1
       cmp.w     0(A0,D0.L),D1
       bhi.s     menuTask_11
; {
; vposicony = menyi[vy];
       and.l     #65535,D3
       move.l    D3,D0
       lsl.l     #1,D0
       move.w    0(A3,D0.L),-2(A6)
; break;
       bra.s     menuTask_10
menuTask_11:
; }
; vpos++;
       addq.b    #1,D5
       addq.w    #1,D3
       bra       menuTask_8
menuTask_10:
; }
; switch (vpos)
       and.l     #255,D5
       cmp.l     #1,D5
       beq       menuTask_16
       bhi.s     menuTask_18
       tst.l     D5
       beq.s     menuTask_15
       bra       menuTask_14
menuTask_18:
       cmp.l     #2,D5
       beq       menuTask_17
       bra       menuTask_14
menuTask_15:
; {
; case 0: // Call "Files" Program from Disk
; vsizefilemalloc = fsInfoFile("/MGUI/PROGS/FILES.BIN", INFO_SIZE);
       pea       1
       pea       @mgui_33.L
       jsr       _fsInfoFile
       addq.w    #8,A7
       move.l    D0,D6
; if (vsizefilemalloc != ERRO_D_NOT_FOUND)
       cmp.l     #-1,D6
       beq       menuTask_19
; {
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       jsr       (A4)
       addq.w    #4,A7
; vEndExec = malloc(vsizefilemalloc);
       move.l    D6,-(A7)
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,D4
; if (!vEndExec)
       tst.l     D4
       bne.s     menuTask_21
; {
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       (A4)
       addq.w    #4,A7
; message("No memory to load FILES.BIN\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_34.L
       jsr       (A5)
       add.w     #12,A7
       bra       menuTask_24
menuTask_21:
; }
; else
; {
; loadFile("/MGUI/PROGS/FILES.BIN", (unsigned long*)vEndExec);
       move.l    D4,-(A7)
       pea       @mgui_33.L
       jsr       _loadFile
       addq.w    #8,A7
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       (A4)
       addq.w    #4,A7
; if (!verro)
       tst.b     _verro.L
       bne.s     menuTask_23
; runFromMGUI(vEndExec);
       move.l    D4,-(A7)
       jsr       _runFromMGUI
       addq.w    #4,A7
       bra.s     menuTask_24
menuTask_23:
; else {
; message("Loading Error...\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_35.L
       jsr       (A5)
       add.w     #12,A7
; free(vEndExec);
       move.l    D4,-(A7)
       jsr       _free
       addq.w    #4,A7
menuTask_24:
       bra.s     menuTask_20
menuTask_19:
; }
; }
; }
; else
; message("File not found...\n/MGUI/PROGS/FILES.BIN\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_36.L
       jsr       (A5)
       add.w     #12,A7
menuTask_20:
; break;
       bra.s     menuTask_14
menuTask_16:
; case 1: // Import File via Serial
; importFile();
       jsr       _importFile
; break;
       bra.s     menuTask_14
menuTask_17:
; case 2: // About
; message("MGUI v0.1\nGraphical User Interface\n \nwww.utilityinf.com.br\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_37.L
       jsr       (A5)
       add.w     #12,A7
; break;
menuTask_14:
; }
; }
; break;
       bra.s     menuTask_3
menuTask_4:
; }
; OSTimeDlyHMSM(0, 0, 0, 50);
       pea       50
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       menuTask_1
menuTask_3:
; }
; RestoreScreen(endSaveMenu);
       lea       _endSaveMenu.L,A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _RestoreScreen
       add.w     #20,A7
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void runBin(void)
; {
       xdef      _runBin
_runBin:
       link      A6,#-248
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       -180(A6),A2
       lea       _message.L,A3
       lea       -116(A6),A4
       lea       -244(A6),A5
; unsigned short ix;
; unsigned char vwb, vresp;
; unsigned char vnamein[64], vfilename[64], vfullpath[96];
; unsigned char *vEndExec;
; unsigned long vsizefilemalloc;
; char *vdot;
; MGUI_SAVESCR vsavescr;
; vnamein[0] = '\0';
       clr.b     (A5)
; vfilename[0] = '\0';
       clr.b     (A2)
; vfullpath[0] = '\0';
       clr.b     (A4)
; SaveScreenNew(&vsavescr, 10,40,240,60);
       pea       60
       pea       240
       pea       40
       pea       10
       pea       -20(A6)
       jsr       _SaveScreenNew
       add.w     #20,A7
; showWindow("Run Binary",10,40,240,50,BTOK | BTCANCEL);
       pea       3
       pea       50
       pea       240
       pea       40
       pea       10
       pea       @mgui_38.L
       jsr       _showWindow
       add.w     #24,A7
; writesxy(12,57,8,"File Name:",vcorwf,vcorwb);
       move.b    _vcorwb.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_39.L
       pea       8
       pea       57
       pea       12
       jsr       _writesxy
       add.w     #24,A7
; fillin(vnamein, 78, 57, 130, WINDISP);
       clr.l     -(A7)
       pea       130
       pea       57
       pea       78
       move.l    A5,-(A7)
       jsr       _fillin
       add.w     #20,A7
; while (1)
runBin_1:
; {
; fillin(vnamein, 78, 57, 130, WINOPER);
       pea       1
       pea       130
       pea       57
       pea       78
       move.l    A5,-(A7)
       jsr       _fillin
       add.w     #20,A7
; vwb = waitButton();
       jsr       _waitButton
       move.b    D0,D5
; if (vwb == BTOK || vwb == BTCANCEL)
       cmp.b     #1,D5
       beq.s     runBin_6
       cmp.b     #2,D5
       bne.s     runBin_4
runBin_6:
; break;
       bra.s     runBin_3
runBin_4:
; OSTimeDlyHMSM(0, 0, 0, 30);
       pea       30
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       runBin_1
runBin_3:
; }
; RestoreScreen(vsavescr);
       lea       -20(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _RestoreScreen
       add.w     #20,A7
; if (vwb != BTOK)
       cmp.b     #1,D5
       beq.s     runBin_7
; return;
       bra       runBin_9
runBin_7:
; if (vnamein[0] == '\0')
       move.b    (A5),D0
       bne.s     runBin_10
; {
; message("Error, file name must be provided!!\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_40.L
       jsr       (A3)
       add.w     #12,A7
; return;
       bra       runBin_9
runBin_10:
; }
; for (ix = 0; ix < 63 && vnamein[ix] != '\0'; ix++)
       clr.w     D2
runBin_12:
       cmp.w     #63,D2
       bhs.s     runBin_14
       and.l     #65535,D2
       move.b    0(A5,D2.L),D0
       beq.s     runBin_14
; vfilename[ix] = toupper(vnamein[ix]);
       and.l     #65535,D2
       move.b    0(A5,D2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
       addq.w    #1,D2
       bra       runBin_12
runBin_14:
; vfilename[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; vdot = 0;
       clr.l     D4
; for (ix = 0; vfilename[ix] != '\0'; ix++)
       clr.w     D2
runBin_15:
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       beq.s     runBin_17
; {
; if (vfilename[ix] == '.')
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       cmp.b     #46,D0
       bne.s     runBin_18
; vdot = &vfilename[ix];
       move.l    A2,D0
       and.l     #65535,D2
       add.l     D2,D0
       move.l    D0,D4
runBin_18:
       addq.w    #1,D2
       bra       runBin_15
runBin_17:
; }
; if (!vdot)
       tst.l     D4
       bne       runBin_20
; {
; if (strlen(vfilename) > 59)
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #59,D0
       ble.s     runBin_22
; {
; message("Invalid file name length\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_41.L
       jsr       (A3)
       add.w     #12,A7
; return;
       bra       runBin_9
runBin_22:
; }
; strcat(vfilename, ".BIN");
       pea       @mgui_42.L
       move.l    A2,-(A7)
       jsr       _strcat
       addq.w    #8,A7
       bra.s     runBin_24
runBin_20:
; }
; else if (strcmp(vdot, ".BIN") != 0)
       pea       @mgui_42.L
       move.l    D4,-(A7)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       beq.s     runBin_24
; {
; message("Only .BIN files are allowed\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_43.L
       jsr       (A3)
       add.w     #12,A7
; return;
       bra       runBin_9
runBin_24:
; }
; if (vfilename[0] == '/')
       move.b    (A2),D0
       cmp.b     #47,D0
       bne.s     runBin_26
; strcpy(vfullpath, vfilename);
       move.l    A2,-(A7)
       move.l    A4,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     runBin_27
runBin_26:
; else
; {
; strcpy(vfullpath, "/MGUI/PROGS/");
       pea       @mgui_44.L
       move.l    A4,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
; strcat(vfullpath, vfilename);
       move.l    A2,-(A7)
       move.l    A4,-(A7)
       jsr       _strcat
       addq.w    #8,A7
runBin_27:
; }
; vresp = message("Run selected file ?\0",(BTYES | BTNO), 0);
       clr.l     -(A7)
       pea       12
       pea       @mgui_45.L
       jsr       (A3)
       add.w     #12,A7
       move.b    D0,-245(A6)
; if (vresp != BTYES)
       move.b    -245(A6),D0
       cmp.b     #4,D0
       beq.s     runBin_28
; return;
       bra       runBin_9
runBin_28:
; vsizefilemalloc = fsInfoFile(vfullpath, INFO_SIZE);
       pea       1
       move.l    A4,-(A7)
       jsr       _fsInfoFile
       addq.w    #8,A7
       move.l    D0,D6
; if (vsizefilemalloc == ERRO_D_NOT_FOUND)
       cmp.l     #-1,D6
       bne.s     runBin_30
; {
; message("File not found...\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_46.L
       jsr       (A3)
       add.w     #12,A7
; return;
       bra       runBin_9
runBin_30:
; }
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; vEndExec = malloc(vsizefilemalloc);
       move.l    D6,-(A7)
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,D3
; if (!vEndExec)
       tst.l     D3
       bne.s     runBin_32
; {
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; message("No memory to load .BIN\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_47.L
       jsr       (A3)
       add.w     #12,A7
; return;
       bra       runBin_9
runBin_32:
; }
; loadFile(vfullpath, (unsigned long*)vEndExec);
       move.l    D3,-(A7)
       move.l    A4,-(A7)
       jsr       _loadFile
       addq.w    #8,A7
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; if (!verro)
       tst.b     _verro.L
       bne.s     runBin_34
; runFromMGUI(vEndExec);
       move.l    D3,-(A7)
       jsr       _runFromMGUI
       addq.w    #4,A7
       bra.s     runBin_35
runBin_34:
; else
; {
; message("Loading Error...\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_35.L
       jsr       (A3)
       add.w     #12,A7
; free(vEndExec);
       move.l    D3,-(A7)
       jsr       _free
       addq.w    #4,A7
runBin_35:
; }
; return;
runBin_9:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void importFile(void)
; {
       xdef      _importFile
_importFile:
       link      A6,#-304
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vcorwf.L,A2
       lea       _vcorwb.L,A3
       lea       _writesxy.L,A4
       lea       -292(A6),A5
; unsigned long vStep, ix;
; unsigned char *xaddress = 0x00840000;
       move.l    #8650752,D7
; unsigned char *xaddressStart;
; unsigned char vErro, vPerc;
; char vfilename[64], vstring[64];
; unsigned char vwb, vresp, vBuffer[128];
; int iy;
; unsigned char sqtdtam[10];
; unsigned long vSizeTotalRec;
; unsigned short vChunkSize;
; MGUI_SAVESCR vsavescr;
; vSizeTotalRec = lstmGetSize();
       move.l    1178,A0
       jsr       (A0)
       move.l    D0,-24(A6)
; SaveScreenNew(&vsavescr, 10,40,240,60);
       pea       60
       pea       240
       pea       40
       pea       10
       pea       -20(A6)
       jsr       _SaveScreenNew
       add.w     #20,A7
; showWindow("Import File",10,40,240,50,BTOK | BTCANCEL);
       pea       3
       pea       50
       pea       240
       pea       40
       pea       10
       pea       @mgui_31.L
       jsr       _showWindow
       add.w     #24,A7
; writesxy(12,57,8,"File Name:",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_39.L
       pea       8
       pea       57
       pea       12
       jsr       (A4)
       add.w     #24,A7
; fillin(vstring, 78, 57, 130, WINDISP);
       clr.l     -(A7)
       pea       130
       pea       57
       pea       78
       pea       -228(A6)
       jsr       _fillin
       add.w     #20,A7
; vErro = RETURN_OK;
       clr.b     D3
; while (1)
importFile_1:
; {
; fillin(vstring, 78, 57, 130, WINOPER);
       pea       1
       pea       130
       pea       57
       pea       78
       pea       -228(A6)
       jsr       _fillin
       add.w     #20,A7
; vwb = waitButton();
       jsr       _waitButton
       move.b    D0,D5
; if (vwb == BTOK || vwb == BTCANCEL)
       cmp.b     #1,D5
       beq.s     importFile_6
       cmp.b     #2,D5
       bne.s     importFile_4
importFile_6:
; break;
       bra.s     importFile_3
importFile_4:
; OSTimeDlyHMSM(0, 0, 0, 30);
       pea       30
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       importFile_1
importFile_3:
; }
; RestoreScreen(vsavescr);
       lea       -20(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _RestoreScreen
       add.w     #20,A7
; if (vwb == BTOK)
       cmp.b     #1,D5
       bne       importFile_15
; {
; if (vstring == 0)
       lea       -228(A6),A0
       move.l    A0,D0
       bne.s     importFile_9
; {
; message("Error, file name must be provided!!\0", BTCLOSE, 0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_40.L
       jsr       _message
       add.w     #12,A7
; return;
       bra       importFile_11
importFile_9:
; }
; for(ix = 0; ix < 12 && toupper(vstring[ix]) != 0x00; ix++)
       clr.l     D2
importFile_12:
       cmp.l     #12,D2
       bhs       importFile_14
       lea       -228(A6),A0
       move.b    0(A0,D2.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       tst.l     D0
       beq.s     importFile_14
; vfilename[ix] = toupper(vstring[ix]);
       lea       -228(A6),A0
       move.b    0(A0,D2.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.b    D0,0(A5,D2.L)
       addq.l    #1,D2
       bra       importFile_12
importFile_14:
; vfilename[ix] = 0x00;
       clr.b     0(A5,D2.L)
; vresp = message("Confirm serial Connected.\nImport File ?\0",(BTYES | BTNO), 0);
       clr.l     -(A7)
       pea       12
       pea       @mgui_48.L
       jsr       _message
       add.w     #12,A7
       move.b    D0,-163(A6)
; if (vresp == BTYES)
       move.b    -163(A6),D0
       cmp.b     #4,D0
       bne       importFile_15
; {
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; SaveScreenNew(&vsavescr, 10,40,240,70);
       pea       70
       pea       240
       pea       40
       pea       10
       pea       -20(A6)
       jsr       _SaveScreenNew
       add.w     #20,A7
; showWindow("Status Import File",10,40,240,70, BTCLOSE);
       pea       64
       pea       70
       pea       240
       pea       40
       pea       10
       pea       @mgui_49.L
       jsr       _showWindow
       add.w     #24,A7
; // Verifica se o arquivo existe
; if (fsFindInDir(vfilename, TYPE_FILE) < ERRO_D_START)
       pea       2
       move.l    A5,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       bhs       importFile_17
; {
; writesxy(12,55,8,"Deleting File...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_50.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; // Se existir, apaga
; fsDelFile(vfilename);
       move.l    A5,-(A7)
       jsr       _fsDelFile
       addq.w    #4,A7
importFile_17:
; }
; // Cria o Arquivo
; writesxy(12,55,8,"Creating File...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_51.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; vErro = fsCreateFile(vfilename);
       move.l    A5,-(A7)
       jsr       _fsCreateFile
       addq.w    #4,A7
       move.b    D0,D3
; if (vErro == RETURN_OK)
       tst.b     D3
       bne       importFile_19
; {
; // Recebe os dados via Serial
; writesxy(12,55,8,"Reading Serial...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_52.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; xaddress = malloc(256UL * 1024UL); // Aloca 256KB para receber o arquivo via serial
       pea       262144
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,D7
; xaddressStart = xaddress;
       move.l    D7,-298(A6)
; if (!loadSerialToMem2(xaddressStart, 0))
       clr.l     -(A7)
       move.l    -298(A6),-(A7)
       move.l    1210,A0
       jsr       (A0)
       addq.w    #8,A7
       tst.b     D0
       bne       importFile_21
; {
; // Abre Arquivo
; writesxy(12,55,8,"Opening File...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_53.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; vErro = fsOpenFile(vfilename);
       move.l    A5,-(A7)
       jsr       _fsOpenFile
       addq.w    #4,A7
       move.b    D0,D3
; if (vErro != RETURN_OK)
       tst.b     D3
       beq.s     importFile_23
; {
; free(xaddressStart);
       move.l    -298(A6),-(A7)
       jsr       _free
       addq.w    #4,A7
       bra       importFile_24
importFile_23:
; }
; else
; {
; // Grava no Arquivo
; writesxy(12,55,8,"Writing File...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_54.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; DrawRect(18,68,203,14,vcorwf);
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       14
       pea       203
       pea       68
       pea       18
       jsr       _DrawRect
       add.w     #20,A7
; vStep = vSizeTotalRec / 20;
       move.l    -24(A6),-(A7)
       pea       20
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-302(A6)
; vPerc = 0;
       clr.b     -293(A6)
; for (ix = 0; ix < vSizeTotalRec; ix += 128)
       clr.l     D2
importFile_25:
       cmp.l     -24(A6),D2
       bhs       importFile_27
; {
; vChunkSize = (unsigned short)(vSizeTotalRec - ix);
       move.l    -24(A6),D0
       sub.l     D2,D0
       move.w    D0,D6
; if (vChunkSize > 128)
       cmp.w     #128,D6
       bls.s     importFile_28
; vChunkSize = 128;
       move.w    #128,D6
importFile_28:
; for (iy = 0; iy < 128; iy++)
       clr.l     D4
importFile_30:
       cmp.l     #128,D4
       bge       importFile_32
; {
; if (ix > 0 && ((ix + iy) % vStep) == 0)
       cmp.l     #0,D2
       bls       importFile_33
       move.l    D2,D0
       add.l     D4,D0
       move.l    D0,-(A7)
       move.l    -302(A6),-(A7)
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     importFile_33
; {
; FillRect((21 + vPerc), 71, 8, 8, VDP_DARK_BLUE);
       pea       4
       pea       8
       pea       8
       pea       71
       moveq     #21,D1
       add.b     -293(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _FillRect
       add.w     #20,A7
; vPerc += 10;
       add.b     #10,-293(A6)
importFile_33:
; }
; if (iy < vChunkSize)
       and.l     #65535,D6
       cmp.l     D6,D4
       bhs.s     importFile_35
; {
; vBuffer[iy] = *xaddress;
       move.l    D7,A0
       lea       -162(A6),A1
       move.b    (A0),0(A1,D4.L)
; xaddress += 1;
       addq.l    #1,D7
importFile_35:
       addq.l    #1,D4
       bra       importFile_30
importFile_32:
; }
; }
; vErro = fsWriteFile(vfilename, ix, vBuffer, (unsigned char)vChunkSize);
       and.l     #255,D6
       move.l    D6,-(A7)
       pea       -162(A6)
       move.l    D2,-(A7)
       move.l    A5,-(A7)
       jsr       _fsWriteFile
       add.w     #16,A7
       move.b    D0,D3
; if (vErro != RETURN_OK)
       tst.b     D3
       beq.s     importFile_37
; {
; free(xaddressStart);
       move.l    -298(A6),-(A7)
       jsr       _free
       addq.w    #4,A7
; break;
       bra.s     importFile_27
importFile_37:
       add.l     #128,D2
       bra       importFile_25
importFile_27:
; }
; }
; // Fecha Arquivo
; writesxy(12,55,8,"Closing File...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_55.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; fsCloseFile(vfilename, 0);
       clr.l     -(A7)
       move.l    A5,-(A7)
       jsr       _fsCloseFile
       addq.w    #8,A7
importFile_24:
; }
; if (vErro == RETURN_OK)
       tst.b     D3
       bne.s     importFile_39
; writesxy(12,55,8,"Done !         ",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_56.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
       bra       importFile_40
importFile_39:
; else
; {
; writesxy(12,55,8,"Writing File Error !",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_57.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; itoa(vErro, sqtdtam, 16);
       pea       16
       pea       -34(A6)
       and.l     #255,D3
       move.l    D3,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writesxy(12,65,8,sqtdtam,vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -34(A6)
       pea       8
       pea       65
       pea       12
       jsr       (A4)
       add.w     #24,A7
importFile_40:
       bra.s     importFile_22
importFile_21:
; }
; }
; else
; writesxy(12,55,8,"Serial Load Error...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_58.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
importFile_22:
       bra       importFile_20
importFile_19:
; }
; else
; {
; writesxy(12,55,8,"Create File Error...",vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       @mgui_59.L
       pea       8
       pea       55
       pea       12
       jsr       (A4)
       add.w     #24,A7
; itoa(vErro, sqtdtam, 16);
       pea       16
       pea       -34(A6)
       and.l     #255,D3
       move.l    D3,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writesxy(12,65,8,sqtdtam,vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -34(A6)
       pea       8
       pea       65
       pea       12
       jsr       (A4)
       add.w     #24,A7
; writesxy(12,75,8,vfilename,vcorwf,vcorwb);
       move.b    (A3),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,-(A7)
       pea       8
       pea       75
       pea       12
       jsr       (A4)
       add.w     #24,A7
importFile_20:
; }
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       jsr       _TrocaSpriteMouse
       addq.w    #4,A7
; while (1)
importFile_41:
; {
; vwb = waitButton();
       jsr       _waitButton
       move.b    D0,D5
; if (vwb == BTCLOSE)
       cmp.b     #64,D5
       bne.s     importFile_44
; break;
       bra.s     importFile_43
importFile_44:
; OSTimeDlyHMSM(0, 0, 0, 30);
       pea       30
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       importFile_41
importFile_43:
; }
; RestoreScreen(vsavescr);
       lea       -20(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _RestoreScreen
       add.w     #20,A7
importFile_15:
; }
; }
; return;
importFile_11:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void putImagePbmP4(unsigned char* cursor, unsigned short ix, unsigned short iy)
; {
       xdef      _putImagePbmP4
_putImagePbmP4:
       link      A6,#-16
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.l    8(A6),D2
       lea       -10(A6),A2
       lea       -14(A6),A3
; char tipo[3], cnum[5];
; int largura = 0, altura = 0;
       clr.l     -4(A6)
       move.w    #0,A5
; int bytes_por_linha,x,y,ixx;
; unsigned char* dados = cursor;
       move.l    D2,D5
; unsigned char* linha = dados;
       move.l    D5,A4
; // Ler o tipo do formato (P4)
; tipo[0] = cursor[0];
       move.l    D2,A0
       move.b    (A0),(A3)
; tipo[1] = cursor[1];
       move.l    D2,A0
       move.b    1(A0),1(A3)
; tipo[2] = '\0';
       clr.b     2(A3)
; cursor += 3;
       addq.l    #3,D2
; if (strcmp(tipo, "P4") != 0)
       pea       @mgui_60.L
       move.l    A3,-(A7)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       beq.s     putImagePbmP4_1
; {
; message("Invalid or unsupported PBM format\nexpected P4",BTCLOSE,0);
       clr.l     -(A7)
       pea       64
       pea       @mgui_61.L
       jsr       _message
       add.w     #12,A7
; return;
       bra       putImagePbmP4_19
putImagePbmP4_1:
; }
; // Ignorar comentários
; while (*cursor == '#') {
putImagePbmP4_4:
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     putImagePbmP4_6
; while (*cursor != '\n') cursor++; // Ignorar até o final da linha
putImagePbmP4_7:
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #10,D0
       beq.s     putImagePbmP4_9
       addq.l    #1,D2
       bra       putImagePbmP4_7
putImagePbmP4_9:
; cursor++; // Pular o '\n'
       addq.l    #1,D2
       bra       putImagePbmP4_4
putImagePbmP4_6:
; }
; // Ler largura e altura
; x = 0;
       clr.l     D3
; y = 0;
       clr.l     D4
; while(y < 8)
putImagePbmP4_10:
       cmp.l     #8,D4
       bge       putImagePbmP4_12
; {
; if (*cursor != ' ' && *cursor != '\n')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     putImagePbmP4_13
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #10,D0
       beq.s     putImagePbmP4_13
; {
; cnum[x] = *cursor;
       move.l    D2,A0
       move.b    (A0),0(A2,D3.L)
; x++;
       addq.l    #1,D3
; cursor++;
       addq.l    #1,D2
; y++;
       addq.l    #1,D4
       bra       putImagePbmP4_14
putImagePbmP4_13:
; }
; else
; {
; cnum[x] = '\0';
       clr.b     0(A2,D3.L)
; x = 0;
       clr.l     D3
; if (*cursor == ' ')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       bne.s     putImagePbmP4_15
; largura = atoi(cnum);
       move.l    A2,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-4(A6)
       bra.s     putImagePbmP4_16
putImagePbmP4_15:
; else
; {
; altura = atoi(cnum);
       move.l    A2,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,A5
; cursor++;
       addq.l    #1,D2
; break;
       bra.s     putImagePbmP4_12
putImagePbmP4_16:
; }
; cursor++;
       addq.l    #1,D2
putImagePbmP4_14:
       bra       putImagePbmP4_10
putImagePbmP4_12:
; }
; }
; // Dados de pixels começam após o cabeçalho
; dados = cursor;
       move.l    D2,D5
; // Calcular o número de bytes por linha (cada byte representa 8 pixels)
; bytes_por_linha = (largura + 7) / 8;
       move.l    -4(A6),D0
       addq.l    #7,D0
       move.l    D0,-(A7)
       pea       8
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D7
; // Processar os dados de pixels
; for (y = 0; y < altura; y++)
       clr.l     D4
putImagePbmP4_17:
       cmp.l     A5,D4
       bge       putImagePbmP4_19
; {
; linha = dados + y * bytes_por_linha;
       move.l    D5,D0
       move.l    D4,-(A7)
       move.l    D7,-(A7)
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,A4
; // Enviar cada byte da linha para o vídeo
; ixx = ix;
       move.w    14(A6),D0
       and.l     #65535,D0
       move.l    D0,D6
; for (x = 0; x < bytes_por_linha; x++)
       clr.l     D3
putImagePbmP4_20:
       cmp.l     D7,D3
       bge       putImagePbmP4_22
; {
; SetByte(ixx, (iy + y), linha[x], vcorwf, vcorwb2);
       move.b    _vcorwb2.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    _vcorwf.L,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    0(A4,D3.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    18(A6),D1
       and.l     #65535,D1
       add.l     D4,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D6
       move.l    D6,-(A7)
       jsr       _SetByte
       add.w     #20,A7
; ixx += 8;
       addq.l    #8,D6
       addq.l    #1,D3
       bra       putImagePbmP4_20
putImagePbmP4_22:
       addq.l    #1,D4
       bra       putImagePbmP4_17
putImagePbmP4_19:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; }
; #ifndef __EM_OBRAS__
; //-----------------------------------------------------------------------------
; void desenhaIconesUsuario(void) {
; unsigned short vx, vy;
; unsigned char lc, lcok, *ptr_ico, *ptr_prg, *ptr_pos;
; // COLOCAR ICONSPERLINE = 10
; // COLOCAR SPACEICONS = 8
; *next_pos = 0;
; ptr_pos = vFinalOS + (MEM_POS_MGICFG + 16);
; ptr_ico = ptr_pos + 32;
; ptr_prg = ptr_ico + 320;
; for(lc = 0; lc <= (ICONSPERLINE * 4 - 1); lc++) {
; ptr_pos = ptr_pos + lc;
; ptr_ico = ptr_ico + (lc * 10);
; ptr_prg = ptr_prg + (lc * 10);
; if (*ptr_prg != 0 && *ptr_ico != 0) {
; if (*ptr_pos <= (ICONSPERLINE - 1)) {
; vx = COLINIICONS + (24 + SPACEICONS) * *ptr_pos;
; vy = 40;
; }
; else if (*ptr_pos <= (ICONSPERLINE * 2 - 1)) {
; vx = COLINIICONS + (24 + SPACEICONS) * (*ptr_pos - ICONSPERLINE);
; vy = 72;
; }
; else if (*ptr_pos <= (ICONSPERLINE * 3 - 1)) {
; vx = COLINIICONS + (24 + SPACEICONS) * (*ptr_pos - ICONSPERLINE);
; vy = 104;
; }
; else {
; vx = COLINIICONS + (24 + SPACEICONS) * (*ptr_pos - ICONSPERLINE * 2);
; vy = 136;
; }
; lcok = lc + 20;
; SendIcone(lcok);
; MostraIcone(vx, vy, lcok);
; *next_pos = *next_pos + 1;
; }
; }
; }
; //-----------------------------------------------------------------------------
; void SendIcone_24x24(unsigned char vicone)
; {
; unsigned char vnomefile[12];
; unsigned char *ptr_prg;
; unsigned long *ptr_viconef;
; unsigned short ix, iy, iz, pw, ph;
; unsigned char* pimage;
; unsigned char ic;
; ptr_prg = vFinalOS + (MEM_POS_MGICFG + 16) + 32 + 320;
; // Procura Icone no Disco se Nao for Padrao
; if (vicone >= 20)
; {
; vicone -= 20;
; ptr_prg = ptr_prg + (vicone * 10);
; _strcat(vnomefile,*ptr_prg,".ICO");
; loadFile(vnomefile, (unsigned long*)0x00FF9FF8);   // 12K espaco pra carregar arquivo. Colocar logica pra pegar tamanho e alocar espaco
; vicone += 20;
; if (*verro)
; vicone = 9;
; else
; ptr_viconef = viconef;
; }
; if (vicone < 20)
; ptr_viconef = vFinalOS + (MEM_POS_ICONES + (1152 * vicone));
; ic = 0;
; iz = 0;
; pw = 24;
; ph = 24;
; pimage = ptr_viconef;
; // Acumula dados, enviando em 9 vezes de 64 x 16 bits
; *vpicg = 0x04;
; *vpicg = 0xDE;
; *vpicg = pw;
; *vpicg = ph;
; *vpicg = vicone;
; *vpicg = 130;
; *vpicg = 0xDE;
; *vpicg = ic;
; for (ix = 0; ix < 576; ix++)
; {
; *vpicg = *pimage++ & 0x00FF;
; *vpicg = *pimage++ & 0x00FF;
; iz++;
; if (iz == 64 && ic < 8)
; {
; ic++;
; *vpicg = 130;
; *vpicg = 0xDE;
; *vpicg = ic;
; iz = 0;
; }
; }
; }
; //-----------------------------------------------------------------------------
; void SendIcone(unsigned char vicone)
; {
; unsigned char vnomefile[12];
; unsigned char *ptr_prg;
; unsigned long *ptr_viconef;
; unsigned short ix, iy, iz, pw, ph;
; unsigned char* pimage;
; unsigned char ic;
; ptr_prg = vFinalOS + (MEM_POS_MGICFG + 16) + 32 + 320;
; // Procura Icone no Disco se Nao for Padrao
; if (vicone >= 20)
; {
; vicone -= 20;
; ptr_prg = ptr_prg + (vicone * 10);
; _strcat(vnomefile,*ptr_prg,".ICO");
; loadFile(vnomefile, (unsigned long*)0x00FF9FF8);   // 12K espaco pra carregar arquivo. Colocar logica pra pegar tamanho e alocar espaco
; vicone += 20;
; if (*verro)
; vicone = 9;
; else
; ptr_viconef = viconef;
; }
; if (vicone < 20)
; ptr_viconef = vFinalOS + (MEM_POS_ICONES + (4608 * vicone));
; ic = 0;
; iz = 0;
; pw = 48;
; ph = 48;
; pimage = ptr_viconef;
; // Acumula dados, enviando em 36 vezes de 64 x 16 bits
; *vpicg = 0x04;
; *vpicg = 0xDE;
; *vpicg = pw;
; *vpicg = ph;
; *vpicg = vicone;
; *vpicg = 130;
; *vpicg = 0xDE;
; *vpicg = ic;
; for (ix = 0; ix < 2304; ix++)
; {
; *vpicg = *pimage++ & 0x00FF;
; *vpicg = *pimage++ & 0x00FF;
; iz++;
; if (iz == 64 && ic < 35)
; {
; ic++;
; *vpicg = 130;
; *vpicg = 0xDE;
; *vpicg = ic;
; iz = 0;
; }
; }
; }
; //------------------------------------------------------------------------
; void VerifyMouse(unsigned char vtipo) {
; }
; //-------------------------------------------------------------------------
; void new_icon(void) {
; }
; //-------------------------------------------------------------------------
; void del_icon(void) {
; }
; //-------------------------------------------------------------------------
; void mgi_setup(void) {
; }
; //-------------------------------------------------------------------------
; void executeCmd(void) {
; unsigned char vstring[64], vwb;
; vstring[0] = '\0';
; strcpy(vparamstr,"Execute");
; vparam[0] = 10;
; vparam[1] = 40;
; vparam[2] = 280;
; vparam[3] = 50;
; vparam[4] = BTOK | BTCANCEL;
; showWindow();
; writesxy(12,55,1,"Execute:",vcorwf,vcorwb);
; fillin(vstring, 84, 55, 160, WINDISP);
; while (1) {
; fillin(vstring, 84, 55, 160, WINOPER);
; vwb = waitButton();
; if (vwb == BTOK || vwb == BTCANCEL)
; break;
; }
; if (vwb == BTOK) {
; strcpy(vbuf, vstring);
; MostraIcone(144, 104, ICON_HOURGLASS);  // Mostra Ampulheta
; // Chama processador de comandos
; processCmd();
; while (*vxmaxold != 0) {
; vwb = waitButton();
; if (vwb == BTCLOSE)
; break;
; }
; if (*vxmaxold != 0) {
; *vxmax = *vxmaxold;
; *vymax = *vymaxold;
; *vcol = 0;
; *vlin = 0;
; *voverx = 0;
; *vovery = 0;
; *vxmaxold = 0;
; *vymaxold = 0;
; }
; *vbuf = 0x00;  // Zera Buffer do teclado
; }
; }
; //-------------------------------------------------------------------------
; void combobox(unsigned char* vopt, unsigned char *vvar,unsigned char x, unsigned char y, unsigned char vtipo) {
; }
; //-------------------------------------------------------------------------
; void editor(unsigned char* vtexto, unsigned char *vvar,unsigned char x, unsigned char y, unsigned char vtipo) {
; }
; #endif
       section   const
@mgui_1:
       dc.b      47,77,71,85,73,47,73,77,65,71,69,83,47,85,84
       dc.b      73,76,73,84,89,46,80,66,77,0
@mgui_2:
       dc.b      77,71,85,73,0
@mgui_3:
       dc.b      71,114,97,112,104,105,99,97,108,0
@mgui_4:
       dc.b      73,110,116,101,114,102,97,99,101,0
@mgui_5:
       dc.b      118,48,46,55,97,48,50,0
@mgui_6:
       dc.b      76,111,97,100,105,110,103,32,67,111,110,102
       dc.b      105,103,0
@mgui_7:
       dc.b      47,77,71,85,73,47,77,71,85,73,46,67,70,71,0
@mgui_8:
       dc.b      76,111,97,100,105,110,103,32,73,99,111,110,115
       dc.b      32,0
@mgui_9:
       dc.b      73,67,79,70,79,76,68,46,80,66,77,0
@mgui_10:
       dc.b      47,77,71,85,73,47,73,77,65,71,69,83,47,73,67
       dc.b      79,70,79,76,68,46,80,66,77,0
@mgui_11:
       dc.b      73,67,79,82,85,78,46,80,66,77,32,0
@mgui_12:
       dc.b      47,77,71,85,73,47,73,77,65,71,69,83,47,73,67
       dc.b      79,82,85,78,46,80,66,77,0
@mgui_13:
       dc.b      73,67,79,79,83,46,80,66,77,32,32,0
@mgui_14:
       dc.b      47,77,71,85,73,47,73,77,65,71,69,83,47,73,67
       dc.b      79,79,83,46,80,66,77,0
@mgui_15:
       dc.b      73,67,79,83,69,84,46,80,66,77,32,0
@mgui_16:
       dc.b      47,77,71,85,73,47,73,77,65,71,69,83,47,73,67
       dc.b      79,83,69,84,46,80,66,77,0
@mgui_17:
       dc.b      73,67,79,79,70,70,46,80,66,77,32,0
@mgui_18:
       dc.b      47,77,71,85,73,47,73,77,65,71,69,83,47,73,67
       dc.b      79,79,70,70,46,80,66,77,0
@mgui_19:
       dc.b      32,32,32,32,32,32,80,108,101,97,115,101,32,87
       dc.b      97,105,116,46,46,46,32,32,32,32,32,32,32,0
@mgui_20:
       dc.b      79,107,13,10,0
@mgui_21:
       dc.b      35,62,0
@mgui_22:
       dc.b      79,75,0
@mgui_23:
       dc.b      83,84,65,82,84,0
@mgui_24:
       dc.b      67,76,79,83,69,0
@mgui_25:
       dc.b      67,65,78,67,0
@mgui_26:
       dc.b      89,69,83,0
@mgui_27:
       dc.b      78,79,0
@mgui_28:
       dc.b      72,69,76,80,0
@mgui_29:
       dc.b      68,111,32,121,111,117,32,119,97,110,116,32,116
       dc.b      111,32,101,120,105,116,32,63,0
@mgui_30:
       dc.b      70,105,108,101,115,0
@mgui_31:
       dc.b      73,109,112,111,114,116,32,70,105,108,101,0
@mgui_32:
       dc.b      65,98,111,117,116,0
@mgui_33:
       dc.b      47,77,71,85,73,47,80,82,79,71,83,47,70,73,76
       dc.b      69,83,46,66,73,78,0
@mgui_34:
       dc.b      78,111,32,109,101,109,111,114,121,32,116,111
       dc.b      32,108,111,97,100,32,70,73,76,69,83,46,66,73
       dc.b      78,0
@mgui_35:
       dc.b      76,111,97,100,105,110,103,32,69,114,114,111
       dc.b      114,46,46,46,0
@mgui_36:
       dc.b      70,105,108,101,32,110,111,116,32,102,111,117
       dc.b      110,100,46,46,46,10,47,77,71,85,73,47,80,82
       dc.b      79,71,83,47,70,73,76,69,83,46,66,73,78,0
@mgui_37:
       dc.b      77,71,85,73,32,118,48,46,49,10,71,114,97,112
       dc.b      104,105,99,97,108,32,85,115,101,114,32,73,110
       dc.b      116,101,114,102,97,99,101,10,32,10,119,119,119
       dc.b      46,117,116,105,108,105,116,121,105,110,102,46
       dc.b      99,111,109,46,98,114,0
@mgui_38:
       dc.b      82,117,110,32,66,105,110,97,114,121,0
@mgui_39:
       dc.b      70,105,108,101,32,78,97,109,101,58,0
@mgui_40:
       dc.b      69,114,114,111,114,44,32,102,105,108,101,32
       dc.b      110,97,109,101,32,109,117,115,116,32,98,101
       dc.b      32,112,114,111,118,105,100,101,100,33,33,0
@mgui_41:
       dc.b      73,110,118,97,108,105,100,32,102,105,108,101
       dc.b      32,110,97,109,101,32,108,101,110,103,116,104
       dc.b      0
@mgui_42:
       dc.b      46,66,73,78,0
@mgui_43:
       dc.b      79,110,108,121,32,46,66,73,78,32,102,105,108
       dc.b      101,115,32,97,114,101,32,97,108,108,111,119
       dc.b      101,100,0
@mgui_44:
       dc.b      47,77,71,85,73,47,80,82,79,71,83,47,0
@mgui_45:
       dc.b      82,117,110,32,115,101,108,101,99,116,101,100
       dc.b      32,102,105,108,101,32,63,0
@mgui_46:
       dc.b      70,105,108,101,32,110,111,116,32,102,111,117
       dc.b      110,100,46,46,46,0
@mgui_47:
       dc.b      78,111,32,109,101,109,111,114,121,32,116,111
       dc.b      32,108,111,97,100,32,46,66,73,78,0
@mgui_48:
       dc.b      67,111,110,102,105,114,109,32,115,101,114,105
       dc.b      97,108,32,67,111,110,110,101,99,116,101,100
       dc.b      46,10,73,109,112,111,114,116,32,70,105,108,101
       dc.b      32,63,0
@mgui_49:
       dc.b      83,116,97,116,117,115,32,73,109,112,111,114
       dc.b      116,32,70,105,108,101,0
@mgui_50:
       dc.b      68,101,108,101,116,105,110,103,32,70,105,108
       dc.b      101,46,46,46,0
@mgui_51:
       dc.b      67,114,101,97,116,105,110,103,32,70,105,108
       dc.b      101,46,46,46,0
@mgui_52:
       dc.b      82,101,97,100,105,110,103,32,83,101,114,105
       dc.b      97,108,46,46,46,0
@mgui_53:
       dc.b      79,112,101,110,105,110,103,32,70,105,108,101
       dc.b      46,46,46,0
@mgui_54:
       dc.b      87,114,105,116,105,110,103,32,70,105,108,101
       dc.b      46,46,46,0
@mgui_55:
       dc.b      67,108,111,115,105,110,103,32,70,105,108,101
       dc.b      46,46,46,0
@mgui_56:
       dc.b      68,111,110,101,32,33,32,32,32,32,32,32,32,32
       dc.b      32,0
@mgui_57:
       dc.b      87,114,105,116,105,110,103,32,70,105,108,101
       dc.b      32,69,114,114,111,114,32,33,0
@mgui_58:
       dc.b      83,101,114,105,97,108,32,76,111,97,100,32,69
       dc.b      114,114,111,114,46,46,46,0
@mgui_59:
       dc.b      67,114,101,97,116,101,32,70,105,108,101,32,69
       dc.b      114,114,111,114,46,46,46,0
@mgui_60:
       dc.b      80,52,0
@mgui_61:
       dc.b      73,110,118,97,108,105,100,32,111,114,32,117
       dc.b      110,115,117,112,112,111,114,116,101,100,32,80
       dc.b      66,77,32,102,111,114,109,97,116,10,101,120,112
       dc.b      101,99,116,101,100,32,80,52,0
       section   data
       xdef      _vvdgd
_vvdgd:
       dc.l      4194369
       xdef      _vvdgc
_vvdgc:
       dc.l      4194371
       xdef      _imgsMenuSys
_imgsMenuSys:
       dc.l      0
       xdef      _vIndicaDialog
_vIndicaDialog:
       dc.b      0
       section   bss
       xdef      _memPosConfig
_memPosConfig:
       ds.b      1
       xdef      _vFinalOS
_vFinalOS:
       ds.b      1
       xdef      _vcorwf
_vcorwf:
       ds.b      1
       xdef      _vcorwb
_vcorwb:
       ds.b      1
       xdef      _vcorwb2
_vcorwb2:
       ds.b      1
       xdef      _mousePointer
_mousePointer:
       ds.b      4
       xdef      _spthdlmouse
_spthdlmouse:
       ds.b      4
       xdef      _mouseX
_mouseX:
       ds.b      4
       xdef      _mouseY
_mouseY:
       ds.b      1
       xdef      _mouseStat
_mouseStat:
       ds.b      1
       xdef      _mouseMoveX
_mouseMoveX:
       ds.b      1
       xdef      _mouseMoveY
_mouseMoveY:
       ds.b      1
       xdef      _mouseBtnPres
_mouseBtnPres:
       ds.b      1
       xdef      _mouseBtnPresDouble
_mouseBtnPresDouble:
       ds.b      1
       xdef      _statusVdpSprite
_statusVdpSprite:
       ds.b      1
       xdef      _mouseHourGlass
_mouseHourGlass:
       ds.b      4
       xdef      _iconesMenuSys
_iconesMenuSys:
       ds.b      4
       xdef      _vbbutton
_vbbutton:
       ds.b      1
       xdef      _vpostx
_vpostx:
       ds.b      2
       xdef      _vposty
_vposty:
       ds.b      2
       xdef      _pposx
_pposx:
       ds.b      2
       xdef      _pposy
_pposy:
       ds.b      2
       xdef      _vxgmax
_vxgmax:
       ds.b      2
       xdef      _vbuttonwin
_vbuttonwin:
       ds.b      32
       xdef      _vbuttonwiny
_vbuttonwiny:
       ds.b      2
       xdef      _mgui_pattern_table
_mgui_pattern_table:
       ds.b      4
       xdef      _mgui_color_table
_mgui_color_table:
       ds.b      4
       xdef      _mguiVideoFontes
_mguiVideoFontes:
       ds.b      4
       xdef      _fgcolorMgui
_fgcolorMgui:
       ds.b      1
       xdef      _bgcolorMgui
_bgcolorMgui:
       ds.b      1
       xdef      _mx
_mx:
       ds.b      2
       xdef      _my
_my:
       ds.b      2
       xdef      _menyi
_menyi:
       ds.b      16
       xdef      _menyf
_menyf:
       ds.b      16
       xdef      _endSaveMenu
_endSaveMenu:
       ds.b      20
       xdef      _StkFiles
_StkFiles:
       ds.b      4096
       xdef      _StkMouse
_StkMouse:
       ds.b      4096
       xdef      _StkMenu
_StkMenu:
       ds.b      2048
       xdef      _StkMessage
_StkMessage:
       ds.b      2048
       xref      _fsCloseFile
       xref      _fsFindInDir
       xref      _strcpy
       xref      _itoa
       xref      LDIV
       xref      LMUL
       xref      _free
       xref      _atoi
       xref      _OSTaskSuspend
       xref      _strlen
       xref      _OSTCBTbl
       xref      ULMUL
       xref      _fsOpenFile
       xref      _malloc
       xref      _OSTimeDlyHMSM
       xref      _OSTaskDel
       xref      _fsInfoFile
       xref      _strcat
       xref      _verro
       xref      _OSTaskCreate
       xref      _toupper
       xref      _runFromMGUI
       xref      _fsDelFile
       xref      _strcmp
       xref      _OSTaskQuery
       xref      ULDIV
       xref      _loadFile
       xref      _OSTaskResume
       xref      _fsCreateFile
       xref      _fsWriteFile
