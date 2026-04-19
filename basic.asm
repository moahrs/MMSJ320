; D:\PROJETOS\MMSJ320\PROGS_MONITOR\BASIC.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; /********************************************************************************
; *    Programa    : basic.c
; *    Objetivo    : MMSJ-Basic para o MMSJ320
; *    Criado em   : 10/10/2022
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 10/10/2022  0.1     Moacir Jr.   Criacao Versao Beta
; * 26/06/2023  0.4     Moacir Jr.   Simplificacoes e ajustres
; * 27/06/2023  0.4a    Moacir Jr.   Adaptar processos de for-next e if-then-else
; * 01/07/2023  0.4b    Moacir Jr.   Ajuste de Bugs
; * 03/07/2023  0.5     Moacir Jr.   Colocar Logica Ponto Flutuante
; * 10/07/2023  0.5a    Moacir Jr.   Colocar Funcoes Graficas
; * 11/07/2023  0.5b    Moacir Jr.   Colocar DATA-READ
; * 20/07/2023  1.0     Moacir Jr.   Versao para publicacao
; * 21/07/2023  1.0a    Moacir Jr.   Ajustes de memoria e bugs
; * 23/07/2023  1.0b    Moacir Jr.   Ajustes bugs no for...next e if...then
; * 24/07/2023  1.0c    Moacir Jr.   Retirada "BYE" message. Ajustes de bugs no gosub...return
; * 25/07/2023  1.0d    Moacir Jr.   Ajuste no basInputGet, quando Get, mandar 1 pro inputLine e sem manipulacoa cursor
; * 20/01/2024  1.0e    Moacir Jr.   Colocar para iniciar direto no Basic
; * 14/04/2026  1.1a03  Moacir Jr.   Ajustes para por cache variaveis e simplificar parse, retirando recursividade
; *--------------------------------------------------------------------------------
; * Variables Simples: start at 00800000
; *   --------------------------------------------------------
; *   Type ($ = String, # = Real, % = Integer)
; *   Name (2 Bytes, 1st and 2nd letters of the name)
; *   --------------- --------------- ------------------------
; *   Integer         Real            String
; *   --------------- --------------- ------------------------
; *   0x00            0x00            Length
; *   Value MSB       Value MSB       Pointer to String (High)
; *   Value           Value           Pointer to String
; *   Value           Value           Pointer to String
; *   Value LSB       Value LSB       Pointer to String (Low)
; *   --------------- --------------- ------------------------
; *   Total: 8 Bytes
; *--------------------------------------------------------------------------------
; *
; *--------------------------------------------------------------------------------
; * To do
; *
; *--------------------------------------------------------------------------------
; *
; *********************************************************************************/
; #include <ctype.h>
; #include <string.h>
; #include <stdlib.h>
; #include "../mmsj320api.h"
; #include "../mmsj320vdp.h"
; #include "../mmsj320mfp.h"
; #include "../monitor.h"
; #include "../monitorapi.h"
; #include "basic.h"
; #define versionBasic "1.1a03"
; //#define __TESTE_TOKENIZE__ 1
; //#define __DEBUG_ARRAYS__ 1
; #define SIMPLE_VAR_CACHE_SLOTS 8
; #define PARSER_STACK_SIZE 32
; #define PAINT_STACK_SIZE 4096
; static unsigned char lastVarCacheName0[SIMPLE_VAR_CACHE_SLOTS] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
; static unsigned char lastVarCacheName1[SIMPLE_VAR_CACHE_SLOTS] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
; static unsigned char *lastVarCacheAddr[SIMPLE_VAR_CACHE_SLOTS] = {0,0,0,0,0,0,0,0};
; static unsigned char paintStackX[PAINT_STACK_SIZE];
; static unsigned char paintStackY[PAINT_STACK_SIZE];
; static unsigned int paintPatternTable = 0x0000;
; static unsigned int paintColorTable = 0x2000;
; static unsigned char *paintVdpData = (unsigned char *)0x00400041;
; /*static unsigned char valStack[32][50];
; static unsigned char opStack[PARSER_STACK_SIZE];
; static unsigned char opPrecStack[PARSER_STACK_SIZE];
; static char valTypeStack[PARSER_STACK_SIZE];
; static unsigned char temp[50];
; static int opTop = -1, valTop = -1;*/
; static void invalidateFindVariableCache(void)
; {
       section   code
@basic_invalidateFindVariableCache:
       move.l    D2,-(A7)
; int ix;
; for (ix = 0; ix < SIMPLE_VAR_CACHE_SLOTS; ix++)
       clr.l     D2
@basic_invalidateFindVariableCache_1:
       cmp.l     #8,D2
       bge.s     @basic_invalidateFindVariableCache_3
; {
; lastVarCacheName0[ix] = 0x00;
       lea       @basic_lastVarCacheName0.L,A0
       clr.b     0(A0,D2.L)
; lastVarCacheName1[ix] = 0x00;
       lea       @basic_lastVarCacheName1.L,A0
       clr.b     0(A0,D2.L)
; lastVarCacheAddr[ix] = 0;
       move.l    D2,D0
       lsl.l     #2,D0
       lea       @basic_lastVarCacheAddr.L,A0
       clr.l     0(A0,D0.L)
       addq.l    #1,D2
       bra       @basic_invalidateFindVariableCache_1
@basic_invalidateFindVariableCache_3:
       move.l    (A7)+,D2
       rts
; }
; }
; static void clearRuntimeData(unsigned char *pForStack)
; {
@basic_clearRuntimeData:
       link      A6,#0
       move.l    A2,-(A7)
       lea       _memset.L,A2
; invalidateFindVariableCache();
       jsr       @basic_invalidateFindVariableCache
; memset(pStartSimpVar, 0x00, 0x2000);
       pea       8192
       clr.l     -(A7)
       move.l    _pStartSimpVar.L,-(A7)
       jsr       (A2)
       add.w     #12,A7
; memset(pStartArrayVar, 0x00, 0x6000);
       pea       24576
       clr.l     -(A7)
       move.l    _pStartArrayVar.L,-(A7)
       jsr       (A2)
       add.w     #12,A7
; memset(pForStack, 0x00, 0x800);
       pea       2048
       clr.l     -(A7)
       move.l    8(A6),-(A7)
       jsr       (A2)
       add.w     #12,A7
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; static void basPaintSyncTables(void)
; {
@basic_basPaintSyncTables:
; vdp_get_cfg(&paintPatternTable, &paintColorTable);
       pea       @basic_paintColorTable.L
       pea       @basic_paintPatternTable.L
       move.l    1182,A0
       jsr       (A0)
       addq.w    #8,A7
       rts
; }
; //-----------------------------------------------------------------------------
; // Principal
; //-----------------------------------------------------------------------------
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-4
       movem.l   D2/A2/A3/A4,-(A7)
       lea       -4(A6),A2
       lea       _pProcess.L,A3
       lea       _pTypeLine.L,A4
; unsigned char vRetInput;
; VDP_COLOR vdpcolor;
; unsigned char countTec = 0;
       clr.b     -1(A6)
; // Timer para o Random
; *(vmfp + Reg_TADR) = 0xF5;  // 245
       move.l    _vmfp.L,A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    #245,0(A0,D0.L)
; *(vmfp + Reg_TACR) = 0x02;  // prescaler de 10. total 2,4576Mhz/10*245 = 1003KHz
       move.l    _vmfp.L,A0
       move.w    _Reg_TACR.L,D0
       and.l     #65535,D0
       move.b    #2,0(A0,D0.L)
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; printText("MMSJ-BASIC v"versionBasic);
       pea       @basic_93.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Utility (c) 2022-2026\r\n\0");
       pea       @basic_95.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("OK\r\n\0");
       pea       @basic_96.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vbufInput[0] = '\0';
       clr.b     _vbufInput.L
; *pProcess = 0x01;
       move.l    (A3),A0
       move.b    #1,(A0)
; *pTypeLine = 0x00;
       move.l    (A4),A0
       clr.b     (A0)
; *nextAddrLine = pStartProg;
       move.l    _nextAddrLine.L,A0
       move.l    _pStartProg.L,(A0)
; *firstLineNumber = 0;
       move.l    _firstLineNumber.L,A0
       clr.w     (A0)
; *addrFirstLineNumber = 0;
       move.l    _addrFirstLineNumber.L,A0
       clr.l     (A0)
; *traceOn = 0;
       move.l    _traceOn.L,A0
       clr.b     (A0)
; *debugOn = 0;
       move.l    _debugOn.L,A0
       clr.b     (A0)
; *lastHgrX = 0;
       move.l    _lastHgrX.L,A0
       clr.b     (A0)
; *lastHgrY = 0;
       move.l    _lastHgrY.L,A0
       clr.b     (A0)
; //vdpcolor = vdp_get_color();
; vdpcolor.fg = VDP_WHITE;
       move.l    A2,D0
       move.l    D0,A0
       move.b    #15,(A0)
; vdpcolor.bg = VDP_BLACK;
       move.l    A2,D0
       move.l    D0,A0
       move.b    #1,1(A0)
; vdpModeBas = VDP_MODE_TEXT; // Text
       move.b    #3,_vdpModeBas.L
; fgcolorBasAnt = vdpcolor.fg;
       move.l    A2,D0
       move.l    D0,A0
       move.b    (A0),_fgcolorBasAnt.L
; bgcolorBasAnt = vdpcolor.bg;
       move.l    A2,D0
       move.l    D0,A0
       move.b    1(A0),_bgcolorBasAnt.L
; vdpMaxCols = 39;
       move.b    #39,_vdpMaxCols.L
; vdpMaxRows = 23;
       move.b    #23,_vdpMaxRows.L
; while (*pProcess)
main_1:
       move.l    (A3),A0
       tst.b     (A0)
       beq       main_3
; {
; vRetInput = inputLineBasic(128,'$');
       pea       36
       pea       128
       jsr       _inputLineBasic
       addq.w    #8,A7
       move.b    D0,D2
; if (vbufInput[0] != 0x00 && (vRetInput == 0x0D || vRetInput == 0x0A))
       move.b    _vbufInput.L,D0
       beq       main_4
       cmp.b     #13,D2
       beq.s     main_6
       cmp.b     #10,D2
       bne       main_4
main_6:
; {
; printText("\r\n\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; processLine();
       jsr       _processLine
; if (!*pTypeLine && *pProcess)
       move.l    (A4),A0
       tst.b     (A0)
       bne.s     main_7
       move.l    (A3),A0
       tst.b     (A0)
       beq.s     main_7
; printText("\r\nOK\0");
       pea       @basic_97.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_7:
; if (!*pTypeLine && *pProcess)
       move.l    (A4),A0
       tst.b     (A0)
       bne.s     main_9
       move.l    (A3),A0
       tst.b     (A0)
       beq.s     main_9
; printText("\r\n\0");   // printText("\r\n>\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_9:
       bra.s     main_11
main_4:
; }
; else if (vRetInput != 0x1B)
       cmp.b     #27,D2
       beq.s     main_11
; {
; printText("\r\n\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_11:
       bra       main_1
main_3:
; }
; }
; printText("\r\n\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       movem.l   (A7)+,D2/A2/A3/A4
       unlk      A6
       rts
; }
; /******************************************************************************************/
; /* Secao de Processamento da linha, tokenização e execução                                */
; /******************************************************************************************/
; //-----------------------------------------------------------------------------
; // pQtdInput - Quantidade a ser digitada, min 1 max 255
; // pTipo - Tipo de entrada:
; //                  input : $ - String, % - Inteiro (sem ponto), # - Real (com ponto), @ - Sem Cursor e Qualquer Coisa e sem enter
; //                   edit : S - String, I - Inteiro (sem ponto), R - Real (com ponto)
; //-----------------------------------------------------------------------------
; unsigned char inputLineBasic(unsigned int pQtdInput, unsigned char pTipo)
; {
       xdef      _inputLineBasic
_inputLineBasic:
       link      A6,#-16
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vbufInput.L,A2
       move.b    15(A6),D3
       and.l     #255,D3
       move.l    8(A6),A3
; unsigned char *vbufptr = &vbufInput;
       move.l    A2,D6
; unsigned char vtec, vtecant;
; int vRetProcCmd, iw, ix;
; int countCursor = 0;
       move.w    #0,A4
; char pEdit = 0, pIns = 0, vbuftemp, vbuftemp2;
       clr.b     -10(A6)
       clr.b     -9(A6)
; int iPos = 0, iz = 0;
       clr.l     D4
       clr.l     -6(A6)
; unsigned short vantX, vantY;
; if (pQtdInput == 0)
       move.l    A3,D0
       bne.s     inputLineBasic_1
; pQtdInput = 512;
       move.w    #512,A3
inputLineBasic_1:
; vtecant = 0x00;
       clr.b     -15(A6)
; vbufptr = &vbufInput;
       move.l    A2,D6
; // Se for Linha editavel apresenta a linha na tela
; if (pTipo == 'S' || pTipo == 'I' || pTipo == 'R')
       cmp.b     #83,D3
       beq.s     inputLineBasic_5
       cmp.b     #73,D3
       beq.s     inputLineBasic_5
       cmp.b     #82,D3
       bne       inputLineBasic_3
inputLineBasic_5:
; {
; // Apresenta a linha na tela, e posiciona o cursor na tela na primeira posicao valida
; iw = strlen(vbufInput) / 40;
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-(A7)
       pea       40
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D7
; printText(vbufInput);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; videoCursorPosRowY -= iw;
       sub.w     D7,_videoCursorPosRowY.L
; videoCursorPosColX = 0;
       clr.w     _videoCursorPosColX.L
; pEdit = 1;
       move.b    #1,-10(A6)
; iPos = 0;
       clr.l     D4
; pIns = 0xFF;
       move.b    #255,-9(A6)
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_3:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_6
; showCursor();
       move.l    1082,A0
       jsr       (A0)
inputLineBasic_6:
; while (1)
inputLineBasic_8:
; {
; // Piscar Cursor
; if (pTipo != '@')
       cmp.b     #64,D3
       beq       inputLineBasic_11
; {
; switch (countCursor)
       move.l    A4,D0
       cmp.l     #12000,D0
       beq       inputLineBasic_16
       bgt       inputLineBasic_14
       cmp.l     #6000,D0
       beq.s     inputLineBasic_15
       bra.s     inputLineBasic_14
inputLineBasic_15:
; {
; case 6000:
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
; if (pEdit)
       tst.b     -10(A6)
       beq.s     inputLineBasic_17
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_17:
; break;
       bra.s     inputLineBasic_14
inputLineBasic_16:
; case 12000:
; showCursor();
       move.l    1082,A0
       jsr       (A0)
; countCursor = 0;
       move.w    #0,A4
; break;
inputLineBasic_14:
; }
; countCursor++;
       addq.w    #1,A4
inputLineBasic_11:
; }
; // Inicia leitura
; vtec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,D2
; if (pTipo == '@')
       cmp.b     #64,D3
       bne.s     inputLineBasic_19
; return vtec;
       move.b    D2,D0
       bra       inputLineBasic_21
inputLineBasic_19:
; // Se nao for string ($ e S) ou Tudo (@), só aceita numeros
; if (pTipo != '$' && pTipo != 'S' && pTipo != '@' && vtec != '.' && vtec > 0x1F && (vtec < 0x30 || vtec > 0x39))
       cmp.b     #36,D3
       beq.s     inputLineBasic_22
       cmp.b     #83,D3
       beq.s     inputLineBasic_22
       cmp.b     #64,D3
       beq.s     inputLineBasic_22
       cmp.b     #46,D2
       beq.s     inputLineBasic_22
       cmp.b     #31,D2
       bls.s     inputLineBasic_22
       cmp.b     #48,D2
       blo.s     inputLineBasic_24
       cmp.b     #57,D2
       bls.s     inputLineBasic_22
inputLineBasic_24:
; vtec = 0;
       clr.b     D2
inputLineBasic_22:
; // So aceita ponto de for numero real (# ou R) ou string ($ ou S) ou tudo (@)
; if (vtec == '.' && pTipo != '#' && pTipo != '$' &&  pTipo != 'R' && pTipo != 'S' && pTipo != '@')
       cmp.b     #46,D2
       bne.s     inputLineBasic_25
       cmp.b     #35,D3
       beq.s     inputLineBasic_25
       cmp.b     #36,D3
       beq.s     inputLineBasic_25
       cmp.b     #82,D3
       beq.s     inputLineBasic_25
       cmp.b     #83,D3
       beq.s     inputLineBasic_25
       cmp.b     #64,D3
       beq.s     inputLineBasic_25
; vtec = 0;
       clr.b     D2
inputLineBasic_25:
; if (vtec)
       tst.b     D2
       beq       inputLineBasic_27
; {
; // Prevenir sujeira no buffer ou repeticao
; if (vtec == vtecant)
       cmp.b     -15(A6),D2
       bne.s     inputLineBasic_31
; {
; if (countCursor % 300 != 0)
       move.l    A4,-(A7)
       pea       300
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       beq.s     inputLineBasic_31
; continue;
       bra       inputLineBasic_28
inputLineBasic_31:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_35
; {
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
; if (pEdit)
       tst.b     -10(A6)
       beq.s     inputLineBasic_35
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_35:
; }
; vtecant = vtec;
       move.b    D2,-15(A6)
; if (vtec >= 0x20 && vtec != 0x7F)   // Caracter Printavel menos o DELete
       cmp.b     #32,D2
       blo       inputLineBasic_37
       cmp.b     #127,D2
       beq       inputLineBasic_37
; {
; if (!pEdit)
       tst.b     -10(A6)
       bne       inputLineBasic_39
; {
; // Digitcao Normal
; if (vbufptr > &vbufInput + pQtdInput)
       move.l    A2,D0
       move.l    A3,D1
       lsl.l     #8,D1
       add.l     D1,D0
       cmp.l     D0,D6
       bls.s     inputLineBasic_43
; {
; *vbufptr--;
       move.l    D6,A0
       subq.l    #1,D6
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_43
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_43:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_45
; printChar(vtec, 1);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_45:
; *vbufptr++ = vtec;
       move.l    D6,A0
       addq.l    #1,D6
       move.b    D2,(A0)
; *vbufptr = '\0';
       move.l    D6,A0
       clr.b     (A0)
       bra       inputLineBasic_58
inputLineBasic_39:
; }
; else
; {
; iw = strlen(vbufInput);
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D7
; // Edicao de Linha
; if (!pIns)
       tst.b     -9(A6)
       bne.s     inputLineBasic_47
; {
; // Sem insercao de caracteres
; if (iw < pQtdInput)
       cmp.l     A3,D7
       bhs.s     inputLineBasic_49
; {
; if (vbufInput[iPos] == 0x00)
       move.b    0(A2,D4.L),D0
       bne.s     inputLineBasic_51
; vbufInput[iPos + 1] = 0x00;
       move.l    D4,A0
       clr.b     1(A0,A2.L)
inputLineBasic_51:
; vbufInput[iPos] = vtec;
       move.b    D2,0(A2,D4.L)
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_49:
       bra       inputLineBasic_53
inputLineBasic_47:
; }
; }
; else
; {
; // Com insercao de caracteres
; if ((iw + 1) <= pQtdInput)
       move.l    D7,D0
       addq.l    #1,D0
       cmp.l     A3,D0
       bhi       inputLineBasic_53
; {
; // Copia todos os caracteres mais 1 pro final
; vbuftemp2 = vbufInput[iPos];
       move.b    0(A2,D4.L),-7(A6)
; vbuftemp = vbufInput[iPos + 1];
       move.l    D4,A0
       move.b    1(A0,A2.L),-8(A6)
; vantX = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,-2(A6)
; vantY = videoCursorPosRowY;
       move.w    _videoCursorPosRowY.L,A5
; printChar(vtec,1);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; for (ix = iPos; ix <= iw ; ix++)
       move.l    D4,D5
inputLineBasic_55:
       cmp.l     D7,D5
       bgt.s     inputLineBasic_57
; {
; vbufInput[ix + 1] = vbuftemp2;
       move.l    D5,A0
       move.b    -7(A6),1(A0,A2.L)
; vbuftemp2 = vbuftemp;
       move.b    -8(A6),-7(A6)
; vbuftemp = vbufInput[ix + 2];
       move.l    D5,A0
       move.b    2(A0,A2.L),-8(A6)
; printChar(vbufInput[ix + 1],1);
       pea       1
       move.l    D5,A0
       move.b    1(A0,A2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       addq.l    #1,D5
       bra       inputLineBasic_55
inputLineBasic_57:
; }
; vbufInput[iw + 1] = 0x00;
       move.l    D7,A0
       clr.b     1(A0,A2.L)
; vbufInput[iPos] = vtec;
       move.b    D2,0(A2,D4.L)
; videoCursorPosColX = vantX;
       move.w    -2(A6),_videoCursorPosColX.L
; videoCursorPosRowY = vantY;
       move.w    A5,_videoCursorPosRowY.L
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_53:
; }
; }
; if (iw <= pQtdInput)
       cmp.l     A3,D7
       bhi.s     inputLineBasic_58
; {
; iPos++;
       addq.l    #1,D4
; videoCursorPosColX = videoCursorPosColX + 1;
       addq.w    #1,_videoCursorPosColX.L
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_58:
       bra       inputLineBasic_105
inputLineBasic_37:
; }
; }
; }
; /*else if (pEdit && vtec == 0x11)    // UpArrow (17)
; {
; // TBD
; }
; else if (pEdit && vtec == 0x13)    // DownArrow (19)
; {
; // TBD
; }*/
; else if (pEdit && vtec == 0x12)    // LeftArrow (18)
       move.b    -10(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLineBasic_60
       cmp.b     #18,D2
       bne       inputLineBasic_60
; {
; if (iPos > 0)
       cmp.l     #0,D4
       ble       inputLineBasic_62
; {
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; iPos--;
       subq.l    #1,D4
; if (videoCursorPosColX == 0)
       move.w    _videoCursorPosColX.L,D0
       bne.s     inputLineBasic_64
; videoCursorPosColX = 255;
       move.w    #255,_videoCursorPosColX.L
       bra.s     inputLineBasic_65
inputLineBasic_64:
; else
; videoCursorPosColX = videoCursorPosColX - 1;
       subq.w    #1,_videoCursorPosColX.L
inputLineBasic_65:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_62:
       bra       inputLineBasic_105
inputLineBasic_60:
; }
; }
; else if (pEdit && vtec == 0x14)    // RightArrow (20)
       move.b    -10(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLineBasic_66
       cmp.b     #20,D2
       bne       inputLineBasic_66
; {
; if (iPos < strlen(vbufInput))
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     D0,D4
       bge       inputLineBasic_68
; {
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; iPos++;
       addq.l    #1,D4
; videoCursorPosColX = videoCursorPosColX + 1;
       addq.w    #1,_videoCursorPosColX.L
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_68:
       bra       inputLineBasic_105
inputLineBasic_66:
; }
; }
; else if (vtec == 0x15)  // Insert
       cmp.b     #21,D2
       bne.s     inputLineBasic_70
; {
; pIns = ~pIns;
       move.b    -9(A6),D0
       not.b     D0
       move.b    D0,-9(A6)
       bra       inputLineBasic_105
inputLineBasic_70:
; }
; else if (vtec == 0x08 && !pEdit)  // Backspace
       cmp.b     #8,D2
       bne       inputLineBasic_72
       tst.b     -10(A6)
       bne.s     inputLineBasic_74
       moveq     #1,D0
       bra.s     inputLineBasic_75
inputLineBasic_74:
       clr.l     D0
inputLineBasic_75:
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq.s     inputLineBasic_72
; {
; // Digitcao Normal
; if (vbufptr > &vbufInput)
       cmp.l     A2,D6
       bls.s     inputLineBasic_78
; {
; *vbufptr--;
       move.l    D6,A0
       subq.l    #1,D6
; *vbufptr = 0x00;
       move.l    D6,A0
       clr.b     (A0)
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_78
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_78:
       bra       inputLineBasic_105
inputLineBasic_72:
; }
; }
; else if ((vtec == 0x08 || vtec == 0x7F) && pEdit)  // Backspace
       cmp.b     #8,D2
       beq.s     inputLineBasic_82
       cmp.b     #127,D2
       bne       inputLineBasic_80
inputLineBasic_82:
       move.b    -10(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLineBasic_80
; {
; iw = strlen(vbufInput);
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D7
; if ((vtec == 0x08 && iPos > 0) || vtec == 0x7F)
       cmp.b     #8,D2
       bne.s     inputLineBasic_86
       cmp.l     #0,D4
       bgt.s     inputLineBasic_85
inputLineBasic_86:
       cmp.b     #127,D2
       bne       inputLineBasic_83
inputLineBasic_85:
; {
; if (vtec == 0x08)
       cmp.b     #8,D2
       bne.s     inputLineBasic_87
; {
; iPos--;
       subq.l    #1,D4
; if (videoCursorPosColX == 0)
       move.w    _videoCursorPosColX.L,D0
       bne.s     inputLineBasic_89
; videoCursorPosColX = 255;
       move.w    #255,_videoCursorPosColX.L
       bra.s     inputLineBasic_90
inputLineBasic_89:
; else
; videoCursorPosColX = videoCursorPosColX - 1;
       subq.w    #1,_videoCursorPosColX.L
inputLineBasic_90:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_87:
; }
; vantX = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,-2(A6)
; vantY = videoCursorPosRowY;
       move.w    _videoCursorPosRowY.L,A5
; for (ix = iPos; ix < iw ; ix++)
       move.l    D4,D5
inputLineBasic_91:
       cmp.l     D7,D5
       bge.s     inputLineBasic_93
; {
; vbufInput[ix] = vbufInput[ix + 1];
       move.l    D5,A0
       move.b    1(A0,A2.L),0(A2,D5.L)
; printChar(vbufInput[ix],1);
       pea       1
       move.b    0(A2,D5.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       addq.l    #1,D5
       bra       inputLineBasic_91
inputLineBasic_93:
; }
; vbufInput[ix] = 0x00;
       clr.b     0(A2,D5.L)
; videoCursorPosColX = vantX;
       move.w    -2(A6),_videoCursorPosColX.L
; videoCursorPosRowY = vantY;
       move.w    A5,_videoCursorPosRowY.L
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_83:
       bra       inputLineBasic_105
inputLineBasic_80:
; }
; }
; else if (vtec == 0x1B)   // ESC
       cmp.b     #27,D2
       bne       inputLineBasic_94
; {
; // Limpa a linha, esvazia o buffer e retorna tecla
; while (vbufptr > &vbufInput)
inputLineBasic_96:
       cmp.l     A2,D6
       bls       inputLineBasic_98
; {
; *vbufptr--;
       move.l    D6,A0
       subq.l    #1,D6
; *vbufptr = 0x00;
       move.l    D6,A0
       clr.b     (A0)
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_99
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
inputLineBasic_99:
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_101
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_101:
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_103
; showCursor();
       move.l    1082,A0
       jsr       (A0)
inputLineBasic_103:
       bra       inputLineBasic_96
inputLineBasic_98:
; }
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
; return vtec;
       move.b    D2,D0
       bra.s     inputLineBasic_21
inputLineBasic_94:
; }
; else if (vtec == 0x0D || vtec == 0x0A ) // CR ou LF
       cmp.b     #13,D2
       beq.s     inputLineBasic_107
       cmp.b     #10,D2
       bne.s     inputLineBasic_105
inputLineBasic_107:
; {
; return vtec;
       move.b    D2,D0
       bra.s     inputLineBasic_21
inputLineBasic_105:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLineBasic_108
; showCursor();
       move.l    1082,A0
       jsr       (A0)
inputLineBasic_108:
       bra.s     inputLineBasic_28
inputLineBasic_27:
; }
; else
; {
; vtecant = 0x00;
       clr.b     -15(A6)
inputLineBasic_28:
       bra       inputLineBasic_8
inputLineBasic_21:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; return 0x00;
; }
; //-----------------------------------------------------------------------------
; // Process line previous input after return
; // If have number in start, is to store in program, if not, is command to execute
; //-----------------------------------------------------------------------------
; void processLine(void)
; {
       xdef      _processLine
_processLine:
       link      A6,#-636
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -634(A6),A2
       lea       _strcmp.L,A3
       lea       _comandLineTokenized.L,A4
       lea       -590(A6),A5
; unsigned char linhacomando[32], vloop, vToken;
; unsigned char *blin = &vbufInput;
       lea       _vbufInput.L,A0
       move.l    A0,D4
; unsigned short varg = 0;
       clr.w     -600(A6)
; unsigned short ix, iy, iz, ikk, kt;
; unsigned short vbytepic = 0, vrecfim;
       clr.w     -596(A6)
; unsigned char cuntam, vLinhaArg[255], vparam2[16], vpicret;
; char vSpace = 0;
       clr.b     -317(A6)
; int vReta;
; typeInf vRetInf;
; unsigned short vTam = 0;
       clr.w     D5
; unsigned char *pSave = *nextAddrLine;
       move.l    _nextAddrLine.L,A0
       move.l    (A0),-54(A6)
; unsigned long vNextAddr = 0;
       clr.l     -50(A6)
; unsigned char vTimer;
; unsigned char vBuffer[20];
; unsigned char *vTempPointer;
; unsigned char sqtdtam[20];
; // Separar linha entre comando e argumento
; linhacomando[0] = '\0';
       clr.b     (A2)
; vLinhaArg[0] = '\0';
       clr.b     (A5)
; ix = 0;
       clr.w     D3
; iy = 0;
       clr.w     D2
; while (*blin)
processLine_1:
       move.l    D4,A0
       tst.b     (A0)
       beq       processLine_3
; {
; if (!varg && *blin >= 0x20 && *blin <= 0x2F)
       tst.w     -600(A6)
       bne.s     processLine_6
       moveq     #1,D0
       bra.s     processLine_7
processLine_6:
       clr.l     D0
processLine_7:
       and.l     #65535,D0
       beq       processLine_4
       move.l    D4,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       blo       processLine_4
       move.l    D4,A0
       move.b    (A0),D0
       cmp.b     #47,D0
       bhi       processLine_4
; {
; varg = 0x01;
       move.w    #1,-600(A6)
; linhacomando[ix] = '\0';
       and.l     #65535,D3
       clr.b     0(A2,D3.L)
; iy = ix;
       move.w    D3,D2
; ix = 0;
       clr.w     D3
; if (*blin != 0x20)
       move.l    D4,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     processLine_8
; vLinhaArg[ix++] = *blin;
       move.l    D4,A0
       move.w    D3,D0
       addq.w    #1,D3
       and.l     #65535,D0
       move.b    (A0),0(A5,D0.L)
       bra.s     processLine_9
processLine_8:
; else
; vSpace = 1;
       move.b    #1,-317(A6)
processLine_9:
       bra.s     processLine_5
processLine_4:
; }
; else
; {
; if (!varg)
       tst.w     -600(A6)
       bne.s     processLine_10
; linhacomando[ix] = *blin;
       move.l    D4,A0
       and.l     #65535,D3
       move.b    (A0),0(A2,D3.L)
       bra.s     processLine_11
processLine_10:
; else
; vLinhaArg[ix] = *blin;
       move.l    D4,A0
       and.l     #65535,D3
       move.b    (A0),0(A5,D3.L)
processLine_11:
; ix++;
       addq.w    #1,D3
processLine_5:
; }
; *blin++;
       move.l    D4,A0
       addq.l    #1,D4
       bra       processLine_1
processLine_3:
; }
; if (!varg)
       tst.w     -600(A6)
       bne.s     processLine_12
; {
; linhacomando[ix] = '\0';
       and.l     #65535,D3
       clr.b     0(A2,D3.L)
; iy = ix;
       move.w    D3,D2
       bra.s     processLine_13
processLine_12:
; }
; else
; vLinhaArg[ix] = '\0';
       and.l     #65535,D3
       clr.b     0(A5,D3.L)
processLine_13:
; vpicret = 0;
       clr.b     -318(A6)
; // Processar e definir o que fazer
; if (linhacomando[0] != 0)
       move.b    (A2),D0
       beq       processLine_60
; {
; // Se for numero o inicio da linha, eh entrada de programa, senao eh comando direto
; if (linhacomando[0] >= 0x31 && linhacomando[0] <= 0x39) // 0 nao é um numero de linha valida
       move.b    (A2),D0
       cmp.b     #49,D0
       blo.s     processLine_16
       move.b    (A2),D0
       cmp.b     #57,D0
       bhi.s     processLine_16
; {
; *pTypeLine = 0x01;
       move.l    _pTypeLine.L,A0
       move.b    #1,(A0)
; // Entrada de programa
; tokenizeLine(vLinhaArg);
       move.l    A5,-(A7)
       jsr       _tokenizeLine
       addq.w    #4,A7
; saveLine(linhacomando, vLinhaArg);
       move.l    A5,-(A7)
       move.l    A2,-(A7)
       jsr       _saveLine
       addq.w    #8,A7
       bra       processLine_60
processLine_16:
; }
; else
; {
; *pTypeLine = 0x00;
       move.l    _pTypeLine.L,A0
       clr.b     (A0)
; for (iz = 0; iz < iy; iz++)
       moveq     #0,D7
processLine_18:
       cmp.w     D2,D7
       bhs.s     processLine_20
; linhacomando[iz] = toupper(linhacomando[iz]);
       and.l     #65535,D7
       move.b    0(A2,D7.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       and.l     #65535,D7
       move.b    D0,0(A2,D7.L)
       addq.w    #1,D7
       bra       processLine_18
processLine_20:
; // Comando Direto
; if (!strcmp(linhacomando,"CLS") && iy == 3)
       pea       @basic_46.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_21
       cmp.w     #3,D2
       bne.s     processLine_21
; {
; clearScr();
       move.l    1054,A0
       jsr       (A0)
       bra       processLine_60
processLine_21:
; }
; else if (!strcmp(linhacomando,"NEW") && iy == 3)
       pea       @basic_98.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne       processLine_23
       cmp.w     #3,D2
       bne       processLine_23
; {
; *pStartProg = 0x00;
       move.l    _pStartProg.L,A0
       clr.b     (A0)
; *(pStartProg + 1) = 0x00;
       move.l    _pStartProg.L,A0
       clr.b     1(A0)
; *(pStartProg + 2) = 0x00;
       move.l    _pStartProg.L,A0
       clr.b     2(A0)
; *nextAddrLine = pStartProg;
       move.l    _nextAddrLine.L,A0
       move.l    _pStartProg.L,(A0)
; *firstLineNumber = 0;
       move.l    _firstLineNumber.L,A0
       clr.w     (A0)
; *addrFirstLineNumber = 0;
       move.l    _addrFirstLineNumber.L,A0
       clr.l     (A0)
; *nextAddrSimpVar = pStartSimpVar;
       move.l    _nextAddrSimpVar.L,A0
       move.l    _pStartSimpVar.L,(A0)
; *nextAddrArrayVar = pStartArrayVar;
       move.l    _nextAddrArrayVar.L,A0
       move.l    _pStartArrayVar.L,(A0)
; *nextAddrString = pStartString;
       move.l    _nextAddrString.L,A0
       move.l    _pStartString.L,(A0)
; clearRuntimeData((unsigned char*)forStack);
       move.l    _forStack.L,-(A7)
       jsr       @basic_clearRuntimeData
       addq.w    #4,A7
       bra       processLine_60
processLine_23:
; }
; else if (!strcmp(linhacomando,"EDIT") && iy == 4)
       pea       @basic_99.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_25
       cmp.w     #4,D2
       bne.s     processLine_25
; {
; editLine(vLinhaArg);
       move.l    A5,-(A7)
       jsr       _editLine
       addq.w    #4,A7
       bra       processLine_60
processLine_25:
; }
; else if (!strcmp(linhacomando,"LIST") && iy == 4)
       pea       @basic_100.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_27
       cmp.w     #4,D2
       bne.s     processLine_27
; {
; listProg(vLinhaArg, 0);
       clr.l     -(A7)
       move.l    A5,-(A7)
       jsr       _listProg
       addq.w    #8,A7
       bra       processLine_60
processLine_27:
; }
; else if (!strcmp(linhacomando,"LISTP") && iy == 5)
       pea       @basic_101.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_29
       cmp.w     #5,D2
       bne.s     processLine_29
; {
; listProg(vLinhaArg, 1);
       pea       1
       move.l    A5,-(A7)
       jsr       _listProg
       addq.w    #8,A7
       bra       processLine_60
processLine_29:
; }
; else if (!strcmp(linhacomando,"RUN") && iy == 3)
       pea       @basic_102.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_31
       cmp.w     #3,D2
       bne.s     processLine_31
; {
; runProg(vLinhaArg);
       move.l    A5,-(A7)
       jsr       _runProg
       addq.w    #4,A7
       bra       processLine_60
processLine_31:
; }
; else if (!strcmp(linhacomando,"DEL") && iy == 3)
       pea       @basic_103.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_33
       cmp.w     #3,D2
       bne.s     processLine_33
; {
; delLine(vLinhaArg);
       move.l    A5,-(A7)
       jsr       _delLine
       addq.w    #4,A7
       bra       processLine_60
processLine_33:
; }
; else if (!strcmp(linhacomando,"XLOAD") && iy == 5)
       pea       @basic_104.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_35
       cmp.w     #5,D2
       bne.s     processLine_35
; {
; basXBasLoad();
       jsr       _basXBasLoad
       bra       processLine_60
processLine_35:
; }
; else if (!strcmp(linhacomando,"XLOAD1K") && iy == 7)
       pea       @basic_105.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_37
       cmp.w     #7,D2
       bne.s     processLine_37
; {
; basXBasLoad1k();
       jsr       _basXBasLoad1k
       bra       processLine_60
processLine_37:
; }
; else if (!strcmp(linhacomando,"TIMER") && iy == 5)
       pea       @basic_106.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne       processLine_39
       cmp.w     #5,D2
       bne       processLine_39
; {
; // Ler contador A do 68901
; vTimer = *(vmfp + Reg_TADR);
       move.l    _vmfp.L,A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),-45(A6)
; // Devolve pra tela
; itoa(vTimer,vBuffer,10);
       pea       10
       pea       -44(A6)
       move.b    -45(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText("Timer: ");
       pea       @basic_107.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(vBuffer);
       pea       -44(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("ms\r\n\0");
       pea       @basic_108.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       processLine_60
processLine_39:
; }
; else if (!strcmp(linhacomando,"TRACE") && iy == 5)
       pea       @basic_109.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_41
       cmp.w     #5,D2
       bne.s     processLine_41
; {
; *traceOn = 1;
       move.l    _traceOn.L,A0
       move.b    #1,(A0)
       bra       processLine_60
processLine_41:
; }
; else if (!strcmp(linhacomando,"NOTRACE") && iy == 7)
       pea       @basic_110.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_43
       cmp.w     #7,D2
       bne.s     processLine_43
; {
; *traceOn = 0;
       move.l    _traceOn.L,A0
       clr.b     (A0)
       bra       processLine_60
processLine_43:
; }
; else if (!strcmp(linhacomando,"DEBUG") && iy == 5)
       pea       @basic_111.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_45
       cmp.w     #5,D2
       bne.s     processLine_45
; {
; *debugOn = 1;
       move.l    _debugOn.L,A0
       move.b    #1,(A0)
       bra       processLine_60
processLine_45:
; }
; else if (!strcmp(linhacomando,"NODEBUG") && iy == 7)
       pea       @basic_112.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_47
       cmp.w     #7,D2
       bne.s     processLine_47
; {
; *debugOn = 0;
       move.l    _debugOn.L,A0
       clr.b     (A0)
       bra       processLine_60
processLine_47:
; }
; // *************************************************
; // ESSE COMANDO NAO VAI EXISTIR QUANDO FOR PRA BIOS
; // *************************************************
; else if (!strcmp(linhacomando,"QUIT") && iy == 4)
       pea       @basic_113.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_49
       cmp.w     #4,D2
       bne.s     processLine_49
; {
; *pProcess = 0x00;
       move.l    _pProcess.L,A0
       clr.b     (A0)
       bra       processLine_60
processLine_49:
; }
; // *************************************************
; // *************************************************
; // *************************************************
; else
; {
; // Tokeniza a linha toda
; strcpy(vRetInf.tString, linhacomando);
       move.l    A2,-(A7)
       lea       -312(A6),A0
       move.l    A0,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
; if (vSpace)
       tst.b     -317(A6)
       beq.s     processLine_51
; strcat(vRetInf.tString, " ");
       pea       @basic_114.L
       lea       -312(A6),A0
       move.l    A0,-(A7)
       jsr       _strcat
       addq.w    #8,A7
processLine_51:
; strcat(vRetInf.tString, vLinhaArg);
       move.l    A5,-(A7)
       lea       -312(A6),A0
       move.l    A0,-(A7)
       jsr       _strcat
       addq.w    #8,A7
; tokenizeLine(vRetInf.tString);
       lea       -312(A6),A0
       move.l    A0,-(A7)
       jsr       _tokenizeLine
       addq.w    #4,A7
; // Salva a linha pra ser interpretada
; vTam = strlen(vRetInf.tString);
       lea       -312(A6),A0
       move.l    A0,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,D5
; vNextAddr = comandLineTokenized + (vTam + 6);
       move.l    (A4),D0
       move.w    D5,D1
       addq.w    #6,D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    D0,-50(A6)
; *comandLineTokenized = ((vNextAddr & 0xFF0000) >> 16);
       move.l    -50(A6),D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    (A4),A0
       move.b    D0,(A0)
; *(comandLineTokenized + 1) = ((vNextAddr & 0xFF00) >> 8);
       move.l    -50(A6),D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    (A4),A0
       move.b    D0,1(A0)
; *(comandLineTokenized + 2) =  (vNextAddr & 0xFF);
       move.l    -50(A6),D0
       and.l     #255,D0
       move.l    (A4),A0
       move.b    D0,2(A0)
; // Grava numero da linha
; *(comandLineTokenized + 3) = 0xFF;
       move.l    (A4),A0
       move.b    #255,3(A0)
; *(comandLineTokenized + 4) = 0xFF;
       move.l    (A4),A0
       move.b    #255,4(A0)
; // Grava linha tokenizada
; for(kt = 0; kt < vTam; kt++)
       clr.w     D6
processLine_53:
       cmp.w     D5,D6
       bhs.s     processLine_55
; *(comandLineTokenized + (kt + 5)) = vRetInf.tString[kt];
       lea       -312(A6),A0
       and.l     #65535,D6
       move.l    (A4),A1
       move.w    D6,D0
       addq.w    #5,D0
       and.l     #65535,D0
       move.b    0(A0,D6.L),0(A1,D0.L)
       addq.w    #1,D6
       bra       processLine_53
processLine_55:
; // Grava final linha 0x00
; *(comandLineTokenized + (vTam + 5)) = 0x00;
       move.l    (A4),A0
       move.w    D5,D0
       addq.w    #5,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(comandLineTokenized + (vTam + 6)) = 0x00;
       move.l    (A4),A0
       move.w    D5,D0
       addq.w    #6,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(comandLineTokenized + (vTam + 7)) = 0x00;
       move.l    (A4),A0
       move.w    D5,D0
       addq.w    #7,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(comandLineTokenized + (vTam + 8)) = 0x00;
       move.l    (A4),A0
       move.w    D5,D0
       addq.w    #8,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *nextAddrSimpVar = pStartSimpVar;
       move.l    _nextAddrSimpVar.L,A0
       move.l    _pStartSimpVar.L,(A0)
; *nextAddrArrayVar = pStartArrayVar;
       move.l    _nextAddrArrayVar.L,A0
       move.l    _pStartArrayVar.L,(A0)
; *nextAddrString = pStartString;
       move.l    _nextAddrString.L,A0
       move.l    _pStartString.L,(A0)
; invalidateFindVariableCache();
       jsr       @basic_invalidateFindVariableCache
; *vMaisTokens = 0;
       move.l    _vMaisTokens.L,A0
       clr.b     (A0)
; *vParenteses = 0x00;
       move.l    _vParenteses.L,A0
       clr.b     (A0)
; *vTemIf = 0x00;
       move.l    _vTemIf.L,A0
       clr.b     (A0)
; *vTemThen = 0;
       move.l    _vTemThen.L,A0
       clr.b     (A0)
; *vTemElse = 0;
       move.l    _vTemElse.L,A0
       clr.b     (A0)
; *vTemIfAndOr = 0x00;
       move.l    _vTemIfAndOr.L,A0
       clr.b     (A0)
; *pointerRunProg = comandLineTokenized + 5;
       move.l    (A4),D0
       addq.l    #5,D0
       move.l    _pointerRunProg.L,A0
       move.l    D0,(A0)
; vRetInf.tString[0] = 0x00;
       lea       -312(A6),A0
       clr.b     (A0)
; *ftos=0;
       move.l    _ftos.L,A0
       clr.l     (A0)
; *gtos=0;
       move.l    _gtos.L,A0
       clr.l     (A0)
; *vErroProc = 0;
       move.l    _vErroProc.L,A0
       clr.w     (A0)
; *randSeed = *(vmfp + Reg_TADR);
       move.l    _vmfp.L,A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    _randSeed.L,A0
       move.l    D0,(A0)
; do
; {
processLine_56:
; *doisPontos = 0;
       move.l    _doisPontos.L,A0
       clr.b     (A0)
; *vInicioSentenca = 1;
       move.l    _vInicioSentenca.L,A0
       move.b    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-24(A6)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
; vReta = executeToken(*vTempPointer);
       move.l    -24(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _executeToken
       addq.w    #4,A7
       move.l    D0,-316(A6)
       move.l    _doisPontos.L,A0
       tst.b     (A0)
       bne       processLine_56
; } while (*doisPontos);
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.b    _vdpModeBas.L,D0
       cmp.b     #3,D0
       beq.s     processLine_58
; basText();
       jsr       _basText
processLine_58:
; #endif
; if (*vErroProc)
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     processLine_60
; {
; showErrorMessage(*vErroProc, 0);
       clr.l     -(A7)
       move.l    _vErroProc.L,A0
       move.w    (A0),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _showErrorMessage
       addq.w    #8,A7
processLine_60:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; }
; }
; }
; //-----------------------------------------------------------------------------
; // Transforma linha em tokens, se existirem
; //-----------------------------------------------------------------------------
; void tokenizeLine(unsigned char *pTokenized)
; {
       xdef      _tokenizeLine
_tokenizeLine:
       link      A6,#-828
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -828(A6),A2
       lea       -310(A6),A3
       lea       @basic_keywords.L,A4
       lea       -572(A6),A5
; unsigned char vLido[255], vLidoCaps[255], vAspas, vAchou = 0;
       clr.b     -315(A6)
; unsigned char *blin = pTokenized;
       move.l    8(A6),D3
; unsigned short ix, iy, kt, iz, iw;
; unsigned char vToken, vLinhaArg[255], vparam2[16], vpicret;
; char vBuffer [sizeof(long)*8+1];
; char vFirstComp = 0;
       moveq     #0,D7
; char isToken;
; char vTemRem = 0;
       clr.b     -1(A6)
; //    unsigned char sqtdtam[20];
; // Separar linha entre comando e argumento
; vLinhaArg[0] = '\0';
       clr.b     (A3)
; vLido[0]  = '\0';
       clr.b     (A2)
; ix = 0;
       clr.w     D4
; iy = 0;
       clr.w     D5
; vAspas = 0;
       clr.b     -316(A6)
; while (1)
tokenizeLine_1:
; {
; vLido[ix] = '\0';
       and.l     #65535,D4
       clr.b     0(A2,D4.L)
; if (*blin == 0x22)
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #34,D0
       bne.s     tokenizeLine_4
; vAspas = !vAspas;
       tst.b     -316(A6)
       bne.s     tokenizeLine_6
       moveq     #1,D0
       bra.s     tokenizeLine_7
tokenizeLine_6:
       clr.l     D0
tokenizeLine_7:
       move.b    D0,-316(A6)
tokenizeLine_4:
; // Se for quebrador sequencia, verifica se é um token
; if ((!vTemRem && !vAspas && strchr(" ;,+-<>()/*^=:",*blin)) || !*blin)
       tst.b     -1(A6)
       bne.s     tokenizeLine_12
       moveq     #1,D0
       bra.s     tokenizeLine_13
tokenizeLine_12:
       clr.l     D0
tokenizeLine_13:
       tst.b     D0
       beq.s     tokenizeLine_11
       tst.b     -316(A6)
       bne.s     tokenizeLine_11
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @basic_115.L
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       bne.s     tokenizeLine_10
tokenizeLine_11:
       move.l    D3,A0
       tst.b     (A0)
       bne.s     tokenizeLine_14
       moveq     #1,D0
       bra.s     tokenizeLine_15
tokenizeLine_14:
       clr.l     D0
tokenizeLine_15:
       and.l     #255,D0
       beq       tokenizeLine_8
tokenizeLine_10:
; {
; // Montar comparacoes "<>", ">=" e "<="
; if (((*blin == 0x3C || *blin == 0x3E) && (!vFirstComp && (*(blin + 1) == 0x3E || *(blin + 1) == 0x3D))) || (vFirstComp && *blin == 0x3D) || (vFirstComp && *blin == 0x3E))
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #60,D0
       beq.s     tokenizeLine_20
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #62,D0
       bne       tokenizeLine_21
tokenizeLine_20:
       tst.b     D7
       bne.s     tokenizeLine_22
       moveq     #1,D0
       bra.s     tokenizeLine_23
tokenizeLine_22:
       clr.l     D0
tokenizeLine_23:
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq.s     tokenizeLine_21
       move.l    D3,A0
       move.b    1(A0),D0
       cmp.b     #62,D0
       beq       tokenizeLine_18
       move.l    D3,A0
       move.b    1(A0),D0
       cmp.b     #61,D0
       beq       tokenizeLine_18
tokenizeLine_21:
       ext.w     D7
       ext.l     D7
       tst.l     D7
       beq.s     tokenizeLine_24
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     tokenizeLine_18
tokenizeLine_24:
       ext.w     D7
       ext.l     D7
       tst.l     D7
       beq       tokenizeLine_16
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #62,D0
       bne       tokenizeLine_16
tokenizeLine_18:
; {
; if (!vFirstComp)
       tst.b     D7
       bne.s     tokenizeLine_25
; {
; for(kt = 0; kt < ix; kt++)
       clr.w     D2
tokenizeLine_27:
       cmp.w     D4,D2
       bhs.s     tokenizeLine_29
; vLinhaArg[iy++] = vLido[kt];
       and.l     #65535,D2
       move.w    D5,D0
       addq.w    #1,D5
       and.l     #65535,D0
       move.b    0(A2,D2.L),0(A3,D0.L)
       addq.w    #1,D2
       bra       tokenizeLine_27
tokenizeLine_29:
; vLido[0] = 0x00;
       clr.b     (A2)
; ix = 0;
       clr.w     D4
; vFirstComp = 1;
       moveq     #1,D7
tokenizeLine_25:
; }
; vLido[ix++] = *blin;
       move.l    D3,A0
       move.w    D4,D0
       addq.w    #1,D4
       and.l     #65535,D0
       move.b    (A0),0(A2,D0.L)
; if (ix < 2)
       cmp.w     #2,D4
       bhs.s     tokenizeLine_30
; {
; blin++;
       addq.l    #1,D3
; continue;
       bra       tokenizeLine_2
tokenizeLine_30:
; }
; vFirstComp = 0;
       moveq     #0,D7
tokenizeLine_16:
; }
; if (vLido[0])
       tst.b     (A2)
       beq       tokenizeLine_32
; {
; vToken = 0;
       clr.b     D6
; /*writeLongSerial("Aqui 332.666.2-[");
; itoa(ix,sqtdtam,10);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*blin,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (ix > 1)
       cmp.w     #1,D4
       bls       tokenizeLine_41
; {
; // Transforma em Caps pra comparar com os tokens
; for (kt = 0; kt < ix; kt++)
       clr.w     D2
tokenizeLine_36:
       cmp.w     D4,D2
       bhs.s     tokenizeLine_38
; vLidoCaps[kt] = toupper(vLido[kt]);
       and.l     #65535,D2
       move.b    0(A2,D2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       and.l     #65535,D2
       move.b    D0,0(A5,D2.L)
       addq.w    #1,D2
       bra       tokenizeLine_36
tokenizeLine_38:
; vLidoCaps[ix] = 0x00;
       and.l     #65535,D4
       clr.b     0(A5,D4.L)
; iz = strlen(vLidoCaps);
       move.l    A5,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,-314(A6)
; // Compara pra ver se é um token
; for(kt = 0; kt < keywords_count; kt++)
       clr.w     D2
tokenizeLine_39:
       and.l     #65535,D2
       cmp.l     _keywords_count.L,D2
       bhs       tokenizeLine_41
; {
; iw = strlen(keywords[kt].keyword);
       and.l     #65535,D2
       move.l    D2,D1
       lsl.l     #3,D1
       move.l    0(A4,D1.L),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,-312(A6)
; if (iw == 2 && iz == iw)
       move.w    -312(A6),D0
       cmp.w     #2,D0
       bne       tokenizeLine_42
       move.w    -314(A6),D0
       cmp.w     -312(A6),D0
       bne       tokenizeLine_42
; {
; if (vLidoCaps[0] == keywords[kt].keyword[0] && vLidoCaps[1] == keywords[kt].keyword[1])
       and.l     #65535,D2
       move.l    D2,D0
       lsl.l     #3,D0
       move.l    0(A4,D0.L),A0
       move.b    (A5),D0
       cmp.b     (A0),D0
       bne.s     tokenizeLine_44
       and.l     #65535,D2
       move.l    D2,D0
       lsl.l     #3,D0
       move.l    0(A4,D0.L),A0
       move.b    1(A5),D0
       cmp.b     1(A0),D0
       bne.s     tokenizeLine_44
; {
; vToken = keywords[kt].token;
       and.l     #65535,D2
       move.l    D2,D0
       lsl.l     #3,D0
       lea       0(A4,D0.L),A0
       move.l    4(A0),D0
       move.b    D0,D6
; break;
       bra       tokenizeLine_41
tokenizeLine_44:
       bra       tokenizeLine_48
tokenizeLine_42:
; }
; }
; else if (iz==iw)
       move.w    -314(A6),D0
       cmp.w     -312(A6),D0
       bne       tokenizeLine_48
; {
; if (strncmp(vLidoCaps, keywords[kt].keyword, iw) == 0)
       move.w    -312(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       and.l     #65535,D2
       move.l    D2,D1
       lsl.l     #3,D1
       move.l    0(A4,D1.L),-(A7)
       move.l    A5,-(A7)
       jsr       _strncmp
       add.w     #12,A7
       tst.l     D0
       bne.s     tokenizeLine_48
; {
; vToken = keywords[kt].token;
       and.l     #65535,D2
       move.l    D2,D0
       lsl.l     #3,D0
       lea       0(A4,D0.L),A0
       move.l    4(A0),D0
       move.b    D0,D6
; break;
       bra.s     tokenizeLine_41
tokenizeLine_48:
       addq.w    #1,D2
       bra       tokenizeLine_39
tokenizeLine_41:
; }
; }
; }
; }
; if (vToken)
       tst.b     D6
       beq       tokenizeLine_50
; {
; if (vToken == 0x8C) // REM
       and.w     #255,D6
       cmp.w     #140,D6
       bne.s     tokenizeLine_52
; vTemRem = 1;
       move.b    #1,-1(A6)
tokenizeLine_52:
; vLinhaArg[iy++] = vToken;
       move.w    D5,D0
       addq.w    #1,D5
       and.l     #65535,D0
       move.b    D6,0(A3,D0.L)
; //if (*blin == 0x28 || *blin == 0x29)
; //    vLinhaArg[iy++] = *blin;
; //if (*blin == 0x3A)  // :
; if (*blin && *blin != 0x20 && vToken < 0xF0 && !vTemRem)
       move.l    D3,A0
       move.b    (A0),D0
       and.l     #255,D0
       beq       tokenizeLine_54
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq       tokenizeLine_54
       and.w     #255,D6
       cmp.w     #240,D6
       bhs       tokenizeLine_54
       tst.b     -1(A6)
       bne.s     tokenizeLine_56
       moveq     #1,D0
       bra.s     tokenizeLine_57
tokenizeLine_56:
       clr.l     D0
tokenizeLine_57:
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq.s     tokenizeLine_54
; vLinhaArg[iy++] = toupper(*blin);
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    D5,D1
       addq.w    #1,D5
       and.l     #65535,D1
       move.b    D0,0(A3,D1.L)
tokenizeLine_54:
       bra       tokenizeLine_61
tokenizeLine_50:
; }
; else
; {
; for(kt = 0; kt < ix; kt++)
       clr.w     D2
tokenizeLine_58:
       cmp.w     D4,D2
       bhs.s     tokenizeLine_60
; vLinhaArg[iy++] = vLido[kt];
       and.l     #65535,D2
       move.w    D5,D0
       addq.w    #1,D5
       and.l     #65535,D0
       move.b    0(A2,D2.L),0(A3,D0.L)
       addq.w    #1,D2
       bra       tokenizeLine_58
tokenizeLine_60:
; if (*blin && *blin != 0x20)
       move.l    D3,A0
       move.b    (A0),D0
       and.l     #255,D0
       beq.s     tokenizeLine_61
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     tokenizeLine_61
; vLinhaArg[iy++] = toupper(*blin);
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    D5,D1
       addq.w    #1,D5
       and.l     #65535,D1
       move.b    D0,0(A3,D1.L)
tokenizeLine_61:
       bra       tokenizeLine_63
tokenizeLine_32:
; }
; }
; else
; {
; if (*blin && *blin != 0x20)
       move.l    D3,A0
       move.b    (A0),D0
       and.l     #255,D0
       beq.s     tokenizeLine_63
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     tokenizeLine_63
; vLinhaArg[iy++] = toupper(*blin);
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    D5,D1
       addq.w    #1,D5
       and.l     #65535,D1
       move.b    D0,0(A3,D1.L)
tokenizeLine_63:
; }
; if (!*blin)
       move.l    D3,A0
       tst.b     (A0)
       bne.s     tokenizeLine_65
; break;
       bra       tokenizeLine_3
tokenizeLine_65:
; vLido[0] = '\0';
       clr.b     (A2)
; ix = 0;
       clr.w     D4
       bra       tokenizeLine_68
tokenizeLine_8:
; }
; else
; {
; if (!vAspas && !vTemRem)
       tst.b     -316(A6)
       bne       tokenizeLine_67
       tst.b     -1(A6)
       bne.s     tokenizeLine_69
       moveq     #1,D0
       bra.s     tokenizeLine_70
tokenizeLine_69:
       clr.l     D0
tokenizeLine_70:
       tst.b     D0
       beq.s     tokenizeLine_67
; vLido[ix++] = toupper(*blin);
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    D4,D1
       addq.w    #1,D4
       and.l     #65535,D1
       move.b    D0,0(A2,D1.L)
       bra.s     tokenizeLine_68
tokenizeLine_67:
; else
; vLido[ix++] = *blin;
       move.l    D3,A0
       move.w    D4,D0
       addq.w    #1,D4
       and.l     #65535,D0
       move.b    (A0),0(A2,D0.L)
tokenizeLine_68:
; }
; blin++;
       addq.l    #1,D3
tokenizeLine_2:
       bra       tokenizeLine_1
tokenizeLine_3:
; }
; vLinhaArg[iy] = 0x00;
       and.l     #65535,D5
       clr.b     0(A3,D5.L)
; for(kt = 0; kt < iy; kt++)
       clr.w     D2
tokenizeLine_71:
       cmp.w     D5,D2
       bhs.s     tokenizeLine_73
; pTokenized[kt] = vLinhaArg[kt];
       and.l     #65535,D2
       move.l    8(A6),A0
       and.l     #65535,D2
       move.b    0(A3,D2.L),0(A0,D2.L)
       addq.w    #1,D2
       bra       tokenizeLine_71
tokenizeLine_73:
; pTokenized[iy] = 0x00;
       move.l    8(A6),A0
       and.l     #65535,D5
       clr.b     0(A0,D5.L)
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Salva a linha no formato:
; // NN NN NN LL LL xxxxxxxxxxxx 00
; // onde:
; //      NN NN NN         = endereco da proxima linha
; //      LL LL            = Numero da linha
; //      xxxxxxxxxxxxxx   = Linha Tokenizada
; //      00               = Indica fim da linha
; //-----------------------------------------------------------------------------
; void saveLine(unsigned char *pNumber, unsigned char *pTokenized)
; {
       xdef      _saveLine
_saveLine:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _nextAddrLine.L,A2
       lea       _firstLineNumber.L,A5
; unsigned short vTam = 0, kt;
       move.w    #0,A3
; unsigned char *pSave = *nextAddrLine;
       move.l    (A2),A0
       move.l    (A0),D5
; unsigned long vNextAddr = 0, vAntAddr = 0, vNextAddr2 = 0;
       clr.l     D4
       moveq     #0,D7
       move.w    #0,A4
; unsigned short vNumLin = 0;
       clr.w     D3
; unsigned char *pAtu = *nextAddrLine, *pLast = *nextAddrLine;
       move.l    (A2),A0
       move.l    (A0),D2
       move.l    (A2),A0
       move.l    (A0),D6
; vNumLin = atoi(pNumber);
       move.l    8(A6),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,D3
; if (*firstLineNumber == 0)
       move.l    (A5),A0
       move.w    (A0),D0
       bne.s     saveLine_1
; {
; *firstLineNumber = vNumLin;
       move.l    (A5),A0
       move.w    D3,(A0)
; *addrFirstLineNumber = pStartProg;
       move.l    _addrFirstLineNumber.L,A0
       move.l    _pStartProg.L,(A0)
       bra       saveLine_3
saveLine_1:
; }
; else
; {
; vNextAddr = findNumberLine(vNumLin, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       and.l     #65535,D3
       move.l    D3,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D4
; if (vNextAddr > 0)
       cmp.l     #0,D4
       bls       saveLine_3
; {
; pAtu = vNextAddr;
       move.l    D4,D2
; if (((*(pAtu + 3) << 8) | *(pAtu + 4)) == vNumLin)
       move.l    D2,A0
       move.b    3(A0),D0
       lsl.b     #8,D0
       move.l    D2,A0
       or.b      4(A0),D0
       and.w     #255,D0
       cmp.w     D3,D0
       bne.s     saveLine_5
; {
; printText("Line number already exists\r\n\0");
       pea       @basic_116.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       saveLine_8
saveLine_5:
; }
; vAntAddr = findNumberLine(vNumLin, 1, 0);
       clr.l     -(A7)
       pea       1
       and.l     #65535,D3
       move.l    D3,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D7
saveLine_3:
; }
; }
; vTam = strlen(pTokenized);
       move.l    12(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,A3
; if (vTam)
       move.w    A3,D0
       beq       saveLine_8
; {
; // Calcula nova posicao da proxima linha
; if (vNextAddr == 0)
       tst.l     D4
       bne.s     saveLine_10
; {
; *nextAddrLine += (vTam + 6);
       move.l    (A2),A0
       move.l    A3,D0
       addq.l    #6,D0
       add.l     D0,(A0)
; vNextAddr = *nextAddrLine;
       move.l    (A2),A0
       move.l    (A0),D4
; *addrLastLineNumber = pSave;
       move.l    _addrLastLineNumber.L,A0
       move.l    D5,(A0)
       bra       saveLine_11
saveLine_10:
; }
; else
; {
; if (*firstLineNumber > vNumLin)
       move.l    (A5),A0
       cmp.w     (A0),D3
       bhs.s     saveLine_12
; {
; *firstLineNumber = vNumLin;
       move.l    (A5),A0
       move.w    D3,(A0)
; *addrFirstLineNumber = *nextAddrLine;
       move.l    (A2),A0
       move.l    _addrFirstLineNumber.L,A1
       move.l    (A0),(A1)
saveLine_12:
; }
; *nextAddrLine += (vTam + 6);
       move.l    (A2),A0
       move.l    A3,D0
       addq.l    #6,D0
       add.l     D0,(A0)
; vNextAddr2 = *nextAddrLine;
       move.l    (A2),A0
       move.l    (A0),A4
; if (vAntAddr != vNextAddr)
       cmp.l     D4,D7
       beq       saveLine_14
; {
; pLast = vAntAddr;
       move.l    D7,D6
; vAntAddr = pSave;
       move.l    D5,D7
; *pLast       = ((vAntAddr & 0xFF0000) >> 16);
       move.l    D7,D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D6,A0
       move.b    D0,(A0)
; *(pLast + 1) = ((vAntAddr & 0xFF00) >> 8);
       move.l    D7,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D6,A0
       move.b    D0,1(A0)
; *(pLast + 2) =  (vAntAddr & 0xFF);
       move.l    D7,D0
       and.l     #255,D0
       move.l    D6,A0
       move.b    D0,2(A0)
saveLine_14:
; }
; pLast = *addrLastLineNumber;
       move.l    _addrLastLineNumber.L,A0
       move.l    (A0),D6
; *pLast       = ((vNextAddr2 & 0xFF0000) >> 16);
       move.l    A4,D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D6,A0
       move.b    D0,(A0)
; *(pLast + 1) = ((vNextAddr2 & 0xFF00) >> 8);
       move.l    A4,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D6,A0
       move.b    D0,1(A0)
; *(pLast + 2) =  (vNextAddr2 & 0xFF);
       move.l    A4,D0
       and.l     #255,D0
       move.l    D6,A0
       move.b    D0,2(A0)
saveLine_11:
; }
; pAtu = *nextAddrLine;
       move.l    (A2),A0
       move.l    (A0),D2
; *pAtu       = 0x00;
       move.l    D2,A0
       clr.b     (A0)
; *(pAtu + 1) = 0x00;
       move.l    D2,A0
       clr.b     1(A0)
; *(pAtu + 2) = 0x00;
       move.l    D2,A0
       clr.b     2(A0)
; *(pAtu + 3) = 0x00;
       move.l    D2,A0
       clr.b     3(A0)
; *(pAtu + 4) = 0x00;
       move.l    D2,A0
       clr.b     4(A0)
; // Grava endereco proxima linha
; *pSave++ = ((vNextAddr & 0xFF0000) >> 16);
       move.l    D4,D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D5,A0
       addq.l    #1,D5
       move.b    D0,(A0)
; *pSave++ = ((vNextAddr & 0xFF00) >> 8);
       move.l    D4,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D5,A0
       addq.l    #1,D5
       move.b    D0,(A0)
; *pSave++ =  (vNextAddr & 0xFF);
       move.l    D4,D0
       and.l     #255,D0
       move.l    D5,A0
       addq.l    #1,D5
       move.b    D0,(A0)
; // Grava numero da linha
; *pSave++ = ((vNumLin & 0xFF00) >> 8);
       move.w    D3,D0
       and.w     #65280,D0
       lsr.w     #8,D0
       move.l    D5,A0
       addq.l    #1,D5
       move.b    D0,(A0)
; *pSave++ = (vNumLin & 0xFF);
       move.w    D3,D0
       and.w     #255,D0
       move.l    D5,A0
       addq.l    #1,D5
       move.b    D0,(A0)
; // Grava linha tokenizada
; for(kt = 0; kt < vTam; kt++)
       clr.w     -2(A6)
saveLine_16:
       move.w    A3,D0
       cmp.w     -2(A6),D0
       bls.s     saveLine_18
; *pSave++ = *pTokenized++;
       move.l    12(A6),A0
       addq.l    #1,12(A6)
       move.l    D5,A1
       addq.l    #1,D5
       move.b    (A0),(A1)
       addq.w    #1,-2(A6)
       bra       saveLine_16
saveLine_18:
; // Grava final linha 0x00
; *pSave = 0x00;
       move.l    D5,A0
       clr.b     (A0)
saveLine_8:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // Sintaxe:
; //      LIST                : lista tudo
; //      LIST <num>          : lista só a linha <num>
; //      LIST <num>-         : lista a partir da linha <num>
; //      LIST <numA>-<numB>  : lista o intervalo de <numA> até <numB>, inclusive
; //
; //      LISTP : mesmo que LIST, mas com pausa a cada scroll
; //-----------------------------------------------------------------------------
; void listProg(unsigned char *pArg, unsigned short pPause)
; {
       xdef      _listProg
_listProg:
       link      A6,#-320
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -290(A6),A2
       move.l    8(A6),D5
       lea       -34(A6),A3
; // Default listar tudo
; unsigned short pIni = 0, pFim = 0xFFFF;
       clr.w     -318(A6)
       move.w    #65535,A5
; unsigned char *vStartList = pStartProg;
       move.l    _pStartProg.L,D3
; unsigned long vNextList;
; unsigned short vNumLin;
; char sNumLin [sizeof(short)*8+1], vFirstByte;
; unsigned char vtec;
; unsigned char vLinhaList[255], sNumPar[10], vToken;
; int iw, ix, iy, iz, vPauseRowCounter;
; unsigned char sqtdtam[20];
; if (pArg[0] != 0x00 && strchr(pArg,'-') != 0x00)
       move.l    D5,A0
       move.b    (A0),D0
       beq       listProg_1
       pea       45
       move.l    D5,-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq       listProg_1
; {
; ix = 0;
       clr.l     D2
; iy = 0;
       clr.l     D4
; // listar intervalo
; while (pArg[ix] != '-')
listProg_3:
       move.l    D5,A0
       move.b    0(A0,D2.L),D0
       cmp.b     #45,D0
       beq.s     listProg_5
; sNumPar[iy++] = pArg[ix++];
       move.l    D5,A0
       move.l    D2,D0
       addq.l    #1,D2
       move.l    D4,D1
       addq.l    #1,D4
       move.b    0(A0,D0.L),0(A3,D1.L)
       bra       listProg_3
listProg_5:
; sNumPar[iy] = 0x00;
       clr.b     0(A3,D4.L)
; pIni = atoi(sNumPar);
       move.l    A3,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-318(A6)
; iy = 0;
       clr.l     D4
; ix++;
       addq.l    #1,D2
; while (pArg[ix])
listProg_6:
       move.l    D5,A0
       tst.b     0(A0,D2.L)
       beq.s     listProg_8
; sNumPar[iy++] = pArg[ix++];
       move.l    D5,A0
       move.l    D2,D0
       addq.l    #1,D2
       move.l    D4,D1
       addq.l    #1,D4
       move.b    0(A0,D0.L),0(A3,D1.L)
       bra       listProg_6
listProg_8:
; sNumPar[iy] = 0x00;
       clr.b     0(A3,D4.L)
; if (sNumPar[0])
       tst.b     (A3)
       beq.s     listProg_9
; pFim = atoi(sNumPar);
       move.l    A3,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,A5
       bra.s     listProg_10
listProg_9:
; else
; pFim = 0xFFFF;
       move.w    #65535,A5
listProg_10:
       bra.s     listProg_11
listProg_1:
; }
; else if (pArg[0] != 0x00)
       move.l    D5,A0
       move.b    (A0),D0
       beq.s     listProg_11
; {
; // listar 1 linha
; pIni = atoi(pArg);
       move.l    D5,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-318(A6)
; pFim = pIni;
       move.w    -318(A6),A5
listProg_11:
; }
; vStartList = findNumberLine(pIni, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.w    -318(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D3
; // Nao achou numero de linha inicial
; if (!vStartList)
       tst.l     D3
       bne.s     listProg_13
; {
; printText("Non-existent line number\r\n\0");
       pea       @basic_117.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       listProg_18
listProg_13:
; }
; vNextList = vStartList;
       move.l    D3,-316(A6)
; vPauseRowCounter = 0;
       move.w    #0,A4
; while (1)
listProg_16:
; {
; // Guarda proxima posicao
; vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    D3,A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D3,A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D3,A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-316(A6)
; if (vNextList)
       tst.l     -316(A6)
       beq       listProg_19
; {
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    D3,A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    D3,A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-312(A6)
; if (vNumLin > pFim)
       move.w    A5,D0
       cmp.w     -312(A6),D0
       bhs.s     listProg_21
; break;
       bra       listProg_18
listProg_21:
; vStartList += 5;
       addq.l    #5,D3
; ix = 0;
       clr.l     D2
; // Coloca numero da linha na listagem
; itoa(vNumLin, sNumLin, 10);
       pea       10
       pea       -310(A6)
       move.w    -312(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; iz = 0;
       moveq     #0,D7
; while (sNumLin[iz])
listProg_23:
       lea       -310(A6),A0
       tst.b     0(A0,D7.L)
       beq.s     listProg_25
; {
; vLinhaList[ix++] = sNumLin[iz++];
       move.l    D7,D0
       addq.l    #1,D7
       lea       -310(A6),A0
       move.l    D2,D1
       addq.l    #1,D2
       move.b    0(A0,D0.L),0(A2,D1.L)
       bra       listProg_23
listProg_25:
; }
; vLinhaList[ix++] = 0x20;
       move.l    D2,D0
       addq.l    #1,D2
       move.b    #32,0(A2,D0.L)
; vFirstByte = 1;
       move.b    #1,-292(A6)
; // Pega caracter a caracter da linha
; while (*vStartList)
listProg_26:
       move.l    D3,A0
       tst.b     (A0)
       beq       listProg_28
; {
; vToken = *vStartList++;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    (A0),D6
; // Verifica se é token, se for, muda pra escrito
; if (vToken >= 0x80)
       and.w     #255,D6
       cmp.w     #128,D6
       blo       listProg_29
; {
; // Procura token na lista
; iy = findToken(vToken);
       and.l     #255,D6
       move.l    D6,-(A7)
       jsr       _findToken
       addq.w    #4,A7
       move.l    D0,D4
; iz = 0;
       moveq     #0,D7
; if (!vFirstByte)
       tst.b     -292(A6)
       bne       listProg_31
; {
; if (isalphas(*(vStartList - 2)) || isdigitus(*(vStartList - 2)) || *(vStartList - 2) == ')')
       move.l    D3,D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne       listProg_35
       move.l    D3,D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       bne.s     listProg_35
       move.l    D3,D0
       subq.l    #2,D0
       move.l    D0,A0
       move.b    (A0),D0
       cmp.b     #41,D0
       bne.s     listProg_33
listProg_35:
; vLinhaList[ix++] = 0x20;
       move.l    D2,D0
       addq.l    #1,D2
       move.b    #32,0(A2,D0.L)
listProg_33:
       bra.s     listProg_32
listProg_31:
; }
; else
; vFirstByte = 0;
       clr.b     -292(A6)
listProg_32:
; while (keywords[iy].keyword[iz])
listProg_36:
       move.l    D4,D0
       lsl.l     #3,D0
       lea       @basic_keywords.L,A0
       move.l    0(A0,D0.L),A0
       tst.b     0(A0,D7.L)
       beq.s     listProg_38
; {
; vLinhaList[ix++] = keywords[iy].keyword[iz++];
       move.l    D4,D0
       lsl.l     #3,D0
       lea       @basic_keywords.L,A0
       move.l    0(A0,D0.L),A0
       move.l    D7,D0
       addq.l    #1,D7
       move.l    D2,D1
       addq.l    #1,D2
       move.b    0(A0,D0.L),0(A2,D1.L)
       bra       listProg_36
listProg_38:
; }
; // Se nao for intervalo de funcao, coloca espaço depois do comando
; if (*vStartList != '=' && (vToken < 0xC0 || vToken > 0xEF))
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     listProg_39
       and.w     #255,D6
       cmp.w     #192,D6
       blo.s     listProg_41
       and.w     #255,D6
       cmp.w     #239,D6
       bls.s     listProg_39
listProg_41:
; vLinhaList[ix++] = 0x20;
       move.l    D2,D0
       addq.l    #1,D2
       move.b    #32,0(A2,D0.L)
listProg_39:
       bra.s     listProg_42
listProg_29:
; /*                    if (*vStartList != 0x28)
; vLinhaList[ix++] = 0x20;*/
; }
; else
; {
; // Apenas inclui na listagem
; //if (strchr("+-*^/=;:><", *vTempPointer) || *vTempPointer >= 0xF0)
; vLinhaList[ix++] = vToken;
       move.l    D2,D0
       addq.l    #1,D2
       move.b    D6,0(A2,D0.L)
; // Se nao for aspas e o proximo for um token, inclui um espaço
; if (vToken == 0x22 && *vStartList >=0x80)
       cmp.b     #34,D6
       bne.s     listProg_42
       move.l    D3,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     listProg_42
; vLinhaList[ix++] = 0x20;
       move.l    D2,D0
       addq.l    #1,D2
       move.b    #32,0(A2,D0.L)
listProg_42:
       bra       listProg_26
listProg_28:
; /*if (isdigitus(vToken) && *vStartList!=')' && *vStartList!='.' && *vStartList!='"' && !isdigitus(*vStartList))
; vLinhaList[ix++] = 0x20;*/
; }
; }
; vLinhaList[ix] = '\0';
       clr.b     0(A2,D2.L)
; iw = strlen(vLinhaList) / 40;
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-(A7)
       pea       40
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-24(A6)
; vLinhaList[ix++] = '\r';
       move.l    D2,D0
       addq.l    #1,D2
       move.b    #13,0(A2,D0.L)
; vLinhaList[ix++] = '\n';
       move.l    D2,D0
       addq.l    #1,D2
       move.b    #10,0(A2,D0.L)
; vLinhaList[ix++] = '\0';
       move.l    D2,D0
       addq.l    #1,D2
       clr.b     0(A2,D0.L)
; printText(vLinhaList);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vPauseRowCounter = vPauseRowCounter + 1 + iw;
       move.l    A4,D0
       addq.l    #1,D0
       add.l     -24(A6),D0
       move.l    D0,A4
; /*writeLongSerial("Aqui 332.666.0-[");
; itoa(pPause,sqtdtam,10);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vPauseRowCounter,sqtdtam,10);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(iw,sqtdtam,10);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(videoCursorPosRowY,sqtdtam,10);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(videoCursorPosRow,sqtdtam,10);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (pPause && vPauseRowCounter >= vdpMaxRows)
       move.w    14(A6),D0
       and.l     #65535,D0
       beq       listProg_46
       move.b    _vdpMaxRows.L,D0
       and.l     #255,D0
       move.l    A4,D1
       cmp.l     D0,D1
       blo       listProg_46
; {
; printText("press any key to continue\0");
       pea       @basic_118.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vtec = inputLineBasic(1,"@");
       pea       @basic_119.L
       pea       1
       jsr       _inputLineBasic
       addq.w    #8,A7
       move.b    D0,-291(A6)
; vPauseRowCounter = 0;
       move.w    #0,A4
; printText("\r\n\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; if (vtec == 0x1B)   // ESC
       move.b    -291(A6),D0
       cmp.b     #27,D0
       bne.s     listProg_46
; break;
       bra.s     listProg_18
listProg_46:
; }
; vStartList = vNextList;
       move.l    -316(A6),D3
       bra.s     listProg_20
listProg_19:
; }
; else
; break;
       bra.s     listProg_18
listProg_20:
       bra       listProg_16
listProg_18:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // Sintaxe:
; //      DEL <num>          : apaga só a linha <num>
; //      DEL <num>-         : apaga a partir da linha <num> até o fim
; //      DEL <numA>-<numB>  : apaga o intervalo de <numA> até <numB>, inclusive
; //-----------------------------------------------------------------------------
; void delLine(unsigned char *pArg)
; {
       xdef      _delLine
_delLine:
       link      A6,#-300
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.l    8(A6),D4
       lea       -16(A6),A2
       lea       _pStartProg.L,A3
; unsigned short pIni = 0, pFim = 0xFFFF;
       move.w    #0,A5
       move.w    #65535,A4
; unsigned char *vStartList = pStartProg;
       move.l    (A3),D2
; unsigned long vDelAddr, vAntAddr, vNewAddr;
; unsigned short vNumLin;
; char sNumLin [sizeof(short)*8+1];
; unsigned char vLinhaList[255], sNumPar[10], vToken;
; int ix, iy, iz;
; if (pArg[0] != 0x00 && strchr(pArg,'-') != 0x00)
       move.l    D4,A0
       move.b    (A0),D0
       beq       delLine_1
       pea       45
       move.l    D4,-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq       delLine_1
; {
; ix = 0;
       moveq     #0,D7
; iy = 0;
       clr.l     D6
; // listar intervalo
; while (pArg[ix] != '-')
delLine_3:
       move.l    D4,A0
       move.b    0(A0,D7.L),D0
       cmp.b     #45,D0
       beq.s     delLine_5
; sNumPar[iy++] = pArg[ix++];
       move.l    D4,A0
       move.l    D7,D0
       addq.l    #1,D7
       move.l    D6,D1
       addq.l    #1,D6
       move.b    0(A0,D0.L),0(A2,D1.L)
       bra       delLine_3
delLine_5:
; sNumPar[iy] = 0x00;
       clr.b     0(A2,D6.L)
; pIni = atoi(sNumPar);
       move.l    A2,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,A5
; iy = 0;
       clr.l     D6
; ix++;
       addq.l    #1,D7
; while (pArg[ix])
delLine_6:
       move.l    D4,A0
       tst.b     0(A0,D7.L)
       beq.s     delLine_8
; sNumPar[iy++] = pArg[ix++];
       move.l    D4,A0
       move.l    D7,D0
       addq.l    #1,D7
       move.l    D6,D1
       addq.l    #1,D6
       move.b    0(A0,D0.L),0(A2,D1.L)
       bra       delLine_6
delLine_8:
; sNumPar[iy] = 0x00;
       clr.b     0(A2,D6.L)
; if (sNumPar[0])
       tst.b     (A2)
       beq.s     delLine_9
; pFim = atoi(sNumPar);
       move.l    A2,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,A4
       bra.s     delLine_10
delLine_9:
; else
; pFim = 0xFFFF;
       move.w    #65535,A4
delLine_10:
       bra.s     delLine_12
delLine_1:
; }
; else if (pArg[0] != 0x00)
       move.l    D4,A0
       move.b    (A0),D0
       beq.s     delLine_11
; {
; pIni = atoi(pArg);
       move.l    D4,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,A5
; pFim = pIni;
       move.w    A5,A4
       bra.s     delLine_12
delLine_11:
; }
; else
; {
; printText("Syntax Error !");
       pea       @basic_120.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       delLine_18
delLine_12:
; }
; vDelAddr = findNumberLine(pIni, 0, 1);
       pea       1
       clr.l     -(A7)
       move.l    A5,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-298(A6)
; if (!vDelAddr)
       tst.l     -298(A6)
       bne.s     delLine_14
; {
; printText("Non-existent line number\r\n\0");
       pea       @basic_117.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       delLine_18
delLine_14:
; }
; while (1)
delLine_16:
; {
; vStartList = vDelAddr;
       move.l    -298(A6),D2
; // Guarda proxima posicao
; vNewAddr = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D2,A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,D3
; if (!vNewAddr)
       tst.l     D3
       bne.s     delLine_19
; break;
       bra       delLine_18
delLine_19:
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    D2,A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,D5
; if (vNumLin > pFim)
       cmp.w     A4,D5
       bls.s     delLine_21
; break;
       bra       delLine_18
delLine_21:
; vAntAddr = findNumberLine(vNumLin, 1, 1);
       pea       1
       pea       1
       and.l     #65535,D5
       move.l    D5,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-294(A6)
; // Apaga a linha atual
; *vStartList       = 0x00;
       move.l    D2,A0
       clr.b     (A0)
; *(vStartList + 1) = 0x00;
       move.l    D2,A0
       clr.b     1(A0)
; *(vStartList + 2) = 0x00;
       move.l    D2,A0
       clr.b     2(A0)
; *(vStartList + 3) = 0x00;
       move.l    D2,A0
       clr.b     3(A0)
; *(vStartList + 4) = 0x00;
       move.l    D2,A0
       clr.b     4(A0)
; vStartList += 5;
       addq.l    #5,D2
; while (*vStartList)
delLine_23:
       move.l    D2,A0
       tst.b     (A0)
       beq.s     delLine_25
; *vStartList++ = 0x00;
       move.l    D2,A0
       addq.l    #1,D2
       clr.b     (A0)
       bra       delLine_23
delLine_25:
; vStartList = vAntAddr;
       move.l    -294(A6),D2
; *vStartList++ = ((vNewAddr & 0xFF0000) >> 16);
       move.l    D3,D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D0,(A0)
; *vStartList++ = ((vNewAddr & 0xFF00) >> 8);
       move.l    D3,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D0,(A0)
; *vStartList++ =  (vNewAddr & 0xFF);
       move.l    D3,D0
       and.l     #255,D0
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D0,(A0)
; // Se for a primeira linha, reposiciona na proxima
; if (*firstLineNumber == vNumLin)
       move.l    _firstLineNumber.L,A0
       cmp.w     (A0),D5
       bne       delLine_29
; {
; if (vNewAddr)
       tst.l     D3
       beq.s     delLine_28
; {
; vStartList = vNewAddr;
       move.l    D3,D2
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    D2,A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,D5
; *firstLineNumber = vNumLin;
       move.l    _firstLineNumber.L,A0
       move.w    D5,(A0)
; *addrFirstLineNumber = vNewAddr;
       move.l    _addrFirstLineNumber.L,A0
       move.l    D3,(A0)
       bra.s     delLine_29
delLine_28:
; }
; else
; {
; *pStartProg = 0x00;
       move.l    (A3),A0
       clr.b     (A0)
; *(pStartProg + 1) = 0x00;
       move.l    (A3),A0
       clr.b     1(A0)
; *(pStartProg + 2) = 0x00;
       move.l    (A3),A0
       clr.b     2(A0)
; *nextAddrLine = pStartProg;
       move.l    _nextAddrLine.L,A0
       move.l    (A3),(A0)
; *firstLineNumber = 0;
       move.l    _firstLineNumber.L,A0
       clr.w     (A0)
; *addrFirstLineNumber = 0;
       move.l    _addrFirstLineNumber.L,A0
       clr.l     (A0)
delLine_29:
; }
; }
; if (!vNewAddr)
       tst.l     D3
       bne.s     delLine_30
; break;
       bra.s     delLine_18
delLine_30:
; vDelAddr = vNewAddr;
       move.l    D3,-298(A6)
       bra       delLine_16
delLine_18:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // Sintaxe:
; //      EDIT <num>          : Edita conteudo da linha <num>
; // PS Ainda precisa ser ajustado
; //-----------------------------------------------------------------------------
; void editLine(unsigned char *pNumber)
; {
       xdef      _editLine
_editLine:
       link      A6,#-304
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -266(A6),A2
       lea       -284(A6),A4
       move.l    8(A6),A5
; int pIni = 0, ix, iy, iz, iw, ivv, vNumLin, pFim;
       clr.l     -304(A6)
; unsigned char *vStartList = pStartProg, *vNextList;
       move.l    _pStartProg.L,D2
; unsigned char vRetInput;
; char sNumLin [sizeof(short)*8+1], vFirstByte;
; unsigned char vLinhaList[255], sNumPar[10], vToken;
; if (pNumber[0] != 0x00)
       move.b    (A5),D0
       beq.s     editLine_1
; {
; // rodar desde uma linha especifica
; pIni = atoi(pNumber);
       move.l    A5,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-304(A6)
       bra.s     editLine_2
editLine_1:
; }
; else
; {
; printText("Syntax Error !");
       pea       @basic_120.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       editLine_38
editLine_2:
; }
; vStartList = findNumberLine(pIni, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    -304(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D2
; // Nao achou numero de linha inicial
; if (!vStartList)
       tst.l     D2
       bne.s     editLine_4
; {
; printText("Non-existent line number\r\n\0");
       pea       @basic_117.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       editLine_38
editLine_4:
; }
; // Carrega a linha no buffer
; // Guarda proxima posicao
; vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D2,A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-288(A6)
; ix = 0;
       clr.l     D5
; ivv = 0;
       clr.l     D4
; if (vNextList)
       tst.l     -288(A6)
       beq       editLine_13
; {
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-296(A6)
; vStartList += 5;
       addq.l    #5,D2
; // Coloca numero da linha na listagem
; itoa(vNumLin, sNumLin, 10);
       pea       10
       move.l    A4,-(A7)
       move.l    -296(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; iz = 0;
       clr.l     D3
; while (sNumLin[iz++])
editLine_8:
       move.l    D3,D0
       addq.l    #1,D3
       tst.b     0(A4,D0.L)
       beq.s     editLine_10
; {
; vLinhaList[ivv] = sNumLin[ivv];
       move.b    0(A4,D4.L),0(A2,D4.L)
; ivv++;
       addq.l    #1,D4
       bra       editLine_8
editLine_10:
; }
; vLinhaList[ivv] = '\r';
       move.b    #13,0(A2,D4.L)
; vLinhaList[ivv + 1] = '\n';
       move.l    D4,A0
       move.b    #10,1(A0,A2.L)
; vLinhaList[ivv + 2] = '\0';
       move.l    D4,A0
       clr.b     2(A0,A2.L)
; printText(vLinhaList);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vFirstByte = 1;
       move.b    #1,-267(A6)
; vbufInput[ix] = 0x00;
       lea       _vbufInput.L,A0
       clr.b     0(A0,D5.L)
; ix = 0;
       clr.l     D5
; // Pega caracter a caracter da linha
; while (*vStartList)
editLine_11:
       move.l    D2,A0
       tst.b     (A0)
       beq       editLine_13
; {
; vToken = *vStartList++;
       move.l    D2,A0
       addq.l    #1,D2
       move.b    (A0),D6
; // Verifica se é token, se for, muda pra escrito
; if (vToken >= 0x80)
       and.w     #255,D6
       cmp.w     #128,D6
       blo       editLine_14
; {
; // Procura token na lista
; iy = findToken(vToken);
       and.l     #255,D6
       move.l    D6,-(A7)
       jsr       _findToken
       addq.w    #4,A7
       move.l    D0,A3
; iz = 0;
       clr.l     D3
; if (!vFirstByte)
       tst.b     -267(A6)
       bne       editLine_16
; {
; if (isalphas(*(vStartList - 2)) || isdigitus(*(vStartList - 2)) || *(vStartList - 2) == ')')
       move.l    D2,D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne       editLine_20
       move.l    D2,D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       bne.s     editLine_20
       move.l    D2,D0
       subq.l    #2,D0
       move.l    D0,A0
       move.b    (A0),D0
       cmp.b     #41,D0
       bne.s     editLine_18
editLine_20:
; vbufInput[ix++] = 0x20;
       move.l    D5,D0
       addq.l    #1,D5
       lea       _vbufInput.L,A0
       move.b    #32,0(A0,D0.L)
editLine_18:
       bra.s     editLine_17
editLine_16:
; }
; else
; vFirstByte = 0;
       clr.b     -267(A6)
editLine_17:
; while (keywords[iy].keyword[iz])
editLine_21:
       move.l    A3,D0
       lsl.l     #3,D0
       lea       @basic_keywords.L,A0
       move.l    0(A0,D0.L),A0
       tst.b     0(A0,D3.L)
       beq.s     editLine_23
; {
; vbufInput[ix++] = keywords[iy].keyword[iz++];
       move.l    A3,D0
       lsl.l     #3,D0
       lea       @basic_keywords.L,A0
       move.l    0(A0,D0.L),A0
       move.l    D3,D0
       addq.l    #1,D3
       move.l    D5,D1
       addq.l    #1,D5
       lea       _vbufInput.L,A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra       editLine_21
editLine_23:
; }
; // Se nao for intervalo de funcao, coloca espaço depois do comando
; if (*vStartList != '=' && (vToken < 0xC0 || vToken > 0xEF))
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     editLine_24
       and.w     #255,D6
       cmp.w     #192,D6
       blo.s     editLine_26
       and.w     #255,D6
       cmp.w     #239,D6
       bls.s     editLine_24
editLine_26:
; vbufInput[ix++] = 0x20;
       move.l    D5,D0
       addq.l    #1,D5
       lea       _vbufInput.L,A0
       move.b    #32,0(A0,D0.L)
editLine_24:
       bra.s     editLine_27
editLine_14:
; }
; else
; {
; vbufInput[ix++] = vToken;
       move.l    D5,D0
       addq.l    #1,D5
       lea       _vbufInput.L,A0
       move.b    D6,0(A0,D0.L)
; // Se nao for aspas e o proximo for um token, inclui um espaço
; if (vToken == 0x22 && *vStartList >=0x80)
       cmp.b     #34,D6
       bne.s     editLine_27
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     editLine_27
; vbufInput[ix++] = 0x20;            }
       move.l    D5,D0
       addq.l    #1,D5
       lea       _vbufInput.L,A0
       move.b    #32,0(A0,D0.L)
editLine_27:
       bra       editLine_11
editLine_13:
; }
; }
; vbufInput[ix] = '\0';
       lea       _vbufInput.L,A0
       clr.b     0(A0,D5.L)
; // Edita a linha no buffer, usando o inputLineBasic do monitor.c
; vRetInput = inputLineBasic(128,'S'); // S - String Linha Editavel
       pea       83
       pea       128
       jsr       _inputLineBasic
       addq.w    #8,A7
       move.b    D0,D7
; if (vbufInput[0] != 0x00 && (vRetInput == 0x0D || vRetInput == 0x0A))
       move.b    _vbufInput.L,D0
       beq       editLine_29
       cmp.b     #13,D7
       beq.s     editLine_31
       cmp.b     #10,D7
       bne       editLine_29
editLine_31:
; {
; vLinhaList[ivv++] = 0x20;
       move.l    D4,D0
       addq.l    #1,D4
       move.b    #32,0(A2,D0.L)
; ix = strlen(vbufInput);
       pea       _vbufInput.L
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D5
; for(iz = 0; iz <= ix; iz++)
       clr.l     D3
editLine_32:
       cmp.l     D5,D3
       bgt.s     editLine_34
; vLinhaList[ivv++] = vbufInput[iz];
       lea       _vbufInput.L,A0
       move.l    D4,D0
       addq.l    #1,D4
       move.b    0(A0,D3.L),0(A2,D0.L)
       addq.l    #1,D3
       bra       editLine_32
editLine_34:
; vLinhaList[ivv] = 0x00;
       clr.b     0(A2,D4.L)
; for(iz = 0; iz <= ivv; iz++)
       clr.l     D3
editLine_35:
       cmp.l     D4,D3
       bgt.s     editLine_37
; vbufInput[iz] = vLinhaList[iz];
       lea       _vbufInput.L,A0
       move.b    0(A2,D3.L),0(A0,D3.L)
       addq.l    #1,D3
       bra       editLine_35
editLine_37:
; printText("\r\n\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; // Apaga a linha atual
; delLine(pNumber);
       move.l    A5,-(A7)
       jsr       _delLine
       addq.w    #4,A7
; // Reinsere a linha editada
; processLine();
       jsr       _processLine
; printText("\r\nOK\0");
       pea       @basic_97.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra.s     editLine_38
editLine_29:
; }
; else if (vRetInput != 0x1B)
       cmp.b     #27,D7
       beq.s     editLine_38
; {
; printText("\r\nAborted !!!\r\n\0");
       pea       @basic_121.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
editLine_38:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // Sintaxe:
; //      RUN                : Executa o programa a partir da primeira linha do prog
; //      RUN <num>          : Executa a partir da linha <num>
; //-----------------------------------------------------------------------------
; void runProg(unsigned char *pNumber)
; {
       xdef      _runProg
_runProg:
       link      A6,#-612
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       _changedPointer.L,A2
       lea       _vErroProc.L,A3
       lea       _pointerRunProg.L,A4
       lea       -82(A6),A5
; // Default rodar desde a primeira linha
; int pIni = 0, ix;
       clr.l     D6
; unsigned char *vStartList = pStartProg;
       move.l    _pStartProg.L,D2
; unsigned long vNextList;
; unsigned short vNumLin;
; unsigned int vInt;
; unsigned char vString[255], vTipoRet;
; unsigned long vReal;
; typeInf vRetInf;
; unsigned int vReta;
; char sNumLin [sizeof(short)*8+1];
; char vBuffer [sizeof(long)*8+1];
; unsigned char *vPointerChangedPointer;
; unsigned char *pForStack = forStack;
       move.l    _forStack.L,-26(A6)
; unsigned char sqtdtam[20];
; unsigned char *vTempPointer;
; unsigned char vBufRec;
; *nextAddrSimpVar = pStartSimpVar;
       move.l    _nextAddrSimpVar.L,A0
       move.l    _pStartSimpVar.L,(A0)
; *nextAddrArrayVar = pStartArrayVar;
       move.l    _nextAddrArrayVar.L,A0
       move.l    _pStartArrayVar.L,(A0)
; *nextAddrString = pStartString;
       move.l    _nextAddrString.L,A0
       move.l    _pStartString.L,(A0)
; clearRuntimeData(pForStack);
       move.l    -26(A6),-(A7)
       jsr       @basic_clearRuntimeData
       addq.w    #4,A7
; if (pNumber[0] != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq.s     runProg_1
; {
; // rodar desde uma linha especifica
; pIni = atoi(pNumber);
       move.l    8(A6),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,D6
runProg_1:
; }
; vStartList = findNumberLine(pIni, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       and.l     #65535,D6
       move.l    D6,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D2
; // Nao achou numero de linha inicial
; if (!vStartList)
       tst.l     D2
       bne.s     runProg_3
; {
; printText("Non-existent line number\r\n\0");
       pea       @basic_117.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       runProg_43
runProg_3:
; }
; vNextList = vStartList;
       move.l    D2,D4
; *ftos=0;
       move.l    _ftos.L,A0
       clr.l     (A0)
; *gtos=0;
       move.l    _gtos.L,A0
       clr.l     (A0)
; *changedPointer = 0;
       move.l    (A2),A0
       clr.l     (A0)
; *vDataPointer = 0;
       move.l    _vDataPointer.L,A0
       clr.l     (A0)
; *randSeed = *(vmfp + Reg_TADR);
       move.l    _vmfp.L,A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    _randSeed.L,A0
       move.l    D0,(A0)
; *onErrGoto = 0;
       move.l    _onErrGoto.L,A0
       clr.l     (A0)
; while (1)
runProg_6:
; {
; if (*changedPointer!=0)
       move.l    (A2),A0
       move.l    (A0),D0
       beq.s     runProg_9
; vStartList = *changedPointer;
       move.l    (A2),A0
       move.l    (A0),D2
runProg_9:
; // Guarda proxima posicao
; vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D2,A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,D4
; *nextAddr = vNextList;
       move.l    _nextAddr.L,A0
       move.l    D4,(A0)
; if (vNextList)
       tst.l     D4
       beq       runProg_11
; {
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    D2,A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,D5
; vStartList += 5;
       addq.l    #5,D2
; // Pega caracter a caracter da linha
; *changedPointer = 0;
       move.l    (A2),A0
       clr.l     (A0)
; *vMaisTokens = 0;
       move.l    _vMaisTokens.L,A0
       clr.b     (A0)
; *vParenteses = 0x00;
       move.l    _vParenteses.L,A0
       clr.b     (A0)
; *vTemIf = 0x00;
       move.l    _vTemIf.L,A0
       clr.b     (A0)
; *vTemThen = 0;
       move.l    _vTemThen.L,A0
       clr.b     (A0)
; *vTemElse = 0;
       move.l    _vTemElse.L,A0
       clr.b     (A0)
; *vTemIfAndOr = 0x00;
       move.l    _vTemIfAndOr.L,A0
       clr.b     (A0)
; vRetInf.tString[0] = 0x00;
       lea       -344(A6),A0
       clr.b     (A0)
; *pointerRunProg = vStartList;
       move.l    (A4),A0
       move.l    D2,(A0)
; *vErroProc = 0;
       move.l    (A3),A0
       clr.w     (A0)
; do
; {
runProg_13:
; vBufRec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,-1(A6)
; if (vBufRec==27)
       move.b    -1(A6),D0
       cmp.b     #27,D0
       bne       runProg_15
; {
; // volta para modo texto
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.b    _vdpModeBas.L,D0
       cmp.b     #3,D0
       beq.s     runProg_17
; basText();
       jsr       _basText
runProg_17:
; #endif
; // mostra mensagem de para subita
; printText("\r\nStopped at ");
       pea       @basic_122.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vNumLin, sNumLin, 10);
       pea       10
       move.l    A5,-(A7)
       and.l     #65535,D5
       move.l    D5,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sNumLin);
       move.l    A5,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; // sai do laço
; *nextAddr = 0;
       move.l    _nextAddr.L,A0
       clr.l     (A0)
; break;
       bra       runProg_14
runProg_15:
; }
; *doisPontos = 0;
       move.l    _doisPontos.L,A0
       clr.b     (A0)
; *vParenteses = 0x00;
       move.l    _vParenteses.L,A0
       clr.b     (A0)
; *vInicioSentenca = 1;
       move.l    _vInicioSentenca.L,A0
       move.b    #1,(A0)
; if (*traceOn)
       move.l    _traceOn.L,A0
       tst.b     (A0)
       beq       runProg_19
; {
; printText("\r\nExecuting at ");
       pea       @basic_123.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vNumLin, sNumLin, 10);
       pea       10
       move.l    A5,-(A7)
       and.l     #65535,D5
       move.l    D5,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sNumLin);
       move.l    A5,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
runProg_19:
; }
; vTempPointer = *pointerRunProg;
       move.l    (A4),A0
       move.l    (A0),D3
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A4),A0
       addq.l    #1,(A0)
; vReta = executeToken(*vTempPointer);
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _executeToken
       addq.w    #4,A7
       move.l    D0,-86(A6)
; if (*vErroProc)
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     runProg_21
; {
; if (*onErrGoto == 0)
       move.l    _onErrGoto.L,A0
       move.l    (A0),D0
       bne.s     runProg_23
; break;
       bra       runProg_14
runProg_23:
; *vErroProc = 0;
       move.l    (A3),A0
       clr.w     (A0)
; *changedPointer = *onErrGoto;
       move.l    _onErrGoto.L,A0
       move.l    (A2),A1
       move.l    (A0),(A1)
runProg_21:
; }
; if (*changedPointer!=0)
       move.l    (A2),A0
       move.l    (A0),D0
       beq.s     runProg_27
; {
; vPointerChangedPointer = *changedPointer;
       move.l    (A2),A0
       move.l    (A0),-30(A6)
; if (*vPointerChangedPointer == 0x3A)
       move.l    -30(A6),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     runProg_27
; {
; *pointerRunProg = *changedPointer;
       move.l    (A2),A0
       move.l    (A4),A1
       move.l    (A0),(A1)
; *changedPointer = 0;
       move.l    (A2),A0
       clr.l     (A0)
runProg_27:
; }
; }
; vTempPointer = *pointerRunProg;
       move.l    (A4),A0
       move.l    (A0),D3
; if (*vTempPointer != 0x00)
       move.l    D3,A0
       move.b    (A0),D0
       beq       runProg_35
; {
; if (*vTempPointer == 0x3A)
       move.l    D3,A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     runProg_31
; {
; *doisPontos = 1;
       move.l    _doisPontos.L,A0
       move.b    #1,(A0)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A4),A0
       addq.l    #1,(A0)
       bra.s     runProg_35
runProg_31:
; }
; else
; {
; if (*doisPontos && *vTempPointer <= 0x80)
       move.l    _doisPontos.L,A0
       move.b    (A0),D0
       and.l     #255,D0
       beq.s     runProg_33
       move.l    D3,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       bhi.s     runProg_33
; {
; // nao faz nada
; }
       bra.s     runProg_35
runProg_33:
; else
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) break;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     runProg_35
       bra.s     runProg_14
runProg_35:
       move.l    _doisPontos.L,A0
       tst.b     (A0)
       bne       runProg_13
runProg_14:
; }
; }
; }
; } while (*doisPontos);
; if (*vErroProc)
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     runProg_37
; {
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.b    _vdpModeBas.L,D0
       cmp.b     #3,D0
       beq.s     runProg_39
; basText();
       jsr       _basText
runProg_39:
; #endif
; showErrorMessage(*vErroProc, vNumLin);
       and.l     #65535,D5
       move.l    D5,-(A7)
       move.l    (A3),A0
       move.w    (A0),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _showErrorMessage
       addq.w    #8,A7
; break;
       bra.s     runProg_8
runProg_37:
; }
; if (*nextAddr == 0)
       move.l    _nextAddr.L,A0
       move.l    (A0),D0
       bne.s     runProg_41
; break;
       bra.s     runProg_8
runProg_41:
; vNextList = *nextAddr;
       move.l    _nextAddr.L,A0
       move.l    (A0),D4
; vStartList = vNextList;
       move.l    D4,D2
       bra.s     runProg_12
runProg_11:
; }
; else
; break;
       bra.s     runProg_8
runProg_12:
       bra       runProg_6
runProg_8:
; }
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.b    _vdpModeBas.L,D0
       cmp.b     #3,D0
       beq.s     runProg_43
; basText();
       jsr       _basText
runProg_43:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; #endif
; }
; //-----------------------------------------------------------------------------
; // Mostra mensagem de erro de acordo com o codigo do erro e numero da linha
; //-----------------------------------------------------------------------------
; void showErrorMessage(unsigned int pError, unsigned int pNumLine)
; {
       xdef      _showErrorMessage
_showErrorMessage:
       link      A6,#-20
; char sNumLin [sizeof(short)*8+1];
; printText("\r\n");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(listError[pError]);
       move.l    8(A6),D1
       lsl.l     #2,D1
       lea       @basic_listError.L,A0
       move.l    0(A0,D1.L),-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; if (pNumLine > 0)
       move.l    12(A6),D0
       cmp.l     #0,D0
       bls.s     showErrorMessage_1
; {
; itoa(pNumLine, sNumLin, 10);
       pea       10
       pea       -18(A6)
       move.l    12(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(" at ");
       pea       @basic_124.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(sNumLin);
       pea       -18(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
showErrorMessage_1:
; }
; printText(" !\r\n\0");
       pea       @basic_125.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; *vErroProc = 0;
       move.l    _vErroProc.L,A0
       clr.w     (A0)
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Load basic program in memory, throught xmodem protocol
; // Syntaxe:
; //          XBASLOAD
; //--------------------------------------------------------------------------------------
; int basXBasLoad(void)
; {
       xdef      _basXBasLoad
_basXBasLoad:
       movem.l   D2/D3/D4/D5,-(A7)
; unsigned char vRet = 0;
       clr.b     D4
; unsigned char vByte = 0;
       clr.b     D2
; unsigned char *vTemp = pStartXBasLoad;
       move.l    _pStartXBasLoad.L,D5
; unsigned char *vBufptr = &vbufInput;
       lea       _vbufInput.L,A0
       move.l    A0,D3
; printText("Loading Basic Program...\r\n");
       pea       @basic_126.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; // Carrega programa em outro ponto da memoria
; vRet = loadSerialToMem(pStartXBasLoad,0);
       clr.l     -(A7)
       move.l    _pStartXBasLoad.L,-(A7)
       move.l    1070,A0
       jsr       (A0)
       addq.w    #8,A7
       move.b    D0,D4
; // Se tudo OK, tokeniza como se estivesse sendo digitado
; if (!vRet)
       tst.b     D4
       bne       basXBasLoad_1
; {
; printText("Done.\r\n");
       pea       @basic_127.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Processing...\r\n");
       pea       @basic_128.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; while (1)
basXBasLoad_3:
; {
; vByte = *vTemp++;
       move.l    D5,A0
       addq.l    #1,D5
       move.b    (A0),D2
; if (vByte != 0x1A)
       cmp.b     #26,D2
       beq.s     basXBasLoad_6
; {
; if (vByte != 0xD && vByte != 0x0A)
       cmp.b     #13,D2
       beq.s     basXBasLoad_8
       cmp.b     #10,D2
       beq.s     basXBasLoad_8
; *vBufptr++ = vByte;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    D2,(A0)
       bra.s     basXBasLoad_9
basXBasLoad_8:
; else
; {
; vTemp++;
       addq.l    #1,D5
; *vBufptr = 0x00;
       move.l    D3,A0
       clr.b     (A0)
; vBufptr = &vbufInput;
       lea       _vbufInput.L,A0
       move.l    A0,D3
; processLine();
       jsr       _processLine
basXBasLoad_9:
       bra.s     basXBasLoad_7
basXBasLoad_6:
; }
; }
; else
; break;
       bra.s     basXBasLoad_5
basXBasLoad_7:
       bra       basXBasLoad_3
basXBasLoad_5:
; }
; printText("Done.\r\n");
       pea       @basic_127.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra.s     basXBasLoad_11
basXBasLoad_1:
; }
; else
; {
; if (vRet == 0xFE)
       and.w     #255,D4
       cmp.w     #254,D4
       bne.s     basXBasLoad_10
; *vErroProc = 19;
       move.l    _vErroProc.L,A0
       move.w    #19,(A0)
       bra.s     basXBasLoad_11
basXBasLoad_10:
; else
; *vErroProc = 20;
       move.l    _vErroProc.L,A0
       move.w    #20,(A0)
basXBasLoad_11:
; }
; return 0;
       clr.l     D0
       movem.l   (A7)+,D2/D3/D4/D5
       rts
; }
; //--------------------------------------------------------------------------------------
; // Load basic program in memory, throught xmodem protocol with 1K blocks and CRC
; // Syntaxe:
; //          XBASLOAD1K
; //--------------------------------------------------------------------------------------
; int basXBasLoad1k(void)
; {
       xdef      _basXBasLoad1k
_basXBasLoad1k:
       movem.l   D2/D3/D4/D5,-(A7)
; unsigned char vRet = 0;
       clr.b     D4
; unsigned char vByte = 0;
       clr.b     D2
; unsigned char *vTemp = pStartXBasLoad;
       move.l    _pStartXBasLoad.L,D5
; unsigned char *vBufptr = &vbufInput;
       lea       _vbufInput.L,A0
       move.l    A0,D3
; printText("Loading Basic Program 1k...\r\n");
       pea       @basic_129.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; // Carrega programa em outro ponto da memoria
; vRet = loadSerialToMem2(pStartXBasLoad,0);
       clr.l     -(A7)
       move.l    _pStartXBasLoad.L,-(A7)
       move.l    1210,A0
       jsr       (A0)
       addq.w    #8,A7
       move.b    D0,D4
; // Se tudo OK, tokeniza como se estivesse sendo digitado
; if (!vRet)
       tst.b     D4
       bne       basXBasLoad1k_1
; {
; printText("Done.\r\n");
       pea       @basic_127.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Processing...\r\n");
       pea       @basic_128.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; while (1)
basXBasLoad1k_3:
; {
; vByte = *vTemp++;
       move.l    D5,A0
       addq.l    #1,D5
       move.b    (A0),D2
; if (vByte != 0x1A)
       cmp.b     #26,D2
       beq.s     basXBasLoad1k_6
; {
; if (vByte != 0xD && vByte != 0x0A)
       cmp.b     #13,D2
       beq.s     basXBasLoad1k_8
       cmp.b     #10,D2
       beq.s     basXBasLoad1k_8
; *vBufptr++ = vByte;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    D2,(A0)
       bra.s     basXBasLoad1k_9
basXBasLoad1k_8:
; else
; {
; vTemp++;
       addq.l    #1,D5
; *vBufptr = 0x00;
       move.l    D3,A0
       clr.b     (A0)
; vBufptr = &vbufInput;
       lea       _vbufInput.L,A0
       move.l    A0,D3
; processLine();
       jsr       _processLine
basXBasLoad1k_9:
       bra.s     basXBasLoad1k_7
basXBasLoad1k_6:
; }
; }
; else
; break;
       bra.s     basXBasLoad1k_5
basXBasLoad1k_7:
       bra       basXBasLoad1k_3
basXBasLoad1k_5:
; }
; printText("Done.\r\n");
       pea       @basic_127.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra.s     basXBasLoad1k_11
basXBasLoad1k_1:
; }
; else
; {
; if (vRet == 0xFE)
       and.w     #255,D4
       cmp.w     #254,D4
       bne.s     basXBasLoad1k_10
; *vErroProc = 19;
       move.l    _vErroProc.L,A0
       move.w    #19,(A0)
       bra.s     basXBasLoad1k_11
basXBasLoad1k_10:
; else
; *vErroProc = 20;
       move.l    _vErroProc.L,A0
       move.w    #20,(A0)
basXBasLoad1k_11:
; }
; return 0;
       clr.l     D0
       movem.l   (A7)+,D2/D3/D4/D5
       rts
; }
; /***************************************************************************************/
; /* Secao CORE - Processamento das linhas apos RUN ou ENTER no processline sem numero   */
; /* Controle do fluxo de execucao e ordem de leitura dentro da linha processando        */
; /***************************************************************************************/
; //-----------------------------------------------------------------------------
; // Executa cada token, chamando as funcoes de acordo
; //-----------------------------------------------------------------------------
; int executeToken(unsigned char pToken)
; {
       xdef      _executeToken
_executeToken:
       link      A6,#-28
       movem.l   D2/A2/A3,-(A7)
       lea       _basTrig.L,A2
       lea       _basLeftRightMid.L,A3
; char vReta = 0;
       clr.b     D2
; #ifndef __TESTE_TOKENIZE__
; unsigned char *pForStack = forStack;
       move.l    _forStack.L,-28(A6)
; int ix;
; unsigned char sqtdtam[20];
; switch (pToken)
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #178,D0
       beq       executeToken_34
       bhi       executeToken_67
       cmp.l     #143,D0
       beq       executeToken_18
       bhi       executeToken_68
       cmp.l     #135,D0
       beq       executeToken_10
       bhi       executeToken_69
       cmp.l     #130,D0
       beq       executeToken_6
       bhi.s     executeToken_70
       cmp.l     #128,D0
       beq       executeToken_4
       bhi.s     executeToken_71
       tst.l     D0
       beq       executeToken_3
       bra       executeToken_1
executeToken_71:
       cmp.l     #129,D0
       beq       executeToken_5
       bra       executeToken_1
executeToken_70:
       cmp.l     #133,D0
       beq       executeToken_8
       bhi.s     executeToken_72
       cmp.l     #131,D0
       beq       executeToken_7
       bra       executeToken_1
executeToken_72:
       cmp.l     #134,D0
       beq       executeToken_9
       bra       executeToken_1
executeToken_69:
       cmp.l     #139,D0
       beq       executeToken_14
       bhi.s     executeToken_73
       cmp.l     #137,D0
       beq       executeToken_12
       bhi.s     executeToken_74
       cmp.l     #136,D0
       beq       executeToken_11
       bra       executeToken_1
executeToken_74:
       cmp.l     #138,D0
       beq       executeToken_13
       bra       executeToken_1
executeToken_73:
       cmp.l     #141,D0
       beq       executeToken_16
       bhi.s     executeToken_75
       cmp.l     #140,D0
       beq       executeToken_15
       bra       executeToken_1
executeToken_75:
       cmp.l     #142,D0
       beq       executeToken_17
       bra       executeToken_1
executeToken_68:
       cmp.l     #151,D0
       beq       executeToken_26
       bhi       executeToken_76
       cmp.l     #147,D0
       beq       executeToken_22
       bhi.s     executeToken_77
       cmp.l     #145,D0
       beq       executeToken_20
       bhi.s     executeToken_78
       cmp.l     #144,D0
       beq       executeToken_19
       bra       executeToken_1
executeToken_78:
       cmp.l     #146,D0
       beq       executeToken_21
       bra       executeToken_1
executeToken_77:
       cmp.l     #149,D0
       beq       executeToken_24
       bhi.s     executeToken_79
       cmp.l     #148,D0
       beq       executeToken_23
       bra       executeToken_1
executeToken_79:
       cmp.l     #150,D0
       beq       executeToken_25
       bra       executeToken_1
executeToken_76:
       cmp.l     #158,D0
       beq       executeToken_30
       bhi.s     executeToken_80
       cmp.l     #153,D0
       beq       executeToken_28
       bhi.s     executeToken_81
       cmp.l     #152,D0
       beq       executeToken_27
       bra       executeToken_1
executeToken_81:
       cmp.l     #154,D0
       beq       executeToken_29
       bra       executeToken_1
executeToken_80:
       cmp.l     #176,D0
       beq       executeToken_32
       bhi.s     executeToken_82
       cmp.l     #159,D0
       beq       executeToken_31
       bra       executeToken_1
executeToken_82:
       cmp.l     #177,D0
       beq       executeToken_33
       bra       executeToken_1
executeToken_67:
       cmp.l     #224,D0
       beq       executeToken_50
       bhi       executeToken_83
       cmp.l     #187,D0
       beq       executeToken_42
       bhi       executeToken_84
       cmp.l     #182,D0
       beq       executeToken_38
       bhi.s     executeToken_85
       cmp.l     #180,D0
       beq       executeToken_36
       bhi.s     executeToken_86
       cmp.l     #179,D0
       beq       executeToken_35
       bra       executeToken_1
executeToken_86:
       cmp.l     #181,D0
       beq       executeToken_37
       bra       executeToken_1
executeToken_85:
       cmp.l     #185,D0
       beq       executeToken_40
       bhi.s     executeToken_87
       cmp.l     #184,D0
       beq       executeToken_39
       bra       executeToken_1
executeToken_87:
       cmp.l     #186,D0
       beq       executeToken_41
       bra       executeToken_1
executeToken_84:
       cmp.l     #209,D0
       beq       executeToken_46
       bhi.s     executeToken_88
       cmp.l     #205,D0
       beq       executeToken_44
       bhi.s     executeToken_89
       cmp.l     #196,D0
       beq       executeToken_43
       bra       executeToken_1
executeToken_89:
       cmp.l     #206,D0
       beq       executeToken_45
       bra       executeToken_1
executeToken_88:
       cmp.l     #220,D0
       beq       executeToken_48
       bhi.s     executeToken_90
       cmp.l     #219,D0
       beq       executeToken_47
       bra       executeToken_1
executeToken_90:
       cmp.l     #221,D0
       beq       executeToken_49
       bra       executeToken_1
executeToken_83:
       cmp.l     #232,D0
       beq       executeToken_58
       bhi       executeToken_91
       cmp.l     #228,D0
       beq       executeToken_54
       bhi.s     executeToken_92
       cmp.l     #226,D0
       beq       executeToken_52
       bhi.s     executeToken_93
       cmp.l     #225,D0
       beq       executeToken_51
       bra       executeToken_1
executeToken_93:
       cmp.l     #227,D0
       beq       executeToken_53
       bra       executeToken_1
executeToken_92:
       cmp.l     #230,D0
       beq       executeToken_56
       bhi.s     executeToken_94
       cmp.l     #229,D0
       beq       executeToken_55
       bra       executeToken_1
executeToken_94:
       cmp.l     #231,D0
       beq       executeToken_57
       bra       executeToken_1
executeToken_91:
       cmp.l     #236,D0
       beq       executeToken_62
       bhi.s     executeToken_95
       cmp.l     #234,D0
       beq       executeToken_60
       bhi.s     executeToken_96
       cmp.l     #233,D0
       beq       executeToken_59
       bra       executeToken_1
executeToken_96:
       cmp.l     #235,D0
       beq       executeToken_61
       bra       executeToken_1
executeToken_95:
       cmp.l     #238,D0
       beq       executeToken_64
       bhi.s     executeToken_97
       cmp.l     #237,D0
       beq       executeToken_63
       bra       executeToken_1
executeToken_97:
       cmp.l     #239,D0
       beq       executeToken_65
       bra       executeToken_1
executeToken_3:
; {
; case 0x00:  // End of Line
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_4:
; case 0x80:  // Let
; vReta = basLet();
       jsr       _basLet
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_5:
; case 0x81:  // Print
; vReta = basPrint();
       jsr       _basPrint
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_6:
; case 0x82:  // IF
; vReta = basIf();
       jsr       _basIf
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_7:
; case 0x83:  // THEN - nao faz nada
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_8:
; case 0x85:  // FOR
; vReta = basFor();
       jsr       _basFor
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_9:
; case 0x86:  // TO - nao faz nada
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_10:
; case 0x87:  // NEXT
; vReta = basNext();
       jsr       _basNext
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_11:
; case 0x88:  // STEP - nao faz nada
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_12:
; case 0x89:  // GOTO
; vReta = basGoto();
       jsr       _basGoto
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_13:
; case 0x8A:  // GOSUB
; vReta = basGosub();
       jsr       _basGosub
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_14:
; case 0x8B:  // RETURN
; vReta = basReturn();
       jsr       _basReturn
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_15:
; case 0x8C:  // REM - Ignora todas a linha depois dele
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_16:
; case 0x8D:  // RESERVED
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_17:
; case 0x8E:  // RESERVED
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_18:
; case 0x8F:  // DIM
; vReta = basDim();
       jsr       _basDim
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_19:
; case 0x90:  // Nao fax nada, soh teste, pode ser retirado
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_20:
; case 0x91:  // DIM
; vReta = basOnVar();
       jsr       _basOnVar
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_21:
; case 0x92:  // Input
; vReta = basInputGet(250);
       pea       250
       jsr       _basInputGet
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_22:
; case 0x93:  // Get
; vReta = basInputGet(1);
       pea       1
       jsr       _basInputGet
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_23:
; case 0x94:  // reservado
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_24:
; case 0x95:  // LOCATE
; vReta = basLocate();
       jsr       _basLocate
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_25:
; case 0x96:  // CLS
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; break;
       bra       executeToken_99
executeToken_26:
; case 0x97:  // CLEAR - Clear all variables
; clearRuntimeData(pForStack);
       move.l    -28(A6),-(A7)
       jsr       @basic_clearRuntimeData
       addq.w    #4,A7
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_27:
; case 0x98:  // DATA - Ignora toda a linha depois dele, READ vai ler essa linha
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_28:
; case 0x99:  // Read
; vReta = basRead();
       jsr       _basRead
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_29:
; case 0x9A:  // Restore
; vReta = basRestore();
       jsr       _basRestore
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_30:
; case 0x9E:  // END
; vReta = basEnd();
       jsr       _basEnd
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_31:
; case 0x9F:  // STOP
; vReta = basStop();
       jsr       _basStop
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_32:
; case 0xB0:  // SCREEN
; vReta = basScreen();
       jsr       _basScreen
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_33:
; case 0xB1:  // CIRCLE
; vReta = basCircle();
       jsr       _basCircle
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_34:
; case 0xB2:  // RECT
; vReta = basRect();
       jsr       _basRect
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_35:
; case 0xB3:  // COLOR
; vReta = basColor();
       jsr       _basColor
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_36:
; case 0xB4:  // PLOT
; vReta = basPlot();
       jsr       _basPlot
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_37:
; case 0xB5:  // HLIN
; vReta = basHVlin(1);
       pea       1
       jsr       _basHVlin
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_38:
; case 0xB6:  // VLIN
; vReta = basHVlin(2);
       pea       2
       jsr       _basHVlin
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_39:
; case 0xB8:  // PAINT
; vReta = basPaint();
       jsr       _basPaint
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_40:
; case 0xB9:  // LINE
; vReta = basLine();
       jsr       _basLine
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_41:
; case 0xBA:  // AT - Nao faz nada
; vReta = 0;
       clr.b     D2
; break;
       bra       executeToken_99
executeToken_42:
; case 0xBB:  // ONERR
; vReta = basOnErr();
       jsr       _basOnErr
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_43:
; case 0xC4:  // ASC
; vReta = basAsc();
       jsr       _basAsc
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_44:
; case 0xCD:  // PEEK
; vReta = basPeekPoke('R');
       pea       82
       jsr       _basPeekPoke
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_45:
; case 0xCE:  // POKE
; vReta = basPeekPoke('W');
       pea       87
       jsr       _basPeekPoke
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_46:
; case 0xD1:  // RND
; vReta = basRnd();
       jsr       _basRnd
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_47:
; case 0xDB:  // Len
; vReta = basLen();
       jsr       _basLen
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_48:
; case 0xDC:  // Val
; vReta = basVal();
       jsr       _basVal
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_49:
; case 0xDD:  // Str$
; vReta = basStr();
       jsr       _basStr
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_50:
; case 0xE0:  // POINT
; vReta = basPoint();
       jsr       _basPoint
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_51:
; case 0xE1:  // Chr$
; vReta = basChr();
       jsr       _basChr
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_52:
; case 0xE2:  // Fre(0)
; vReta = basFre();
       jsr       _basFre
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_53:
; case 0xE3:  // Sqrt
; vReta = basTrig(6);
       pea       6
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_54:
; case 0xE4:  // Sin
; vReta = basTrig(1);
       pea       1
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_55:
; case 0xE5:  // Cos
; vReta = basTrig(2);
       pea       2
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_56:
; case 0xE6:  // Tan
; vReta = basTrig(3);
       pea       3
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_57:
; case 0xE7:  // Log
; vReta = basTrig(4);
       pea       4
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_58:
; case 0xE8:  // Exp
; vReta = basTrig(5);
       pea       5
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_59:
; case 0xE9:  // SPC
; vReta = basSpc();
       jsr       _basSpc
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_60:
; case 0xEA:  // Tab
; vReta = basTab();
       jsr       _basTab
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_61:
; case 0xEB:  // Mid$
; vReta = basLeftRightMid('M');
       pea       77
       jsr       (A3)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_62:
; case 0xEC:  // Right$
; vReta = basLeftRightMid('R');
       pea       82
       jsr       (A3)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_63:
; case 0xED:  // Left$
; vReta = basLeftRightMid('L');
       pea       76
       jsr       (A3)
       addq.w    #4,A7
       move.b    D0,D2
; break;
       bra       executeToken_99
executeToken_64:
; case 0xEE:  // INT
; vReta = basInt();
       jsr       _basInt
       move.b    D0,D2
; break;
       bra.s     executeToken_99
executeToken_65:
; case 0xEF:  // ABS
; vReta = basAbs();
       jsr       _basAbs
       move.b    D0,D2
; break;
       bra.s     executeToken_99
executeToken_1:
; default:
; if (pToken < 0x80)  // variavel sem LET
       move.b    11(A6),D0
       and.w     #255,D0
       cmp.w     #128,D0
       bhs.s     executeToken_98
; {
; *pointerRunProg = *pointerRunProg - 1;
       move.l    _pointerRunProg.L,A0
       subq.l    #1,(A0)
; vReta = basLet();
       jsr       _basLet
       move.b    D0,D2
       bra.s     executeToken_99
executeToken_98:
; }
; else // Nao forem operadores logicos
; {
; *vErroProc = 14;
       move.l    _vErroProc.L,A0
       move.w    #14,(A0)
; vReta = 14;
       moveq     #14,D2
executeToken_99:
; }
; }
; #endif
; return vReta;
       ext.w     D2
       ext.l     D2
       move.l    D2,D0
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Procura o proximo token ou componente da linha sendo processada
; //--------------------------------------------------------------------------------------
; int nextToken(void)
; {
       xdef      _nextToken
_nextToken:
       link      A6,#-28
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _token_type.L,A2
       lea       _pointerRunProg.L,A3
       lea       _token.L,A4
       lea       _tok.L,A5
; unsigned char *temp;
; int vRet, ccc;
; unsigned char sqtdtam[20];
; unsigned char *vTempPointer;
; *token_type = 0;
       move.l    (A2),A0
       clr.b     (A0)
; *tok = 0;
       move.l    (A5),A0
       clr.b     (A0)
; temp = token;
       move.l    (A4),D3
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
; if (*vTempPointer >= 0x80 && *vTempPointer < 0xF0)   // is a command
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo       nextToken_1
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       bhs.s     nextToken_1
; {
; *tok = *vTempPointer;
       move.l    D2,A0
       move.l    (A5),A1
       move.b    (A0),(A1)
; *token_type = COMMAND;
       move.l    (A2),A0
       move.b    #4,(A0)
; *token = *vTempPointer;
       move.l    D2,A0
       move.l    (A4),A1
       move.b    (A0),(A1)
; *(token + 1) = 0x00;
       move.l    (A4),A0
       clr.b     1(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_1:
; }
; if (*vTempPointer == '\0') { // end of file
       move.l    D2,A0
       move.b    (A0),D0
       bne.s     nextToken_4
; *token = 0;
       move.l    (A4),A0
       clr.b     (A0)
; *tok = FINISHED;
       move.l    (A5),A0
       move.b    #224,(A0)
; *token_type = DELIMITER;
       move.l    (A2),A0
       move.b    #1,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_4:
; }
; while(*vTempPointer == ' ' || *vTempPointer == '\t') // skip over white space
nextToken_6:
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     nextToken_9
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       bne.s     nextToken_8
nextToken_9:
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
       bra       nextToken_6
nextToken_8:
; }
; if (*vTempPointer == '\r') { // crlf
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #13,D0
       bne       nextToken_10
; *pointerRunProg = *pointerRunProg + 2;
       move.l    (A3),A0
       addq.l    #2,(A0)
; *tok = EOL;
       move.l    (A5),A0
       move.b    #226,(A0)
; *token = '\r';
       move.l    (A4),A0
       move.b    #13,(A0)
; *(token + 1) = '\n';
       move.l    (A4),A0
       move.b    #10,1(A0)
; *(token + 2) = 0;
       move.l    (A4),A0
       clr.b     2(A0)
; *token_type = DELIMITER;
       move.l    (A2),A0
       move.b    #1,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_10:
; }
; if ((*vTempPointer == '+' || *vTempPointer == '-' || *vTempPointer == '*' ||
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #43,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #45,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #42,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #94,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #47,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq       nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #62,D0
       beq.s     nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #60,D0
       beq.s     nextToken_14
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       blo.s     nextToken_12
nextToken_14:
; *vTempPointer == '^' || *vTempPointer == '/' || *vTempPointer == '=' ||
; *vTempPointer == ';' || *vTempPointer == ':' || *vTempPointer == ',' ||
; *vTempPointer == '>' || *vTempPointer == '<' || *vTempPointer >= 0xF0)) { // delimiter
; *temp = *vTempPointer;
       move.l    D2,A0
       move.l    D3,A1
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1; // advance to next position
       move.l    (A3),A0
       addq.l    #1,(A0)
; temp++;
       addq.l    #1,D3
; *temp = 0;
       move.l    D3,A0
       clr.b     (A0)
; *token_type = DELIMITER;
       move.l    (A2),A0
       move.b    #1,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_12:
; }
; if (*vTempPointer == 0x28 || *vTempPointer == 0x29)
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #40,D0
       beq.s     nextToken_17
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #41,D0
       bne       nextToken_15
nextToken_17:
; {
; if (*vTempPointer == 0x28)
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne.s     nextToken_18
; *token_type = OPENPARENT;
       move.l    (A2),A0
       move.b    #8,(A0)
       bra.s     nextToken_19
nextToken_18:
; else
; *token_type = CLOSEPARENT;
       move.l    (A2),A0
       move.b    #9,(A0)
nextToken_19:
; *token = *vTempPointer;
       move.l    D2,A0
       move.l    (A4),A1
       move.b    (A0),(A1)
; *(token + 1) = 0x00;
       move.l    (A4),A0
       clr.b     1(A0)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_15:
; }
; if (*vTempPointer == ":")
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       lea       @basic_130.L,A0
       cmp.l     A0,D0
       bne.s     nextToken_20
; {
; *doisPontos = 1;
       move.l    _doisPontos.L,A0
       move.b    #1,(A0)
; *token_type = DOISPONTOS;
       move.l    (A2),A0
       move.b    #7,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_20:
; }
; if (*vTempPointer == '"') { // quoted string
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #34,D0
       bne       nextToken_22
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
; while(*vTempPointer != '"'&& *vTempPointer != '\r')
nextToken_24:
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #34,D0
       beq.s     nextToken_26
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #13,D0
       beq.s     nextToken_26
; {
; *temp++ = *vTempPointer;
       move.l    D2,A0
       move.l    D3,A1
       addq.l    #1,D3
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
       bra       nextToken_24
nextToken_26:
; }
; if (*vTempPointer == '\r')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #13,D0
       bne.s     nextToken_27
; {
; *vErroProc = 14;
       move.l    _vErroProc.L,A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       nextToken_3
nextToken_27:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; *temp = 0;
       move.l    D3,A0
       clr.b     (A0)
; *token_type = QUOTE;
       move.l    (A2),A0
       move.b    #6,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_22:
; }
; if (isdigitus(*vTempPointer)) { // number
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       beq       nextToken_29
; while(!isdelim(*vTempPointer) && (*vTempPointer < 0x80 || *vTempPointer >= 0xF0))
nextToken_31:
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdelim
       addq.w    #4,A7
       tst.l     D0
       bne       nextToken_33
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     nextToken_34
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       blo.s     nextToken_33
nextToken_34:
; {
; *temp++ = *vTempPointer;
       move.l    D2,A0
       move.l    D3,A1
       addq.l    #1,D3
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
       bra       nextToken_31
nextToken_33:
; }
; *temp = '\0';
       move.l    D3,A0
       clr.b     (A0)
; *token_type = NUMBER;
       move.l    (A2),A0
       move.b    #3,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_29:
; }
; if (isalphas(*vTempPointer)) { // var or command
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq       nextToken_35
; while(!isdelim(*vTempPointer) && (*vTempPointer < 0x80 || *vTempPointer >= 0xF0))
nextToken_37:
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdelim
       addq.w    #4,A7
       tst.l     D0
       bne       nextToken_39
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     nextToken_40
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       blo.s     nextToken_39
nextToken_40:
; {
; *temp++ = *vTempPointer;
       move.l    D2,A0
       move.l    D3,A1
       addq.l    #1,D3
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
       bra       nextToken_37
nextToken_39:
; }
; *temp = '\0';
       move.l    D3,A0
       clr.b     (A0)
; *token_type = VARIABLE;
       move.l    (A2),A0
       move.b    #2,(A0)
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra.s     nextToken_3
nextToken_35:
; }
; *temp = '\0';
       move.l    D3,A0
       clr.b     (A0)
; // see if a string is a command or a variable
; if (*token_type == STRING) {
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #5,D0
       bne.s     nextToken_41
; *token_type = VARIABLE;
       move.l    (A2),A0
       move.b    #2,(A0)
nextToken_41:
; }
; return *token_type;
       move.l    (A2),A0
       move.b    (A0),D0
       and.l     #255,D0
nextToken_3:
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Procura o token na lista de keywords e devolve a posicao, se nao encontrar,
; // devolve 14 (token desconhecido)
; //-----------------------------------------------------------------------------
; int findToken(unsigned char pToken)
; {
       xdef      _findToken
_findToken:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned char kt;
; // Procura o Token na lista e devolve a posicao
; for(kt = 0; kt < keywords_count; kt++)
       clr.b     D2
findToken_1:
       and.l     #255,D2
       cmp.l     _keywords_count.L,D2
       bhs.s     findToken_3
; {
; if (keywords[kt].token == pToken)
       and.l     #255,D2
       move.l    D2,D0
       lsl.l     #3,D0
       lea       @basic_keywords.L,A0
       add.l     D0,A0
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     4(A0),D0
       bne.s     findToken_4
; return kt;
       and.l     #255,D2
       move.l    D2,D0
       bra.s     findToken_6
findToken_4:
       addq.b    #1,D2
       bra       findToken_1
findToken_3:
; }
; // Procura o Token nas operacões de 1 char
; /*for(kt = 0; kt < keywordsUnique_count; kt++)
; {
; if (keywordsUnique[kt].token == pToken)
; return (kt + 0x80);
; }*/
; return 14;
       moveq     #14,D0
findToken_6:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Procura o numero da linha na lista de linhas do programa e devolve o endereco,
; // se nao encontrar, devolve 0
; //-----------------------------------------------------------------------------
; unsigned long findNumberLine(unsigned short pNumber, unsigned char pTipoRet, unsigned char pTipoFind)
; {
       xdef      _findNumberLine
_findNumberLine:
       link      A6,#-36
       movem.l   D2/D3/D4/D5,-(A7)
       move.w    10(A6),D4
       and.l     #65535,D4
; unsigned char *vStartList = *addrFirstLineNumber;
       move.l    _addrFirstLineNumber.L,A0
       move.l    (A0),D2
; unsigned char *vLastList = *addrFirstLineNumber;
       move.l    _addrFirstLineNumber.L,A0
       move.l    (A0),D5
; unsigned short vNumber = 0;
       clr.w     D3
; char vBuffer [sizeof(long)*8+1];
; if (pNumber)
       tst.w     D4
       beq       findNumberLine_5
; {
; while(vStartList)
findNumberLine_3:
       tst.l     D2
       beq       findNumberLine_5
; {
; vNumber = ((*(vStartList + 3) << 8) | *(vStartList + 4));
       move.l    D2,A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,D3
; if ((!pTipoFind && vNumber < pNumber) || (pTipoFind && vNumber != pNumber))
       tst.b     19(A6)
       bne.s     findNumberLine_10
       moveq     #1,D0
       bra.s     findNumberLine_11
findNumberLine_10:
       clr.l     D0
findNumberLine_11:
       and.l     #255,D0
       beq.s     findNumberLine_9
       cmp.w     D4,D3
       blo.s     findNumberLine_8
findNumberLine_9:
       move.b    19(A6),D0
       and.l     #255,D0
       beq       findNumberLine_6
       cmp.w     D4,D3
       beq       findNumberLine_6
findNumberLine_8:
; {
; vLastList = vStartList;
       move.l    D2,D5
; vStartList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D2,A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,D2
       bra.s     findNumberLine_7
findNumberLine_6:
; }
; else
; break;
       bra.s     findNumberLine_5
findNumberLine_7:
       bra       findNumberLine_3
findNumberLine_5:
; }
; }
; if (!pTipoRet)
       tst.b     15(A6)
       bne.s     findNumberLine_12
; return vStartList;
       move.l    D2,D0
       bra.s     findNumberLine_14
findNumberLine_12:
; else
; return vLastList;
       move.l    D5,D0
findNumberLine_14:
       movem.l   (A7)+,D2/D3/D4/D5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Return true if c is a alphabetical (A-Z or a-z).
; //--------------------------------------------------------------------------------------
; int isalphas(unsigned char c)
; {
       xdef      _isalphas
_isalphas:
       link      A6,#0
       move.l    D2,-(A7)
       move.b    11(A6),D2
       and.l     #255,D2
; if ((c>0x40 && c<0x5B) || (c>0x60 && c<0x7B))
       cmp.b     #64,D2
       bls.s     isalphas_4
       cmp.b     #91,D2
       blo.s     isalphas_3
isalphas_4:
       cmp.b     #96,D2
       bls.s     isalphas_1
       cmp.b     #123,D2
       bhs.s     isalphas_1
isalphas_3:
; return 1;
       moveq     #1,D0
       bra.s     isalphas_5
isalphas_1:
; return 0;
       clr.l     D0
isalphas_5:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Return true if c is a number (0-9).
; //--------------------------------------------------------------------------------------
; int isdigitus(unsigned char c)
; {
       xdef      _isdigitus
_isdigitus:
       link      A6,#0
; if (c>0x2F && c<0x3A)
       move.b    11(A6),D0
       cmp.b     #47,D0
       bls.s     isdigitus_1
       move.b    11(A6),D0
       cmp.b     #58,D0
       bhs.s     isdigitus_1
; return 1;
       moveq     #1,D0
       bra.s     isdigitus_3
isdigitus_1:
; return 0;
       clr.l     D0
isdigitus_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Return true if c is a delimiter.
; //--------------------------------------------------------------------------------------
; int isdelim(unsigned char c)
; {
       xdef      _isdelim
_isdelim:
       link      A6,#0
       move.l    D2,-(A7)
       move.b    11(A6),D2
       and.l     #255,D2
; if (c >= 0xF0 || c == 0 || c == '\r' || c == '\t' || c == ' ' ||
       and.w     #255,D2
       cmp.w     #240,D2
       bhs       isdelim_3
       tst.b     D2
       beq       isdelim_3
       cmp.b     #13,D2
       beq       isdelim_3
       cmp.b     #9,D2
       beq       isdelim_3
       cmp.b     #32,D2
       beq       isdelim_3
       cmp.b     #59,D2
       beq       isdelim_3
       cmp.b     #44,D2
       beq       isdelim_3
       cmp.b     #43,D2
       beq       isdelim_3
       cmp.b     #45,D2
       beq       isdelim_3
       cmp.b     #60,D2
       beq       isdelim_3
       cmp.b     #62,D2
       beq.s     isdelim_3
       cmp.b     #40,D2
       beq.s     isdelim_3
       cmp.b     #41,D2
       beq.s     isdelim_3
       cmp.b     #47,D2
       beq.s     isdelim_3
       cmp.b     #42,D2
       beq.s     isdelim_3
       cmp.b     #94,D2
       beq.s     isdelim_3
       cmp.b     #61,D2
       beq.s     isdelim_3
       cmp.b     #58,D2
       bne.s     isdelim_1
isdelim_3:
; c == ';' || c == ',' || c == '+' || c == '-' || c == '<' ||
; c == '>' || c == '(' || c == ')' || c == '/' || c == '*' ||
; c == '^' || c == '=' || c == ':')
; return 1;
       moveq     #1,D0
       bra.s     isdelim_4
isdelim_1:
; return 0;
       clr.l     D0
isdelim_4:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Return 1 if c is space or tab.
; //--------------------------------------------------------------------------------------
; int iswhite(unsigned char c)
; {
       xdef      _iswhite
_iswhite:
       link      A6,#0
; if (c==' ' || c=='\t')
       move.b    11(A6),D0
       cmp.b     #32,D0
       beq.s     iswhite_3
       move.b    11(A6),D0
       cmp.b     #9,D0
       bne.s     iswhite_1
iswhite_3:
; return 1;
       moveq     #1,D0
       bra.s     iswhite_4
iswhite_1:
; return 0;
       clr.l     D0
iswhite_4:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Return a token to input stream.
; //--------------------------------------------------------------------------------------
; void putback(void)
; {
       xdef      _putback
_putback:
       link      A6,#-4
; unsigned char *t;
; if (*token_type==COMMAND)    // comando nao faz isso
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #4,D0
       bne.s     putback_1
; return;
       bra.s     putback_6
putback_1:
; t = token;
       move.l    _token.L,-4(A6)
; while (*t++)
putback_4:
       move.l    -4(A6),A0
       addq.l    #1,-4(A6)
       tst.b     (A0)
       beq.s     putback_6
; *pointerRunProg = *pointerRunProg - 1;
       move.l    _pointerRunProg.L,A0
       subq.l    #1,(A0)
       bra       putback_4
putback_6:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Return compara 2 strings
; //--------------------------------------------------------------------------------------
; int ustrcmp(char *X, char *Y)
; {
       xdef      _ustrcmp
_ustrcmp:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.l    8(A6),D2
       move.l    12(A6),D3
; while (*X)
ustrcmp_1:
       move.l    D2,A0
       tst.b     (A0)
       beq.s     ustrcmp_3
; {
; // if characters differ, or end of the second string is reached
; if (*X != *Y) {
       move.l    D2,A0
       move.l    D3,A1
       move.b    (A0),D0
       cmp.b     (A1),D0
       beq.s     ustrcmp_4
; break;
       bra.s     ustrcmp_3
ustrcmp_4:
; }
; // move to the next pair of characters
; X++;
       addq.l    #1,D2
; Y++;
       addq.l    #1,D3
       bra       ustrcmp_1
ustrcmp_3:
; }
; // return the ASCII difference after converting `char*` to `unsigned char*`
; return *(unsigned char*)X - *(unsigned char*)Y;
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       sub.l     D1,D0
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Entry point into parser.
; //--------------------------------------------------------------------------------------
; void getExp(unsigned char *result)
; {
       xdef      _getExp
_getExp:
       link      A6,#-12
; unsigned char sqtdtam[10];
; #ifdef USE_ITERATIVE_PARSER
; parseExpressionIterative(result);
       move.l    8(A6),-(A7)
       jsr       _parseExpressionIterative
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     getExp_1
       bra.s     getExp_3
getExp_1:
; putback(); // return last token read to input stream
       jsr       _putback
; return;
getExp_3:
       unlk      A6
       rts
; #else
; nextToken();
; if (*vErroProc) return;
; if (!*token) {
; *vErroProc = 2;
; return;
; }
; level2(result);
; if (*vErroProc) return;
; putback(); // return last token read to input stream
; return;
; #endif
; }
; // -----------------------------------------------------------------------------
; // Precedência dos operadores
; // -----------------------------------------------------------------------------
; int getPrec(unsigned char op)
; {
       xdef      _getPrec
_getPrec:
       link      A6,#0
; switch (op)
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #62,D0
       beq       getPrec_6
       bhi       getPrec_18
       cmp.l     #45,D0
       beq       getPrec_12
       bhi.s     getPrec_19
       cmp.l     #42,D0
       beq       getPrec_14
       bhi.s     getPrec_20
       cmp.l     #40,D0
       beq       getPrec_3
       bra       getPrec_1
getPrec_20:
       cmp.l     #43,D0
       beq       getPrec_12
       bra       getPrec_1
getPrec_19:
       cmp.l     #60,D0
       beq       getPrec_6
       bhi.s     getPrec_21
       cmp.l     #47,D0
       beq       getPrec_14
       bra       getPrec_1
getPrec_21:
       cmp.l     #61,D0
       beq       getPrec_6
       bra       getPrec_1
getPrec_18:
       cmp.l     #245,D0
       beq       getPrec_6
       bhi.s     getPrec_22
       cmp.l     #243,D0
       beq       getPrec_5
       bhi.s     getPrec_23
       cmp.l     #94,D0
       beq       getPrec_16
       bra       getPrec_1
getPrec_23:
       cmp.l     #244,D0
       beq.s     getPrec_4
       bra       getPrec_1
getPrec_22:
       cmp.l     #247,D0
       beq.s     getPrec_6
       bhi       getPrec_1
       cmp.l     #246,D0
       beq.s     getPrec_6
       bra.s     getPrec_1
getPrec_3:
; {
; case '(':
; return 0;
       clr.l     D0
       bra.s     getPrec_24
getPrec_4:
; case 0xF4:
; return 1; // OR
       moveq     #1,D0
       bra.s     getPrec_24
getPrec_5:
; case 0xF3:
; return 2; // AND
       moveq     #2,D0
       bra.s     getPrec_24
getPrec_6:
; case '=':
; case '<':
; case '>':
; case 0xF5:
; case 0xF6:
; case 0xF7:
; return 3; // comparadores
       moveq     #3,D0
       bra.s     getPrec_24
getPrec_12:
; case '+':
; case '-':
; return 4;
       moveq     #4,D0
       bra.s     getPrec_24
getPrec_14:
; case '*':
; case '/':
; return 5;
       moveq     #5,D0
       bra.s     getPrec_24
getPrec_16:
; case '^':
; return 6;
       moveq     #6,D0
       bra.s     getPrec_24
getPrec_1:
; default:
; return 0;
       clr.l     D0
getPrec_24:
       unlk      A6
       rts
; }
; }
; // -----------------------------------------------------------------------------
; // Associatividade: ^ é direita, resto esquerda
; // -----------------------------------------------------------------------------
; int isRightAssoc(char op) {
       xdef      _isRightAssoc
_isRightAssoc:
       link      A6,#0
; return (op == '^');
       move.b    11(A6),D0
       cmp.b     #94,D0
       bne.s     isRightAssoc_1
       moveq     #1,D0
       bra.s     isRightAssoc_2
isRightAssoc_1:
       clr.l     D0
isRightAssoc_2:
       unlk      A6
       rts
; }
; // -----------------------------------------------------------------------------
; // Parser iterativo (experimental, ativado por USE_ITERATIVE_PARSER)
; // -----------------------------------------------------------------------------
; void parseExpressionIterative(unsigned char *result) {
       xdef      _parseExpressionIterative
_parseExpressionIterative:
       link      A6,#-1808
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       -1770(A6),A3
       lea       -54(A6),A4
       lea       _token.L,A5
; unsigned char op, currentOp;
; char typeA, typeB;
; unsigned char tokenType, tokenChar, valueType;
; unsigned char *a, *b;
; unsigned char *vRet;
; unsigned long numberValue;
; unsigned char *numberBytes;
; unsigned char tokenLen;
; unsigned char *commandPointer;
; int expectValue = 1; // Para detectar unário
       move.l    #1,-1784(A6)
; char pendingUnary = 0; // 0: nenhum, '+': unário +, '-': unário -
       clr.b     -1779(A6)
; int currentPrec, topPrec;
; unsigned char sqtdtam[20];
; unsigned char valStack[32][50];
; unsigned char opStack[PARSER_STACK_SIZE];
; unsigned char opPrecStack[PARSER_STACK_SIZE];
; char valTypeStack[PARSER_STACK_SIZE];
; unsigned char temp[50];
; unsigned char tokenVarAtu[3];
; unsigned char tokenVarAtuLen;
; int opTop = -1, valTop = -1;
       moveq     #-1,D7
       moveq     #-1,D3
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_1
       bra       parseExpressionIterative_3
parseExpressionIterative_1:
; if (!*token) {
       move.l    (A5),A0
       tst.b     (A0)
       bne.s     parseExpressionIterative_4
; *vErroProc = 2;
       move.l    (A2),A0
       move.w    #2,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_4:
; }
; while (1) {
parseExpressionIterative_6:
; tokenType = *token_type;
       move.l    _token_type.L,A0
       move.b    (A0),-1805(A6)
; tokenChar = *token;
       move.l    (A5),A0
       move.b    (A0),-1804(A6)
; if (expectValue) {
       tst.l     -1784(A6)
       beq       parseExpressionIterative_74
; if (tokenType == DELIMITER && (tokenChar == '+' || tokenChar == '-')) {
       move.b    -1805(A6),D0
       cmp.b     #1,D0
       bne.s     parseExpressionIterative_11
       move.b    -1804(A6),D0
       cmp.b     #43,D0
       beq.s     parseExpressionIterative_13
       move.b    -1804(A6),D0
       cmp.b     #45,D0
       bne.s     parseExpressionIterative_11
parseExpressionIterative_13:
; pendingUnary = tokenChar;
       move.b    -1804(A6),-1779(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_14
       bra       parseExpressionIterative_3
parseExpressionIterative_14:
; continue;
       bra       parseExpressionIterative_7
parseExpressionIterative_11:
; }
; if (tokenType == NUMBER || tokenType == VARIABLE || tokenType == QUOTE || tokenType == COMMAND) {
       move.b    -1805(A6),D0
       cmp.b     #3,D0
       beq.s     parseExpressionIterative_18
       move.b    -1805(A6),D0
       cmp.b     #2,D0
       beq.s     parseExpressionIterative_18
       move.b    -1805(A6),D0
       cmp.b     #6,D0
       beq.s     parseExpressionIterative_18
       move.b    -1805(A6),D0
       cmp.b     #4,D0
       bne       parseExpressionIterative_16
parseExpressionIterative_18:
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       parseExpressionIterative_19
; {
; writeLongSerial("Aqui 888.666.5 - [\0");
       pea       @basic_131.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(tokenType,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.b    -1805(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(tokenChar,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.b    -1804(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n\0");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_19:
; }
; if (tokenType == VARIABLE) {
       move.b    -1805(A6),D0
       cmp.b     #2,D0
       bne       parseExpressionIterative_21
; tokenLen = 0;
       clr.b     -1789(A6)
; while (token[tokenLen])
parseExpressionIterative_23:
       move.l    (A5),A0
       move.b    -1789(A6),D0
       and.l     #255,D0
       tst.b     0(A0,D0.L)
       beq.s     parseExpressionIterative_25
; tokenLen++;
       addq.b    #1,-1789(A6)
       bra       parseExpressionIterative_23
parseExpressionIterative_25:
; if (tokenLen < 3)
       move.b    -1789(A6),D0
       cmp.b     #3,D0
       bhs.s     parseExpressionIterative_26
; {
; valueType = VARTYPEDEFAULT;
       move.b    #35,-1803(A6)
; if (tokenLen == 2 && token[1] < 0x30)
       move.b    -1789(A6),D0
       cmp.b     #2,D0
       bne.s     parseExpressionIterative_28
       move.l    (A5),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     parseExpressionIterative_28
; valueType = token[1];
       move.l    (A5),A0
       move.b    1(A0),-1803(A6)
parseExpressionIterative_28:
       bra.s     parseExpressionIterative_27
parseExpressionIterative_26:
; }
; else
; {
; valueType = token[2];
       move.l    (A5),A0
       move.b    2(A0),-1803(A6)
parseExpressionIterative_27:
; }
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       parseExpressionIterative_30
; {
; writeLongSerial("Aqui 888.666.0 - [\0");
       pea       @basic_134.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(char*)token,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.l    (A5),D1
       move.l    D1,A0
       move.b    (A0),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(char*)(token + 1),sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.l    (A5),D1
       addq.l    #1,D1
       move.l    D1,A0
       move.b    (A0),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n\0");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_30:
; }
; tokenVarAtuLen = tokenLen;
       move.b    -1789(A6),-1(A6)
; tokenVarAtu[0] = token[0];
       move.l    (A5),A0
       move.b    (A0),-4+0(A6)
; tokenVarAtu[1] = token[1];
       move.l    (A5),A0
       move.b    1(A0),-4+1(A6)
; tokenVarAtu[2] = token[2];
       move.l    (A5),A0
       move.b    2(A0),-4+2(A6)
; vRet = find_var((char*)tokenVarAtu);
       pea       -4(A6)
       jsr       _find_var
       addq.w    #4,A7
       move.l    D0,-1802(A6)
; if (vRet == 0)
       move.l    -1802(A6),D0
       bne.s     parseExpressionIterative_32
; {
; if (*vErroProc == 0)
       move.l    (A2),A0
       move.w    (A0),D0
       bne.s     parseExpressionIterative_34
; *vErroProc = 4;
       move.l    (A2),A0
       move.w    #4,(A0)
parseExpressionIterative_34:
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_32:
; }
; if (tokenLen < 3)
       move.b    -1789(A6),D0
       cmp.b     #3,D0
       bhs.s     parseExpressionIterative_36
; valueType = valueType;   // *value_type;
       bra.s     parseExpressionIterative_37
parseExpressionIterative_36:
; else
; valueType = tokenVarAtu[2];
       move.b    -4+2(A6),-1803(A6)
parseExpressionIterative_37:
; if (valueType == '$')
       move.b    -1803(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_38
; strcpy((char*)temp, (char*)vRet);
       move.l    -1802(A6),-(A7)
       move.l    A4,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     parseExpressionIterative_39
parseExpressionIterative_38:
; else
; {
; temp[0] = vRet[0];
       move.l    -1802(A6),A0
       move.b    (A0),(A4)
; temp[1] = vRet[1];
       move.l    -1802(A6),A0
       move.b    1(A0),1(A4)
; temp[2] = vRet[2];
       move.l    -1802(A6),A0
       move.b    2(A0),2(A4)
; temp[3] = vRet[3];
       move.l    -1802(A6),A0
       move.b    3(A0),3(A4)
; temp[4] = 0x00;
       clr.b     4(A4)
parseExpressionIterative_39:
; }
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       parseExpressionIterative_40
; {
; writeLongSerial("Aqui 888.666.1 - [\0");
       pea       @basic_135.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)vRet,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.l    -1802(A6),D1
       move.l    D1,A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)temp,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.l    (A4),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(tokenLen,sqtdtam,10);
       pea       10
       move.l    A3,-(A7)
       move.b    -1789(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(valueType);
       move.b    -1803(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n\0");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_40:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_42
       bra       parseExpressionIterative_3
parseExpressionIterative_42:
       bra       parseExpressionIterative_60
parseExpressionIterative_21:
; }
; else if (tokenType == QUOTE) {
       move.b    -1805(A6),D0
       cmp.b     #6,D0
       bne.s     parseExpressionIterative_44
; valueType = '$';
       move.b    #36,-1803(A6)
; strcpy((char*)temp, (char*)token);
       move.l    (A5),-(A7)
       move.l    A4,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_46
       bra       parseExpressionIterative_3
parseExpressionIterative_46:
       bra       parseExpressionIterative_60
parseExpressionIterative_44:
; }
; else if (tokenType == NUMBER) {
       move.b    -1805(A6),D0
       cmp.b     #3,D0
       bne       parseExpressionIterative_48
; if (strchr((char*)token, '.'))
       pea       46
       move.l    (A5),-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq.s     parseExpressionIterative_50
; {
; valueType = '#';
       move.b    #35,-1803(A6)
; numberValue = floatStringToFpp(token);
       move.l    (A5),-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,-1798(A6)
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_52
       bra       parseExpressionIterative_3
parseExpressionIterative_52:
       bra.s     parseExpressionIterative_51
parseExpressionIterative_50:
; }
; else
; {
; valueType = '%';
       move.b    #37,-1803(A6)
; numberValue = atoi((char*)token);
       move.l    (A5),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-1798(A6)
parseExpressionIterative_51:
; }
; numberBytes = (unsigned char*)&numberValue;
       lea       -1798(A6),A0
       move.l    A0,-1794(A6)
; temp[0] = numberBytes[0];
       move.l    -1794(A6),A0
       move.b    (A0),(A4)
; temp[1] = numberBytes[1];
       move.l    -1794(A6),A0
       move.b    1(A0),1(A4)
; temp[2] = numberBytes[2];
       move.l    -1794(A6),A0
       move.b    2(A0),2(A4)
; temp[3] = numberBytes[3];
       move.l    -1794(A6),A0
       move.b    3(A0),3(A4)
; temp[4] = 0x00;
       clr.b     4(A4)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_54
       bra       parseExpressionIterative_3
parseExpressionIterative_54:
       bra       parseExpressionIterative_60
parseExpressionIterative_48:
; }
; else {
; commandPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-1788(A6)
; *token = *commandPointer;
       move.l    -1788(A6),A0
       move.l    (A5),A1
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
; executeToken(*commandPointer);
       move.l    -1788(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _executeToken
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_56
       bra       parseExpressionIterative_3
parseExpressionIterative_56:
; valueType = *value_type;
       move.l    _value_type.L,A0
       move.b    (A0),-1803(A6)
; if (valueType == '$')
       move.b    -1803(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_58
; strcpy((char*)temp, (char*)token);
       move.l    (A5),-(A7)
       move.l    A4,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     parseExpressionIterative_59
parseExpressionIterative_58:
; else
; {
; temp[0] = token[0];
       move.l    (A5),A0
       move.b    (A0),(A4)
; temp[1] = token[1];
       move.l    (A5),A0
       move.b    1(A0),1(A4)
; temp[2] = token[2];
       move.l    (A5),A0
       move.b    2(A0),2(A4)
; temp[3] = token[3];
       move.l    (A5),A0
       move.b    3(A0),3(A4)
; temp[4] = 0x00;
       clr.b     4(A4)
parseExpressionIterative_59:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_60
       bra       parseExpressionIterative_3
parseExpressionIterative_60:
; }
; if (pendingUnary) {
       tst.b     -1779(A6)
       beq       parseExpressionIterative_62
; if (valueType == '$') {
       move.b    -1803(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_64
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_64:
; }
; if (valueType == '#')
       move.b    -1803(A6),D0
       cmp.b     #35,D0
       bne.s     parseExpressionIterative_66
; unaryReal(pendingUnary, (int*)temp);
       move.l    A4,-(A7)
       move.b    -1779(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _unaryReal
       addq.w    #8,A7
       bra.s     parseExpressionIterative_67
parseExpressionIterative_66:
; else
; unaryInt(pendingUnary, (int*)temp);
       move.l    A4,-(A7)
       move.b    -1779(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _unaryInt
       addq.w    #8,A7
parseExpressionIterative_67:
; pendingUnary = 0;
       clr.b     -1779(A6)
parseExpressionIterative_62:
; }
; if (valTop + 1 >= PARSER_STACK_SIZE) {
       move.l    D3,D0
       addq.l    #1,D0
       cmp.l     #32,D0
       blt.s     parseExpressionIterative_68
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_68:
; }
; valTop++;
       addq.l    #1,D3
; if (valueType == '$')
       move.b    -1803(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_70
; strcpy((char*)valStack[valTop], (char*)temp);
       move.l    A4,-(A7)
       lea       -1750(A6),A0
       move.l    D3,D1
       muls      #50,D1
       add.l     D1,A0
       move.l    A0,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     parseExpressionIterative_71
parseExpressionIterative_70:
; else
; {
; *(unsigned int*)valStack[valTop] = *(unsigned int*)temp;
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    (A4),(A0)
; valStack[valTop][4] = 0x00;
       move.l    D3,D0
       muls      #50,D0
       lea       -1750(A6),A0
       add.l     D0,A0
       clr.b     4(A0)
parseExpressionIterative_71:
; }
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       parseExpressionIterative_72
; {
; writeLongSerial("Aqui 888.666.3 - [\0");
       pea       @basic_136.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)temp,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.l    (A4),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(valTop,sqtdtam,10);
       pea       10
       move.l    A3,-(A7)
       move.l    D3,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)valStack[valTop],sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       lea       -1750(A6),A0
       move.l    D3,D1
       muls      #50,D1
       add.l     D1,A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n\0");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_72:
; }
; valTypeStack[valTop] = valueType;
       move.b    -1803(A6),-86(A6,D3.L)
; expectValue = 0;
       clr.l     -1784(A6)
; continue;
       bra       parseExpressionIterative_7
parseExpressionIterative_16:
; }
; if (tokenChar == '(') {
       move.b    -1804(A6),D0
       cmp.b     #40,D0
       bne       parseExpressionIterative_74
; if (pendingUnary) {
       tst.b     -1779(A6)
       beq       parseExpressionIterative_76
; if (pendingUnary == '-') {
       move.b    -1779(A6),D0
       cmp.b     #45,D0
       bne       parseExpressionIterative_78
; if (valTop + 1 >= PARSER_STACK_SIZE) {
       move.l    D3,D0
       addq.l    #1,D0
       cmp.l     #32,D0
       blt.s     parseExpressionIterative_80
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_80:
; }
; valTop++;
       addq.l    #1,D3
; *(unsigned int*)valStack[valTop] = 0;
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       clr.l     (A0)
; valTypeStack[valTop] = '%';
       move.b    #37,-86(A6,D3.L)
; if (opTop + 1 >= PARSER_STACK_SIZE) {
       move.l    D7,D0
       addq.l    #1,D0
       cmp.l     #32,D0
       blt.s     parseExpressionIterative_82
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_82:
; }
; opTop++;
       addq.l    #1,D7
; opStack[opTop] = '-';
       lea       -150(A6),A0
       move.b    #45,0(A0,D7.L)
; opPrecStack[opTop] = 2;
       move.b    #2,-118(A6,D7.L)
parseExpressionIterative_78:
; }
; pendingUnary = 0;
       clr.b     -1779(A6)
parseExpressionIterative_76:
; }
; if (opTop + 1 >= PARSER_STACK_SIZE) {
       move.l    D7,D0
       addq.l    #1,D0
       cmp.l     #32,D0
       blt.s     parseExpressionIterative_84
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_84:
; }
; opTop++;
       addq.l    #1,D7
; opStack[opTop] = '(';
       lea       -150(A6),A0
       move.b    #40,0(A0,D7.L)
; opPrecStack[opTop] = 0;
       clr.b     -118(A6,D7.L)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_86
       bra       parseExpressionIterative_3
parseExpressionIterative_86:
; continue;
       bra       parseExpressionIterative_7
parseExpressionIterative_74:
; }
; }
; if (tokenChar == ')') {
       move.b    -1804(A6),D0
       cmp.b     #41,D0
       bne       parseExpressionIterative_88
; char foundOpenParen = 0;
       clr.b     -1808(A6)
; while (opTop >= 0) {
parseExpressionIterative_90:
       cmp.l     #0,D7
       blt       parseExpressionIterative_92
; if (opStack[opTop] == '(') {
       lea       -150(A6),A0
       move.b    0(A0,D7.L),D0
       cmp.b     #40,D0
       bne.s     parseExpressionIterative_93
; foundOpenParen = 1;
       move.b    #1,-1808(A6)
; break;
       bra       parseExpressionIterative_92
parseExpressionIterative_93:
; }
; op = opStack[opTop--];
       move.l    D7,D0
       subq.l    #1,D7
       lea       -150(A6),A0
       move.b    0(A0,D0.L),D2
; if (valTop < 1) {
       cmp.l     #1,D3
       bge.s     parseExpressionIterative_95
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_95:
; }
; b = valStack[valTop];
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    A0,D6
; typeB = valTypeStack[valTop];
       move.b    -86(A6,D3.L),-1806(A6)
; valTop--;
       subq.l    #1,D3
; a = valStack[valTop];
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    A0,D4
; typeA = valTypeStack[valTop];
       move.b    -86(A6,D3.L),D5
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       parseExpressionIterative_97
; {
; writeLongSerial("Aqui 888.666.4 - [\0");
       pea       @basic_137.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)a,sqtdtam,10);
       pea       10
       move.l    A3,-(A7)
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(typeA);
       and.l     #255,D5
       move.l    D5,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)b,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(typeB);
       move.b    -1806(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(op);
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n\0");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_97:
; }
; if (typeA != typeB) {
       cmp.b     -1806(A6),D5
       beq       parseExpressionIterative_105
; if (typeA == '$' || typeB == '$') {
       cmp.b     #36,D5
       beq.s     parseExpressionIterative_103
       move.b    -1806(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_101
parseExpressionIterative_103:
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_101:
; }
; if (typeA == '#') {
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_104
; *(unsigned int*)b = fppReal(*(unsigned int*)b);
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D6,A0
       move.l    D0,(A0)
; typeB = '#';
       move.b    #35,-1806(A6)
       bra.s     parseExpressionIterative_105
parseExpressionIterative_104:
; }
; else {
; *(unsigned int*)a = fppReal(*(unsigned int*)a);
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D4,A0
       move.l    D0,(A0)
; typeA = '#';
       moveq     #35,D5
parseExpressionIterative_105:
; }
; }
; if (op == 0xF3 || op == 0xF4) {
       and.w     #255,D2
       cmp.w     #243,D2
       beq.s     parseExpressionIterative_108
       and.w     #255,D2
       cmp.w     #244,D2
       bne       parseExpressionIterative_106
parseExpressionIterative_108:
; if (typeA == '$' || typeB == '$') {
       cmp.b     #36,D5
       beq.s     parseExpressionIterative_111
       move.b    -1806(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_109
parseExpressionIterative_111:
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_109:
; }
; if (op == 0xF3)
       and.w     #255,D2
       cmp.w     #243,D2
       bne.s     parseExpressionIterative_112
; *(int*)a = (*(int*)a && *(int*)b);
       move.l    D4,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_114
       move.l    D6,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_114
       moveq     #1,D0
       bra.s     parseExpressionIterative_115
parseExpressionIterative_114:
       clr.l     D0
parseExpressionIterative_115:
       move.l    D4,A0
       move.l    D0,(A0)
       bra.s     parseExpressionIterative_113
parseExpressionIterative_112:
; else
; *(int*)a = (*(int*)a || *(int*)b);
       move.l    D4,A0
       tst.l     (A0)
       bne.s     parseExpressionIterative_118
       move.l    D6,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_116
parseExpressionIterative_118:
       moveq     #1,D0
       bra.s     parseExpressionIterative_117
parseExpressionIterative_116:
       clr.l     D0
parseExpressionIterative_117:
       move.l    D4,A0
       move.l    D0,(A0)
parseExpressionIterative_113:
; valTypeStack[valTop] = '%';
       move.b    #37,-86(A6,D3.L)
       bra       parseExpressionIterative_120
parseExpressionIterative_106:
; } else if (op == '=' || op == '<' || op == '>' || op == 0xF5 || op == 0xF6 || op == 0xF7) {
       cmp.b     #61,D2
       beq.s     parseExpressionIterative_121
       cmp.b     #60,D2
       beq.s     parseExpressionIterative_121
       cmp.b     #62,D2
       beq.s     parseExpressionIterative_121
       and.w     #255,D2
       cmp.w     #245,D2
       beq.s     parseExpressionIterative_121
       and.w     #255,D2
       cmp.w     #246,D2
       beq.s     parseExpressionIterative_121
       and.w     #255,D2
       cmp.w     #247,D2
       bne       parseExpressionIterative_119
parseExpressionIterative_121:
; if (typeA == '$')
       cmp.b     #36,D5
       bne.s     parseExpressionIterative_122
; logicalString(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalString
       add.w     #12,A7
       bra.s     parseExpressionIterative_125
parseExpressionIterative_122:
; else if (typeA == '#')
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_124
; logicalNumericFloat(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericFloat
       add.w     #12,A7
       bra.s     parseExpressionIterative_125
parseExpressionIterative_124:
; else
; logicalNumericInt(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericInt
       add.w     #12,A7
parseExpressionIterative_125:
; valTypeStack[valTop] = '%';
       move.b    #37,-86(A6,D3.L)
       bra       parseExpressionIterative_120
parseExpressionIterative_119:
; } else {
; if (typeA == '#')
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_126
; arithReal(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithReal
       add.w     #12,A7
       bra.s     parseExpressionIterative_127
parseExpressionIterative_126:
; else
; arithInt(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithInt
       add.w     #12,A7
parseExpressionIterative_127:
; valTypeStack[valTop] = typeA;
       move.b    D5,-86(A6,D3.L)
parseExpressionIterative_120:
       bra       parseExpressionIterative_90
parseExpressionIterative_92:
; }
; }
; if (foundOpenParen) {
       tst.b     -1808(A6)
       beq.s     parseExpressionIterative_128
; opTop--;
       subq.l    #1,D7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_130
       bra       parseExpressionIterative_3
parseExpressionIterative_130:
; expectValue = 0;
       clr.l     -1784(A6)
; continue;
       bra       parseExpressionIterative_7
parseExpressionIterative_128:
; }
; break;
       bra       parseExpressionIterative_8
parseExpressionIterative_88:
; }
; if (tokenChar == '+' || tokenChar == '-' || tokenChar == '*' || tokenChar == '/' || tokenChar == '^' ||
       move.b    -1804(A6),D0
       cmp.b     #43,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       cmp.b     #45,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       cmp.b     #42,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       cmp.b     #47,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       cmp.b     #94,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       cmp.b     #61,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       cmp.b     #60,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       cmp.b     #62,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       and.w     #255,D0
       cmp.w     #245,D0
       beq       parseExpressionIterative_134
       move.b    -1804(A6),D0
       and.w     #255,D0
       cmp.w     #246,D0
       beq.s     parseExpressionIterative_134
       move.b    -1804(A6),D0
       and.w     #255,D0
       cmp.w     #247,D0
       beq.s     parseExpressionIterative_134
       move.b    -1804(A6),D0
       and.w     #255,D0
       cmp.w     #243,D0
       beq.s     parseExpressionIterative_134
       move.b    -1804(A6),D0
       and.w     #255,D0
       cmp.w     #244,D0
       bne       parseExpressionIterative_132
parseExpressionIterative_134:
; tokenChar == '=' || tokenChar == '<' || tokenChar == '>' || tokenChar == 0xF5 || tokenChar == 0xF6 || tokenChar == 0xF7 ||
; tokenChar == 0xF3 || tokenChar == 0xF4) {
; currentOp = tokenChar;
       move.b    -1804(A6),-1807(A6)
; currentPrec = getPrec(currentOp);
       move.b    -1807(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _getPrec
       addq.w    #4,A7
       move.l    D0,-1778(A6)
; while (opTop >= 0) {
parseExpressionIterative_135:
       cmp.l     #0,D7
       blt       parseExpressionIterative_137
; topPrec = opPrecStack[opTop];
       move.b    -118(A6,D7.L),D0
       and.l     #255,D0
       move.l    D0,-1774(A6)
; if (topPrec < currentPrec)
       move.l    -1774(A6),D0
       cmp.l     -1778(A6),D0
       bge.s     parseExpressionIterative_138
; break;
       bra       parseExpressionIterative_137
parseExpressionIterative_138:
; if (currentOp == '^' && topPrec == currentPrec)
       move.b    -1807(A6),D0
       cmp.b     #94,D0
       bne.s     parseExpressionIterative_140
       move.l    -1774(A6),D0
       cmp.l     -1778(A6),D0
       bne.s     parseExpressionIterative_140
; break;
       bra       parseExpressionIterative_137
parseExpressionIterative_140:
; op = opStack[opTop--];
       move.l    D7,D0
       subq.l    #1,D7
       lea       -150(A6),A0
       move.b    0(A0,D0.L),D2
; if (valTop < 1) {
       cmp.l     #1,D3
       bge.s     parseExpressionIterative_142
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_142:
; }
; b = valStack[valTop];
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    A0,D6
; typeB = valTypeStack[valTop];
       move.b    -86(A6,D3.L),-1806(A6)
; valTop--;
       subq.l    #1,D3
; a = valStack[valTop];
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    A0,D4
; typeA = valTypeStack[valTop];
       move.b    -86(A6,D3.L),D5
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       parseExpressionIterative_144
; {
; writeLongSerial("Aqui 888.666.2 - [\0");
       pea       @basic_138.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)a,sqtdtam,10);
       pea       10
       move.l    A3,-(A7)
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(typeA);
       and.l     #255,D5
       move.l    D5,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(unsigned int*)b,sqtdtam,16);
       pea       16
       move.l    A3,-(A7)
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(typeB);
       move.b    -1806(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(op);
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n\0");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_144:
; }
; if (typeA != typeB) {
       cmp.b     -1806(A6),D5
       beq       parseExpressionIterative_152
; if (typeA == '$' || typeB == '$') {
       cmp.b     #36,D5
       beq.s     parseExpressionIterative_150
       move.b    -1806(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_148
parseExpressionIterative_150:
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_148:
; }
; if (typeA == '#')
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_151
; {
; *(unsigned int*)b = fppReal(*(unsigned int*)b);
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D6,A0
       move.l    D0,(A0)
; typeB = '#';
       move.b    #35,-1806(A6)
       bra.s     parseExpressionIterative_152
parseExpressionIterative_151:
; }
; else {
; *(unsigned int*)a = fppReal(*(unsigned int*)a);
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D4,A0
       move.l    D0,(A0)
; typeA = '#';
       moveq     #35,D5
parseExpressionIterative_152:
; }
; }
; if (op == 0xF3 || op == 0xF4) {
       and.w     #255,D2
       cmp.w     #243,D2
       beq.s     parseExpressionIterative_155
       and.w     #255,D2
       cmp.w     #244,D2
       bne       parseExpressionIterative_153
parseExpressionIterative_155:
; if (typeA == '$' || typeB == '$') {
       cmp.b     #36,D5
       beq.s     parseExpressionIterative_158
       move.b    -1806(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_156
parseExpressionIterative_158:
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_156:
; }
; if (op == 0xF3)
       and.w     #255,D2
       cmp.w     #243,D2
       bne.s     parseExpressionIterative_159
; *(int*)a = (*(int*)a && *(int*)b);
       move.l    D4,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_161
       move.l    D6,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_161
       moveq     #1,D0
       bra.s     parseExpressionIterative_162
parseExpressionIterative_161:
       clr.l     D0
parseExpressionIterative_162:
       move.l    D4,A0
       move.l    D0,(A0)
       bra.s     parseExpressionIterative_160
parseExpressionIterative_159:
; else
; *(int*)a = (*(int*)a || *(int*)b);
       move.l    D4,A0
       tst.l     (A0)
       bne.s     parseExpressionIterative_165
       move.l    D6,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_163
parseExpressionIterative_165:
       moveq     #1,D0
       bra.s     parseExpressionIterative_164
parseExpressionIterative_163:
       clr.l     D0
parseExpressionIterative_164:
       move.l    D4,A0
       move.l    D0,(A0)
parseExpressionIterative_160:
; valTypeStack[valTop] = '%';
       move.b    #37,-86(A6,D3.L)
       bra       parseExpressionIterative_167
parseExpressionIterative_153:
; } else if (op == '=' || op == '<' || op == '>' || op == 0xF5 || op == 0xF6 || op == 0xF7) {
       cmp.b     #61,D2
       beq.s     parseExpressionIterative_168
       cmp.b     #60,D2
       beq.s     parseExpressionIterative_168
       cmp.b     #62,D2
       beq.s     parseExpressionIterative_168
       and.w     #255,D2
       cmp.w     #245,D2
       beq.s     parseExpressionIterative_168
       and.w     #255,D2
       cmp.w     #246,D2
       beq.s     parseExpressionIterative_168
       and.w     #255,D2
       cmp.w     #247,D2
       bne       parseExpressionIterative_166
parseExpressionIterative_168:
; if (typeA == '$')
       cmp.b     #36,D5
       bne.s     parseExpressionIterative_169
; logicalString(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalString
       add.w     #12,A7
       bra.s     parseExpressionIterative_172
parseExpressionIterative_169:
; else if (typeA == '#')
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_171
; logicalNumericFloat(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericFloat
       add.w     #12,A7
       bra.s     parseExpressionIterative_172
parseExpressionIterative_171:
; else
; logicalNumericInt(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericInt
       add.w     #12,A7
parseExpressionIterative_172:
; valTypeStack[valTop] = '%';
       move.b    #37,-86(A6,D3.L)
       bra       parseExpressionIterative_167
parseExpressionIterative_166:
; } else {
; if (typeA == '#')
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_173
; arithReal(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithReal
       add.w     #12,A7
       bra.s     parseExpressionIterative_174
parseExpressionIterative_173:
; else
; arithInt(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithInt
       add.w     #12,A7
parseExpressionIterative_174:
; valTypeStack[valTop] = typeA;
       move.b    D5,-86(A6,D3.L)
parseExpressionIterative_167:
       bra       parseExpressionIterative_135
parseExpressionIterative_137:
; }
; }
; if (opTop + 1 >= PARSER_STACK_SIZE) {
       move.l    D7,D0
       addq.l    #1,D0
       cmp.l     #32,D0
       blt.s     parseExpressionIterative_175
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_175:
; }
; opTop++;
       addq.l    #1,D7
; opStack[opTop] = currentOp;
       lea       -150(A6),A0
       move.b    -1807(A6),0(A0,D7.L)
; opPrecStack[opTop] = (unsigned char)currentPrec;
       move.l    -1778(A6),D0
       move.b    D0,-118(A6,D7.L)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     parseExpressionIterative_177
       bra       parseExpressionIterative_3
parseExpressionIterative_177:
; expectValue = 1;
       move.l    #1,-1784(A6)
; continue;
       bra.s     parseExpressionIterative_7
parseExpressionIterative_132:
; }
; break;
       bra.s     parseExpressionIterative_8
parseExpressionIterative_7:
       bra       parseExpressionIterative_6
parseExpressionIterative_8:
; }
; while (opTop >= 0) {
parseExpressionIterative_179:
       cmp.l     #0,D7
       blt       parseExpressionIterative_181
; op = opStack[opTop--];
       move.l    D7,D0
       subq.l    #1,D7
       lea       -150(A6),A0
       move.b    0(A0,D0.L),D2
; if (op == '(') {
       cmp.b     #40,D2
       bne.s     parseExpressionIterative_182
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_182:
; }
; if (valTop < 1) {
       cmp.l     #1,D3
       bge.s     parseExpressionIterative_184
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_184:
; }
; b = valStack[valTop];
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    A0,D6
; typeB = valTypeStack[valTop];
       move.b    -86(A6,D3.L),-1806(A6)
; valTop--;
       subq.l    #1,D3
; a = valStack[valTop];
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    A0,D4
; typeA = valTypeStack[valTop];
       move.b    -86(A6,D3.L),D5
; if (typeA != typeB) {
       cmp.b     -1806(A6),D5
       beq       parseExpressionIterative_192
; if (typeA == '$' || typeB == '$') {
       cmp.b     #36,D5
       beq.s     parseExpressionIterative_190
       move.b    -1806(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_188
parseExpressionIterative_190:
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_188:
; }
; if (typeA == '#') {
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_191
; *(unsigned int*)b = fppReal(*(unsigned int*)b);
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D6,A0
       move.l    D0,(A0)
; typeB = '#';
       move.b    #35,-1806(A6)
       bra.s     parseExpressionIterative_192
parseExpressionIterative_191:
; }
; else {
; *(unsigned int*)a = fppReal(*(unsigned int*)a);
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D4,A0
       move.l    D0,(A0)
; typeA = '#';
       moveq     #35,D5
parseExpressionIterative_192:
; }
; }
; if (op == 0xF3 || op == 0xF4) {
       and.w     #255,D2
       cmp.w     #243,D2
       beq.s     parseExpressionIterative_195
       and.w     #255,D2
       cmp.w     #244,D2
       bne       parseExpressionIterative_193
parseExpressionIterative_195:
; if (typeA == '$' || typeB == '$') {
       cmp.b     #36,D5
       beq.s     parseExpressionIterative_198
       move.b    -1806(A6),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_196
parseExpressionIterative_198:
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_196:
; }
; if (op == 0xF3)
       and.w     #255,D2
       cmp.w     #243,D2
       bne.s     parseExpressionIterative_199
; *(int*)a = (*(int*)a && *(int*)b);
       move.l    D4,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_201
       move.l    D6,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_201
       moveq     #1,D0
       bra.s     parseExpressionIterative_202
parseExpressionIterative_201:
       clr.l     D0
parseExpressionIterative_202:
       move.l    D4,A0
       move.l    D0,(A0)
       bra.s     parseExpressionIterative_200
parseExpressionIterative_199:
; else
; *(int*)a = (*(int*)a || *(int*)b);
       move.l    D4,A0
       tst.l     (A0)
       bne.s     parseExpressionIterative_205
       move.l    D6,A0
       tst.l     (A0)
       beq.s     parseExpressionIterative_203
parseExpressionIterative_205:
       moveq     #1,D0
       bra.s     parseExpressionIterative_204
parseExpressionIterative_203:
       clr.l     D0
parseExpressionIterative_204:
       move.l    D4,A0
       move.l    D0,(A0)
parseExpressionIterative_200:
; valTypeStack[valTop] = '%';
       move.b    #37,-86(A6,D3.L)
       bra       parseExpressionIterative_207
parseExpressionIterative_193:
; } else if (op == '=' || op == '<' || op == '>' || op == 0xF5 || op == 0xF6 || op == 0xF7) {
       cmp.b     #61,D2
       beq.s     parseExpressionIterative_208
       cmp.b     #60,D2
       beq.s     parseExpressionIterative_208
       cmp.b     #62,D2
       beq.s     parseExpressionIterative_208
       and.w     #255,D2
       cmp.w     #245,D2
       beq.s     parseExpressionIterative_208
       and.w     #255,D2
       cmp.w     #246,D2
       beq.s     parseExpressionIterative_208
       and.w     #255,D2
       cmp.w     #247,D2
       bne       parseExpressionIterative_206
parseExpressionIterative_208:
; if (typeA == '$')
       cmp.b     #36,D5
       bne.s     parseExpressionIterative_209
; logicalString(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalString
       add.w     #12,A7
       bra.s     parseExpressionIterative_212
parseExpressionIterative_209:
; else if (typeA == '#')
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_211
; logicalNumericFloat(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericFloat
       add.w     #12,A7
       bra.s     parseExpressionIterative_212
parseExpressionIterative_211:
; else
; logicalNumericInt(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericInt
       add.w     #12,A7
parseExpressionIterative_212:
; valTypeStack[valTop] = '%';
       move.b    #37,-86(A6,D3.L)
       bra       parseExpressionIterative_207
parseExpressionIterative_206:
; } else {
; if (typeA == '#')
       cmp.b     #35,D5
       bne.s     parseExpressionIterative_213
; arithReal(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithReal
       add.w     #12,A7
       bra.s     parseExpressionIterative_214
parseExpressionIterative_213:
; else
; arithInt(op, a, b);
       move.l    D6,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithInt
       add.w     #12,A7
parseExpressionIterative_214:
; valTypeStack[valTop] = typeA;
       move.b    D5,-86(A6,D3.L)
parseExpressionIterative_207:
       bra       parseExpressionIterative_179
parseExpressionIterative_181:
; }
; }
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       parseExpressionIterative_215
; {
; writeLongSerial("Aqui 888.666.78 - [\0");
       pea       @basic_139.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(valTop,sqtdtam,10);
       pea       10
       move.l    A3,-(A7)
       move.l    D3,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A3,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n\0");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_215:
; }
; if (valTop < 0) {
       cmp.l     #0,D3
       bge.s     parseExpressionIterative_217
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return;
       bra       parseExpressionIterative_3
parseExpressionIterative_217:
; }
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq.s     parseExpressionIterative_219
; {
; writeLongSerial("Aqui 888.666.79\r\n\0");
       pea       @basic_140.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
parseExpressionIterative_219:
; }
; *value_type = valTypeStack[valTop];
       move.l    _value_type.L,A0
       move.b    -86(A6,D3.L),(A0)
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     parseExpressionIterative_221
; strcpy((char*)result, (char*)valStack[valTop]);
       lea       -1750(A6),A0
       move.l    D3,D1
       muls      #50,D1
       add.l     D1,A0
       move.l    A0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     parseExpressionIterative_222
parseExpressionIterative_221:
; else
; *(unsigned int*)result = *(unsigned int*)valStack[valTop];
       lea       -1750(A6),A0
       move.l    D3,D0
       muls      #50,D0
       add.l     D0,A0
       move.l    8(A6),D0
       move.l    D0,A1
       move.l    (A0),(A1)
parseExpressionIterative_222:
; return;
parseExpressionIterative_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //  Add or subtract two terms real/int or string.
; //--------------------------------------------------------------------------------------
; void level2(unsigned char *result)
; {
       xdef      _level2
_level2:
       link      A6,#-92
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4,-(A7)
       lea       _value_type.L,A2
       lea       _vErroProc.L,A3
       lea       -90(A6),A4
       move.l    8(A6),D4
; char  op;
; unsigned char hold[50];
; unsigned char valueTypeAnt;
; unsigned int *lresult = result;
       move.l    D4,D6
; unsigned int *lhold = hold;
       move.l    A4,D5
; unsigned char* sqtdtam[10];
; level3(result);
       move.l    D4,-(A7)
       jsr       _level3
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level2_1
       bra       level2_3
level2_1:
; op = *token;
       move.l    _token.L,A0
       move.b    (A0),D2
; while(op == '+' || op == '-') {
level2_4:
       cmp.b     #43,D2
       beq.s     level2_7
       cmp.b     #45,D2
       bne       level2_6
level2_7:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level2_8
       bra       level2_3
level2_8:
; valueTypeAnt = *value_type;
       move.l    (A2),A0
       move.b    (A0),D3
; level3(&hold);
       move.l    A4,-(A7)
       jsr       _level3
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level2_10
       bra       level2_3
level2_10:
; if (*value_type != valueTypeAnt)
       move.l    (A2),A0
       cmp.b     (A0),D3
       beq.s     level2_14
; {
; if (*value_type == '$' || valueTypeAnt == '$')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level2_16
       cmp.b     #36,D3
       bne.s     level2_14
level2_16:
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return;
       bra       level2_3
level2_14:
; }
; }
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type == '$' && valueTypeAnt == '$' && op == '+')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level2_17
       cmp.b     #36,D3
       bne.s     level2_17
       cmp.b     #43,D2
       bne.s     level2_17
; strcat(result,&hold);
       move.l    A4,-(A7)
       move.l    D4,-(A7)
       jsr       _strcat
       addq.w    #8,A7
       bra       level2_30
level2_17:
; else if ((*value_type == '$' || valueTypeAnt == '$') && op == '-')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level2_21
       cmp.b     #36,D3
       bne.s     level2_19
level2_21:
       cmp.b     #45,D2
       bne.s     level2_19
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return;
       bra       level2_3
level2_19:
; }
; else
; {
; if (*value_type != valueTypeAnt)
       move.l    (A2),A0
       cmp.b     (A0),D3
       beq       level2_28
; {
; if (*value_type == '$' || valueTypeAnt == '$')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level2_26
       cmp.b     #36,D3
       bne.s     level2_24
level2_26:
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return;
       bra       level2_3
level2_24:
; }
; else if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level2_27
; {
; *lresult = fppReal(*lresult);
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D6,A0
       move.l    D0,(A0)
       bra.s     level2_28
level2_27:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    D5,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D5,A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    (A2),A0
       move.b    #35,(A0)
level2_28:
; }
; }
; if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level2_29
; arithReal(op, result, &hold);
       move.l    A4,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithReal
       add.w     #12,A7
       bra.s     level2_30
level2_29:
; else
; arithInt(op, result, &hold);
       move.l    A4,-(A7)
       move.l    D4,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithInt
       add.w     #12,A7
level2_30:
; }
; op = *token;
       move.l    _token.L,A0
       move.b    (A0),D2
       bra       level2_4
level2_6:
; }
; return;
level2_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Multiply or divide two factors real/int.
; //--------------------------------------------------------------------------------------
; void level3(unsigned char *result)
; {
       xdef      _level3
_level3:
       link      A6,#-92
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       _value_type.L,A2
       lea       _vErroProc.L,A3
       lea       _fppReal.L,A4
       lea       _token.L,A5
       move.l    8(A6),D6
; char  op;
; unsigned char hold[50];
; unsigned int *lresult = result;
       move.l    D6,D4
; unsigned int *lhold = hold;
       lea       -90(A6),A0
       move.l    A0,D3
; char value_type_ant=0;
       clr.b     D5
; unsigned char* sqtdtam[10];
; do
; {
level3_1:
; level30(result);
       move.l    D6,-(A7)
       jsr       _level30
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level3_3
       bra       level3_5
level3_3:
; if (*token==0xF3||*token==0xF4)
       move.l    (A5),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #243,D0
       beq.s     level3_8
       move.l    (A5),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #244,D0
       bne.s     level3_6
level3_8:
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level3_9
       bra       level3_5
level3_9:
       bra.s     level3_7
level3_6:
; }
; else
; break;
       bra.s     level3_2
level3_7:
       bra       level3_1
level3_2:
; }
; while (1);
; op = *token;
       move.l    (A5),A0
       move.b    (A0),D2
; while(op == '*' || op == '/' || op == '%') {
level3_11:
       cmp.b     #42,D2
       beq.s     level3_14
       cmp.b     #47,D2
       beq.s     level3_14
       cmp.b     #37,D2
       bne       level3_13
level3_14:
; if (*value_type == '$')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level3_15
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return;
       bra       level3_5
level3_15:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level3_17
       bra       level3_5
level3_17:
; value_type_ant = *value_type;
       move.l    (A2),A0
       move.b    (A0),D5
; level4(&hold);
       pea       -90(A6)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level3_19
       bra       level3_5
level3_19:
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type == '$' || value_type_ant == '$')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level3_23
       cmp.b     #36,D5
       bne.s     level3_21
level3_23:
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return;
       bra       level3_5
level3_21:
; }
; if (*value_type != value_type_ant)
       move.l    (A2),A0
       cmp.b     (A0),D5
       beq       level3_27
; {
; if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level3_26
; {
; *lresult = fppReal(*lresult);
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.l    D4,A0
       move.l    D0,(A0)
       bra.s     level3_27
level3_26:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    (A2),A0
       move.b    #35,(A0)
level3_27:
; }
; }
; // se valor inteiro e for divisao, obrigatoriamente devolve valor real
; if (*value_type == '%' && op == '/')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne       level3_28
       cmp.b     #47,D2
       bne.s     level3_28
; {
; *lresult = fppReal(*lresult);
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.l    D4,A0
       move.l    D0,(A0)
; *lhold = fppReal(*lhold);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    (A2),A0
       move.b    #35,(A0)
level3_28:
; }
; if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level3_30
; arithReal(op, result, &hold);
       pea       -90(A6)
       move.l    D6,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithReal
       add.w     #12,A7
       bra.s     level3_31
level3_30:
; else
; arithInt(op, result, &hold);
       pea       -90(A6)
       move.l    D6,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _arithInt
       add.w     #12,A7
level3_31:
; op = *token;
       move.l    (A5),A0
       move.b    (A0),D2
       bra       level3_11
level3_13:
; }
; return;
level3_5:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Is a NOT
; //--------------------------------------------------------------------------------------
; void level30(unsigned char *result)
; {
       xdef      _level30
_level30:
       link      A6,#0
       movem.l   D2/D3/A2,-(A7)
       lea       _vErroProc.L,A2
; char  op;
; int *iLog = result;
       move.l    8(A6),D3
; op = 0;
       clr.b     D2
; if (*token == 0xF8) // NOT
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #248,D0
       bne.s     level30_3
; {
; op = *token;
       move.l    _token.L,A0
       move.b    (A0),D2
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level30_3
       bra       level30_5
level30_3:
; }
; level31(result);
       move.l    8(A6),-(A7)
       jsr       _level31
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level30_6
       bra       level30_5
level30_6:
; if (op)
       tst.b     D2
       beq       level30_8
; {
; if (*value_type == '$' || *value_type == '#')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level30_12
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level30_10
level30_12:
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra.s     level30_5
level30_10:
; }
; *iLog = !*iLog;
       move.l    D3,A0
       tst.l     (A0)
       bne.s     level30_13
       moveq     #1,D0
       bra.s     level30_14
level30_13:
       clr.l     D0
level30_14:
       move.l    D3,A0
       move.l    D0,(A0)
level30_8:
; }
; return;
level30_5:
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Process logic conditions AND or OR.
; //--------------------------------------------------------------------------------------
; void level31(unsigned char *result)
; {
       xdef      _level31
_level31:
       link      A6,#-92
       movem.l   D2/D3/D4/A2,-(A7)
       lea       _vErroProc.L,A2
; unsigned char  op;
; unsigned char hold[50];
; char value_type_ant=0;
       clr.b     -41(A6)
; int *rVal = result;
       move.l    8(A6),D2
; int *hVal = hold;
       lea       -92(A6),A0
       move.l    A0,D4
; unsigned char* sqtdtam[10];
; level32(result);
       move.l    8(A6),-(A7)
       jsr       _level32
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level31_1
       bra       level31_3
level31_1:
; op = *token;
       move.l    _token.L,A0
       move.b    (A0),D3
; if (op==0xF3 /* AND */|| op==0xF4 /* OR */) {
       and.w     #255,D3
       cmp.w     #243,D3
       beq.s     level31_6
       and.w     #255,D3
       cmp.w     #244,D3
       bne       level31_12
level31_6:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level31_7
       bra       level31_3
level31_7:
; level32(&hold);
       pea       -92(A6)
       jsr       _level32
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level31_9
       bra       level31_3
level31_9:
; /*writeLongSerial("Aqui 333.666.0-[");
; itoa(op,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*rVal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*hVal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (op==0xF3)
       and.w     #255,D3
       cmp.w     #243,D3
       bne.s     level31_11
; *rVal = (*rVal && *hVal);
       move.l    D2,A0
       tst.l     (A0)
       beq.s     level31_13
       move.l    D4,A0
       tst.l     (A0)
       beq.s     level31_13
       moveq     #1,D0
       bra.s     level31_14
level31_13:
       clr.l     D0
level31_14:
       move.l    D2,A0
       move.l    D0,(A0)
       bra.s     level31_12
level31_11:
; else
; *rVal = (*rVal || *hVal);
       move.l    D2,A0
       tst.l     (A0)
       bne.s     level31_17
       move.l    D4,A0
       tst.l     (A0)
       beq.s     level31_15
level31_17:
       moveq     #1,D0
       bra.s     level31_16
level31_15:
       clr.l     D0
level31_16:
       move.l    D2,A0
       move.l    D0,(A0)
level31_12:
; /*riteLongSerial("Aqui 333.666.1-[");
; itoa(op,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*rVal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; }
; return;
level31_3:
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Process logic conditions
; //--------------------------------------------------------------------------------------
; void level32(unsigned char *result)
; {
       xdef      _level32
_level32:
       link      A6,#-72
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4,-(A7)
       lea       _value_type.L,A2
       lea       -70(A6),A3
       move.l    8(A6),D3
       lea       _vErroProc.L,A4
; unsigned char  op;
; unsigned char hold[50];
; unsigned char value_type_ant=0;
       clr.b     D4
; unsigned int *lresult = result;
       move.l    D3,D6
; unsigned int *lhold = hold;
       move.l    A3,D5
; unsigned char sqtdtam[20];
; level4(result);
       move.l    D3,-(A7)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     level32_1
       bra       level32_3
level32_1:
; op = *token;
       move.l    _token.L,A0
       move.b    (A0),D2
; if (op=='=' || op=='<' || op=='>' || op==0xF5 /* >= */ || op==0xF6 /* <= */|| op==0xF7 /* <> */) {
       cmp.b     #61,D2
       beq.s     level32_6
       cmp.b     #60,D2
       beq.s     level32_6
       cmp.b     #62,D2
       beq.s     level32_6
       and.w     #255,D2
       cmp.w     #245,D2
       beq.s     level32_6
       and.w     #255,D2
       cmp.w     #246,D2
       beq.s     level32_6
       and.w     #255,D2
       cmp.w     #247,D2
       bne       level32_22
level32_6:
; //        if (op==0xF5 /* >= */ || op==0xF6 /* <= */|| op==0xF7)
; //            pointerRunProg++;
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     level32_7
       bra       level32_3
level32_7:
; value_type_ant = *value_type;
       move.l    (A2),A0
       move.b    (A0),D4
; level4(&hold);
       move.l    A3,-(A7)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     level32_9
       bra       level32_3
level32_9:
; if ((value_type_ant=='$' && *value_type!='$') || (value_type_ant != '$' && *value_type == '$'))
       cmp.b     #36,D4
       bne.s     level32_14
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level32_13
level32_14:
       cmp.b     #36,D4
       beq.s     level32_11
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level32_11
level32_13:
; {
; *vErroProc = 16;
       move.l    (A4),A0
       move.w    #16,(A0)
; return;
       bra       level32_3
level32_11:
; }
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type != value_type_ant)
       move.l    (A2),A0
       cmp.b     (A0),D4
       beq       level32_18
; {
; if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level32_17
; {
; *lresult = fppReal(*lresult);
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D6,A0
       move.l    D0,(A0)
       bra.s     level32_18
level32_17:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    D5,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D5,A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    (A2),A0
       move.b    #35,(A0)
level32_18:
; }
; }
; if (*value_type == '$')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level32_19
; logicalString(op, result, &hold);
       move.l    A3,-(A7)
       move.l    D3,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalString
       add.w     #12,A7
       bra       level32_22
level32_19:
; else if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level32_21
; logicalNumericFloat(op, result, &hold);
       move.l    A3,-(A7)
       move.l    D3,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericFloat
       add.w     #12,A7
       bra.s     level32_22
level32_21:
; else
; logicalNumericInt(op, result, &hold);
       move.l    A3,-(A7)
       move.l    D3,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _logicalNumericInt
       add.w     #12,A7
level32_22:
; }
; return;
level32_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Process integer exponent real/int.
; //--------------------------------------------------------------------------------------
; void level4(unsigned char *result)
; {
       xdef      _level4
_level4:
       link      A6,#-52
       movem.l   D2/D3/D4/D5/A2/A3/A4,-(A7)
       lea       _value_type.L,A2
       lea       _vErroProc.L,A3
       lea       -50(A6),A4
       move.l    8(A6),D2
; unsigned char hold[50];
; unsigned int *lresult = result;
       move.l    D2,D5
; unsigned int *lhold = hold;
       move.l    A4,D4
; char value_type_ant=0;
       clr.b     D3
; level5(result);
       move.l    D2,-(A7)
       jsr       _level5
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level4_1
       bra       level4_3
level4_1:
; if (*token== '^') {
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #94,D0
       bne       level4_19
; if (*value_type == '$')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level4_6
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return;
       bra       level4_3
level4_6:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level4_8
       bra       level4_3
level4_8:
; value_type_ant = *value_type;
       move.l    (A2),A0
       move.b    (A0),D3
; level4(&hold);
       move.l    A4,-(A7)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     level4_10
       bra       level4_3
level4_10:
; if (*value_type == '$')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level4_12
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return;
       bra       level4_3
level4_12:
; }
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type != value_type_ant)
       move.l    (A2),A0
       cmp.b     (A0),D3
       beq       level4_17
; {
; if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level4_16
; {
; *lresult = fppReal(*lresult);
       move.l    D5,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D5,A0
       move.l    D0,(A0)
       bra.s     level4_17
level4_16:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    D4,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D4,A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    (A2),A0
       move.b    #35,(A0)
level4_17:
; }
; }
; if (*value_type == '#')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level4_18
; arithReal('^', result, &hold);
       move.l    A4,-(A7)
       move.l    D2,-(A7)
       pea       94
       jsr       _arithReal
       add.w     #12,A7
       bra.s     level4_19
level4_18:
; else
; arithInt('^', result, &hold);
       move.l    A4,-(A7)
       move.l    D2,-(A7)
       pea       94
       jsr       _arithInt
       add.w     #12,A7
level4_19:
; }
; return;
level4_3:
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3/A4
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Is a unary + or -.
; //--------------------------------------------------------------------------------------
; void level5(unsigned char *result)
; {
       xdef      _level5
_level5:
       link      A6,#0
       movem.l   D2/D3/A2/A3,-(A7)
       move.l    8(A6),D3
       lea       _vErroProc.L,A2
       lea       _token.L,A3
; char  op;
; op = 0;
       clr.b     D2
; if (*token_type==DELIMITER && (*token=='+' || *token=='-')) {
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #1,D0
       bne.s     level5_4
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #43,D0
       beq.s     level5_3
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #45,D0
       bne.s     level5_4
level5_3:
; op = *token;
       move.l    (A3),A0
       move.b    (A0),D2
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level5_4
       bra       level5_6
level5_4:
; }
; level6(result);
       move.l    D3,-(A7)
       jsr       _level6
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level5_7
       bra       level5_6
level5_7:
; if (op)
       tst.b     D2
       beq       level5_14
; {
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level5_11
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       level5_6
level5_11:
; }
; if (*value_type == '#')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level5_13
; unaryReal(op, result);
       move.l    D3,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _unaryReal
       addq.w    #8,A7
       bra.s     level5_14
level5_13:
; else
; unaryInt(op, result);
       move.l    D3,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _unaryInt
       addq.w    #8,A7
level5_14:
; }
; return;
level5_6:
       movem.l   (A7)+,D2/D3/A2/A3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Process parenthesized expression real/int/string or function.
; //--------------------------------------------------------------------------------------
; void level6(unsigned char *result)
; {
       xdef      _level6
_level6:
       link      A6,#0
       move.l    A2,-(A7)
       lea       _vErroProc.L,A2
; if ((*token == '(') && (*token_type == OPENPARENT)) {
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       level6_1
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       bne       level6_1
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level6_3
       bra       level6_5
level6_3:
; level2(result);
       move.l    8(A6),-(A7)
       jsr       _level2
       addq.w    #4,A7
; if (*token != ')')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #41,D0
       beq.s     level6_6
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return;
       bra.s     level6_5
level6_6:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     level6_8
       bra.s     level6_5
level6_8:
       bra.s     level6_2
level6_1:
; }
; else
; {
; primitive(result);
       move.l    8(A6),-(A7)
       jsr       _primitive
       addq.w    #4,A7
; return;
       bra       level6_5
level6_2:
; }
; return;
level6_5:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Find value of number or variable.
; //--------------------------------------------------------------------------------------
; void primitive(unsigned char *result)
; {
       xdef      _primitive
_primitive:
       link      A6,#-16
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       _token.L,A2
       move.l    8(A6),D2
       lea       _vErroProc.L,A3
       lea       _value_type.L,A4
       lea       _nextToken.L,A5
; unsigned long ix;
; unsigned char* vix = &ix;
       lea       -14(A6),A0
       move.l    A0,D3
; unsigned char* vRet;
; unsigned char sqtdtam[10];
; unsigned char *vTempPointer;
; unsigned char tokenLen = 0;
       clr.b     D4
; switch(*token_type) {
       move.l    _token_type.L,A0
       move.b    (A0),D0
       and.l     #255,D0
       subq.l    #2,D0
       blo       primitive_1
       cmp.l     #5,D0
       bhs       primitive_1
       asl.l     #1,D0
       move.w    primitive_3(PC,D0.L),D0
       jmp       primitive_3(PC,D0.W)
primitive_3:
       dc.w      primitive_4-primitive_3
       dc.w      primitive_6-primitive_3
       dc.w      primitive_7-primitive_3
       dc.w      primitive_1-primitive_3
       dc.w      primitive_5-primitive_3
primitive_4:
; case VARIABLE:
; while (token[tokenLen])
primitive_9:
       move.l    (A2),A0
       and.l     #255,D4
       tst.b     0(A0,D4.L)
       beq.s     primitive_11
; tokenLen++;
       addq.b    #1,D4
       bra       primitive_9
primitive_11:
; if (tokenLen < 3)
       cmp.b     #3,D4
       bhs.s     primitive_12
; {
; *value_type=VARTYPEDEFAULT;
       move.l    (A4),A0
       move.b    #35,(A0)
; if (tokenLen == 2 && *(token + 1) < 0x30)
       cmp.b     #2,D4
       bne.s     primitive_14
       move.l    (A2),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     primitive_14
; *value_type = *(token + 1);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    1(A0),(A1)
primitive_14:
       bra.s     primitive_13
primitive_12:
; }
; else
; {
; *value_type = *(token + 2);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    2(A0),(A1)
primitive_13:
; }
; vRet = find_var(token);
       move.l    (A2),-(A7)
       jsr       _find_var
       addq.w    #4,A7
       move.l    D0,D6
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     primitive_16
       bra       primitive_18
primitive_16:
; if (*value_type == '$')  // Tipo da variavel
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     primitive_19
; strcpy(result,vRet);
       move.l    D6,-(A7)
       move.l    D2,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     primitive_23
primitive_19:
; else
; {
; for (ix = 0;ix < 5;ix++)
       clr.l     -14(A6)
primitive_21:
       move.l    -14(A6),D0
       cmp.l     #5,D0
       bhs.s     primitive_23
; result[ix] = vRet[ix];
       move.l    D6,A0
       move.l    -14(A6),D0
       move.l    D2,A1
       move.l    -14(A6),D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-14(A6)
       bra       primitive_21
primitive_23:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     primitive_24
       bra       primitive_18
primitive_24:
; return;
       bra       primitive_18
primitive_5:
; case QUOTE:
; *value_type='$';
       move.l    (A4),A0
       move.b    #36,(A0)
; strcpy(result,token);
       move.l    (A2),-(A7)
       move.l    D2,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
; nextToken();
       jsr       (A5)
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     primitive_26
       bra       primitive_18
primitive_26:
; return;
       bra       primitive_18
primitive_6:
; case NUMBER:
; if (strchr(token,'.'))  // verifica se eh numero inteiro ou real
       pea       46
       move.l    (A2),-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq.s     primitive_28
; {
; *value_type='#'; // Real
       move.l    (A4),A0
       move.b    #35,(A0)
; ix=floatStringToFpp(token);
       move.l    (A2),-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,-14(A6)
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     primitive_30
       bra       primitive_18
primitive_30:
       bra.s     primitive_29
primitive_28:
; }
; else
; {
; *value_type='%'; // Inteiro
       move.l    (A4),A0
       move.b    #37,(A0)
; ix=atoi(token);
       move.l    (A2),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-14(A6)
primitive_29:
; }
; vix = &ix;
       lea       -14(A6),A0
       move.l    A0,D3
; result[0] = vix[0];
       move.l    D3,A0
       move.l    D2,A1
       move.b    (A0),(A1)
; result[1] = vix[1];
       move.l    D3,A0
       move.l    D2,A1
       move.b    1(A0),1(A1)
; result[2] = vix[2];
       move.l    D3,A0
       move.l    D2,A1
       move.b    2(A0),2(A1)
; result[3] = vix[3];
       move.l    D3,A0
       move.l    D2,A1
       move.b    3(A0),3(A1)
; nextToken();
       jsr       (A5)
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     primitive_32
       bra       primitive_18
primitive_32:
; return;
       bra       primitive_18
primitive_7:
; case COMMAND:
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),D5
; *token = *vTempPointer;
       move.l    D5,A0
       move.l    (A2),A1
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
; executeToken(*vTempPointer);  // Retorno do resultado da funcao deve voltar pela variavel token. *value_type tera o tipo de retorno
       move.l    D5,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _executeToken
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     primitive_34
       bra       primitive_18
primitive_34:
; if (*value_type == '$')  // Tipo do retorno
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     primitive_36
; strcpy(result,token);
       move.l    (A2),-(A7)
       move.l    D2,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     primitive_40
primitive_36:
; else
; {
; for (ix = 0; ix < 4; ix++)
       clr.l     -14(A6)
primitive_38:
       move.l    -14(A6),D0
       cmp.l     #4,D0
       bhs.s     primitive_40
; {
; result[ix] = *(token + ix);
       move.l    (A2),A0
       move.l    -14(A6),D0
       move.l    D2,A1
       move.l    -14(A6),D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-14(A6)
       bra       primitive_38
primitive_40:
; }
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     primitive_41
       bra.s     primitive_18
primitive_41:
; return;
       bra.s     primitive_18
primitive_1:
; default:
; *vErroProc = 14;
       move.l    (A3),A0
       move.w    #14,(A0)
; return;
primitive_18:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; return;
; }
; //--------------------------------------------------------------------------------------
; // Perform the specified arithmetic inteiro.
; //--------------------------------------------------------------------------------------
; void arithInt(char o, char *r, char *h)
; {
       xdef      _arithInt
_arithInt:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6,-(A7)
       move.l    12(A6),D4
; int t, ex;
; int *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    D4,D2
; int *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),D3
; char* vRval = rVal;
       move.l    D2,D5
; switch(o) {
       move.b    11(A6),D0
       ext.w     D0
       ext.l     D0
       cmp.l     #45,D0
       beq.s     arithInt_3
       bgt.s     arithInt_8
       cmp.l     #43,D0
       beq.s     arithInt_4
       bgt       arithInt_2
       cmp.l     #42,D0
       beq       arithInt_5
       bra       arithInt_2
arithInt_8:
       cmp.l     #94,D0
       beq       arithInt_7
       bgt       arithInt_2
       cmp.l     #47,D0
       beq       arithInt_6
       bra       arithInt_2
arithInt_3:
; case '-':
; *rVal = *rVal - *hVal;
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A1),D0
       sub.l     D0,(A0)
; break;
       bra       arithInt_2
arithInt_4:
; case '+':
; *rVal = *rVal + *hVal;
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A1),D0
       add.l     D0,(A0)
; break;
       bra       arithInt_2
arithInt_5:
; case '*':
; *rVal = *rVal * *hVal;
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),-(A7)
       move.l    (A1),-(A7)
       jsr       LMUL
       move.l    (A7),(A0)
       addq.w    #8,A7
; break;
       bra       arithInt_2
arithInt_6:
; case '/':
; *rVal = (*rVal)/(*hVal);
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),-(A7)
       move.l    (A1),-(A7)
       jsr       LDIV
       move.l    (A7),(A0)
       addq.w    #8,A7
; break;
       bra       arithInt_2
arithInt_7:
; case '^':
; ex = *rVal;
       move.l    D2,A0
       move.l    (A0),D6
; if (*hVal==0) {
       move.l    D3,A0
       move.l    (A0),D0
       bne.s     arithInt_9
; *rVal = 1;
       move.l    D2,A0
       move.l    #1,(A0)
; break;
       bra.s     arithInt_2
arithInt_9:
; }
; ex = powNum(*rVal,*hVal);
       move.l    D3,A0
       move.l    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _powNum
       addq.w    #8,A7
       move.l    D0,D6
; *rVal = ex;
       move.l    D2,A0
       move.l    D6,(A0)
; break;
arithInt_2:
; }
; r[0] = vRval[0];
       move.l    D5,A0
       move.l    D4,A1
       move.b    (A0),(A1)
; r[1] = vRval[1];
       move.l    D5,A0
       move.l    D4,A1
       move.b    1(A0),1(A1)
; r[2] = vRval[2];
       move.l    D5,A0
       move.l    D4,A1
       move.b    2(A0),2(A1)
; r[3] = vRval[3];
       move.l    D5,A0
       move.l    D4,A1
       move.b    3(A0),3(A1)
; r[4] = 0x00;
       move.l    D4,A0
       clr.b     4(A0)
       movem.l   (A7)+,D2/D3/D4/D5/D6
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Perform the specified arithmetic real.
; //--------------------------------------------------------------------------------------
; void arithReal(char o, char *r, char *h)
; {
       xdef      _arithReal
_arithReal:
       link      A6,#-12
       movem.l   D2/D3,-(A7)
; int t, ex;
; unsigned long *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    12(A6),D2
; unsigned long *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),D3
; char* vRval = rVal;
       move.l    D2,-4(A6)
; switch(o) {
       move.b    11(A6),D0
       ext.w     D0
       ext.l     D0
       cmp.l     #45,D0
       beq.s     arithReal_3
       bgt.s     arithReal_8
       cmp.l     #43,D0
       beq       arithReal_4
       bgt       arithReal_2
       cmp.l     #42,D0
       beq       arithReal_5
       bra       arithReal_2
arithReal_8:
       cmp.l     #94,D0
       beq       arithReal_7
       bgt       arithReal_2
       cmp.l     #47,D0
       beq       arithReal_6
       bra       arithReal_2
arithReal_3:
; case '-':
; *rVal = fppSub(*rVal, *hVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppSub
       addq.w    #8,A7
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra       arithReal_2
arithReal_4:
; case '+':
; *rVal = fppSum(*rVal, *hVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppSum
       addq.w    #8,A7
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra       arithReal_2
arithReal_5:
; case '*':
; *rVal = fppMul(*rVal, *hVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppMul
       addq.w    #8,A7
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra       arithReal_2
arithReal_6:
; case '/':
; *rVal = fppDiv(*rVal, *hVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppDiv
       addq.w    #8,A7
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra.s     arithReal_2
arithReal_7:
; case '^':
; *rVal = fppPwr(*rVal, *hVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppPwr
       addq.w    #8,A7
       move.l    D2,A0
       move.l    D0,(A0)
; break;
arithReal_2:
; }
; r[4] = 0x00;
       move.l    12(A6),A0
       clr.b     4(A0)
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; void logicalNumericFloat(unsigned char o, char *r, char *h)
; {
       xdef      _logicalNumericFloat
_logicalNumericFloat:
       link      A6,#-12
       movem.l   D2/D3,-(A7)
; int t, ex;
; unsigned long *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    12(A6),D3
; unsigned long *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),-4(A6)
; unsigned long oCCR = 0;
       clr.l     D2
; oCCR = fppComp(*rVal, *hVal);
       move.l    -4(A6),A0
       move.l    (A0),-(A7)
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       _fppComp
       addq.w    #8,A7
       move.l    D0,D2
; *rVal = 0;
       move.l    D3,A0
       clr.l     (A0)
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; switch(o) {
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #245,D0
       beq       logicalNumericFloat_6
       bhi.s     logicalNumericFloat_9
       cmp.l     #61,D0
       beq.s     logicalNumericFloat_3
       bhi.s     logicalNumericFloat_10
       cmp.l     #60,D0
       beq       logicalNumericFloat_5
       bra       logicalNumericFloat_2
logicalNumericFloat_10:
       cmp.l     #62,D0
       beq.s     logicalNumericFloat_4
       bra       logicalNumericFloat_2
logicalNumericFloat_9:
       cmp.l     #247,D0
       beq       logicalNumericFloat_8
       bhi       logicalNumericFloat_2
       cmp.l     #246,D0
       beq       logicalNumericFloat_7
       bra       logicalNumericFloat_2
logicalNumericFloat_3:
; case '=':
; if (oCCR & 0x04)    // Z=1
       move.l    D2,D0
       and.l     #4,D0
       beq.s     logicalNumericFloat_11
; *rVal = 1;
       move.l    D3,A0
       move.l    #1,(A0)
logicalNumericFloat_11:
; break;
       bra       logicalNumericFloat_2
logicalNumericFloat_4:
; case '>':
; if (!(oCCR & 0x08) && !(oCCR & 0x04))   // N=0 e Z=0
       move.l    D2,D0
       and.l     #8,D0
       bne.s     logicalNumericFloat_13
       move.l    D2,D0
       and.l     #4,D0
       bne.s     logicalNumericFloat_13
; *rVal = 1;
       move.l    D3,A0
       move.l    #1,(A0)
logicalNumericFloat_13:
; break;
       bra       logicalNumericFloat_2
logicalNumericFloat_5:
; case '<':
; if ((oCCR & 0x08) && !(oCCR & 0x04))   // N=1 e Z=0
       move.l    D2,D0
       and.l     #8,D0
       beq.s     logicalNumericFloat_15
       move.l    D2,D0
       and.l     #4,D0
       bne.s     logicalNumericFloat_15
; *rVal = 1;
       move.l    D3,A0
       move.l    #1,(A0)
logicalNumericFloat_15:
; break;
       bra       logicalNumericFloat_2
logicalNumericFloat_6:
; case 0xF5:  // >=
; if (!(oCCR & 0x08) || (oCCR & 0x04))   // N=0 ou Z=1
       move.l    D2,D0
       and.l     #8,D0
       beq.s     logicalNumericFloat_19
       move.l    D2,D0
       and.l     #4,D0
       beq.s     logicalNumericFloat_17
logicalNumericFloat_19:
; *rVal = 1;
       move.l    D3,A0
       move.l    #1,(A0)
logicalNumericFloat_17:
; break;
       bra.s     logicalNumericFloat_2
logicalNumericFloat_7:
; case 0xF6:  // <=
; if ((oCCR & 0x08) || (oCCR & 0x04))   // N=1 ou Z=1
       move.l    D2,D0
       and.l     #8,D0
       bne.s     logicalNumericFloat_22
       move.l    D2,D0
       and.l     #4,D0
       beq.s     logicalNumericFloat_20
logicalNumericFloat_22:
; *rVal = 1;
       move.l    D3,A0
       move.l    #1,(A0)
logicalNumericFloat_20:
; break;
       bra.s     logicalNumericFloat_2
logicalNumericFloat_8:
; case 0xF7:  // <>
; if (!(oCCR & 0x04)) // z=0
       move.l    D2,D0
       and.l     #4,D0
       bne.s     logicalNumericFloat_23
; *rVal = 1;
       move.l    D3,A0
       move.l    #1,(A0)
logicalNumericFloat_23:
; break;
logicalNumericFloat_2:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; char logicalNumericFloatLong(unsigned char o, long r, long h)
; {
       xdef      _logicalNumericFloatLong
_logicalNumericFloatLong:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; char ex = 0;
       clr.b     D3
; unsigned long oCCR = 0;
       clr.l     D2
; oCCR = fppComp(r, h);
       move.l    16(A6),-(A7)
       move.l    12(A6),-(A7)
       jsr       _fppComp
       addq.w    #8,A7
       move.l    D0,D2
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; switch(o) {
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #245,D0
       beq       logicalNumericFloatLong_6
       bhi.s     logicalNumericFloatLong_9
       cmp.l     #61,D0
       beq.s     logicalNumericFloatLong_3
       bhi.s     logicalNumericFloatLong_10
       cmp.l     #60,D0
       beq       logicalNumericFloatLong_5
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_10:
       cmp.l     #62,D0
       beq.s     logicalNumericFloatLong_4
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_9:
       cmp.l     #247,D0
       beq       logicalNumericFloatLong_8
       bhi       logicalNumericFloatLong_2
       cmp.l     #246,D0
       beq       logicalNumericFloatLong_7
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_3:
; case '=':
; if (oCCR & 0x04)    // Z=1
       move.l    D2,D0
       and.l     #4,D0
       beq.s     logicalNumericFloatLong_11
; ex = 1;
       moveq     #1,D3
logicalNumericFloatLong_11:
; break;
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_4:
; case '>':
; if (!(oCCR & 0x08) && !(oCCR & 0x04))   // N=0 e Z=0
       move.l    D2,D0
       and.l     #8,D0
       bne.s     logicalNumericFloatLong_13
       move.l    D2,D0
       and.l     #4,D0
       bne.s     logicalNumericFloatLong_13
; ex = 1;
       moveq     #1,D3
logicalNumericFloatLong_13:
; break;
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_5:
; case '<':
; if ((oCCR & 0x08) && !(oCCR & 0x04))   // N=1 e Z=0
       move.l    D2,D0
       and.l     #8,D0
       beq.s     logicalNumericFloatLong_15
       move.l    D2,D0
       and.l     #4,D0
       bne.s     logicalNumericFloatLong_15
; ex = 1;
       moveq     #1,D3
logicalNumericFloatLong_15:
; break;
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_6:
; case 0xF5:  // >=
; if (!(oCCR & 0x08) || (oCCR & 0x04))   // N=0 ou Z=1
       move.l    D2,D0
       and.l     #8,D0
       beq.s     logicalNumericFloatLong_19
       move.l    D2,D0
       and.l     #4,D0
       beq.s     logicalNumericFloatLong_17
logicalNumericFloatLong_19:
; ex = 1;
       moveq     #1,D3
logicalNumericFloatLong_17:
; break;
       bra.s     logicalNumericFloatLong_2
logicalNumericFloatLong_7:
; case 0xF6:  // <=
; if ((oCCR & 0x08) || (oCCR & 0x04))   // N=1 ou Z=1
       move.l    D2,D0
       and.l     #8,D0
       bne.s     logicalNumericFloatLong_22
       move.l    D2,D0
       and.l     #4,D0
       beq.s     logicalNumericFloatLong_20
logicalNumericFloatLong_22:
; ex = 1;
       moveq     #1,D3
logicalNumericFloatLong_20:
; break;
       bra.s     logicalNumericFloatLong_2
logicalNumericFloatLong_8:
; case 0xF7:  // <>
; if (!(oCCR & 0x04)) // z=0
       move.l    D2,D0
       and.l     #4,D0
       bne.s     logicalNumericFloatLong_23
; ex = 1;
       moveq     #1,D3
logicalNumericFloatLong_23:
; break;
logicalNumericFloatLong_2:
; }
; return ex;
       move.b    D3,D0
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; void logicalNumericInt(unsigned char o, char *r, char *h)
; {
       xdef      _logicalNumericInt
_logicalNumericInt:
       link      A6,#-8
       movem.l   D2/D3,-(A7)
; int t, ex;
; int *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    12(A6),D2
; int *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),D3
; switch(o) {
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #245,D0
       beq       logicalNumericInt_6
       bhi.s     logicalNumericInt_9
       cmp.l     #61,D0
       beq.s     logicalNumericInt_3
       bhi.s     logicalNumericInt_10
       cmp.l     #60,D0
       beq       logicalNumericInt_5
       bra       logicalNumericInt_2
logicalNumericInt_10:
       cmp.l     #62,D0
       beq       logicalNumericInt_4
       bra       logicalNumericInt_2
logicalNumericInt_9:
       cmp.l     #247,D0
       beq       logicalNumericInt_8
       bhi       logicalNumericInt_2
       cmp.l     #246,D0
       beq       logicalNumericInt_7
       bra       logicalNumericInt_2
logicalNumericInt_3:
; case '=':
; *rVal = (*rVal == *hVal);
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       bne.s     logicalNumericInt_11
       moveq     #1,D0
       bra.s     logicalNumericInt_12
logicalNumericInt_11:
       clr.l     D0
logicalNumericInt_12:
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_4:
; case '>':
; *rVal = (*rVal > *hVal);
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       ble.s     logicalNumericInt_13
       moveq     #1,D0
       bra.s     logicalNumericInt_14
logicalNumericInt_13:
       clr.l     D0
logicalNumericInt_14:
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_5:
; case '<':
; *rVal = (*rVal < *hVal);
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       bge.s     logicalNumericInt_15
       moveq     #1,D0
       bra.s     logicalNumericInt_16
logicalNumericInt_15:
       clr.l     D0
logicalNumericInt_16:
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_6:
; case 0xF5:
; *rVal = (*rVal >= *hVal);
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       blt.s     logicalNumericInt_17
       moveq     #1,D0
       bra.s     logicalNumericInt_18
logicalNumericInt_17:
       clr.l     D0
logicalNumericInt_18:
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_7:
; case 0xF6:
; *rVal = (*rVal <= *hVal);
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       bgt.s     logicalNumericInt_19
       moveq     #1,D0
       bra.s     logicalNumericInt_20
logicalNumericInt_19:
       clr.l     D0
logicalNumericInt_20:
       move.l    D2,A0
       move.l    D0,(A0)
; break;
       bra.s     logicalNumericInt_2
logicalNumericInt_8:
; case 0xF7:
; *rVal = (*rVal != *hVal);
       move.l    D2,A0
       move.l    D3,A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       beq.s     logicalNumericInt_21
       moveq     #1,D0
       bra.s     logicalNumericInt_22
logicalNumericInt_21:
       clr.l     D0
logicalNumericInt_22:
       move.l    D2,A0
       move.l    D0,(A0)
; break;
logicalNumericInt_2:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; void logicalString(unsigned char o, char *r, char *h)
; {
       xdef      _logicalString
_logicalString:
       link      A6,#-4
       movem.l   D2/D3,-(A7)
; int t, ex;
; int *rVal = r;
       move.l    12(A6),D3
; ex = ustrcmp(r,h);
       move.l    16(A6),-(A7)
       move.l    12(A6),-(A7)
       jsr       _ustrcmp
       addq.w    #8,A7
       move.l    D0,D2
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; switch(o) {
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #245,D0
       beq       logicalString_6
       bhi.s     logicalString_9
       cmp.l     #61,D0
       beq.s     logicalString_3
       bhi.s     logicalString_10
       cmp.l     #60,D0
       beq       logicalString_5
       bra       logicalString_2
logicalString_10:
       cmp.l     #62,D0
       beq.s     logicalString_4
       bra       logicalString_2
logicalString_9:
       cmp.l     #247,D0
       beq       logicalString_8
       bhi       logicalString_2
       cmp.l     #246,D0
       beq       logicalString_7
       bra       logicalString_2
logicalString_3:
; case '=':
; *rVal = (ex == 0);
       tst.l     D2
       bne.s     logicalString_11
       moveq     #1,D0
       bra.s     logicalString_12
logicalString_11:
       clr.l     D0
logicalString_12:
       move.l    D3,A0
       move.l    D0,(A0)
; break;
       bra       logicalString_2
logicalString_4:
; case '>':
; *rVal = (ex > 0);
       cmp.l     #0,D2
       ble.s     logicalString_13
       moveq     #1,D0
       bra.s     logicalString_14
logicalString_13:
       clr.l     D0
logicalString_14:
       move.l    D3,A0
       move.l    D0,(A0)
; break;
       bra       logicalString_2
logicalString_5:
; case '<':
; *rVal = (ex < 0);
       cmp.l     #0,D2
       bge.s     logicalString_15
       moveq     #1,D0
       bra.s     logicalString_16
logicalString_15:
       clr.l     D0
logicalString_16:
       move.l    D3,A0
       move.l    D0,(A0)
; break;
       bra       logicalString_2
logicalString_6:
; case 0xF5:
; *rVal = (ex >= 0);
       cmp.l     #0,D2
       blt.s     logicalString_17
       moveq     #1,D0
       bra.s     logicalString_18
logicalString_17:
       clr.l     D0
logicalString_18:
       move.l    D3,A0
       move.l    D0,(A0)
; break;
       bra.s     logicalString_2
logicalString_7:
; case 0xF6:
; *rVal = (ex <= 0);
       cmp.l     #0,D2
       bgt.s     logicalString_19
       moveq     #1,D0
       bra.s     logicalString_20
logicalString_19:
       clr.l     D0
logicalString_20:
       move.l    D3,A0
       move.l    D0,(A0)
; break;
       bra.s     logicalString_2
logicalString_8:
; case 0xF7:
; *rVal = (ex != 0);
       tst.l     D2
       beq.s     logicalString_21
       moveq     #1,D0
       bra.s     logicalString_22
logicalString_21:
       clr.l     D0
logicalString_22:
       move.l    D3,A0
       move.l    D0,(A0)
; break;
logicalString_2:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; }
; //--------------------------------------------------------------------------------------
; // Reverse the sign.
; //--------------------------------------------------------------------------------------
; void unaryInt(char o, int *r)
; {
       xdef      _unaryInt
_unaryInt:
       link      A6,#0
; if (o=='-')
       move.b    11(A6),D0
       cmp.b     #45,D0
       bne.s     unaryInt_1
; *r = -(*r);
       move.l    12(A6),A0
       move.l    (A0),D0
       neg.l     D0
       move.l    12(A6),A0
       move.l    D0,(A0)
unaryInt_1:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Reverse the sign.
; //--------------------------------------------------------------------------------------
; void unaryReal(char o, int *r)
; {
       xdef      _unaryReal
_unaryReal:
       link      A6,#0
; if (o=='-')
       move.b    11(A6),D0
       cmp.b     #45,D0
       bne.s     unaryReal_1
; {
; *r = fppNeg(*r);
       move.l    12(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppNeg
       addq.w    #4,A7
       move.l    12(A6),A0
       move.l    D0,(A0)
unaryReal_1:
       unlk      A6
       rts
; }
; }
; //--------------------------------------------------------------------------------------
; // Find the value of a variable.
; //--------------------------------------------------------------------------------------
; unsigned char* find_var(char *s)
; {
       xdef      _find_var
_find_var:
       link      A6,#0
       movem.l   D2/D3/D4/A2,-(A7)
       move.l    8(A6),D3
       lea       _vErroProc.L,A2
; static unsigned char vTempPool[4][250];
; static unsigned char vTempDepth = 0;
; unsigned char *vTemp;
; unsigned char vLen = 0;
       clr.b     D4
; vTemp = vTempPool[vTempDepth & 0x03];
       lea       find_var_vTempPool.L,A0
       move.b    find_var_vTempDepth.L,D0
       and.l     #255,D0
       and.l     #3,D0
       muls      #250,D0
       add.l     D0,A0
       move.l    A0,D2
; vTempDepth++;
       addq.b    #1,find_var_vTempDepth.L
; while (s[vLen])
find_var_3:
       move.l    D3,A0
       and.l     #255,D4
       tst.b     0(A0,D4.L)
       beq.s     find_var_5
; vLen++;
       addq.b    #1,D4
       bra       find_var_3
find_var_5:
; *vErroProc = 0x00;
       move.l    (A2),A0
       clr.w     (A0)
; if (!isalphas(*s)){
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     find_var_6
; *vErroProc = 4; // not a variable
       move.l    (A2),A0
       move.w    #4,(A0)
; vTempDepth--;
       subq.b    #1,find_var_vTempDepth.L
; return 0;
       clr.l     D0
       bra       find_var_8
find_var_6:
; }
; if (vLen < 3)
       cmp.b     #3,D4
       bhs       find_var_9
; {
; vTemp[0] = *s;
       move.l    D3,A0
       move.l    D2,A1
       move.b    (A0),(A1)
; vTemp[2] = VARTYPEDEFAULT;
       move.l    D2,A0
       move.b    #35,2(A0)
; if (vLen == 2 && *(s + 1) < 0x30)
       cmp.b     #2,D4
       bne.s     find_var_11
       move.l    D3,A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bge.s     find_var_11
; vTemp[2] = *(s + 1);
       move.l    D3,A0
       move.l    D2,A1
       move.b    1(A0),2(A1)
find_var_11:
; if (vLen == 2 && isalphas(*(s + 1)))
       cmp.b     #2,D4
       bne.s     find_var_13
       move.l    D3,A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     find_var_13
; vTemp[1] = *(s + 1);
       move.l    D3,A0
       move.l    D2,A1
       move.b    1(A0),1(A1)
       bra.s     find_var_14
find_var_13:
; else
; vTemp[1] = 0x00;
       move.l    D2,A0
       clr.b     1(A0)
find_var_14:
       bra.s     find_var_10
find_var_9:
; }
; else
; {
; vTemp[0] = *s++;
       move.l    D3,A0
       addq.l    #1,D3
       move.l    D2,A1
       move.b    (A0),(A1)
; vTemp[1] = *s++;
       move.l    D3,A0
       addq.l    #1,D3
       move.l    D2,A1
       move.b    (A0),1(A1)
; vTemp[2] = *s;
       move.l    D3,A0
       move.l    D2,A1
       move.b    (A0),2(A1)
find_var_10:
; }
; if (!findVariable(vTemp))
       move.l    D2,-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       tst.l     D0
       bne.s     find_var_15
; {
; *vErroProc = 4; // not a variable
       move.l    (A2),A0
       move.w    #4,(A0)
; vTempDepth--;
       subq.b    #1,find_var_vTempDepth.L
; return 0;
       clr.l     D0
       bra.s     find_var_8
find_var_15:
; }
; vTempDepth--;
       subq.b    #1,find_var_vTempDepth.L
; return vTemp;
       move.l    D2,D0
find_var_8:
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; void forPush(for_stack i)
; {
       xdef      _forPush
_forPush:
       link      A6,#0
       move.l    A2,-(A7)
       lea       _ftos.L,A2
; if (*ftos>FOR_NEST)
       move.l    (A2),A0
       move.l    (A0),D0
       cmp.l     #80,D0
       ble.s     forPush_1
; {
; *vErroProc = 10;
       move.l    _vErroProc.L,A0
       move.w    #10,(A0)
; return;
       bra.s     forPush_3
forPush_1:
; }
; *(forStack + *ftos) = i;
       move.l    _forStack.L,D0
       move.l    (A2),A0
       move.l    (A0),D1
       muls      #20,D1
       add.l     D1,D0
       move.l    D0,A0
       lea       8(A6),A1
       moveq     #4,D0
       move.l    (A1)+,(A0)+
       dbra      D0,*-2
; *ftos = *ftos + 1;
       move.l    (A2),A0
       addq.l    #1,(A0)
forPush_3:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; for_stack forPop(void)
; {
       xdef      _forPop
_forPop:
       link      A6,#-20
       move.l    A2,-(A7)
       lea       _ftos.L,A2
; for_stack i;
; *ftos = *ftos - 1;
       move.l    (A2),A0
       subq.l    #1,(A0)
; if (*ftos<0)
       move.l    (A2),A0
       move.l    (A0),D0
       cmp.l     #0,D0
       bge.s     forPop_1
; {
; *vErroProc = 11;
       move.l    _vErroProc.L,A0
       move.w    #11,(A0)
; return(*forStack);
       move.l    _forStack.L,A0
       move.l    8(A6),A1
       moveq     #4,D0
       move.l    (A0)+,(A1)+
       dbra      D0,*-2
       move.l    8(A6),D0
       bra       forPop_3
forPop_1:
; }
; i=*(forStack + *ftos);
       lea       -20(A6),A0
       move.l    _forStack.L,D0
       move.l    (A2),A1
       move.l    (A1),D1
       muls      #20,D1
       add.l     D1,D0
       move.l    D0,A1
       moveq     #4,D0
       move.l    (A1)+,(A0)+
       dbra      D0,*-2
; return(i);
       lea       -20(A6),A0
       move.l    8(A6),A1
       moveq     #4,D0
       move.l    (A0)+,(A1)+
       dbra      D0,*-2
       move.l    8(A6),D0
forPop_3:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // GOSUB stack push function.
; //-----------------------------------------------------------------------------
; void gosubPush(unsigned long i)
; {
       xdef      _gosubPush
_gosubPush:
       link      A6,#0
       move.l    A2,-(A7)
       lea       _gtos.L,A2
; if (*gtos>SUB_NEST)
       move.l    (A2),A0
       move.l    (A0),D0
       cmp.l     #190,D0
       ble.s     gosubPush_1
; {
; *vErroProc = 12;
       move.l    _vErroProc.L,A0
       move.w    #12,(A0)
; return;
       bra.s     gosubPush_3
gosubPush_1:
; }
; *(gosubStack + *gtos)=i;
       move.l    _gosubStack.L,A0
       move.l    (A2),A1
       move.l    (A1),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
; *gtos = *gtos + 1;
       move.l    (A2),A0
       addq.l    #1,(A0)
gosubPush_3:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // GOSUB stack pop function.
; //-----------------------------------------------------------------------------
; unsigned long gosubPop(void)
; {
       xdef      _gosubPop
_gosubPop:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       _gtos.L,A2
; unsigned long i;
; *gtos = *gtos - 1;
       move.l    (A2),A0
       subq.l    #1,(A0)
; if (*gtos<0)
       move.l    (A2),A0
       move.l    (A0),D0
       cmp.l     #0,D0
       bge.s     gosubPop_1
; {
; *vErroProc = 13;
       move.l    _vErroProc.L,A0
       move.w    #13,(A0)
; return 0;
       clr.l     D0
       bra.s     gosubPop_3
gosubPop_1:
; }
; i=*(gosubStack + *gtos);
       move.l    _gosubStack.L,A0
       move.l    (A2),A1
       move.l    (A1),D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),-4(A6)
; return i;
       move.l    -4(A6),D0
gosubPop_3:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; unsigned int powNum(unsigned int pbase, unsigned char pexp)
; {
       xdef      _powNum
_powNum:
       link      A6,#0
       movem.l   D2/D3/D4,-(A7)
       move.b    15(A6),D4
       and.l     #255,D4
; unsigned int iz, vRes = pbase;
       move.l    8(A6),D2
; if (pexp > 0)
       cmp.b     #0,D4
       bls.s     powNum_1
; {
; pexp--;
       subq.b    #1,D4
; for(iz = 0; iz < pexp; iz++)
       clr.l     D3
powNum_3:
       and.l     #255,D4
       cmp.l     D4,D3
       bhs.s     powNum_5
; {
; vRes = vRes * pbase;
       move.l    D2,-(A7)
       move.l    8(A6),-(A7)
       jsr       ULMUL
       move.l    (A7),D2
       addq.w    #8,A7
       addq.l    #1,D3
       bra       powNum_3
powNum_5:
       bra.s     powNum_2
powNum_1:
; }
; }
; else
; vRes = 1;
       moveq     #1,D2
powNum_2:
; return vRes;
       move.l    D2,D0
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // FUNCOES PONTO FLUTUANTE
; //-----------------------------------------------------------------------------
; //-----------------------------------------------------------------------------
; // Convert from String to Float Single-Precision
; //-----------------------------------------------------------------------------
; unsigned long floatStringToFpp(unsigned char* pFloat)
; {
       xdef      _floatStringToFpp
_floatStringToFpp:
       link      A6,#-4
; unsigned long vFpp;
; *floatBufferStr = pFloat;
       move.l    _floatBufferStr.L,A0
       move.l    8(A6),(A0)
; STR_TO_FP();
       jsr       _STR_TO_FP
; vFpp = *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),-4(A6)
; return vFpp;
       move.l    -4(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Convert from Float Single-Precision to String
; //-----------------------------------------------------------------------------
; int fppTofloatString(unsigned long pFpp, unsigned char *buf)
; {
       xdef      _fppTofloatString
_fppTofloatString:
       link      A6,#0
; *floatBufferStr = buf;
       move.l    _floatBufferStr.L,A0
       move.l    12(A6),(A0)
; *floatNumD7 = pFpp;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FP_TO_STR();
       jsr       _FP_TO_STR
; return 0;
       clr.l     D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function to SUM D7+D6
; //-----------------------------------------------------------------------------
; unsigned long fppSum(unsigned long pFppD7, unsigned long pFppD6)
; {
       xdef      _fppSum
_fppSum:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    _floatNumD6.L,A0
       move.l    12(A6),(A0)
; FPP_SUM();
       jsr       _FPP_SUM
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function to Subtraction D7-D6
; //-----------------------------------------------------------------------------
; unsigned long fppSub(unsigned long pFppD7, unsigned long pFppD6)
; {
       xdef      _fppSub
_fppSub:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    _floatNumD6.L,A0
       move.l    12(A6),(A0)
; FPP_SUB();
       jsr       _FPP_SUB
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function to Mul D7*D6
; //-----------------------------------------------------------------------------
; unsigned long fppMul(unsigned long pFppD7, unsigned long pFppD6)
; {
       xdef      _fppMul
_fppMul:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    _floatNumD6.L,A0
       move.l    12(A6),(A0)
; FPP_MUL();
       jsr       _FPP_MUL
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function to Division D7/D6
; //-----------------------------------------------------------------------------
; unsigned long fppDiv(unsigned long pFppD7, unsigned long pFppD6)
; {
       xdef      _fppDiv
_fppDiv:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    _floatNumD6.L,A0
       move.l    12(A6),(A0)
; FPP_DIV();
       jsr       _FPP_DIV
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function to Power D7^D6
; //-----------------------------------------------------------------------------
; unsigned long fppPwr(unsigned long pFppD7, unsigned long pFppD6)
; {
       xdef      _fppPwr
_fppPwr:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    _floatNumD6.L,A0
       move.l    12(A6),(A0)
; FPP_PWR();
       jsr       _FPP_PWR
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Convert Float to Int
; //-----------------------------------------------------------------------------
; long fppInt(unsigned long pFppD7)
; {
       xdef      _fppInt
_fppInt:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_INT();
       jsr       _FPP_INT
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Convert Int to Float
; //-----------------------------------------------------------------------------
; unsigned long fppReal(long pFppD7)
; {
       xdef      _fppReal
_fppReal:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_FPP();
       jsr       _FPP_FPP
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return SIN
; //-----------------------------------------------------------------------------
; unsigned long fppSin(long pFppD7)
; {
       xdef      _fppSin
_fppSin:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_SIN();
       jsr       _FPP_SIN
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return COS
; //-----------------------------------------------------------------------------
; unsigned long fppCos(long pFppD7)
; {
       xdef      _fppCos
_fppCos:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_COS();
       jsr       _FPP_COS
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return TAN
; //-----------------------------------------------------------------------------
; unsigned long fppTan(long pFppD7)
; {
       xdef      _fppTan
_fppTan:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_TAN();
       jsr       _FPP_TAN
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return SIN Hiperb
; //-----------------------------------------------------------------------------
; unsigned long fppSinH(long pFppD7)
; {
       xdef      _fppSinH
_fppSinH:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_SINH();
       jsr       _FPP_SINH
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return COS Hiperb
; //-----------------------------------------------------------------------------
; unsigned long fppCosH(long pFppD7)
; {
       xdef      _fppCosH
_fppCosH:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_COSH();
       jsr       _FPP_COSH
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return TAN Hiperb
; //-----------------------------------------------------------------------------
; unsigned long fppTanH(long pFppD7)
; {
       xdef      _fppTanH
_fppTanH:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_TANH();
       jsr       _FPP_TANH
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return Sqrt
; //-----------------------------------------------------------------------------
; unsigned long fppSqrt(long pFppD7)
; {
       xdef      _fppSqrt
_fppSqrt:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_SQRT();
       jsr       _FPP_SQRT
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return TAN Hiperb
; //-----------------------------------------------------------------------------
; unsigned long fppLn(long pFppD7)
; {
       xdef      _fppLn
_fppLn:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_LN();
       jsr       _FPP_LN
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return Exp
; //-----------------------------------------------------------------------------
; unsigned long fppExp(long pFppD7)
; {
       xdef      _fppExp
_fppExp:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_EXP();
       jsr       _FPP_EXP
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return ABS
; //-----------------------------------------------------------------------------
; unsigned long fppAbs(long pFppD7)
; {
       xdef      _fppAbs
_fppAbs:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_ABS();
       jsr       _FPP_ABS
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function Return Neg
; //-----------------------------------------------------------------------------
; unsigned long fppNeg(long pFppD7)
; {
       xdef      _fppNeg
_fppNeg:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; FPP_NEG();
       jsr       _FPP_NEG
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Float Function to Comp 2 float values D7-D6
; //-----------------------------------------------------------------------------
; unsigned long fppComp(unsigned long pFppD7, unsigned long pFppD6)
; {
       xdef      _fppComp
_fppComp:
       link      A6,#0
; *floatNumD7 = pFppD7;
       move.l    _floatNumD7.L,A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    _floatNumD6.L,A0
       move.l    12(A6),(A0)
; FPP_CMP();
       jsr       _FPP_CMP
; return *floatNumD7;
       move.l    _floatNumD7.L,A0
       move.l    (A0),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Processa Parametros do comando/funcao Basic
; // Parametros:
; //      tipoRetorno: 0 - Valor Final, 1 - Nome Variavel
; //      temParenteses: 1 - tem, 0 - nao
; //      qtdParam: Quanto parametros tem 1 a 255
; //      tipoParams: Array com o tipo de cada param ($, % e #)ex: 3 params = [$,%,%]
; //      retParams: Pointer para o retorno dos parametros para a função Utilizar
; //-----------------------------------------------------------------------------
; int procParam(unsigned char tipoRetorno, unsigned char temParenteses, unsigned char tipoSeparador, unsigned char qtdParam, unsigned char *tipoParams,  unsigned char *retParams)
; {
       xdef      _procParam
_procParam:
       link      A6,#-224
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _token.L,A2
       lea       _vErroProc.L,A3
       move.l    28(A6),D2
       lea       -224(A6),A4
       lea       _varName.L,A5
       move.b    23(A6),D4
       and.l     #255,D4
; int ix, iy;
; unsigned char answer[200], varTipo, vTipoParam;
; char last_delim, last_token_type = 0;
       clr.b     -23(A6)
; unsigned char sqtdtam[10];
; long *vConvVal;
; long *vValor = answer;
       move.l    A4,-8(A6)
; unsigned char *vTempRetParam = retParams;
       move.l    D2,-4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     procParam_1
       clr.l     D0
       bra       procParam_3
procParam_1:
; // Se obriga parenteses, primeiro caracter deve ser abre parenteses
; if (temParenteses)
       tst.b     15(A6)
       beq       procParam_9
; {
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     procParam_8
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     procParam_8
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     procParam_6
procParam_8:
; {
; *vErroProc = 15;
       move.l    (A3),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_6:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     procParam_9
       clr.l     D0
       bra       procParam_3
procParam_9:
; }
; if (qtdParam == 255)
       and.w     #255,D4
       cmp.w     #255,D4
       bne.s     procParam_11
; *retParams++ = 0x00;
       move.l    D2,A0
       addq.l    #1,D2
       clr.b     (A0)
procParam_11:
; for (ix = 0; ix < qtdParam; ix++)
       clr.l     D6
procParam_13:
       and.l     #255,D4
       cmp.l     D4,D6
       bhs       procParam_15
; {
; if (qtdParam < 255)
       and.w     #255,D4
       cmp.w     #255,D4
       bhs.s     procParam_16
; vTipoParam = tipoParams[ix];
       move.l    24(A6),A0
       move.b    0(A0,D6.L),D3
       bra.s     procParam_17
procParam_16:
; else
; vTipoParam = tipoParams[0];
       move.l    24(A6),A0
       move.b    (A0),D3
procParam_17:
; if (tipoRetorno == 0)
       move.b    11(A6),D0
       bne       procParam_18
; {
; // Valor Final
; if (*token_type == QUOTE)  /* se o parametro nao pedir string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne       procParam_20
; {
; if (vTipoParam != '$')
       cmp.b     #36,D3
       beq.s     procParam_22
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_22:
; }
; // Transfere a String pro retorno do parametro
; iy = 0;
       clr.l     D5
; while (token[iy])
procParam_24:
       move.l    (A2),A0
       tst.b     0(A0,D5.L)
       beq.s     procParam_26
; *retParams++ = token[iy++];
       move.l    (A2),A0
       move.l    D5,D0
       addq.l    #1,D5
       move.l    D2,A1
       addq.l    #1,D2
       move.b    0(A0,D0.L),(A1)
       bra       procParam_24
procParam_26:
; *retParams++ = 0x00;
       move.l    D2,A0
       addq.l    #1,D2
       clr.b     (A0)
       bra       procParam_42
procParam_20:
; }
; else
; {
; /* is expression */
; last_token_type = *token_type;
       move.l    _token_type.L,A0
       move.b    (A0),-23(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A4,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     procParam_27
       clr.l     D0
       bra       procParam_3
procParam_27:
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne       procParam_29
; {
; if (vTipoParam != '$')   /* se o parametro nao pedir string, error */
       cmp.b     #36,D3
       beq.s     procParam_31
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_31:
; }
; // Transfere a String pro retorno do parametro
; iy = 0;
       clr.l     D5
; while (answer[iy])
procParam_33:
       tst.b     0(A4,D5.L)
       beq.s     procParam_35
; *retParams++ = answer[iy++];
       move.l    D5,D0
       addq.l    #1,D5
       move.l    D2,A0
       addq.l    #1,D2
       move.b    0(A4,D0.L),(A0)
       bra       procParam_33
procParam_35:
; *retParams++ = 0x00;
       move.l    D2,A0
       addq.l    #1,D2
       clr.b     (A0)
       bra       procParam_42
procParam_29:
; }
; else
; {
; if (vTipoParam == '$')   /* se nao é uma string, mas o parametro pedir string, error */
       cmp.b     #36,D3
       bne.s     procParam_36
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_36:
; }
; // Converter aqui pro valor solicitado (de int pra dec e dec pra int). @ = nao converte
; if (vTipoParam != '@' && vTipoParam != *value_type)
       cmp.b     #64,D3
       beq       procParam_38
       move.l    _value_type.L,A0
       cmp.b     (A0),D3
       beq.s     procParam_38
; {
; if (vTipoParam == '%')
       cmp.b     #37,D3
       bne.s     procParam_40
; vConvVal = fppInt(*vValor);
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,-12(A6)
       bra.s     procParam_41
procParam_40:
; else
; vConvVal = fppReal(*vValor);
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D0,-12(A6)
procParam_41:
; *vValor = vConvVal;
       move.l    -8(A6),A0
       move.l    -12(A6),(A0)
procParam_38:
; }
; // Transfere o numero gerado para o retorno do parametro
; *retParams++ = answer[0];
       move.l    D2,A0
       addq.l    #1,D2
       move.b    (A4),(A0)
; *retParams++ = answer[1];
       move.l    D2,A0
       addq.l    #1,D2
       move.b    1(A4),(A0)
; *retParams++ = answer[2];
       move.l    D2,A0
       addq.l    #1,D2
       move.b    2(A4),(A0)
; *retParams++ = answer[3];
       move.l    D2,A0
       addq.l    #1,D2
       move.b    3(A4),(A0)
; // Se for @, o proximo byte desse valor é o tipo
; if (vTipoParam == '@')
       cmp.b     #64,D3
       bne.s     procParam_42
; *retParams++ = *value_type;
       move.l    _value_type.L,A0
       move.l    D2,A1
       addq.l    #1,D2
       move.b    (A0),(A1)
procParam_42:
       bra       procParam_19
procParam_18:
; }
; }
; }
; else
; {
; // Nome Variavel
; if (!isalphas(*token)) {
       move.l    (A2),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     procParam_44
; *vErroProc = 4;
       move.l    (A3),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_44:
; }
; if (strlen(token) < 3)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       procParam_46
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       moveq     #35,D7
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     procParam_48
       move.l    (A2),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     procParam_48
; varTipo = *(token + 1);
       move.l    (A2),A0
       move.b    1(A0),D7
procParam_48:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     procParam_50
       move.l    (A2),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     procParam_50
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    1(A0),1(A1)
       bra.s     procParam_51
procParam_50:
; else
; *(varName + 1) = 0x00;
       move.l    (A5),A0
       clr.b     1(A0)
procParam_51:
; *(varName + 2) = varTipo;
       move.l    (A5),A0
       move.b    D7,2(A0)
       bra.s     procParam_47
procParam_46:
; }
; else
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    2(A0),2(A1)
; varTipo = *(varName + 2);
       move.l    (A5),A0
       move.b    2(A0),D7
procParam_47:
; }
; answer[0] = varTipo;
       move.b    D7,(A4)
procParam_19:
; }
; if ((ix + 1) != qtdParam)
       move.l    D6,D0
       addq.l    #1,D0
       and.l     #255,D4
       cmp.l     D4,D0
       beq       procParam_62
; {
; // Verifica se tem separador
; if (tipoSeparador == 0 && qtdParam != 255)
       move.b    19(A6),D0
       bne.s     procParam_54
       and.w     #255,D4
       cmp.w     #255,D4
       beq.s     procParam_54
; {
; *vErroProc = 27;
       move.l    (A3),A0
       move.w    #27,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_54:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     procParam_56
       clr.l     D0
       bra       procParam_3
procParam_56:
; // Se for um separador diferente do definido
; if (*token != tipoSeparador)
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     19(A6),D0
       beq.s     procParam_58
; {
; // Se for qtd definida, erro
; if (qtdParam != 255)
       and.w     #255,D4
       cmp.w     #255,D4
       beq.s     procParam_60
; {
; *vErroProc = 18;
       move.l    (A3),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_60:
; }
; else
; {
; *vTempRetParam = (ix + 1);
       move.l    D6,D0
       addq.l    #1,D0
       move.l    -4(A6),A0
       move.b    D0,(A0)
; break;
       bra.s     procParam_15
procParam_58:
; }
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     procParam_62
       clr.l     D0
       bra       procParam_3
procParam_62:
       addq.l    #1,D6
       bra       procParam_13
procParam_15:
; }
; }
; last_delim = *token;
       move.l    (A2),A0
       move.b    (A0),-24(A6)
; if (temParenteses)
       tst.b     15(A6)
       beq       procParam_70
; {
; if (qtdParam == 1)
       cmp.b     #1,D4
       bne.s     procParam_68
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     procParam_68
       clr.l     D0
       bra       procParam_3
procParam_68:
; }
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type != CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     procParam_70
; {
; *vErroProc = 15;
       move.l    (A3),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_70:
; }
; }
; if (qtdParam != 1 && tipoRetorno == 0)
       cmp.b     #1,D4
       beq       procParam_78
       move.b    11(A6),D0
       bne       procParam_78
; {
; if (*token != 0xBA && *token != 0x86)   // AT and TO token's
       move.l    (A2),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #186,D0
       beq       procParam_78
       move.l    (A2),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq.s     procParam_78
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     procParam_76
       clr.l     D0
       bra.s     procParam_3
procParam_76:
; if (*token == ':' || *token == tipoSeparador)
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq.s     procParam_80
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     19(A6),D0
       bne.s     procParam_78
procParam_80:
; putback();
       jsr       _putback
procParam_78:
; }
; }
; return 0;
       clr.l     D0
procParam_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; /*****************************************************************************/
; /* CONTROLE DE VARIAVEIS                                                     */
; /*****************************************************************************/
; //-----------------------------------------------------------------------------
; // Calcula o endereco do valor dentro da area de dados de uma variavel array.
; // Retorna 0 em caso de erro de limite e ajusta vErroProc.
; //-----------------------------------------------------------------------------
; static unsigned char* getArrayValuePointer(unsigned char ixDim, unsigned char* vLista, unsigned char* vDim, unsigned char vTamValue)
; {
@basic_getArrayValuePointer:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7,-(A7)
       move.l    12(A6),D6
; int ix;
; int iw;
; unsigned char ixDimAnt;
; unsigned char* vPosValueVar;
; unsigned short iDim;
; unsigned long vOffSet;
; iw = (ixDim - 1);
       move.b    11(A6),D0
       and.l     #255,D0
       subq.l    #1,D0
       move.l    D0,D5
; ixDimAnt = 1;
       moveq     #1,D4
; vPosValueVar = 0;
       clr.l     D3
; for (ix = ((ixDim - 1) * 2 ); ix >= 0; ix -= 2)
       move.b    11(A6),D0
       subq.b    #1,D0
       and.w     #255,D0
       mulu.w    #2,D0
       and.l     #65535,D0
       move.l    D0,D2
@basic_getArrayValuePointer_1:
       cmp.l     #0,D2
       blt       @basic_getArrayValuePointer_3
; {
; iDim = ((vLista[ix + 8] << 8) | vLista[ix + 9]);
       move.l    D6,A0
       move.l    D2,A1
       move.b    8(A1,A0.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    D6,A0
       move.l    D2,A1
       move.b    9(A1,A0.L),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,D7
; if (vDim[iw] > iDim)
       move.l    16(A6),A0
       move.b    0(A0,D5.L),D0
       and.w     #255,D0
       cmp.w     D7,D0
       bls.s     @basic_getArrayValuePointer_4
; {
; *vErroProc = 21;
       move.l    _vErroProc.L,A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       @basic_getArrayValuePointer_6
@basic_getArrayValuePointer_4:
; }
; vPosValueVar = vPosValueVar + ((vDim[iw] - 1 ) * ixDimAnt * vTamValue);
       move.l    16(A6),A0
       move.b    0(A0,D5.L),D0
       subq.b    #1,D0
       and.w     #255,D0
       and.w     #255,D4
       mulu.w    D4,D0
       and.w     #255,D0
       move.b    23(A6),D1
       and.w     #255,D1
       mulu.w    D1,D0
       and.l     #255,D0
       add.l     D0,D3
; ixDimAnt = ixDimAnt * iDim;
       move.b    D4,D0
       and.w     #255,D0
       mulu.w    D7,D0
       move.b    D0,D4
; iw--;
       subq.l    #1,D5
       subq.l    #2,D2
       bra       @basic_getArrayValuePointer_1
@basic_getArrayValuePointer_3:
; }
; vOffSet = vLista;
       move.l    D6,-4(A6)
; vPosValueVar = vPosValueVar + (vOffSet + 8 + (ixDim * 2));
       move.l    -4(A6),D0
       addq.l    #8,D0
       move.b    11(A6),D1
       and.w     #255,D1
       mulu.w    #2,D1
       and.l     #255,D1
       add.l     D1,D0
       add.l     D0,D3
; return vPosValueVar;
       move.l    D3,D0
@basic_getArrayValuePointer_6:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Retornos: -1 - Erro, 0 - Nao Existe, 1 - eh um valor numeral
; //           [endereco > 1] - Endereco da variavel
; //
; //           se retorno > 1: pVariable vai conter o valor numeral (qdo 1) ou
; //                           o conteudo da variavel (qdo endereco)
; //-----------------------------------------------------------------------------
; long findVariable(unsigned char* pVariable)
; {
       xdef      _findVariable
_findVariable:
       link      A6,#-156
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -24(A6),A2
       move.l    8(A6),D4
       lea       _itoa.L,A3
       lea       _vErroProc.L,A4
       lea       _debugOn.L,A5
; unsigned char* vLista = pStartSimpVar;
       move.l    _pStartSimpVar.L,D2
; unsigned char* vTemp = pStartSimpVar;
       move.l    _pStartSimpVar.L,-154(A6)
; unsigned char vVarName0 = pVariable[0];
       move.l    D4,A0
       move.b    (A0),-150(A6)
; unsigned char vVarName1 = pVariable[1];
       move.l    D4,A0
       move.b    1(A0),-149(A6)
; long vEnder = 0;
       clr.l     -148(A6)
; int ix = 0, iy = 0, iz = 0;
       clr.l     D5
       clr.l     -144(A6)
       clr.l     -140(A6)
; unsigned char vDim[88];
; unsigned int vTempDim = 0;
       clr.l     -48(A6)
; unsigned long vOffSet;
; unsigned char ixDim = 0;
       clr.b     -43(A6)
; unsigned char vArray = 0;
       moveq     #0,D7
; unsigned long vPosNextVar = 0;
       clr.l     -42(A6)
; unsigned char* vPosValueVar = 0;
       clr.l     D3
; unsigned char vTamValue = 4;
       move.b    #4,-37(A6)
; unsigned char *vTempPointer;
; unsigned char *pDst;
; unsigned char *pSrc;
; unsigned char sqtdtam[20];
; int vCacheIx;
; // Verifica se eh array (tem parenteses logo depois do nome da variavel)
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq       findVariable_1
; {
; writeLongSerial("Aqui 333.666.0 varName-[");
       pea       @basic_141.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[0],sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D4,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[1],sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D4,A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_1:
; }
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-36(A6)
; if (*vTempPointer == 0x28)
       move.l    -36(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       findVariable_35
; {
; // Define que eh array
; vArray = 1;
       moveq     #1,D7
; // Procura as dimensoes
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     findVariable_5
       clr.l     D0
       bra       findVariable_7
findVariable_5:
; // Erro, primeiro caracter depois da variavel, deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     findVariable_10
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     findVariable_10
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     findVariable_8
findVariable_10:
; {
; *vErroProc = 15;
       move.l    (A4),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_8:
; }
; do
; {
findVariable_11:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     findVariable_13
       clr.l     D0
       bra       findVariable_7
findVariable_13:
; if (*token_type == QUOTE) { // is string, error
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     findVariable_15
; *vErroProc = 16;
       move.l    (A4),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_15:
; }
; else { // is expression
; putback();
       jsr       _putback
; getExp(&vTempDim);
       pea       -48(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq       findVariable_17
; {
; writeLongSerial("Aqui 333.666.99 varName-[");
       pea       @basic_142.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vTempDim,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    -48(A6),-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*vErroProc,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    (A4),A0
       move.w    (A0),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*token,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    _token.L,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_17:
; }
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     findVariable_19
       clr.l     D0
       bra       findVariable_7
findVariable_19:
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     findVariable_21
; {
; *vErroProc = 16;
       move.l    (A4),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_21:
; }
; if (*value_type == '#')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     findVariable_23
; {
; vTempDim = fppInt(vTempDim);
       move.l    -48(A6),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,-48(A6)
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
findVariable_23:
; }
; vDim[ixDim] = vTempDim + 1;
       move.l    -48(A6),D0
       addq.l    #1,D0
       move.b    -43(A6),D1
       and.l     #255,D1
       lea       -136(A6),A0
       move.b    D0,0(A0,D1.L)
; ixDim++;
       addq.b    #1,-43(A6)
; }
; if (*token == ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       findVariable_25
; {
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq.s     findVariable_27
; {
; writeLongSerial("Aqui 333.666.98 varName-\r\n\0");
       pea       @basic_143.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_27:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-36(A6)
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq.s     findVariable_29
; {
; writeLongSerial("Aqui 333.666.97 varName-\r\n\0");
       pea       @basic_144.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*pointerRunProg,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_29:
       bra.s     findVariable_26
findVariable_25:
; }
; }
; else
; break;
       bra.s     findVariable_12
findVariable_26:
       bra       findVariable_11
findVariable_12:
; } while(1);
; // Deve ter pelo menos 1 elemento
; if (ixDim < 1)
       move.b    -43(A6),D0
       cmp.b     #1,D0
       bhs.s     findVariable_31
; {
; *vErroProc = 21;
       move.l    (A4),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_31:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     findVariable_33
       clr.l     D0
       bra       findVariable_7
findVariable_33:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     findVariable_35
; {
; *vErroProc = 15;
       move.l    (A4),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_35:
; }
; }
; // Procura na lista geral de variaveis simples / array
; if (vArray)
       tst.b     D7
       beq.s     findVariable_37
; vLista = pStartArrayVar;
       move.l    _pStartArrayVar.L,D2
       bra.s     findVariable_38
findVariable_37:
; else
; vLista = pStartSimpVar;
       move.l    _pStartSimpVar.L,D2
findVariable_38:
; if (1) // (!vArray)
; {
; for (vCacheIx = 0; vCacheIx < SIMPLE_VAR_CACHE_SLOTS; vCacheIx++)
       clr.l     -4(A6)
findVariable_41:
       move.l    -4(A6),D0
       cmp.l     #8,D0
       bge       findVariable_43
; {
; if (lastVarCacheAddr[vCacheIx] &&
       move.l    -4(A6),D0
       lsl.l     #2,D0
       lea       @basic_lastVarCacheAddr.L,A0
       tst.l     0(A0,D0.L)
       beq       findVariable_44
       move.l    -4(A6),D0
       lea       @basic_lastVarCacheName0.L,A0
       move.b    0(A0,D0.L),D1
       cmp.b     -150(A6),D1
       bne.s     findVariable_46
       moveq     #1,D0
       bra.s     findVariable_47
findVariable_46:
       clr.l     D0
findVariable_47:
       and.l     #255,D0
       beq       findVariable_44
       move.l    -4(A6),D0
       lea       @basic_lastVarCacheName1.L,A0
       move.b    0(A0,D0.L),D1
       cmp.b     -149(A6),D1
       bne.s     findVariable_48
       moveq     #1,D0
       bra.s     findVariable_49
findVariable_48:
       clr.l     D0
findVariable_49:
       and.l     #255,D0
       beq       findVariable_44
; lastVarCacheName0[vCacheIx] == vVarName0 &&
; lastVarCacheName1[vCacheIx] == vVarName1)
; {
; vLista = lastVarCacheAddr[vCacheIx];
       move.l    -4(A6),D0
       lsl.l     #2,D0
       lea       @basic_lastVarCacheAddr.L,A0
       move.l    0(A0,D0.L),D2
; *value_type = *vLista;
       move.l    D2,A0
       move.l    _value_type.L,A1
       move.b    (A0),(A1)
; if (vArray)
       tst.b     D7
       beq       findVariable_50
; {
; if (*vLista == '$')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     findVariable_52
; vTamValue = 5;
       move.b    #5,-37(A6)
findVariable_52:
; // Verifica se os tamanhos da dimensao informada e da variavel sao iguais
; if (ixDim != vLista[7])
       move.l    D2,A0
       move.b    -43(A6),D0
       cmp.b     7(A0),D0
       beq.s     findVariable_54
; {
; *vErroProc = 21;
       move.l    (A4),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_54:
; }
; vPosValueVar = getArrayValuePointer(ixDim, vLista, vDim, vTamValue);
       move.b    -37(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       -136(A6)
       move.l    D2,-(A7)
       move.b    -43(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       @basic_getArrayValuePointer
       add.w     #16,A7
       move.l    D0,D3
; if (*vErroProc)
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     findVariable_56
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_56:
       bra.s     findVariable_51
findVariable_50:
; }
; else
; {
; vPosValueVar = vLista + 3;
       move.l    D2,D0
       addq.l    #3,D0
       move.l    D0,D3
findVariable_51:
; }
; if (*vLista == '$')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne       findVariable_58
; {
; vOffSet  = (((unsigned long)*(vPosValueVar + 1) << 24) & 0xFF000000);
       move.l    D3,A0
       move.b    1(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,D6
; vOffSet |= (((unsigned long)*(vPosValueVar + 2) << 16) & 0x00FF0000);
       move.l    D3,A0
       move.b    2(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,D6
; vOffSet |= (((unsigned long)*(vPosValueVar + 3) << 8) & 0x0000FF00);
       move.l    D3,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,D6
; vOffSet |= ((unsigned long)*(vPosValueVar + 4) & 0x000000FF);
       move.l    D3,A0
       move.b    4(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,D6
; vTempPointer = vOffSet;
       move.l    D6,-36(A6)
; iy = *vPosValueVar;
       move.l    D3,A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-144(A6)
; pDst = pVariable;
       move.l    D4,-32(A6)
; pSrc = vTempPointer;
       move.l    -36(A6),-28(A6)
; for (ix = 0; ix < iy; ix++)
       clr.l     D5
findVariable_60:
       cmp.l     -144(A6),D5
       bge.s     findVariable_62
; {
; *pDst++ = *pSrc++;
       move.l    -28(A6),A0
       addq.l    #1,-28(A6)
       move.l    -32(A6),A1
       addq.l    #1,-32(A6)
       move.b    (A0),(A1)
       addq.l    #1,D5
       bra       findVariable_60
findVariable_62:
; }
; *pDst = 0x00;
       move.l    -32(A6),A0
       clr.b     (A0)
       bra       findVariable_59
findVariable_58:
; }
; else
; {
; if (!vArray)
       tst.b     D7
       bne.s     findVariable_63
; vPosValueVar++;
       addq.l    #1,D3
findVariable_63:
; pVariable[0] = *(vPosValueVar);
       move.l    D3,A0
       move.l    D4,A1
       move.b    (A0),(A1)
; pVariable[1] = *(vPosValueVar + 1);
       move.l    D3,A0
       move.l    D4,A1
       move.b    1(A0),1(A1)
; pVariable[2] = *(vPosValueVar + 2);
       move.l    D3,A0
       move.l    D4,A1
       move.b    2(A0),2(A1)
; pVariable[3] = *(vPosValueVar + 3);
       move.l    D3,A0
       move.l    D4,A1
       move.b    3(A0),3(A1)
; pVariable[4] = 0x00;
       move.l    D4,A0
       clr.b     4(A0)
findVariable_59:
; }
; return (long)vLista;
       move.l    D2,D0
       bra       findVariable_7
findVariable_44:
       addq.l    #1,-4(A6)
       bra       findVariable_41
findVariable_43:
; }
; }
; }
; while(1)
findVariable_65:
; {
; vPosNextVar  = (((unsigned long)*(vLista + 3) << 24) & 0xFF000000);
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,-42(A6)
; vPosNextVar |= (((unsigned long)*(vLista + 4) << 16) & 0x00FF0000);
       move.l    D2,A0
       move.b    4(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,-42(A6)
; vPosNextVar |= (((unsigned long)*(vLista + 5) << 8) & 0x0000FF00);
       move.l    D2,A0
       move.b    5(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,-42(A6)
; vPosNextVar |= ((unsigned long)*(vLista + 6) & 0x000000FF);
       move.l    D2,A0
       move.b    6(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,-42(A6)
; *value_type = *vLista;
       move.l    D2,A0
       move.l    _value_type.L,A1
       move.b    (A0),(A1)
; if (*(vLista + 1) == pVariable[0] && *(vLista + 2) ==  pVariable[1])
       move.l    D2,A0
       move.l    D4,A1
       move.b    1(A0),D0
       cmp.b     (A1),D0
       bne       findVariable_68
       move.l    D2,A0
       move.l    D4,A1
       move.b    2(A0),D0
       cmp.b     1(A1),D0
       bne       findVariable_68
; {
; // Pega endereco da variavel pra delvover
; if (vArray)
       tst.b     D7
       beq       findVariable_70
; {
; if (*vLista == '$')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     findVariable_72
; vTamValue = 5;
       move.b    #5,-37(A6)
findVariable_72:
; // Verifica se os tamanhos da dimensao informada e da variavel sao iguais
; if (ixDim != vLista[7])
       move.l    D2,A0
       move.b    -43(A6),D0
       cmp.b     7(A0),D0
       beq.s     findVariable_74
; {
; *vErroProc = 21;
       move.l    (A4),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_74:
; }
; vPosValueVar = getArrayValuePointer(ixDim, vLista, vDim, vTamValue);
       move.b    -37(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       -136(A6)
       move.l    D2,-(A7)
       move.b    -43(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       @basic_getArrayValuePointer
       add.w     #16,A7
       move.l    D0,D3
; if (*vErroProc)
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     findVariable_76
; return 0;
       clr.l     D0
       bra       findVariable_7
findVariable_76:
; vEnder = vPosValueVar;
       move.l    D3,-148(A6)
       bra.s     findVariable_71
findVariable_70:
; }
; else
; {
; vPosValueVar = vLista + 3;
       move.l    D2,D0
       addq.l    #3,D0
       move.l    D0,D3
; vEnder = vLista;
       move.l    D2,-148(A6)
findVariable_71:
; }
; // Pelo tipo da variavel, ja retorna na variavel de nome o conteudo da variavel
; if (*vLista == '$')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne       findVariable_78
; {
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq       findVariable_80
; {
; writeLongSerial("Aqui 333.666.0-[");
       pea       @basic_145.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(*vLista);
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vPosValueVar,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D3,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_80:
; }
; vOffSet  = (((unsigned long)*(vPosValueVar + 1) << 24) & 0xFF000000);
       move.l    D3,A0
       move.b    1(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,D6
; vOffSet |= (((unsigned long)*(vPosValueVar + 2) << 16) & 0x00FF0000);
       move.l    D3,A0
       move.b    2(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,D6
; vOffSet |= (((unsigned long)*(vPosValueVar + 3) << 8) & 0x0000FF00);
       move.l    D3,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,D6
; vOffSet |= ((unsigned long)*(vPosValueVar + 4) & 0x000000FF);
       move.l    D3,A0
       move.b    4(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,D6
; vTemp = vOffSet;
       move.l    D6,-154(A6)
; iy = *vPosValueVar;
       move.l    D3,A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-144(A6)
; pDst = pVariable;
       move.l    D4,-32(A6)
; pSrc = vTemp;
       move.l    -154(A6),-28(A6)
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq       findVariable_82
; {
; writeLongSerial("Aqui 333.666.1-[");
       pea       @basic_146.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vTemp,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    -154(A6),-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_82:
; }
; for (ix = 0; ix < iy; ix++)
       clr.l     D5
findVariable_84:
       cmp.l     -144(A6),D5
       bge       findVariable_86
; {
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq       findVariable_87
; {
; itoa(ix,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D5,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa((unsigned long)(pDst - pVariable),sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    -32(A6),D1
       sub.l     D4,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*pSrc,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    -28(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_87:
; }
; *pDst = *pSrc;
       move.l    -28(A6),A0
       move.l    -32(A6),A1
       move.b    (A0),(A1)
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq       findVariable_89
; {
; itoa(*pDst,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    -32(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_89:
; }
; pDst++;
       addq.l    #1,-32(A6)
; pSrc++;
       addq.l    #1,-28(A6)
       addq.l    #1,D5
       bra       findVariable_84
findVariable_86:
; }
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq.s     findVariable_91
; {
; writeLongSerial("]\r\n");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_91:
; }
; *pDst = 0x00;
       move.l    -32(A6),A0
       clr.b     (A0)
; if (*debugOn)
       move.l    (A5),A0
       tst.b     (A0)
       beq       findVariable_93
; {
; writeLongSerial("Aqui 333.666.2-[");
       pea       @basic_147.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vOffSet,sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D6,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[0],sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D4,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[1],sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D4,A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[2],sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D4,A0
       move.b    2(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       pea       @basic_132.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[3],sqtdtam,16);
       pea       16
       move.l    A2,-(A7)
       move.l    D4,A0
       move.b    3(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       move.l    A2,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_93:
       bra       findVariable_79
findVariable_78:
; }
; }
; else
; {
; if (!vArray)
       tst.b     D7
       bne.s     findVariable_95
; vPosValueVar++;
       addq.l    #1,D3
findVariable_95:
; pVariable[0] = *(vPosValueVar);
       move.l    D3,A0
       move.l    D4,A1
       move.b    (A0),(A1)
; pVariable[1] = *(vPosValueVar + 1);
       move.l    D3,A0
       move.l    D4,A1
       move.b    1(A0),1(A1)
; pVariable[2] = *(vPosValueVar + 2);
       move.l    D3,A0
       move.l    D4,A1
       move.b    2(A0),2(A1)
; pVariable[3] = *(vPosValueVar + 3);
       move.l    D3,A0
       move.l    D4,A1
       move.b    3(A0),3(A1)
; pVariable[4] = 0x00;
       move.l    D4,A0
       clr.b     4(A0)
findVariable_79:
; }
; if (!vArray)
       tst.b     D7
       bne       findVariable_97
; {
; for (ix = (SIMPLE_VAR_CACHE_SLOTS - 1); ix > 0; ix--)
       moveq     #7,D5
findVariable_99:
       cmp.l     #0,D5
       ble       findVariable_101
; {
; lastVarCacheName0[ix] = lastVarCacheName0[ix - 1];
       move.l    D5,D0
       subq.l    #1,D0
       lea       @basic_lastVarCacheName0.L,A0
       lea       @basic_lastVarCacheName0.L,A1
       move.b    0(A0,D0.L),0(A1,D5.L)
; lastVarCacheName1[ix] = lastVarCacheName1[ix - 1];
       move.l    D5,D0
       subq.l    #1,D0
       lea       @basic_lastVarCacheName1.L,A0
       lea       @basic_lastVarCacheName1.L,A1
       move.b    0(A0,D0.L),0(A1,D5.L)
; lastVarCacheAddr[ix] = lastVarCacheAddr[ix - 1];
       move.l    D5,D0
       subq.l    #1,D0
       lsl.l     #2,D0
       lea       @basic_lastVarCacheAddr.L,A0
       move.l    D5,D1
       lsl.l     #2,D1
       lea       @basic_lastVarCacheAddr.L,A1
       move.l    0(A0,D0.L),0(A1,D1.L)
       subq.l    #1,D5
       bra       findVariable_99
findVariable_101:
; }
; lastVarCacheName0[0] = vVarName0;
       move.b    -150(A6),@basic_lastVarCacheName0.L
; lastVarCacheName1[0] = vVarName1;
       move.b    -149(A6),@basic_lastVarCacheName1.L
; lastVarCacheAddr[0] = vLista;
       move.l    D2,@basic_lastVarCacheAddr.L
findVariable_97:
; }
; return vEnder;
       move.l    -148(A6),D0
       bra       findVariable_7
findVariable_68:
; }
; if (vArray)
       tst.b     D7
       beq.s     findVariable_102
; vLista = vPosNextVar;
       move.l    -42(A6),D2
       bra.s     findVariable_103
findVariable_102:
; else
; vLista += 8;
       addq.l    #8,D2
findVariable_103:
; if ((!vArray && vLista >= pStartArrayVar) || (vArray && vLista >= pStartProg) || *vLista == 0x00)
       tst.b     D7
       bne.s     findVariable_108
       moveq     #1,D0
       bra.s     findVariable_109
findVariable_108:
       clr.l     D0
findVariable_109:
       and.l     #255,D0
       beq.s     findVariable_107
       cmp.l     _pStartArrayVar.L,D2
       bhs.s     findVariable_106
findVariable_107:
       and.l     #255,D7
       beq.s     findVariable_110
       cmp.l     _pStartProg.L,D2
       bhs.s     findVariable_106
findVariable_110:
       move.l    D2,A0
       move.b    (A0),D0
       bne.s     findVariable_104
findVariable_106:
; break;
       bra.s     findVariable_67
findVariable_104:
       bra       findVariable_65
findVariable_67:
; }
; return 0;
       clr.l     D0
findVariable_7:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Cria a Variavel NO ENDEREÇO DEFINIDO POR nextAddrSimpVar OU nextAddrArrayVar,
; // DE ACORDO COM O TIPO E NOME INFORMADOS
; //-----------------------------------------------------------------------------
; char createVariable(unsigned char* pVariable, unsigned char* pValor, char pType)
; {
       xdef      _createVariable
_createVariable:
       link      A6,#-40
       movem.l   D2/D3/D4/A2,-(A7)
       move.l    8(A6),D3
       lea       _nextAddrSimpVar.L,A2
; char vRet = 0;
       clr.b     D4
; long vTemp = 0;
       clr.l     -38(A6)
; char vBuffer [sizeof(long)*8+1];
; unsigned char* vNextSimpVar;
; char vLenVar = 0;
       clr.b     -1(A6)
; vTemp = *nextAddrSimpVar;
       move.l    (A2),A0
       move.l    (A0),-38(A6)
; vNextSimpVar = *nextAddrSimpVar;
       move.l    (A2),A0
       move.l    (A0),D2
; vLenVar = strlen(pVariable);
       move.l    D3,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.b    D0,-1(A6)
; *vNextSimpVar++ = pType;
       move.l    D2,A0
       addq.l    #1,D2
       move.b    19(A6),(A0)
; *vNextSimpVar++ = pVariable[0];
       move.l    D3,A0
       move.l    D2,A1
       addq.l    #1,D2
       move.b    (A0),(A1)
; *vNextSimpVar++ = pVariable[1];
       move.l    D3,A0
       move.l    D2,A1
       addq.l    #1,D2
       move.b    1(A0),(A1)
; vRet = updateVariable(vNextSimpVar, pValor, pType, 0);
       clr.l     -(A7)
       move.b    19(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    12(A6),-(A7)
       move.l    D2,-(A7)
       jsr       _updateVariable
       add.w     #16,A7
       move.b    D0,D4
; *nextAddrSimpVar += 8;
       move.l    (A2),A0
       addq.l    #8,(A0)
; return vRet;
       move.b    D4,D0
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Atualiza o valor da Variavel no ENDEREÇO DEFINIDO POR nextAddrSimpVar OU nextAddrArrayVar,
; // DE ACORDO COM O TIPO E NOME INFORMADOS
; //-----------------------------------------------------------------------------
; char updateVariable(unsigned long* pVariable, unsigned char* pValor, char pType, char pOper)
; {
       xdef      _updateVariable
_updateVariable:
       link      A6,#-36
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3,-(A7)
       move.l    12(A6),D4
       lea       _nextAddrString.L,A3
; long vNumVal = 0;
       clr.l     D6
; int ix, iz = 0;
       clr.l     D5
; char vBuffer [sizeof(long)*8+1];
; unsigned char* vNextSimpVar;
; unsigned char* vNextString;
; char pNewStr = 0;
       clr.b     -1(A6)
; unsigned long vOffSet;
; //    unsigned char* sqtdtam[20];
; vNextSimpVar = pVariable;
       move.l    8(A6),D2
; *atuVarAddr = pVariable;
       move.l    _atuVarAddr.L,A0
       move.l    8(A6),(A0)
; /*writeLongSerial("Aqui 333.666.0-[");
; itoa(pVariable,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(pValor,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(pType,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (pType == '#' || pType == '%')   // Real ou Inteiro
       move.b    19(A6),D0
       cmp.b     #35,D0
       beq.s     updateVariable_3
       move.b    19(A6),D0
       cmp.b     #37,D0
       bne       updateVariable_1
updateVariable_3:
; {
; if (vNextSimpVar < pStartArrayVar)
       cmp.l     _pStartArrayVar.L,D2
       bhs.s     updateVariable_4
; *vNextSimpVar++ = 0x00;
       move.l    D2,A0
       addq.l    #1,D2
       clr.b     (A0)
updateVariable_4:
; *vNextSimpVar++ = pValor[0];
       move.l    D4,A0
       move.l    D2,A1
       addq.l    #1,D2
       move.b    (A0),(A1)
; *vNextSimpVar++ = pValor[1];
       move.l    D4,A0
       move.l    D2,A1
       addq.l    #1,D2
       move.b    1(A0),(A1)
; *vNextSimpVar++ = pValor[2];
       move.l    D4,A0
       move.l    D2,A1
       addq.l    #1,D2
       move.b    2(A0),(A1)
; *vNextSimpVar++ = pValor[3];
       move.l    D4,A0
       move.l    D2,A1
       addq.l    #1,D2
       move.b    3(A0),(A1)
       bra       updateVariable_2
updateVariable_1:
; }
; else // String
; {
; iz = strlen(pValor);    // Tamanho da strings
       move.l    D4,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D5
; /*writeLongSerial("Aqui 333.666.1-[");
; itoa(*vNextSimpVar,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(iz,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(pOper,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; // Se for o mesmo tamanho ou menor, usa a mesma posicao
; if (*vNextSimpVar <= iz && pOper)
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       cmp.l     D5,D0
       bhi       updateVariable_6
       move.b    23(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       updateVariable_6
; {
; vOffSet  = (((unsigned long)*(vNextSimpVar + 1) << 24) & 0xFF000000);
       move.l    D2,A0
       move.b    1(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,D7
; vOffSet |= (((unsigned long)*(vNextSimpVar + 2) << 16) & 0x00FF0000);
       move.l    D2,A0
       move.b    2(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,D7
; vOffSet |= (((unsigned long)*(vNextSimpVar + 3) << 8) & 0x0000FF00);
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,D7
; vOffSet |= ((unsigned long)*(vNextSimpVar + 4) & 0x000000FF);
       move.l    D2,A0
       move.b    4(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,D7
; vNextString = vOffSet;
       move.l    D7,D3
; if (pOper == 2 && vNextString == 0)
       move.b    23(A6),D0
       cmp.b     #2,D0
       bne.s     updateVariable_8
       tst.l     D3
       bne.s     updateVariable_8
; {
; vNextString = *nextAddrString;
       move.l    (A3),A0
       move.l    (A0),D3
; pNewStr = 1;
       move.b    #1,-1(A6)
updateVariable_8:
       bra.s     updateVariable_7
updateVariable_6:
; }
; }
; else
; vNextString = *nextAddrString;
       move.l    (A3),A0
       move.l    (A0),D3
updateVariable_7:
; vNumVal = vNextString;
       move.l    D3,D6
; /*writeLongSerial("Aqui 333.666.2-[");
; itoa(nextAddrString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vNextString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vNumVal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; for (ix = 0; ix < iz; ix++)
       move.w    #0,A2
updateVariable_10:
       move.l    A2,D0
       cmp.l     D5,D0
       bge.s     updateVariable_12
; {
; *vNextString++ = pValor[ix];
       move.l    D4,A0
       move.l    D3,A1
       addq.l    #1,D3
       move.b    0(A0,A2.L),(A1)
       addq.w    #1,A2
       bra       updateVariable_10
updateVariable_12:
; }
; /*writeLongSerial("Aqui 333.666.3-[");
; itoa(nextAddrString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vNextString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vNumVal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (*vNextSimpVar > iz || !pOper || pNewStr)
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       cmp.l     D5,D0
       bhi.s     updateVariable_15
       tst.b     23(A6)
       bne.s     updateVariable_16
       moveq     #1,D0
       bra.s     updateVariable_17
updateVariable_16:
       clr.l     D0
updateVariable_17:
       ext.w     D0
       ext.l     D0
       tst.l     D0
       bne.s     updateVariable_15
       move.b    -1(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq.s     updateVariable_13
updateVariable_15:
; *nextAddrString = vNextString;
       move.l    (A3),A0
       move.l    D3,(A0)
updateVariable_13:
; /*writeLongSerial("Aqui 333.666.4-[");
; itoa(vNextString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vNumVal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; *vNextSimpVar++ = iz;
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D5,(A0)
; /*writeLongSerial("Aqui 333.666.5-[");
; itoa(vNextString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; *vNextSimpVar++ = ((vNumVal & 0xFF000000) >>24);
       move.l    D6,D0
       and.l     #-16777216,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D0,(A0)
; *vNextSimpVar++ = ((vNumVal & 0x00FF0000) >>16);
       move.l    D6,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D0,(A0)
; *vNextSimpVar++ = ((vNumVal & 0x0000FF00) >>8);
       move.l    D6,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D0,(A0)
; *vNextSimpVar++ = (vNumVal & 0x000000FF);
       move.l    D6,D0
       and.l     #255,D0
       move.l    D2,A0
       addq.l    #1,D2
       move.b    D0,(A0)
updateVariable_2:
; /*writeLongSerial("Aqui 333.666.6-[");
; itoa(vNextString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; }
; /*    *(vNextSimpVar + 1) = 0x00;
; *(vNextSimpVar + 2) = 0x00;
; *(vNextSimpVar + 3) = 0x00;
; *(vNextSimpVar + 4) = 0x00;*/
; return 0;
       clr.b     D0
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Cria a Variavel Array NO ENDEREÇO DEFINIDO POR nextAddrArrayVar, DE ACORDO COM O TIPO,
; // NOME E DIMENSÕES INFORMADOS
; //--------------------------------------------------------------------------------------
; char createVariableArray(unsigned char* pVariable, char pType, unsigned int pNumDim, unsigned int *pDim)
; {
       xdef      _createVariableArray
_createVariableArray:
       link      A6,#-44
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7)
       move.l    20(A6),D5
       move.l    16(A6),D6
       lea       _nextAddrArrayVar.L,A3
       move.l    8(A6),A4
; char vRet = 0;
       clr.b     -43(A6)
; long vTemp = 0;
       clr.l     -42(A6)
; unsigned char* vTempC = &vTemp;
       lea       -42(A6),A0
       move.l    A0,A2
; char vBuffer [sizeof(long)*8+1];
; unsigned char* vNextArrayVar;
; char vLenVar = 0;
       clr.b     -5(A6)
; int ix, vTam;
; long vAreaFree = (pStartString - *nextAddrArrayVar);
       move.l    _pStartString.L,D0
       move.l    (A3),A0
       sub.l     (A0),D0
       move.l    D0,-4(A6)
; long vSizeTotal = 0;
       moveq     #0,D7
; //    unsigned char sqtdtam[20];
; vTemp = *nextAddrArrayVar;
       move.l    (A3),A0
       move.l    (A0),-42(A6)
; vNextArrayVar = *nextAddrArrayVar;
       move.l    (A3),A0
       move.l    (A0),D3
; vLenVar = strlen(pVariable);
       move.l    A4,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.b    D0,-5(A6)
; *vNextArrayVar++ = pType;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    15(A6),(A0)
; *vNextArrayVar++ = pVariable[0];
       move.l    D3,A0
       addq.l    #1,D3
       move.b    (A4),(A0)
; *vNextArrayVar++ = pVariable[1];
       move.l    D3,A0
       addq.l    #1,D3
       move.b    1(A4),(A0)
; vTam = 0;
       clr.l     D4
; for (ix = 0; ix < pNumDim; ix++)
       clr.l     D2
createVariableArray_1:
       cmp.l     D6,D2
       bhs       createVariableArray_3
; {
; // Somando mais 1, porque 0 = 1 em quantidade e e em posicao (igual ao c)
; pDim[ix] = pDim[ix] /*+ 1*/ ;
       move.l    D5,A0
       move.l    D2,D0
       lsl.l     #2,D0
       move.l    D5,A1
       move.l    D2,D1
       lsl.l     #2,D1
       move.l    0(A0,D0.L),0(A1,D1.L)
; // Definir o tamanho do campo de dados do array
; if (vTam == 0)
       tst.l     D4
       bne.s     createVariableArray_4
; vTam = pDim[ix] /*- 1*/ ;
       move.l    D5,A0
       move.l    D2,D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),D4
       bra.s     createVariableArray_5
createVariableArray_4:
; else
; vTam = vTam * (pDim[ix] /*- 1*/ );
       move.l    D5,A0
       move.l    D2,D0
       lsl.l     #2,D0
       move.l    D4,-(A7)
       move.l    0(A0,D0.L),-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D4
createVariableArray_5:
       addq.l    #1,D2
       bra       createVariableArray_1
createVariableArray_3:
; /*writeLongSerial("Aqui 333.666.0-[");
; itoa(vTam,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(ix,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(pDim[ix],sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; }
; /*writeLongSerial("Aqui 333.666.1-[");
; itoa(vTam,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(pNumDim,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (pType == '$')
       move.b    15(A6),D0
       cmp.b     #36,D0
       bne.s     createVariableArray_6
; vTam = vTam * 5;
       move.l    D4,-(A7)
       pea       5
       jsr       LMUL
       move.l    (A7),D4
       addq.w    #8,A7
       bra.s     createVariableArray_7
createVariableArray_6:
; else
; vTam = vTam * 4;
       move.l    D4,-(A7)
       pea       4
       jsr       LMUL
       move.l    (A7),D4
       addq.w    #8,A7
createVariableArray_7:
; /*writeLongSerial("Aqui 333.666.2-[");
; itoa(pType,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vTam,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; vSizeTotal = vTam + 8;
       move.l    D4,D0
       addq.l    #8,D0
       move.l    D0,D7
; vSizeTotal = vSizeTotal + (pNumDim *2);
       move.l    D7,D0
       move.l    D6,-(A7)
       pea       2
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,D7
; /*writeLongSerial("Aqui 333.666.3-[");
; itoa(pStartString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*nextAddrArrayVar,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vAreaFree,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vSizeTotal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (vSizeTotal > vAreaFree)
       cmp.l     -4(A6),D7
       ble.s     createVariableArray_8
; {
; *vErroProc = 22;
       move.l    _vErroProc.L,A0
       move.w    #22,(A0)
; return 0;
       clr.b     D0
       bra       createVariableArray_10
createVariableArray_8:
; }
; // Coloca setup do array
; vTemp = vTemp + vTam + 8 + (pNumDim * 2);
       move.l    -42(A6),D0
       add.l     D4,D0
       addq.l    #8,D0
       move.l    D6,-(A7)
       pea       2
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,-42(A6)
; *vNextArrayVar++ = vTempC[0];
       move.l    D3,A0
       addq.l    #1,D3
       move.b    (A2),(A0)
; *vNextArrayVar++ = vTempC[1];
       move.l    D3,A0
       addq.l    #1,D3
       move.b    1(A2),(A0)
; *vNextArrayVar++ = vTempC[2];
       move.l    D3,A0
       addq.l    #1,D3
       move.b    2(A2),(A0)
; *vNextArrayVar++ = vTempC[3];
       move.l    D3,A0
       addq.l    #1,D3
       move.b    3(A2),(A0)
; *vNextArrayVar++ = pNumDim;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    D6,(A0)
; for (ix = 0; ix < pNumDim; ix++)
       clr.l     D2
createVariableArray_11:
       cmp.l     D6,D2
       bhs       createVariableArray_13
; {
; *vNextArrayVar++ = (pDim[ix] >> 8);
       move.l    D5,A0
       move.l    D2,D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),D0
       lsr.l     #8,D0
       move.l    D3,A0
       addq.l    #1,D3
       move.b    D0,(A0)
; *vNextArrayVar++ = (pDim[ix] & 0xFF);
       move.l    D5,A0
       move.l    D2,D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    D3,A0
       addq.l    #1,D3
       move.b    D0,(A0)
       addq.l    #1,D2
       bra       createVariableArray_11
createVariableArray_13:
; }
; // Limpa area de dados (zera)
; for (ix = 0; ix < vTam; ix++)
       clr.l     D2
createVariableArray_14:
       cmp.l     D4,D2
       bge.s     createVariableArray_16
; *(vNextArrayVar + ix) = 0x00;
       move.l    D3,A0
       clr.b     0(A0,D2.L)
       addq.l    #1,D2
       bra       createVariableArray_14
createVariableArray_16:
; *nextAddrArrayVar = vTemp;
       move.l    (A3),A0
       move.l    -42(A6),(A0)
; return 0;
       clr.b     D0
createVariableArray_10:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
       unlk      A6
       rts
; }
; /*****************************************************************************/
; /* FUNCOES BASIC                                                             */
; /*****************************************************************************/
; //-----------------------------------------------------------------------------
; // Joga pra tela Texto.
; // Syntaxe:
; //      Print "<Texto>"/<value>[, "<Texto>"/<value>][; "<Texto>"/<value>]
; //-----------------------------------------------------------------------------
; int basPrint(void)
; {
       xdef      _basPrint
_basPrint:
       link      A6,#-516
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _token.L,A2
       lea       _tok.L,A3
       lea       _vErroProc.L,A4
       lea       -224(A6),A5
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -514(A6)
       clr.b     -513(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -244(A6)
       clr.l     -240(A6)
       clr.l     -236(A6)
       clr.l     -232(A6)
; unsigned char answer[200];
; long *lVal = answer;
       move.l    A5,-24(A6)
; int  *iVal = answer;
       move.l    A5,-20(A6)
; int len=0, spaces;
       clr.l     -16(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; do {
basPrint_1:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basPrint_3
       clr.l     D0
       bra       basPrint_5
basPrint_3:
; if (*tok == EOL || *tok == FINISHED)
       move.l    (A3),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPrint_8
       move.l    (A3),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basPrint_6
basPrint_8:
; break;
       bra       basPrint_2
basPrint_6:
; if (*token_type == QUOTE) { // is string
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPrint_9
; printText(token);
       move.l    (A2),-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basPrint_11
       clr.l     D0
       bra       basPrint_5
basPrint_11:
       bra       basPrint_23
basPrint_9:
; }
; else if (*token!=':') { // is expression
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq       basPrint_23
; last_token_type = *token_type;
       move.l    _token_type.L,A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A5,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basPrint_15
       clr.l     D0
       bra       basPrint_5
basPrint_15:
; if (*value_type != '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq       basPrint_20
; {
; if (*value_type == '#')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basPrint_19
; {
; // Real
; fppTofloatString(*lVal, answer);
       move.l    A5,-(A7)
       move.l    -24(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppTofloatString
       addq.w    #8,A7
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basPrint_21
       clr.l     D0
       bra       basPrint_5
basPrint_21:
       bra.s     basPrint_20
basPrint_19:
; }
; else
; {
; // Inteiro
; itoa(*iVal, answer, 10);
       pea       10
       move.l    A5,-(A7)
       move.l    -20(A6),A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
basPrint_20:
; }
; }
; printText(answer);
       move.l    A5,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basPrint_23
       clr.l     D0
       bra       basPrint_5
basPrint_23:
; }
; last_delim = *token;
       move.l    (A2),A0
       move.b    (A0),D3
; if (*token==',') {
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basPrint_25
; // compute number of spaces to move to next tab
; spaces = 8 - (len % 8);
       moveq     #8,D0
       ext.w     D0
       ext.l     D0
       move.l    -16(A6),-(A7)
       pea       8
       jsr       LDIV
       move.l    4(A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,D2
; while(spaces) {
basPrint_27:
       tst.l     D2
       beq.s     basPrint_29
; printChar(' ',1);
       pea       1
       pea       32
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; spaces--;
       subq.l    #1,D2
       bra       basPrint_27
basPrint_29:
       bra       basPrint_35
basPrint_25:
; }
; }
; else if (*token==';' || *token=='+')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq.s     basPrint_32
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #43,D0
       bne.s     basPrint_30
basPrint_32:
       bra       basPrint_35
basPrint_30:
; /* do nothing */;
; else if (*token==':')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     basPrint_33
; {
; *pointerRunProg = *pointerRunProg - 1;
       move.l    _pointerRunProg.L,A0
       subq.l    #1,(A0)
       bra       basPrint_35
basPrint_33:
; }
; else if (*tok!=EOL && *tok!=FINISHED && *token!=':')
       move.l    (A3),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPrint_35
       move.l    (A3),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basPrint_35
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq.s     basPrint_35
; {
; *vErroProc = 14;
       move.l    (A4),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basPrint_5
basPrint_35:
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq       basPrint_1
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq       basPrint_1
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #43,D0
       beq       basPrint_1
basPrint_2:
; }
; } while (*token==';' || *token==',' || *token=='+');
; if (*tok == EOL || *tok == FINISHED || *token==':') {
       move.l    (A3),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPrint_39
       move.l    (A3),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basPrint_39
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     basPrint_40
basPrint_39:
; if (last_delim != ';' && last_delim!=',')
       cmp.b     #59,D3
       beq.s     basPrint_40
       cmp.b     #44,D3
       beq.s     basPrint_40
; printText("\r\n");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
basPrint_40:
; }
; return 0;
       clr.l     D0
basPrint_5:
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Devolve o caracter ligado ao codigo ascii passado
; // Syntaxe:
; //      CHR$(<codigo ascii>)
; //-----------------------------------------------------------------------------
; int basChr(void)
; {
       xdef      _basChr
_basChr:
       link      A6,#-324
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       _token_type.L,A4
       lea       _token.L,A5
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -324(A6)
       clr.b     -323(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -54(A6)
       clr.l     -50(A6)
       clr.l     -46(A6)
       clr.l     -42(A6)
; unsigned char answer[10];
; long *lVal = answer;
       lea       -34(A6),A0
       move.l    A0,-24(A6)
; int  *iVal = answer;
       lea       -34(A6),A0
       move.l    A0,D2
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basChr_1
       clr.l     D0
       bra       basChr_3
basChr_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basChr_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basChr_6
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basChr_4
basChr_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basChr_7
       clr.l     D0
       bra       basChr_3
basChr_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basChr_9
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_9:
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    (A4),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -34(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basChr_11
       clr.l     D0
       bra       basChr_3
basChr_11:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basChr_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_13:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basChr_15
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basChr_15:
; }
; // Inteiro
; if (*iVal<0 || *iVal>255)
       move.l    D2,A0
       move.l    (A0),D0
       cmp.l     #0,D0
       blt.s     basChr_19
       move.l    D2,A0
       move.l    (A0),D0
       cmp.l     #255,D0
       ble.s     basChr_17
basChr_19:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_17:
; }
; }
; last_delim = *token;
       move.l    (A5),A0
       move.b    (A0),-12(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basChr_20
       clr.l     D0
       bra       basChr_3
basChr_20:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basChr_22
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra.s     basChr_3
basChr_22:
; }
; *token=(char)*iVal;
       move.l    D2,A0
       move.l    (A0),D0
       move.l    (A5),A0
       move.b    D0,(A0)
; *(token + 1)=0x00;
       move.l    (A5),A0
       clr.b     1(A0)
; *value_type='$';
       move.l    (A3),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basChr_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Devolve o numerico da string
; // Syntaxe:
; //      VAL(<string>)
; //-----------------------------------------------------------------------------
; int basVal(void)
; {
       xdef      _basVal
_basVal:
       link      A6,#-336
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       -44(A6),A4
       lea       _token_type.L,A5
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -334(A6)
       clr.b     -333(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -64(A6)
       clr.l     -60(A6)
       clr.l     -56(A6)
       clr.l     -52(A6)
; unsigned char answer[20];
; int  iVal = answer;
       move.l    A4,D2
; int vValue = 0;
       clr.l     -24(A6)
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_value_type=' ', last_token_type = 0;
       moveq     #32,D3
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basVal_1
       clr.l     D0
       bra       basVal_3
basVal_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basVal_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basVal_6
       move.l    (A5),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basVal_4
basVal_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basVal_3
basVal_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basVal_7
       clr.l     D0
       bra       basVal_3
basVal_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A5),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne       basVal_9
; if (strchr(token,'.'))  // verifica se eh numero inteiro ou real
       pea       46
       move.l    (A3),-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq.s     basVal_11
; {
; last_value_type='#'; // Real
       moveq     #35,D3
; iVal=floatStringToFpp(token);
       move.l    (A3),-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,D2
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basVal_13
       clr.l     D0
       bra       basVal_3
basVal_13:
       bra.s     basVal_12
basVal_11:
; }
; else
; {
; last_value_type='%'; // Inteiro
       moveq     #37,D3
; iVal=atoi(token);
       move.l    (A3),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,D2
basVal_12:
       bra       basVal_20
basVal_9:
; }
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    (A5),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A4,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basVal_15
       clr.l     D0
       bra       basVal_3
basVal_15:
; if (*value_type != '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basVal_17
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basVal_3
basVal_17:
; }
; if (strchr(answer,'.'))  // verifica se eh numero inteiro ou real
       pea       46
       move.l    A4,-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq.s     basVal_19
; {
; last_value_type='#'; // Real
       moveq     #35,D3
; iVal=floatStringToFpp(answer);
       move.l    A4,-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,D2
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basVal_21
       clr.l     D0
       bra       basVal_3
basVal_21:
       bra.s     basVal_20
basVal_19:
; }
; else
; {
; last_value_type='%'; // Inteiro
       moveq     #37,D3
; iVal=atoi(answer);
       move.l    A4,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,D2
basVal_20:
; }
; }
; last_delim = *token;
       move.l    (A3),A0
       move.b    (A0),-12(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basVal_23
       clr.l     D0
       bra       basVal_3
basVal_23:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A5),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basVal_25
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basVal_3
basVal_25:
; }
; *token=((int)(iVal & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,2(A0)
; *(token + 3)=(iVal & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A3),A0
       move.b    D0,3(A0)
; *value_type = last_value_type;
       move.l    _value_type.L,A0
       move.b    D3,(A0)
; return 0;
       clr.l     D0
basVal_3:
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Devolve a string do numero
; // Syntaxe:
; //      STR$(<Numero>)
; //-----------------------------------------------------------------------------
; int basStr(void)
; {
       xdef      _basStr
_basStr:
       link      A6,#-364
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token_type.L,A3
       lea       _token.L,A4
       lea       _value_type.L,A5
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -364(A6)
       clr.b     -363(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -94(A6)
       clr.l     -90(A6)
       clr.l     -86(A6)
       clr.l     -82(A6)
; unsigned char answer[50];
; long *lVal = answer;
       lea       -74(A6),A0
       move.l    A0,-24(A6)
; int  *iVal = answer;
       lea       -74(A6),A0
       move.l    A0,D2
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basStr_1
       clr.l     D0
       bra       basStr_3
basStr_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basStr_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basStr_6
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basStr_4
basStr_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basStr_7
       clr.l     D0
       bra       basStr_3
basStr_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basStr_9
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_9:
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    (A3),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -74(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basStr_11
       clr.l     D0
       bra       basStr_3
basStr_11:
; if (*value_type == '$')
       move.l    (A5),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basStr_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_13:
; }
; }
; last_delim = *token;
       move.l    (A4),A0
       move.b    (A0),-12(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basStr_15
       clr.l     D0
       bra       basStr_3
basStr_15:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basStr_17
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_17:
; }
; if (*value_type=='#')    // real
       move.l    (A5),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basStr_19
; {
; fppTofloatString(*iVal,token);
       move.l    (A4),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppTofloatString
       addq.w    #8,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basStr_21
       clr.l     D0
       bra.s     basStr_3
basStr_21:
       bra.s     basStr_20
basStr_19:
; }
; else    // Inteiro
; {
; itoa(*iVal,token,10);
       pea       10
       move.l    (A4),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
basStr_20:
; }
; *value_type='$';
       move.l    (A5),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basStr_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Devolve o tamanho da string
; // Syntaxe:
; //      LEN(<string>)
; //-----------------------------------------------------------------------------
; int basLen(void)
; {
       xdef      _basLen
_basLen:
       link      A6,#-516
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       _token_type.L,A4
       lea       _nextToken.L,A5
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -514(A6)
       clr.b     -513(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -244(A6)
       clr.l     -240(A6)
       clr.l     -236(A6)
       clr.l     -232(A6)
; unsigned char answer[200];
; int iVal = 0;
       clr.l     D2
; int vValue = 0;
       clr.l     -24(A6)
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLen_1
       clr.l     D0
       bra       basLen_3
basLen_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basLen_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basLen_6
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basLen_4
basLen_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLen_3
basLen_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLen_7
       clr.l     D0
       bra       basLen_3
basLen_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLen_9
; iVal=strlen(token);
       move.l    (A3),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D2
       bra       basLen_10
basLen_9:
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    (A4),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -224(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLen_11
       clr.l     D0
       bra       basLen_3
basLen_11:
; if (*value_type != '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basLen_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLen_3
basLen_13:
; }
; iVal=strlen(answer);
       pea       -224(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D2
basLen_10:
; }
; last_delim = *token;
       move.l    (A3),A0
       move.b    (A0),-12(A6)
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLen_15
       clr.l     D0
       bra       basLen_3
basLen_15:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basLen_17
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLen_3
basLen_17:
; }
; *token=((int)(iVal & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,2(A0)
; *(token + 3)=(iVal & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A3),A0
       move.b    D0,3(A0)
; *value_type='%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basLen_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Devolve qtd memoria usuario disponivel
; // Syntaxe:
; //      FRE(0)
; //-----------------------------------------------------------------------------
; int basFre(void)
; {
       xdef      _basFre
_basFre:
       link      A6,#-404
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       _token_type.L,A4
       lea       _nextToken.L,A5
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -402(A6)
       clr.b     -401(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -132(A6)
       clr.l     -128(A6)
       clr.l     -124(A6)
       clr.l     -120(A6)
; unsigned char answer[50];
; long *lVal = answer;
       lea       -112(A6),A0
       move.l    A0,-62(A6)
; int  *iVal = answer;
       lea       -112(A6),A0
       move.l    A0,-58(A6)
; long vTotal = 0;
       clr.l     D2
; char vBuffer [sizeof(long)*8+1];
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim;
; unsigned char sqtdtam[10];
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basFre_1
       clr.l     D0
       bra       basFre_3
basFre_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basFre_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basFre_6
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basFre_4
basFre_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basFre_3
basFre_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basFre_7
       clr.l     D0
       bra       basFre_3
basFre_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basFre_9
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basFre_3
basFre_9:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -112(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basFre_11
       clr.l     D0
       bra       basFre_3
basFre_11:
; if (*iVal!=0)
       move.l    -58(A6),A0
       move.l    (A0),D0
       beq.s     basFre_13
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basFre_3
basFre_13:
; }
; }
; last_delim = *token;
       move.l    (A3),A0
       move.b    (A0),-11(A6)
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basFre_15
       clr.l     D0
       bra       basFre_3
basFre_15:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basFre_17
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basFre_3
basFre_17:
; }
; // Calcula Quantidade de Memoria e printa na tela
; vTotal = (pStartArrayVar - pStartSimpVar) + (pStartString - pStartArrayVar);
       move.l    _pStartArrayVar.L,D0
       sub.l     _pStartSimpVar.L,D0
       move.l    _pStartString.L,D1
       sub.l     _pStartArrayVar.L,D1
       add.l     D1,D0
       move.l    D0,D2
; /*    printText("Memory Free for: \r\n\0");
; ltoa(vTotal, vBuffer, 10);
; printText("     Variables: \0");
; printText(vBuffer);
; printText("Bytes\r\n\0");
; vTotal = pStartProg - *nextAddrArrayVar;
; ltoa(vTotal, vBuffer, 10);
; printText("        Arrays: \0");
; printText(vBuffer);
; printText("Bytes\r\n\0");
; vTotal = pStartXBasLoad - *nextAddrLine;
; ltoa(vTotal, vBuffer, 10);
; printText("       Program: \0");
; printText(vBuffer);
; printText("Bytes\r\n\0");*/
; *token=((int)(vTotal & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vTotal & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vTotal & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,2(A0)
; *(token + 3)=(vTotal & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A3),A0
       move.b    D0,3(A0)
; *value_type='%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basFre_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; int basTrig(unsigned char pFunc)
; {
       xdef      _basTrig
_basTrig:
       link      A6,#-4
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       _value_type.L,A4
       lea       _nextToken.L,A5
; unsigned long vReal = 0, vResult = 0;
       clr.l     -4(A6)
       clr.l     D2
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basTrig_1
       clr.l     D0
       bra       basTrig_3
basTrig_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basTrig_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basTrig_6
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basTrig_4
basTrig_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basTrig_3
basTrig_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basTrig_7
       clr.l     D0
       bra       basTrig_3
basTrig_7:
; putback();
       jsr       _putback
; getExp(&vReal); //
       pea       -4(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basTrig_9
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basTrig_3
basTrig_9:
; }
; else if (*value_type != '#')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       beq.s     basTrig_11
; {
; *value_type='#'; // Real
       move.l    (A4),A0
       move.b    #35,(A0)
; vReal=fppReal(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D0,-4(A6)
basTrig_11:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basTrig_13
       clr.l     D0
       bra       basTrig_3
basTrig_13:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basTrig_15
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basTrig_3
basTrig_15:
; }
; switch (pFunc)
       move.b    11(A6),D0
       and.l     #255,D0
       subq.l    #1,D0
       blo       basTrig_17
       cmp.l     #6,D0
       bhs       basTrig_17
       asl.l     #1,D0
       move.w    basTrig_19(PC,D0.L),D0
       jmp       basTrig_19(PC,D0.W)
basTrig_19:
       dc.w      basTrig_20-basTrig_19
       dc.w      basTrig_21-basTrig_19
       dc.w      basTrig_22-basTrig_19
       dc.w      basTrig_23-basTrig_19
       dc.w      basTrig_24-basTrig_19
       dc.w      basTrig_25-basTrig_19
basTrig_20:
; {
; case 1: // sin
; vResult = fppSin(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppSin
       addq.w    #4,A7
       move.l    D0,D2
; break;
       bra       basTrig_18
basTrig_21:
; case 2: // cos
; vResult = fppCos(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppCos
       addq.w    #4,A7
       move.l    D0,D2
; break;
       bra       basTrig_18
basTrig_22:
; case 3: // tan
; vResult = fppTan(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppTan
       addq.w    #4,A7
       move.l    D0,D2
; break;
       bra       basTrig_18
basTrig_23:
; case 4: // log (ln)
; vResult = fppLn(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppLn
       addq.w    #4,A7
       move.l    D0,D2
; break;
       bra.s     basTrig_18
basTrig_24:
; case 5: // exp
; vResult = fppExp(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppExp
       addq.w    #4,A7
       move.l    D0,D2
; break;
       bra.s     basTrig_18
basTrig_25:
; case 6: // sqrt
; vResult = fppSqrt(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppSqrt
       addq.w    #4,A7
       move.l    D0,D2
; break;
       bra.s     basTrig_18
basTrig_17:
; default:
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basTrig_3
basTrig_18:
; }
; *token=((int)(vResult & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,2(A0)
; *(token + 3)=(vResult & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A3),A0
       move.b    D0,3(A0)
; *value_type = '#';
       move.l    (A4),A0
       move.b    #35,(A0)
; return 0;
       clr.l     D0
basTrig_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; int basAsc(void)
; {
       xdef      _basAsc
_basAsc:
       link      A6,#-24
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       _token_type.L,A4
       lea       _nextToken.L,A5
; unsigned char answer[20];
; int  iVal = answer;
       lea       -22(A6),A0
       move.l    A0,D2
; char last_delim;
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basAsc_1
       clr.l     D0
       bra       basAsc_3
basAsc_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basAsc_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basAsc_6
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basAsc_4
basAsc_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basAsc_7
       clr.l     D0
       bra       basAsc_3
basAsc_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basAsc_9
; if (strlen(token)>1)
       move.l    (A3),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #1,D0
       ble.s     basAsc_11
; {
; *vErroProc = 6;
       move.l    (A2),A0
       move.w    #6,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_11:
; }
; iVal = *token;
       move.l    (A3),A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,D2
       bra       basAsc_10
basAsc_9:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -22(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basAsc_13
       clr.l     D0
       bra       basAsc_3
basAsc_13:
; if (*value_type != '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basAsc_15
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_15:
; }
; iVal = *answer;
       move.b    -22(A6),D0
       and.l     #255,D0
       move.l    D0,D2
basAsc_10:
; }
; last_delim = *token;
       move.l    (A3),A0
       move.b    (A0),-1(A6)
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basAsc_17
       clr.l     D0
       bra       basAsc_3
basAsc_17:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basAsc_19
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_19:
; }
; *token=((int)(iVal & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,2(A0)
; *(token + 3)=(iVal & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A3),A0
       move.b    D0,3(A0)
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basAsc_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; int basLeftRightMid(char pTipo)
; {
       xdef      _basLeftRightMid
_basLeftRightMid:
       link      A6,#-424
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       -218(A6),A3
       lea       _token.L,A4
       lea       _strlen.L,A5
       move.b    11(A6),D5
       ext.w     D5
       ext.l     D5
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     D2
       clr.l     D4
       clr.l     D6
       clr.l     D3
; unsigned char answer[200], vTemp[200];
; int vqtd = 0, vstart = 0;
       clr.l     -18(A6)
       clr.l     -14(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_1
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basLeftRightMid_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basLeftRightMid_6
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basLeftRightMid_4
basLeftRightMid_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_7
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLeftRightMid_9
; strcpy(vTemp, token);
       move.l    (A4),-(A7)
       move.l    A3,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra       basLeftRightMid_10
basLeftRightMid_9:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -418(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_11
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_11:
; if (*value_type != '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basLeftRightMid_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_13:
; }
; strcpy(vTemp, answer);
       pea       -418(A6)
       move.l    A3,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
basLeftRightMid_10:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_15
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_15:
; // Deve ser uma virgula para Receber a qtd, e se for mid = a posiao incial
; if (*token!=',')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basLeftRightMid_17
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_17:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_19
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_19:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLeftRightMid_21
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_21:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; if (pTipo=='M')
       cmp.b     #77,D5
       bne.s     basLeftRightMid_23
; {
; getExp(&vstart);
       pea       -14(A6)
       jsr       _getExp
       addq.w    #4,A7
; vqtd=strlen(vTemp);
       move.l    A3,-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    D0,-18(A6)
       bra.s     basLeftRightMid_24
basLeftRightMid_23:
; }
; else
; getExp(&vqtd);
       pea       -18(A6)
       jsr       _getExp
       addq.w    #4,A7
basLeftRightMid_24:
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_25
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_25:
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLeftRightMid_27
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_27:
; }
; }
; if (pTipo == 'M')
       cmp.b     #77,D5
       bne       basLeftRightMid_39
; {
; // Deve ser uma virgula para Receber a qtd
; if (*token==',')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basLeftRightMid_39
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_33
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_33:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLeftRightMid_35
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_35:
; }
; else { /* is expression */
; //putback();
; getExp(&vqtd);
       pea       -18(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_37
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_37:
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLeftRightMid_39
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_39:
; }
; }
; }
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_41
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_41:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basLeftRightMid_43
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_43:
; }
; if (vqtd > strlen(vTemp))
       move.l    A3,-(A7)
       jsr       (A5)
       addq.w    #4,A7
       cmp.l     -18(A6),D0
       bge.s     basLeftRightMid_48
; {
; if (pTipo=='M')
       cmp.b     #77,D5
       bne.s     basLeftRightMid_47
; vqtd = (strlen(vTemp) - vstart) + 1;
       move.l    A3,-(A7)
       jsr       (A5)
       addq.w    #4,A7
       sub.l     -14(A6),D0
       addq.l    #1,D0
       move.l    D0,-18(A6)
       bra.s     basLeftRightMid_48
basLeftRightMid_47:
; else
; vqtd = strlen(vTemp);
       move.l    A3,-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    D0,-18(A6)
basLeftRightMid_48:
; }
; if (pTipo == 'L') // Left$
       cmp.b     #76,D5
       bne.s     basLeftRightMid_49
; {
; for (ix = 0; ix < vqtd; ix++)
       clr.l     D2
basLeftRightMid_51:
       cmp.l     -18(A6),D2
       bge.s     basLeftRightMid_53
; *(token + ix) = vTemp[ix];
       move.l    (A4),A0
       move.b    0(A3,D2.L),0(A0,D2.L)
       addq.l    #1,D2
       bra       basLeftRightMid_51
basLeftRightMid_53:
; *(token + ix) = 0x00;
       move.l    (A4),A0
       clr.b     0(A0,D2.L)
       bra       basLeftRightMid_55
basLeftRightMid_49:
; }
; else if (pTipo == 'R') // Right$
       cmp.b     #82,D5
       bne       basLeftRightMid_54
; {
; iy = strlen(vTemp);
       move.l    A3,-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    D0,D4
; iz = (iy - vqtd);
       move.l    D4,D0
       sub.l     -18(A6),D0
       move.l    D0,D6
; iw = 0;
       clr.l     D3
; for (ix = iz; ix < iy; ix++)
       move.l    D6,D2
basLeftRightMid_56:
       cmp.l     D4,D2
       bge.s     basLeftRightMid_58
; *(token + iw++) = vTemp[ix];
       move.l    (A4),A0
       move.l    D3,D0
       addq.l    #1,D3
       move.b    0(A3,D2.L),0(A0,D0.L)
       addq.l    #1,D2
       bra       basLeftRightMid_56
basLeftRightMid_58:
; *(token + iw)=0x00;
       move.l    (A4),A0
       clr.b     0(A0,D3.L)
       bra       basLeftRightMid_55
basLeftRightMid_54:
; }
; else  // Mid$
; {
; iy = strlen(vTemp);
       move.l    A3,-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    D0,D4
; iw=0;
       clr.l     D3
; vstart--;
       subq.l    #1,-14(A6)
; for (ix = vstart; ix < iy; ix++)
       move.l    -14(A6),D2
basLeftRightMid_59:
       cmp.l     D4,D2
       bge.s     basLeftRightMid_61
; {
; if (iw <= iy && vqtd-- > 0)
       cmp.l     D4,D3
       bgt.s     basLeftRightMid_62
       move.l    -18(A6),D0
       subq.l    #1,-18(A6)
       cmp.l     #0,D0
       ble.s     basLeftRightMid_62
; *(token + iw++) = vTemp[ix];
       move.l    (A4),A0
       move.l    D3,D0
       addq.l    #1,D3
       move.b    0(A3,D2.L),0(A0,D0.L)
       bra.s     basLeftRightMid_63
basLeftRightMid_62:
; else
; break;
       bra.s     basLeftRightMid_61
basLeftRightMid_63:
       addq.l    #1,D2
       bra       basLeftRightMid_59
basLeftRightMid_61:
; }
; *(token + iw) = 0x00;
       move.l    (A4),A0
       clr.b     0(A0,D3.L)
basLeftRightMid_55:
; }
; *value_type = '$';
       move.l    _value_type.L,A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basLeftRightMid_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //  Comandos de memoria
; //      Leitura de Memoria:   peek(<endereco>)
; //      Gravacao em endereco: poke(<endereco>,<byte>)
; //--------------------------------------------------------------------------------------
; int basPeekPoke(char pTipo)
; {
       xdef      _basPeekPoke
_basPeekPoke:
       link      A6,#-100
       movem.l   A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       _token_type.L,A4
       lea       _nextToken.L,A5
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -98(A6)
       clr.l     -94(A6)
       clr.l     -90(A6)
       clr.l     -86(A6)
; unsigned char answer[30], vTemp[30];
; unsigned char *vEnd = 0;
       clr.l     -18(A6)
; unsigned int vByte = 0;
       clr.l     -14(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPeekPoke_1
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPeekPoke_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basPeekPoke_6
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basPeekPoke_4
basPeekPoke_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPeekPoke_7
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPeekPoke_9
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_9:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&vEnd);
       pea       -18(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPeekPoke_11
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_11:
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPeekPoke_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_13:
; }
; }
; // Deve ser uma virgula para Receber a qtd
; if (pTipo == 'W')
       move.b    11(A6),D0
       cmp.b     #87,D0
       bne       basPeekPoke_25
; {
; if (*token==',')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basPeekPoke_25
; {
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPeekPoke_19
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_19:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPeekPoke_21
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_21:
; }
; else { /* is expression */
; //putback();
; getExp(&vByte);
       pea       -14(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPeekPoke_23
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_23:
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPeekPoke_25
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_25:
; }
; }
; }
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPeekPoke_27
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_27:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basPeekPoke_29
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_29:
; }
; if (pTipo == 'R')
       move.b    11(A6),D0
       cmp.b     #82,D0
       bne.s     basPeekPoke_31
; {
; *token = 0;
       move.l    (A3),A0
       clr.b     (A0)
; *(token + 1) = 0;
       move.l    (A3),A0
       clr.b     1(A0)
; *(token + 2) = 0;
       move.l    (A3),A0
       clr.b     2(A0)
; *(token + 3) = *vEnd;
       move.l    -18(A6),A0
       move.l    (A3),A1
       move.b    (A0),3(A1)
       bra.s     basPeekPoke_32
basPeekPoke_31:
; }
; else
; {
; *vEnd = (char)vByte;
       move.l    -14(A6),D0
       move.l    -18(A6),A0
       move.b    D0,(A0)
basPeekPoke_32:
; }
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basPeekPoke_3:
       movem.l   (A7)+,A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //  Array (min 1 dimensoes)
; //      Sintaxe:
; //              DIM (<dim 1>[,<dim 2>[,<dim 3>,<dim 4>,...,<dim n>])
; //--------------------------------------------------------------------------------------
; int basDim(void)
; {
       xdef      _basDim
_basDim:
       link      A6,#-452
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _token.L,A2
       lea       _vErroProc.L,A3
       lea       _varName.L,A4
       lea       _strlen.L,A5
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -450(A6)
       clr.l     -446(A6)
       clr.l     -442(A6)
       clr.l     -438(A6)
; unsigned char answer[30], vTemp[30];
; unsigned char sqtdtam[10];
; unsigned int vDim[88], ixDim = 0, vTempDim = 0;
       clr.l     D3
       clr.l     -8(A6)
; unsigned char varTipo;
; long vRetFV;
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     basDim_1
       clr.l     D0
       bra       basDim_3
basDim_1:
; // Pega o nome da variavel
; if (!isalphas(*token)) {
       move.l    (A2),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basDim_4
; *vErroProc = 4;
       move.l    (A3),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_4:
; }
; if (strlen(token) < 3)
       move.l    (A2),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basDim_6
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       moveq     #35,D2
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    (A2),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basDim_8
       move.l    (A2),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basDim_8
; varTipo = *(token + 1);
       move.l    (A2),A0
       move.b    1(A0),D2
basDim_8:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    (A2),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basDim_10
       move.l    (A2),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basDim_10
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    1(A0),1(A1)
       bra.s     basDim_11
basDim_10:
; else
; *(varName + 1) = 0x00;
       move.l    (A4),A0
       clr.b     1(A0)
basDim_11:
; *(varName + 2) = varTipo;
       move.l    (A4),A0
       move.b    D2,2(A0)
       bra       basDim_7
basDim_6:
; }
; else
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    (A2),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-442(A6)
; varTipo = *(varName + 2);
       move.l    (A4),A0
       move.b    2(A0),D2
basDim_7:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     basDim_12
       clr.l     D0
       bra       basDim_3
basDim_12:
; // Erro, primeiro caracter depois da variavel, deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basDim_16
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basDim_16
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basDim_14
basDim_16:
; {
; *vErroProc = 15;
       move.l    (A3),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_14:
; }
; do
; {
basDim_17:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     basDim_19
       clr.l     D0
       bra       basDim_3
basDim_19:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basDim_21
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_21:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&vTempDim);
       pea       -8(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     basDim_23
       clr.l     D0
       bra       basDim_3
basDim_23:
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basDim_25
; {
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_25:
; }
; if (*value_type == '#')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basDim_27
; {
; vTempDim = fppInt(vTempDim);
       move.l    -8(A6),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,-8(A6)
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
basDim_27:
; }
; vTempDim += 1; // porque nao é de 1 a x, é de 0 a x, entao é x + 1
       addq.l    #1,-8(A6)
; vDim[ixDim] = vTempDim;
       move.l    D3,D0
       lsl.l     #2,D0
       lea       -360(A6),A0
       move.l    -8(A6),0(A0,D0.L)
; ixDim++;
       addq.l    #1,D3
; }
; if (*token == ',')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne.s     basDim_29
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
       bra.s     basDim_30
basDim_29:
; }
; else
; break;
       bra.s     basDim_18
basDim_30:
       bra       basDim_17
basDim_18:
; } while(1);
; // Deve ter pelo menos 1 elemento
; if (ixDim < 1)
       cmp.l     #1,D3
       bhs.s     basDim_31
; {
; *vErroProc = 21;
       move.l    (A3),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_31:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     basDim_33
       clr.l     D0
       bra       basDim_3
basDim_33:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basDim_35
; {
; *vErroProc = 15;
       move.l    (A3),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_35:
; }
; // assign the value
; vRetFV = findVariable(varName);
       move.l    (A4),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-4(A6)
; // Se nao existe a variavel, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     -4(A6)
       bne.s     basDim_37
; createVariableArray(varName, varTipo, ixDim, vDim);
       pea       -360(A6)
       move.l    D3,-(A7)
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       move.l    (A4),-(A7)
       jsr       _createVariableArray
       add.w     #16,A7
       bra.s     basDim_38
basDim_37:
; else
; {
; *vErroProc = 23;
       move.l    (A3),A0
       move.w    #23,(A0)
; return 0;
       clr.l     D0
       bra.s     basDim_3
basDim_38:
; }
; return 0;
       clr.l     D0
basDim_3:
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; int basIf(void)
; {
       xdef      _basIf
_basIf:
       link      A6,#-4
       movem.l   D2/A2/A3,-(A7)
       lea       _pointerRunProg.L,A2
       lea       _vErroProc.L,A3
; unsigned int vCond = 0;
       clr.l     -4(A6)
; unsigned char *vTempPointer;
; getExp(&vCond); // get target value
       pea       -4(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basIf_3
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basIf_1
basIf_3:
; *vErroProc = 16;
       move.l    (A3),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basIf_4
basIf_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A3),A0
       tst.w     (A0)
       beq.s     basIf_5
       clr.l     D0
       bra       basIf_4
basIf_5:
; if (*token!=0x83)
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #131,D0
       beq.s     basIf_7
; {
; *vErroProc = 8;
       move.l    (A3),A0
       move.w    #8,(A0)
; return 0;
       clr.l     D0
       bra       basIf_4
basIf_7:
; }
; if (vCond)
       tst.l     -4(A6)
       beq.s     basIf_9
; {
; // Vai pro proximo comando apos o Then e continua
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A2),A0
       addq.l    #1,(A0)
; // simula ":" para continuar a execucao
; *doisPontos = 1;
       move.l    _doisPontos.L,A0
       move.b    #1,(A0)
       bra.s     basIf_13
basIf_9:
; }
; else
; {
; // Ignora toda a linha
; vTempPointer = *pointerRunProg;
       move.l    (A2),A0
       move.l    (A0),D2
; while (*vTempPointer)
basIf_11:
       move.l    D2,A0
       tst.b     (A0)
       beq.s     basIf_13
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A2),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A2),A0
       move.l    (A0),D2
       bra       basIf_11
basIf_13:
; }
; }
; return 0;
       clr.l     D0
basIf_4:
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Atribuir valor a uma variavel/array - comando opcional.
; // Syntaxe:
; //            [LET] <variavel/array(x[,y])> = <string/valor>
; //--------------------------------------------------------------------------------------
; int basLet(void)
; {
       xdef      _basLet
_basLet:
       link      A6,#-220
       movem.l   D2/D3/D4/D5/A2/A3/A4/A5,-(A7)
       lea       _token.L,A2
       lea       _varName.L,A3
       lea       _vErroProc.L,A4
       lea       -214(A6),A5
; long vRetFV, iz;
; unsigned char varTipo;
; unsigned char value[200];
; unsigned long *lValue = &value;
       move.l    A5,D5
; unsigned char sqtdtam[10];
; unsigned char vArray = 0;
       clr.b     D4
; unsigned char *vTempPointer;
; /* get the variable name */
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basLet_1
       clr.l     D0
       bra       basLet_3
basLet_1:
; if (!isalphas(*token)) {
       move.l    (A2),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basLet_4
; *vErroProc = 4;
       move.l    (A4),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basLet_3
basLet_4:
; }
; if (strlen(token) < 3)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basLet_6
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A3),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       moveq     #35,D2
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basLet_8
       move.l    (A2),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basLet_8
; varTipo = *(token + 1);
       move.l    (A2),A0
       move.b    1(A0),D2
basLet_8:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basLet_10
       move.l    (A2),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basLet_10
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A3),A1
       move.b    1(A0),1(A1)
       bra.s     basLet_11
basLet_10:
; else
; *(varName + 1) = 0x00;
       move.l    (A3),A0
       clr.b     1(A0)
basLet_11:
; *(varName + 2) = varTipo;
       move.l    (A3),A0
       move.b    D2,2(A0)
       bra       basLet_7
basLet_6:
; }
; else
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A3),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A3),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    (A2),A0
       move.l    (A3),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-218(A6)
; varTipo = *(varName + 2);
       move.l    (A3),A0
       move.b    2(A0),D2
basLet_7:
; }
; // verifica se é array (abre parenteses no inicio)
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-4(A6)
; if (*vTempPointer == 0x28)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       basLet_12
; {
; vRetFV = findVariable(varName);
       move.l    (A3),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,D3
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basLet_14
       clr.l     D0
       bra       basLet_3
basLet_14:
; if (!vRetFV)
       tst.l     D3
       bne.s     basLet_16
; {
; *vErroProc = 4;
       move.l    (A4),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basLet_3
basLet_16:
; }
; vArray = 1;
       moveq     #1,D4
basLet_12:
; }
; // get the equals sign
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A4),A0
       tst.w     (A0)
       beq.s     basLet_18
       clr.l     D0
       bra       basLet_3
basLet_18:
; if (*token!='=') {
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     basLet_20
; *vErroProc = 3;
       move.l    (A4),A0
       move.w    #3,(A0)
; return 0;
       clr.l     D0
       bra       basLet_3
basLet_20:
; }
; /* get the value to assign to varName */
; getExp(&value);
       move.l    A5,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (varTipo == '#' && *value_type != '#')
       cmp.b     #35,D2
       bne.s     basLet_22
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       beq.s     basLet_22
; *lValue = fppReal(*lValue);
       move.l    D5,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D5,A0
       move.l    D0,(A0)
basLet_22:
; // assign the value
; if (!vArray)
       tst.b     D4
       bne       basLet_24
; {
; vRetFV = findVariable(varName);
       move.l    (A3),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,D3
; // Se nao existe a variavel, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     D3
       bne.s     basLet_26
; createVariable(varName, value, varTipo);
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       move.l    A5,-(A7)
       move.l    (A3),-(A7)
       jsr       _createVariable
       add.w     #12,A7
       bra.s     basLet_27
basLet_26:
; else // se ja existe, altera
; updateVariable((vRetFV + 3), value, varTipo, 1);
       pea       1
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       move.l    A5,-(A7)
       move.l    D3,D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basLet_27:
       bra.s     basLet_25
basLet_24:
; }
; else
; {
; updateVariable(vRetFV, value, varTipo, 2);
       pea       2
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       move.l    A5,-(A7)
       move.l    D3,-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basLet_25:
; }
; return 0;
       clr.l     D0
basLet_3:
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Entrada pelo teclado de numeros/caracteres ateh teclar ENTER (INPUT)
; // Entrada pelo teclado de um unico caracter ou numero (GET)
; // Entrada dos dados de acordo com o tipo de variavel $(qquer), %(Nums), #(Nums & '.')
; // Syntaxe:
; //          INPUT ["texto",]<variavel> : A variavel sera criada se nao existir
; //          GET <variavel> : A variavel sera criada se nao existir
; //--------------------------------------------------------------------------------------
; int basInputGet(unsigned char pSize)
; {
       xdef      _basInputGet
_basInputGet:
       link      A6,#-512
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _token.L,A2
       lea       -224(A6),A3
       lea       _varName.L,A4
       lea       _vErroProc.L,A5
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -510(A6)
       clr.b     -509(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     D6
       clr.l     -240(A6)
       clr.l     -236(A6)
       clr.l     -232(A6)
; unsigned char answer[200], vtec;
; long *lVal = answer;
       move.l    A3,-24(A6)
; int  *iVal = answer;
       move.l    A3,D5
; char vTemTexto = 0;
       clr.b     D4
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim;
; unsigned char *buffptr = &vbufInput;
       lea       _vbufInput.L,A0
       move.l    A0,-10(A6)
; long vRetFV;
; unsigned char varTipo;
; char vArray = 0;
       clr.b     -5(A6)
; unsigned char *vTempPointer;
; do {
basInputGet_1:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A5),A0
       tst.w     (A0)
       beq.s     basInputGet_3
       clr.l     D0
       bra       basInputGet_5
basInputGet_3:
; if (*tok == EOL || *tok == FINISHED)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basInputGet_8
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basInputGet_6
basInputGet_8:
; break;
       bra       basInputGet_2
basInputGet_6:
; if (*token_type == QUOTE) /* is string */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne       basInputGet_9
; {
; if (vTemTexto)
       tst.b     D4
       beq.s     basInputGet_11
; {
; *vErroProc = 14;
       move.l    (A5),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_11:
; }
; printText(token);
       move.l    (A2),-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A5),A0
       tst.w     (A0)
       beq.s     basInputGet_13
       clr.l     D0
       bra       basInputGet_5
basInputGet_13:
; vTemTexto = 1;
       moveq     #1,D4
       bra       basInputGet_56
basInputGet_9:
; }
; else /* is expression */
; {
; // Verifica se comeca com letra, pois tem que ser uma variavel agora
; if (!isalphas(*token))
       move.l    (A2),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basInputGet_15
; {
; *vErroProc = 4;
       move.l    (A5),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_15:
; }
; if (strlen(token) < 3)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basInputGet_17
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       moveq     #35,D2
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basInputGet_19
       move.l    (A2),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basInputGet_19
; varTipo = *(token + 1);
       move.l    (A2),A0
       move.b    1(A0),D2
basInputGet_19:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basInputGet_21
       move.l    (A2),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basInputGet_21
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    1(A0),1(A1)
       bra.s     basInputGet_22
basInputGet_21:
; else
; *(varName + 1) = 0x00;
       move.l    (A4),A0
       clr.b     1(A0)
basInputGet_22:
; *(varName + 2) = varTipo;
       move.l    (A4),A0
       move.b    D2,2(A0)
       bra       basInputGet_18
basInputGet_17:
; }
; else
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    (A2),A0
       move.l    (A4),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-236(A6)
; varTipo = *(varName + 2);
       move.l    (A4),A0
       move.b    2(A0),D2
basInputGet_18:
; }
; answer[0] = 0x00;
       clr.b     (A3)
; vbufInput[0] = 0x00;
       clr.b     _vbufInput.L
; if (pSize == 1)
       move.b    11(A6),D0
       cmp.b     #1,D0
       bne       basInputGet_23
; {
; // GET
; for (ix = 0; ix < 15000; ix++)
       clr.l     D6
basInputGet_25:
       cmp.l     #15000,D6
       bge.s     basInputGet_27
; {
; vtec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,D3
; if (vtec)
       tst.b     D3
       beq.s     basInputGet_28
; break;
       bra.s     basInputGet_27
basInputGet_28:
       addq.l    #1,D6
       bra       basInputGet_25
basInputGet_27:
; }
; //                vtec = inputLineBasic(1,'@');    // Qualquer coisa
; if (varTipo != '$' && vtec)
       cmp.b     #36,D2
       beq.s     basInputGet_32
       and.l     #255,D3
       beq.s     basInputGet_32
; {
; if (!isdigitus(vtec))
       and.l     #255,D3
       move.l    D3,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       bne.s     basInputGet_32
; vtec = 0;
       clr.b     D3
basInputGet_32:
; }
; answer[0] = vtec;
       move.b    D3,(A3)
; answer[1] = 0x00;
       clr.b     1(A3)
       bra       basInputGet_24
basInputGet_23:
; }
; else
; {
; // INPUT
; vtec = inputLineBasic(255,varTipo);
       and.l     #255,D2
       move.l    D2,-(A7)
       pea       255
       jsr       _inputLineBasic
       addq.w    #8,A7
       move.b    D0,D3
; if (vbufInput[0] != 0x00 && (vtec == 0x0D || vtec == 0x0A))
       move.b    _vbufInput.L,D0
       beq.s     basInputGet_39
       cmp.b     #13,D3
       beq.s     basInputGet_36
       cmp.b     #10,D3
       bne.s     basInputGet_39
basInputGet_36:
; {
; ix = 0;
       clr.l     D6
; while (*buffptr)
basInputGet_37:
       move.l    -10(A6),A0
       tst.b     (A0)
       beq.s     basInputGet_39
; {
; answer[ix++] = *buffptr++;
       move.l    -10(A6),A0
       addq.l    #1,-10(A6)
       move.l    D6,D0
       addq.l    #1,D6
       move.b    (A0),0(A3,D0.L)
; answer[ix] = 0x00;
       clr.b     0(A3,D6.L)
       bra       basInputGet_37
basInputGet_39:
; }
; }
; printText("\r\n");
       pea       @basic_94.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
basInputGet_24:
; }
; if (varTipo!='$')
       cmp.b     #36,D2
       beq       basInputGet_40
; {
; if (varTipo=='#')  // verifica se eh numero inteiro ou real
       cmp.b     #35,D2
       bne.s     basInputGet_42
; {
; iVal=floatStringToFpp(answer);
       move.l    A3,-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,D5
; if (*vErroProc) return 0;
       move.l    (A5),A0
       tst.w     (A0)
       beq.s     basInputGet_44
       clr.l     D0
       bra       basInputGet_5
basInputGet_44:
       bra.s     basInputGet_43
basInputGet_42:
; }
; else
; {
; iVal=atoi(answer);
       move.l    A3,-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,D5
basInputGet_43:
; }
; answer[0]=((int)(*iVal & 0xFF000000) >> 24);
       move.l    D5,A0
       move.l    (A0),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.b    D0,(A3)
; answer[1]=((int)(*iVal & 0x00FF0000) >> 16);
       move.l    D5,A0
       move.l    (A0),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.b    D0,1(A3)
; answer[2]=((int)(*iVal & 0x0000FF00) >> 8);
       move.l    D5,A0
       move.l    (A0),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.b    D0,2(A3)
; answer[3]=(char)(*iVal & 0x000000FF);
       move.l    D5,A0
       move.l    (A0),D0
       and.l     #255,D0
       move.b    D0,3(A3)
basInputGet_40:
; }
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-4(A6)
; if (*vTempPointer == 0x28)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       basInputGet_46
; {
; vRetFV = findVariable(varName);
       move.l    (A4),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,D7
; if (*vErroProc) return 0;
       move.l    (A5),A0
       tst.w     (A0)
       beq.s     basInputGet_48
       clr.l     D0
       bra       basInputGet_5
basInputGet_48:
; if (!vRetFV)
       tst.l     D7
       bne.s     basInputGet_50
; {
; *vErroProc = 4;
       move.l    (A5),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_50:
; }
; vArray = 1;
       move.b    #1,-5(A6)
basInputGet_46:
; }
; if (!vArray)
       tst.b     -5(A6)
       bne       basInputGet_52
; {
; // assign the value
; vRetFV = findVariable(varName);
       move.l    (A4),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,D7
; // Se nao existe variavel e inicio sentenca, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     D7
       bne.s     basInputGet_54
; createVariable(varName, answer, varTipo);
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       move.l    A3,-(A7)
       move.l    (A4),-(A7)
       jsr       _createVariable
       add.w     #12,A7
       bra.s     basInputGet_55
basInputGet_54:
; else // se ja existe, altera
; updateVariable((vRetFV + 3), answer, varTipo, 1);
       pea       1
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       move.l    A3,-(A7)
       move.l    D7,D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basInputGet_55:
       bra.s     basInputGet_53
basInputGet_52:
; }
; else
; {
; updateVariable(vRetFV, answer, varTipo, 2);
       pea       2
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       move.l    A3,-(A7)
       move.l    D7,-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basInputGet_53:
; }
; vTemTexto=2;
       moveq     #2,D4
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A5),A0
       tst.w     (A0)
       beq.s     basInputGet_56
       clr.l     D0
       bra       basInputGet_5
basInputGet_56:
; }
; last_delim = *token;
       move.l    (A2),A0
       move.b    (A0),-11(A6)
; if (vTemTexto==1 && *token==';')
       cmp.b     #1,D4
       bne.s     basInputGet_58
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       bne.s     basInputGet_58
       bra       basInputGet_64
basInputGet_58:
; /* do nothing */;
; else if (vTemTexto==1 && *token!=';')
       cmp.b     #1,D4
       bne.s     basInputGet_60
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq.s     basInputGet_60
; {
; *vErroProc = 14;
       move.l    (A5),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_60:
; }
; else if (vTemTexto!=1 && *token==';')
       cmp.b     #1,D4
       beq.s     basInputGet_62
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       bne.s     basInputGet_62
; {
; *vErroProc = 14;
       move.l    (A5),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_62:
; }
; else if (*tok!=EOL && *tok!=FINISHED && *token!=':')
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basInputGet_64
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basInputGet_64
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq.s     basInputGet_64
; {
; *vErroProc = 14;
       move.l    (A5),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra.s     basInputGet_5
basInputGet_64:
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq       basInputGet_1
basInputGet_2:
; }
; } while (*token==';');
; return 0;
       clr.l     D0
basInputGet_5:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; char forFind(for_stack *i, unsigned char* endLastVar)
; {
       xdef      _forFind
_forFind:
       link      A6,#-12
       movem.l   D2/D3,-(A7)
; int ix;
; unsigned char sqtdtam[10];
; for_stack *j;
; j = forStack;
       move.l    _forStack.L,D3
; for(ix = 0; ix < *ftos; ix++)
       clr.l     D2
forFind_1:
       move.l    _ftos.L,A0
       cmp.l     (A0),D2
       bge       forFind_3
; {
; if (j[ix].nameVar[0] == endLastVar[1] && j[ix].nameVar[1] == endLastVar[2])
       move.l    D3,A0
       move.l    D2,D0
       muls      #20,D0
       move.l    12(A6),A1
       move.b    0(A0,D0.L),D1
       cmp.b     1(A1),D1
       bne       forFind_4
       move.l    D3,A0
       move.l    D2,D0
       muls      #20,D0
       add.l     D0,A0
       move.l    12(A6),A1
       move.b    1(A0),D0
       cmp.b     2(A1),D0
       bne.s     forFind_4
; {
; *i = j[ix];
       move.l    8(A6),A0
       move.l    D3,D0
       move.l    D2,D1
       muls      #20,D1
       add.l     D1,D0
       move.l    D0,A1
       moveq     #4,D0
       move.l    (A1)+,(A0)+
       dbra      D0,*-2
; return ix;
       move.b    D2,D0
       bra.s     forFind_6
forFind_4:
; }
; else if (!j[ix].nameVar[0])
       move.l    D3,A0
       move.l    D2,D0
       muls      #20,D0
       tst.b     0(A0,D0.L)
       bne.s     forFind_7
; return -1;
       moveq     #-1,D0
       bra.s     forFind_6
forFind_7:
       addq.l    #1,D2
       bra       forFind_1
forFind_3:
; }
; return -1;
       moveq     #-1,D0
forFind_6:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Inicio do laco de repeticao
; // Syntaxe:
; //          FOR <variavel> = <inicio> TO <final> [STEP <passo>] : A variavel sera criada se nao existir
; //--------------------------------------------------------------------------------------
; int basFor(void)
; {
       xdef      _basFor
_basFor:
       link      A6,#-48
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -46(A6),A2
       lea       _pointerRunProg.L,A3
       lea       _logicalNumericFloatLong.L,A4
       lea       _fppReal.L,A5
; for_stack i, *j;
; int value=0;
       clr.l     -26(A6)
; long *endVarCont;
; long iStep = 1;
       move.l    #1,-22(A6)
; long iTarget = 0;
       clr.l     -18(A6)
; unsigned char* endLastVar;
; unsigned char sqtdtam[10];
; char vRetVar = -1;
       moveq     #-1,D6
; unsigned char *vTempPointer;
; char vResLog1 = 0, vResLog2 = 0;
       clr.b     -3(A6)
       clr.b     -2(A6)
; char vResLog3 = 0, vResLog4 = 0;
       clr.b     -1(A6)
       moveq     #0,D7
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq.s     basFor_1
; {
; writeLongSerial("Aqui 444.666.0\r\n");
       pea       @basic_148.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
basFor_1:
; }
; basLet();
       jsr       _basLet
; if (*vErroProc) return 0;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     basFor_3
       clr.l     D0
       bra       basFor_5
basFor_3:
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq.s     basFor_6
; {
; writeLongSerial("Aqui 444.666.1]\r\n");
       pea       @basic_149.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
basFor_6:
; }
; endLastVar = *atuVarAddr - 3;
       move.l    _atuVarAddr.L,A0
       move.l    (A0),D0
       subq.l    #3,D0
       move.l    D0,D5
; endVarCont = *atuVarAddr + 1;
       move.l    _atuVarAddr.L,A0
       move.l    (A0),D0
       addq.l    #1,D0
       move.l    D0,D3
; vRetVar = forFind(&i, endLastVar);
       move.l    D5,-(A7)
       move.l    A2,-(A7)
       jsr       _forFind
       addq.w    #8,A7
       move.b    D0,D6
; if (vRetVar < 0)
       cmp.b     #0,D6
       bge.s     basFor_8
; {
; i.nameVar[0]=endLastVar[1];
       move.l    D5,A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    1(A0),(A1)
; i.nameVar[1]=endLastVar[2];
       move.l    D5,A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    2(A0),1(A1)
; i.nameVar[2]=endLastVar[0];
       move.l    D5,A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    (A0),2(A1)
basFor_8:
; }
; if (i.nameVar[2] == '#')
       move.l    A2,D0
       move.l    D0,A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basFor_10
; i.step = fppReal(iStep);
       move.l    -22(A6),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    A2,D1
       move.l    D1,A0
       move.l    D0,12(A0)
       bra.s     basFor_11
basFor_10:
; else
; i.step = iStep;
       move.l    A2,D0
       move.l    D0,A0
       move.l    -22(A6),12(A0)
basFor_11:
; i.endVar = endVarCont;
       move.l    A2,D0
       move.l    D0,A0
       move.l    D3,4(A0)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     basFor_12
       clr.l     D0
       bra       basFor_5
basFor_12:
; if (*tok!=0x86) /* read and discard the TO */
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq.s     basFor_14
; {
; *vErroProc = 9;
       move.l    _vErroProc.L,A0
       move.w    #9,(A0)
; return 0;
       clr.l     D0
       bra       basFor_5
basFor_14:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; if (*debugOn)
       move.l    _debugOn.L,A0
       tst.b     (A0)
       beq       basFor_16
; {
; writeLongSerial("Aqui 444.666.2 varName-[");
       pea       @basic_150.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*pointerRunProg,sqtdtam,16);
       pea       16
       pea       -14(A6)
       move.l    (A3),A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -14(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n");
       pea       @basic_133.L
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
basFor_16:
; }
; getExp(&iTarget); /* get target value */
       pea       -18(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (i.nameVar[2] == '#' && *value_type == '%')
       move.l    A2,D0
       move.l    D0,A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basFor_18
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne.s     basFor_18
; i.target = fppReal(iTarget);
       move.l    -18(A6),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    A2,D1
       move.l    D1,A0
       move.l    D0,8(A0)
       bra.s     basFor_19
basFor_18:
; else
; i.target = iTarget;
       move.l    A2,D0
       move.l    D0,A0
       move.l    -18(A6),8(A0)
basFor_19:
; if (*tok==0x88) /* read STEP */
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #136,D0
       bne       basFor_23
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; getExp(&iStep); /* get target value */
       pea       -22(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (i.nameVar[2] == '#' && *value_type == '%')
       move.l    A2,D0
       move.l    D0,A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basFor_22
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne.s     basFor_22
; i.step = fppReal(iStep);
       move.l    -22(A6),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    A2,D1
       move.l    D1,A0
       move.l    D0,12(A0)
       bra.s     basFor_23
basFor_22:
; else
; i.step = iStep;
       move.l    A2,D0
       move.l    D0,A0
       move.l    -22(A6),12(A0)
basFor_23:
; }
; endVarCont=i.endVar;
       move.l    A2,D0
       move.l    D0,A0
       move.l    4(A0),D3
; // if loop can execute at least once, push info on stack     //    if ((i.step > 0 && *endVarCont <= i.target) || (i.step < 0 && *endVarCont >= i.target))
; if (i.nameVar[2] == '#')
       move.l    A2,D0
       move.l    D0,A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne       basFor_24
; {
; vResLog1 = logicalNumericFloatLong(0xF6 /* <= */, *endVarCont, i.target);
       move.l    A2,D1
       move.l    D1,A0
       move.l    8(A0),-(A7)
       move.l    D3,A0
       move.l    (A0),-(A7)
       pea       246
       jsr       (A4)
       add.w     #12,A7
       move.b    D0,-3(A6)
; vResLog2 = logicalNumericFloatLong(0xF5 /* >= */, *endVarCont, i.target);
       move.l    A2,D1
       move.l    D1,A0
       move.l    8(A0),-(A7)
       move.l    D3,A0
       move.l    (A0),-(A7)
       pea       245
       jsr       (A4)
       add.w     #12,A7
       move.b    D0,-2(A6)
; vResLog3 = logicalNumericFloatLong('>', i.step, 0);
       clr.l     -(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.l    12(A0),-(A7)
       pea       62
       jsr       (A4)
       add.w     #12,A7
       move.b    D0,-1(A6)
; vResLog4 = logicalNumericFloatLong('<', i.step, 0);
       clr.l     -(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.l    12(A0),-(A7)
       pea       60
       jsr       (A4)
       add.w     #12,A7
       move.b    D0,D7
       bra       basFor_25
basFor_24:
; }
; else
; {
; vResLog1 = (*endVarCont <= i.target);
       move.l    D3,A0
       move.l    A2,D0
       move.l    D0,A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       bgt.s     basFor_26
       moveq     #1,D0
       bra.s     basFor_27
basFor_26:
       clr.l     D0
basFor_27:
       move.b    D0,-3(A6)
; vResLog2 = (*endVarCont >= i.target);
       move.l    D3,A0
       move.l    A2,D0
       move.l    D0,A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       blt.s     basFor_28
       moveq     #1,D0
       bra.s     basFor_29
basFor_28:
       clr.l     D0
basFor_29:
       move.b    D0,-2(A6)
; vResLog3 = (i.step > 0);
       move.l    A2,D0
       move.l    D0,A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       ble.s     basFor_30
       moveq     #1,D0
       bra.s     basFor_31
basFor_30:
       clr.l     D0
basFor_31:
       move.b    D0,-1(A6)
; vResLog4 = (i.step < 0);
       move.l    A2,D0
       move.l    D0,A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       bge.s     basFor_32
       moveq     #1,D0
       bra.s     basFor_33
basFor_32:
       clr.l     D0
basFor_33:
       move.b    D0,D7
basFor_25:
; }
; if (vResLog3 && vResLog1 || (vResLog4 && vResLog2))
       tst.b     -1(A6)
       beq.s     basFor_37
       tst.b     -3(A6)
       bne.s     basFor_36
basFor_37:
       tst.b     D7
       beq       basFor_34
       tst.b     -2(A6)
       beq       basFor_34
basFor_36:
; {
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
; if (*vTempPointer==0x3A) // ":"
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     basFor_38
; {
; i.progPosPointerRet = *pointerRunProg;
       move.l    (A3),A0
       move.l    A2,D0
       move.l    D0,A1
       move.l    (A0),16(A1)
       bra.s     basFor_39
basFor_38:
; }
; else
; i.progPosPointerRet = *nextAddr;
       move.l    _nextAddr.L,A0
       move.l    A2,D0
       move.l    D0,A1
       move.l    (A0),16(A1)
basFor_39:
; if (vRetVar < 0)
       cmp.b     #0,D6
       bge.s     basFor_40
; forPush(i);
       move.l    A2,D1
       move.l    D1,A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _forPush
       add.w     #20,A7
       bra       basFor_41
basFor_40:
; else
; {
; j = (forStack + vRetVar);
       move.l    _forStack.L,D0
       ext.w     D6
       ext.l     D6
       move.l    D6,D1
       muls      #20,D1
       ext.w     D1
       ext.l     D1
       add.l     D1,D0
       move.l    D0,D4
; j->target = i.target;
       move.l    A2,D0
       move.l    D0,A0
       move.l    D4,A1
       move.l    8(A0),8(A1)
; j->step = i.step;
       move.l    A2,D0
       move.l    D0,A0
       move.l    D4,A1
       move.l    12(A0),12(A1)
; j->endVar = i.endVar;
       move.l    A2,D0
       move.l    D0,A0
       move.l    D4,A1
       move.l    4(A0),4(A1)
; j->progPosPointerRet = i.progPosPointerRet;
       move.l    A2,D0
       move.l    D0,A0
       move.l    D4,A1
       move.l    16(A0),16(A1)
basFor_41:
       bra       basFor_44
basFor_34:
; }
; }
; else  /* otherwise, skip loop code alltogether */
; {
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
; while(*vTempPointer != 0x87) // Search NEXT
basFor_42:
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #135,D0
       beq       basFor_44
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
; // Verifica se chegou no next
; if (*vTempPointer == 0x87)
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #135,D0
       bne       basFor_51
; {
; // Verifica se tem letra, se nao tiver, usa ele
; if (*(vTempPointer + 1)!=0x00)
       move.l    D2,A0
       move.b    1(A0),D0
       beq       basFor_51
; {
; // verifica se é a mesma variavel que ele tem
; if (*(vTempPointer + 1) != i.nameVar[0])
       move.l    D2,A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    1(A0),D0
       cmp.b     (A1),D0
       beq.s     basFor_49
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
       bra       basFor_51
basFor_49:
; }
; else
; {
; if (*(vTempPointer + 2) != i.nameVar[1] && *(vTempPointer + 2) != i.nameVar[2])
       move.l    D2,A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    2(A0),D0
       cmp.b     1(A1),D0
       beq.s     basFor_51
       move.l    D2,A0
       move.l    A2,D0
       move.l    D0,A1
       move.b    2(A0),D0
       cmp.b     2(A1),D0
       beq.s     basFor_51
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A3),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    (A3),A0
       move.l    (A0),D2
basFor_51:
       bra       basFor_42
basFor_44:
; }
; }
; }
; }
; }
; }
; return 0;
       clr.l     D0
basFor_5:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Final/Incremento do Laco de repeticao, voltando para o commando/linha após o FOR
; // Syntaxe:
; //          NEXT [<variavel>]
; //--------------------------------------------------------------------------------------
; int basNext(void)
; {
       xdef      _basNext
_basNext:
       link      A6,#-40
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -28(A6),A2
       lea       -8(A6),A3
       lea       _token.L,A4
       lea       _logicalNumericFloatLong.L,A5
; unsigned char sqtdtam[10];
; for_stack i;
; int *endVarCont;
; unsigned char answer[3];
; char vRetVar = -1;
       moveq     #-1,D7
; unsigned char *vTempPointer;
; char vResLog1 = 0, vResLog2 = 0;
       clr.b     D6
       clr.b     D5
; char vResLog3 = 0, vResLog4 = 0;
       clr.b     D4
       clr.b     D3
; /*writeLongSerial("Aqui 777.666.0-[");
; itoa(*pointerRunProg,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*pointerRunProg,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-4(A6)
; if (isalphas(*vTempPointer))
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq       basNext_1
; {
; // procura pela variavel no forStack
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     basNext_3
       clr.l     D0
       bra       basNext_5
basNext_3:
; if (*token_type != VARIABLE)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basNext_6
; {
; *vErroProc = 4;
       move.l    _vErroProc.L,A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basNext_5
basNext_6:
; }
; answer[1] = *token;
       move.l    (A4),A0
       move.b    (A0),1(A3)
; if (strlen(token) == 1)
       move.l    (A4),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #1,D0
       bne.s     basNext_8
; {
; answer[0] = 0x00;
       clr.b     (A3)
; answer[2] = 0x00;
       clr.b     2(A3)
       bra       basNext_11
basNext_8:
; }
; else if (strlen(token) == 2)
       move.l    (A4),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basNext_10
; {
; if (*(token + 1) < 0x30)
       move.l    (A4),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basNext_12
; {
; answer[0] = *(token + 1);
       move.l    (A4),A0
       move.b    1(A0),(A3)
; answer[2] = 0x00;
       clr.b     2(A3)
       bra.s     basNext_13
basNext_12:
; }
; else
; {
; answer[0] = 0x00;
       clr.b     (A3)
; answer[2] = *(token + 1);
       move.l    (A4),A0
       move.b    1(A0),2(A3)
basNext_13:
       bra.s     basNext_11
basNext_10:
; }
; }
; else
; {
; answer[0] = *(token + 2);
       move.l    (A4),A0
       move.b    2(A0),(A3)
; answer[2] = *(token + 1);
       move.l    (A4),A0
       move.b    1(A0),2(A3)
basNext_11:
; }
; vRetVar = forFind(&i,answer);
       move.l    A3,-(A7)
       move.l    A2,-(A7)
       jsr       _forFind
       addq.w    #8,A7
       move.b    D0,D7
; if (vRetVar < 0)
       cmp.b     #0,D7
       bge.s     basNext_14
; {
; *vErroProc = 11;
       move.l    _vErroProc.L,A0
       move.w    #11,(A0)
; return 0;
       clr.l     D0
       bra       basNext_5
basNext_14:
       bra.s     basNext_2
basNext_1:
; }
; }
; else // faz o pop da pilha
; i = forPop(); // read the loop info
       move.l    A2,A0
       move.l    A0,-(A7)
       jsr       _forPop
       move.l    (A7)+,A0
       move.l    D0,A1
       moveq     #4,D0
       move.l    (A1)+,(A0)+
       dbra      D0,*-2
basNext_2:
; endVarCont = i.endVar;
       move.l    A2,D0
       move.l    D0,A0
       move.l    4(A0),D2
; if (i.nameVar[2] == '#')
       move.l    A2,D0
       move.l    D0,A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basNext_16
; {
; *endVarCont = fppSum(*endVarCont,i.step); // inc/dec, using step, control variable
       move.l    A2,D1
       move.l    D1,A0
       move.l    12(A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppSum
       addq.w    #8,A7
       move.l    D2,A0
       move.l    D0,(A0)
       bra.s     basNext_17
basNext_16:
; }
; else
; *endVarCont = *endVarCont + i.step; // inc/dec, using step, control variable
       move.l    D2,A0
       move.l    A2,D0
       move.l    D0,A1
       move.l    12(A1),D0
       add.l     D0,(A0)
basNext_17:
; if (i.nameVar[2] == '#')
       move.l    A2,D0
       move.l    D0,A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne       basNext_18
; {
; vResLog1 = logicalNumericFloatLong('>', *endVarCont, i.target);
       move.l    A2,D1
       move.l    D1,A0
       move.l    8(A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       pea       62
       jsr       (A5)
       add.w     #12,A7
       move.b    D0,D6
; vResLog2 = logicalNumericFloatLong('<', *endVarCont, i.target);
       move.l    A2,D1
       move.l    D1,A0
       move.l    8(A0),-(A7)
       move.l    D2,A0
       move.l    (A0),-(A7)
       pea       60
       jsr       (A5)
       add.w     #12,A7
       move.b    D0,D5
; vResLog3 = logicalNumericFloatLong('>', i.step, 0);
       clr.l     -(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.l    12(A0),-(A7)
       pea       62
       jsr       (A5)
       add.w     #12,A7
       move.b    D0,D4
; vResLog4 = logicalNumericFloatLong('<', i.step, 0);
       clr.l     -(A7)
       move.l    A2,D1
       move.l    D1,A0
       move.l    12(A0),-(A7)
       pea       60
       jsr       (A5)
       add.w     #12,A7
       move.b    D0,D3
       bra       basNext_19
basNext_18:
; }
; else
; {
; vResLog1 = (*endVarCont > i.target);
       move.l    D2,A0
       move.l    A2,D0
       move.l    D0,A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       ble.s     basNext_20
       moveq     #1,D0
       bra.s     basNext_21
basNext_20:
       clr.l     D0
basNext_21:
       move.b    D0,D6
; vResLog2 = (*endVarCont < i.target);
       move.l    D2,A0
       move.l    A2,D0
       move.l    D0,A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       bge.s     basNext_22
       moveq     #1,D0
       bra.s     basNext_23
basNext_22:
       clr.l     D0
basNext_23:
       move.b    D0,D5
; vResLog3 = (i.step > 0);
       move.l    A2,D0
       move.l    D0,A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       ble.s     basNext_24
       moveq     #1,D0
       bra.s     basNext_25
basNext_24:
       clr.l     D0
basNext_25:
       move.b    D0,D4
; vResLog4 = (i.step < 0);
       move.l    A2,D0
       move.l    D0,A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       bge.s     basNext_26
       moveq     #1,D0
       bra.s     basNext_27
basNext_26:
       clr.l     D0
basNext_27:
       move.b    D0,D3
basNext_19:
; }
; // compara se ja chegou no final  //     if ((i.step > 0 && *endVarCont>i.target) || (i.step < 0 && *endVarCont<i.target))
; if ((vResLog3 && vResLog1) || (vResLog4 && vResLog2))
       tst.b     D4
       beq.s     basNext_31
       tst.b     D6
       bne.s     basNext_30
basNext_31:
       tst.b     D3
       beq.s     basNext_28
       tst.b     D5
       beq.s     basNext_28
basNext_30:
; return 0 ;  // all done
       clr.l     D0
       bra.s     basNext_5
basNext_28:
; *changedPointer = i.progPosPointerRet;  // loop
       move.l    A2,D0
       move.l    D0,A0
       move.l    _changedPointer.L,A1
       move.l    16(A0),(A1)
; if (vRetVar < 0)
       cmp.b     #0,D7
       bge.s     basNext_32
; forPush(i);  // otherwise, restore the info
       move.l    A2,D1
       move.l    D1,A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _forPush
       add.w     #20,A7
basNext_32:
; return 0;
       clr.l     D0
basNext_5:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Salta para uma linha se erro
; // Syntaxe:
; //          ON <VAR> GOSUB <num.linha 1>,<num.linha 2>,...,,<num.linha n>
; //          ON <VAR> GOTO <num.linha 1>,<num.linha 2>,...,<num.linha n>
; //--------------------------------------------------------------------------------------
; int basOnVar(void)
; {
       xdef      _basOnVar
_basOnVar:
       link      A6,#-12
       movem.l   D2/D3/D4/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       _nextToken.L,A4
       lea       _pointerRunProg.L,A5
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -12(A6)
; unsigned char *vTempPointer;
; unsigned int vSalto;
; unsigned int iSalto = 0;
       clr.l     -4(A6)
; unsigned int ix;
; vTempPointer = *pointerRunProg;
       move.l    (A5),A0
       move.l    (A0),D3
; if (isalphas(*vTempPointer))
       move.l    D3,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq       basOnVar_1
; {
; // procura pela variavel no forStack
; nextToken();
       jsr       (A4)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basOnVar_3
       clr.l     D0
       bra       basOnVar_5
basOnVar_3:
; if (*token_type != VARIABLE)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basOnVar_6
; {
; *vErroProc = 4;
       move.l    (A2),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_6:
; }
; putback();
       jsr       _putback
; getExp(&iSalto);
       pea       -4(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basOnVar_8
       clr.l     D0
       bra       basOnVar_5
basOnVar_8:
; if (*value_type != '%')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       beq.s     basOnVar_10
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_10:
; }
; if (iSalto == 0 || iSalto > 255)
       move.l    -4(A6),D0
       beq.s     basOnVar_14
       move.l    -4(A6),D0
       cmp.l     #255,D0
       bls.s     basOnVar_12
basOnVar_14:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_12:
       bra.s     basOnVar_2
basOnVar_1:
; }
; }
; else
; {
; *vErroProc = 4;
       move.l    (A2),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_2:
; }
; vTempPointer = *pointerRunProg;
       move.l    (A5),A0
       move.l    (A0),D3
; // Se nao for goto ou gosub, erro
; if (*vTempPointer != 0x89 && *vTempPointer != 0x8A)
       move.l    D3,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #137,D0
       beq.s     basOnVar_15
       move.l    D3,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #138,D0
       beq.s     basOnVar_15
; {
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_15:
; }
; vSalto = *vTempPointer;
       move.l    D3,A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-8(A6)
; ix = 0;
       clr.l     D4
; *pointerRunProg = *pointerRunProg + 1;
       move.l    (A5),A0
       addq.l    #1,(A0)
; while (1)
basOnVar_17:
; {
; getExp(&vNumLin); // get target value
       pea       -12(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basOnVar_22
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basOnVar_20
basOnVar_22:
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_20:
; }
; ix++;
       addq.l    #1,D4
; if (ix == iSalto)
       cmp.l     -4(A6),D4
       bne.s     basOnVar_23
; break;
       bra       basOnVar_19
basOnVar_23:
; nextToken();
       jsr       (A4)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basOnVar_25
       clr.l     D0
       bra       basOnVar_5
basOnVar_25:
; // Deve ser uma virgula
; if (*token!=',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basOnVar_27
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_27:
; }
; nextToken();
       jsr       (A4)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basOnVar_29
       clr.l     D0
       bra       basOnVar_5
basOnVar_29:
; putback();
       jsr       _putback
       bra       basOnVar_17
basOnVar_19:
; }
; if (ix == 0 || ix > iSalto)
       tst.l     D4
       beq.s     basOnVar_33
       cmp.l     -4(A6),D4
       bls.s     basOnVar_31
basOnVar_33:
; {
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_31:
; }
; vNextAddrGoto = findNumberLine(vNumLin, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    -12(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D2
; if (vSalto == 0x89)
       move.l    -8(A6),D0
       cmp.l     #137,D0
       bne       basOnVar_34
; {
; // GOTO
; if (vNextAddrGoto > 0)
       cmp.l     #0,D2
       bls       basOnVar_36
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -12(A6),D0
       bne.s     basOnVar_38
; {
; *changedPointer = vNextAddrGoto;
       move.l    _changedPointer.L,A0
       move.l    D2,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_38:
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_36:
; }
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_34:
; }
; }
; else
; {
; // GOSUB
; if (vNextAddrGoto > 0)
       cmp.l     #0,D2
       bls       basOnVar_40
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -12(A6),D0
       bne.s     basOnVar_42
; {
; gosubPush(*nextAddr);
       move.l    _nextAddr.L,A0
       move.l    (A0),-(A7)
       jsr       _gosubPush
       addq.w    #4,A7
; *changedPointer = vNextAddrGoto;
       move.l    _changedPointer.L,A0
       move.l    D2,(A0)
; return 0;
       clr.l     D0
       bra.s     basOnVar_5
basOnVar_42:
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
       bra.s     basOnVar_5
basOnVar_40:
; }
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basOnVar_5:
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; return 0;
; }
; //--------------------------------------------------------------------------------------
; // Salta para uma linha se erro
; // Syntaxe:
; //          ONERR GOTO <num.linha>
; //--------------------------------------------------------------------------------------
; int basOnErr(void)
; {
       xdef      _basOnErr
_basOnErr:
       link      A6,#-20
       movem.l   D2/A2,-(A7)
       lea       _vErroProc.L,A2
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -18(A6)
; unsigned char sqtdtam[10];
; unsigned char *vTempPointer;
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-4(A6)
; // Se nao for goto, erro
; if (*vTempPointer != 0x89)
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #137,D0
       beq.s     basOnErr_1
; {
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basOnErr_3
basOnErr_1:
; }
; // soma mais um pra ir pro numero da linha
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
; getExp(&vNumLin); // get target value
       pea       -18(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basOnErr_6
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basOnErr_4
basOnErr_6:
; *vErroProc = 17;
       move.l    (A2),A0
       move.w    #17,(A0)
; return 0;
       clr.l     D0
       bra       basOnErr_3
basOnErr_4:
; }
; vNextAddrGoto = findNumberLine(vNumLin, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    -18(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D2
; if (vNextAddrGoto > 0)
       cmp.l     #0,D2
       bls       basOnErr_7
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -18(A6),D0
       bne.s     basOnErr_9
; {
; *onErrGoto = vNextAddrGoto;
       move.l    _onErrGoto.L,A0
       move.l    D2,(A0)
; return 0;
       clr.l     D0
       bra.s     basOnErr_3
basOnErr_9:
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
       bra.s     basOnErr_3
basOnErr_7:
; }
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basOnErr_3:
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; return 0;
; }
; //--------------------------------------------------------------------------------------
; // Salta para uma linha, sem retorno
; // Syntaxe:
; //          GOTO <num.linha>
; //--------------------------------------------------------------------------------------
; int basGoto(void)
; {
       xdef      _basGoto
_basGoto:
       link      A6,#-16
       movem.l   D2/A2,-(A7)
       lea       _vErroProc.L,A2
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -14(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basGoto_1
       clr.l     D0
       bra       basGoto_3
basGoto_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basGoto_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basGoto_4
basGoto_6:
; {
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basGoto_3
basGoto_4:
; }
; putback();
       jsr       _putback
; getExp(&vNumLin); // get target value
       pea       -14(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basGoto_9
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basGoto_7
basGoto_9:
; *vErroProc = 17;
       move.l    (A2),A0
       move.w    #17,(A0)
; return 0;
       clr.l     D0
       bra       basGoto_3
basGoto_7:
; }
; vNextAddrGoto = findNumberLine(vNumLin, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    -14(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D2
; if (vNextAddrGoto > 0)
       cmp.l     #0,D2
       bls       basGoto_10
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -14(A6),D0
       bne.s     basGoto_12
; {
; *changedPointer = vNextAddrGoto;
       move.l    _changedPointer.L,A0
       move.l    D2,(A0)
; return 0;
       clr.l     D0
       bra.s     basGoto_3
basGoto_12:
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
       bra.s     basGoto_3
basGoto_10:
; }
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basGoto_3:
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; return 0;
; }
; //--------------------------------------------------------------------------------------
; // Salta para uma linha e guarda a posicao atual para voltar
; // Syntaxe:
; //          GOSUB <num.linha>
; //--------------------------------------------------------------------------------------
; int basGosub(void)
; {
       xdef      _basGosub
_basGosub:
       link      A6,#-4
       movem.l   D2/A2,-(A7)
       lea       _vErroProc.L,A2
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basGosub_1
       clr.l     D0
       bra       basGosub_3
basGosub_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basGosub_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basGosub_4
basGosub_6:
; {
; *vErroProc = 14;
       move.l    (A2),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basGosub_3
basGosub_4:
; }
; putback();
       jsr       _putback
; getExp(&vNumLin); // get target valuedel 20
       pea       -4(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basGosub_9
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basGosub_7
basGosub_9:
; *vErroProc = 17;
       move.l    (A2),A0
       move.w    #17,(A0)
; return 0;
       clr.l     D0
       bra       basGosub_3
basGosub_7:
; }
; vNextAddrGoto = findNumberLine(vNumLin, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    -4(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,D2
; if (vNextAddrGoto > 0)
       cmp.l     #0,D2
       bls       basGosub_10
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    D2,A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    D2,A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -4(A6),D0
       bne.s     basGosub_12
; {
; gosubPush(*nextAddr);
       move.l    _nextAddr.L,A0
       move.l    (A0),-(A7)
       jsr       _gosubPush
       addq.w    #4,A7
; *changedPointer = vNextAddrGoto;
       move.l    _changedPointer.L,A0
       move.l    D2,(A0)
; return 0;
       clr.l     D0
       bra.s     basGosub_3
basGosub_12:
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
       bra.s     basGosub_3
basGosub_10:
; }
; }
; else
; {
; *vErroProc = 7;
       move.l    (A2),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basGosub_3:
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; return 0;
; }
; //--------------------------------------------------------------------------------------
; // Retorna de um Gosub
; // Syntaxe:
; //          RETURN
; //--------------------------------------------------------------------------------------
; int basReturn(void)
; {
       xdef      _basReturn
_basReturn:
       link      A6,#-4
; unsigned long i;
; i = gosubPop();
       jsr       _gosubPop
       move.l    D0,-4(A6)
; *changedPointer = i;
       move.l    _changedPointer.L,A0
       move.l    -4(A6),(A0)
; return 0;
       clr.l     D0
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Retorna um numero real como inteiro
; // Syntaxe:
; //          INT(<number real>)
; //--------------------------------------------------------------------------------------
; int basInt(void)
; {
       xdef      _basInt
_basInt:
       link      A6,#-4
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       _value_type.L,A4
       lea       _nextToken.L,A5
; int vReal = 0, vResult = 0;
       clr.l     -4(A6)
       clr.l     D2
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basInt_1
       clr.l     D0
       bra       basInt_3
basInt_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basInt_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basInt_6
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basInt_4
basInt_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basInt_3
basInt_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basInt_7
       clr.l     D0
       bra       basInt_3
basInt_7:
; putback();
       jsr       _putback
; getExp(&vReal); //
       pea       -4(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basInt_9
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basInt_3
basInt_9:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basInt_11
       clr.l     D0
       bra       basInt_3
basInt_11:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basInt_13
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basInt_3
basInt_13:
; }
; if (*value_type == '#')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basInt_15
; vResult = fppInt(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,D2
       bra.s     basInt_16
basInt_15:
; else
; vResult = vReal;
       move.l    -4(A6),D2
basInt_16:
; *value_type='%';
       move.l    (A4),A0
       move.b    #37,(A0)
; *token=((int)(vResult & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,2(A0)
; *(token + 3)=(vResult & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A3),A0
       move.b    D0,3(A0)
; return 0;
       clr.l     D0
basInt_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Retorna um numero absoluto como inteiro
; // Syntaxe:
; //          ABS(<number real>)
; //--------------------------------------------------------------------------------------
; int basAbs(void)
; {
       xdef      _basAbs
_basAbs:
       link      A6,#-4
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _token.L,A3
       lea       _value_type.L,A4
       lea       _nextToken.L,A5
; int vReal = 0, vResult = 0;
       clr.l     -4(A6)
       clr.l     D2
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basAbs_1
       clr.l     D0
       bra       basAbs_3
basAbs_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basAbs_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basAbs_6
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basAbs_4
basAbs_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAbs_3
basAbs_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basAbs_7
       clr.l     D0
       bra       basAbs_3
basAbs_7:
; putback();
       jsr       _putback
; getExp(&vReal); //
       pea       -4(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basAbs_9
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basAbs_3
basAbs_9:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basAbs_11
       clr.l     D0
       bra       basAbs_3
basAbs_11:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basAbs_13
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAbs_3
basAbs_13:
; }
; if (*value_type == '#')
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basAbs_15
; vResult = fppAbs(vReal);
       move.l    -4(A6),-(A7)
       jsr       _fppAbs
       addq.w    #4,A7
       move.l    D0,D2
       bra.s     basAbs_17
basAbs_15:
; else
; {
; vResult = vReal;
       move.l    -4(A6),D2
; if (vResult < 1)
       cmp.l     #1,D2
       bge.s     basAbs_17
; vResult = vResult * (-1);
       move.l    D2,-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),D2
       addq.w    #8,A7
basAbs_17:
; }
; *value_type='%';
       move.l    (A4),A0
       move.b    #37,(A0)
; *token=((int)(vResult & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A3),A0
       move.b    D0,2(A0)
; *(token + 3)=(vResult & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A3),A0
       move.b    D0,3(A0)
; return 0;
       clr.l     D0
basAbs_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Retorna um numero randomicamente
; // Syntaxe:
; //          RND(<number>)
; //--------------------------------------------------------------------------------------
; int basRnd(void)
; {
       xdef      _basRnd
_basRnd:
       link      A6,#-48
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       -20(A6),A3
       lea       _token.L,A4
       lea       _randSeed.L,A5
; unsigned long vRand;
; int vReal = 0, vResult = 0;
       clr.l     -48(A6)
       clr.l     -44(A6)
; unsigned char vTRand[20];
; unsigned char vSRand[20];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRnd_1
       clr.l     D0
       bra       basRnd_3
basRnd_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basRnd_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basRnd_6
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basRnd_4
basRnd_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basRnd_3
basRnd_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRnd_7
       clr.l     D0
       bra       basRnd_3
basRnd_7:
; putback();
       jsr       _putback
; getExp(&vReal); //
       pea       -48(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basRnd_9
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basRnd_3
basRnd_9:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRnd_11
       clr.l     D0
       bra       basRnd_3
basRnd_11:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type != CLOSEPARENT)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basRnd_13
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basRnd_3
basRnd_13:
; }
; if (vReal == 0)
       move.l    -48(A6),D0
       bne.s     basRnd_15
; {
; vRand = *randSeed;
       move.l    (A5),A0
       move.l    (A0),D2
       bra       basRnd_20
basRnd_15:
; }
; else if (vReal >= -1 && vReal < 0)
       move.l    -48(A6),D0
       cmp.l     #-1,D0
       blt       basRnd_17
       move.l    -48(A6),D0
       cmp.l     #0,D0
       bge       basRnd_17
; {
; vRand = *(vmfp + Reg_TADR);
       move.l    _vmfp.L,A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    D0,D2
; vRand = (vRand << 3);
       lsl.l     #3,D2
; vRand += 0x466;
       add.l     #1126,D2
; vRand -= ((*(vmfp + Reg_TADR)) * 3);
       move.l    _vmfp.L,A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       mulu.w    #3,D0
       and.l     #65535,D0
       sub.l     D0,D2
; *randSeed = vRand;
       move.l    (A5),A0
       move.l    D2,(A0)
       bra       basRnd_20
basRnd_17:
; }
; else if (vReal > 0 && vReal <= 1)
       move.l    -48(A6),D0
       cmp.l     #0,D0
       ble       basRnd_19
       move.l    -48(A6),D0
       cmp.l     #1,D0
       bgt.s     basRnd_19
; {
; vRand = *randSeed;
       move.l    (A5),A0
       move.l    (A0),D2
; vRand = (vRand << 3);
       lsl.l     #3,D2
; vRand += 0x466;
       add.l     #1126,D2
; vRand -= ((*(vmfp + Reg_TADR)) * 3);
       move.l    _vmfp.L,A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       mulu.w    #3,D0
       and.l     #65535,D0
       sub.l     D0,D2
; *randSeed = vRand;
       move.l    (A5),A0
       move.l    D2,(A0)
       bra.s     basRnd_20
basRnd_19:
; }
; else
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basRnd_3
basRnd_20:
; }
; itoa(vRand, vTRand, 10);
       pea       10
       pea       -40(A6)
       move.l    D2,-(A7)
       jsr       _itoa
       add.w     #12,A7
; vSRand[0] = '0';
       move.b    #48,(A3)
; vSRand[1] = '.';
       move.b    #46,1(A3)
; vSRand[2] = 0x00;
       clr.b     2(A3)
; strcat(vSRand, vTRand);
       pea       -40(A6)
       move.l    A3,-(A7)
       jsr       _strcat
       addq.w    #8,A7
; vRand = floatStringToFpp(vSRand);
       move.l    A3,-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,D2
; *value_type='#';
       move.l    _value_type.L,A0
       move.b    #35,(A0)
; *token=((int)(vRand & 0xFF000000) >> 24);
       move.l    D2,D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A4),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vRand & 0x00FF0000) >> 16);
       move.l    D2,D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    (A4),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vRand & 0x0000FF00) >> 8);
       move.l    D2,D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    (A4),A0
       move.b    D0,2(A0)
; *(token + 3)=(vRand & 0x000000FF);
       move.l    D2,D0
       and.l     #255,D0
       move.l    (A4),A0
       move.b    D0,3(A0)
; return 0;
       clr.l     D0
basRnd_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Posiciona o cursor na tela atual.
; // Syntaxe:
; //          LOCATE <x>,<y>
; //--------------------------------------------------------------------------------------
; int basLocate(void)
; {
       xdef      _basLocate
_basLocate:
       link      A6,#-20
       movem.l   D2/D3/D4/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       _nextToken.L,A4
       lea       -20(A6),A5
; int vColumn = 0;
       clr.l     D4
; int vRow = 0;
       clr.l     D3
; unsigned char answer[20];
; int *iVal = answer;
       move.l    A5,D2
; nextToken();
       jsr       (A4)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLocate_1
       clr.l     D0
       bra       basLocate_3
basLocate_1:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLocate_4
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_4:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A5,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLocate_6
       clr.l     D0
       bra       basLocate_3
basLocate_6:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLocate_8
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_8:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basLocate_10
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basLocate_10:
; }
; }
; vColumn = *iVal;
       move.l    D2,A0
       move.l    (A0),D4
; if (vColumn < 0 || vColumn > vdpMaxCols)
       cmp.l     #0,D4
       blt.s     basLocate_14
       move.b    _vdpMaxCols.L,D0
       and.l     #255,D0
       cmp.l     D0,D4
       bls.s     basLocate_12
basLocate_14:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_12:
; }
; nextToken();
       jsr       (A4)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLocate_15
       clr.l     D0
       bra       basLocate_3
basLocate_15:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basLocate_17
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_17:
; }
; nextToken();
       jsr       (A4)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLocate_19
       clr.l     D0
       bra       basLocate_3
basLocate_19:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLocate_21
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_21:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A5,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLocate_23
       clr.l     D0
       bra       basLocate_3
basLocate_23:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLocate_25
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_25:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basLocate_27
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basLocate_27:
; }
; }
; vRow = *iVal;
       move.l    D2,A0
       move.l    (A0),D3
; if (vRow < 0 || vRow > vdpMaxRows)
       cmp.l     #0,D3
       blt.s     basLocate_31
       move.b    _vdpMaxRows.L,D0
       and.l     #255,D0
       cmp.l     D0,D3
       bls.s     basLocate_29
basLocate_31:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra.s     basLocate_3
basLocate_29:
; }
; vdp_set_cursor(vColumn, vRow);
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; return 0;
       clr.l     D0
basLocate_3:
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Finaliza o programa sem erro
; // Syntaxe:
; //          END
; //--------------------------------------------------------------------------------------
; int basEnd(void)
; {
       xdef      _basEnd
_basEnd:
; *nextAddr = 0;
       move.l    _nextAddr.L,A0
       clr.l     (A0)
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // Finaliza o programa com erro
; // Syntaxe:
; //          STOP
; //--------------------------------------------------------------------------------------
; int basStop(void)
; {
       xdef      _basStop
_basStop:
; *vErroProc = 1;
       move.l    _vErroProc.L,A0
       move.w    #1,(A0)
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // Retorna 'n' Espaços
; // Syntaxe:
; //          SPC <numero>
; //--------------------------------------------------------------------------------------
; int basSpc(void)
; {
       xdef      _basSpc
_basSpc:
       link      A6,#-48
       movem.l   D2/D3/D4/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       _token_type.L,A4
       lea       _nextToken.L,A5
; unsigned int vSpc = 0;
       clr.l     D4
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     D2
       clr.l     -48(A6)
       clr.l     -44(A6)
       clr.l     -40(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -32(A6),A0
       move.l    A0,D3
; unsigned char vTab, vColumn;
; unsigned char sqtdtam[10];
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basSpc_1
       clr.l     D0
       bra       basSpc_3
basSpc_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basSpc_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basSpc_6
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basSpc_4
basSpc_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basSpc_3
basSpc_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basSpc_7
       clr.l     D0
       bra       basSpc_3
basSpc_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basSpc_9
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basSpc_3
basSpc_9:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -32(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basSpc_11
       clr.l     D0
       bra       basSpc_3
basSpc_11:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basSpc_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basSpc_3
basSpc_13:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basSpc_15
; {
; *iVal = fppInt(*iVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basSpc_15:
; }
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basSpc_17
       clr.l     D0
       bra       basSpc_3
basSpc_17:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basSpc_19
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra.s     basSpc_3
basSpc_19:
; }
; vSpc=(char)*iVal;
       move.l    D3,A0
       move.l    (A0),D4
; for (ix = 0; ix < vSpc; ix++)
       clr.l     D2
basSpc_21:
       cmp.l     D4,D2
       bhs.s     basSpc_23
; *(token + ix) = ' ';
       move.l    _token.L,A0
       move.b    #32,0(A0,D2.L)
       addq.l    #1,D2
       bra       basSpc_21
basSpc_23:
; *(token + ix) = 0;
       move.l    _token.L,A0
       clr.b     0(A0,D2.L)
; *value_type = '$';
       move.l    (A3),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basSpc_3:
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Advance 'n' columns
; // Syntaxe:
; //          TAB <numero>
; //--------------------------------------------------------------------------------------
; int basTab(void)
; {
       xdef      _basTab
_basTab:
       link      A6,#-52
       movem.l   D2/D3/D4/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       _token_type.L,A4
       lea       _nextToken.L,A5
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -50(A6)
       clr.l     -46(A6)
       clr.l     -42(A6)
       clr.l     -38(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -30(A6),A0
       move.l    A0,D3
; unsigned char vTab, vColumn;
; unsigned char sqtdtam[10];
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basTab_1
       clr.l     D0
       bra       basTab_3
basTab_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basTab_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basTab_6
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basTab_4
basTab_6:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basTab_3
basTab_4:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basTab_7
       clr.l     D0
       bra       basTab_3
basTab_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basTab_9
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basTab_3
basTab_9:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -30(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basTab_11
       clr.l     D0
       bra       basTab_3
basTab_11:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basTab_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basTab_3
basTab_13:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basTab_15
; {
; *iVal = fppInt(*iVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basTab_15:
; }
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basTab_17
       clr.l     D0
       bra       basTab_3
basTab_17:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basTab_19
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basTab_3
basTab_19:
; }
; vTab=(char)*iVal;
       move.l    D3,A0
       move.l    (A0),D0
       move.b    D0,D4
; vColumn = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,D0
       move.b    D0,D2
; if (vTab>vColumn)
       cmp.b     D2,D4
       bls       basTab_21
; {
; vColumn = vColumn + vTab;
       add.b     D4,D2
; while (vColumn>vdpMaxCols)
basTab_23:
       cmp.b     _vdpMaxCols.L,D2
       bls.s     basTab_25
; {
; vColumn = vColumn - vdpMaxCols;
       move.b    _vdpMaxCols.L,D0
       sub.b     D0,D2
; if (videoCursorPosRowY < vdpMaxRows)
       move.b    _vdpMaxRows.L,D0
       and.w     #255,D0
       cmp.w     _videoCursorPosRowY.L,D0
       bls.s     basTab_26
; videoCursorPosRowY += 1;
       addq.w    #1,_videoCursorPosRowY.L
basTab_26:
       bra       basTab_23
basTab_25:
; }
; vdp_set_cursor(vColumn, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
basTab_21:
; }
; *token = ' ';
       move.l    _token.L,A0
       move.b    #32,(A0)
; *value_type='$';
       move.l    (A3),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basTab_3:
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Screen Mode Switch
; // Syntaxe:
; //          SCREEN <mode>, [spriteSize]
; //              Mode: (0,1,2)
; //                  0: Text Screen Mode (40 cols x 24 rows)
; //                  1: Low Resolution Screen Mode (64x48)   
; //                  2: High Resolution Screen Mode (256x192)
; //
; //              SpriteSize: (0,1,2,3)
; //                  0: 8x8 pixels (standard).  (Default)
; //                  1: 8x8 pixels (magnified to 16x16).
; //                  2: 16x16 pixels (standard).
; //                  3: 16x16 pixels (magnified to 32x32).
; //--------------------------------------------------------------------------------------
; int basScreen(void)
; {
       xdef      _basScreen
_basScreen:
       link      A6,#-20
       movem.l   D2/D3/A2/A3,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
; unsigned char answer[20];
; int *iVal = answer;
       lea       -20(A6),A0
       move.l    A0,D3
; int vModeAux;
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basScreen_1
       clr.l     D0
       bra       basScreen_3
basScreen_1:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basScreen_4
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_4:
; }
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -20(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basScreen_6
       clr.l     D0
       bra       basScreen_3
basScreen_6:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basScreen_8
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_8:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basScreen_10
; {
; *iVal = fppInt(*iVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basScreen_10:
; }
; vModeAux = *iVal;
       move.l    D3,A0
       move.l    (A0),D2
; if (vModeAux < 0 || vModeAux > 2)
       cmp.l     #0,D2
       blt.s     basScreen_14
       cmp.l     #2,D2
       ble.s     basScreen_12
basScreen_14:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_12:
; }
; switch (vModeAux)
       cmp.l     #1,D2
       beq.s     basScreen_18
       bgt.s     basScreen_20
       tst.l     D2
       beq.s     basScreen_17
       bra       basScreen_16
basScreen_20:
       cmp.l     #2,D2
       beq.s     basScreen_19
       bra       basScreen_16
basScreen_17:
; {
; case 0:
; basText();
       jsr       _basText
; break;
       bra       basScreen_16
basScreen_18:
; case 1:
; vdp_init(VDP_MODE_MULTICOLOR, 0, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       pea       2
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdpMaxCols = 63;
       move.b    #63,_vdpMaxCols.L
; vdpMaxRows = 47;
       move.b    #47,_vdpMaxRows.L
; vdpModeBas = VDP_MODE_MULTICOLOR;
       move.b    #2,_vdpModeBas.L
; break;
       bra       basScreen_16
basScreen_19:
; case 2:
; vdp_init(VDP_MODE_G2, 0x0, 1, 0);
       clr.l     -(A7)
       pea       1
       clr.l     -(A7)
       pea       1
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdpMaxCols = 255;
       move.b    #255,_vdpMaxCols.L
; vdpMaxRows = 191;
       move.b    #191,_vdpMaxRows.L
; vdpModeBas = VDP_MODE_G2;
       move.b    #1,_vdpModeBas.L
; vdp_set_bdcolor(VDP_BLACK);
       pea       1
       move.l    1110,A0
       jsr       (A0)
       addq.w    #4,A7
; bgcolorBas = VDP_BLACK;
       move.b    #1,_bgcolorBas.L
; basPaintSyncTables();
       jsr       @basic_basPaintSyncTables
; break;
basScreen_16:
; }
; return 0;
       clr.l     D0
basScreen_3:
       movem.l   (A7)+,D2/D3/A2/A3
       unlk      A6
       rts
; }
; int basText(void)
; {
       xdef      _basText
_basText:
; fgcolorBas = VDP_WHITE;
       move.b    #15,_fgcolorBas.L
; bgcolorBas = VDP_BLACK;
       move.b    #1,_bgcolorBas.L
; vdp_init(VDP_MODE_TEXT, (fgcolorBas<<4) | (bgcolorBas & 0x0f), 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.b    _fgcolorBas.L,D1
       lsl.b     #4,D1
       move.l    D0,-(A7)
       move.b    _bgcolorBas.L,D0
       and.b     #15,D0
       or.b      D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       3
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdpMaxCols = 39;
       move.b    #39,_vdpMaxCols.L
; vdpMaxRows = 23;
       move.b    #23,_vdpMaxRows.L
; vdpModeBas = VDP_MODE_TEXT;
       move.b    #3,_vdpModeBas.L
; clearScr();     
       move.l    1054,A0
       jsr       (A0)
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // Muda as cores atuais de frente e fundo.
; // Syntaxe:
; //          COLOR <foreground>,<background>
; //          COLOR ,<background>
; //          COLOR <foreground>
; //--------------------------------------------------------------------------------------
; int basColor(void)
; {
       xdef      _basColor
_basColor:
       link      A6,#-20
       movem.l   D2/D3/D4/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       _tok.L,A4
       lea       _nextToken.L,A5
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -20(A6),A0
       move.l    A0,D2
; int foreground = fgcolorBas;
       move.b    _fgcolorBas.L,D0
       and.l     #255,D0
       move.l    D0,D4
; int background = bgcolorBas;
       move.b    _bgcolorBas.L,D0
       and.l     #255,D0
       move.l    D0,D3
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basColor_1
       clr.l     D0
       bra       basColor_3
basColor_1:
; if (*tok == EOL || *tok == FINISHED)
       move.l    (A4),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basColor_6
       move.l    (A4),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basColor_4
basColor_6:
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_4:
; }
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq       basColor_20
; {
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basColor_9
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_9:
; }
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -20(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basColor_11
       clr.l     D0
       bra       basColor_3
basColor_11:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basColor_13
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_13:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basColor_15
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basColor_15:
; }
; foreground = *iVal;
       move.l    D2,A0
       move.l    (A0),D4
; if (foreground < 0 || foreground > 15)
       cmp.l     #0,D4
       blt.s     basColor_19
       cmp.l     #15,D4
       ble.s     basColor_17
basColor_19:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_17:
; }
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;        
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basColor_20
       clr.l     D0
       bra       basColor_3
basColor_20:
; }
; if (*token == ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basColor_37
; {
; nextToken();
       jsr       (A5)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basColor_24
       clr.l     D0
       bra       basColor_3
basColor_24:
; if (*tok == EOL || *tok == FINISHED)
       move.l    (A4),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basColor_28
       move.l    (A4),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basColor_26
basColor_28:
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_26:
; }
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basColor_29
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_29:
; }
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -20(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basColor_31
       clr.l     D0
       bra       basColor_3
basColor_31:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basColor_33
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_33:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basColor_35
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basColor_35:
; }
; background = *iVal;
       move.l    D2,A0
       move.l    (A0),D3
; if (background < 0 || background > 15)
       cmp.l     #0,D3
       blt.s     basColor_39
       cmp.l     #15,D3
       ble.s     basColor_37
basColor_39:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra.s     basColor_3
basColor_37:
; }
; }
; fgcolorBas = (unsigned char)foreground;
       move.b    D4,_fgcolorBas.L
; bgcolorBas = (unsigned char)background;
       move.b    D3,_bgcolorBas.L
; vdp_textcolor(fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1126,A0
       jsr       (A0)
       addq.w    #8,A7
; *value_type='%';
       move.l    (A3),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basColor_3:
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Desenha um circulo ou ovoide.
; // Syntaxe:
; //          CIRCLE x,y,rh[,rv]
; //--------------------------------------------------------------------------------------
; static void basPlotEllipsePoints(int x0, int y0, int dx, int dy)
; {
@basic_basPlotEllipsePoints:
       link      A6,#0
       movem.l   D2/D3/D4/D5,-(A7)
       move.l    16(A6),D2
       move.l    8(A6),D3
       move.l    20(A6),D4
       move.l    12(A6),D5
; vdp_plot_hires((unsigned char)(x0 + dx), (unsigned char)(y0 + dy), fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D5,D1
       add.l     D4,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D3,D1
       add.l     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires((unsigned char)(x0 - dx), (unsigned char)(y0 + dy), fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D5,D1
       add.l     D4,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D3,D1
       sub.l     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires((unsigned char)(x0 + dx), (unsigned char)(y0 - dy), fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D5,D1
       sub.l     D4,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D3,D1
       add.l     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; vdp_plot_hires((unsigned char)(x0 - dx), (unsigned char)(y0 - dy), fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D5,D1
       sub.l     D4,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D3,D1
       sub.l     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       movem.l   (A7)+,D2/D3/D4/D5
       unlk      A6
       rts
; }
; static void basReadNumericArg(int *pValue)
; {
@basic_basReadNumericArg:
       link      A6,#-20
       movem.l   D2/A2/A3,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -20(A6),A0
       move.l    A0,D2
; if (*token_type == QUOTE)
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     @basic_basReadNumericArg_1
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra       @basic_basReadNumericArg_3
@basic_basReadNumericArg_1:
; }
; if (*token_type == DELIMITER && (*token == '\r' || *token == 0x00))
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #1,D0
       bne.s     @basic_basReadNumericArg_4
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #13,D0
       beq.s     @basic_basReadNumericArg_6
       move.l    _token.L,A0
       move.b    (A0),D0
       bne.s     @basic_basReadNumericArg_4
@basic_basReadNumericArg_6:
; {
; *vErroProc = 2;
       move.l    (A2),A0
       move.w    #2,(A0)
; return;
       bra       @basic_basReadNumericArg_3
@basic_basReadNumericArg_4:
; }
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -20(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     @basic_basReadNumericArg_7
       bra       @basic_basReadNumericArg_3
@basic_basReadNumericArg_7:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     @basic_basReadNumericArg_9
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return;
       bra.s     @basic_basReadNumericArg_3
@basic_basReadNumericArg_9:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     @basic_basReadNumericArg_11
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
@basic_basReadNumericArg_11:
; }
; *pValue = *iVal;
       move.l    D2,A0
       move.l    8(A6),A1
       move.l    (A0),(A1)
@basic_basReadNumericArg_3:
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; int basCircle(void)
; {
       xdef      _basCircle
_basCircle:
       link      A6,#-24
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _nextToken.L,A3
; int centerX = 0, centerY = 0, horizontalRadius = 0, verticalRadius = 0;
       clr.l     -24(A6)
       clr.l     -20(A6)
       clr.l     -16(A6)
       clr.l     -12(A6)
; long rx2, ry2, twoRx2, twoRy2, d1, d2, dx, dy;
; int x, y;
; if (vdpModeBas != VDP_MODE_G2)
       move.b    _vdpModeBas.L,D0
       cmp.b     #1,D0
       beq.s     basCircle_1
; {
; *vErroProc = 24;
       move.l    (A2),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basCircle_3
basCircle_1:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_4
       clr.l     D0
       bra       basCircle_3
basCircle_4:
; basReadNumericArg(&centerX);
       pea       -24(A6)
       jsr       @basic_basReadNumericArg
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_6
       clr.l     D0
       bra       basCircle_3
basCircle_6:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_8
       clr.l     D0
       bra       basCircle_3
basCircle_8:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basCircle_10
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basCircle_3
basCircle_10:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_12
       clr.l     D0
       bra       basCircle_3
basCircle_12:
; basReadNumericArg(&centerY);
       pea       -20(A6)
       jsr       @basic_basReadNumericArg
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_14
       clr.l     D0
       bra       basCircle_3
basCircle_14:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_16
       clr.l     D0
       bra       basCircle_3
basCircle_16:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basCircle_18
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basCircle_3
basCircle_18:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_20
       clr.l     D0
       bra       basCircle_3
basCircle_20:
; basReadNumericArg(&horizontalRadius);
       pea       -16(A6)
       jsr       @basic_basReadNumericArg
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_22
       clr.l     D0
       bra       basCircle_3
basCircle_22:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_24
       clr.l     D0
       bra       basCircle_3
basCircle_24:
; if (*token == ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne.s     basCircle_26
; {
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_28
       clr.l     D0
       bra       basCircle_3
basCircle_28:
; basReadNumericArg(&verticalRadius);
       pea       -12(A6)
       jsr       @basic_basReadNumericArg
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basCircle_30
       clr.l     D0
       bra       basCircle_3
basCircle_30:
       bra.s     basCircle_27
basCircle_26:
; }
; else
; {
; verticalRadius = horizontalRadius;
       move.l    -16(A6),-12(A6)
basCircle_27:
; }
; if (horizontalRadius < 0)
       move.l    -16(A6),D0
       cmp.l     #0,D0
       bge.s     basCircle_32
; horizontalRadius = -horizontalRadius;
       move.l    -16(A6),D0
       neg.l     D0
       move.l    D0,-16(A6)
basCircle_32:
; if (verticalRadius < 0)
       move.l    -12(A6),D0
       cmp.l     #0,D0
       bge.s     basCircle_34
; verticalRadius = -verticalRadius;
       move.l    -12(A6),D0
       neg.l     D0
       move.l    D0,-12(A6)
basCircle_34:
; if (horizontalRadius == 0 && verticalRadius == 0)
       move.l    -16(A6),D0
       bne       basCircle_36
       move.l    -12(A6),D0
       bne       basCircle_36
; {
; vdp_plot_hires((unsigned char)centerX, (unsigned char)centerY, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -20(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -24(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       bra       basCircle_55
basCircle_36:
; }
; else if (horizontalRadius == 0)
       move.l    -16(A6),D0
       bne       basCircle_38
; {
; for (y = -verticalRadius; y <= verticalRadius; y++)
       move.l    -12(A6),D0
       neg.l     D0
       move.l    D0,D2
basCircle_40:
       cmp.l     -12(A6),D2
       bgt       basCircle_42
; vdp_plot_hires((unsigned char)centerX, (unsigned char)(centerY + y), fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -20(A6),D1
       add.l     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -24(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,D2
       bra       basCircle_40
basCircle_42:
       bra       basCircle_55
basCircle_38:
; }
; else if (verticalRadius == 0)
       move.l    -12(A6),D0
       bne       basCircle_43
; {
; for (x = -horizontalRadius; x <= horizontalRadius; x++)
       move.l    -16(A6),D0
       neg.l     D0
       move.l    D0,D3
basCircle_45:
       cmp.l     -16(A6),D3
       bgt       basCircle_47
; vdp_plot_hires((unsigned char)(centerX + x), (unsigned char)centerY, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -20(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -24(A6),D1
       add.l     D3,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,D3
       bra       basCircle_45
basCircle_47:
       bra       basCircle_55
basCircle_43:
; }
; else
; {
; rx2 = (long)horizontalRadius * (long)horizontalRadius;
       move.l    -16(A6),-(A7)
       move.l    -16(A6),-(A7)
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D5
; ry2 = (long)verticalRadius * (long)verticalRadius;
       move.l    -12(A6),-(A7)
       move.l    -12(A6),-(A7)
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D4
; twoRx2 = rx2 << 1;
       move.l    D5,D0
       asl.l     #1,D0
       move.l    D0,A4
; twoRy2 = ry2 << 1;
       move.l    D4,D0
       asl.l     #1,D0
       move.l    D0,-8(A6)
; x = 0;
       clr.l     D3
; y = verticalRadius;
       move.l    -12(A6),D2
; dx = 0;
       moveq     #0,D7
; dy = twoRx2 * y;
       move.l    A4,-(A7)
       move.l    D2,-(A7)
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D6
; d1 = ry2 - (rx2 * verticalRadius) + (rx2 / 4);
       move.l    D4,D0
       move.l    D5,-(A7)
       move.l    -12(A6),-(A7)
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D5,-(A7)
       pea       4
       jsr       LDIV
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,-4(A6)
; while (dx < dy)
basCircle_48:
       cmp.l     D6,D7
       bge       basCircle_50
; {
; basPlotEllipsePoints(centerX, centerY, x, y);
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       move.l    -20(A6),-(A7)
       move.l    -24(A6),-(A7)
       jsr       @basic_basPlotEllipsePoints
       add.w     #16,A7
; if (d1 < 0)
       move.l    -4(A6),D0
       cmp.l     #0,D0
       bge.s     basCircle_51
; {
; x++;
       addq.l    #1,D3
; dx += twoRy2;
       move.l    -8(A6),D0
       add.l     D0,D7
; d1 += dx + ry2;
       move.l    D7,D0
       add.l     D4,D0
       add.l     D0,-4(A6)
       bra.s     basCircle_52
basCircle_51:
; }
; else
; {
; x++;
       addq.l    #1,D3
; y--;
       subq.l    #1,D2
; dx += twoRy2;
       move.l    -8(A6),D0
       add.l     D0,D7
; dy -= twoRx2;
       sub.l     A4,D6
; d1 += dx - dy + ry2;
       move.l    D7,D0
       sub.l     D6,D0
       add.l     D4,D0
       add.l     D0,-4(A6)
basCircle_52:
       bra       basCircle_48
basCircle_50:
; }
; }
; d2 = (ry2 * (long)(x * x)) + (ry2 * x) + (ry2 / 4) + (rx2 * (long)(y * y)) - (twoRx2 * y) + rx2 - (rx2 * ry2);
       move.l    D3,-(A7)
       move.l    D3,-(A7)
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D4,-(A7)
       move.l    D0,-(A7)
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D4,-(A7)
       move.l    D3,-(A7)
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D4,-(A7)
       pea       4
       jsr       LDIV
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D2,-(A7)
       move.l    D2,-(A7)
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       move.l    D5,-(A7)
       move.l    D1,-(A7)
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    A4,-(A7)
       move.l    D2,-(A7)
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       add.l     D5,D0
       move.l    D5,-(A7)
       move.l    D4,-(A7)
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,A5
; while (y >= 0)
basCircle_53:
       cmp.l     #0,D2
       blt       basCircle_55
; {
; basPlotEllipsePoints(centerX, centerY, x, y);
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       move.l    -20(A6),-(A7)
       move.l    -24(A6),-(A7)
       jsr       @basic_basPlotEllipsePoints
       add.w     #16,A7
; if (d2 > 0)
       move.l    A5,D0
       cmp.l     #0,D0
       ble.s     basCircle_56
; {
; y--;
       subq.l    #1,D2
; dy -= twoRx2;
       sub.l     A4,D6
; d2 += rx2 - dy;
       move.l    D5,D0
       sub.l     D6,D0
       add.l     D0,A5
       bra.s     basCircle_57
basCircle_56:
; }
; else
; {
; x++;
       addq.l    #1,D3
; y--;
       subq.l    #1,D2
; dx += twoRy2;
       move.l    -8(A6),D0
       add.l     D0,D7
; dy -= twoRx2;
       sub.l     A4,D6
; d2 += dx - dy + rx2;
       move.l    D7,D0
       sub.l     D6,D0
       add.l     D5,D0
       add.l     D0,A5
basCircle_57:
       bra       basCircle_53
basCircle_55:
; }
; }
; }
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basCircle_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Desenha um retangulo de x1,y1 ate x2,y2
; // Syntaxe:
; //          RECT x1,y1,x2,y2
; //--------------------------------------------------------------------------------------
; int basRect(void)
; {
       xdef      _basRect
_basRect:
       link      A6,#-16
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _nextToken.L,A3
       lea       @basic_basReadNumericArg.L,A5
; int x1 = 0, y1 = 0, x2 = 0, y2 = 0, temp;
       clr.l     -16(A6)
       clr.l     -12(A6)
       clr.l     -8(A6)
       clr.l     -4(A6)
; int ix, iy, left, right, top, bottom;
; if (vdpModeBas != VDP_MODE_G2)
       move.b    _vdpModeBas.L,D0
       cmp.b     #1,D0
       beq.s     basRect_1
; {
; *vErroProc = 24;
       move.l    (A2),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basRect_3
basRect_1:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_4
       clr.l     D0
       bra       basRect_3
basRect_4:
; basReadNumericArg(&x1);
       pea       -16(A6)
       jsr       (A5)
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_6
       clr.l     D0
       bra       basRect_3
basRect_6:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_8
       clr.l     D0
       bra       basRect_3
basRect_8:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basRect_10
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basRect_3
basRect_10:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_12
       clr.l     D0
       bra       basRect_3
basRect_12:
; basReadNumericArg(&y1);
       pea       -12(A6)
       jsr       (A5)
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_14
       clr.l     D0
       bra       basRect_3
basRect_14:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_16
       clr.l     D0
       bra       basRect_3
basRect_16:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basRect_18
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basRect_3
basRect_18:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_20
       clr.l     D0
       bra       basRect_3
basRect_20:
; basReadNumericArg(&x2);
       pea       -8(A6)
       jsr       (A5)
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_22
       clr.l     D0
       bra       basRect_3
basRect_22:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_24
       clr.l     D0
       bra       basRect_3
basRect_24:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basRect_26
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basRect_3
basRect_26:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_28
       clr.l     D0
       bra       basRect_3
basRect_28:
; basReadNumericArg(&y2);
       pea       -4(A6)
       jsr       (A5)
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basRect_30
       clr.l     D0
       bra       basRect_3
basRect_30:
; left = x1;
       move.l    -16(A6),D7
; right = x2;
       move.l    -8(A6),D6
; top = y1;
       move.l    -12(A6),D5
; bottom = y2;
       move.l    -4(A6),D4
; if (right < left)
       cmp.l     D7,D6
       bge.s     basRect_32
; {
; temp = left;
       move.l    D7,A4
; left = right;
       move.l    D6,D7
; right = temp;
       move.l    A4,D6
basRect_32:
; }
; if (bottom < top)
       cmp.l     D5,D4
       bge.s     basRect_34
; {
; temp = top;
       move.l    D5,A4
; top = bottom;
       move.l    D4,D5
; bottom = temp;
       move.l    A4,D4
basRect_34:
; }
; for (ix = left; ix <= right; ix++)
       move.l    D7,D3
basRect_36:
       cmp.l     D6,D3
       bgt.s     basRect_38
; vdp_plot_hires((unsigned char)ix, (unsigned char)top, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,D3
       bra       basRect_36
basRect_38:
; for (iy = top; iy <= bottom; iy++)
       move.l    D5,D2
basRect_39:
       cmp.l     D4,D2
       bgt.s     basRect_41
; vdp_plot_hires((unsigned char)left, (unsigned char)iy, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,D2
       bra       basRect_39
basRect_41:
; if (bottom != top)
       cmp.l     D5,D4
       beq       basRect_46
; {
; for (ix = left; ix <= right; ix++)
       move.l    D7,D3
basRect_44:
       cmp.l     D6,D3
       bgt.s     basRect_46
; vdp_plot_hires((unsigned char)ix, (unsigned char)bottom, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,D3
       bra       basRect_44
basRect_46:
; }
; if (right != left)
       cmp.l     D7,D6
       beq       basRect_51
; {
; for (iy = top; iy <= bottom; iy++)
       move.l    D5,D2
basRect_49:
       cmp.l     D4,D2
       bgt.s     basRect_51
; vdp_plot_hires((unsigned char)right, (unsigned char)iy, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,D2
       bra       basRect_49
basRect_51:
; }
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basRect_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Flood fill a partir de um ponto ate encontrar bordas de outra cor.
; // Syntaxe:
; //          PAINT x,y,c
; //--------------------------------------------------------------------------------------
; static unsigned char basPaintReadPixel(unsigned char x, unsigned char y)
; {
@basic_basPaintReadPixel:
       link      A6,#-4
       movem.l   D2/D3,-(A7)
; unsigned int offset;
; unsigned char pixel;
; unsigned char color;
; offset = (unsigned int)(8 * (x / 8)) + (unsigned int)(y % 8) + (unsigned int)(256 * (y / 8));
       move.b    11(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       and.w     #255,D0
       mulu.w    #8,D0
       and.l     #255,D0
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
; setReadAddress(paintPatternTable + offset);
       move.l    @basic_paintPatternTable.L,D1
       add.l     D2,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(paintPatternTable + offset);
       move.l    @basic_paintPatternTable.L,D1
       add.l     D2,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; pixel = *paintVdpData;
       move.l    @basic_paintVdpData.L,A0
       move.b    (A0),-1(A6)
; setReadAddress(paintColorTable + offset);
       move.l    @basic_paintColorTable.L,D1
       add.l     D2,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; setReadAddress(paintColorTable + offset);
       move.l    @basic_paintColorTable.L,D1
       add.l     D2,D1
       move.l    D1,-(A7)
       move.l    1198,A0
       jsr       (A0)
       addq.w    #4,A7
; color = *paintVdpData;
       move.l    @basic_paintVdpData.L,A0
       move.b    (A0),D3
; if (pixel & (0x80 >> (x % 8)))
       move.b    -1(A6),D0
       and.w     #255,D0
       move.w    #128,D1
       move.l    D0,-(A7)
       move.b    11(A6),D0
       and.l     #65535,D0
       divu.w    #8,D0
       swap      D0
       and.w     #255,D0
       asr.w     D0,D1
       move.l    (A7)+,D0
       and.w     D1,D0
       beq.s     @basic_basPaintReadPixel_1
; return (color >> 4) & 0x0F;
       move.b    D3,D0
       lsr.b     #4,D0
       and.b     #15,D0
       bra.s     @basic_basPaintReadPixel_3
@basic_basPaintReadPixel_1:
; return color & 0x0F;
       move.b    D3,D0
       and.b     #15,D0
@basic_basPaintReadPixel_3:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; static int basPaintPush(unsigned int *stackTop, unsigned char x, unsigned char y)
; {
@basic_basPaintPush:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; if (*stackTop >= PAINT_STACK_SIZE)
       move.l    D2,A0
       move.l    (A0),D0
       cmp.l     #4096,D0
       blo.s     @basic_basPaintPush_1
; {
; *vErroProc = 21;
       move.l    _vErroProc.L,A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra.s     @basic_basPaintPush_3
@basic_basPaintPush_1:
; }
; paintStackX[*stackTop] = x;
       move.l    D2,A0
       move.l    (A0),D0
       lea       @basic_paintStackX.L,A0
       move.b    15(A6),0(A0,D0.L)
; paintStackY[*stackTop] = y;
       move.l    D2,A0
       move.l    (A0),D0
       lea       @basic_paintStackY.L,A0
       move.b    19(A6),0(A0,D0.L)
; *stackTop = *stackTop + 1;
       move.l    D2,A0
       addq.l    #1,(A0)
; return 1;
       moveq     #1,D0
@basic_basPaintPush_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; static int basPaintQueueRow(unsigned int *stackTop, unsigned char left, unsigned char right, unsigned char y, unsigned char targetColor)
; {
@basic_basPaintQueueRow:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.b    23(A6),D3
       and.l     #255,D3
; unsigned int x = left;
       move.b    15(A6),D0
       and.l     #255,D0
       move.l    D0,D2
; while (x <= right)
@basic_basPaintQueueRow_1:
       move.b    19(A6),D0
       and.l     #255,D0
       cmp.l     D0,D2
       bhi       @basic_basPaintQueueRow_3
; {
; if (basPaintReadPixel((unsigned char)x, y) == targetColor)
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       @basic_basPaintReadPixel
       addq.w    #8,A7
       cmp.b     27(A6),D0
       bne       @basic_basPaintQueueRow_11
; {
; if (!basPaintPush(stackTop, (unsigned char)x, y))
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    8(A6),-(A7)
       jsr       @basic_basPaintPush
       add.w     #12,A7
       tst.l     D0
       bne.s     @basic_basPaintQueueRow_6
; return 0;
       clr.l     D0
       bra       @basic_basPaintQueueRow_8
@basic_basPaintQueueRow_6:
; while (x <= right && basPaintReadPixel((unsigned char)x, y) == targetColor)
@basic_basPaintQueueRow_9:
       move.b    19(A6),D0
       and.l     #255,D0
       cmp.l     D0,D2
       bhi.s     @basic_basPaintQueueRow_11
       and.l     #255,D3
       move.l    D3,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       @basic_basPaintReadPixel
       addq.w    #8,A7
       cmp.b     27(A6),D0
       bne.s     @basic_basPaintQueueRow_11
; x++;
       addq.l    #1,D2
       bra       @basic_basPaintQueueRow_9
@basic_basPaintQueueRow_11:
; }
; x++;
       addq.l    #1,D2
       bra       @basic_basPaintQueueRow_1
@basic_basPaintQueueRow_3:
; }
; return 1;
       moveq     #1,D0
@basic_basPaintQueueRow_8:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; int basPaint(void)
; {
       xdef      _basPaint
_basPaint:
       link      A6,#-20
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _nextToken.L,A3
       lea       @basic_basPaintReadPixel.L,A4
       lea       -4(A6),A5
; int xValue = 0, yValue = 0, colorValue = 0;
       clr.l     -18(A6)
       clr.l     -14(A6)
       clr.l     -10(A6)
; unsigned char startX, startY, fillColor, targetColor;
; unsigned int stackTop = 0;
       clr.l     (A5)
; int left, right, x, y;
; if (vdpModeBas != VDP_MODE_G2)
       move.b    _vdpModeBas.L,D0
       cmp.b     #1,D0
       beq.s     basPaint_1
; {
; *vErroProc = 24;
       move.l    (A2),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_1:
; }
; basPaintSyncTables();
       jsr       @basic_basPaintSyncTables
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_4
       clr.l     D0
       bra       basPaint_3
basPaint_4:
; basReadNumericArg(&xValue);
       pea       -18(A6)
       jsr       @basic_basReadNumericArg
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_6
       clr.l     D0
       bra       basPaint_3
basPaint_6:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_8
       clr.l     D0
       bra       basPaint_3
basPaint_8:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basPaint_10
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_10:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_12
       clr.l     D0
       bra       basPaint_3
basPaint_12:
; basReadNumericArg(&yValue);
       pea       -14(A6)
       jsr       @basic_basReadNumericArg
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_14
       clr.l     D0
       bra       basPaint_3
basPaint_14:
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_16
       clr.l     D0
       bra       basPaint_3
basPaint_16:
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basPaint_18
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_18:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_20
       clr.l     D0
       bra       basPaint_3
basPaint_20:
; basReadNumericArg(&colorValue);
       pea       -10(A6)
       jsr       @basic_basReadNumericArg
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPaint_22
       clr.l     D0
       bra       basPaint_3
basPaint_22:
; if (xValue < 0 || xValue > vdpMaxCols || yValue < 0 || yValue > vdpMaxRows)
       move.l    -18(A6),D0
       cmp.l     #0,D0
       blt.s     basPaint_26
       move.b    _vdpMaxCols.L,D0
       and.l     #255,D0
       cmp.l     -18(A6),D0
       blo.s     basPaint_26
       move.l    -14(A6),D0
       cmp.l     #0,D0
       blt.s     basPaint_26
       move.b    _vdpMaxRows.L,D0
       and.l     #255,D0
       cmp.l     -14(A6),D0
       bhs.s     basPaint_24
basPaint_26:
; {
; *vErroProc = 25;
       move.l    (A2),A0
       move.w    #25,(A0)
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_24:
; }
; if (colorValue < 0 || colorValue > 15)
       move.l    -10(A6),D0
       cmp.l     #0,D0
       blt.s     basPaint_29
       move.l    -10(A6),D0
       cmp.l     #15,D0
       ble.s     basPaint_27
basPaint_29:
; {
; *vErroProc = 5;
       move.l    (A2),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_27:
; }
; startX = (unsigned char)xValue;
       move.l    -18(A6),D0
       move.b    D0,-6(A6)
; startY = (unsigned char)yValue;
       move.l    -14(A6),D0
       move.b    D0,-5(A6)
; fillColor = (unsigned char)colorValue;
       move.l    -10(A6),D0
       move.b    D0,D7
; targetColor = basPaintReadPixel(startX, startY);
       move.b    -5(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -6(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
       move.b    D0,D6
; if (targetColor == fillColor)
       cmp.b     D7,D6
       bne.s     basPaint_30
; {
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_30:
; }
; if (!basPaintPush(&stackTop, startX, startY))
       move.b    -5(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -6(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,-(A7)
       jsr       @basic_basPaintPush
       add.w     #12,A7
       tst.l     D0
       bne.s     basPaint_32
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_32:
; while (stackTop > 0)
basPaint_34:
       move.l    (A5),D0
       cmp.l     #0,D0
       bls       basPaint_36
; {
; stackTop--;
       subq.l    #1,(A5)
; x = paintStackX[stackTop];
       move.l    (A5),D0
       lea       @basic_paintStackX.L,A0
       move.b    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    D0,D3
; y = paintStackY[stackTop];
       move.l    (A5),D0
       lea       @basic_paintStackY.L,A0
       move.b    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    D0,D2
; if (basPaintReadPixel((unsigned char)x, (unsigned char)y) != targetColor)
       and.l     #255,D2
       move.l    D2,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       jsr       (A4)
       addq.w    #8,A7
       cmp.b     D6,D0
       beq.s     basPaint_37
; continue;
       bra       basPaint_54
basPaint_37:
; left = x;
       move.l    D3,D5
; while (left > 0 && basPaintReadPixel((unsigned char)(left - 1), (unsigned char)y) == targetColor)
basPaint_39:
       cmp.l     #0,D5
       ble.s     basPaint_41
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    D5,D1
       subq.l    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
       cmp.b     D6,D0
       bne.s     basPaint_41
; left--;
       subq.l    #1,D5
       bra       basPaint_39
basPaint_41:
; right = x;
       move.l    D3,D4
; while (right < vdpMaxCols && basPaintReadPixel((unsigned char)(right + 1), (unsigned char)y) == targetColor)
basPaint_42:
       move.b    _vdpMaxCols.L,D0
       and.l     #255,D0
       cmp.l     D0,D4
       bhs.s     basPaint_44
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    D4,D1
       addq.l    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
       cmp.b     D6,D0
       bne.s     basPaint_44
; right++;
       addq.l    #1,D4
       bra       basPaint_42
basPaint_44:
; for (x = left; x <= right; x++)
       move.l    D5,D3
basPaint_45:
       cmp.l     D4,D3
       bgt.s     basPaint_47
; vdp_plot_hires((unsigned char)x, (unsigned char)y, fillColor, 0);
       clr.l     -(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       addq.l    #1,D3
       bra       basPaint_45
basPaint_47:
; if (y > 0)
       cmp.l     #0,D2
       ble       basPaint_50
; {
; if (!basPaintQueueRow(&stackTop, (unsigned char)left, (unsigned char)right, (unsigned char)(y - 1), targetColor))
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    D2,D1
       subq.l    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       move.l    A5,-(A7)
       jsr       @basic_basPaintQueueRow
       add.w     #20,A7
       tst.l     D0
       bne.s     basPaint_50
; return 0;
       clr.l     D0
       bra       basPaint_3
basPaint_50:
; }
; if (y < vdpMaxRows)
       move.b    _vdpMaxRows.L,D0
       and.l     #255,D0
       cmp.l     D0,D2
       bhs       basPaint_54
; {
; if (!basPaintQueueRow(&stackTop, (unsigned char)left, (unsigned char)right, (unsigned char)(y + 1), targetColor))
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    D2,D1
       addq.l    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       move.l    A5,-(A7)
       jsr       @basic_basPaintQueueRow
       add.w     #20,A7
       tst.l     D0
       bne.s     basPaint_54
; return 0;
       clr.l     D0
       bra.s     basPaint_3
basPaint_54:
       bra       basPaint_34
basPaint_36:
; }
; }
; *value_type = '%';
       move.l    _value_type.L,A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basPaint_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Coloca um dot ou preenche uma area com a color previamente definida
; // Syntaxe:
; //          PLOT <x entre 0 e 63/255>, <y entre 0 e 47/191>
; //--------------------------------------------------------------------------------------
; int basPlot(void)
; {
       xdef      _basPlot
_basPlot:
       link      A6,#-52
       movem.l   D2/A2/A3/A4,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       -32(A6),A4
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -52(A6)
       clr.l     -48(A6)
       clr.l     -44(A6)
       clr.l     -40(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       move.l    A4,D2
; unsigned char vx, vy;
; unsigned char sqtdtam[10];
; if (vdpModeBas == VDP_MODE_TEXT)
       move.b    _vdpModeBas.L,D0
       cmp.b     #3,D0
       bne.s     basPlot_1
; {
; *vErroProc = 24;
       move.l    (A2),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPlot_4
       clr.l     D0
       bra       basPlot_3
basPlot_4:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPlot_6
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_6:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A4,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPlot_8
       clr.l     D0
       bra       basPlot_3
basPlot_8:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPlot_10
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_10:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basPlot_12
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basPlot_12:
; }
; }
; vx=(char)*iVal;
       move.l    D2,A0
       move.l    (A0),D0
       move.b    D0,-12(A6)
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basPlot_14
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_14:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPlot_16
       clr.l     D0
       bra       basPlot_3
basPlot_16:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPlot_18
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_18:
; }
; else { /* is expression */
; //putback();
; getExp(&answer);
       move.l    A4,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPlot_20
       clr.l     D0
       bra       basPlot_3
basPlot_20:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPlot_22
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_22:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basPlot_24
; {
; *iVal = fppInt(*iVal);
       move.l    D2,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D2,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basPlot_24:
; }
; }
; vy=(char)*iVal;
       move.l    D2,A0
       move.l    (A0),D0
       move.b    D0,-11(A6)
; vdp_plot_color(vx, vy, fgcolorBas);
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -12(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1106,A0
       jsr       (A0)
       add.w     #12,A7
; *value_type='%';
       move.l    (A3),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basPlot_3:
       movem.l   (A7)+,D2/A2/A3/A4
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Desenha uma linha horizontal de x1, y1 até x2, y1
; // Syntaxe:
; //          HLIN <x1>, <x2> at <y1>
; //               x1 e x2 : de 0 a 63
; //                    y1 : de 0 a 47
; //
; // Desenha uma linha vertical de x1, y1 até x1, y2
; // Syntaxe:
; //          VLIN <y1>, <y2> at <x1>
; //                    x1 : de 0 a 63
; //               y1 e y2 : de 0 a 47
; //--------------------------------------------------------------------------------------
; int basHVlin(unsigned char vTipo)   // 1 - HLIN, 2 - VLIN
; {
       xdef      _basHVlin
_basHVlin:
       link      A6,#-48
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
       lea       -30(A6),A4
       lea       _fppInt.L,A5
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     D2
       clr.l     -46(A6)
       clr.l     -42(A6)
       clr.l     -38(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       move.l    A4,D3
; unsigned char vx1, vx2, vy;
; unsigned char sqtdtam[10];
; if (vdpModeBas != VDP_MODE_MULTICOLOR)
       move.b    _vdpModeBas.L,D0
       cmp.b     #2,D0
       beq.s     basHVlin_1
; {
; *vErroProc = 24;
       move.l    (A2),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basHVlin_4
       clr.l     D0
       bra       basHVlin_3
basHVlin_4:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHVlin_6
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_6:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A4,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basHVlin_8
       clr.l     D0
       bra       basHVlin_3
basHVlin_8:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHVlin_10
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_10:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHVlin_12
; {
; *iVal = fppInt(*iVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basHVlin_12:
; }
; }
; vx1=(char)*iVal;
       move.l    D3,A0
       move.l    (A0),D0
       move.b    D0,D5
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basHVlin_14
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_14:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basHVlin_16
       clr.l     D0
       bra       basHVlin_3
basHVlin_16:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHVlin_18
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_18:
; }
; else { /* is expression */
; //putback();
; getExp(&answer);
       move.l    A4,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basHVlin_20
       clr.l     D0
       bra       basHVlin_3
basHVlin_20:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHVlin_22
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_22:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHVlin_24
; {
; *iVal = fppInt(*iVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basHVlin_24:
; }
; }
; vx2=(char)*iVal;
       move.l    D3,A0
       move.l    (A0),D0
       move.b    D0,D4
; if (*token != 0xBA) // AT Token
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #186,D0
       beq.s     basHVlin_26
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_26:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basHVlin_28
       clr.l     D0
       bra       basHVlin_3
basHVlin_28:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHVlin_30
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_30:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       move.l    A4,-(A7)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basHVlin_32
       clr.l     D0
       bra       basHVlin_3
basHVlin_32:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHVlin_34
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_34:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHVlin_36
; {
; *iVal = fppInt(*iVal);
       move.l    D3,A0
       move.l    (A0),-(A7)
       jsr       (A5)
       addq.w    #4,A7
       move.l    D3,A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basHVlin_36:
; }
; }
; vy=(char)*iVal;
       move.l    D3,A0
       move.l    (A0),D0
       move.b    D0,D6
; if (vx2 < vx1)
       cmp.b     D5,D4
       bhs.s     basHVlin_38
; {
; ix = vx1;
       and.l     #255,D5
       move.l    D5,D2
; vx1 = vx2;
       move.b    D4,D5
; vx2 = ix;
       move.b    D2,D4
basHVlin_38:
; }
; if (vTipo == 1)   // HLIN
       move.b    11(A6),D0
       cmp.b     #1,D0
       bne       basHVlin_40
; {
; for(ix = vx1; ix <= vx2; ix++)
       and.l     #255,D5
       move.l    D5,D2
basHVlin_42:
       and.l     #255,D4
       cmp.l     D4,D2
       bhi.s     basHVlin_44
; vdp_plot_color(ix, vy, fgcolorBas);
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1106,A0
       jsr       (A0)
       add.w     #12,A7
       addq.l    #1,D2
       bra       basHVlin_42
basHVlin_44:
       bra       basHVlin_47
basHVlin_40:
; }
; else   // VLIN
; {
; for(ix = vx1; ix <= vx2; ix++)
       and.l     #255,D5
       move.l    D5,D2
basHVlin_45:
       and.l     #255,D4
       cmp.l     D4,D2
       bhi.s     basHVlin_47
; vdp_plot_color(vy, ix, fgcolorBas);
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    1106,A0
       jsr       (A0)
       add.w     #12,A7
       addq.l    #1,D2
       bra       basHVlin_45
basHVlin_47:
; }
; *value_type='%';
       move.l    (A3),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basHVlin_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; // Syntaxe:
; //
; //--------------------------------------------------------------------------------------
; int basPoint(void)
; {
       xdef      _basPoint
_basPoint:
       link      A6,#-56
       movem.l   D2/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _nextToken.L,A3
       lea       _token_type.L,A4
       lea       _value_type.L,A5
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -56(A6)
       clr.l     -52(A6)
       clr.l     -48(A6)
       clr.l     -44(A6)
; unsigned char answer[20];
; int *iVal = answer;
       lea       -36(A6),A0
       move.l    A0,D2
; int *tval = token;
       move.l    _token.L,-16(A6)
; unsigned char vx, vy;
; unsigned char sqtdtam[10];
; if (vdpModeBas == VDP_MODE_TEXT)
       move.b    _vdpModeBas.L,D0
       cmp.b     #3,D0
       bne.s     basPoint_1
; {
; *vErroProc = 24;
       move.l    (A2),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basPoint_3
basPoint_1:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPoint_4
       clr.l     D0
       bra       basPoint_3
basPoint_4:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPoint_8
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basPoint_8
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basPoint_6
basPoint_8:
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basPoint_3
basPoint_6:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPoint_9
       clr.l     D0
       bra       basPoint_3
basPoint_9:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPoint_11
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPoint_3
basPoint_11:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPoint_13
       clr.l     D0
       bra       basPoint_3
basPoint_13:
; if (*value_type != '%')
       move.l    (A5),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       beq.s     basPoint_15
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPoint_3
basPoint_15:
; }
; }
; vx=(char)*iVal;
       move.l    D2,A0
       move.l    (A0),D0
       move.b    D0,-12(A6)
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPoint_17
       clr.l     D0
       bra       basPoint_3
basPoint_17:
; if (*token!=',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basPoint_19
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basPoint_3
basPoint_19:
; }
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPoint_21
       clr.l     D0
       bra       basPoint_3
basPoint_21:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPoint_23
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPoint_3
basPoint_23:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPoint_25
       clr.l     D0
       bra       basPoint_3
basPoint_25:
; if (*value_type != '%')
       move.l    (A5),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       beq.s     basPoint_27
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPoint_3
basPoint_27:
; }
; }
; vy=(char)*iVal;
       move.l    D2,A0
       move.l    (A0),D0
       move.b    D0,-11(A6)
; nextToken();
       jsr       (A3)
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basPoint_29
       clr.l     D0
       bra       basPoint_3
basPoint_29:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    (A4),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basPoint_31
; {
; *vErroProc = 15;
       move.l    (A2),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra.s     basPoint_3
basPoint_31:
; }
; // Ler Aqui.. a cor e devolver em *tval
; *tval = vdp_read_color_pixel(vx,vy);
       move.b    -11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -12(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1166,A0
       jsr       (A0)
       addq.w    #8,A7
       and.l     #255,D0
       move.l    -16(A6),A0
       move.l    D0,(A0)
; *value_type='%';
       move.l    (A5),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basPoint_3:
       movem.l   (A7)+,D2/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; // Syntaxe:
; //     LINE x,y TO x,y [TO x,y...]
; //--------------------------------------------------------------------------------------
; int basLine(void)
; {
       xdef      _basLine
_basLine:
       link      A6,#-88
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vErroProc.L,A2
       lea       _value_type.L,A3
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       move.w    #0,A5
       clr.l     -88(A6)
       clr.l     -84(A6)
       clr.l     -80(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -72(A6),A0
       move.l    A0,A4
; int rivx, rivy;
; unsigned long riy, rlvx, rlvy, vDiag;
; unsigned char vx, vy, vtemp;
; unsigned char sqtdtam[10];
; unsigned char vOper = 0;
       moveq     #0,D7
; int x,y,addx,addy,dx,dy;
; long P;
; if (vdpModeBas != VDP_MODE_G2)
       move.b    _vdpModeBas.L,D0
       cmp.b     #1,D0
       beq.s     basLine_1
; {
; *vErroProc = 24;
       move.l    (A2),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basLine_3
basLine_1:
; }
; do
; {
basLine_4:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLine_6
       clr.l     D0
       bra       basLine_3
basLine_6:
; if (*token != 0x86)
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq       basLine_8
; {
; if (*token_type == QUOTE) { // is string, error
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLine_10
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLine_3
basLine_10:
; }
; else { // is expression
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -72(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLine_12
       clr.l     D0
       bra       basLine_3
basLine_12:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLine_14
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLine_3
basLine_14:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basLine_16
; {
; *iVal = fppInt(*iVal);
       move.l    (A4),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,(A4)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basLine_16:
; }
; }
; vx = (unsigned char)*iVal;
       move.l    (A4),D0
       move.b    D0,D6
; if (*token != ',')
       move.l    _token.L,A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basLine_18
; {
; *vErroProc = 18;
       move.l    (A2),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basLine_3
basLine_18:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLine_20
       clr.l     D0
       bra       basLine_3
basLine_20:
; if (*token_type == QUOTE) { // is string, error
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLine_22
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLine_3
basLine_22:
; }
; else { // is expression
; //putback();
; getExp(&answer);
       pea       -72(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    (A2),A0
       tst.w     (A0)
       beq.s     basLine_24
       clr.l     D0
       bra       basLine_3
basLine_24:
; if (*value_type == '$')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLine_26
; {
; *vErroProc = 16;
       move.l    (A2),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLine_3
basLine_26:
; }
; if (*value_type == '#')
       move.l    (A3),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basLine_28
; {
; *iVal = fppInt(*iVal);
       move.l    (A4),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,(A4)
; *value_type = '%';
       move.l    (A3),A0
       move.b    #37,(A0)
basLine_28:
; }
; }
; vy = (unsigned char)*iVal;
       move.l    (A4),D0
       move.b    D0,D5
; if (!vOper)
       tst.b     D7
       bne.s     basLine_30
; vOper = 1;
       moveq     #1,D7
basLine_30:
       bra       basLine_9
basLine_8:
; }
; else
; {
; // *pointerRunProg = *pointerRunProg + 1;
; }
basLine_9:
; if (*tok == EOL || *tok == FINISHED || *token == 0x86)    // Fim de linha, programa ou token
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basLine_34
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basLine_34
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       bne       basLine_65
basLine_34:
; {
; if (!vOper)
       tst.b     D7
       bne.s     basLine_35
; {
; vOper = 2;
       moveq     #2,D7
       bra       basLine_41
basLine_35:
; }
; else if (vOper == 1)
       cmp.b     #1,D7
       bne       basLine_37
; {
; *lastHgrX = vx;
       move.l    _lastHgrX.L,A0
       move.b    D6,(A0)
; *lastHgrY = vy;
       move.l    _lastHgrY.L,A0
       move.b    D5,(A0)
; if (*token != 0x86)
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq.s     basLine_39
; vdp_plot_hires(vx, vy, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
basLine_39:
       bra       basLine_41
basLine_37:
; }
; else if (vOper == 2)
       cmp.b     #2,D7
       bne       basLine_41
; {
; if (vx == *lastHgrX && vy == *lastHgrY)
       move.l    _lastHgrX.L,A0
       cmp.b     (A0),D6
       bne       basLine_43
       move.l    _lastHgrY.L,A0
       cmp.b     (A0),D5
       bne.s     basLine_43
; vdp_plot_hires(vx, vy, fgcolorBas, bgcolorBas);
       move.b    _bgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       bra       basLine_62
basLine_43:
; else
; {
; dx = (vx - *lastHgrX);
       and.l     #255,D6
       move.l    D6,D0
       move.l    _lastHgrX.L,A0
       move.b    (A0),D1
       and.l     #255,D1
       sub.l     D1,D0
       move.l    D0,D4
; dy = (vy - *lastHgrY);
       and.l     #255,D5
       move.l    D5,D0
       move.l    _lastHgrY.L,A0
       move.b    (A0),D1
       and.l     #255,D1
       sub.l     D1,D0
       move.l    D0,D3
; if (dx < 0)
       cmp.l     #0,D4
       bge.s     basLine_45
; dx = dx * (-1);
       move.l    D4,-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),D4
       addq.w    #8,A7
basLine_45:
; if (dy < 0)
       cmp.l     #0,D3
       bge.s     basLine_47
; dy = dy * (-1);
       move.l    D3,-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),D3
       addq.w    #8,A7
basLine_47:
; x = *lastHgrX;
       move.l    _lastHgrX.L,A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-16(A6)
; y = *lastHgrY;
       move.l    _lastHgrY.L,A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-12(A6)
; if(*lastHgrX > vx)
       move.l    _lastHgrX.L,A0
       cmp.b     (A0),D6
       bhs.s     basLine_49
; addx = -1;
       move.l    #-1,-8(A6)
       bra.s     basLine_50
basLine_49:
; else
; addx = 1;
       move.l    #1,-8(A6)
basLine_50:
; if(*lastHgrY > vy)
       move.l    _lastHgrY.L,A0
       cmp.b     (A0),D5
       bhs.s     basLine_51
; addy = -1;
       move.l    #-1,-4(A6)
       bra.s     basLine_52
basLine_51:
; else
; addy = 1;
       move.l    #1,-4(A6)
basLine_52:
; if(dx >= dy)
       cmp.l     D3,D4
       blt       basLine_53
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
       move.w    #1,A5
basLine_55:
       move.l    D4,D0
       addq.l    #1,D0
       move.l    A5,D1
       cmp.l     D0,D1
       bgt       basLine_57
; {
; vdp_plot_hires(x, y, fgcolorBas, 0);
       clr.l     -(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -12(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -16(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; if (P < 0)
       cmp.l     #0,D2
       bge.s     basLine_58
; {
; P = P + (2 * dy);
       move.l    D3,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,D2
; x = (x + addx);
       move.l    -8(A6),D0
       add.l     D0,-16(A6)
       bra       basLine_59
basLine_58:
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
       move.l    -8(A6),D0
       add.l     D0,-16(A6)
; y = y + addy;
       move.l    -4(A6),D0
       add.l     D0,-12(A6)
basLine_59:
       addq.w    #1,A5
       bra       basLine_55
basLine_57:
       bra       basLine_62
basLine_53:
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
       move.w    #1,A5
basLine_60:
       move.l    D3,D0
       addq.l    #1,D0
       move.l    A5,D1
       cmp.l     D0,D1
       bgt       basLine_62
; {
; vdp_plot_hires(x, y, fgcolorBas, 0);
       clr.l     -(A7)
       move.b    _fgcolorBas.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -12(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -16(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; if (P < 0)
       cmp.l     #0,D2
       bge.s     basLine_63
; {
; P = P + (2 * dx);
       move.l    D4,-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,D2
; y = y + addy;
       move.l    -4(A6),D0
       add.l     D0,-12(A6)
       bra       basLine_64
basLine_63:
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
       move.l    -8(A6),D0
       add.l     D0,-16(A6)
; y = y + addy;
       move.l    -4(A6),D0
       add.l     D0,-12(A6)
basLine_64:
       addq.w    #1,A5
       bra       basLine_60
basLine_62:
; }
; }
; }
; }
; *lastHgrX = vx;
       move.l    _lastHgrX.L,A0
       move.b    D6,(A0)
; *lastHgrY = vy;
       move.l    _lastHgrY.L,A0
       move.b    D5,(A0)
basLine_41:
; }
; if (*token == 0x86)
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       bne.s     basLine_65
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       addq.l    #1,(A0)
basLine_65:
; }
; }
; vOper = 2;
       moveq     #2,D7
       move.l    _token.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq       basLine_4
; } while (*token == 0x86); // TO Token
; *value_type='%';
       move.l    (A3),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basLine_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Ler dados no comando DATA
; // Syntaxe:
; //          READ <variavel>
; //--------------------------------------------------------------------------------------
; int basRead(void)
; {
       xdef      _basRead
_basRead:
       link      A6,#-128
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _token.L,A2
       lea       _vDataLineAtu.L,A3
       lea       _vDataPointer.L,A4
       lea       _varName.L,A5
; int ix = 0, iy = 0, iz = 0;
       clr.l     -126(A6)
       clr.l     -122(A6)
       clr.l     -118(A6)
; unsigned char answer[100];
; int  *iVal = answer;
       lea       -114(A6),A0
       move.l    A0,D6
; unsigned char varTipo, vArray = 0;
       moveq     #0,D7
; unsigned char sqtdtam[10];
; unsigned long vTemp;
; unsigned char *vTempLine;
; long vRetFV;
; unsigned char *vTempPointer;
; // Pega a variavel
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     basRead_1
       clr.l     D0
       bra       basRead_3
basRead_1:
; if (*tok == EOL || *tok == FINISHED)
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basRead_6
       move.l    _tok.L,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basRead_4
basRead_6:
; {
; *vErroProc = 4;
       move.l    _vErroProc.L,A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_4:
; }
; if (*token_type == QUOTE) { /* is string */
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basRead_7
; *vErroProc = 4;
       move.l    _vErroProc.L,A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_7:
; }
; else { /* is expression */
; // Verifica se comeca com letra, pois tem que ser uma variavel
; if (!isalphas(*token))
       move.l    (A2),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basRead_9
; {
; *vErroProc = 4;
       move.l    _vErroProc.L,A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_9:
; }
; if (strlen(token) < 3)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basRead_11
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       moveq     #35,D3
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basRead_13
       move.l    (A2),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basRead_13
; varTipo = *(token + 1);
       move.l    (A2),A0
       move.b    1(A0),D3
basRead_13:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basRead_15
       move.l    (A2),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basRead_15
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    1(A0),1(A1)
       bra.s     basRead_16
basRead_15:
; else
; *(varName + 1) = 0x00;
       move.l    (A5),A0
       clr.b     1(A0)
basRead_16:
; *(varName + 2) = varTipo;
       move.l    (A5),A0
       move.b    D3,2(A0)
       bra       basRead_12
basRead_11:
; }
; else
; {
; *varName = *token;
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    (A2),A0
       move.l    (A5),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    (A2),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-118(A6)
; varTipo = *(varName + 2);
       move.l    (A5),A0
       move.b    2(A0),D3
basRead_12:
; }
; }
; // Procurar Data
; if (*vDataPointer == 0)
       move.l    (A4),A0
       move.l    (A0),D0
       bne       basRead_20
; {
; // Primeira Leitura, procura primeira ocorrencia
; *vDataLineAtu = *addrFirstLineNumber;
       move.l    _addrFirstLineNumber.L,A0
       move.l    (A3),A1
       move.l    (A0),(A1)
; do
; {
basRead_19:
; *vDataPointer = *vDataLineAtu;
       move.l    (A3),A0
       move.l    (A4),A1
       move.l    (A0),(A1)
; vTempLine = *vDataPointer;
       move.l    (A4),A0
       move.l    (A0),D2
; if (*(vTempLine + 5) == 0x98)    // Token do comando DATA é o primeiro comando da linha
       move.l    D2,A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #152,D0
       bne.s     basRead_21
; {
; *vDataPointer = (*vDataLineAtu + 6);
       move.l    (A3),A0
       move.l    (A0),D0
       addq.l    #6,D0
       move.l    (A4),A0
       move.l    D0,(A0)
; *vDataFirst = *vDataLineAtu;
       move.l    (A3),A0
       move.l    _vDataFirst.L,A1
       move.l    (A0),(A1)
; break;
       bra       basRead_20
basRead_21:
; }
; vTempLine = *vDataLineAtu;
       move.l    (A3),A0
       move.l    (A0),D2
; vTemp  = ((*vTempLine & 0xFF) << 16);
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,D4
; vTemp |= ((*(vTempLine + 1) & 0xFF) << 8);
       move.l    D2,A0
       move.b    1(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       or.l      D0,D4
; vTemp |= (*(vTempLine + 2) & 0xFF);
       move.l    D2,A0
       move.b    2(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,D4
; *vDataLineAtu = vTemp;
       move.l    (A3),A0
       move.l    D4,(A0)
; vTempLine = *vDataLineAtu;
       move.l    (A3),A0
       move.l    (A0),D2
       move.l    D2,A0
       tst.b     (A0)
       bne       basRead_19
basRead_20:
; } while (*vTempLine);
; }
; if (*vDataPointer == 0xFFFFFFFF)
       move.l    (A4),A0
       move.l    (A0),D0
       cmp.l     #-1,D0
       bne.s     basRead_23
; {
; *vErroProc = 26;
       move.l    _vErroProc.L,A0
       move.w    #26,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_23:
; }
; *vDataBkpPointerProg = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    _vDataBkpPointerProg.L,A1
       move.l    (A0),(A1)
; *pointerRunProg = *vDataPointer;
       move.l    (A4),A0
       move.l    _pointerRunProg.L,A1
       move.l    (A0),(A1)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     basRead_25
       clr.l     D0
       bra       basRead_3
basRead_25:
; if (*token_type == QUOTE) {
       move.l    _token_type.L,A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basRead_27
; strcpy(answer,token);
       move.l    (A2),-(A7)
       pea       -114(A6)
       jsr       _strcpy
       addq.w    #8,A7
; *value_type = '$';
       move.l    _value_type.L,A0
       move.b    #36,(A0)
       bra.s     basRead_29
basRead_27:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -114(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     basRead_29
       clr.l     D0
       bra       basRead_3
basRead_29:
; }
; // Pega ponteiro atual (proximo numero/char)
; *vDataPointer = *pointerRunProg + 1;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),D0
       addq.l    #1,D0
       move.l    (A4),A0
       move.l    D0,(A0)
; // Devolve ponteiro anterior
; *pointerRunProg = *vDataBkpPointerProg;
       move.l    _vDataBkpPointerProg.L,A0
       move.l    _pointerRunProg.L,A1
       move.l    (A0),(A1)
; // Se nao foi virgula, é final de linha, procura proximo comando data
; if (*token != ',')
       move.l    (A2),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq       basRead_34
; {
; do
; {
basRead_33:
; vTempLine = *vDataLineAtu;
       move.l    (A3),A0
       move.l    (A0),D2
; vTemp  = ((*(vTempLine) & 0xFF) << 16);
       move.l    D2,A0
       move.b    (A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,D4
; vTemp |= ((*(vTempLine + 1) & 0xFF) << 8);
       move.l    D2,A0
       move.b    1(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       or.l      D0,D4
; vTemp |= (*(vTempLine + 2) & 0xFF);
       move.l    D2,A0
       move.b    2(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,D4
; *vDataLineAtu = vTemp;
       move.l    (A3),A0
       move.l    D4,(A0)
; vTempLine = *vDataLineAtu;
       move.l    (A3),A0
       move.l    (A0),D2
; if (!*vDataLineAtu)
       move.l    (A3),A0
       tst.l     (A0)
       bne.s     basRead_35
; {
; *vDataPointer = 0xFFFFFFFF;
       move.l    (A4),A0
       move.l    #-1,(A0)
; break;
       bra       basRead_34
basRead_35:
; }
; *vDataPointer = *vDataLineAtu;
       move.l    (A3),A0
       move.l    (A4),A1
       move.l    (A0),(A1)
; vTempLine = *vDataPointer;
       move.l    (A4),A0
       move.l    (A0),D2
; if (*(vTempLine + 5) == 0x98)    // Token do comando DATA é o primeiro comando da linha
       move.l    D2,A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #152,D0
       bne.s     basRead_37
; {
; *vDataPointer = (*vDataLineAtu + 6);
       move.l    (A3),A0
       move.l    (A0),D0
       addq.l    #6,D0
       move.l    (A4),A0
       move.l    D0,(A0)
; break;
       bra.s     basRead_34
basRead_37:
; }
; vTempLine = *vDataLineAtu;
       move.l    (A3),A0
       move.l    (A0),D2
       move.l    D2,A0
       tst.b     (A0)
       bne       basRead_33
basRead_34:
; } while (*vTempLine);
; }
; if (varTipo != *value_type)
       move.l    _value_type.L,A0
       cmp.b     (A0),D3
       beq       basRead_39
; {
; if (*value_type == '$' || varTipo == '$')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basRead_43
       cmp.b     #36,D3
       bne.s     basRead_41
basRead_43:
; {
; *vErroProc = 16;
       move.l    _vErroProc.L,A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_41:
; }
; if (*value_type == '%')
       move.l    _value_type.L,A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne.s     basRead_44
; *iVal = fppReal(*iVal);
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D6,A0
       move.l    D0,(A0)
       bra.s     basRead_45
basRead_44:
; else
; *iVal = fppInt(*iVal);
       move.l    D6,A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D6,A0
       move.l    D0,(A0)
basRead_45:
; *value_type = varTipo;
       move.l    _value_type.L,A0
       move.b    D3,(A0)
basRead_39:
; }
; vTempPointer = *pointerRunProg;
       move.l    _pointerRunProg.L,A0
       move.l    (A0),-4(A6)
; if (*vTempPointer == 0x28)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       basRead_46
; {
; vRetFV = findVariable(varName);
       move.l    (A5),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,D5
; if (*vErroProc) return 0;
       move.l    _vErroProc.L,A0
       tst.w     (A0)
       beq.s     basRead_48
       clr.l     D0
       bra       basRead_3
basRead_48:
; if (!vRetFV)
       tst.l     D5
       bne.s     basRead_50
; {
; *vErroProc = 4;
       move.l    _vErroProc.L,A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_50:
; }
; vArray = 1;
       moveq     #1,D7
basRead_46:
; }
; if (!vArray)
       tst.b     D7
       bne       basRead_52
; {
; // assign the value
; vRetFV = findVariable(varName);
       move.l    (A5),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,D5
; // Se nao existe variavel e inicio sentenca, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     D5
       bne.s     basRead_54
; createVariable(varName, answer, varTipo);
       ext.w     D3
       ext.l     D3
       move.l    D3,-(A7)
       pea       -114(A6)
       move.l    (A5),-(A7)
       jsr       _createVariable
       add.w     #12,A7
       bra.s     basRead_55
basRead_54:
; else // se ja existe, altera
; updateVariable((vRetFV + 3), answer, varTipo, 1);
       pea       1
       ext.w     D3
       ext.l     D3
       move.l    D3,-(A7)
       pea       -114(A6)
       move.l    D5,D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basRead_55:
       bra.s     basRead_53
basRead_52:
; }
; else
; {
; updateVariable(vRetFV, answer, varTipo, 2);
       pea       2
       ext.w     D3
       ext.l     D3
       move.l    D3,-(A7)
       pea       -114(A6)
       move.l    D5,-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basRead_53:
; }
; return 0;
       clr.l     D0
basRead_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Volta ponteiro do READ para o primeiro item dos comandos DATA
; // Syntaxe:
; //          RESTORE
; //--------------------------------------------------------------------------------------
; int basRestore(void)
; {
       xdef      _basRestore
_basRestore:
; *vDataLineAtu = *vDataFirst;
       move.l    _vDataFirst.L,A0
       move.l    _vDataLineAtu.L,A1
       move.l    (A0),(A1)
; *vDataPointer = (*vDataLineAtu + 6);
       move.l    _vDataLineAtu.L,A0
       move.l    (A0),D0
       addq.l    #6,D0
       move.l    _vDataPointer.L,A0
       move.l    D0,(A0)
; return 0;
       clr.l     D0
       rts
; }
       section   const
@basic_1:
       dc.b      63,114,101,115,101,114,118,101,100,32,48,0
@basic_2:
       dc.b      63,83,116,111,112,112,101,100,0
@basic_3:
       dc.b      63,78,111,32,101,120,112,114,101,115,115,105
       dc.b      111,110,32,112,114,101,115,101,110,116,0
@basic_4:
       dc.b      63,69,113,117,97,108,115,32,115,105,103,110
       dc.b      32,101,120,112,101,99,116,101,100,0
@basic_5:
       dc.b      63,78,111,116,32,97,32,118,97,114,105,97,98
       dc.b      108,101,0
@basic_6:
       dc.b      63,79,117,116,32,111,102,32,114,97,110,103,101
       dc.b      0
@basic_7:
       dc.b      63,73,108,108,101,103,97,108,32,113,117,97,110
       dc.b      116,105,116,121,0
@basic_8:
       dc.b      63,76,105,110,101,32,110,111,116,32,102,111
       dc.b      117,110,100,0
@basic_9:
       dc.b      63,84,72,69,78,32,101,120,112,101,99,116,101
       dc.b      100,0
@basic_10:
       dc.b      63,84,79,32,101,120,112,101,99,116,101,100,0
@basic_11:
       dc.b      63,84,111,111,32,109,97,110,121,32,110,101,115
       dc.b      116,101,100,32,70,79,82,32,108,111,111,112,115
       dc.b      0
@basic_12:
       dc.b      63,78,69,88,84,32,119,105,116,104,111,117,116
       dc.b      32,70,79,82,0
@basic_13:
       dc.b      63,84,111,111,32,109,97,110,121,32,110,101,115
       dc.b      116,101,100,32,71,79,83,85,66,115,0
@basic_14:
       dc.b      63,82,69,84,85,82,78,32,119,105,116,104,111
       dc.b      117,116,32,71,79,83,85,66,0
@basic_15:
       dc.b      63,83,121,110,116,97,120,32,101,114,114,111
       dc.b      114,0
@basic_16:
       dc.b      63,85,110,98,97,108,97,110,99,101,100,32,112
       dc.b      97,114,101,110,116,104,101,115,101,115,0
@basic_17:
       dc.b      63,73,110,99,111,109,112,97,116,105,98,108,101
       dc.b      32,116,121,112,101,115,0
@basic_18:
       dc.b      63,76,105,110,101,32,110,117,109,98,101,114
       dc.b      32,101,120,112,101,99,116,101,100,0
@basic_19:
       dc.b      63,67,111,109,109,97,32,69,115,112,101,99,116
       dc.b      101,100,0
@basic_20:
       dc.b      63,84,105,109,101,111,117,116,0
@basic_21:
       dc.b      63,76,111,97,100,32,119,105,116,104,32,69,114
       dc.b      114,111,114,115,0
@basic_22:
       dc.b      63,83,105,122,101,32,101,114,114,111,114,0
@basic_23:
       dc.b      63,79,117,116,32,111,102,32,109,101,109,111
       dc.b      114,121,0
@basic_24:
       dc.b      63,86,97,114,105,97,98,108,101,32,110,97,109
       dc.b      101,32,97,108,114,101,97,100,121,32,101,120
       dc.b      105,115,116,0
@basic_25:
       dc.b      63,87,114,111,110,103,32,109,111,100,101,32
       dc.b      114,101,115,111,108,117,116,105,111,110,0
@basic_26:
       dc.b      63,73,108,108,101,103,97,108,32,112,111,115
       dc.b      105,116,105,111,110,0
@basic_27:
       dc.b      63,79,117,116,32,111,102,32,100,97,116,97,0
@basic_28:
       dc.b      76,69,84,0
@basic_29:
       dc.b      80,82,73,78,84,0
@basic_30:
       dc.b      73,70,0
@basic_31:
       dc.b      84,72,69,78,0
@basic_32:
       dc.b      70,79,82,0
@basic_33:
       dc.b      84,79,0
@basic_34:
       dc.b      78,69,88,84,0
@basic_35:
       dc.b      83,84,69,80,0
@basic_36:
       dc.b      71,79,84,79,0
@basic_37:
       dc.b      71,79,83,85,66,0
@basic_38:
       dc.b      82,69,84,85,82,78,0
@basic_39:
       dc.b      82,69,77,0
@basic_40:
       dc.b      82,69,83,69,82,86,69,68,0
@basic_41:
       dc.b      68,73,77,0
@basic_42:
       dc.b      79,78,0
@basic_43:
       dc.b      73,78,80,85,84,0
@basic_44:
       dc.b      71,69,84,0
@basic_45:
       dc.b      76,79,67,65,84,69,0
@basic_46:
       dc.b      67,76,83,0
@basic_47:
       dc.b      67,76,69,65,82,0
@basic_48:
       dc.b      68,65,84,65,0
@basic_49:
       dc.b      82,69,65,68,0
@basic_50:
       dc.b      82,69,83,84,79,82,69,0
@basic_51:
       dc.b      69,78,68,0
@basic_52:
       dc.b      83,84,79,80,0
@basic_53:
       dc.b      83,67,82,69,69,78,0
@basic_54:
       dc.b      67,73,82,67,76,69,0
@basic_55:
       dc.b      82,69,67,84,0
@basic_56:
       dc.b      67,79,76,79,82,0
@basic_57:
       dc.b      80,76,79,84,0
@basic_58:
       dc.b      72,76,73,78,0
@basic_59:
       dc.b      86,76,73,78,0
@basic_60:
       dc.b      80,65,73,78,84,0
@basic_61:
       dc.b      76,73,78,69,0
@basic_62:
       dc.b      65,84,0
@basic_63:
       dc.b      79,78,69,82,82,0
@basic_64:
       dc.b      65,83,67,0
@basic_65:
       dc.b      80,69,69,75,0
@basic_66:
       dc.b      80,79,75,69,0
@basic_67:
       dc.b      82,78,68,0
@basic_68:
       dc.b      76,69,78,0
@basic_69:
       dc.b      86,65,76,0
@basic_70:
       dc.b      83,84,82,36,0
@basic_71:
       dc.b      80,79,73,78,84,0
@basic_72:
       dc.b      67,72,82,36,0
@basic_73:
       dc.b      70,82,69,0
@basic_74:
       dc.b      83,81,82,84,0
@basic_75:
       dc.b      83,73,78,0
@basic_76:
       dc.b      67,79,83,0
@basic_77:
       dc.b      84,65,78,0
@basic_78:
       dc.b      76,79,71,0
@basic_79:
       dc.b      69,88,80,0
@basic_80:
       dc.b      83,80,67,0
@basic_81:
       dc.b      84,65,66,0
@basic_82:
       dc.b      77,73,68,36,0
@basic_83:
       dc.b      82,73,71,72,84,36,0
@basic_84:
       dc.b      76,69,70,84,36,0
@basic_85:
       dc.b      73,78,84,0
@basic_86:
       dc.b      65,66,83,0
@basic_87:
       dc.b      65,78,68,0
@basic_88:
       dc.b      79,82,0
@basic_89:
       dc.b      62,61,0
@basic_90:
       dc.b      60,61,0
@basic_91:
       dc.b      60,62,0
@basic_92:
       dc.b      78,79,84,0
@basic_93:
       dc.b      77,77,83,74,45,66,65,83,73,67,32,118,49,46,49
       dc.b      97,48,51,0
@basic_94:
       dc.b      13,10,0
@basic_95:
       dc.b      85,116,105,108,105,116,121,32,40,99,41,32,50
       dc.b      48,50,50,45,50,48,50,54,13,10,0
@basic_96:
       dc.b      79,75,13,10,0
@basic_97:
       dc.b      13,10,79,75,0
@basic_98:
       dc.b      78,69,87,0
@basic_99:
       dc.b      69,68,73,84,0
@basic_100:
       dc.b      76,73,83,84,0
@basic_101:
       dc.b      76,73,83,84,80,0
@basic_102:
       dc.b      82,85,78,0
@basic_103:
       dc.b      68,69,76,0
@basic_104:
       dc.b      88,76,79,65,68,0
@basic_105:
       dc.b      88,76,79,65,68,49,75,0
@basic_106:
       dc.b      84,73,77,69,82,0
@basic_107:
       dc.b      84,105,109,101,114,58,32,0
@basic_108:
       dc.b      109,115,13,10,0
@basic_109:
       dc.b      84,82,65,67,69,0
@basic_110:
       dc.b      78,79,84,82,65,67,69,0
@basic_111:
       dc.b      68,69,66,85,71,0
@basic_112:
       dc.b      78,79,68,69,66,85,71,0
@basic_113:
       dc.b      81,85,73,84,0
@basic_114:
       dc.b      32,0
@basic_115:
       dc.b      32,59,44,43,45,60,62,40,41,47,42,94,61,58,0
@basic_116:
       dc.b      76,105,110,101,32,110,117,109,98,101,114,32
       dc.b      97,108,114,101,97,100,121,32,101,120,105,115
       dc.b      116,115,13,10,0
@basic_117:
       dc.b      78,111,110,45,101,120,105,115,116,101,110,116
       dc.b      32,108,105,110,101,32,110,117,109,98,101,114
       dc.b      13,10,0
@basic_118:
       dc.b      112,114,101,115,115,32,97,110,121,32,107,101
       dc.b      121,32,116,111,32,99,111,110,116,105,110,117
       dc.b      101,0
@basic_119:
       dc.b      64,0
@basic_120:
       dc.b      83,121,110,116,97,120,32,69,114,114,111,114
       dc.b      32,33,0
@basic_121:
       dc.b      13,10,65,98,111,114,116,101,100,32,33,33,33
       dc.b      13,10,0
@basic_122:
       dc.b      13,10,83,116,111,112,112,101,100,32,97,116,32
       dc.b      0
@basic_123:
       dc.b      13,10,69,120,101,99,117,116,105,110,103,32,97
       dc.b      116,32,0
@basic_124:
       dc.b      32,97,116,32,0
@basic_125:
       dc.b      32,33,13,10,0
@basic_126:
       dc.b      76,111,97,100,105,110,103,32,66,97,115,105,99
       dc.b      32,80,114,111,103,114,97,109,46,46,46,13,10
       dc.b      0
@basic_127:
       dc.b      68,111,110,101,46,13,10,0
@basic_128:
       dc.b      80,114,111,99,101,115,115,105,110,103,46,46
       dc.b      46,13,10,0
@basic_129:
       dc.b      76,111,97,100,105,110,103,32,66,97,115,105,99
       dc.b      32,80,114,111,103,114,97,109,32,49,107,46,46
       dc.b      46,13,10,0
@basic_130:
       dc.b      58,0
@basic_131:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,53
       dc.b      32,45,32,91,0
@basic_132:
       dc.b      93,45,91,0
@basic_133:
       dc.b      93,13,10,0
@basic_134:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,48
       dc.b      32,45,32,91,0
@basic_135:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,49
       dc.b      32,45,32,91,0
@basic_136:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,51
       dc.b      32,45,32,91,0
@basic_137:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,52
       dc.b      32,45,32,91,0
@basic_138:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,50
       dc.b      32,45,32,91,0
@basic_139:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,55
       dc.b      56,32,45,32,91,0
@basic_140:
       dc.b      65,113,117,105,32,56,56,56,46,54,54,54,46,55
       dc.b      57,13,10,0
@basic_141:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,48
       dc.b      32,118,97,114,78,97,109,101,45,91,0
@basic_142:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,57
       dc.b      57,32,118,97,114,78,97,109,101,45,91,0
@basic_143:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,57
       dc.b      56,32,118,97,114,78,97,109,101,45,13,10,0
@basic_144:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,57
       dc.b      55,32,118,97,114,78,97,109,101,45,13,10,0
@basic_145:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,48
       dc.b      45,91,0
@basic_146:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,49
       dc.b      45,91,0
@basic_147:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,50
       dc.b      45,91,0
@basic_148:
       dc.b      65,113,117,105,32,52,52,52,46,54,54,54,46,48
       dc.b      13,10,0
@basic_149:
       dc.b      65,113,117,105,32,52,52,52,46,54,54,54,46,49
       dc.b      93,13,10,0
@basic_150:
       dc.b      65,113,117,105,32,52,52,52,46,54,54,54,46,50
       dc.b      32,118,97,114,78,97,109,101,45,91,0
       xdef      _keywords_count
_keywords_count:
       dc.l      67
@basic_keywords:
       dc.l      @basic_28,128,@basic_29,129,@basic_30,130
       dc.l      @basic_31,131,@basic_32,133,@basic_33,134
       dc.l      @basic_34,135,@basic_35,136,@basic_36,137
       dc.l      @basic_37,138,@basic_38,139,@basic_39,140
       dc.l      @basic_40,141,@basic_40,142,@basic_41,143
       dc.l      @basic_42,145,@basic_43,146,@basic_44,147
       dc.l      @basic_40,148,@basic_45,149,@basic_46,150
       dc.l      @basic_47,151,@basic_48,152,@basic_49,153
       dc.l      @basic_50,154,@basic_51,158,@basic_52,159
       dc.l      @basic_53,176,@basic_54,177,@basic_55,178
       dc.l      @basic_56,179,@basic_57,180,@basic_58,181
       dc.l      @basic_59,182,@basic_60,184,@basic_61,185
       dc.l      @basic_62,186,@basic_63,187,@basic_64,196
       dc.l      @basic_65,205,@basic_66,206,@basic_67,209
       dc.l      @basic_68,219,@basic_69,220,@basic_70,221
       dc.l      @basic_71,224,@basic_72,225,@basic_73,226
       dc.l      @basic_74,227,@basic_75,228,@basic_76,229
       dc.l      @basic_77,230,@basic_78,231,@basic_79,232
       dc.l      @basic_80,233,@basic_81,234,@basic_82,235
       dc.l      @basic_83,236,@basic_84,237,@basic_85,238
       dc.l      @basic_86,239,@basic_87,243,@basic_88,244
       dc.l      @basic_89,245,@basic_90,246,@basic_91,247
       dc.l      @basic_92,248
       xdef      _operandsWithTokens
_operandsWithTokens:
       dc.b      43,45,42,47,94,62,61,60,0
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
       xdef      _pStartSimpVar
_pStartSimpVar:
       dc.l      8388608
       xdef      _pStartArrayVar
_pStartArrayVar:
       dc.l      8400896
       xdef      _pStartString
_pStartString:
       dc.l      8585216
       xdef      _pStartProg
_pStartProg:
       dc.l      8716288
       xdef      _pStartXBasLoad
_pStartXBasLoad:
       dc.l      9109504
       xdef      _pStartStack
_pStartStack:
       dc.l      9428992
       xdef      _pProcess
_pProcess:
       dc.l      9437182
       xdef      _pTypeLine
_pTypeLine:
       dc.l      9437180
       xdef      _nextAddrLine
_nextAddrLine:
       dc.l      9437176
       xdef      _firstLineNumber
_firstLineNumber:
       dc.l      9437174
       xdef      _addrFirstLineNumber
_addrFirstLineNumber:
       dc.l      9437170
       xdef      _addrLastLineNumber
_addrLastLineNumber:
       dc.l      9437166
       xdef      _nextAddr
_nextAddr:
       dc.l      9437162
       xdef      _nextAddrSimpVar
_nextAddrSimpVar:
       dc.l      9437158
       xdef      _nextAddrArrayVar
_nextAddrArrayVar:
       dc.l      9437154
       xdef      _nextAddrString
_nextAddrString:
       dc.l      9437150
       xdef      _comandLineTokenized
_comandLineTokenized:
       dc.l      9436895
       xdef      _vParenteses
_vParenteses:
       dc.l      9436893
       xdef      _vInicioSentenca
_vInicioSentenca:
       dc.l      9436891
       xdef      _vMaisTokens
_vMaisTokens:
       dc.l      9436889
       xdef      _vTemIf
_vTemIf:
       dc.l      9436887
       xdef      _doisPontos
_doisPontos:
       dc.l      9436883
       xdef      _vTemAndOr
_vTemAndOr:
       dc.l      9436881
       xdef      _vTemThen
_vTemThen:
       dc.l      9436879
       xdef      _vTemElse
_vTemElse:
       dc.l      9436877
       xdef      _vTemIfAndOr
_vTemIfAndOr:
       dc.l      9436874
       xdef      _vErroProc
_vErroProc:
       dc.l      9436870
       xdef      _ftos
_ftos:
       dc.l      9436866
       xdef      _gtos
_gtos:
       dc.l      9436862
       xdef      _floatBufferStr
_floatBufferStr:
       dc.l      9432998
       xdef      _floatNumD7
_floatNumD7:
       dc.l      9432734
       xdef      _floatNumD6
_floatNumD6:
       dc.l      9432726
       xdef      _floatNumA0
_floatNumA0:
       dc.l      9432718
       xdef      _randSeed
_randSeed:
       dc.l      9432710
       xdef      _lastHgrX
_lastHgrX:
       dc.l      9432708
       xdef      _lastHgrY
_lastHgrY:
       dc.l      9432706
       xdef      _vDataBkpPointerProg
_vDataBkpPointerProg:
       dc.l      9432688
       xdef      _vDataPointer
_vDataPointer:
       dc.l      9432666
       xdef      _pointerRunProg
_pointerRunProg:
       dc.l      9432662
       xdef      _tok
_tok:
       dc.l      9432660
       xdef      _token_type
_token_type:
       dc.l      9432658
       xdef      _value_type
_value_type:
       dc.l      9432656
       xdef      _onErrGoto
_onErrGoto:
       dc.l      9432650
       xdef      _changedPointer
_changedPointer:
       dc.l      9432642
       xdef      _token
_token:
       dc.l      9432430
       xdef      _varName
_varName:
       dc.l      9432174
       xdef      _traceOn
_traceOn:
       dc.l      9432166
       xdef      _debugOn
_debugOn:
       dc.l      9432164
       xdef      _gosubStack
_gosubStack:
       dc.l      9431398
       xdef      _vDataFirst
_vDataFirst:
       dc.l      9431394
       xdef      _vDataLineAtu
_vDataLineAtu:
       dc.l      9431390
       xdef      _forStack
_forStack:
       dc.l      9434814
       xdef      _atuVarAddr
_atuVarAddr:
       dc.l      9434800
@basic_listError:
       dc.l      @basic_1,@basic_2,@basic_3,@basic_4,@basic_5
       dc.l      @basic_6,@basic_7,@basic_8,@basic_9,@basic_10
       dc.l      @basic_11,@basic_12,@basic_13,@basic_14,@basic_15
       dc.l      @basic_16,@basic_17,@basic_18,@basic_19,@basic_20
       dc.l      @basic_21,@basic_22,@basic_23,@basic_24,@basic_25
       dc.l      @basic_26,@basic_27
@basic_lastVarCacheName0:
       dc.b      0,0,0,0,0,0,0,0
@basic_lastVarCacheName1:
       dc.b      0,0,0,0,0,0,0,0
@basic_lastVarCacheAddr:
       dc.l      0,0,0,0,0,0,0,0
@basic_paintPatternTable:
       dc.l      0
@basic_paintColorTable:
       dc.l      8192
@basic_paintVdpData:
       dc.l      4194369
find_var_vTempDepth:
       dc.b      0
       section   bss
       xdef      _vbufInput
_vbufInput:
       ds.b      256
       xdef      _fgcolorBas
_fgcolorBas:
       ds.b      1
       xdef      _bgcolorBas
_bgcolorBas:
       ds.b      1
       xdef      _fgcolorBasAnt
_fgcolorBasAnt:
       ds.b      1
       xdef      _bgcolorBasAnt
_bgcolorBasAnt:
       ds.b      1
       xdef      _vdpModeBas
_vdpModeBas:
       ds.b      1
       xdef      _vdpMaxCols
_vdpMaxCols:
       ds.b      1
       xdef      _vdpMaxRows
_vdpMaxRows:
       ds.b      1
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
@basic_paintStackX:
       ds.b      4096
@basic_paintStackY:
       ds.b      4096
find_var_vTempPool:
       ds.b      1000
       xref      _Reg_TACR
       xref      _strcpy
       xref      _itoa
       xref      LDIV
       xref      LMUL
       xref      _FPP_SUM
       xref      _atoi
       xref      _vmfp
       xref      _FPP_SUB
       xref      _strlen
       xref      _FPP_EXP
       xref      ULMUL
       xref      _FPP_INT
       xref      _FPP_LN
       xref      _FPP_DIV
       xref      _FPP_NEG
       xref      _STR_TO_FP
       xref      _FPP_FPP
       xref      _FPP_SQRT
       xref      _memset
       xref      _FPP_COSH
       xref      _FPP_PWR
       xref      _FP_TO_STR
       xref      _strcat
       xref      _FPP_TAN
       xref      _FPP_ABS
       xref      _FPP_SINH
       xref      _FPP_MUL
       xref      _toupper
       xref      _strchr
       xref      _FPP_COS
       xref      _strcmp
       xref      _FPP_SIN
       xref      _FPP_TANH
       xref      _Reg_TADR
       xref      _FPP_CMP
       xref      _strncmp
