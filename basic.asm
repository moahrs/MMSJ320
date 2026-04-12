; D:\PROJETOS\MMSJ320\PROGS\BASIC.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; #ifndef MMSJOSAPI_H
; #define MMSJOSAPI_H
; // Function Shared Definitions
; #define MMSJOS_FUNC_TABLE    0x00817F00
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
; typedef void (*fsSetMfpType)(unsigned int Config, unsigned char Value, unsigned char TypeSet);
; typedef unsigned int (*fsGetMfpType)(unsigned int Config);
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
; typedef void (*importFileType)(void);
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
; #define fsSetMfp ((fsSetMfpType *)(unsigned long)MMSJOS_FUNC_TABLE)[25] // Índice da função
; #define fsGetMfp ((fsGetMfpType *)(unsigned long)MMSJOS_FUNC_TABLE)[26] // Índice da função
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
; #define importFile ((importFileType *)(unsigned long)MGUI_FUNC_TABLE)[23] // Índice da função
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
; typedef struct  {
; /********************************************************************************
; *    Programa    : basic.c
; *    Objetivo    : MMSJ-xBasic para o MMSJ320 like MSX
; *    Criado em   : 26/03/2026
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 26/03/2026  0.1     Moacir Jr.   Conversão Basico Apple2 para MSX
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
; #include "../monitor.h"
; #include "../mmsjos.h"
; #include "../mgui.h"
; #include "../monitorapi.h"
; #include "../mmsjosapi.h"
; #include "basic.h"
; /*
; * In relocatable modules loaded via malloc, do not use Reg_* extern symbols
; * from mmsj320mfp.h. Pass literal MFP register offsets to OS API wrappers.
; */
; #define MFP_REG_TACR 0x19
; #define MFP_REG_TADR 0x1F
; #define versionBasic "0.1"
; //#define __TESTE_TOKENIZE__ 1
; //#define __DEBUG_ARRAYS__ 1
; //-----------------------------------------------------------------------------
; // Principal
; //-----------------------------------------------------------------------------
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-296
; unsigned char vRetInput;
; VDP_COLOR vdpcolor;
; unsigned char countTec = 0;
       clr.b     -289(A6)
; unsigned int mgui_pattern_table2 = 0;
       clr.l     -288(A6)
; unsigned int mgui_color_table2 = 0;
       clr.l     -284(A6)
; unsigned char vbufInput[256];
; unsigned char sqtdtam[20];
; unsigned long ix;
; // Timer para o Random
; fsSetMfp(MFP_REG_TADR, 0xF5, 1);  // 245
       pea       1
       pea       245
       pea       31
       move.l    8486756,A0
       jsr       (A0)
       add.w     #12,A7
; fsSetMfp(MFP_REG_TACR, 0x02, 1);  // prescaler de 10. total 2,4576Mhz/10*245 = 1003KHz
       pea       1
       pea       2
       pea       25
       move.l    8486756,A0
       jsr       (A0)
       add.w     #12,A7
; printText("Aqui 0 :-)\r\n\0");
       move.l    A5,A0
       add.l     #@basic_88,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_1:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_3
       addq.l    #1,-4(A6)
       bra       main_1
main_3:
; clearScrWPtr = MMSJOS_FUNC_RELOC[FILES_RELOC_CLRSCRW_DEF];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_clearScrWPtr,A1
       move.l    (A0),(A1)
; basTextPtr = MMSJOS_FUNC_RELOC[FILES_RELOC_BASTEXT_DEF];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_basTextPtr,A1
       move.l    4(A0),(A1)
; basTextPtr();
       move.l    A5,A0
       add.l     #_basTextPtr,A0
       move.l    (A0),A0
       jsr       (A0)
; printText("Aqui 1 :-)\r\n\0");
       move.l    A5,A0
       add.l     #@basic_89,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_4:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_6
       addq.l    #1,-4(A6)
       bra       main_4
main_6:
; vdp_get_cfg(&mgui_pattern_table2, &mgui_color_table2);
       pea       -284(A6)
       pea       -288(A6)
       move.l    1182,A0
       jsr       (A0)
       addq.w    #8,A7
; printText("Aqui 2 :-)\r\n\0");
       move.l    A5,A0
       add.l     #@basic_90,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_7:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_9
       addq.l    #1,-4(A6)
       bra       main_7
main_9:
; mgui_pattern_table = mgui_pattern_table2;
       move.l    A5,A0
       add.l     #_mgui_pattern_table,A0
       move.l    -288(A6),(A0)
; printText("Aqui 3 :-)\r\n\0");
       move.l    A5,A0
       add.l     #@basic_91,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_10:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_12
       addq.l    #1,-4(A6)
       bra       main_10
main_12:
; mgui_color_table = mgui_color_table2;
       move.l    A5,A0
       add.l     #_mgui_color_table,A0
       move.l    -284(A6),(A0)
; printText("Aqui 4 :-)\r\n\0");
       move.l    A5,A0
       add.l     #@basic_92,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_13:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_15
       addq.l    #1,-4(A6)
       bra       main_13
main_15:
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; printText("MMSJ-xBASIC v"versionBasic"\r\n\0");
       move.l    A5,A0
       add.l     #@basic_93,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_16:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_18
       addq.l    #1,-4(A6)
       bra       main_16
main_18:
; printText("Utility (c) 2026\r\n\0");
       move.l    A5,A0
       add.l     #@basic_94,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_19:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_21
       addq.l    #1,-4(A6)
       bra       main_19
main_21:
; printText("OK\r\n\0");
       move.l    A5,A0
       add.l     #@basic_95,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_22:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_24
       addq.l    #1,-4(A6)
       bra       main_22
main_24:
; pStartSimpVar = fsMalloc(8192);
       pea       8192
       move.l    8486744,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    D0,(A0)
; pStartArrayVar = fsMalloc(24576);
       pea       24576
       move.l    8486744,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    D0,(A0)
; pStartString = fsMalloc(32768);
       pea       32768
       move.l    8486744,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_pStartString,A0
       move.l    D0,(A0)
; pStartProg = fsMalloc(65536);
       pea       65536
       move.l    8486744,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    D0,(A0)
; pStartXBasLoad = fsMalloc(65536);
       pea       65536
       move.l    8486744,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_pStartXBasLoad,A0
       move.l    D0,(A0)
; pStartStack = fsMalloc(8192);
       pea       8192
       move.l    8486744,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_pStartStack,A0
       move.l    D0,(A0)
; printText("Aqui 5 :-)\r\n\0");
       move.l    A5,A0
       add.l     #@basic_96,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_25:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_27
       addq.l    #1,-4(A6)
       bra       main_25
main_27:
; vbufInput[0] = '\0';
       clr.b     -280+0(A6)
; *pProcess = 0x01;
       move.l    A5,A0
       add.l     #_pProcess,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; *pTypeLine = 0x00;
       move.l    A5,A0
       add.l     #_pTypeLine,A0
       move.l    (A0),A0
       clr.b     (A0)
; *nextAddrLine = pStartProg;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    A5,A1
       add.l     #_nextAddrLine,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *firstLineNumber = 0;
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       clr.w     (A0)
; *addrFirstLineNumber = 0;
       move.l    A5,A0
       add.l     #_addrFirstLineNumber,A0
       move.l    (A0),A0
       clr.l     (A0)
; *traceOn = 0;
       move.l    A5,A0
       add.l     #_traceOn,A0
       move.l    (A0),A0
       clr.b     (A0)
; *debugOn = 0;
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       clr.b     (A0)
; *lastHgrX = 0;
       move.l    A5,A0
       add.l     #_lastHgrX,A0
       move.l    (A0),A0
       clr.b     (A0)
; *lastHgrY = 0;
       move.l    A5,A0
       add.l     #_lastHgrY,A0
       move.l    (A0),A0
       clr.b     (A0)
; //vdpcolor = vdp_get_color();
; vdpcolor.fg = VDP_WHITE;
       lea       -292(A6),A0
       move.b    #15,(A0)
; vdpcolor.bg = VDP_BLACK;
       lea       -292(A6),A0
       move.b    #1,1(A0)
; vdpModeBas = VDP_MODE_TEXT; // Text
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    #3,(A0)
; fgcolorBasAnt = vdpcolor.fg;
       lea       -292(A6),A0
       move.l    A5,A1
       add.l     #_fgcolorBasAnt,A1
       move.b    (A0),(A1)
; bgcolorBasAnt = vdpcolor.bg;
       lea       -292(A6),A0
       move.l    A5,A1
       add.l     #_bgcolorBasAnt,A1
       move.b    1(A0),(A1)
; vdpMaxCols = 39;
       move.l    A5,A0
       add.l     #_vdpMaxCols,A0
       move.b    #39,(A0)
; vdpMaxRows = 23;
       move.l    A5,A0
       add.l     #_vdpMaxRows,A0
       move.b    #23,(A0)
; printText("Aqui 6 :-)\r\n\0");
       move.l    A5,A0
       add.l     #@basic_97,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0; ix < 100000; ix++); // Delay pra dar tempo de ler o timer
       clr.l     -4(A6)
main_28:
       move.l    -4(A6),D0
       cmp.l     #100000,D0
       bhs.s     main_30
       addq.l    #1,-4(A6)
       bra       main_28
main_30:
; while (*pProcess)
main_31:
       move.l    A5,A0
       add.l     #_pProcess,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq       main_33
; {
; vRetInput = inputLineBasic(&vbufInput, 128,'$');
       pea       36
       pea       128
       pea       -280(A6)
       jsr       _inputLineBasic
       add.w     #12,A7
       move.b    D0,-293(A6)
; if (vbufInput[0] != 0x00 && (vRetInput == 0x0D || vRetInput == 0x0A))
       move.b    -280+0(A6),D0
       beq       main_34
       move.b    -293(A6),D0
       cmp.b     #13,D0
       beq.s     main_36
       move.b    -293(A6),D0
       cmp.b     #10,D0
       bne       main_34
main_36:
; {
; printText("\r\n\0");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; processLine(&vbufInput);
       pea       -280(A6)
       jsr       _processLine
       addq.w    #4,A7
; if (!*pTypeLine && *pProcess)
       move.l    A5,A0
       add.l     #_pTypeLine,A0
       move.l    (A0),A0
       tst.b     (A0)
       bne.s     main_37
       move.l    A5,A0
       add.l     #_pProcess,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq.s     main_37
; printText("\r\nOK\0");
       move.l    A5,A0
       add.l     #@basic_99,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_37:
; if (!*pTypeLine && *pProcess)
       move.l    A5,A0
       add.l     #_pTypeLine,A0
       move.l    (A0),A0
       tst.b     (A0)
       bne.s     main_39
       move.l    A5,A0
       add.l     #_pProcess,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq.s     main_39
; printText("\r\n\0");   // printText("\r\n>\0");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_39:
       bra.s     main_41
main_34:
; }
; else if (vRetInput != 0x1B)
       move.b    -293(A6),D0
       cmp.b     #27,D0
       beq.s     main_41
; {
; printText("\r\n\0");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_41:
       bra       main_31
main_33:
; }
; }
; fsFree(pStartSimpVar);
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    (A0),-(A7)
       move.l    8486700,A0
       jsr       (A0)
       addq.w    #4,A7
; fsFree(pStartArrayVar);
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    (A0),-(A7)
       move.l    8486700,A0
       jsr       (A0)
       addq.w    #4,A7
; fsFree(pStartString);
       move.l    A5,A0
       add.l     #_pStartString,A0
       move.l    (A0),-(A7)
       move.l    8486700,A0
       jsr       (A0)
       addq.w    #4,A7
; fsFree(pStartProg);
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),-(A7)
       move.l    8486700,A0
       jsr       (A0)
       addq.w    #4,A7
; fsFree(pStartXBasLoad);
       move.l    A5,A0
       add.l     #_pStartXBasLoad,A0
       move.l    (A0),-(A7)
       move.l    8486700,A0
       jsr       (A0)
       addq.w    #4,A7
; fsFree(pStartStack);
       move.l    A5,A0
       add.l     #_pStartStack,A0
       move.l    (A0),-(A7)
       move.l    8486700,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // pQtdInput - Quantidade a ser digitada, min 1 max 255
; // pTipo - Tipo de entrada:
; //                  input : $ - String, % - Inteiro (sem ponto), # - Real (com ponto), @ - Sem Cursor e Qualquer Coisa e sem enter
; //                   edit : S - String, I - Inteiro (sem ponto), R - Real (com ponto)
; //-----------------------------------------------------------------------------
; unsigned char inputLineBasic(unsigned char *vbufInput, unsigned int pQtdInput, unsigned char pTipo)
; {
       xdef      _inputLineBasic
_inputLineBasic:
       link      A6,#-40
; unsigned char *vbufptr = vbufInput;
       move.l    8(A6),-38(A6)
; unsigned char vtec, vtecant;
; int vRetProcCmd, iw, ix;
; int countCursor = 0;
       clr.l     -20(A6)
; char pEdit = 0, pIns = 0, vbuftemp, vbuftemp2;
       clr.b     -16(A6)
       clr.b     -15(A6)
; int iPos = 0, iz = 0;
       clr.l     -12(A6)
       clr.l     -8(A6)
; unsigned short vantX, vantY;
; if (pQtdInput == 0)
       move.l    12(A6),D0
       bne.s     inputLineBasic_1
; pQtdInput = 512;
       move.l    #512,12(A6)
inputLineBasic_1:
; vtecant = 0x00;
       clr.b     -33(A6)
; vbufptr = vbufInput;
       move.l    8(A6),-38(A6)
; // Se for Linha editavel apresenta a linha na tela
; if (pTipo == 'S' || pTipo == 'I' || pTipo == 'R')
       move.b    19(A6),D0
       cmp.b     #83,D0
       beq.s     inputLineBasic_5
       move.b    19(A6),D0
       cmp.b     #73,D0
       beq.s     inputLineBasic_5
       move.b    19(A6),D0
       cmp.b     #82,D0
       bne       inputLineBasic_3
inputLineBasic_5:
; {
; // Apresenta a linha na tela, e posiciona o cursor na tela na primeira posicao valida
; iw = strlen(vbufInput) / 40;
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-(A7)
       pea       40
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-28(A6)
; printText(vbufInput);
       move.l    8(A6),-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; videoCursorPosRowY -= iw;
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.l    -28(A6),D0
       sub.w     D0,(A0)
; videoCursorPosColX = 0;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       clr.w     (A0)
; pEdit = 1;
       move.b    #1,-16(A6)
; iPos = 0;
       clr.l     -12(A6)
; pIns = 0xFF;
       move.b    #255,-15(A6)
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_3:
; }
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
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
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq       inputLineBasic_14
; {
; if (basVideoCursorShow)
       move.l    A5,A0
       add.l     #_basVideoCursorShow,A0
       tst.b     (A0)
       beq       inputLineBasic_13
; {
; switch (countCursor)
       move.l    -20(A6),D0
       cmp.l     #12000,D0
       beq       inputLineBasic_18
       bgt       inputLineBasic_16
       cmp.l     #6000,D0
       beq.s     inputLineBasic_17
       bra       inputLineBasic_16
inputLineBasic_17:
; {
; case 6000:
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
; if (pEdit)
       tst.b     -16(A6)
       beq.s     inputLineBasic_19
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.l    8(A6),A0
       move.l    -12(A6),D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_19:
; break;
       bra.s     inputLineBasic_16
inputLineBasic_18:
; case 12000:
; showCursor();
       move.l    1082,A0
       jsr       (A0)
; countCursor = 0;
       clr.l     -20(A6)
; break;
inputLineBasic_16:
; }
; countCursor++;
       addq.l    #1,-20(A6)
       bra.s     inputLineBasic_14
inputLineBasic_13:
; }
; else
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
inputLineBasic_14:
; }
; // Inicia leitura
; vtec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,-34(A6)
; if (pTipo == '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       bne.s     inputLineBasic_21
; return vtec;
       move.b    -34(A6),D0
       bra       inputLineBasic_23
inputLineBasic_21:
; // Se nao for string ($ e S) ou Tudo (@), só aceita numeros
; if (pTipo != '$' && pTipo != 'S' && pTipo != '@' && vtec != '.' && vtec > 0x1F && (vtec < 0x30 || vtec > 0x39))
       move.b    19(A6),D0
       cmp.b     #36,D0
       beq       inputLineBasic_24
       move.b    19(A6),D0
       cmp.b     #83,D0
       beq       inputLineBasic_24
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_24
       move.b    -34(A6),D0
       cmp.b     #46,D0
       beq.s     inputLineBasic_24
       move.b    -34(A6),D0
       cmp.b     #31,D0
       bls.s     inputLineBasic_24
       move.b    -34(A6),D0
       cmp.b     #48,D0
       blo.s     inputLineBasic_26
       move.b    -34(A6),D0
       cmp.b     #57,D0
       bls.s     inputLineBasic_24
inputLineBasic_26:
; vtec = 0;
       clr.b     -34(A6)
inputLineBasic_24:
; // So aceita ponto de for numero real (# ou R) ou string ($ ou S) ou tudo (@)
; if (vtec == '.' && pTipo != '#' && pTipo != '$' &&  pTipo != 'R' && pTipo != 'S' && pTipo != '@')
       move.b    -34(A6),D0
       cmp.b     #46,D0
       bne       inputLineBasic_27
       move.b    19(A6),D0
       cmp.b     #35,D0
       beq.s     inputLineBasic_27
       move.b    19(A6),D0
       cmp.b     #36,D0
       beq.s     inputLineBasic_27
       move.b    19(A6),D0
       cmp.b     #82,D0
       beq.s     inputLineBasic_27
       move.b    19(A6),D0
       cmp.b     #83,D0
       beq.s     inputLineBasic_27
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_27
; vtec = 0;
       clr.b     -34(A6)
inputLineBasic_27:
; if (vtec)
       tst.b     -34(A6)
       beq       inputLineBasic_29
; {
; // Prevenir sujeira no buffer ou repeticao
; if (vtec == vtecant)
       move.b    -34(A6),D0
       cmp.b     -33(A6),D0
       bne.s     inputLineBasic_33
; {
; if (countCursor % 300 != 0)
       move.l    -20(A6),-(A7)
       pea       300
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       beq.s     inputLineBasic_33
; continue;
       bra       inputLineBasic_30
inputLineBasic_33:
; }
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_37
; {
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
; if (pEdit)
       tst.b     -16(A6)
       beq.s     inputLineBasic_37
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.l    8(A6),A0
       move.l    -12(A6),D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_37:
; }
; vtecant = vtec;
       move.b    -34(A6),-33(A6)
; if (vtec >= 0x20 && vtec != 0x7F)   // Caracter Printavel menos o DELete
       move.b    -34(A6),D0
       cmp.b     #32,D0
       blo       inputLineBasic_39
       move.b    -34(A6),D0
       cmp.b     #127,D0
       beq       inputLineBasic_39
; {
; if (!pEdit)
       tst.b     -16(A6)
       bne       inputLineBasic_41
; {
; // Digitcao Normal
; if (vbufptr > vbufInput + pQtdInput)
       move.l    8(A6),D0
       add.l     12(A6),D0
       cmp.l     -38(A6),D0
       bhs.s     inputLineBasic_45
; {
; *vbufptr--;
       move.l    -38(A6),A0
       subq.l    #1,-38(A6)
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_45
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_45:
; }
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_47
; printChar(vtec, 1);
       pea       1
       move.b    -34(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_47:
; *vbufptr++ = vtec;
       move.l    -38(A6),A0
       addq.l    #1,-38(A6)
       move.b    -34(A6),(A0)
; *vbufptr = '\0';
       move.l    -38(A6),A0
       clr.b     (A0)
       bra       inputLineBasic_60
inputLineBasic_41:
; }
; else
; {
; iw = strlen(vbufInput);
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-28(A6)
; // Edicao de Linha
; if (!pIns)
       tst.b     -15(A6)
       bne       inputLineBasic_49
; {
; // Sem insercao de caracteres
; if (iw < pQtdInput)
       move.l    -28(A6),D0
       cmp.l     12(A6),D0
       bhs       inputLineBasic_51
; {
; if (vbufInput[iPos] == 0x00)
       move.l    8(A6),A0
       move.l    -12(A6),D0
       move.b    0(A0,D0.L),D0
       bne.s     inputLineBasic_53
; vbufInput[iPos + 1] = 0x00;
       move.l    8(A6),A0
       move.l    -12(A6),A1
       clr.b     1(A1,A0.L)
inputLineBasic_53:
; vbufInput[iPos] = vtec;
       move.l    8(A6),A0
       move.l    -12(A6),D0
       move.b    -34(A6),0(A0,D0.L)
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.l    8(A6),A0
       move.l    -12(A6),D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_51:
       bra       inputLineBasic_55
inputLineBasic_49:
; }
; }
; else
; {
; // Com insercao de caracteres
; if ((iw + 1) <= pQtdInput)
       move.l    -28(A6),D0
       addq.l    #1,D0
       cmp.l     12(A6),D0
       bhi       inputLineBasic_55
; {
; // Copia todos os caracteres mais 1 pro final
; vbuftemp2 = vbufInput[iPos];
       move.l    8(A6),A0
       move.l    -12(A6),D0
       move.b    0(A0,D0.L),-13(A6)
; vbuftemp = vbufInput[iPos + 1];
       move.l    8(A6),A0
       move.l    -12(A6),A1
       move.b    1(A1,A0.L),-14(A6)
; vantX = videoCursorPosColX;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),-4(A6)
; vantY = videoCursorPosRowY;
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),-2(A6)
; printChar(vtec,1);
       pea       1
       move.b    -34(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; for (ix = iPos; ix <= iw ; ix++)
       move.l    -12(A6),-24(A6)
inputLineBasic_57:
       move.l    -24(A6),D0
       cmp.l     -28(A6),D0
       bgt       inputLineBasic_59
; {
; vbufInput[ix + 1] = vbuftemp2;
       move.l    8(A6),A0
       move.l    -24(A6),A1
       move.b    -13(A6),1(A1,A0.L)
; vbuftemp2 = vbuftemp;
       move.b    -14(A6),-13(A6)
; vbuftemp = vbufInput[ix + 2];
       move.l    8(A6),A0
       move.l    -24(A6),A1
       move.b    2(A1,A0.L),-14(A6)
; printChar(vbufInput[ix + 1],1);
       pea       1
       move.l    8(A6),A0
       move.l    -24(A6),A1
       move.b    1(A1,A0.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       addq.l    #1,-24(A6)
       bra       inputLineBasic_57
inputLineBasic_59:
; }
; vbufInput[iw + 1] = 0x00;
       move.l    8(A6),A0
       move.l    -28(A6),A1
       clr.b     1(A1,A0.L)
; vbufInput[iPos] = vtec;
       move.l    8(A6),A0
       move.l    -12(A6),D0
       move.b    -34(A6),0(A0,D0.L)
; videoCursorPosColX = vantX;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    -4(A6),(A0)
; videoCursorPosRowY = vantY;
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    -2(A6),(A0)
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_55:
; }
; }
; if (iw <= pQtdInput)
       move.l    -28(A6),D0
       cmp.l     12(A6),D0
       bhi       inputLineBasic_60
; {
; iPos++;
       addq.l    #1,-12(A6)
; videoCursorPosColX = videoCursorPosColX + 1;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       addq.w    #1,(A0)
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_60:
       bra       inputLineBasic_107
inputLineBasic_39:
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
       move.b    -16(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLineBasic_62
       move.b    -34(A6),D0
       cmp.b     #18,D0
       bne       inputLineBasic_62
; {
; if (iPos > 0)
       move.l    -12(A6),D0
       cmp.l     #0,D0
       ble       inputLineBasic_64
; {
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.l    8(A6),A0
       move.l    -12(A6),D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; iPos--;
       subq.l    #1,-12(A6)
; if (videoCursorPosColX == 0)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D0
       bne.s     inputLineBasic_66
; videoCursorPosColX = 255;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    #255,(A0)
       bra.s     inputLineBasic_67
inputLineBasic_66:
; else
; videoCursorPosColX = videoCursorPosColX - 1;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       subq.w    #1,(A0)
inputLineBasic_67:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_64:
       bra       inputLineBasic_107
inputLineBasic_62:
; }
; }
; else if (pEdit && vtec == 0x14)    // RightArrow (20)
       move.b    -16(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLineBasic_68
       move.b    -34(A6),D0
       cmp.b     #20,D0
       bne       inputLineBasic_68
; {
; if (iPos < strlen(vbufInput))
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     -12(A6),D0
       ble       inputLineBasic_70
; {
; printChar(vbufInput[iPos],0);
       clr.l     -(A7)
       move.l    8(A6),A0
       move.l    -12(A6),D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; iPos++;
       addq.l    #1,-12(A6)
; videoCursorPosColX = videoCursorPosColX + 1;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       addq.w    #1,(A0)
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_70:
       bra       inputLineBasic_107
inputLineBasic_68:
; }
; }
; else if (vtec == 0x15)  // Insert
       move.b    -34(A6),D0
       cmp.b     #21,D0
       bne.s     inputLineBasic_72
; {
; pIns = ~pIns;
       move.b    -15(A6),D0
       not.b     D0
       move.b    D0,-15(A6)
       bra       inputLineBasic_107
inputLineBasic_72:
; }
; else if (vtec == 0x08 && !pEdit)  // Backspace
       move.b    -34(A6),D0
       cmp.b     #8,D0
       bne       inputLineBasic_74
       tst.b     -16(A6)
       bne.s     inputLineBasic_76
       moveq     #1,D0
       bra.s     inputLineBasic_77
inputLineBasic_76:
       clr.l     D0
inputLineBasic_77:
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLineBasic_74
; {
; // Digitcao Normal
; if (vbufptr > &vbufInput)
       lea       8(A6),A0
       move.l    A0,D0
       cmp.l     -38(A6),D0
       bhs.s     inputLineBasic_80
; {
; *vbufptr--;
       move.l    -38(A6),A0
       subq.l    #1,-38(A6)
; *vbufptr = 0x00;
       move.l    -38(A6),A0
       clr.b     (A0)
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_80
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_80:
       bra       inputLineBasic_107
inputLineBasic_74:
; }
; }
; else if ((vtec == 0x08 || vtec == 0x7F) && pEdit)  // Backspace
       move.b    -34(A6),D0
       cmp.b     #8,D0
       beq.s     inputLineBasic_84
       move.b    -34(A6),D0
       cmp.b     #127,D0
       bne       inputLineBasic_82
inputLineBasic_84:
       move.b    -16(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       inputLineBasic_82
; {
; iw = strlen(vbufInput);
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-28(A6)
; if ((vtec == 0x08 && iPos > 0) || vtec == 0x7F)
       move.b    -34(A6),D0
       cmp.b     #8,D0
       bne.s     inputLineBasic_88
       move.l    -12(A6),D0
       cmp.l     #0,D0
       bgt.s     inputLineBasic_87
inputLineBasic_88:
       move.b    -34(A6),D0
       cmp.b     #127,D0
       bne       inputLineBasic_85
inputLineBasic_87:
; {
; if (vtec == 0x08)
       move.b    -34(A6),D0
       cmp.b     #8,D0
       bne       inputLineBasic_89
; {
; iPos--;
       subq.l    #1,-12(A6)
; if (videoCursorPosColX == 0)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D0
       bne.s     inputLineBasic_91
; videoCursorPosColX = 255;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    #255,(A0)
       bra.s     inputLineBasic_92
inputLineBasic_91:
; else
; videoCursorPosColX = videoCursorPosColX - 1;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       subq.w    #1,(A0)
inputLineBasic_92:
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_89:
; }
; vantX = videoCursorPosColX;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),-4(A6)
; vantY = videoCursorPosRowY;
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),-2(A6)
; for (ix = iPos; ix < iw ; ix++)
       move.l    -12(A6),-24(A6)
inputLineBasic_93:
       move.l    -24(A6),D0
       cmp.l     -28(A6),D0
       bge       inputLineBasic_95
; {
; vbufInput[ix] = vbufInput[ix + 1];
       move.l    8(A6),A0
       move.l    -24(A6),A1
       move.l    A0,-(A7)
       move.l    8(A6),A0
       move.l    -24(A6),D0
       move.b    1(A1,A0.L),0(A0,D0.L)
       move.l    (A7)+,A0
; printChar(vbufInput[ix],1);
       pea       1
       move.l    8(A6),A0
       move.l    -24(A6),D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       addq.l    #1,-24(A6)
       bra       inputLineBasic_93
inputLineBasic_95:
; }
; vbufInput[ix] = 0x00;
       move.l    8(A6),A0
       move.l    -24(A6),D0
       clr.b     0(A0,D0.L)
; videoCursorPosColX = vantX;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    -4(A6),(A0)
; videoCursorPosRowY = vantY;
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    -2(A6),(A0)
; vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_85:
       bra       inputLineBasic_107
inputLineBasic_82:
; }
; }
; else if (vtec == 0x1B)   // ESC
       move.b    -34(A6),D0
       cmp.b     #27,D0
       bne       inputLineBasic_96
; {
; // Limpa a linha, esvazia o buffer e retorna tecla
; while (vbufptr > &vbufInput)
inputLineBasic_98:
       lea       8(A6),A0
       move.l    A0,D0
       cmp.l     -38(A6),D0
       bhs       inputLineBasic_100
; {
; *vbufptr--;
       move.l    -38(A6),A0
       subq.l    #1,-38(A6)
; *vbufptr = 0x00;
       move.l    -38(A6),A0
       clr.b     (A0)
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_101
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
inputLineBasic_101:
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_103
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputLineBasic_103:
; if (pTipo != '@' && basVideoCursorShow)
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_105
       move.l    A5,A0
       add.l     #_basVideoCursorShow,A0
       move.b    (A0),D0
       and.l     #255,D0
       beq.s     inputLineBasic_105
; showCursor();
       move.l    1082,A0
       jsr       (A0)
inputLineBasic_105:
       bra       inputLineBasic_98
inputLineBasic_100:
; }
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
; return vtec;
       move.b    -34(A6),D0
       bra       inputLineBasic_23
inputLineBasic_96:
; }
; else if (vtec == 0x0D || vtec == 0x0A ) // CR ou LF
       move.b    -34(A6),D0
       cmp.b     #13,D0
       beq.s     inputLineBasic_109
       move.b    -34(A6),D0
       cmp.b     #10,D0
       bne.s     inputLineBasic_107
inputLineBasic_109:
; {
; return vtec;
       move.b    -34(A6),D0
       bra.s     inputLineBasic_23
inputLineBasic_107:
; }
; if (pTipo != '@')
       move.b    19(A6),D0
       cmp.b     #64,D0
       beq.s     inputLineBasic_110
; showCursor();
       move.l    1082,A0
       jsr       (A0)
inputLineBasic_110:
       bra.s     inputLineBasic_30
inputLineBasic_29:
; }
; else
; {
; vtecant = 0x00;
       clr.b     -33(A6)
inputLineBasic_30:
       bra       inputLineBasic_8
inputLineBasic_23:
       unlk      A6
       rts
; }
; }
; return 0x00;
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; void processLine(unsigned char *vbufInput)
; {
       xdef      _processLine
_processLine:
       link      A6,#-648
; unsigned char linhacomando[32], vloop, vToken;
; unsigned char *blin = vbufInput;
       move.l    8(A6),-614(A6)
; unsigned short varg = 0;
       clr.w     -610(A6)
; unsigned short ix, iy, iz, ikk, kt;
; unsigned short vbytepic = 0, vrecfim;
       clr.w     -598(A6)
; unsigned char cuntam, vLinhaArg[255], vparam2[16], vpicret;
; char vSpace = 0;
       clr.b     -319(A6)
; int vReta;
; typeInf vRetInf;
; unsigned short vTam = 0;
       clr.w     -56(A6)
; unsigned char *pSave = *nextAddrLine;
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    (A0),-54(A6)
; unsigned long vNextAddr = 0;
       clr.l     -50(A6)
; unsigned char vTimer;
; unsigned char vBuffer[20];
; unsigned char *vTempPointer;
; unsigned char sqtdtam[20];
; // Separar linha entre comando e argumento
; linhacomando[0] = '\0';
       clr.b     -648+0(A6)
; vLinhaArg[0] = '\0';
       clr.b     -592+0(A6)
; ix = 0;
       clr.w     -608(A6)
; iy = 0;
       clr.w     -606(A6)
; while (*blin)
processLine_1:
       move.l    -614(A6),A0
       tst.b     (A0)
       beq       processLine_3
; {
; if (!varg && *blin >= 0x20 && *blin <= 0x2F)
       tst.w     -610(A6)
       bne.s     processLine_6
       moveq     #1,D0
       bra.s     processLine_7
processLine_6:
       clr.l     D0
processLine_7:
       and.l     #65535,D0
       beq       processLine_4
       move.l    -614(A6),A0
       move.b    (A0),D0
       cmp.b     #32,D0
       blo       processLine_4
       move.l    -614(A6),A0
       move.b    (A0),D0
       cmp.b     #47,D0
       bhi       processLine_4
; {
; varg = 0x01;
       move.w    #1,-610(A6)
; linhacomando[ix] = '\0';
       move.w    -608(A6),D0
       and.l     #65535,D0
       lea       -648(A6),A0
       clr.b     0(A0,D0.L)
; iy = ix;
       move.w    -608(A6),-606(A6)
; ix = 0;
       clr.w     -608(A6)
; if (*blin != 0x20)
       move.l    -614(A6),A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     processLine_8
; vLinhaArg[ix++] = *blin;
       move.l    -614(A6),A0
       move.w    -608(A6),D0
       addq.w    #1,-608(A6)
       and.l     #65535,D0
       lea       -592(A6),A1
       move.b    (A0),0(A1,D0.L)
       bra.s     processLine_9
processLine_8:
; else
; vSpace = 1;
       move.b    #1,-319(A6)
processLine_9:
       bra.s     processLine_5
processLine_4:
; }
; else
; {
; if (!varg)
       tst.w     -610(A6)
       bne.s     processLine_10
; linhacomando[ix] = *blin;
       move.l    -614(A6),A0
       move.w    -608(A6),D0
       and.l     #65535,D0
       lea       -648(A6),A1
       move.b    (A0),0(A1,D0.L)
       bra.s     processLine_11
processLine_10:
; else
; vLinhaArg[ix] = *blin;
       move.l    -614(A6),A0
       move.w    -608(A6),D0
       and.l     #65535,D0
       lea       -592(A6),A1
       move.b    (A0),0(A1,D0.L)
processLine_11:
; ix++;
       addq.w    #1,-608(A6)
processLine_5:
; }
; *blin++;
       move.l    -614(A6),A0
       addq.l    #1,-614(A6)
       bra       processLine_1
processLine_3:
; }
; if (!varg)
       tst.w     -610(A6)
       bne.s     processLine_12
; {
; linhacomando[ix] = '\0';
       move.w    -608(A6),D0
       and.l     #65535,D0
       lea       -648(A6),A0
       clr.b     0(A0,D0.L)
; iy = ix;
       move.w    -608(A6),-606(A6)
       bra.s     processLine_13
processLine_12:
; }
; else
; vLinhaArg[ix] = '\0';
       move.w    -608(A6),D0
       and.l     #65535,D0
       lea       -592(A6),A0
       clr.b     0(A0,D0.L)
processLine_13:
; vpicret = 0;
       clr.b     -320(A6)
; // Processar e definir o que fazer
; if (linhacomando[0] != 0)
       move.b    -648+0(A6),D0
       beq       processLine_58
; {
; // Se for numero o inicio da linha, eh entrada de programa, senao eh comando direto
; if (linhacomando[0] >= 0x31 && linhacomando[0] <= 0x39) // 0 nao é um numero de linha valida
       move.b    -648+0(A6),D0
       cmp.b     #49,D0
       blo.s     processLine_16
       move.b    -648+0(A6),D0
       cmp.b     #57,D0
       bhi.s     processLine_16
; {
; *pTypeLine = 0x01;
       move.l    A5,A0
       add.l     #_pTypeLine,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; // Entrada de programa
; tokenizeLine(vLinhaArg);
       pea       -592(A6)
       jsr       _tokenizeLine
       addq.w    #4,A7
; saveLine(linhacomando, vLinhaArg);
       pea       -592(A6)
       pea       -648(A6)
       jsr       _saveLine
       addq.w    #8,A7
       bra       processLine_58
processLine_16:
; }
; else
; {
; *pTypeLine = 0x00;
       move.l    A5,A0
       add.l     #_pTypeLine,A0
       move.l    (A0),A0
       clr.b     (A0)
; for (iz = 0; iz < iy; iz++)
       clr.w     -604(A6)
processLine_18:
       move.w    -604(A6),D0
       cmp.w     -606(A6),D0
       bhs.s     processLine_20
; linhacomando[iz] = toupper(linhacomando[iz]);
       move.w    -604(A6),D1
       and.l     #65535,D1
       lea       -648(A6),A0
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    -604(A6),D1
       and.l     #65535,D1
       lea       -648(A6),A0
       move.b    D0,0(A0,D1.L)
       addq.w    #1,-604(A6)
       bra       processLine_18
processLine_20:
; // Comando Direto
; if (!strcmp(linhacomando,"CLS") && iy == 3)
       move.l    A5,A0
       add.l     #@basic_46,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_21
       move.w    -606(A6),D0
       cmp.w     #3,D0
       bne.s     processLine_21
; {
; clearScr();
       move.l    1054,A0
       jsr       (A0)
       bra       processLine_58
processLine_21:
; }
; else if (!strcmp(linhacomando,"NEW") && iy == 3)
       move.l    A5,A0
       add.l     #@basic_100,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne       processLine_23
       move.w    -606(A6),D0
       cmp.w     #3,D0
       bne       processLine_23
; {
; *pStartProg = 0x00;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),A0
       clr.b     (A0)
; *(pStartProg + 1) = 0x00;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),A0
       clr.b     1(A0)
; *(pStartProg + 2) = 0x00;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),A0
       clr.b     2(A0)
; *nextAddrLine = pStartProg;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    A5,A1
       add.l     #_nextAddrLine,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *firstLineNumber = 0;
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       clr.w     (A0)
; *addrFirstLineNumber = 0;
       move.l    A5,A0
       add.l     #_addrFirstLineNumber,A0
       move.l    (A0),A0
       clr.l     (A0)
       bra       processLine_58
processLine_23:
; }
; else if (!strcmp(linhacomando,"EDIT") && iy == 4)
       move.l    A5,A0
       add.l     #@basic_101,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_25
       move.w    -606(A6),D0
       cmp.w     #4,D0
       bne.s     processLine_25
; {
; editLine(vLinhaArg);
       pea       -592(A6)
       jsr       _editLine
       addq.w    #4,A7
       bra       processLine_58
processLine_25:
; }
; else if (!strcmp(linhacomando,"LIST") && iy == 4)
       move.l    A5,A0
       add.l     #@basic_102,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_27
       move.w    -606(A6),D0
       cmp.w     #4,D0
       bne.s     processLine_27
; {
; listProg(vLinhaArg, 0);
       clr.l     -(A7)
       pea       -592(A6)
       jsr       _listProg
       addq.w    #8,A7
       bra       processLine_58
processLine_27:
; }
; else if (!strcmp(linhacomando,"LISTP") && iy == 5)
       move.l    A5,A0
       add.l     #@basic_103,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_29
       move.w    -606(A6),D0
       cmp.w     #5,D0
       bne.s     processLine_29
; {
; listProg(vLinhaArg, 1);
       pea       1
       pea       -592(A6)
       jsr       _listProg
       addq.w    #8,A7
       bra       processLine_58
processLine_29:
; }
; else if (!strcmp(linhacomando,"RUN") && iy == 3)
       move.l    A5,A0
       add.l     #@basic_104,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_31
       move.w    -606(A6),D0
       cmp.w     #3,D0
       bne.s     processLine_31
; {
; runProg(vLinhaArg);
       pea       -592(A6)
       jsr       _runProg
       addq.w    #4,A7
       bra       processLine_58
processLine_31:
; }
; else if (!strcmp(linhacomando,"DELETE") && iy == 3)
       move.l    A5,A0
       add.l     #@basic_105,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_33
       move.w    -606(A6),D0
       cmp.w     #3,D0
       bne.s     processLine_33
; {
; delLine(vLinhaArg);
       pea       -592(A6)
       jsr       _delLine
       addq.w    #4,A7
       bra       processLine_58
processLine_33:
; }
; else if (!strcmp(linhacomando,"XLOAD") && iy == 5)
       move.l    A5,A0
       add.l     #@basic_106,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_35
       move.w    -606(A6),D0
       cmp.w     #5,D0
       bne.s     processLine_35
; {
; basXBasLoad();
       jsr       _basXBasLoad
       bra       processLine_58
processLine_35:
; }
; else if (!strcmp(linhacomando,"TIMER") && iy == 5)
       move.l    A5,A0
       add.l     #@basic_107,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne       processLine_37
       move.w    -606(A6),D0
       cmp.w     #5,D0
       bne       processLine_37
; {
; // Ler contador A do 68901
; vTimer = fsGetMfp(MFP_REG_TADR);
       pea       31
       move.l    8486760,A0
       jsr       (A0)
       addq.w    #4,A7
       move.b    D0,-45(A6)
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
       move.l    A5,A0
       add.l     #@basic_108,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(vBuffer);
       pea       -44(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("ms\r\n\0");
       move.l    A5,A0
       add.l     #@basic_109,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       processLine_58
processLine_37:
; }
; else if (!strcmp(linhacomando,"TRON") && iy == 4)
       move.l    A5,A0
       add.l     #@basic_110,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_39
       move.w    -606(A6),D0
       cmp.w     #4,D0
       bne.s     processLine_39
; {
; *traceOn = 1;
       move.l    A5,A0
       add.l     #_traceOn,A0
       move.l    (A0),A0
       move.b    #1,(A0)
       bra       processLine_58
processLine_39:
; }
; else if (!strcmp(linhacomando,"TROFF") && iy == 5)
       move.l    A5,A0
       add.l     #@basic_111,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_41
       move.w    -606(A6),D0
       cmp.w     #5,D0
       bne.s     processLine_41
; {
; *traceOn = 0;
       move.l    A5,A0
       add.l     #_traceOn,A0
       move.l    (A0),A0
       clr.b     (A0)
       bra       processLine_58
processLine_41:
; }
; else if (!strcmp(linhacomando,"DEBUGON") && iy == 7)
       move.l    A5,A0
       add.l     #@basic_112,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_43
       move.w    -606(A6),D0
       cmp.w     #7,D0
       bne.s     processLine_43
; {
; *debugOn = 1;
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       move.b    #1,(A0)
       bra       processLine_58
processLine_43:
; }
; else if (!strcmp(linhacomando,"DEBUGOFF") && iy == 8)
       move.l    A5,A0
       add.l     #@basic_113,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_45
       move.w    -606(A6),D0
       cmp.w     #8,D0
       bne.s     processLine_45
; {
; *debugOn = 0;
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       clr.b     (A0)
       bra       processLine_58
processLine_45:
; }
; // *************************************************
; // ESSE COMANDO NAO VAI EXISTIR QUANDO FOR PRA BIOS
; // *************************************************
; else if (!strcmp(linhacomando,"QUIT") && iy == 4)
       move.l    A5,A0
       add.l     #@basic_114,A0
       move.l    A0,-(A7)
       pea       -648(A6)
       jsr       _strcmp
       addq.w    #8,A7
       tst.l     D0
       bne.s     processLine_47
       move.w    -606(A6),D0
       cmp.w     #4,D0
       bne.s     processLine_47
; {
; *pProcess = 0x00;
       move.l    A5,A0
       add.l     #_pProcess,A0
       move.l    (A0),A0
       clr.b     (A0)
       bra       processLine_58
processLine_47:
; }
; // *************************************************
; // *************************************************
; // *************************************************
; else
; {
; // Tokeniza a linha toda
; strcpy(vRetInf.tString, linhacomando);
       pea       -648(A6)
       lea       -314(A6),A0
       move.l    A0,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
; if (vSpace)
       tst.b     -319(A6)
       beq.s     processLine_49
; strcat(vRetInf.tString, " ");
       move.l    A5,A0
       add.l     #@basic_115,A0
       move.l    A0,-(A7)
       lea       -314(A6),A0
       move.l    A0,-(A7)
       jsr       _strcat
       addq.w    #8,A7
processLine_49:
; strcat(vRetInf.tString, vLinhaArg);
       pea       -592(A6)
       lea       -314(A6),A0
       move.l    A0,-(A7)
       jsr       _strcat
       addq.w    #8,A7
; tokenizeLine(vRetInf.tString);
       lea       -314(A6),A0
       move.l    A0,-(A7)
       jsr       _tokenizeLine
       addq.w    #4,A7
; strcpy(vLinhaArg, vRetInf.tString);
       lea       -314(A6),A0
       move.l    A0,-(A7)
       pea       -592(A6)
       jsr       _strcpy
       addq.w    #8,A7
; // Salva a linha pra ser interpretada
; vTam = strlen(vLinhaArg);
       pea       -592(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,-56(A6)
; vNextAddr = comandLineTokenized + (vTam + 6);
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),D0
       move.w    -56(A6),D1
       addq.w    #6,D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    D0,-50(A6)
; *comandLineTokenized = ((vNextAddr & 0xFF0000) >> 16);
       move.l    -50(A6),D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(comandLineTokenized + 1) = ((vNextAddr & 0xFF00) >> 8);
       move.l    -50(A6),D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(comandLineTokenized + 2) =  (vNextAddr & 0xFF);
       move.l    -50(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; // Grava numero da linha
; *(comandLineTokenized + 3) = 0xFF;
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.b    #255,3(A0)
; *(comandLineTokenized + 4) = 0xFF;
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.b    #255,4(A0)
; // Grava linha tokenizada
; for(kt = 0; kt < vTam; kt++)
       clr.w     -600(A6)
processLine_51:
       move.w    -600(A6),D0
       cmp.w     -56(A6),D0
       bhs.s     processLine_53
; *(comandLineTokenized + (kt + 5)) = vLinhaArg[kt];
       move.w    -600(A6),D0
       and.l     #65535,D0
       lea       -592(A6),A0
       move.l    A5,A1
       add.l     #_comandLineTokenized,A1
       move.l    (A1),A1
       move.w    -600(A6),D1
       addq.w    #5,D1
       and.l     #65535,D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.w    #1,-600(A6)
       bra       processLine_51
processLine_53:
; // Grava final linha 0x00
; *(comandLineTokenized + (vTam + 5)) = 0x00;
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.w    -56(A6),D0
       addq.w    #5,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(comandLineTokenized + (vTam + 6)) = 0x00;
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.w    -56(A6),D0
       addq.w    #6,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(comandLineTokenized + (vTam + 7)) = 0x00;
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.w    -56(A6),D0
       addq.w    #7,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *(comandLineTokenized + (vTam + 8)) = 0x00;
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),A0
       move.w    -56(A6),D0
       addq.w    #8,D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
; *nextAddrSimpVar = pStartSimpVar;
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    A5,A1
       add.l     #_nextAddrSimpVar,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *nextAddrArrayVar = pStartArrayVar;
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    A5,A1
       add.l     #_nextAddrArrayVar,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *nextAddrString = pStartString;
       move.l    A5,A0
       add.l     #_pStartString,A0
       move.l    A5,A1
       add.l     #_nextAddrString,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *vMaisTokens = 0;
       move.l    A5,A0
       add.l     #_vMaisTokens,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vParenteses = 0x00;
       move.l    A5,A0
       add.l     #_vParenteses,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemIf = 0x00;
       move.l    A5,A0
       add.l     #_vTemIf,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemThen = 0;
       move.l    A5,A0
       add.l     #_vTemThen,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemElse = 0;
       move.l    A5,A0
       add.l     #_vTemElse,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemIfAndOr = 0x00;
       move.l    A5,A0
       add.l     #_vTemIfAndOr,A0
       move.l    (A0),A0
       clr.b     (A0)
; *pointerRunProg = comandLineTokenized + 5;
       move.l    A5,A0
       add.l     #_comandLineTokenized,A0
       move.l    (A0),D0
       addq.l    #5,D0
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    D0,(A0)
; vRetInf.tString[0] = 0x00;
       lea       -314(A6),A0
       clr.b     (A0)
; *ftos=0;
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       clr.l     (A0)
; *gtos=0;
       move.l    A5,A0
       add.l     #_gtos,A0
       move.l    (A0),A0
       clr.l     (A0)
; *vErroProc = 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       clr.w     (A0)
; *randSeed = fsGetMfp(MFP_REG_TADR);
       pea       31
       move.l    8486760,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_randSeed,A0
       move.l    (A0),A0
       move.l    D0,(A0)
; do
; {
processLine_54:
; *doisPontos = 0;
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vInicioSentenca = 1;
       move.l    A5,A0
       add.l     #_vInicioSentenca,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-24(A6)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vReta = executeToken(*vTempPointer);
       move.l    -24(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _executeToken
       addq.w    #4,A7
       move.l    D0,-318(A6)
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       tst.b     (A0)
       bne       processLine_54
; } while (*doisPontos);
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #3,D0
       beq.s     processLine_56
; basText();
       jsr       _basText
processLine_56:
; #endif
; if (*vErroProc)
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     processLine_58
; {
; showErrorMessage(*vErroProc, 0);
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    (A0),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _showErrorMessage
       addq.w    #8,A7
processLine_58:
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
       link      A6,#-840
; unsigned char vLido[255], vLidoCaps[255], vAspas, vAchou = 0;
       clr.b     -327(A6)
; unsigned char *blin = pTokenized;
       move.l    8(A6),-326(A6)
; unsigned short ix, iy, kt, iz, iw;
; unsigned char vToken, vLinhaArg[255], vparam2[16], vpicret;
; char vBuffer [sizeof(long)*8+1];
; char vFirstComp = 0;
       clr.b     -3(A6)
; char isToken;
; char vTemRem = 0;
       clr.b     -1(A6)
; //    unsigned char sqtdtam[20];
; // Separar linha entre comando e argumento
; vLinhaArg[0] = '\0';
       clr.b     -310+0(A6)
; vLido[0]  = '\0';
       clr.b     -840+0(A6)
; ix = 0;
       clr.w     -322(A6)
; iy = 0;
       clr.w     -320(A6)
; vAspas = 0;
       clr.b     -328(A6)
; while (1)
tokenizeLine_1:
; {
; vLido[ix] = '\0';
       move.w    -322(A6),D0
       and.l     #65535,D0
       lea       -840(A6),A0
       clr.b     0(A0,D0.L)
; if (*blin == 0x22)
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #34,D0
       bne.s     tokenizeLine_4
; vAspas = !vAspas;
       tst.b     -328(A6)
       bne.s     tokenizeLine_6
       moveq     #1,D0
       bra.s     tokenizeLine_7
tokenizeLine_6:
       clr.l     D0
tokenizeLine_7:
       move.b    D0,-328(A6)
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
       tst.b     -328(A6)
       bne.s     tokenizeLine_11
       move.l    -326(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@basic_116,A0
       move.l    A0,-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       bne.s     tokenizeLine_10
tokenizeLine_11:
       move.l    -326(A6),A0
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
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #60,D0
       beq.s     tokenizeLine_20
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #62,D0
       bne       tokenizeLine_21
tokenizeLine_20:
       tst.b     -3(A6)
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
       move.l    -326(A6),A0
       move.b    1(A0),D0
       cmp.b     #62,D0
       beq       tokenizeLine_18
       move.l    -326(A6),A0
       move.b    1(A0),D0
       cmp.b     #61,D0
       beq       tokenizeLine_18
tokenizeLine_21:
       move.b    -3(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq.s     tokenizeLine_24
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     tokenizeLine_18
tokenizeLine_24:
       move.b    -3(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       tokenizeLine_16
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #62,D0
       bne       tokenizeLine_16
tokenizeLine_18:
; {
; if (!vFirstComp)
       tst.b     -3(A6)
       bne       tokenizeLine_25
; {
; for(kt = 0; kt < ix; kt++)
       clr.w     -318(A6)
tokenizeLine_27:
       move.w    -318(A6),D0
       cmp.w     -322(A6),D0
       bhs.s     tokenizeLine_29
; vLinhaArg[iy++] = vLido[kt];
       move.w    -318(A6),D0
       and.l     #65535,D0
       lea       -840(A6),A0
       move.w    -320(A6),D1
       addq.w    #1,-320(A6)
       and.l     #65535,D1
       lea       -310(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.w    #1,-318(A6)
       bra       tokenizeLine_27
tokenizeLine_29:
; vLido[0] = 0x00;
       clr.b     -840+0(A6)
; ix = 0;
       clr.w     -322(A6)
; vFirstComp = 1;
       move.b    #1,-3(A6)
tokenizeLine_25:
; }
; vLido[ix++] = *blin;
       move.l    -326(A6),A0
       move.w    -322(A6),D0
       addq.w    #1,-322(A6)
       and.l     #65535,D0
       lea       -840(A6),A1
       move.b    (A0),0(A1,D0.L)
; if (ix < 2)
       move.w    -322(A6),D0
       cmp.w     #2,D0
       bhs.s     tokenizeLine_30
; {
; blin++;
       addq.l    #1,-326(A6)
; continue;
       bra       tokenizeLine_2
tokenizeLine_30:
; }
; vFirstComp = 0;
       clr.b     -3(A6)
tokenizeLine_16:
; }
; if (vLido[0])
       tst.b     -840+0(A6)
       beq       tokenizeLine_32
; {
; vToken = 0;
       clr.b     -311(A6)
; /*writeLongSerial("Aqui 332.666.2-[");
; itoa(ix,sqtdtam,10);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*blin,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; if (ix > 1)
       move.w    -322(A6),D0
       cmp.w     #1,D0
       bls       tokenizeLine_41
; {
; // Transforma em Caps pra comparar com os tokens
; for (kt = 0; kt < ix; kt++)
       clr.w     -318(A6)
tokenizeLine_36:
       move.w    -318(A6),D0
       cmp.w     -322(A6),D0
       bhs.s     tokenizeLine_38
; vLidoCaps[kt] = toupper(vLido[kt]);
       move.w    -318(A6),D1
       and.l     #65535,D1
       lea       -840(A6),A0
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    -318(A6),D1
       and.l     #65535,D1
       lea       -584(A6),A0
       move.b    D0,0(A0,D1.L)
       addq.w    #1,-318(A6)
       bra       tokenizeLine_36
tokenizeLine_38:
; vLidoCaps[ix] = 0x00;
       move.w    -322(A6),D0
       and.l     #65535,D0
       lea       -584(A6),A0
       clr.b     0(A0,D0.L)
; iz = strlen(vLidoCaps);
       pea       -584(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,-316(A6)
; // Compara pra ver se é um token
; for(kt = 0; kt < keywords_count; kt++)
       clr.w     -318(A6)
tokenizeLine_39:
       move.w    -318(A6),D0
       and.l     #65535,D0
       move.l    A5,A0
       add.l     #_keywords_count,A0
       cmp.l     (A0),D0
       bhs       tokenizeLine_41
; {
; iw = strlen(keywords[kt].keyword);
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.w    -318(A6),D1
       and.l     #65535,D1
       lsl.l     #3,D1
       move.l    0(A0,D1.L),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,-314(A6)
; if (iw == 2 && iz == iw)
       move.w    -314(A6),D0
       cmp.w     #2,D0
       bne       tokenizeLine_42
       move.w    -316(A6),D0
       cmp.w     -314(A6),D0
       bne       tokenizeLine_42
; {
; if (vLidoCaps[0] == keywords[kt].keyword[0] && vLidoCaps[1] == keywords[kt].keyword[1])
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.w    -318(A6),D0
       and.l     #65535,D0
       lsl.l     #3,D0
       move.l    0(A0,D0.L),A0
       move.b    -584+0(A6),D0
       cmp.b     (A0),D0
       bne       tokenizeLine_44
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.w    -318(A6),D0
       and.l     #65535,D0
       lsl.l     #3,D0
       move.l    0(A0,D0.L),A0
       move.b    -584+1(A6),D0
       cmp.b     1(A0),D0
       bne.s     tokenizeLine_44
; {
; vToken = keywords[kt].token;
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.w    -318(A6),D0
       and.l     #65535,D0
       lsl.l     #3,D0
       add.l     D0,A0
       move.l    4(A0),D0
       move.b    D0,-311(A6)
; break;
       bra       tokenizeLine_41
tokenizeLine_44:
       bra       tokenizeLine_48
tokenizeLine_42:
; }
; }
; else if (iz==iw)
       move.w    -316(A6),D0
       cmp.w     -314(A6),D0
       bne       tokenizeLine_48
; {
; if (strncmp(vLidoCaps, keywords[kt].keyword, iw) == 0)
       move.w    -314(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.w    -318(A6),D1
       and.l     #65535,D1
       lsl.l     #3,D1
       move.l    0(A0,D1.L),-(A7)
       pea       -584(A6)
       jsr       _strncmp
       add.w     #12,A7
       tst.l     D0
       bne.s     tokenizeLine_48
; {
; vToken = keywords[kt].token;
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.w    -318(A6),D0
       and.l     #65535,D0
       lsl.l     #3,D0
       add.l     D0,A0
       move.l    4(A0),D0
       move.b    D0,-311(A6)
; break;
       bra.s     tokenizeLine_41
tokenizeLine_48:
       addq.w    #1,-318(A6)
       bra       tokenizeLine_39
tokenizeLine_41:
; }
; }
; }
; }
; if (vToken)
       tst.b     -311(A6)
       beq       tokenizeLine_50
; {
; if (vToken == 0x8C) // REM
       move.b    -311(A6),D0
       and.w     #255,D0
       cmp.w     #140,D0
       bne.s     tokenizeLine_52
; vTemRem = 1;
       move.b    #1,-1(A6)
tokenizeLine_52:
; vLinhaArg[iy++] = vToken;
       move.w    -320(A6),D0
       addq.w    #1,-320(A6)
       and.l     #65535,D0
       lea       -310(A6),A0
       move.b    -311(A6),0(A0,D0.L)
; //if (*blin == 0x28 || *blin == 0x29)
; //    vLinhaArg[iy++] = *blin;
; //if (*blin == 0x3A)  // :
; if (*blin && *blin != 0x20 && vToken < 0xF0 && !vTemRem)
       move.l    -326(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       beq       tokenizeLine_54
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq       tokenizeLine_54
       move.b    -311(A6),D0
       and.w     #255,D0
       cmp.w     #240,D0
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
       move.l    -326(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    -320(A6),D1
       addq.w    #1,-320(A6)
       and.l     #65535,D1
       lea       -310(A6),A0
       move.b    D0,0(A0,D1.L)
tokenizeLine_54:
       bra       tokenizeLine_61
tokenizeLine_50:
; }
; else
; {
; for(kt = 0; kt < ix; kt++)
       clr.w     -318(A6)
tokenizeLine_58:
       move.w    -318(A6),D0
       cmp.w     -322(A6),D0
       bhs.s     tokenizeLine_60
; vLinhaArg[iy++] = vLido[kt];
       move.w    -318(A6),D0
       and.l     #65535,D0
       lea       -840(A6),A0
       move.w    -320(A6),D1
       addq.w    #1,-320(A6)
       and.l     #65535,D1
       lea       -310(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.w    #1,-318(A6)
       bra       tokenizeLine_58
tokenizeLine_60:
; if (*blin && *blin != 0x20)
       move.l    -326(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       beq.s     tokenizeLine_61
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     tokenizeLine_61
; vLinhaArg[iy++] = toupper(*blin);
       move.l    -326(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    -320(A6),D1
       addq.w    #1,-320(A6)
       and.l     #65535,D1
       lea       -310(A6),A0
       move.b    D0,0(A0,D1.L)
tokenizeLine_61:
       bra       tokenizeLine_63
tokenizeLine_32:
; }
; }
; else
; {
; if (*blin && *blin != 0x20)
       move.l    -326(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       beq.s     tokenizeLine_63
       move.l    -326(A6),A0
       move.b    (A0),D0
       cmp.b     #32,D0
       beq.s     tokenizeLine_63
; vLinhaArg[iy++] = toupper(*blin);
       move.l    -326(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    -320(A6),D1
       addq.w    #1,-320(A6)
       and.l     #65535,D1
       lea       -310(A6),A0
       move.b    D0,0(A0,D1.L)
tokenizeLine_63:
; }
; if (!*blin)
       move.l    -326(A6),A0
       tst.b     (A0)
       bne.s     tokenizeLine_65
; break;
       bra       tokenizeLine_3
tokenizeLine_65:
; vLido[0] = '\0';
       clr.b     -840+0(A6)
; ix = 0;
       clr.w     -322(A6)
       bra       tokenizeLine_68
tokenizeLine_8:
; }
; else
; {
; if (!vAspas && !vTemRem)
       tst.b     -328(A6)
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
       move.l    -326(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.w    -322(A6),D1
       addq.w    #1,-322(A6)
       and.l     #65535,D1
       lea       -840(A6),A0
       move.b    D0,0(A0,D1.L)
       bra.s     tokenizeLine_68
tokenizeLine_67:
; else
; vLido[ix++] = *blin;
       move.l    -326(A6),A0
       move.w    -322(A6),D0
       addq.w    #1,-322(A6)
       and.l     #65535,D0
       lea       -840(A6),A1
       move.b    (A0),0(A1,D0.L)
tokenizeLine_68:
; }
; blin++;
       addq.l    #1,-326(A6)
tokenizeLine_2:
       bra       tokenizeLine_1
tokenizeLine_3:
; }
; vLinhaArg[iy] = 0x00;
       move.w    -320(A6),D0
       and.l     #65535,D0
       lea       -310(A6),A0
       clr.b     0(A0,D0.L)
; for(kt = 0; kt < iy; kt++)
       clr.w     -318(A6)
tokenizeLine_71:
       move.w    -318(A6),D0
       cmp.w     -320(A6),D0
       bhs.s     tokenizeLine_73
; pTokenized[kt] = vLinhaArg[kt];
       move.w    -318(A6),D0
       and.l     #65535,D0
       lea       -310(A6),A0
       move.l    8(A6),A1
       move.w    -318(A6),D1
       and.l     #65535,D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.w    #1,-318(A6)
       bra       tokenizeLine_71
tokenizeLine_73:
; pTokenized[iy] = 0x00;
       move.l    8(A6),A0
       move.w    -320(A6),D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
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
       link      A6,#-32
; unsigned short vTam = 0, kt;
       clr.w     -30(A6)
; unsigned char *pSave = *nextAddrLine;
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    (A0),-26(A6)
; unsigned long vNextAddr = 0, vAntAddr = 0, vNextAddr2 = 0;
       clr.l     -22(A6)
       clr.l     -18(A6)
       clr.l     -14(A6)
; unsigned short vNumLin = 0;
       clr.w     -10(A6)
; unsigned char *pAtu = *nextAddrLine, *pLast = *nextAddrLine;
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; vNumLin = atoi(pNumber);
       move.l    8(A6),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-10(A6)
; if (*firstLineNumber == 0)
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       move.w    (A0),D0
       bne.s     saveLine_1
; {
; *firstLineNumber = vNumLin;
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       move.w    -10(A6),(A0)
; *addrFirstLineNumber = pStartProg;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    A5,A1
       add.l     #_addrFirstLineNumber,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
       bra       saveLine_3
saveLine_1:
; }
; else
; {
; vNextAddr = findNumberLine(vNumLin, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.w    -10(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-22(A6)
; if (vNextAddr > 0)
       move.l    -22(A6),D0
       cmp.l     #0,D0
       bls       saveLine_3
; {
; pAtu = vNextAddr;
       move.l    -22(A6),-8(A6)
; if (((*(pAtu + 3) << 8) | *(pAtu + 4)) == vNumLin)
       move.l    -8(A6),A0
       move.b    3(A0),D0
       lsl.b     #8,D0
       move.l    -8(A6),A0
       or.b      4(A0),D0
       and.w     #255,D0
       cmp.w     -10(A6),D0
       bne.s     saveLine_5
; {
; printText("Line number already exists\r\n\0");
       move.l    A5,A0
       add.l     #@basic_117,A0
       move.l    A0,-(A7)
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
       move.w    -10(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-18(A6)
saveLine_3:
; }
; }
; vTam = strlen(pTokenized);
       move.l    12(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.w    D0,-30(A6)
; if (vTam)
       tst.w     -30(A6)
       beq       saveLine_8
; {
; // Calcula nova posicao da proxima linha
; if (vNextAddr == 0)
       move.l    -22(A6),D0
       bne       saveLine_10
; {
; *nextAddrLine += (vTam + 6);
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.w    -30(A6),D0
       and.l     #65535,D0
       addq.l    #6,D0
       add.l     D0,(A0)
; vNextAddr = *nextAddrLine;
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    (A0),-22(A6)
; *addrLastLineNumber = pSave;
       move.l    A5,A0
       add.l     #_addrLastLineNumber,A0
       move.l    (A0),A0
       move.l    -26(A6),(A0)
       bra       saveLine_11
saveLine_10:
; }
; else
; {
; if (*firstLineNumber > vNumLin)
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       move.w    (A0),D0
       cmp.w     -10(A6),D0
       bls.s     saveLine_12
; {
; *firstLineNumber = vNumLin;
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       move.w    -10(A6),(A0)
; *addrFirstLineNumber = *nextAddrLine;
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_addrFirstLineNumber,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
saveLine_12:
; }
; *nextAddrLine += (vTam + 6);
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.w    -30(A6),D0
       and.l     #65535,D0
       addq.l    #6,D0
       add.l     D0,(A0)
; vNextAddr2 = *nextAddrLine;
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    (A0),-14(A6)
; if (vAntAddr != vNextAddr)
       move.l    -18(A6),D0
       cmp.l     -22(A6),D0
       beq       saveLine_14
; {
; pLast = vAntAddr;
       move.l    -18(A6),-4(A6)
; vAntAddr = pSave;
       move.l    -26(A6),-18(A6)
; *pLast       = ((vAntAddr & 0xFF0000) >> 16);
       move.l    -18(A6),D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    -4(A6),A0
       move.b    D0,(A0)
; *(pLast + 1) = ((vAntAddr & 0xFF00) >> 8);
       move.l    -18(A6),D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    -4(A6),A0
       move.b    D0,1(A0)
; *(pLast + 2) =  (vAntAddr & 0xFF);
       move.l    -18(A6),D0
       and.l     #255,D0
       move.l    -4(A6),A0
       move.b    D0,2(A0)
saveLine_14:
; }
; pLast = *addrLastLineNumber;
       move.l    A5,A0
       add.l     #_addrLastLineNumber,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; *pLast       = ((vNextAddr2 & 0xFF0000) >> 16);
       move.l    -14(A6),D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    -4(A6),A0
       move.b    D0,(A0)
; *(pLast + 1) = ((vNextAddr2 & 0xFF00) >> 8);
       move.l    -14(A6),D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    -4(A6),A0
       move.b    D0,1(A0)
; *(pLast + 2) =  (vNextAddr2 & 0xFF);
       move.l    -14(A6),D0
       and.l     #255,D0
       move.l    -4(A6),A0
       move.b    D0,2(A0)
saveLine_11:
; }
; pAtu = *nextAddrLine;
       move.l    A5,A0
       add.l     #_nextAddrLine,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
; *pAtu       = 0x00;
       move.l    -8(A6),A0
       clr.b     (A0)
; *(pAtu + 1) = 0x00;
       move.l    -8(A6),A0
       clr.b     1(A0)
; *(pAtu + 2) = 0x00;
       move.l    -8(A6),A0
       clr.b     2(A0)
; *(pAtu + 3) = 0x00;
       move.l    -8(A6),A0
       clr.b     3(A0)
; *(pAtu + 4) = 0x00;
       move.l    -8(A6),A0
       clr.b     4(A0)
; // Grava endereco proxima linha
; *pSave++ = ((vNextAddr & 0xFF0000) >> 16);
       move.l    -22(A6),D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    -26(A6),A0
       addq.l    #1,-26(A6)
       move.b    D0,(A0)
; *pSave++ = ((vNextAddr & 0xFF00) >> 8);
       move.l    -22(A6),D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    -26(A6),A0
       addq.l    #1,-26(A6)
       move.b    D0,(A0)
; *pSave++ =  (vNextAddr & 0xFF);
       move.l    -22(A6),D0
       and.l     #255,D0
       move.l    -26(A6),A0
       addq.l    #1,-26(A6)
       move.b    D0,(A0)
; // Grava numero da linha
; *pSave++ = ((vNumLin & 0xFF00) >> 8);
       move.w    -10(A6),D0
       and.w     #65280,D0
       lsr.w     #8,D0
       move.l    -26(A6),A0
       addq.l    #1,-26(A6)
       move.b    D0,(A0)
; *pSave++ = (vNumLin & 0xFF);
       move.w    -10(A6),D0
       and.w     #255,D0
       move.l    -26(A6),A0
       addq.l    #1,-26(A6)
       move.b    D0,(A0)
; // Grava linha tokenizada
; for(kt = 0; kt < vTam; kt++)
       clr.w     -28(A6)
saveLine_16:
       move.w    -28(A6),D0
       cmp.w     -30(A6),D0
       bhs.s     saveLine_18
; *pSave++ = *pTokenized++;
       move.l    12(A6),A0
       addq.l    #1,12(A6)
       move.l    -26(A6),A1
       addq.l    #1,-26(A6)
       move.b    (A0),(A1)
       addq.w    #1,-28(A6)
       bra       saveLine_16
saveLine_18:
; // Grava final linha 0x00
; *pSave = 0x00;
       move.l    -26(A6),A0
       clr.b     (A0)
saveLine_8:
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
       link      A6,#-600
; // Default listar tudo
; unsigned short pIni = 0, pFim = 0xFFFF;
       clr.w     -598(A6)
       move.w    #65535,-596(A6)
; unsigned char *vStartList = pStartProg;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),-594(A6)
; unsigned long vNextList;
; unsigned short vNumLin;
; char sNumLin [sizeof(short)*8+1], vFirstByte;
; unsigned char vtec;
; unsigned char vLinhaList[255], sNumPar[10], vToken;
; int iw, ix, iy, iz, vPauseRowCounter;
; unsigned char sqtdtam[20];
; unsigned char vbufInput[256];
; if (pArg[0] != 0x00 && strchr(pArg,'-') != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq       listProg_1
       pea       45
       move.l    8(A6),-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq       listProg_1
; {
; ix = 0;
       clr.l     -292(A6)
; iy = 0;
       clr.l     -288(A6)
; // listar intervalo
; while (pArg[ix] != '-')
listProg_3:
       move.l    8(A6),A0
       move.l    -292(A6),D0
       move.b    0(A0,D0.L),D0
       cmp.b     #45,D0
       beq.s     listProg_5
; sNumPar[iy++] = pArg[ix++];
       move.l    8(A6),A0
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       move.l    -288(A6),D1
       addq.l    #1,-288(A6)
       lea       -308(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra       listProg_3
listProg_5:
; sNumPar[iy] = 0x00;
       move.l    -288(A6),D0
       lea       -308(A6),A0
       clr.b     0(A0,D0.L)
; pIni = atoi(sNumPar);
       pea       -308(A6)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-598(A6)
; iy = 0;
       clr.l     -288(A6)
; ix++;
       addq.l    #1,-292(A6)
; while (pArg[ix])
listProg_6:
       move.l    8(A6),A0
       move.l    -292(A6),D0
       tst.b     0(A0,D0.L)
       beq.s     listProg_8
; sNumPar[iy++] = pArg[ix++];
       move.l    8(A6),A0
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       move.l    -288(A6),D1
       addq.l    #1,-288(A6)
       lea       -308(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra       listProg_6
listProg_8:
; sNumPar[iy] = 0x00;
       move.l    -288(A6),D0
       lea       -308(A6),A0
       clr.b     0(A0,D0.L)
; if (sNumPar[0])
       tst.b     -308+0(A6)
       beq.s     listProg_9
; pFim = atoi(sNumPar);
       pea       -308(A6)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-596(A6)
       bra.s     listProg_10
listProg_9:
; else
; pFim = 0xFFFF;
       move.w    #65535,-596(A6)
listProg_10:
       bra.s     listProg_11
listProg_1:
; }
; else if (pArg[0] != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq.s     listProg_11
; {
; // listar 1 linha
; pIni = atoi(pArg);
       move.l    8(A6),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-598(A6)
; pFim = pIni;
       move.w    -598(A6),-596(A6)
listProg_11:
; }
; vStartList = findNumberLine(pIni, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.w    -598(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-594(A6)
; // Nao achou numero de linha inicial
; if (!vStartList)
       tst.l     -594(A6)
       bne.s     listProg_13
; {
; printText("Non-existent line number\r\n\0");
       move.l    A5,A0
       add.l     #@basic_118,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       listProg_18
listProg_13:
; }
; vNextList = vStartList;
       move.l    -594(A6),-590(A6)
; vPauseRowCounter = 0;
       clr.l     -280(A6)
; while (1)
listProg_16:
; {
; // Guarda proxima posicao
; vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    -594(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    -594(A6),A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    -594(A6),A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-590(A6)
; if (vNextList)
       tst.l     -590(A6)
       beq       listProg_19
; {
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    -594(A6),A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    -594(A6),A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-586(A6)
; if (vNumLin > pFim)
       move.w    -586(A6),D0
       cmp.w     -596(A6),D0
       bls.s     listProg_21
; break;
       bra       listProg_18
listProg_21:
; vStartList += 5;
       addq.l    #5,-594(A6)
; ix = 0;
       clr.l     -292(A6)
; // Coloca numero da linha na listagem
; itoa(vNumLin, sNumLin, 10);
       pea       10
       pea       -584(A6)
       move.w    -586(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; iz = 0;
       clr.l     -284(A6)
; while (sNumLin[iz])
listProg_23:
       move.l    -284(A6),D0
       lea       -584(A6),A0
       tst.b     0(A0,D0.L)
       beq.s     listProg_25
; {
; vLinhaList[ix++] = sNumLin[iz++];
       move.l    -284(A6),D0
       addq.l    #1,-284(A6)
       lea       -584(A6),A0
       move.l    -292(A6),D1
       addq.l    #1,-292(A6)
       lea       -564(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra       listProg_23
listProg_25:
; }
; vLinhaList[ix++] = 0x20;
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       move.b    #32,0(A0,D0.L)
; vFirstByte = 1;
       move.b    #1,-566(A6)
; // Pega caracter a caracter da linha
; while (*vStartList)
listProg_26:
       move.l    -594(A6),A0
       tst.b     (A0)
       beq       listProg_28
; {
; vToken = *vStartList++;
       move.l    -594(A6),A0
       addq.l    #1,-594(A6)
       move.b    (A0),-297(A6)
; // Verifica se é token, se for, muda pra escrito
; if (vToken >= 0x80)
       move.b    -297(A6),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo       listProg_29
; {
; // Procura token na lista
; iy = findToken(vToken);
       move.b    -297(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _findToken
       addq.w    #4,A7
       move.l    D0,-288(A6)
; iz = 0;
       clr.l     -284(A6)
; if (!vFirstByte)
       tst.b     -566(A6)
       bne       listProg_31
; {
; if (isalphas(*(vStartList - 2)) || isdigitus(*(vStartList - 2)) || *(vStartList - 2) == ')')
       move.l    -594(A6),D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne       listProg_35
       move.l    -594(A6),D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       bne.s     listProg_35
       move.l    -594(A6),D0
       subq.l    #2,D0
       move.l    D0,A0
       move.b    (A0),D0
       cmp.b     #41,D0
       bne.s     listProg_33
listProg_35:
; vLinhaList[ix++] = 0x20;
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       move.b    #32,0(A0,D0.L)
listProg_33:
       bra.s     listProg_32
listProg_31:
; }
; else
; vFirstByte = 0;
       clr.b     -566(A6)
listProg_32:
; while (keywords[iy].keyword[iz])
listProg_36:
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.l    -288(A6),D0
       lsl.l     #3,D0
       move.l    0(A0,D0.L),A0
       move.l    -284(A6),D0
       tst.b     0(A0,D0.L)
       beq.s     listProg_38
; {
; vLinhaList[ix++] = keywords[iy].keyword[iz++];
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.l    -288(A6),D0
       lsl.l     #3,D0
       move.l    0(A0,D0.L),A0
       move.l    -284(A6),D0
       addq.l    #1,-284(A6)
       move.l    -292(A6),D1
       addq.l    #1,-292(A6)
       lea       -564(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra       listProg_36
listProg_38:
; }
; // Se nao for intervalo de funcao, coloca espaço depois do comando
; if (*vStartList != '=' && (vToken < 0xC0 || vToken > 0xEF))
       move.l    -594(A6),A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     listProg_39
       move.b    -297(A6),D0
       and.w     #255,D0
       cmp.w     #192,D0
       blo.s     listProg_41
       move.b    -297(A6),D0
       and.w     #255,D0
       cmp.w     #239,D0
       bls.s     listProg_39
listProg_41:
; vLinhaList[ix++] = 0x20;
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       move.b    #32,0(A0,D0.L)
listProg_39:
       bra       listProg_42
listProg_29:
; /*                    if (*vStartList != 0x28)
; vLinhaList[ix++] = 0x20;*/
; }
; else
; {
; // Apenas inclui na listagem
; //if (strchr("+-*^/=;:><", *vTempPointer) || *vTempPointer >= 0xF0)
; vLinhaList[ix++] = vToken;
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       move.b    -297(A6),0(A0,D0.L)
; // Se nao for aspas e o proximo for um token, inclui um espaço
; if (vToken == 0x22 && *vStartList >=0x80)
       move.b    -297(A6),D0
       cmp.b     #34,D0
       bne.s     listProg_42
       move.l    -594(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     listProg_42
; vLinhaList[ix++] = 0x20;
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       move.b    #32,0(A0,D0.L)
listProg_42:
       bra       listProg_26
listProg_28:
; /*if (isdigitus(vToken) && *vStartList!=')' && *vStartList!='.' && *vStartList!='"' && !isdigitus(*vStartList))
; vLinhaList[ix++] = 0x20;*/
; }
; }
; vLinhaList[ix] = '\0';
       move.l    -292(A6),D0
       lea       -564(A6),A0
       clr.b     0(A0,D0.L)
; iw = strlen(vLinhaList) / 40;
       pea       -564(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-(A7)
       pea       40
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-296(A6)
; vLinhaList[ix++] = '\r';
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       move.b    #13,0(A0,D0.L)
; vLinhaList[ix++] = '\n';
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       move.b    #10,0(A0,D0.L)
; vLinhaList[ix++] = '\0';
       move.l    -292(A6),D0
       addq.l    #1,-292(A6)
       lea       -564(A6),A0
       clr.b     0(A0,D0.L)
; printText(vLinhaList);
       pea       -564(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vPauseRowCounter = vPauseRowCounter + 1 + iw;
       move.l    -280(A6),D0
       addq.l    #1,D0
       add.l     -296(A6),D0
       move.l    D0,-280(A6)
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
       move.l    A5,A0
       add.l     #_vdpMaxRows,A0
       move.b    (A0),D0
       and.l     #255,D0
       cmp.l     -280(A6),D0
       bhi       listProg_46
; {
; printText("press any key to continue\0");
       move.l    A5,A0
       add.l     #@basic_119,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vtec = inputLineBasic(&vbufInput, 1,"@");
       move.l    A5,A0
       add.l     #@basic_120,A0
       move.l    A0,-(A7)
       pea       1
       pea       -256(A6)
       jsr       _inputLineBasic
       add.w     #12,A7
       move.b    D0,-565(A6)
; vPauseRowCounter = 0;
       clr.l     -280(A6)
; printText("\r\n\0");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; if (vtec == 0x1B)   // ESC
       move.b    -565(A6),D0
       cmp.b     #27,D0
       bne.s     listProg_46
; break;
       bra.s     listProg_18
listProg_46:
; }
; vStartList = vNextList;
       move.l    -590(A6),-594(A6)
       bra.s     listProg_20
listProg_19:
; }
; else
; break;
       bra.s     listProg_18
listProg_20:
       bra       listProg_16
listProg_18:
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
       link      A6,#-320
; unsigned short pIni = 0, pFim = 0xFFFF;
       clr.w     -320(A6)
       move.w    #65535,-318(A6)
; unsigned char *vStartList = pStartProg;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),-316(A6)
; unsigned long vDelAddr, vAntAddr, vNewAddr;
; unsigned short vNumLin;
; char sNumLin [sizeof(short)*8+1];
; unsigned char vLinhaList[255], sNumPar[10], vToken;
; int ix, iy, iz;
; if (pArg[0] != 0x00 && strchr(pArg,'-') != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq       delLine_1
       pea       45
       move.l    8(A6),-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq       delLine_1
; {
; ix = 0;
       clr.l     -12(A6)
; iy = 0;
       clr.l     -8(A6)
; // listar intervalo
; while (pArg[ix] != '-')
delLine_3:
       move.l    8(A6),A0
       move.l    -12(A6),D0
       move.b    0(A0,D0.L),D0
       cmp.b     #45,D0
       beq.s     delLine_5
; sNumPar[iy++] = pArg[ix++];
       move.l    8(A6),A0
       move.l    -12(A6),D0
       addq.l    #1,-12(A6)
       move.l    -8(A6),D1
       addq.l    #1,-8(A6)
       move.b    0(A0,D0.L),-24(A6,D1.L)
       bra       delLine_3
delLine_5:
; sNumPar[iy] = 0x00;
       move.l    -8(A6),D0
       clr.b     -24(A6,D0.L)
; pIni = atoi(sNumPar);
       pea       -24(A6)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-320(A6)
; iy = 0;
       clr.l     -8(A6)
; ix++;
       addq.l    #1,-12(A6)
; while (pArg[ix])
delLine_6:
       move.l    8(A6),A0
       move.l    -12(A6),D0
       tst.b     0(A0,D0.L)
       beq.s     delLine_8
; sNumPar[iy++] = pArg[ix++];
       move.l    8(A6),A0
       move.l    -12(A6),D0
       addq.l    #1,-12(A6)
       move.l    -8(A6),D1
       addq.l    #1,-8(A6)
       move.b    0(A0,D0.L),-24(A6,D1.L)
       bra       delLine_6
delLine_8:
; sNumPar[iy] = 0x00;
       move.l    -8(A6),D0
       clr.b     -24(A6,D0.L)
; if (sNumPar[0])
       tst.b     -24+0(A6)
       beq.s     delLine_9
; pFim = atoi(sNumPar);
       pea       -24(A6)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-318(A6)
       bra.s     delLine_10
delLine_9:
; else
; pFim = 0xFFFF;
       move.w    #65535,-318(A6)
delLine_10:
       bra       delLine_12
delLine_1:
; }
; else if (pArg[0] != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq.s     delLine_11
; {
; pIni = atoi(pArg);
       move.l    8(A6),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.w    D0,-320(A6)
; pFim = pIni;
       move.w    -320(A6),-318(A6)
       bra.s     delLine_12
delLine_11:
; }
; else
; {
; printText("Syntax Error !");
       move.l    A5,A0
       add.l     #@basic_121,A0
       move.l    A0,-(A7)
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
       move.w    -320(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-312(A6)
; if (!vDelAddr)
       tst.l     -312(A6)
       bne.s     delLine_14
; {
; printText("Non-existent line number\r\n\0");
       move.l    A5,A0
       add.l     #@basic_118,A0
       move.l    A0,-(A7)
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
       move.l    -312(A6),-316(A6)
; // Guarda proxima posicao
; vNewAddr = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    -316(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    -316(A6),A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    -316(A6),A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-304(A6)
; if (!vNewAddr)
       tst.l     -304(A6)
       bne.s     delLine_19
; break;
       bra       delLine_18
delLine_19:
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    -316(A6),A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    -316(A6),A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-300(A6)
; if (vNumLin > pFim)
       move.w    -300(A6),D0
       cmp.w     -318(A6),D0
       bls.s     delLine_21
; break;
       bra       delLine_18
delLine_21:
; vAntAddr = findNumberLine(vNumLin, 1, 1);
       pea       1
       pea       1
       move.w    -300(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-308(A6)
; // Apaga a linha atual
; *vStartList       = 0x00;
       move.l    -316(A6),A0
       clr.b     (A0)
; *(vStartList + 1) = 0x00;
       move.l    -316(A6),A0
       clr.b     1(A0)
; *(vStartList + 2) = 0x00;
       move.l    -316(A6),A0
       clr.b     2(A0)
; *(vStartList + 3) = 0x00;
       move.l    -316(A6),A0
       clr.b     3(A0)
; *(vStartList + 4) = 0x00;
       move.l    -316(A6),A0
       clr.b     4(A0)
; vStartList += 5;
       addq.l    #5,-316(A6)
; while (*vStartList)
delLine_23:
       move.l    -316(A6),A0
       tst.b     (A0)
       beq.s     delLine_25
; *vStartList++ = 0x00;
       move.l    -316(A6),A0
       addq.l    #1,-316(A6)
       clr.b     (A0)
       bra       delLine_23
delLine_25:
; vStartList = vAntAddr;
       move.l    -308(A6),-316(A6)
; *vStartList++ = ((vNewAddr & 0xFF0000) >> 16);
       move.l    -304(A6),D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    -316(A6),A0
       addq.l    #1,-316(A6)
       move.b    D0,(A0)
; *vStartList++ = ((vNewAddr & 0xFF00) >> 8);
       move.l    -304(A6),D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    -316(A6),A0
       addq.l    #1,-316(A6)
       move.b    D0,(A0)
; *vStartList++ =  (vNewAddr & 0xFF);
       move.l    -304(A6),D0
       and.l     #255,D0
       move.l    -316(A6),A0
       addq.l    #1,-316(A6)
       move.b    D0,(A0)
; // Se for a primeira linha, reposiciona na proxima
; if (*firstLineNumber == vNumLin)
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       move.w    (A0),D0
       cmp.w     -300(A6),D0
       bne       delLine_29
; {
; if (vNewAddr)
       tst.l     -304(A6)
       beq       delLine_28
; {
; vStartList = vNewAddr;
       move.l    -304(A6),-316(A6)
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    -316(A6),A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    -316(A6),A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-300(A6)
; *firstLineNumber = vNumLin;
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       move.w    -300(A6),(A0)
; *addrFirstLineNumber = vNewAddr;
       move.l    A5,A0
       add.l     #_addrFirstLineNumber,A0
       move.l    (A0),A0
       move.l    -304(A6),(A0)
       bra       delLine_29
delLine_28:
; }
; else
; {
; *pStartProg = 0x00;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),A0
       clr.b     (A0)
; *(pStartProg + 1) = 0x00;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),A0
       clr.b     1(A0)
; *(pStartProg + 2) = 0x00;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),A0
       clr.b     2(A0)
; *nextAddrLine = pStartProg;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    A5,A1
       add.l     #_nextAddrLine,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *firstLineNumber = 0;
       move.l    A5,A0
       add.l     #_firstLineNumber,A0
       move.l    (A0),A0
       clr.w     (A0)
; *addrFirstLineNumber = 0;
       move.l    A5,A0
       add.l     #_addrFirstLineNumber,A0
       move.l    (A0),A0
       clr.l     (A0)
delLine_29:
; }
; }
; if (!vNewAddr)
       tst.l     -304(A6)
       bne.s     delLine_30
; break;
       bra.s     delLine_18
delLine_30:
; vDelAddr = vNewAddr;
       move.l    -304(A6),-312(A6)
       bra       delLine_16
delLine_18:
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; // Sintaxe:
; //      EDIT <num>          : Edita conteudo da linha <num>
; //-----------------------------------------------------------------------------
; void editLine(unsigned char *pNumber)
; {
       xdef      _editLine
_editLine:
       link      A6,#-584
; int pIni = 0, ix, iy, iz, iw, ivv, vNumLin, pFim;
       clr.l     -584(A6)
; unsigned char *vStartList = pStartProg, *vNextList;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),-552(A6)
; unsigned char vRetInput;
; char sNumLin [sizeof(short)*8+1], vFirstByte;
; unsigned char vLinhaList[255], sNumPar[10], vToken;
; unsigned char vbufInput[256];
; if (pNumber[0] != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq.s     editLine_1
; {
; // rodar desde uma linha especifica
; pIni = atoi(pNumber);
       move.l    8(A6),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-584(A6)
       bra.s     editLine_2
editLine_1:
; }
; else
; {
; printText("Syntax Error !");
       move.l    A5,A0
       add.l     #@basic_121,A0
       move.l    A0,-(A7)
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
       move.l    -584(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-552(A6)
; // Nao achou numero de linha inicial
; if (!vStartList)
       tst.l     -552(A6)
       bne.s     editLine_4
; {
; printText("Non-existent line number\r\n\0");
       move.l    A5,A0
       add.l     #@basic_118,A0
       move.l    A0,-(A7)
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
       move.l    -552(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    -552(A6),A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    -552(A6),A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-548(A6)
; ix = 0;
       clr.l     -580(A6)
; ivv = 0;
       clr.l     -564(A6)
; if (vNextList)
       tst.l     -548(A6)
       beq       editLine_13
; {
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    -552(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    -552(A6),A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-560(A6)
; vStartList += 5;
       addq.l    #5,-552(A6)
; // Coloca numero da linha na listagem
; itoa(vNumLin, sNumLin, 10);
       pea       10
       pea       -542(A6)
       move.l    -560(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; iz = 0;
       clr.l     -572(A6)
; while (sNumLin[iz++])
editLine_8:
       move.l    -572(A6),D0
       addq.l    #1,-572(A6)
       lea       -542(A6),A0
       tst.b     0(A0,D0.L)
       beq.s     editLine_10
; {
; vLinhaList[ivv] = sNumLin[ivv];
       move.l    -564(A6),D0
       lea       -542(A6),A0
       move.l    -564(A6),D1
       lea       -524(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
; ivv++;
       addq.l    #1,-564(A6)
       bra       editLine_8
editLine_10:
; }
; vLinhaList[ivv] = '\r';
       move.l    -564(A6),D0
       lea       -524(A6),A0
       move.b    #13,0(A0,D0.L)
; vLinhaList[ivv + 1] = '\n';
       move.l    -564(A6),A0
       lea       -524(A6),A1
       move.b    #10,0(A0,A1.L)
; vLinhaList[ivv + 2] = '\0';
       move.l    -564(A6),A0
       lea       -524(A6),A1
       clr.b     0(A0,A1.L)
; printText(vLinhaList);
       pea       -524(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vFirstByte = 1;
       move.b    #1,-525(A6)
; vbufInput[ix] = 0x00;
       move.l    -580(A6),D0
       lea       -256(A6),A0
       clr.b     0(A0,D0.L)
; ix = 0;
       clr.l     -580(A6)
; // Pega caracter a caracter da linha
; while (*vStartList)
editLine_11:
       move.l    -552(A6),A0
       tst.b     (A0)
       beq       editLine_13
; {
; vToken = *vStartList++;
       move.l    -552(A6),A0
       addq.l    #1,-552(A6)
       move.b    (A0),-257(A6)
; // Verifica se é token, se for, muda pra escrito
; if (vToken >= 0x80)
       move.b    -257(A6),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo       editLine_14
; {
; // Procura token na lista
; iy = findToken(vToken);
       move.b    -257(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _findToken
       addq.w    #4,A7
       move.l    D0,-576(A6)
; iz = 0;
       clr.l     -572(A6)
; if (!vFirstByte)
       tst.b     -525(A6)
       bne       editLine_16
; {
; if (isalphas(*(vStartList - 2)) || isdigitus(*(vStartList - 2)) || *(vStartList - 2) == ')')
       move.l    -552(A6),D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne       editLine_20
       move.l    -552(A6),D1
       subq.l    #2,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       bne.s     editLine_20
       move.l    -552(A6),D0
       subq.l    #2,D0
       move.l    D0,A0
       move.b    (A0),D0
       cmp.b     #41,D0
       bne.s     editLine_18
editLine_20:
; vbufInput[ix++] = 0x20;
       move.l    -580(A6),D0
       addq.l    #1,-580(A6)
       lea       -256(A6),A0
       move.b    #32,0(A0,D0.L)
editLine_18:
       bra.s     editLine_17
editLine_16:
; }
; else
; vFirstByte = 0;
       clr.b     -525(A6)
editLine_17:
; while (keywords[iy].keyword[iz])
editLine_21:
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.l    -576(A6),D0
       lsl.l     #3,D0
       move.l    0(A0,D0.L),A0
       move.l    -572(A6),D0
       tst.b     0(A0,D0.L)
       beq.s     editLine_23
; {
; vbufInput[ix++] = keywords[iy].keyword[iz++];
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.l    -576(A6),D0
       lsl.l     #3,D0
       move.l    0(A0,D0.L),A0
       move.l    -572(A6),D0
       addq.l    #1,-572(A6)
       move.l    -580(A6),D1
       addq.l    #1,-580(A6)
       lea       -256(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra       editLine_21
editLine_23:
; }
; // Se nao for intervalo de funcao, coloca espaço depois do comando
; if (*vStartList != '=' && (vToken < 0xC0 || vToken > 0xEF))
       move.l    -552(A6),A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     editLine_24
       move.b    -257(A6),D0
       and.w     #255,D0
       cmp.w     #192,D0
       blo.s     editLine_26
       move.b    -257(A6),D0
       and.w     #255,D0
       cmp.w     #239,D0
       bls.s     editLine_24
editLine_26:
; vbufInput[ix++] = 0x20;
       move.l    -580(A6),D0
       addq.l    #1,-580(A6)
       lea       -256(A6),A0
       move.b    #32,0(A0,D0.L)
editLine_24:
       bra       editLine_27
editLine_14:
; }
; else
; {
; vbufInput[ix++] = vToken;
       move.l    -580(A6),D0
       addq.l    #1,-580(A6)
       lea       -256(A6),A0
       move.b    -257(A6),0(A0,D0.L)
; // Se nao for aspas e o proximo for um token, inclui um espaço
; if (vToken == 0x22 && *vStartList >=0x80)
       move.b    -257(A6),D0
       cmp.b     #34,D0
       bne.s     editLine_27
       move.l    -552(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     editLine_27
; vbufInput[ix++] = 0x20;            }
       move.l    -580(A6),D0
       addq.l    #1,-580(A6)
       lea       -256(A6),A0
       move.b    #32,0(A0,D0.L)
editLine_27:
       bra       editLine_11
editLine_13:
; }
; }
; vbufInput[ix] = '\0';
       move.l    -580(A6),D0
       lea       -256(A6),A0
       clr.b     0(A0,D0.L)
; // Edita a linha no buffer, usando o inputLineBasic do monitor.c
; vRetInput = inputLineBasic(&vbufInput, 128,'S'); // S - String Linha Editavel
       pea       83
       pea       128
       pea       -256(A6)
       jsr       _inputLineBasic
       add.w     #12,A7
       move.b    D0,-543(A6)
; if (vbufInput[0] != 0x00 && (vRetInput == 0x0D || vRetInput == 0x0A))
       move.b    -256+0(A6),D0
       beq       editLine_29
       move.b    -543(A6),D0
       cmp.b     #13,D0
       beq.s     editLine_31
       move.b    -543(A6),D0
       cmp.b     #10,D0
       bne       editLine_29
editLine_31:
; {
; vLinhaList[ivv++] = 0x20;
       move.l    -564(A6),D0
       addq.l    #1,-564(A6)
       lea       -524(A6),A0
       move.b    #32,0(A0,D0.L)
; ix = strlen(vbufInput);
       pea       -256(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-580(A6)
; for(iz = 0; iz <= ix; iz++)
       clr.l     -572(A6)
editLine_32:
       move.l    -572(A6),D0
       cmp.l     -580(A6),D0
       bgt.s     editLine_34
; vLinhaList[ivv++] = vbufInput[iz];
       move.l    -572(A6),D0
       lea       -256(A6),A0
       move.l    -564(A6),D1
       addq.l    #1,-564(A6)
       lea       -524(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-572(A6)
       bra       editLine_32
editLine_34:
; vLinhaList[ivv] = 0x00;
       move.l    -564(A6),D0
       lea       -524(A6),A0
       clr.b     0(A0,D0.L)
; for(iz = 0; iz <= ivv; iz++)
       clr.l     -572(A6)
editLine_35:
       move.l    -572(A6),D0
       cmp.l     -564(A6),D0
       bgt.s     editLine_37
; vbufInput[iz] = vLinhaList[iz];
       move.l    -572(A6),D0
       lea       -524(A6),A0
       move.l    -572(A6),D1
       lea       -256(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-572(A6)
       bra       editLine_35
editLine_37:
; printText("\r\n\0");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; // Apaga a linha atual
; delLine(pNumber);
       move.l    8(A6),-(A7)
       jsr       _delLine
       addq.w    #4,A7
; // Reinsere a linha editada
; processLine(vbufInput);
       pea       -256(A6)
       jsr       _processLine
       addq.w    #4,A7
; printText("\r\nOK\0");
       move.l    A5,A0
       add.l     #@basic_99,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra.s     editLine_38
editLine_29:
; }
; else if (vRetInput != 0x1B)
       move.b    -543(A6),D0
       cmp.b     #27,D0
       beq.s     editLine_38
; {
; printText("\r\nAborted !!!\r\n\0");
       move.l    A5,A0
       add.l     #@basic_122,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
editLine_38:
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
       link      A6,#-632
; // Default rodar desde a primeira linha
; int pIni = 0, ix;
       clr.l     -630(A6)
; unsigned char *vStartList = pStartProg;
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    (A0),-622(A6)
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
       move.l    A5,A0
       add.l     #_forStack,A0
       move.l    (A0),-30(A6)
; unsigned char sqtdtam[20];
; unsigned char *vTempPointer;
; unsigned char vBufRec;
; *nextAddrSimpVar = pStartSimpVar;
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    A5,A1
       add.l     #_nextAddrSimpVar,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *nextAddrArrayVar = pStartArrayVar;
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    A5,A1
       add.l     #_nextAddrArrayVar,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *nextAddrString = pStartString;
       move.l    A5,A0
       add.l     #_pStartString,A0
       move.l    A5,A1
       add.l     #_nextAddrString,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; for (ix = 0; ix < 0x2000; ix++)
       clr.l     -626(A6)
runProg_1:
       move.l    -626(A6),D0
       cmp.l     #8192,D0
       bge.s     runProg_3
; *(pStartSimpVar + ix) = 0x00;
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    (A0),A0
       move.l    -626(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-626(A6)
       bra       runProg_1
runProg_3:
; for (ix = 0; ix < 0x6000; ix++)
       clr.l     -626(A6)
runProg_4:
       move.l    -626(A6),D0
       cmp.l     #24576,D0
       bge.s     runProg_6
; *(pStartArrayVar + ix) = 0x00;
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    (A0),A0
       move.l    -626(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-626(A6)
       bra       runProg_4
runProg_6:
; for (ix = 0; ix < 0x800; ix++)
       clr.l     -626(A6)
runProg_7:
       move.l    -626(A6),D0
       cmp.l     #2048,D0
       bge.s     runProg_9
; *(pForStack + ix) = 0x00;
       move.l    -30(A6),A0
       move.l    -626(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-626(A6)
       bra       runProg_7
runProg_9:
; if (pNumber[0] != 0x00)
       move.l    8(A6),A0
       move.b    (A0),D0
       beq.s     runProg_10
; {
; // rodar desde uma linha especifica
; pIni = atoi(pNumber);
       move.l    8(A6),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-630(A6)
runProg_10:
; }
; vStartList = findNumberLine(pIni, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    -630(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-622(A6)
; // Nao achou numero de linha inicial
; if (!vStartList)
       tst.l     -622(A6)
       bne.s     runProg_12
; {
; printText("Non-existent line number\r\n\0");
       move.l    A5,A0
       add.l     #@basic_118,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       runProg_52
runProg_12:
; }
; vNextList = vStartList;
       move.l    -622(A6),-618(A6)
; *ftos=0;
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       clr.l     (A0)
; *gtos=0;
       move.l    A5,A0
       add.l     #_gtos,A0
       move.l    (A0),A0
       clr.l     (A0)
; *changedPointer = 0;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       clr.l     (A0)
; *vDataPointer = 0;
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       clr.l     (A0)
; *randSeed = fsGetMfp(MFP_REG_TADR);
       pea       31
       move.l    8486760,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_randSeed,A0
       move.l    (A0),A0
       move.l    D0,(A0)
; *onErrGoto = 0;
       move.l    A5,A0
       add.l     #_onErrGoto,A0
       move.l    (A0),A0
       clr.l     (A0)
; while (1)
runProg_15:
; {
; if (*changedPointer!=0)
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    (A0),D0
       beq.s     runProg_18
; vStartList = *changedPointer;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    (A0),-622(A6)
runProg_18:
; // Guarda proxima posicao
; vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    -622(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    -622(A6),A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    -622(A6),A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-618(A6)
; *nextAddr = vNextList;
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
       move.l    -618(A6),(A0)
; if (vNextList)
       tst.l     -618(A6)
       beq       runProg_20
; {
; // Pega numero da linha
; vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);
       move.l    -622(A6),A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    -622(A6),A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-614(A6)
; vStartList += 5;
       addq.l    #5,-622(A6)
; // Pega caracter a caracter da linha
; *changedPointer = 0;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       clr.l     (A0)
; *vMaisTokens = 0;
       move.l    A5,A0
       add.l     #_vMaisTokens,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vParenteses = 0x00;
       move.l    A5,A0
       add.l     #_vParenteses,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemIf = 0x00;
       move.l    A5,A0
       add.l     #_vTemIf,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemThen = 0;
       move.l    A5,A0
       add.l     #_vTemThen,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemElse = 0;
       move.l    A5,A0
       add.l     #_vTemElse,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vTemIfAndOr = 0x00;
       move.l    A5,A0
       add.l     #_vTemIfAndOr,A0
       move.l    (A0),A0
       clr.b     (A0)
; vRetInf.tString[0] = 0x00;
       lea       -348(A6),A0
       clr.b     (A0)
; *pointerRunProg = vStartList;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    -622(A6),(A0)
; *vErroProc = 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       clr.w     (A0)
; do
; {
runProg_22:
; vBufRec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,-1(A6)
; if (vBufRec==27)
       move.b    -1(A6),D0
       cmp.b     #27,D0
       bne       runProg_24
; {
; // volta para modo texto
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #3,D0
       beq.s     runProg_26
; basText();
       jsr       _basText
runProg_26:
; #endif
; // mostra mensagem de para subita
; printText("\r\nStopped at ");
       move.l    A5,A0
       add.l     #@basic_123,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vNumLin, sNumLin, 10);
       pea       10
       pea       -86(A6)
       move.w    -614(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sNumLin);
       pea       -86(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; // sai do laço
; *nextAddr = 0;
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
       clr.l     (A0)
; break;
       bra       runProg_23
runProg_24:
; }
; *doisPontos = 0;
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vParenteses = 0x00;
       move.l    A5,A0
       add.l     #_vParenteses,A0
       move.l    (A0),A0
       clr.b     (A0)
; *vInicioSentenca = 1;
       move.l    A5,A0
       add.l     #_vInicioSentenca,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; if (*traceOn)
       move.l    A5,A0
       add.l     #_traceOn,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq       runProg_28
; {
; printText("\r\nExecuting at ");
       move.l    A5,A0
       add.l     #@basic_124,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vNumLin, sNumLin, 10);
       pea       10
       pea       -86(A6)
       move.w    -614(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sNumLin);
       pea       -86(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
runProg_28:
; }
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-6(A6)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vReta = executeToken(*vTempPointer);
       move.l    -6(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _executeToken
       addq.w    #4,A7
       move.l    D0,-90(A6)
; if (*vErroProc)
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq       runProg_30
; {
; if (*onErrGoto == 0)
       move.l    A5,A0
       add.l     #_onErrGoto,A0
       move.l    (A0),A0
       move.l    (A0),D0
       bne.s     runProg_32
; break;
       bra       runProg_23
runProg_32:
; *vErroProc = 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       clr.w     (A0)
; *changedPointer = *onErrGoto;
       move.l    A5,A0
       add.l     #_onErrGoto,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_changedPointer,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
runProg_30:
; }
; if (*changedPointer!=0)
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    (A0),D0
       beq       runProg_36
; {
; vPointerChangedPointer = *changedPointer;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    (A0),-34(A6)
; if (*vPointerChangedPointer == 0x3A)
       move.l    -34(A6),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     runProg_36
; {
; *pointerRunProg = *changedPointer;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_pointerRunProg,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *changedPointer = 0;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       clr.l     (A0)
runProg_36:
; }
; }
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-6(A6)
; if (*vTempPointer != 0x00)
       move.l    -6(A6),A0
       move.b    (A0),D0
       beq       runProg_44
; {
; if (*vTempPointer == 0x3A)
       move.l    -6(A6),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     runProg_40
; {
; *doisPontos = 1;
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
       bra       runProg_44
runProg_40:
; }
; else
; {
; if (*doisPontos && *vTempPointer <= 0x80)
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       beq.s     runProg_42
       move.l    -6(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       bhi.s     runProg_42
; {
; // nao faz nada
; }
       bra.s     runProg_44
runProg_42:
; else
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) break;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     runProg_44
       bra.s     runProg_23
runProg_44:
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       tst.b     (A0)
       bne       runProg_22
runProg_23:
; }
; }
; }
; } while (*doisPontos);
; if (*vErroProc)
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq       runProg_46
; {
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #3,D0
       beq.s     runProg_48
; basText();
       jsr       _basText
runProg_48:
; #endif
; showErrorMessage(*vErroProc, vNumLin);
       move.w    -614(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    (A0),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _showErrorMessage
       addq.w    #8,A7
; break;
       bra.s     runProg_17
runProg_46:
; }
; if (*nextAddr == 0)
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
       move.l    (A0),D0
       bne.s     runProg_50
; break;
       bra.s     runProg_17
runProg_50:
; vNextList = *nextAddr;
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
       move.l    (A0),-618(A6)
; vStartList = vNextList;
       move.l    -618(A6),-622(A6)
       bra.s     runProg_21
runProg_20:
; }
; else
; break;
       bra.s     runProg_17
runProg_21:
       bra       runProg_15
runProg_17:
; }
; #ifndef __TESTE_TOKENIZE__
; if (vdpModeBas != VDP_MODE_TEXT)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #3,D0
       beq.s     runProg_52
; basText();
       jsr       _basText
runProg_52:
       unlk      A6
       rts
; #endif
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; void showErrorMessage(unsigned int pError, unsigned int pNumLine)
; {
       xdef      _showErrorMessage
_showErrorMessage:
       link      A6,#-20
; char sNumLin [sizeof(short)*8+1];
; printText("\r\n");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(listError[pError]);
       move.l    A5,A0
       add.l     #@basic_listError,A0
       move.l    8(A6),D1
       lsl.l     #2,D1
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
       move.l    A5,A0
       add.l     #@basic_125,A0
       move.l    A0,-(A7)
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
       move.l    A5,A0
       add.l     #@basic_126,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; *vErroProc = 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       clr.w     (A0)
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; int executeToken(unsigned char pToken)
; {
       xdef      _executeToken
_executeToken:
       link      A6,#-32
; char vReta = 0;
       clr.b     -29(A6)
; #ifndef __TESTE_TOKENIZE__
; unsigned char *pForStack = forStack;
       move.l    A5,A0
       add.l     #_forStack,A0
       move.l    (A0),-28(A6)
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
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_4:
; case 0x80:  // Let
; vReta = basLet();
       jsr       _basLet
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_5:
; case 0x81:  // Print
; vReta = basPrint();
       jsr       _basPrint
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_6:
; case 0x82:  // IF
; vReta = basIf();
       jsr       _basIf
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_7:
; case 0x83:  // THEN - nao faz nada
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_8:
; case 0x85:  // FOR
; vReta = basFor();
       jsr       _basFor
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_9:
; case 0x86:  // TO - nao faz nada
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_10:
; case 0x87:  // NEXT
; vReta = basNext();
       jsr       _basNext
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_11:
; case 0x88:  // STEP - nao faz nada
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_12:
; case 0x89:  // GOTO
; vReta = basGoto();
       jsr       _basGoto
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_13:
; case 0x8A:  // GOSUB
; vReta = basGosub();
       jsr       _basGosub
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_14:
; case 0x8B:  // RETURN
; vReta = basReturn();
       jsr       _basReturn
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_15:
; case 0x8C:  // REM - Ignora todas a linha depois dele
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_16:
; case 0x8D:  // INVERSE
; vReta = basInverse();
       jsr       _basInverse
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_17:
; case 0x8E:  // NORMAL
; vReta = basNormal();
       jsr       _basNormal
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_18:
; case 0x8F:  // DIM
; vReta = basDim();
       jsr       _basDim
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_19:
; case 0x90:  // Nao fax nada, soh teste, pode ser retirado
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_20:
; case 0x91:  // ON
; vReta = basOnVar();
       jsr       _basOnVar
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_21:
; case 0x92:  // Input
; vReta = basInputGet(250);
       pea       250
       jsr       _basInputGet
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_22:
; case 0x93:  // Get
; vReta = basInputGet(1);
       pea       1
       jsr       _basInputGet
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_23:
; case 0x94:  // LOCATE
; vReta = basLocate();
       jsr       _basLocate
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_24:
; case 0x95:  // HTAB
; vReta = basHtab();
       jsr       _basHtab
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_25:
; case 0x96:  // Home
; switch(vdpModeBas)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       and.l     #255,D0
       cmp.l     #4,D0
       bhs       executeToken_99
       asl.l     #1,D0
       move.w    executeToken_100(PC,D0.L),D0
       jmp       executeToken_100(PC,D0.W)
executeToken_100:
       dc.w      executeToken_102-executeToken_100
       dc.w      executeToken_103-executeToken_100
       dc.w      executeToken_104-executeToken_100
       dc.w      executeToken_101-executeToken_100
executeToken_101:
; {
; case VDP_MODE_TEXT:
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; break;
       bra       executeToken_99
executeToken_102:
; case VDP_MODE_G1:
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; break;
       bra.s     executeToken_99
executeToken_103:
; case VDP_MODE_G2:
; clearScrW(bgcolorBas);
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _clearScrW
       addq.w    #4,A7
; break;
       bra.s     executeToken_99
executeToken_104:
; case VDP_MODE_MULTICOLOR:
; clearScrW(bgcolorBas);
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _clearScrW
       addq.w    #4,A7
; break;
executeToken_99:
; }
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; break;
       bra       executeToken_115
executeToken_26:
; case 0x97:  // CLEAR - Clear all variables
; for (ix = 0; ix < 0x2000; ix++)
       clr.l     -24(A6)
executeToken_105:
       move.l    -24(A6),D0
       cmp.l     #8192,D0
       bge.s     executeToken_107
; *(pStartSimpVar + ix) = 0x00;
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    (A0),A0
       move.l    -24(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-24(A6)
       bra       executeToken_105
executeToken_107:
; for (ix = 0; ix < 0x6000; ix++)
       clr.l     -24(A6)
executeToken_108:
       move.l    -24(A6),D0
       cmp.l     #24576,D0
       bge.s     executeToken_110
; *(pStartArrayVar + ix) = 0x00;
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    (A0),A0
       move.l    -24(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-24(A6)
       bra       executeToken_108
executeToken_110:
; for (ix = 0; ix < 0x800; ix++)
       clr.l     -24(A6)
executeToken_111:
       move.l    -24(A6),D0
       cmp.l     #2048,D0
       bge.s     executeToken_113
; *(pForStack + ix) = 0x00;
       move.l    -28(A6),A0
       move.l    -24(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-24(A6)
       bra       executeToken_111
executeToken_113:
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_27:
; case 0x98:  // DATA - Ignora toda a linha depois dele, READ vai ler essa linha
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_28:
; case 0x99:  // Read
; vReta = basRead();
       jsr       _basRead
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_29:
; case 0x9A:  // Restore
; vReta = basRestore();
       jsr       _basRestore
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_30:
; case 0x9E:  // END
; vReta = basEnd();
       jsr       _basEnd
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_31:
; case 0x9F:  // STOP
; vReta = basStop();
       jsr       _basStop
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_32:
; case 0xB0:  // Screen
; vReta = basScreen();
       jsr       _basScreen
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_33:
; case 0xB1:  // GR
; vReta = basGr();
       jsr       _basGr
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_34:
; case 0xB2:  // HGR
; vReta = basHgr();
       jsr       _basHgr
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_35:
; case 0xB3:  // COLOR
; vReta = basColor();
       jsr       _basColor
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_36:
; case 0xB4:  // PLOT
; vReta = basPlot();
       jsr       _basPlot
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_37:
; case 0xB5:  // HLIN
; vReta = basHVlin(1);
       pea       1
       jsr       _basHVlin
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_38:
; case 0xB6:  // VLIN
; vReta = basHVlin(2);
       pea       2
       jsr       _basHVlin
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_39:
; case 0xB8:  // HCOLOR
; vReta = basHcolor();
       jsr       _basHcolor
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_40:
; case 0xB9:  // HPLOT
; vReta = basHplot();
       jsr       _basHplot
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_41:
; case 0xBA:  // AT - Nao faz nada
; vReta = 0;
       clr.b     -29(A6)
; break;
       bra       executeToken_115
executeToken_42:
; case 0xBB:  // ONERR
; vReta = basOnErr();
       jsr       _basOnErr
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_43:
; case 0xC4:  // ASC
; vReta = basAsc();
       jsr       _basAsc
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_44:
; case 0xCD:  // PEEK
; vReta = basPeekPoke('R');
       pea       82
       jsr       _basPeekPoke
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_45:
; case 0xCE:  // POKE
; vReta = basPeekPoke('W');
       pea       87
       jsr       _basPeekPoke
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_46:
; case 0xD1:  // RND
; vReta = basRnd();
       jsr       _basRnd
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_47:
; case 0xDB:  // Len
; vReta = basLen();
       jsr       _basLen
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_48:
; case 0xDC:  // Val
; vReta = basVal();
       jsr       _basVal
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_49:
; case 0xDD:  // Str$
; vReta = basStr();
       jsr       _basStr
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_50:
; case 0xE0:  // SCRN
; vReta = basScrn();
       jsr       _basScrn
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_51:
; case 0xE1:  // Chr$
; vReta = basChr();
       jsr       _basChr
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_52:
; case 0xE2:  // Fre(0)
; vReta = basFre();
       jsr       _basFre
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_53:
; case 0xE3:  // Sqrt
; vReta = basTrig(6);
       pea       6
       jsr       _basTrig
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_54:
; case 0xE4:  // Sin
; vReta = basTrig(1);
       pea       1
       jsr       _basTrig
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_55:
; case 0xE5:  // Cos
; vReta = basTrig(2);
       pea       2
       jsr       _basTrig
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_56:
; case 0xE6:  // Tan
; vReta = basTrig(3);
       pea       3
       jsr       _basTrig
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_57:
; case 0xE7:  // Log
; vReta = basTrig(4);
       pea       4
       jsr       _basTrig
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_58:
; case 0xE8:  // Exp
; vReta = basTrig(5);
       pea       5
       jsr       _basTrig
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_59:
; case 0xE9:  // SPC
; vReta = basSpc();
       jsr       _basSpc
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_60:
; case 0xEA:  // Tab
; vReta = basTab();
       jsr       _basTab
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_61:
; case 0xEB:  // Mid$
; vReta = basLeftRightMid('M');
       pea       77
       jsr       _basLeftRightMid
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_62:
; case 0xEC:  // Right$
; vReta = basLeftRightMid('R');
       pea       82
       jsr       _basLeftRightMid
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_63:
; case 0xED:  // Left$
; vReta = basLeftRightMid('L');
       pea       76
       jsr       _basLeftRightMid
       addq.w    #4,A7
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_64:
; case 0xEE:  // INT
; vReta = basInt();
       jsr       _basInt
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_65:
; case 0xEF:  // ABS
; vReta = basAbs();
       jsr       _basAbs
       move.b    D0,-29(A6)
; break;
       bra       executeToken_115
executeToken_1:
; default:
; if (pToken < 0x80)  // variavel sem LET
       move.b    11(A6),D0
       and.w     #255,D0
       cmp.w     #128,D0
       bhs.s     executeToken_114
; {
; *pointerRunProg = *pointerRunProg - 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       subq.l    #1,(A0)
; vReta = basLet();
       jsr       _basLet
       move.b    D0,-29(A6)
       bra.s     executeToken_115
executeToken_114:
; }
; else // Nao forem operadores logicos
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; vReta = 14;
       move.b    #14,-29(A6)
executeToken_115:
; }
; }
; #endif
; return vReta;
       move.b    -29(A6),D0
       ext.w     D0
       ext.l     D0
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; int nextToken(void)
; {
       xdef      _nextToken
_nextToken:
       link      A6,#-36
; unsigned char *temp;
; int vRet, ccc;
; unsigned char sqtdtam[20];
; unsigned char *vTempPointer;
; *token_type = 0;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       clr.b     (A0)
; *tok = 0;
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       clr.b     (A0)
; temp = token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-36(A6)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; if (*vTempPointer >= 0x80 && *vTempPointer < 0xF0)   // is a command
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo       nextToken_1
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       bhs       nextToken_1
; {
; *tok = *vTempPointer;
       move.l    -4(A6),A0
       move.l    A5,A1
       add.l     #_tok,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *token_type = COMMAND;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #4,(A0)
; *token = *vTempPointer;
       move.l    -4(A6),A0
       move.l    A5,A1
       add.l     #_token,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *(token + 1) = 0x00;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     1(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_1:
; }
; if (*vTempPointer == '\0') { // end of file
       move.l    -4(A6),A0
       move.b    (A0),D0
       bne       nextToken_4
; *token = 0;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     (A0)
; *tok = FINISHED;
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    #224,(A0)
; *token_type = DELIMITER;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_4:
; }
; while(iswhite(*vTempPointer)) // skip over white space
nextToken_6:
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _iswhite
       addq.w    #4,A7
       tst.l     D0
       beq.s     nextToken_8
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
       bra       nextToken_6
nextToken_8:
; }
; if (*vTempPointer == '\r') { // crlf
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #13,D0
       bne       nextToken_9
; *pointerRunProg = *pointerRunProg + 2;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #2,(A0)
; *tok = EOL;
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    #226,(A0)
; *token = '\r';
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    #13,(A0)
; *(token + 1) = '\n';
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    #10,1(A0)
; *(token + 2) = 0;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     2(A0)
; *token_type = DELIMITER;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_9:
; }
; if (strchr("+-*^/=;:,><", *vTempPointer) || *vTempPointer >= 0xF0) { // delimiter
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@basic_127,A0
       move.l    A0,-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       bne.s     nextToken_13
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       blo.s     nextToken_14
       moveq     #1,D0
       bra.s     nextToken_15
nextToken_14:
       clr.l     D0
nextToken_15:
       ext.l     D0
       tst.l     D0
       beq       nextToken_11
nextToken_13:
; *temp = *vTempPointer;
       move.l    -4(A6),A0
       move.l    -36(A6),A1
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1; // advance to next position
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; temp++;
       addq.l    #1,-36(A6)
; *temp = 0;
       move.l    -36(A6),A0
       clr.b     (A0)
; *token_type = DELIMITER;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_11:
; }
; if (*vTempPointer == 0x28 || *vTempPointer == 0x29)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       beq.s     nextToken_18
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #41,D0
       bne       nextToken_16
nextToken_18:
; {
; if (*vTempPointer == 0x28)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne.s     nextToken_19
; *token_type = OPENPARENT;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #8,(A0)
       bra.s     nextToken_20
nextToken_19:
; else
; *token_type = CLOSEPARENT;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #9,(A0)
nextToken_20:
; *token = *vTempPointer;
       move.l    -4(A6),A0
       move.l    A5,A1
       add.l     #_token,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *(token + 1) = 0x00;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     1(A0)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_16:
; }
; if (*vTempPointer == ":")
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #@basic_128,A0
       cmp.l     A0,D0
       bne.s     nextToken_21
; {
; *doisPontos = 1;
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       move.b    #1,(A0)
; *token_type = DOISPONTOS;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #7,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_21:
; }
; if (*vTempPointer == '"') { // quoted string
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #34,D0
       bne       nextToken_23
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; while(*vTempPointer != '"'&& *vTempPointer != '\r')
nextToken_25:
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #34,D0
       beq       nextToken_27
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #13,D0
       beq.s     nextToken_27
; {
; *temp++ = *vTempPointer;
       move.l    -4(A6),A0
       move.l    -36(A6),A1
       addq.l    #1,-36(A6)
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
       bra       nextToken_25
nextToken_27:
; }
; if (*vTempPointer == '\r')
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #13,D0
       bne.s     nextToken_28
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       nextToken_3
nextToken_28:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; *temp = 0;
       move.l    -36(A6),A0
       clr.b     (A0)
; *token_type = QUOTE;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #6,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_23:
; }
; if (isdigitus(*vTempPointer)) { // number
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       beq       nextToken_30
; while(!isdelim(*vTempPointer) && (*vTempPointer < 0x80 || *vTempPointer >= 0xF0))
nextToken_32:
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdelim
       addq.w    #4,A7
       tst.l     D0
       bne       nextToken_34
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     nextToken_35
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       blo.s     nextToken_34
nextToken_35:
; {
; *temp++ = *vTempPointer;
       move.l    -4(A6),A0
       move.l    -36(A6),A1
       addq.l    #1,-36(A6)
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
       bra       nextToken_32
nextToken_34:
; }
; *temp = '\0';
       move.l    -36(A6),A0
       clr.b     (A0)
; *token_type = NUMBER;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #3,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_30:
; }
; if (isalphas(*vTempPointer)) { // var or command
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq       nextToken_36
; while(!isdelim(*vTempPointer) && (*vTempPointer < 0x80 || *vTempPointer >= 0xF0))
nextToken_38:
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdelim
       addq.w    #4,A7
       tst.l     D0
       bne       nextToken_40
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #128,D0
       blo.s     nextToken_41
       move.l    -4(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #240,D0
       blo.s     nextToken_40
nextToken_41:
; {
; *temp++ = *vTempPointer;
       move.l    -4(A6),A0
       move.l    -36(A6),A1
       addq.l    #1,-36(A6)
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
       bra       nextToken_38
nextToken_40:
; }
; *temp = '\0';
       move.l    -36(A6),A0
       clr.b     (A0)
; *token_type = VARIABLE;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #2,(A0)
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       bra       nextToken_3
nextToken_36:
; }
; *temp = '\0';
       move.l    -36(A6),A0
       clr.b     (A0)
; // see if a string is a command or a variable
; if (*token_type == STRING) {
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #5,D0
       bne.s     nextToken_42
; *token_type = VARIABLE;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    #2,(A0)
nextToken_42:
; }
; return *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
nextToken_3:
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; int findToken(unsigned char pToken)
; {
       xdef      _findToken
_findToken:
       link      A6,#-4
; unsigned char kt;
; // Procura o Token na lista e devolve a posicao
; for(kt = 0; kt < keywords_count; kt++)
       clr.b     -1(A6)
findToken_1:
       move.b    -1(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_keywords_count,A0
       cmp.l     (A0),D0
       bhs.s     findToken_3
; {
; if (keywords[kt].token == pToken)
       move.l    A5,A0
       add.l     #@basic_keywords,A0
       move.b    -1(A6),D0
       and.l     #255,D0
       lsl.l     #3,D0
       add.l     D0,A0
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     4(A0),D0
       bne.s     findToken_4
; return kt;
       move.b    -1(A6),D0
       and.l     #255,D0
       bra.s     findToken_6
findToken_4:
       addq.b    #1,-1(A6)
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
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; unsigned long findNumberLine(unsigned short pNumber, unsigned char pTipoRet, unsigned char pTipoFind)
; {
       xdef      _findNumberLine
_findNumberLine:
       link      A6,#-44
; unsigned char *vStartList = *addrFirstLineNumber;
       move.l    A5,A0
       add.l     #_addrFirstLineNumber,A0
       move.l    (A0),A0
       move.l    (A0),-44(A6)
; unsigned char *vLastList = *addrFirstLineNumber;
       move.l    A5,A0
       add.l     #_addrFirstLineNumber,A0
       move.l    (A0),A0
       move.l    (A0),-40(A6)
; unsigned short vNumber = 0;
       clr.w     -36(A6)
; char vBuffer [sizeof(long)*8+1];
; if (pNumber)
       tst.w     10(A6)
       beq       findNumberLine_5
; {
; while(vStartList)
findNumberLine_3:
       tst.l     -44(A6)
       beq       findNumberLine_5
; {
; vNumber = ((*(vStartList + 3) << 8) | *(vStartList + 4));
       move.l    -44(A6),A0
       move.b    3(A0),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    -44(A6),A0
       move.b    4(A0),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-36(A6)
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
       move.w    -36(A6),D0
       cmp.w     10(A6),D0
       blo.s     findNumberLine_8
findNumberLine_9:
       move.b    19(A6),D0
       and.l     #255,D0
       beq       findNumberLine_6
       move.w    -36(A6),D0
       cmp.w     10(A6),D0
       beq       findNumberLine_6
findNumberLine_8:
; {
; vLastList = vStartList;
       move.l    -44(A6),-40(A6)
; vStartList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
       move.l    -44(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    -44(A6),A0
       move.b    1(A0),D1
       and.l     #255,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    -44(A6),A0
       move.b    2(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,-44(A6)
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
       move.l    -44(A6),D0
       bra.s     findNumberLine_14
findNumberLine_12:
; else
; return vLastList;
       move.l    -40(A6),D0
findNumberLine_14:
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
; if ((c>0x40 && c<0x5B) || (c>0x60 && c<0x7B))
       move.b    11(A6),D0
       cmp.b     #64,D0
       bls.s     isalphas_4
       move.b    11(A6),D0
       cmp.b     #91,D0
       blo.s     isalphas_3
isalphas_4:
       move.b    11(A6),D0
       cmp.b     #96,D0
       bls.s     isalphas_1
       move.b    11(A6),D0
       cmp.b     #123,D0
       bhs.s     isalphas_1
isalphas_3:
; return 1;
       moveq     #1,D0
       bra.s     isalphas_5
isalphas_1:
; return 0;
       clr.l     D0
isalphas_5:
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
; if (strchr(" ;,+-<>()/*^=:", c) || c==9 || c=='\r' || c==0 || c>=0xF0)
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@basic_116,A0
       move.l    A0,-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       bne       isdelim_3
       move.b    11(A6),D0
       cmp.b     #9,D0
       bne.s     isdelim_4
       moveq     #1,D0
       bra.s     isdelim_5
isdelim_4:
       clr.l     D0
isdelim_5:
       and.l     #255,D0
       bne       isdelim_3
       move.b    11(A6),D0
       cmp.b     #13,D0
       bne.s     isdelim_6
       moveq     #1,D0
       bra.s     isdelim_7
isdelim_6:
       clr.l     D0
isdelim_7:
       and.l     #255,D0
       bne       isdelim_3
       move.b    11(A6),D0
       bne.s     isdelim_8
       moveq     #1,D0
       bra.s     isdelim_9
isdelim_8:
       clr.l     D0
isdelim_9:
       and.l     #255,D0
       bne.s     isdelim_3
       move.b    11(A6),D0
       and.w     #255,D0
       cmp.w     #240,D0
       blo.s     isdelim_10
       moveq     #1,D0
       bra.s     isdelim_11
isdelim_10:
       clr.l     D0
isdelim_11:
       ext.l     D0
       tst.l     D0
       beq.s     isdelim_1
isdelim_3:
; return 1;
       moveq     #1,D0
       bra.s     isdelim_12
isdelim_1:
; return 0;
       clr.l     D0
isdelim_12:
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
; // Load basic program in memory, throught xmodem protocol
; // Syntaxe:
; //          XBASLOAD
; //--------------------------------------------------------------------------------------
; int basXBasLoad(void)
; {
       xdef      _basXBasLoad
_basXBasLoad:
       link      A6,#-268
; unsigned char vRet = 0;
       clr.b     -266(A6)
; unsigned char vByte = 0;
       clr.b     -265(A6)
; unsigned char *vTemp = pStartXBasLoad;
       move.l    A5,A0
       add.l     #_pStartXBasLoad,A0
       move.l    (A0),-264(A6)
; unsigned char vbufInput[256];
; unsigned char *vBufptr = vbufInput;
       lea       -260(A6),A0
       move.l    A0,-4(A6)
; printText("Loading Basic Program...\r\n");
       move.l    A5,A0
       add.l     #@basic_129,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; // Carrega programa em outro ponto da memoria
; vRet = loadSerialToMem(pStartXBasLoad,0);
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_pStartXBasLoad,A0
       move.l    (A0),-(A7)
       move.l    1070,A0
       jsr       (A0)
       addq.w    #8,A7
       move.b    D0,-266(A6)
; // Se tudo OK, tokeniza como se estivesse sendo digitado
; if (!vRet)
       tst.b     -266(A6)
       bne       basXBasLoad_1
; {
; printText("Done.\r\n");
       move.l    A5,A0
       add.l     #@basic_130,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Processing...\r\n");
       move.l    A5,A0
       add.l     #@basic_131,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; while (1)
basXBasLoad_3:
; {
; vByte = *vTemp++;
       move.l    -264(A6),A0
       addq.l    #1,-264(A6)
       move.b    (A0),-265(A6)
; if (vByte != 0x1A)
       move.b    -265(A6),D0
       cmp.b     #26,D0
       beq       basXBasLoad_6
; {
; if (vByte != 0xD && vByte != 0x0A)
       move.b    -265(A6),D0
       cmp.b     #13,D0
       beq.s     basXBasLoad_8
       move.b    -265(A6),D0
       cmp.b     #10,D0
       beq.s     basXBasLoad_8
; *vBufptr++ = vByte;
       move.l    -4(A6),A0
       addq.l    #1,-4(A6)
       move.b    -265(A6),(A0)
       bra.s     basXBasLoad_9
basXBasLoad_8:
; else
; {
; vTemp++;
       addq.l    #1,-264(A6)
; *vBufptr = 0x00;
       move.l    -4(A6),A0
       clr.b     (A0)
; vBufptr = vbufInput;
       lea       -260(A6),A0
       move.l    A0,-4(A6)
; processLine(vbufInput);
       pea       -260(A6)
       jsr       _processLine
       addq.w    #4,A7
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
       move.l    A5,A0
       add.l     #@basic_130,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra.s     basXBasLoad_11
basXBasLoad_1:
; }
; else
; {
; if (vRet == 0xFE)
       move.b    -266(A6),D0
       and.w     #255,D0
       cmp.w     #254,D0
       bne.s     basXBasLoad_10
; *vErroProc = 19;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #19,(A0)
       bra.s     basXBasLoad_11
basXBasLoad_10:
; else
; *vErroProc = 20;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #20,(A0)
basXBasLoad_11:
; }
; return 0;
       clr.l     D0
       unlk      A6
       rts
; }
; #ifndef __TESTE_TOKENIZE__
; //-----------------------------------------------------------------------------
; // Calcula o endereco do valor dentro da area de dados de uma variavel array.
; // Retorna 0 em caso de erro de limite e ajusta vErroProc.
; //-----------------------------------------------------------------------------
; static unsigned char* getArrayValuePointer(unsigned char ixDim, unsigned char* vLista, unsigned char* vDim, unsigned char vTamValue)
; {
@basic_getArrayValuePointer:
       link      A6,#-20
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
       move.l    D0,-16(A6)
; ixDimAnt = 1;
       move.b    #1,-11(A6)
; vPosValueVar = 0;
       clr.l     -10(A6)
; for (ix = ((ixDim - 1) * 2 ); ix >= 0; ix -= 2)
       move.b    11(A6),D0
       subq.b    #1,D0
       and.w     #255,D0
       mulu.w    #2,D0
       and.l     #65535,D0
       move.l    D0,-20(A6)
@basic_getArrayValuePointer_1:
       move.l    -20(A6),D0
       cmp.l     #0,D0
       blt       @basic_getArrayValuePointer_3
; {
; iDim = ((vLista[ix + 8] << 8) | vLista[ix + 9]);
       move.l    12(A6),A0
       move.l    -20(A6),A1
       move.b    8(A1,A0.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.l    12(A6),A0
       move.l    -20(A6),A1
       move.b    9(A1,A0.L),D1
       and.w     #255,D1
       or.w      D1,D0
       move.w    D0,-6(A6)
; if (vDim[iw] > iDim)
       move.l    16(A6),A0
       move.l    -16(A6),D0
       move.b    0(A0,D0.L),D0
       and.w     #255,D0
       cmp.w     -6(A6),D0
       bls.s     @basic_getArrayValuePointer_4
; {
; *vErroProc = 21;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       @basic_getArrayValuePointer_6
@basic_getArrayValuePointer_4:
; }
; vPosValueVar = vPosValueVar + ((vDim[iw] - 1 ) * ixDimAnt * vTamValue);
       move.l    16(A6),A0
       move.l    -16(A6),D0
       move.b    0(A0,D0.L),D0
       subq.b    #1,D0
       and.w     #255,D0
       move.b    -11(A6),D1
       and.w     #255,D1
       mulu.w    D1,D0
       and.w     #255,D0
       move.b    23(A6),D1
       and.w     #255,D1
       mulu.w    D1,D0
       and.l     #255,D0
       add.l     D0,-10(A6)
; ixDimAnt = ixDimAnt * iDim;
       move.b    -11(A6),D0
       and.w     #255,D0
       mulu.w    -6(A6),D0
       move.b    D0,-11(A6)
; iw--;
       subq.l    #1,-16(A6)
       subq.l    #2,-20(A6)
       bra       @basic_getArrayValuePointer_1
@basic_getArrayValuePointer_3:
; }
; vOffSet = vLista;
       move.l    12(A6),-4(A6)
; vPosValueVar = vPosValueVar + (vOffSet + 8 + (ixDim * 2));
       move.l    -4(A6),D0
       addq.l    #8,D0
       move.b    11(A6),D1
       and.w     #255,D1
       mulu.w    #2,D1
       and.l     #255,D1
       add.l     D1,D0
       add.l     D0,-10(A6)
; return vPosValueVar;
       move.l    -10(A6),D0
@basic_getArrayValuePointer_6:
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
; unsigned char* vLista = pStartSimpVar;
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    (A0),-156(A6)
; unsigned char* vTemp = pStartSimpVar;
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    (A0),-152(A6)
; long vEnder = 0;
       clr.l     -148(A6)
; int ix = 0, iy = 0, iz = 0;
       clr.l     -144(A6)
       clr.l     -140(A6)
       clr.l     -136(A6)
; unsigned char vDim[88];
; unsigned int vTempDim = 0;
       clr.l     -44(A6)
; unsigned long vOffSet;
; unsigned char ixDim = 0;
       clr.b     -36(A6)
; unsigned char vArray = 0;
       clr.b     -35(A6)
; unsigned long vPosNextVar = 0;
       clr.l     -34(A6)
; unsigned char* vPosValueVar = 0;
       clr.l     -30(A6)
; unsigned char vTamValue = 4;
       move.b    #4,-25(A6)
; unsigned char *vTempPointer;
; unsigned char sqtdtam[20];
; // Verifica se eh array (tem parenteses logo depois do nome da variavel)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-24(A6)
; if (*vTempPointer == 0x28)
       move.l    -24(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       findVariable_27
; {
; // Define que eh array
; vArray = 1;
       move.b    #1,-35(A6)
; // Procura as dimensoes
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     findVariable_3
       clr.l     D0
       bra       findVariable_5
findVariable_3:
; // Erro, primeiro caracter depois da variavel, deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     findVariable_8
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     findVariable_8
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     findVariable_6
findVariable_8:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_5
findVariable_6:
; }
; do
; {
findVariable_9:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     findVariable_11
       clr.l     D0
       bra       findVariable_5
findVariable_11:
; if (*token_type == QUOTE) { // is string, error
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     findVariable_13
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_5
findVariable_13:
; }
; else { // is expression
; putback();
       jsr       _putback
; getExp(&vTempDim);
       pea       -44(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     findVariable_15
       clr.l     D0
       bra       findVariable_5
findVariable_15:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     findVariable_17
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_5
findVariable_17:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     findVariable_19
; {
; vTempDim = fppInt(vTempDim);
       move.l    -44(A6),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,-44(A6)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
findVariable_19:
; }
; vDim[ixDim] = vTempDim + 1;
       move.l    -44(A6),D0
       addq.l    #1,D0
       move.b    -36(A6),D1
       and.l     #255,D1
       lea       -132(A6),A0
       move.b    D0,0(A0,D1.L)
; ixDim++;
       addq.b    #1,-36(A6)
; }
; if (*token == ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne.s     findVariable_21
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-24(A6)
       bra.s     findVariable_22
findVariable_21:
; }
; else
; break;
       bra.s     findVariable_10
findVariable_22:
       bra       findVariable_9
findVariable_10:
; } while(1);
; // Deve ter pelo menos 1 elemento
; if (ixDim < 1)
       move.b    -36(A6),D0
       cmp.b     #1,D0
       bhs.s     findVariable_23
; {
; *vErroProc = 21;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_5
findVariable_23:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     findVariable_25
       clr.l     D0
       bra       findVariable_5
findVariable_25:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     findVariable_27
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_5
findVariable_27:
; }
; }
; // Procura na lista geral de variaveis simples / array
; if (vArray)
       tst.b     -35(A6)
       beq.s     findVariable_29
; vLista = pStartArrayVar;
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    (A0),-156(A6)
       bra.s     findVariable_30
findVariable_29:
; else
; vLista = pStartSimpVar;
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       move.l    (A0),-156(A6)
findVariable_30:
; while(1)
findVariable_31:
; {
; vPosNextVar  = (((unsigned long)*(vLista + 3) << 24) & 0xFF000000);
       move.l    -156(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,-34(A6)
; vPosNextVar |= (((unsigned long)*(vLista + 4) << 16) & 0x00FF0000);
       move.l    -156(A6),A0
       move.b    4(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,-34(A6)
; vPosNextVar |= (((unsigned long)*(vLista + 5) << 8) & 0x0000FF00);
       move.l    -156(A6),A0
       move.b    5(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,-34(A6)
; vPosNextVar |= ((unsigned long)*(vLista + 6) & 0x000000FF);
       move.l    -156(A6),A0
       move.b    6(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,-34(A6)
; *value_type = *vLista;
       move.l    -156(A6),A0
       move.l    A5,A1
       add.l     #_value_type,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; if (*(vLista + 1) == pVariable[0] && *(vLista + 2) ==  pVariable[1])
       move.l    -156(A6),A0
       move.l    8(A6),A1
       move.b    1(A0),D0
       cmp.b     (A1),D0
       bne       findVariable_34
       move.l    -156(A6),A0
       move.l    8(A6),A1
       move.b    2(A0),D0
       cmp.b     1(A1),D0
       bne       findVariable_34
; {
; // Pega endereco da variavel pra delvover
; if (vArray)
       tst.b     -35(A6)
       beq       findVariable_36
; {
; if (*vLista == '$')
       move.l    -156(A6),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     findVariable_38
; vTamValue = 5;
       move.b    #5,-25(A6)
findVariable_38:
; // Verifica se os tamanhos da dimensao informada e da variavel sao iguais
; if (ixDim != vLista[7])
       move.l    -156(A6),A0
       move.b    -36(A6),D0
       cmp.b     7(A0),D0
       beq.s     findVariable_40
; {
; *vErroProc = 21;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       findVariable_5
findVariable_40:
; }
; vPosValueVar = getArrayValuePointer(ixDim, vLista, vDim, vTamValue);
       move.b    -25(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       -132(A6)
       move.l    -156(A6),-(A7)
       move.b    -36(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       @basic_getArrayValuePointer
       add.w     #16,A7
       move.l    D0,-30(A6)
; if (*vErroProc)
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     findVariable_42
; return 0;
       clr.l     D0
       bra       findVariable_5
findVariable_42:
; vEnder = vPosValueVar;
       move.l    -30(A6),-148(A6)
       bra.s     findVariable_37
findVariable_36:
; }
; else
; {
; vPosValueVar = vLista + 3;
       move.l    -156(A6),D0
       addq.l    #3,D0
       move.l    D0,-30(A6)
; vEnder = vLista;
       move.l    -156(A6),-148(A6)
findVariable_37:
; }
; // Pelo tipo da variavel, ja retorna na variavel de nome o conteudo da variavel
; if (*vLista == '$')
       move.l    -156(A6),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne       findVariable_44
; {
; if (*debugOn)
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq       findVariable_46
; {
; writeLongSerial("Aqui 333.666.0-[");
       move.l    A5,A0
       add.l     #@basic_132,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeSerial(*vLista);
       move.l    -156(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1162,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vPosValueVar,sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    -30(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n");
       move.l    A5,A0
       add.l     #@basic_134,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_46:
; }
; vOffSet  = (((unsigned long)*(vPosValueVar + 1) << 24) & 0xFF000000);
       move.l    -30(A6),A0
       move.b    1(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,-40(A6)
; vOffSet |= (((unsigned long)*(vPosValueVar + 2) << 16) & 0x00FF0000);
       move.l    -30(A6),A0
       move.b    2(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,-40(A6)
; vOffSet |= (((unsigned long)*(vPosValueVar + 3) << 8) & 0x0000FF00);
       move.l    -30(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,-40(A6)
; vOffSet |= ((unsigned long)*(vPosValueVar + 4) & 0x000000FF);
       move.l    -30(A6),A0
       move.b    4(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,-40(A6)
; vTemp = vOffSet;
       move.l    -40(A6),-152(A6)
; iy = *vPosValueVar;
       move.l    -30(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-140(A6)
; iz = 0;
       clr.l     -136(A6)
; if (*debugOn)
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq       findVariable_48
; {
; writeLongSerial("Aqui 333.666.1-[");
       move.l    A5,A0
       add.l     #@basic_135,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vTemp,sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    -152(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_48:
; }
; for (ix = 0; ix < iy; ix++)
       clr.l     -144(A6)
findVariable_50:
       move.l    -144(A6),D0
       cmp.l     -140(A6),D0
       bge       findVariable_52
; {
; if (*debugOn)
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq       findVariable_53
; {
; itoa(ix,sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    -144(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(iz,sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    -136(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*(vTemp + ix),sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    -152(A6),A0
       move.l    -144(A6),D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_53:
; }
; pVariable[iz++] = *(vTemp + ix); // Numero gerado
       move.l    -152(A6),A0
       move.l    -144(A6),D0
       move.l    8(A6),A1
       move.l    -136(A6),D1
       addq.l    #1,-136(A6)
       move.b    0(A0,D0.L),0(A1,D1.L)
; pVariable[iz] = 0x00;
       move.l    8(A6),A0
       move.l    -136(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-144(A6)
       bra       findVariable_50
findVariable_52:
; }
; if (*debugOn)
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq.s     findVariable_55
; {
; writeLongSerial("]\r\n");
       move.l    A5,A0
       add.l     #@basic_134,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_55:
; }
; pVariable[iz++] = 0x00;
       move.l    8(A6),A0
       move.l    -136(A6),D0
       addq.l    #1,-136(A6)
       clr.b     0(A0,D0.L)
; if (*debugOn)
       move.l    A5,A0
       add.l     #_debugOn,A0
       move.l    (A0),A0
       tst.b     (A0)
       beq       findVariable_57
; {
; writeLongSerial("Aqui 333.666.2-[");
       move.l    A5,A0
       add.l     #@basic_136,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vOffSet,sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    -40(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[0],sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    8(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[1],sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    8(A6),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[2],sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    8(A6),A0
       move.b    2(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]-[");
       move.l    A5,A0
       add.l     #@basic_133,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(pVariable[3],sqtdtam,16);
       pea       16
       pea       -20(A6)
       move.l    8(A6),A0
       move.b    3(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; writeLongSerial(sqtdtam);
       pea       -20(A6)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
; writeLongSerial("]\r\n");
       move.l    A5,A0
       add.l     #@basic_134,A0
       move.l    A0,-(A7)
       move.l    1158,A0
       jsr       (A0)
       addq.w    #4,A7
findVariable_57:
       bra       findVariable_45
findVariable_44:
; }
; }
; else
; {
; if (!vArray)
       tst.b     -35(A6)
       bne.s     findVariable_59
; vPosValueVar++;
       addq.l    #1,-30(A6)
findVariable_59:
; pVariable[0] = *(vPosValueVar);
       move.l    -30(A6),A0
       move.l    8(A6),A1
       move.b    (A0),(A1)
; pVariable[1] = *(vPosValueVar + 1);
       move.l    -30(A6),A0
       move.l    8(A6),A1
       move.b    1(A0),1(A1)
; pVariable[2] = *(vPosValueVar + 2);
       move.l    -30(A6),A0
       move.l    8(A6),A1
       move.b    2(A0),2(A1)
; pVariable[3] = *(vPosValueVar + 3);
       move.l    -30(A6),A0
       move.l    8(A6),A1
       move.b    3(A0),3(A1)
; pVariable[4] = 0x00;
       move.l    8(A6),A0
       clr.b     4(A0)
findVariable_45:
; }
; return vEnder;
       move.l    -148(A6),D0
       bra       findVariable_5
findVariable_34:
; }
; if (vArray)
       tst.b     -35(A6)
       beq.s     findVariable_61
; vLista = vPosNextVar;
       move.l    -34(A6),-156(A6)
       bra.s     findVariable_62
findVariable_61:
; else
; vLista += 8;
       addq.l    #8,-156(A6)
findVariable_62:
; if ((!vArray && vLista >= pStartArrayVar) || (vArray && vLista >= pStartProg) || *vLista == 0x00)
       tst.b     -35(A6)
       bne.s     findVariable_67
       moveq     #1,D0
       bra.s     findVariable_68
findVariable_67:
       clr.l     D0
findVariable_68:
       and.l     #255,D0
       beq.s     findVariable_66
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    -156(A6),D0
       cmp.l     (A0),D0
       bhs.s     findVariable_65
findVariable_66:
       move.b    -35(A6),D0
       and.l     #255,D0
       beq.s     findVariable_69
       move.l    A5,A0
       add.l     #_pStartProg,A0
       move.l    -156(A6),D0
       cmp.l     (A0),D0
       bhs.s     findVariable_65
findVariable_69:
       move.l    -156(A6),A0
       move.b    (A0),D0
       bne.s     findVariable_63
findVariable_65:
; break;
       bra.s     findVariable_33
findVariable_63:
       bra       findVariable_31
findVariable_33:
; }
; return 0;
       clr.l     D0
findVariable_5:
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; char createVariable(unsigned char* pVariable, unsigned char* pValor, char pType)
; {
       xdef      _createVariable
_createVariable:
       link      A6,#-48
; char vRet = 0;
       clr.b     -45(A6)
; long vTemp = 0;
       clr.l     -44(A6)
; char vBuffer [sizeof(long)*8+1];
; unsigned char* vNextSimpVar;
; char vLenVar = 0;
       clr.b     -1(A6)
; vTemp = *nextAddrSimpVar;
       move.l    A5,A0
       add.l     #_nextAddrSimpVar,A0
       move.l    (A0),A0
       move.l    (A0),-44(A6)
; vNextSimpVar = *nextAddrSimpVar;
       move.l    A5,A0
       add.l     #_nextAddrSimpVar,A0
       move.l    (A0),A0
       move.l    (A0),-6(A6)
; vLenVar = strlen(pVariable);
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.b    D0,-1(A6)
; *vNextSimpVar++ = pType;
       move.l    -6(A6),A0
       addq.l    #1,-6(A6)
       move.b    19(A6),(A0)
; *vNextSimpVar++ = pVariable[0];
       move.l    8(A6),A0
       move.l    -6(A6),A1
       addq.l    #1,-6(A6)
       move.b    (A0),(A1)
; *vNextSimpVar++ = pVariable[1];
       move.l    8(A6),A0
       move.l    -6(A6),A1
       addq.l    #1,-6(A6)
       move.b    1(A0),(A1)
; vRet = updateVariable(vNextSimpVar, pValor, pType, 0);
       clr.l     -(A7)
       move.b    19(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    12(A6),-(A7)
       move.l    -6(A6),-(A7)
       jsr       _updateVariable
       add.w     #16,A7
       move.b    D0,-45(A6)
; *nextAddrSimpVar += 8;
       move.l    A5,A0
       add.l     #_nextAddrSimpVar,A0
       move.l    (A0),A0
       addq.l    #8,(A0)
; return vRet;
       move.b    -45(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; //
; //-----------------------------------------------------------------------------
; char updateVariable(unsigned long* pVariable, unsigned char* pValor, char pType, char pOper)
; {
       xdef      _updateVariable
_updateVariable:
       link      A6,#-60
; long vNumVal = 0;
       clr.l     -60(A6)
; int ix, iz = 0;
       clr.l     -52(A6)
; char vBuffer [sizeof(long)*8+1];
; unsigned char* vNextSimpVar;
; unsigned char* vNextString;
; char pNewStr = 0;
       clr.b     -5(A6)
; unsigned long vOffSet;
; //    unsigned char* sqtdtam[20];
; vNextSimpVar = pVariable;
       move.l    8(A6),-14(A6)
; *atuVarAddr = pVariable;
       move.l    A5,A0
       add.l     #_atuVarAddr,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    -14(A6),D0
       cmp.l     (A0),D0
       bhs.s     updateVariable_4
; *vNextSimpVar++ = 0x00;
       move.l    -14(A6),A0
       addq.l    #1,-14(A6)
       clr.b     (A0)
updateVariable_4:
; *vNextSimpVar++ = pValor[0];
       move.l    12(A6),A0
       move.l    -14(A6),A1
       addq.l    #1,-14(A6)
       move.b    (A0),(A1)
; *vNextSimpVar++ = pValor[1];
       move.l    12(A6),A0
       move.l    -14(A6),A1
       addq.l    #1,-14(A6)
       move.b    1(A0),(A1)
; *vNextSimpVar++ = pValor[2];
       move.l    12(A6),A0
       move.l    -14(A6),A1
       addq.l    #1,-14(A6)
       move.b    2(A0),(A1)
; *vNextSimpVar++ = pValor[3];
       move.l    12(A6),A0
       move.l    -14(A6),A1
       addq.l    #1,-14(A6)
       move.b    3(A0),(A1)
       bra       updateVariable_2
updateVariable_1:
; }
; else // String
; {
; iz = strlen(pValor);    // Tamanho da strings
       move.l    12(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-52(A6)
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
       move.l    -14(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       cmp.l     -52(A6),D0
       bhi       updateVariable_6
       move.b    23(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq       updateVariable_6
; {
; vOffSet  = (((unsigned long)*(vNextSimpVar + 1) << 24) & 0xFF000000);
       move.l    -14(A6),A0
       move.b    1(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,-4(A6)
; vOffSet |= (((unsigned long)*(vNextSimpVar + 2) << 16) & 0x00FF0000);
       move.l    -14(A6),A0
       move.b    2(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,-4(A6)
; vOffSet |= (((unsigned long)*(vNextSimpVar + 3) << 8) & 0x0000FF00);
       move.l    -14(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,-4(A6)
; vOffSet |= ((unsigned long)*(vNextSimpVar + 4) & 0x000000FF);
       move.l    -14(A6),A0
       move.b    4(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,-4(A6)
; vNextString = vOffSet;
       move.l    -4(A6),-10(A6)
; if (pOper == 2 && vNextString == 0)
       move.b    23(A6),D0
       cmp.b     #2,D0
       bne.s     updateVariable_8
       move.l    -10(A6),D0
       bne.s     updateVariable_8
; {
; vNextString = *nextAddrString;
       move.l    A5,A0
       add.l     #_nextAddrString,A0
       move.l    (A0),A0
       move.l    (A0),-10(A6)
; pNewStr = 1;
       move.b    #1,-5(A6)
updateVariable_8:
       bra.s     updateVariable_7
updateVariable_6:
; }
; }
; else
; vNextString = *nextAddrString;
       move.l    A5,A0
       add.l     #_nextAddrString,A0
       move.l    (A0),A0
       move.l    (A0),-10(A6)
updateVariable_7:
; vNumVal = vNextString;
       move.l    -10(A6),-60(A6)
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
       clr.l     -56(A6)
updateVariable_10:
       move.l    -56(A6),D0
       cmp.l     -52(A6),D0
       bge.s     updateVariable_12
; {
; *vNextString++ = pValor[ix];
       move.l    12(A6),A0
       move.l    -56(A6),D0
       move.l    -10(A6),A1
       addq.l    #1,-10(A6)
       move.b    0(A0,D0.L),(A1)
       addq.l    #1,-56(A6)
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
       move.l    -14(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       cmp.l     -52(A6),D0
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
       move.b    -5(A6),D0
       ext.w     D0
       ext.l     D0
       tst.l     D0
       beq.s     updateVariable_13
updateVariable_15:
; *nextAddrString = vNextString;
       move.l    A5,A0
       add.l     #_nextAddrString,A0
       move.l    (A0),A0
       move.l    -10(A6),(A0)
updateVariable_13:
; /*writeLongSerial("Aqui 333.666.4-[");
; itoa(vNextString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(vNumVal,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; *vNextSimpVar++ = iz;
       move.l    -52(A6),D0
       move.l    -14(A6),A0
       addq.l    #1,-14(A6)
       move.b    D0,(A0)
; /*writeLongSerial("Aqui 333.666.5-[");
; itoa(vNextString,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; *vNextSimpVar++ = ((vNumVal & 0xFF000000) >>24);
       move.l    -60(A6),D0
       and.l     #-16777216,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    -14(A6),A0
       addq.l    #1,-14(A6)
       move.b    D0,(A0)
; *vNextSimpVar++ = ((vNumVal & 0x00FF0000) >>16);
       move.l    -60(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    -14(A6),A0
       addq.l    #1,-14(A6)
       move.b    D0,(A0)
; *vNextSimpVar++ = ((vNumVal & 0x0000FF00) >>8);
       move.l    -60(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    -14(A6),A0
       addq.l    #1,-14(A6)
       move.b    D0,(A0)
; *vNextSimpVar++ = (vNumVal & 0x000000FF);
       move.l    -60(A6),D0
       and.l     #255,D0
       move.l    -14(A6),A0
       addq.l    #1,-14(A6)
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
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; char createVariableArray(unsigned char* pVariable, char pType, unsigned int pNumDim, unsigned int *pDim)
; {
       xdef      _createVariableArray
_createVariableArray:
       link      A6,#-68
; char vRet = 0;
       clr.b     -65(A6)
; long vTemp = 0;
       clr.l     -64(A6)
; unsigned char* vTempC = &vTemp;
       lea       -64(A6),A0
       move.l    A0,-60(A6)
; char vBuffer [sizeof(long)*8+1];
; unsigned char* vNextArrayVar;
; char vLenVar = 0;
       clr.b     -17(A6)
; int ix, vTam;
; long vAreaFree = (pStartString - *nextAddrArrayVar);
       move.l    A5,A0
       add.l     #_pStartString,A0
       move.l    (A0),D0
       move.l    A5,A0
       add.l     #_nextAddrArrayVar,A0
       move.l    (A0),A0
       sub.l     (A0),D0
       move.l    D0,-8(A6)
; long vSizeTotal = 0;
       clr.l     -4(A6)
; //    unsigned char sqtdtam[20];
; vTemp = *nextAddrArrayVar;
       move.l    A5,A0
       add.l     #_nextAddrArrayVar,A0
       move.l    (A0),A0
       move.l    (A0),-64(A6)
; vNextArrayVar = *nextAddrArrayVar;
       move.l    A5,A0
       add.l     #_nextAddrArrayVar,A0
       move.l    (A0),A0
       move.l    (A0),-22(A6)
; vLenVar = strlen(pVariable);
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.b    D0,-17(A6)
; *vNextArrayVar++ = pType;
       move.l    -22(A6),A0
       addq.l    #1,-22(A6)
       move.b    15(A6),(A0)
; *vNextArrayVar++ = pVariable[0];
       move.l    8(A6),A0
       move.l    -22(A6),A1
       addq.l    #1,-22(A6)
       move.b    (A0),(A1)
; *vNextArrayVar++ = pVariable[1];
       move.l    8(A6),A0
       move.l    -22(A6),A1
       addq.l    #1,-22(A6)
       move.b    1(A0),(A1)
; vTam = 0;
       clr.l     -12(A6)
; for (ix = 0; ix < pNumDim; ix++)
       clr.l     -16(A6)
createVariableArray_1:
       move.l    -16(A6),D0
       cmp.l     16(A6),D0
       bhs       createVariableArray_3
; {
; // Somando mais 1, porque 0 = 1 em quantidade e e em posicao (igual ao c)
; pDim[ix] = pDim[ix] /*+ 1*/ ;
       move.l    20(A6),A0
       move.l    -16(A6),D0
       lsl.l     #2,D0
       move.l    20(A6),A1
       move.l    -16(A6),D1
       lsl.l     #2,D1
       move.l    0(A0,D0.L),0(A1,D1.L)
; // Definir o tamanho do campo de dados do array
; if (vTam == 0)
       move.l    -12(A6),D0
       bne.s     createVariableArray_4
; vTam = pDim[ix] /*- 1*/ ;
       move.l    20(A6),A0
       move.l    -16(A6),D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),-12(A6)
       bra.s     createVariableArray_5
createVariableArray_4:
; else
; vTam = vTam * (pDim[ix] /*- 1*/ );
       move.l    20(A6),A0
       move.l    -16(A6),D0
       lsl.l     #2,D0
       move.l    -12(A6),-(A7)
       move.l    0(A0,D0.L),-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-12(A6)
createVariableArray_5:
       addq.l    #1,-16(A6)
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
       move.l    -12(A6),-(A7)
       pea       5
       jsr       LMUL
       move.l    (A7),-12(A6)
       addq.w    #8,A7
       bra.s     createVariableArray_7
createVariableArray_6:
; else
; vTam = vTam * 4;
       move.l    -12(A6),-(A7)
       pea       4
       jsr       LMUL
       move.l    (A7),-12(A6)
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
       move.l    -12(A6),D0
       addq.l    #8,D0
       move.l    D0,-4(A6)
; vSizeTotal = vSizeTotal + (pNumDim *2);
       move.l    -4(A6),D0
       move.l    16(A6),-(A7)
       pea       2
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,-4(A6)
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
       move.l    -4(A6),D0
       cmp.l     -8(A6),D0
       ble.s     createVariableArray_8
; {
; *vErroProc = 22;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #22,(A0)
; return 0;
       clr.b     D0
       bra       createVariableArray_10
createVariableArray_8:
; }
; // Coloca setup do array
; vTemp = vTemp + vTam + 8 + (pNumDim * 2);
       move.l    -64(A6),D0
       add.l     -12(A6),D0
       addq.l    #8,D0
       move.l    16(A6),-(A7)
       pea       2
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,-64(A6)
; *vNextArrayVar++ = vTempC[0];
       move.l    -60(A6),A0
       move.l    -22(A6),A1
       addq.l    #1,-22(A6)
       move.b    (A0),(A1)
; *vNextArrayVar++ = vTempC[1];
       move.l    -60(A6),A0
       move.l    -22(A6),A1
       addq.l    #1,-22(A6)
       move.b    1(A0),(A1)
; *vNextArrayVar++ = vTempC[2];
       move.l    -60(A6),A0
       move.l    -22(A6),A1
       addq.l    #1,-22(A6)
       move.b    2(A0),(A1)
; *vNextArrayVar++ = vTempC[3];
       move.l    -60(A6),A0
       move.l    -22(A6),A1
       addq.l    #1,-22(A6)
       move.b    3(A0),(A1)
; *vNextArrayVar++ = pNumDim;
       move.l    16(A6),D0
       move.l    -22(A6),A0
       addq.l    #1,-22(A6)
       move.b    D0,(A0)
; for (ix = 0; ix < pNumDim; ix++)
       clr.l     -16(A6)
createVariableArray_11:
       move.l    -16(A6),D0
       cmp.l     16(A6),D0
       bhs       createVariableArray_13
; {
; *vNextArrayVar++ = (pDim[ix] >> 8);
       move.l    20(A6),A0
       move.l    -16(A6),D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),D0
       lsr.l     #8,D0
       move.l    -22(A6),A0
       addq.l    #1,-22(A6)
       move.b    D0,(A0)
; *vNextArrayVar++ = (pDim[ix] & 0xFF);
       move.l    20(A6),A0
       move.l    -16(A6),D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    -22(A6),A0
       addq.l    #1,-22(A6)
       move.b    D0,(A0)
       addq.l    #1,-16(A6)
       bra       createVariableArray_11
createVariableArray_13:
; }
; // Limpa area de dados (zera)
; for (ix = 0; ix < vTam; ix++)
       clr.l     -16(A6)
createVariableArray_14:
       move.l    -16(A6),D0
       cmp.l     -12(A6),D0
       bge.s     createVariableArray_16
; *(vNextArrayVar + ix) = 0x00;
       move.l    -22(A6),A0
       move.l    -16(A6),D0
       clr.b     0(A0,D0.L)
       addq.l    #1,-16(A6)
       bra       createVariableArray_14
createVariableArray_16:
; *nextAddrArrayVar = vTemp;
       move.l    A5,A0
       add.l     #_nextAddrArrayVar,A0
       move.l    (A0),A0
       move.l    -64(A6),(A0)
; return 0;
       clr.b     D0
createVariableArray_10:
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
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #4,D0
       bne.s     putback_1
; return;
       bra.s     putback_6
putback_1:
; t = token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-4(A6)
; while (*t++)
putback_4:
       move.l    -4(A6),A0
       addq.l    #1,-4(A6)
       tst.b     (A0)
       beq.s     putback_6
; *pointerRunProg = *pointerRunProg - 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
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
; while (*X)
ustrcmp_1:
       move.l    8(A6),A0
       tst.b     (A0)
       beq.s     ustrcmp_3
; {
; // if characters differ, or end of the second string is reached
; if (*X != *Y) {
       move.l    8(A6),A0
       move.l    12(A6),A1
       move.b    (A0),D0
       cmp.b     (A1),D0
       beq.s     ustrcmp_4
; break;
       bra.s     ustrcmp_3
ustrcmp_4:
; }
; // move to the next pair of characters
; X++;
       addq.l    #1,8(A6)
; Y++;
       addq.l    #1,12(A6)
       bra       ustrcmp_1
ustrcmp_3:
; }
; // return the ASCII difference after converting `char*` to `unsigned char*`
; return *(unsigned char*)X - *(unsigned char*)Y;
       move.l    8(A6),D0
       move.l    D0,A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    12(A6),D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       sub.l     D1,D0
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
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     getExp_1
       bra       getExp_3
getExp_1:
; if (!*token) {
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       tst.b     (A0)
       bne.s     getExp_4
; *vErroProc = 2;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #2,(A0)
; return;
       bra.s     getExp_3
getExp_4:
; }
; level2(result);
       move.l    8(A6),-(A7)
       jsr       _level2
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     getExp_6
       bra.s     getExp_3
getExp_6:
; putback(); // return last token read to input stream
       jsr       _putback
; return;
getExp_3:
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
       link      A6,#-104
; char  op;
; unsigned char hold[50];
; unsigned char valueTypeAnt;
; unsigned int *lresult = result;
       move.l    8(A6),-48(A6)
; unsigned int *lhold = hold;
       lea       -100(A6),A0
       move.l    A0,-44(A6)
; unsigned char* sqtdtam[10];
; level3(result);
       move.l    8(A6),-(A7)
       jsr       _level3
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level2_1
       bra       level2_3
level2_1:
; op = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-101(A6)
; while(op == '+' || op == '-') {
level2_4:
       move.b    -101(A6),D0
       cmp.b     #43,D0
       beq.s     level2_7
       move.b    -101(A6),D0
       cmp.b     #45,D0
       bne       level2_6
level2_7:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level2_8
       bra       level2_3
level2_8:
; valueTypeAnt = *value_type;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),-49(A6)
; level3(&hold);
       pea       -100(A6)
       jsr       _level3
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level2_10
       bra       level2_3
level2_10:
; if (*value_type != valueTypeAnt)
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     -49(A6),D0
       beq.s     level2_14
; {
; if (*value_type == '$' || valueTypeAnt == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level2_16
       move.b    -49(A6),D0
       cmp.b     #36,D0
       bne.s     level2_14
level2_16:
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level2_3
level2_14:
; }
; }
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type == '$' && valueTypeAnt == '$' && op == '+')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level2_17
       move.b    -49(A6),D0
       cmp.b     #36,D0
       bne.s     level2_17
       move.b    -101(A6),D0
       cmp.b     #43,D0
       bne.s     level2_17
; strcat(result,&hold);
       pea       -100(A6)
       move.l    8(A6),-(A7)
       jsr       _strcat
       addq.w    #8,A7
       bra       level2_30
level2_17:
; else if ((*value_type == '$' || valueTypeAnt == '$') && op == '-')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level2_21
       move.b    -49(A6),D0
       cmp.b     #36,D0
       bne.s     level2_19
level2_21:
       move.b    -101(A6),D0
       cmp.b     #45,D0
       bne.s     level2_19
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level2_3
level2_19:
; }
; else
; {
; if (*value_type != valueTypeAnt)
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     -49(A6),D0
       beq       level2_28
; {
; if (*value_type == '$' || valueTypeAnt == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level2_26
       move.b    -49(A6),D0
       cmp.b     #36,D0
       bne.s     level2_24
level2_26:
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level2_3
level2_24:
; }
; else if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level2_27
; {
; *lresult = fppReal(*lresult);
       move.l    -48(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -48(A6),A0
       move.l    D0,(A0)
       bra.s     level2_28
level2_27:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    -44(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -44(A6),A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
level2_28:
; }
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level2_29
; arithReal(op, result, &hold);
       pea       -100(A6)
       move.l    8(A6),-(A7)
       move.b    -101(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _arithReal
       add.w     #12,A7
       bra.s     level2_30
level2_29:
; else
; arithInt(op, result, &hold);
       pea       -100(A6)
       move.l    8(A6),-(A7)
       move.b    -101(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _arithInt
       add.w     #12,A7
level2_30:
; }
; op = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-101(A6)
       bra       level2_4
level2_6:
; }
; return;
level2_3:
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
       link      A6,#-104
; char  op;
; unsigned char hold[50];
; unsigned int *lresult = result;
       move.l    8(A6),-50(A6)
; unsigned int *lhold = hold;
       lea       -100(A6),A0
       move.l    A0,-46(A6)
; char value_type_ant=0;
       clr.b     -41(A6)
; unsigned char* sqtdtam[10];
; do
; {
level3_1:
; level30(result);
       move.l    8(A6),-(A7)
       jsr       _level30
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level3_3
       bra       level3_5
level3_3:
; if (*token==0xF3||*token==0xF4)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #243,D0
       beq.s     level3_8
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #244,D0
       bne.s     level3_6
level3_8:
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-101(A6)
; while(op == '*' || op == '/' || op == '%') {
level3_11:
       move.b    -101(A6),D0
       cmp.b     #42,D0
       beq.s     level3_14
       move.b    -101(A6),D0
       cmp.b     #47,D0
       beq.s     level3_14
       move.b    -101(A6),D0
       cmp.b     #37,D0
       bne       level3_13
level3_14:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level3_15
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level3_5
level3_15:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level3_17
       bra       level3_5
level3_17:
; value_type_ant = *value_type;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),-41(A6)
; level4(&hold);
       pea       -100(A6)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level3_19
       bra       level3_5
level3_19:
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type == '$' || value_type_ant == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level3_23
       move.b    -41(A6),D0
       cmp.b     #36,D0
       bne.s     level3_21
level3_23:
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level3_5
level3_21:
; }
; if (*value_type != value_type_ant)
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     -41(A6),D0
       beq       level3_27
; {
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level3_26
; {
; *lresult = fppReal(*lresult);
       move.l    -50(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -50(A6),A0
       move.l    D0,(A0)
       bra.s     level3_27
level3_26:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    -46(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -46(A6),A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
level3_27:
; }
; }
; // se valor inteiro e for divisao, obrigatoriamente devolve valor real
; if (*value_type == '%' && op == '/')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne       level3_28
       move.b    -101(A6),D0
       cmp.b     #47,D0
       bne       level3_28
; {
; *lresult = fppReal(*lresult);
       move.l    -50(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -50(A6),A0
       move.l    D0,(A0)
; *lhold = fppReal(*lhold);
       move.l    -46(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -46(A6),A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
level3_28:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level3_30
; arithReal(op, result, &hold);
       pea       -100(A6)
       move.l    8(A6),-(A7)
       move.b    -101(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _arithReal
       add.w     #12,A7
       bra.s     level3_31
level3_30:
; else
; arithInt(op, result, &hold);
       pea       -100(A6)
       move.l    8(A6),-(A7)
       move.b    -101(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _arithInt
       add.w     #12,A7
level3_31:
; op = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-101(A6)
       bra       level3_11
level3_13:
; }
; return;
level3_5:
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
       link      A6,#-8
; char  op;
; int *iLog = result;
       move.l    8(A6),-4(A6)
; op = 0;
       clr.b     -5(A6)
; if (*token == 0xF8) // NOT
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #248,D0
       bne.s     level30_3
; {
; op = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-5(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level30_6
       bra       level30_5
level30_6:
; if (op)
       tst.b     -5(A6)
       beq       level30_8
; {
; if (*value_type == '$' || *value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     level30_12
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level30_10
level30_12:
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra.s     level30_5
level30_10:
; }
; *iLog = !*iLog;
       move.l    -4(A6),A0
       tst.l     (A0)
       bne.s     level30_13
       moveq     #1,D0
       bra.s     level30_14
level30_13:
       clr.l     D0
level30_14:
       move.l    -4(A6),A0
       move.l    D0,(A0)
level30_8:
; }
; return;
level30_5:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Process logic conditions
; //--------------------------------------------------------------------------------------
; void level31(unsigned char *result)
; {
       xdef      _level31
_level31:
       link      A6,#-104
; unsigned char  op;
; unsigned char hold[50];
; char value_type_ant=0;
       clr.b     -49(A6)
; int *rVal = result;
       move.l    8(A6),-48(A6)
; int *hVal = hold;
       lea       -100(A6),A0
       move.l    A0,-44(A6)
; unsigned char* sqtdtam[10];
; level32(result);
       move.l    8(A6),-(A7)
       jsr       _level32
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level31_1
       bra       level31_3
level31_1:
; op = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-101(A6)
; if (op==0xF3 /* AND */|| op==0xF4 /* OR */) {
       move.b    -101(A6),D0
       and.w     #255,D0
       cmp.w     #243,D0
       beq.s     level31_6
       move.b    -101(A6),D0
       and.w     #255,D0
       cmp.w     #244,D0
       bne       level31_12
level31_6:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level31_7
       bra       level31_3
level31_7:
; level32(&hold);
       pea       -100(A6)
       jsr       _level32
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.b    -101(A6),D0
       and.w     #255,D0
       cmp.w     #243,D0
       bne.s     level31_11
; *rVal = (*rVal && *hVal);
       move.l    -48(A6),A0
       tst.l     (A0)
       beq.s     level31_13
       move.l    -44(A6),A0
       tst.l     (A0)
       beq.s     level31_13
       moveq     #1,D0
       bra.s     level31_14
level31_13:
       clr.l     D0
level31_14:
       move.l    -48(A6),A0
       move.l    D0,(A0)
       bra.s     level31_12
level31_11:
; else
; *rVal = (*rVal || *hVal);
       move.l    -48(A6),A0
       tst.l     (A0)
       bne.s     level31_17
       move.l    -44(A6),A0
       tst.l     (A0)
       beq.s     level31_15
level31_17:
       moveq     #1,D0
       bra.s     level31_16
level31_15:
       clr.l     D0
level31_16:
       move.l    -48(A6),A0
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
       link      A6,#-84
; unsigned char  op;
; unsigned char hold[50];
; unsigned char value_type_ant=0;
       clr.b     -29(A6)
; unsigned int *lresult = result;
       move.l    8(A6),-28(A6)
; unsigned int *lhold = hold;
       lea       -80(A6),A0
       move.l    A0,-24(A6)
; unsigned char sqtdtam[20];
; level4(result);
       move.l    8(A6),-(A7)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level32_1
       bra       level32_3
level32_1:
; op = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-81(A6)
; if (op=='=' || op=='<' || op=='>' || op==0xF5 /* >= */ || op==0xF6 /* <= */|| op==0xF7 /* <> */) {
       move.b    -81(A6),D0
       cmp.b     #61,D0
       beq       level32_6
       move.b    -81(A6),D0
       cmp.b     #60,D0
       beq.s     level32_6
       move.b    -81(A6),D0
       cmp.b     #62,D0
       beq.s     level32_6
       move.b    -81(A6),D0
       and.w     #255,D0
       cmp.w     #245,D0
       beq.s     level32_6
       move.b    -81(A6),D0
       and.w     #255,D0
       cmp.w     #246,D0
       beq.s     level32_6
       move.b    -81(A6),D0
       and.w     #255,D0
       cmp.w     #247,D0
       bne       level32_22
level32_6:
; //        if (op==0xF5 /* >= */ || op==0xF6 /* <= */|| op==0xF7)
; //            pointerRunProg++;
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level32_7
       bra       level32_3
level32_7:
; value_type_ant = *value_type;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),-29(A6)
; level4(&hold);
       pea       -80(A6)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level32_9
       bra       level32_3
level32_9:
; if ((value_type_ant=='$' && *value_type!='$') || (value_type_ant != '$' && *value_type == '$'))
       move.b    -29(A6),D0
       cmp.b     #36,D0
       bne.s     level32_14
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level32_13
level32_14:
       move.b    -29(A6),D0
       cmp.b     #36,D0
       beq.s     level32_11
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level32_11
level32_13:
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level32_3
level32_11:
; }
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type != value_type_ant)
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     -29(A6),D0
       beq       level32_18
; {
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level32_17
; {
; *lresult = fppReal(*lresult);
       move.l    -28(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -28(A6),A0
       move.l    D0,(A0)
       bra.s     level32_18
level32_17:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    -24(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -24(A6),A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
level32_18:
; }
; }
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level32_19
; logicalString(op, result, &hold);
       pea       -80(A6)
       move.l    8(A6),-(A7)
       move.b    -81(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _logicalString
       add.w     #12,A7
       bra       level32_22
level32_19:
; else if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level32_21
; logicalNumericFloat(op, result, &hold);
       pea       -80(A6)
       move.l    8(A6),-(A7)
       move.b    -81(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _logicalNumericFloat
       add.w     #12,A7
       bra.s     level32_22
level32_21:
; else
; logicalNumericInt(op, result, &hold);
       pea       -80(A6)
       move.l    8(A6),-(A7)
       move.b    -81(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _logicalNumericInt
       add.w     #12,A7
level32_22:
; }
; return;
level32_3:
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
       link      A6,#-60
; unsigned char hold[50];
; unsigned int *lresult = result;
       move.l    8(A6),-10(A6)
; unsigned int *lhold = hold;
       lea       -60(A6),A0
       move.l    A0,-6(A6)
; char value_type_ant=0;
       clr.b     -1(A6)
; level5(result);
       move.l    8(A6),-(A7)
       jsr       _level5
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level4_1
       bra       level4_3
level4_1:
; if (*token== '^') {
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #94,D0
       bne       level4_19
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level4_6
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level4_3
level4_6:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level4_8
       bra       level4_3
level4_8:
; value_type_ant = *value_type;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),-1(A6)
; level4(&hold);
       pea       -60(A6)
       jsr       _level4
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level4_10
       bra       level4_3
level4_10:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level4_12
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level4_3
level4_12:
; }
; // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
; if (*value_type != value_type_ant)
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     -1(A6),D0
       beq       level4_17
; {
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level4_16
; {
; *lresult = fppReal(*lresult);
       move.l    -10(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -10(A6),A0
       move.l    D0,(A0)
       bra.s     level4_17
level4_16:
; }
; else
; {
; *lhold = fppReal(*lhold);
       move.l    -6(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -6(A6),A0
       move.l    D0,(A0)
; *value_type = '#';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
level4_17:
; }
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level4_18
; arithReal('^', result, &hold);
       pea       -60(A6)
       move.l    8(A6),-(A7)
       pea       94
       jsr       _arithReal
       add.w     #12,A7
       bra.s     level4_19
level4_18:
; else
; arithInt('^', result, &hold);
       pea       -60(A6)
       move.l    8(A6),-(A7)
       pea       94
       jsr       _arithInt
       add.w     #12,A7
level4_19:
; }
; return;
level4_3:
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
       link      A6,#-4
; char  op;
; op = 0;
       clr.b     -1(A6)
; if (*token_type==DELIMITER && (*token=='+' || *token=='-')) {
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #1,D0
       bne       level5_4
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #43,D0
       beq.s     level5_3
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #45,D0
       bne.s     level5_4
level5_3:
; op = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-1(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level5_4
       bra       level5_6
level5_4:
; }
; level6(result);
       move.l    8(A6),-(A7)
       jsr       _level6
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level5_7
       bra       level5_6
level5_7:
; if (op)
       tst.b     -1(A6)
       beq       level5_14
; {
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     level5_11
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return;
       bra       level5_6
level5_11:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     level5_13
; unaryReal(op, result);
       move.l    8(A6),-(A7)
       move.b    -1(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _unaryReal
       addq.w    #8,A7
       bra.s     level5_14
level5_13:
; else
; unaryInt(op, result);
       move.l    8(A6),-(A7)
       move.b    -1(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _unaryInt
       addq.w    #8,A7
level5_14:
; }
; return;
level5_6:
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
; if ((*token == '(') && (*token_type == OPENPARENT)) {
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       level6_1
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       bne       level6_1
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     level6_3
       bra       level6_5
level6_3:
; level2(result);
       move.l    8(A6),-(A7)
       jsr       _level2
       addq.w    #4,A7
; if (*token != ')')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #41,D0
       beq.s     level6_6
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return;
       bra.s     level6_5
level6_6:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       link      A6,#-28
; unsigned long ix;
; unsigned char* vix = &ix;
       lea       -26(A6),A0
       move.l    A0,-22(A6)
; unsigned char* vRet;
; unsigned char sqtdtam[10];
; unsigned char *vTempPointer;
; switch(*token_type) {
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
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
; if (strlen(token) < 3)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       primitive_9
; {
; *value_type=VARTYPEDEFAULT;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     primitive_11
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     primitive_11
; *value_type = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_value_type,A1
       move.l    (A1),A1
       move.b    1(A0),(A1)
primitive_11:
       bra.s     primitive_10
primitive_9:
; }
; else
; {
; *value_type = *(token + 2);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_value_type,A1
       move.l    (A1),A1
       move.b    2(A0),(A1)
primitive_10:
; }
; vRet = find_var(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _find_var
       addq.w    #4,A7
       move.l    D0,-18(A6)
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     primitive_13
       bra       primitive_15
primitive_13:
; if (*value_type == '$')  // Tipo da variavel
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     primitive_16
; strcpy(result,vRet);
       move.l    -18(A6),-(A7)
       move.l    8(A6),-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     primitive_20
primitive_16:
; else
; {
; for (ix = 0;ix < 5;ix++)
       clr.l     -26(A6)
primitive_18:
       move.l    -26(A6),D0
       cmp.l     #5,D0
       bhs.s     primitive_20
; result[ix] = vRet[ix];
       move.l    -18(A6),A0
       move.l    -26(A6),D0
       move.l    8(A6),A1
       move.l    -26(A6),D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-26(A6)
       bra       primitive_18
primitive_20:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     primitive_21
       bra       primitive_15
primitive_21:
; return;
       bra       primitive_15
primitive_5:
; case QUOTE:
; *value_type='$';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #36,(A0)
; strcpy(result,token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       move.l    8(A6),-(A7)
       jsr       _strcpy
       addq.w    #8,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     primitive_23
       bra       primitive_15
primitive_23:
; return;
       bra       primitive_15
primitive_6:
; case NUMBER:
; if (strchr(token,'.'))  // verifica se eh numero inteiro ou real
       pea       46
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq       primitive_25
; {
; *value_type='#'; // Real
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
; ix=floatStringToFpp(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,-26(A6)
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     primitive_27
       bra       primitive_15
primitive_27:
       bra.s     primitive_26
primitive_25:
; }
; else
; {
; *value_type='%'; // Inteiro
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; ix=atoi(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-26(A6)
primitive_26:
; }
; vix = &ix;
       lea       -26(A6),A0
       move.l    A0,-22(A6)
; result[0] = vix[0];
       move.l    -22(A6),A0
       move.l    8(A6),A1
       move.b    (A0),(A1)
; result[1] = vix[1];
       move.l    -22(A6),A0
       move.l    8(A6),A1
       move.b    1(A0),1(A1)
; result[2] = vix[2];
       move.l    -22(A6),A0
       move.l    8(A6),A1
       move.b    2(A0),2(A1)
; result[3] = vix[3];
       move.l    -22(A6),A0
       move.l    8(A6),A1
       move.b    3(A0),3(A1)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     primitive_29
       bra       primitive_15
primitive_29:
; return;
       bra       primitive_15
primitive_7:
; case COMMAND:
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; *token = *vTempPointer;
       move.l    -4(A6),A0
       move.l    A5,A1
       add.l     #_token,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; executeToken(*vTempPointer);  // Retorno do resultado da funcao deve voltar pela variavel token. *value_type tera o tipo de retorno
       move.l    -4(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _executeToken
       addq.w    #4,A7
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     primitive_31
       bra       primitive_15
primitive_31:
; if (*value_type == '$')  // Tipo do retorno
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     primitive_33
; strcpy(result,token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       move.l    8(A6),-(A7)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     primitive_37
primitive_33:
; else
; {
; for (ix = 0; ix < 4; ix++)
       clr.l     -26(A6)
primitive_35:
       move.l    -26(A6),D0
       cmp.l     #4,D0
       bhs.s     primitive_37
; {
; result[ix] = *(token + ix);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -26(A6),D0
       move.l    8(A6),A1
       move.l    -26(A6),D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-26(A6)
       bra       primitive_35
primitive_37:
; }
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     primitive_38
       bra.s     primitive_15
primitive_38:
; return;
       bra.s     primitive_15
primitive_1:
; default:
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return;
primitive_15:
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
       link      A6,#-20
; int t, ex;
; int *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    12(A6),-12(A6)
; int *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),-8(A6)
; char* vRval = rVal;
       move.l    -12(A6),-4(A6)
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
       move.l    -12(A6),A0
       move.l    -8(A6),A1
       move.l    (A1),D0
       sub.l     D0,(A0)
; break;
       bra       arithInt_2
arithInt_4:
; case '+':
; *rVal = *rVal + *hVal;
       move.l    -12(A6),A0
       move.l    -8(A6),A1
       move.l    (A1),D0
       add.l     D0,(A0)
; break;
       bra       arithInt_2
arithInt_5:
; case '*':
; *rVal = *rVal * *hVal;
       move.l    -12(A6),A0
       move.l    -8(A6),A1
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
       move.l    -12(A6),A0
       move.l    -8(A6),A1
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
       move.l    -12(A6),A0
       move.l    (A0),-16(A6)
; if (*hVal==0) {
       move.l    -8(A6),A0
       move.l    (A0),D0
       bne.s     arithInt_9
; *rVal = 1;
       move.l    -12(A6),A0
       move.l    #1,(A0)
; break;
       bra.s     arithInt_2
arithInt_9:
; }
; ex = powNum(*rVal,*hVal);
       move.l    -8(A6),A0
       move.l    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -12(A6),A0
       move.l    (A0),-(A7)
       jsr       _powNum
       addq.w    #8,A7
       move.l    D0,-16(A6)
; *rVal = ex;
       move.l    -12(A6),A0
       move.l    -16(A6),(A0)
; break;
arithInt_2:
; }
; r[0] = vRval[0];
       move.l    -4(A6),A0
       move.l    12(A6),A1
       move.b    (A0),(A1)
; r[1] = vRval[1];
       move.l    -4(A6),A0
       move.l    12(A6),A1
       move.b    1(A0),1(A1)
; r[2] = vRval[2];
       move.l    -4(A6),A0
       move.l    12(A6),A1
       move.b    2(A0),2(A1)
; r[3] = vRval[3];
       move.l    -4(A6),A0
       move.l    12(A6),A1
       move.b    3(A0),3(A1)
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
       link      A6,#-20
; int t, ex;
; unsigned long *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    12(A6),-12(A6)
; unsigned long *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),-8(A6)
; char* vRval = rVal;
       move.l    -12(A6),-4(A6)
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
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       move.l    -12(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppSub
       addq.w    #8,A7
       move.l    -12(A6),A0
       move.l    D0,(A0)
; break;
       bra       arithReal_2
arithReal_4:
; case '+':
; *rVal = fppSum(*rVal, *hVal);
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       move.l    -12(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppSum
       addq.w    #8,A7
       move.l    -12(A6),A0
       move.l    D0,(A0)
; break;
       bra       arithReal_2
arithReal_5:
; case '*':
; *rVal = fppMul(*rVal, *hVal);
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       move.l    -12(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppMul
       addq.w    #8,A7
       move.l    -12(A6),A0
       move.l    D0,(A0)
; break;
       bra       arithReal_2
arithReal_6:
; case '/':
; *rVal = fppDiv(*rVal, *hVal);
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       move.l    -12(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppDiv
       addq.w    #8,A7
       move.l    -12(A6),A0
       move.l    D0,(A0)
; break;
       bra.s     arithReal_2
arithReal_7:
; case '^':
; *rVal = fppPwr(*rVal, *hVal);
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       move.l    -12(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppPwr
       addq.w    #8,A7
       move.l    -12(A6),A0
       move.l    D0,(A0)
; break;
arithReal_2:
       unlk      A6
       rts
; }
; }
; //--------------------------------------------------------------------------------------
; //
; //--------------------------------------------------------------------------------------
; void logicalNumericFloat(unsigned char o, char *r, char *h)
; {
       xdef      _logicalNumericFloat
_logicalNumericFloat:
       link      A6,#-20
; int t, ex;
; unsigned long *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    12(A6),-12(A6)
; unsigned long *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),-8(A6)
; unsigned long oCCR = 0;
       clr.l     -4(A6)
; oCCR = fppComp(*rVal, *hVal);
       move.l    -8(A6),A0
       move.l    (A0),-(A7)
       move.l    -12(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppComp
       addq.w    #8,A7
       move.l    D0,-4(A6)
; *rVal = 0;
       move.l    -12(A6),A0
       clr.l     (A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
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
       move.l    -4(A6),D0
       and.l     #4,D0
       beq.s     logicalNumericFloat_11
; *rVal = 1;
       move.l    -12(A6),A0
       move.l    #1,(A0)
logicalNumericFloat_11:
; break;
       bra       logicalNumericFloat_2
logicalNumericFloat_4:
; case '>':
; if (!(oCCR & 0x08) && !(oCCR & 0x04))   // N=0 e Z=0
       move.l    -4(A6),D0
       and.l     #8,D0
       bne.s     logicalNumericFloat_13
       move.l    -4(A6),D0
       and.l     #4,D0
       bne.s     logicalNumericFloat_13
; *rVal = 1;
       move.l    -12(A6),A0
       move.l    #1,(A0)
logicalNumericFloat_13:
; break;
       bra       logicalNumericFloat_2
logicalNumericFloat_5:
; case '<':
; if ((oCCR & 0x08) && !(oCCR & 0x04))   // N=1 e Z=0
       move.l    -4(A6),D0
       and.l     #8,D0
       beq.s     logicalNumericFloat_15
       move.l    -4(A6),D0
       and.l     #4,D0
       bne.s     logicalNumericFloat_15
; *rVal = 1;
       move.l    -12(A6),A0
       move.l    #1,(A0)
logicalNumericFloat_15:
; break;
       bra       logicalNumericFloat_2
logicalNumericFloat_6:
; case 0xF5:  // >=
; if (!(oCCR & 0x08) || (oCCR & 0x04))   // N=0 ou Z=1
       move.l    -4(A6),D0
       and.l     #8,D0
       beq.s     logicalNumericFloat_19
       move.l    -4(A6),D0
       and.l     #4,D0
       beq.s     logicalNumericFloat_17
logicalNumericFloat_19:
; *rVal = 1;
       move.l    -12(A6),A0
       move.l    #1,(A0)
logicalNumericFloat_17:
; break;
       bra.s     logicalNumericFloat_2
logicalNumericFloat_7:
; case 0xF6:  // <=
; if ((oCCR & 0x08) || (oCCR & 0x04))   // N=1 ou Z=1
       move.l    -4(A6),D0
       and.l     #8,D0
       bne.s     logicalNumericFloat_22
       move.l    -4(A6),D0
       and.l     #4,D0
       beq.s     logicalNumericFloat_20
logicalNumericFloat_22:
; *rVal = 1;
       move.l    -12(A6),A0
       move.l    #1,(A0)
logicalNumericFloat_20:
; break;
       bra.s     logicalNumericFloat_2
logicalNumericFloat_8:
; case 0xF7:  // <>
; if (!(oCCR & 0x04)) // z=0
       move.l    -4(A6),D0
       and.l     #4,D0
       bne.s     logicalNumericFloat_23
; *rVal = 1;
       move.l    -12(A6),A0
       move.l    #1,(A0)
logicalNumericFloat_23:
; break;
logicalNumericFloat_2:
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
       link      A6,#-8
; char ex = 0;
       clr.b     -5(A6)
; unsigned long oCCR = 0;
       clr.l     -4(A6)
; oCCR = fppComp(r, h);
       move.l    16(A6),-(A7)
       move.l    12(A6),-(A7)
       jsr       _fppComp
       addq.w    #8,A7
       move.l    D0,-4(A6)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
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
       move.l    -4(A6),D0
       and.l     #4,D0
       beq.s     logicalNumericFloatLong_11
; ex = 1;
       move.b    #1,-5(A6)
logicalNumericFloatLong_11:
; break;
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_4:
; case '>':
; if (!(oCCR & 0x08) && !(oCCR & 0x04))   // N=0 e Z=0
       move.l    -4(A6),D0
       and.l     #8,D0
       bne.s     logicalNumericFloatLong_13
       move.l    -4(A6),D0
       and.l     #4,D0
       bne.s     logicalNumericFloatLong_13
; ex = 1;
       move.b    #1,-5(A6)
logicalNumericFloatLong_13:
; break;
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_5:
; case '<':
; if ((oCCR & 0x08) && !(oCCR & 0x04))   // N=1 e Z=0
       move.l    -4(A6),D0
       and.l     #8,D0
       beq.s     logicalNumericFloatLong_15
       move.l    -4(A6),D0
       and.l     #4,D0
       bne.s     logicalNumericFloatLong_15
; ex = 1;
       move.b    #1,-5(A6)
logicalNumericFloatLong_15:
; break;
       bra       logicalNumericFloatLong_2
logicalNumericFloatLong_6:
; case 0xF5:  // >=
; if (!(oCCR & 0x08) || (oCCR & 0x04))   // N=0 ou Z=1
       move.l    -4(A6),D0
       and.l     #8,D0
       beq.s     logicalNumericFloatLong_19
       move.l    -4(A6),D0
       and.l     #4,D0
       beq.s     logicalNumericFloatLong_17
logicalNumericFloatLong_19:
; ex = 1;
       move.b    #1,-5(A6)
logicalNumericFloatLong_17:
; break;
       bra.s     logicalNumericFloatLong_2
logicalNumericFloatLong_7:
; case 0xF6:  // <=
; if ((oCCR & 0x08) || (oCCR & 0x04))   // N=1 ou Z=1
       move.l    -4(A6),D0
       and.l     #8,D0
       bne.s     logicalNumericFloatLong_22
       move.l    -4(A6),D0
       and.l     #4,D0
       beq.s     logicalNumericFloatLong_20
logicalNumericFloatLong_22:
; ex = 1;
       move.b    #1,-5(A6)
logicalNumericFloatLong_20:
; break;
       bra.s     logicalNumericFloatLong_2
logicalNumericFloatLong_8:
; case 0xF7:  // <>
; if (!(oCCR & 0x04)) // z=0
       move.l    -4(A6),D0
       and.l     #4,D0
       bne.s     logicalNumericFloatLong_23
; ex = 1;
       move.b    #1,-5(A6)
logicalNumericFloatLong_23:
; break;
logicalNumericFloatLong_2:
; }
; return ex;
       move.b    -5(A6),D0
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
       link      A6,#-16
; int t, ex;
; int *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
       move.l    12(A6),-8(A6)
; int *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
       move.l    16(A6),-4(A6)
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
       move.l    -8(A6),A0
       move.l    -4(A6),A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       bne.s     logicalNumericInt_11
       moveq     #1,D0
       bra.s     logicalNumericInt_12
logicalNumericInt_11:
       clr.l     D0
logicalNumericInt_12:
       move.l    -8(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_4:
; case '>':
; *rVal = (*rVal > *hVal);
       move.l    -8(A6),A0
       move.l    -4(A6),A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       ble.s     logicalNumericInt_13
       moveq     #1,D0
       bra.s     logicalNumericInt_14
logicalNumericInt_13:
       clr.l     D0
logicalNumericInt_14:
       move.l    -8(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_5:
; case '<':
; *rVal = (*rVal < *hVal);
       move.l    -8(A6),A0
       move.l    -4(A6),A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       bge.s     logicalNumericInt_15
       moveq     #1,D0
       bra.s     logicalNumericInt_16
logicalNumericInt_15:
       clr.l     D0
logicalNumericInt_16:
       move.l    -8(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_6:
; case 0xF5:
; *rVal = (*rVal >= *hVal);
       move.l    -8(A6),A0
       move.l    -4(A6),A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       blt.s     logicalNumericInt_17
       moveq     #1,D0
       bra.s     logicalNumericInt_18
logicalNumericInt_17:
       clr.l     D0
logicalNumericInt_18:
       move.l    -8(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalNumericInt_2
logicalNumericInt_7:
; case 0xF6:
; *rVal = (*rVal <= *hVal);
       move.l    -8(A6),A0
       move.l    -4(A6),A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       bgt.s     logicalNumericInt_19
       moveq     #1,D0
       bra.s     logicalNumericInt_20
logicalNumericInt_19:
       clr.l     D0
logicalNumericInt_20:
       move.l    -8(A6),A0
       move.l    D0,(A0)
; break;
       bra.s     logicalNumericInt_2
logicalNumericInt_8:
; case 0xF7:
; *rVal = (*rVal != *hVal);
       move.l    -8(A6),A0
       move.l    -4(A6),A1
       move.l    (A0),D0
       cmp.l     (A1),D0
       beq.s     logicalNumericInt_21
       moveq     #1,D0
       bra.s     logicalNumericInt_22
logicalNumericInt_21:
       clr.l     D0
logicalNumericInt_22:
       move.l    -8(A6),A0
       move.l    D0,(A0)
; break;
logicalNumericInt_2:
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
       link      A6,#-12
; int t, ex;
; int *rVal = r;
       move.l    12(A6),-4(A6)
; ex = ustrcmp(r,h);
       move.l    16(A6),-(A7)
       move.l    12(A6),-(A7)
       jsr       _ustrcmp
       addq.w    #8,A7
       move.l    D0,-8(A6)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
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
       move.l    -8(A6),D0
       bne.s     logicalString_11
       moveq     #1,D0
       bra.s     logicalString_12
logicalString_11:
       clr.l     D0
logicalString_12:
       move.l    -4(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalString_2
logicalString_4:
; case '>':
; *rVal = (ex > 0);
       move.l    -8(A6),D0
       cmp.l     #0,D0
       ble.s     logicalString_13
       moveq     #1,D0
       bra.s     logicalString_14
logicalString_13:
       clr.l     D0
logicalString_14:
       move.l    -4(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalString_2
logicalString_5:
; case '<':
; *rVal = (ex < 0);
       move.l    -8(A6),D0
       cmp.l     #0,D0
       bge.s     logicalString_15
       moveq     #1,D0
       bra.s     logicalString_16
logicalString_15:
       clr.l     D0
logicalString_16:
       move.l    -4(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalString_2
logicalString_6:
; case 0xF5:
; *rVal = (ex >= 0);
       move.l    -8(A6),D0
       cmp.l     #0,D0
       blt.s     logicalString_17
       moveq     #1,D0
       bra.s     logicalString_18
logicalString_17:
       clr.l     D0
logicalString_18:
       move.l    -4(A6),A0
       move.l    D0,(A0)
; break;
       bra       logicalString_2
logicalString_7:
; case 0xF6:
; *rVal = (ex <= 0);
       move.l    -8(A6),D0
       cmp.l     #0,D0
       bgt.s     logicalString_19
       moveq     #1,D0
       bra.s     logicalString_20
logicalString_19:
       clr.l     D0
logicalString_20:
       move.l    -4(A6),A0
       move.l    D0,(A0)
; break;
       bra.s     logicalString_2
logicalString_8:
; case 0xF7:
; *rVal = (ex != 0);
       move.l    -8(A6),D0
       beq.s     logicalString_21
       moveq     #1,D0
       bra.s     logicalString_22
logicalString_21:
       clr.l     D0
logicalString_22:
       move.l    -4(A6),A0
       move.l    D0,(A0)
; break;
logicalString_2:
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
       link      A6,#-252
; unsigned char vTemp[250];
; *vErroProc = 0x00;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       clr.w     (A0)
; if (!isalphas(*s)){
       move.l    8(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     find_var_1
; *vErroProc = 4; // not a variable
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       find_var_3
find_var_1:
; }
; if (strlen(s) < 3)
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       find_var_4
; {
; vTemp[0] = *s;
       move.l    8(A6),A0
       move.b    (A0),-250+0(A6)
; vTemp[2] = VARTYPEDEFAULT;
       move.b    #35,-250+2(A6)
; if (strlen(s) == 2 && *(s + 1) < 0x30)
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     find_var_6
       move.l    8(A6),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bge.s     find_var_6
; vTemp[2] = *(s + 1);
       move.l    8(A6),A0
       move.b    1(A0),-250+2(A6)
find_var_6:
; if (strlen(s) == 2 && isalphas(*(s + 1)))
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     find_var_8
       move.l    8(A6),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     find_var_8
; vTemp[1] = *(s + 1);
       move.l    8(A6),A0
       move.b    1(A0),-250+1(A6)
       bra.s     find_var_9
find_var_8:
; else
; vTemp[1] = 0x00;
       clr.b     -250+1(A6)
find_var_9:
       bra.s     find_var_5
find_var_4:
; }
; else
; {
; vTemp[0] = *s++;
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-250+0(A6)
; vTemp[1] = *s++;
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-250+1(A6)
; vTemp[2] = *s;
       move.l    8(A6),A0
       move.b    (A0),-250+2(A6)
find_var_5:
; }
; if (!findVariable(&vTemp))
       pea       -250(A6)
       jsr       _findVariable
       addq.w    #4,A7
       tst.l     D0
       bne.s     find_var_10
; {
; *vErroProc = 4; // not a variable
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra.s     find_var_3
find_var_10:
; }
; return vTemp;
       lea       -250(A6),A0
       move.l    A0,D0
find_var_3:
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
; if (*ftos>FOR_NEST)
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       move.l    (A0),D0
       cmp.l     #80,D0
       ble.s     forPush_1
; {
; *vErroProc = 10;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #10,(A0)
; return;
       bra       forPush_3
forPush_1:
; }
; *(forStack + *ftos) = i;
       move.l    A5,A0
       add.l     #_forStack,A0
       move.l    (A0),D0
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       move.l    (A0),D1
       muls      #20,D1
       add.l     D1,D0
       move.l    D0,A0
       lea       8(A6),A1
       moveq     #4,D0
       move.l    (A1)+,(A0)+
       dbra      D0,*-2
; *ftos = *ftos + 1;
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
forPush_3:
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
; for_stack i;
; *ftos = *ftos - 1;
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       subq.l    #1,(A0)
; if (*ftos<0)
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       move.l    (A0),D0
       cmp.l     #0,D0
       bge.s     forPop_1
; {
; *vErroProc = 11;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #11,(A0)
; return(*forStack);
       move.l    A5,A0
       add.l     #_forStack,A0
       move.l    (A0),A0
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
       move.l    A5,A1
       add.l     #_forStack,A1
       move.l    (A1),D0
       move.l    A5,A1
       add.l     #_ftos,A1
       move.l    (A1),A1
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
; if (*gtos>SUB_NEST)
       move.l    A5,A0
       add.l     #_gtos,A0
       move.l    (A0),A0
       move.l    (A0),D0
       cmp.l     #190,D0
       ble.s     gosubPush_1
; {
; *vErroProc = 12;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #12,(A0)
; return;
       bra.s     gosubPush_3
gosubPush_1:
; }
; *(gosubStack + *gtos)=i;
       move.l    A5,A0
       add.l     #_gosubStack,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_gtos,A1
       move.l    (A1),A1
       move.l    (A1),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
; *gtos = *gtos + 1;
       move.l    A5,A0
       add.l     #_gtos,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
gosubPush_3:
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
; unsigned long i;
; *gtos = *gtos - 1;
       move.l    A5,A0
       add.l     #_gtos,A0
       move.l    (A0),A0
       subq.l    #1,(A0)
; if (*gtos<0)
       move.l    A5,A0
       add.l     #_gtos,A0
       move.l    (A0),A0
       move.l    (A0),D0
       cmp.l     #0,D0
       bge.s     gosubPop_1
; {
; *vErroProc = 13;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #13,(A0)
; return 0;
       clr.l     D0
       bra.s     gosubPop_3
gosubPop_1:
; }
; i=*(gosubStack + *gtos);
       move.l    A5,A0
       add.l     #_gosubStack,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_gtos,A1
       move.l    (A1),A1
       move.l    (A1),D0
       lsl.l     #2,D0
       move.l    0(A0,D0.L),-4(A6)
; return i;
       move.l    -4(A6),D0
gosubPop_3:
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
       link      A6,#-8
; unsigned int iz, vRes = pbase;
       move.l    8(A6),-4(A6)
; if (pexp > 0)
       move.b    15(A6),D0
       cmp.b     #0,D0
       bls.s     powNum_1
; {
; pexp--;
       subq.b    #1,15(A6)
; for(iz = 0; iz < pexp; iz++)
       clr.l     -8(A6)
powNum_3:
       move.b    15(A6),D0
       and.l     #255,D0
       cmp.l     -8(A6),D0
       bls.s     powNum_5
; {
; vRes = vRes * pbase;
       move.l    -4(A6),-(A7)
       move.l    8(A6),-(A7)
       jsr       ULMUL
       move.l    (A7),-4(A6)
       addq.w    #8,A7
       addq.l    #1,-8(A6)
       bra       powNum_3
powNum_5:
       bra.s     powNum_2
powNum_1:
; }
; }
; else
; vRes = 1;
       move.l    #1,-4(A6)
powNum_2:
; return vRes;
       move.l    -4(A6),D0
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
       move.l    A5,A0
       add.l     #_floatBufferStr,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; STR_TO_FP();
       jsr       _STR_TO_FP
; vFpp = *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatBufferStr,A0
       move.l    (A0),A0
       move.l    12(A6),(A0)
; *floatNumD7 = pFpp;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    A5,A0
       add.l     #_floatNumD6,A0
       move.l    (A0),A0
       move.l    12(A6),(A0)
; FPP_SUM();
       jsr       _FPP_SUM
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    A5,A0
       add.l     #_floatNumD6,A0
       move.l    (A0),A0
       move.l    12(A6),(A0)
; FPP_SUB();
       jsr       _FPP_SUB
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    A5,A0
       add.l     #_floatNumD6,A0
       move.l    (A0),A0
       move.l    12(A6),(A0)
; FPP_MUL();
       jsr       _FPP_MUL
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    A5,A0
       add.l     #_floatNumD6,A0
       move.l    (A0),A0
       move.l    12(A6),(A0)
; FPP_DIV();
       jsr       _FPP_DIV
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    A5,A0
       add.l     #_floatNumD6,A0
       move.l    (A0),A0
       move.l    12(A6),(A0)
; FPP_PWR();
       jsr       _FPP_PWR
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_INT();
       jsr       _FPP_INT
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_FPP();
       jsr       _FPP_FPP
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_SIN();
       jsr       _FPP_SIN
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_COS();
       jsr       _FPP_COS
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_TAN();
       jsr       _FPP_TAN
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_SINH();
       jsr       _FPP_SINH
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_COSH();
       jsr       _FPP_COSH
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_TANH();
       jsr       _FPP_TANH
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_SQRT();
       jsr       _FPP_SQRT
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_LN();
       jsr       _FPP_LN
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_EXP();
       jsr       _FPP_EXP
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_ABS();
       jsr       _FPP_ABS
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; FPP_NEG();
       jsr       _FPP_NEG
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
       move.l    8(A6),(A0)
; *floatNumD6 = pFppD6;
       move.l    A5,A0
       add.l     #_floatNumD6,A0
       move.l    (A0),A0
       move.l    12(A6),(A0)
; FPP_CMP();
       jsr       _FPP_CMP
; return *floatNumD7;
       move.l    A5,A0
       add.l     #_floatNumD7,A0
       move.l    (A0),A0
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
       link      A6,#-236
; int ix, iy;
; unsigned char answer[200], varTipo, vTipoParam;
; char last_delim, last_token_type = 0;
       clr.b     -23(A6)
; unsigned char sqtdtam[10];
; long *vConvVal;
; long *vValor = answer;
       lea       -226(A6),A0
       move.l    A0,-8(A6)
; unsigned char *vTempRetParam = retParams;
       move.l    28(A6),-4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     procParam_8
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     procParam_8
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     procParam_6
procParam_8:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_6:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     procParam_9
       clr.l     D0
       bra       procParam_3
procParam_9:
; }
; if (qtdParam == 255)
       move.b    23(A6),D0
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     procParam_11
; *retParams++ = 0x00;
       move.l    28(A6),A0
       addq.l    #1,28(A6)
       clr.b     (A0)
procParam_11:
; for (ix = 0; ix < qtdParam; ix++)
       clr.l     -234(A6)
procParam_13:
       move.b    23(A6),D0
       and.l     #255,D0
       cmp.l     -234(A6),D0
       bls       procParam_15
; {
; if (qtdParam < 255)
       move.b    23(A6),D0
       and.w     #255,D0
       cmp.w     #255,D0
       bhs.s     procParam_16
; vTipoParam = tipoParams[ix];
       move.l    24(A6),A0
       move.l    -234(A6),D0
       move.b    0(A0,D0.L),-25(A6)
       bra.s     procParam_17
procParam_16:
; else
; vTipoParam = tipoParams[0];
       move.l    24(A6),A0
       move.b    (A0),-25(A6)
procParam_17:
; if (tipoRetorno == 0)
       move.b    11(A6),D0
       bne       procParam_18
; {
; // Valor Final
; if (*token_type == QUOTE)  /* se o parametro nao pedir string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne       procParam_20
; {
; if (vTipoParam != '$')
       move.b    -25(A6),D0
       cmp.b     #36,D0
       beq.s     procParam_22
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_22:
; }
; // Transfere a String pro retorno do parametro
; iy = 0;
       clr.l     -230(A6)
; while (token[iy])
procParam_24:
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -230(A6),D0
       tst.b     0(A0,D0.L)
       beq.s     procParam_26
; *retParams++ = token[iy++];
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -230(A6),D0
       addq.l    #1,-230(A6)
       move.l    28(A6),A1
       addq.l    #1,28(A6)
       move.b    0(A0,D0.L),(A1)
       bra       procParam_24
procParam_26:
; *retParams++ = 0x00;
       move.l    28(A6),A0
       addq.l    #1,28(A6)
       clr.b     (A0)
       bra       procParam_42
procParam_20:
; }
; else
; {
; /* is expression */
; last_token_type = *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),-23(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -226(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     procParam_27
       clr.l     D0
       bra       procParam_3
procParam_27:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne       procParam_29
; {
; if (vTipoParam != '$')   /* se o parametro nao pedir string, error */
       move.b    -25(A6),D0
       cmp.b     #36,D0
       beq.s     procParam_31
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_31:
; }
; // Transfere a String pro retorno do parametro
; iy = 0;
       clr.l     -230(A6)
; while (answer[iy])
procParam_33:
       move.l    -230(A6),D0
       lea       -226(A6),A0
       tst.b     0(A0,D0.L)
       beq.s     procParam_35
; *retParams++ = answer[iy++];
       move.l    -230(A6),D0
       addq.l    #1,-230(A6)
       lea       -226(A6),A0
       move.l    28(A6),A1
       addq.l    #1,28(A6)
       move.b    0(A0,D0.L),(A1)
       bra       procParam_33
procParam_35:
; *retParams++ = 0x00;
       move.l    28(A6),A0
       addq.l    #1,28(A6)
       clr.b     (A0)
       bra       procParam_42
procParam_29:
; }
; else
; {
; if (vTipoParam == '$')   /* se nao é uma string, mas o parametro pedir string, error */
       move.b    -25(A6),D0
       cmp.b     #36,D0
       bne.s     procParam_36
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_36:
; }
; // Converter aqui pro valor solicitado (de int pra dec e dec pra int). @ = nao converte
; if (vTipoParam != '@' && vTipoParam != *value_type)
       move.b    -25(A6),D0
       cmp.b     #64,D0
       beq       procParam_38
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    -25(A6),D0
       cmp.b     (A0),D0
       beq       procParam_38
; {
; if (vTipoParam == '%')
       move.b    -25(A6),D0
       cmp.b     #37,D0
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
       move.l    28(A6),A0
       addq.l    #1,28(A6)
       move.b    -226+0(A6),(A0)
; *retParams++ = answer[1];
       move.l    28(A6),A0
       addq.l    #1,28(A6)
       move.b    -226+1(A6),(A0)
; *retParams++ = answer[2];
       move.l    28(A6),A0
       addq.l    #1,28(A6)
       move.b    -226+2(A6),(A0)
; *retParams++ = answer[3];
       move.l    28(A6),A0
       addq.l    #1,28(A6)
       move.b    -226+3(A6),(A0)
; // Se for @, o proximo byte desse valor é o tipo
; if (vTipoParam == '@')
       move.b    -25(A6),D0
       cmp.b     #64,D0
       bne.s     procParam_42
; *retParams++ = *value_type;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.l    28(A6),A1
       addq.l    #1,28(A6)
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
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     procParam_44
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_44:
; }
; if (strlen(token) < 3)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       procParam_46
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       move.b    #35,-26(A6)
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     procParam_48
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     procParam_48
; varTipo = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-26(A6)
procParam_48:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne       procParam_50
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     procParam_50
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
       bra.s     procParam_51
procParam_50:
; else
; *(varName + 1) = 0x00;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       clr.b     1(A0)
procParam_51:
; *(varName + 2) = varTipo;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    -26(A6),2(A0)
       bra       procParam_47
procParam_46:
; }
; else
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    2(A0),2(A1)
; varTipo = *(varName + 2);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    2(A0),-26(A6)
procParam_47:
; }
; answer[0] = varTipo;
       move.b    -26(A6),-226+0(A6)
procParam_19:
; }
; if ((ix + 1) != qtdParam)
       move.l    -234(A6),D0
       addq.l    #1,D0
       move.b    23(A6),D1
       and.l     #255,D1
       cmp.l     D1,D0
       beq       procParam_62
; {
; // Verifica se tem separador
; if (tipoSeparador == 0 && qtdParam != 255)
       move.b    19(A6),D0
       bne.s     procParam_54
       move.b    23(A6),D0
       and.w     #255,D0
       cmp.w     #255,D0
       beq.s     procParam_54
; {
; *vErroProc = 27;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #27,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_54:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     procParam_56
       clr.l     D0
       bra       procParam_3
procParam_56:
; // Se for um separador diferente do definido
; if (*token != tipoSeparador)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     19(A6),D0
       beq.s     procParam_58
; {
; // Se for qtd definida, erro
; if (qtdParam != 255)
       move.b    23(A6),D0
       and.w     #255,D0
       cmp.w     #255,D0
       beq.s     procParam_60
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_60:
; }
; else
; {
; *vTempRetParam = (ix + 1);
       move.l    -234(A6),D0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     procParam_62
       clr.l     D0
       bra       procParam_3
procParam_62:
       addq.l    #1,-234(A6)
       bra       procParam_13
procParam_15:
; }
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-24(A6)
; if (temParenteses)
       tst.b     15(A6)
       beq       procParam_70
; {
; if (qtdParam == 1)
       move.b    23(A6),D0
       cmp.b     #1,D0
       bne.s     procParam_68
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     procParam_68
       clr.l     D0
       bra       procParam_3
procParam_68:
; }
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type != CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     procParam_70
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       procParam_3
procParam_70:
; }
; }
; if (qtdParam != 1 && tipoRetorno == 0)
       move.b    23(A6),D0
       cmp.b     #1,D0
       beq       procParam_78
       move.b    11(A6),D0
       bne       procParam_78
; {
; if (*token != 0xBA && *token != 0x86)   // AT and TO token's
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #186,D0
       beq       procParam_78
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq       procParam_78
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     procParam_76
       clr.l     D0
       bra.s     procParam_3
procParam_76:
; if (*token == ':' || *token == tipoSeparador)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq.s     procParam_80
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
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
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // FUNCOES BASIC
; //-----------------------------------------------------------------------------
; //-----------------------------------------------------------------------------
; // Joga pra tela Texto.
; // Syntaxe:
; //      Print "<Texto>"/<value>[, "<Texto>"/<value>][; "<Texto>"/<value>]
; //-----------------------------------------------------------------------------
; int basPrint(void)
; {
       xdef      _basPrint
_basPrint:
       link      A6,#-520
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -518(A6)
       clr.b     -517(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -248(A6)
       clr.l     -244(A6)
       clr.l     -240(A6)
       clr.l     -236(A6)
; unsigned char answer[200];
; long *lVal = answer;
       lea       -228(A6),A0
       move.l    A0,-28(A6)
; int  *iVal = answer;
       lea       -228(A6),A0
       move.l    A0,-24(A6)
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; do {
basPrint_1:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPrint_3
       clr.l     D0
       bra       basPrint_5
basPrint_3:
; if (*tok == EOL || *tok == FINISHED)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPrint_8
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basPrint_6
basPrint_8:
; break;
       bra       basPrint_2
basPrint_6:
; if (*token_type == QUOTE) { // is string
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPrint_9
; printText(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPrint_11
       clr.l     D0
       bra       basPrint_5
basPrint_11:
       bra       basPrint_23
basPrint_9:
; }
; else if (*token!=':') { // is expression
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq       basPrint_23
; last_token_type = *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -228(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPrint_15
       clr.l     D0
       bra       basPrint_5
basPrint_15:
; if (*value_type != '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq       basPrint_20
; {
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basPrint_19
; {
; // Real
; fppTofloatString(*lVal, answer);
       pea       -228(A6)
       move.l    -28(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppTofloatString
       addq.w    #8,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -228(A6)
       move.l    -24(A6),A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
basPrint_20:
; }
; }
; printText(answer);
       pea       -228(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPrint_23
       clr.l     D0
       bra       basPrint_5
basPrint_23:
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-12(A6)
; if (*token==',') {
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basPrint_25
; // compute number of spaces to move to next tab
; spaces = 8 - (len % 8);
       moveq     #8,D0
       ext.w     D0
       ext.l     D0
       move.l    -20(A6),-(A7)
       pea       8
       jsr       LDIV
       move.l    4(A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,-16(A6)
; while(spaces) {
basPrint_27:
       tst.l     -16(A6)
       beq.s     basPrint_29
; printChar(' ',1);
       pea       1
       pea       32
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; spaces--;
       subq.l    #1,-16(A6)
       bra       basPrint_27
basPrint_29:
       bra       basPrint_35
basPrint_25:
; }
; }
; else if (*token==';' || *token=='+')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq.s     basPrint_32
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #43,D0
       bne.s     basPrint_30
basPrint_32:
       bra       basPrint_35
basPrint_30:
; /* do nothing */;
; else if (*token==':')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     basPrint_33
; {
; *pointerRunProg = *pointerRunProg - 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       subq.l    #1,(A0)
       bra       basPrint_35
basPrint_33:
; }
; else if (*tok!=EOL && *tok!=FINISHED && *token!=':')
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq       basPrint_35
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basPrint_35
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq.s     basPrint_35
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basPrint_5
basPrint_35:
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq       basPrint_1
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq       basPrint_1
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #43,D0
       beq       basPrint_1
basPrint_2:
; }
; } while (*token==';' || *token==',' || *token=='+');
; if (*tok == EOL || *tok == FINISHED || *token==':') {
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPrint_39
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basPrint_39
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     basPrint_40
basPrint_39:
; if (last_delim != ';' && last_delim!=',')
       move.b    -12(A6),D0
       cmp.b     #59,D0
       beq.s     basPrint_40
       move.b    -12(A6),D0
       cmp.b     #44,D0
       beq.s     basPrint_40
; printText("\r\n");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
basPrint_40:
; }
; return 0;
       clr.l     D0
basPrint_5:
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
       link      A6,#-328
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -328(A6)
       clr.b     -327(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -58(A6)
       clr.l     -54(A6)
       clr.l     -50(A6)
       clr.l     -46(A6)
; unsigned char answer[10];
; long *lVal = answer;
       lea       -38(A6),A0
       move.l    A0,-28(A6)
; int  *iVal = answer;
       lea       -38(A6),A0
       move.l    A0,-24(A6)
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basChr_1
       clr.l     D0
       bra       basChr_3
basChr_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basChr_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basChr_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basChr_4
basChr_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basChr_7
       clr.l     D0
       bra       basChr_3
basChr_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basChr_9
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_9:
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -38(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basChr_11
       clr.l     D0
       bra       basChr_3
basChr_11:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basChr_13
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_13:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basChr_15
; {
; *iVal = fppInt(*iVal);
       move.l    -24(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -24(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basChr_15:
; }
; // Inteiro
; if (*iVal<0 || *iVal>255)
       move.l    -24(A6),A0
       move.l    (A0),D0
       cmp.l     #0,D0
       blt.s     basChr_19
       move.l    -24(A6),A0
       move.l    (A0),D0
       cmp.l     #255,D0
       ble.s     basChr_17
basChr_19:
; {
; *vErroProc = 5;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basChr_3
basChr_17:
; }
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-12(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basChr_20
       clr.l     D0
       bra       basChr_3
basChr_20:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basChr_22
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra.s     basChr_3
basChr_22:
; }
; *token=(char)*iVal;
       move.l    -24(A6),A0
       move.l    (A0),D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=0x00;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     1(A0)
; *value_type='$';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basChr_3:
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
       link      A6,#-340
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -340(A6)
       clr.b     -339(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -70(A6)
       clr.l     -66(A6)
       clr.l     -62(A6)
       clr.l     -58(A6)
; unsigned char answer[20];
; int  iVal = answer;
       lea       -50(A6),A0
       move.l    A0,-30(A6)
; int vValue = 0;
       clr.l     -26(A6)
; int len=0, spaces;
       clr.l     -22(A6)
; char last_delim, last_value_type=' ', last_token_type = 0;
       move.b    #32,-12(A6)
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basVal_1
       clr.l     D0
       bra       basVal_3
basVal_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basVal_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basVal_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basVal_4
basVal_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basVal_3
basVal_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basVal_7
       clr.l     D0
       bra       basVal_3
basVal_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne       basVal_9
; if (strchr(token,'.'))  // verifica se eh numero inteiro ou real
       pea       46
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq.s     basVal_11
; {
; last_value_type='#'; // Real
       move.b    #35,-12(A6)
; iVal=floatStringToFpp(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,-30(A6)
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.b    #37,-12(A6)
; iVal=atoi(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-30(A6)
basVal_12:
       bra       basVal_20
basVal_9:
; }
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -50(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basVal_15
       clr.l     D0
       bra       basVal_3
basVal_15:
; if (*value_type != '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basVal_17
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basVal_3
basVal_17:
; }
; if (strchr(answer,'.'))  // verifica se eh numero inteiro ou real
       pea       46
       pea       -50(A6)
       jsr       _strchr
       addq.w    #8,A7
       tst.l     D0
       beq.s     basVal_19
; {
; last_value_type='#'; // Real
       move.b    #35,-12(A6)
; iVal=floatStringToFpp(answer);
       pea       -50(A6)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,-30(A6)
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.b    #37,-12(A6)
; iVal=atoi(answer);
       pea       -50(A6)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-30(A6)
basVal_20:
; }
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-13(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basVal_23
       clr.l     D0
       bra       basVal_3
basVal_23:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basVal_25
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basVal_3
basVal_25:
; }
; *token=((int)(iVal & 0xFF000000) >> 24);
       move.l    -30(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
       move.l    -30(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
       move.l    -30(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(iVal & 0x000000FF);
       move.l    -30(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; *value_type = last_value_type;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    -12(A6),(A0)
; return 0;
       clr.l     D0
basVal_3:
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
       link      A6,#-368
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -368(A6)
       clr.b     -367(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -98(A6)
       clr.l     -94(A6)
       clr.l     -90(A6)
       clr.l     -86(A6)
; unsigned char answer[50];
; long *lVal = answer;
       lea       -78(A6),A0
       move.l    A0,-28(A6)
; int  *iVal = answer;
       lea       -78(A6),A0
       move.l    A0,-24(A6)
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basStr_1
       clr.l     D0
       bra       basStr_3
basStr_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basStr_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basStr_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basStr_4
basStr_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basStr_7
       clr.l     D0
       bra       basStr_3
basStr_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basStr_9
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_9:
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -78(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basStr_11
       clr.l     D0
       bra       basStr_3
basStr_11:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basStr_13
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_13:
; }
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-12(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basStr_15
       clr.l     D0
       bra       basStr_3
basStr_15:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basStr_17
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basStr_3
basStr_17:
; }
; if (*value_type=='#')    // real
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basStr_19
; {
; fppTofloatString(*iVal,token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       move.l    -24(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppTofloatString
       addq.w    #8,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       move.l    -24(A6),A0
       move.l    (A0),-(A7)
       jsr       _itoa
       add.w     #12,A7
basStr_20:
; }
; *value_type='$';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basStr_3:
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
       link      A6,#-520
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -518(A6)
       clr.b     -517(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -248(A6)
       clr.l     -244(A6)
       clr.l     -240(A6)
       clr.l     -236(A6)
; unsigned char answer[200];
; int iVal = 0;
       clr.l     -28(A6)
; int vValue = 0;
       clr.l     -24(A6)
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim, last_token_type = 0;
       clr.b     -11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLen_1
       clr.l     D0
       bra       basLen_3
basLen_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basLen_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basLen_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basLen_4
basLen_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLen_3
basLen_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLen_7
       clr.l     D0
       bra       basLen_3
basLen_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLen_9
; iVal=strlen(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-28(A6)
       bra       basLen_10
basLen_9:
; }
; else { /* is expression */
; last_token_type = *token_type;
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),-11(A6)
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -228(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLen_11
       clr.l     D0
       bra       basLen_3
basLen_11:
; if (*value_type != '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basLen_13
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLen_3
basLen_13:
; }
; iVal=strlen(answer);
       pea       -228(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-28(A6)
basLen_10:
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-12(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLen_15
       clr.l     D0
       bra       basLen_3
basLen_15:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basLen_17
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLen_3
basLen_17:
; }
; *token=((int)(iVal & 0xFF000000) >> 24);
       move.l    -28(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
       move.l    -28(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
       move.l    -28(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(iVal & 0x000000FF);
       move.l    -28(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; *value_type='%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basLen_3:
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
       link      A6,#-408
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -406(A6)
       clr.b     -405(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -136(A6)
       clr.l     -132(A6)
       clr.l     -128(A6)
       clr.l     -124(A6)
; unsigned char answer[50];
; long *lVal = answer;
       lea       -116(A6),A0
       move.l    A0,-66(A6)
; int  *iVal = answer;
       lea       -116(A6),A0
       move.l    A0,-62(A6)
; long vTotal = 0;
       clr.l     -58(A6)
; char vBuffer [sizeof(long)*8+1];
; int len=0, spaces;
       clr.l     -20(A6)
; char last_delim;
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basFre_1
       clr.l     D0
       bra       basFre_3
basFre_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basFre_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basFre_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basFre_4
basFre_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basFre_3
basFre_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basFre_7
       clr.l     D0
       bra       basFre_3
basFre_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basFre_9
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -116(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basFre_11
       clr.l     D0
       bra       basFre_3
basFre_11:
; if (*iVal!=0)
       move.l    -62(A6),A0
       move.l    (A0),D0
       beq.s     basFre_13
; {
; *vErroProc = 5;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basFre_3
basFre_13:
; }
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-11(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basFre_15
       clr.l     D0
       bra       basFre_3
basFre_15:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basFre_17
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basFre_3
basFre_17:
; }
; // Calcula Quantidade de Memoria e printa na tela
; vTotal = (pStartArrayVar - pStartSimpVar) + (pStartString - pStartArrayVar);
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       move.l    (A0),D0
       move.l    A5,A0
       add.l     #_pStartSimpVar,A0
       sub.l     (A0),D0
       move.l    A5,A0
       add.l     #_pStartString,A0
       move.l    (A0),D1
       move.l    A5,A0
       add.l     #_pStartArrayVar,A0
       sub.l     (A0),D1
       add.l     D1,D0
       move.l    D0,-58(A6)
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
       move.l    -58(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vTotal & 0x00FF0000) >> 16);
       move.l    -58(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vTotal & 0x0000FF00) >> 8);
       move.l    -58(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(vTotal & 0x000000FF);
       move.l    -58(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; *value_type='%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basFre_3:
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
       link      A6,#-8
; unsigned long vReal = 0, vResult = 0;
       clr.l     -8(A6)
       clr.l     -4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basTrig_1
       clr.l     D0
       bra       basTrig_3
basTrig_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basTrig_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basTrig_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basTrig_4
basTrig_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basTrig_3
basTrig_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basTrig_7
       clr.l     D0
       bra       basTrig_3
basTrig_7:
; putback();
       jsr       _putback
; getExp(&vReal); //
       pea       -8(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basTrig_9
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basTrig_3
basTrig_9:
; }
; else if (*value_type != '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       beq.s     basTrig_11
; {
; *value_type='#'; // Real
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
; vReal=fppReal(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    D0,-8(A6)
basTrig_11:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basTrig_13
       clr.l     D0
       bra       basTrig_3
basTrig_13:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basTrig_15
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    -8(A6),-(A7)
       jsr       _fppSin
       addq.w    #4,A7
       move.l    D0,-4(A6)
; break;
       bra       basTrig_18
basTrig_21:
; case 2: // cos
; vResult = fppCos(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppCos
       addq.w    #4,A7
       move.l    D0,-4(A6)
; break;
       bra       basTrig_18
basTrig_22:
; case 3: // tan
; vResult = fppTan(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppTan
       addq.w    #4,A7
       move.l    D0,-4(A6)
; break;
       bra       basTrig_18
basTrig_23:
; case 4: // log (ln)
; vResult = fppLn(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppLn
       addq.w    #4,A7
       move.l    D0,-4(A6)
; break;
       bra       basTrig_18
basTrig_24:
; case 5: // exp
; vResult = fppExp(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppExp
       addq.w    #4,A7
       move.l    D0,-4(A6)
; break;
       bra.s     basTrig_18
basTrig_25:
; case 6: // sqrt
; vResult = fppSqrt(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppSqrt
       addq.w    #4,A7
       move.l    D0,-4(A6)
; break;
       bra.s     basTrig_18
basTrig_17:
; default:
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basTrig_3
basTrig_18:
; }
; *token=((int)(vResult & 0xFF000000) >> 24);
       move.l    -4(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
       move.l    -4(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
       move.l    -4(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(vResult & 0x000000FF);
       move.l    -4(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; *value_type = '#';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
; return 0;
       clr.l     D0
basTrig_3:
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
       link      A6,#-28
; unsigned char answer[20];
; int  iVal = answer;
       lea       -26(A6),A0
       move.l    A0,-6(A6)
; char last_delim;
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basAsc_1
       clr.l     D0
       bra       basAsc_3
basAsc_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basAsc_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basAsc_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basAsc_4
basAsc_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basAsc_7
       clr.l     D0
       bra       basAsc_3
basAsc_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne       basAsc_9
; if (strlen(token)>1)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #1,D0
       ble.s     basAsc_11
; {
; *vErroProc = 6;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #6,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_11:
; }
; iVal = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-6(A6)
       bra       basAsc_10
basAsc_9:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -26(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basAsc_13
       clr.l     D0
       bra       basAsc_3
basAsc_13:
; if (*value_type != '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basAsc_15
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_15:
; }
; iVal = *answer;
       move.b    -26(A6),D0
       and.l     #255,D0
       move.l    D0,-6(A6)
basAsc_10:
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-1(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basAsc_17
       clr.l     D0
       bra       basAsc_3
basAsc_17:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basAsc_19
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAsc_3
basAsc_19:
; }
; *token=((int)(iVal & 0xFF000000) >> 24);
       move.l    -6(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
       move.l    -6(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
       move.l    -6(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(iVal & 0x000000FF);
       move.l    -6(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basAsc_3:
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
       link      A6,#-440
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -438(A6)
       clr.l     -434(A6)
       clr.l     -430(A6)
       clr.l     -426(A6)
; unsigned char answer[200], vTemp[200];
; int vqtd = 0, vstart = 0;
       clr.l     -18(A6)
       clr.l     -14(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_1
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basLeftRightMid_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basLeftRightMid_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basLeftRightMid_4
basLeftRightMid_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_7
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLeftRightMid_9
; strcpy(vTemp, token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       pea       -218(A6)
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_11
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_11:
; if (*value_type != '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basLeftRightMid_13
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_13:
; }
; strcpy(vTemp, answer);
       pea       -418(A6)
       pea       -218(A6)
       jsr       _strcpy
       addq.w    #8,A7
basLeftRightMid_10:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_15
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_15:
; // Deve ser uma virgula para Receber a qtd, e se for mid = a posiao incial
; if (*token!=',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basLeftRightMid_17
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_17:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_19
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_19:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLeftRightMid_21
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.b    11(A6),D0
       cmp.b     #77,D0
       bne.s     basLeftRightMid_23
; {
; getExp(&vstart);
       pea       -14(A6)
       jsr       _getExp
       addq.w    #4,A7
; vqtd=strlen(vTemp);
       pea       -218(A6)
       jsr       _strlen
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_25
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_25:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLeftRightMid_27
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_27:
; }
; }
; if (pTipo == 'M')
       move.b    11(A6),D0
       cmp.b     #77,D0
       bne       basLeftRightMid_39
; {
; // Deve ser uma virgula para Receber a qtd
; if (*token==',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basLeftRightMid_39
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_33
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_33:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLeftRightMid_35
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_37
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_37:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLeftRightMid_39
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLeftRightMid_41
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_41:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basLeftRightMid_43
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basLeftRightMid_3
basLeftRightMid_43:
; }
; if (vqtd > strlen(vTemp))
       pea       -218(A6)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     -18(A6),D0
       bge.s     basLeftRightMid_48
; {
; if (pTipo=='M')
       move.b    11(A6),D0
       cmp.b     #77,D0
       bne.s     basLeftRightMid_47
; vqtd = (strlen(vTemp) - vstart) + 1;
       pea       -218(A6)
       jsr       _strlen
       addq.w    #4,A7
       sub.l     -14(A6),D0
       addq.l    #1,D0
       move.l    D0,-18(A6)
       bra.s     basLeftRightMid_48
basLeftRightMid_47:
; else
; vqtd = strlen(vTemp);
       pea       -218(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-18(A6)
basLeftRightMid_48:
; }
; if (pTipo == 'L') // Left$
       move.b    11(A6),D0
       cmp.b     #76,D0
       bne       basLeftRightMid_49
; {
; for (ix = 0; ix < vqtd; ix++)
       clr.l     -438(A6)
basLeftRightMid_51:
       move.l    -438(A6),D0
       cmp.l     -18(A6),D0
       bge.s     basLeftRightMid_53
; *(token + ix) = vTemp[ix];
       move.l    -438(A6),D0
       lea       -218(A6),A0
       move.l    A5,A1
       add.l     #_token,A1
       move.l    (A1),A1
       move.l    -438(A6),D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-438(A6)
       bra       basLeftRightMid_51
basLeftRightMid_53:
; *(token + ix) = 0x00;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -438(A6),D0
       clr.b     0(A0,D0.L)
       bra       basLeftRightMid_55
basLeftRightMid_49:
; }
; else if (pTipo == 'R') // Right$
       move.b    11(A6),D0
       cmp.b     #82,D0
       bne       basLeftRightMid_54
; {
; iy = strlen(vTemp);
       pea       -218(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-434(A6)
; iz = (iy - vqtd);
       move.l    -434(A6),D0
       sub.l     -18(A6),D0
       move.l    D0,-430(A6)
; iw = 0;
       clr.l     -426(A6)
; for (ix = iz; ix < iy; ix++)
       move.l    -430(A6),-438(A6)
basLeftRightMid_56:
       move.l    -438(A6),D0
       cmp.l     -434(A6),D0
       bge.s     basLeftRightMid_58
; *(token + iw++) = vTemp[ix];
       move.l    -438(A6),D0
       lea       -218(A6),A0
       move.l    A5,A1
       add.l     #_token,A1
       move.l    (A1),A1
       move.l    -426(A6),D1
       addq.l    #1,-426(A6)
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.l    #1,-438(A6)
       bra       basLeftRightMid_56
basLeftRightMid_58:
; *(token + iw)=0x00;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -426(A6),D0
       clr.b     0(A0,D0.L)
       bra       basLeftRightMid_55
basLeftRightMid_54:
; }
; else  // Mid$
; {
; iy = strlen(vTemp);
       pea       -218(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,-434(A6)
; iw=0;
       clr.l     -426(A6)
; vstart--;
       subq.l    #1,-14(A6)
; for (ix = vstart; ix < iy; ix++)
       move.l    -14(A6),-438(A6)
basLeftRightMid_59:
       move.l    -438(A6),D0
       cmp.l     -434(A6),D0
       bge       basLeftRightMid_61
; {
; if (iw <= iy && vqtd-- > 0)
       move.l    -426(A6),D0
       cmp.l     -434(A6),D0
       bgt.s     basLeftRightMid_62
       move.l    -18(A6),D0
       subq.l    #1,-18(A6)
       cmp.l     #0,D0
       ble.s     basLeftRightMid_62
; *(token + iw++) = vTemp[ix];
       move.l    -438(A6),D0
       lea       -218(A6),A0
       move.l    A5,A1
       add.l     #_token,A1
       move.l    (A1),A1
       move.l    -426(A6),D1
       addq.l    #1,-426(A6)
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra.s     basLeftRightMid_63
basLeftRightMid_62:
; else
; break;
       bra.s     basLeftRightMid_61
basLeftRightMid_63:
       addq.l    #1,-438(A6)
       bra       basLeftRightMid_59
basLeftRightMid_61:
; }
; *(token + iw) = 0x00;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -426(A6),D0
       clr.b     0(A0,D0.L)
basLeftRightMid_55:
; }
; *value_type = '$';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basLeftRightMid_3:
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
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPeekPoke_1
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basPeekPoke_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basPeekPoke_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basPeekPoke_4
basPeekPoke_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPeekPoke_7
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPeekPoke_9
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPeekPoke_11
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_11:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPeekPoke_13
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basPeekPoke_25
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPeekPoke_19
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_19:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPeekPoke_21
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPeekPoke_23
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_23:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPeekPoke_25
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPeekPoke_27
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_27:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basPeekPoke_29
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basPeekPoke_3
basPeekPoke_29:
; }
; if (pTipo == 'R')
       move.b    11(A6),D0
       cmp.b     #82,D0
       bne       basPeekPoke_31
; {
; *token = 0;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     (A0)
; *(token + 1) = 0;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     1(A0)
; *(token + 2) = 0;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       clr.b     2(A0)
; *(token + 3) = *vEnd;
       move.l    -18(A6),A0
       move.l    A5,A1
       add.l     #_token,A1
       move.l    (A1),A1
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
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basPeekPoke_3:
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
       link      A6,#-456
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -456(A6)
       clr.l     -452(A6)
       clr.l     -448(A6)
       clr.l     -444(A6)
; unsigned char answer[30], vTemp[30];
; unsigned char sqtdtam[10];
; unsigned int vDim[88], ixDim = 0, vTempDim = 0;
       clr.l     -14(A6)
       clr.l     -10(A6)
; unsigned char varTipo;
; long vRetFV;
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basDim_1
       clr.l     D0
       bra       basDim_3
basDim_1:
; // Pega o nome da variavel
; if (!isalphas(*token)) {
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basDim_4
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_4:
; }
; if (strlen(token) < 3)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basDim_6
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       move.b    #35,-5(A6)
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basDim_8
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basDim_8
; varTipo = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-5(A6)
basDim_8:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne       basDim_10
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basDim_10
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
       bra.s     basDim_11
basDim_10:
; else
; *(varName + 1) = 0x00;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       clr.b     1(A0)
basDim_11:
; *(varName + 2) = varTipo;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    -5(A6),2(A0)
       bra       basDim_7
basDim_6:
; }
; else
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-448(A6)
; varTipo = *(varName + 2);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    2(A0),-5(A6)
basDim_7:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basDim_12
       clr.l     D0
       bra       basDim_3
basDim_12:
; // Erro, primeiro caracter depois da variavel, deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basDim_16
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basDim_16
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basDim_14
basDim_16:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basDim_19
       clr.l     D0
       bra       basDim_3
basDim_19:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basDim_21
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -10(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basDim_23
       clr.l     D0
       bra       basDim_3
basDim_23:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basDim_25
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_25:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basDim_27
; {
; vTempDim = fppInt(vTempDim);
       move.l    -10(A6),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,-10(A6)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basDim_27:
; }
; vTempDim += 1; // porque nao é de 1 a x, é de 0 a x, entao é x + 1
       addq.l    #1,-10(A6)
; vDim[ixDim] = vTempDim;
       move.l    -14(A6),D0
       lsl.l     #2,D0
       lea       -366(A6),A0
       move.l    -10(A6),0(A0,D0.L)
; ixDim++;
       addq.l    #1,-14(A6)
; }
; if (*token == ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne.s     basDim_29
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
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
       move.l    -14(A6),D0
       cmp.l     #1,D0
       bhs.s     basDim_31
; {
; *vErroProc = 21;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #21,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_31:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basDim_33
       clr.l     D0
       bra       basDim_3
basDim_33:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basDim_35
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basDim_3
basDim_35:
; }
; // assign the value
; vRetFV = findVariable(varName);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-4(A6)
; // Se nao existe a variavel, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     -4(A6)
       bne.s     basDim_37
; createVariableArray(varName, varTipo, ixDim, vDim);
       pea       -366(A6)
       move.l    -14(A6),-(A7)
       move.b    -5(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _createVariableArray
       add.w     #16,A7
       bra.s     basDim_38
basDim_37:
; else
; {
; *vErroProc = 23;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #23,(A0)
; return 0;
       clr.l     D0
       bra.s     basDim_3
basDim_38:
; }
; return 0;
       clr.l     D0
basDim_3:
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
       link      A6,#-8
; unsigned int vCond = 0;
       clr.l     -8(A6)
; unsigned char *vTempPointer;
; getExp(&vCond); // get target value
       pea       -8(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basIf_3
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basIf_1
basIf_3:
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basIf_4
basIf_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basIf_5
       clr.l     D0
       bra       basIf_4
basIf_5:
; if (*token!=0x83)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #131,D0
       beq.s     basIf_7
; {
; *vErroProc = 8;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #8,(A0)
; return 0;
       clr.l     D0
       bra       basIf_4
basIf_7:
; }
; if (vCond)
       tst.l     -8(A6)
       beq.s     basIf_9
; {
; // Vai pro proximo comando apos o Then e continua
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; // simula ":" para continuar a execucao
; *doisPontos = 1;
       move.l    A5,A0
       add.l     #_doisPontos,A0
       move.l    (A0),A0
       move.b    #1,(A0)
       bra       basIf_13
basIf_9:
; }
; else
; {
; // Ignora toda a linha
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; while (*vTempPointer)
basIf_11:
       move.l    -4(A6),A0
       tst.b     (A0)
       beq.s     basIf_13
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
       bra       basIf_11
basIf_13:
; }
; }
; return 0;
       clr.l     D0
basIf_4:
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
       link      A6,#-232
; long vRetFV, iz;
; unsigned char varTipo;
; unsigned char value[200];
; unsigned long *lValue = &value;
       lea       -220(A6),A0
       move.l    A0,-20(A6)
; unsigned char sqtdtam[10];
; unsigned char vArray = 0;
       clr.b     -5(A6)
; unsigned char *vTempPointer;
; /* get the variable name */
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLet_1
       clr.l     D0
       bra       basLet_3
basLet_1:
; if (!isalphas(*token)) {
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basLet_4
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basLet_3
basLet_4:
; }
; if (strlen(token) < 3)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basLet_6
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       move.b    #35,-221(A6)
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basLet_8
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basLet_8
; varTipo = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-221(A6)
basLet_8:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne       basLet_10
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basLet_10
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
       bra.s     basLet_11
basLet_10:
; else
; *(varName + 1) = 0x00;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       clr.b     1(A0)
basLet_11:
; *(varName + 2) = varTipo;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    -221(A6),2(A0)
       bra       basLet_7
basLet_6:
; }
; else
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-226(A6)
; varTipo = *(varName + 2);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    2(A0),-221(A6)
basLet_7:
; }
; // verifica se é array (abre parenteses no inicio)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; if (*vTempPointer == 0x28)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       basLet_12
; {
; vRetFV = findVariable(varName);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-230(A6)
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLet_14
       clr.l     D0
       bra       basLet_3
basLet_14:
; if (!vRetFV)
       tst.l     -230(A6)
       bne.s     basLet_16
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basLet_3
basLet_16:
; }
; vArray = 1;
       move.b    #1,-5(A6)
basLet_12:
; }
; // get the equals sign
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLet_18
       clr.l     D0
       bra       basLet_3
basLet_18:
; if (*token!='=') {
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     basLet_20
; *vErroProc = 3;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #3,(A0)
; return 0;
       clr.l     D0
       bra       basLet_3
basLet_20:
; }
; /* get the value to assign to varName */
; getExp(&value);
       pea       -220(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (varTipo == '#' && *value_type != '#')
       move.b    -221(A6),D0
       cmp.b     #35,D0
       bne.s     basLet_22
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       beq.s     basLet_22
; *lValue = fppReal(*lValue);
       move.l    -20(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -20(A6),A0
       move.l    D0,(A0)
basLet_22:
; // assign the value
; if (!vArray)
       tst.b     -5(A6)
       bne       basLet_24
; {
; vRetFV = findVariable(varName);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-230(A6)
; // Se nao existe a variavel, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     -230(A6)
       bne.s     basLet_26
; createVariable(varName, value, varTipo);
       move.b    -221(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -220(A6)
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _createVariable
       add.w     #12,A7
       bra.s     basLet_27
basLet_26:
; else // se ja existe, altera
; updateVariable((vRetFV + 3), value, varTipo, 1);
       pea       1
       move.b    -221(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -220(A6)
       move.l    -230(A6),D1
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
       move.b    -221(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -220(A6)
       move.l    -230(A6),-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basLet_25:
; }
; return 0;
       clr.l     D0
basLet_3:
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
       link      A6,#-784
; unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
       clr.b     -782(A6)
       clr.b     -781(A6)
; char sNumLin [sizeof(short)*8+1];
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -512(A6)
       clr.l     -508(A6)
       clr.l     -504(A6)
       clr.l     -500(A6)
; unsigned char answer[200], vtec;
; long *lVal = answer;
       lea       -492(A6),A0
       move.l    A0,-290(A6)
; int  *iVal = answer;
       lea       -492(A6),A0
       move.l    A0,-286(A6)
; char vTemTexto = 0;
       clr.b     -281(A6)
; int len=0, spaces;
       clr.l     -280(A6)
; char last_delim;
; unsigned char vbufInput[256];
; unsigned char *buffptr = vbufInput;
       lea       -270(A6),A0
       move.l    A0,-14(A6)
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basInputGet_3
       clr.l     D0
       bra       basInputGet_5
basInputGet_3:
; if (*tok == EOL || *tok == FINISHED)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basInputGet_8
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basInputGet_6
basInputGet_8:
; break;
       bra       basInputGet_2
basInputGet_6:
; if (*token_type == QUOTE) /* is string */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne       basInputGet_9
; {
; if (vTemTexto)
       tst.b     -281(A6)
       beq.s     basInputGet_11
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_11:
; }
; printText(token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basInputGet_13
       clr.l     D0
       bra       basInputGet_5
basInputGet_13:
; vTemTexto = 1;
       move.b    #1,-281(A6)
       bra       basInputGet_56
basInputGet_9:
; }
; else /* is expression */
; {
; // Verifica se comeca com letra, pois tem que ser uma variavel agora
; if (!isalphas(*token))
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basInputGet_15
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_15:
; }
; if (strlen(token) < 3)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basInputGet_17
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       move.b    #35,-6(A6)
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basInputGet_19
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basInputGet_19
; varTipo = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-6(A6)
basInputGet_19:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne       basInputGet_21
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basInputGet_21
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
       bra.s     basInputGet_22
basInputGet_21:
; else
; *(varName + 1) = 0x00;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       clr.b     1(A0)
basInputGet_22:
; *(varName + 2) = varTipo;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    -6(A6),2(A0)
       bra       basInputGet_18
basInputGet_17:
; }
; else
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-504(A6)
; varTipo = *(varName + 2);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    2(A0),-6(A6)
basInputGet_18:
; }
; answer[0] = 0x00;
       clr.b     -492+0(A6)
; vbufInput[0] = 0x00;
       clr.b     -270+0(A6)
; if (pSize == 1)
       move.b    11(A6),D0
       cmp.b     #1,D0
       bne       basInputGet_23
; {
; // GET
; for (ix = 0; ix < 15000; ix++)
       clr.l     -512(A6)
basInputGet_25:
       move.l    -512(A6),D0
       cmp.l     #15000,D0
       bge.s     basInputGet_27
; {
; vtec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,-291(A6)
; if (vtec)
       tst.b     -291(A6)
       beq.s     basInputGet_28
; break;
       bra.s     basInputGet_27
basInputGet_28:
       addq.l    #1,-512(A6)
       bra       basInputGet_25
basInputGet_27:
; }
; //                vtec = inputLineBasic(1,'@');    // Qualquer coisa
; if (varTipo != '$' && vtec)
       move.b    -6(A6),D0
       cmp.b     #36,D0
       beq.s     basInputGet_32
       move.b    -291(A6),D0
       and.l     #255,D0
       beq.s     basInputGet_32
; {
; if (!isdigitus(vtec))
       move.b    -291(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isdigitus
       addq.w    #4,A7
       tst.l     D0
       bne.s     basInputGet_32
; vtec = 0;
       clr.b     -291(A6)
basInputGet_32:
; }
; answer[0] = vtec;
       move.b    -291(A6),-492+0(A6)
; answer[1] = 0x00;
       clr.b     -492+1(A6)
       bra       basInputGet_24
basInputGet_23:
; }
; else
; {
; // INPUT
; vtec = inputLineBasic(&vbufInput, 255,varTipo);
       move.b    -6(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       255
       pea       -270(A6)
       jsr       _inputLineBasic
       add.w     #12,A7
       move.b    D0,-291(A6)
; if (vbufInput[0] != 0x00 && (vtec == 0x0D || vtec == 0x0A))
       move.b    -270+0(A6),D0
       beq       basInputGet_39
       move.b    -291(A6),D0
       cmp.b     #13,D0
       beq.s     basInputGet_36
       move.b    -291(A6),D0
       cmp.b     #10,D0
       bne.s     basInputGet_39
basInputGet_36:
; {
; ix = 0;
       clr.l     -512(A6)
; while (*buffptr)
basInputGet_37:
       move.l    -14(A6),A0
       tst.b     (A0)
       beq.s     basInputGet_39
; {
; answer[ix++] = *buffptr++;
       move.l    -14(A6),A0
       addq.l    #1,-14(A6)
       move.l    -512(A6),D0
       addq.l    #1,-512(A6)
       lea       -492(A6),A1
       move.b    (A0),0(A1,D0.L)
; answer[ix] = 0x00;
       move.l    -512(A6),D0
       lea       -492(A6),A0
       clr.b     0(A0,D0.L)
       bra       basInputGet_37
basInputGet_39:
; }
; }
; printText("\r\n");
       move.l    A5,A0
       add.l     #@basic_98,A0
       move.l    A0,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
basInputGet_24:
; }
; if (varTipo!='$')
       move.b    -6(A6),D0
       cmp.b     #36,D0
       beq       basInputGet_40
; {
; if (varTipo=='#')  // verifica se eh numero inteiro ou real
       move.b    -6(A6),D0
       cmp.b     #35,D0
       bne.s     basInputGet_42
; {
; iVal=floatStringToFpp(answer);
       pea       -492(A6)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,-286(A6)
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -492(A6)
       jsr       _atoi
       addq.w    #4,A7
       move.l    D0,-286(A6)
basInputGet_43:
; }
; answer[0]=((int)(*iVal & 0xFF000000) >> 24);
       move.l    -286(A6),A0
       move.l    (A0),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.b    D0,-492+0(A6)
; answer[1]=((int)(*iVal & 0x00FF0000) >> 16);
       move.l    -286(A6),A0
       move.l    (A0),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.b    D0,-492+1(A6)
; answer[2]=((int)(*iVal & 0x0000FF00) >> 8);
       move.l    -286(A6),A0
       move.l    (A0),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.b    D0,-492+2(A6)
; answer[3]=(char)(*iVal & 0x000000FF);
       move.l    -286(A6),A0
       move.l    (A0),D0
       and.l     #255,D0
       move.b    D0,-492+3(A6)
basInputGet_40:
; }
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; if (*vTempPointer == 0x28)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       basInputGet_46
; {
; vRetFV = findVariable(varName);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-10(A6)
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basInputGet_48
       clr.l     D0
       bra       basInputGet_5
basInputGet_48:
; if (!vRetFV)
       tst.l     -10(A6)
       bne.s     basInputGet_50
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-10(A6)
; // Se nao existe variavel e inicio sentenca, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     -10(A6)
       bne.s     basInputGet_54
; createVariable(varName, answer, varTipo);
       move.b    -6(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -492(A6)
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _createVariable
       add.w     #12,A7
       bra.s     basInputGet_55
basInputGet_54:
; else // se ja existe, altera
; updateVariable((vRetFV + 3), answer, varTipo, 1);
       pea       1
       move.b    -6(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -492(A6)
       move.l    -10(A6),D1
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
       move.b    -6(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -492(A6)
       move.l    -10(A6),-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basInputGet_53:
; }
; vTemTexto=2;
       move.b    #2,-281(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basInputGet_56
       clr.l     D0
       bra       basInputGet_5
basInputGet_56:
; }
; last_delim = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-271(A6)
; if (vTemTexto==1 && *token==';')
       move.b    -281(A6),D0
       cmp.b     #1,D0
       bne.s     basInputGet_58
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       bne.s     basInputGet_58
       bra       basInputGet_64
basInputGet_58:
; /* do nothing */;
; else if (vTemTexto==1 && *token!=';')
       move.b    -281(A6),D0
       cmp.b     #1,D0
       bne.s     basInputGet_60
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq.s     basInputGet_60
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_60:
; }
; else if (vTemTexto!=1 && *token==';')
       move.b    -281(A6),D0
       cmp.b     #1,D0
       beq.s     basInputGet_62
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       bne.s     basInputGet_62
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basInputGet_5
basInputGet_62:
; }
; else if (*tok!=EOL && *tok!=FINISHED && *token!=':')
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq       basInputGet_64
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basInputGet_64
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       beq.s     basInputGet_64
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra.s     basInputGet_5
basInputGet_64:
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #59,D0
       beq       basInputGet_1
basInputGet_2:
; }
; } while (*token==';');
; return 0;
       clr.l     D0
basInputGet_5:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; char forFind(for_stack *i, unsigned char* endLastVar)
; {
       xdef      _forFind
_forFind:
       link      A6,#-20
; int ix;
; unsigned char sqtdtam[10];
; for_stack *j;
; j = forStack;
       move.l    A5,A0
       add.l     #_forStack,A0
       move.l    (A0),-4(A6)
; for(ix = 0; ix < *ftos; ix++)
       clr.l     -18(A6)
forFind_1:
       move.l    A5,A0
       add.l     #_ftos,A0
       move.l    (A0),A0
       move.l    -18(A6),D0
       cmp.l     (A0),D0
       bge       forFind_3
; {
; if (j[ix].nameVar[0] == endLastVar[1] && j[ix].nameVar[1] == endLastVar[2])
       move.l    -4(A6),A0
       move.l    -18(A6),D0
       muls      #20,D0
       move.l    12(A6),A1
       move.b    0(A0,D0.L),D1
       cmp.b     1(A1),D1
       bne       forFind_4
       move.l    -4(A6),A0
       move.l    -18(A6),D0
       muls      #20,D0
       add.l     D0,A0
       move.l    12(A6),A1
       move.b    1(A0),D0
       cmp.b     2(A1),D0
       bne.s     forFind_4
; {
; *i = j[ix];
       move.l    8(A6),A0
       move.l    -4(A6),D0
       move.l    -18(A6),D1
       muls      #20,D1
       add.l     D1,D0
       move.l    D0,A1
       moveq     #4,D0
       move.l    (A1)+,(A0)+
       dbra      D0,*-2
; return ix;
       move.l    -18(A6),D0
       bra.s     forFind_6
forFind_4:
; }
; else if (!j[ix].nameVar[0])
       move.l    -4(A6),A0
       move.l    -18(A6),D0
       muls      #20,D0
       tst.b     0(A0,D0.L)
       bne.s     forFind_7
; return -1;
       moveq     #-1,D0
       bra.s     forFind_6
forFind_7:
       addq.l    #1,-18(A6)
       bra       forFind_1
forFind_3:
; }
; return -1;
       moveq     #-1,D0
forFind_6:
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
       link      A6,#-64
; for_stack i, *j;
; int value=0;
       clr.l     -40(A6)
; long *endVarCont;
; long iStep = 1;
       move.l    #1,-32(A6)
; long iTarget = 0;
       clr.l     -28(A6)
; unsigned char* endLastVar;
; unsigned char sqtdtam[10];
; char vRetVar = -1;
       move.b    #-1,-9(A6)
; unsigned char *vTempPointer;
; char vResLog1 = 0, vResLog2 = 0;
       clr.b     -4(A6)
       clr.b     -3(A6)
; char vResLog3 = 0, vResLog4 = 0;
       clr.b     -2(A6)
       clr.b     -1(A6)
; basLet();
       jsr       _basLet
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basFor_1
       clr.l     D0
       bra       basFor_3
basFor_1:
; endLastVar = *atuVarAddr - 3;
       move.l    A5,A0
       add.l     #_atuVarAddr,A0
       move.l    (A0),A0
       move.l    (A0),D0
       subq.l    #3,D0
       move.l    D0,-24(A6)
; endVarCont = *atuVarAddr + 1;
       move.l    A5,A0
       add.l     #_atuVarAddr,A0
       move.l    (A0),A0
       move.l    (A0),D0
       addq.l    #1,D0
       move.l    D0,-36(A6)
; vRetVar = forFind(&i, endLastVar);
       move.l    -24(A6),-(A7)
       pea       -64(A6)
       jsr       _forFind
       addq.w    #8,A7
       move.b    D0,-9(A6)
; if (vRetVar < 0)
       move.b    -9(A6),D0
       cmp.b     #0,D0
       bge.s     basFor_4
; {
; i.nameVar[0]=endLastVar[1];
       move.l    -24(A6),A0
       lea       -64(A6),A1
       move.b    1(A0),(A1)
; i.nameVar[1]=endLastVar[2];
       move.l    -24(A6),A0
       lea       -64(A6),A1
       move.b    2(A0),1(A1)
; i.nameVar[2]=endLastVar[0];
       move.l    -24(A6),A0
       lea       -64(A6),A1
       move.b    (A0),2(A1)
basFor_4:
; }
; if (i.nameVar[2] == '#')
       lea       -64(A6),A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basFor_6
; i.step = fppReal(iStep);
       move.l    -32(A6),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       lea       -64(A6),A0
       move.l    D0,12(A0)
       bra.s     basFor_7
basFor_6:
; else
; i.step = iStep;
       lea       -64(A6),A0
       move.l    -32(A6),12(A0)
basFor_7:
; i.endVar = endVarCont;
       lea       -64(A6),A0
       move.l    -36(A6),4(A0)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basFor_8
       clr.l     D0
       bra       basFor_3
basFor_8:
; if (*tok!=0x86) /* read and discard the TO */
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq.s     basFor_10
; {
; *vErroProc = 9;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #9,(A0)
; return 0;
       clr.l     D0
       bra       basFor_3
basFor_10:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; getExp(&iTarget); /* get target value */
       pea       -28(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (i.nameVar[2] == '#' && *value_type == '%')
       lea       -64(A6),A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basFor_12
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne.s     basFor_12
; i.target = fppReal(iTarget);
       move.l    -28(A6),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       lea       -64(A6),A0
       move.l    D0,8(A0)
       bra.s     basFor_13
basFor_12:
; else
; i.target = iTarget;
       lea       -64(A6),A0
       move.l    -28(A6),8(A0)
basFor_13:
; if (*tok==0x88) /* read STEP */
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #136,D0
       bne       basFor_17
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; getExp(&iStep); /* get target value */
       pea       -32(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (i.nameVar[2] == '#' && *value_type == '%')
       lea       -64(A6),A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basFor_16
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne.s     basFor_16
; i.step = fppReal(iStep);
       move.l    -32(A6),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       lea       -64(A6),A0
       move.l    D0,12(A0)
       bra.s     basFor_17
basFor_16:
; else
; i.step = iStep;
       lea       -64(A6),A0
       move.l    -32(A6),12(A0)
basFor_17:
; }
; endVarCont=i.endVar;
       lea       -64(A6),A0
       move.l    4(A0),-36(A6)
; // if loop can execute at least once, push info on stack     //    if ((i.step > 0 && *endVarCont <= i.target) || (i.step < 0 && *endVarCont >= i.target))
; if (i.nameVar[2] == '#')
       lea       -64(A6),A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne       basFor_18
; {
; vResLog1 = logicalNumericFloatLong(0xF6 /* <= */, *endVarCont, i.target);
       lea       -64(A6),A0
       move.l    8(A0),-(A7)
       move.l    -36(A6),A0
       move.l    (A0),-(A7)
       pea       246
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-4(A6)
; vResLog2 = logicalNumericFloatLong(0xF5 /* >= */, *endVarCont, i.target);
       lea       -64(A6),A0
       move.l    8(A0),-(A7)
       move.l    -36(A6),A0
       move.l    (A0),-(A7)
       pea       245
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-3(A6)
; vResLog3 = logicalNumericFloatLong('>', i.step, 0);
       clr.l     -(A7)
       lea       -64(A6),A0
       move.l    12(A0),-(A7)
       pea       62
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-2(A6)
; vResLog4 = logicalNumericFloatLong('<', i.step, 0);
       clr.l     -(A7)
       lea       -64(A6),A0
       move.l    12(A0),-(A7)
       pea       60
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-1(A6)
       bra       basFor_19
basFor_18:
; }
; else
; {
; vResLog1 = (*endVarCont <= i.target);
       move.l    -36(A6),A0
       lea       -64(A6),A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       bgt.s     basFor_20
       moveq     #1,D0
       bra.s     basFor_21
basFor_20:
       clr.l     D0
basFor_21:
       move.b    D0,-4(A6)
; vResLog2 = (*endVarCont >= i.target);
       move.l    -36(A6),A0
       lea       -64(A6),A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       blt.s     basFor_22
       moveq     #1,D0
       bra.s     basFor_23
basFor_22:
       clr.l     D0
basFor_23:
       move.b    D0,-3(A6)
; vResLog3 = (i.step > 0);
       lea       -64(A6),A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       ble.s     basFor_24
       moveq     #1,D0
       bra.s     basFor_25
basFor_24:
       clr.l     D0
basFor_25:
       move.b    D0,-2(A6)
; vResLog4 = (i.step < 0);
       lea       -64(A6),A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       bge.s     basFor_26
       moveq     #1,D0
       bra.s     basFor_27
basFor_26:
       clr.l     D0
basFor_27:
       move.b    D0,-1(A6)
basFor_19:
; }
; if (vResLog3 && vResLog1 || (vResLog4 && vResLog2))
       tst.b     -2(A6)
       beq.s     basFor_31
       tst.b     -4(A6)
       bne.s     basFor_30
basFor_31:
       tst.b     -1(A6)
       beq       basFor_28
       tst.b     -3(A6)
       beq       basFor_28
basFor_30:
; {
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
; if (*vTempPointer==0x3A) // ":"
       move.l    -8(A6),A0
       move.b    (A0),D0
       cmp.b     #58,D0
       bne.s     basFor_32
; {
; i.progPosPointerRet = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       lea       -64(A6),A1
       move.l    (A0),16(A1)
       bra.s     basFor_33
basFor_32:
; }
; else
; i.progPosPointerRet = *nextAddr;
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
       lea       -64(A6),A1
       move.l    (A0),16(A1)
basFor_33:
; if (vRetVar < 0)
       move.b    -9(A6),D0
       cmp.b     #0,D0
       bge.s     basFor_34
; forPush(i);
       lea       -64(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       jsr       _forPush
       add.w     #20,A7
       bra       basFor_35
basFor_34:
; else
; {
; j = (forStack + vRetVar);
       move.l    A5,A0
       add.l     #_forStack,A0
       move.l    (A0),D0
       move.b    -9(A6),D1
       ext.w     D1
       ext.l     D1
       muls      #20,D1
       ext.w     D1
       ext.l     D1
       add.l     D1,D0
       move.l    D0,-44(A6)
; j->target = i.target;
       lea       -64(A6),A0
       move.l    -44(A6),A1
       move.l    8(A0),8(A1)
; j->step = i.step;
       lea       -64(A6),A0
       move.l    -44(A6),A1
       move.l    12(A0),12(A1)
; j->endVar = i.endVar;
       lea       -64(A6),A0
       move.l    -44(A6),A1
       move.l    4(A0),4(A1)
; j->progPosPointerRet = i.progPosPointerRet;
       lea       -64(A6),A0
       move.l    -44(A6),A1
       move.l    16(A0),16(A1)
basFor_35:
       bra       basFor_38
basFor_28:
; }
; }
; else  /* otherwise, skip loop code alltogether */
; {
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
; while(*vTempPointer != 0x87) // Search NEXT
basFor_36:
       move.l    -8(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #135,D0
       beq       basFor_38
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
; // Verifica se chegou no next
; if (*vTempPointer == 0x87)
       move.l    -8(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #135,D0
       bne       basFor_45
; {
; // Verifica se tem letra, se nao tiver, usa ele
; if (*(vTempPointer + 1)!=0x00)
       move.l    -8(A6),A0
       move.b    1(A0),D0
       beq       basFor_45
; {
; // verifica se é a mesma variavel que ele tem
; if (*(vTempPointer + 1) != i.nameVar[0])
       move.l    -8(A6),A0
       lea       -64(A6),A1
       move.b    1(A0),D0
       cmp.b     (A1),D0
       beq.s     basFor_43
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
       bra       basFor_45
basFor_43:
; }
; else
; {
; if (*(vTempPointer + 2) != i.nameVar[1] && *(vTempPointer + 2) != i.nameVar[2])
       move.l    -8(A6),A0
       lea       -64(A6),A1
       move.b    2(A0),D0
       cmp.b     1(A1),D0
       beq.s     basFor_45
       move.l    -8(A6),A0
       lea       -64(A6),A1
       move.b    2(A0),D0
       cmp.b     2(A1),D0
       beq.s     basFor_45
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
basFor_45:
       bra       basFor_36
basFor_38:
; }
; }
; }
; }
; }
; }
; return 0;
       clr.l     D0
basFor_3:
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
       link      A6,#-48
; unsigned char sqtdtam[10];
; for_stack i;
; int *endVarCont;
; unsigned char answer[3];
; char vRetVar = -1;
       move.b    #-1,-9(A6)
; unsigned char *vTempPointer;
; char vResLog1 = 0, vResLog2 = 0;
       clr.b     -4(A6)
       clr.b     -3(A6)
; char vResLog3 = 0, vResLog4 = 0;
       clr.b     -2(A6)
       clr.b     -1(A6)
; /*writeLongSerial("Aqui 777.666.0-[");
; itoa(*pointerRunProg,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]-[");
; itoa(*pointerRunProg,sqtdtam,16);
; writeLongSerial(sqtdtam);
; writeLongSerial("]\r\n");*/
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-8(A6)
; if (isalphas(*vTempPointer))
       move.l    -8(A6),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basNext_3
       clr.l     D0
       bra       basNext_5
basNext_3:
; if (*token_type != VARIABLE)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basNext_6
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basNext_5
basNext_6:
; }
; answer[1] = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),-12+1(A6)
; if (strlen(token) == 1)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #1,D0
       bne.s     basNext_8
; {
; answer[0] = 0x00;
       clr.b     -12+0(A6)
; answer[2] = 0x00;
       clr.b     -12+2(A6)
       bra       basNext_11
basNext_8:
; }
; else if (strlen(token) == 2)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne       basNext_10
; {
; if (*(token + 1) < 0x30)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basNext_12
; {
; answer[0] = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-12+0(A6)
; answer[2] = 0x00;
       clr.b     -12+2(A6)
       bra.s     basNext_13
basNext_12:
; }
; else
; {
; answer[0] = 0x00;
       clr.b     -12+0(A6)
; answer[2] = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-12+2(A6)
basNext_13:
       bra.s     basNext_11
basNext_10:
; }
; }
; else
; {
; answer[0] = *(token + 2);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    2(A0),-12+0(A6)
; answer[2] = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-12+2(A6)
basNext_11:
; }
; vRetVar = forFind(&i,answer);
       pea       -12(A6)
       pea       -36(A6)
       jsr       _forFind
       addq.w    #8,A7
       move.b    D0,-9(A6)
; if (vRetVar < 0)
       move.b    -9(A6),D0
       cmp.b     #0,D0
       bge.s     basNext_14
; {
; *vErroProc = 11;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -36(A6)
       jsr       _forPop
       move.l    (A7)+,A0
       move.l    D0,A1
       moveq     #4,D0
       move.l    (A1)+,(A0)+
       dbra      D0,*-2
basNext_2:
; endVarCont = i.endVar;
       lea       -36(A6),A0
       move.l    4(A0),-16(A6)
; if (i.nameVar[2] == '#')
       lea       -36(A6),A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne.s     basNext_16
; {
; *endVarCont = fppSum(*endVarCont,i.step); // inc/dec, using step, control variable
       lea       -36(A6),A0
       move.l    12(A0),-(A7)
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppSum
       addq.w    #8,A7
       move.l    -16(A6),A0
       move.l    D0,(A0)
       bra.s     basNext_17
basNext_16:
; }
; else
; *endVarCont = *endVarCont + i.step; // inc/dec, using step, control variable
       move.l    -16(A6),A0
       lea       -36(A6),A1
       move.l    12(A1),D0
       add.l     D0,(A0)
basNext_17:
; if (i.nameVar[2] == '#')
       lea       -36(A6),A0
       move.b    2(A0),D0
       cmp.b     #35,D0
       bne       basNext_18
; {
; vResLog1 = logicalNumericFloatLong('>', *endVarCont, i.target);
       lea       -36(A6),A0
       move.l    8(A0),-(A7)
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       pea       62
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-4(A6)
; vResLog2 = logicalNumericFloatLong('<', *endVarCont, i.target);
       lea       -36(A6),A0
       move.l    8(A0),-(A7)
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       pea       60
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-3(A6)
; vResLog3 = logicalNumericFloatLong('>', i.step, 0);
       clr.l     -(A7)
       lea       -36(A6),A0
       move.l    12(A0),-(A7)
       pea       62
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-2(A6)
; vResLog4 = logicalNumericFloatLong('<', i.step, 0);
       clr.l     -(A7)
       lea       -36(A6),A0
       move.l    12(A0),-(A7)
       pea       60
       jsr       _logicalNumericFloatLong
       add.w     #12,A7
       move.b    D0,-1(A6)
       bra       basNext_19
basNext_18:
; }
; else
; {
; vResLog1 = (*endVarCont > i.target);
       move.l    -16(A6),A0
       lea       -36(A6),A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       ble.s     basNext_20
       moveq     #1,D0
       bra.s     basNext_21
basNext_20:
       clr.l     D0
basNext_21:
       move.b    D0,-4(A6)
; vResLog2 = (*endVarCont < i.target);
       move.l    -16(A6),A0
       lea       -36(A6),A1
       move.l    (A0),D0
       cmp.l     8(A1),D0
       bge.s     basNext_22
       moveq     #1,D0
       bra.s     basNext_23
basNext_22:
       clr.l     D0
basNext_23:
       move.b    D0,-3(A6)
; vResLog3 = (i.step > 0);
       lea       -36(A6),A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       ble.s     basNext_24
       moveq     #1,D0
       bra.s     basNext_25
basNext_24:
       clr.l     D0
basNext_25:
       move.b    D0,-2(A6)
; vResLog4 = (i.step < 0);
       lea       -36(A6),A0
       move.l    12(A0),D0
       cmp.l     #0,D0
       bge.s     basNext_26
       moveq     #1,D0
       bra.s     basNext_27
basNext_26:
       clr.l     D0
basNext_27:
       move.b    D0,-1(A6)
basNext_19:
; }
; // compara se ja chegou no final  //     if ((i.step > 0 && *endVarCont>i.target) || (i.step < 0 && *endVarCont<i.target))
; if ((vResLog3 && vResLog1) || (vResLog4 && vResLog2))
       tst.b     -2(A6)
       beq.s     basNext_31
       tst.b     -4(A6)
       bne.s     basNext_30
basNext_31:
       tst.b     -1(A6)
       beq.s     basNext_28
       tst.b     -3(A6)
       beq.s     basNext_28
basNext_30:
; return 0 ;  // all done
       clr.l     D0
       bra       basNext_5
basNext_28:
; *changedPointer = i.progPosPointerRet;  // loop
       lea       -36(A6),A0
       move.l    A5,A1
       add.l     #_changedPointer,A1
       move.l    (A1),A1
       move.l    16(A0),(A1)
; if (vRetVar < 0)
       move.b    -9(A6),D0
       cmp.b     #0,D0
       bge.s     basNext_32
; forPush(i);  // otherwise, restore the info
       lea       -36(A6),A0
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
       link      A6,#-24
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -20(A6)
; unsigned char *vTempPointer;
; unsigned int vSalto;
; unsigned int iSalto = 0;
       clr.l     -8(A6)
; unsigned int ix;
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-16(A6)
; if (isalphas(*vTempPointer))
       move.l    -16(A6),A0
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
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basOnVar_3
       clr.l     D0
       bra       basOnVar_5
basOnVar_3:
; if (*token_type != VARIABLE)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basOnVar_6
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_6:
; }
; putback();
       jsr       _putback
; getExp(&iSalto);
       pea       -8(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basOnVar_8
       clr.l     D0
       bra       basOnVar_5
basOnVar_8:
; if (*value_type != '%')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       beq.s     basOnVar_10
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_10:
; }
; if (iSalto == 0 || iSalto > 255)
       move.l    -8(A6),D0
       beq.s     basOnVar_14
       move.l    -8(A6),D0
       cmp.l     #255,D0
       bls.s     basOnVar_12
basOnVar_14:
; {
; *vErroProc = 5;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_2:
; }
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-16(A6)
; // Se nao for goto ou gosub, erro
; if (*vTempPointer != 0x89 && *vTempPointer != 0x8A)
       move.l    -16(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #137,D0
       beq.s     basOnVar_15
       move.l    -16(A6),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #138,D0
       beq.s     basOnVar_15
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_15:
; }
; vSalto = *vTempPointer;
       move.l    -16(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-12(A6)
; ix = 0;
       clr.l     -4(A6)
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; while (1)
basOnVar_17:
; {
; getExp(&vNumLin); // get target value
       pea       -20(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basOnVar_22
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basOnVar_20
basOnVar_22:
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_20:
; }
; ix++;
       addq.l    #1,-4(A6)
; if (ix == iSalto)
       move.l    -4(A6),D0
       cmp.l     -8(A6),D0
       bne.s     basOnVar_23
; break;
       bra       basOnVar_19
basOnVar_23:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basOnVar_25
       clr.l     D0
       bra       basOnVar_5
basOnVar_25:
; // Deve ser uma virgula
; if (*token!=',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basOnVar_27
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_27:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    -4(A6),D0
       beq.s     basOnVar_33
       move.l    -4(A6),D0
       cmp.l     -8(A6),D0
       bls.s     basOnVar_31
basOnVar_33:
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_31:
; }
; vNextAddrGoto = findNumberLine(vNumLin, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    -20(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _findNumberLine
       add.w     #12,A7
       move.l    D0,-24(A6)
; if (vSalto == 0x89)
       move.l    -12(A6),D0
       cmp.l     #137,D0
       bne       basOnVar_34
; {
; // GOTO
; if (vNextAddrGoto > 0)
       move.l    -24(A6),D0
       cmp.l     #0,D0
       bls       basOnVar_36
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    -24(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    -24(A6),A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -20(A6),D0
       bne.s     basOnVar_38
; {
; *changedPointer = vNextAddrGoto;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    -24(A6),(A0)
; return 0;
       clr.l     D0
       bra       basOnVar_5
basOnVar_38:
; }
; else
; {
; *vErroProc = 7;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    -24(A6),D0
       cmp.l     #0,D0
       bls       basOnVar_40
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    -24(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    -24(A6),A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -20(A6),D0
       bne.s     basOnVar_42
; {
; gosubPush(*nextAddr);
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
       move.l    (A0),-(A7)
       jsr       _gosubPush
       addq.w    #4,A7
; *changedPointer = vNextAddrGoto;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    -24(A6),(A0)
; return 0;
       clr.l     D0
       bra.s     basOnVar_5
basOnVar_42:
; }
; else
; {
; *vErroProc = 7;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basOnVar_5:
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
       link      A6,#-24
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -18(A6)
; unsigned char sqtdtam[10];
; unsigned char *vTempPointer;
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #14,(A0)
; return 0;
       clr.l     D0
       bra       basOnErr_3
basOnErr_1:
; }
; // soma mais um pra ir pro numero da linha
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; getExp(&vNumLin); // get target value
       pea       -18(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$' || *value_type == '#') {
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basOnErr_6
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basOnErr_4
basOnErr_6:
; *vErroProc = 17;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    D0,-22(A6)
; if (vNextAddrGoto > 0)
       move.l    -22(A6),D0
       cmp.l     #0,D0
       bls       basOnErr_7
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    -22(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    -22(A6),A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -18(A6),D0
       bne.s     basOnErr_9
; {
; *onErrGoto = vNextAddrGoto;
       move.l    A5,A0
       add.l     #_onErrGoto,A0
       move.l    (A0),A0
       move.l    -22(A6),(A0)
; return 0;
       clr.l     D0
       bra.s     basOnErr_3
basOnErr_9:
; }
; else
; {
; *vErroProc = 7;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basOnErr_3:
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
       link      A6,#-20
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -14(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basGoto_1
       clr.l     D0
       bra       basGoto_3
basGoto_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basGoto_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basGoto_4
basGoto_6:
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basGoto_9
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basGoto_7
basGoto_9:
; *vErroProc = 17;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    D0,-18(A6)
; if (vNextAddrGoto > 0)
       move.l    -18(A6),D0
       cmp.l     #0,D0
       bls       basGoto_10
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    -18(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    -18(A6),A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -14(A6),D0
       bne.s     basGoto_12
; {
; *changedPointer = vNextAddrGoto;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    -18(A6),(A0)
; return 0;
       clr.l     D0
       bra.s     basGoto_3
basGoto_12:
; }
; else
; {
; *vErroProc = 7;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basGoto_3:
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
       link      A6,#-8
; unsigned char* vNextAddrGoto;
; unsigned int vNumLin = 0;
       clr.l     -4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basGosub_1
       clr.l     D0
       bra       basGosub_3
basGosub_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basGosub_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basGosub_4
basGosub_6:
; {
; *vErroProc = 14;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basGosub_9
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basGosub_7
basGosub_9:
; *vErroProc = 17;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    D0,-8(A6)
; if (vNextAddrGoto > 0)
       move.l    -8(A6),D0
       cmp.l     #0,D0
       bls       basGosub_10
; {
; if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
       move.l    -8(A6),A0
       move.b    3(A0),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    -8(A6),A0
       move.b    4(A0),D1
       and.l     #255,D1
       or.l      D1,D0
       cmp.l     -4(A6),D0
       bne.s     basGosub_12
; {
; gosubPush(*nextAddr);
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
       move.l    (A0),-(A7)
       jsr       _gosubPush
       addq.w    #4,A7
; *changedPointer = vNextAddrGoto;
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
       move.l    -8(A6),(A0)
; return 0;
       clr.l     D0
       bra.s     basGosub_3
basGosub_12:
; }
; else
; {
; *vErroProc = 7;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #7,(A0)
; return 0;
       clr.l     D0
basGosub_3:
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
       move.l    A5,A0
       add.l     #_changedPointer,A0
       move.l    (A0),A0
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
       link      A6,#-8
; int vReal = 0, vResult = 0;
       clr.l     -8(A6)
       clr.l     -4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basInt_1
       clr.l     D0
       bra       basInt_3
basInt_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basInt_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basInt_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basInt_4
basInt_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basInt_3
basInt_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basInt_7
       clr.l     D0
       bra       basInt_3
basInt_7:
; putback();
       jsr       _putback
; getExp(&vReal); //
       pea       -8(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basInt_9
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basInt_3
basInt_9:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basInt_11
       clr.l     D0
       bra       basInt_3
basInt_11:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basInt_13
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basInt_3
basInt_13:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basInt_15
; vResult = fppInt(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,-4(A6)
       bra.s     basInt_16
basInt_15:
; else
; vResult = vReal;
       move.l    -8(A6),-4(A6)
basInt_16:
; *value_type='%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; *token=((int)(vResult & 0xFF000000) >> 24);
       move.l    -4(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
       move.l    -4(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
       move.l    -4(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(vResult & 0x000000FF);
       move.l    -4(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; return 0;
       clr.l     D0
basInt_3:
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
       link      A6,#-8
; int vReal = 0, vResult = 0;
       clr.l     -8(A6)
       clr.l     -4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basAbs_1
       clr.l     D0
       bra       basAbs_3
basAbs_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basAbs_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basAbs_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basAbs_4
basAbs_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAbs_3
basAbs_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basAbs_7
       clr.l     D0
       bra       basAbs_3
basAbs_7:
; putback();
       jsr       _putback
; getExp(&vReal); //
       pea       -8(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basAbs_9
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basAbs_3
basAbs_9:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basAbs_11
       clr.l     D0
       bra       basAbs_3
basAbs_11:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basAbs_13
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basAbs_3
basAbs_13:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basAbs_15
; vResult = fppAbs(vReal);
       move.l    -8(A6),-(A7)
       jsr       _fppAbs
       addq.w    #4,A7
       move.l    D0,-4(A6)
       bra.s     basAbs_17
basAbs_15:
; else
; {
; vResult = vReal;
       move.l    -8(A6),-4(A6)
; if (vResult < 1)
       move.l    -4(A6),D0
       cmp.l     #1,D0
       bge.s     basAbs_17
; vResult = vResult * (-1);
       move.l    -4(A6),-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),-4(A6)
       addq.w    #8,A7
basAbs_17:
; }
; *value_type='%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; *token=((int)(vResult & 0xFF000000) >> 24);
       move.l    -4(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
       move.l    -4(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
       move.l    -4(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(vResult & 0x000000FF);
       move.l    -4(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; return 0;
       clr.l     D0
basAbs_3:
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
       link      A6,#-52
; unsigned long vRand;
; int vReal = 0, vResult = 0;
       clr.l     -48(A6)
       clr.l     -44(A6)
; unsigned char vTRand[20];
; unsigned char vSRand[20];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basRnd_1
       clr.l     D0
       bra       basRnd_3
basRnd_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basRnd_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basRnd_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basRnd_4
basRnd_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basRnd_3
basRnd_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basRnd_9
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basRnd_3
basRnd_9:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basRnd_11
       clr.l     D0
       bra       basRnd_3
basRnd_11:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type != CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basRnd_13
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_randSeed,A0
       move.l    (A0),A0
       move.l    (A0),-52(A6)
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
; vRand = fsGetMfp(MFP_REG_TADR);
       pea       31
       move.l    8486760,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    D0,-52(A6)
; vRand = (vRand << 3);
       move.l    -52(A6),D0
       lsl.l     #3,D0
       move.l    D0,-52(A6)
; vRand += 0x466;
       add.l     #1126,-52(A6)
; vRand -= ((fsGetMfp(MFP_REG_TADR)) * 3);
       pea       31
       move.l    8486760,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    D0,-(A7)
       pea       3
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       sub.l     D0,-52(A6)
; *randSeed = vRand;
       move.l    A5,A0
       add.l     #_randSeed,A0
       move.l    (A0),A0
       move.l    -52(A6),(A0)
       bra       basRnd_20
basRnd_17:
; }
; else if (vReal > 0 && vReal <= 1)
       move.l    -48(A6),D0
       cmp.l     #0,D0
       ble       basRnd_19
       move.l    -48(A6),D0
       cmp.l     #1,D0
       bgt       basRnd_19
; {
; vRand = *randSeed;
       move.l    A5,A0
       add.l     #_randSeed,A0
       move.l    (A0),A0
       move.l    (A0),-52(A6)
; vRand = (vRand << 3);
       move.l    -52(A6),D0
       lsl.l     #3,D0
       move.l    D0,-52(A6)
; vRand += 0x466;
       add.l     #1126,-52(A6)
; vRand -= ((fsGetMfp(MFP_REG_TADR)) * 3);
       pea       31
       move.l    8486760,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    D0,-(A7)
       pea       3
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       sub.l     D0,-52(A6)
; *randSeed = vRand;
       move.l    A5,A0
       add.l     #_randSeed,A0
       move.l    (A0),A0
       move.l    -52(A6),(A0)
       bra.s     basRnd_20
basRnd_19:
; }
; else
; {
; *vErroProc = 5;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basRnd_3
basRnd_20:
; }
; itoa(vRand, vTRand, 10);
       pea       10
       pea       -40(A6)
       move.l    -52(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; vSRand[0] = '0';
       move.b    #48,-20+0(A6)
; vSRand[1] = '.';
       move.b    #46,-20+1(A6)
; vSRand[2] = 0x00;
       clr.b     -20+2(A6)
; strcat(vSRand, vTRand);
       pea       -40(A6)
       pea       -20(A6)
       jsr       _strcat
       addq.w    #8,A7
; vRand = floatStringToFpp(vSRand);
       pea       -20(A6)
       jsr       _floatStringToFpp
       addq.w    #4,A7
       move.l    D0,-52(A6)
; *value_type='#';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #35,(A0)
; *token=((int)(vRand & 0xFF000000) >> 24);
       move.l    -52(A6),D0
       and.l     #-16777216,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,(A0)
; *(token + 1)=((int)(vRand & 0x00FF0000) >> 16);
       move.l    -52(A6),D0
       and.l     #16711680,D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,1(A0)
; *(token + 2)=((int)(vRand & 0x0000FF00) >> 8);
       move.l    -52(A6),D0
       and.l     #65280,D0
       asr.l     #8,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,2(A0)
; *(token + 3)=(vRand & 0x000000FF);
       move.l    -52(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    D0,3(A0)
; return 0;
       clr.l     D0
basRnd_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Seta posicao screen 0
; // Syntaxe:
; //          LOCATE <Col>,<Row>,[Show Cursor = 1]
; //--------------------------------------------------------------------------------------
; int basLocate(void)
; {
       xdef      _basLocate
_basLocate:
       link      A6,#-36
; unsigned int vCol = 0, vRow = 0;
       clr.l     -34(A6)
       clr.l     -30(A6)
; unsigned char vShowCursor = 1;
       move.b    #1,-25(A6)
; unsigned char answer[20];
; char *iVal = answer;
       lea       -24(A6),A0
       move.l    A0,-4(A6)
; if (vdpModeBas != VDP_MODE_TEXT)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #3,D0
       beq.s     basLocate_1
; {
; *vErroProc = 24;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLocate_4
       clr.l     D0
       bra       basLocate_3
basLocate_4:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLocate_6
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_6:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -24(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLocate_8
       clr.l     D0
       bra       basLocate_3
basLocate_8:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLocate_10
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_10:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basLocate_12
; {
; *iVal = fppInt(*iVal);
       move.l    -4(A6),A0
       move.b    (A0),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -4(A6),A0
       move.b    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basLocate_12:
; }
; }
; vCol=(char)*iVal;
       move.l    -4(A6),A0
       move.b    (A0),D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-34(A6)
; if (*token != ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basLocate_14
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_14:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLocate_16
       clr.l     D0
       bra       basLocate_3
basLocate_16:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLocate_18
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_18:
; }
; else { /* is expression */
; //putback();
; getExp(&answer);
       pea       -24(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLocate_20
       clr.l     D0
       bra       basLocate_3
basLocate_20:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLocate_22
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_22:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basLocate_24
; {
; *iVal = fppInt(*iVal);
       move.l    -4(A6),A0
       move.b    (A0),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -4(A6),A0
       move.b    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basLocate_24:
; }
; }
; vRow=(char)*iVal;
       move.l    -4(A6),A0
       move.b    (A0),D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-30(A6)
; if (*token == ',')  // Optional show cursor
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne       basLocate_26
; {
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLocate_28
       clr.l     D0
       bra       basLocate_3
basLocate_28:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basLocate_30
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_30:
; }
; else { /* is expression */
; //putback();
; getExp(&answer);
       pea       -24(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basLocate_32
       clr.l     D0
       bra       basLocate_3
basLocate_32:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basLocate_34
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basLocate_3
basLocate_34:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basLocate_36
; {
; *iVal = fppInt(*iVal);
       move.l    -4(A6),A0
       move.b    (A0),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -4(A6),A0
       move.b    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basLocate_36:
; }
; }
; vShowCursor=(char)*iVal;
       move.l    -4(A6),A0
       move.b    (A0),-25(A6)
basLocate_26:
; }
; basVideoCursorShow = vShowCursor;
       move.l    A5,A0
       add.l     #_basVideoCursorShow,A0
       move.b    -25(A6),(A0)
; vdp_set_cursor(vCol, vRow);
       move.l    -30(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -34(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; return 0;
       clr.l     D0
basLocate_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Seta posicao horizontal (coluna em texto e x em grafico)
; // Syntaxe:
; //          HTAB <numero>
; //--------------------------------------------------------------------------------------
; int basHtab(void)
; {
       xdef      _basHtab
_basHtab:
       link      A6,#-4
; unsigned int vColumn = 0;
       clr.l     -4(A6)
; getExp(&vColumn);
       pea       -4(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*value_type == '$') {
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHtab_1
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHtab_3
basHtab_1:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHtab_4
; {
; vColumn = fppInt(vColumn);
       move.l    -4(A6),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    D0,-4(A6)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basHtab_4:
; }
; vdp_set_cursor(vColumn, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -4(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; return 0;
       clr.l     D0
basHtab_3:
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
       move.l    A5,A0
       add.l     #_nextAddr,A0
       move.l    (A0),A0
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
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       link      A6,#-60
; unsigned int vSpc = 0;
       clr.l     -60(A6)
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -56(A6)
       clr.l     -52(A6)
       clr.l     -48(A6)
       clr.l     -44(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -36(A6),A0
       move.l    A0,-16(A6)
; unsigned char vTab, vColumn;
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basSpc_1
       clr.l     D0
       bra       basSpc_3
basSpc_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basSpc_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basSpc_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basSpc_4
basSpc_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basSpc_3
basSpc_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basSpc_7
       clr.l     D0
       bra       basSpc_3
basSpc_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basSpc_9
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basSpc_11
       clr.l     D0
       bra       basSpc_3
basSpc_11:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basSpc_13
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basSpc_3
basSpc_13:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basSpc_15
; {
; *iVal = fppInt(*iVal);
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -16(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basSpc_15:
; }
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basSpc_17
       clr.l     D0
       bra       basSpc_3
basSpc_17:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basSpc_19
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basSpc_3
basSpc_19:
; }
; vSpc=(char)*iVal;
       move.l    -16(A6),A0
       move.l    (A0),-60(A6)
; for (ix = 0; ix < vSpc; ix++)
       clr.l     -56(A6)
basSpc_21:
       move.l    -56(A6),D0
       cmp.l     -60(A6),D0
       bhs.s     basSpc_23
; *(token + ix) = ' ';
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -56(A6),D0
       move.b    #32,0(A0,D0.L)
       addq.l    #1,-56(A6)
       bra       basSpc_21
basSpc_23:
; *(token + ix) = 0;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    -56(A6),D0
       clr.b     0(A0,D0.L)
; *value_type = '$';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basSpc_3:
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
       link      A6,#-56
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -56(A6)
       clr.l     -52(A6)
       clr.l     -48(A6)
       clr.l     -44(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -36(A6),A0
       move.l    A0,-16(A6)
; unsigned char vTab, vColumn;
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basTab_1
       clr.l     D0
       bra       basTab_3
basTab_1:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basTab_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basTab_6
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basTab_4
basTab_6:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basTab_3
basTab_4:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basTab_7
       clr.l     D0
       bra       basTab_3
basTab_7:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basTab_9
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basTab_11
       clr.l     D0
       bra       basTab_3
basTab_11:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basTab_13
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basTab_3
basTab_13:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basTab_15
; {
; *iVal = fppInt(*iVal);
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -16(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basTab_15:
; }
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basTab_17
       clr.l     D0
       bra       basTab_3
basTab_17:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basTab_19
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basTab_3
basTab_19:
; }
; vTab=(char)*iVal;
       move.l    -16(A6),A0
       move.l    (A0),D0
       move.b    D0,-12(A6)
; vColumn = videoCursorPosColX;
       move.l    A5,A0
       add.l     #_videoCursorPosColX,A0
       move.w    (A0),D0
       move.b    D0,-11(A6)
; if (vTab>vColumn)
       move.b    -12(A6),D0
       cmp.b     -11(A6),D0
       bls       basTab_21
; {
; vColumn = vColumn + vTab;
       move.b    -12(A6),D0
       add.b     D0,-11(A6)
; while (vColumn>vdpMaxCols)
basTab_23:
       move.l    A5,A0
       add.l     #_vdpMaxCols,A0
       move.b    -11(A6),D0
       cmp.b     (A0),D0
       bls       basTab_25
; {
; vColumn = vColumn - vdpMaxCols;
       move.l    A5,A0
       add.l     #_vdpMaxCols,A0
       move.b    (A0),D0
       sub.b     D0,-11(A6)
; if (videoCursorPosRowY < vdpMaxRows)
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.l    A5,A1
       add.l     #_vdpMaxRows,A1
       move.b    (A1),D0
       and.w     #255,D0
       cmp.w     (A0),D0
       bls.s     basTab_26
; videoCursorPosRowY += 1;
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       addq.w    #1,(A0)
basTab_26:
       bra       basTab_23
basTab_25:
; }
; vdp_set_cursor(vColumn, videoCursorPosRowY);
       move.l    A5,A0
       add.l     #_videoCursorPosRowY,A0
       move.w    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
basTab_21:
; }
; *token = ' ';
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    #32,(A0)
; *value_type='$';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #36,(A0)
; return 0;
       clr.l     D0
basTab_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Screen Mode Switch
; // Syntaxe:
; //          SCREEN [mode (0 to 3)],[sprite size (0 to 3)]
; //--------------------------------------------------------------------------------------
; int basScreen(void)
; {
       xdef      _basScreen
_basScreen:
       link      A6,#-56
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -56(A6)
       clr.l     -52(A6)
       clr.l     -48(A6)
       clr.l     -44(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -36(A6),A0
       move.l    A0,-16(A6)
; unsigned char vModeAux = 99;
       move.b    #99,-11(A6)
; unsigned char sqtdtam[10];
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScreen_1
       clr.l     D0
       bra       basScreen_3
basScreen_1:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basScreen_4
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_4:
; }
; else if (*token != ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq       basScreen_6
; { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScreen_8
       clr.l     D0
       bra       basScreen_3
basScreen_8:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basScreen_10
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_10:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basScreen_12
; {
; *iVal = fppInt(*iVal);
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -16(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basScreen_12:
; }
; vModeAux=(char)*iVal;
       move.l    -16(A6),A0
       move.l    (A0),D0
       move.b    D0,-11(A6)
; switch (vModeAux)
       move.b    -11(A6),D0
       and.l     #255,D0
       cmp.l     #4,D0
       bhs.s     basScreen_14
       asl.l     #1,D0
       move.w    basScreen_16(PC,D0.L),D0
       jmp       basScreen_16(PC,D0.W)
basScreen_16:
       dc.w      basScreen_17-basScreen_16
       dc.w      basScreen_18-basScreen_16
       dc.w      basScreen_19-basScreen_16
       dc.w      basScreen_20-basScreen_16
basScreen_17:
; {
; case 0:
; basText();
       jsr       _basText
; break;
       bra.s     basScreen_15
basScreen_18:
; case 1:
; basGr1();
       jsr       _basGr1
; break;
       bra.s     basScreen_15
basScreen_19:
; case 2:
; basHgr();
       jsr       _basHgr
; break;
       bra.s     basScreen_15
basScreen_20:
; case 3:
; basGr();
       jsr       _basGr
; break;
       bra.s     basScreen_15
basScreen_14:
; default:
; *vErroProc = 5;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #5,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_15:
       bra.s     basScreen_22
basScreen_6:
; }
; }
; else if (*token == ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       bne.s     basScreen_22
; nextToken();
       jsr       _nextToken
basScreen_22:
; if (vModeAux == 99 && *token != ',') // If not have first parameter, and not have ",", error
       move.b    -11(A6),D0
       cmp.b     #99,D0
       bne.s     basScreen_24
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basScreen_24
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_24:
; }
; if (vModeAux != 99)
       move.b    -11(A6),D0
       cmp.b     #99,D0
       beq.s     basScreen_26
; nextToken();
       jsr       _nextToken
basScreen_26:
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScreen_28
       clr.l     D0
       bra       basScreen_3
basScreen_28:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basScreen_30
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_30:
; }
; else { /* is expression */
; //putback();
; getExp(&answer);
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScreen_32
       clr.l     D0
       bra       basScreen_3
basScreen_32:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basScreen_34
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScreen_3
basScreen_34:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basScreen_36
; {
; *iVal = fppInt(*iVal);
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -16(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basScreen_36:
; }
; basVideoSpriteSize = (char)*iVal;
       move.l    -16(A6),A0
       move.l    (A0),D0
       move.l    A5,A0
       add.l     #_basVideoSpriteSize,A0
       move.b    D0,(A0)
; }
; return 0;
       clr.l     D0
basScreen_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Text Screen Mode (40 cols x 24 rows)
; // Syntaxe:
; //          Screen 0 - Text
; //--------------------------------------------------------------------------------------
; int basText(void)
; {
       xdef      _basText
_basText:
; fgcolorBas = VDP_WHITE;
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    #15,(A0)
; bgcolorBas = VDP_BLACK;
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.b    #1,(A0)
; vdp_init(VDP_MODE_TEXT, (fgcolorBas<<4) | (bgcolorBas & 0x0f), 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       lsl.b     #4,D1
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.l    D0,-(A7)
       move.b    (A0),D0
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
       move.l    A5,A0
       add.l     #_vdpMaxCols,A0
       move.b    #39,(A0)
; vdpMaxRows = 23;
       move.l    A5,A0
       add.l     #_vdpMaxRows,A0
       move.b    #23,(A0)
; vdpModeBas = VDP_MODE_TEXT;
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    #3,(A0)
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // Text Screen Mode (32 cols x 24 rows)
; // Syntaxe:
; //          Screen 1 - Low Res
; //--------------------------------------------------------------------------------------
; int basGr1(void)
; {
       xdef      _basGr1
_basGr1:
; fgcolorBas = VDP_WHITE;
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    #15,(A0)
; bgcolorBas = VDP_BLACK;
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.b    #1,(A0)
; vdp_init(VDP_MODE_G1, (fgcolorBas<<4) | (bgcolorBas & 0x0f), 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       lsl.b     #4,D1
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.l    D0,-(A7)
       move.b    (A0),D0
       and.b     #15,D0
       or.b      D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdpMaxCols = 32;
       move.l    A5,A0
       add.l     #_vdpMaxCols,A0
       move.b    #32,(A0)
; vdpMaxRows = 23;
       move.l    A5,A0
       add.l     #_vdpMaxRows,A0
       move.b    #23,(A0)
; vdpModeBas = VDP_MODE_G1;
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       clr.b     (A0)
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // High Resolution Screen Mode (256x192)
; // Syntaxe:
; //          Screen 2 - High Res
; //--------------------------------------------------------------------------------------
; int basHgr(void)
; {
       xdef      _basHgr
_basHgr:
; vdp_init(VDP_MODE_G2, 0x0, 1, 0);
       clr.l     -(A7)
       pea       1
       clr.l     -(A7)
       pea       1
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdpMaxCols = 255;
       move.l    A5,A0
       add.l     #_vdpMaxCols,A0
       move.b    #255,(A0)
; vdpMaxRows = 191;
       move.l    A5,A0
       add.l     #_vdpMaxRows,A0
       move.b    #191,(A0)
; vdpModeBas = VDP_MODE_G2;
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    #1,(A0)
; vdp_set_bdcolor(VDP_BLACK);
       pea       1
       move.l    1110,A0
       jsr       (A0)
       addq.w    #4,A7
; bgcolorBas = VDP_BLACK;
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.b    #1,(A0)
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // MultiColor Resolution Screen Mode (256x192 com 4 Blocos = 64x48)
; // Syntaxe:
; //          Screen 3 - MultiColor
; //--------------------------------------------------------------------------------------
; int basGr(void)
; {
       xdef      _basGr
_basGr:
; vdp_init(VDP_MODE_MULTICOLOR, 0, 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       pea       2
       move.l    1094,A0
       jsr       (A0)
       add.w     #16,A7
; vdpMaxCols = 63;
       move.l    A5,A0
       add.l     #_vdpMaxCols,A0
       move.b    #63,(A0)
; vdpMaxRows = 47;
       move.l    A5,A0
       add.l     #_vdpMaxRows,A0
       move.b    #47,(A0)
; vdpModeBas = VDP_MODE_MULTICOLOR;
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    #2,(A0)
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // Inverte as Cores de tela (COR FRENTE <> COR NORMAL)
; // Syntaxe:
; //          INVERSE
; //
; //    **********************************************************************************
; //    ** SOMENTE PARA COMPATIBILIDADE, NO TMS91xx E TMS99xx NAO FUNCIONA COR POR CHAR **
; //    **********************************************************************************
; //--------------------------------------------------------------------------------------
; int basInverse(void)
; {
       xdef      _basInverse
_basInverse:
; /*    unsigned char vTempCor;
; fgcolorBasAnt = fgcolorBas;
; bgcolorBasAnt = bgcolorBas;
; vTempCor = fgcolorBas;
; fgcolorBas = bgcolorBas;
; bgcolorBas = vTempCor;
; vdp_textcolor(fgcolorBas,bgcolorBas);*/
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // Volta as cores de tela as cores iniciais
; // Syntaxe:
; //          NORMAL
; //
; //    **********************************************************************************
; //    ** SOMENTE PARA COMPATIBILIDADE, NO TMS91xx E TMS99xx NAO FUNCIONA COR POR CHAR **
; //    **********************************************************************************
; //--------------------------------------------------------------------------------------
; int basNormal(void)
; {
       xdef      _basNormal
_basNormal:
; /*    fgcolorBas = fgcolorBasAnt;
; bgcolorBas = bgcolorBasAnt;
; vdp_textcolor(fgcolorBas,bgcolorBas);*/
; return 0;
       clr.l     D0
       rts
; }
; //--------------------------------------------------------------------------------------
; // Muda a cor do plot em baixa/alta resolucao (GR or HGR from basHcolor)
; // Syntaxe:
; //          COLOR=<color>
; //--------------------------------------------------------------------------------------
; int basColor(void)
; {
       xdef      _basColor
_basColor:
       link      A6,#-60
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -60(A6)
       clr.l     -56(A6)
       clr.l     -52(A6)
       clr.l     -48(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -40(A6),A0
       move.l    A0,-20(A6)
; unsigned char vTab, vColumn;
; unsigned char sqtdtam[10];
; unsigned char *vTempPointer;
; if (vdpModeBas != VDP_MODE_MULTICOLOR && vdpModeBas != VDP_MODE_G2)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basColor_1
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #1,D0
       beq.s     basColor_1
; {
; *vErroProc = 24;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_1:
; }
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; if (*vTempPointer != '=')
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #61,D0
       beq.s     basColor_4
; {
; *vErroProc = 3;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #3,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_4:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basColor_6
       clr.l     D0
       bra       basColor_3
basColor_6:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basColor_8
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_8:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -40(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basColor_10
       clr.l     D0
       bra       basColor_3
basColor_10:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basColor_12
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basColor_3
basColor_12:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basColor_14
; {
; *iVal = fppInt(*iVal);
       move.l    -20(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -20(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basColor_14:
; }
; }
; fgcolorBas=(char)*iVal;
       move.l    -20(A6),A0
       move.l    (A0),D0
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    D0,(A0)
; *value_type='%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basColor_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; // Coloca um dot ou preenche uma area com a color previamente definida
; // Syntaxe:
; //          PLOT <x entre 0 e 63>, <y entre 0 e 47>
; //--------------------------------------------------------------------------------------
; int basPlot(void)
; {
       xdef      _basPlot
_basPlot:
       link      A6,#-56
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -56(A6)
       clr.l     -52(A6)
       clr.l     -48(A6)
       clr.l     -44(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -36(A6),A0
       move.l    A0,-16(A6)
; unsigned char vx, vy;
; unsigned char sqtdtam[10];
; if (vdpModeBas != VDP_MODE_MULTICOLOR)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basPlot_1
; {
; *vErroProc = 24;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPlot_4
       clr.l     D0
       bra       basPlot_3
basPlot_4:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPlot_6
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPlot_8
       clr.l     D0
       bra       basPlot_3
basPlot_8:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPlot_10
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_10:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basPlot_12
; {
; *iVal = fppInt(*iVal);
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -16(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basPlot_12:
; }
; }
; vx=(char)*iVal;
       move.l    -16(A6),A0
       move.l    (A0),D0
       move.b    D0,-12(A6)
; if (*token != ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basPlot_14
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_14:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPlot_16
       clr.l     D0
       bra       basPlot_3
basPlot_16:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basPlot_18
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_18:
; }
; else { /* is expression */
; //putback();
; getExp(&answer);
       pea       -36(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basPlot_20
       clr.l     D0
       bra       basPlot_3
basPlot_20:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basPlot_22
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basPlot_3
basPlot_22:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basPlot_24
; {
; *iVal = fppInt(*iVal);
       move.l    -16(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -16(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basPlot_24:
; }
; }
; vy=(char)*iVal;
       move.l    -16(A6),A0
       move.l    (A0),D0
       move.b    D0,-11(A6)
; vdp_plot_color(vx, vy, fgcolorBas);
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
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
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basPlot_3:
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
       link      A6,#-60
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -58(A6)
       clr.l     -54(A6)
       clr.l     -50(A6)
       clr.l     -46(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -38(A6),A0
       move.l    A0,-18(A6)
; unsigned char vx1, vx2, vy;
; unsigned char sqtdtam[10];
; if (vdpModeBas != VDP_MODE_MULTICOLOR)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basHVlin_1
; {
; *vErroProc = 24;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHVlin_4
       clr.l     D0
       bra       basHVlin_3
basHVlin_4:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHVlin_6
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -38(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHVlin_8
       clr.l     D0
       bra       basHVlin_3
basHVlin_8:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHVlin_10
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_10:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHVlin_12
; {
; *iVal = fppInt(*iVal);
       move.l    -18(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -18(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basHVlin_12:
; }
; }
; vx1=(char)*iVal;
       move.l    -18(A6),A0
       move.l    (A0),D0
       move.b    D0,-13(A6)
; if (*token != ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basHVlin_14
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_14:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHVlin_16
       clr.l     D0
       bra       basHVlin_3
basHVlin_16:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHVlin_18
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_18:
; }
; else { /* is expression */
; //putback();
; getExp(&answer);
       pea       -38(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHVlin_20
       clr.l     D0
       bra       basHVlin_3
basHVlin_20:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHVlin_22
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_22:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHVlin_24
; {
; *iVal = fppInt(*iVal);
       move.l    -18(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -18(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basHVlin_24:
; }
; }
; vx2=(char)*iVal;
       move.l    -18(A6),A0
       move.l    (A0),D0
       move.b    D0,-12(A6)
; if (*token != 0xBA) // AT Token
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #186,D0
       beq.s     basHVlin_26
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_26:
; }
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHVlin_28
       clr.l     D0
       bra       basHVlin_3
basHVlin_28:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHVlin_30
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
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
       pea       -38(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHVlin_32
       clr.l     D0
       bra       basHVlin_3
basHVlin_32:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHVlin_34
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHVlin_3
basHVlin_34:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHVlin_36
; {
; *iVal = fppInt(*iVal);
       move.l    -18(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -18(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basHVlin_36:
; }
; }
; vy=(char)*iVal;
       move.l    -18(A6),A0
       move.l    (A0),D0
       move.b    D0,-11(A6)
; if (vx2 < vx1)
       move.b    -12(A6),D0
       cmp.b     -13(A6),D0
       bhs.s     basHVlin_38
; {
; ix = vx1;
       move.b    -13(A6),D0
       and.l     #255,D0
       move.l    D0,-58(A6)
; vx1 = vx2;
       move.b    -12(A6),-13(A6)
; vx2 = ix;
       move.l    -58(A6),D0
       move.b    D0,-12(A6)
basHVlin_38:
; }
; if (vTipo == 1)   // HLIN
       move.b    11(A6),D0
       cmp.b     #1,D0
       bne       basHVlin_40
; {
; for(ix = vx1; ix <= vx2; ix++)
       move.b    -13(A6),D0
       and.l     #255,D0
       move.l    D0,-58(A6)
basHVlin_42:
       move.b    -12(A6),D0
       and.l     #255,D0
       cmp.l     -58(A6),D0
       blo       basHVlin_44
; vdp_plot_color(ix, vy, fgcolorBas);
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -58(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1106,A0
       jsr       (A0)
       add.w     #12,A7
       addq.l    #1,-58(A6)
       bra       basHVlin_42
basHVlin_44:
       bra       basHVlin_47
basHVlin_40:
; }
; else   // VLIN
; {
; for(ix = vx1; ix <= vx2; ix++)
       move.b    -13(A6),D0
       and.l     #255,D0
       move.l    D0,-58(A6)
basHVlin_45:
       move.b    -12(A6),D0
       and.l     #255,D0
       cmp.l     -58(A6),D0
       blo       basHVlin_47
; vdp_plot_color(vy, ix, fgcolorBas);
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -58(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1106,A0
       jsr       (A0)
       add.w     #12,A7
       addq.l    #1,-58(A6)
       bra       basHVlin_45
basHVlin_47:
; }
; *value_type='%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basHVlin_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; // Syntaxe:
; //
; //--------------------------------------------------------------------------------------
; int basScrn(void)
; {
       xdef      _basScrn
_basScrn:
       link      A6,#-60
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -60(A6)
       clr.l     -56(A6)
       clr.l     -52(A6)
       clr.l     -48(A6)
; unsigned char answer[20];
; int *iVal = answer;
       lea       -40(A6),A0
       move.l    A0,-20(A6)
; int *tval = token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-16(A6)
; unsigned char vx, vy;
; unsigned char sqtdtam[10];
; if (vdpModeBas != VDP_MODE_MULTICOLOR)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     basScrn_1
; {
; *vErroProc = 24;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_1:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScrn_4
       clr.l     D0
       bra       basScrn_3
basScrn_4:
; // Erro, primeiro caracter deve ser abre parenteses
; if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basScrn_8
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basScrn_8
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #8,D0
       beq.s     basScrn_6
basScrn_8:
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_6:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScrn_9
       clr.l     D0
       bra       basScrn_3
basScrn_9:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basScrn_11
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_11:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -40(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScrn_13
       clr.l     D0
       bra       basScrn_3
basScrn_13:
; if (*value_type != '%')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       beq.s     basScrn_15
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_15:
; }
; }
; vx=(char)*iVal;
       move.l    -20(A6),A0
       move.l    (A0),D0
       move.b    D0,-12(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScrn_17
       clr.l     D0
       bra       basScrn_3
basScrn_17:
; if (*token!=',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basScrn_19
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_19:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScrn_21
       clr.l     D0
       bra       basScrn_3
basScrn_21:
; if (*token_type == QUOTE) { /* is string, error */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basScrn_23
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_23:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -40(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScrn_25
       clr.l     D0
       bra       basScrn_3
basScrn_25:
; if (*value_type != '%')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       beq.s     basScrn_27
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_27:
; }
; }
; vy=(char)*iVal;
       move.l    -20(A6),A0
       move.l    (A0),D0
       move.b    D0,-11(A6)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basScrn_29
       clr.l     D0
       bra       basScrn_3
basScrn_29:
; // Ultimo caracter deve ser fecha parenteses
; if (*token_type!=CLOSEPARENT)
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #9,D0
       beq.s     basScrn_31
; {
; *vErroProc = 15;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #15,(A0)
; return 0;
       clr.l     D0
       bra       basScrn_3
basScrn_31:
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
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basScrn_3:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; // Syntaxe:
; //
; //--------------------------------------------------------------------------------------
; int basHcolor(void)
; {
       xdef      _basHcolor
_basHcolor:
; if (vdpModeBas != VDP_MODE_G2)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #1,D0
       beq.s     basHcolor_1
; {
; *vErroProc = 24;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra.s     basHcolor_3
basHcolor_1:
; }
; basColor();
       jsr       _basColor
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHcolor_4
       clr.l     D0
       bra.s     basHcolor_3
basHcolor_4:
; return 0;
       clr.l     D0
basHcolor_3:
       rts
; }
; //--------------------------------------------------------------------------------------
; //
; // Syntaxe:
; //
; //--------------------------------------------------------------------------------------
; int basHplot(void)
; {
       xdef      _basHplot
_basHplot:
       link      A6,#-112
; int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
       clr.l     -112(A6)
       clr.l     -108(A6)
       clr.l     -104(A6)
       clr.l     -100(A6)
; unsigned char answer[20];
; int  *iVal = answer;
       lea       -92(A6),A0
       move.l    A0,-72(A6)
; int rivx, rivy;
; unsigned long riy, rlvx, rlvy, vDiag;
; unsigned char vx, vy, vtemp;
; unsigned char sqtdtam[10];
; unsigned char vOper = 0;
       clr.b     -29(A6)
; int x,y,addx,addy,dx,dy;
; long P;
; if (vdpModeBas != VDP_MODE_G2)
       move.l    A5,A0
       add.l     #_vdpModeBas,A0
       move.b    (A0),D0
       cmp.b     #1,D0
       beq.s     basHplot_1
; {
; *vErroProc = 24;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #24,(A0)
; return 0;
       clr.l     D0
       bra       basHplot_3
basHplot_1:
; }
; do
; {
basHplot_4:
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHplot_6
       clr.l     D0
       bra       basHplot_3
basHplot_6:
; if (*token != 0x86)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq       basHplot_8
; {
; if (*token_type == QUOTE) { // is string, error
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHplot_10
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHplot_3
basHplot_10:
; }
; else { // is expression
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -92(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHplot_12
       clr.l     D0
       bra       basHplot_3
basHplot_12:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHplot_14
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHplot_3
basHplot_14:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHplot_16
; {
; *iVal = fppInt(*iVal);
       move.l    -72(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -72(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basHplot_16:
; }
; }
; vx = (unsigned char)*iVal;
       move.l    -72(A6),A0
       move.l    (A0),D0
       move.b    D0,-43(A6)
; if (*token != ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq.s     basHplot_18
; {
; *vErroProc = 18;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #18,(A0)
; return 0;
       clr.l     D0
       bra       basHplot_3
basHplot_18:
; }
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHplot_20
       clr.l     D0
       bra       basHplot_3
basHplot_20:
; if (*token_type == QUOTE) { // is string, error
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basHplot_22
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHplot_3
basHplot_22:
; }
; else { // is expression
; //putback();
; getExp(&answer);
       pea       -92(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basHplot_24
       clr.l     D0
       bra       basHplot_3
basHplot_24:
; if (*value_type == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       bne.s     basHplot_26
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basHplot_3
basHplot_26:
; }
; if (*value_type == '#')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #35,D0
       bne.s     basHplot_28
; {
; *iVal = fppInt(*iVal);
       move.l    -72(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -72(A6),A0
       move.l    D0,(A0)
; *value_type = '%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
basHplot_28:
; }
; }
; vy = (unsigned char)*iVal;
       move.l    -72(A6),A0
       move.l    (A0),D0
       move.b    D0,-42(A6)
; if (!vOper)
       tst.b     -29(A6)
       bne.s     basHplot_30
; vOper = 1;
       move.b    #1,-29(A6)
basHplot_30:
       bra       basHplot_9
basHplot_8:
; }
; else
; {
; // *pointerRunProg = *pointerRunProg + 1;
; }
basHplot_9:
; if (*tok == EOL || *tok == FINISHED || *token == 0x86)    // Fim de linha, programa ou token
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basHplot_34
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       beq.s     basHplot_34
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       bne       basHplot_65
basHplot_34:
; {
; if (!vOper)
       tst.b     -29(A6)
       bne.s     basHplot_35
; {
; vOper = 2;
       move.b    #2,-29(A6)
       bra       basHplot_41
basHplot_35:
; }
; else if (vOper == 1)
       move.b    -29(A6),D0
       cmp.b     #1,D0
       bne       basHplot_37
; {
; *lastHgrX = vx;
       move.l    A5,A0
       add.l     #_lastHgrX,A0
       move.l    (A0),A0
       move.b    -43(A6),(A0)
; *lastHgrY = vy;
       move.l    A5,A0
       add.l     #_lastHgrY,A0
       move.l    (A0),A0
       move.b    -42(A6),(A0)
; if (*token != 0x86)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq       basHplot_39
; vdp_plot_hires(vx, vy, fgcolorBas, bgcolorBas);
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -42(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -43(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
basHplot_39:
       bra       basHplot_41
basHplot_37:
; }
; else if (vOper == 2)
       move.b    -29(A6),D0
       cmp.b     #2,D0
       bne       basHplot_41
; {
; if (vx == *lastHgrX && vy == *lastHgrY)
       move.l    A5,A0
       add.l     #_lastHgrX,A0
       move.l    (A0),A0
       move.b    -43(A6),D0
       cmp.b     (A0),D0
       bne       basHplot_43
       move.l    A5,A0
       add.l     #_lastHgrY,A0
       move.l    (A0),A0
       move.b    -42(A6),D0
       cmp.b     (A0),D0
       bne       basHplot_43
; vdp_plot_hires(vx, vy, fgcolorBas, bgcolorBas);
       move.l    A5,A0
       add.l     #_bgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -42(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -43(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
       bra       basHplot_62
basHplot_43:
; else
; {
; dx = (vx - *lastHgrX);
       move.b    -43(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_lastHgrX,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       sub.l     D1,D0
       move.l    D0,-12(A6)
; dy = (vy - *lastHgrY);
       move.b    -42(A6),D0
       and.l     #255,D0
       move.l    A5,A0
       add.l     #_lastHgrY,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       sub.l     D1,D0
       move.l    D0,-8(A6)
; if (dx < 0)
       move.l    -12(A6),D0
       cmp.l     #0,D0
       bge.s     basHplot_45
; dx = dx * (-1);
       move.l    -12(A6),-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),-12(A6)
       addq.w    #8,A7
basHplot_45:
; if (dy < 0)
       move.l    -8(A6),D0
       cmp.l     #0,D0
       bge.s     basHplot_47
; dy = dy * (-1);
       move.l    -8(A6),-(A7)
       pea       -1
       jsr       LMUL
       move.l    (A7),-8(A6)
       addq.w    #8,A7
basHplot_47:
; x = *lastHgrX;
       move.l    A5,A0
       add.l     #_lastHgrX,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-28(A6)
; y = *lastHgrY;
       move.l    A5,A0
       add.l     #_lastHgrY,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.l     #255,D0
       move.l    D0,-24(A6)
; if(*lastHgrX > vx)
       move.l    A5,A0
       add.l     #_lastHgrX,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     -43(A6),D0
       bls.s     basHplot_49
; addx = -1;
       move.l    #-1,-20(A6)
       bra.s     basHplot_50
basHplot_49:
; else
; addx = 1;
       move.l    #1,-20(A6)
basHplot_50:
; if(*lastHgrY > vy)
       move.l    A5,A0
       add.l     #_lastHgrY,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     -42(A6),D0
       bls.s     basHplot_51
; addy = -1;
       move.l    #-1,-16(A6)
       bra.s     basHplot_52
basHplot_51:
; else
; addy = 1;
       move.l    #1,-16(A6)
basHplot_52:
; if(dx >= dy)
       move.l    -12(A6),D0
       cmp.l     -8(A6),D0
       blt       basHplot_53
; {
; P = (2 * dy) - dx;
       move.l    -8(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       sub.l     -12(A6),D0
       move.l    D0,-4(A6)
; for(ix = 1; ix <= (dx + 1); ix++)
       move.l    #1,-112(A6)
basHplot_55:
       move.l    -12(A6),D0
       addq.l    #1,D0
       cmp.l     -112(A6),D0
       blt       basHplot_57
; {
; vdp_plot_hires(x, y, fgcolorBas, 0);
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -24(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -28(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; if (P < 0)
       move.l    -4(A6),D0
       cmp.l     #0,D0
       bge.s     basHplot_58
; {
; P = P + (2 * dy);
       move.l    -8(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,-4(A6)
; x = (x + addx);
       move.l    -20(A6),D0
       add.l     D0,-28(A6)
       bra       basHplot_59
basHplot_58:
; }
; else
; {
; P = P + (2 * dy) - (2 * dx);
       move.l    -4(A6),D0
       move.l    -8(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    -12(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,-4(A6)
; x = x + addx;
       move.l    -20(A6),D0
       add.l     D0,-28(A6)
; y = y + addy;
       move.l    -16(A6),D0
       add.l     D0,-24(A6)
basHplot_59:
       addq.l    #1,-112(A6)
       bra       basHplot_55
basHplot_57:
       bra       basHplot_62
basHplot_53:
; }
; }
; }
; else
; {
; P = (2 * dx) - dy;
       move.l    -12(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       sub.l     -8(A6),D0
       move.l    D0,-4(A6)
; for(ix = 1; ix <= (dy +1); ix++)
       move.l    #1,-112(A6)
basHplot_60:
       move.l    -8(A6),D0
       addq.l    #1,D0
       cmp.l     -112(A6),D0
       blt       basHplot_62
; {
; vdp_plot_hires(x, y, fgcolorBas, 0);
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_fgcolorBas,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -24(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    -28(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1102,A0
       jsr       (A0)
       add.w     #16,A7
; if (P < 0)
       move.l    -4(A6),D0
       cmp.l     #0,D0
       bge.s     basHplot_63
; {
; P = P + (2 * dx);
       move.l    -12(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,-4(A6)
; y = y + addy;
       move.l    -16(A6),D0
       add.l     D0,-24(A6)
       bra       basHplot_64
basHplot_63:
; }
; else
; {
; P = P + (2 * dx) - (2 * dy);
       move.l    -4(A6),D0
       move.l    -12(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    -8(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       sub.l     D1,D0
       move.l    D0,-4(A6)
; x = x + addx;
       move.l    -20(A6),D0
       add.l     D0,-28(A6)
; y = y + addy;
       move.l    -16(A6),D0
       add.l     D0,-24(A6)
basHplot_64:
       addq.l    #1,-112(A6)
       bra       basHplot_60
basHplot_62:
; }
; }
; }
; }
; *lastHgrX = vx;
       move.l    A5,A0
       add.l     #_lastHgrX,A0
       move.l    (A0),A0
       move.b    -43(A6),(A0)
; *lastHgrY = vy;
       move.l    A5,A0
       add.l     #_lastHgrY,A0
       move.l    (A0),A0
       move.b    -42(A6),(A0)
basHplot_41:
; }
; if (*token == 0x86)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       bne.s     basHplot_65
; {
; *pointerRunProg = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       addq.l    #1,(A0)
basHplot_65:
; }
; }
; vOper = 2;
       move.b    #2,-29(A6)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #134,D0
       beq       basHplot_4
; } while (*token == 0x86); // TO Token
; *value_type='%';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #37,(A0)
; return 0;
       clr.l     D0
basHplot_3:
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
       link      A6,#-144
; int ix = 0, iy = 0, iz = 0;
       clr.l     -144(A6)
       clr.l     -140(A6)
       clr.l     -136(A6)
; unsigned char answer[100];
; int  *iVal = answer;
       lea       -132(A6),A0
       move.l    A0,-32(A6)
; unsigned char varTipo, vArray = 0;
       clr.b     -27(A6)
; unsigned char sqtdtam[10];
; unsigned long vTemp;
; unsigned char *vTempLine;
; long vRetFV;
; unsigned char *vTempPointer;
; // Pega a variavel
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basRead_1
       clr.l     D0
       bra       basRead_3
basRead_1:
; if (*tok == EOL || *tok == FINISHED)
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #226,D0
       beq.s     basRead_6
       move.l    A5,A0
       add.l     #_tok,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #224,D0
       bne.s     basRead_4
basRead_6:
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_4:
; }
; if (*token_type == QUOTE) { /* is string */
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basRead_7
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_7:
; }
; else { /* is expression */
; // Verifica se comeca com letra, pois tem que ser uma variavel
; if (!isalphas(*token))
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       bne.s     basRead_9
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_9:
; }
; if (strlen(token) < 3)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #3,D0
       bge       basRead_11
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; varTipo = VARTYPEDEFAULT;
       move.b    #35,-28(A6)
; if (strlen(token) == 2 && *(token + 1) < 0x30)
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne.s     basRead_13
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D0
       cmp.b     #48,D0
       bhs.s     basRead_13
; varTipo = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),-28(A6)
basRead_13:
; if (strlen(token) == 2 && isalphas(*(token + 1)))
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     #2,D0
       bne       basRead_15
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _isalphas
       addq.w    #4,A7
       tst.l     D0
       beq.s     basRead_15
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
       bra.s     basRead_16
basRead_15:
; else
; *(varName + 1) = 0x00;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       clr.b     1(A0)
basRead_16:
; *(varName + 2) = varTipo;
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    -28(A6),2(A0)
       bra       basRead_12
basRead_11:
; }
; else
; {
; *varName = *token;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *(varName + 1) = *(token + 1);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    1(A0),1(A1)
; *(varName + 2) = *(token + 2);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_varName,A1
       move.l    (A1),A1
       move.b    2(A0),2(A1)
; iz = strlen(token) - 1;
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       subq.l    #1,D0
       move.l    D0,-136(A6)
; varTipo = *(varName + 2);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),A0
       move.b    2(A0),-28(A6)
basRead_12:
; }
; }
; // Procurar Data
; if (*vDataPointer == 0)
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    (A0),D0
       bne       basRead_20
; {
; // Primeira Leitura, procura primeira ocorrencia
; *vDataLineAtu = *addrFirstLineNumber;
       move.l    A5,A0
       add.l     #_addrFirstLineNumber,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vDataLineAtu,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; do
; {
basRead_19:
; *vDataPointer = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vDataPointer,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; vTempLine = *vDataPointer;
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    (A0),-12(A6)
; if (*(vTempLine + 5) == 0x98)    // Token do comando DATA é o primeiro comando da linha
       move.l    -12(A6),A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #152,D0
       bne       basRead_21
; {
; *vDataPointer = (*vDataLineAtu + 6);
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),D0
       addq.l    #6,D0
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    D0,(A0)
; *vDataFirst = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vDataFirst,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; break;
       bra       basRead_20
basRead_21:
; }
; vTempLine = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),-12(A6)
; vTemp  = ((*vTempLine & 0xFF) << 16);
       move.l    -12(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,-16(A6)
; vTemp |= ((*(vTempLine + 1) & 0xFF) << 8);
       move.l    -12(A6),A0
       move.b    1(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       or.l      D0,-16(A6)
; vTemp |= (*(vTempLine + 2) & 0xFF);
       move.l    -12(A6),A0
       move.b    2(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,-16(A6)
; *vDataLineAtu = vTemp;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    -16(A6),(A0)
; vTempLine = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),-12(A6)
       move.l    -12(A6),A0
       tst.b     (A0)
       bne       basRead_19
basRead_20:
; } while (*vTempLine);
; }
; if (*vDataPointer == 0xFFFFFFFF)
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    (A0),D0
       cmp.l     #-1,D0
       bne.s     basRead_23
; {
; *vErroProc = 26;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #26,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_23:
; }
; *vDataBkpPointerProg = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vDataBkpPointerProg,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *pointerRunProg = *vDataPointer;
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_pointerRunProg,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; nextToken();
       jsr       _nextToken
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basRead_25
       clr.l     D0
       bra       basRead_3
basRead_25:
; if (*token_type == QUOTE) {
       move.l    A5,A0
       add.l     #_token_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #6,D0
       bne.s     basRead_27
; strcpy(answer,token);
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),-(A7)
       pea       -132(A6)
       jsr       _strcpy
       addq.w    #8,A7
; *value_type = '$';
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    #36,(A0)
       bra.s     basRead_29
basRead_27:
; }
; else { /* is expression */
; putback();
       jsr       _putback
; getExp(&answer);
       pea       -132(A6)
       jsr       _getExp
       addq.w    #4,A7
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basRead_29
       clr.l     D0
       bra       basRead_3
basRead_29:
; }
; // Pega ponteiro atual (proximo numero/char)
; *vDataPointer = *pointerRunProg + 1;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),D0
       addq.l    #1,D0
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    D0,(A0)
; // Devolve ponteiro anterior
; *pointerRunProg = *vDataBkpPointerProg;
       move.l    A5,A0
       add.l     #_vDataBkpPointerProg,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_pointerRunProg,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; // Se nao foi virgula, é final de linha, procura proximo comando data
; if (*token != ',')
       move.l    A5,A0
       add.l     #_token,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #44,D0
       beq       basRead_34
; {
; do
; {
basRead_33:
; vTempLine = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),-12(A6)
; vTemp  = ((*(vTempLine) & 0xFF) << 16);
       move.l    -12(A6),A0
       move.b    (A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,-16(A6)
; vTemp |= ((*(vTempLine + 1) & 0xFF) << 8);
       move.l    -12(A6),A0
       move.b    1(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       asl.l     #8,D0
       or.l      D0,-16(A6)
; vTemp |= (*(vTempLine + 2) & 0xFF);
       move.l    -12(A6),A0
       move.b    2(A0),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,-16(A6)
; *vDataLineAtu = vTemp;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    -16(A6),(A0)
; vTempLine = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),-12(A6)
; if (!*vDataLineAtu)
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       tst.l     (A0)
       bne.s     basRead_35
; {
; *vDataPointer = 0xFFFFFFFF;
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    #-1,(A0)
; break;
       bra       basRead_34
basRead_35:
; }
; *vDataPointer = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vDataPointer,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; vTempLine = *vDataPointer;
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    (A0),-12(A6)
; if (*(vTempLine + 5) == 0x98)    // Token do comando DATA é o primeiro comando da linha
       move.l    -12(A6),A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #152,D0
       bne.s     basRead_37
; {
; *vDataPointer = (*vDataLineAtu + 6);
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),D0
       addq.l    #6,D0
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    D0,(A0)
; break;
       bra.s     basRead_34
basRead_37:
; }
; vTempLine = *vDataLineAtu;
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),-12(A6)
       move.l    -12(A6),A0
       tst.b     (A0)
       bne       basRead_33
basRead_34:
; } while (*vTempLine);
; }
; if (varTipo != *value_type)
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    -28(A6),D0
       cmp.b     (A0),D0
       beq       basRead_39
; {
; if (*value_type == '$' || varTipo == '$')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #36,D0
       beq.s     basRead_43
       move.b    -28(A6),D0
       cmp.b     #36,D0
       bne.s     basRead_41
basRead_43:
; {
; *vErroProc = 16;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #16,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_41:
; }
; if (*value_type == '%')
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    (A0),D0
       cmp.b     #37,D0
       bne.s     basRead_44
; *iVal = fppReal(*iVal);
       move.l    -32(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppReal
       addq.w    #4,A7
       move.l    -32(A6),A0
       move.l    D0,(A0)
       bra.s     basRead_45
basRead_44:
; else
; *iVal = fppInt(*iVal);
       move.l    -32(A6),A0
       move.l    (A0),-(A7)
       jsr       _fppInt
       addq.w    #4,A7
       move.l    -32(A6),A0
       move.l    D0,(A0)
basRead_45:
; *value_type = varTipo;
       move.l    A5,A0
       add.l     #_value_type,A0
       move.l    (A0),A0
       move.b    -28(A6),(A0)
basRead_39:
; }
; vTempPointer = *pointerRunProg;
       move.l    A5,A0
       add.l     #_pointerRunProg,A0
       move.l    (A0),A0
       move.l    (A0),-4(A6)
; if (*vTempPointer == 0x28)
       move.l    -4(A6),A0
       move.b    (A0),D0
       cmp.b     #40,D0
       bne       basRead_46
; {
; vRetFV = findVariable(varName);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-8(A6)
; if (*vErroProc) return 0;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       tst.w     (A0)
       beq.s     basRead_48
       clr.l     D0
       bra       basRead_3
basRead_48:
; if (!vRetFV)
       tst.l     -8(A6)
       bne.s     basRead_50
; {
; *vErroProc = 4;
       move.l    A5,A0
       add.l     #_vErroProc,A0
       move.l    (A0),A0
       move.w    #4,(A0)
; return 0;
       clr.l     D0
       bra       basRead_3
basRead_50:
; }
; vArray = 1;
       move.b    #1,-27(A6)
basRead_46:
; }
; if (!vArray)
       tst.b     -27(A6)
       bne       basRead_52
; {
; // assign the value
; vRetFV = findVariable(varName);
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _findVariable
       addq.w    #4,A7
       move.l    D0,-8(A6)
; // Se nao existe variavel e inicio sentenca, cria variavel e atribui o valor
; if (!vRetFV)
       tst.l     -8(A6)
       bne.s     basRead_54
; createVariable(varName, answer, varTipo);
       move.b    -28(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -132(A6)
       move.l    A5,A0
       add.l     #_varName,A0
       move.l    (A0),-(A7)
       jsr       _createVariable
       add.w     #12,A7
       bra.s     basRead_55
basRead_54:
; else // se ja existe, altera
; updateVariable((vRetFV + 3), answer, varTipo, 1);
       pea       1
       move.b    -28(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -132(A6)
       move.l    -8(A6),D1
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
       move.b    -28(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       -132(A6)
       move.l    -8(A6),-(A7)
       jsr       _updateVariable
       add.w     #16,A7
basRead_53:
; }
; return 0;
       clr.l     D0
basRead_3:
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
       move.l    A5,A0
       add.l     #_vDataFirst,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vDataLineAtu,A1
       move.l    (A1),A1
       move.l    (A0),(A1)
; *vDataPointer = (*vDataLineAtu + 6);
       move.l    A5,A0
       add.l     #_vDataLineAtu,A0
       move.l    (A0),A0
       move.l    (A0),D0
       addq.l    #6,D0
       move.l    A5,A0
       add.l     #_vDataPointer,A0
       move.l    (A0),A0
       move.l    D0,(A0)
; return 0;
       clr.l     D0
       rts
; }
; //-----------------------------------------------------------------------------
; void clearScrW(unsigned char color)
; {
       xdef      _clearScrW
_clearScrW:
       link      A6,#-8
; unsigned int ix, iy;
; color &= 0x0F;
       and.b     #15,11(A6)
; setWriteAddress(mgui_pattern_table);
       move.l    A5,A0
       add.l     #_mgui_pattern_table,A0
       move.l    (A0),-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; for (iy = 0; iy < 192; iy++)
       clr.l     -4(A6)
clearScrW_1:
       move.l    -4(A6),D0
       cmp.l     #192,D0
       bhs.s     clearScrW_3
; {
; for (ix = 0; ix < 32; ix++)
       clr.l     -8(A6)
clearScrW_4:
       move.l    -8(A6),D0
       cmp.l     #32,D0
       bhs.s     clearScrW_6
; *vvdgd = 0x00;
       move.l    A5,A0
       add.l     #_vvdgd,A0
       move.l    (A0),A0
       clr.b     (A0)
       addq.l    #1,-8(A6)
       bra       clearScrW_4
clearScrW_6:
       addq.l    #1,-4(A6)
       bra       clearScrW_1
clearScrW_3:
; }
; setWriteAddress(mgui_color_table);
       move.l    A5,A0
       add.l     #_mgui_color_table,A0
       move.l    (A0),-(A7)
       move.l    1194,A0
       jsr       (A0)
       addq.w    #4,A7
; for (iy = 0; iy < 192; iy++)
       clr.l     -4(A6)
clearScrW_7:
       move.l    -4(A6),D0
       cmp.l     #192,D0
       bhs.s     clearScrW_9
; {
; for (ix = 0; ix < 32; ix++)
       clr.l     -8(A6)
clearScrW_10:
       move.l    -8(A6),D0
       cmp.l     #32,D0
       bhs.s     clearScrW_12
; *vvdgd = color;
       move.l    A5,A0
       add.l     #_vvdgd,A0
       move.l    (A0),A0
       move.b    11(A6),(A0)
       addq.l    #1,-8(A6)
       bra       clearScrW_10
clearScrW_12:
       addq.l    #1,-4(A6)
       bra       clearScrW_7
clearScrW_9:
       unlk      A6
       rts
; }
; }
; #endif
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
       dc.b      0
@basic_41:
       dc.b      68,73,77,0
@basic_42:
       dc.b      79,78,0
@basic_43:
       dc.b      73,78,80,85,84,0
@basic_44:
       dc.b      73,78,75,69,89,36,0
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
       dc.b      67,79,76,79,82,0
@basic_55:
       dc.b      80,83,69,84,0
@basic_56:
       dc.b      80,82,69,83,69,84,0
@basic_57:
       dc.b      65,84,0
@basic_58:
       dc.b      79,78,69,82,82,0
@basic_59:
       dc.b      65,83,67,0
@basic_60:
       dc.b      80,69,69,75,0
@basic_61:
       dc.b      80,79,75,69,0
@basic_62:
       dc.b      82,78,68,0
@basic_63:
       dc.b      76,69,78,0
@basic_64:
       dc.b      86,65,76,0
@basic_65:
       dc.b      83,84,82,36,0
@basic_66:
       dc.b      80,79,73,78,84,0
@basic_67:
       dc.b      67,72,82,36,0
@basic_68:
       dc.b      70,82,69,0
@basic_69:
       dc.b      83,81,82,0
@basic_70:
       dc.b      83,73,78,0
@basic_71:
       dc.b      67,79,83,0
@basic_72:
       dc.b      84,65,78,0
@basic_73:
       dc.b      76,79,71,0
@basic_74:
       dc.b      69,88,80,0
@basic_75:
       dc.b      83,80,67,0
@basic_76:
       dc.b      84,65,66,0
@basic_77:
       dc.b      77,73,68,36,0
@basic_78:
       dc.b      82,73,71,72,84,36,0
@basic_79:
       dc.b      76,69,70,84,36,0
@basic_80:
       dc.b      73,78,84,0
@basic_81:
       dc.b      65,66,83,0
@basic_82:
       dc.b      65,78,68,0
@basic_83:
       dc.b      79,82,0
@basic_84:
       dc.b      62,61,0
@basic_85:
       dc.b      60,61,0
@basic_86:
       dc.b      60,62,0
@basic_87:
       dc.b      78,79,84,0
@basic_88:
       dc.b      65,113,117,105,32,48,32,58,45,41,13,10,0
@basic_89:
       dc.b      65,113,117,105,32,49,32,58,45,41,13,10,0
@basic_90:
       dc.b      65,113,117,105,32,50,32,58,45,41,13,10,0
@basic_91:
       dc.b      65,113,117,105,32,51,32,58,45,41,13,10,0
@basic_92:
       dc.b      65,113,117,105,32,52,32,58,45,41,13,10,0
@basic_93:
       dc.b      77,77,83,74,45,120,66,65,83,73,67,32,118,48
       dc.b      46,49,13,10,0
@basic_94:
       dc.b      85,116,105,108,105,116,121,32,40,99,41,32,50
       dc.b      48,50,54,13,10,0
@basic_95:
       dc.b      79,75,13,10,0
@basic_96:
       dc.b      65,113,117,105,32,53,32,58,45,41,13,10,0
@basic_97:
       dc.b      65,113,117,105,32,54,32,58,45,41,13,10,0
@basic_98:
       dc.b      13,10,0
@basic_99:
       dc.b      13,10,79,75,0
@basic_100:
       dc.b      78,69,87,0
@basic_101:
       dc.b      69,68,73,84,0
@basic_102:
       dc.b      76,73,83,84,0
@basic_103:
       dc.b      76,73,83,84,80,0
@basic_104:
       dc.b      82,85,78,0
@basic_105:
       dc.b      68,69,76,69,84,69,0
@basic_106:
       dc.b      88,76,79,65,68,0
@basic_107:
       dc.b      84,73,77,69,82,0
@basic_108:
       dc.b      84,105,109,101,114,58,32,0
@basic_109:
       dc.b      109,115,13,10,0
@basic_110:
       dc.b      84,82,79,78,0
@basic_111:
       dc.b      84,82,79,70,70,0
@basic_112:
       dc.b      68,69,66,85,71,79,78,0
@basic_113:
       dc.b      68,69,66,85,71,79,70,70,0
@basic_114:
       dc.b      81,85,73,84,0
@basic_115:
       dc.b      32,0
@basic_116:
       dc.b      32,59,44,43,45,60,62,40,41,47,42,94,61,58,0
@basic_117:
       dc.b      76,105,110,101,32,110,117,109,98,101,114,32
       dc.b      97,108,114,101,97,100,121,32,101,120,105,115
       dc.b      116,115,13,10,0
@basic_118:
       dc.b      78,111,110,45,101,120,105,115,116,101,110,116
       dc.b      32,108,105,110,101,32,110,117,109,98,101,114
       dc.b      13,10,0
@basic_119:
       dc.b      112,114,101,115,115,32,97,110,121,32,107,101
       dc.b      121,32,116,111,32,99,111,110,116,105,110,117
       dc.b      101,0
@basic_120:
       dc.b      64,0
@basic_121:
       dc.b      83,121,110,116,97,120,32,69,114,114,111,114
       dc.b      32,33,0
@basic_122:
       dc.b      13,10,65,98,111,114,116,101,100,32,33,33,33
       dc.b      13,10,0
@basic_123:
       dc.b      13,10,83,116,111,112,112,101,100,32,97,116,32
       dc.b      0
@basic_124:
       dc.b      13,10,69,120,101,99,117,116,105,110,103,32,97
       dc.b      116,32,0
@basic_125:
       dc.b      32,97,116,32,0
@basic_126:
       dc.b      32,33,13,10,0
@basic_127:
       dc.b      43,45,42,94,47,61,59,58,44,62,60,0
@basic_128:
       dc.b      58,0
@basic_129:
       dc.b      76,111,97,100,105,110,103,32,66,97,115,105,99
       dc.b      32,80,114,111,103,114,97,109,46,46,46,13,10
       dc.b      0
@basic_130:
       dc.b      68,111,110,101,46,13,10,0
@basic_131:
       dc.b      80,114,111,99,101,115,115,105,110,103,46,46
       dc.b      46,13,10,0
@basic_132:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,48
       dc.b      45,91,0
@basic_133:
       dc.b      93,45,91,0
@basic_134:
       dc.b      93,13,10,0
@basic_135:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,49
       dc.b      45,91,0
@basic_136:
       dc.b      65,113,117,105,32,51,51,51,46,54,54,54,46,50
       dc.b      45,91,0
       xdef      _strValidChars
_strValidChars:
       dc.b      48,49,50,51,52,53,54,55,56,57,65,66,67,68,69
       dc.b      70,71,72,73,74,75,76,77,78,79,80,81,82,83,84
       dc.b      85,86,87,88,89,90,94,38,39,64,123,125,91,93
       dc.b      44,36,61,33,45,35,40,41,37,46,43,126,95,0
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
       dc.l      @basic_45,148,@basic_40,149,@basic_46,150
       dc.l      @basic_47,151,@basic_48,152,@basic_49,153
       dc.l      @basic_50,154,@basic_51,158,@basic_52,159
       dc.l      @basic_53,176,@basic_40,177,@basic_40,178
       dc.l      @basic_54,179,@basic_55,180,@basic_40,181
       dc.l      @basic_56,182,@basic_40,183,@basic_40,184
       dc.l      @basic_40,185,@basic_57,186,@basic_58,187
       dc.l      @basic_59,196,@basic_60,205,@basic_61,206
       dc.l      @basic_62,209,@basic_63,219,@basic_64,220
       dc.l      @basic_65,221,@basic_66,224,@basic_67,225
       dc.l      @basic_68,226,@basic_69,227,@basic_70,228
       dc.l      @basic_71,229,@basic_72,230,@basic_73,231
       dc.l      @basic_74,232,@basic_75,233,@basic_76,234
       dc.l      @basic_77,235,@basic_78,236,@basic_79,237
       dc.l      @basic_80,238,@basic_81,239,@basic_82,243
       dc.l      @basic_83,244,@basic_84,245,@basic_85,246
       dc.l      @basic_86,247,@basic_87,248
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
       xdef      _vmesc
_vmesc:
       dc.b      74,97,110,70,101,98,77,97,114,65,112,114,77
       dc.b      97,121,74,117,110,74,117,108,65,117,103,83,101
       dc.b      112,79,99,116,78,111,118,68,101,99
       xdef      _vvdgd
_vvdgd:
       dc.l      4194369
       xdef      _vvdgc
_vvdgc:
       dc.l      4194371
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
       section   bss
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
       xdef      _basVideoCursorShow
_basVideoCursorShow:
       ds.b      1
       xdef      _basVideoSpriteSize
_basVideoSpriteSize:
       ds.b      1
       xdef      _mgui_pattern_table
_mgui_pattern_table:
       ds.b      4
       xdef      _mgui_color_table
_mgui_color_table:
       ds.b      4
       xdef      _pStartSimpVar
_pStartSimpVar:
       ds.b      4
       xdef      _pStartArrayVar
_pStartArrayVar:
       ds.b      4
       xdef      _pStartString
_pStartString:
       ds.b      4
       xdef      _pStartProg
_pStartProg:
       ds.b      4
       xdef      _pStartXBasLoad
_pStartXBasLoad:
       ds.b      4
       xdef      _pStartStack
_pStartStack:
       ds.b      4
       xdef      _clearScrWPtr
_clearScrWPtr:
       ds.b      4
       xdef      _basTextPtr
_basTextPtr:
       ds.b      4
       xref      _strcpy
       xref      _itoa
       xref      LDIV
       xref      LMUL
       xref      _FPP_SUM
       xref      _atoi
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
       xref      _MMSJOS_FUNC_RELOC
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
       xref      _FPP_CMP
       xref      _strncmp
