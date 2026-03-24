; D:\PROJETOS\MMSJ320\PROGS_MONITOR\HELLO.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
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
; /********************************************************************************
; *    Programa    : hello.c
; *    Objetivo    : Hello para testes
; *    Criado em   : 11/01/2025
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 11/01/2025  0.1     Moacir Jr.   Criacao Versao Beta
; *--------------------------------------------------------------------------------*/
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
; void listHello(void);
; unsigned char vmouseStat;
; unsigned char vmouseMoveX;
; unsigned char vmouseMoveY;
; unsigned char *vMseMovPtrR = 0x00600512; // Contador do ponteiro das dados do mouse recebidos
; unsigned char *vMseMovPtrW = 0x00600514; // Contador do ponteiro das dados do mouse recebidos
; //-----------------------------------------------------------------------------
; // Principal
; //-----------------------------------------------------------------------------
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-12
       movem.l   D2/A2/A3,-(A7)
       lea       -10(A6),A2
       lea       _itoa.L,A3
; int ix;
; unsigned char sqtdtam[10];
; //unsigned char sqtdtam[10];
; // mostra msgs na tela
; printText("Hellooooooooo...\r\n\0");
       pea       @hello_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; for(ix=0;ix<90000;ix++);
       clr.l     D2
main_1:
       cmp.l     #90000,D2
       bge.s     main_3
       addq.l    #1,D2
       bra       main_1
main_3:
; listHello();
       jsr       _listHello
; while(1)
main_4:
; {
; if (readMouse(&vmouseStat, &vmouseMoveX, &vmouseMoveY))
       pea       _vmouseMoveY.L
       pea       _vmouseMoveX.L
       pea       _vmouseStat.L
       move.l    1206,A0
       jsr       (A0)
       add.w     #12,A7
       tst.b     D0
       beq       main_7
; {
; printText("*[");
       pea       @hello_2.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vmouseStat, sqtdtam, 16);
       pea       16
       move.l    A2,-(A7)
       move.b    _vmouseStat.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; printText(sqtdtam);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("]-[");
       pea       @hello_3.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vmouseMoveX, sqtdtam, 16);
       pea       16
       move.l    A2,-(A7)
       move.b    _vmouseMoveX.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; printText(sqtdtam);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("]-[");
       pea       @hello_3.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(vmouseMoveY, sqtdtam, 16);
       pea       16
       move.l    A2,-(A7)
       move.b    _vmouseMoveY.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; printText(sqtdtam);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("]-[");
       pea       @hello_3.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*vMseMovPtrR, sqtdtam, 10);
       pea       10
       move.l    A2,-(A7)
       move.l    _vMseMovPtrR.L,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; printText(sqtdtam);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("]-[");
       pea       @hello_3.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; itoa(*vMseMovPtrW, sqtdtam, 10);
       pea       10
       move.l    A2,-(A7)
       move.l    _vMseMovPtrW.L,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
; printText(sqtdtam);
       move.l    A2,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("]*\r\n\0");
       pea       @hello_4.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
main_7:
; }
; if (readChar() == 0x1B)
       move.l    1074,A0
       jsr       (A0)
       cmp.b     #27,D0
       bne.s     main_9
; break;
       bra.s     main_6
main_9:
       bra       main_4
main_6:
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; }
; void listHello(void)
; {
       xdef      _listHello
_listHello:
       move.l    D2,-(A7)
; int ix;
; for (ix=0;ix<5;ix++)
       clr.l     D2
listHello_1:
       cmp.l     #5,D2
       bge.s     listHello_3
; printText("Hello................\r\n\0");
       pea       @hello_5.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       addq.l    #1,D2
       bra       listHello_1
listHello_3:
       move.l    (A7)+,D2
       rts
; }
       section   const
@hello_1:
       dc.b      72,101,108,108,111,111,111,111,111,111,111,111
       dc.b      111,46,46,46,13,10,0
@hello_2:
       dc.b      42,91,0
@hello_3:
       dc.b      93,45,91,0
@hello_4:
       dc.b      93,42,13,10,0
@hello_5:
       dc.b      72,101,108,108,111,46,46,46,46,46,46,46,46,46
       dc.b      46,46,46,46,46,46,46,13,10,0
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
       xdef      _vMseMovPtrR
_vMseMovPtrR:
       dc.l      6292754
       xdef      _vMseMovPtrW
_vMseMovPtrW:
       dc.l      6292756
       section   bss
       xdef      _vmouseStat
_vmouseStat:
       ds.b      1
       xdef      _vmouseMoveX
_vmouseMoveX:
       ds.b      1
       xdef      _vmouseMoveY
_vmouseMoveY:
       ds.b      1
       xref      _itoa
