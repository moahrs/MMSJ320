; D:\PROJETOS\MMSJ320\PROGS\FILES.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
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
; typedef struct FILES_DIR
; /********************************************************************************
; *    Programa    : files.c
; *    Objetivo    : File Explorer for MMSJOS com MGUI
; *    Criado em   : 25/12/2024
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 25/12/2024  0.1     Moacir Jr.   Criacao Versao Beta
; * 23/01/2025  0.2     Moacir Jr.   Adaptação nova estrutura e uC/OS-II
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
; #include "files.h"
; //-----------------------------------------------------------------------------
; // Principal
; //-----------------------------------------------------------------------------
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-324
; unsigned char vcont, ix, iy, cc, dd, ee, cnum[20], *cfileptr, *cfilepos;
; unsigned char ikk, vnomefile[128], vnomefilenew[15], avdm2, avdm, avdl, vopc, vresp;
; unsigned long vtotbytes = 0;
       clr.l     -140(A6)
; unsigned char vstring[64], vwb, my, corOpcFile, corOpcFileExec, corOpcDir, corDisable;
; unsigned char *vMemTail;
; unsigned char sqtdtam[10];
; void (*pCarregaDir)(void);
; VDP_COLOR vdpcolor;
; MGUI_SAVESCR vsavescr;
; MGUI_MOUSE mouseData;
; MGUI_SAVESCR windowScr;
; //filesInitReloc();
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; linhastatus = MMSJOS_FUNC_RELOC[FILES_RELOC_LINESTATUS_DEF];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_linhastatus,A1
       move.l    (A0),(A1)
; SearchFile = MMSJOS_FUNC_RELOC[FILES_RELOC_SEARCHFILE_DEF];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_SearchFile,A1
       move.l    4(A0),(A1)
; carregaDir = MMSJOS_FUNC_RELOC[FILES_RELOC_CARREGADIR_DEF];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_carregaDir,A1
       move.l    8(A0),(A1)
; listaDir = MMSJOS_FUNC_RELOC[FILES_RELOC_LISTADIR_DEF];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_listaDir,A1
       move.l    12(A0),(A1)
; mystrcpy = MMSJOS_FUNC_RELOC[FILES_RELOC_STRCPY];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_mystrcpy,A1
       move.l    16(A0),(A1)
; mystrcat = MMSJOS_FUNC_RELOC[FILES_RELOC_STRCAT];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_mystrcat,A1
       move.l    20(A0),(A1)
; mymemset = MMSJOS_FUNC_RELOC[FILES_RELOC_MEMSET];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_mymemset,A1
       move.l    24(A0),(A1)
; mytoupper = MMSJOS_FUNC_RELOC[FILES_RELOC_TOUPPER];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_mytoupper,A1
       move.l    28(A0),(A1)
; myitoa = MMSJOS_FUNC_RELOC[FILES_RELOC_ITOA];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_myitoa,A1
       move.l    32(A0),(A1)
; myltoa = MMSJOS_FUNC_RELOC[FILES_RELOC_LTOA];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_myltoa,A1
       move.l    36(A0),(A1)
; myvRetAlloc = MMSJOS_FUNC_RELOC[FILES_RELOC_VRETALLOC];
       move.l    A5,A0
       add.l     #_MMSJOS_FUNC_RELOC,A0
       move.l    A5,A1
       add.l     #_myvRetAlloc,A1
       move.l    40(A0),(A1)
; if ((unsigned long)mystrcpy < 0x00010000UL)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),D0
       cmp.l     #65536,D0
       bhs.s     main_1
; mystrcpy = strcpy;
       lea       _strcpy(PC),A0
       lea       _strcpy(A5),A0
       move.l    A5,A1
       add.l     #_mystrcpy,A1
       move.l    A0,(A1)
main_1:
; if ((unsigned long)mystrcat < 0x00010000UL)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),D0
       cmp.l     #65536,D0
       bhs.s     main_3
; mystrcat = strcat;
       lea       _strcat(PC),A0
       lea       _strcat(A5),A0
       move.l    A5,A1
       add.l     #_mystrcat,A1
       move.l    A0,(A1)
main_3:
; if ((unsigned long)mymemset < 0x00010000UL)
       move.l    A5,A0
       add.l     #_mymemset,A0
       move.l    (A0),D0
       cmp.l     #65536,D0
       bhs.s     main_5
; mymemset = memset;
       lea       _memset(PC),A0
       lea       _memset(A5),A0
       move.l    A5,A1
       add.l     #_mymemset,A1
       move.l    A0,(A1)
main_5:
; if ((unsigned long)mytoupper < 0x00010000UL)
       move.l    A5,A0
       add.l     #_mytoupper,A0
       move.l    (A0),D0
       cmp.l     #65536,D0
       bhs.s     main_7
; mytoupper = toupper;
       lea       _toupper(PC),A0
       lea       _toupper(A5),A0
       move.l    A5,A1
       add.l     #_mytoupper,A1
       move.l    A0,(A1)
main_7:
; if ((unsigned long)myitoa < 0x00010000UL)
       move.l    A5,A0
       add.l     #_myitoa,A0
       move.l    (A0),D0
       cmp.l     #65536,D0
       bhs.s     main_9
; myitoa = itoa;
       lea       _itoa(PC),A0
       lea       _itoa(A5),A0
       move.l    A5,A1
       add.l     #_myitoa,A1
       move.l    A0,(A1)
main_9:
; if ((unsigned long)myltoa < 0x00010000UL)
       move.l    A5,A0
       add.l     #_myltoa,A0
       move.l    (A0),D0
       cmp.l     #65536,D0
       bhs.s     main_11
; myltoa = ltoa;
       lea       _ltoa(PC),A0
       lea       _ltoa(A5),A0
       move.l    A5,A1
       add.l     #_myltoa,A1
       move.l    A0,(A1)
main_11:
; // Copias locais dos ponteiros para o trecho critico de bootstrap.
; // Isso evita depender de leitura dos globais via base register entre chamadas.
; pCarregaDir = carregaDir;
       move.l    A5,A0
       add.l     #_carregaDir,A0
       move.l    (A0),-52(A6)
; // Reserva apenas o necessario para os globais do explorer.
; // fsMalloc usa a mesma heap do malloc() usado pelo SaveScreenNew.
; vMemTotal = (unsigned char *)fsMalloc(sizeof(LIST_DIR) + 64);
       pea       5918
       move.l    8486744,A0
       jsr       (A0)
       addq.w    #4,A7
       move.l    A5,A0
       add.l     #_vMemTotal,A0
       move.l    D0,(A0)
; if (vMemTotal == 0)
       move.l    A5,A0
       add.l     #_vMemTotal,A0
       move.l    (A0),D0
       bne.s     main_13
; {
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       main_15
main_13:
; }
; // Layout fixo: LIST_DIR no inicio do bloco; variaveis pequenas no final.
; dfile = (LIST_DIR *)vMemTotal;
       move.l    A5,A0
       add.l     #_vMemTotal,A0
       move.l    A5,A1
       add.l     #_dfile,A1
       move.l    (A0),(A1)
; vMemTail = vMemTotal + sizeof(LIST_DIR);
       move.l    A5,A0
       add.l     #_vMemTotal,A0
       move.l    (A0),D0
       add.l     #5854,D0
       move.l    D0,-66(A6)
; vpos = (unsigned short *)vMemTail;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    -66(A6),(A0)
; vposold = (unsigned short *)(vMemTail + 2);
       move.l    -66(A6),D0
       addq.l    #2,D0
       move.l    A5,A0
       add.l     #_vposold,A0
       move.l    D0,(A0)
; dFileCursor = (unsigned char *)(vMemTail + 4);
       move.l    -66(A6),D0
       addq.l    #4,D0
       move.l    A5,A0
       add.l     #_dFileCursor,A0
       move.l    D0,(A0)
; vcorfg = (unsigned char *)(vMemTail + 5);
       move.l    -66(A6),D0
       addq.l    #5,D0
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    D0,(A0)
; vcorbg = (unsigned char *)(vMemTail + 6);
       move.l    -66(A6),D0
       addq.l    #6,D0
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    D0,(A0)
; clinha = (unsigned char *)(vMemTail + 8);
       move.l    -66(A6),D0
       addq.l    #8,D0
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    D0,(A0)
; // Pega as cores atuais
; getColorData(&vdpcolor);
       pea       -48(A6)
       move.l    8410606,A0
       jsr       (A0)
       addq.w    #4,A7
; *vcorfg = vdpcolor.fg;
       lea       -48(A6),A0
       move.l    A5,A1
       add.l     #_vcorfg,A1
       move.l    (A1),A1
       move.b    (A0),(A1)
; *vcorbg = vdpcolor.bg;
       lea       -48(A6),A0
       move.l    A5,A1
       add.l     #_vcorbg,A1
       move.l    (A1),A1
       move.b    1(A0),(A1)
; SaveScreenNew(&windowScr, 0, 0, 255, 191);
       pea       191
       pea       255
       clr.l     -(A7)
       clr.l     -(A7)
       pea       -20(A6)
       move.l    8410498,A0
       jsr       (A0)
       add.w     #20,A7
; // Cria a Janela
; vcont = 1;
       move.b    #1,-324(A6)
; *vpos = 0;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       clr.w     (A0)
; *vposold = 0xFF;
       move.l    A5,A0
       add.l     #_vposold,A0
       move.l    (A0),A0
       move.w    #255,(A0)
; vnomefile[0] = 0x00;
       clr.b     -288+0(A6)
; // Prepara Cabeçalho
; DrawRect(0,18,255,10,*vcorfg);
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       10
       pea       255
       pea       18
       clr.l     -(A7)
       move.l    8410522,A0
       jsr       (A0)
       add.w     #20,A7
; writesxy(16,20,8,"Name\0", *vcorfg, *vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_1,A0
       move.l    A0,-(A7)
       pea       8
       pea       20
       pea       16
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(66,20,8,"Ext\0", *vcorfg, *vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_2,A0
       move.l    A0,-(A7)
       pea       8
       pea       20
       pea       66
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(90,20,8,"Modify\0", *vcorfg, *vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_3,A0
       move.l    A0,-(A7)
       pea       8
       pea       20
       pea       90
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(165,20,8,"Size\0", *vcorfg, *vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_4,A0
       move.l    A0,-(A7)
       pea       8
       pea       20
       pea       165
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(200,20,8,"Atrib\0", *vcorfg, *vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_5,A0
       move.l    A0,-(A7)
       pea       8
       pea       20
       pea       200
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; // Carrega Diretorio
; pCarregaDir();
       move.l    -52(A6),A0
       jsr       (A0)
; // Lista Diretorio
; listaDir();
       move.l    A5,A0
       add.l     #_listaDir,A0
       move.l    (A0),A0
       jsr       (A0)
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; // Loop Principal
; while (vcont)
main_16:
       tst.b     -324(A6)
       beq       main_18
; {
; setPosPressed(0,0); // vposty = 0;
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8410586,A0
       jsr       (A0)
       addq.w    #8,A7
; while (1)
main_19:
; {
; getMouseData(&mouseData);
       pea       -26(A6)
       move.l    8410590,A0
       jsr       (A0)
       addq.w    #4,A7
; if (mouseData.mouseButton == 0x02 || mouseData.mouseBtnDouble == 0x01)  // Direito ou DoubleClick Esquerdo
       lea       -26(A6),A0
       move.b    (A0),D0
       cmp.b     #2,D0
       beq.s     main_24
       lea       -26(A6),A0
       move.b    1(A0),D0
       cmp.b     #1,D0
       bne       main_22
main_24:
; {
; if (mouseData.vposty >= 34 && mouseData.vposty <= 170)
       lea       -26(A6),A0
       move.b    5(A0),D0
       cmp.b     #34,D0
       blo       main_155
       lea       -26(A6),A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #170,D0
       bhi       main_155
; {
; ee = 99;
       move.b    #99,-319(A6)
; dd = 0;
       clr.b     -320(A6)
; while (ee == 99)
main_27:
       move.b    -319(A6),D0
       cmp.b     #99,D0
       bne       main_29
; {
; if (mouseData.vposty >= clinha[dd] && mouseData.vposty <= (clinha[dd] + 10) && clinha[dd] != 0)
       lea       -26(A6),A0
       move.l    A5,A1
       add.l     #_clinha,A1
       move.l    (A1),A1
       move.b    -320(A6),D0
       and.l     #255,D0
       move.b    5(A0),D1
       cmp.b     0(A1,D0.L),D1
       blo       main_30
       lea       -26(A6),A0
       move.l    A5,A1
       add.l     #_clinha,A1
       move.l    (A1),A1
       move.b    -320(A6),D0
       and.l     #255,D0
       move.b    0(A1,D0.L),D0
       add.b     #10,D0
       cmp.b     5(A0),D0
       blo.s     main_30
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -320(A6),D0
       and.l     #255,D0
       move.b    0(A0,D0.L),D0
       beq.s     main_30
; ee = dd;
       move.b    -320(A6),-319(A6)
main_30:
; dd++;
       addq.b    #1,-320(A6)
; if (dd > 13)
       move.b    -320(A6),D0
       cmp.b     #13,D0
       bls.s     main_32
; break;
       bra.s     main_29
main_32:
       bra       main_27
main_29:
; }
; corOpcFile = VDP_LIGHT_RED;
       move.b    #9,-70(A6)
; corOpcFileExec = VDP_LIGHT_RED;
       move.b    #9,-69(A6)
; corOpcDir = VDP_LIGHT_RED;
       move.b    #9,-68(A6)
; corDisable = VDP_LIGHT_RED;
       move.b    #9,-67(A6)
; if (ee != 99)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq       main_34
; {
; MostraIcone(8, clinha[ee], 6, VDP_DARK_GREEN, *vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       12
       pea       6
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -319(A6),D1
       and.l     #255,D1
       move.b    0(A0,D1.L),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       8
       move.l    8410574,A0
       jsr       (A0)
       add.w     #20,A7
; if (dfile->dir[ee].Attr[0] == ' ')
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    34(A0),D0
       cmp.b     #32,D0
       bne       main_36
; {
; corOpcFile = *vcorfg;
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),-70(A6)
; if (dfile->dir[ee].Ext[0] == 'B' && dfile->dir[ee].Ext[1] == 'I' && dfile->dir[ee].Ext[2] == 'N')
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    10(A0),D0
       cmp.b     #66,D0
       bne       main_38
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    11(A0),D0
       cmp.b     #73,D0
       bne.s     main_38
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    12(A0),D0
       cmp.b     #78,D0
       bne.s     main_38
; corOpcFileExec = *vcorfg;
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),-69(A6)
main_38:
       bra.s     main_37
main_36:
; }
; else
; corOpcDir = *vcorfg;
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),-68(A6)
main_37:
       bra.s     main_35
main_34:
; }
; else
; corOpcDir = *vcorfg;
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),-68(A6)
main_35:
; if (!mouseData.mouseBtnDouble)
       lea       -26(A6),A0
       tst.b     1(A0)
       bne       main_40
; {
; if (ee != 99)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq.s     main_42
; my = clinha[ee] + 8;
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       move.b    0(A0,D0.L),D0
       addq.b    #8,D0
       move.b    D0,-71(A6)
       bra.s     main_43
main_42:
; else
; my = mouseData.vposty;
       lea       -26(A6),A0
       move.b    5(A0),-71(A6)
main_43:
; if (my + 46 > 190)
       move.b    -71(A6),D0
       add.b     #46,D0
       and.w     #255,D0
       cmp.w     #190,D0
       bls.s     main_44
; my = my - 52;
       sub.b     #52,-71(A6)
main_44:
; // Abre menu : Delete, Rename, Close
; SaveScreenNew(&vsavescr,30,my,52,46);
       pea       46
       pea       52
       move.b    -71(A6),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       30
       pea       -46(A6)
       move.l    8410498,A0
       jsr       (A0)
       add.w     #20,A7
; FillRect(30,my,50,44,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       44
       pea       50
       move.b    -71(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       30
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; DrawRect(30,my,50,44,*vcorfg);
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       44
       pea       50
       move.b    -71(A6),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       30
       move.l    8410522,A0
       jsr       (A0)
       add.w     #20,A7
; if (corOpcFile == *vcorfg)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -70(A6),D0
       cmp.b     (A0),D0
       bne       main_46
; {
; writesxy(33,my+2,8,"Delete",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_6,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       addq.b    #2,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(33,my+10,8,"Rename",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_7,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       add.b     #10,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(33,my+18,8,"Copy",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_8,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       add.b     #18,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(33,my+26,8,"Execute",corOpcFileExec,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    -69(A6),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_9,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       add.b     #26,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
       bra       main_47
main_46:
; }
; else
; {
; if (ee != 99)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq.s     main_48
; corDisable = *vcorfg;
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),-67(A6)
main_48:
; writesxy(33,my+2,8,"Open",corDisable,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    -67(A6),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_10,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       addq.b    #2,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(33,my+10,8,"New",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_11,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       add.b     #10,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(33,my+18,8,"Remove",corDisable,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    -67(A6),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_12,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       add.b     #18,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(33,my+26,8," ",VDP_LIGHT_RED,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       9
       move.l    A5,A0
       add.l     #@files_13,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       add.b     #26,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
main_47:
; }
; DrawLine(30,my+34,80,my+34,*vcorfg);
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.b    -71(A6),D1
       add.b     #34,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       80
       move.b    -71(A6),D1
       add.b     #34,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       30
       move.l    8410518,A0
       jsr       (A0)
       add.w     #20,A7
; writesxy(33,my+36,8,"Close",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_14,A0
       move.l    A0,-(A7)
       pea       8
       move.b    -71(A6),D1
       add.b     #36,D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       33
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; vopc = 99;
       move.b    #99,-142(A6)
; while (1)
main_50:
; {
; getMouseData(&mouseData);
       pea       -26(A6)
       move.l    8410590,A0
       jsr       (A0)
       addq.w    #4,A7
; if (mouseData.mouseButton == 0x01)  // Esquerdo
       lea       -26(A6),A0
       move.b    (A0),D0
       cmp.b     #1,D0
       bne       main_71
; {
; if (mouseData.vpostx >= 31 && mouseData.vpostx <= 138)
       lea       -26(A6),A0
       move.b    4(A0),D0
       cmp.b     #31,D0
       blo       main_71
       lea       -26(A6),A0
       move.b    4(A0),D0
       and.w     #255,D0
       cmp.w     #138,D0
       bhi       main_71
; {
; if (mouseData.vposty >= my+2 && mouseData.vposty <= my+8 && corOpcFile == *vcorfg)
       lea       -26(A6),A0
       move.b    -71(A6),D0
       addq.b    #2,D0
       cmp.b     5(A0),D0
       bhi.s     main_57
       lea       -26(A6),A0
       move.b    -71(A6),D0
       addq.b    #8,D0
       cmp.b     5(A0),D0
       blo.s     main_57
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -70(A6),D0
       cmp.b     (A0),D0
       bne.s     main_57
; {
; vopc = 0;
       clr.b     -142(A6)
; break;
       bra       main_52
main_57:
; }
; else if (mouseData.vposty >= my+10 && mouseData.vposty <= my+17 && corOpcFile == *vcorfg)
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #10,D0
       cmp.b     5(A0),D0
       bhi.s     main_59
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #17,D0
       cmp.b     5(A0),D0
       blo.s     main_59
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -70(A6),D0
       cmp.b     (A0),D0
       bne.s     main_59
; {
; vopc = 1;
       move.b    #1,-142(A6)
; break;
       bra       main_52
main_59:
; }
; else if (mouseData.vposty >= my+18 && mouseData.vposty <= my+25 && corOpcFile == *vcorfg)
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #18,D0
       cmp.b     5(A0),D0
       bhi.s     main_61
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #25,D0
       cmp.b     5(A0),D0
       blo.s     main_61
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -70(A6),D0
       cmp.b     (A0),D0
       bne.s     main_61
; {
; vopc = 2;
       move.b    #2,-142(A6)
; break;
       bra       main_52
main_61:
; }
; else if (ee != 99 && mouseData.vposty >= my+2 && mouseData.vposty <= my+8 && corOpcDir == *vcorfg)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq       main_63
       lea       -26(A6),A0
       move.b    -71(A6),D0
       addq.b    #2,D0
       cmp.b     5(A0),D0
       bhi.s     main_63
       lea       -26(A6),A0
       move.b    -71(A6),D0
       addq.b    #8,D0
       cmp.b     5(A0),D0
       blo.s     main_63
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -68(A6),D0
       cmp.b     (A0),D0
       bne.s     main_63
; {
; vopc = 3;
       move.b    #3,-142(A6)
; break;
       bra       main_52
main_63:
; }
; else if (mouseData.vposty >= my+10 && mouseData.vposty <= my+17 && corOpcDir == *vcorfg)
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #10,D0
       cmp.b     5(A0),D0
       bhi.s     main_65
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #17,D0
       cmp.b     5(A0),D0
       blo.s     main_65
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -68(A6),D0
       cmp.b     (A0),D0
       bne.s     main_65
; {
; vopc = 4;
       move.b    #4,-142(A6)
; break;
       bra       main_52
main_65:
; }
; else if (ee != 99 && mouseData.vposty >= my+18 && mouseData.vposty <= my+25 && corOpcDir == *vcorfg)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq       main_67
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #18,D0
       cmp.b     5(A0),D0
       bhi.s     main_67
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #25,D0
       cmp.b     5(A0),D0
       blo.s     main_67
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -68(A6),D0
       cmp.b     (A0),D0
       bne.s     main_67
; {
; vopc = 5;
       move.b    #5,-142(A6)
; break;
       bra       main_52
main_67:
; }
; else if (mouseData.vposty >= my+26 && mouseData.vposty <= my+33 && corOpcFileExec == *vcorfg)
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #26,D0
       cmp.b     5(A0),D0
       bhi.s     main_69
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #33,D0
       cmp.b     5(A0),D0
       blo.s     main_69
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -69(A6),D0
       cmp.b     (A0),D0
       bne.s     main_69
; {
; vopc = 6;
       move.b    #6,-142(A6)
; break;
       bra       main_52
main_69:
; }
; else if (mouseData.vposty >= my+44 && mouseData.vposty <= my+51)
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #44,D0
       cmp.b     5(A0),D0
       bhi.s     main_71
       lea       -26(A6),A0
       move.b    -71(A6),D0
       add.b     #51,D0
       cmp.b     5(A0),D0
       blo.s     main_71
; {
; vopc = 7;
       move.b    #7,-142(A6)
; break;
       bra.s     main_52
main_71:
; }
; }
; }
; OSTimeDlyHMSM(0, 0, 0, 100);
       pea       100
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8486736,A0
       jsr       (A0)
       add.w     #16,A7
       bra       main_50
main_52:
; }
; RestoreScreen(vsavescr);
       lea       -46(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       move.l    8410502,A0
       jsr       (A0)
       add.w     #20,A7
       bra       main_77
main_40:
; }
; else
; {
; if (ee != 99)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq.s     main_77
; {
; if (corOpcDir == *vcorfg)   // Se for dir, entra na pasta
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -68(A6),D0
       cmp.b     (A0),D0
       bne.s     main_75
; vopc = 3;
       move.b    #3,-142(A6)
       bra.s     main_77
main_75:
; else if (corOpcFileExec == *vcorfg) // Se for .BIN executa
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    -69(A6),D0
       cmp.b     (A0),D0
       bne.s     main_77
; vopc = 6;
       move.b    #6,-142(A6)
main_77:
; }
; }
; // Executa opcao selecionada
; if (vopc == 0 || vopc == 5)  // Delete File && Delete Directory
       move.b    -142(A6),D0
       beq.s     main_81
       move.b    -142(A6),D0
       cmp.b     #5,D0
       bne       main_79
main_81:
; {
; // Deleta Arquivo
; if (vopc == 0)
       move.b    -142(A6),D0
       bne.s     main_82
; vresp = message("Confirm\nDelete File ?\0",(BTYES | BTNO), 0);
       clr.l     -(A7)
       pea       12
       move.l    A5,A0
       add.l     #@files_15,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
       move.b    D0,-141(A6)
       bra.s     main_83
main_82:
; else
; vresp = message("Confirm\nRemove Directory ?\0",(BTYES | BTNO), 0);
       clr.l     -(A7)
       pea       12
       move.l    A5,A0
       add.l     #@files_16,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
       move.b    D0,-141(A6)
main_83:
; FillRect(8,clinha[ee],8,8,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       pea       8
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -319(A6),D1
       and.l     #255,D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; if (vresp == BTYES)
       move.b    -141(A6),D0
       cmp.b     #4,D0
       bne       main_91
; {
; mystrcpy(vnomefile,dfile->dir[ee].Name);
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),D1
       move.l    D0,-(A7)
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; if (dfile->dir[ee].Ext[0] != 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    10(A0),D0
       beq       main_86
; {
; mystrcat(vnomefile,".");
       move.l    A5,A0
       add.l     #@files_17,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile,dfile->dir[ee].Ext);
       moveq     #10,D1
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    D0,-(A7)
       move.l    (A0),D0
       move.l    D1,-(A7)
       move.b    -319(A6),D1
       and.l     #255,D1
       muls      #39,D1
       add.l     D1,D0
       move.l    (A7)+,D1
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
main_86:
; }
; if (vopc == 0)
       move.b    -142(A6),D0
       bne.s     main_88
; {
; linhastatus(4, vnomefile);
       pea       -288(A6)
       pea       4
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vresp = fsDelFile(vnomefile);
       pea       -288(A6)
       move.l    8486712,A0
       jsr       (A0)
       addq.w    #4,A7
       move.b    D0,-141(A6)
       bra.s     main_89
main_88:
; }
; else
; {
; linhastatus(6, vnomefile);
       pea       -288(A6)
       pea       6
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vresp = fsRemoveDir(vnomefile);
       pea       -288(A6)
       move.l    8486732,A0
       jsr       (A0)
       addq.w    #4,A7
       move.b    D0,-141(A6)
main_89:
; }
; if (vresp >= ERRO_D_START)
       move.b    -141(A6),D0
       and.l     #255,D0
       cmp.l     #-16,D0
       blo       main_90
; {
; if (vopc == 0)
       move.b    -142(A6),D0
       bne.s     main_92
; message("Delete File Error.\0",(BTCLOSE), 0);
       clr.l     -(A7)
       pea       64
       move.l    A5,A0
       add.l     #@files_18,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
       bra.s     main_93
main_92:
; else
; message("Remove Directory Error.\0",(BTCLOSE), 0);
       clr.l     -(A7)
       pea       64
       move.l    A5,A0
       add.l     #@files_19,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
main_93:
       bra.s     main_91
main_90:
; }
; else
; {
; carregaDir();
       move.l    A5,A0
       add.l     #_carregaDir,A0
       move.l    (A0),A0
       jsr       (A0)
; listaDir();
       move.l    A5,A0
       add.l     #_listaDir,A0
       move.l    (A0),A0
       jsr       (A0)
main_91:
; }
; }
; break;
       bra       main_21
main_79:
; }
; else if (vopc == 1 || vopc == 2 || vopc == 4) // Rename (1) / Copy (2) File & Create Directory (4)
       move.b    -142(A6),D0
       cmp.b     #1,D0
       beq.s     main_96
       move.b    -142(A6),D0
       cmp.b     #2,D0
       beq.s     main_96
       move.b    -142(A6),D0
       cmp.b     #4,D0
       bne       main_94
main_96:
; {
; // Renomeia Arquivo
; linhastatus(1, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       pea       1
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; // Abre janela para pedir novo nome
; vstring[0] = '\0';
       clr.b     -136+0(A6)
; SaveScreenNew(&vsavescr,10,40,240,60);
       pea       60
       pea       240
       pea       40
       pea       10
       pea       -46(A6)
       move.l    8410498,A0
       jsr       (A0)
       add.w     #20,A7
; switch (vopc)
       move.b    -142(A6),D0
       and.l     #255,D0
       cmp.l     #2,D0
       beq       main_100
       bhi.s     main_102
       cmp.l     #1,D0
       beq.s     main_99
       bra       main_98
main_102:
       cmp.l     #4,D0
       beq       main_101
       bra       main_98
main_99:
; {
; case 1:
; linhastatus(5, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       pea       5
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; showWindow("Rename File",10,40,240,50, BTNONE);
       clr.l     -(A7)
       pea       50
       pea       240
       pea       40
       pea       10
       move.l    A5,A0
       add.l     #@files_21,A0
       move.l    A0,-(A7)
       move.l    8410566,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(12,57,8,"   New Name:",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_22,A0
       move.l    A0,-(A7)
       pea       8
       pea       57
       pea       12
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       main_98
main_100:
; case 2:
; linhastatus(8, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       pea       8
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; showWindow("Copy File",10,40,240,50, BTNONE);
       clr.l     -(A7)
       pea       50
       pea       240
       pea       40
       pea       10
       move.l    A5,A0
       add.l     #@files_23,A0
       move.l    A0,-(A7)
       move.l    8410566,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(12,57,8,"Destination:",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_24,A0
       move.l    A0,-(A7)
       pea       8
       pea       57
       pea       12
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       main_98
main_101:
; case 4:
; linhastatus(9, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       pea       9
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; showWindow("Create Directory",10,40,240,50, BTNONE);
       clr.l     -(A7)
       pea       50
       pea       240
       pea       40
       pea       10
       move.l    A5,A0
       add.l     #@files_25,A0
       move.l    A0,-(A7)
       move.l    8410566,A0
       jsr       (A0)
       add.w     #24,A7
; writesxy(12,57,8,"   Dir Name:",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_26,A0
       move.l    A0,-(A7)
       pea       8
       pea       57
       pea       12
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
main_98:
; }
; fillin(&vstring, 80, 57, 130, WINDISP);
       clr.l     -(A7)
       pea       130
       pea       57
       pea       80
       pea       -136(A6)
       move.l    8410602,A0
       jsr       (A0)
       add.w     #20,A7
; button("OK", 18, 78, 44, 10, WINDISP);
       clr.l     -(A7)
       pea       10
       pea       44
       pea       78
       pea       18
       move.l    A5,A0
       add.l     #@files_27,A0
       move.l    A0,-(A7)
       move.l    8410610,A0
       jsr       (A0)
       add.w     #24,A7
; button("CANCEL", 66, 78, 44, 10, WINDISP);
       clr.l     -(A7)
       pea       10
       pea       44
       pea       78
       pea       66
       move.l    A5,A0
       add.l     #@files_28,A0
       move.l    A0,-(A7)
       move.l    8410610,A0
       jsr       (A0)
       add.w     #24,A7
; while (1)
main_103:
; {
; fillin(&vstring, 80, 57, 130, WINOPER);
       pea       1
       pea       130
       pea       57
       pea       80
       pea       -136(A6)
       move.l    8410602,A0
       jsr       (A0)
       add.w     #20,A7
; if (button("OK", 18, 78, 44, 10, WINOPER))
       pea       1
       pea       10
       pea       44
       pea       78
       pea       18
       move.l    A5,A0
       add.l     #@files_27,A0
       move.l    A0,-(A7)
       move.l    8410610,A0
       jsr       (A0)
       add.w     #24,A7
       tst.b     D0
       beq.s     main_106
; {
; vwb = BTOK;
       move.b    #1,-72(A6)
; break;
       bra       main_105
main_106:
; }
; if (button("CANCEL", 66, 78, 44, 10, WINOPER))
       pea       1
       pea       10
       pea       44
       pea       78
       pea       66
       move.l    A5,A0
       add.l     #@files_28,A0
       move.l    A0,-(A7)
       move.l    8410610,A0
       jsr       (A0)
       add.w     #24,A7
       tst.b     D0
       beq.s     main_108
; {
; vwb = BTCANCEL;
       move.b    #2,-72(A6)
; break;
       bra.s     main_105
main_108:
; }
; OSTimeDlyHMSM(0, 0, 0, 100);
       pea       100
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8486736,A0
       jsr       (A0)
       add.w     #16,A7
       bra       main_103
main_105:
; }
; RestoreScreen(vsavescr);
       lea       -46(A6),A0
       add.w     #20,A0
       moveq     #4,D1
       move.l    -(A0),-(A7)
       dbra      D1,*-2
       move.l    8410502,A0
       jsr       (A0)
       add.w     #20,A7
; if (vwb == BTOK) {
       move.b    -72(A6),D0
       cmp.b     #1,D0
       bne       main_138
; ix = 0;
       clr.b     -323(A6)
; while(vstring[ix])
main_112:
       move.b    -323(A6),D0
       and.l     #255,D0
       lea       -136(A6),A0
       tst.b     0(A0,D0.L)
       beq       main_114
; {
; vnomefilenew[ix] = mytoupper(vstring[ix]);
       move.b    -323(A6),D1
       and.l     #255,D1
       lea       -136(A6),A0
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_mytoupper,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #4,A7
       move.b    -323(A6),D1
       and.l     #255,D1
       lea       -160(A6),A0
       move.b    D0,0(A0,D1.L)
; ix++;
       addq.b    #1,-323(A6)
       bra       main_112
main_114:
; }
; vstring[ix] = 0x00;
       move.b    -323(A6),D0
       and.l     #255,D0
       lea       -136(A6),A0
       clr.b     0(A0,D0.L)
; switch (vopc)
       move.b    -142(A6),D0
       and.l     #255,D0
       cmp.l     #2,D0
       beq       main_118
       bhi.s     main_120
       cmp.l     #1,D0
       beq.s     main_117
       bra       main_116
main_120:
       cmp.l     #4,D0
       beq       main_119
       bra       main_116
main_117:
; {
; case 1:
; mystrcpy(vnomefile,"Confirm\nRename File ?\n\0");
       move.l    A5,A0
       add.l     #@files_29,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; break;
       bra       main_116
main_118:
; case 2:
; mystrcpy(vnomefile,"Confirm\nCopy File ?\n\0");
       move.l    A5,A0
       add.l     #@files_30,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; break;
       bra.s     main_116
main_119:
; case 4:
; mystrcpy(vnomefile,"Confirm\nCreate Directory ?\n\0");
       move.l    A5,A0
       add.l     #@files_31,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; break;
main_116:
; }
; mystrcat(vnomefile, vstring);
       pea       -136(A6)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vresp = message(vnomefile,(BTYES | BTNO), 0);
       clr.l     -(A7)
       pea       12
       pea       -288(A6)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
       move.b    D0,-141(A6)
; if (vresp == BTYES)
       move.b    -141(A6),D0
       cmp.b     #4,D0
       bne       main_138
; {
; if (ee != 99)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq       main_129
; {
; if (vopc == 1)
       move.b    -142(A6),D0
       cmp.b     #1,D0
       bne       main_125
; {
; mystrcpy(vnomefile,dfile->dir[ee].Name);
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),D1
       move.l    D0,-(A7)
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
       bra       main_127
main_125:
; }
; else if (vopc == 2)
       move.b    -142(A6),D0
       cmp.b     #2,D0
       bne       main_127
; {
; mystrcpy(vnomefile,"CP ");
       move.l    A5,A0
       add.l     #@files_32,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile,dfile->dir[ee].Name);
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),D1
       move.l    D0,-(A7)
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
main_127:
; }
; if (dfile->dir[ee].Ext[0] != 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    10(A0),D0
       beq       main_129
; {
; mystrcat(vnomefile,".");
       move.l    A5,A0
       add.l     #@files_17,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile,dfile->dir[ee].Ext);
       moveq     #10,D1
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    D0,-(A7)
       move.l    (A0),D0
       move.l    D1,-(A7)
       move.b    -319(A6),D1
       and.l     #255,D1
       muls      #39,D1
       add.l     D1,D0
       move.l    (A7)+,D1
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
main_129:
; }
; }
; switch (vopc)
       move.b    -142(A6),D0
       and.l     #255,D0
       cmp.l     #2,D0
       beq       main_134
       bhi.s     main_136
       cmp.l     #1,D0
       beq.s     main_133
       bra       main_132
main_136:
       cmp.l     #4,D0
       beq       main_135
       bra       main_132
main_133:
; {
; case 1:
; linhastatus(5, vnomefile);
       pea       -288(A6)
       pea       5
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vresp = fsRenameFile(vnomefile,vnomefilenew);
       pea       -160(A6)
       pea       -288(A6)
       move.l    8486716,A0
       jsr       (A0)
       addq.w    #8,A7
       move.b    D0,-141(A6)
; break;
       bra       main_132
main_134:
; case 2:
; linhastatus(8, vnomefile);
       pea       -288(A6)
       pea       8
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile," ");
       move.l    A5,A0
       add.l     #@files_13,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile,vnomefilenew);
       pea       -160(A6)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vresp = fsOsCommand(vnomefile);
       pea       -288(A6)
       move.l    8486680,A0
       jsr       (A0)
       addq.w    #4,A7
       move.b    D0,-141(A6)
; break;
       bra.s     main_132
main_135:
; case 4:
; linhastatus(9, vnomefile);
       pea       -288(A6)
       pea       9
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vresp = fsMakeDir(vnomefilenew);
       pea       -160(A6)
       move.l    8486724,A0
       jsr       (A0)
       addq.w    #4,A7
       move.b    D0,-141(A6)
; break;
main_132:
; }
; if (vresp >= ERRO_D_START)
       move.b    -141(A6),D0
       and.l     #255,D0
       cmp.l     #-16,D0
       blo       main_137
; {
; switch (vopc)
       move.b    -142(A6),D0
       and.l     #255,D0
       cmp.l     #2,D0
       beq       main_142
       bhi.s     main_144
       cmp.l     #1,D0
       beq.s     main_141
       bra       main_140
main_144:
       cmp.l     #4,D0
       beq       main_143
       bra       main_140
main_141:
; {
; case 1:
; message("Rename File Error.\0",(BTCLOSE), 0);
       clr.l     -(A7)
       pea       64
       move.l    A5,A0
       add.l     #@files_33,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
; break;
       bra       main_140
main_142:
; case 2:
; message("Copy File Error.\0",(BTCLOSE), 0);
       clr.l     -(A7)
       pea       64
       move.l    A5,A0
       add.l     #@files_34,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
; break;
       bra.s     main_140
main_143:
; case 4:
; message("Create Directory Error.\0",(BTCLOSE), 0);
       clr.l     -(A7)
       pea       64
       move.l    A5,A0
       add.l     #@files_35,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
; break;
main_140:
       bra.s     main_138
main_137:
; }
; }
; else
; {
; carregaDir();
       move.l    A5,A0
       add.l     #_carregaDir,A0
       move.l    (A0),A0
       jsr       (A0)
; listaDir();
       move.l    A5,A0
       add.l     #_listaDir,A0
       move.l    (A0),A0
       jsr       (A0)
main_138:
; }
; }
; }
; linhastatus(0, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; if (ee != 99)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq       main_145
; FillRect(8,clinha[ee],8,8,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       pea       8
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -319(A6),D1
       and.l     #255,D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
main_145:
; break;
       bra       main_21
main_94:
; }
; else if (vopc == 3) // Enter Directory  // Usar click duplo tb
       move.b    -142(A6),D0
       cmp.b     #3,D0
       bne       main_147
; {
; FillRect(8,clinha[ee],8,8,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       pea       8
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -319(A6),D1
       and.l     #255,D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; mystrcpy(vnomefile,dfile->dir[ee].Name);
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),D1
       move.l    D0,-(A7)
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; if (dfile->dir[ee].Ext[0] != 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    10(A0),D0
       beq       main_149
; {
; mystrcat(vnomefile,".");
       move.l    A5,A0
       add.l     #@files_17,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile,dfile->dir[ee].Ext);
       moveq     #10,D1
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    D0,-(A7)
       move.l    (A0),D0
       move.l    D1,-(A7)
       move.b    -319(A6),D1
       and.l     #255,D1
       muls      #39,D1
       add.l     D1,D0
       move.l    (A7)+,D1
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
main_149:
; }
; linhastatus(5, vnomefile);
       pea       -288(A6)
       pea       5
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vresp = fsChangeDir(vnomefile);
       pea       -288(A6)
       move.l    8486728,A0
       jsr       (A0)
       addq.w    #4,A7
       move.b    D0,-141(A6)
; if (vresp >= ERRO_D_START)
       move.b    -141(A6),D0
       and.l     #255,D0
       cmp.l     #-16,D0
       blo.s     main_151
; {
; message("Change Directory Error.\0",(BTCLOSE), 0);
       clr.l     -(A7)
       pea       64
       move.l    A5,A0
       add.l     #@files_36,A0
       move.l    A0,-(A7)
       move.l    8410558,A0
       jsr       (A0)
       add.w     #12,A7
       bra.s     main_152
main_151:
; }
; else
; {
; carregaDir();
       move.l    A5,A0
       add.l     #_carregaDir,A0
       move.l    (A0),A0
       jsr       (A0)
; listaDir();
       move.l    A5,A0
       add.l     #_listaDir,A0
       move.l    (A0),A0
       jsr       (A0)
main_152:
; }
; linhastatus(0, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; break;
       bra       main_21
main_147:
; }
; else if (vopc == 6) // Execute File .BIN    // Usar click duplo tb
       move.b    -142(A6),D0
       cmp.b     #6,D0
       bne       main_153
; {
; FillRect(8,clinha[ee],8,8,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       pea       8
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -319(A6),D1
       and.l     #255,D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; mystrcpy(vnomefile,dfile->dir[ee].Name);
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),D1
       move.l    D0,-(A7)
       move.b    -319(A6),D0
       and.l     #255,D0
       muls      #39,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcpy,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile,".");
       move.l    A5,A0
       add.l     #@files_17,A0
       move.l    (A0),-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; mystrcat(vnomefile,dfile->dir[ee].Ext);
       moveq     #10,D1
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    D0,-(A7)
       move.l    (A0),D0
       move.l    D1,-(A7)
       move.b    -319(A6),D1
       and.l     #255,D1
       muls      #39,D1
       add.l     D1,D0
       move.l    (A7)+,D1
       add.l     D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -288(A6)
       move.l    A5,A0
       add.l     #_mystrcat,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; linhastatus(5, vnomefile);
       pea       -288(A6)
       pea       5
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; // Chama Execução via SO
; // vresp = xxxxxx.
; linhastatus(0, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; break;
       bra       main_21
main_153:
; }
; else if (vopc == 7) // Close Menu
       move.b    -142(A6),D0
       cmp.b     #7,D0
       bne       main_155
; {
; if (ee != 99)
       move.b    -319(A6),D0
       cmp.b     #99,D0
       beq       main_157
; FillRect(8,clinha[ee],8,8,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       pea       8
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -319(A6),D1
       and.l     #255,D1
       move.b    0(A0,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       8
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
main_157:
; break;
       bra       main_21
main_155:
       bra       main_171
main_22:
; }
; }
; }
; else if (mouseData.mouseButton == 0x01)  // Esquerdo
       lea       -26(A6),A0
       move.b    (A0),D0
       cmp.b     #1,D0
       bne       main_171
; {
; if (mouseData.vposty > 170) {
       lea       -26(A6),A0
       move.b    5(A0),D0
       and.w     #255,D0
       cmp.w     #170,D0
       bls       main_171
; // Ultima Linha
; if (mouseData.vpostx > 5 && mouseData.vpostx <= 20) {               // Flecha Esquerda
       lea       -26(A6),A0
       move.b    4(A0),D0
       cmp.b     #5,D0
       bls       main_163
       lea       -26(A6),A0
       move.b    4(A0),D0
       cmp.b     #20,D0
       bhi       main_163
; *vposold = *vpos;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vposold,A1
       move.l    (A1),A1
       move.w    (A0),(A1)
; if (*vpos < 14)
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       move.w    (A0),D0
       cmp.w     #14,D0
       bhs.s     main_165
; *vpos = 0;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       clr.w     (A0)
       bra.s     main_166
main_165:
; else
; *vpos = *vpos - 14;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       sub.w     #14,(A0)
main_166:
; listaDir();
       move.l    A5,A0
       add.l     #_listaDir,A0
       move.l    (A0),A0
       jsr       (A0)
; break;
       bra       main_21
main_163:
; }
; else if (mouseData.vpostx >= 25 && mouseData.vpostx <= 40) {         // Flecha Direita
       lea       -26(A6),A0
       move.b    4(A0),D0
       cmp.b     #25,D0
       blo       main_167
       lea       -26(A6),A0
       move.b    4(A0),D0
       cmp.b     #40,D0
       bhi       main_167
; *vposold = *vpos;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       move.l    A5,A1
       add.l     #_vposold,A1
       move.l    (A1),A1
       move.w    (A0),(A1)
; *vpos = *vpos + 14;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       add.w     #14,(A0)
; listaDir();
       move.l    A5,A0
       add.l     #_listaDir,A0
       move.l    (A0),A0
       jsr       (A0)
; break;
       bra       main_21
main_167:
; }
; else if (mouseData.vpostx >= 100 && mouseData.vpostx <= 120) {       // Search
       lea       -26(A6),A0
       move.b    4(A0),D0
       cmp.b     #100,D0
       blo.s     main_169
       lea       -26(A6),A0
       move.b    4(A0),D0
       cmp.b     #120,D0
       bhi.s     main_169
; break;
       bra       main_21
main_169:
; }
; else if (mouseData.vpostx >= 200 && mouseData.vpostx <= 220) {       // Sair
       lea       -26(A6),A0
       move.b    4(A0),D0
       and.w     #255,D0
       cmp.w     #200,D0
       blo       main_171
       lea       -26(A6),A0
       move.b    4(A0),D0
       and.w     #255,D0
       cmp.w     #220,D0
       bhi.s     main_171
; linhastatus(7,"\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       pea       7
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; vcont = 0;
       clr.b     -324(A6)
; break;
       bra.s     main_21
main_171:
; }
; }
; }
; OSTimeDlyHMSM(0, 0, 0, 100);
       pea       100
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8486736,A0
       jsr       (A0)
       add.w     #16,A7
       bra       main_19
main_21:
; }
; if (vcont)
       tst.b     -324(A6)
       beq.s     main_173
; OSTimeDlyHMSM(0, 0, 0, 100);
       pea       100
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       move.l    8486736,A0
       jsr       (A0)
       add.w     #16,A7
main_173:
       bra       main_16
main_18:
; }
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; RestoreScreen(windowScr);
       lea       -20(A6),A0
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
; fsFree(vMemTotal);
       move.l    A5,A0
       add.l     #_vMemTotal,A0
       move.l    (A0),-(A7)
       move.l    8486700,A0
       jsr       (A0)
       addq.w    #4,A7
main_15:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------
; void linhastatusDef(unsigned char vtipomsgs, unsigned char * vmsgs)
; {
       xdef      _linhastatusDef
_linhastatusDef:
       link      A6,#0
; FillRect(2,176,252,13,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       13
       pea       252
       pea       176
       pea       2
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; DrawRect(0,175,255,15,*vcorfg);
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       15
       pea       255
       pea       175
       clr.l     -(A7)
       move.l    8410522,A0
       jsr       (A0)
       add.w     #20,A7
; switch (vtipomsgs) {
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #10,D0
       bhs       linhastatusDef_2
       asl.l     #1,D0
       move.w    linhastatusDef_3(PC,D0.L),D0
       jmp       linhastatusDef_3(PC,D0.W)
linhastatusDef_3:
       dc.w      linhastatusDef_4-linhastatusDef_3
       dc.w      linhastatusDef_5-linhastatusDef_3
       dc.w      linhastatusDef_6-linhastatusDef_3
       dc.w      linhastatusDef_7-linhastatusDef_3
       dc.w      linhastatusDef_8-linhastatusDef_3
       dc.w      linhastatusDef_9-linhastatusDef_3
       dc.w      linhastatusDef_10-linhastatusDef_3
       dc.w      linhastatusDef_11-linhastatusDef_3
       dc.w      linhastatusDef_12-linhastatusDef_3
       dc.w      linhastatusDef_13-linhastatusDef_3
linhastatusDef_4:
; case 0:
; MostraIcone(10, 180, 5,*vcorfg, *vcorbg);   // Icone <
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       5
       pea       180
       pea       10
       move.l    8410574,A0
       jsr       (A0)
       add.w     #20,A7
; MostraIcone(30, 180, 6,*vcorfg, *vcorbg);   // Icone >
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       6
       pea       180
       pea       30
       move.l    8410574,A0
       jsr       (A0)
       add.w     #20,A7
; MostraIcone(107, 180, 7,*vcorfg, *vcorbg);  // Icone Search
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       7
       pea       180
       pea       107
       move.l    8410574,A0
       jsr       (A0)
       add.w     #20,A7
; MostraIcone(207, 180, 4,*vcorfg, *vcorbg);  // Icone Exit
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       4
       pea       180
       pea       207
       move.l    8410574,A0
       jsr       (A0)
       add.w     #20,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_5:
; case 1:
; writesxy(7,180,8,"wait...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_37,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_6:
; case 2:
; writesxy(7,180,8,"processing...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_38,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_7:
; case 3:
; writesxy(7,180,8,"file not found...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_39,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_8:
; case 4:
; writesxy(7,180,8,"Deleting file...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_40,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_9:
; case 5:
; writesxy(7,180,8,"Renaming file...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_41,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_10:
; case 6:
; writesxy(7,180,8,"Deleting Directory...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_42,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_11:
; case 7:
; writesxy(7,180,8,"Exiting...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_43,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_12:
; case 8:
; writesxy(7,180,8,"Copying File...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_44,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
       bra       linhastatusDef_2
linhastatusDef_13:
; case 9:
; writesxy(7,180,8,"Creating Directory...\0",*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #@files_45,A0
       move.l    A0,-(A7)
       pea       8
       pea       180
       pea       7
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; break;
linhastatusDef_2:
; }
; if (*vmsgs)
       move.l    12(A6),A0
       tst.b     (A0)
       beq       linhastatusDef_14
; writesxy(151,180,8,vmsgs,*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    12(A6),-(A7)
       pea       8
       pea       180
       pea       151
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
linhastatusDef_14:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------
; void carregaDirDef(void)
; {
       xdef      _carregaDirDef
_carregaDirDef:
       link      A6,#-168
; unsigned char vcont, ikk, ix, iy, cc, dd, ee, cnum[20];
; unsigned char vnomefile[32], dsize;
; unsigned char sqtdtam[10], cuntam;
; unsigned char vlen;
; unsigned char destIdx;
; unsigned long vtotbytes = 0, vqtdtam;
       clr.l     -90(A6)
; FILES_DIR ddir;
; FILES_DIR *pDestDir;
; FAT32_DIR vdirfiles;
; if (vMemTotal == 0 || dfile == (LIST_DIR *)1 || dFileCursor == (unsigned char *)1)
       move.l    A5,A0
       add.l     #_vMemTotal,A0
       move.l    (A0),D0
       beq.s     carregaDirDef_3
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),D0
       cmp.l     #1,D0
       beq.s     carregaDirDef_3
       move.l    A5,A0
       add.l     #_dFileCursor,A0
       move.l    (A0),D0
       cmp.l     #1,D0
       bne.s     carregaDirDef_1
carregaDirDef_3:
; {
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       carregaDirDef_4
carregaDirDef_1:
; }
; // Leitura dos Arquivos
; *dFileCursor = 0;
       move.l    A5,A0
       add.l     #_dFileCursor,A0
       move.l    (A0),A0
       clr.b     (A0)
; dsize = sizeof(FILES_DIR);
       move.b    #39,-105(A6)
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; // Logica de leitura Diretorio FAT32
; if (fsFindInDir(NULL, TYPE_FIRST_ENTRY) < ERRO_D_START)
       pea       8
       clr.b     D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    8486740,A0
       jsr       (A0)
       addq.w    #8,A7
       cmp.l     #-16,D0
       bhs       carregaDirDef_9
; {
; while (1)
carregaDirDef_7:
; {
; fsGetDirAtuData(&vdirfiles);
       pea       -38(A6)
       move.l    8486656,A0
       jsr       (A0)
       addq.w    #4,A7
; if (vdirfiles.Attr != ATTR_VOLUME && (vdirfiles.Name[0] != '.' || (vdirfiles.Name[0] == '.' && vdirfiles.Name[1] == '.' )))
       lea       -38(A6),A0
       move.b    11(A0),D0
       cmp.b     #8,D0
       beq       carregaDirDef_10
       lea       -38(A6),A0
       move.b    (A0),D0
       cmp.b     #46,D0
       bne.s     carregaDirDef_12
       lea       -38(A6),A0
       move.b    (A0),D0
       cmp.b     #46,D0
       bne       carregaDirDef_10
       lea       -38(A6),A0
       move.b    1(A0),D0
       cmp.b     #46,D0
       bne       carregaDirDef_10
carregaDirDef_12:
; {
; if (*dFileCursor >= 150)
       move.l    A5,A0
       add.l     #_dFileCursor,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #150,D0
       blo.s     carregaDirDef_13
; {
; break;
       bra       carregaDirDef_9
carregaDirDef_13:
; }
; // Nome
; for (cc = 0; cc <= 7; cc++)
       clr.b     -161(A6)
carregaDirDef_15:
       move.b    -161(A6),D0
       cmp.b     #7,D0
       bhi       carregaDirDef_17
; {
; if (vdirfiles.Name[cc] > 32)
       lea       -38(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       move.b    0(A0,D0.L),D0
       cmp.b     #32,D0
       bls.s     carregaDirDef_18
; ddir.Name[cc] = vdirfiles.Name[cc];
       lea       -38(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       lea       -82(A6),A1
       move.b    -161(A6),D1
       and.l     #255,D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       bra.s     carregaDirDef_19
carregaDirDef_18:
; else
; ddir.Name[cc] = '\0';
       lea       -82(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       clr.b     0(A0,D0.L)
carregaDirDef_19:
       addq.b    #1,-161(A6)
       bra       carregaDirDef_15
carregaDirDef_17:
; }
; ddir.Name[8] = '\0';
       lea       -82(A6),A0
       clr.b     8(A0)
; // Extensao
; for (cc = 0; cc <= 2; cc++)
       clr.b     -161(A6)
carregaDirDef_20:
       move.b    -161(A6),D0
       cmp.b     #2,D0
       bhi       carregaDirDef_22
; {
; if (vdirfiles.Ext[cc] > 32)
       lea       -38(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    8(A0),D0
       cmp.b     #32,D0
       bls.s     carregaDirDef_23
; ddir.Ext[cc] = vdirfiles.Ext[cc];
       lea       -38(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       lea       -82(A6),A1
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A1
       move.b    8(A0),10(A1)
       bra.s     carregaDirDef_24
carregaDirDef_23:
; else
; ddir.Ext[cc] = '\0';
       lea       -82(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       clr.b     10(A0)
carregaDirDef_24:
       addq.b    #1,-161(A6)
       bra       carregaDirDef_20
carregaDirDef_22:
; }
; ddir.Ext[3] = '\0';
       lea       -82(A6),A0
       clr.b     13(A0)
; // Data Ultima Modificacao
; // Mes
; vqtdtam = (vdirfiles.UpdateDate & 0x01E0) >> 5;
       lea       -38(A6),A0
       move.w    18(A0),D0
       and.l     #65535,D0
       and.l     #480,D0
       lsr.l     #5,D0
       move.l    D0,-86(A6)
; if (vqtdtam < 1 || vqtdtam > 12)
       move.l    -86(A6),D0
       cmp.l     #1,D0
       blo.s     carregaDirDef_27
       move.l    -86(A6),D0
       cmp.l     #12,D0
       bls.s     carregaDirDef_25
carregaDirDef_27:
; vqtdtam = 1;
       move.l    #1,-86(A6)
carregaDirDef_25:
; vqtdtam--;
       subq.l    #1,-86(A6)
; ddir.Modify[0] = vmesc[vqtdtam][0];
       move.l    A5,A0
       add.l     #_vmesc,A0
       move.l    -86(A6),D0
       muls      #3,D0
       lea       -82(A6),A1
       move.b    0(A0,D0.L),14(A1)
; ddir.Modify[1] = vmesc[vqtdtam][1];
       move.l    A5,A0
       add.l     #_vmesc,A0
       move.l    -86(A6),D0
       muls      #3,D0
       add.l     D0,A0
       lea       -82(A6),A1
       move.b    1(A0),15(A1)
; ddir.Modify[2] = vmesc[vqtdtam][2];
       move.l    A5,A0
       add.l     #_vmesc,A0
       move.l    -86(A6),D0
       muls      #3,D0
       add.l     D0,A0
       lea       -82(A6),A1
       move.b    2(A0),16(A1)
; ddir.Modify[3] = '/';
       lea       -82(A6),A0
       move.b    #47,17(A0)
; // Dia
; vqtdtam = vdirfiles.UpdateDate & 0x001F;
       lea       -38(A6),A0
       move.w    18(A0),D0
       and.l     #65535,D0
       and.l     #31,D0
       move.l    D0,-86(A6)
; mymemset(sqtdtam, 0x0, 10);
       pea       10
       clr.l     -(A7)
       pea       -104(A6)
       move.l    A5,A0
       add.l     #_mymemset,A0
       move.l    (A0),A0
       jsr       (A0)
       add.w     #12,A7
; myitoa(vqtdtam, sqtdtam, 10);
       pea       10
       pea       -104(A6)
       move.l    -86(A6),-(A7)
       move.l    A5,A0
       add.l     #_myitoa,A0
       move.l    (A0),A0
       jsr       (A0)
       add.w     #12,A7
; if (vqtdtam < 10) {
       move.l    -86(A6),D0
       cmp.l     #10,D0
       bhs.s     carregaDirDef_28
; ddir.Modify[4] = '0';
       lea       -82(A6),A0
       move.b    #48,18(A0)
; ddir.Modify[5] = sqtdtam[0];
       lea       -82(A6),A0
       move.b    -104+0(A6),19(A0)
       bra.s     carregaDirDef_29
carregaDirDef_28:
; }
; else {
; ddir.Modify[4] = sqtdtam[0];
       lea       -82(A6),A0
       move.b    -104+0(A6),18(A0)
; ddir.Modify[5] = sqtdtam[1];
       lea       -82(A6),A0
       move.b    -104+1(A6),19(A0)
carregaDirDef_29:
; }
; ddir.Modify[6] = '/';
       lea       -82(A6),A0
       move.b    #47,20(A0)
; // Ano
; vqtdtam = ((vdirfiles.UpdateDate & 0xFE00) >> 9) + 1980;
       lea       -38(A6),A0
       move.w    18(A0),D0
       and.l     #65535,D0
       and.l     #65024,D0
       lsr.l     #8,D0
       lsr.l     #1,D0
       add.l     #1980,D0
       move.l    D0,-86(A6)
; mymemset(sqtdtam, 0x0, 10);
       pea       10
       clr.l     -(A7)
       pea       -104(A6)
       move.l    A5,A0
       add.l     #_mymemset,A0
       move.l    (A0),A0
       jsr       (A0)
       add.w     #12,A7
; myitoa(vqtdtam, sqtdtam, 10);
       pea       10
       pea       -104(A6)
       move.l    -86(A6),-(A7)
       move.l    A5,A0
       add.l     #_myitoa,A0
       move.l    (A0),A0
       jsr       (A0)
       add.w     #12,A7
; ddir.Modify[7] = sqtdtam[0];
       lea       -82(A6),A0
       move.b    -104+0(A6),21(A0)
; ddir.Modify[8] = sqtdtam[1];
       lea       -82(A6),A0
       move.b    -104+1(A6),22(A0)
; ddir.Modify[9] = sqtdtam[2];
       lea       -82(A6),A0
       move.b    -104+2(A6),23(A0)
; ddir.Modify[10] = sqtdtam[3];
       lea       -82(A6),A0
       move.b    -104+3(A6),24(A0)
; ddir.Modify[11] = '\0';
       lea       -82(A6),A0
       clr.b     25(A0)
; // Tamanho
; if (vdirfiles.Attr != ATTR_DIRECTORY) {
       lea       -38(A6),A0
       move.b    11(A0),D0
       cmp.b     #16,D0
       beq       carregaDirDef_30
; // Reduz o tamanho a unidade (GB, MB ou KB)
; vqtdtam = vdirfiles.Size;
       lea       -38(A6),A0
       move.l    26(A0),-86(A6)
; if ((vqtdtam & 0xC0000000) != 0) {
       move.l    -86(A6),D0
       and.l     #-1073741824,D0
       beq.s     carregaDirDef_32
; cuntam = 'G';
       move.b    #71,-93(A6)
; vqtdtam = ((vqtdtam & 0xC0000000) >> 30) + 1;
       move.l    -86(A6),D0
       and.l     #-1073741824,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #6,D0
       addq.l    #1,D0
       move.l    D0,-86(A6)
       bra       carregaDirDef_37
carregaDirDef_32:
; }
; else if ((vqtdtam & 0x3FF00000) != 0) {
       move.l    -86(A6),D0
       and.l     #1072693248,D0
       beq.s     carregaDirDef_34
; cuntam = 'M';
       move.b    #77,-93(A6)
; vqtdtam = ((vqtdtam & 0x3FF00000) >> 20) + 1;
       move.l    -86(A6),D0
       and.l     #1072693248,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #4,D0
       addq.l    #1,D0
       move.l    D0,-86(A6)
       bra.s     carregaDirDef_37
carregaDirDef_34:
; }
; else if ((vqtdtam & 0x000FFC00) != 0) {
       move.l    -86(A6),D0
       and.l     #1047552,D0
       beq.s     carregaDirDef_36
; cuntam = 'K';
       move.b    #75,-93(A6)
; vqtdtam = ((vqtdtam & 0x000FFC00) >> 10) + 1;
       move.l    -86(A6),D0
       and.l     #1047552,D0
       lsr.l     #8,D0
       lsr.l     #2,D0
       addq.l    #1,D0
       move.l    D0,-86(A6)
       bra.s     carregaDirDef_37
carregaDirDef_36:
; }
; else
; cuntam = ' ';
       move.b    #32,-93(A6)
carregaDirDef_37:
; // Transforma para decimal
; mymemset(sqtdtam, 0x0, 10);
       pea       10
       clr.l     -(A7)
       pea       -104(A6)
       move.l    A5,A0
       add.l     #_mymemset,A0
       move.l    (A0),A0
       jsr       (A0)
       add.w     #12,A7
; myitoa(vqtdtam, sqtdtam, 10);
       pea       10
       pea       -104(A6)
       move.l    -86(A6),-(A7)
       move.l    A5,A0
       add.l     #_myitoa,A0
       move.l    (A0),A0
       jsr       (A0)
       add.w     #12,A7
; // Primeira Parte da Linha do dir, tamanho
; for(ix = 0; ix <= 3; ix++) {
       clr.b     -163(A6)
carregaDirDef_38:
       move.b    -163(A6),D0
       cmp.b     #3,D0
       bhi.s     carregaDirDef_40
; if (sqtdtam[ix] == 0)
       move.b    -163(A6),D0
       and.l     #255,D0
       move.b    -104(A6,D0.L),D0
       bne.s     carregaDirDef_41
; break;
       bra.s     carregaDirDef_40
carregaDirDef_41:
       addq.b    #1,-163(A6)
       bra       carregaDirDef_38
carregaDirDef_40:
; }
; iy = (4 - ix);
       moveq     #4,D0
       sub.b     -163(A6),D0
       move.b    D0,-162(A6)
; for(ix = 0; ix <= 3; ix++) {
       clr.b     -163(A6)
carregaDirDef_43:
       move.b    -163(A6),D0
       cmp.b     #3,D0
       bhi       carregaDirDef_45
; if (iy <= ix) {
       move.b    -162(A6),D0
       cmp.b     -163(A6),D0
       bhi.s     carregaDirDef_46
; ikk = ix - iy;
       move.b    -163(A6),D0
       sub.b     -162(A6),D0
       move.b    D0,-164(A6)
; ddir.Size[ix] = sqtdtam[ikk];
       move.b    -164(A6),D0
       and.l     #255,D0
       lea       -82(A6),A0
       move.b    -163(A6),D1
       and.l     #255,D1
       add.l     D1,A0
       move.b    -104(A6,D0.L),26(A0)
       bra.s     carregaDirDef_47
carregaDirDef_46:
; }
; else
; ddir.Size[ix] = ' ';
       lea       -82(A6),A0
       move.b    -163(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    #32,26(A0)
carregaDirDef_47:
       addq.b    #1,-163(A6)
       bra       carregaDirDef_43
carregaDirDef_45:
; }
; ddir.Size[ix] = cuntam;
       lea       -82(A6),A0
       move.b    -163(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    -93(A6),26(A0)
       bra.s     carregaDirDef_31
carregaDirDef_30:
; }
; else {
; ddir.Size[0] = ' ';
       lea       -82(A6),A0
       move.b    #32,26(A0)
; ddir.Size[1] = ' ';
       lea       -82(A6),A0
       move.b    #32,27(A0)
; ddir.Size[2] = ' ';
       lea       -82(A6),A0
       move.b    #32,28(A0)
; ddir.Size[3] = ' ';
       lea       -82(A6),A0
       move.b    #32,29(A0)
; ddir.Size[4] = '0';
       lea       -82(A6),A0
       move.b    #48,30(A0)
carregaDirDef_31:
; }
; ddir.Size[5] = '\0';
       lea       -82(A6),A0
       clr.b     31(A0)
; // Atributos
; if (vdirfiles.Attr == ATTR_DIRECTORY) {
       lea       -38(A6),A0
       move.b    11(A0),D0
       cmp.b     #16,D0
       bne.s     carregaDirDef_48
; ddir.Attr[0] = '<';
       lea       -82(A6),A0
       move.b    #60,34(A0)
; ddir.Attr[1] = 'D';
       lea       -82(A6),A0
       move.b    #68,35(A0)
; ddir.Attr[2] = 'I';
       lea       -82(A6),A0
       move.b    #73,36(A0)
; ddir.Attr[3] = 'R';
       lea       -82(A6),A0
       move.b    #82,37(A0)
; ddir.Attr[4] = '>';
       lea       -82(A6),A0
       move.b    #62,38(A0)
       bra.s     carregaDirDef_49
carregaDirDef_48:
; }
; else {
; ddir.Attr[0] = ' ';
       lea       -82(A6),A0
       move.b    #32,34(A0)
; ddir.Attr[1] = ' ';
       lea       -82(A6),A0
       move.b    #32,35(A0)
; ddir.Attr[2] = ' ';
       lea       -82(A6),A0
       move.b    #32,36(A0)
; ddir.Attr[3] = ' ';
       lea       -82(A6),A0
       move.b    #32,37(A0)
; ddir.Attr[4] = ' ';
       lea       -82(A6),A0
       move.b    #32,38(A0)
carregaDirDef_49:
; }
; ddir.Attr[5] = '\0';
       lea       -82(A6),A0
       clr.b     39(A0)
; destIdx = *dFileCursor;
       move.l    A5,A0
       add.l     #_dFileCursor,A0
       move.l    (A0),A0
       move.b    (A0),-91(A6)
; pDestDir = &dfile->dir[destIdx];
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),D0
       move.b    -91(A6),D1
       and.l     #255,D1
       muls      #39,D1
       add.l     D1,D0
       move.l    D0,-42(A6)
; for (cc = 0; cc <= 8; cc++)
       clr.b     -161(A6)
carregaDirDef_50:
       move.b    -161(A6),D0
       cmp.b     #8,D0
       bhi.s     carregaDirDef_52
; pDestDir->Name[cc] = ddir.Name[cc];
       lea       -82(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       move.l    -42(A6),A1
       move.b    -161(A6),D1
       and.l     #255,D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.b    #1,-161(A6)
       bra       carregaDirDef_50
carregaDirDef_52:
; for (cc = 0; cc <= 3; cc++)
       clr.b     -161(A6)
carregaDirDef_53:
       move.b    -161(A6),D0
       cmp.b     #3,D0
       bhi.s     carregaDirDef_55
; pDestDir->Ext[cc] = ddir.Ext[cc];
       lea       -82(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.l    -42(A6),A1
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A1
       move.b    10(A0),10(A1)
       addq.b    #1,-161(A6)
       bra       carregaDirDef_53
carregaDirDef_55:
; for (cc = 0; cc <= 11; cc++)
       clr.b     -161(A6)
carregaDirDef_56:
       move.b    -161(A6),D0
       cmp.b     #11,D0
       bhi.s     carregaDirDef_58
; pDestDir->Modify[cc] = ddir.Modify[cc];
       lea       -82(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.l    -42(A6),A1
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A1
       move.b    14(A0),14(A1)
       addq.b    #1,-161(A6)
       bra       carregaDirDef_56
carregaDirDef_58:
; for (cc = 0; cc <= 5; cc++)
       clr.b     -161(A6)
carregaDirDef_59:
       move.b    -161(A6),D0
       cmp.b     #5,D0
       bhi.s     carregaDirDef_61
; pDestDir->Size[cc] = ddir.Size[cc];
       lea       -82(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.l    -42(A6),A1
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A1
       move.b    26(A0),26(A1)
       addq.b    #1,-161(A6)
       bra       carregaDirDef_59
carregaDirDef_61:
; for (cc = 0; cc <= 5; cc++)
       clr.b     -161(A6)
carregaDirDef_62:
       move.b    -161(A6),D0
       cmp.b     #5,D0
       bhi.s     carregaDirDef_64
; pDestDir->Attr[cc] = ddir.Attr[cc];
       lea       -82(A6),A0
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.l    -42(A6),A1
       move.b    -161(A6),D0
       and.l     #255,D0
       add.l     D0,A1
       move.b    34(A0),34(A1)
       addq.b    #1,-161(A6)
       bra       carregaDirDef_62
carregaDirDef_64:
; pDestDir->posy = ddir.posy;
       lea       -82(A6),A0
       move.l    -42(A6),A1
       move.b    38(A0),38(A1)
; *dFileCursor = *dFileCursor + 1;
       move.l    A5,A0
       add.l     #_dFileCursor,A0
       move.l    (A0),A0
       addq.b    #1,(A0)
carregaDirDef_10:
; }
; // Verifica se tem mais Arquivos
; for (ix = 0; ix <= 7; ix++) {
       clr.b     -163(A6)
carregaDirDef_65:
       move.b    -163(A6),D0
       cmp.b     #7,D0
       bhi       carregaDirDef_67
; vnomefile[ix] = vdirfiles.Name[ix];
       lea       -38(A6),A0
       move.b    -163(A6),D0
       and.l     #255,D0
       move.b    -163(A6),D1
       and.l     #255,D1
       lea       -138(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
; if (vnomefile[ix] == 0x20) {
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       move.b    0(A0,D0.L),D0
       cmp.b     #32,D0
       bne.s     carregaDirDef_68
; vnomefile[ix] = '\0';
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       clr.b     0(A0,D0.L)
; break;
       bra.s     carregaDirDef_67
carregaDirDef_68:
       addq.b    #1,-163(A6)
       bra       carregaDirDef_65
carregaDirDef_67:
; }
; }
; vnomefile[ix] = '\0';
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       clr.b     0(A0,D0.L)
; if (vdirfiles.Name[0] != '.') {
       lea       -38(A6),A0
       move.b    (A0),D0
       cmp.b     #46,D0
       beq       carregaDirDef_70
; vnomefile[ix] = '.';
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       move.b    #46,0(A0,D0.L)
; ix++;
       addq.b    #1,-163(A6)
; for (iy = 0; iy <= 2; iy++) {
       clr.b     -162(A6)
carregaDirDef_72:
       move.b    -162(A6),D0
       cmp.b     #2,D0
       bhi       carregaDirDef_74
; vnomefile[ix] = vdirfiles.Ext[iy];
       lea       -38(A6),A0
       move.b    -162(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A1
       move.b    8(A0),0(A1,D0.L)
; if (vnomefile[ix] == 0x20) {
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       move.b    0(A0,D0.L),D0
       cmp.b     #32,D0
       bne.s     carregaDirDef_75
; vnomefile[ix] = '\0';
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       clr.b     0(A0,D0.L)
; break;
       bra.s     carregaDirDef_74
carregaDirDef_75:
; }
; ix++;
       addq.b    #1,-163(A6)
       addq.b    #1,-162(A6)
       bra       carregaDirDef_72
carregaDirDef_74:
; }
; vnomefile[ix] = '\0';
       move.b    -163(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       clr.b     0(A0,D0.L)
carregaDirDef_70:
; }
; vlen = 0;
       clr.b     -92(A6)
; while (vnomefile[vlen] != '\0') {
carregaDirDef_77:
       move.b    -92(A6),D0
       and.l     #255,D0
       lea       -138(A6),A0
       move.b    0(A0,D0.L),D0
       beq.s     carregaDirDef_79
; vlen++;
       addq.b    #1,-92(A6)
; if (vlen > 12)
       move.b    -92(A6),D0
       cmp.b     #12,D0
       bls.s     carregaDirDef_80
; break;
       bra.s     carregaDirDef_79
carregaDirDef_80:
       bra       carregaDirDef_77
carregaDirDef_79:
; }
; if (fsFindInDir(vnomefile, TYPE_NEXT_ENTRY) >= ERRO_D_START)
       pea       9
       pea       -138(A6)
       move.l    8486740,A0
       jsr       (A0)
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     carregaDirDef_82
; break;
       bra.s     carregaDirDef_9
carregaDirDef_82:
       bra       carregaDirDef_7
carregaDirDef_9:
; }
; }
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
carregaDirDef_4:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------
; void listaDirDef(void)
; {
       xdef      _listaDirDef
_listaDirDef:
       link      A6,#-32
; unsigned short pposy, vretfs, dd, ww, total;
; unsigned char ee, cc, ix, cstring[16];
; linhastatus(1, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       pea       1
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; TrocaSpriteMouse(MOUSE_HOURGLASS);
       pea       2
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; for (dd = 0; dd <= 13; dd++)
       clr.w     -26(A6)
listaDirDef_1:
       move.w    -26(A6),D0
       cmp.w     #13,D0
       bhi.s     listaDirDef_3
; clinha[dd] = 0x00;
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       clr.b     0(A0,D0.L)
       addq.w    #1,-26(A6)
       bra       listaDirDef_1
listaDirDef_3:
; pposy = 34;
       move.w    #34,-30(A6)
; dd = *vpos;
       move.l    A5,A0
       add.l     #_vpos,A0
       move.l    (A0),A0
       move.w    (A0),-26(A6)
; total = *dFileCursor;
       move.l    A5,A0
       add.l     #_dFileCursor,A0
       move.l    (A0),A0
       move.b    (A0),D0
       and.w     #255,D0
       move.w    D0,-22(A6)
; if (total > 150)
       move.w    -22(A6),D0
       cmp.w     #150,D0
       bls.s     listaDirDef_4
; total = 150;
       move.w    #150,-22(A6)
listaDirDef_4:
; // Sem entradas carregadas: limpa area da listagem e sai.
; if (total == 0)
       move.w    -22(A6),D0
       bne       listaDirDef_6
; {
; FillRect(5,34,249,140,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       140
       pea       249
       pea       34
       pea       5
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; linhastatus(0, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
; return;
       bra       listaDirDef_8
listaDirDef_6:
; }
; if (dd >= total)
       move.w    -26(A6),D0
       cmp.w     -22(A6),D0
       blo.s     listaDirDef_9
; dd = (total - 1);
       move.w    -22(A6),D0
       subq.w    #1,D0
       move.w    D0,-26(A6)
listaDirDef_9:
; if (dd > 149)
       move.w    -26(A6),D0
       cmp.w     #149,D0
       bls.s     listaDirDef_11
; dd = 149;
       move.w    #149,-26(A6)
listaDirDef_11:
; ee = 14;
       move.b    #14,-19(A6)
; cc = 0;
       clr.b     -18(A6)
; while(1)
listaDirDef_13:
; {
; if (dd > 149 || dd >= total || cc >= 14)
       move.w    -26(A6),D0
       cmp.w     #149,D0
       bhi.s     listaDirDef_18
       move.w    -26(A6),D0
       cmp.w     -22(A6),D0
       bhs.s     listaDirDef_18
       move.b    -18(A6),D0
       cmp.b     #14,D0
       blo.s     listaDirDef_16
listaDirDef_18:
; break;
       bra       listaDirDef_15
listaDirDef_16:
; for (ix = 0; ix < 8; ix++)
       clr.b     -17(A6)
listaDirDef_19:
       move.b    -17(A6),D0
       cmp.b     #8,D0
       bhs       listaDirDef_21
; {
; if (dfile->dir[dd].Name[ix] == 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    0(A0,D0.L),D0
       bne.s     listaDirDef_22
; cstring[ix] = 0x20;
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    #32,-16(A6,D0.L)
       bra.s     listaDirDef_23
listaDirDef_22:
; else
; cstring[ix] = dfile->dir[dd].Name[ix];
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    -17(A6),D1
       and.l     #255,D1
       move.b    0(A0,D0.L),-16(A6,D1.L)
listaDirDef_23:
       addq.b    #1,-17(A6)
       bra       listaDirDef_19
listaDirDef_21:
; }
; cstring[8] = '\0';
       clr.b     -16+8(A6)
; // Nome
; writesxy(16,pposy,6,cstring,*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -16(A6)
       pea       6
       move.w    -30(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       16
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; for (ix = 0; ix < 3; ix++)
       clr.b     -17(A6)
listaDirDef_24:
       move.b    -17(A6),D0
       cmp.b     #3,D0
       bhs       listaDirDef_26
; {
; if (dfile->dir[dd].Ext[ix] == 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    10(A0),D0
       bne.s     listaDirDef_27
; cstring[ix] = 0x20;
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    #32,-16(A6,D0.L)
       bra.s     listaDirDef_28
listaDirDef_27:
; else
; cstring[ix] = dfile->dir[dd].Ext[ix];
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    10(A0),-16(A6,D0.L)
listaDirDef_28:
       addq.b    #1,-17(A6)
       bra       listaDirDef_24
listaDirDef_26:
; }
; cstring[3] = '\0';
       clr.b     -16+3(A6)
; // Ext
; writesxy(66,pposy,6,cstring,*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -16(A6)
       pea       6
       move.w    -30(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       66
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; // Modif
; for (ix = 0; ix < 11; ix++)
       clr.b     -17(A6)
listaDirDef_29:
       move.b    -17(A6),D0
       cmp.b     #11,D0
       bhs       listaDirDef_31
; {
; if (dfile->dir[dd].Modify[ix] == 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    14(A0),D0
       bne.s     listaDirDef_32
; cstring[ix] = 0x20;
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    #32,-16(A6,D0.L)
       bra.s     listaDirDef_33
listaDirDef_32:
; else
; cstring[ix] = dfile->dir[dd].Modify[ix];
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    14(A0),-16(A6,D0.L)
listaDirDef_33:
       addq.b    #1,-17(A6)
       bra       listaDirDef_29
listaDirDef_31:
; }
; cstring[11] = '\0';
       clr.b     -16+11(A6)
; writesxy(90,pposy,6,cstring,*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -16(A6)
       pea       6
       move.w    -30(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       90
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; // Tamanho
; for (ix = 0; ix < 5; ix++)
       clr.b     -17(A6)
listaDirDef_34:
       move.b    -17(A6),D0
       cmp.b     #5,D0
       bhs       listaDirDef_36
; {
; if (dfile->dir[dd].Size[ix] == 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    26(A0),D0
       bne.s     listaDirDef_37
; cstring[ix] = 0x20;
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    #32,-16(A6,D0.L)
       bra.s     listaDirDef_38
listaDirDef_37:
; else
; cstring[ix] = dfile->dir[dd].Size[ix];
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    26(A0),-16(A6,D0.L)
listaDirDef_38:
       addq.b    #1,-17(A6)
       bra       listaDirDef_34
listaDirDef_36:
; }
; cstring[5] = '\0';
       clr.b     -16+5(A6)
; writesxy(165,pposy,6,cstring,*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -16(A6)
       pea       6
       move.w    -30(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       165
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; // Atrib
; for (ix = 0; ix < 5; ix++)
       clr.b     -17(A6)
listaDirDef_39:
       move.b    -17(A6),D0
       cmp.b     #5,D0
       bhs       listaDirDef_41
; {
; if (dfile->dir[dd].Attr[ix] == 0x00)
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    34(A0),D0
       bne.s     listaDirDef_42
; cstring[ix] = 0x20;
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    #32,-16(A6,D0.L)
       bra.s     listaDirDef_43
listaDirDef_42:
; else
; cstring[ix] = dfile->dir[dd].Attr[ix];
       move.l    A5,A0
       add.l     #_dfile,A0
       move.l    (A0),A0
       move.w    -26(A6),D0
       and.l     #65535,D0
       muls      #39,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       add.l     D0,A0
       move.b    -17(A6),D0
       and.l     #255,D0
       move.b    34(A0),-16(A6,D0.L)
listaDirDef_43:
       addq.b    #1,-17(A6)
       bra       listaDirDef_39
listaDirDef_41:
; }
; cstring[5] = '\0';
       clr.b     -16+5(A6)
; writesxy(200,pposy,6,cstring,*vcorfg,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,A0
       add.l     #_vcorfg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.w     #255,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -16(A6)
       pea       6
       move.w    -30(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       200
       move.l    8410486,A0
       jsr       (A0)
       add.w     #24,A7
; clinha[cc] = pposy;
       move.w    -30(A6),D0
       move.l    A5,A0
       add.l     #_clinha,A0
       move.l    (A0),A0
       move.b    -18(A6),D1
       and.l     #255,D1
       move.b    D0,0(A0,D1.L)
; pposy += 10;
       add.w     #10,-30(A6)
; dd++;
       addq.w    #1,-26(A6)
; cc++;
       addq.b    #1,-18(A6)
; ee--;
       subq.b    #1,-19(A6)
; if (dd >= total)
       move.w    -26(A6),D0
       cmp.w     -22(A6),D0
       blo.s     listaDirDef_44
; break;
       bra.s     listaDirDef_15
listaDirDef_44:
; if (ee == 0)
       move.b    -19(A6),D0
       bne.s     listaDirDef_46
; break;
       bra.s     listaDirDef_15
listaDirDef_46:
       bra       listaDirDef_13
listaDirDef_15:
; }
; if (ee > 0) {
       move.b    -19(A6),D0
       cmp.b     #0,D0
       bls       listaDirDef_48
; dd = 14 - ee;
       moveq     #14,D0
       ext.w     D0
       move.b    -19(A6),D1
       and.w     #255,D1
       sub.w     D1,D0
       move.w    D0,-26(A6)
; dd = dd * 10;
       move.w    -26(A6),D0
       mulu.w    #10,D0
       move.w    D0,-26(A6)
; dd = dd + 34;
       add.w     #34,-26(A6)
; ww = ee * 10;
       move.b    -19(A6),D0
       and.w     #255,D0
       mulu.w    #10,D0
       move.w    D0,-24(A6)
; FillRect(5,dd,249,ww,*vcorbg);
       move.l    A5,A0
       add.l     #_vcorbg,A0
       move.l    (A0),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    -24(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       249
       move.w    -26(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       5
       move.l    8410514,A0
       jsr       (A0)
       add.w     #20,A7
listaDirDef_48:
; }
; TrocaSpriteMouse(MOUSE_POINTER);
       pea       1
       move.l    8410570,A0
       jsr       (A0)
       addq.w    #4,A7
; linhastatus(0, "\0");
       move.l    A5,A0
       add.l     #@files_20,A0
       move.l    (A0),-(A7)
       clr.l     -(A7)
       move.l    A5,A0
       add.l     #_linhastatus,A0
       move.l    (A0),A0
       jsr       (A0)
       addq.w    #8,A7
listaDirDef_8:
       unlk      A6
       rts
; }
; //--------------------------------------------------------------------------
; void SearchFileDef(void)
; {
       xdef      _SearchFileDef
_SearchFileDef:
       rts
; }
       section   const
@files_1:
       dc.b      78,97,109,101,0
@files_2:
       dc.b      69,120,116,0
@files_3:
       dc.b      77,111,100,105,102,121,0
@files_4:
       dc.b      83,105,122,101,0
@files_5:
       dc.b      65,116,114,105,98,0
@files_6:
       dc.b      68,101,108,101,116,101,0
@files_7:
       dc.b      82,101,110,97,109,101,0
@files_8:
       dc.b      67,111,112,121,0
@files_9:
       dc.b      69,120,101,99,117,116,101,0
@files_10:
       dc.b      79,112,101,110,0
@files_11:
       dc.b      78,101,119,0
@files_12:
       dc.b      82,101,109,111,118,101,0
@files_13:
       dc.b      32,0
@files_14:
       dc.b      67,108,111,115,101,0
@files_15:
       dc.b      67,111,110,102,105,114,109,10,68,101,108,101
       dc.b      116,101,32,70,105,108,101,32,63,0
@files_16:
       dc.b      67,111,110,102,105,114,109,10,82,101,109,111
       dc.b      118,101,32,68,105,114,101,99,116,111,114,121
       dc.b      32,63,0
@files_17:
       dc.b      46,0
@files_18:
       dc.b      68,101,108,101,116,101,32,70,105,108,101,32
       dc.b      69,114,114,111,114,46,0
@files_19:
       dc.b      82,101,109,111,118,101,32,68,105,114,101,99
       dc.b      116,111,114,121,32,69,114,114,111,114,46,0
@files_20:
       dc.b      0
@files_21:
       dc.b      82,101,110,97,109,101,32,70,105,108,101,0
@files_22:
       dc.b      32,32,32,78,101,119,32,78,97,109,101,58,0
@files_23:
       dc.b      67,111,112,121,32,70,105,108,101,0
@files_24:
       dc.b      68,101,115,116,105,110,97,116,105,111,110,58
       dc.b      0
@files_25:
       dc.b      67,114,101,97,116,101,32,68,105,114,101,99,116
       dc.b      111,114,121,0
@files_26:
       dc.b      32,32,32,68,105,114,32,78,97,109,101,58,0
@files_27:
       dc.b      79,75,0
@files_28:
       dc.b      67,65,78,67,69,76,0
@files_29:
       dc.b      67,111,110,102,105,114,109,10,82,101,110,97
       dc.b      109,101,32,70,105,108,101,32,63,10,0
@files_30:
       dc.b      67,111,110,102,105,114,109,10,67,111,112,121
       dc.b      32,70,105,108,101,32,63,10,0
@files_31:
       dc.b      67,111,110,102,105,114,109,10,67,114,101,97
       dc.b      116,101,32,68,105,114,101,99,116,111,114,121
       dc.b      32,63,10,0
@files_32:
       dc.b      67,80,32,0
@files_33:
       dc.b      82,101,110,97,109,101,32,70,105,108,101,32,69
       dc.b      114,114,111,114,46,0
@files_34:
       dc.b      67,111,112,121,32,70,105,108,101,32,69,114,114
       dc.b      111,114,46,0
@files_35:
       dc.b      67,114,101,97,116,101,32,68,105,114,101,99,116
       dc.b      111,114,121,32,69,114,114,111,114,46,0
@files_36:
       dc.b      67,104,97,110,103,101,32,68,105,114,101,99,116
       dc.b      111,114,121,32,69,114,114,111,114,46,0
@files_37:
       dc.b      119,97,105,116,46,46,46,0
@files_38:
       dc.b      112,114,111,99,101,115,115,105,110,103,46,46
       dc.b      46,0
@files_39:
       dc.b      102,105,108,101,32,110,111,116,32,102,111,117
       dc.b      110,100,46,46,46,0
@files_40:
       dc.b      68,101,108,101,116,105,110,103,32,102,105,108
       dc.b      101,46,46,46,0
@files_41:
       dc.b      82,101,110,97,109,105,110,103,32,102,105,108
       dc.b      101,46,46,46,0
@files_42:
       dc.b      68,101,108,101,116,105,110,103,32,68,105,114
       dc.b      101,99,116,111,114,121,46,46,46,0
@files_43:
       dc.b      69,120,105,116,105,110,103,46,46,46,0
@files_44:
       dc.b      67,111,112,121,105,110,103,32,70,105,108,101
       dc.b      46,46,46,0
@files_45:
       dc.b      67,114,101,97,116,105,110,103,32,68,105,114
       dc.b      101,99,116,111,114,121,46,46,46,0
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
       xdef      _dfile
_dfile:
       dc.l      1
       xdef      _vMemTotal
_vMemTotal:
       dc.l      9436928
       xdef      _clinha
_clinha:
       dc.l      1
       xdef      _vpos
_vpos:
       dc.l      1
       xdef      _vposold
_vposold:
       dc.l      1
       xdef      _dFileCursor
_dFileCursor:
       dc.l      1
       xdef      _vcorfg
_vcorfg:
       dc.l      1
       xdef      _vcorbg
_vcorbg:
       dc.l      1
       xdef      _linhastatus
_linhastatus:
       dc.l      1
       xdef      _SearchFile
_SearchFile:
       dc.l      1
       xdef      _carregaDir
_carregaDir:
       dc.l      1
       xdef      _listaDir
_listaDir:
       dc.l      1
       xdef      _mystrcpy
_mystrcpy:
       dc.l      1
       xdef      _mystrcat
_mystrcat:
       dc.l      1
       xdef      _mymemset
_mymemset:
       dc.l      1
       xdef      _mytoupper
_mytoupper:
       dc.l      1
       xdef      _myitoa
_myitoa:
       dc.l      1
       xdef      _myltoa
_myltoa:
       dc.l      1
       xdef      _myvRetAlloc
_myvRetAlloc:
       dc.l      1
       xref      _strcpy
       xref      _itoa
       xref      _ltoa
       xref      _MMSJOS_FUNC_RELOC
       xref      _memset
       xref      _strcat
       xref      _toupper
