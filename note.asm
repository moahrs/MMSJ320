; D:\PROJETOS\MMSJ320\PROGS\NOTE.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; #ifndef MMSJOSAPI_H
; #define MMSJOSAPI_H
; // Function Shared Definitions
; #define MMSJOS_FUNC_TABLE    0x00800032
; #define MGUI_FUNC_TABLE      0x00805576
; // MMSJOS Struct for Functions
; typedef unsigned char (*fsGetDirAtuDataType)(FAT32_DIR *pDir);
; typedef void (*fsSetClusterDirType)(unsigned long vclusdiratu);
; typedef unsigned long (*fsGetClusterDirType)(void);
; typedef unsigned char (*fsSectorWriteType)(unsigned long vsector, unsigned char* vbuffer, unsigned char vtipo);
; typedef unsigned char (*fsSectorReadType)(unsigned long vsector, unsigned char* vbuffer);
; typedef unsigned char (*fsFindDirPathType)(char * vpath, char vtype);
; typedef unsigned long (*fsOsCommandType)(unsigned char * linhaParametro);
; typedef unsigned char (*fsCreateFileType)(char * vfilename);
; typedef unsigned char (*fsOpenFileType)(char * vfilename);
; typedef unsigned char (*fsCloseFileType)(char * vfilename, unsigned char vupdated);
; typedef unsigned long (*fsInfoFileType)(char * vfilename, unsigned char vtype);
; typedef unsigned char (*fsFreeType)(unsigned long vAddress);
; typedef unsigned short (*fsReadFileType)(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer);
; typedef unsigned char (*fsWriteFileType)(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer);
; typedef unsigned char (*fsDelFileType)(char * vfilename);
; typedef unsigned char (*fsRenameFileType)(char * vfilename, char * vnewname);
; typedef unsigned long (*loadFileType)(unsigned char *parquivo, unsigned short* xaddress);
; typedef unsigned char (*fsMakeDirType)(char * vdirname);
; typedef unsigned char (*fsChangeDirType)(char * vdirname);
; typedef unsigned char (*fsRemoveDirType)(char * vdirname);
; typedef unsigned char (*fsPwdDirType)(unsigned char *vdirpath);
; typedef unsigned long (*fsFindInDirType)(char * vname, unsigned char vtype);
; typedef unsigned long (*fsMallocType)(unsigned long vMemSize);
; typedef unsigned long (*fsFindNextClusterType)(unsigned long vclusteratual, unsigned char vtype);
; typedef unsigned long (*fsFindClusterFreeType)(unsigned char vtype);
; typedef unsigned char (*OSTimeDlyHMSMType)(unsigned char hours, unsigned char minutes, unsigned char seconds, unsigned int ms);
; typedef unsigned char (*OSTaskSuspendType)(unsigned char prio);
; typedef unsigned char (*OSTaskResumeType)(unsigned char prio);
; // MGUI Struct for Functions
; typedef void (*writesxyType)(unsigned short x, unsigned short y, unsigned char sizef, unsigned char *msgs, unsigned short pcolor, unsigned short pbcolor);
; typedef void (*writecxyType)(unsigned char sizef, unsigned char pbyte, unsigned short pcolor, unsigned short pbcolor);
; typedef void (*locatexyType)(unsigned short xx, unsigned short yy);
; typedef void (*SaveScreenNewType)(MGUI_SAVESCR *mguiSave, unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
; typedef void (*RestoreScreenType)(MGUI_SAVESCR vEnderSave);
; typedef void (*SetDotType)(unsigned short x, unsigned short y, unsigned short color);
; typedef void (*SetByteType)(unsigned short ix, unsigned short iy, unsigned char pByte, unsigned short pfcolor, unsigned short pbcolor);
; typedef void (*FillRectType)(unsigned char xi, unsigned char yi, unsigned short pwidth, unsigned char pheight, unsigned char pcor);
; typedef void (*DrawLineType)(unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2, unsigned short color);
; typedef void (*DrawRectType)(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight, unsigned short color);
; typedef void (*DrawRoundRectType)(unsigned int xi, unsigned int yi, unsigned int pwidth, unsigned int pheight, unsigned char radius, unsigned char color);
; typedef void (*DrawCircleType)(unsigned short x0, unsigned short y0, unsigned char r, unsigned char pfil, unsigned short pcor);
; typedef void (*PutIconeType)(unsigned int* vimage, unsigned short x, unsigned short y, unsigned char numSprite);
; typedef void (*InvertRectType)(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
; typedef void (*SelRectType)(unsigned short x, unsigned short y, unsigned short pwidth, unsigned short pheight);
; typedef void (*PutImageType)(unsigned char* cimage, unsigned short x, unsigned short y);
; typedef void (*LoadIconLibType)(unsigned char* cfile);
; typedef unsigned char (*waitButtonType)(void);
; typedef unsigned char (*messageType)(char* bstr, unsigned char bbutton, unsigned short btime);
; typedef void (*drawButtonsnewType)(unsigned char *vbuttons, unsigned char *pbbutton, unsigned short xib, unsigned short yib);
; typedef void (*showWindowType)(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton);
; typedef void (*TrocaSpriteMouseType)(unsigned char vicone);
; typedef void (*MostraIconeType)(unsigned short xi, unsigned short yi, unsigned char vicone, unsigned char colorfg, unsigned char colorbg);
; typedef char (*mguiCfgGetType)(char *section, char *key, char *vOutBuf, unsigned char vOutMax);
; typedef void (*putImagePbmP4Type)(unsigned long* memoria, unsigned short ix, unsigned short iy);
; typedef void (*setPosPressedType)(unsigned char vppostx, unsigned char vpposty);
; typedef void (*getMouseDataType)(MGUI_MOUSE *pmouseData);
; typedef void (*toggleboxType)(unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
; typedef void (*radiosetType)(unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
; typedef void (*fillinType)(unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo);
; typedef void (*getColorDataType)(MGUI_COLOR *pColor);
; typedef unsigned char (*buttonType)(unsigned char* title, unsigned short xib, unsigned short yib, unsigned short pwidth, unsigned short height, unsigned char vtipo);
; // MMSJOS define functions
; #define fsGetDirAtuData ((fsGetDirAtuDataType *)(unsigned long)MMSJOS_FUNC_TABLE)[0] // Índice da função
; #define fsSetClusterDir ((fsSetClusterDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[1] // Índice da função
; #define fsGetClusterDir ((fsGetClusterDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[2] // Índice da função
; #define fsSectorWrite ((fsSectorWriteType *)(unsigned long)MMSJOS_FUNC_TABLE)[3] // Índice da função
; #define fsSectorRead ((fsSectorReadType *)(unsigned long)MMSJOS_FUNC_TABLE)[4] // Índice da função
; #define fsFindDirPath ((fsFindDirPathType *)(unsigned long)MMSJOS_FUNC_TABLE)[5] // Índice da função
; #define fsOsCommand ((fsOsCommandType *)(unsigned long)MMSJOS_FUNC_TABLE)[6] // Índice da função
; #define fsCreateFile ((fsCreateFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[7] // Índice da função
; #define fsOpenFile ((fsOpenFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[8] // Índice da função
; #define fsCloseFile ((fsCloseFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[9] // Índice da função
; #define fsInfoFile ((fsInfoFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[10] // Índice da função
; #define fsFree ((fsFreeType *)(unsigned long)MMSJOS_FUNC_TABLE)[11] // Índice da função
; #define fsReadFile ((fsReadFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[12] // Índice da função
; #define fsWriteFile ((fsWriteFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[13] // Índice da função
; #define fsDelFile ((fsDelFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[14] // Índice da função
; #define fsRenameFile ((fsRenameFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[15] // Índice da função
; #define loadFile ((loadFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[16] // Índice da função
; #define fsMakeDir ((fsMakeDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[17] // Índice da função
; #define fsChangeDir ((fsChangeDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[18] // Índice da função
; #define fsRemoveDir ((fsRemoveDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[19] // Índice da função
; #define OSTimeDlyHMSM ((OSTimeDlyHMSMType *)(unsigned long)MMSJOS_FUNC_TABLE)[20] // Índice da função
; #define fsFindInDir ((fsFindInDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[21] // Índice da função
; #define fsMalloc ((fsMallocType *)(unsigned long)MMSJOS_FUNC_TABLE)[22] // Índice da função
; #define fsFindNextCluster ((fsFindNextClusterType *)(unsigned long)MMSJOS_FUNC_TABLE)[23] // Índice da função
; #define fsFindClusterFree ((fsFindClusterFreeType *)(unsigned long)MMSJOS_FUNC_TABLE)[24] // Índice da função
; #define OSTaskSuspend ((OSTaskSuspendType *)(unsigned long)MMSJOS_FUNC_TABLE)[25] // Índice da função
; #define OSTaskResume ((OSTaskResumeType *)(unsigned long)MMSJOS_FUNC_TABLE)[26] // Índice da função
; // MGUI define functions
; #define writesxy ((writesxyType *)(unsigned long)MGUI_FUNC_TABLE)[0] // Índice da função
; #define writecxy ((writecxyType *)(unsigned long)MGUI_FUNC_TABLE)[1] // Índice da função
; #define locatexy ((locatexyType *)(unsigned long)MGUI_FUNC_TABLE)[2] // Índice da função
; #define SaveScreenNew ((SaveScreenNewType *)(unsigned long)MGUI_FUNC_TABLE)[3] // Índice da função
; #define RestoreScreen ((RestoreScreenType *)(unsigned long)MGUI_FUNC_TABLE)[4] // Índice da função
; #define SetDot ((SetDotType *)(unsigned long)MGUI_FUNC_TABLE)[5] // Índice da função
; #define SetByte ((SetByteType *)(unsigned long)MGUI_FUNC_TABLE)[6] // Índice da função
; #define FillRect ((FillRectType *)(unsigned long)MGUI_FUNC_TABLE)[7] // Índice da função
; #define DrawLine ((DrawLineType *)(unsigned long)MGUI_FUNC_TABLE)[8] // Índice da função
; #define DrawRect ((DrawRectType *)(unsigned long)MGUI_FUNC_TABLE)[9] // Índice da função
; #define DrawRoundRect ((DrawRoundRectType *)(unsigned long)MGUI_FUNC_TABLE)[10] // Índice da função
; #define DrawCircle ((DrawCircleType *)(unsigned long)MGUI_FUNC_TABLE)[11] // Índice da função
; #define PutIcone ((PutIconeType *)(unsigned long)MGUI_FUNC_TABLE)[12] // Índice da função
; #define InvertRect ((InvertRectType *)(unsigned long)MGUI_FUNC_TABLE)[13] // Índice da função
; #define SelRect ((SelRectType *)(unsigned long)MGUI_FUNC_TABLE)[14] // Índice da função
; #define PutImage ((PutImageType *)(unsigned long)MGUI_FUNC_TABLE)[15] // Índice da função
; #define LoadIconLib ((LoadIconLibType *)(unsigned long)MGUI_FUNC_TABLE)[16] // Índice da função
; #define waitButton ((waitButtonType *)(unsigned long)MGUI_FUNC_TABLE)[17] // Índice da função
; #define message ((messageType *)(unsigned long)MGUI_FUNC_TABLE)[18] // Índice da função
; #define drawButtonsnew ((drawButtonsnewType *)(unsigned long)MGUI_FUNC_TABLE)[19] // Índice da função
; #define showWindow ((showWindowType *)(unsigned long)MGUI_FUNC_TABLE)[20] // Índice da função
; #define TrocaSpriteMouse ((TrocaSpriteMouseType *)(unsigned long)MGUI_FUNC_TABLE)[21] // Índice da função
; #define MostraIcone ((MostraIconeType *)(unsigned long)MGUI_FUNC_TABLE)[22] // Índice da função
; #define mguiCfgGet ((mguiCfgGetType *)(unsigned long)MGUI_FUNC_TABLE)[23] // Índice da função
; #define putImagePbmP4 ((putImagePbmP4Type *)(unsigned long)MGUI_FUNC_TABLE)[24] // Índice da função
; #define setPosPressed ((setPosPressedType *)(unsigned long)MGUI_FUNC_TABLE)[25] // Índice da função
; #define getMouseData ((getMouseDataType *)(unsigned long)MGUI_FUNC_TABLE)[26] // Índice da função
; #define togglebox ((toggleboxType *)(unsigned long)MGUI_FUNC_TABLE)[27] // Índice da função
; #define radioset ((radiosetType *)(unsigned long)MGUI_FUNC_TABLE)[28] // Índice da função
; #define fillin ((fillinType *)(unsigned long)MGUI_FUNC_TABLE)[29] // Índice da função
; #define getColorData ((getColorDataType *)(unsigned long)MGUI_FUNC_TABLE)[30] // Índice da função
; #define button ((buttonType *)(unsigned long)MGUI_FUNC_TABLE)[31] // Índice da função
; const unsigned char strValidChars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^&'@{}[],$=!-#()%.+~_";
; const unsigned char vmesc[12][3] = {{'J','a','n'},{'F','e','b'},{'M','a','r'},
; {'A','p','r'},{'M','a','y'},{'J','u','n'},
; {'J','u','l'},{'A','u','g'},{'S','e','p'},
; {'O','c','t'},{'N','o','v'},{'D','e','c'}};
; //---------------------------------------------------------------------------------------------
; // Retorna a posicao de memoria da proxima variavel com base no tamanho da variavel anterior
; //          pMemInic : Posicao da Memoria Total Alocada com malloc
; //          pSizeAlloc : Atual tamanho já allocado das variaveis. Retorna nela mesma atualizada
; //          pSizeOff : tanaho, sizeof, da variavel anterior
; //---------------------------------------------------------------------------------------------
; unsigned long vRetAlloc(unsigned long pMemInic, unsigned long *pSizeAlloc, unsigned long pSizeOf)
; {
       section   code
       xdef      _vRetAlloc
_vRetAlloc:
       link      A6,#0
; *pSizeAlloc = *pSizeAlloc + pSizeOf;
       move.l    12(A6),A0
       move.l    16(A6),D0
       add.l     D0,(A0)
; return (pMemInic + *pSizeAlloc);
       move.l    8(A6),D0
       move.l    12(A6),A0
       add.l     (A0),D0
       unlk      A6
       rts
; /*------------------------------------------------------------------------------
; * MMSJ320API.H - Arquivo de Header do MMSJ320
; * Author: Moacir Silveira Junior (moacir.silveira@gmail.com)
; * Date: 10/01/2025
; *------------------------------------------------------------------------------*/
; // Alternate definitions
; //typedef void                    VOID;
; //typedef char                    CHAR;
; //typedef unsigned char           BYTE;                           /* 8-bit unsigned  */
; //typedef unsigned short          WORD;                           /* 16-bit unsigned */
; //typedef unsigned long           DWORD;                          /* 32-bit unsigned */
; // Pointers to I/O devices
; unsigned char *vdsk  = 0x00200000; // DISK Arduino Uno, r/w
; /********************************************************************************
; *    Programa    : note.c
; *    Objetivo    : Visualizador de Texto Simples para MMSJOS com MGUI
; *    Criado em   : 26/04/2026
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 26/04/2026  0.1     Moacir Jr.   Criacao - Visualizacao somente, scroll mouse/teclado
; *--------------------------------------------------------------------------------
; *
; * Uso: chamar com paramBasic = nome do arquivo a abrir
; *
; * Teclas:
; *   Cursor Cima    (0x11) : Rola texto para cima  1 linha
; *   Cursor Baixo   (0x13) : Rola texto para baixo 1 linha
; *   Cursor Esquerda(0x12) : Rola texto para esquerda 1 coluna
; *   Cursor Direita (0x14) : Rola texto para direita  1 coluna
; *   ESC            (0x1B) : Fecha o visualizador
; *
; * Mouse:
; *   Clique na barra de rolagem vertical : pula para a posicao proporcional
; *   Clique no botao Close               : fecha o visualizador
; ********************************************************************************/
; #include <ctype.h>
; #include <string.h>
; #include <stdlib.h>
; #include "../mmsj320vdp.h"
; #include "../mmsj320mfp.h"
; #include "../monitor.h"
; #include "../mmsjos.h"
; #include "../mgui.h"
; #include "../monitorapi.h"
; #include "../mmsjosapi.h"
; #include "../mmsj320api.h"
; #include "note.h"
; //-----------------------------------------------------------------------------
; // Principal
; //-----------------------------------------------------------------------------
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-64
; MGUI_SAVESCR windowScr;
; MGUI_MOUSE mouseData;
; VDP_COLOR vdpcolor;
; unsigned char vcont, vtec;
; unsigned short thumbY, thumbH, trackH, range;
; unsigned short clickLine;
; unsigned long vMemLines;
; unsigned long voffset, vch;
; unsigned long vsizefile;
; unsigned short vReadSize;
; unsigned short vReadOff;
; buttonType pButton;
; // --- Atribuicao de ponteiros de funcao locais ---
; drawNote        = drawNoteDef;
       lea       _drawNoteDef(PC),A0
       lea       _drawNoteDef(A5),A0
       move.l    A5,A1
       add.l     #_drawNote,A1
       move.l    A0,(A1)
; displayNotePage = displayNotePageDef;
       lea       _displayNotePageDef(PC),A0
       lea       _displayNotePageDef(A5),A0
       move.l    A5,A1
       add.l     #_displayNotePage,A1
       move.l    A0,(A1)
; drawScrollBar   = drawScrollBarDef;
       lea       _drawScrollBarDef(PC),A0
       lea       _drawScrollBarDef(A5),A0
       move.l    A5,A1
       add.l     #_drawScrollBar,A1
       move.l    A0,(A1)
; nmystrcpy       = strcpy;
       lea       _strcpy(PC),A0
       lea       _strcpy(A5),A0
       move.l    A5,A1
       add.l     #_nmystrcpy,A1
       move.l    A0,(A1)
; nmymemset       = memset;
       lea       _memset(PC),A0
       lea       _memset(A5),A0
       move.l    A5,A1
       add.l     #_nmymemset,A1
       move.l    A0,(A1)
; nmyitoa         = itoa;
       lea       _itoa(PC),A0
       lea       _itoa(A5),A0
       move.l    A5,A1
       add.l     #_nmyitoa,A1
       move.l    A0,(A1)
; pButton         = button;
       move.l    8410610,-4(A6)
; // --- Inicializa variaveis ---
; getColorData(&vdpcolor);
       pea       -38(A6)
       move.l    8410606,A0
       jsr       (A0)
       addq.w    #4,A7
; nvcorfg = vdpcolor.fg;
       lea       -38(A6),A0
       move.l    A5,A1
       add.l     #_nvcorfg,A1
       move.b    (A0),(A1)
; nvcorbg = vdpcolor.bg;
       lea       -38(A6),A0
       move.l    A5,A1
       add.l     #_nvcorbg,A1
       move.b    1(A0),(A1)
; noteTopLine   = 0;
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       clr.w     (A0)
; noteHOffset   = 0;
       move.l    A5,A0
       add.l     #_noteHOffset,A0
       clr.w     (A0)
; noteLineCount = 0;
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       clr.w     (A0)
; noteTextBuf   = 0;
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       clr.l     (A0)
; noteLines     = 0;
       move.l    A5,A0
       add.l     #_noteLines,A0
       clr.l     (A0)
; noteBufSize   = 0;
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       clr.l     (A0)
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; SaveScreenNew(&windowScr, 0, 0, 255, 191);
       pea       191
       pea       255
       clr.l     -(A7)
       clr.l     -(A7)
       pea       -64(A6)
       move.l    8410498,A0
       jsr       (A0)
       add.w     #20,A7
; // --- Carrega o arquivo indicado em paramBasic ---
; if (*paramBasic != 0x00)
       move.l    A5,A0
       add.l     #_paramBasic,A0
       move.l    (A0),A0
       move.b    (A0),D0
       beq       main_7
; {
; vsizefile = fsInfoFile(paramBasic, INFO_SIZE);
       pea       1
       move.l    A5,A0
       add.l     #_paramBasic,A0
       move.l    (A0),-(A7)
       move.l    8388698,A0
       jsr       (A0)
       addq.w    #8,A7
       move.l    D0,-12(A6)
; if (vsizefile > 0 && vsizefile != ERRO_D_NOT_FOUND)
       move.l    -12(A6),D0
       cmp.l     #0,D0
       bls       main_7
       move.l    -12(A6),D0
       cmp.l     #-1,D0
       beq       main_7
; {
; // Limita a 32KB para seguranca
; if (vsizefile > 32768)
       move.l    -12(A6),D0
       cmp.l     #32768,D0
       bls.s     main_5
; vsizefile = 32768;
       move.l    #32768,-12(A6)
main_5:
; noteBufSize = vsizefile;
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    -12(A6),(A0)
; noteTextBuf = fsMalloc(noteBufSize + 1);
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    (A0),D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       move.l    8388746,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       move.l    D0,(A0)
; if (noteTextBuf)
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       tst.l     (A0)
       beq       main_7
; {
; // Le o arquivo em blocos de 512 bytes
; voffset = 0;
       clr.l     -20(A6)
; while (voffset < noteBufSize)
main_9:
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    -20(A6),D0
       cmp.l     (A0),D0
       bhs       main_11
; {
; vReadSize = 512;
       move.w    #512,-8(A6)
; if (voffset + vReadSize > noteBufSize)
       move.l    -20(A6),D0
       move.w    -8(A6),D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       cmp.l     (A0),D0
       bls.s     main_12
; vReadSize = (unsigned short)(noteBufSize - voffset);
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    (A0),D0
       sub.l     -20(A6),D0
       move.w    D0,-8(A6)
main_12:
; fsReadFile(paramBasic, voffset, noteTextBuf + voffset, vReadSize);
       move.w    -8(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       move.l    (A0),D1
       add.l     -20(A6),D1
       move.l    D1,-(A7)
       move.l    -20(A6),-(A7)
       move.l    A5,A0
       add.l     #_paramBasic,A0
       move.l    (A0),-(A7)
       move.l    8388706,A0
       jsr       (A0)
       add.w     #16,A7
; voffset = voffset + vReadSize;
       move.w    -8(A6),D0
       and.l     #65535,D0
       add.l     D0,-20(A6)
       bra       main_9
main_11:
; }
; // Garante terminador nulo
; *(noteTextBuf + noteBufSize) = 0x00;
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_noteBufSize,A1
       move.l    (A1),D0
       clr.b     0(A0,D0.L)
main_7:
; }
; }
; }
; // --- Aloca array de indices de linhas ---
; vMemLines = fsMalloc(NOTE_MAX_LINES * 4);   // 4 bytes por unsigned long no M68K
       pea       2000
       move.l    8388746,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    D0,-24(A6)
; noteLines = vMemLines;
       move.l    A5,A0
       add.l     #_noteLines,A0
       move.l    -24(A6),(A0)
; // --- Indexa as linhas do arquivo ---
; if (noteTextBuf && noteLines && noteBufSize > 0)
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       tst.l     (A0)
       beq       main_18
       move.l    A5,A0
       add.l     #_noteLines,A0
       tst.l     (A0)
       beq       main_18
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    (A0),D0
       cmp.l     #0,D0
       bls       main_18
; {
; // Primeira linha comeca no offset 0
; noteLines[0] = 0;
       move.l    A5,A0
       add.l     #_noteLines,A0
       move.l    (A0),A0
       clr.l     (A0)
; noteLineCount = 1;
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    #1,(A0)
; voffset = 0;
       clr.l     -20(A6)
; while (voffset < noteBufSize && noteLineCount < NOTE_MAX_LINES)
main_16:
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    -20(A6),D0
       cmp.l     (A0),D0
       bhs       main_18
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       cmp.w     #500,D0
       bhs       main_18
; {
; vch = *(noteTextBuf + voffset);
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       move.l    (A0),A0
       move.l    -20(A6),D0
       move.b    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    D0,-16(A6)
; if (vch == 0x0A)        // LF (Unix)
       move.l    -16(A6),D0
       cmp.l     #10,D0
       bne       main_19
; {
; voffset++;
       addq.l    #1,-20(A6)
; if (voffset < noteBufSize)
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    -20(A6),D0
       cmp.l     (A0),D0
       bhs.s     main_21
; {
; noteLines[noteLineCount] = voffset;
       move.l    A5,A0
       add.l     #_noteLines,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_noteLineCount,A1
       move.w    (A1),D0
       and.l     #65535,D0
       lsl.l     #2,D0
       move.l    -20(A6),0(A0,D0.L)
; noteLineCount++;
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       addq.w    #1,(A0)
main_21:
       bra       main_24
main_19:
; }
; }
; else if (vch == 0x0D)   // CR (Mac) ou CR+LF (Windows)
       move.l    -16(A6),D0
       cmp.l     #13,D0
       bne       main_23
; {
; voffset++;
       addq.l    #1,-20(A6)
; if (voffset < noteBufSize && *(noteTextBuf + voffset) == 0x0A)
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    -20(A6),D0
       cmp.l     (A0),D0
       bhs.s     main_25
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       move.l    (A0),A0
       move.l    -20(A6),D0
       move.b    0(A0,D0.L),D0
       cmp.b     #10,D0
       bne.s     main_25
; voffset++;      // Consome o LF do par CR+LF
       addq.l    #1,-20(A6)
main_25:
; if (voffset < noteBufSize)
       move.l    A5,A0
       add.l     #_noteBufSize,A0
       move.l    -20(A6),D0
       cmp.l     (A0),D0
       bhs.s     main_27
; {
; noteLines[noteLineCount] = voffset;
       move.l    A5,A0
       add.l     #_noteLines,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_noteLineCount,A1
       move.w    (A1),D0
       and.l     #65535,D0
       lsl.l     #2,D0
       move.l    -20(A6),0(A0,D0.L)
; noteLineCount++;
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       addq.w    #1,(A0)
main_27:
       bra.s     main_24
main_23:
; }
; }
; else
; {
; voffset++;
       addq.l    #1,-20(A6)
main_24:
       bra       main_16
main_18:
; }
; }
; }
; // --- Desenha janela inicial ---
; drawNote();
       move.l    A5,A0
       add.l     #_drawNote,A0
       move.l    (A0),A0
       jsr       (A0)
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; // --- Loop Principal ---
; vcont = 1;
       move.b    #1,-36(A6)
; while (vcont)
main_29:
       tst.b     -36(A6)
       beq       main_31
; {
; setPosPressed(0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8410586,A0
       jsr       (A0)
       addq.w    #8,A7
; while (1)
main_32:
; {
; getMouseData(&mouseData);
       pea       -44(A6)
       move.l    8410590,A0
       jsr       (A0)
       addq.w    #4,A7
; vtec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,-35(A6)
; // --- Tratamento de Teclado ---
; if (vtec == 0x1B)               // ESC: fecha
       move.b    -35(A6),D0
       cmp.b     #27,D0
       bne.s     main_35
; {
; vcont = 0;
       clr.b     -36(A6)
; break;
       bra       main_34
main_35:
; }
; else if (vtec == 0x11)          // Cursor Cima: rola 1 linha para cima
       move.b    -35(A6),D0
       cmp.b     #17,D0
       bne       main_37
; {
; if (noteTopLine > 0)
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       move.w    (A0),D0
       cmp.w     #0,D0
       bls.s     main_39
; {
; noteTopLine--;
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       subq.w    #1,(A0)
; displayNotePage();
       move.l    A5,A0
       add.l     #_displayNotePage,A0
       move.l    (A0),A0
       jsr       (A0)
; drawScrollBar();
       move.l    A5,A0
       add.l     #_drawScrollBar,A0
       move.l    (A0),A0
       jsr       (A0)
main_39:
       bra       main_49
main_37:
; }
; }
; else if (vtec == 0x13)          // Cursor Baixo: rola 1 linha para baixo
       move.b    -35(A6),D0
       cmp.b     #19,D0
       bne       main_41
; {
; if (noteLineCount > NOTE_VISIBLE &&
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       cmp.w     #15,D0
       bls       main_43
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       move.l    A5,A1
       add.l     #_noteLineCount,A1
       move.w    (A1),D0
       sub.w     #15,D0
       cmp.w     (A0),D0
       bls.s     main_43
; noteTopLine < noteLineCount - NOTE_VISIBLE)
; {
; noteTopLine++;
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       addq.w    #1,(A0)
; displayNotePage();
       move.l    A5,A0
       add.l     #_displayNotePage,A0
       move.l    (A0),A0
       jsr       (A0)
; drawScrollBar();
       move.l    A5,A0
       add.l     #_drawScrollBar,A0
       move.l    (A0),A0
       jsr       (A0)
main_43:
       bra       main_49
main_41:
; }
; }
; else if (vtec == 0x12)          // Cursor Esquerda: rola 1 coluna para esquerda
       move.b    -35(A6),D0
       cmp.b     #18,D0
       bne.s     main_45
; {
; if (noteHOffset > 0)
       move.l    A5,A0
       add.l     #_noteHOffset,A0
       move.w    (A0),D0
       cmp.w     #0,D0
       bls.s     main_47
; {
; noteHOffset--;
       move.l    A5,A0
       add.l     #_noteHOffset,A0
       subq.w    #1,(A0)
; displayNotePage();
       move.l    A5,A0
       add.l     #_displayNotePage,A0
       move.l    (A0),A0
       jsr       (A0)
main_47:
       bra.s     main_49
main_45:
; }
; }
; else if (vtec == 0x14)          // Cursor Direita: rola 1 coluna para direita
       move.b    -35(A6),D0
       cmp.b     #20,D0
       bne.s     main_49
; {
; noteHOffset++;
       move.l    A5,A0
       add.l     #_noteHOffset,A0
       addq.w    #1,(A0)
; displayNotePage();
       move.l    A5,A0
       add.l     #_displayNotePage,A0
       move.l    (A0),A0
       jsr       (A0)
main_49:
; }
; // --- Tratamento de Mouse ---
; if (mouseData.mouseButton == 0x01)   // Botao esquerdo
       lea       -44(A6),A0
       move.b    (A0),D0
       cmp.b     #1,D0
       bne       main_55
; {
; // Clique no botao Close
; if (mouseData.vpostx >= NOTE_CLOSE_X &&
       lea       -44(A6),A0
       move.b    4(A0),D0
       cmp.b     #100,D0
       blo       main_53
       lea       -44(A6),A0
       move.b    4(A0),D0
       cmp.b     #156,D0
       bhi.s     main_53
       lea       -44(A6),A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #178,D0
       blo.s     main_53
       lea       -44(A6),A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #188,D0
       bhi.s     main_53
; mouseData.vpostx <= NOTE_CLOSE_X + NOTE_CLOSE_W &&
; mouseData.vposty >= NOTE_CLOSE_Y &&
; mouseData.vposty <= NOTE_CLOSE_Y + NOTE_CLOSE_H)
; {
; vcont = 0;
       clr.b     -36(A6)
; break;
       bra       main_34
main_53:
; }
; // Clique na barra de rolagem vertical
; if (mouseData.vpostx >= NOTE_SCRL_X &&
       lea       -44(A6),A0
       move.b    4(A0),D0
       and.w     #255,D0
       cmp.w     #246,D0
       blo       main_55
       lea       -44(A6),A0
       move.b    4(A0),D0
       and.w     #255,D0
       cmp.w     #253,D0
       bhi       main_55
       lea       -44(A6),A0
       move.b    5(A0),D0
       cmp.b     #15,D0
       blo       main_55
       lea       -44(A6),A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #165,D0
       bhi       main_55
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       cmp.w     #15,D0
       bls       main_55
; mouseData.vpostx <= NOTE_SCRL_X + NOTE_SCRL_W &&
; mouseData.vposty >= NOTE_SCRL_Y &&
; mouseData.vposty <= NOTE_SCRL_Y + NOTE_SCRL_H &&
; noteLineCount > NOTE_VISIBLE)
; {
; // Mapeia a posicao do click para o numero de linha
; range = noteLineCount - NOTE_VISIBLE;
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       sub.w     #15,D0
       move.w    D0,-28(A6)
; clickLine = (unsigned short)(
       lea       -44(A6),A0
       move.b    5(A0),D0
       sub.b     #15,D0
       and.l     #255,D0
       move.w    -28(A6),D1
       and.l     #65535,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-(A7)
       pea       150
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,-26(A6)
; (unsigned long)(mouseData.vposty - NOTE_SCRL_Y) * range / NOTE_SCRL_H
; );
; if (clickLine >= noteLineCount - NOTE_VISIBLE)
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       sub.w     #15,D0
       cmp.w     -26(A6),D0
       bhi.s     main_57
; clickLine = noteLineCount - NOTE_VISIBLE - 1;
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       sub.w     #15,D0
       subq.w    #1,D0
       move.w    D0,-26(A6)
main_57:
; noteTopLine = clickLine;
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       move.w    -26(A6),(A0)
; displayNotePage();
       move.l    A5,A0
       add.l     #_displayNotePage,A0
       move.l    (A0),A0
       jsr       (A0)
; drawScrollBar();
       move.l    A5,A0
       add.l     #_drawScrollBar,A0
       move.l    (A0),A0
       jsr       (A0)
main_55:
; }
; }
; OSTimeDlyHMSM(0, 0, 0, 50);
       pea       50
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8388738,A0
       jsr       (A0)
       add.w     #16,A7
       bra       main_32
main_34:
; } // while(1) inner
; if (vcont)
       tst.b     -36(A6)
       beq.s     main_59
; OSTimeDlyHMSM(0, 0, 0, 50);
       pea       50
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8388738,A0
       jsr       (A0)
       add.w     #16,A7
main_59:
       bra       main_29
main_31:
; } // while(vcont)
; // --- Encerra ---
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; if (noteLines)
       move.l    A5,A0
       add.l     #_noteLines,A0
       tst.l     (A0)
       beq.s     main_61
; fsFree((unsigned long)noteLines);
       move.l    A5,A0
       add.l     #_noteLines,A0
       move.l    (A0),-(A7)
       move.l    8388702,A0
       jsr       (A0)
       addq.w    #4,A7
main_61:
; if (noteTextBuf)
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       tst.l     (A0)
       beq.s     main_63
; fsFree((unsigned long)noteTextBuf);
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       move.l    (A0),-(A7)
       move.l    8388702,A0
       jsr       (A0)
       addq.w    #4,A7
main_63:
; RestoreScreen(windowScr);
       lea       -64(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       move.l    8410502,A0
       jsr       (A0)
       add.w     #20,A7
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Desenha a janela completa (titulo, area de texto, botao, scrollbar)
; //-----------------------------------------------------------------------------
; void drawNoteDef(void)
; {
       xdef      _drawNoteDef
_drawNoteDef:
       link      A6,#-44
; unsigned char titleBuf[32];
; unsigned char *pParam;
; unsigned char ix;
; buttonType pButton;
; pButton = button;
       move.l    8410610,-4(A6)
; // Janela cheia
; showWindow("Note Viewer v0.1\0", 0, 0, 255, 191, BTNONE);
       clr.l     -(A7)
       pea       191
       pea       255
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #@note_1,A0
       move.l    A0,-(A7)
       move.l    8410566,A0
       jsr       (A0)
       add.w     #24,A7
; // Linha separadora acima do botao
; DrawLine(0, NOTE_CLOSE_Y - 4, 255, NOTE_CLOSE_Y - 4, nvcorfg);
       move.l    A5,A0
       add.l     #_nvcorfg,A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       174
       pea       255
       pea       174
       clr.l     -(A7)
       move.l    8410518,A0
       jsr       (A0)
       add.w     #20,A7
; // Botao Close
; pButton("Close", NOTE_CLOSE_X, NOTE_CLOSE_Y, NOTE_CLOSE_W, NOTE_CLOSE_H, WINDISP);
       clr.l     -(A7)
       pea       10
       pea       56
       pea       178
       pea       100
       move.l    A5,A0
       add.l     #@note_2,A0
       move.l    (A0),-(A7)
       move.l    -4(A6),A0
       jsr       (A0)
       add.w     #24,A7
; // Se nao ha arquivo, exibe mensagem na area de texto
; if (!noteTextBuf || noteLineCount == 0)
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       tst.l     (A0)
       beq.s     drawNoteDef_3
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       bne.s     drawNoteDef_4
       moveq     #1,D0
       bra.s     drawNoteDef_5
drawNoteDef_4:
       clr.l     D0
drawNoteDef_5:
       and.l     #65535,D0
       beq       drawNoteDef_1
drawNoteDef_3:
; {
; writesxy(NOTE_TEXT_X, NOTE_Y_TEXT + 20, 8, "No file to display.\0", nvcorfg, nvcorbg);
       move.l    A5,A0
       add.l     #_nvcorbg,A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_nvcorfg,A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@note_3,A0
       move.l    A0,-(A7)
       pea       8
       pea       35
       pea       3
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; return;
       bra.s     drawNoteDef_6
drawNoteDef_1:
; }
; // Exibe conteudo e scrollbar
; displayNotePage();
       move.l    A5,A0
       add.l     #_displayNotePage,A0
       move.l    (A0),A0
       jsr       (A0)
; drawScrollBar();
       move.l    A5,A0
       add.l     #_drawScrollBar,A0
       move.l    (A0),A0
       jsr       (A0)
drawNoteDef_6:
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Exibe as linhas visiveis a partir de noteTopLine com offset noteHOffset
; //-----------------------------------------------------------------------------
; void displayNotePageDef(void)
; {
       xdef      _displayNotePageDef
_displayNotePageDef:
       link      A6,#-60
; unsigned char linebuf[42];  // NOTE_CHARS_LINE + 2 de margem
; unsigned char *p;
; unsigned char vch;
; unsigned short line, col, ly;
; unsigned long lpos;
; // Limpa area de texto (sem tocar a scrollbar)
; FillRect(0, NOTE_Y_TEXT, NOTE_SCRL_X - 1, NOTE_VISIBLE * NOTE_LINE_H, nvcorbg);
       move.l    A5,A0
       add.l     #_nvcorbg,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       150
       pea       245
       pea       15
       clr.l     -(A7)
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; if (!noteTextBuf || noteLineCount == 0)
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       tst.l     (A0)
       beq.s     displayNotePageDef_3
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       bne.s     displayNotePageDef_4
       moveq     #1,D0
       bra.s     displayNotePageDef_5
displayNotePageDef_4:
       clr.l     D0
displayNotePageDef_5:
       and.l     #65535,D0
       beq.s     displayNotePageDef_1
displayNotePageDef_3:
; return;
       bra       displayNotePageDef_9
displayNotePageDef_1:
; for (line = 0; line < NOTE_VISIBLE; line++)
       clr.w     -10(A6)
displayNotePageDef_7:
       move.w    -10(A6),D0
       cmp.w     #15,D0
       bhs       displayNotePageDef_9
; {
; ly = NOTE_Y_TEXT + (line * NOTE_LINE_H);
       moveq     #15,D0
       ext.w     D0
       move.w    -10(A6),D1
       mulu.w    #10,D1
       add.w     D1,D0
       move.w    D0,-6(A6)
; if ((noteTopLine + line) >= noteLineCount)
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       move.w    (A0),D0
       add.w     -10(A6),D0
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       cmp.w     (A0),D0
       blo.s     displayNotePageDef_10
; break;
       bra       displayNotePageDef_9
displayNotePageDef_10:
; // Ponteiro para inicio desta linha no buffer
; lpos = noteLines[noteTopLine + line];
       move.l    A5,A0
       add.l     #_noteLines,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_noteTopLine,A1
       move.w    (A1),D0
       and.l     #65535,D0
       move.w    -10(A6),D1
       and.l     #65535,D1
       add.l     D1,D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),-4(A6)
; p    = noteTextBuf + lpos;
       move.l    A5,A0
       add.l     #_noteTextBuf,A0
       move.l    (A0),D0
       add.l     -4(A6),D0
       move.l    D0,-16(A6)
; // Avanca noteHOffset colunas (scroll horizontal)
; col = 0;
       clr.w     -8(A6)
; while (col < noteHOffset)
displayNotePageDef_12:
       move.l    A5,A0
       add.l     #_noteHOffset,A0
       move.w    -8(A6),D0
       cmp.w     (A0),D0
       bhs       displayNotePageDef_14
; {
; vch = *p;
       move.l    -16(A6),A0
       move.b    (A0),-11(A6)
; if (!vch || vch == 0x0A || vch == 0x0D)
       tst.b     -11(A6)
       bne.s     displayNotePageDef_18
       moveq     #1,D0
       bra.s     displayNotePageDef_19
displayNotePageDef_18:
       clr.l     D0
displayNotePageDef_19:
       and.l     #255,D0
       bne.s     displayNotePageDef_17
       move.b    -11(A6),D0
       cmp.b     #10,D0
       beq.s     displayNotePageDef_17
       move.b    -11(A6),D0
       cmp.b     #13,D0
       bne.s     displayNotePageDef_15
displayNotePageDef_17:
; break;
       bra.s     displayNotePageDef_14
displayNotePageDef_15:
; col++;
       addq.w    #1,-8(A6)
; p++;
       addq.l    #1,-16(A6)
       bra       displayNotePageDef_12
displayNotePageDef_14:
; }
; // Copia ate NOTE_CHARS_LINE caracteres para o buffer de linha
; col = 0;
       clr.w     -8(A6)
; while (col < NOTE_CHARS_LINE)
displayNotePageDef_20:
       move.w    -8(A6),D0
       cmp.w     #39,D0
       bhs       displayNotePageDef_22
; {
; vch = *p;
       move.l    -16(A6),A0
       move.b    (A0),-11(A6)
; if (!vch || vch == 0x0A || vch == 0x0D)
       tst.b     -11(A6)
       bne.s     displayNotePageDef_26
       moveq     #1,D0
       bra.s     displayNotePageDef_27
displayNotePageDef_26:
       clr.l     D0
displayNotePageDef_27:
       and.l     #255,D0
       bne.s     displayNotePageDef_25
       move.b    -11(A6),D0
       cmp.b     #10,D0
       beq.s     displayNotePageDef_25
       move.b    -11(A6),D0
       cmp.b     #13,D0
       bne.s     displayNotePageDef_23
displayNotePageDef_25:
; break;
       bra       displayNotePageDef_22
displayNotePageDef_23:
; if (vch == 0x09)            // TAB -> espaco
       move.b    -11(A6),D0
       cmp.b     #9,D0
       bne.s     displayNotePageDef_28
; vch = 0x20;
       move.b    #32,-11(A6)
       bra.s     displayNotePageDef_30
displayNotePageDef_28:
; else if (vch < 0x20 || vch >= 0x7F)
       move.b    -11(A6),D0
       cmp.b     #32,D0
       blo.s     displayNotePageDef_32
       move.b    -11(A6),D0
       cmp.b     #127,D0
       blo.s     displayNotePageDef_30
displayNotePageDef_32:
; vch = 0x20;             // Nao imprimivel -> espaco
       move.b    #32,-11(A6)
displayNotePageDef_30:
; linebuf[col] = vch;
       move.w    -8(A6),D0
       and.l     #65535,D0
       move.b    -11(A6),-58(A6,D0.L)
; col++;
       addq.w    #1,-8(A6)
; p++;
       addq.l    #1,-16(A6)
       bra       displayNotePageDef_20
displayNotePageDef_22:
; }
; linebuf[col] = 0x00;
       move.w    -8(A6),D0
       and.l     #65535,D0
       clr.b     -58(A6,D0.L)
; if (col > 0)
       move.w    -8(A6),D0
       cmp.w     #0,D0
       bls       displayNotePageDef_33
; writesxy(NOTE_TEXT_X, ly, 8, linebuf, nvcorfg, nvcorbg);
       move.l    A5,A0
       add.l     #_nvcorbg,A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_nvcorfg,A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -58(A6)
       pea       8
       move.w    -6(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       3
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
displayNotePageDef_33:
       addq.w    #1,-10(A6)
       bra       displayNotePageDef_7
displayNotePageDef_9:
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // Desenha a barra de rolagem vertical com indicador de posicao (thumb)
; //-----------------------------------------------------------------------------
; void drawScrollBarDef(void)
; {
       xdef      _drawScrollBarDef
_drawScrollBarDef:
       link      A6,#-12
; unsigned short thumbY, thumbH;
; unsigned short range;
; unsigned long ltmp;
; // Trilha da barra de rolagem
; FillRect(NOTE_SCRL_X, NOTE_SCRL_Y, NOTE_SCRL_W, NOTE_SCRL_H, nvcorbg);
       move.l    A5,A0
       add.l     #_nvcorbg,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       150
       pea       7
       pea       15
       pea       246
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; DrawRect(NOTE_SCRL_X, NOTE_SCRL_Y, NOTE_SCRL_W, NOTE_SCRL_H, nvcorfg);
       move.l    A5,A0
       add.l     #_nvcorfg,A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       150
       pea       7
       pea       15
       pea       246
       move.l    8410522,A0
       jsr       (A0)
       add.w     #20,A7
; // Sem scrollbar se todo o conteudo e visivel
; if (noteLineCount <= NOTE_VISIBLE)
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       cmp.w     #15,D0
       bhi.s     drawScrollBarDef_1
; return;
       bra       drawScrollBarDef_3
drawScrollBarDef_1:
; range = noteLineCount - NOTE_VISIBLE;
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       move.w    (A0),D0
       sub.w     #15,D0
       move.w    D0,-6(A6)
; // --- Calcula altura do thumb ---
; thumbH = NOTE_VISIBLE * NOTE_SCRL_H / noteLineCount;
       move.w    #2250,D0
       move.l    A5,A0
       add.l     #_noteLineCount,A0
       and.l     #65535,D0
       divu.w    (A0),D0
       move.w    D0,-8(A6)
; if (thumbH < 8)
       move.w    -8(A6),D0
       cmp.w     #8,D0
       bhs.s     drawScrollBarDef_4
; thumbH = 8;
       move.w    #8,-8(A6)
drawScrollBarDef_4:
; if (thumbH > NOTE_SCRL_H)
       move.w    -8(A6),D0
       cmp.w     #150,D0
       bls.s     drawScrollBarDef_6
; thumbH = NOTE_SCRL_H;
       move.w    #150,-8(A6)
drawScrollBarDef_6:
; // --- Calcula posicao Y do thumb ---
; ltmp   = noteTopLine;
       move.l    A5,A0
       add.l     #_noteTopLine,A0
       move.w    (A0),D0
       and.l     #65535,D0
       move.l    D0,-4(A6)
; ltmp   = ltmp * (NOTE_SCRL_H - thumbH);
       move.w    #150,D0
       sub.w     -8(A6),D0
       and.l     #65535,D0
       move.l    -4(A6),-(A7)
       move.l    D0,-(A7)
       jsr       ULMUL
       move.l    (A7),-4(A6)
       addq.w    #8,A7
; ltmp   = ltmp / range;
       move.w    -6(A6),D0
       and.l     #65535,D0
       move.l    -4(A6),-(A7)
       move.l    D0,-(A7)
       jsr       ULDIV
       move.l    (A7),-4(A6)
       addq.w    #8,A7
; thumbY = NOTE_SCRL_Y + (unsigned short)ltmp;
       moveq     #15,D0
       ext.w     D0
       move.l    -4(A6),D1
       add.w     D1,D0
       move.w    D0,-10(A6)
; // Garante que nao ultrapassa o limite da trilha
; if (thumbY + thumbH > NOTE_SCRL_Y + NOTE_SCRL_H)
       move.w    -10(A6),D0
       add.w     -8(A6),D0
       cmp.w     #165,D0
       bls.s     drawScrollBarDef_8
; thumbY = NOTE_SCRL_Y + NOTE_SCRL_H - thumbH;
       move.w    #165,D0
       sub.w     -8(A6),D0
       move.w    D0,-10(A6)
drawScrollBarDef_8:
; // Desenha o thumb
; FillRect(NOTE_SCRL_X + 1, thumbY, NOTE_SCRL_W - 2, thumbH, nvcorfg);
       move.l    A5,A0
       add.l     #_nvcorfg,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    -8(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       5
       move.w    -10(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       247
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
drawScrollBarDef_3:
       unlk      A6
       rts
; }
       section   const
@note_1:
       dc.b      78,111,116,101,32,86,105,101,119,101,114,32
       dc.b      118,48,46,49,0
@note_2:
       dc.b      67,108,111,115,101,0
@note_3:
       dc.b      78,111,32,102,105,108,101,32,116,111,32,100
       dc.b      105,115,112,108,97,121,46,0
       xdef      _strValidChars
_strValidChars:
       dc.b      48,49,50,51,52,53,54,55,56,57,65,66,67,68,69
       dc.b      70,71,72,73,74,75,76,77,78,79,80,81,82,83,84
       dc.b      85,86,87,88,89,90,94,38,39,64,123,125,91,93
       dc.b      44,36,61,33,45,35,40,41,37,46,43,126,95,0
       section   data
       xdef      _vmesc
_vmesc:
       dc.b      74,97,110,70,101,98,77,97,114,65,112,114,77
       dc.b      97,121,74,117,110,74,117,108,65,117,103,83,101
       dc.b      112,79,99,116,78,111,118,68,101,99
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
       xdef      _reserved
_reserved:
       dc.l      6354876
       section   bss
       xdef      _noteTextBuf
_noteTextBuf:
       ds.b      4
       xdef      _noteBufSize
_noteBufSize:
       ds.b      4
       xdef      _noteLines
_noteLines:
       ds.b      4
       xdef      _noteLineCount
_noteLineCount:
       ds.b      2
       xdef      _noteTopLine
_noteTopLine:
       ds.b      2
       xdef      _noteHOffset
_noteHOffset:
       ds.b      2
       xdef      _nvcorfg
_nvcorfg:
       ds.b      1
       xdef      _nvcorbg
_nvcorbg:
       ds.b      1
       xdef      _drawNote
_drawNote:
       ds.b      4
       xdef      _displayNotePage
_displayNotePage:
       ds.b      4
       xdef      _drawScrollBar
_drawScrollBar:
       ds.b      4
       xdef      _nmystrcpy
_nmystrcpy:
       ds.b      4
       xdef      _nmymemset
_nmymemset:
       ds.b      4
       xdef      _nmyitoa
_nmyitoa:
       ds.b      4
       xref      _strcpy
       xref      _itoa
       xref      ULMUL
       xref      _memset
       xref      ULDIV
