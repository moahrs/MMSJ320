; D:\PROJETOS\MMSJ320\MMSJ320VDP.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; #include "mmsj320vdp.h"
; unsigned char *vvdgd = 0x00400041; // VDP TMS9118 Data Mode
; unsigned char *vvdgc = 0x00400043; // VDP TMS9118 Registers/Address Mode
; unsigned char fgcolor;    // Buffer da VRAM 6KB onde o computador vai trabalhar e a cada interrupcao, sera enviado a VRAM
; unsigned char bgcolor; // QTD de BYTES no eixo X (COLS) a srem enviados pra VRAM
; unsigned char videoBufferQtdY; // QTD de BYTES no eixo Y (Rows) a serem enviados pra VRAM
; unsigned int color_table;
; unsigned int sprite_attribute_table; // Contador da quantidade ja enviada acumulada. A cada 2KB, ele esera uma nova interrupcao
; unsigned long videoFontes; // Ponteir para a posicao onde estão as Fontes para vga
; unsigned short videoCursorPosCol;  // Posicao atual caracter do cursor na coluna (0 a 31)
; unsigned short videoCursorPosRow;  // Posical atual caracter do cursor na linha (0 a 23)
; unsigned short videoCursorPosColX;  // Posicao atual do cursor na coluna (0 a 255)
; unsigned short videoCursorPosRowY;  // Posical atual do cursor na linha (0 a 191)
; unsigned char videoCursorBlink; // Cursor piscante (1 = sim, 0 = nao)
; unsigned char videoCursorShow;  // Mostrar Cursor  (1 = sim, 0 = nao)
; unsigned int name_table;
; unsigned char vdp_mode; // Modo de video 0 = caracter (32 x 24), 1 = grafico (256 x 192)
; unsigned char videoScroll;    // Define se quando a linha passar de 23 (0-23), a tela será rolada (0-nao, 1-sim)
; unsigned char videoScrollDir;    // Define a direcao do scroll (1-up, 2-down, 3-left, 4-right)
; unsigned int pattern_table;
; unsigned char sprite_size_sel;
; unsigned char vdpMaxCols; // max col number
; unsigned char vdpMaxRows;
; unsigned char fgcolorAnt; // Cor Anterior de Frente
; unsigned char bgcolorAnt; // Cor Anterior de Fundo
; unsigned int sprite_pattern_table;
; unsigned int color_table_size;
; //-----------------------------------------------------------------------------
; // VDP Functions
; //-----------------------------------------------------------------------------
; void setRegister(unsigned char registerIndex, unsigned char value)
; {
       section   code
       xdef      _setRegister
_setRegister:
       link      A6,#0
; *vvdgc = value;
       move.l    _vvdgc.L,A0
       move.b    15(A6),(A0)
; *vvdgc = (0x80 | registerIndex);
       move.w    #128,D0
       move.b    11(A6),D1
       and.w     #255,D1
       or.w      D1,D0
       move.l    _vvdgc.L,A0
       move.b    D0,(A0)
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned char read_status_reg(void)
; {
       xdef      _read_status_reg
_read_status_reg:
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
; void setWriteAddress(unsigned int address)
; {
       xdef      _setWriteAddress
_setWriteAddress:
       link      A6,#0
; *vvdgc = (unsigned char)(address & 0xff);
       move.l    8(A6),D0
       and.l     #255,D0
       move.l    _vvdgc.L,A0
       move.b    D0,(A0)
; *vvdgc = (unsigned char)(0x40 | (address >> 8) & 0x3f);
       moveq     #64,D0
       ext.w     D0
       ext.l     D0
       move.l    8(A6),D1
       lsr.l     #8,D1
       and.l     #63,D1
       or.l      D1,D0
       move.l    _vvdgc.L,A0
       move.b    D0,(A0)
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void setReadAddress(unsigned int address)
; {
       xdef      _setReadAddress
_setReadAddress:
       link      A6,#0
; *vvdgc = (unsigned char)(address & 0xff);
       move.l    8(A6),D0
       and.l     #255,D0
       move.l    _vvdgc.L,A0
       move.b    D0,(A0)
; *vvdgc = (unsigned char)((address >> 8) & 0x3f);
       move.l    8(A6),D0
       lsr.l     #8,D0
       and.l     #63,D0
       move.l    _vvdgc.L,A0
       move.b    D0,(A0)
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; int vdp_init(unsigned char mode, unsigned char color, unsigned char big_sprites, unsigned char magnify)
; {
       xdef      _vdp_init
_vdp_init:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       _setRegister.L,A2
       lea       _name_table.L,A3
       lea       _pattern_table.L,A4
       lea       _vvdgd.L,A5
       move.b    19(A6),D5
       and.l     #255,D5
       move.b    23(A6),D6
       and.w     #255,D6
; unsigned int i, j;
; unsigned char *tempFontes = videoFontes;
       move.l    _videoFontes.L,D3
; vdp_mode = mode;
       move.b    11(A6),_vdp_mode.L
; sprite_size_sel = big_sprites;
       move.b    D5,_sprite_size_sel.L
; // Clear Ram
; setWriteAddress(0x0);
       clr.l     -(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i < 0x3FFF; i++)
       clr.l     D2
vdp_init_1:
       cmp.l     #16383,D2
       bhs.s     vdp_init_3
; *vvdgd = 0;
       move.l    (A5),A0
       clr.b     (A0)
       addq.l    #1,D2
       bra       vdp_init_1
vdp_init_3:
; switch (mode)
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #4,D0
       bhs       vdp_init_4
       asl.l     #1,D0
       move.w    vdp_init_6(PC,D0.L),D0
       jmp       vdp_init_6(PC,D0.W)
vdp_init_6:
       dc.w      vdp_init_7-vdp_init_6
       dc.w      vdp_init_8-vdp_init_6
       dc.w      vdp_init_9-vdp_init_6
       dc.w      vdp_init_10-vdp_init_6
vdp_init_7:
; {
; case VDP_MODE_G1:
; setRegister(0, 0x00);
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; setRegister(1, 0xC0 | (big_sprites << 1) | magnify); // Ram size 16k, activate video output
       move.w    #192,D1
       move.l    D0,-(A7)
       move.b    D5,D0
       lsl.b     #1,D0
       and.w     #255,D0
       or.w      D0,D1
       move.l    (A7)+,D0
       and.w     #255,D6
       or.w      D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       jsr       (A2)
       addq.w    #8,A7
; setRegister(2, 0x05); // Name table at 0x1400
       pea       5
       pea       2
       jsr       (A2)
       addq.w    #8,A7
; setRegister(3, 0x80); // Color, start at 0x2000
       pea       128
       pea       3
       jsr       (A2)
       addq.w    #8,A7
; setRegister(4, 0x01); // Pattern generator start at 0x800
       pea       1
       pea       4
       jsr       (A2)
       addq.w    #8,A7
; setRegister(5, 0x20); // Sprite attriutes start at 0x1000
       pea       32
       pea       5
       jsr       (A2)
       addq.w    #8,A7
; setRegister(6, 0x00); // Sprite pattern table at 0x000
       clr.l     -(A7)
       pea       6
       jsr       (A2)
       addq.w    #8,A7
; sprite_pattern_table = 0;
       clr.l     _sprite_pattern_table.L
; pattern_table = 0x800;
       move.l    #2048,(A4)
; sprite_attribute_table = 0x1000;
       move.l    #4096,_sprite_attribute_table.L
; name_table = 0x1400;
       move.l    #5120,(A3)
; color_table = 0x2000;
       move.l    #8192,_color_table.L
; color_table_size = 32;
       move.l    #32,_color_table_size.L
; // Initialize pattern table with ASCII patterns
; setWriteAddress(pattern_table + 0x100);
       move.l    (A4),D1
       add.l     #256,D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i < 1784; i++)  // era 768
       clr.l     D2
vdp_init_12:
       cmp.l     #1784,D2
       bhs.s     vdp_init_14
; {
; tempFontes = videoFontes + i;
       move.l    _videoFontes.L,D0
       add.l     D2,D0
       move.l    D0,D3
; *vvdgd = *tempFontes;
       move.l    D3,A0
       move.l    (A5),A1
       move.b    (A0),(A1)
       addq.l    #1,D2
       bra       vdp_init_12
vdp_init_14:
; }
; break;
       bra       vdp_init_5
vdp_init_8:
; case VDP_MODE_G2:
; setRegister(0, 0x02);
       pea       2
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; setRegister(1, 0xC0 | (big_sprites << 1) | magnify); // Ram size 16k, Disable Int, 16x16 Sprites, mag off, activate video output
       move.w    #192,D1
       move.l    D0,-(A7)
       move.b    D5,D0
       lsl.b     #1,D0
       and.w     #255,D0
       or.w      D0,D1
       move.l    (A7)+,D0
       and.w     #255,D6
       or.w      D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       jsr       (A2)
       addq.w    #8,A7
; setRegister(2, 0x0E); // Name table at 0x3800
       pea       14
       pea       2
       jsr       (A2)
       addq.w    #8,A7
; setRegister(3, 0xFF); // Color, start at 0x2000             // segundo manual, deve ser 7F para 0x0000 ou FF para 0x2000
       pea       255
       pea       3
       jsr       (A2)
       addq.w    #8,A7
; setRegister(4, 0x03); // Pattern generator start at 0x000   // segundo manual, deve ser 03 para 0x0000 ou 07 para 0x2000
       pea       3
       pea       4
       jsr       (A2)
       addq.w    #8,A7
; setRegister(5, 0x76); // Sprite attriutes start at 0x3800
       pea       118
       pea       5
       jsr       (A2)
       addq.w    #8,A7
; setRegister(6, 0x03); // Sprite pattern table at 0x1800
       pea       3
       pea       6
       jsr       (A2)
       addq.w    #8,A7
; pattern_table = 0x00;
       clr.l     (A4)
; sprite_pattern_table = 0x1800;
       move.l    #6144,_sprite_pattern_table.L
; color_table = 0x2000;
       move.l    #8192,_color_table.L
; name_table = 0x3800;
       move.l    #14336,(A3)
; sprite_attribute_table = 0x3B00;
       move.l    #15104,_sprite_attribute_table.L
; color_table_size = 0x1800;
       move.l    #6144,_color_table_size.L
; vdpMaxCols = 255;
       move.b    #255,_vdpMaxCols.L
; vdpMaxRows = 191;
       move.b    #191,_vdpMaxRows.L
; setWriteAddress(name_table);
       move.l    (A3),-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i < 768; i++)  // era 768
       clr.l     D2
vdp_init_15:
       cmp.l     #768,D2
       bhs.s     vdp_init_17
; *vvdgd = (unsigned char)(i & 0xFF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A5),A0
       move.b    D0,(A0)
       addq.l    #1,D2
       bra       vdp_init_15
vdp_init_17:
; break;
       bra       vdp_init_5
vdp_init_9:
; case VDP_MODE_MULTICOLOR:
; setRegister(0, 0x00);
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; setRegister(1, 0xC8 | (big_sprites << 1) | magnify); // Ram size 16k, Multicolor
       move.w    #200,D1
       move.l    D0,-(A7)
       move.b    D5,D0
       lsl.b     #1,D0
       and.w     #255,D0
       or.w      D0,D1
       move.l    (A7)+,D0
       and.w     #255,D6
       or.w      D6,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       jsr       (A2)
       addq.w    #8,A7
; setRegister(2, 0x05); // Name table at 0x1400
       pea       5
       pea       2
       jsr       (A2)
       addq.w    #8,A7
; // setRegister(3, 0xFF); // Color table not available
; setRegister(4, 0x01); // Pattern table start at 0x800
       pea       1
       pea       4
       jsr       (A2)
       addq.w    #8,A7
; setRegister(5, 0x76); // Sprite Attribute table at 0x1000
       pea       118
       pea       5
       jsr       (A2)
       addq.w    #8,A7
; setRegister(6, 0x03); // Sprites Pattern Table at 0x0
       pea       3
       pea       6
       jsr       (A2)
       addq.w    #8,A7
; pattern_table = 0x800;
       move.l    #2048,(A4)
; name_table = 0x1400;
       move.l    #5120,(A3)
; vdpMaxCols = 63;
       move.b    #63,_vdpMaxCols.L
; vdpMaxRows = 47;
       move.b    #47,_vdpMaxRows.L
; setWriteAddress(name_table); // Init name table
       move.l    (A3),-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (j = 0; j < 24; j++)
       clr.l     D4
vdp_init_18:
       cmp.l     #24,D4
       bhs       vdp_init_20
; for (i = 0; i < 32; i++)
       clr.l     D2
vdp_init_21:
       cmp.l     #32,D2
       bhs       vdp_init_23
; *vvdgd = (i + 32 * (j / 4));
       move.l    D2,D0
       move.l    D4,-(A7)
       pea       4
       jsr       ULDIV
       move.l    (A7),D1
       addq.w    #8,A7
       move.l    D1,-(A7)
       pea       32
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    (A5),A0
       move.b    D0,(A0)
       addq.l    #1,D2
       bra       vdp_init_21
vdp_init_23:
       addq.l    #1,D4
       bra       vdp_init_18
vdp_init_20:
; break;
       bra       vdp_init_5
vdp_init_10:
; case VDP_MODE_TEXT:
; setRegister(0, 0x00);
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; setRegister(1, 0xD2); // Ram size 16k, Disable Int
       pea       210
       pea       1
       jsr       (A2)
       addq.w    #8,A7
; setRegister(2, 0x02); // Name table at 0x800
       pea       2
       pea       2
       jsr       (A2)
       addq.w    #8,A7
; setRegister(4, 0x00); // Pattern table start at 0x0
       clr.l     -(A7)
       pea       4
       jsr       (A2)
       addq.w    #8,A7
; pattern_table = 0x00;
       clr.l     (A4)
; name_table = 0x800;
       move.l    #2048,(A3)
; vdpMaxCols = 39;
       move.b    #39,_vdpMaxCols.L
; vdpMaxRows = 23;
       move.b    #23,_vdpMaxRows.L
; setWriteAddress(pattern_table + 0x100);
       move.l    (A4),D1
       add.l     #256,D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i < 1784; i++)  // era 768
       clr.l     D2
vdp_init_24:
       cmp.l     #1784,D2
       bhs.s     vdp_init_26
; {
; tempFontes = videoFontes + i;
       move.l    _videoFontes.L,D0
       add.l     D2,D0
       move.l    D0,D3
; *vvdgd = *tempFontes;
       move.l    D3,A0
       move.l    (A5),A1
       move.b    (A0),(A1)
       addq.l    #1,D2
       bra       vdp_init_24
vdp_init_26:
; }
; vdp_textcolor(VDP_WHITE, VDP_BLACK);
       pea       1
       pea       15
       jsr       _vdp_textcolor
       addq.w    #8,A7
; break;
       bra.s     vdp_init_5
vdp_init_4:
; default:
; return VDP_ERROR; // Unsupported mode
       moveq     #1,D0
       bra.s     vdp_init_27
vdp_init_5:
; }
; setRegister(7, color);
       move.b    15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       7
       jsr       (A2)
       addq.w    #8,A7
; return VDP_OK;
       clr.l     D0
vdp_init_27:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_colorize(unsigned char fg, unsigned char bg)
; {
       xdef      _vdp_colorize
_vdp_colorize:
       link      A6,#-8
       move.l    D2,-(A7)
; unsigned int name_offset = videoCursorPosRowY * (vdpMaxCols + 1) + videoCursorPosColX; // Position in name table
       move.w    _videoCursorPosRowY.L,D0
       move.b    _vdpMaxCols.L,D1
       addq.b    #1,D1
       and.w     #255,D1
       mulu.w    D1,D0
       and.l     #65535,D0
       move.w    _videoCursorPosColX.L,D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    D0,-8(A6)
; unsigned int color_offset = name_offset << 3;                      // Offset of pattern in pattern table
       move.l    -8(A6),D0
       lsl.l     #3,D0
       move.l    D0,-4(A6)
; unsigned int i;
; if (vdp_mode != VDP_MODE_G2)
       move.b    _vdp_mode.L,D0
       cmp.b     #1,D0
       beq.s     vdp_colorize_1
; return;
       bra.s     vdp_colorize_6
vdp_colorize_1:
; setWriteAddress(color_table + color_offset);
       move.l    _color_table.L,D1
       add.l     -4(A6),D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i < 8; i++)
       clr.l     D2
vdp_colorize_4:
       cmp.l     #8,D2
       bhs.s     vdp_colorize_6
; *vvdgd = ((fg << 4) + bg);
       move.b    11(A6),D0
       lsl.b     #4,D0
       add.b     15(A6),D0
       move.l    _vvdgd.L,A0
       move.b    D0,(A0)
       addq.l    #1,D2
       bra       vdp_colorize_4
vdp_colorize_6:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_plot_hires(unsigned char x, unsigned char y, unsigned char color1, unsigned char color2)
; {
       xdef      _vdp_plot_hires
_vdp_plot_hires:
       link      A6,#-24
       movem.l   D2/D3/D4/D5/A2/A3/A4/A5,-(A7)
       lea       _vvdgd.L,A2
       lea       _setReadAddress.L,A3
       lea       _color_table.L,A4
       lea       _pattern_table.L,A5
       move.b    11(A6),D5
       and.l     #255,D5
; unsigned int offset, posX, posY, modY;
; unsigned char pixel;
; unsigned char color;
; unsigned char sqtdtam[10];
; posX = (int)(8 * (x / 8));
       move.b    D5,D0
       and.l     #65535,D0
       divu.w    #8,D0
       and.w     #255,D0
       mulu.w    #8,D0
       and.l     #255,D0
       move.l    D0,-22(A6)
; posY = (int)(256 * (y / 8));
       move.b    15(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       and.w     #255,D0
       lsl.w     #8,D0
       ext.l     D0
       move.l    D0,-18(A6)
; modY = (int)(y % 8);
       move.b    15(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       swap      D0
       and.l     #255,D0
       move.l    D0,-14(A6)
; offset = posX + modY + posY;
       move.l    -22(A6),D0
       add.l     -14(A6),D0
       add.l     -18(A6),D0
       move.l    D0,D2
; setReadAddress(pattern_table + offset);
       move.l    (A5),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; setReadAddress(pattern_table + offset);
       move.l    (A5),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; pixel = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D4
; setReadAddress(color_table + offset);
       move.l    (A4),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; setReadAddress(color_table + offset);
       move.l    (A4),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; color = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D3
; if(color1 != 0x00)
       move.b    19(A6),D0
       beq.s     vdp_plot_hires_1
; {
; pixel |= 0x80 >> (x % 8); //Set a "1"
       move.w    #128,D0
       move.b    D5,D1
       and.l     #65535,D1
       divu.w    #8,D1
       swap      D1
       and.w     #255,D1
       asr.w     D1,D0
       or.b      D0,D4
; color = (color & 0x0F) | (color1 << 4);
       move.b    D3,D0
       and.b     #15,D0
       move.b    19(A6),D1
       lsl.b     #4,D1
       or.b      D1,D0
       move.b    D0,D3
       bra       vdp_plot_hires_2
vdp_plot_hires_1:
; }
; else
; {
; pixel &= ~(0x80 >> (x % 8)); //Set bit as "0"
       move.w    #128,D0
       move.b    D5,D1
       and.l     #65535,D1
       divu.w    #8,D1
       swap      D1
       and.w     #255,D1
       asr.w     D1,D0
       not.w     D0
       and.b     D0,D4
; color = (color & 0xF0) | (color2 & 0x0F);
       move.b    D3,D0
       and.w     #255,D0
       and.w     #240,D0
       move.b    23(A6),D1
       and.b     #15,D1
       and.w     #255,D1
       or.w      D1,D0
       move.b    D0,D3
vdp_plot_hires_2:
; }
; setWriteAddress(pattern_table + offset);
       move.l    (A5),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; *vvdgd = (pixel);
       move.l    (A2),A0
       move.b    D4,(A0)
; setWriteAddress(color_table + offset);
       move.l    (A4),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; *vvdgd = (color);
       move.l    (A2),A0
       move.b    D3,(A0)
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_plot_color(unsigned char x, unsigned char y, unsigned char color)
; {
       xdef      _vdp_plot_color
_vdp_plot_color:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7)
       lea       _vvdgd.L,A2
       move.b    19(A6),D3
       and.l     #255,D3
       move.b    15(A6),D5
       and.l     #255,D5
       move.b    11(A6),D6
       and.l     #255,D6
       lea       _setWriteAddress.L,A3
; unsigned int addr = pattern_table + 8 * (x / 2) + y % 8 + 256 * (y / 8);
       move.l    _pattern_table.L,D0
       move.b    D6,D1
       and.l     #65535,D1
       divu.w    #2,D1
       and.w     #255,D1
       mulu.w    #8,D1
       and.l     #255,D1
       add.l     D1,D0
       move.b    D5,D1
       and.l     #65535,D1
       divu.w    #8,D1
       swap      D1
       and.l     #255,D1
       add.l     D1,D0
       move.b    D5,D1
       and.l     #65535,D1
       divu.w    #8,D1
       and.w     #255,D1
       lsl.w     #8,D1
       ext.l     D1
       add.l     D1,D0
       move.l    D0,A4
; unsigned char dot = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D7
; unsigned int offset = 8 * (x / 2) + y % 8 + 256 * (y / 8);
       move.b    D6,D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.w     #255,D0
       mulu.w    #8,D0
       and.l     #65535,D0
       move.b    D5,D1
       and.l     #65535,D1
       divu.w    #8,D1
       swap      D1
       and.l     #255,D1
       add.l     D1,D0
       move.b    D5,D1
       and.l     #65535,D1
       divu.w    #8,D1
       and.l     #255,D1
       lsl.l     #8,D1
       add.l     D1,D0
       move.l    D0,D4
; unsigned char color_ = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D2
; if (vdp_mode == VDP_MODE_MULTICOLOR)
       move.b    _vdp_mode.L,D0
       cmp.b     #2,D0
       bne       vdp_plot_color_1
; {
; setReadAddress(addr);
       move.l    A4,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; setWriteAddress(addr);
       move.l    A4,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; if (x & 1) // Odd columns
       move.b    D6,D0
       and.b     #1,D0
       beq.s     vdp_plot_color_3
; *vvdgd = ((dot & 0xF0) + (color & 0x0f));
       move.b    D7,D0
       and.w     #255,D0
       and.w     #240,D0
       move.b    D3,D1
       and.b     #15,D1
       and.w     #255,D1
       add.w     D1,D0
       move.l    (A2),A0
       move.b    D0,(A0)
       bra.s     vdp_plot_color_4
vdp_plot_color_3:
; else
; *vvdgd = ((dot & 0x0F) + (color << 4));
       move.b    D7,D0
       and.b     #15,D0
       move.b    D3,D1
       lsl.b     #4,D1
       add.b     D1,D0
       move.l    (A2),A0
       move.b    D0,(A0)
vdp_plot_color_4:
       bra       vdp_plot_color_5
vdp_plot_color_1:
; }
; else if (vdp_mode == VDP_MODE_G2)
       move.b    _vdp_mode.L,D0
       cmp.b     #1,D0
       bne       vdp_plot_color_5
; {
; // Draw bitmap
; setReadAddress(color_table + offset);
       move.l    _color_table.L,D1
       add.l     D4,D1
       move.l    D1,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; if((x & 1) == 0) //Even
       move.b    D6,D0
       and.b     #1,D0
       bne.s     vdp_plot_color_7
; {
; color_ &= 0x0F;
       and.b     #15,D2
; color_ |= (color << 4);
       move.b    D3,D0
       lsl.b     #4,D0
       or.b      D0,D2
       bra.s     vdp_plot_color_8
vdp_plot_color_7:
; }
; else
; {
; color_ &= 0xF0;
       and.b     #240,D2
; color_ |= color & 0x0F;
       move.b    D3,D0
       and.b     #15,D0
       or.b      D0,D2
vdp_plot_color_8:
; }
; setWriteAddress(pattern_table + offset);
       move.l    _pattern_table.L,D1
       add.l     D4,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; *vvdgd = (0xF0);
       move.l    (A2),A0
       move.b    #240,(A0)
; setWriteAddress(color_table + offset);
       move.l    _color_table.L,D1
       add.l     D4,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; *vvdgd = (color_);
       move.l    (A2),A0
       move.b    D2,(A0)
vdp_plot_color_5:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
       unlk      A6
       rts
; // Colorize
; }
; }
; //-----------------------------------------------------------------------------
; void vdp_set_sprite_pattern(unsigned char number, const unsigned char *sprite)
; {
       xdef      _vdp_set_sprite_pattern
_vdp_set_sprite_pattern:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned char i;
; if(sprite_size_sel)
       tst.b     _sprite_size_sel.L
       beq       vdp_set_sprite_pattern_1
; {
; setWriteAddress(sprite_pattern_table + (32 * number));
       move.l    _sprite_pattern_table.L,D1
       move.l    D0,-(A7)
       move.b    11(A6),D0
       and.w     #255,D0
       mulu.w    #32,D0
       and.l     #255,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i<32; i++)
       clr.b     D2
vdp_set_sprite_pattern_3:
       cmp.b     #32,D2
       bhs.s     vdp_set_sprite_pattern_5
; {
; *vvdgd = (sprite[i]);
       move.l    12(A6),A0
       and.l     #255,D2
       move.l    _vvdgd.L,A1
       move.b    0(A0,D2.L),(A1)
       addq.b    #1,D2
       bra       vdp_set_sprite_pattern_3
vdp_set_sprite_pattern_5:
       bra       vdp_set_sprite_pattern_8
vdp_set_sprite_pattern_1:
; }
; }
; else
; {
; setWriteAddress(sprite_pattern_table + (8 * number));
       move.l    _sprite_pattern_table.L,D1
       move.l    D0,-(A7)
       move.b    11(A6),D0
       and.w     #255,D0
       mulu.w    #8,D0
       and.l     #255,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i<8; i++)
       clr.b     D2
vdp_set_sprite_pattern_6:
       cmp.b     #8,D2
       bhs.s     vdp_set_sprite_pattern_8
; {
; *vvdgd = (sprite[i]);
       move.l    12(A6),A0
       and.l     #255,D2
       move.l    _vvdgd.L,A1
       move.b    0(A0,D2.L),(A1)
       addq.b    #1,D2
       bra       vdp_set_sprite_pattern_6
vdp_set_sprite_pattern_8:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; }
; //-----------------------------------------------------------------------------
; void vdp_sprite_color(unsigned int addr, unsigned char color)
; {
       xdef      _vdp_sprite_color
_vdp_sprite_color:
       link      A6,#-4
; unsigned char ecclr;
; setReadAddress(addr + 3);
       move.l    8(A6),D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; ecclr = *vvdgd & 0x80 | (color & 0x0F);
       move.l    _vvdgd.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       and.w     #128,D0
       move.b    15(A6),D1
       and.b     #15,D1
       and.w     #255,D1
       or.w      D1,D0
       move.b    D0,-1(A6)
; setWriteAddress(addr + 3);
       move.l    8(A6),D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; *vvdgd = (ecclr);
       move.l    _vvdgd.L,A0
       move.b    -1(A6),(A0)
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; Sprite_attributes vdp_sprite_get_attributes(unsigned int addr)
; {
       xdef      _vdp_sprite_get_attributes
_vdp_sprite_get_attributes:
       link      A6,#-4
       movem.l   A2/A3,-(A7)
       lea       -4(A6),A2
       lea       _vvdgd.L,A3
; Sprite_attributes attrs;
; setReadAddress(addr);
       move.l    12(A6),-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; attrs.y = *vvdgd;
       move.l    (A3),A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    (A0),1(A1)
; attrs.x = *vvdgd;
       move.l    (A3),A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    (A0),(A1)
; attrs.name_ptr = *vvdgd;
       move.l    (A3),A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    (A0),2(A1)
; attrs.ecclr = *vvdgd;
       move.l    (A3),A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    (A0),3(A1)
; return attrs;
       move.l    A2,A0
       move.l    8(A6),A1
       move.l    (A0)+,(A1)+
       move.l    8(A6),D0
       movem.l   (A7)+,A2/A3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; Sprite_attributes vdp_sprite_get_position(unsigned int addr)
; {
       xdef      _vdp_sprite_get_position
_vdp_sprite_get_position:
       link      A6,#-8
       movem.l   D2/A2/A3,-(A7)
       lea       _vvdgd.L,A2
       lea       -4(A6),A3
; unsigned char x;
; unsigned char eccr;
; unsigned char vdumbread;
; Sprite_attributes attrs;
; setReadAddress(addr);
       move.l    12(A6),-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; attrs.y = *vvdgd;
       move.l    (A2),A0
       move.l    A3,D0
       move.l    D0,A1
       move.b    (A0),1(A1)
; x = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D2
; vdumbread = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),-5(A6)
; eccr = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),-6(A6)
; attrs.x = eccr & 0x80 ? x : x+32;
       move.b    -6(A6),D0
       and.w     #255,D0
       and.w     #128,D0
       beq.s     vdp_sprite_get_position_1
       move.b    D2,D0
       bra.s     vdp_sprite_get_position_2
vdp_sprite_get_position_1:
       move.b    D2,D0
       add.b     #32,D0
vdp_sprite_get_position_2:
       move.l    A3,D1
       move.l    D1,A0
       move.b    D0,(A0)
; return attrs;
       move.l    A3,A0
       move.l    8(A6),A1
       move.l    (A0)+,(A1)+
       move.l    8(A6),D0
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned int vdp_sprite_init(unsigned char name, unsigned char priority, unsigned char color)
; {
       xdef      _vdp_sprite_init
_vdp_sprite_init:
       link      A6,#0
       movem.l   D2/D3/D4/A2,-(A7)
       lea       _vvdgd.L,A2
       move.b    11(A6),D4
       and.l     #255,D4
; unsigned int addr = sprite_attribute_table + 4*priority;
       move.l    _sprite_attribute_table.L,D0
       move.b    15(A6),D1
       and.w     #255,D1
       mulu.w    #4,D1
       and.l     #255,D1
       add.l     D1,D0
       move.l    D0,D3
; unsigned char byteVdp;
; while (1)
vdp_sprite_init_1:
; {
; setWriteAddress(addr);
       move.l    D3,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; *vvdgd = (0);
       move.l    (A2),A0
       clr.b     (A0)
; *vvdgd = (0);
       move.l    (A2),A0
       clr.b     (A0)
; if(sprite_size_sel)
       tst.b     _sprite_size_sel.L
       beq.s     vdp_sprite_init_4
; *vvdgd = (4*name);
       move.b    D4,D0
       and.w     #255,D0
       mulu.w    #4,D0
       move.l    (A2),A0
       move.b    D0,(A0)
       bra.s     vdp_sprite_init_5
vdp_sprite_init_4:
; else
; *vvdgd = (4*name);
       move.b    D4,D0
       and.w     #255,D0
       mulu.w    #4,D0
       move.l    (A2),A0
       move.b    D0,(A0)
vdp_sprite_init_5:
; *vvdgd = (0x80 | (color & 0xF));
       move.w    #128,D0
       move.b    19(A6),D1
       and.b     #15,D1
       and.w     #255,D1
       or.w      D1,D0
       move.l    (A2),A0
       move.b    D0,(A0)
; setReadAddress(addr);
       move.l    D3,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; setReadAddress(addr);
       move.l    D3,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; byteVdp = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D2
; if (byteVdp != 0)
       tst.b     D2
       beq.s     vdp_sprite_init_6
; continue;
       bra       vdp_sprite_init_2
vdp_sprite_init_6:
; byteVdp = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D2
; if (byteVdp != 0)
       tst.b     D2
       beq.s     vdp_sprite_init_8
; continue;
       bra       vdp_sprite_init_2
vdp_sprite_init_8:
; byteVdp = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D2
; if (byteVdp != (4*name))
       move.b    D4,D0
       and.w     #255,D0
       mulu.w    #4,D0
       cmp.b     D0,D2
       beq.s     vdp_sprite_init_10
; continue;
       bra.s     vdp_sprite_init_2
vdp_sprite_init_10:
; byteVdp = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),D2
; if (byteVdp != (0x80 | (color & 0xF)))
       and.w     #255,D2
       move.w    #128,D0
       move.b    19(A6),D1
       and.b     #15,D1
       and.w     #255,D1
       or.w      D1,D0
       cmp.w     D0,D2
       beq.s     vdp_sprite_init_12
; continue;
       bra.s     vdp_sprite_init_2
vdp_sprite_init_12:
; break;
       bra.s     vdp_sprite_init_3
vdp_sprite_init_2:
       bra       vdp_sprite_init_1
vdp_sprite_init_3:
; }
; return addr;
       move.l    D3,D0
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned char vdp_sprite_set_position(unsigned int addr, unsigned int x, unsigned char y)
; {
       xdef      _vdp_sprite_set_position
_vdp_sprite_set_position:
       link      A6,#-4
       movem.l   D2/A2/A3,-(A7)
       move.l    8(A6),D2
       lea       _vvdgd.L,A2
       lea       _setWriteAddress.L,A3
; unsigned char ec, xpos;
; unsigned char color;
; xpos = (unsigned char)(x & 0xFF);
       move.l    12(A6),D0
       and.l     #255,D0
       move.b    D0,-2(A6)
; ec = 0;
       clr.b     -3(A6)
; setReadAddress(addr + 3);
       move.l    D2,D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; setReadAddress(addr + 3);
       move.l    D2,D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; color = *vvdgd & 0x0f;
       move.l    (A2),A0
       move.b    (A0),D0
       and.b     #15,D0
       move.b    D0,-1(A6)
; setWriteAddress(addr);
       move.l    D2,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; *vvdgd = y;
       move.l    (A2),A0
       move.b    19(A6),(A0)
; setWriteAddress(addr + 1);
       move.l    D2,D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; *vvdgd = xpos;
       move.l    (A2),A0
       move.b    -2(A6),(A0)
; setWriteAddress(addr + 3);
       move.l    D2,D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; *vvdgd = ((ec << 7) | color);
       move.b    -3(A6),D0
       lsl.b     #7,D0
       or.b      -1(A6),D0
       move.l    (A2),A0
       move.b    D0,(A0)
; return read_status_reg();
       jsr       _read_status_reg
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_set_bdcolor(unsigned char color)
; {
       xdef      _vdp_set_bdcolor
_vdp_set_bdcolor:
       link      A6,#0
; setRegister(7, color);
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       7
       jsr       _setRegister
       addq.w    #8,A7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_set_pattern_color(unsigned int index, unsigned char fg, unsigned char bg)
; {
       xdef      _vdp_set_pattern_color
_vdp_set_pattern_color:
       link      A6,#0
; if (vdp_mode == VDP_MODE_G1)
       move.b    _vdp_mode.L,D0
       bne.s     vdp_set_pattern_color_1
; {
; index &= 31;
       and.l     #31,8(A6)
vdp_set_pattern_color_1:
; }
; setWriteAddress(color_table + index);
       move.l    _color_table.L,D1
       add.l     8(A6),D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; *vvdgd = ((fg << 4) + bg);
       move.b    15(A6),D0
       lsl.b     #4,D0
       add.b     19(A6),D0
       move.l    _vvdgd.L,A0
       move.b    D0,(A0)
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_set_cursor(unsigned char pcol, unsigned char prow)
; {
       xdef      _vdp_set_cursor
_vdp_set_cursor:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.b    15(A6),D2
       and.l     #255,D2
       move.b    11(A6),D3
       and.l     #255,D3
; if (pcol == 255) //<0
       and.w     #255,D3
       cmp.w     #255,D3
       bne.s     vdp_set_cursor_1
; {
; pcol = vdpMaxCols;
       move.b    _vdpMaxCols.L,D3
; prow--;
       subq.b    #1,D2
       bra.s     vdp_set_cursor_3
vdp_set_cursor_1:
; }
; else if (pcol > vdpMaxCols)
       cmp.b     _vdpMaxCols.L,D3
       bls.s     vdp_set_cursor_3
; {
; pcol = 0;
       clr.b     D3
; prow++;
       addq.b    #1,D2
vdp_set_cursor_3:
; }
; if (prow == 255)
       and.w     #255,D2
       cmp.w     #255,D2
       bne.s     vdp_set_cursor_5
; {
; prow = vdpMaxRows;
       move.b    _vdpMaxRows.L,D2
       bra.s     vdp_set_cursor_7
vdp_set_cursor_5:
; }
; else if (prow > vdpMaxRows)
       cmp.b     _vdpMaxRows.L,D2
       bls.s     vdp_set_cursor_7
; {
; prow = vdpMaxRows; //0;
       move.b    _vdpMaxRows.L,D2
; geraScroll();
       jsr       _geraScroll
vdp_set_cursor_7:
; }
; videoCursorPosColX = pcol;
       and.w     #255,D3
       move.w    D3,_videoCursorPosColX.L
; videoCursorPosRowY = prow;
       and.w     #255,D2
       move.w    D2,_videoCursorPosRowY.L
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; VDP_COORD vdp_get_cursor(void)
; {
       xdef      _vdp_get_cursor
_vdp_get_cursor:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       -4(A6),A2
; VDP_COORD cursor;
; cursor.x = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,D0
       move.l    A2,D1
       move.l    D1,A0
       move.b    D0,(A0)
; cursor.y = videoCursorPosRowY;
       move.w    _videoCursorPosRowY.L,D0
       move.l    A2,D1
       move.l    D1,A0
       move.b    D0,1(A0)
; cursor.maxx = vdpMaxCols;
       move.l    A2,D0
       move.l    D0,A0
       move.b    _vdpMaxCols.L,2(A0)
; cursor.maxy = vdpMaxRows;
       move.l    A2,D0
       move.l    D0,A0
       move.b    _vdpMaxRows.L,3(A0)
; return cursor;
       move.l    A2,A0
       move.l    8(A6),A1
       move.l    (A0)+,(A1)+
       move.l    8(A6),D0
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; VDP_COLOR vdp_get_color(void)
; {
       xdef      _vdp_get_color
_vdp_get_color:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       -2(A6),A2
; VDP_COLOR cores;
; cores.fg = fgcolor;
       move.l    A2,D0
       move.l    D0,A0
       move.b    _fgcolor.L,(A0)
; cores.bg = bgcolor;
       move.l    A2,D0
       move.l    D0,A0
       move.b    _bgcolor.L,1(A0)
; return cores;
       move.l    A2,A0
       move.l    8(A6),A1
       moveq     #-1,D0
       move.l    (A0)+,(A1)+
       dbra      D0,*-2
       move.w    (A0)+,(A1)+
       move.l    8(A6),D0
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_get_cfg(unsigned int *pat, unsigned int *cor)
; {
       xdef      _vdp_get_cfg
_vdp_get_cfg:
       link      A6,#0
; *pat = pattern_table;
       move.l    8(A6),A0
       move.l    _pattern_table.L,(A0)
; *cor = color_table;
       move.l    12(A6),A0
       move.l    _color_table.L,(A0)
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned long getVideoFontes(void)
; {
       xdef      _getVideoFontes
_getVideoFontes:
; return videoFontes;
       move.l    _videoFontes.L,D0
       rts
; }
; //-----------------------------------------------------------------------------
; void vdp_set_cursor_pos(unsigned char direction)
; {
       xdef      _vdp_set_cursor_pos
_vdp_set_cursor_pos:
       link      A6,#0
       movem.l   D2/A2,-(A7)
       lea       _vdp_set_cursor.L,A2
; unsigned char pMoveId = 1;
       moveq     #1,D2
; if (vdp_mode != VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       beq.s     vdp_set_cursor_pos_1
; pMoveId = 8;
       moveq     #8,D2
vdp_set_cursor_pos_1:
; switch (direction)
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #4,D0
       bhs       vdp_set_cursor_pos_4
       asl.l     #1,D0
       move.w    vdp_set_cursor_pos_5(PC,D0.L),D0
       jmp       vdp_set_cursor_pos_5(PC,D0.W)
vdp_set_cursor_pos_5:
       dc.w      vdp_set_cursor_pos_6-vdp_set_cursor_pos_5
       dc.w      vdp_set_cursor_pos_7-vdp_set_cursor_pos_5
       dc.w      vdp_set_cursor_pos_8-vdp_set_cursor_pos_5
       dc.w      vdp_set_cursor_pos_9-vdp_set_cursor_pos_5
vdp_set_cursor_pos_6:
; {
; case VDP_CSR_UP:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY - pMoveId);
       move.w    _videoCursorPosRowY.L,D1
       and.w     #255,D2
       sub.w     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; break;
       bra       vdp_set_cursor_pos_4
vdp_set_cursor_pos_7:
; case VDP_CSR_DOWN:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY + pMoveId);
       move.w    _videoCursorPosRowY.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; break;
       bra       vdp_set_cursor_pos_4
vdp_set_cursor_pos_8:
; case VDP_CSR_LEFT:
; vdp_set_cursor(videoCursorPosColX - pMoveId, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.w     #255,D2
       sub.w     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; break;
       bra.s     vdp_set_cursor_pos_4
vdp_set_cursor_pos_9:
; case VDP_CSR_RIGHT:
; vdp_set_cursor(videoCursorPosColX + pMoveId, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.w     #255,D2
       add.w     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; break;
vdp_set_cursor_pos_4:
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void vdp_write(unsigned char chr)
; {
       xdef      _vdp_write
_vdp_write:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7)
       lea       _videoFontes.L,A3
; unsigned int name_offset = videoCursorPosRowY * (vdpMaxCols + 1) + videoCursorPosColX; // Position in name table
       move.w    _videoCursorPosRowY.L,D0
       move.b    _vdpMaxCols.L,D1
       addq.b    #1,D1
       and.w     #255,D1
       mulu.w    D1,D0
       and.l     #65535,D0
       move.w    _videoCursorPosColX.L,D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    D0,A4
; unsigned int pattern_offset = name_offset << 3;                    // Offset of pattern in pattern table
       move.l    A4,D0
       lsl.l     #3,D0
       move.l    D0,-4(A6)
; char i, ix;
; unsigned short vAntX, vAntY;
; unsigned char *tempFontes = videoFontes;
       move.l    (A3),D6
; unsigned long vEndFont, vEndPart;
; if (vdp_mode == VDP_MODE_G2)
       move.b    _vdp_mode.L,D0
       cmp.b     #1,D0
       bne       vdp_write_1
; {
; vEndPart = chr - 32;
       move.b    11(A6),D0
       and.l     #255,D0
       sub.l     #32,D0
       move.l    D0,D5
; vEndPart = vEndPart << 3;
       lsl.l     #3,D5
; vAntY = videoCursorPosRowY;
       move.w    _videoCursorPosRowY.L,A2
; for (i = 0; i < 8; i++)
       clr.b     D3
vdp_write_3:
       cmp.b     #8,D3
       bge       vdp_write_5
; {
; vEndFont = videoFontes;
       move.l    (A3),D4
; vEndFont += vEndPart + i;
       move.l    D5,D0
       ext.w     D3
       ext.l     D3
       add.l     D3,D0
       add.l     D0,D4
; tempFontes = vEndFont;
       move.l    D4,D6
; vAntX = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,D7
; for (ix = 7; ix >=0; ix--)
       moveq     #7,D2
vdp_write_6:
       cmp.b     #0,D2
       blt       vdp_write_8
; {
; vdp_plot_hires(videoCursorPosColX, videoCursorPosRowY, ((*tempFontes >> ix) & 0x01) ? fgcolor : 0, bgcolor);
       move.b    _bgcolor.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D6,A0
       move.b    (A0),D1
       lsr.b     D2,D1
       and.b     #1,D1
       beq.s     vdp_write_9
       move.b    _fgcolor.L,D1
       bra.s     vdp_write_10
vdp_write_9:
       clr.b     D1
vdp_write_10:
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _vdp_plot_hires
       add.w     #16,A7
; videoCursorPosColX = videoCursorPosColX + 1;
       addq.w    #1,_videoCursorPosColX.L
       subq.b    #1,D2
       bra       vdp_write_6
vdp_write_8:
; }
; videoCursorPosColX = vAntX;
       move.w    D7,_videoCursorPosColX.L
; videoCursorPosRowY = videoCursorPosRowY + 1;
       addq.w    #1,_videoCursorPosRowY.L
       addq.b    #1,D3
       bra       vdp_write_3
vdp_write_5:
; }
; videoCursorPosRowY = vAntY;
       move.w    A2,_videoCursorPosRowY.L
       bra       vdp_write_12
vdp_write_1:
; }
; else if (vdp_mode == VDP_MODE_MULTICOLOR)
       move.b    _vdp_mode.L,D0
       cmp.b     #2,D0
       bne       vdp_write_11
; {
; vEndPart = chr - 32;
       move.b    11(A6),D0
       and.l     #255,D0
       sub.l     #32,D0
       move.l    D0,D5
; vEndPart = vEndPart << 3;
       lsl.l     #3,D5
; vAntY = videoCursorPosRowY;
       move.w    _videoCursorPosRowY.L,A2
; for (i = 0; i < 8; i++)
       clr.b     D3
vdp_write_13:
       cmp.b     #8,D3
       bge       vdp_write_15
; {
; vEndFont = videoFontes;
       move.l    (A3),D4
; vEndFont += vEndPart + i;
       move.l    D5,D0
       ext.w     D3
       ext.l     D3
       add.l     D3,D0
       add.l     D0,D4
; tempFontes = vEndFont;
       move.l    D4,D6
; vAntX = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,D7
; for (ix = 7; ix >=0; ix--)
       moveq     #7,D2
vdp_write_16:
       cmp.b     #0,D2
       blt       vdp_write_18
; {
; vdp_plot_color(videoCursorPosColX, videoCursorPosRowY, ((*tempFontes >> ix) & 0x01) ? fgcolor : bgcolor);
       move.l    D6,A0
       move.b    (A0),D1
       lsr.b     D2,D1
       and.b     #1,D1
       beq.s     vdp_write_19
       move.b    _fgcolor.L,D1
       bra.s     vdp_write_20
vdp_write_19:
       move.b    _bgcolor.L,D1
vdp_write_20:
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _vdp_plot_color
       add.w     #12,A7
; videoCursorPosColX = videoCursorPosColX + 1;
       addq.w    #1,_videoCursorPosColX.L
       subq.b    #1,D2
       bra       vdp_write_16
vdp_write_18:
; }
; videoCursorPosColX = vAntX;
       move.w    D7,_videoCursorPosColX.L
; videoCursorPosRowY = videoCursorPosRowY + 1;
       addq.w    #1,_videoCursorPosRowY.L
       addq.b    #1,D3
       bra       vdp_write_13
vdp_write_15:
; }
; videoCursorPosRowY = vAntY;
       move.w    A2,_videoCursorPosRowY.L
       bra.s     vdp_write_12
vdp_write_11:
; }
; else // G1 and text mode
; {
; setWriteAddress(name_table + name_offset);
       move.l    _name_table.L,D1
       add.l     A4,D1
       move.l    D1,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; *vvdgd = (chr);
       move.l    _vvdgd.L,A0
       move.b    11(A6),(A0)
vdp_write_12:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void vdp_textcolor(unsigned char fg, unsigned char bg)
; {
       xdef      _vdp_textcolor
_vdp_textcolor:
       link      A6,#0
; fgcolor = fg;
       move.b    11(A6),_fgcolor.L
; bgcolor = bg;
       move.b    15(A6),_bgcolor.L
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     vdp_textcolor_1
; setRegister(7, (fg << 4) + bg);
       move.b    11(A6),D1
       lsl.b     #4,D1
       add.b     15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       7
       jsr       _setRegister
       addq.w    #8,A7
vdp_textcolor_1:
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; int vdp_init_textmode(unsigned char fg, unsigned char bg)
; {
       xdef      _vdp_init_textmode
_vdp_init_textmode:
       link      A6,#-4
; unsigned int vret;
; fgcolor = fg;
       move.b    11(A6),_fgcolor.L
; bgcolor = bg;
       move.b    15(A6),_bgcolor.L
; vret = vdp_init(VDP_MODE_TEXT, (fgcolor<<4) | (bgcolor & 0x0f), 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.b    _fgcolor.L,D1
       lsl.b     #4,D1
       move.l    D0,-(A7)
       move.b    _bgcolor.L,D0
       and.b     #15,D0
       or.b      D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       3
       jsr       _vdp_init
       add.w     #16,A7
       move.l    D0,-4(A6)
; return vret;
       move.l    -4(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; int vdp_init_g1(unsigned char fg, unsigned char bg)
; {
       xdef      _vdp_init_g1
_vdp_init_g1:
       link      A6,#-4
; unsigned int vret;
; fgcolor = fg;
       move.b    11(A6),_fgcolor.L
; bgcolor = bg;
       move.b    15(A6),_bgcolor.L
; vret = vdp_init(VDP_MODE_G1, (fgcolor<<4) | (bgcolor & 0x0f), 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.b    _fgcolor.L,D1
       lsl.b     #4,D1
       move.l    D0,-(A7)
       move.b    _bgcolor.L,D0
       and.b     #15,D0
       or.b      D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       jsr       _vdp_init
       add.w     #16,A7
       move.l    D0,-4(A6)
; return vret;
       move.l    -4(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; int vdp_init_g2(unsigned char big_sprites, unsigned char scale_sprites) // 1, false
; {
       xdef      _vdp_init_g2
_vdp_init_g2:
       link      A6,#-4
; unsigned int vret;
; vret = vdp_init(VDP_MODE_G2, 0x0, big_sprites, scale_sprites);
       move.b    15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       pea       1
       jsr       _vdp_init
       add.w     #16,A7
       move.l    D0,-4(A6)
; return vret;
       move.l    -4(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; int vdp_init_multicolor(void)
; {
       xdef      _vdp_init_multicolor
_vdp_init_multicolor:
       link      A6,#-4
; unsigned int vret;
; vret = vdp_init(VDP_MODE_MULTICOLOR, 0, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       pea       2
       jsr       _vdp_init
       add.w     #16,A7
       move.l    D0,-4(A6)
; return vret;
       move.l    -4(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; char vdp_read_color_pixel(unsigned char x, unsigned char y)
; {
       xdef      _vdp_read_color_pixel
_vdp_read_color_pixel:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; char vRetColor = -1;
       moveq     #-1,D3
; unsigned int addr = 0;
       clr.l     D2
; if (vdp_mode == VDP_MODE_MULTICOLOR)
       move.b    _vdp_mode.L,D0
       cmp.b     #2,D0
       bne       vdp_read_color_pixel_4
; {
; addr = pattern_table + 8 * (x / 2) + y % 8 + 256 * (y / 8);
       move.l    _pattern_table.L,D0
       move.b    11(A6),D1
       and.l     #65535,D1
       divu.w    #2,D1
       and.w     #255,D1
       mulu.w    #8,D1
       and.l     #255,D1
       add.l     D1,D0
       move.b    15(A6),D1
       and.l     #65535,D1
       divu.w    #8,D1
       swap      D1
       and.l     #255,D1
       add.l     D1,D0
       move.b    15(A6),D1
       and.l     #65535,D1
       divu.w    #8,D1
       and.w     #255,D1
       lsl.w     #8,D1
       ext.l     D1
       add.l     D1,D0
       move.l    D0,D2
; setReadAddress(addr);
       move.l    D2,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; setReadAddress(addr);
       move.l    D2,-(A7)
       jsr       _setReadAddress
       addq.w    #4,A7
; if (x & 1) // Odd columns
       move.b    11(A6),D0
       and.b     #1,D0
       beq.s     vdp_read_color_pixel_3
; vRetColor = (*vvdgd & 0x0f);
       move.l    _vvdgd.L,A0
       move.b    (A0),D0
       and.b     #15,D0
       move.b    D0,D3
       bra.s     vdp_read_color_pixel_4
vdp_read_color_pixel_3:
; else
; vRetColor = (*vvdgd >> 4);
       move.l    _vvdgd.L,A0
       move.b    (A0),D0
       lsr.b     #4,D0
       move.b    D0,D3
vdp_read_color_pixel_4:
; }
; return vRetColor;
       move.b    D3,D0
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void geraScroll(void)
; {
       xdef      _geraScroll
_geraScroll:
       link      A6,#-44
       movem.l   D2/D3/D4/A2/A3/A4,-(A7)
       lea       _vvdgd.L,A2
       lea       _name_table.L,A3
       lea       _setWriteAddress.L,A4
; unsigned int name_offset = 0; // Position in name table
       clr.l     D3
; unsigned int i, j;
; unsigned char chr[40];
; unsigned char vdumbread;
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne       geraScroll_14
; {
; for (i = 1; i < 24; i++)
       moveq     #1,D4
geraScroll_3:
       cmp.l     #24,D4
       bhs       geraScroll_5
; {
; // Ler Linha
; name_offset = (i * (vdpMaxCols + 1)); // Position in name table
       move.b    _vdpMaxCols.L,D0
       addq.b    #1,D0
       and.l     #255,D0
       move.l    D4,-(A7)
       move.l    D0,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D3
; setWriteAddress((name_table + name_offset));
       move.l    (A3),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #4,A7
; vdumbread = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),-1(A6)
; for (j = 0; j < 40; j++)
       clr.l     D2
geraScroll_6:
       cmp.l     #40,D2
       bhs.s     geraScroll_8
; {
; chr[j] = *vvdgd;
       move.l    (A2),A0
       move.b    (A0),-42(A6,D2.L)
       addq.l    #1,D2
       bra       geraScroll_6
geraScroll_8:
; }
; // Escrever na linha anterior
; name_offset = ((i - 1) * (vdpMaxCols + 1)); // Position in name table
       move.l    D4,D0
       subq.l    #1,D0
       move.b    _vdpMaxCols.L,D1
       addq.b    #1,D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D3
; setWriteAddress((name_table + name_offset));
       move.l    (A3),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #4,A7
; for (j = 0; j < 40; j++)
       clr.l     D2
geraScroll_9:
       cmp.l     #40,D2
       bhs.s     geraScroll_11
; {
; *vvdgd = chr[j];
       move.l    (A2),A0
       move.b    -42(A6,D2.L),(A0)
       addq.l    #1,D2
       bra       geraScroll_9
geraScroll_11:
       addq.l    #1,D4
       bra       geraScroll_3
geraScroll_5:
; }
; }
; // Apaga Ultima Linha
; name_offset = (23 * (vdpMaxCols + 1)); // Position in name table
       move.b    _vdpMaxCols.L,D0
       addq.b    #1,D0
       and.w     #255,D0
       mulu.w    #23,D0
       and.l     #65535,D0
       move.l    D0,D3
; setWriteAddress((name_table + name_offset));
       move.l    (A3),D1
       add.l     D3,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #4,A7
; for (j = 0; j < 40; j++)
       clr.l     D2
geraScroll_12:
       cmp.l     #40,D2
       bhs.s     geraScroll_14
; {
; *vvdgd = 0x00;
       move.l    (A2),A0
       clr.b     (A0)
       addq.l    #1,D2
       bra       geraScroll_12
geraScroll_14:
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4
       unlk      A6
       rts
; }
; }
; }
; //-----------------------------------------------------------------------------
; void clearScr(void)
; {
       xdef      _clearScr
_clearScr:
       move.l    D2,-(A7)
; unsigned int i;
; // Ler Linha
; setWriteAddress(name_table);
       move.l    _name_table.L,-(A7)
       jsr       _setWriteAddress
       addq.w    #4,A7
; for (i = 0; i < 960; i++)
       clr.l     D2
clearScr_1:
       cmp.l     #960,D2
       bhs.s     clearScr_3
; *vvdgd = 0x00;
       move.l    _vvdgd.L,A0
       clr.b     (A0)
       addq.l    #1,D2
       bra       clearScr_1
clearScr_3:
; videoCursorPosColX = 0;
       clr.w     _videoCursorPosColX.L
; videoCursorPosRowY = 0;
       clr.w     _videoCursorPosRowY.L
       move.l    (A7)+,D2
       rts
; #ifdef __MON_SERIAL_VDG__
; writeLongSerial("\r\n\r\n\0");
; writeLongSerial("\033[2J");   // Clear Screeen
; writeLongSerial("\033[H");    // Cursor to Upper left corner
; #endif
; }
; //-----------------------------------------------------------------------------
; void printChar(unsigned char pchr, unsigned char pmove)
; {
       xdef      _printChar
_printChar:
       link      A6,#0
       movem.l   A2/A3,-(A7)
       lea       _vdp_write.L,A2
       lea       _vdp_set_cursor.L,A3
; switch (pchr)
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #13,D0
       beq       printChar_4
       bhi.s     printChar_8
       cmp.l     #10,D0
       beq.s     printChar_3
       bhi       printChar_1
       cmp.l     #8,D0
       beq       printChar_5
       bra       printChar_1
printChar_8:
       cmp.l     #255,D0
       beq       printChar_6
       bra       printChar_1
printChar_3:
; {
; case 0x0A:  // LF
; videoCursorPosRowY = videoCursorPosRowY + 1;
       addq.w    #1,_videoCursorPosRowY.L
; if (videoCursorPosRowY == 24)
       move.w    _videoCursorPosRowY.L,D0
       cmp.w     #24,D0
       bne.s     printChar_9
; {
; videoCursorPosRowY = 23;
       move.w    #23,_videoCursorPosRowY.L
; geraScroll();
       jsr       _geraScroll
printChar_9:
; }
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; break;
       bra       printChar_19
printChar_4:
; case 0x0D:  // CR
; videoCursorPosColX = 0;
       clr.w     _videoCursorPosColX.L
; vdp_set_cursor(0, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       jsr       (A3)
       addq.w    #8,A7
; break;
       bra       printChar_19
printChar_5:
; case 0x08:  // BackSpace
; if (videoCursorPosColX > 0)
       move.w    _videoCursorPosColX.L,D0
       cmp.w     #0,D0
       bls.s     printChar_11
; {
; videoCursorPosColX = videoCursorPosColX - 1;
       subq.w    #1,_videoCursorPosColX.L
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
printChar_11:
; }
; break;
       bra       printChar_19
printChar_6:
; case 0xFF:  // Cursor
; if (videoCursorShow)
       tst.b     _videoCursorShow.L
       beq.s     printChar_13
; vdp_write(0xFE);
       pea       254
       jsr       (A2)
       addq.w    #4,A7
       bra.s     printChar_14
printChar_13:
; else
; vdp_write(0x20);
       pea       32
       jsr       (A2)
       addq.w    #4,A7
printChar_14:
; break;
       bra       printChar_19
printChar_1:
; default:
; vdp_write(pchr);
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     printChar_15
; vdp_colorize(fgcolor, bgcolor);
       move.b    _bgcolor.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolor.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _vdp_colorize
       addq.w    #8,A7
printChar_15:
; if (pmove)
       tst.b     15(A6)
       beq.s     printChar_19
; {
; vdp_set_cursor_pos(VDP_CSR_RIGHT);
       pea       3
       jsr       _vdp_set_cursor_pos
       addq.w    #4,A7
; if (vdp_mode == VDP_MODE_TEXT && videoCursorPosRowY == 24)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     printChar_19
       move.w    _videoCursorPosRowY.L,D0
       cmp.w     #24,D0
       bne.s     printChar_19
; {
; videoCursorPosRowY = 23;
       move.w    #23,_videoCursorPosRowY.L
; geraScroll();
       jsr       _geraScroll
printChar_19:
       movem.l   (A7)+,A2/A3
       unlk      A6
       rts
; }
; }
; }
; }
; //-----------------------------------------------------------------------------
; void printText(unsigned char *msg)
; {
       xdef      _printText
_printText:
       link      A6,#0
; while (*msg)
printText_1:
       move.l    8(A6),A0
       tst.b     (A0)
       beq.s     printText_3
; {
; printChar(*msg++, 1);
       pea       1
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _printChar
       addq.w    #8,A7
       bra       printText_1
printText_3:
       unlk      A6
       rts
; }
; }
       section   data
       xdef      _vvdgd
_vvdgd:
       dc.l      4194369
       xdef      _vvdgc
_vvdgc:
       dc.l      4194371
       section   bss
       xdef      _fgcolor
_fgcolor:
       ds.b      1
       xdef      _bgcolor
_bgcolor:
       ds.b      1
       xdef      _videoBufferQtdY
_videoBufferQtdY:
       ds.b      1
       xdef      _color_table
_color_table:
       ds.b      4
       xdef      _sprite_attribute_table
_sprite_attribute_table:
       ds.b      4
       xdef      _videoFontes
_videoFontes:
       ds.b      4
       xdef      _videoCursorPosCol
_videoCursorPosCol:
       ds.b      2
       xdef      _videoCursorPosRow
_videoCursorPosRow:
       ds.b      2
       xdef      _videoCursorPosColX
_videoCursorPosColX:
       ds.b      2
       xdef      _videoCursorPosRowY
_videoCursorPosRowY:
       ds.b      2
       xdef      _videoCursorBlink
_videoCursorBlink:
       ds.b      1
       xdef      _videoCursorShow
_videoCursorShow:
       ds.b      1
       xdef      _name_table
_name_table:
       ds.b      4
       xdef      _vdp_mode
_vdp_mode:
       ds.b      1
       xdef      _videoScroll
_videoScroll:
       ds.b      1
       xdef      _videoScrollDir
_videoScrollDir:
       ds.b      1
       xdef      _pattern_table
_pattern_table:
       ds.b      4
       xdef      _sprite_size_sel
_sprite_size_sel:
       ds.b      1
       xdef      _vdpMaxCols
_vdpMaxCols:
       ds.b      1
       xdef      _vdpMaxRows
_vdpMaxRows:
       ds.b      1
       xdef      _fgcolorAnt
_fgcolorAnt:
       ds.b      1
       xdef      _bgcolorAnt
_bgcolorAnt:
       ds.b      1
       xdef      _sprite_pattern_table
_sprite_pattern_table:
       ds.b      4
       xdef      _color_table_size
_color_table_size:
       ds.b      4
       xref      ULMUL
       xref      ULDIV
