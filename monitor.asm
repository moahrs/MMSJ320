; D:\PROJETOS\MMSJ320\MONITOR.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; /********************************************************************************
; *    Programa    : monitor.c
; *    Objetivo    : BIOS do modulo MMSJ300 - Versao vintage compatible
; *    Criado em   : 17/09/2022
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 17/09/2022  0.1     Moacir Jr.   Criacao Versao Beta
; *                                  512KB EEPROM + 256KB RAM BUFFER + 8MB RAM USU
; * 12/11/2023  0.2     Moacir Jr.   Adaptacao do MC68901 p/ serial e interrupcoes
; * 01/06/2023  0.3     Moacir Jr.   Adaptacao do teclado PS/2 via arduino nano
; *                                  Simulando um FPGA de epoca
; * 22/06/2023  0.4     Moacir Jr.   Adaptacao do TMS9118 VDP
; * 23/06/2023  0.4a    Moacir Jr.   Adaptacao lib arduino tms9918 pro mmsj300
; * 15/07/2023  0.4b    Moacir Jr.   Colocar tela vermelha de erros
; * 15/07/2023  0.4c    Moacir Jr.   Colocar rotina de trace
; * 18/07/2023  0.4d    Moacir Jr.   Verificar e Ajustar Problema no G2 do VDP
; * 19/07/2023  1.0     Moacir Jr.   Versao para publicacao
; * 20/07/2023  1.0a    Moacir Jr.   Ajuste de bugs
; * 21/07/2023  1.1     Moacir Jr.   Adaptar Basic ao monitor
; * 25/07/2023  1.1a    Moacir Jr.   Ajustes no inputLine, aceitar tipo '@'
; * 20/01/2024  1.1b    Moacir Jr.   Iniciar direto no basic... Ai com QUIT, volta pro monitor
; * 06/03/2024  1.1b    Moacir Jr.   Colocar dumpw (dump em forma de janela texto)
; * 06/03/2024  1.1c    Moacir Jr.   Ajuste write char no modo grafico G2
; * 09/03/2024  1.1d    Moacir Jr.   Adaptar floppy disk via arduino como controlador (FAT será aqui)
; *                                  ***** A B O R T A D O *****
; * 17/11/2024  1.1e    Moacir Jr.   Colocar o PS/2 direto no MFP->IRQ->CPU
; * 25/12/2024  1.1f    Moacir Jr.   Ajustes e colocar tamanho total recebido
; *                                  no carregamento seria pra memoria
; * 10/01/2025  1.2     Moacir Jr.   Integrar com uC/CosII para o MMSJ320
; * 16/01/2025  1.3     Moacir Jr.   Voltar para teclado e mouse com arduino nano
; * 28/01/2025  1.3a    Moacir Jr.   Ajustes na leitura dos dados recebidos do Mouse
; *--------------------------------------------------------------------------------
; *
; * Mapa de Memoria
; * ---------------
; *
; *     SLOT 0                          SLOT 1
; * +-------------+ 000000h
; * |   EEPROM    |
; * |   512KB     |
; * |   (BIOS)    | 07FFFFh
; * +-------------+ 080000h
; * |    LIVRE    | 1FFFFFh
; * +-------------+ 200000h
; * |             |
; * |  EXPANSAO   |
; * |             | 3FFFFFh
; * +-------------+ 400000h
; * |             |
; * | PERIFERICOS |
; * |             | 5FFFFFh
; * +-------------+ 600000h
; * |  RAM 256KB  |
; * |  BUFFER E   |
; * |  SISTEMA    | 63FFFFh
; * +-------------+ 640000h
; * |    LIVRE    | 7FFFFFh
; * +-------------+ 800000h
; * |             |
; * |   ATUAL     |
; * |    RAM      |
; * |  USUARIO    |
; * |    1MB      | 8FFFFFh
; * +-------------+ 900000h
; * |             |
; * |             |
; * |    RAM      |
; * |  USUARIO    |
; * |    7MB      |
; * |             |
; * |             |
; * |             |
; * |             |
; * |             |
; * |             |
; * |             |
; * |             |
; * +-------------+ FFFFFFh
; *--------------------------------------------------------------------------------
; *
; * Enderecos de Perifericos
; *
; * 00200001h e 00200003 - DISK Arduino UNO (Temp)
; *                        - A1 = 0: r/w 4 bits LSB
; *                        - A1 = 1: r/w 4 bits MSB
; * 00400020h a 0040003F - MFP MC68901p - Cristal de 2.4576MHz
; *                        - SERIAL 9600, 8, 1, n
; *                        - TECLADO (PC-AT - PS/2)
; *                        - Controle de Interrupcoes e PS/2
; * 00400040h a 00400043 - VIDEO TMS9118 (16KB VRAM):
; *             00400041 - Data Mode
; *             00400043 - Register / Adress Mode
; ********************************************************************************/
; #define VDP_EXT extern
; #define MFP_EXT extern
; #include <ctype.h>
; #include <string.h>
; #include <malloc.h>
; #include <stdlib.h>
; #include "mmsj320api.h"
; #include "mmsj320vdp.h"
; #include "mmsj320mfp.h"
; #include "monitor.h"
; #define versionBios "1.3a"
; HEADER *_allocp;
; unsigned long runMemory;
; unsigned char kbdKeyPtrR; // Contador do ponteiro das teclas colocadas no buffer
; unsigned char kbdKeyPtrW; // Contador do ponteiro das teclas colocadas no buffer
; unsigned char kbdKeyBuffer[66];   // 16 buffer char
; #ifdef __KEYPS2__
; unsigned char kbdScanCodePtrR; // Contador do ponteiro das teclas colocadas no buffer
; unsigned char kbdScanCodePtrW; // Contador do ponteiro das teclas colocadas no buffer
; unsigned char kbdScanCodeBuf[66];   // 16 buffer char
; #endif
; unsigned char scanCode;
; unsigned char vBufReceived; // Byte recebido pelo MFP
; unsigned char vbuf[128]; // Buffer Linha Digitavel, maximo de 128 caracteres -
; unsigned char MseMovPtrR; // Contador do ponteiro das dados do mouse recebidos
; unsigned char MseMovPtrW; // Contador do ponteiro das dados do mouse recebidos
; unsigned char MseMovBuffer[66];   // 64 buffer mouse movimentos
; unsigned long vSizeTotalRec;
; unsigned char vBufXmitEmpty;
; unsigned char vtotmem;
; unsigned long SysClockms;
; unsigned short startBasic;
; unsigned char debugMessages;
; void delayms(int pTimeMS);
; void delayus(int pTimeUS);
; unsigned char readChar(void);
; unsigned char inputLine(unsigned int pQtdInput, unsigned char pTipo);
; int processCmd(void);
; void writeSerial(unsigned char pchr);
; void writeLongSerial(unsigned char *msg);
; unsigned long lstmGetSize(void);
; unsigned char loadSerialToMem(unsigned char *pEnder, unsigned char ptipo);
; void runMem(unsigned long pEnder);
; void runBasic(unsigned long pEnder);
; void pokeMem(unsigned char *pEnder, unsigned char *pByte);
; void dumpMem (unsigned char *pEnder, unsigned char *pqtd, unsigned char *pCols);
; void dumpMem2 (unsigned char *pEnder, unsigned char *pqtd);
; void dumpMemWin (unsigned char *pEnder, unsigned char *pqtd, unsigned char *pCols);
; void diskCmd (unsigned char *pCmd, unsigned char *pParam);
; void basicFuncBios(void);
; unsigned long hexToLong(char *pHex);
; unsigned long pow(int val, int pot);
; int hex2int(char ch);
; void asctohex(unsigned char a, unsigned char *s);
; void runCmd(void);
; void runBas(void);
; void runOSCmd(void);
; void runSO(void);
; unsigned int carregaSO(void);
; void carregaOSDisk(void);
; void runSystemOper(void);
; void hideCursor(void);
; void showCursor(void);
; void modeVideo(unsigned char *pMode);
; void printCharBuffer(unsigned char *pCharMade);
; unsigned char readMouse(unsigned char *vStat, unsigned char *vMovX, unsigned char *vMovY);
; void inputTask(void);
; #ifdef __KEYPS2__
; void scanCodeTask(void *);
; #endif
; // ASCII character set
; unsigned char ascii[]  = "abcdefghijklmnopqrstuvwxyz0123456789;=.,/'[]`- "; // Sem Caps sem Shift
; unsigned char ascii2[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ)!@#$%^&*(:+><?\"{}~_ "; // Sem Caps com Shift
; unsigned char ascii3[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789;=.,/'[]`- "; // Com Caps sem Shift
; unsigned char ascii4[] = "abcdefghijklmnopqrstuvwxyz)!@#$%^&*(:+><?\"{}~_ "; // Com Caps com Shift
; // KeyCode set
; // Querty keycode set: uncomment to activate this code
; unsigned char keyCode[]={0x1C,0x32,0x21,0x23,0x24,0x2B,0x34,0x33,0x43,0x3B,0x42,
; 0x4B,0x3A,0x31,0x44,0x4D,0x15,0x2D,0x1B,0x2C,0x3C,0x2A,
; 0x1D,0x22,0x35,0x1A,0x45,0x16,0x1E,0x26,0x25,0x2E,0x36,
; 0x3D,0x3E,0x46,0x4C,0x55,0x49,0x41,0x4A,0x52,0x54,0x5B,
; 0x0E,0x4E,0x29,0x00};
; //-----------------------------------------------------------------------------
; // Principal
; //-----------------------------------------------------------------------------
; void main(void)
; {
       section   code
       xdef      _main
_main:
       link      A6,#-12
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vmfp.L,A2
       lea       _printText.L,A3
       lea       -10(A6),A4
       lea       _Reg_IMRA.L,A5
; unsigned short *xaddr = (unsigned short *) 0x00600000;
       move.l    #6291456,D2
; unsigned short vbytepic = 0, xdado;
       clr.w     -12(A6)
; unsigned int ix = 0, xcounter = 0;
       clr.l     D3
       clr.l     D4
; unsigned char sqtdtam[10];
; unsigned char vRamSyst1st = 1, vRamUser1st = 1;
       moveq     #1,D7
       moveq     #1,D6
; // Inicia com Basic
; startBasic = 0;
       clr.w     _startBasic.L
; debugMessages = 0;
       clr.b     _debugMessages.L
; // Tempo para Inicializar a Memoria DRAM (se tiver), Perifericos e etc...
; for(ix = 0; ix <= 12000; ix++);
       clr.l     D3
main_1:
       cmp.l     #12000,D3
       bhi.s     main_3
       addq.l    #1,D3
       bra       main_1
main_3:
; //---------------------------------------------
; // Enviar setup para o MFP 68901
; //---------------------------------------------
; vBufXmitEmpty = 1;
       move.b    #1,_vBufXmitEmpty.L
; // Setup Timers
; *(vmfp + Reg_TACR)  = 0x10; // Stop Counter Timer A
       move.l    (A2),A0
       move.w    _Reg_TACR.L,D0
       and.l     #65535,D0
       move.b    #16,0(A0,D0.L)
; *(vmfp + Reg_TBCR)  = 0x10; // Stop Counter Timer A
       move.l    (A2),A0
       move.w    _Reg_TBCR.L,D0
       and.l     #65535,D0
       move.b    #16,0(A0,D0.L)
; while(*(vmfp + Reg_TADR) != 0x9A)
main_4:
       move.l    (A2),A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       cmp.w     #154,D0
       beq.s     main_6
; *(vmfp + Reg_TADR)  = 0x9A; // Valor para 1 ms
       move.l    (A2),A0
       move.w    _Reg_TADR.L,D0
       and.l     #65535,D0
       move.b    #154,0(A0,D0.L)
       bra       main_4
main_6:
; *(vmfp + Reg_TACR)  = 0x13; // Start Counter Timer A Com Delay por 16
       move.l    (A2),A0
       move.w    _Reg_TACR.L,D0
       and.l     #65535,D0
       move.b    #19,0(A0,D0.L)
; while(*(vmfp + Reg_TBDR) != 0xF6)
main_7:
       move.l    (A2),A0
       move.w    _Reg_TBDR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       cmp.w     #246,D0
       beq.s     main_9
; *(vmfp + Reg_TBDR)  = 0xF6; // Valor para 10 ms
       move.l    (A2),A0
       move.w    _Reg_TBDR.L,D0
       and.l     #65535,D0
       move.b    #246,0(A0,D0.L)
       bra       main_7
main_9:
; *(vmfp + Reg_TBCR)  = 0x16; // Start Counter Timer B Com Delay por 100
       move.l    (A2),A0
       move.w    _Reg_TBCR.L,D0
       and.l     #65535,D0
       move.b    #22,0(A0,D0.L)
; *(vmfp + Reg_TCDR)  = 0x02;
       move.l    (A2),A0
       move.w    _Reg_TCDR.L,D0
       and.l     #65535,D0
       move.b    #2,0(A0,D0.L)
; *(vmfp + Reg_TDDR)  = 0x02;
       move.l    (A2),A0
       move.w    _Reg_TDDR.L,D0
       and.l     #65535,D0
       move.b    #2,0(A0,D0.L)
; *(vmfp + Reg_TCDCR) = 0x11;
       move.l    (A2),A0
       move.w    _Reg_TCDCR.L,D0
       and.l     #65535,D0
       move.b    #17,0(A0,D0.L)
; // Setup Interruptions
; *(vmfp + Reg_VR)    = 0xA0; // vector = 0xA msb = 0x1010 and lsb = 0x0000 auto end session interrupt ///// antigo = lsb = 0x1000 software end session interrupt
       move.l    (A2),A0
       move.w    _Reg_VR.L,D0
       and.l     #65535,D0
       move.b    #160,0(A0,D0.L)
; *(vmfp + Reg_IERA)  = 0x00; // disable all at start
       move.l    (A2),A0
       move.w    _Reg_IERA.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_IERB)  = 0x00; // disable all at start
       move.l    (A2),A0
       move.w    _Reg_IERB.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_IMRA)  = 0x00; // disable all at start
       move.l    (A2),A0
       move.w    (A5),D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_IMRB)  = 0x00; // disable all at start
       move.l    (A2),A0
       move.w    _Reg_IMRB.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_ISRA)  = 0x00; // disable all at start
       move.l    (A2),A0
       move.w    _Reg_ISRA.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_ISRB)  = 0x00; // disable all at start
       move.l    (A2),A0
       move.w    _Reg_ISRB.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; // Setup Serial = 9600, 8, 1, n
; *(vmfp + Reg_UCR)   = 0x88;
       move.l    (A2),A0
       move.w    _Reg_UCR.L,D0
       and.l     #65535,D0
       move.b    #136,0(A0,D0.L)
; *(vmfp + Reg_RSR)   = 0x01;
       move.l    (A2),A0
       move.w    _Reg_RSR.L,D0
       and.l     #65535,D0
       move.b    #1,0(A0,D0.L)
; *(vmfp + Reg_TSR)   = 0x21;
       move.l    (A2),A0
       move.w    _Reg_TSR.L,D0
       and.l     #65535,D0
       move.b    #33,0(A0,D0.L)
; // Setup GPIO
; #ifdef __KEYPS2__
; *(vmfp + Reg_DDR)   = 0x10; // I4 as Output, I7 - I5 e I3 - I0 as Input
; #endif
; #ifdef __KEYPS2_EXT__
; *(vmfp + Reg_DDR)   = 0x10; // I4 as Output, I7 - I5 e I3 - I0 as Input
       move.l    (A2),A0
       move.w    _Reg_DDR.L,D0
       and.l     #65535,D0
       move.b    #16,0(A0,D0.L)
; #endif
; *(vmfp + Reg_AER)   = 0x00; // All Interrupts transction 1 to 0
       move.l    (A2),A0
       move.w    _Reg_AER.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; // Setup Interruptions
; *(vmfp + Reg_IERA)  = 0x00; // 0xCE; // serial interrupt (buffer full and empty) i7 = Clock PS2 Mouse, I6 = Clock PS2 KeyBoard (clk pin OR DTRDY pin)
       move.l    (A2),A0
       move.w    _Reg_IERA.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_IERB)  = 0x00;
       move.l    (A2),A0
       move.w    _Reg_IERB.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_IMRA)  = 0x00; // 0xCE; // serial interrupt (buffer full and empty) i7 = Clock PS2 Mouse, I6 = Clock PS2 KeyBoard (clk pin OR DTRDY pin)
       move.l    (A2),A0
       move.w    (A5),D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(vmfp + Reg_IMRB)  = 0x00;
       move.l    (A2),A0
       move.w    _Reg_IMRB.L,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; //---------------------------------------------
; #ifdef __KEYPS2_EXT__
; *(vmfp + Reg_GPDR) |= 0x10;  // Seta CS = 1 (I4) do controlador
       move.l    (A2),A0
       move.w    _Reg_GPDR.L,D0
       and.l     #65535,D0
       or.b      #16,0(A0,D0.L)
; #endif
; //---------------------------------------------
; // Enviar setup para o VDP TMS9118
; //---------------------------------------------
; // Definindo variaveis de video
; videoCursorPosColX = 0;
       clr.w     _videoCursorPosColX.L
; videoCursorPosRowY = 0;
       clr.w     _videoCursorPosRowY.L
; videoScroll = 1;       // Ativo
       move.b    #1,_videoScroll.L
; videoScrollDir = 1;    // Pra Cima
       move.b    #1,_videoScrollDir.L
; videoCursorBlink = 0;
       clr.b     _videoCursorBlink.L
; videoCursorShow = 0;
       clr.b     _videoCursorShow.L
; vdpMaxCols = 39;
       move.b    #39,_vdpMaxCols.L
; vdpMaxRows = 23;
       move.b    #23,_vdpMaxRows.L
; vdp_init_textmode(VDP_WHITE, VDP_BLACK);
       pea       1
       pea       15
       jsr       _vdp_init_textmode
       addq.w    #8,A7
; //---------------------------------------------
; // Zera Tudo (se tiver o que zerar), sem verificar, antes de testar
; xaddr = 0x00600000;
       move.l    #6291456,D2
; while (xaddr <= 0x00FFFFFE)
main_10:
       cmp.l     #16777214,D2
       bhi.s     main_12
; {
; *xaddr = 0x0000;
       move.l    D2,A0
       clr.w     (A0)
; xaddr += 32768;
       add.l     #65536,D2
       bra       main_10
main_12:
; }
; // Testando memoria RAM de 64 em 64K Word pra saber quando tem
; xaddr = 0x00600000;
       move.l    #6291456,D2
; xcounter = 0;
       clr.l     D4
; while (xaddr <= 0x00FFFFFE) {
main_13:
       cmp.l     #16777214,D2
       bhi       main_15
; // Se ja passou por esse endereco, cai fora - (caso de usar memoria de sistema como principal)
; xdado = *xaddr;
       move.l    D2,A0
       move.w    (A0),D5
; if (xaddr < 0x00800000 && xdado == 0x5A4C && !vRamSyst1st)
       cmp.l     #8388608,D2
       bhs.s     main_16
       cmp.w     #23116,D5
       bne.s     main_16
       tst.b     D7
       bne.s     main_18
       moveq     #1,D0
       bra.s     main_19
main_18:
       clr.l     D0
main_19:
       and.l     #255,D0
       beq.s     main_16
; {
; xaddr = 0x00800000;
       move.l    #8388608,D2
; continue;
       bra       main_14
main_16:
; }
; else
; {
; if (xaddr >= 0x00800000 && xdado == 0x5A4C && !vRamUser1st)
       cmp.l     #8388608,D2
       blo.s     main_20
       cmp.w     #23116,D5
       bne.s     main_20
       tst.b     D6
       bne.s     main_22
       moveq     #1,D0
       bra.s     main_23
main_22:
       clr.l     D0
main_23:
       and.l     #255,D0
       beq.s     main_20
; break;
       bra       main_15
main_20:
; }
; // Testa Gravacao de 0000h
; *xaddr = 0x0000;
       move.l    D2,A0
       clr.w     (A0)
; for(ix = 0; ix <= 100; ix++);
       clr.l     D3
main_24:
       cmp.l     #100,D3
       bhi.s     main_26
       addq.l    #1,D3
       bra       main_24
main_26:
; xdado = *xaddr;
       move.l    D2,A0
       move.w    (A0),D5
; if (xdado != 0x0000)
       tst.w     D5
       beq.s     main_27
; {
; if (xaddr < 0x00800000)
       cmp.l     #8388608,D2
       bhs.s     main_29
; {
; xaddr = 0x00800000;
       move.l    #8388608,D2
; continue;
       bra       main_14
main_29:
; }
; break;
       bra       main_15
main_27:
; }
; // Testa Gravacao de FFFFh
; *xaddr = 0xFFFF;
       move.l    D2,A0
       move.w    #65535,(A0)
; for(ix = 0; ix <= 100; ix++);
       clr.l     D3
main_31:
       cmp.l     #100,D3
       bhi.s     main_33
       addq.l    #1,D3
       bra       main_31
main_33:
; xdado = *xaddr;
       move.l    D2,A0
       move.w    (A0),D5
; if (xdado != 0xFFFF)
       cmp.w     #65535,D5
       beq.s     main_34
; {
; if (xaddr < 0x00800000)
       cmp.l     #8388608,D2
       bhs.s     main_36
; {
; xaddr = 0x00800000;
       move.l    #8388608,D2
; continue;
       bra.s     main_14
main_36:
; }
; break;
       bra.s     main_15
main_34:
; }
; // Se tudo ok, deixa gravado 0x5A4C para nao ler novamente - (caso de usar memoria de sistema como principal)
; *xaddr = 0x5A4C;
       move.l    D2,A0
       move.w    #23116,(A0)
; if (xaddr < 0x00800000)
       cmp.l     #8388608,D2
       bhs.s     main_38
; vRamSyst1st = 0;
       moveq     #0,D7
       bra.s     main_39
main_38:
; else
; vRamUser1st = 0;
       clr.b     D6
main_39:
; xcounter += 64; // dobrar a soma para aparecer em bytes e nao em words
       add.l     #64,D4
; // Limite maximo de contagem, 8MB
; if (xcounter >= 8448)
       cmp.l     #8448,D4
       blo.s     main_40
; break;
       bra.s     main_15
main_40:
; xaddr += 32768;
       add.l     #65536,D2
main_14:
       bra       main_13
main_15:
; }
; vtotmem = xcounter;
       move.b    D4,_vtotmem.L
; clearScr();
       jsr       _clearScr
; printText("MMSJ-320 BIOS v"versionBios);
       pea       @monitor_1.L
       jsr       (A3)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
; printText("Utility (c) 2014-2026\r\n\0");
       pea       @monitor_3.L
       jsr       (A3)
       addq.w    #4,A7
; itoa(xcounter, sqtdtam, 10);
       pea       10
       move.l    A4,-(A7)
       move.l    D4,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; printText("K Bytes Found. ");
       pea       @monitor_4.L
       jsr       (A3)
       addq.w    #4,A7
; xcounter = xcounter - 256;
       sub.l     #256,D4
; itoa(xcounter, sqtdtam, 10);
       pea       10
       move.l    A4,-(A7)
       move.l    D4,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A3)
       addq.w    #4,A7
; printText("K Bytes Free.\r\n\0");
       pea       @monitor_5.L
       jsr       (A3)
       addq.w    #4,A7
; if (!startBasic)
       tst.w     _startBasic.L
       bne.s     main_42
; {
; printText("OK\r\n\0");
       pea       @monitor_6.L
       jsr       (A3)
       addq.w    #4,A7
; printText(">");
       pea       @monitor_7.L
       jsr       (A3)
       addq.w    #4,A7
main_42:
; }
; showCursor();
       jsr       _showCursor
; vBufReceived = 0x00;
       clr.b     _vBufReceived.L
; vbuf[0] = '\0';
       clr.b     _vbuf.L
; SysClockms = 0;
       clr.l     _SysClockms.L
; #if defined(__KEYPS2__) || defined(__KEYPS2_EXT__)
; /*        *kbdvprim = 1;
; *kbdvshift = 0;
; *kbdvctrl = 0;
; *kbdvalt = 0;
; *kbdvcaps = 0;
; *kbdvnum = 0;
; *kbdvscr = 0;
; *kbdvreleased = 0x00;
; *kbdve0 = 0;
; *kbdClockCount = 0;*/
; kbdKeyBuffer[0] = 0x00;
       clr.b     _kbdKeyBuffer.L
; scanCode = 0;
       clr.b     _scanCode.L
; kbdKeyPtrR = 0;
       clr.b     _kbdKeyPtrR.L
; kbdKeyPtrW = 0;
       clr.b     _kbdKeyPtrW.L
; #ifdef __KEYPS2__
; kbdScanCodePtrR = 0;
; kbdScanCodePtrW = 0;
; kbdScanCodeBuf[0] = 0x00;
; #endif
; /*        *kbdtimeout = 0;
; *kbdPs2Readtype = 1;*/
; MseMovPtrR = 0;
       clr.b     _MseMovPtrR.L
; MseMovPtrW = 0;
       clr.b     _MseMovPtrW.L
; MseMovBuffer[0] = 0x00;
       clr.b     _MseMovBuffer.L
; // Ativando Interrupcao do Kbd/Mse PS/2
; *(vmfp + Reg_IERA) = 0xC0; // GPI6 and 7 will be KBD/MSE PS2 interrupt (clk pin OR DTRDYK/M pin)
       move.l    (A2),A0
       move.w    _Reg_IERA.L,D0
       and.l     #65535,D0
       move.b    #192,0(A0,D0.L)
; *(vmfp + Reg_IMRA) = 0xC0; // GPI6 and 7 will be KBD/MSE PS2 interrupt (clk pin OR DTRDYK/M pin)
       move.l    (A2),A0
       move.w    (A5),D0
       and.l     #65535,D0
       move.b    #192,0(A0,D0.L)
; #endif
; #ifdef __MOUSEPS2__
; *MseMovPntr = 0;
; *MseMovBuffer = 0;
; *MseClockCount = 0;
; *Msetimeout = 0;
; scanCodeMse = 0xFF;
; *vUseMouse = 0;
; ix = 0;
; do
; {
; // Send Reset
; writeMsePs2(0xFF);
; // Read 3 bytes Response
; *MseMovBuffer = readMsePs2();
; *(MseMovBuffer + 1) = readMsePs2();
; *(MseMovBuffer + 2) = readMsePs2();
; ix++;
; } while (*MseMovBuffer == 0xFE && ix++ < 4);
; if (*MseMovBuffer == 0xFA && *(MseMovBuffer + 1) == 0xAA)
; {
; flushMsePs2();
; // Send To know the ID
; writeMsePs2(0xF2);
; // Read 1 byte response
; *(MseMovBuffer + 4) = readMsePs2();
; *TypeMse = readMsePs2();
; flushMsePs2();
; ix = 3;
; do
; {
; if (ix > 3)
; delayus(100);
; // Send Enable
; writeMsePs2(0xF4);
; // Read 1 byte response
; *(MseMovBuffer + 3) = readMsePs2();
; ix++;
; } while (*(MseMovBuffer + 3) == 0xFE && ix < 7);
; if (*(MseMovBuffer + 3) == 0xFA)
; *vUseMouse = 0x01;
; }
; #endif
; inputTask();
       jsr       _inputTask
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void inputTask(void)
; {
       xdef      _inputTask
_inputTask:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/A2/A3,-(A7)
       lea       _vbuf.L,A2
       lea       _printChar.L,A3
; unsigned char vtec, vtecant = 0;
       clr.b     -1(A6)
; int vRetProcCmd, countCursor = 0;
       clr.l     D4
; unsigned char vbufptr = 0;
       clr.b     D3
; while (1)
inputTask_1:
; {
; // Piscar Cursor
; if (debugMessages) //(videoCursorBlink)
       tst.b     _debugMessages.L
       beq.s     inputTask_4
; {
; switch (countCursor)
       cmp.l     #12000,D4
       beq.s     inputTask_9
       bgt.s     inputTask_7
       cmp.l     #6000,D4
       beq.s     inputTask_8
       bra.s     inputTask_7
inputTask_8:
; {
; case 6000:  //20
; hideCursor();
       jsr       _hideCursor
; break;
       bra.s     inputTask_7
inputTask_9:
; case 12000: //40
; showCursor();
       jsr       _showCursor
; countCursor = 0;
       clr.l     D4
; break;
inputTask_7:
; }
; countCursor++;
       addq.l    #1,D4
inputTask_4:
; }
; vtec = readChar();
       jsr       _readChar
       move.b    D0,D2
; if (vtec)
       tst.b     D2
       beq       inputTask_10
; {
; hideCursor();
       jsr       _hideCursor
; if (vtec >= 0x20 && vtec != 0x7F)   // Caracter Printavel menos o DeLete
       cmp.b     #32,D2
       blo       inputTask_12
       cmp.b     #127,D2
       beq       inputTask_12
; {
; // Digitcao Normal
; if (vbufptr > 127)
       cmp.b     #127,D3
       bls.s     inputTask_14
; {
; vbufptr--;
       subq.b    #1,D3
; printChar(0x08, 1);
       pea       1
       pea       8
       jsr       (A3)
       addq.w    #8,A7
inputTask_14:
; }
; printChar(vtec, 1);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; vbuf[vbufptr++] = vtec;
       move.b    D3,D0
       addq.b    #1,D3
       and.l     #255,D0
       move.b    D2,0(A2,D0.L)
; vbuf[vbufptr] = '\0';
       and.l     #255,D3
       clr.b     0(A2,D3.L)
       bra       inputTask_20
inputTask_12:
; }
; else if (vtec == 0x08)  // Backspace
       cmp.b     #8,D2
       bne.s     inputTask_16
; {
; if (vbufptr > 0)
       cmp.b     #0,D3
       bls.s     inputTask_18
; {
; vbuf[vbufptr] = 0x00;
       and.l     #255,D3
       clr.b     0(A2,D3.L)
; vbufptr--;
       subq.b    #1,D3
; printChar(0x08, 1);
       pea       1
       pea       8
       jsr       (A3)
       addq.w    #8,A7
inputTask_18:
       bra       inputTask_20
inputTask_16:
; }
; }
; else if (vtec == 0x0D || vtec == 0x0A)
       cmp.b     #13,D2
       beq.s     inputTask_22
       cmp.b     #10,D2
       bne       inputTask_20
inputTask_22:
; {
; vRetProcCmd = 1;
       moveq     #1,D5
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       _printText
       addq.w    #4,A7
; vRetProcCmd = processCmd();
       jsr       _processCmd
       move.l    D0,D5
; vBufReceived = 0x00;
       clr.b     _vBufReceived.L
; vbuf[0] = '\0';
       clr.b     (A2)
; vbufptr = 0x00;
       clr.b     D3
; if (vRetProcCmd)
       tst.l     D5
       beq.s     inputTask_23
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       _printText
       addq.w    #4,A7
inputTask_23:
; printChar('>', 1);
       pea       1
       pea       62
       jsr       (A3)
       addq.w    #8,A7
inputTask_20:
; }
; showCursor();
       jsr       _showCursor
inputTask_10:
; }
; vtecant = vtec;
       move.b    D2,-1(A6)
       bra       inputTask_1
; }
; }
; //-----------------------------------------------------------------------------
; #ifdef __KEYPS2__
; void scanCodeTask(void *pdata)
; {
; unsigned int error_code = OS_ERR_NONE;
; while (1)
; {
; if (kbdScanCodePtrR != kbdScanCodePtrW)
; {
; // Pega proximo Scan Code disponivel
; scanCode = kbdScanCodeBuf[kbdScanCodePtrR];
; // Processa Codigo
; processCode();
; // Adiciona 1 no ponteiro de leitura do buffer circular
; kbdScanCodePtrR++;
; // Se chegar em 16, volta pra 0
; if (kbdScanCodePtrR > kbdKeyBuffMax)
; kbdScanCodePtrR = 0;
; }
; }
; }
; #endif
; //-----------------------------------------------------------------------------
; // pQtdInput - Quantidade a ser digitada, min 1 max 255
; // pTipo - Tipo de entrada:
; //                  input : $ - String, % - Inteiro (sem ponto), # - Real (com ponto), @ - Sem Cursor e Qualquer Coisa e sem enter
; //                   edit : S - String, I - Inteiro (sem ponto), R - Real (com ponto)
; //-----------------------------------------------------------------------------
; unsigned char inputLine(unsigned int pQtdInput, unsigned char pTipo)
; {
       xdef      _inputLine
_inputLine:
       link      A6,#-24
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _vbuf.L,A2
       move.b    15(A6),D3
       and.l     #255,D3
       lea       _printChar.L,A3
       lea       _vdp_set_cursor.L,A4
       move.l    8(A6),A5
; unsigned char *vbufptr = vbuf;
       move.l    A2,D6
; unsigned char vtec, vtecant;
; int vRetProcCmd, iw, ix;
; int countCursor = 0;
       clr.l     -16(A6)
; char pEdit = 0, pIns = 0, vbuftemp, vbuftemp2;
       clr.b     -12(A6)
       clr.b     -11(A6)
; int iPos, iz;
; unsigned short vantX, vantY;
; if (pQtdInput == 0)
       move.l    A5,D0
       bne.s     inputLine_1
; pQtdInput = 512;
       move.w    #512,A5
inputLine_1:
; vtecant = 0x00;
       clr.b     -21(A6)
; vbufptr = vbuf;
       move.l    A2,D6
; // Se for Linha editavel apresenta a linha na tela
; if (pTipo == 'S' || pTipo == 'I' || pTipo == 'R')
       cmp.b     #83,D3
       beq.s     inputLine_5
       cmp.b     #73,D3
       beq.s     inputLine_5
       cmp.b     #82,D3
       bne       inputLine_3
inputLine_5:
; {
; // Apresenta a linha na tela, e posiciona o cursor na tela na primeira posicao valida
; iw = strlen(vbuf) / 40;
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-(A7)
       pea       40
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,D7
; printText(vbuf);
       move.l    A2,-(A7)
       jsr       _printText
       addq.w    #4,A7
; videoCursorPosRowY -= iw;
       sub.w     D7,_videoCursorPosRowY.L
; videoCursorPosColX = 0;
       clr.w     _videoCursorPosColX.L
; pEdit = 1;
       move.b    #1,-12(A6)
; iPos = 0;
       clr.l     D4
; pIns = 0xFF;
       move.b    #255,-11(A6)
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
inputLine_3:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_6
; showCursor();
       jsr       _showCursor
inputLine_6:
; while (1)
inputLine_8:
; {
; // Piscar Cursor
; if (videoCursorBlink && pTipo != '@')
       move.b    _videoCursorBlink.L,D0
       and.l     #255,D0
       beq       inputLine_11
       cmp.b     #64,D3
       beq       inputLine_11
; {
; switch (countCursor)
       move.l    -16(A6),D0
       cmp.l     #12000,D0
       beq.s     inputLine_16
       bgt.s     inputLine_14
       cmp.l     #6000,D0
       beq.s     inputLine_15
       bra.s     inputLine_14
inputLine_15:
; {
; case 6000:
; hideCursor();
       jsr       _hideCursor
; if (pEdit)
       tst.b     -12(A6)
       beq.s     inputLine_17
; printChar(vbuf[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
inputLine_17:
; break;
       bra.s     inputLine_14
inputLine_16:
; case 12000:
; showCursor();
       jsr       _showCursor
; countCursor = 0;
       clr.l     -16(A6)
; break;
inputLine_14:
; }
; countCursor++;
       addq.l    #1,-16(A6)
inputLine_11:
; }
; // Inicia leitura
; vtec = readChar();
       jsr       _readChar
       move.b    D0,D2
; if (pTipo == '@')
       cmp.b     #64,D3
       bne.s     inputLine_19
; return vtec;
       move.b    D2,D0
       bra       inputLine_21
inputLine_19:
; // Se nao for string ($ e S) ou Tudo (@), só aceita numeros
; if (pTipo != '$' && pTipo != 'S' && pTipo != '@' && vtec != '.' && vtec > 0x1F && (vtec < 0x30 || vtec > 0x39))
       cmp.b     #36,D3
       beq.s     inputLine_22
       cmp.b     #83,D3
       beq.s     inputLine_22
       cmp.b     #64,D3
       beq.s     inputLine_22
       cmp.b     #46,D2
       beq.s     inputLine_22
       cmp.b     #31,D2
       bls.s     inputLine_22
       cmp.b     #48,D2
       blo.s     inputLine_24
       cmp.b     #57,D2
       bls.s     inputLine_22
inputLine_24:
; vtec = 0;
       clr.b     D2
inputLine_22:
; // So aceita ponto de for numero real (# ou R) ou string ($ ou S) ou tudo (@)
; if (vtec == '.' && pTipo != '#' && pTipo != '$' &&  pTipo != 'R' && pTipo != 'S' && pTipo != '@')
       cmp.b     #46,D2
       bne.s     inputLine_25
       cmp.b     #35,D3
       beq.s     inputLine_25
       cmp.b     #36,D3
       beq.s     inputLine_25
       cmp.b     #82,D3
       beq.s     inputLine_25
       cmp.b     #83,D3
       beq.s     inputLine_25
       cmp.b     #64,D3
       beq.s     inputLine_25
; vtec = 0;
       clr.b     D2
inputLine_25:
; if (vtec)
       tst.b     D2
       beq       inputLine_27
; {
; // Prevenir sujeira no buffer ou repeticao
; if (vtec == vtecant)
       cmp.b     -21(A6),D2
       bne.s     inputLine_31
; {
; if (countCursor % 300 != 0)
       move.l    -16(A6),-(A7)
       pea       300
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       beq.s     inputLine_31
; continue;
       bra       inputLine_28
inputLine_31:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_35
; {
; hideCursor();
       jsr       _hideCursor
; if (pEdit)
       tst.b     -12(A6)
       beq.s     inputLine_35
; printChar(vbuf[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
inputLine_35:
; }
; vtecant = vtec;
       move.b    D2,-21(A6)
; if (vtec >= 0x20 && vtec != 0x7F)   // Caracter Printavel menos o DELete
       cmp.b     #32,D2
       blo       inputLine_37
       cmp.b     #127,D2
       beq       inputLine_37
; {
; if (!pEdit)
       tst.b     -12(A6)
       bne       inputLine_39
; {
; // Digitcao Normal
; if (vbufptr > vbuf + pQtdInput)
       move.l    A2,D0
       add.l     A5,D0
       cmp.l     D0,D6
       bls.s     inputLine_43
; {
; *vbufptr--;
       move.l    D6,A0
       subq.l    #1,D6
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_43
; printChar(0x08, 1);
       pea       1
       pea       8
       jsr       (A3)
       addq.w    #8,A7
inputLine_43:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_45
; printChar(vtec, 1);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
inputLine_45:
; *vbufptr++ = vtec;
       move.l    D6,A0
       addq.l    #1,D6
       move.b    D2,(A0)
; *vbufptr = '\0';
       move.l    D6,A0
       clr.b     (A0)
       bra       inputLine_58
inputLine_39:
; }
; else
; {
; iw = strlen(vbuf);
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D7
; // Edicao de Linha
; if (!pIns)
       tst.b     -11(A6)
       bne.s     inputLine_47
; {
; // Sem insercao de caracteres
; if (iw < pQtdInput)
       cmp.l     A5,D7
       bhs.s     inputLine_49
; {
; if (vbuf[iPos] == 0x00)
       move.b    0(A2,D4.L),D0
       bne.s     inputLine_51
; vbuf[iPos + 1] = 0x00;
       move.l    D4,A0
       clr.b     1(A0,A2.L)
inputLine_51:
; vbuf[iPos] = vtec;
       move.b    D2,0(A2,D4.L)
; printChar(vbuf[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
inputLine_49:
       bra       inputLine_53
inputLine_47:
; }
; }
; else
; {
; // Com insercao de caracteres
; if ((iw + 1) <= pQtdInput)
       move.l    D7,D0
       addq.l    #1,D0
       cmp.l     A5,D0
       bhi       inputLine_53
; {
; // Copia todos os caracteres mais 1 pro final
; vbuftemp2 = vbuf[iPos];
       move.b    0(A2,D4.L),-9(A6)
; vbuftemp = vbuf[iPos + 1];
       move.l    D4,A0
       move.b    1(A0,A2.L),-10(A6)
; vantX = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,-4(A6)
; vantY = videoCursorPosRowY;
       move.w    _videoCursorPosRowY.L,-2(A6)
; printChar(vtec,1);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; for (ix = iPos; ix <= iw ; ix++)
       move.l    D4,D5
inputLine_55:
       cmp.l     D7,D5
       bgt.s     inputLine_57
; {
; vbuf[ix + 1] = vbuftemp2;
       move.l    D5,A0
       move.b    -9(A6),1(A0,A2.L)
; vbuftemp2 = vbuftemp;
       move.b    -10(A6),-9(A6)
; vbuftemp = vbuf[ix + 2];
       move.l    D5,A0
       move.b    2(A0,A2.L),-10(A6)
; printChar(vbuf[ix + 1],1);
       pea       1
       move.l    D5,A0
       move.b    1(A0,A2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D5
       bra       inputLine_55
inputLine_57:
; }
; vbuf[iw + 1] = 0x00;
       move.l    D7,A0
       clr.b     1(A0,A2.L)
; vbuf[iPos] = vtec;
       move.b    D2,0(A2,D4.L)
; videoCursorPosColX = vantX;
       move.w    -4(A6),_videoCursorPosColX.L
; videoCursorPosRowY = vantY;
       move.w    -2(A6),_videoCursorPosRowY.L
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
inputLine_53:
; }
; }
; if (iw <= pQtdInput)
       cmp.l     A5,D7
       bhi.s     inputLine_58
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
       jsr       (A4)
       addq.w    #8,A7
inputLine_58:
       bra       inputLine_105
inputLine_37:
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
       move.b    -12(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLine_60
       cmp.b     #18,D2
       bne       inputLine_60
; {
; if (iPos > 0)
       cmp.l     #0,D4
       ble       inputLine_62
; {
; printChar(vbuf[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; iPos--;
       subq.l    #1,D4
; if (videoCursorPosColX == 0)
       move.w    _videoCursorPosColX.L,D0
       bne.s     inputLine_64
; videoCursorPosColX = 255;
       move.w    #255,_videoCursorPosColX.L
       bra.s     inputLine_65
inputLine_64:
; else
; videoCursorPosColX = videoCursorPosColX - 1;
       subq.w    #1,_videoCursorPosColX.L
inputLine_65:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
inputLine_62:
       bra       inputLine_105
inputLine_60:
; }
; }
; else if (pEdit && vtec == 0x14)    // RightArrow (20)
       move.b    -12(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLine_66
       cmp.b     #20,D2
       bne       inputLine_66
; {
; if (iPos < strlen(vbuf))
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     D0,D4
       bge       inputLine_68
; {
; printChar(vbuf[iPos],0);
       clr.l     -(A7)
       move.b    0(A2,D4.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
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
       jsr       (A4)
       addq.w    #8,A7
inputLine_68:
       bra       inputLine_105
inputLine_66:
; }
; }
; else if (vtec == 0x15)  // Insert
       cmp.b     #21,D2
       bne.s     inputLine_70
; {
; pIns = ~pIns;
       move.b    -11(A6),D0
       not.b     D0
       move.b    D0,-11(A6)
       bra       inputLine_105
inputLine_70:
; }
; else if (vtec == 0x08 && !pEdit)  // Backspace
       cmp.b     #8,D2
       bne       inputLine_72
       tst.b     -12(A6)
       bne.s     inputLine_74
       moveq     #1,D0
       bra.s     inputLine_75
inputLine_74:
       clr.l     D0
inputLine_75:
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq.s     inputLine_72
; {
; // Digitcao Normal
; if (vbufptr > vbuf)
       cmp.l     A2,D6
       bls.s     inputLine_78
; {
; *vbufptr--;
       move.l    D6,A0
       subq.l    #1,D6
; *vbufptr = 0x00;
       move.l    D6,A0
       clr.b     (A0)
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_78
; printChar(0x08, 1);
       pea       1
       pea       8
       jsr       (A3)
       addq.w    #8,A7
inputLine_78:
       bra       inputLine_105
inputLine_72:
; }
; }
; else if ((vtec == 0x08 || vtec == 0x7F) && pEdit)  // Backspace
       cmp.b     #8,D2
       beq.s     inputLine_82
       cmp.b     #127,D2
       bne       inputLine_80
inputLine_82:
       move.b    -12(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLine_80
; {
; iw = strlen(vbuf);
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D7
; if ((vtec == 0x08 && iPos > 0) || vtec == 0x7F)
       cmp.b     #8,D2
       bne.s     inputLine_86
       cmp.l     #0,D4
       bgt.s     inputLine_85
inputLine_86:
       cmp.b     #127,D2
       bne       inputLine_83
inputLine_85:
; {
; if (vtec == 0x08)
       cmp.b     #8,D2
       bne.s     inputLine_87
; {
; iPos--;
       subq.l    #1,D4
; if (videoCursorPosColX == 0)
       move.w    _videoCursorPosColX.L,D0
       bne.s     inputLine_89
; videoCursorPosColX = 255;
       move.w    #255,_videoCursorPosColX.L
       bra.s     inputLine_90
inputLine_89:
; else
; videoCursorPosColX = videoCursorPosColX - 1;
       subq.w    #1,_videoCursorPosColX.L
inputLine_90:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
inputLine_87:
; }
; vantX = videoCursorPosColX;
       move.w    _videoCursorPosColX.L,-4(A6)
; vantY = videoCursorPosRowY;
       move.w    _videoCursorPosRowY.L,-2(A6)
; for (ix = iPos; ix < iw ; ix++)
       move.l    D4,D5
inputLine_91:
       cmp.l     D7,D5
       bge.s     inputLine_93
; {
; vbuf[ix] = vbuf[ix + 1];
       move.l    D5,A0
       move.b    1(A0,A2.L),0(A2,D5.L)
; printChar(vbuf[ix],1);
       pea       1
       move.b    0(A2,D5.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D5
       bra       inputLine_91
inputLine_93:
; }
; vbuf[ix] = 0x00;
       clr.b     0(A2,D5.L)
; videoCursorPosColX = vantX;
       move.w    -4(A6),_videoCursorPosColX.L
; videoCursorPosRowY = vantY;
       move.w    -2(A6),_videoCursorPosRowY.L
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.w    _videoCursorPosRowY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _videoCursorPosColX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A4)
       addq.w    #8,A7
inputLine_83:
       bra       inputLine_105
inputLine_80:
; }
; }
; else if (vtec == 0x1B)   // ESC
       cmp.b     #27,D2
       bne       inputLine_94
; {
; // Limpa a linha, esvazia o buffer e retorna tecla
; while (vbufptr > vbuf)
inputLine_96:
       cmp.l     A2,D6
       bls       inputLine_98
; {
; *vbufptr--;
       move.l    D6,A0
       subq.l    #1,D6
; *vbufptr = 0x00;
       move.l    D6,A0
       clr.b     (A0)
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_99
; hideCursor();
       jsr       _hideCursor
inputLine_99:
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_101
; printChar(0x08, 1);
       pea       1
       pea       8
       jsr       (A3)
       addq.w    #8,A7
inputLine_101:
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_103
; showCursor();
       jsr       _showCursor
inputLine_103:
       bra       inputLine_96
inputLine_98:
; }
; hideCursor();
       jsr       _hideCursor
; return vtec;
       move.b    D2,D0
       bra.s     inputLine_21
inputLine_94:
; }
; else if (vtec == 0x0D || vtec == 0x0A ) // CR ou LF
       cmp.b     #13,D2
       beq.s     inputLine_107
       cmp.b     #10,D2
       bne.s     inputLine_105
inputLine_107:
; {
; return vtec;
       move.b    D2,D0
       bra.s     inputLine_21
inputLine_105:
; }
; if (pTipo != '@')
       cmp.b     #64,D3
       beq.s     inputLine_108
; showCursor();
       jsr       _showCursor
inputLine_108:
       bra.s     inputLine_28
inputLine_27:
; }
; else
; {
; vtecant = 0x00;
       clr.b     -21(A6)
inputLine_28:
       bra       inputLine_8
inputLine_21:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; return 0x00;
; }
; //-----------------------------------------------------------------------------
; int processCmd(void)
; {
       xdef      _processCmd
_processCmd:
       link      A6,#-156
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -156(A6),A2
       lea       _strcmp.L,A3
       lea       -124(A6),A4
       lea       -70(A6),A5
; unsigned char linhacomando[32], linhaarg[32], vloop;
; unsigned char *blin = vbuf;
       lea       _vbuf.L,A0
       move.l    A0,D7
; unsigned char *vEndLoad = 0x00000000;
       clr.l     D6
; unsigned short varg = 0;
       clr.w     D4
; unsigned short ix, iy, iz, ikk, izz;
; unsigned short vbytepic = 0, vrecfim;
       clr.w     -86(A6)
; unsigned char sqtdtam[10], cuntam, vparam[32], vparam2[16], vparam3[16], vpicret, vresp;
; int vRet = 1;
       move.l    #1,-4(A6)
; // Separar linha entre comando e argumento
; linhacomando[0] = '\0';
       clr.b     (A2)
; linhaarg[0] = '\0';
       clr.b     (A4)
; ix = 0;
       clr.w     D3
; iy = 0;
       clr.w     D2
; while (*blin)
processCmd_1:
       move.l    D7,A0
       tst.b     (A0)
       beq       processCmd_3
; {
; if (!varg && *blin == 0x20)
       tst.w     D4
       bne.s     processCmd_6
       moveq     #1,D0
       bra.s     processCmd_7
processCmd_6:
       clr.l     D0
processCmd_7:
       and.l     #65535,D0
       beq.s     processCmd_4
       move.l    D7,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       bne.s     processCmd_4
; {
; varg = 0x01;
       moveq     #1,D4
; linhacomando[ix] = '\0';
       and.l     #65535,D3
       clr.b     0(A2,D3.L)
; iy = ix;
       move.w    D3,D2
; ix = 0;
       clr.w     D3
       bra       processCmd_5
processCmd_4:
; }
; else
; {
; if (!varg)
       tst.w     D4
       bne.s     processCmd_8
; linhacomando[ix] = toupper(*blin);
       move.l    D7,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       and.l     #65535,D3
       move.b    D0,0(A2,D3.L)
       bra.s     processCmd_9
processCmd_8:
; else
; linhaarg[ix] = toupper(*blin);
       move.l    D7,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       and.l     #65535,D3
       move.b    D0,0(A4,D3.L)
processCmd_9:
; ix++;
       addq.w    #1,D3
processCmd_5:
; }
; *blin++;
       move.l    D7,A0
       addq.l    #1,D7
       bra       processCmd_1
processCmd_3:
; }
; if (!varg)
       tst.w     D4
       bne.s     processCmd_10
; {
; linhacomando[ix] = '\0';
       and.l     #65535,D3
       clr.b     0(A2,D3.L)
; iy = ix;
       move.w    D3,D2
       bra       processCmd_14
processCmd_10:
; }
; else
; {
; linhaarg[ix] = '\0';
       and.l     #65535,D3
       clr.b     0(A4,D3.L)
; ikk = 0;
       clr.w     D5
; iz = 0;
       clr.w     -90(A6)
; izz = 0;
       clr.w     -88(A6)
; varg = 0;
       clr.w     D4
; while (ikk < ix)
processCmd_12:
       cmp.w     D3,D5
       bhs       processCmd_14
; {
; if (linhaarg[ikk] == 0x20)
       and.l     #65535,D5
       move.b    0(A4,D5.L),D0
       cmp.b     #32,D0
       bne.s     processCmd_15
; varg++;
       addq.w    #1,D4
       bra       processCmd_21
processCmd_15:
; else
; {
; if (!varg)
       tst.w     D4
       bne.s     processCmd_17
; vparam[ikk] = linhaarg[ikk];
       and.l     #65535,D5
       and.l     #65535,D5
       move.b    0(A4,D5.L),0(A5,D5.L)
       bra.s     processCmd_21
processCmd_17:
; else if (varg == 1)
       cmp.w     #1,D4
       bne.s     processCmd_19
; {
; vparam2[iz] = linhaarg[ikk];
       and.l     #65535,D5
       move.w    -90(A6),D0
       and.l     #65535,D0
       move.b    0(A4,D5.L),-38(A6,D0.L)
; iz++;
       addq.w    #1,-90(A6)
       bra.s     processCmd_21
processCmd_19:
; }
; else if (varg == 2)
       cmp.w     #2,D4
       bne.s     processCmd_21
; {
; vparam3[izz] = linhaarg[ikk];
       and.l     #65535,D5
       move.w    -88(A6),D0
       and.l     #65535,D0
       move.b    0(A4,D5.L),-22(A6,D0.L)
; izz++;
       addq.w    #1,-88(A6)
processCmd_21:
; }
; }
; ikk++;
       addq.w    #1,D5
       bra       processCmd_12
processCmd_14:
; }
; }
; vparam[ikk] = '\0';
       and.l     #65535,D5
       clr.b     0(A5,D5.L)
; vparam2[iz] = '\0';
       move.w    -90(A6),D0
       and.l     #65535,D0
       clr.b     -38(A6,D0.L)
; vparam3[izz] = '\0';
       move.w    -88(A6),D0
       and.l     #65535,D0
       clr.b     -22(A6,D0.L)
; vpicret = 0;
       clr.b     -6(A6)
; // Processar e definir o que fazer
; if (linhacomando[0] != 0)
       move.b    (A2),D0
       beq       processCmd_61
; {
; if (!strcmp(linhacomando,"CLS") && iy == 3)
       pea       @monitor_8.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_25
       cmp.w     #3,D2
       bne.s     processCmd_25
; {
; clearScr();
       jsr       _clearScr
; vRet = 0;
       clr.l     -4(A6)
       bra       processCmd_61
processCmd_25:
; }
; else if (!strcmp(linhacomando,"CLEAR") && iy == 5)
       pea       @monitor_9.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_27
       cmp.w     #5,D2
       bne.s     processCmd_27
; {
; clearScr();
       jsr       _clearScr
; vRet = 0;
       clr.l     -4(A6)
       bra       processCmd_61
processCmd_27:
; }
; else if (!strcmp(linhacomando,"VER") && iy == 3)
       pea       @monitor_10.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_29
       cmp.w     #3,D2
       bne.s     processCmd_29
; {
; printText("MMSJ-320 BIOS v"versionBios);
       pea       @monitor_1.L
       jsr       _printText
       addq.w    #4,A7
       bra       processCmd_61
processCmd_29:
; }
; else if (!strcmp(linhacomando,"LOAD") && iy == 4)
       pea       @monitor_11.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne       processCmd_31
       cmp.w     #4,D2
       bne.s     processCmd_31
; {
; printText("Wait...\r\n\0");
       pea       @monitor_12.L
       jsr       _printText
       addq.w    #4,A7
; if (linhaarg[0] != 0x00)
       move.b    (A4),D0
       beq.s     processCmd_33
; vEndLoad = hexToLong(linhaarg);
       move.l    A4,-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,D6
processCmd_33:
; loadSerialToMem(vEndLoad, 1);
       pea       1
       move.l    D6,-(A7)
       jsr       _loadSerialToMem
       addq.w    #8,A7
       bra       processCmd_61
processCmd_31:
; }
; else if (!strcmp(linhacomando,"RUN") && iy == 3)
       pea       @monitor_13.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_35
       cmp.w     #3,D2
       bne.s     processCmd_35
; {
; if (linhaarg[0] != 0x00)
       move.b    (A4),D0
       beq.s     processCmd_37
; vEndLoad = hexToLong(linhaarg);
       move.l    A4,-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,D6
       bra.s     processCmd_38
processCmd_37:
; else
; vEndLoad = 0x00810000;
       move.l    #8454144,D6
processCmd_38:
; runMem(vEndLoad);
       move.l    D6,-(A7)
       jsr       _runMem
       addq.w    #4,A7
       bra       processCmd_61
processCmd_35:
; }
; else if (!strcmp(linhacomando,"BASIC") && iy == 5)
       pea       @monitor_14.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_39
       cmp.w     #5,D2
       bne.s     processCmd_39
; {
; runBasic(linhaarg);
       move.l    A4,-(A7)
       jsr       _runBasic
       addq.w    #4,A7
       bra       processCmd_61
processCmd_39:
; }
; else if (!strcmp(linhacomando,"MODE") && iy == 4)
       pea       @monitor_15.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_41
       cmp.w     #4,D2
       bne.s     processCmd_41
; {
; modeVideo(vparam);
       move.l    A5,-(A7)
       jsr       _modeVideo
       addq.w    #4,A7
       bra       processCmd_61
processCmd_41:
; }
; else if (!strcmp(linhacomando,"POKE") && iy == 4)
       pea       @monitor_16.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_43
       cmp.w     #4,D2
       bne.s     processCmd_43
; {
; pokeMem(vparam, vparam2);
       pea       -38(A6)
       move.l    A5,-(A7)
       jsr       _pokeMem
       addq.w    #8,A7
       bra       processCmd_61
processCmd_43:
; }
; else if (!strcmp(linhacomando,"LOADSO") && iy == 6)
       pea       @monitor_17.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_45
       cmp.w     #6,D2
       bne.s     processCmd_45
; {
; carregaOSDisk();
       jsr       _carregaOSDisk
       bra       processCmd_61
processCmd_45:
; }
; else if (!strcmp(linhacomando,"RUNSO") && iy == 5)
       pea       @monitor_18.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_47
       cmp.w     #5,D2
       bne.s     processCmd_47
; {
; runSystemOper();
       jsr       _runSystemOper
       bra       processCmd_61
processCmd_47:
; }
; else if (!strcmp(linhacomando,"DEBUG") && iy == 5)
       pea       @monitor_19.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_49
       cmp.w     #5,D2
       bne.s     processCmd_49
; {
; if (debugMessages)
       tst.b     _debugMessages.L
       beq.s     processCmd_51
; {
; debugMessages = 0;
       clr.b     _debugMessages.L
; printText("Debug Messages Off\r\n\0");
       pea       @monitor_20.L
       jsr       _printText
       addq.w    #4,A7
       bra.s     processCmd_52
processCmd_51:
; }
; else
; {
; debugMessages = 1;
       move.b    #1,_debugMessages.L
; printText("Debug Messages On\r\n\0");
       pea       @monitor_21.L
       jsr       _printText
       addq.w    #4,A7
processCmd_52:
       bra       processCmd_61
processCmd_49:
; }
; }
; else if (strcmp(linhacomando,"DUMP") == 0 && iy == 4)
       pea       @monitor_22.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_53
       cmp.w     #4,D2
       bne.s     processCmd_53
; {
; dumpMem(vparam, vparam2, vparam3);
       pea       -22(A6)
       pea       -38(A6)
       move.l    A5,-(A7)
       jsr       _dumpMem
       add.w     #12,A7
       bra       processCmd_61
processCmd_53:
; }
; else if (strcmp(linhacomando,"DDUUMMPP") == 0 && iy == 8)
       pea       @monitor_23.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_55
       cmp.w     #8,D2
       bne.s     processCmd_55
; {
; dumpMem("6020A0\0", "128\0", "\0");
       pea       @monitor_26.L
       pea       @monitor_25.L
       pea       @monitor_24.L
       jsr       _dumpMem
       add.w     #12,A7
       bra       processCmd_61
processCmd_55:
; }
; else if (strcmp(linhacomando,"DUMPS") == 0 && linhacomando[4] == 'S' && iy == 5)
       pea       @monitor_27.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_57
       move.b    4(A2),D0
       cmp.b     #83,D0
       bne.s     processCmd_57
       cmp.w     #5,D2
       bne.s     processCmd_57
; {
; dumpMem2(vparam, vparam2);
       pea       -38(A6)
       move.l    A5,-(A7)
       jsr       _dumpMem2
       addq.w    #8,A7
       bra       processCmd_61
processCmd_57:
; }
; else if (strcmp(linhacomando,"DUMPW") == 0 && linhacomando[4] == 'W' && iy == 5)
       pea       @monitor_28.L
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       tst.l     D0
       bne.s     processCmd_59
       move.b    4(A2),D0
       cmp.b     #87,D0
       bne.s     processCmd_59
       cmp.w     #5,D2
       bne.s     processCmd_59
; {
; dumpMemWin(vparam, vparam2, vparam3);
       pea       -22(A6)
       pea       -38(A6)
       move.l    A5,-(A7)
       jsr       _dumpMemWin
       add.w     #12,A7
       bra.s     processCmd_61
processCmd_59:
; }
; else
; {
; vresp = 0;
       clr.b     -5(A6)
; if (!vresp)
       tst.b     -5(A6)
       bne.s     processCmd_61
; printText("Unknown Command !!!\r\n\0");
       pea       @monitor_29.L
       jsr       _printText
       addq.w    #4,A7
processCmd_61:
; }
; }
; return vRet;
       move.l    -4(A6),D0
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned char readMouse(unsigned char *vStat, unsigned char *vMovX, unsigned char *vMovY)
; {
       xdef      _readMouse
_readMouse:
       link      A6,#0
       movem.l   D2/D3/D4/D5/A2,-(A7)
       lea       _MseMovBuffer.L,A2
       move.l    16(A6),D3
       move.l    12(A6),D4
       move.l    8(A6),D5
; unsigned char ix = 0;
       clr.b     D2
; *vStat = 0;
       move.l    D5,A0
       clr.b     (A0)
; *vMovX = 0;
       move.l    D4,A0
       clr.b     (A0)
; *vMovY = 0;
       move.l    D3,A0
       clr.b     (A0)
; if (MseMovPtrR != MseMovPtrW)
       move.b    _MseMovPtrR.L,D0
       cmp.b     _MseMovPtrW.L,D0
       beq       readMouse_5
; {
; // Pega proximos 3 status do mouse disponivel
; for(ix=0; ix<3; ix++)
       clr.b     D2
readMouse_3:
       cmp.b     #3,D2
       bhs       readMouse_5
; {
; switch (ix)
       and.l     #255,D2
       cmp.l     #1,D2
       beq.s     readMouse_9
       bhi.s     readMouse_11
       tst.l     D2
       beq.s     readMouse_8
       bra       readMouse_7
readMouse_11:
       cmp.l     #2,D2
       beq.s     readMouse_10
       bra.s     readMouse_7
readMouse_8:
; {
; case 0:
; *vStat = MseMovBuffer[MseMovPtrR];
       move.b    _MseMovPtrR.L,D0
       and.l     #255,D0
       move.l    D5,A0
       move.b    0(A2,D0.L),(A0)
; break;
       bra.s     readMouse_7
readMouse_9:
; case 1:
; *vMovX = MseMovBuffer[MseMovPtrR];
       move.b    _MseMovPtrR.L,D0
       and.l     #255,D0
       move.l    D4,A0
       move.b    0(A2,D0.L),(A0)
; break;
       bra.s     readMouse_7
readMouse_10:
; case 2:
; *vMovY = MseMovBuffer[MseMovPtrR];
       move.b    _MseMovPtrR.L,D0
       and.l     #255,D0
       move.l    D3,A0
       move.b    0(A2,D0.L),(A0)
; break;
readMouse_7:
; }
; MseMovPtrR++;
       addq.b    #1,_MseMovPtrR.L
; if (MseMovPtrR > kbdKeyBuffMax)
       move.b    _MseMovPtrR.L,D0
       cmp.b     #65,D0
       bls.s     readMouse_12
; MseMovPtrR = 0;
       clr.b     _MseMovPtrR.L
readMouse_12:
; // Erro de leitura ou gravacao vinda do mouse. Ignora essa leitura
; if (MseMovPtrR == MseMovPtrW && ix < 2)
       move.b    _MseMovPtrR.L,D0
       cmp.b     _MseMovPtrW.L,D0
       bne.s     readMouse_14
       cmp.b     #2,D2
       bhs.s     readMouse_14
; {
; *vStat = 0;
       move.l    D5,A0
       clr.b     (A0)
; *vMovX = 0;
       move.l    D4,A0
       clr.b     (A0)
; *vMovY = 0;
       move.l    D3,A0
       clr.b     (A0)
; ix = 0;
       clr.b     D2
; break;
       bra.s     readMouse_5
readMouse_14:
       addq.b    #1,D2
       bra       readMouse_3
readMouse_5:
; }
; }
; }
; return ix;
       move.b    D2,D0
       movem.l   (A7)+,D2/D3/D4/D5/A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned char readChar(void)
; {
       xdef      _readChar
_readChar:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       _vBufReceived.L,A2
; unsigned char ix = 0, vmove;
       clr.b     -2(A6)
; vBufReceived = 0;
       clr.b     (A2)
; if (kbdKeyPtrR != kbdKeyPtrW)
       move.b    _kbdKeyPtrR.L,D0
       cmp.b     _kbdKeyPtrW.L,D0
       beq.s     readChar_3
; {
; // Pega proxima tecla disponivel
; vBufReceived = kbdKeyBuffer[kbdKeyPtrR];
       move.b    _kbdKeyPtrR.L,D0
       and.l     #255,D0
       lea       _kbdKeyBuffer.L,A0
       move.b    0(A0,D0.L),(A2)
; kbdKeyPtrR++;
       addq.b    #1,_kbdKeyPtrR.L
; if (kbdKeyPtrR > kbdKeyBuffMax)
       move.b    _kbdKeyPtrR.L,D0
       cmp.b     #65,D0
       bls.s     readChar_3
; kbdKeyPtrR = 0;
       clr.b     _kbdKeyPtrR.L
readChar_3:
; }
; #ifdef __MON_SERIAL_KBD__
; if (vBufReceived == 0x00)
; {
; if ((*(vmfp + Reg_RSR) & 0x80))  // Se buffer de recepcao cheio
; {
; vBufReceived = *(vmfp + Reg_UDR);
; }
; }
; #endif
; return vBufReceived;
       move.b    (A2),D0
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void hideCursor(void)
; {
       xdef      _hideCursor
_hideCursor:
; if (!videoCursorShow)  // Cursor já esta escondido, nao faz nada
       tst.b     _videoCursorShow.L
       bne.s     hideCursor_1
; return;
       bra.s     hideCursor_3
hideCursor_1:
; videoCursorShow = 0;
       clr.b     _videoCursorShow.L
; printChar(0xFF, 1);
       pea       1
       pea       255
       jsr       _printChar
       addq.w    #8,A7
hideCursor_3:
       rts
; }
; //-----------------------------------------------------------------------------
; void showCursor(void)
; {
       xdef      _showCursor
_showCursor:
; if (videoCursorShow)   // Cursor já esta aparecendo, nao faz nada
       tst.b     _videoCursorShow.L
       beq.s     showCursor_1
; return;
       bra.s     showCursor_3
showCursor_1:
; videoCursorShow = 1;
       move.b    #1,_videoCursorShow.L
; printChar(0xFF, 1);
       pea       1
       pea       255
       jsr       _printChar
       addq.w    #8,A7
showCursor_3:
       rts
; }
; //-----------------------------------------------------------------------------
; void modeVideo(unsigned char *pMode)
; {
       xdef      _modeVideo
_modeVideo:
       link      A6,#0
       movem.l   D2/A2,-(A7)
       lea       _printText.L,A2
; unsigned long vMode = 0;
       clr.l     D2
; if (pMode[0] != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq       modeVideo_1
; {
; vMode = atol(pMode);
       move.l    8(A6),-(A7)
       jsr       _atol
       addq.w    #4,A7
       move.l    D0,D2
; if (vMode <= 3)
       cmp.l     #3,D2
       bhi       modeVideo_3
; {
; switch(vMode)
       move.l    D2,D0
       cmp.l     #4,D0
       bhs       modeVideo_6
       asl.l     #1,D0
       move.w    modeVideo_7(PC,D0.L),D0
       jmp       modeVideo_7(PC,D0.W)
modeVideo_7:
       dc.w      modeVideo_8-modeVideo_7
       dc.w      modeVideo_9-modeVideo_7
       dc.w      modeVideo_10-modeVideo_7
       dc.w      modeVideo_11-modeVideo_7
modeVideo_8:
; {
; case 0:
; vdp_init_textmode(VDP_WHITE, VDP_BLACK);
       pea       1
       pea       15
       jsr       _vdp_init_textmode
       addq.w    #8,A7
; break;
       bra.s     modeVideo_6
modeVideo_9:
; case 1:
; vdp_init_g1(VDP_WHITE, VDP_BLACK);
       pea       1
       pea       15
       jsr       _vdp_init_g1
       addq.w    #8,A7
; break;
       bra.s     modeVideo_6
modeVideo_10:
; case 2:
; vdp_init_g2(1, 0);
       clr.l     -(A7)
       pea       1
       jsr       _vdp_init_g2
       addq.w    #8,A7
; break;
       bra.s     modeVideo_6
modeVideo_11:
; case 3:
; vdp_init_multicolor();
       jsr       _vdp_init_multicolor
; break;
modeVideo_6:
; }
; clearScr();
       jsr       _clearScr
       bra.s     modeVideo_4
modeVideo_3:
; }
; else
; vMode = 0xFF;
       move.l    #255,D2
modeVideo_4:
       bra.s     modeVideo_2
modeVideo_1:
; }
; else
; vMode = 0xFF;
       move.l    #255,D2
modeVideo_2:
; if (vMode == 0xFF && vdp_mode == VDP_MODE_TEXT)
       cmp.l     #255,D2
       bne       modeVideo_12
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     modeVideo_12
; {
; printText("usage: mode [code]\r\n\0");
       pea       @monitor_30.L
       jsr       (A2)
       addq.w    #4,A7
; printText("   code: 0 = Text Mode 40x24\r\n\0");
       pea       @monitor_31.L
       jsr       (A2)
       addq.w    #4,A7
; printText("         1 = Graphic Text Mode 32x24\r\n\0");
       pea       @monitor_32.L
       jsr       (A2)
       addq.w    #4,A7
; printText("         2 = Graphic 256x192\r\n\0");
       pea       @monitor_33.L
       jsr       (A2)
       addq.w    #4,A7
; printText("         3 = Graphic 64x48\r\n\0");
       pea       @monitor_34.L
       jsr       (A2)
       addq.w    #4,A7
modeVideo_12:
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void asctohex(unsigned char a, unsigned char *s)
; {
       xdef      _asctohex
_asctohex:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.l    12(A6),D3
; unsigned char c;
; c = (a >> 4) & 0x0f;
       move.b    11(A6),D0
       lsr.b     #4,D0
       and.b     #15,D0
       move.b    D0,D2
; if (c <= 9) c+= '0'; else c += 'a' - 10;
       cmp.b     #9,D2
       bhi.s     asctohex_1
       add.b     #48,D2
       bra.s     asctohex_2
asctohex_1:
       add.b     #87,D2
asctohex_2:
; *s++ = c;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    D2,(A0)
; c = a & 0x0f;
       move.b    11(A6),D0
       and.b     #15,D0
       move.b    D0,D2
; if (c <= 9) c+= '0'; else c += 'a' - 10;
       cmp.b     #9,D2
       bhi.s     asctohex_3
       add.b     #48,D2
       bra.s     asctohex_4
asctohex_3:
       add.b     #87,D2
asctohex_4:
; *s++ = c;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    D2,(A0)
; *s = 0;
       move.l    D3,A0
       clr.b     (A0)
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; int hex2int(char ch)
; {
       xdef      _hex2int
_hex2int:
       link      A6,#0
       move.l    D2,-(A7)
       move.b    11(A6),D2
       ext.w     D2
       ext.l     D2
; if (ch >= '0' && ch <= '9')
       cmp.b     #48,D2
       blt.s     hex2int_1
       cmp.b     #57,D2
       bgt.s     hex2int_1
; return ch - '0';
       ext.w     D2
       ext.l     D2
       move.l    D2,D0
       sub.l     #48,D0
       bra       hex2int_3
hex2int_1:
; if (ch >= 'A' && ch <= 'F')
       cmp.b     #65,D2
       blt.s     hex2int_4
       cmp.b     #70,D2
       bgt.s     hex2int_4
; return ch - 'A' + 10;
       moveq     #-55,D0
       ext.w     D2
       ext.l     D2
       add.l     D2,D0
       bra.s     hex2int_3
hex2int_4:
; if (ch >= 'a' && ch <= 'f')
       cmp.b     #97,D2
       blt.s     hex2int_6
       cmp.b     #102,D2
       bgt.s     hex2int_6
; return ch - 'a' + 10;
       moveq     #-87,D0
       ext.w     D2
       ext.l     D2
       add.l     D2,D0
       bra.s     hex2int_3
hex2int_6:
; return -1;
       moveq     #-1,D0
hex2int_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned long pow(int val, int pot)
; {
       xdef      _pow
_pow:
       link      A6,#0
       movem.l   D2/D3/D4/D5,-(A7)
       move.l    8(A6),D2
       move.l    12(A6),D4
; int ix;
; int base = val;
       move.l    D2,D5
; if (val != 0)
       tst.l     D2
       beq       pow_9
; {
; if (pot == 0)
       tst.l     D4
       bne.s     pow_3
; val = 1;
       moveq     #1,D2
       bra       pow_9
pow_3:
; else if (pot == 1)
       cmp.l     #1,D4
       bne.s     pow_5
; val = base;
       move.l    D5,D2
       bra.s     pow_9
pow_5:
; else
; {
; for (ix = 0; ix <= pot; ix++)
       clr.l     D3
pow_7:
       cmp.l     D4,D3
       bgt.s     pow_9
; {
; if (ix >= 2)
       cmp.l     #2,D3
       blt.s     pow_10
; val *= base;
       move.l    D2,-(A7)
       move.l    D5,-(A7)
       jsr       LMUL
       move.l    (A7),D2
       addq.w    #8,A7
pow_10:
       addq.l    #1,D3
       bra       pow_7
pow_9:
; }
; }
; }
; return val;
       move.l    D2,D0
       movem.l   (A7)+,D2/D3/D4/D5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned long hexToLong(char *pHex)
; {
       xdef      _hexToLong
_hexToLong:
       link      A6,#0
       movem.l   D2/D3/D4,-(A7)
; int ix;
; unsigned char ilen = strlen(pHex) - 1;
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.b    D0,D4
; unsigned long pVal = 0;
       clr.l     D3
; for (ix = ilen; ix >= 0; ix--)
       and.l     #255,D4
       move.l    D4,D2
hexToLong_1:
       cmp.l     #0,D2
       blt       hexToLong_3
; {
; pVal += hex2int(pHex[ilen - ix]) * pow(16, ix);
       move.l    8(A6),A0
       move.b    D4,D1
       and.l     #255,D1
       sub.l     D2,D1
       move.b    0(A0,D1.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _hex2int
       addq.w    #4,A7
       move.l    D0,-(A7)
       move.l    D2,-(A7)
       pea       16
       jsr       _pow
       addq.w    #8,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,D3
       subq.l    #1,D2
       bra       hexToLong_1
hexToLong_3:
; }
; return pVal;
       move.l    D3,D0
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void pokeMem(unsigned char *pEnder, unsigned char *pByte)
; {
       xdef      _pokeMem
_pokeMem:
       link      A6,#-8
       move.l    D2,-(A7)
; unsigned char *vEnder = hexToLong(pEnder);
       move.l    8(A6),-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,-8(A6)
; unsigned long tByte = hexToLong(pByte);
       move.l    12(A6),-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,-4(A6)
; unsigned char vByte = 0;
       clr.b     D2
; if (pEnder[0] != 0x00 && pByte[0] != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq.s     pokeMem_1
       move.l    12(A6),A0
       move.b    (A0),D0
       beq.s     pokeMem_1
; {
; vByte = (unsigned char)tByte;
       move.l    -4(A6),D0
       move.b    D0,D2
; *vEnder = vByte;
       move.l    -8(A6),A0
       move.b    D2,(A0)
       bra.s     pokeMem_3
pokeMem_1:
; }
; else
; {
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     pokeMem_3
; printText("usage: poke <ender> <byte>\r\n\0");
       pea       @monitor_35.L
       jsr       _printText
       addq.w    #4,A7
pokeMem_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // dump <ender> [qtd (default 64)] [cols (default 8 (42cols) or 4 (32cols))]
; //-----------------------------------------------------------------------------
; void dumpMem (unsigned char *pEnder, unsigned char *pqtd, unsigned char *pCols)
; {
       xdef      _dumpMem
_dumpMem:
       link      A6,#-72
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _printText.L,A2
       lea       -60(A6),A3
       lea       -10(A6),A4
       lea       -44(A6),A5
; unsigned char ptype = 0x00;
       clr.b     -71(A6)
; unsigned char *pender = hexToLong(pEnder);
       move.l    8(A6),-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,-70(A6)
; unsigned long vqtd = 64, ix;
       moveq     #64,D7
; unsigned long vcols = 8;
       moveq     #8,D4
; int iy;
; unsigned char shex[4], vchr[2];
; unsigned char pbytes[16];
; char vbuffer [sizeof(long)*8+1];
; char buffer[10];
; int i=0;
       clr.l     D3
; int j=0;
       clr.l     D5
; if (pEnder[0] == 0)
       move.l    8(A6),A0
       move.b    (A0),D0
       bne.s     dumpMem_1
; {
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     dumpMem_3
; {
; printText("usage: dump <ender> [qtd] [cols]\r\n\0");
       pea       @monitor_36.L
       jsr       (A2)
       addq.w    #4,A7
; printText("    qtd: default 64\r\n\0");
       pea       @monitor_37.L
       jsr       (A2)
       addq.w    #4,A7
; printText("   cols: default 8\r\n\0");
       pea       @monitor_38.L
       jsr       (A2)
       addq.w    #4,A7
dumpMem_3:
; }
; return;
       bra       dumpMem_14
dumpMem_1:
; }
; if (vdpMaxCols == 32)
       move.b    _vdpMaxCols.L,D0
       cmp.b     #32,D0
       bne.s     dumpMem_6
; vcols = 4;
       moveq     #4,D4
dumpMem_6:
; if (pqtd[0] != 0x00)
       move.l    12(A6),A0
       move.b    (A0),D0
       beq.s     dumpMem_8
; vqtd = atol(pqtd);
       move.l    12(A6),-(A7)
       jsr       _atol
       addq.w    #4,A7
       move.l    D0,D7
dumpMem_8:
; if (pCols[0] != 0x00)
       move.l    16(A6),A0
       move.b    (A0),D0
       beq.s     dumpMem_10
; vcols = atol(pCols);
       move.l    16(A6),-(A7)
       jsr       _atol
       addq.w    #4,A7
       move.l    D0,D4
dumpMem_10:
; for (ix = 0; ix < vqtd; ix += vcols)
       clr.l     D6
dumpMem_12:
       cmp.l     D7,D6
       bhs       dumpMem_14
; {
; ltoa (pender,vbuffer,16);
       pea       16
       move.l    A5,-(A7)
       move.l    -70(A6),-(A7)
       jsr       _ltoa
       add.w     #12,A7
; for (i=0; i<(6-strlen(vbuffer));i++) {
       clr.l     D3
dumpMem_15:
       moveq     #6,D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-(A7)
       move.l    A5,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       sub.l     D1,D0
       cmp.l     D0,D3
       bge.s     dumpMem_17
; buffer[i]='0';
       move.b    #48,0(A4,D3.L)
       addq.l    #1,D3
       bra       dumpMem_15
dumpMem_17:
; }
; for(j=0;j<strlen(vbuffer);j++){
       clr.l     D5
dumpMem_18:
       move.l    A5,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     D0,D5
       bge.s     dumpMem_20
; buffer[i] = vbuffer[j];
       move.b    0(A5,D5.L),0(A4,D3.L)
; i++;
       addq.l    #1,D3
; buffer[i] = 0x00;
       clr.b     0(A4,D3.L)
       addq.l    #1,D5
       bra       dumpMem_18
dumpMem_20:
; }
; printText(buffer);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printChar(':', 1);
       pea       1
       pea       58
       jsr       _printChar
       addq.w    #8,A7
; for (iy = 0; iy < vcols; iy++)
       clr.l     D2
dumpMem_21:
       cmp.l     D4,D2
       bhs.s     dumpMem_23
; pbytes[iy] = *pender++;
       move.l    -70(A6),A0
       addq.l    #1,-70(A6)
       move.b    (A0),0(A3,D2.L)
       addq.l    #1,D2
       bra       dumpMem_21
dumpMem_23:
; for (iy = 0; iy < vcols; iy++)
       clr.l     D2
dumpMem_24:
       cmp.l     D4,D2
       bhs       dumpMem_26
; {
; asctohex(pbytes[iy], shex);
       pea       -66(A6)
       move.b    0(A3,D2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _asctohex
       addq.w    #8,A7
; printText(shex);
       pea       -66(A6)
       jsr       (A2)
       addq.w    #4,A7
; if ((vcols - iy) >= 2)
       move.l    D4,D0
       sub.l     D2,D0
       cmp.l     #2,D0
       blo.s     dumpMem_27
; printChar(' ', 1);
       pea       1
       pea       32
       jsr       _printChar
       addq.w    #8,A7
dumpMem_27:
       addq.l    #1,D2
       bra       dumpMem_24
dumpMem_26:
; }
; printText("|\0");
       pea       @monitor_39.L
       jsr       (A2)
       addq.w    #4,A7
; for (iy = 0; iy < vcols; iy++)
       clr.l     D2
dumpMem_29:
       cmp.l     D4,D2
       bhs.s     dumpMem_31
; {
; if (pbytes[iy] >= 0x20)
       move.b    0(A3,D2.L),D0
       cmp.b     #32,D0
       blo.s     dumpMem_32
; {
; vchr[0] = pbytes[iy];
       move.b    0(A3,D2.L),-62+0(A6)
; vchr[1] = 0x00;
       clr.b     -62+1(A6)
; printText(vchr);
       pea       -62(A6)
       jsr       (A2)
       addq.w    #4,A7
       bra.s     dumpMem_33
dumpMem_32:
; }
; else
; printChar('.', 1);
       pea       1
       pea       46
       jsr       _printChar
       addq.w    #8,A7
dumpMem_33:
       addq.l    #1,D2
       bra       dumpMem_29
dumpMem_31:
; }
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
       add.l     D4,D6
       bra       dumpMem_12
dumpMem_14:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // dumps <ender> [qtd (default 256)]
; // Joga direto pra serial
; //-----------------------------------------------------------------------------
; void dumpMem2 (unsigned char *pEnder, unsigned char *pqtd)
; {
       xdef      _dumpMem2
_dumpMem2:
       link      A6,#-68
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _writeLongSerial.L,A2
       lea       -60(A6),A3
       lea       -10(A6),A4
       lea       -44(A6),A5
; unsigned char ptype = 0x00;
       clr.b     -65(A6)
; unsigned char *pender = hexToLong(pEnder);;
       move.l    8(A6),-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,D5
; unsigned long vqtd = 256, ix;
       move.l    #256,D7
; int iy;
; unsigned char shex[4];
; unsigned char pbytes[16];
; char vbuffer [sizeof(long)*8+1];
; char buffer[10];
; int i=0;
       clr.l     D3
; int j=0;
       clr.l     D4
; if (pEnder[0] == 0)
       move.l    8(A6),A0
       move.b    (A0),D0
       bne.s     dumpMem2_1
; {
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     dumpMem2_3
; writeLongSerial("usage: dump <ender initial> [qtd (default 256)]\r\n\0");
       pea       @monitor_40.L
       jsr       (A2)
       addq.w    #4,A7
dumpMem2_3:
; return;
       bra       dumpMem2_10
dumpMem2_1:
; }
; if (pqtd[0] != 0x00)
       move.l    12(A6),A0
       move.b    (A0),D0
       beq.s     dumpMem2_6
; vqtd = atol(pqtd);
       move.l    12(A6),-(A7)
       jsr       _atol
       addq.w    #4,A7
       move.l    D0,D7
dumpMem2_6:
; for (ix = 0; ix < vqtd; ix += 16)
       clr.l     D6
dumpMem2_8:
       cmp.l     D7,D6
       bhs       dumpMem2_10
; {
; ltoa (pender,vbuffer,16);
       pea       16
       move.l    A5,-(A7)
       move.l    D5,-(A7)
       jsr       _ltoa
       add.w     #12,A7
; for (i=0; i<(6-strlen(vbuffer));i++) {
       clr.l     D3
dumpMem2_11:
       moveq     #6,D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-(A7)
       move.l    A5,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       sub.l     D1,D0
       cmp.l     D0,D3
       bge.s     dumpMem2_13
; buffer[i]='0';
       move.b    #48,0(A4,D3.L)
       addq.l    #1,D3
       bra       dumpMem2_11
dumpMem2_13:
; }
; for(j=0;j<strlen(vbuffer);j++){
       clr.l     D4
dumpMem2_14:
       move.l    A5,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     D0,D4
       bge.s     dumpMem2_16
; buffer[i] = vbuffer[j];
       move.b    0(A5,D4.L),0(A4,D3.L)
; i++;
       addq.l    #1,D3
; buffer[i] = 0x00;
       clr.b     0(A4,D3.L)
       addq.l    #1,D4
       bra       dumpMem2_14
dumpMem2_16:
; }
; writeLongSerial(buffer);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; writeLongSerial("h : ");
       pea       @monitor_41.L
       jsr       (A2)
       addq.w    #4,A7
; for (iy = 0; iy < 16; iy++)
       clr.l     D2
dumpMem2_17:
       cmp.l     #16,D2
       bge.s     dumpMem2_19
; {
; pbytes[iy] = *pender;
       move.l    D5,A0
       move.b    (A0),0(A3,D2.L)
; pender = pender + vdpAddCol;
       add.l     #256,D5
       addq.l    #1,D2
       bra       dumpMem2_17
dumpMem2_19:
; }
; for (iy = 0; iy < 16; iy++)
       clr.l     D2
dumpMem2_20:
       cmp.l     #16,D2
       bge.s     dumpMem2_22
; {
; asctohex(pbytes[iy], shex);
       pea       -64(A6)
       move.b    0(A3,D2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _asctohex
       addq.w    #8,A7
; writeLongSerial(shex);
       pea       -64(A6)
       jsr       (A2)
       addq.w    #4,A7
; writeSerial(' ');
       pea       32
       jsr       _writeSerial
       addq.w    #4,A7
       addq.l    #1,D2
       bra       dumpMem2_20
dumpMem2_22:
; }
; writeLongSerial(" | \0");
       pea       @monitor_42.L
       jsr       (A2)
       addq.w    #4,A7
; for (iy = 0; iy < 16; iy++)
       clr.l     D2
dumpMem2_23:
       cmp.l     #16,D2
       bge.s     dumpMem2_25
; {
; if (pbytes[iy] >= 0x20)
       move.b    0(A3,D2.L),D0
       cmp.b     #32,D0
       blo.s     dumpMem2_26
; writeSerial(pbytes[iy]);
       move.b    0(A3,D2.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _writeSerial
       addq.w    #4,A7
       bra.s     dumpMem2_27
dumpMem2_26:
; else
; writeSerial('.');
       pea       46
       jsr       _writeSerial
       addq.w    #4,A7
dumpMem2_27:
       addq.l    #1,D2
       bra       dumpMem2_23
dumpMem2_25:
; }
; writeLongSerial("\r\n\0");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
       add.l     #16,D6
       bra       dumpMem2_8
dumpMem2_10:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // dumpw <ender> [qtd (default 64)] [cols (default 8 (42cols) or 4 (32cols))]
; //-----------------------------------------------------------------------------
; void dumpMemWin (unsigned char *pEnder, unsigned char *pqtd, unsigned char *pCols)
; {
       xdef      _dumpMemWin
_dumpMemWin:
       link      A6,#-76
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _printChar.L,A2
       lea       _printText.L,A3
       lea       _vdp_set_cursor.L,A4
; unsigned char ptype = 0x00;
       clr.b     -75(A6)
; unsigned char *pender = hexToLong(pEnder);
       move.l    8(A6),-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,D4
; unsigned char *blin = vbuf;
       lea       _vbuf.L,A0
       move.l    A0,-74(A6)
; unsigned long vqtd = 128, ix;
       move.l    #128,-70(A6)
; unsigned long vcols = 8;
       moveq     #8,D7
; int iy;
; unsigned char shex[4], vchr[2];
; unsigned char pbytes[16];
; char vbuffer [sizeof(long)*8+1];
; char buffer[10];
; int i=0;
       clr.l     D6
; int j=0;
       move.w    #0,A5
; unsigned char vRetInput;
; if (pEnder[0] == 0)
       move.l    8(A6),A0
       move.b    (A0),D0
       bne.s     dumpMemWin_1
; {
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     dumpMemWin_3
; {
; printText("usage: dumpw <ender> [qtd] [cols]\r\n\0");
       pea       @monitor_43.L
       jsr       (A3)
       addq.w    #4,A7
; printText("    qtd: default 128\r\n\0");
       pea       @monitor_44.L
       jsr       (A3)
       addq.w    #4,A7
; printText("   cols: default 8\r\n\0");
       pea       @monitor_38.L
       jsr       (A3)
       addq.w    #4,A7
dumpMemWin_3:
; }
; return;
       bra       dumpMemWin_5
dumpMemWin_1:
; }
; if (vdpMaxCols == 32)
       move.b    _vdpMaxCols.L,D0
       cmp.b     #32,D0
       bne.s     dumpMemWin_6
; {
; if (vdp_mode == VDP_MODE_TEXT)
       move.b    _vdp_mode.L,D0
       cmp.b     #3,D0
       bne.s     dumpMemWin_8
; printText("dumpw Only Works in 40 cols\r\n\0");
       pea       @monitor_45.L
       jsr       (A3)
       addq.w    #4,A7
dumpMemWin_8:
; return;
       bra       dumpMemWin_5
dumpMemWin_6:
; }
; if (pqtd[0] != 0x00)
       move.l    12(A6),A0
       move.b    (A0),D0
       beq.s     dumpMemWin_10
; vqtd = atol(pqtd);
       move.l    12(A6),-(A7)
       jsr       _atol
       addq.w    #4,A7
       move.l    D0,-70(A6)
dumpMemWin_10:
; if (pCols[0] != 0x00)
       move.l    16(A6),A0
       move.b    (A0),D0
       beq.s     dumpMemWin_12
; vcols = atol(pCols);
       move.l    16(A6),-(A7)
       jsr       _atol
       addq.w    #4,A7
       move.l    D0,D7
dumpMemWin_12:
; clearScr();
       jsr       _clearScr
; printText("             DUMPW v0.1                \r\n\0");
       pea       @monitor_46.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(218,1);
       pea       1
       pea       218
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 5; ix++)
       clr.l     D2
dumpMemWin_14:
       cmp.l     #5,D2
       bhs.s     dumpMemWin_16
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_14
dumpMemWin_16:
; printChar(194,1);
       pea       1
       pea       194
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 23; ix++)
       clr.l     D2
dumpMemWin_17:
       cmp.l     #23,D2
       bhs.s     dumpMemWin_19
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_17
dumpMemWin_19:
; printChar(194,1);
       pea       1
       pea       194
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 7; ix++)
       clr.l     D2
dumpMemWin_20:
       cmp.l     #7,D2
       bhs.s     dumpMemWin_22
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_20
dumpMemWin_22:
; printChar(191,1);
       pea       1
       pea       191
       jsr       (A2)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A2)
       addq.w    #8,A7
; printText("Addr ");
       pea       @monitor_47.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A2)
       addq.w    #8,A7
; printText("         Bytes         ");
       pea       @monitor_48.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A2)
       addq.w    #8,A7
; printText(" ASCII ");
       pea       @monitor_49.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A2)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(192,1);
       pea       1
       pea       192
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 5; ix++)
       clr.l     D2
dumpMemWin_23:
       cmp.l     #5,D2
       bhs.s     dumpMemWin_25
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_23
dumpMemWin_25:
; printChar(193,1);
       pea       1
       pea       193
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 23; ix++)
       clr.l     D2
dumpMemWin_26:
       cmp.l     #23,D2
       bhs.s     dumpMemWin_28
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_26
dumpMemWin_28:
; printChar(193,1);
       pea       1
       pea       193
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 7; ix++)
       clr.l     D2
dumpMemWin_29:
       cmp.l     #7,D2
       bhs.s     dumpMemWin_31
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_29
dumpMemWin_31:
; printChar(217,1);
       pea       1
       pea       217
       jsr       (A2)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
; vdp_set_cursor(0, 20);
       pea       20
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #8,A7
; printChar(218,1);
       pea       1
       pea       218
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 37; ix++)
       clr.l     D2
dumpMemWin_32:
       cmp.l     #37,D2
       bhs.s     dumpMemWin_34
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_32
dumpMemWin_34:
; printChar(191,1);
       pea       1
       pea       191
       jsr       (A2)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A2)
       addq.w    #8,A7
; printText(" <-:Prev  ->:Next  <");
       pea       @monitor_50.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(217,1);
       pea       1
       pea       217
       jsr       (A2)
       addq.w    #8,A7
; printText(":Addr  ESC:Exit ");
       pea       @monitor_51.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A2)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(192,1);
       pea       1
       pea       192
       jsr       (A2)
       addq.w    #8,A7
; for (ix = 0; ix < 37; ix++)
       clr.l     D2
dumpMemWin_35:
       cmp.l     #37,D2
       bhs.s     dumpMemWin_37
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A2)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       dumpMemWin_35
dumpMemWin_37:
; printChar(217,1);
       pea       1
       pea       217
       jsr       (A2)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
; if (vdpMaxCols == 32)
       move.b    _vdpMaxCols.L,D0
       cmp.b     #32,D0
       bne.s     dumpMemWin_38
; vcols = 4;
       moveq     #4,D7
dumpMemWin_38:
; while (1)
dumpMemWin_40:
; {
; vdp_set_cursor(0, 4);
       pea       4
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #8,A7
; for (ix = 0; ix < vqtd; ix += vcols)
       clr.l     D2
dumpMemWin_43:
       cmp.l     -70(A6),D2
       bhs       dumpMemWin_45
; {
; ltoa (pender,vbuffer,16);
       pea       16
       pea       -44(A6)
       move.l    D4,-(A7)
       jsr       _ltoa
       add.w     #12,A7
; for (i=0; i<(6-strlen(vbuffer));i++) {
       clr.l     D6
dumpMemWin_46:
       moveq     #6,D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-(A7)
       pea       -44(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       sub.l     D1,D0
       cmp.l     D0,D6
       bge.s     dumpMemWin_48
; buffer[i]='0';
       move.b    #48,-10(A6,D6.L)
       addq.l    #1,D6
       bra       dumpMemWin_46
dumpMemWin_48:
; }
; for(j=0;j<strlen(vbuffer);j++){
       move.w    #0,A5
dumpMemWin_49:
       pea       -44(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    A5,D1
       cmp.l     D0,D1
       bge.s     dumpMemWin_51
; buffer[i] = vbuffer[j];
       move.b    -44(A6,A5.L),-10(A6,D6.L)
; i++;
       addq.l    #1,D6
; buffer[i] = 0x00;
       clr.b     -10(A6,D6.L)
       addq.w    #1,A5
       bra       dumpMemWin_49
dumpMemWin_51:
; }
; printText(buffer);
       pea       -10(A6)
       jsr       (A3)
       addq.w    #4,A7
; printChar(':', 1);
       pea       1
       pea       58
       jsr       (A2)
       addq.w    #8,A7
; for (iy = 0; iy < vcols; iy++)
       clr.l     D3
dumpMemWin_52:
       cmp.l     D7,D3
       bhs.s     dumpMemWin_54
; pbytes[iy] = *pender++;
       move.l    D4,A0
       addq.l    #1,D4
       move.b    (A0),-60(A6,D3.L)
       addq.l    #1,D3
       bra       dumpMemWin_52
dumpMemWin_54:
; for (iy = 0; iy < vcols; iy++)
       clr.l     D3
dumpMemWin_55:
       cmp.l     D7,D3
       bhs       dumpMemWin_57
; {
; asctohex(pbytes[iy], shex);
       pea       -66(A6)
       move.b    -60(A6,D3.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _asctohex
       addq.w    #8,A7
; printText(shex);
       pea       -66(A6)
       jsr       (A3)
       addq.w    #4,A7
; if ((vcols - iy) >= 2)
       move.l    D7,D0
       sub.l     D3,D0
       cmp.l     #2,D0
       blo.s     dumpMemWin_58
; printChar(' ', 1);
       pea       1
       pea       32
       jsr       (A2)
       addq.w    #8,A7
dumpMemWin_58:
       addq.l    #1,D3
       bra       dumpMemWin_55
dumpMemWin_57:
; }
; printText("|\0");
       pea       @monitor_39.L
       jsr       (A3)
       addq.w    #4,A7
; for (iy = 0; iy < vcols; iy++)
       clr.l     D3
dumpMemWin_60:
       cmp.l     D7,D3
       bhs.s     dumpMemWin_62
; {
; if (pbytes[iy] >= 0x20)
       move.b    -60(A6,D3.L),D0
       cmp.b     #32,D0
       blo.s     dumpMemWin_63
; {
; vchr[0] = pbytes[iy];
       move.b    -60(A6,D3.L),-62+0(A6)
; vchr[1] = 0x00;
       clr.b     -62+1(A6)
; printText(vchr);
       pea       -62(A6)
       jsr       (A3)
       addq.w    #4,A7
       bra.s     dumpMemWin_64
dumpMemWin_63:
; }
; else
; printChar('.', 1);
       pea       1
       pea       46
       jsr       (A2)
       addq.w    #8,A7
dumpMemWin_64:
       addq.l    #1,D3
       bra       dumpMemWin_60
dumpMemWin_62:
; }
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       (A3)
       addq.w    #4,A7
       add.l     D7,D2
       bra       dumpMemWin_43
dumpMemWin_45:
; }
; while (1)
dumpMemWin_65:
; {
; vRetInput = inputLine(1,'@');
       pea       64
       pea       1
       jsr       _inputLine
       addq.w    #8,A7
       move.b    D0,D5
; if (vRetInput == 0x12)  // LeftArrow (18)
       cmp.b     #18,D5
       bne.s     dumpMemWin_68
; {
; pender = pender - 256;
       sub.l     #256,D4
; if (pender > 0x00FFFFFF)
       cmp.l     #16777215,D4
       bls.s     dumpMemWin_70
; pender = 0x00FFFF00;
       move.l    #16776960,D4
dumpMemWin_70:
; break;
       bra       dumpMemWin_67
dumpMemWin_68:
; }
; else if (vRetInput == 0x14)  // RightArrow (20)
       cmp.b     #20,D5
       bne.s     dumpMemWin_72
; {
; if (pender > 0x00FFFFFF)
       cmp.l     #16777215,D4
       bls.s     dumpMemWin_74
; pender = 0x00000000;
       clr.l     D4
dumpMemWin_74:
; break;
       bra       dumpMemWin_67
dumpMemWin_72:
; }
; else if (vRetInput == 0x0D)  // Enter (13)
       cmp.b     #13,D5
       bne       dumpMemWin_76
; {
; vdp_set_cursor(1, 21);
       pea       21
       pea       1
       jsr       (A4)
       addq.w    #8,A7
; printText(" Address(HEX):                       \0");
       pea       @monitor_52.L
       jsr       (A3)
       addq.w    #4,A7
; vdp_set_cursor(16, 21);
       pea       21
       pea       16
       jsr       (A4)
       addq.w    #8,A7
; vRetInput = inputLine(6,'$');
       pea       36
       pea       6
       jsr       _inputLine
       addq.w    #8,A7
       move.b    D0,D5
; vdp_set_cursor(1, 21);
       pea       21
       pea       1
       jsr       (A4)
       addq.w    #8,A7
; printText(" <-:Prev  ->:Next  <");
       pea       @monitor_50.L
       jsr       (A3)
       addq.w    #4,A7
; printChar(217,1);
       pea       1
       pea       217
       jsr       (A2)
       addq.w    #8,A7
; printText(":Addr  ESC:Exit ");
       pea       @monitor_51.L
       jsr       (A3)
       addq.w    #4,A7
; if (vRetInput != 0x1B)
       cmp.b     #27,D5
       beq.s     dumpMemWin_78
; {
; blin = vbuf;
       lea       _vbuf.L,A0
       move.l    A0,-74(A6)
; pender = hexToLong(blin);
       move.l    -74(A6),-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,D4
; if (pender > 0x00FFFF00)
       cmp.l     #16776960,D4
       bls.s     dumpMemWin_80
; pender = 0x00FFFF00;
       move.l    #16776960,D4
dumpMemWin_80:
; break;
       bra.s     dumpMemWin_67
dumpMemWin_78:
       bra.s     dumpMemWin_82
dumpMemWin_76:
; }
; }
; else if (vRetInput == 0x1B)  // ESC
       cmp.b     #27,D5
       bne.s     dumpMemWin_82
; {
; break;
       bra.s     dumpMemWin_67
dumpMemWin_82:
       bra       dumpMemWin_65
dumpMemWin_67:
; }
; }
; if (vRetInput == 0x1B)  // ESC
       cmp.b     #27,D5
       bne.s     dumpMemWin_84
; {
; break;
       bra.s     dumpMemWin_42
dumpMemWin_84:
       bra       dumpMemWin_40
dumpMemWin_42:
; }
; }
; clearScr();
       jsr       _clearScr
dumpMemWin_5:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void writeSerial(unsigned char pchr)
; {
       xdef      _writeSerial
_writeSerial:
       link      A6,#0
; while(!(*(vmfp + Reg_TSR) & 0x80));  // Aguarda buffer de transmissao estar vazio
writeSerial_1:
       move.l    _vmfp.L,A0
       move.w    _Reg_TSR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       and.w     #128,D0
       bne.s     writeSerial_3
       bra       writeSerial_1
writeSerial_3:
; *(vmfp + Reg_UDR) = pchr;
       move.l    _vmfp.L,A0
       move.w    _Reg_UDR.L,D0
       and.l     #65535,D0
       move.b    11(A6),0(A0,D0.L)
; vBufXmitEmpty = 0;     // Indica que o buffer de transmissao esta cheio
       clr.b     _vBufXmitEmpty.L
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void writeLongSerial(unsigned char *msg)
; {
       xdef      _writeLongSerial
_writeLongSerial:
       link      A6,#0
; while (*msg)
writeLongSerial_1:
       move.l    8(A6),A0
       tst.b     (A0)
       beq.s     writeLongSerial_3
; {
; writeSerial(*msg++);
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _writeSerial
       addq.w    #4,A7
       bra       writeLongSerial_1
writeLongSerial_3:
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; unsigned long lstmGetSize(void)
; {
       xdef      _lstmGetSize
_lstmGetSize:
; return vSizeTotalRec;
       move.l    _vSizeTotalRec.L,D0
       rts
; }
; //-----------------------------------------------------------------------------
; // load <ender initial to save>
; //-----------------------------------------------------------------------------
; //         Uses XMODEM Protocol
; //-----------------------------------------------------------------------------
; // ptipo : 1 = mostra mensagens 0 = nao mostra e apenas retorna os erros ou 0x00 carregado com sucesso
; //-----------------------------------------------------------------------------
; unsigned char loadSerialToMem(unsigned char *pEndStart, unsigned char ptipo)
; {
       xdef      _loadSerialToMem
_loadSerialToMem:
       link      A6,#-48
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _printText.L,A2
       move.l    8(A6),D4
       lea       _vdp_write.L,A3
       lea       _vSizeTotalRec.L,A4
; unsigned long vTamanho;
; unsigned char vHeader[3];
; unsigned int vchecksum = 0;
       clr.l     -38(A6)
; unsigned char inputBuffer, verro = 0;
       moveq     #0,D7
; unsigned char *vEndSave = 0x00000000;
       clr.l     D6
; unsigned char *vEndOld  = 0x00000000;
       clr.l     -34(A6)
; unsigned char *pEnder  = pEndStart;
       move.l    D4,A5
; unsigned long vTimeout = 0, vchecksumcalc = 0;
       clr.l     D5
       clr.l     -30(A6)
; unsigned char sqtdtam[20];
; unsigned char vinicio = 0x00;
       clr.b     D2
; unsigned char vStart = 0x00;
       clr.b     -6(A6)
; unsigned char vBlockOld = 0x00;
       clr.b     -5(A6)
; unsigned int vAnim = 1000;
       move.l    #1000,-4(A6)
; if (ptipo)
       tst.b     15(A6)
       beq.s     loadSerialToMem_1
; printText("Receiving. <Esc> to Cancel... \r\n\0");
       pea       @monitor_53.L
       jsr       (A2)
       addq.w    #4,A7
loadSerialToMem_1:
; // Desabilita Timers and Mouse Interruption
; //    *(vmfp + Reg_IERA) &= 0x5E;
; vSizeTotalRec = 0;
       clr.l     (A4)
; kbdKeyBuffer[kbdKeyPtrR] = 0x00;
       move.b    _kbdKeyPtrR.L,D0
       and.l     #255,D0
       lea       _kbdKeyBuffer.L,A0
       clr.b     0(A0,D0.L)
; if (pEnder == 0)
       move.l    A5,D0
       bne.s     loadSerialToMem_3
; pEndStart = malloc(1024);
       pea       1024
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,D4
loadSerialToMem_3:
; printText("Address loading: 0x");
       pea       @monitor_54.L
       jsr       (A2)
       addq.w    #4,A7
; itoa(pEndStart, sqtdtam, 16);
       pea       16
       pea       -26(A6)
       move.l    D4,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sqtdtam);
       pea       -26(A6)
       jsr       (A2)
       addq.w    #4,A7
; printText(" \0");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
; vEndSave = pEndStart;
       move.l    D4,D6
; vEndOld = pEndStart;
       move.l    D4,-34(A6)
; while(1)
loadSerialToMem_5:
; {
; inputBuffer = 0;
       clr.b     D3
; vTimeout = 0;
       clr.l     D5
; if (ptipo)
       tst.b     15(A6)
       beq       loadSerialToMem_8
; {
; switch (vAnim)
       move.l    -4(A6),D0
       cmp.l     #2400,D0
       beq       loadSerialToMem_14
       bhi.s     loadSerialToMem_16
       cmp.l     #1600,D0
       beq.s     loadSerialToMem_13
       bhi       loadSerialToMem_11
       cmp.l     #800,D0
       beq.s     loadSerialToMem_12
       bra       loadSerialToMem_11
loadSerialToMem_16:
       cmp.l     #3200,D0
       beq.s     loadSerialToMem_15
       bra       loadSerialToMem_11
loadSerialToMem_12:
; {
; case 800:
; vdp_write(0x2F);    // Show "/"
       pea       47
       jsr       (A3)
       addq.w    #4,A7
; break;
       bra.s     loadSerialToMem_11
loadSerialToMem_13:
; case 1600:
; vdp_write(0x2D);    // Show "-"
       pea       45
       jsr       (A3)
       addq.w    #4,A7
; break;
       bra.s     loadSerialToMem_11
loadSerialToMem_14:
; case 2400:
; vdp_write(0x5C);    // Show "\"
       pea       92
       jsr       (A3)
       addq.w    #4,A7
; break;
       bra.s     loadSerialToMem_11
loadSerialToMem_15:
; case 3200:
; vdp_write(0x7C);    // Show "|"
       pea       124
       jsr       (A3)
       addq.w    #4,A7
; vAnim = 0;
       clr.l     -4(A6)
; break;
loadSerialToMem_11:
; }
; vAnim++;
       addq.l    #1,-4(A6)
loadSerialToMem_8:
; }
; while(!(*(vmfp + Reg_RSR) & 0x80))
loadSerialToMem_17:
       move.l    _vmfp.L,A0
       move.w    _Reg_RSR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       and.w     #128,D0
       bne       loadSerialToMem_19
; {
; if (kbdKeyBuffer[kbdKeyPtrR] == 0x1B)  // ESC
       move.b    _kbdKeyPtrR.L,D0
       and.l     #255,D0
       lea       _kbdKeyBuffer.L,A0
       move.b    0(A0,D0.L),D0
       cmp.b     #27,D0
       bne.s     loadSerialToMem_20
; break;
       bra       loadSerialToMem_19
loadSerialToMem_20:
; if(vinicio == 0x00 && vStart == 0x00)
       tst.b     D2
       bne.s     loadSerialToMem_24
       move.b    -6(A6),D0
       bne.s     loadSerialToMem_24
; {
; if ((vTimeout % 100000) == 0) // +/- 10s
       move.l    D5,-(A7)
       pea       100000
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     loadSerialToMem_24
; {
; //*(vmfp + Reg_GPDR) = 0x01;
; writeSerial(0x15);    // Send NACK to start
       pea       21
       jsr       _writeSerial
       addq.w    #4,A7
loadSerialToMem_24:
; }
; /*else
; {
; *(vmfp + Reg_GPDR) = 0x01;
; }*/
; }
; vTimeout++;
       addq.l    #1,D5
; if (vTimeout > 3000000) // +/- 5 min
       cmp.l     #3000000,D5
       bls.s     loadSerialToMem_26
; break;
       bra.s     loadSerialToMem_19
loadSerialToMem_26:
       bra       loadSerialToMem_17
loadSerialToMem_19:
; };
; if (kbdKeyBuffer[kbdKeyPtrR] == 0x1B)  // ESC
       move.b    _kbdKeyPtrR.L,D0
       and.l     #255,D0
       lea       _kbdKeyBuffer.L,A0
       move.b    0(A0,D0.L),D0
       cmp.b     #27,D0
       bne.s     loadSerialToMem_28
; {
; verro = 99;
       moveq     #99,D7
; break;
       bra       loadSerialToMem_7
loadSerialToMem_28:
; }
; if (vTimeout > 3000000)
       cmp.l     #3000000,D5
       bls.s     loadSerialToMem_30
; break;
       bra       loadSerialToMem_7
loadSerialToMem_30:
; inputBuffer = *(vmfp + Reg_UDR);
       move.l    _vmfp.L,A0
       move.w    _Reg_UDR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D3
; if (vinicio == 0 && inputBuffer == 0x04)    // Primeiro byte eh EOT
       tst.b     D2
       bne.s     loadSerialToMem_32
       cmp.b     #4,D3
       bne.s     loadSerialToMem_32
; {
; writeSerial(0x06);    // Send ACK
       pea       6
       jsr       _writeSerial
       addq.w    #4,A7
; break;
       bra       loadSerialToMem_7
loadSerialToMem_32:
; }
; else if (vinicio < 3)
       cmp.b     #3,D2
       bhs.s     loadSerialToMem_34
; {
; //*(vmfp + Reg_GPDR) = 0x04;
; vHeader[vinicio] = inputBuffer;
       and.l     #255,D2
       move.b    D3,-42(A6,D2.L)
; if (vinicio == 1)
       cmp.b     #1,D2
       bne.s     loadSerialToMem_39
; {
; if (vBlockOld == inputBuffer)
       cmp.b     -5(A6),D3
       bne.s     loadSerialToMem_38
; vEndSave = vEndOld;
       move.l    -34(A6),D6
       bra.s     loadSerialToMem_39
loadSerialToMem_38:
; else
; {
; vEndOld = vEndSave;
       move.l    D6,-34(A6)
; vBlockOld = inputBuffer;
       move.b    D3,-5(A6)
loadSerialToMem_39:
; }
; }
; vinicio++;
       addq.b    #1,D2
; vchecksumcalc = 0;
       clr.l     -30(A6)
; verro = 0;
       moveq     #0,D7
; vStart = 0x01;
       move.b    #1,-6(A6)
       bra       loadSerialToMem_46
loadSerialToMem_34:
; }
; else if (vinicio == 131)
       and.w     #255,D2
       cmp.w     #131,D2
       bne       loadSerialToMem_40
; {
; //*(vmfp + Reg_GPDR) = 0x05;
; vinicio = 0;
       clr.b     D2
; vchecksum = inputBuffer;
       and.l     #255,D3
       move.l    D3,-38(A6)
; if ((vchecksumcalc % 256) != vchecksum)
       move.l    -30(A6),-(A7)
       pea       256
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       cmp.l     -38(A6),D0
       beq.s     loadSerialToMem_42
; {
; //*(vmfp + Reg_GPDR) = 0x00;
; verro = 1;
       moveq     #1,D7
; vEndSave = vEndOld;
       move.l    -34(A6),D6
; writeSerial(0x15);    // Send NACK
       pea       21
       jsr       _writeSerial
       addq.w    #4,A7
       bra.s     loadSerialToMem_43
loadSerialToMem_42:
; }
; else
; {
; //*(vmfp + Reg_GPDR) = 0x01;
; writeSerial(0x06);    // Send ACK
       pea       6
       jsr       _writeSerial
       addq.w    #4,A7
loadSerialToMem_43:
       bra       loadSerialToMem_46
loadSerialToMem_40:
; }
; }
; else
; {
; *vEndSave++ = inputBuffer;
       move.l    D6,A0
       addq.l    #1,D6
       move.b    D3,(A0)
; vchecksumcalc += inputBuffer;
       and.l     #255,D3
       add.l     D3,-30(A6)
; vinicio++;
       addq.b    #1,D2
; vSizeTotalRec = vSizeTotalRec + 1;
       addq.l    #1,(A4)
; if (pEnder == 0)
       move.l    A5,D0
       bne.s     loadSerialToMem_46
; {
; if (vSizeTotalRec >= vSizeTotalRec + 1024)
       move.l    (A4),D0
       add.l     #1024,D0
       cmp.l     (A4),D0
       bhi.s     loadSerialToMem_46
; realloc(pEndStart, (vSizeTotalRec + 1024));
       move.l    (A4),D1
       add.l     #1024,D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       jsr       _realloc
       addq.w    #8,A7
loadSerialToMem_46:
       bra       loadSerialToMem_5
loadSerialToMem_7:
; }
; }
; }
; vdp_write(' ');
       pea       32
       jsr       (A3)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; // Habilita Timers Interruption
; //    *(vmfp + Reg_IERA) |= 0x61;
; if (vTimeout > 3000000)
       cmp.l     #3000000,D5
       bls.s     loadSerialToMem_48
; {
; if (pEnder == 0)
       move.l    A5,D0
       bne.s     loadSerialToMem_50
; free(pEndStart);
       move.l    D4,-(A7)
       jsr       _free
       addq.w    #4,A7
loadSerialToMem_50:
; if (ptipo)
       tst.b     15(A6)
       beq.s     loadSerialToMem_52
; printText("Timeout. Process Aborted.\r\n\0");
       pea       @monitor_56.L
       jsr       (A2)
       addq.w    #4,A7
loadSerialToMem_52:
; return 0xFE;
       move.b    #254,D0
       bra       loadSerialToMem_54
loadSerialToMem_48:
; }
; else
; {
; if (!verro)
       tst.b     D7
       bne       loadSerialToMem_55
; {
; if (ptipo)
       tst.b     15(A6)
       beq       loadSerialToMem_57
; {
; printText("File loaded in to memory successfuly.\r\n\0");
       pea       @monitor_57.L
       jsr       (A2)
       addq.w    #4,A7
; printText("Address loaded: 0x");
       pea       @monitor_58.L
       jsr       (A2)
       addq.w    #4,A7
; itoa(pEndStart, sqtdtam, 16);
       pea       16
       pea       -26(A6)
       move.l    D4,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sqtdtam);
       pea       -26(A6)
       jsr       (A2)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
loadSerialToMem_57:
; }
; return 0x00;
       clr.b     D0
       bra       loadSerialToMem_54
loadSerialToMem_55:
; }
; else
; {
; if (pEnder == 0)
       move.l    A5,D0
       bne.s     loadSerialToMem_59
; free(pEndStart);
       move.l    D4,-(A7)
       jsr       _free
       addq.w    #4,A7
loadSerialToMem_59:
; if (ptipo)
       tst.b     15(A6)
       beq.s     loadSerialToMem_64
; {
; if (verro == 99)
       cmp.b     #99,D7
       bne.s     loadSerialToMem_63
; printText("Loading aborted.\r\n\0");
       pea       @monitor_59.L
       jsr       (A2)
       addq.w    #4,A7
       bra.s     loadSerialToMem_64
loadSerialToMem_63:
; else
; printText("File loaded in to memory with checksum errors.\r\n\0");
       pea       @monitor_60.L
       jsr       (A2)
       addq.w    #4,A7
loadSerialToMem_64:
; }
; return 0xFD;
       move.b    #253,D0
loadSerialToMem_54:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; return 0xF0;
; }
; //-----------------------------------------------------------------------------
; void runMem(unsigned long pEnder)
; {
       xdef      _runMem
_runMem:
       link      A6,#0
; runMemory = pEnder;
       move.l    8(A6),_runMemory.L
; runCmd();
       jsr       _runCmd
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void runBasic(unsigned long pEnder)
; {
       xdef      _runBasic
_runBasic:
       link      A6,#0
; runBas();
       jsr       _runBas
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void runSystemOper(void)
; {
       xdef      _runSystemOper
_runSystemOper:
; runSO();
       jsr       _runSO
       rts
; }
; //-----------------------------------------------------------------------------
; int fsSendByte(unsigned char vByte, unsigned char pType)
; {
       xdef      _fsSendByte
_fsSendByte:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.b    11(A6),D2
       and.l     #255,D2
       move.b    15(A6),D3
       and.l     #255,D3
; if (pType == 0)
       tst.b     D3
       bne.s     fsSendByte_1
; *vdskc = vByte;
       move.l    _vdskc.L,A0
       move.b    D2,(A0)
       bra.s     fsSendByte_5
fsSendByte_1:
; else if (pType == 1)
       cmp.b     #1,D3
       bne.s     fsSendByte_3
; *vdskd = vByte;
       move.l    _vdskd.L,A0
       move.b    D2,(A0)
       bra.s     fsSendByte_5
fsSendByte_3:
; else if (pType == 2)
       cmp.b     #2,D3
       bne.s     fsSendByte_5
; *vdskp = vByte;
       move.l    _vdskp.L,A0
       move.b    D2,(A0)
fsSendByte_5:
; return 1;
       moveq     #1,D0
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned char fsRecByte(unsigned char pType)
; {
       xdef      _fsRecByte
_fsRecByte:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned char vByte;
; if (pType == 0)
       move.b    11(A6),D0
       bne.s     fsRecByte_1
; vByte = *vdskc;
       move.l    _vdskc.L,A0
       move.b    (A0),D2
       bra.s     fsRecByte_3
fsRecByte_1:
; else if (pType == 1)
       move.b    11(A6),D0
       cmp.b     #1,D0
       bne.s     fsRecByte_3
; vByte = *vdskd;
       move.l    _vdskd.L,A0
       move.b    (A0),D2
fsRecByte_3:
; return vByte;
       move.b    D2,D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned int carregaSO(void)
; {
       xdef      _carregaSO
_carregaSO:
       link      A6,#-156
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _fsRecByte.L,A2
       lea       _videoCursorPosColX.L,A3
       lea       _printText.L,A4
       lea       _fsSendByte.L,A5
; unsigned char *xaddress = 0x00800000;
       move.l    #8388608,-154(A6)
; unsigned char vbyteprog[128], vbytes[4], dd, vByte = 0;
       clr.b     D2
; unsigned int ix, cc;
; unsigned int vSizeFile;
; unsigned char sqtdtam[11];
; unsigned char vPosAnim = 0, vStep;
       clr.b     D5
; unsigned short vAntX = 0;
       clr.w     D3
; // Envia comando resetar e abortar tudo
; fsSendByte('a', FS_CMD);
       clr.l     -(A7)
       pea       97
       jsr       (A5)
       addq.w    #8,A7
; // Comando recebido ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     carregaSO_1
; return vByte;
       and.l     #255,D2
       move.l    D2,D0
       bra       carregaSO_3
carregaSO_1:
; // Envia comando
; fsSendByte('s', FS_CMD);
       clr.l     -(A7)
       pea       115
       jsr       (A5)
       addq.w    #8,A7
; // Comando recebido ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     carregaSO_4
; return vByte;
       and.l     #255,D2
       move.l    D2,D0
       bra       carregaSO_3
carregaSO_4:
; // Comando Executado ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     carregaSO_6
; return vByte;
       and.l     #255,D2
       move.l    D2,D0
       bra       carregaSO_3
carregaSO_6:
; printText(" ");
       pea       @monitor_55.L
       jsr       (A4)
       addq.w    #4,A7
; /*--------------*/
; vAntX = videoCursorPosColX;
       move.w    (A3),D3
; vStep = 0;
       moveq     #0,D7
; /*--------------*/
; while (1)
carregaSO_8:
; {
; // Verifica o tamanho recebido
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; vSizeFile = vByte << 8;
       and.l     #255,D2
       move.l    D2,D0
       lsl.l     #8,D0
       move.l    D0,D4
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; vSizeFile |= vByte;
       and.l     #255,D2
       or.l      D2,D4
; /*--------------*/
; vStep++;
       addq.b    #1,D7
; if (vStep % 13 == 0)
       move.b    D7,D0
       and.l     #65535,D0
       divu.w    #13,D0
       swap      D0
       tst.b     D0
       bne.s     carregaSO_14
; {
; if (vPosAnim == 3) 
       cmp.b     #3,D5
       bne.s     carregaSO_13
; {
; vPosAnim = 0;
       clr.b     D5
; videoCursorPosColX = vAntX;
       move.w    D3,(A3)
; printText("   ");
       pea       @monitor_61.L
       jsr       (A4)
       addq.w    #4,A7
; videoCursorPosColX = vAntX;
       move.w    D3,(A3)
       bra.s     carregaSO_14
carregaSO_13:
; }
; else
; {
; printChar('<',1);
       pea       1
       pea       60
       jsr       _printChar
       addq.w    #8,A7
; vPosAnim++;
       addq.b    #1,D5
carregaSO_14:
; }
; }
; /*--------------*/
; // Carrega Dados Recebidos
; for (cc = 0; cc < vSizeFile ; cc++)
       clr.l     D6
carregaSO_15:
       cmp.l     D4,D6
       bhs.s     carregaSO_17
; {
; vByte = fsRecByte(FS_DATA);
       pea       1
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; *xaddress = vByte;
       move.l    -154(A6),A0
       move.b    D2,(A0)
; xaddress += 1;
       addq.l    #1,-154(A6)
       addq.l    #1,D6
       bra       carregaSO_15
carregaSO_17:
; }
; if (vSizeFile < 512)
       cmp.l     #512,D4
       bhs.s     carregaSO_18
; break;
       bra       carregaSO_10
carregaSO_18:
; fsSendByte('t', FS_CMD);    // Continua Enviado o SO
       clr.l     -(A7)
       pea       116
       jsr       (A5)
       addq.w    #8,A7
; // Comando recebido ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     carregaSO_20
; return vByte;
       and.l     #255,D2
       move.l    D2,D0
       bra       carregaSO_3
carregaSO_20:
; // Comando Executado ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     carregaSO_22
; return vByte;
       and.l     #255,D2
       move.l    D2,D0
       bra.s     carregaSO_3
carregaSO_22:
       bra       carregaSO_8
carregaSO_10:
; }
; videoCursorPosColX = vAntX;
       move.w    D3,(A3)
; printText("Done!");
       pea       @monitor_62.L
       jsr       (A4)
       addq.w    #4,A7
; //    printChar(' ',0);
; printText("\r\n\0");
       pea       @monitor_2.L
       jsr       (A4)
       addq.w    #4,A7
; return 0;
       clr.l     D0
carregaSO_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void carregaOSDisk(void)
; {
       xdef      _carregaOSDisk
_carregaOSDisk:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       _printText.L,A2
; unsigned int verro;
; printText("Loading OS. Please Wait...\0");
       pea       @monitor_63.L
       jsr       (A2)
       addq.w    #4,A7
; verro = carregaSO();
       jsr       _carregaSO
       move.l    D0,-4(A6)
; if (verro)
       tst.l     -4(A6)
       beq.s     carregaOSDisk_1
; printText("IO Error....\r\n\0");
       pea       @monitor_64.L
       jsr       (A2)
       addq.w    #4,A7
       bra.s     carregaOSDisk_2
carregaOSDisk_1:
; else {
; printText("Ok\r\n\0");
       pea       @monitor_65.L
       jsr       (A2)
       addq.w    #4,A7
carregaOSDisk_2:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // Delay Function
; //-----------------------------------------------------------------------------
; void delayms(int pTimeMS)
; {
       xdef      _delayms
_delayms:
       link      A6,#-4
       move.l    D2,-(A7)
; unsigned int ix;
; unsigned int iTempo = (100 * pTimeMS);
       move.l    8(A6),-(A7)
       pea       100
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-4(A6)
; for(ix = 0; ix <= iTempo; ix++);    // +/- 1ms * pTimeMs parada
       clr.l     D2
delayms_1:
       cmp.l     -4(A6),D2
       bhi.s     delayms_3
       addq.l    #1,D2
       bra       delayms_1
delayms_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void delayus(int pTimeUS)
; {
       xdef      _delayus
_delayus:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned int ix;
; pTimeUS /= 4;
       move.l    8(A6),D0
       asr.l     #2,D0
       move.l    D0,8(A6)
; for(ix = 0; ix <= pTimeUS; ix++);    // +/- 1us * pTimeMs parada
       clr.l     D2
delayus_1:
       cmp.l     8(A6),D2
       bhi.s     delayus_3
       addq.l    #1,D2
       bra       delayus_1
delayus_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; #ifdef __KEYPS2__
; //-----------------------------------------------------------------------------
; // KBD PS2 Functions
; //-----------------------------------------------------------------------------
; void processCode(void)
; {
; unsigned char decoded;
; if ((scanCode /*| 0x10*/ ) == 0xF0)
; {
; // release code!
; *kbdvreleased = 0x01;
; }
; else if ((scanCode /*| 0x10*/ ) == 0xE0)
; {
; // apenas prepara para o proximo codigo
; *kbdve0 = 0x01;
; }
; else if ((scanCode /*| 0x10*/ ) == 0xE1)
; {
; // apenas prepara para o proximo codigo
; }
; else
; {
; // normal character received
; if (!*kbdvcaps && !*kbdvshift)
; decoded = convertCode(scanCode,keyCode,ascii);
; else if (!*kbdvcaps && *kbdvshift)
; decoded = convertCode(scanCode,keyCode,ascii2);
; else if (*kbdvcaps && !*kbdvshift)
; decoded = convertCode(scanCode,keyCode,ascii3);
; else if (*kbdvcaps && *kbdvshift)
; decoded = convertCode(scanCode,keyCode,ascii4);
; if (decoded != '\0')
; {
; // allowed key code character received
; if (!*kbdvreleased)
; {
; kbdKeyBuffer[kbdKeyPtrW] = decoded;
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; }
; else
; {
; // other character received
; switch (scanCode)
; {
; case 0x12:  // Shift
; case 0x59:
; *kbdvshift = ~*kbdvreleased & 0x01;
; break;
; case 0x14:  // Ctrl
; *kbdvctrl = ~*kbdvreleased & 0x01;
; break;
; case 0x11:  // Alt
; *kbdvalt = ~*kbdvreleased & 0x01;
; break;
; case 0x58:  // Caps Lock
; if (!*kbdvreleased)
; {
; *kbdvcaps = ~*kbdvcaps & 0x01;
; }
; break;
; case 0x77:  // Num Lock
; if (!*kbdvreleased)
; {
; *kbdvnum = ~*kbdvnum & 0x01;
; }
; break;
; case 0x7E:  // Scroll Lock
; if (!*kbdvreleased)
; {
; *kbdvscr = ~*kbdvscr & 0x01;
; }
; break;
; case 0x66:  // backspace
; if (!*kbdvreleased)
; {
; kbdKeyBuffer[kbdKeyPtrW] = 0x08;
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; case 0x5A:  // enter
; if (!*kbdvreleased)
; {
; kbdKeyBuffer[kbdKeyPtrW] = 0x0D;
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; case 0x76:  // ESCAPE
; if (!*kbdvreleased)
; {
; kbdKeyBuffer[kbdKeyPtrW] = 0x1B;
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; case 0x0D:  // TAB
; if (!*kbdvreleased)
; {
; kbdKeyBuffer[kbdKeyPtrW] = 0x09;
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; case 0x75: // up arrow
; if (!*kbdvreleased)
; {
; if (*kbdve0)
; kbdKeyBuffer[kbdKeyPtrW] = 0x11; // 17
; else
; kbdKeyBuffer[kbdKeyPtrW] = '8';
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; case 0x6B: // left arrow
; if (!*kbdvreleased)
; {
; if (*kbdve0)
; kbdKeyBuffer[kbdKeyPtrW] = 0x12; // 18
; else
; kbdKeyBuffer[kbdKeyPtrW] = '4';
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; case 0x72: // down arrow
; if (!*kbdvreleased)
; {
; if (*kbdve0)
; kbdKeyBuffer[kbdKeyPtrW] = 0x13; // 19
; else
; kbdKeyBuffer[kbdKeyPtrW] = '2';
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; case 0x74: // right arrow
; if (!*kbdvreleased)
; {
; if (*kbdve0)
; kbdKeyBuffer[kbdKeyPtrW] = 0x14; // 20
; else
; kbdKeyBuffer[kbdKeyPtrW] = '6';
; kbdKeyPtrW++;
; if (kbdKeyPtrW > kbdKeyBuffMax)
; kbdKeyPtrW = 0;
; }
; break;
; } // end switch
; *kbdvreleased = 0;
; *kbdve0 = 0;
; } // end if (decoded>0x00)
; *kbdvreleased = 0;
; }
; }
; //-----------------------------------------------------------------------------
; unsigned char convertCode(unsigned char codeToFind, unsigned char *source, unsigned char *destination)
; {
; while(*source != codeToFind && *source++ > 0x00)
; destination++;
; return *destination;
; }
; //-----------------------------------------------------------------------------
; void sendByte(unsigned char b)
; {
; /*unsigned char a=0;
; unsigned char p = 1;
; unsigned char t = 0;
; // Desabilita KBD and VDP Interruption
; *(vmfp + Reg_IERA) &= 0x3E;
; *(vmfp + Reg_GPDR) &= 0xBF; // Zera Clock (I6)
; *(vmfp + Reg_DDR)  |= 0x40; // I6 as Output
; delayus(125);
; *(vmfp + Reg_GPDR) &= 0xFE; // Zera Data (I0)
; *(vmfp + Reg_DDR)  |= 0x01; // I0 as Output
; delayus(125);
; *(vmfp + Reg_DDR)  &= 0xBF; // I6 as Input
; for(a = 0; a < 8; a++) {
; t = (b >> a) & 0x01;
; while ((*(vmfp + Reg_GPDR) & 0x40) == 0x40); //wait clock for 0
; *(vmfp + Reg_GPDR) |= t;
; if (t) p++;
; while ((*(vmfp + Reg_GPDR) & 0x40) == 0x00); //wait clock for 1
; }
; while((*(vmfp + Reg_GPDR) & 0x40) == 0x40); //wait clock for 0
; *(vmfp + Reg_GPDR) |= p & 0x01;
; while((*(vmfp + Reg_GPDR) & 0x40) == 0x00); //wait clock for 1
; *(vmfp + Reg_DDR)  &= 0xFE; // I0 as Input
; while((*(vmfp + Reg_GPDR) & 0x01) == 0x01); //wait data for 0
; while((*(vmfp + Reg_GPDR) & 0x40) == 0x40); //wait clock for 0
; // Habilita KBD and VDP Interruption
; *(vmfp + Reg_IERA) |= 0xC0;*/
; }
; #endif
; //-----------------------------------------------------------------------------
; void basicFuncBios(void)
; {
       xdef      _basicFuncBios
_basicFuncBios:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcSpuriousInt(void)
; {
       xdef      _funcSpuriousInt
_funcSpuriousInt:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntPIC(void)
; {
       xdef      _funcIntPIC
_funcIntPIC:
       rts
; // Chamada de dados do PIC para o processador
; }
; //-----------------------------------------------------------------------------
; void funcIntUsbSerial(void)
; {
       xdef      _funcIntUsbSerial
_funcIntUsbSerial:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntVideo(void)
; {
       xdef      _funcIntVideo
_funcIntVideo:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMouse(void)
; {
       xdef      _funcIntMouse
_funcIntMouse:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntKeyboard(void)
; {
       xdef      _funcIntKeyboard
_funcIntKeyboard:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMultiTask(void)
; {
       xdef      _funcIntMultiTask
_funcIntMultiTask:
       rts
; // Nao usara por enquanto, porque sera controlado pelo SO
; // E serah feito em ASM por causa das trocas de SP (A7)
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi0(void)
; {
       xdef      _funcIntMfpGpi0
_funcIntMfpGpi0:
; // TBD
; *(vmfp + Reg_ISRB) &= 0xFE;  // Reseta flag de interrupcao GPI0 no MFP
       move.l    _vmfp.L,A0
       move.w    _Reg_ISRB.L,D0
       and.l     #65535,D0
       and.b     #254,0(A0,D0.L)
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi1(void)
; {
       xdef      _funcIntMfpGpi1
_funcIntMfpGpi1:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi2(void)
; {
       xdef      _funcIntMfpGpi2
_funcIntMfpGpi2:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi3(void)
; {
       xdef      _funcIntMfpGpi3
_funcIntMfpGpi3:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpTmrD(void)
; {
       xdef      _funcIntMfpTmrD
_funcIntMfpTmrD:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpTmrC(void)
; {
       xdef      _funcIntMfpTmrC
_funcIntMfpTmrC:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi4(void)
; {
       xdef      _funcIntMfpGpi4
_funcIntMfpGpi4:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi5(void)
; {
       xdef      _funcIntMfpGpi5
_funcIntMfpGpi5:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpTmrB(void)
; {
       xdef      _funcIntMfpTmrB
_funcIntMfpTmrB:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpXmitErr(void)
; {
       xdef      _funcIntMfpXmitErr
_funcIntMfpXmitErr:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpXmitBufEmpty(void)
; {
       xdef      _funcIntMfpXmitBufEmpty
_funcIntMfpXmitBufEmpty:
; vBufXmitEmpty = 1; // Buffer Transmissao Vazio
       move.b    #1,_vBufXmitEmpty.L
       rts
; //*(vmfp + Reg_GPDR) = 0x05;
; //    *(vmfp + Reg_ISRA) &= 0xFB; // Reseta flag de interrupcao no MFP
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpRecErr(void)
; {
       xdef      _funcIntMfpRecErr
_funcIntMfpRecErr:
       rts
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpRecBufFull(void)
; {
       xdef      _funcIntMfpRecBufFull
_funcIntMfpRecBufFull:
; vBufReceived = *(vmfp + Reg_UDR);   // Carrega byte do buffer do MFP
       move.l    _vmfp.L,A0
       move.w    _Reg_UDR.L,D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),_vBufReceived.L
       rts
; //    *(vmfp + Reg_ISRA) &= 0xEF;  // Reseta flag de interrupcao no MFP
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpTmrA(void)
; {
       xdef      _funcIntMfpTmrA
_funcIntMfpTmrA:
; SysClockms = SysClockms + 1;
       addq.l    #1,_SysClockms.L
       rts
; // Reseta flag de interrupcao no MFP do Timer A
; //    *(vmfp + Reg_ISRA) &= 0xDF;
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi6(void)
; {
       xdef      _funcIntMfpGpi6
_funcIntMfpGpi6:
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _Reg_GPDR.L,A2
       lea       _vmfp.L,A3
       lea       _writeLongSerial.L,A4
       lea       _debugMessages.L,A5
; #ifdef __KEYPS2_EXT__
; unsigned char decoded = 0xFF;
       move.b    #255,D3
; int vTimeout;
; if (debugMessages)
       tst.b     (A5)
       beq.s     funcIntMfpGpi6_1
; writeLongSerial("Aqui 0\r\n\0");
       pea       @monitor_66.L
       jsr       (A4)
       addq.w    #4,A7
funcIntMfpGpi6_1:
; // Pega dados do controlador via protocolo
; while (decoded != 0)
funcIntMfpGpi6_3:
       tst.b     D3
       beq       funcIntMfpGpi6_5
; {
; vTimeout = 0x0FF;
       move.l    #255,D2
; *(vmfp + Reg_GPDR) &= 0xEF;  // Seta CS (I4) = 0 do controlador e/ou indicando que ja leu MSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       and.b     #239,0(A0,D0.L)
; while (*(vmfp + Reg_GPDR) & 0x20 && vTimeout) vTimeout--; // Aguarda Controlador liberar LSB para leitura
funcIntMfpGpi6_6:
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #32,D0
       and.l     #255,D0
       beq.s     funcIntMfpGpi6_8
       tst.l     D2
       beq.s     funcIntMfpGpi6_8
       subq.l    #1,D2
       bra       funcIntMfpGpi6_6
funcIntMfpGpi6_8:
; decoded = *(vmfp + Reg_GPDR) & 0x0F;
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #15,D0
       move.b    D0,D3
; vTimeout = 0x0FF;
       move.l    #255,D2
; *(vmfp + Reg_GPDR) |= 0x10;  // Seta CS (I4) = 1 do controlador indicando que ja leu LSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       or.b      #16,0(A0,D0.L)
; while (!(*(vmfp + Reg_GPDR) & 0x20) && vTimeout) vTimeout--; // Aguarda Controlador liberar MSB para leitura
funcIntMfpGpi6_9:
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #32,D0
       bne.s     funcIntMfpGpi6_12
       moveq     #1,D0
       bra.s     funcIntMfpGpi6_13
funcIntMfpGpi6_12:
       clr.l     D0
funcIntMfpGpi6_13:
       and.l     #255,D0
       beq.s     funcIntMfpGpi6_11
       tst.l     D2
       beq.s     funcIntMfpGpi6_11
       subq.l    #1,D2
       bra       funcIntMfpGpi6_9
funcIntMfpGpi6_11:
; decoded |= ((*(vmfp + Reg_GPDR) & 0x0F) << 4);
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #15,D0
       lsl.b     #4,D0
       or.b      D0,D3
; if (!vTimeout)
       tst.l     D2
       bne.s     funcIntMfpGpi6_14
; {
; if (debugMessages)
       tst.b     (A5)
       beq.s     funcIntMfpGpi6_16
; writeLongSerial("Aqui 0.1\r\n\0");
       pea       @monitor_67.L
       jsr       (A4)
       addq.w    #4,A7
funcIntMfpGpi6_16:
; *(vmfp + Reg_GPDR) &= 0xEF;  // Seta CS (I4) = 0 do controlador e/ou indicando que ja leu MSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       and.b     #239,0(A0,D0.L)
; break;
       bra       funcIntMfpGpi6_5
funcIntMfpGpi6_14:
; }
; if (decoded != 0x00)
       tst.b     D3
       beq.s     funcIntMfpGpi6_20
; {
; // Coloca tecla digitada no buffer
; kbdKeyBuffer[kbdKeyPtrW] = decoded;
       move.b    _kbdKeyPtrW.L,D0
       and.l     #255,D0
       lea       _kbdKeyBuffer.L,A0
       move.b    D3,0(A0,D0.L)
; kbdKeyPtrW = kbdKeyPtrW + 1;
       addq.b    #1,_kbdKeyPtrW.L
; if (kbdKeyPtrW > kbdKeyBuffMax)
       move.b    _kbdKeyPtrW.L,D0
       cmp.b     #65,D0
       bls.s     funcIntMfpGpi6_20
; kbdKeyPtrW = 0;
       clr.b     _kbdKeyPtrW.L
funcIntMfpGpi6_20:
; }
; *(vmfp + Reg_GPDR) &= 0xEF;  // Seta CS (I4) = 0 do controlador e/ou indicando que ja leu MSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       and.b     #239,0(A0,D0.L)
       bra       funcIntMfpGpi6_3
funcIntMfpGpi6_5:
; }
; *(vmfp + Reg_GPDR) |= 0x10;  // Seta CS = 1 (I4) do controlador
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       or.b      #16,0(A0,D0.L)
; if (debugMessages)
       tst.b     (A5)
       beq.s     funcIntMfpGpi6_22
; writeLongSerial("Aqui 1\r\n\0");
       pea       @monitor_68.L
       jsr       (A4)
       addq.w    #4,A7
funcIntMfpGpi6_22:
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       rts
; #endif
; #ifdef __KEYPS2__
; unsigned int vTimeout;
; /*if (*kbdPs2Readtype == 1)
; {
; // Verifica se deu timout no timer A do MFP
; if (*kbdClockCount != 0 && (SysClockms > *kbdtimeout))
; {
; // Timer A zerou: timeout ocorreu. Reinicia nova sequencia
; scanCode = 0;
; *kbdClockCount = 0;
; }
; if (*kbdClockCount >= 1 && *kbdClockCount <= 8)
; {
; // No 11 bits received yet: add to the scancode [start][d0...d7][parity][stop]
; scanCode = (scanCode >> 1);
; scanCode = scanCode | ((*(vmfp + Reg_GPDR) & 0x01) << 7);
; }
; if (*kbdClockCount == 10)
; {
; // 11 bits received: process the code
; processCode();
; scanCode = 0;
; *kbdClockCount = 0;
; }
; else
; {
; *kbdClockCount = *kbdClockCount + 1;
; }
; *kbdtimeout = SysClockms + 64;
; }
; else
; {*/
; vTimeout = 0x0FFF;
; while((*mfpgpdr & 0x01) && vTimeout) vTimeout--; // Wait data = 0
; if (vTimeout)
; {
; scanCode = readKbdPs2();
; if (scanCode != 0xFE)   // If not retry, continue
; {
; scanCode = (scanCode >> 1) & 0x00FF;  // shift out the start bit
; // Grava o scancode no buffer
; kbdScanCodeBuf[kbdScanCodePtrW] = scanCode;
; // Soma 1 no ponteiro de gravacao do buffer circular
; kbdScanCodePtrW++;
; // Se chegar em 16, volta pra 0
; if (kbdScanCodePtrW > kbdKeyBuffMax)
; kbdScanCodePtrW = 0;
; }
; }
; //}
; #endif
; // Reseta flag de interrupcao no MFP do I6
; //    *(vmfp + Reg_ISRA) &= 0xBF;
; }
; //-----------------------------------------------------------------------------
; void funcIntMfpGpi7(void)
; {
       xdef      _funcIntMfpGpi7
_funcIntMfpGpi7:
       movem.l   D2/D3/A2/A3/A4/A5,-(A7)
       lea       _Reg_GPDR.L,A2
       lea       _vmfp.L,A3
       lea       _writeLongSerial.L,A4
       lea       _debugMessages.L,A5
; #ifdef __MOUSEPS2__EXT__
; unsigned char decoded = 0xFF;
       move.b    #255,D3
; int vTimeout;
; if (debugMessages)
       tst.b     (A5)
       beq.s     funcIntMfpGpi7_1
; writeLongSerial("Aqui 2\r\n\0");
       pea       @monitor_69.L
       jsr       (A4)
       addq.w    #4,A7
funcIntMfpGpi7_1:
; // Pega dados do controlador via protocolo
; while (1)
funcIntMfpGpi7_3:
; {
; if (*(vmfp + Reg_GPDR) & 0x80)
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       and.w     #128,D0
       beq.s     funcIntMfpGpi7_6
; {
; break;
       bra       funcIntMfpGpi7_5
funcIntMfpGpi7_6:
; }
; vTimeout = 0xFF;
       move.l    #255,D2
; *(vmfp + Reg_GPDR) &= 0xEF;  // Seta CS (I4) = 0 do controlador e/ou indicando que ja leu MSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       and.b     #239,0(A0,D0.L)
; while (*(vmfp + Reg_GPDR) & 0x20 && vTimeout) vTimeout--; // Aguarda Controlador liberar LSB para leitura
funcIntMfpGpi7_8:
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #32,D0
       and.l     #255,D0
       beq.s     funcIntMfpGpi7_10
       tst.l     D2
       beq.s     funcIntMfpGpi7_10
       subq.l    #1,D2
       bra       funcIntMfpGpi7_8
funcIntMfpGpi7_10:
; decoded = *(vmfp + Reg_GPDR) & 0x0F;
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #15,D0
       move.b    D0,D3
; if (vTimeout)
       tst.l     D2
       beq.s     funcIntMfpGpi7_11
; vTimeout = 0xFF;
       move.l    #255,D2
funcIntMfpGpi7_11:
; *(vmfp + Reg_GPDR) |= 0x10;  // Seta CS (I4) = 1 do controlador indicando que ja leu LSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       or.b      #16,0(A0,D0.L)
; while (!(*(vmfp + Reg_GPDR) & 0x20) && vTimeout) vTimeout--; // Aguarda Controlador liberar MSB para leitura
funcIntMfpGpi7_13:
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #32,D0
       bne.s     funcIntMfpGpi7_16
       moveq     #1,D0
       bra.s     funcIntMfpGpi7_17
funcIntMfpGpi7_16:
       clr.l     D0
funcIntMfpGpi7_17:
       and.l     #255,D0
       beq.s     funcIntMfpGpi7_15
       tst.l     D2
       beq.s     funcIntMfpGpi7_15
       subq.l    #1,D2
       bra       funcIntMfpGpi7_13
funcIntMfpGpi7_15:
; decoded |= ((*(vmfp + Reg_GPDR) & 0x0F) << 4);
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       move.b    0(A0,D0.L),D0
       and.b     #15,D0
       lsl.b     #4,D0
       or.b      D0,D3
; if (!vTimeout)
       tst.l     D2
       bne.s     funcIntMfpGpi7_18
; {
; if (debugMessages)
       tst.b     (A5)
       beq.s     funcIntMfpGpi7_20
; writeLongSerial("Aqui 2.1\r\n\0");
       pea       @monitor_70.L
       jsr       (A4)
       addq.w    #4,A7
funcIntMfpGpi7_20:
; *(vmfp + Reg_GPDR) &= 0xEF;  // Seta CS (I4) = 0 do controlador e/ou indicando que ja leu MSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       and.b     #239,0(A0,D0.L)
; break;
       bra.s     funcIntMfpGpi7_5
funcIntMfpGpi7_18:
; }
; // Coloca dado mouse lido no buffer
; MseMovBuffer[MseMovPtrW] = decoded;
       move.b    _MseMovPtrW.L,D0
       and.l     #255,D0
       lea       _MseMovBuffer.L,A0
       move.b    D3,0(A0,D0.L)
; MseMovPtrW = MseMovPtrW + 1;
       addq.b    #1,_MseMovPtrW.L
; if (MseMovPtrW > kbdKeyBuffMax)
       move.b    _MseMovPtrW.L,D0
       cmp.b     #65,D0
       bls.s     funcIntMfpGpi7_22
; MseMovPtrW = 0;
       clr.b     _MseMovPtrW.L
funcIntMfpGpi7_22:
; *(vmfp + Reg_GPDR) &= 0xEF;  // Seta CS (I4) = 0 do controlador e/ou indicando que ja leu MSB
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       and.b     #239,0(A0,D0.L)
       bra       funcIntMfpGpi7_3
funcIntMfpGpi7_5:
; }
; *(vmfp + Reg_GPDR) |= 0x10;  // Seta CS = 1 (I4) do controlador
       move.l    (A3),A0
       move.w    (A2),D0
       and.l     #65535,D0
       or.b      #16,0(A0,D0.L)
; // Verifica se ao final, o cursor de gravacao é modulo 3, ou seja, sempre entrou 3 dados do mouse
; // Se nao for modulo 3, volta até ser modulo 3.
; while ((MseMovPtrW % 3) != 0)
funcIntMfpGpi7_24:
       move.b    _MseMovPtrW.L,D0
       and.l     #65535,D0
       divu.w    #3,D0
       swap      D0
       tst.b     D0
       beq.s     funcIntMfpGpi7_26
; MseMovPtrW = MseMovPtrW - 1;
       subq.b    #1,_MseMovPtrW.L
       bra       funcIntMfpGpi7_24
funcIntMfpGpi7_26:
; if (debugMessages)
       tst.b     (A5)
       beq.s     funcIntMfpGpi7_27
; writeLongSerial("Aqui 3\r\n\0");
       pea       @monitor_71.L
       jsr       (A4)
       addq.w    #4,A7
funcIntMfpGpi7_27:
       movem.l   (A7)+,D2/D3/A2/A3/A4/A5
       rts
; #endif
; }
; #ifdef __KEYPS2__
; //-----------------------------------------------------------------------------
; // read a byte from Keyboard
; //-----------------------------------------------------------------------------
; unsigned char readKbdPs2 (void)
; {
; unsigned long bData = 0;
; unsigned long vTimeout = 0xFFFF;
; unsigned int ix;
; // shift in 11 bits from MSB to LSB
; for(ix = 0; ix < 11; ix++)
; {
; while((*mfpgpdr & 0x40) && vTimeout) vTimeout--; // wait for the clock to go LOW
; if (vTimeout)
; bData += ((*mfpgpdr & 0x01) << ix);    // shift in a bit
; while(!(*mfpgpdr & 0x40) && vTimeout) vTimeout--;  // wait here while the clock is still low
; }
; if (!vTimeout)
; {
; writeKbdPs2(0xFE);  // Resend Last Byte
; bData = 0xFE;
; }
; return (unsigned char)bData;
; }
; //-----------------------------------------------------------------------------
; // write a byte to the keyboard
; //-----------------------------------------------------------------------------
; void writeKbdPs2(unsigned char pData)
; {
; int ix, pParity;
; unsigned long vTimeout = 0xFFFF;
; unsigned char pDataTemp;
; // bring the clock low to stop mouse from communicating
; *mfpddr |= 0x40;   // I6 - Output
; *mfpgpdr &= 0xBF;  // Seta Clk = 0
; delayus(200); // wait for mouse 200us
; // bring data low to tell mouse that the host wants to communicate
; *mfpddr |= 0x01;   // I0 - Output
; *mfpgpdr &= 0xFE;  // Seta Data = 0
; delayus(50);  // wait for mouse 50us
; // release control of clock by putting it back to a input
; *mfpddr &= 0xBF;   // I6 - Input
; while((*mfpgpdr & 0x40) && vTimeout) vTimeout--;     // wait for clk to go low
; *Ps2PairChk = 0x00;
; for (ix = 0; ix < 8; ix++)
; {
; pDataTemp = ((pData & (1 << ix)) >> ix);
; *mfpgpdr = ((*mfpgpdr & 0xFE) | pDataTemp);
; *Ps2PairChk += pDataTemp;         // count if 1 for pairity check later
; while(!(*mfpgpdr & 0x40) && vTimeout) vTimeout--;  // wait for clk to go high
; while((*mfpgpdr & 0x40) && vTimeout) vTimeout--;     // wait for clk to go low
; }
; // Send parity data
; if(*Ps2PairChk % 2 == 0)
; *mfpgpdr |= 0x01;
; else
; *mfpgpdr &= 0xFE;
; *vStatusMse = *mfpgpdr;
; while(!(*mfpgpdr & 0x40) && vTimeout) vTimeout--;  // wait for clk to go high
; while((*mfpgpdr & 0x40) && vTimeout) vTimeout--;     // wait for clk to go low
; // release control of data
; *mfpddr &= 0xFE;   // I0 - Input
; while((*mfpgpdr & 0x01) && vTimeout) vTimeout--; // wait for data to go low
; while((*mfpgpdr & 0x40) && vTimeout) vTimeout--; // wait for clk to go low
; while(!(*mfpgpdr & 0x01) && vTimeout) vTimeout--; // wait for data to go high again
; while(!(*mfpgpdr & 0x40) && vTimeout) vTimeout--;  // wait for clk to go high again
; }
; #endif
; #ifdef __MOUSEPS2__
; //-----------------------------------------------------------------------------
; // write a byte to the mouse
; //-----------------------------------------------------------------------------
; void writeMsePs2(unsigned char pData)
; {
; int ix, pParity;
; unsigned long vTimeout = 0xFFFF;
; unsigned char pDataTemp;
; // bring the clock low to stop mouse from communicating
; *mfpddr |= 0x80;   // I7 - Output
; *mfpgpdr &= 0x7F;  // Seta Clk = 0
; delayus(200); // wait for mouse 200us
; // bring data low to tell mouse that the host wants to communicate
; *mfpddr |= 0x02;   // I1 - Output
; *mfpgpdr &= 0xFD;  // Seta Data = 0
; delayus(50);  // wait for mouse 50us
; // release control of clock by putting it back to a input
; *mfpddr &= 0x7F;   // I7 - Input
; while((*mfpgpdr & 0x80) && vTimeout) vTimeout--;     // wait for clk to go low
; *Ps2PairChk = 0x00;
; for (ix = 0; ix < 8; ix++)
; {
; pDataTemp = ((pData & (1 << ix)) >> ix);
; *mfpgpdr = (*mfpgpdr & 0xFD) | (pDataTemp << 1);
; //*(MseMovBuffer + 8 + ix) = pDataTemp;
; *Ps2PairChk += pDataTemp;         // count if 1 for pairity check later
; while(!(*mfpgpdr & 0x80) && vTimeout) vTimeout--;  // wait for clk to go high
; while((*mfpgpdr & 0x80) && vTimeout) vTimeout--;     // wait for clk to go low
; }
; // Send parity data
; if(*Ps2PairChk % 2 == 0)
; *mfpgpdr |= 0x02;
; else
; *mfpgpdr &= 0xFD;
; *vStatusMse = *mfpgpdr;
; while(!(*mfpgpdr & 0x80) && vTimeout) vTimeout--;  // wait for clk to go high
; while((*mfpgpdr & 0x80) && vTimeout) vTimeout--;     // wait for clk to go low
; // release control of data
; *mfpddr &= 0xFD;   // I1 - Input
; while((*mfpgpdr & 0x02) && vTimeout) vTimeout--; // wait for data to go low
; while((*mfpgpdr & 0x80) && vTimeout) vTimeout--; // wait for clk to go low
; while(!(*mfpgpdr & 0x02) && vTimeout) vTimeout--; // wait for data to go high again
; while(!(*mfpgpdr & 0x80) && vTimeout) vTimeout--;  // wait for clk to go high again
; }
; //-----------------------------------------------------------------------------
; // read a byte from Mouse
; //-----------------------------------------------------------------------------
; unsigned char readMsePs2 (void)
; {
; unsigned long bData = 0;
; unsigned long vTimeout = 0xFFFF;
; unsigned int ix;
; // shift in 11 bits from MSB to LSB
; for(ix = 0; ix < 11; ix++)
; {
; while((*mfpgpdr & 0x80) && vTimeout) vTimeout--; // wait for the clock to go LOW
; if (vTimeout)
; bData += (((*mfpgpdr & 0x02) >> 1) << ix);    // shift in a bit
; while(!(*mfpgpdr & 0x80) && vTimeout) vTimeout--;  // wait here while the clock is still low
; }
; bData = (bData >> 1) & 0x00FF; // shift out the start bit
; return (unsigned char)bData;
; }
; //-----------------------------------------------------------------------------
; // clear input clk/data from Mouse
; //-----------------------------------------------------------------------------
; void flushMsePs2 (void)
; {
; unsigned long bData = 0;
; unsigned long vTimeout = 0xFFF;
; unsigned int ix;
; for(ix = 0; ix < 11; ix++)
; {
; while(!(*mfpgpdr & 0x80) && vTimeout) vTimeout--;  // wait here while the clock is still low
; }
; }
; #endif
; //-----------------------------------------------------------------------------
; void funcZeroesLeft(unsigned char* buffer, unsigned char vTam)
; {
       xdef      _funcZeroesLeft
_funcZeroesLeft:
       link      A6,#-20
       movem.l   D2/D3/D4/D5/A2/A3,-(A7)
       lea       -20(A6),A2
       move.l    8(A6),D4
       lea       _strlen.L,A3
       move.b    15(A6),D5
       and.l     #255,D5
; unsigned char vbuffer[20], i, j;
; if (vTam < strlen(vbuffer))
       and.l     #255,D5
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #4,A7
       cmp.l     D0,D5
       bhs.s     funcZeroesLeft_1
; vTam = strlen(vbuffer);
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #4,A7
       move.b    D0,D5
funcZeroesLeft_1:
; strcpy(vbuffer,buffer);
       move.l    D4,-(A7)
       move.l    A2,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
; for (i=0; i<(vTam-strlen(vbuffer));i++) {
       clr.b     D2
funcZeroesLeft_3:
       and.l     #255,D2
       move.b    D5,D0
       and.l     #255,D0
       move.l    D0,-(A7)
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       sub.l     D1,D0
       cmp.l     D0,D2
       bhs.s     funcZeroesLeft_5
; buffer[i]='0';
       move.l    D4,A0
       and.l     #255,D2
       move.b    #48,0(A0,D2.L)
       addq.b    #1,D2
       bra       funcZeroesLeft_3
funcZeroesLeft_5:
; }
; for(j=0;j<strlen(vbuffer);j++){
       clr.b     D3
funcZeroesLeft_6:
       and.l     #255,D3
       move.l    A2,-(A7)
       jsr       (A3)
       addq.w    #4,A7
       cmp.l     D0,D3
       bhs.s     funcZeroesLeft_8
; buffer[i] = vbuffer[j];
       and.l     #255,D3
       move.l    D4,A0
       and.l     #255,D2
       move.b    0(A2,D3.L),0(A0,D2.L)
; i++;
       addq.b    #1,D2
; buffer[i] = 0x00;
       move.l    D4,A0
       and.l     #255,D2
       clr.b     0(A0,D2.L)
       addq.b    #1,D3
       bra       funcZeroesLeft_6
funcZeroesLeft_8:
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; void funcErrorBusAddr(void)
; {
       xdef      _funcErrorBusAddr
_funcErrorBusAddr:
       link      A6,#-20
       movem.l   D2/D3/D4/A2/A3/A4/A5,-(A7)
       lea       _printText.L,A2
       lea       _printChar.L,A3
       lea       -20(A6),A4
       lea       _funcZeroesLeft.L,A5
; unsigned int ix = 0, iz;
       clr.l     D2
; unsigned char sqtdtam[20];
; unsigned short vOP = 0;
       clr.w     D4
; videoCursorPosColX = 0;
       clr.w     _videoCursorPosColX.L
; videoCursorPosRowY = 0;
       clr.w     _videoCursorPosRowY.L
; videoScroll = 1;       // Ativo
       move.b    #1,_videoScroll.L
; videoScrollDir = 1;    // Pra Cima
       move.b    #1,_videoScrollDir.L
; videoCursorBlink = 1;
       move.b    #1,_videoCursorBlink.L
; videoCursorShow = 0;
       clr.b     _videoCursorShow.L
; vdpMaxCols = 39;
       move.b    #39,_vdpMaxCols.L
; vdpMaxRows = 23;
       move.b    #23,_vdpMaxRows.L
; vdp_init_textmode(VDP_WHITE, VDP_DARK_RED);
       pea       6
       pea       15
       jsr       _vdp_init_textmode
       addq.w    #8,A7
; clearScr();
       jsr       _clearScr
; printChar(218,1);
       pea       1
       pea       218
       jsr       (A3)
       addq.w    #8,A7
; for (ix = 0; ix < 36; ix++)
       clr.l     D2
funcErrorBusAddr_1:
       cmp.l     #36,D2
       bhs.s     funcErrorBusAddr_3
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       funcErrorBusAddr_1
funcErrorBusAddr_3:
; printChar(191,1);
       pea       1
       pea       191
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("          EXCEPTION OCCURRED        ");
       pea       @monitor_73.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(195,1);
       pea       1
       pea       195
       jsr       (A3)
       addq.w    #8,A7
; for (ix = 0; ix < 36; ix++)
       clr.l     D2
funcErrorBusAddr_4:
       cmp.l     #36,D2
       bhs.s     funcErrorBusAddr_6
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       funcErrorBusAddr_4
funcErrorBusAddr_6:
; printChar(180,1);
       pea       1
       pea       180
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; vOP = *errorBufferAddrBus;
       move.l    _errorBufferAddrBus.L,A0
       move.w    (A0),D4
; switch (vOP)
       and.l     #65535,D4
       move.l    D4,D0
       cmp.l     #6,D0
       bhs       funcErrorBusAddr_7
       asl.l     #1,D0
       move.w    funcErrorBusAddr_9(PC,D0.L),D0
       jmp       funcErrorBusAddr_9(PC,D0.W)
funcErrorBusAddr_9:
       dc.w      funcErrorBusAddr_10-funcErrorBusAddr_9
       dc.w      funcErrorBusAddr_11-funcErrorBusAddr_9
       dc.w      funcErrorBusAddr_12-funcErrorBusAddr_9
       dc.w      funcErrorBusAddr_13-funcErrorBusAddr_9
       dc.w      funcErrorBusAddr_14-funcErrorBusAddr_9
       dc.w      funcErrorBusAddr_15-funcErrorBusAddr_9
funcErrorBusAddr_10:
; {
; case 0x0000:
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("      BUS ERROR / ADDRESS ERROR     ");
       pea       @monitor_74.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       funcErrorBusAddr_8
funcErrorBusAddr_11:
; case 0x0001:
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("         ILLEGAL INSTRUCTION        ");
       pea       @monitor_75.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       funcErrorBusAddr_8
funcErrorBusAddr_12:
; case 0x0002:
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("             ZERO DIVIDE            ");
       pea       @monitor_76.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       funcErrorBusAddr_8
funcErrorBusAddr_13:
; case 0x0003:
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("           CHK INSTRUCTION          ");
       pea       @monitor_77.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       funcErrorBusAddr_8
funcErrorBusAddr_14:
; case 0x0004:
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("                TRAPV               ");
       pea       @monitor_78.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       funcErrorBusAddr_8
funcErrorBusAddr_15:
; case 0x0005:
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("         PRIVILEGE VIOLATION        ");
       pea       @monitor_79.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       funcErrorBusAddr_8
funcErrorBusAddr_7:
; default:
; itoa(errorBufferAddrBus,sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 8);
       pea       8
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText(" : ");
       pea       @monitor_80.L
       jsr       (A2)
       addq.w    #4,A7
; itoa(vOP,sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       and.l     #65535,D4
       move.l    D4,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; break;
funcErrorBusAddr_8:
; }
; printChar(195,1);
       pea       1
       pea       195
       jsr       (A3)
       addq.w    #8,A7
; for (ix = 0; ix < 36; ix++)
       clr.l     D2
funcErrorBusAddr_17:
       cmp.l     #36,D2
       bhs.s     funcErrorBusAddr_19
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       funcErrorBusAddr_17
funcErrorBusAddr_19:
; printChar(180,1);
       pea       1
       pea       180
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; // Mostra Registradores: 2 words by register
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" D0       D1       D2       D3      ");
       pea       @monitor_81.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printChar(' ',1);
       pea       1
       pea       32
       jsr       (A3)
       addq.w    #8,A7
; for (iz = 0; iz < 4; iz++)  // Mostra d0-d3
       clr.l     D3
funcErrorBusAddr_20:
       cmp.l     #4,D3
       bhs       funcErrorBusAddr_22
; {
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; if (iz < 3)
       cmp.l     #3,D3
       bhs.s     funcErrorBusAddr_23
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
funcErrorBusAddr_23:
       addq.l    #1,D3
       bra       funcErrorBusAddr_20
funcErrorBusAddr_22:
; }
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" D4       D5       D6       D7      ");
       pea       @monitor_82.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printChar(' ',1);
       pea       1
       pea       32
       jsr       (A3)
       addq.w    #8,A7
; for (iz = 0; iz < 4; iz++)  // Mostra d4-d7
       clr.l     D3
funcErrorBusAddr_25:
       cmp.l     #4,D3
       bhs       funcErrorBusAddr_27
; {
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; if (iz < 3)
       cmp.l     #3,D3
       bhs.s     funcErrorBusAddr_28
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
funcErrorBusAddr_28:
       addq.l    #1,D3
       bra       funcErrorBusAddr_25
funcErrorBusAddr_27:
; }
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" A0       A1       A2       A3      ");
       pea       @monitor_83.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printChar(' ',1);
       pea       1
       pea       32
       jsr       (A3)
       addq.w    #8,A7
; for (iz = 0; iz < 4; iz++)  // Mostra d0-d3
       clr.l     D3
funcErrorBusAddr_30:
       cmp.l     #4,D3
       bhs       funcErrorBusAddr_32
; {
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; if (iz < 3)
       cmp.l     #3,D3
       bhs.s     funcErrorBusAddr_33
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
funcErrorBusAddr_33:
       addq.l    #1,D3
       bra       funcErrorBusAddr_30
funcErrorBusAddr_32:
; }
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" A4       A5       A6               ");
       pea       @monitor_84.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printChar(' ',1);
       pea       1
       pea       32
       jsr       (A3)
       addq.w    #8,A7
; for (iz = 0; iz < 3; iz++)  // Mostra d4-d7
       clr.l     D3
funcErrorBusAddr_35:
       cmp.l     #3,D3
       bhs       funcErrorBusAddr_37
; {
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
       addq.l    #1,D3
       bra       funcErrorBusAddr_35
funcErrorBusAddr_37:
; }
; printText("        ");
       pea       @monitor_85.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("                                    ");
       pea       @monitor_86.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" SR   PC       OffSet Special_Word  ");
       pea       @monitor_87.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printChar(' ',1);
       pea       1
       pea       32
       jsr       (A3)
       addq.w    #8,A7
; // Mostra SR: 1 word
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
; // Mostra PC to Return: 2 words
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
; // Mostra Vector offset: 1 word
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText("   ");
       pea       @monitor_61.L
       jsr       (A2)
       addq.w    #4,A7
; // Mostra Special Status Word: 1 word
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText("          ");
       pea       @monitor_88.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("                                    ");
       pea       @monitor_86.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" FaultAddr OutB InB  Instr.InB      ");
       pea       @monitor_89.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printChar(' ',1);
       pea       1
       pea       32
       jsr       (A3)
       addq.w    #8,A7
; // Mostra Fault Address: 2 words
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText("  ");
       pea       @monitor_90.L
       jsr       (A2)
       addq.w    #4,A7
; // unused: 1 word
; ix++;
       addq.l    #1,D2
; // Mostra output buffer: 1 word
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
; // unused: 1 word
; ix++;
       addq.l    #1,D2
; // Mostra input buffer: 1 word
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText(" ");
       pea       @monitor_55.L
       jsr       (A2)
       addq.w    #4,A7
; // unused: 1 word
; ix++;
       addq.l    #1,D2
; // Mostra instruction input buffer: 1 word
; itoa(*(errorBufferAddrBus + ix),sqtdtam,16);
       pea       16
       move.l    A4,-(A7)
       move.l    _errorBufferAddrBus.L,A0
       move.l    D2,D1
       lsl.l     #1,D1
       move.w    0(A0,D1.L),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; funcZeroesLeft(&sqtdtam, 4);
       pea       4
       move.l    A4,-(A7)
       jsr       (A5)
       addq.w    #8,A7
; printText(sqtdtam);
       move.l    A4,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; ix++;
       addq.l    #1,D2
; printText("           ");
       pea       @monitor_91.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("\r\n");
       pea       @monitor_2.L
       jsr       (A2)
       addq.w    #4,A7
; // Halt
; printChar(195,1);
       pea       1
       pea       195
       jsr       (A3)
       addq.w    #8,A7
; for (ix = 0; ix < 36; ix++)
       clr.l     D2
funcErrorBusAddr_38:
       cmp.l     #36,D2
       bhs.s     funcErrorBusAddr_40
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       funcErrorBusAddr_38
funcErrorBusAddr_40:
; printChar(180,1);
       pea       1
       pea       180
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText("            SYSTEM HALTED           ");
       pea       @monitor_92.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; printChar(192,1);
       pea       1
       pea       192
       jsr       (A3)
       addq.w    #8,A7
; for (ix = 0; ix < 36; ix++)
       clr.l     D2
funcErrorBusAddr_41:
       cmp.l     #36,D2
       bhs.s     funcErrorBusAddr_43
; printChar(196,1);
       pea       1
       pea       196
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       funcErrorBusAddr_41
funcErrorBusAddr_43:
; printChar(217,1);
       pea       1
       pea       217
       jsr       (A3)
       addq.w    #8,A7
; printText(" \r\n");
       pea       @monitor_72.L
       jsr       (A2)
       addq.w    #4,A7
; for(;;);
funcErrorBusAddr_44:
       bra       funcErrorBusAddr_44
; }
       section   const
@monitor_1:
       dc.b      77,77,83,74,45,51,50,48,32,66,73,79,83,32,118
       dc.b      49,46,51,97,0
@monitor_2:
       dc.b      13,10,0
@monitor_3:
       dc.b      85,116,105,108,105,116,121,32,40,99,41,32,50
       dc.b      48,49,52,45,50,48,50,54,13,10,0
@monitor_4:
       dc.b      75,32,66,121,116,101,115,32,70,111,117,110,100
       dc.b      46,32,0
@monitor_5:
       dc.b      75,32,66,121,116,101,115,32,70,114,101,101,46
       dc.b      13,10,0
@monitor_6:
       dc.b      79,75,13,10,0
@monitor_7:
       dc.b      62,0
@monitor_8:
       dc.b      67,76,83,0
@monitor_9:
       dc.b      67,76,69,65,82,0
@monitor_10:
       dc.b      86,69,82,0
@monitor_11:
       dc.b      76,79,65,68,0
@monitor_12:
       dc.b      87,97,105,116,46,46,46,13,10,0
@monitor_13:
       dc.b      82,85,78,0
@monitor_14:
       dc.b      66,65,83,73,67,0
@monitor_15:
       dc.b      77,79,68,69,0
@monitor_16:
       dc.b      80,79,75,69,0
@monitor_17:
       dc.b      76,79,65,68,83,79,0
@monitor_18:
       dc.b      82,85,78,83,79,0
@monitor_19:
       dc.b      68,69,66,85,71,0
@monitor_20:
       dc.b      68,101,98,117,103,32,77,101,115,115,97,103,101
       dc.b      115,32,79,102,102,13,10,0
@monitor_21:
       dc.b      68,101,98,117,103,32,77,101,115,115,97,103,101
       dc.b      115,32,79,110,13,10,0
@monitor_22:
       dc.b      68,85,77,80,0
@monitor_23:
       dc.b      68,68,85,85,77,77,80,80,0
@monitor_24:
       dc.b      54,48,50,48,65,48,0
@monitor_25:
       dc.b      49,50,56,0
@monitor_26:
       dc.b      0
@monitor_27:
       dc.b      68,85,77,80,83,0
@monitor_28:
       dc.b      68,85,77,80,87,0
@monitor_29:
       dc.b      85,110,107,110,111,119,110,32,67,111,109,109
       dc.b      97,110,100,32,33,33,33,13,10,0
@monitor_30:
       dc.b      117,115,97,103,101,58,32,109,111,100,101,32
       dc.b      91,99,111,100,101,93,13,10,0
@monitor_31:
       dc.b      32,32,32,99,111,100,101,58,32,48,32,61,32,84
       dc.b      101,120,116,32,77,111,100,101,32,52,48,120,50
       dc.b      52,13,10,0
@monitor_32:
       dc.b      32,32,32,32,32,32,32,32,32,49,32,61,32,71,114
       dc.b      97,112,104,105,99,32,84,101,120,116,32,77,111
       dc.b      100,101,32,51,50,120,50,52,13,10,0
@monitor_33:
       dc.b      32,32,32,32,32,32,32,32,32,50,32,61,32,71,114
       dc.b      97,112,104,105,99,32,50,53,54,120,49,57,50,13
       dc.b      10,0
@monitor_34:
       dc.b      32,32,32,32,32,32,32,32,32,51,32,61,32,71,114
       dc.b      97,112,104,105,99,32,54,52,120,52,56,13,10,0
@monitor_35:
       dc.b      117,115,97,103,101,58,32,112,111,107,101,32
       dc.b      60,101,110,100,101,114,62,32,60,98,121,116,101
       dc.b      62,13,10,0
@monitor_36:
       dc.b      117,115,97,103,101,58,32,100,117,109,112,32
       dc.b      60,101,110,100,101,114,62,32,91,113,116,100
       dc.b      93,32,91,99,111,108,115,93,13,10,0
@monitor_37:
       dc.b      32,32,32,32,113,116,100,58,32,100,101,102,97
       dc.b      117,108,116,32,54,52,13,10,0
@monitor_38:
       dc.b      32,32,32,99,111,108,115,58,32,100,101,102,97
       dc.b      117,108,116,32,56,13,10,0
@monitor_39:
       dc.b      124,0
@monitor_40:
       dc.b      117,115,97,103,101,58,32,100,117,109,112,32
       dc.b      60,101,110,100,101,114,32,105,110,105,116,105
       dc.b      97,108,62,32,91,113,116,100,32,40,100,101,102
       dc.b      97,117,108,116,32,50,53,54,41,93,13,10,0
@monitor_41:
       dc.b      104,32,58,32,0
@monitor_42:
       dc.b      32,124,32,0
@monitor_43:
       dc.b      117,115,97,103,101,58,32,100,117,109,112,119
       dc.b      32,60,101,110,100,101,114,62,32,91,113,116,100
       dc.b      93,32,91,99,111,108,115,93,13,10,0
@monitor_44:
       dc.b      32,32,32,32,113,116,100,58,32,100,101,102,97
       dc.b      117,108,116,32,49,50,56,13,10,0
@monitor_45:
       dc.b      100,117,109,112,119,32,79,110,108,121,32,87
       dc.b      111,114,107,115,32,105,110,32,52,48,32,99,111
       dc.b      108,115,13,10,0
@monitor_46:
       dc.b      32,32,32,32,32,32,32,32,32,32,32,32,32,68,85
       dc.b      77,80,87,32,118,48,46,49,32,32,32,32,32,32,32
       dc.b      32,32,32,32,32,32,32,32,32,13,10,0
@monitor_47:
       dc.b      65,100,100,114,32,0
@monitor_48:
       dc.b      32,32,32,32,32,32,32,32,32,66,121,116,101,115
       dc.b      32,32,32,32,32,32,32,32,32,0
@monitor_49:
       dc.b      32,65,83,67,73,73,32,0
@monitor_50:
       dc.b      32,60,45,58,80,114,101,118,32,32,45,62,58,78
       dc.b      101,120,116,32,32,60,0
@monitor_51:
       dc.b      58,65,100,100,114,32,32,69,83,67,58,69,120,105
       dc.b      116,32,0
@monitor_52:
       dc.b      32,65,100,100,114,101,115,115,40,72,69,88,41
       dc.b      58,32,32,32,32,32,32,32,32,32,32,32,32,32,32
       dc.b      32,32,32,32,32,32,32,32,32,0
@monitor_53:
       dc.b      82,101,99,101,105,118,105,110,103,46,32,60,69
       dc.b      115,99,62,32,116,111,32,67,97,110,99,101,108
       dc.b      46,46,46,32,13,10,0
@monitor_54:
       dc.b      65,100,100,114,101,115,115,32,108,111,97,100
       dc.b      105,110,103,58,32,48,120,0
@monitor_55:
       dc.b      32,0
@monitor_56:
       dc.b      84,105,109,101,111,117,116,46,32,80,114,111
       dc.b      99,101,115,115,32,65,98,111,114,116,101,100
       dc.b      46,13,10,0
@monitor_57:
       dc.b      70,105,108,101,32,108,111,97,100,101,100,32
       dc.b      105,110,32,116,111,32,109,101,109,111,114,121
       dc.b      32,115,117,99,99,101,115,115,102,117,108,121
       dc.b      46,13,10,0
@monitor_58:
       dc.b      65,100,100,114,101,115,115,32,108,111,97,100
       dc.b      101,100,58,32,48,120,0
@monitor_59:
       dc.b      76,111,97,100,105,110,103,32,97,98,111,114,116
       dc.b      101,100,46,13,10,0
@monitor_60:
       dc.b      70,105,108,101,32,108,111,97,100,101,100,32
       dc.b      105,110,32,116,111,32,109,101,109,111,114,121
       dc.b      32,119,105,116,104,32,99,104,101,99,107,115
       dc.b      117,109,32,101,114,114,111,114,115,46,13,10
       dc.b      0
@monitor_61:
       dc.b      32,32,32,0
@monitor_62:
       dc.b      68,111,110,101,33,0
@monitor_63:
       dc.b      76,111,97,100,105,110,103,32,79,83,46,32,80
       dc.b      108,101,97,115,101,32,87,97,105,116,46,46,46
       dc.b      0
@monitor_64:
       dc.b      73,79,32,69,114,114,111,114,46,46,46,46,13,10
       dc.b      0
@monitor_65:
       dc.b      79,107,13,10,0
@monitor_66:
       dc.b      65,113,117,105,32,48,13,10,0
@monitor_67:
       dc.b      65,113,117,105,32,48,46,49,13,10,0
@monitor_68:
       dc.b      65,113,117,105,32,49,13,10,0
@monitor_69:
       dc.b      65,113,117,105,32,50,13,10,0
@monitor_70:
       dc.b      65,113,117,105,32,50,46,49,13,10,0
@monitor_71:
       dc.b      65,113,117,105,32,51,13,10,0
@monitor_72:
       dc.b      32,13,10,0
@monitor_73:
       dc.b      32,32,32,32,32,32,32,32,32,32,69,88,67,69,80
       dc.b      84,73,79,78,32,79,67,67,85,82,82,69,68,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_74:
       dc.b      32,32,32,32,32,32,66,85,83,32,69,82,82,79,82
       dc.b      32,47,32,65,68,68,82,69,83,83,32,69,82,82,79
       dc.b      82,32,32,32,32,32,0
@monitor_75:
       dc.b      32,32,32,32,32,32,32,32,32,73,76,76,69,71,65
       dc.b      76,32,73,78,83,84,82,85,67,84,73,79,78,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_76:
       dc.b      32,32,32,32,32,32,32,32,32,32,32,32,32,90,69
       dc.b      82,79,32,68,73,86,73,68,69,32,32,32,32,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_77:
       dc.b      32,32,32,32,32,32,32,32,32,32,32,67,72,75,32
       dc.b      73,78,83,84,82,85,67,84,73,79,78,32,32,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_78:
       dc.b      32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
       dc.b      32,84,82,65,80,86,32,32,32,32,32,32,32,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_79:
       dc.b      32,32,32,32,32,32,32,32,32,80,82,73,86,73,76
       dc.b      69,71,69,32,86,73,79,76,65,84,73,79,78,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_80:
       dc.b      32,58,32,0
@monitor_81:
       dc.b      32,68,48,32,32,32,32,32,32,32,68,49,32,32,32
       dc.b      32,32,32,32,68,50,32,32,32,32,32,32,32,68,51
       dc.b      32,32,32,32,32,32,0
@monitor_82:
       dc.b      32,68,52,32,32,32,32,32,32,32,68,53,32,32,32
       dc.b      32,32,32,32,68,54,32,32,32,32,32,32,32,68,55
       dc.b      32,32,32,32,32,32,0
@monitor_83:
       dc.b      32,65,48,32,32,32,32,32,32,32,65,49,32,32,32
       dc.b      32,32,32,32,65,50,32,32,32,32,32,32,32,65,51
       dc.b      32,32,32,32,32,32,0
@monitor_84:
       dc.b      32,65,52,32,32,32,32,32,32,32,65,53,32,32,32
       dc.b      32,32,32,32,65,54,32,32,32,32,32,32,32,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_85:
       dc.b      32,32,32,32,32,32,32,32,0
@monitor_86:
       dc.b      32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
       dc.b      32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
       dc.b      32,32,32,32,32,32,0
@monitor_87:
       dc.b      32,83,82,32,32,32,80,67,32,32,32,32,32,32,32
       dc.b      79,102,102,83,101,116,32,83,112,101,99,105,97
       dc.b      108,95,87,111,114,100,32,32,0
@monitor_88:
       dc.b      32,32,32,32,32,32,32,32,32,32,0
@monitor_89:
       dc.b      32,70,97,117,108,116,65,100,100,114,32,79,117
       dc.b      116,66,32,73,110,66,32,32,73,110,115,116,114
       dc.b      46,73,110,66,32,32,32,32,32,32,0
@monitor_90:
       dc.b      32,32,0
@monitor_91:
       dc.b      32,32,32,32,32,32,32,32,32,32,32,0
@monitor_92:
       dc.b      32,32,32,32,32,32,32,32,32,32,32,32,83,89,83
       dc.b      84,69,77,32,72,65,76,84,69,68,32,32,32,32,32
       dc.b      32,32,32,32,32,32,0
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
       xdef      _ascii
_ascii:
       dc.b      97,98,99,100,101,102,103,104,105,106,107,108
       dc.b      109,110,111,112,113,114,115,116,117,118,119
       dc.b      120,121,122,48,49,50,51,52,53,54,55,56,57,59
       dc.b      61,46,44,47,39,91,93,96,45,32,0
       xdef      _ascii2
_ascii2:
       dc.b      65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
       dc.b      80,81,82,83,84,85,86,87,88,89,90,41,33,64,35
       dc.b      36,37,94,38,42,40,58,43,62,60,63,34,123,125
       dc.b      126,95,32,0
       xdef      _ascii3
_ascii3:
       dc.b      65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
       dc.b      80,81,82,83,84,85,86,87,88,89,90,48,49,50,51
       dc.b      52,53,54,55,56,57,59,61,46,44,47,39,91,93,96
       dc.b      45,32,0
       xdef      _ascii4
_ascii4:
       dc.b      97,98,99,100,101,102,103,104,105,106,107,108
       dc.b      109,110,111,112,113,114,115,116,117,118,119
       dc.b      120,121,122,41,33,64,35,36,37,94,38,42,40,58
       dc.b      43,62,60,63,34,123,125,126,95,32,0
       xdef      _keyCode
_keyCode:
       dc.b      28,50,33,35,36,43,52,51,67,59,66,75,58,49,68
       dc.b      77,21,45,27,44,60,42,29,34,53,26,69,22,30,38
       dc.b      37,46,54,61,62,70,76,85,73,65,74,82,84,91,14
       dc.b      78,41,0
       section   bss
       xdef      __allocp
__allocp:
       ds.b      4
       xdef      _runMemory
_runMemory:
       ds.b      4
       xdef      _kbdKeyPtrR
_kbdKeyPtrR:
       ds.b      1
       xdef      _kbdKeyPtrW
_kbdKeyPtrW:
       ds.b      1
       xdef      _kbdKeyBuffer
_kbdKeyBuffer:
       ds.b      66
       xdef      _scanCode
_scanCode:
       ds.b      1
       xdef      _vBufReceived
_vBufReceived:
       ds.b      1
       xdef      _vbuf
_vbuf:
       ds.b      128
       xdef      _MseMovPtrR
_MseMovPtrR:
       ds.b      1
       xdef      _MseMovPtrW
_MseMovPtrW:
       ds.b      1
       xdef      _MseMovBuffer
_MseMovBuffer:
       ds.b      66
       xdef      _vSizeTotalRec
_vSizeTotalRec:
       ds.b      4
       xdef      _vBufXmitEmpty
_vBufXmitEmpty:
       ds.b      1
       xdef      _vtotmem
_vtotmem:
       ds.b      1
       xdef      _SysClockms
_SysClockms:
       ds.b      4
       xdef      _startBasic
_startBasic:
       ds.b      2
       xdef      _debugMessages
_debugMessages:
       ds.b      1
       xref      _Reg_TACR
       xref      _videoScroll
       xref      _strcpy
       xref      _itoa
       xref      _ltoa
       xref      LDIV
       xref      _vdp_init_multicolor
       xref      LMUL
       xref      _atol
       xref      _free
       xref      _vmfp
       xref      _videoCursorPosRowY
       xref      _videoCursorBlink
       xref      _Reg_VR
       xref      _vdpMaxCols
       xref      _strlen
       xref      _Reg_IMRA
       xref      _Reg_IMRB
       xref      _Reg_GPDR
       xref      _vdp_write
       xref      _realloc
       xref      _Reg_RSR
       xref      ULMUL
       xref      _vdp_mode
       xref      _videoCursorShow
       xref      _videoCursorPosColX
       xref      _vdp_init_textmode
       xref      _clearScr
       xref      _vdp_set_cursor
       xref      _vdpMaxRows
       xref      _malloc
       xref      _vdp_init_g2
       xref      _vdp_init_g1
       xref      _runCmd
       xref      _runSO
       xref      _Reg_UCR
       xref      _toupper
       xref      _printText
       xref      _Reg_IERA
       xref      _Reg_IERB
       xref      _Reg_TDDR
       xref      _Reg_DDR
       xref      _Reg_TCDR
       xref      _Reg_TSR
       xref      _strcmp
       xref      _Reg_ISRA
       xref      ULDIV
       xref      _Reg_TCDCR
       xref      _Reg_ISRB
       xref      _Reg_TBCR
       xref      _videoScrollDir
       xref      _Reg_TBDR
       xref      _Reg_TADR
       xref      _Reg_AER
       xref      _runBas
       xref      _printChar
       xref      _Reg_UDR
