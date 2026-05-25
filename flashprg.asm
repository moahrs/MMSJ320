; D:\PROJETOS\MMSJ320\PROGS_MONITOR\FLASHPRG.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; /********************************************************************************
; *    Programa    : flashprg.c
; *    Objetivo    : Gravador AT29C020 (LDS/UDS) via XMODEM-1K CRC
; *    Criado em   : 19/04/2026
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * AT29C020: gravacao direta por word (68000 UDS+LDS), setor 256 bytes.
; * SDP desligado de fabrica; 1a gravacao com unlock AA/55/A0 ativa SDP permanente.
; * Endereco flash >= 0x00020000 (monitor 0-1FFFF continua no Arduino Mega).
; *--------------------------------------------------------------------------------*/
; #include <ctype.h>
; #include <string.h>
; #include <stdlib.h>
; #include "../mmsj320api.h"
; #include "../mmsj320vdp.h"
; #include "../mmsj320mfp.h"
; #include "../monitor.h"
; #include "../monitorapi.h"
; #define FP_FLASH_MIN     0x00020000L
; #define FP_FLASH_TOP     0x00080000L
; #define FP_RAM_BASE      ((unsigned char *)0x00850000)
; #define FP_RAM_MAX       0x00030000L
; #define FP_SECTOR_SIZE   512
; /* Unlock SDP/comando: word em endereco par -> LDS+UDS ao mesmo tempo (2x AT29C020) */
; #define FP_CMD5555W ((volatile unsigned short *)0x0000AAAAUL)
; #define FP_CMD2AAAW ((volatile unsigned short *)0x00005554UL)
; static unsigned char fpSectorBuf[FP_SECTOR_SIZE];
; static unsigned long fpHexToLong(const unsigned char *s);
; static void fpPrintHex(unsigned long v);
; static void fpPrintDec(unsigned long v);
; static int fpReadHexAddr(unsigned long *pAddr);
; static int fpAskYesNo(const unsigned char *msg);
; extern void fpIntsOff(void);
; extern void fpIntsOn(void);
; static void fpSdpUnlock(void);
; static int fpPollProgram(unsigned char *p, unsigned char data);
; static int fpProgramSector(unsigned long secAddr, unsigned char *src, int useSdpUnlock);
; static int fpProgramRange(unsigned long dst, unsigned char *src, unsigned long len, int useSdpUnlock);
; static int fpVerifyRange(unsigned long dst, unsigned char *src, unsigned long len);
; static unsigned long fpSectorBase(unsigned long addr);
; static void fpPrintHex(unsigned long v)
; {
       section   code
@flashprg_fpPrintHex:
       link      A6,#-12
; unsigned char buf[12];
; itoa(v, (char *)buf, 16);
       pea       16
       pea       -12(A6)
       move.l    8(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(buf);
       pea       -12(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       unlk      A6
       rts
; }
; static void fpPrintDec(unsigned long v)
; {
@flashprg_fpPrintDec:
       link      A6,#-12
; unsigned char buf[12];
; itoa(v, (char *)buf, 10);
       pea       10
       pea       -12(A6)
       move.l    8(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(buf);
       pea       -12(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       unlk      A6
       rts
; }
; static unsigned long fpHexToLong(const unsigned char *s)
; {
@flashprg_fpHexToLong:
       link      A6,#0
       movem.l   D2/D3/D4,-(A7)
       move.l    8(A6),D3
; unsigned long v = 0;
       clr.l     D4
; unsigned char c;
; while (*s == ' ' || *s == '\t')
@flashprg_fpHexToLong_1:
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     @flashprg_fpHexToLong_4
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       bne.s     @flashprg_fpHexToLong_3
@flashprg_fpHexToLong_4:
; s++;
       addq.l    #1,D3
       bra       @flashprg_fpHexToLong_1
@flashprg_fpHexToLong_3:
; if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #48,D0
       bne.s     @flashprg_fpHexToLong_5
       move.l    D3,A0
       move.b    1(A0),D0
       cmp.b     #120,D0
       beq.s     @flashprg_fpHexToLong_7
       move.l    D3,A0
       move.b    1(A0),D0
       cmp.b     #88,D0
       bne.s     @flashprg_fpHexToLong_5
@flashprg_fpHexToLong_7:
; s += 2;
       addq.l    #2,D3
@flashprg_fpHexToLong_5:
; while (*s)
@flashprg_fpHexToLong_8:
       move.l    D3,A0
       tst.b     (A0)
       beq       @flashprg_fpHexToLong_10
; {
; c = *s++;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    (A0),D2
; if (c >= '0' && c <= '9')
       cmp.b     #48,D2
       blo.s     @flashprg_fpHexToLong_11
       cmp.b     #57,D2
       bhi.s     @flashprg_fpHexToLong_11
; c = (unsigned char)(c - '0');
       move.b    D2,D0
       sub.b     #48,D0
       move.b    D0,D2
       bra       @flashprg_fpHexToLong_16
@flashprg_fpHexToLong_11:
; else if (c >= 'A' && c <= 'F')
       cmp.b     #65,D2
       blo.s     @flashprg_fpHexToLong_13
       cmp.b     #70,D2
       bhi.s     @flashprg_fpHexToLong_13
; c = (unsigned char)(c - 'A' + 10);
       move.b    D2,D0
       sub.b     #65,D0
       add.b     #10,D0
       move.b    D0,D2
       bra.s     @flashprg_fpHexToLong_16
@flashprg_fpHexToLong_13:
; else if (c >= 'a' && c <= 'f')
       cmp.b     #97,D2
       blo.s     @flashprg_fpHexToLong_15
       cmp.b     #102,D2
       bhi.s     @flashprg_fpHexToLong_15
; c = (unsigned char)(c - 'a' + 10);
       move.b    D2,D0
       sub.b     #97,D0
       add.b     #10,D0
       move.b    D0,D2
       bra.s     @flashprg_fpHexToLong_16
@flashprg_fpHexToLong_15:
; else
; break;
       bra.s     @flashprg_fpHexToLong_10
@flashprg_fpHexToLong_16:
; v = (v << 4) | c;
       move.l    D4,D0
       lsl.l     #4,D0
       and.l     #255,D2
       or.l      D2,D0
       move.l    D0,D4
       bra       @flashprg_fpHexToLong_8
@flashprg_fpHexToLong_10:
; }
; return v;
       move.l    D4,D0
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; static int fpReadHexAddr(unsigned long *pAddr)
; {
@flashprg_fpReadHexAddr:
       link      A6,#-16
       movem.l   D2/D3/D4/A2,-(A7)
       lea       -16(A6),A2
; unsigned char buf[16];
; unsigned char *p = buf;
       move.l    A2,D4
; unsigned char c;
; int i = 0;
       clr.l     D3
; buf[0] = 0;
       clr.b     (A2)
; while (i < (int)(sizeof(buf) - 1))
@flashprg_fpReadHexAddr_1:
       cmp.l     #15,D3
       bge       @flashprg_fpReadHexAddr_3
; {
; c = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,D2
; if (c == 0x0D || c == 0x0A)
       cmp.b     #13,D2
       beq.s     @flashprg_fpReadHexAddr_6
       cmp.b     #10,D2
       bne.s     @flashprg_fpReadHexAddr_4
@flashprg_fpReadHexAddr_6:
; break;
       bra       @flashprg_fpReadHexAddr_3
@flashprg_fpReadHexAddr_4:
; if (c == 0x1B)
       cmp.b     #27,D2
       bne.s     @flashprg_fpReadHexAddr_7
; return 0;
       clr.l     D0
       bra       @flashprg_fpReadHexAddr_18
@flashprg_fpReadHexAddr_7:
; if (c == 0x08 || c == 0x7F)
       cmp.b     #8,D2
       beq.s     @flashprg_fpReadHexAddr_12
       cmp.b     #127,D2
       bne.s     @flashprg_fpReadHexAddr_10
@flashprg_fpReadHexAddr_12:
; {
; if (i > 0)
       cmp.l     #0,D3
       ble.s     @flashprg_fpReadHexAddr_13
; {
; i--;
       subq.l    #1,D3
; p[i] = 0;
       move.l    D4,A0
       clr.b     0(A0,D3.L)
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
@flashprg_fpReadHexAddr_13:
; }
; continue;
       bra.s     @flashprg_fpReadHexAddr_15
@flashprg_fpReadHexAddr_10:
; }
; if (c >= 0x20)
       cmp.b     #32,D2
       blo.s     @flashprg_fpReadHexAddr_15
; {
; p[i++] = c;
       move.l    D4,A0
       move.l    D3,D0
       addq.l    #1,D3
       move.b    D2,0(A0,D0.L)
; p[i] = 0;
       move.l    D4,A0
       clr.b     0(A0,D3.L)
; printChar(c, 1);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
@flashprg_fpReadHexAddr_15:
       bra       @flashprg_fpReadHexAddr_1
@flashprg_fpReadHexAddr_3:
; }
; }
; printText("\r\n\0");
       pea       @flashprg_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; *pAddr = fpHexToLong(buf);
       move.l    A2,-(A7)
       jsr       @flashprg_fpHexToLong
       addq.w    #4,A7
       move.l    8(A6),A0
       move.l    D0,(A0)
; return (buf[0] != 0);
       move.b    (A2),D0
       beq.s     @flashprg_fpReadHexAddr_17
       moveq     #1,D0
       bra.s     @flashprg_fpReadHexAddr_18
@flashprg_fpReadHexAddr_17:
       clr.l     D0
@flashprg_fpReadHexAddr_18:
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; static int fpAskYesNo(const unsigned char *msg)
; {
@flashprg_fpAskYesNo:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned char c;
; printText(msg);
       move.l    8(A6),-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; while (1)
@flashprg_fpAskYesNo_1:
; {
; c = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,D2
; if (c == 'Y' || c == 'y')
       cmp.b     #89,D2
       beq.s     @flashprg_fpAskYesNo_6
       cmp.b     #121,D2
       bne.s     @flashprg_fpAskYesNo_4
@flashprg_fpAskYesNo_6:
; {
; printText("Y\r\n\0");
       pea       @flashprg_2.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return 1;
       moveq     #1,D0
       bra.s     @flashprg_fpAskYesNo_7
@flashprg_fpAskYesNo_4:
; }
; if (c == 'N' || c == 'n')
       cmp.b     #78,D2
       beq.s     @flashprg_fpAskYesNo_10
       cmp.b     #110,D2
       bne.s     @flashprg_fpAskYesNo_8
@flashprg_fpAskYesNo_10:
; {
; printText("N\r\n\0");
       pea       @flashprg_3.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return 0;
       clr.l     D0
       bra.s     @flashprg_fpAskYesNo_7
@flashprg_fpAskYesNo_8:
; }
; if (c == 0x1B)
       cmp.b     #27,D2
       bne.s     @flashprg_fpAskYesNo_11
; return 0;
       clr.l     D0
       bra.s     @flashprg_fpAskYesNo_7
@flashprg_fpAskYesNo_11:
       bra       @flashprg_fpAskYesNo_1
@flashprg_fpAskYesNo_7:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; return 0;
; }
; static void fpSdpUnlock(void)
; {
@flashprg_fpSdpUnlock:
; *FP_CMD5555W = 0xAAAA;
       move.w    #43690,43690
; *FP_CMD2AAAW = 0x5555;
       move.w    #21845,21844
; *FP_CMD5555W = 0xA0A0;
       move.w    #41120,43690
       rts
; }
; /*static int fpSectorNeedsProgram(unsigned char *src)
; {
; unsigned int i;
; for (i = 0; i < FP_SECTOR_SIZE; i++)
; {
; if (src[i] != 0xFF)
; return 1;
; }
; return 0;
; }*/
; static int fpSectorDiffers(unsigned long secAddr, unsigned char *src)
; {
@flashprg_fpSectorDiffers:
       link      A6,#-4
       move.l    D2,-(A7)
; unsigned int i;
; volatile unsigned char *flash = (volatile unsigned char *)secAddr;
       move.l    8(A6),-4(A6)
; for (i = 0; i < FP_SECTOR_SIZE; i++)
       clr.l     D2
@flashprg_fpSectorDiffers_1:
       cmp.l     #512,D2
       bhs.s     @flashprg_fpSectorDiffers_3
; {
; if (flash[i] != src[i])
       move.l    -4(A6),A0
       move.l    12(A6),A1
       move.b    0(A0,D2.L),D0
       cmp.b     0(A1,D2.L),D0
       beq.s     @flashprg_fpSectorDiffers_4
; return 1;
       moveq     #1,D0
       bra.s     @flashprg_fpSectorDiffers_6
@flashprg_fpSectorDiffers_4:
       addq.l    #1,D2
       bra       @flashprg_fpSectorDiffers_1
@flashprg_fpSectorDiffers_3:
; }
; return 0;
       clr.l     D0
@flashprg_fpSectorDiffers_6:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; static int fpPollProgramToggle(unsigned char *p)
; {
@flashprg_fpPollProgramToggle:
       link      A6,#-4
       move.l    D2,-(A7)
; unsigned char v1;
; unsigned char v2;
; unsigned long t = 0;
       clr.l     D2
; while (t < 0x00200000L)
@flashprg_fpPollProgramToggle_1:
       cmp.l     #2097152,D2
       bhs.s     @flashprg_fpPollProgramToggle_3
; {
; v1 = *p;
       move.l    8(A6),A0
       move.b    (A0),-2(A6)
; v2 = *p;
       move.l    8(A6),A0
       move.b    (A0),-1(A6)
; if ((v1 & 0x40) != (v2 & 0x40))
       move.b    -2(A6),D0
       and.b     #64,D0
       move.b    -1(A6),D1
       and.b     #64,D1
       cmp.b     D1,D0
       beq.s     @flashprg_fpPollProgramToggle_4
; {
; t++;
       addq.l    #1,D2
; continue;
       bra.s     @flashprg_fpPollProgramToggle_2
@flashprg_fpPollProgramToggle_4:
; }
; return 0;
       clr.l     D0
       bra.s     @flashprg_fpPollProgramToggle_6
@flashprg_fpPollProgramToggle_2:
       bra       @flashprg_fpPollProgramToggle_1
@flashprg_fpPollProgramToggle_3:
; }
; return -2;
       moveq     #-2,D0
@flashprg_fpPollProgramToggle_6:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; static int fpPollProgram(unsigned char *p, unsigned char data)
; {
@flashprg_fpPollProgram:
       link      A6,#-4
       movem.l   D2/D3/D4,-(A7)
       move.l    8(A6),D3
; unsigned char v1;
; unsigned char v2;
; unsigned long t = 0;
       clr.l     D4
; if (data == 0xFF)
       move.b    15(A6),D0
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     @flashprg_fpPollProgram_1
; return fpPollProgramToggle(p);
       move.l    D3,-(A7)
       jsr       @flashprg_fpPollProgramToggle
       addq.w    #4,A7
       bra       @flashprg_fpPollProgram_3
@flashprg_fpPollProgram_1:
; while (t < 0x00200000L)
@flashprg_fpPollProgram_4:
       cmp.l     #2097152,D4
       bhs       @flashprg_fpPollProgram_6
; {
; v1 = *p;
       move.l    D3,A0
       move.b    (A0),D2
; if ((v1 & 0x80) == (data & 0x80))
       move.b    D2,D0
       and.w     #255,D0
       and.w     #128,D0
       move.b    15(A6),D1
       and.w     #255,D1
       and.w     #128,D1
       cmp.w     D1,D0
       bne.s     @flashprg_fpPollProgram_7
; return 0;
       clr.l     D0
       bra.s     @flashprg_fpPollProgram_3
@flashprg_fpPollProgram_7:
; v2 = *p;
       move.l    D3,A0
       move.b    (A0),-1(A6)
; if ((v1 & 0x40) == (v2 & 0x40))
       move.b    D2,D0
       and.b     #64,D0
       move.b    -1(A6),D1
       and.b     #64,D1
       cmp.b     D1,D0
       bne.s     @flashprg_fpPollProgram_9
; return -1;
       moveq     #-1,D0
       bra.s     @flashprg_fpPollProgram_3
@flashprg_fpPollProgram_9:
; t++;
       addq.l    #1,D4
       bra       @flashprg_fpPollProgram_4
@flashprg_fpPollProgram_6:
; }
; return -2;
       moveq     #-2,D0
@flashprg_fpPollProgram_3:
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; /*static int fpLoadSector256(unsigned long secAddr, unsigned char *src)
; {
; unsigned int i;
; unsigned char *flash = (unsigned char *)secAddr;
; // AT29C020: 256 byte loads no latch interno; depois erase+program do setor
; for (i = 0; i < FP_SECTOR_SIZE; i++)
; flash[i] = src[i];
; return fpPollProgram(flash + (FP_SECTOR_SIZE - 1), src[FP_SECTOR_SIZE - 1]);
; }*/
; static int fpLoadSector512(unsigned long secAddr, unsigned char *src)
; {
@flashprg_fpLoadSector512:
       link      A6,#-16
       movem.l   D2/D3/D4,-(A7)
       move.l    12(A6),D3
       move.l    8(A6),D4
; unsigned int i;
; volatile unsigned short *flash;
; unsigned short w;
; int r1, r2;
; flash = (volatile unsigned short *)secAddr;
       move.l    D4,-14(A6)
; for (i = 0; i < FP_SECTOR_SIZE; i += 2)
       clr.l     D2
@flashprg_fpLoadSector512_1:
       cmp.l     #512,D2
       bhs       @flashprg_fpLoadSector512_3
; {
; w = ((unsigned short)src[i] << 8) |
       move.l    D3,A0
       move.b    0(A0,D2.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    D3,A0
       move.l    D2,A1
       move.b    1(A1,A0.L),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-10(A6)
; (unsigned short)src[i + 1];
; flash[i >> 1] = w;
       move.l    -14(A6),A0
       move.l    D2,D0
       lsr.l     #1,D0
       lsl.l     #1,D0
       move.w    -10(A6),0(A0,D0.L)
       addq.l    #2,D2
       bra       @flashprg_fpLoadSector512_1
@flashprg_fpLoadSector512_3:
; }
; r1 = fpPollProgram((unsigned char *)(secAddr + FP_SECTOR_SIZE - 2),
       move.l    D3,A0
       move.b    510(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D4,D1
       add.l     #512,D1
       subq.l    #2,D1
       move.l    D1,-(A7)
       jsr       @flashprg_fpPollProgram
       addq.w    #8,A7
       move.l    D0,-8(A6)
; src[FP_SECTOR_SIZE - 2]);
; r2 = fpPollProgram((unsigned char *)(secAddr + FP_SECTOR_SIZE - 1),
       move.l    D3,A0
       move.b    511(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D4,D1
       add.l     #512,D1
       subq.l    #1,D1
       move.l    D1,-(A7)
       jsr       @flashprg_fpPollProgram
       addq.w    #8,A7
       move.l    D0,-4(A6)
; src[FP_SECTOR_SIZE - 1]);
; if (r1 || r2)
       tst.l     -8(A6)
       bne.s     @flashprg_fpLoadSector512_6
       tst.l     -4(A6)
       beq.s     @flashprg_fpLoadSector512_4
@flashprg_fpLoadSector512_6:
; return -1;
       moveq     #-1,D0
       bra.s     @flashprg_fpLoadSector512_7
@flashprg_fpLoadSector512_4:
; return 0;
       clr.l     D0
@flashprg_fpLoadSector512_7:
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; static int fpProgramSector(unsigned long secAddr, unsigned char *src, int useSdpUnlock)
; {
@flashprg_fpProgramSector:
       link      A6,#0
; if (!fpSectorDiffers(secAddr, src))
       move.l    12(A6),-(A7)
       move.l    8(A6),-(A7)
       jsr       @flashprg_fpSectorDiffers
       addq.w    #8,A7
       tst.l     D0
       bne.s     @flashprg_fpProgramSector_1
; return 0;
       clr.l     D0
       bra       @flashprg_fpProgramSector_3
@flashprg_fpProgramSector_1:
; if (useSdpUnlock)
       tst.l     16(A6)
       beq.s     @flashprg_fpProgramSector_4
; fpSdpUnlock();
       jsr       @flashprg_fpSdpUnlock
@flashprg_fpProgramSector_4:
; if (fpLoadSector512(secAddr, src))
       move.l    12(A6),-(A7)
       move.l    8(A6),-(A7)
       jsr       @flashprg_fpLoadSector512
       addq.w    #8,A7
       tst.l     D0
       beq.s     @flashprg_fpProgramSector_6
; return -1;
       moveq     #-1,D0
       bra.s     @flashprg_fpProgramSector_3
@flashprg_fpProgramSector_6:
; delayms(12);
       pea       12
       move.l    1066,A0
       jsr       (A0)
       addq.w    #4,A7
; return 0;
       clr.l     D0
@flashprg_fpProgramSector_3:
       unlk      A6
       rts
; }
; static unsigned long fpSectorBase(unsigned long addr)
; {
@flashprg_fpSectorBase:
       link      A6,#0
; return addr & ~(unsigned long)(FP_SECTOR_SIZE - 1);
       move.l    8(A6),D0
       move.w    #511,D1
       ext.l     D1
       not.l     D1
       and.l     D1,D0
       unlk      A6
       rts
; }
; static int fpProgramRange(unsigned long dst, unsigned char *src, unsigned long len, int useSdpUnlock)
; {
@flashprg_fpProgramRange:
       link      A6,#-12
       movem.l   D2/D3/D4/A2,-(A7)
       move.l    8(A6),D4
       lea       @flashprg_fpSectorBuf.L,A2
; unsigned long sec;
; unsigned long secEnd;
; unsigned long end;
; unsigned long off;
; unsigned long imgEnd;
; if (dst & 1)
       move.l    D4,D0
       and.l     #1,D0
       beq.s     @flashprg_fpProgramRange_1
; return -10;
       moveq     #-10,D0
       bra       @flashprg_fpProgramRange_3
@flashprg_fpProgramRange_1:
; end = fpSectorBase(dst + len - 1);
       move.l    D4,D1
       add.l     16(A6),D1
       subq.l    #1,D1
       move.l    D1,-(A7)
       jsr       @flashprg_fpSectorBase
       addq.w    #4,A7
       move.l    D0,-8(A6)
; imgEnd = dst + len;
       move.l    D4,D0
       add.l     16(A6),D0
       move.l    D0,-4(A6)
; for (sec = fpSectorBase(dst); sec <= end; sec += FP_SECTOR_SIZE)
       move.l    D4,-(A7)
       jsr       @flashprg_fpSectorBase
       addq.w    #4,A7
       move.l    D0,D3
@flashprg_fpProgramRange_4:
       cmp.l     -8(A6),D3
       bhi       @flashprg_fpProgramRange_6
; {
; secEnd = sec + FP_SECTOR_SIZE;
       move.l    D3,D0
       add.l     #512,D0
       move.l    D0,-12(A6)
; for (off = 0; off < FP_SECTOR_SIZE; off++)
       clr.l     D2
@flashprg_fpProgramRange_7:
       cmp.l     #512,D2
       bhs.s     @flashprg_fpProgramRange_9
; fpSectorBuf[off] = 0xFF;
       move.b    #255,0(A2,D2.L)
       addq.l    #1,D2
       bra       @flashprg_fpProgramRange_7
@flashprg_fpProgramRange_9:
; if (sec < dst)
       cmp.l     D4,D3
       bhs.s     @flashprg_fpProgramRange_10
; off = dst - sec;
       move.l    D4,D0
       sub.l     D3,D0
       move.l    D0,D2
       bra.s     @flashprg_fpProgramRange_11
@flashprg_fpProgramRange_10:
; else
; off = 0;
       clr.l     D2
@flashprg_fpProgramRange_11:
; while (off < FP_SECTOR_SIZE && (sec + off) < imgEnd)
@flashprg_fpProgramRange_12:
       cmp.l     #512,D2
       bhs.s     @flashprg_fpProgramRange_14
       move.l    D3,D0
       add.l     D2,D0
       cmp.l     -4(A6),D0
       bhs.s     @flashprg_fpProgramRange_14
; {
; fpSectorBuf[off] = src[(sec + off) - dst];
       move.l    12(A6),A0
       move.l    D3,D0
       add.l     D2,D0
       sub.l     D4,D0
       move.b    0(A0,D0.L),0(A2,D2.L)
; off++;
       addq.l    #1,D2
       bra       @flashprg_fpProgramRange_12
@flashprg_fpProgramRange_14:
; }
; if ((sec & 0x3FFF) == 0)
       move.l    D3,D0
       and.l     #16383,D0
       bne.s     @flashprg_fpProgramRange_15
; {
; printText("Sector 0x\0");
       pea       @flashprg_4.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex(sec);
       move.l    D3,-(A7)
       jsr       @flashprg_fpPrintHex
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @flashprg_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
@flashprg_fpProgramRange_15:
; }
; if (fpProgramSector(sec, fpSectorBuf, useSdpUnlock))
       move.l    20(A6),-(A7)
       move.l    A2,-(A7)
       move.l    D3,-(A7)
       jsr       @flashprg_fpProgramSector
       add.w     #12,A7
       tst.l     D0
       beq.s     @flashprg_fpProgramRange_17
; return -1;
       moveq     #-1,D0
       bra.s     @flashprg_fpProgramRange_3
@flashprg_fpProgramRange_17:
       add.l     #512,D3
       bra       @flashprg_fpProgramRange_4
@flashprg_fpProgramRange_6:
; }
; return 0;
       clr.l     D0
@flashprg_fpProgramRange_3:
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; static int fpVerifyRange(unsigned long dst, unsigned char *src, unsigned long len)
; {
@flashprg_fpVerifyRange:
       link      A6,#0
       movem.l   D2/D3/A2,-(A7)
       lea       @flashprg_fpPrintHex.L,A2
; unsigned long i;
; unsigned char rv;
; for (i = 0; i < len; i++)
       clr.l     D2
@flashprg_fpVerifyRange_1:
       cmp.l     16(A6),D2
       bhs       @flashprg_fpVerifyRange_3
; {
; rv = *((unsigned char *)(dst + i));
       move.l    8(A6),D0
       add.l     D2,D0
       move.l    D0,A0
       move.b    (A0),D3
; if (rv != src[i])
       move.l    12(A6),A0
       cmp.b     0(A0,D2.L),D3
       beq       @flashprg_fpVerifyRange_4
; {
; printText("Verify fail 0x\0");
       pea       @flashprg_5.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex(dst + i);
       move.l    8(A6),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText(" wr=\0");
       pea       @flashprg_6.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex(src[i]);
       move.l    12(A6),A0
       move.b    0(A0,D2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText(" rd=\0");
       pea       @flashprg_7.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex(rv);
       and.l     #255,D3
       move.l    D3,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @flashprg_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return -1;
       moveq     #-1,D0
       bra.s     @flashprg_fpVerifyRange_6
@flashprg_fpVerifyRange_4:
       addq.l    #1,D2
       bra       @flashprg_fpVerifyRange_1
@flashprg_fpVerifyRange_3:
; }
; }
; return 0;
       clr.l     D0
@flashprg_fpVerifyRange_6:
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/A2,-(A7)
       lea       @flashprg_fpPrintHex.L,A2
; unsigned long flashAddr = 0;
       clr.l     -4(A6)
; unsigned long imgSize = 0;
       clr.l     D2
; unsigned char loadRet;
; int useSdp = 0;
       clr.l     D3
; int st;
; printText("\r\nMMSJ320 Flash Programmer (AT29C020)\r\n\0");
       pea       @flashprg_8.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Sector load 256 bytes, addr >= 0x20000\r\n\0");
       pea       @flashprg_9.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Flash start address (hex, even): \0");
       pea       @flashprg_10.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; if (!fpReadHexAddr(&flashAddr))
       pea       -4(A6)
       jsr       @flashprg_fpReadHexAddr
       addq.w    #4,A7
       tst.l     D0
       bne.s     main_1
; {
; printText("Aborted.\r\n\0");
       pea       @flashprg_11.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_1:
; }
; useSdp = 1;
       moveq     #1,D3
; if (flashAddr < FP_FLASH_MIN)
       move.l    -4(A6),D0
       cmp.l     #131072,D0
       bhs.s     main_4
; {
; printText("Error: address < 0x20000\r\n\0");
       pea       @flashprg_12.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_4:
; }
; if (flashAddr >= FP_FLASH_TOP)
       move.l    -4(A6),D0
       cmp.l     #524288,D0
       blo.s     main_6
; {
; printText("Error: address out of ROM\r\n\0");
       pea       @flashprg_13.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_6:
; }
; if (flashAddr & 1)
       move.l    -4(A6),D0
       and.l     #1,D0
       beq.s     main_8
; {
; printText("Error: address must be even\r\n\0");
       pea       @flashprg_14.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_8:
; }
; printText("Target 0x\0");
       pea       @flashprg_15.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex(flashAddr);
       move.l    -4(A6),-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText(" SDP=\0");
       pea       @flashprg_16.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(useSdp ? "ON\r\n\0" : "OFF\r\n\0");
       tst.l     D3
       beq.s     main_10
       lea       @flashprg_17.L,A0
       bra.s     main_11
main_10:
       lea       @flashprg_18.L,A0
main_11:
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("RAM 0x\0");
       pea       @flashprg_19.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex((unsigned long)FP_RAM_BASE);
       pea       8716288
       jsr       (A2)
       addq.w    #4,A7
; printText("\r\nStart XMODEM now...\r\n\0");
       pea       @flashprg_20.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; loadRet = loadSerialToMem2(FP_RAM_BASE, 1);
       pea       1
       pea       8716288
       move.l    1210,A0
       jsr       (A0)
       addq.w    #8,A7
       move.b    D0,D5
; if (loadRet != 0)
       tst.b     D5
       beq.s     main_12
; {
; printText("XMODEM error \0");
       pea       @flashprg_21.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex(loadRet);
       and.l     #255,D5
       move.l    D5,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @flashprg_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_12:
; }
; imgSize = lstmGetSize();
       move.l    1178,A0
       jsr       (A0)
       move.l    D0,D2
; if (imgSize == 0)
       tst.l     D2
       bne.s     main_14
; {
; printText("Empty image.\r\n\0");
       pea       @flashprg_22.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_14:
; }
; if (imgSize > FP_RAM_MAX)
       cmp.l     #196608,D2
       bls.s     main_16
; {
; printText("Image too big for RAM buffer.\r\n\0");
       pea       @flashprg_23.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_16:
; }
; if ((flashAddr + imgSize) > FP_FLASH_TOP)
       move.l    -4(A6),D0
       add.l     D2,D0
       cmp.l     #524288,D0
       bls.s     main_18
; {
; printText("Image does not fit in ROM.\r\n\0");
       pea       @flashprg_24.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_18:
; }
; printText("Received \0");
       pea       @flashprg_25.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintDec(imgSize);
       move.l    D2,-(A7)
       jsr       @flashprg_fpPrintDec
       addq.w    #4,A7
; printText(" bytes. Programming...\r\n\0");
       pea       @flashprg_26.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpIntsOff();
       jsr       _fpIntsOff
; delayms(6);
       pea       6
       move.l    1066,A0
       jsr       (A0)
       addq.w    #4,A7
; st = fpProgramRange(flashAddr, FP_RAM_BASE, imgSize, useSdp);
       move.l    D3,-(A7)
       move.l    D2,-(A7)
       pea       8716288
       move.l    -4(A6),-(A7)
       jsr       @flashprg_fpProgramRange
       add.w     #16,A7
       move.l    D0,D4
; if (st == 0)
       tst.l     D4
       bne.s     main_20
; st = fpVerifyRange(flashAddr, FP_RAM_BASE, imgSize);
       move.l    D2,-(A7)
       pea       8716288
       move.l    -4(A6),-(A7)
       jsr       @flashprg_fpVerifyRange
       add.w     #12,A7
       move.l    D0,D4
main_20:
; fpIntsOn();
       jsr       _fpIntsOn
; if (st)
       tst.l     D4
       beq.s     main_22
; {
; printText("Flash failed.\r\n\0");
       pea       @flashprg_27.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_24
main_22:
; }
; printText("Flash OK. \0");
       pea       @flashprg_28.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintDec(imgSize);
       move.l    D2,-(A7)
       jsr       @flashprg_fpPrintDec
       addq.w    #4,A7
; printText(" bytes at 0x\0");
       pea       @flashprg_29.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fpPrintHex(flashAddr);
       move.l    -4(A6),-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @flashprg_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; if (useSdp)
       tst.l     D3
       beq.s     main_24
; printText("SDP enabled. Use unlock AA/55/A0 before each sector.\r\n\0");
       pea       @flashprg_30.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_24:
       movem.l   (A7)+,D2/D3/D4/D5/A2
       unlk      A6
       rts
; }
       section   const
@flashprg_1:
       dc.b      13,10,0
@flashprg_2:
       dc.b      89,13,10,0
@flashprg_3:
       dc.b      78,13,10,0
@flashprg_4:
       dc.b      83,101,99,116,111,114,32,48,120,0
@flashprg_5:
       dc.b      86,101,114,105,102,121,32,102,97,105,108,32
       dc.b      48,120,0
@flashprg_6:
       dc.b      32,119,114,61,0
@flashprg_7:
       dc.b      32,114,100,61,0
@flashprg_8:
       dc.b      13,10,77,77,83,74,51,50,48,32,70,108,97,115
       dc.b      104,32,80,114,111,103,114,97,109,109,101,114
       dc.b      32,40,65,84,50,57,67,48,50,48,41,13,10,0
@flashprg_9:
       dc.b      83,101,99,116,111,114,32,108,111,97,100,32,50
       dc.b      53,54,32,98,121,116,101,115,44,32,97,100,100
       dc.b      114,32,62,61,32,48,120,50,48,48,48,48,13,10
       dc.b      0
@flashprg_10:
       dc.b      70,108,97,115,104,32,115,116,97,114,116,32,97
       dc.b      100,100,114,101,115,115,32,40,104,101,120,44
       dc.b      32,101,118,101,110,41,58,32,0
@flashprg_11:
       dc.b      65,98,111,114,116,101,100,46,13,10,0
@flashprg_12:
       dc.b      69,114,114,111,114,58,32,97,100,100,114,101
       dc.b      115,115,32,60,32,48,120,50,48,48,48,48,13,10
       dc.b      0
@flashprg_13:
       dc.b      69,114,114,111,114,58,32,97,100,100,114,101
       dc.b      115,115,32,111,117,116,32,111,102,32,82,79,77
       dc.b      13,10,0
@flashprg_14:
       dc.b      69,114,114,111,114,58,32,97,100,100,114,101
       dc.b      115,115,32,109,117,115,116,32,98,101,32,101
       dc.b      118,101,110,13,10,0
@flashprg_15:
       dc.b      84,97,114,103,101,116,32,48,120,0
@flashprg_16:
       dc.b      32,83,68,80,61,0
@flashprg_17:
       dc.b      79,78,13,10,0
@flashprg_18:
       dc.b      79,70,70,13,10,0
@flashprg_19:
       dc.b      82,65,77,32,48,120,0
@flashprg_20:
       dc.b      13,10,83,116,97,114,116,32,88,77,79,68,69,77
       dc.b      32,110,111,119,46,46,46,13,10,0
@flashprg_21:
       dc.b      88,77,79,68,69,77,32,101,114,114,111,114,32
       dc.b      0
@flashprg_22:
       dc.b      69,109,112,116,121,32,105,109,97,103,101,46
       dc.b      13,10,0
@flashprg_23:
       dc.b      73,109,97,103,101,32,116,111,111,32,98,105,103
       dc.b      32,102,111,114,32,82,65,77,32,98,117,102,102
       dc.b      101,114,46,13,10,0
@flashprg_24:
       dc.b      73,109,97,103,101,32,100,111,101,115,32,110
       dc.b      111,116,32,102,105,116,32,105,110,32,82,79,77
       dc.b      46,13,10,0
@flashprg_25:
       dc.b      82,101,99,101,105,118,101,100,32,0
@flashprg_26:
       dc.b      32,98,121,116,101,115,46,32,80,114,111,103,114
       dc.b      97,109,109,105,110,103,46,46,46,13,10,0
@flashprg_27:
       dc.b      70,108,97,115,104,32,102,97,105,108,101,100
       dc.b      46,13,10,0
@flashprg_28:
       dc.b      70,108,97,115,104,32,79,75,46,32,0
@flashprg_29:
       dc.b      32,98,121,116,101,115,32,97,116,32,48,120,0
@flashprg_30:
       dc.b      83,68,80,32,101,110,97,98,108,101,100,46,32
       dc.b      85,115,101,32,117,110,108,111,99,107,32,65,65
       dc.b      47,53,53,47,65,48,32,98,101,102,111,114,101
       dc.b      32,101,97,99,104,32,115,101,99,116,111,114,46
       dc.b      13,10,0
       section   data
       xdef      _vdsk
_vdsk:
       dc.l      2097152
       xdef      _vdskc
_vdskc:
       dc.l      2097153
       xdef      _vdskp
_vdskp:
       dc.l      2097157
       xdef      _vdskd
_vdskd:
       dc.l      2097155
       xdef      _vdest
_vdest:
       dc.l      0
       xdef      _errorBufferAddrBus
_errorBufferAddrBus:
       dc.l      6353416
       xdef      _traceData
_traceData:
       dc.l      6353546
       xdef      _tracePointer
_tracePointer:
       dc.l      6354572
       xdef      _traceA7
_traceA7:
       dc.l      6354578
       xdef      _regA7
_regA7:
       dc.l      6354582
       xdef      _hasMmsjosLoaded
_hasMmsjosLoaded:
       dc.l      6354592
       xdef      _startBasic
_startBasic:
       dc.l      6354594
       xdef      _startBasic0
_startBasic0:
       dc.l      6354596
       xdef      _startBasic1
_startBasic1:
       dc.l      6354600
       xdef      _startBasic2
_startBasic2:
       dc.l      6354604
       xdef      _startBasic3
_startBasic3:
       dc.l      6354608
       xdef      _startBasic4
_startBasic4:
       dc.l      6354612
       xdef      _startBasic5
_startBasic5:
       dc.l      6354616
       xdef      _paramBasic
_paramBasic:
       dc.l      6354620
       xdef      _hookTable
_hookTable:
       dc.l      6354876
       section   bss
@flashprg_fpSectorBuf:
       ds.b      512
       xref      _itoa
       xref      _fpIntsOff
       xref      _fpIntsOn
