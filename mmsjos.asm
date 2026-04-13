; D:\PROJETOS\MMSJ320\MMSJOS.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; /********************************************************************************
; *    Programa    : mmsjos.c
; *    Objetivo    : MMSJOS - Versao vintage compatible
; *    Criado em   : 11/03/2024
; *    Programador : Moacir Jr.
; *--------------------------------------------------------------------------------
; * Data        Versao  Responsavel  Motivo
; * 18/12/2024  0.1     Moacir Jr.   Criação Versão Beta
; *                                  Adaptar para FAT32 com uno e SD CARD
; * 25/12/2024  0.2     Moacir Jr.   Carregar Dados da Serial e Gravar no Arquivo
; * 04/01/2025  0.3     Moacir Jr.   Receber pasta no nome do arquivo "<pasta>/<file>"
; * 08/01/2025  0.4     Moacir Jr.   Implementar wildcards "*?" para LS, RM e CP
; * 18/01/2025  0.5     Moacir Jr.   Adaptar uC/OS-II - RTOS
; * 13/04/2026  1.0a02  Moacir Jr.   Ajustes no malloc/realloc/free e inclusao do xmodem 1k crc
; ********************************************************************************/
; #include <ucos_ii.h>
; #include <ctype.h>
; #include <string.h>
; #include <malloc.h>
; #include <stdlib.h>
; #include "mmsj320api.h"
; #include "mmsj320vdp.h"
; #include "mmsj320mfp.h"
; #include "mmsjos.h"
; #include "mgui.h"
; #include "monitor.h"
; #include "monitorapi.h"
; unsigned long runOSMemory;
; FAT32_DIR vdir;
; DISK  vdisk;
; unsigned long vclusterdir;
; unsigned char vbuf[128]; // Buffer Linha Digitavel, maximo de 128 caracteres -
; unsigned char  gDataBuffer[512]; // The global data sector buffer to 0x00609FF7
; unsigned short  verroSo;
; unsigned char  vdiratu[128]; // Buffer de pasta atual 128 bytes
; unsigned short  vdiratuidx; // Pointer Buffer de pasta atual 128 bytes (SO FUNCIONA NA RAM)
; unsigned char verro;
; RET_PATH vretpath;
; RET_PATH vretpath2;
; MEM_ALOC vMemAloc;
; //--- FAT16 Functions
; unsigned long fsInit(void);
; void fsVer(void);
; void printDiskError(unsigned char pError);
; unsigned char fsMountDisk(void);
; unsigned long fsOsCommand(unsigned char * linhaParametro);
; unsigned char fsFormat (long int serialNumber, char * volumeID);
; void fsSetClusterDir (unsigned long vclusdiratu);
; unsigned long fsGetClusterDir (void);
; unsigned char fsSectorWrite(unsigned long vsector, unsigned char* vbuffer, unsigned char vtipo);
; unsigned char fsSectorRead(unsigned long vsector, unsigned char* vbuffer);
; int fsRecSerial(unsigned char* pByte, unsigned char pTimeOut);
; int fsSendSerial(unsigned char pByte);
; int fsSendByte(unsigned char vByte, unsigned char pType);
; unsigned char fsRecByte(unsigned char pType);
; int fsSendLongSerial(unsigned char *msg);
; void fsConvClusterToTHS(unsigned short cluster, unsigned char* vtrack, unsigned char* vside, unsigned char* vsector);
; void fsReadDir(unsigned short ix, unsigned short vdata);
; // Funcoes de Manipulacao de Arquivos
; unsigned char fsCreateFile(char * vfilename);
; unsigned char fsOpenFile(char * vfilename);
; unsigned char fsCloseFile(char * vfilename, unsigned char vupdated);
; unsigned long fsInfoFile(char * vfilename, unsigned char vtype);
; unsigned char fsRWFile(unsigned long vclusterini, unsigned long voffset, unsigned char *buffer, unsigned char vtype);
; unsigned short fsReadFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer);
; unsigned char fsWriteFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer);
; unsigned char fsDelFile(char * vfilename);
; unsigned char fsRenameFile(char * vfilename, char * vnewname);
; void runFromOsCmd(void);
; unsigned long loadFile(unsigned char *parquivo, unsigned short* xaddress);
; void catFile(unsigned char *parquivo);
; unsigned char fsLoadSerialToFile(char * vfilename, char * vPosMem);
; unsigned char fsLoadSerialToRun(char * vfilename);
; unsigned char fsFindDirPath(char * vpath, char vtype);
; void fsGetDirAtuData(FAT32_DIR *pDir);
; unsigned long fsMalloc(unsigned long vMemSize);
; void fsFree(unsigned long vAddress);
; void runFromMGUI(unsigned long vEnderExec);
; static unsigned char fsCheckDirEmpty(unsigned long vdircluster);
; // Funcoes de Manipulacao de Diretorios
; unsigned char fsMakeDir(char * vdirname);
; unsigned char fsChangeDir(char * vdirname);
; unsigned char fsRemoveDir(char * vdirname);
; unsigned char fsPwdDir(unsigned char *vdirpath);
; // Funcoes de Apoio
; unsigned short fsLoadFat(unsigned short vclusteratual);
; unsigned long fsFindInDir(char * vname, unsigned char vtype);
; unsigned char fsUpdateDir(void);
; unsigned long fsFindNextCluster(unsigned long vclusteratual, unsigned char vtype);
; unsigned long fsFindClusterFree(unsigned char vtype);
; unsigned int bcd2dec(unsigned int bcd);
; int getDateTimeAtu(void);
; unsigned short datetimetodir(unsigned char hr_day, unsigned char min_month, unsigned char sec_year, unsigned char vtype);
; unsigned long pow(int val, int pot);
; int hex2int(char ch);
; unsigned long hexToLong(char *pHex);
; void strncpy2( char* _dst, const char* _src, int _n );
; int isValidFilename(char *filename) ;
; unsigned char matches_wildcard(const char *pattern, const char *filename);
; unsigned char contains_wildcards(const char *pattern);
; #ifdef __SO_ST_MFP__
; void fsSetMfp(unsigned int Config, unsigned char Value, unsigned char TypeSet = 1);
; unsigned int fsGetMfp(unsigned int Config);
; #endif
; const unsigned char strValidChars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^&'@{}[],$=!-#()%.+~_";
; const unsigned char vmesc[12][3] = {{'J','a','n'},{'F','e','b'},{'M','a','r'},
; {'A','p','r'},{'M','a','y'},{'J','u','n'},
; {'J','u','l'},{'A','u','g'},{'S','e','p'},
; {'O','c','t'},{'N','o','v'},{'D','e','c'}};
; // Funcoes de Alocacao de Memoria
; void memInit(void);
; HEADER *_allocp;
; #define versionMMSJOS "1.0a02"
; #define STACKSIZE  1024
; #define STACKSIZEMGUI  2048
; OS_STK StkInput[STACKSIZE];
; OS_STK StkMgui[STACKSIZEMGUI];
; OS_STK StkTask01[STACKSIZEMGUI];
; OS_STK StkTask02[STACKSIZEMGUI];
; OS_STK StkTask03[STACKSIZEMGUI];
; OS_STK StkTask04[STACKSIZEMGUI];
; OS_STK StkTask05[STACKSIZEMGUI];
; OS_STK StkTask06[STACKSIZEMGUI];
; OS_EVENT *shared_sem;
; void inputTask(void *pdata);
; void mguiTask(void *pdata);
; void prog01Task(void *pdata);   // Prio: 25
; void prog02Task(void *pdata);   // Prio: 26
; void prog03Task(void *pdata);   // Prio: 27
; void prog04Task(void *pdata);   // Prio: 28
; void prog05Task(void *pdata);   // Prio: 29
; void prog06Task(void *pdata);   // Prio: 30
; //-----------------------------------------------------------------------------
; // FAT16 Functions
; //-----------------------------------------------------------------------------
; //-----------------------------------------------------------------------------
; unsigned long fsInit(void)
; {
       section   code
       xdef      _fsInit
_fsInit:
       link      A6,#-4
; char verr = 0;
       clr.b     -1(A6)
; if (fsMountDisk())
       jsr       _fsMountDisk
       tst.b     D0
       beq.s     fsInit_1
; {
; printDiskError(ERRO_B_OPEN_DISK);
       pea       227
       jsr       _printDiskError
       addq.w    #4,A7
; return ERRO_B_OPEN_DISK;
       move.l    #227,D0
       bra.s     fsInit_3
fsInit_1:
; }
; vdiratuidx = 1;
       move.w    #1,_vdiratuidx.L
; vdiratu[0] = '/';
       move.b    #47,_vdiratu.L
; vdiratu[vdiratuidx] = 0x00;
       move.w    _vdiratuidx.L,D0
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       clr.b     0(A0,D0.L)
; return 0;
       clr.l     D0
fsInit_3:
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void fsVer(void)
; {
       xdef      _fsVer
_fsVer:
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("MMSJ-OS v"versionMMSJOS);
       pea       @mmsjos_2.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Powered by uC/OS-II v2.91\0");
       pea       @mmsjos_3.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       rts
; }
; //-----------------------------------------------------------------------------
; void printDiskError(unsigned char pError)
; {
       xdef      _printDiskError
_printDiskError:
       link      A6,#-12
; unsigned char sqtdtam[10];
; printText("Error: ");
       pea       @mmsjos_4.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; switch( pError )
       move.b    11(A6),D0
       and.l     #255,D0
       cmp.l     #233,D0
       beq       printDiskError_12
       bhi       printDiskError_22
       cmp.l     #228,D0
       beq       printDiskError_7
       bhi.s     printDiskError_23
       cmp.l     #226,D0
       beq       printDiskError_5
       bhi.s     printDiskError_24
       cmp.l     #225,D0
       beq       printDiskError_4
       bhi       printDiskError_1
       cmp.l     #224,D0
       beq       printDiskError_3
       bra       printDiskError_1
printDiskError_24:
       cmp.l     #227,D0
       beq       printDiskError_6
       bra       printDiskError_1
printDiskError_23:
       cmp.l     #231,D0
       beq       printDiskError_10
       bhi.s     printDiskError_25
       cmp.l     #230,D0
       beq       printDiskError_9
       bhi       printDiskError_1
       cmp.l     #229,D0
       beq       printDiskError_8
       bra       printDiskError_1
printDiskError_25:
       cmp.l     #232,D0
       beq       printDiskError_11
       bra       printDiskError_1
printDiskError_22:
       cmp.l     #238,D0
       beq       printDiskError_17
       bhi.s     printDiskError_26
       cmp.l     #236,D0
       beq       printDiskError_15
       bhi.s     printDiskError_27
       cmp.l     #235,D0
       beq       printDiskError_14
       bhi       printDiskError_1
       cmp.l     #234,D0
       beq       printDiskError_13
       bra       printDiskError_1
printDiskError_27:
       cmp.l     #237,D0
       beq       printDiskError_16
       bra       printDiskError_1
printDiskError_26:
       cmp.l     #240,D0
       beq       printDiskError_19
       bhi.s     printDiskError_28
       cmp.l     #239,D0
       beq       printDiskError_18
       bra       printDiskError_1
printDiskError_28:
       cmp.l     #255,D0
       beq       printDiskError_20
       bra       printDiskError_1
printDiskError_3:
; {
; case ERRO_B_FILE_NOT_FOUND    : printText("File not found"); break;
       pea       @mmsjos_5.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_4:
; case ERRO_B_READ_DISK         : printText("Reading disk"); break;
       pea       @mmsjos_6.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_5:
; case ERRO_B_WRITE_DISK        : printText("Writing disk"); break;
       pea       @mmsjos_7.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_6:
; case ERRO_B_OPEN_DISK         : printText("Opening disk"); break;
       pea       @mmsjos_8.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_7:
; case ERRO_B_INVALID_NAME      : printText("Invalid Folder or File Name"); break;
       pea       @mmsjos_9.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_8:
; case ERRO_B_DIR_NOT_FOUND     : printText("Directory not found"); break;
       pea       @mmsjos_10.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_9:
; case ERRO_B_CREATE_FILE       : printText("Creating file"); break;
       pea       @mmsjos_11.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_10:
; case ERRO_B_APAGAR_ARQUIVO    : printText("Deleting file"); break;
       pea       @mmsjos_12.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_11:
; case ERRO_B_FILE_FOUND        : printText("File already exist"); break;
       pea       @mmsjos_13.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_12:
; case ERRO_B_UPDATE_DIR        : printText("Updating directory"); break;
       pea       @mmsjos_14.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_13:
; case ERRO_B_OFFSET_READ       : printText("Offset read"); break;
       pea       @mmsjos_15.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_14:
; case ERRO_B_DISK_FULL         : printText("Disk full"); break;
       pea       @mmsjos_16.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_15:
; case ERRO_B_READ_FILE         : printText("Reading file"); break;
       pea       @mmsjos_17.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_16:
; case ERRO_B_WRITE_FILE        : printText("Writing file"); break;
       pea       @mmsjos_18.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_17:
; case ERRO_B_DIR_FOUND         : printText("Directory already exist"); break;
       pea       @mmsjos_19.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_18:
; case ERRO_B_CREATE_DIR        : printText("Creating directory"); break;
       pea       @mmsjos_20.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_19:
; case ERRO_B_DIR_NOT_EMPTY     : printText("Directory not empty"); break;
       pea       @mmsjos_21.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       printDiskError_2
printDiskError_20:
; case ERRO_B_NOT_FOUND         : printText("Not found"); break;
       pea       @mmsjos_22.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra.s     printDiskError_2
printDiskError_1:
; default                       :
; itoa(pError, sqtdtam, 10);
       pea       10
       pea       -10(A6)
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText(sqtdtam);
       pea       -10(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(" - Unknown Code");
       pea       @mmsjos_23.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; break;
printDiskError_2:
; }
; printText("!\r\n\0");
       pea       @mmsjos_24.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Main Function
; //-----------------------------------------------------------------------------
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-8
; unsigned char vRetInput;
; int vRetProcCmd;
; clearScr();
       move.l    1054,A0
       jsr       (A0)
; printText("MMSJ-OS v"versionMMSJOS);
       pea       @mmsjos_2.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Powered by uC/OS-II v2.91\r\n\0");
       pea       @mmsjos_25.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("Utility (c) 2014-2026\r\n\0");
       pea       @mmsjos_26.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fsInit();
       jsr       _fsInit
; memInit();
       jsr       _memInit
; fsChangeDir("/");
       pea       @mmsjos_27.L
       jsr       _fsChangeDir
       addq.w    #4,A7
; printText("Ok\r\n\0");
       pea       @mmsjos_28.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("#>");
       pea       @mmsjos_29.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; showCursor();
       move.l    1082,A0
       jsr       (A0)
; *(vmfp + Reg_IERA) |= 0x01; // Timer B 10ms - Tick OS
       move.l    _vmfp.L,A0
       move.w    _Reg_IERA.L,D0
       and.l     #65535,D0
       or.b      #1,0(A0,D0.L)
; *(vmfp + Reg_IMRA) |= 0x01; // Timer B 10ms - Tick OS
       move.l    _vmfp.L,A0
       move.w    _Reg_IMRA.L,D0
       and.l     #65535,D0
       or.b      #1,0(A0,D0.L)
; // Cria duas Tasks
; OSInit();
       jsr       _OSInit
; shared_sem = OSSemCreate(0);
       clr.l     -(A7)
       jsr       _OSSemCreate
       addq.w    #4,A7
       move.l    D0,_shared_sem.L
; OSTaskCreate(inputTask, OS_NULL, &StkInput[STACKSIZE], 10);
       pea       10
       lea       _StkInput.L,A0
       add.w     #2048,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _inputTask.L
       jsr       _OSTaskCreate
       add.w     #16,A7
; OSStart();
       jsr       _OSStart
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void inputTask(void *pdata)
; {
       xdef      _inputTask
_inputTask:
       link      A6,#-12
       movem.l   D2/D3/D4/A2,-(A7)
       lea       _vbuf.L,A2
; unsigned char vtec, vtecant = 0;
       clr.b     -9(A6)
; unsigned long vRetProcCmd;
; int countCursor = 0;
       clr.l     -8(A6)
; unsigned char vbufptr = 0;
       clr.b     D3
; unsigned int error_code = OS_ERR_NONE;
       clr.l     -4(A6)
; while (1)
inputTask_1:
; {
; OSSemPend(&shared_sem, 0, &error_code);
       pea       -4(A6)
       clr.l     -(A7)
       pea       _shared_sem.L
       jsr       _OSSemPend
       add.w     #12,A7
; vtec = readChar();
       move.l    1074,A0
       jsr       (A0)
       move.b    D0,D2
; if (vtec)
       tst.b     D2
       beq       inputTask_4
; {
; hideCursor();
       move.l    1078,A0
       jsr       (A0)
; if (vtec >= 0x20 && vtec != 0x7F)   // Caracter Printavel menos o DeLete
       cmp.b     #32,D2
       blo       inputTask_6
       cmp.b     #127,D2
       beq       inputTask_6
; {
; // Digitcao Normal
; if (vbufptr > 127)
       cmp.b     #127,D3
       bls.s     inputTask_8
; {
; vbufptr--;
       subq.b    #1,D3
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputTask_8:
; }
; printChar(vtec, 1);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; vbuf[vbufptr++] = vtec;
       move.b    D3,D0
       addq.b    #1,D3
       and.l     #255,D0
       move.b    D2,0(A2,D0.L)
; vbuf[vbufptr] = '\0';
       and.l     #255,D3
       clr.b     0(A2,D3.L)
       bra       inputTask_14
inputTask_6:
; }
; else if (vtec == 0x08)  // Backspace
       cmp.b     #8,D2
       bne.s     inputTask_10
; {
; if (vbufptr > 0)
       cmp.b     #0,D3
       bls.s     inputTask_12
; {
; vbuf[vbufptr] = 0x00;
       and.l     #255,D3
       clr.b     0(A2,D3.L)
; vbufptr--;
       subq.b    #1,D3
; printChar(0x08, 1);
       pea       1
       pea       8
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputTask_12:
       bra       inputTask_14
inputTask_10:
; }
; }
; else if (vtec == 0x0D || vtec == 0x0A)
       cmp.b     #13,D2
       beq.s     inputTask_16
       cmp.b     #10,D2
       bne       inputTask_14
inputTask_16:
; {
; vRetProcCmd = 1;
       moveq     #1,D4
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vRetProcCmd = fsOsCommand("\0");
       pea       @mmsjos_30.L
       jsr       _fsOsCommand
       addq.w    #4,A7
       move.l    D0,D4
; vbuf[0] = '\0';
       clr.b     (A2)
; vbufptr = 0x00;
       clr.b     D3
; if (vRetProcCmd)
       tst.l     D4
       beq.s     inputTask_17
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
inputTask_17:
; printChar('#>', 1);
       pea       1
       pea       62
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
inputTask_14:
; }
; showCursor();
       move.l    1082,A0
       jsr       (A0)
inputTask_4:
; }
; vtecant = vtec;
       move.b    D2,-9(A6)
; OSSemPost(&shared_sem);
       pea       _shared_sem.L
       jsr       _OSSemPost
       addq.w    #4,A7
; OSTimeDlyHMSM(0, 0, 0, 15);
       pea       15
       clr.l     -(A7)
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _OSTimeDlyHMSM
       add.w     #16,A7
       bra       inputTask_1
; }
; }
; //-----------------------------------------------------------------------------
; void mguiTask(void *pData)
; {
       xdef      _mguiTask
_mguiTask:
       link      A6,#0
; while(1)
; {
; startMGI();
       jsr       _startMGI
; break;
; }
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void prog01Task(void *pdata)
; {
       xdef      _prog01Task
_prog01Task:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned long vAddrExec = (unsigned long*)pdata;
       move.l    8(A6),D2
; runOSMemory = vAddrExec;
       move.l    D2,_runOSMemory.L
; while(1)
; {
; runFromOsCmd();
       jsr       _runFromOsCmd
; break;
; }
; free(vAddrExec);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void prog02Task(void *pdata)
; {
       xdef      _prog02Task
_prog02Task:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned long vAddrExec = (unsigned long*)pdata;
       move.l    8(A6),D2
; runOSMemory = vAddrExec;
       move.l    D2,_runOSMemory.L
; while(1)
; {
; runFromOsCmd();
       jsr       _runFromOsCmd
; break;
; }
; free(vAddrExec);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void prog03Task(void *pdata)
; {
       xdef      _prog03Task
_prog03Task:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned long vAddrExec = (unsigned long*)pdata;
       move.l    8(A6),D2
; runOSMemory = vAddrExec;
       move.l    D2,_runOSMemory.L
; while(1)
; {
; runFromOsCmd();
       jsr       _runFromOsCmd
; break;
; }
; free(vAddrExec);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void prog04Task(void *pdata)
; {
       xdef      _prog04Task
_prog04Task:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned long vAddrExec = (unsigned long*)pdata;
       move.l    8(A6),D2
; runOSMemory = vAddrExec;
       move.l    D2,_runOSMemory.L
; while(1)
; {
; runFromOsCmd();
       jsr       _runFromOsCmd
; break;
; }
; free(vAddrExec);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void prog05Task(void *pdata)
; {
       xdef      _prog05Task
_prog05Task:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned long vAddrExec = (unsigned long*)pdata;
       move.l    8(A6),D2
; runOSMemory = vAddrExec;
       move.l    D2,_runOSMemory.L
; while(1)
; {
; runFromOsCmd();
       jsr       _runFromOsCmd
; break;
; }
; free(vAddrExec);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void prog06Task(void *pdata)
; {
       xdef      _prog06Task
_prog06Task:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned long vAddrExec = (unsigned long*)pdata;
       move.l    8(A6),D2
; runOSMemory = vAddrExec;
       move.l    D2,_runOSMemory.L
; while(1)
; {
; runFromOsCmd();
       jsr       _runFromOsCmd
; break;
; }
; free(vAddrExec);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
; OSTaskDel(OS_PRIO_SELF);
       pea       255
       jsr       _OSTaskDel
       addq.w    #4,A7
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned long fsOsCommand(unsigned char * linhaParametro)
; {
       xdef      _fsOsCommand
_fsOsCommand:
       link      A6,#-596
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -596(A6),A2
       lea       -462(A6),A3
       lea       -266(A6),A4
       lea       _strcmp.L,A5
       move.l    8(A6),D7
; unsigned char linhacomando[64], linhaarg[64], vloop;
; unsigned char *blin = vbuf, vbuffer[128], vlinha[40];
       lea       _vbuf.L,A0
       move.l    A0,-466(A6)
; unsigned short varg = 0;
       clr.w     D3
; unsigned short ix, iy, iz, ikk, isrc;
; unsigned short vbytepic = 0, vrecfim;
       clr.w     -288(A6)
; unsigned short vReadSize;
; unsigned char *vdirptr = (unsigned char*)&vdir;
       lea       _vdir.L,A0
       move.l    A0,-282(A6)
; unsigned char sqtdtam[10], cuntam, vparam[32], vparam2[32], vparam3[32], vparam4[13], vpicret;
; unsigned long vretfat, vclusterdiratu, vclusterdirsrc, vclusterdirdst, vsizefilemalloc;
; unsigned char *vEnderExec;
; long vqtdtam;
; unsigned char izzzz, logpath = 0, logcopyok;
       clr.b     -134(A6)
; char cTemp[128];
; unsigned char vposTemp = 0, vrettype, logwildcard = 0;
       clr.b     -3(A6)
       clr.b     -1(A6)
; // Se veio parametro pela linha de parametro, usa esse
; if (linhaParametro[0] != '\0')
       move.l    D7,A0
       move.b    (A0),D0
       beq.s     fsOsCommand_1
; blin = linhaParametro;
       move.l    D7,-466(A6)
fsOsCommand_1:
; // Separar linha entre comando e argumento
; linhacomando[0] = '\0';
       clr.b     (A2)
; linhaarg[0] = '\0';
       clr.b     -532+0(A6)
; vparam[0] = '\0';
       clr.b     (A4)
; vparam2[0] = '\0';
       clr.b     -234+0(A6)
; ix = 0;
       clr.w     D2
; iy = 0;
       clr.w     D4
; while (*blin != 0)
fsOsCommand_3:
       move.l    -466(A6),A0
       move.b    (A0),D0
       beq       fsOsCommand_5
; {
; if (!varg && *blin == 0x20)
       tst.w     D3
       bne.s     fsOsCommand_8
       moveq     #1,D0
       bra.s     fsOsCommand_9
fsOsCommand_8:
       clr.l     D0
fsOsCommand_9:
       and.l     #65535,D0
       beq.s     fsOsCommand_6
       move.l    -466(A6),A0
       move.b    (A0),D0
       cmp.b     #32,D0
       bne.s     fsOsCommand_6
; {
; varg = 0x01;
       moveq     #1,D3
; linhacomando[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; iy = ix;
       move.w    D2,D4
; ix = 0;
       clr.w     D2
       bra       fsOsCommand_7
fsOsCommand_6:
; }
; else
; {
; if (!varg)
       tst.w     D3
       bne.s     fsOsCommand_10
; linhacomando[ix] = toupper(*blin);
       move.l    -466(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
       bra.s     fsOsCommand_11
fsOsCommand_10:
; else
; linhaarg[ix] = toupper(*blin);
       move.l    -466(A6),A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       and.l     #65535,D2
       lea       -532(A6),A0
       move.b    D0,0(A0,D2.L)
fsOsCommand_11:
; ix++;
       addq.w    #1,D2
fsOsCommand_7:
; }
; *blin++;
       move.l    -466(A6),A0
       addq.l    #1,-466(A6)
       bra       fsOsCommand_3
fsOsCommand_5:
; }
; if (!varg)
       tst.w     D3
       bne.s     fsOsCommand_12
; {
; linhacomando[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; iy = ix;
       move.w    D2,D4
       bra       fsOsCommand_13
fsOsCommand_12:
; }
; else
; {
; linhaarg[ix] = '\0';
       and.l     #65535,D2
       lea       -532(A6),A0
       clr.b     0(A0,D2.L)
; memset(vparam, 0x00, sizeof(vparam));
       pea       32
       clr.l     -(A7)
       move.l    A4,-(A7)
       jsr       _memset
       add.w     #12,A7
; memset(vparam2, 0x00, sizeof(vparam2));
       pea       32
       clr.l     -(A7)
       pea       -234(A6)
       jsr       _memset
       add.w     #12,A7
; ikk = 0;
       clr.w     -292(A6)
; isrc = 0;
       clr.w     -290(A6)
; iz = 0;
       clr.w     -294(A6)
; varg = 0;
       clr.w     D3
; while (ikk < ix)
fsOsCommand_14:
       cmp.w     -292(A6),D2
       bls       fsOsCommand_16
; {
; if (linhaarg[ikk] == 0x20)
       move.w    -292(A6),D0
       and.l     #65535,D0
       lea       -532(A6),A0
       move.b    0(A0,D0.L),D0
       cmp.b     #32,D0
       bne.s     fsOsCommand_17
; {
; if (!varg && isrc > 0)
       tst.w     D3
       bne.s     fsOsCommand_21
       moveq     #1,D0
       bra.s     fsOsCommand_22
fsOsCommand_21:
       clr.l     D0
fsOsCommand_22:
       and.l     #65535,D0
       beq.s     fsOsCommand_19
       move.w    -290(A6),D0
       cmp.w     #0,D0
       bls.s     fsOsCommand_19
; varg = 1;
       moveq     #1,D3
fsOsCommand_19:
       bra       fsOsCommand_27
fsOsCommand_17:
; }
; else
; {
; if (!varg)
       tst.w     D3
       bne.s     fsOsCommand_23
; {
; if (isrc < (sizeof(vparam) - 1))
       move.w    -290(A6),D0
       and.l     #65535,D0
       cmp.l     #31,D0
       bhs.s     fsOsCommand_25
; vparam[isrc++] = linhaarg[ikk];
       move.w    -292(A6),D0
       and.l     #65535,D0
       lea       -532(A6),A0
       move.w    -290(A6),D1
       addq.w    #1,-290(A6)
       and.l     #65535,D1
       move.b    0(A0,D0.L),0(A4,D1.L)
fsOsCommand_25:
       bra.s     fsOsCommand_27
fsOsCommand_23:
; }
; else
; {
; if (iz < (sizeof(vparam2) - 1))
       move.w    -294(A6),D0
       and.l     #65535,D0
       cmp.l     #31,D0
       bhs.s     fsOsCommand_27
; vparam2[iz++] = linhaarg[ikk];
       move.w    -292(A6),D0
       and.l     #65535,D0
       lea       -532(A6),A0
       move.w    -294(A6),D1
       addq.w    #1,-294(A6)
       and.l     #65535,D1
       lea       -234(A6),A1
       move.b    0(A0,D0.L),0(A1,D1.L)
fsOsCommand_27:
; }
; }
; ikk++;
       addq.w    #1,-292(A6)
       bra       fsOsCommand_14
fsOsCommand_16:
; }
; vparam[isrc] = '\0';
       move.w    -290(A6),D0
       and.l     #65535,D0
       clr.b     0(A4,D0.L)
; vparam2[iz] = '\0';
       move.w    -294(A6),D0
       and.l     #65535,D0
       lea       -234(A6),A0
       clr.b     0(A0,D0.L)
fsOsCommand_13:
; }
; if (linhaarg[0] == 0x00)
       move.b    -532+0(A6),D0
       bne.s     fsOsCommand_29
; {
; vparam[0] = '\0';
       clr.b     (A4)
; vparam2[0] = '\0';
       clr.b     -234+0(A6)
fsOsCommand_29:
; }
; vpicret = 0;
       clr.b     -157(A6)
; // Processar e definir o que fazer
; if (linhacomando[0] != 0)
       move.b    (A2),D0
       beq       fsOsCommand_296
; {
; if (!strcmp(linhacomando,"CLS") && iy == 3)
       pea       @mmsjos_31.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_33
       cmp.w     #3,D4
       bne.s     fsOsCommand_33
; {
; clearScr();
       move.l    1054,A0
       jsr       (A0)
       bra       fsOsCommand_296
fsOsCommand_33:
; }
; else if (!strcmp(linhacomando,"CLEAR") && iy == 5)
       pea       @mmsjos_32.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_35
       cmp.w     #5,D4
       bne.s     fsOsCommand_35
; {
; clearScr();
       move.l    1054,A0
       jsr       (A0)
       bra       fsOsCommand_296
fsOsCommand_35:
; }
; else if (!strcmp(linhacomando,"QUIT") && iy == 4)
       pea       @mmsjos_33.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_37
       cmp.w     #4,D4
       bne.s     fsOsCommand_37
; {
; return 99;
       moveq     #99,D0
       bra       fsOsCommand_39
fsOsCommand_37:
; }
; else if (!strcmp(linhacomando,"VER") && iy == 3)
       pea       @mmsjos_34.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_40
       cmp.w     #3,D4
       bne.s     fsOsCommand_40
; {
; fsVer();
       jsr       _fsVer
       bra       fsOsCommand_296
fsOsCommand_40:
; }
; else if (!strcmp(linhacomando,"MGUI") && iy == 4)
       pea       @mmsjos_35.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_42
       cmp.w     #4,D4
       bne.s     fsOsCommand_42
; {
; OSTaskCreate(mguiTask, OS_NULL, &StkMgui[STACKSIZEMGUI], 11);
       pea       11
       lea       _StkMgui.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _mguiTask.L
       jsr       _OSTaskCreate
       add.w     #16,A7
       bra       fsOsCommand_296
fsOsCommand_42:
; }
; else if (!strcmp(linhacomando,"PWD") && iy == 3)
       pea       @mmsjos_36.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_44
       cmp.w     #3,D4
       bne.s     fsOsCommand_44
; {
; printText(vdiratu);
       pea       _vdiratu.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       fsOsCommand_296
fsOsCommand_44:
; }
; else if (iy == 2 && (!strcmp(linhacomando,"LS") ||
       cmp.w     #2,D4
       bne       fsOsCommand_46
       pea       @mmsjos_37.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       beq.s     fsOsCommand_48
       pea       @mmsjos_38.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       beq.s     fsOsCommand_48
       pea       @mmsjos_39.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_46
fsOsCommand_48:
; !strcmp(linhacomando,"RM") ||
; !strcmp(linhacomando,"CP")))
; {
; vclusterdiratu = vclusterdir;
       move.l    _vclusterdir.L,-156(A6)
; memcpy(vparam3, vparam, 32);
       pea       32
       move.l    A4,-(A7)
       pea       -202(A6)
       jsr       _memcpy
       add.w     #12,A7
; if (vparam3[0] > 0x20)
       move.b    -202+0(A6),D0
       cmp.b     #32,D0
       bls       fsOsCommand_49
; {
; // Acha o caminho final
; vrettype = fsFindDirPath(vparam3, FIND_PATH_LAST);
       pea       1
       pea       -202(A6)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       move.b    D0,-2(A6)
; // Verifica se tem wildcard
; logwildcard = contains_wildcards(vretpath.Name);
       pea       _vretpath.L
       jsr       _contains_wildcards
       addq.w    #4,A7
       move.b    D0,-1(A6)
; // Verifica Erro
; if (vrettype == FIND_PATH_RET_ERROR && !logwildcard)
       move.b    -2(A6),D0
       and.w     #255,D0
       cmp.w     #255,D0
       bne       fsOsCommand_51
       tst.b     -1(A6)
       bne.s     fsOsCommand_53
       moveq     #1,D0
       bra.s     fsOsCommand_54
fsOsCommand_53:
       clr.l     D0
fsOsCommand_54:
       and.l     #255,D0
       beq.s     fsOsCommand_51
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_55
; printText("File not found.\r\n\0");
       pea       @mmsjos_40.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_55:
; return 0;
       clr.l     D0
       bra       fsOsCommand_39
fsOsCommand_51:
; }
; vclusterdir = vretpath.ClusterDir;
       move.l    _vretpath+14.L,_vclusterdir.L
; iy = 0;
       clr.w     D4
; iz = 0;
       clr.w     -294(A6)
; for (ix = 0; ix < 12; ix++)
       clr.w     D2
fsOsCommand_57:
       cmp.w     #12,D2
       bhs       fsOsCommand_59
; {
; if (iy)
       tst.w     D4
       beq.s     fsOsCommand_60
; iz++;
       addq.w    #1,-294(A6)
fsOsCommand_60:
; if (iz == 4)
       move.w    -294(A6),D0
       cmp.w     #4,D0
       bne.s     fsOsCommand_62
; break;
       bra       fsOsCommand_59
fsOsCommand_62:
; if (vretpath.Name[ix] == 0x00 || vretpath.Name[ix] == 0x20)
       and.l     #65535,D2
       lea       _vretpath.L,A0
       move.b    0(A0,D2.L),D0
       beq.s     fsOsCommand_66
       and.l     #65535,D2
       lea       _vretpath.L,A0
       move.b    0(A0,D2.L),D0
       cmp.b     #32,D0
       bne.s     fsOsCommand_64
fsOsCommand_66:
; break;
       bra.s     fsOsCommand_59
fsOsCommand_64:
; if (vretpath.Name[ix] == '.')
       and.l     #65535,D2
       lea       _vretpath.L,A0
       move.b    0(A0,D2.L),D0
       cmp.b     #46,D0
       bne.s     fsOsCommand_67
; iy = 1;
       moveq     #1,D4
fsOsCommand_67:
       addq.w    #1,D2
       bra       fsOsCommand_57
fsOsCommand_59:
; }
; vretpath.Name[ix] = 0x00;
       and.l     #65535,D2
       lea       _vretpath.L,A0
       clr.b     0(A0,D2.L)
; memcpy(vparam3, vretpath.Name, 13);
       pea       13
       pea       _vretpath.L
       pea       -202(A6)
       jsr       _memcpy
       add.w     #12,A7
; logpath = 1;
       move.b    #1,-134(A6)
       bra.s     fsOsCommand_50
fsOsCommand_49:
; }
; else
; vrettype = FIND_PATH_RET_FOLDER;
       move.b    #1,-2(A6)
fsOsCommand_50:
; if (fsFindInDir(NULL, TYPE_FIRST_ENTRY) >= ERRO_D_START)
       pea       8
       clr.b     D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsOsCommand_69
; {
; printText("File not found..\r\n\0");
       pea       @mmsjos_41.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       fsOsCommand_73
fsOsCommand_69:
; }
; else
; {
; vclusterdirsrc = vclusterdir;
       move.l    _vclusterdir.L,-152(A6)
; while (1)
fsOsCommand_71:
; {
; // Pega nome do arquivo atual
; for (ix = 0; ix <= 7; ix++)
       clr.w     D2
fsOsCommand_74:
       cmp.w     #7,D2
       bhi       fsOsCommand_76
; {
; vparam[ix] = vdir.Name[ix];
       and.l     #65535,D2
       lea       _vdir.L,A0
       and.l     #65535,D2
       move.b    0(A0,D2.L),0(A4,D2.L)
; if (vparam[ix] == 0x20 || vparam[ix] == 0x00)
       and.l     #65535,D2
       move.b    0(A4,D2.L),D0
       cmp.b     #32,D0
       beq.s     fsOsCommand_79
       and.l     #65535,D2
       move.b    0(A4,D2.L),D0
       bne.s     fsOsCommand_77
fsOsCommand_79:
; {
; vparam[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A4,D2.L)
; break;
       bra.s     fsOsCommand_76
fsOsCommand_77:
       addq.w    #1,D2
       bra       fsOsCommand_74
fsOsCommand_76:
; }
; }
; vparam[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A4,D2.L)
; if (vdir.Name[0] != '.')
       move.b    _vdir.L,D0
       cmp.b     #46,D0
       beq       fsOsCommand_80
; {
; vparam[ix] = '.';
       and.l     #65535,D2
       move.b    #46,0(A4,D2.L)
; ix++;
       addq.w    #1,D2
; for (iy = 0; iy <= 2; iy++)
       clr.w     D4
fsOsCommand_82:
       cmp.w     #2,D4
       bhi       fsOsCommand_84
; {
; vparam[ix] = vdir.Ext[iy];
       and.l     #65535,D4
       lea       _vdir.L,A0
       add.l     D4,A0
       and.l     #65535,D2
       move.b    8(A0),0(A4,D2.L)
; if (vparam[ix] == 0x20 || vparam[ix] == 0x00)
       and.l     #65535,D2
       move.b    0(A4,D2.L),D0
       cmp.b     #32,D0
       beq.s     fsOsCommand_87
       and.l     #65535,D2
       move.b    0(A4,D2.L),D0
       bne.s     fsOsCommand_85
fsOsCommand_87:
; {
; vparam[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A4,D2.L)
; break;
       bra.s     fsOsCommand_84
fsOsCommand_85:
; }
; ix++;
       addq.w    #1,D2
       addq.w    #1,D4
       bra       fsOsCommand_82
fsOsCommand_84:
; }
; vparam[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A4,D2.L)
fsOsCommand_80:
; }
; if (!strcmp(linhacomando,"LS"))
       pea       @mmsjos_37.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_88
; {
; if (vrettype == FIND_PATH_RET_FOLDER || (vrettype != FIND_PATH_RET_FOLDER && matches_wildcard(vretpath.Name, vparam)))
       move.b    -2(A6),D0
       cmp.b     #1,D0
       beq.s     fsOsCommand_92
       move.b    -2(A6),D0
       cmp.b     #1,D0
       beq       fsOsCommand_90
       move.l    A4,-(A7)
       pea       _vretpath.L
       jsr       _matches_wildcard
       addq.w    #8,A7
       and.l     #255,D0
       beq       fsOsCommand_90
fsOsCommand_92:
; {
; if (vdir.Attr != ATTR_VOLUME)
       move.b    _vdir+11.L,D0
       cmp.b     #8,D0
       beq       fsOsCommand_93
; {
; memset(vbuffer, 0x0, 128);
       pea       128
       clr.l     -(A7)
       move.l    A3,-(A7)
       jsr       _memset
       add.w     #12,A7
; vdirptr = (unsigned char*)&vdir;
       lea       _vdir.L,A0
       move.l    A0,-282(A6)
; for(ix = 40; ix <= 79; ix++)
       moveq     #40,D2
fsOsCommand_95:
       cmp.w     #79,D2
       bhi.s     fsOsCommand_97
; vbuffer[ix] = *vdirptr++;
       move.l    -282(A6),A0
       addq.l    #1,-282(A6)
       and.l     #65535,D2
       move.b    (A0),0(A3,D2.L)
       addq.w    #1,D2
       bra       fsOsCommand_95
fsOsCommand_97:
; if (vdir.Attr != ATTR_DIRECTORY)
       move.b    _vdir+11.L,D0
       cmp.b     #16,D0
       beq       fsOsCommand_98
; {
; // Reduz o tamanho a unidade (GB, MB ou KB)
; vqtdtam = vdir.Size;
       move.l    _vdir+26.L,D6
; if ((vqtdtam & 0xC0000000) != 0)
       move.l    D6,D0
       and.l     #-1073741824,D0
       beq.s     fsOsCommand_100
; {
; cuntam = 'G';
       move.b    #71,-267(A6)
; vqtdtam = ((vqtdtam & 0xC0000000) >> 30) + 1;
       move.l    D6,D0
       and.l     #-1073741824,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #6,D0
       addq.l    #1,D0
       move.l    D0,D6
       bra       fsOsCommand_105
fsOsCommand_100:
; }
; else if ((vqtdtam & 0x3FF00000) != 0)
       move.l    D6,D0
       and.l     #1072693248,D0
       beq.s     fsOsCommand_102
; {
; cuntam = 'M';
       move.b    #77,-267(A6)
; vqtdtam = ((vqtdtam & 0x3FF00000) >> 20) + 1;
       move.l    D6,D0
       and.l     #1072693248,D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #4,D0
       addq.l    #1,D0
       move.l    D0,D6
       bra.s     fsOsCommand_105
fsOsCommand_102:
; }
; else if ((vqtdtam & 0x000FFC00) != 0)
       move.l    D6,D0
       and.l     #1047552,D0
       beq.s     fsOsCommand_104
; {
; cuntam = 'K';
       move.b    #75,-267(A6)
; vqtdtam = ((vqtdtam & 0x000FFC00) >> 10) + 1;
       move.l    D6,D0
       and.l     #1047552,D0
       asr.l     #8,D0
       asr.l     #2,D0
       addq.l    #1,D0
       move.l    D0,D6
       bra.s     fsOsCommand_105
fsOsCommand_104:
; }
; else
; cuntam = ' ';
       move.b    #32,-267(A6)
fsOsCommand_105:
; // Transforma para decimal
; memset(sqtdtam, 0x0, 10);
       pea       10
       clr.l     -(A7)
       pea       -278(A6)
       jsr       _memset
       add.w     #12,A7
; itoa(vqtdtam, sqtdtam, 10);
       pea       10
       pea       -278(A6)
       move.l    D6,-(A7)
       jsr       _itoa
       add.w     #12,A7
; // Primeira Parte da Linha do dir, tamanho
; for(ix = 0; ix <= 3; ix++)
       clr.w     D2
fsOsCommand_106:
       cmp.w     #3,D2
       bhi.s     fsOsCommand_108
; {
; if (sqtdtam[ix] == 0)
       and.l     #65535,D2
       lea       -278(A6),A0
       move.b    0(A0,D2.L),D0
       bne.s     fsOsCommand_109
; break;
       bra.s     fsOsCommand_108
fsOsCommand_109:
       addq.w    #1,D2
       bra       fsOsCommand_106
fsOsCommand_108:
; }
; iy = (4 - ix);
       moveq     #4,D0
       ext.w     D0
       sub.w     D2,D0
       move.w    D0,D4
; for(ix = 0; ix <= 3; ix++)
       clr.w     D2
fsOsCommand_111:
       cmp.w     #3,D2
       bhi       fsOsCommand_113
; {
; if (iy <= ix)
       cmp.w     D2,D4
       bhi.s     fsOsCommand_114
; {
; ikk = ix - iy;
       move.w    D2,D0
       sub.w     D4,D0
       move.w    D0,-292(A6)
; vbuffer[ix] = sqtdtam[ix - iy];
       and.l     #65535,D2
       move.l    D2,D0
       and.l     #65535,D4
       sub.l     D4,D0
       lea       -278(A6),A0
       and.l     #65535,D2
       move.b    0(A0,D0.L),0(A3,D2.L)
       bra.s     fsOsCommand_115
fsOsCommand_114:
; }
; else
; vbuffer[ix] = ' ';
       and.l     #65535,D2
       move.b    #32,0(A3,D2.L)
fsOsCommand_115:
       addq.w    #1,D2
       bra       fsOsCommand_111
fsOsCommand_113:
; }
; vbuffer[4] = cuntam;
       move.b    -267(A6),4(A3)
       bra.s     fsOsCommand_99
fsOsCommand_98:
; }
; else
; {
; vbuffer[0] = ' ';
       move.b    #32,(A3)
; vbuffer[1] = ' ';
       move.b    #32,1(A3)
; vbuffer[2] = ' ';
       move.b    #32,2(A3)
; vbuffer[3] = ' ';
       move.b    #32,3(A3)
; vbuffer[4] = '0';
       move.b    #48,4(A3)
fsOsCommand_99:
; }
; vbuffer[5] = ' ';
       move.b    #32,5(A3)
; // Segunda parte da linha do dir, data ult modif
; // Mes
; vqtdtam = (vdir.UpdateDate & 0x01E0) >> 5;
       move.w    _vdir+18.L,D0
       and.l     #65535,D0
       and.l     #480,D0
       lsr.l     #5,D0
       move.l    D0,D6
; if (vqtdtam < 1 || vqtdtam > 12)
       cmp.l     #1,D6
       blt.s     fsOsCommand_118
       cmp.l     #12,D6
       ble.s     fsOsCommand_116
fsOsCommand_118:
; vqtdtam = 1;
       moveq     #1,D6
fsOsCommand_116:
; vqtdtam--;
       subq.l    #1,D6
; vbuffer[6] = vmesc[vqtdtam][0];
       move.l    D6,D0
       muls      #3,D0
       lea       _vmesc.L,A0
       move.b    0(A0,D0.L),6(A3)
; vbuffer[7] = vmesc[vqtdtam][1];
       move.l    D6,D0
       muls      #3,D0
       lea       _vmesc.L,A0
       add.l     D0,A0
       move.b    1(A0),7(A3)
; vbuffer[8] = vmesc[vqtdtam][2];
       move.l    D6,D0
       muls      #3,D0
       lea       _vmesc.L,A0
       add.l     D0,A0
       move.b    2(A0),8(A3)
; vbuffer[9] = ' ';
       move.b    #32,9(A3)
; // Dia
; vqtdtam = vdir.UpdateDate & 0x001F;
       move.w    _vdir+18.L,D0
       and.l     #65535,D0
       and.l     #31,D0
       move.l    D0,D6
; memset(sqtdtam, 0x0, 10);
       pea       10
       clr.l     -(A7)
       pea       -278(A6)
       jsr       _memset
       add.w     #12,A7
; itoa(vqtdtam, sqtdtam, 10);
       pea       10
       pea       -278(A6)
       move.l    D6,-(A7)
       jsr       _itoa
       add.w     #12,A7
; if (vqtdtam < 10)
       cmp.l     #10,D6
       bge.s     fsOsCommand_119
; {
; vbuffer[10] = '0';
       move.b    #48,10(A3)
; vbuffer[11] = sqtdtam[0];
       move.b    -278+0(A6),11(A3)
       bra.s     fsOsCommand_120
fsOsCommand_119:
; }
; else
; {
; vbuffer[10] = sqtdtam[0];
       move.b    -278+0(A6),10(A3)
; vbuffer[11] = sqtdtam[1];
       move.b    -278+1(A6),11(A3)
fsOsCommand_120:
; }
; vbuffer[12] = ' ';
       move.b    #32,12(A3)
; // Ano
; vqtdtam = ((vdir.UpdateDate & 0xFE00) >> 9) + 1980;
       move.w    _vdir+18.L,D0
       and.l     #65535,D0
       and.l     #65024,D0
       lsr.l     #8,D0
       lsr.l     #1,D0
       add.l     #1980,D0
       move.l    D0,D6
; memset(sqtdtam, 0x0, 10);
       pea       10
       clr.l     -(A7)
       pea       -278(A6)
       jsr       _memset
       add.w     #12,A7
; itoa(vqtdtam, sqtdtam, 10);
       pea       10
       pea       -278(A6)
       move.l    D6,-(A7)
       jsr       _itoa
       add.w     #12,A7
; vbuffer[13] = sqtdtam[0];
       move.b    -278+0(A6),13(A3)
; vbuffer[14] = sqtdtam[1];
       move.b    -278+1(A6),14(A3)
; vbuffer[15] = sqtdtam[2];
       move.b    -278+2(A6),15(A3)
; vbuffer[16] = sqtdtam[3];
       move.b    -278+3(A6),16(A3)
; vbuffer[17] = ' ';
       move.b    #32,17(A3)
; // Terceira parte da linha do dir, nome.ext
; ix = 18;
       moveq     #18,D2
; varg = 0;
       clr.w     D3
; while (vdir.Name[varg] != 0x20 && vdir.Name[varg] != 0x00 && varg <= 7)
fsOsCommand_121:
       and.l     #65535,D3
       lea       _vdir.L,A0
       move.b    0(A0,D3.L),D0
       cmp.b     #32,D0
       beq.s     fsOsCommand_123
       and.l     #65535,D3
       lea       _vdir.L,A0
       move.b    0(A0,D3.L),D0
       beq.s     fsOsCommand_123
       cmp.w     #7,D3
       bhi.s     fsOsCommand_123
; {
; vbuffer[ix] = vdir.Name[varg];
       and.l     #65535,D3
       lea       _vdir.L,A0
       and.l     #65535,D2
       move.b    0(A0,D3.L),0(A3,D2.L)
; ix++;
       addq.w    #1,D2
; varg++;
       addq.w    #1,D3
       bra       fsOsCommand_121
fsOsCommand_123:
; }
; vbuffer[ix] = '.';
       and.l     #65535,D2
       move.b    #46,0(A3,D2.L)
; ix++;
       addq.w    #1,D2
; varg = 0;
       clr.w     D3
; while (vdir.Ext[varg] != 0x20 && vdir.Ext[varg] != 0x00 && varg <= 2)
fsOsCommand_124:
       and.l     #65535,D3
       lea       _vdir.L,A0
       add.l     D3,A0
       move.b    8(A0),D0
       cmp.b     #32,D0
       beq.s     fsOsCommand_126
       and.l     #65535,D3
       lea       _vdir.L,A0
       add.l     D3,A0
       move.b    8(A0),D0
       beq.s     fsOsCommand_126
       cmp.w     #2,D3
       bhi.s     fsOsCommand_126
; {
; vbuffer[ix] = vdir.Ext[varg];
       and.l     #65535,D3
       lea       _vdir.L,A0
       add.l     D3,A0
       and.l     #65535,D2
       move.b    8(A0),0(A3,D2.L)
; ix++;
       addq.w    #1,D2
; varg++;
       addq.w    #1,D3
       bra       fsOsCommand_124
fsOsCommand_126:
; }
; if (varg == 0)
       tst.w     D3
       bne.s     fsOsCommand_127
; {
; ix--;
       subq.w    #1,D2
; vbuffer[ix] = ' ';
       and.l     #65535,D2
       move.b    #32,0(A3,D2.L)
; ix++;
       addq.w    #1,D2
fsOsCommand_127:
; }
; // Quarta parte da linha do dir, "/" para diretorio
; if (vdir.Attr == ATTR_DIRECTORY)
       move.b    _vdir+11.L,D0
       cmp.b     #16,D0
       bne.s     fsOsCommand_129
; {
; ix--;
       subq.w    #1,D2
; vbuffer[ix] = '/';
       and.l     #65535,D2
       move.b    #47,0(A3,D2.L)
; ix++;
       addq.w    #1,D2
fsOsCommand_129:
; }
; vbuffer[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A3,D2.L)
; for(ix = 0; ix <= 39; ix++)
       clr.w     D2
fsOsCommand_131:
       cmp.w     #39,D2
       bhi.s     fsOsCommand_133
; vlinha[ix] = vbuffer[ix];
       and.l     #65535,D2
       and.l     #65535,D2
       lea       -334(A6),A0
       move.b    0(A3,D2.L),0(A0,D2.L)
       addq.w    #1,D2
       bra       fsOsCommand_131
fsOsCommand_133:
       bra       fsOsCommand_94
fsOsCommand_93:
; }
; else
; {
; memset(vlinha, 0x20, 40);
       pea       40
       pea       32
       pea       -334(A6)
       jsr       _memset
       add.w     #12,A7
; vlinha[5]  = 'D';
       move.b    #68,-334+5(A6)
; vlinha[6]  = 'i';
       move.b    #105,-334+6(A6)
; vlinha[7]  = 's';
       move.b    #115,-334+7(A6)
; vlinha[8]  = 'k';
       move.b    #107,-334+8(A6)
; vlinha[9]  = ' ';
       move.b    #32,-334+9(A6)
; vlinha[10] = 'N';
       move.b    #78,-334+10(A6)
; vlinha[11] = 'a';
       move.b    #97,-334+11(A6)
; vlinha[12] = 'm';
       move.b    #109,-334+12(A6)
; vlinha[13] = 'e';
       move.b    #101,-334+13(A6)
; vlinha[14] = ' ';
       move.b    #32,-334+14(A6)
; vlinha[15] = 'i';
       move.b    #105,-334+15(A6)
; vlinha[16] = 's';
       move.b    #115,-334+16(A6)
; vlinha[17] = ' ';
       move.b    #32,-334+17(A6)
; ix = 18;
       moveq     #18,D2
; varg = 0;
       clr.w     D3
; while (vdir.Name[varg] != 0x00 && varg <= 7)
fsOsCommand_134:
       and.l     #65535,D3
       lea       _vdir.L,A0
       move.b    0(A0,D3.L),D0
       beq.s     fsOsCommand_136
       cmp.w     #7,D3
       bhi.s     fsOsCommand_136
; {
; vlinha[ix] = vdir.Name[varg];
       and.l     #65535,D3
       lea       _vdir.L,A0
       and.l     #65535,D2
       lea       -334(A6),A1
       move.b    0(A0,D3.L),0(A1,D2.L)
; ix++;
       addq.w    #1,D2
; varg++;
       addq.w    #1,D3
       bra       fsOsCommand_134
fsOsCommand_136:
; }
; varg = 0;
       clr.w     D3
; while (vdir.Ext[varg] != 0x00 && varg <= 2)
fsOsCommand_137:
       and.l     #65535,D3
       lea       _vdir.L,A0
       add.l     D3,A0
       move.b    8(A0),D0
       beq.s     fsOsCommand_139
       cmp.w     #2,D3
       bhi.s     fsOsCommand_139
; {
; vlinha[ix] = vdir.Ext[varg];
       and.l     #65535,D3
       lea       _vdir.L,A0
       add.l     D3,A0
       and.l     #65535,D2
       lea       -334(A6),A1
       move.b    8(A0),0(A1,D2.L)
; ix++;
       addq.w    #1,D2
; varg++;
       addq.w    #1,D3
       bra       fsOsCommand_137
fsOsCommand_139:
; }
; vlinha[ix] = '\0';
       and.l     #65535,D2
       lea       -334(A6),A0
       clr.b     0(A0,D2.L)
fsOsCommand_94:
; }
; // Mostra linha
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(vlinha);
       pea       -334(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_90:
; }
; vretfat = RETURN_OK;
       clr.l     D5
; // Verifica se Tem mais arquivos no diretorio
; if (fsFindInDir(vparam, TYPE_NEXT_ENTRY) >= ERRO_D_START)
       pea       9
       move.l    A4,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsOsCommand_140
; {
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; break;
       bra       fsOsCommand_73
fsOsCommand_140:
       bra       fsOsCommand_209
fsOsCommand_88:
; }
; }
; else if (!strcmp(linhacomando,"RM"))
       pea       @mmsjos_38.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_142
; {
; vretfat = RETURN_OK;
       clr.l     D5
; logcopyok = 1;
       move.b    #1,-133(A6)
; // Verifica se Tem mais arquivos no diretorio antes de deletar
; if (fsFindInDir(vparam, TYPE_NEXT_ENTRY) >= ERRO_D_START)
       pea       9
       move.l    A4,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsOsCommand_144
; logcopyok = 0;
       clr.b     -133(A6)
       bra       fsOsCommand_152
fsOsCommand_144:
; else
; {
; // Pega o nome do proximo arquivo antes de deletar o atual
; vparam2[0] = '\0';
       clr.b     -234+0(A6)
; for (ix = 0; ix <= 7; ix++)
       clr.w     D2
fsOsCommand_146:
       cmp.w     #7,D2
       bhi       fsOsCommand_148
; {
; vparam2[ix] = vdir.Name[ix];
       and.l     #65535,D2
       lea       _vdir.L,A0
       and.l     #65535,D2
       lea       -234(A6),A1
       move.b    0(A0,D2.L),0(A1,D2.L)
; if (vparam2[ix] == 0x20 || vparam2[ix] == 0x00)
       and.l     #65535,D2
       lea       -234(A6),A0
       move.b    0(A0,D2.L),D0
       cmp.b     #32,D0
       beq.s     fsOsCommand_151
       and.l     #65535,D2
       lea       -234(A6),A0
       move.b    0(A0,D2.L),D0
       bne.s     fsOsCommand_149
fsOsCommand_151:
; {
; vparam2[ix] = '\0';
       and.l     #65535,D2
       lea       -234(A6),A0
       clr.b     0(A0,D2.L)
; break;
       bra.s     fsOsCommand_148
fsOsCommand_149:
       addq.w    #1,D2
       bra       fsOsCommand_146
fsOsCommand_148:
; }
; }
; vparam2[ix] = '\0';
       and.l     #65535,D2
       lea       -234(A6),A0
       clr.b     0(A0,D2.L)
; if (vdir.Name[0] != '.')
       move.b    _vdir.L,D0
       cmp.b     #46,D0
       beq       fsOsCommand_152
; {
; vparam2[ix] = '.';
       and.l     #65535,D2
       lea       -234(A6),A0
       move.b    #46,0(A0,D2.L)
; ix++;
       addq.w    #1,D2
; for (iy = 0; iy <= 2; iy++)
       clr.w     D4
fsOsCommand_154:
       cmp.w     #2,D4
       bhi       fsOsCommand_156
; {
; vparam2[ix] = vdir.Ext[iy];
       and.l     #65535,D4
       lea       _vdir.L,A0
       add.l     D4,A0
       and.l     #65535,D2
       lea       -234(A6),A1
       move.b    8(A0),0(A1,D2.L)
; if (vparam2[ix] == 0x20 || vparam2[ix] == 0x00)
       and.l     #65535,D2
       lea       -234(A6),A0
       move.b    0(A0,D2.L),D0
       cmp.b     #32,D0
       beq.s     fsOsCommand_159
       and.l     #65535,D2
       lea       -234(A6),A0
       move.b    0(A0,D2.L),D0
       bne.s     fsOsCommand_157
fsOsCommand_159:
; {
; vparam2[ix] = '\0';
       and.l     #65535,D2
       lea       -234(A6),A0
       clr.b     0(A0,D2.L)
; break;
       bra.s     fsOsCommand_156
fsOsCommand_157:
; }
; ix++;
       addq.w    #1,D2
       addq.w    #1,D4
       bra       fsOsCommand_154
fsOsCommand_156:
; }
; vparam2[ix] = '\0';
       and.l     #65535,D2
       lea       -234(A6),A0
       clr.b     0(A0,D2.L)
fsOsCommand_152:
; }
; }
; if (logwildcard)
       tst.b     -1(A6)
       beq       fsOsCommand_160
; {
; if (matches_wildcard(vparam3, vparam))
       move.l    A4,-(A7)
       pea       -202(A6)
       jsr       _matches_wildcard
       addq.w    #8,A7
       tst.b     D0
       beq       fsOsCommand_162
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_164
; {
; printText(vparam);
       move.l    A4,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_164:
; }
; vretfat = fsDelFile(vparam);
       move.l    A4,-(A7)
       jsr       _fsDelFile
       addq.w    #4,A7
       and.l     #255,D0
       move.l    D0,D5
fsOsCommand_162:
; }
; if (vretfat != RETURN_OK)
       tst.l     D5
       beq.s     fsOsCommand_166
; break;
       bra       fsOsCommand_73
fsOsCommand_166:
       bra.s     fsOsCommand_161
fsOsCommand_160:
; }
; else
; {
; vretfat = fsDelFile(vretpath.Name);
       pea       _vretpath.L
       jsr       _fsDelFile
       addq.w    #4,A7
       and.l     #255,D0
       move.l    D0,D5
; break;
       bra       fsOsCommand_73
fsOsCommand_161:
; }
; if (!logcopyok)
       tst.b     -133(A6)
       bne.s     fsOsCommand_168
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_170
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_170:
; break;
       bra       fsOsCommand_73
fsOsCommand_168:
; }
; else
; {
; if (fsFindInDir(vparam2, TYPE_ALL) >= ERRO_D_START)
       pea       255
       pea       -234(A6)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsOsCommand_172
; {
; vretfat = ERRO_B_NOT_FOUND;
       move.l    #255,D5
; break;
       bra       fsOsCommand_73
fsOsCommand_172:
       bra       fsOsCommand_209
fsOsCommand_142:
; }
; }
; }
; else if (!strcmp(linhacomando,"CP"))
       pea       @mmsjos_39.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_209
; {
; ikk = 0;
       clr.w     -292(A6)
; vretfat = RETURN_OK;
       clr.l     D5
; logcopyok = 1;
       move.b    #1,-133(A6)
; if (logwildcard)
       tst.b     -1(A6)
       beq.s     fsOsCommand_176
; {
; if (!matches_wildcard(vparam3, vparam))
       move.l    A4,-(A7)
       pea       -202(A6)
       jsr       _matches_wildcard
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsOsCommand_178
; logcopyok = 0;
       clr.b     -133(A6)
fsOsCommand_178:
       bra.s     fsOsCommand_177
fsOsCommand_176:
; }
; else
; strcpy(vparam, vparam3);
       pea       -202(A6)
       move.l    A4,-(A7)
       jsr       _strcpy
       addq.w    #8,A7
fsOsCommand_177:
; vclusterdir = vclusterdirsrc;
       move.l    -152(A6),_vclusterdir.L
; if (logcopyok)
       tst.b     -133(A6)
       beq       fsOsCommand_180
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_182
; {
; printText(vparam);
       move.l    A4,-(A7)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_182:
; }
; if (fsOpenFile(vparam) != RETURN_OK)
       move.l    A4,-(A7)
       jsr       _fsOpenFile
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsOsCommand_184
; {
; vretfat = ERRO_B_NOT_FOUND;
       move.l    #255,D5
       bra       fsOsCommand_196
fsOsCommand_184:
; }
; else
; {
; vclusterdir = vclusterdiratu;
       move.l    -156(A6),_vclusterdir.L
; vrettype = fsFindDirPath(vparam2, FIND_PATH_LAST); // nao tem comparacao com erro pois o arquivo destino pode nao existir
       pea       1
       pea       -234(A6)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       move.b    D0,-2(A6)
; if (!isValidFilename(vretpath.Name))
       pea       _vretpath.L
       jsr       _isValidFilename
       addq.w    #4,A7
       tst.l     D0
       bne.s     fsOsCommand_186
; vretfat = ERRO_B_INVALID_NAME;
       move.l    #228,D5
       bra       fsOsCommand_196
fsOsCommand_186:
; else
; {
; if (vrettype == FIND_PATH_RET_FOLDER)
       move.b    -2(A6),D0
       cmp.b     #1,D0
       bne.s     fsOsCommand_188
; strcpy(vparam4, vparam);
       move.l    A4,-(A7)
       pea       -170(A6)
       jsr       _strcpy
       addq.w    #8,A7
       bra.s     fsOsCommand_189
fsOsCommand_188:
; else
; strcpy(vparam4, vretpath.Name);
       pea       _vretpath.L
       pea       -170(A6)
       jsr       _strcpy
       addq.w    #8,A7
fsOsCommand_189:
; vclusterdirdst = vretpath.ClusterDir;
       move.l    _vretpath+14.L,-148(A6)
; vclusterdir = vclusterdirdst;
       move.l    -148(A6),_vclusterdir.L
; if (fsOpenFile(vparam4) == RETURN_OK)
       pea       -170(A6)
       jsr       _fsOpenFile
       addq.w    #4,A7
       tst.b     D0
       bne.s     fsOsCommand_190
; {
; if (fsDelFile(vparam4) != RETURN_OK)
       pea       -170(A6)
       jsr       _fsDelFile
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsOsCommand_192
; vretfat = ERRO_B_APAGAR_ARQUIVO;
       move.l    #231,D5
       bra.s     fsOsCommand_194
fsOsCommand_192:
; else if (fsCreateFile(vparam4) != RETURN_OK)
       pea       -170(A6)
       jsr       _fsCreateFile
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsOsCommand_194
; vretfat = ERRO_B_CREATE_FILE;
       move.l    #230,D5
fsOsCommand_194:
       bra.s     fsOsCommand_196
fsOsCommand_190:
; }
; else
; {
; if (fsCreateFile(vparam4) != RETURN_OK)
       pea       -170(A6)
       jsr       _fsCreateFile
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsOsCommand_196
; vretfat = ERRO_B_CREATE_FILE;
       move.l    #230,D5
fsOsCommand_196:
; }
; //memcpy(vdirdst, vdir, sizeof(FAT32_DIR));
; }
; }
; while (vretfat == RETURN_OK)
fsOsCommand_198:
       tst.l     D5
       bne       fsOsCommand_200
; {
; vclusterdir = vclusterdirsrc;
       move.l    -152(A6),_vclusterdir.L
; vReadSize = fsReadFile(vparam, ikk, vbuffer, 128);
       pea       128
       move.l    A3,-(A7)
       move.w    -292(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A4,-(A7)
       jsr       _fsReadFile
       add.w     #16,A7
       move.w    D0,-284(A6)
; if (vReadSize > 0)
       move.w    -284(A6),D0
       cmp.w     #0,D0
       bls       fsOsCommand_201
; {
; vclusterdir = vclusterdirdst;
       move.l    -148(A6),_vclusterdir.L
; if (fsWriteFile(vparam4, ikk, vbuffer, (unsigned char)vReadSize) != RETURN_OK)
       move.w    -284(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A3,-(A7)
       move.w    -292(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -170(A6)
       jsr       _fsWriteFile
       add.w     #16,A7
       tst.b     D0
       beq.s     fsOsCommand_203
; {
; vretfat = ERRO_B_WRITE_FILE;
       move.l    #237,D5
; break;
       bra.s     fsOsCommand_200
fsOsCommand_203:
; }
; ikk += vReadSize;
       move.w    -284(A6),D0
       add.w     D0,-292(A6)
       bra.s     fsOsCommand_202
fsOsCommand_201:
; }
; else
; break;
       bra.s     fsOsCommand_200
fsOsCommand_202:
       bra       fsOsCommand_198
fsOsCommand_200:
; }
; if (vretfat != RETURN_OK)
       tst.l     D5
       beq.s     fsOsCommand_205
; break;
       bra       fsOsCommand_73
fsOsCommand_205:
; vclusterdir = vclusterdirsrc;
       move.l    -152(A6),_vclusterdir.L
fsOsCommand_180:
; }
; if (!logwildcard)
       tst.b     -1(A6)
       bne.s     fsOsCommand_207
; break;
       bra.s     fsOsCommand_73
fsOsCommand_207:
; // Verifica se Tem mais arquivos no diretorio
; if (fsFindInDir(vparam, TYPE_NEXT_ENTRY) >= ERRO_D_START)
       pea       9
       move.l    A4,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsOsCommand_209
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_211
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_211:
; break;
       bra.s     fsOsCommand_73
fsOsCommand_209:
       bra       fsOsCommand_71
fsOsCommand_73:
; }
; }
; }
; }
; vclusterdir = vclusterdiratu;
       move.l    -156(A6),_vclusterdir.L
; if (vretfat != RETURN_OK)
       tst.l     D5
       beq.s     fsOsCommand_215
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_215
; {
; printDiskError(vretfat);
       and.l     #255,D5
       move.l    D5,-(A7)
       jsr       _printDiskError
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_215:
       bra       fsOsCommand_296
fsOsCommand_46:
; }
; }
; }
; else
; {
; if (!strcmp(linhacomando,"REN") && iy == 3) // Arquivo (somente 1, nao uar wildcard)
       pea       @mmsjos_42.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_217
       cmp.w     #3,D4
       bne       fsOsCommand_217
; {
; if (fsFindDirPath(vparam, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
       clr.l     -(A7)
       move.l    A4,-(A7)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     fsOsCommand_219
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_221
; printText("file not found.\r\n\0");
       pea       @mmsjos_43.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_221:
; vretfat = ERRO_B_NOT_FOUND;
       move.l    #255,D5
       bra.s     fsOsCommand_224
fsOsCommand_219:
; }
; else
; {
; if (!isValidFilename(vparam2))
       pea       -234(A6)
       jsr       _isValidFilename
       addq.w    #4,A7
       tst.l     D0
       bne.s     fsOsCommand_223
; vretfat = ERRO_B_INVALID_NAME;
       move.l    #228,D5
       bra.s     fsOsCommand_224
fsOsCommand_223:
; else
; {
; vclusterdir = vretpath.ClusterDir;
       move.l    _vretpath+14.L,_vclusterdir.L
; vretfat = fsRenameFile(vretpath.Name, vparam2);
       pea       -234(A6)
       pea       _vretpath.L
       jsr       _fsRenameFile
       addq.w    #8,A7
       and.l     #255,D0
       move.l    D0,D5
fsOsCommand_224:
; }
; }
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    _vretpath+18.L,_vclusterdir.L
       bra       fsOsCommand_246
fsOsCommand_217:
; }
; else if (!strcmp(linhacomando,"MD") && iy == 2)
       pea       @mmsjos_44.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_225
       cmp.w     #2,D4
       bne.s     fsOsCommand_225
; {
; vretfat = fsMakeDir(linhaarg);
       pea       -532(A6)
       jsr       _fsMakeDir
       addq.w    #4,A7
       and.l     #255,D0
       move.l    D0,D5
       bra       fsOsCommand_246
fsOsCommand_225:
; }
; else if (!strcmp(linhacomando,"CD") && iy == 2)
       pea       @mmsjos_45.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_227
       cmp.w     #2,D4
       bne.s     fsOsCommand_227
; {
; vretfat = fsChangeDir(linhaarg);
       pea       -532(A6)
       jsr       _fsChangeDir
       addq.w    #4,A7
       and.l     #255,D0
       move.l    D0,D5
       bra       fsOsCommand_246
fsOsCommand_227:
; }
; else if (!strcmp(linhacomando,"RD") && iy == 2)
       pea       @mmsjos_46.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_229
       cmp.w     #2,D4
       bne.s     fsOsCommand_229
; {
; vretfat = fsRemoveDir(linhaarg);
       pea       -532(A6)
       jsr       _fsRemoveDir
       addq.w    #4,A7
       and.l     #255,D0
       move.l    D0,D5
       bra       fsOsCommand_246
fsOsCommand_229:
; }
; else if (!strcmp(linhacomando,"STOF") && iy == 4) // Arquivo (usa 1 soh)
       pea       @mmsjos_47.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_231
       cmp.w     #4,D4
       bne.s     fsOsCommand_231
; {
; vretfat = fsLoadSerialToFile(linhaarg, "810000");  // Carrega da Serial para o Arquivo
       pea       @mmsjos_48.L
       pea       -532(A6)
       jsr       _fsLoadSerialToFile
       addq.w    #8,A7
       and.l     #255,D0
       move.l    D0,D5
       bra       fsOsCommand_246
fsOsCommand_231:
; }
; else if (!strcmp(linhacomando,"STOR") && iy == 4) // Arquivo (usa 1 soh)
       pea       @mmsjos_49.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_233
       cmp.w     #4,D4
       bne.s     fsOsCommand_233
; {
; vretfat = fsLoadSerialToRun(linhaarg);  // Carrega da Serial para o Arquivo
       pea       -532(A6)
       jsr       _fsLoadSerialToRun
       addq.w    #4,A7
       and.l     #255,D0
       move.l    D0,D5
       bra       fsOsCommand_246
fsOsCommand_233:
; }
; else if (!strcmp(linhacomando,"DATE") && iy == 4)
       pea       @mmsjos_50.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_235
       cmp.w     #4,D4
       bne.s     fsOsCommand_235
; {
; // TBD
; }
       bra       fsOsCommand_246
fsOsCommand_235:
; else if (!strcmp(linhacomando,"TIME") && iy == 4)
       pea       @mmsjos_51.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_237
       cmp.w     #4,D4
       bne.s     fsOsCommand_237
; {
; // TBD
; }
       bra       fsOsCommand_246
fsOsCommand_237:
; else if (!strcmp(linhacomando,"FORMAT") && iy == 6)
       pea       @mmsjos_52.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_239
       cmp.w     #6,D4
       bne.s     fsOsCommand_239
; {
; vretfat = fsFormat(0x5678, linhaarg);
       pea       -532(A6)
       pea       22136
       jsr       _fsFormat
       addq.w    #8,A7
       and.l     #255,D0
       move.l    D0,D5
       bra       fsOsCommand_246
fsOsCommand_239:
; }
; else if (!strcmp(linhacomando,"MODE") && iy == 4)
       pea       @mmsjos_53.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_241
       cmp.w     #4,D4
       bne.s     fsOsCommand_241
; {
; // A definir
; ix = 255;
       move.w    #255,D2
       bra       fsOsCommand_246
fsOsCommand_241:
; }
; else if (!strcmp(linhacomando,"CAT") && iy == 3) // Arquivo (usa 1 soh)
       pea       @mmsjos_54.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_243
       cmp.w     #3,D4
       bne.s     fsOsCommand_243
; {
; catFile(linhaarg);
       pea       -532(A6)
       jsr       _catFile
       addq.w    #4,A7
; ix = 255;
       move.w    #255,D2
       bra       fsOsCommand_246
fsOsCommand_243:
; }
; else
; {
; // Verifica se tem Arquivo com esse nome na pasta atual no disco
; ix = iy;
       move.w    D4,D2
; linhacomando[ix] = '.';
       and.l     #65535,D2
       move.b    #46,0(A2,D2.L)
; ix++;
       addq.w    #1,D2
; linhacomando[ix] = 'B';
       and.l     #65535,D2
       move.b    #66,0(A2,D2.L)
; ix++;
       addq.w    #1,D2
; linhacomando[ix] = 'I';
       and.l     #65535,D2
       move.b    #73,0(A2,D2.L)
; ix++;
       addq.w    #1,D2
; linhacomando[ix] = 'N';
       and.l     #65535,D2
       move.b    #78,0(A2,D2.L)
; ix++;
       addq.w    #1,D2
; linhacomando[ix] = '\0';
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; vretfat = fsFindInDir(linhacomando, TYPE_FILE);
       pea       2
       move.l    A2,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       move.l    D0,D5
; if (vretfat <= ERRO_D_START)
       cmp.l     #-16,D5
       bhi       fsOsCommand_245
; {
; // Se tiver, carrega em 0x00810000 e executa
; vsizefilemalloc = fsInfoFile(linhacomando, INFO_SIZE);
       pea       1
       move.l    A2,-(A7)
       jsr       _fsInfoFile
       addq.w    #8,A7
       move.l    D0,-144(A6)
; vEnderExec = malloc(vsizefilemalloc);
       move.l    -144(A6),-(A7)
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,-140(A6)
; if (!vEnderExec)
       tst.l     -140(A6)
       bne.s     fsOsCommand_247
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_249
; printText("No memory to load file...\r\n\0");
       pea       @mmsjos_55.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_249:
       bra       fsOsCommand_253
fsOsCommand_247:
; }
; else
; {
; itoa(vEnderExec,sqtdtam,16);
       pea       16
       pea       -278(A6)
       move.l    -140(A6),-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText("Loading File in \0");
       pea       @mmsjos_56.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(sqtdtam);
       pea       -278(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("h\r\n\0");
       pea       @mmsjos_57.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; loadFile(linhacomando, (unsigned long*)vEnderExec);
       move.l    -140(A6),-(A7)
       move.l    A2,-(A7)
       jsr       _loadFile
       addq.w    #8,A7
; if (!verro)
       tst.b     _verro.L
       bne.s     fsOsCommand_251
; {
; runOSMemory = vEnderExec;
       move.l    -140(A6),_runOSMemory.L
; runFromOsCmd();
       jsr       _runFromOsCmd
; free(vEnderExec);
       move.l    -140(A6),-(A7)
       jsr       _free
       addq.w    #4,A7
       bra.s     fsOsCommand_253
fsOsCommand_251:
; }
; else
; {
; free(vEnderExec);
       move.l    -140(A6),-(A7)
       jsr       _free
       addq.w    #4,A7
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_253
; printText("Loading File Error...\r\n\0");
       pea       @mmsjos_58.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_253:
; }
; }
; ix = 255;
       move.w    #255,D2
       bra.s     fsOsCommand_246
fsOsCommand_245:
; }
; else
; {
; // Se nao tiver, mostra erro
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_255
; printText("Invalid Command or File Name\r\n\0");
       pea       @mmsjos_59.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_255:
; ix = 255;
       move.w    #255,D2
fsOsCommand_246:
; }
; }
; if (ix != 255)
       cmp.w     #255,D2
       beq       fsOsCommand_296
; {
; if (vpicret)
       tst.b     -157(A6)
       beq       fsOsCommand_259
; {
; for (varg = 0; varg < ix; varg++)
       clr.w     D3
fsOsCommand_261:
       cmp.w     D2,D3
       bhs.s     fsOsCommand_263
; fsSendByte(linhaarg[varg], FS_DATA);
       pea       1
       and.l     #65535,D3
       lea       -532(A6),A0
       move.b    0(A0,D3.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _fsSendByte
       addq.w    #8,A7
       addq.w    #1,D3
       bra       fsOsCommand_261
fsOsCommand_263:
; vbytepic = fsRecByte(FS_DATA);
       pea       1
       jsr       _fsRecByte
       addq.w    #4,A7
       and.w     #255,D0
       move.w    D0,-288(A6)
fsOsCommand_259:
; }
; if (((vpicret) && (vbytepic != RETURN_OK)) || ((!vpicret) && (vretfat != RETURN_OK)))
       move.b    -157(A6),D0
       and.l     #255,D0
       beq.s     fsOsCommand_267
       move.w    -288(A6),D0
       bne.s     fsOsCommand_266
fsOsCommand_267:
       tst.b     -157(A6)
       bne.s     fsOsCommand_268
       moveq     #1,D0
       bra.s     fsOsCommand_269
fsOsCommand_268:
       clr.l     D0
fsOsCommand_269:
       and.l     #255,D0
       beq.s     fsOsCommand_264
       tst.l     D5
       beq.s     fsOsCommand_264
fsOsCommand_266:
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_270
; {
; printDiskError(vretfat);
       and.l     #255,D5
       move.l    D5,-(A7)
       jsr       _printDiskError
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_270:
       bra       fsOsCommand_296
fsOsCommand_264:
; }
; }
; else
; {
; if (!strcmp(linhacomando,"CD"))
       pea       @mmsjos_45.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_272
; {
; if (linhaarg[0] == '.' && linhaarg[1] == '.')
       move.b    -532+0(A6),D0
       cmp.b     #46,D0
       bne       fsOsCommand_274
       move.b    -532+1(A6),D0
       cmp.b     #46,D0
       bne       fsOsCommand_274
; {
; while (vdiratu[vdiratuidx] != '/')
fsOsCommand_276:
       move.w    _vdiratuidx.L,D0
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       move.b    0(A0,D0.L),D0
       cmp.b     #47,D0
       beq.s     fsOsCommand_278
; {
; vdiratu[vdiratuidx--] = '\0';
       move.w    _vdiratuidx.L,D0
       subq.w    #1,_vdiratuidx.L
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       clr.b     0(A0,D0.L)
       bra       fsOsCommand_276
fsOsCommand_278:
; }
; if (vdiratuidx > 127)
       move.w    _vdiratuidx.L,D0
       cmp.w     #127,D0
       bls.s     fsOsCommand_279
; vdiratu[vdiratuidx--] = '\0';
       move.w    _vdiratuidx.L,D0
       subq.w    #1,_vdiratuidx.L
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       clr.b     0(A0,D0.L)
       bra.s     fsOsCommand_280
fsOsCommand_279:
; else
; vdiratuidx++;
       addq.w    #1,_vdiratuidx.L
fsOsCommand_280:
       bra       fsOsCommand_283
fsOsCommand_274:
; }
; else if(linhaarg[0] == '/')
       move.b    -532+0(A6),D0
       cmp.b     #47,D0
       bne.s     fsOsCommand_281
; {
; vdiratuidx = 1;
       move.w    #1,_vdiratuidx.L
; vdiratu[0] = '/';
       move.b    #47,_vdiratu.L
; vdiratu[vdiratuidx] = '\0';
       move.w    _vdiratuidx.L,D0
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       clr.b     0(A0,D0.L)
       bra       fsOsCommand_283
fsOsCommand_281:
; }
; else if(linhaarg[0] != '.')
       move.b    -532+0(A6),D0
       cmp.b     #46,D0
       beq       fsOsCommand_283
; {
; vdiratuidx--;
       subq.w    #1,_vdiratuidx.L
; if (vdiratu[vdiratuidx++] != '/')
       move.w    _vdiratuidx.L,D0
       addq.w    #1,_vdiratuidx.L
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       move.b    0(A0,D0.L),D0
       cmp.b     #47,D0
       beq.s     fsOsCommand_285
; vdiratu[vdiratuidx++] = '/';
       move.w    _vdiratuidx.L,D0
       addq.w    #1,_vdiratuidx.L
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       move.b    #47,0(A0,D0.L)
fsOsCommand_285:
; for (varg = 0; varg < ix; varg++)
       clr.w     D3
fsOsCommand_287:
       cmp.w     D2,D3
       bhs.s     fsOsCommand_289
; vdiratu[vdiratuidx++] = linhaarg[varg];
       and.l     #65535,D3
       lea       -532(A6),A0
       move.w    _vdiratuidx.L,D0
       addq.w    #1,_vdiratuidx.L
       and.l     #65535,D0
       lea       _vdiratu.L,A1
       move.b    0(A0,D3.L),0(A1,D0.L)
       addq.w    #1,D3
       bra       fsOsCommand_287
fsOsCommand_289:
; vdiratu[vdiratuidx] = '\0';
       move.w    _vdiratuidx.L,D0
       and.l     #65535,D0
       lea       _vdiratu.L,A0
       clr.b     0(A0,D0.L)
fsOsCommand_283:
       bra       fsOsCommand_296
fsOsCommand_272:
; }
; }
; else if (!strcmp(linhacomando,"DATE"))
       pea       @mmsjos_50.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_290
; {
; /*for(ix = 0; ix <= 9; ix++)
; {
; recPic();
; vlinha[ix] = vbytepic;
; }*/
; vlinha[ix] = '\0';
       and.l     #65535,D2
       lea       -334(A6),A0
       clr.b     0(A0,D2.L)
; printText("  Date is \0");
       pea       @mmsjos_60.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(vlinha);
       pea       -334(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       fsOsCommand_296
fsOsCommand_290:
; }
; else if (!strcmp(linhacomando,"TIME"))
       pea       @mmsjos_51.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne       fsOsCommand_292
; {
; /*for(ix = 0; ix <= 7; ix++)
; {
; recPic();
; vlinha[ix] = vbytepic;
; }*/
; vlinha[ix] = '\0';
       and.l     #65535,D2
       lea       -334(A6),A0
       clr.b     0(A0,D2.L)
; printText("  Time is \0");
       pea       @mmsjos_61.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(vlinha);
       pea       -334(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra.s     fsOsCommand_296
fsOsCommand_292:
; }
; else if (!strcmp(linhacomando,"FORMAT"))
       pea       @mmsjos_52.L
       move.l    A2,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsOsCommand_296
; {
; if (linhaParametro[0] == '\0')
       move.l    D7,A0
       move.b    (A0),D0
       bne.s     fsOsCommand_296
; printText("Format disk was successfully\r\n\0");
       pea       @mmsjos_62.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
fsOsCommand_296:
; }
; }
; }
; }
; }
; return vretfat;
       move.l    D5,D0
fsOsCommand_39:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void runFromMGUI(unsigned long vEnderExec)
; {
       xdef      _runFromMGUI
_runFromMGUI:
       link      A6,#-88
       movem.l   D2/D3/A2,-(A7)
       move.l    8(A6),D2
       lea       _OSTaskCreate.L,A2
; unsigned int ix;
; OS_TCB dataTask;
; // Verifica qual task esta liberada
; for (ix = 0; ix < 6; ix++)
       clr.l     D3
runFromMGUI_1:
       cmp.l     #6,D3
       bhs.s     runFromMGUI_3
; {
; // Se nao existir essa task, usa ela
; if (OSTaskQuery((25 + ix), &dataTask) != OS_ERR_NONE)
       pea       -86(A6)
       moveq     #25,D1
       ext.w     D1
       ext.l     D1
       add.l     D3,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _OSTaskQuery
       addq.w    #8,A7
       tst.b     D0
       beq.s     runFromMGUI_4
; break;
       bra.s     runFromMGUI_3
runFromMGUI_4:
       addq.l    #1,D3
       bra       runFromMGUI_1
runFromMGUI_3:
; }
; // Cria a task
; switch (ix)
       move.l    D3,D0
       cmp.l     #6,D0
       bhs       runFromMGUI_6
       asl.l     #1,D0
       move.w    runFromMGUI_8(PC,D0.L),D0
       jmp       runFromMGUI_8(PC,D0.W)
runFromMGUI_8:
       dc.w      runFromMGUI_9-runFromMGUI_8
       dc.w      runFromMGUI_10-runFromMGUI_8
       dc.w      runFromMGUI_11-runFromMGUI_8
       dc.w      runFromMGUI_12-runFromMGUI_8
       dc.w      runFromMGUI_13-runFromMGUI_8
       dc.w      runFromMGUI_14-runFromMGUI_8
runFromMGUI_9:
; {
; case 0:
; OSTaskCreate(prog01Task, (void *)vEnderExec, &StkTask01[STACKSIZEMGUI], 25);
       pea       25
       lea       _StkTask01.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       move.l    D2,-(A7)
       pea       _prog01Task.L
       jsr       (A2)
       add.w     #16,A7
; break;
       bra       runFromMGUI_7
runFromMGUI_10:
; case 1:
; OSTaskCreate(prog02Task, (void *)vEnderExec, &StkTask02[STACKSIZEMGUI], 26);
       pea       26
       lea       _StkTask02.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       move.l    D2,-(A7)
       pea       _prog02Task.L
       jsr       (A2)
       add.w     #16,A7
; break;
       bra       runFromMGUI_7
runFromMGUI_11:
; case 2:
; OSTaskCreate(prog03Task, (void *)vEnderExec, &StkTask03[STACKSIZEMGUI], 27);
       pea       27
       lea       _StkTask03.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       move.l    D2,-(A7)
       pea       _prog03Task.L
       jsr       (A2)
       add.w     #16,A7
; break;
       bra       runFromMGUI_7
runFromMGUI_12:
; case 3:
; OSTaskCreate(prog04Task, (void *)vEnderExec, &StkTask04[STACKSIZEMGUI], 28);
       pea       28
       lea       _StkTask04.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       move.l    D2,-(A7)
       pea       _prog04Task.L
       jsr       (A2)
       add.w     #16,A7
; break;
       bra       runFromMGUI_7
runFromMGUI_13:
; case 4:
; OSTaskCreate(prog05Task, (void *)vEnderExec, &StkTask05[STACKSIZEMGUI], 20);
       pea       20
       lea       _StkTask05.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       move.l    D2,-(A7)
       pea       _prog05Task.L
       jsr       (A2)
       add.w     #16,A7
; break;
       bra.s     runFromMGUI_7
runFromMGUI_14:
; case 5:
; OSTaskCreate(prog06Task, (void *)vEnderExec, &StkTask06[STACKSIZEMGUI], 30);
       pea       30
       lea       _StkTask06.L,A0
       add.w     #4096,A0
       move.l    A0,-(A7)
       move.l    D2,-(A7)
       pea       _prog06Task.L
       jsr       (A2)
       add.w     #16,A7
; break;
       bra       runFromMGUI_7
runFromMGUI_6:
; default:
; break;
runFromMGUI_7:
; }
; // Se for um programa de execucao exclusiva, suspende o SO
; if (0)
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; {
; OSTaskSuspend(OS_PRIO_SELF);
; }
; }
; //-----------------------------------------------------------------------------
; // Delay Function
; //-----------------------------------------------------------------------------
; void delayus(int pTimeUS)
; {
       xdef      _delayus
_delayus:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned int ix;
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
; //-----------------------------------------------------------------------------
; // Memory Allocation Functions
; //-----------------------------------------------------------------------------
; void memInit(void)
; {
       xdef      _memInit
_memInit:
       rts
; // Alloc all memmory available minus reserved
; /*vMemAloc->prev = NULL;
; vMemAloc->name[0] = 0x00;
; vMemAloc->address = 0x00810000;
; vMemAloc->size = (*vtotmem * 1024) - 0x00010000 - 0x00040000; // 0x00600000 - 0x0063FFFF (256KB) = Reserved and 0x00800000 - 0x0080FFFF (64KB) = Reserved SO
; vMemAloc->status = 0;
; vMemAloc->next = NULL;*/
; }
; //-----------------------------------------------------------------------------
; // Disk Functions
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
; static unsigned char fsWriteFatSector(unsigned long vfat)
; {
@mmsjos_fsWriteFatSector:
       link      A6,#-4
       movem.l   D2/A2,-(A7)
       lea       _vdisk.L,A2
; unsigned char vfatCopy;
; unsigned long vfatCopySector;
; if (vdisk.NumberOfFATs == 0)
       move.b    30(A2),D0
       bne.s     @mmsjos_fsWriteFatSector_1
; vdisk.NumberOfFATs = 1;
       move.b    #1,30(A2)
@mmsjos_fsWriteFatSector_1:
; for (vfatCopy = 0; vfatCopy < vdisk.NumberOfFATs; vfatCopy++)
       clr.b     D2
@mmsjos_fsWriteFatSector_3:
       cmp.b     30(A2),D2
       bhs       @mmsjos_fsWriteFatSector_5
; {
; vfatCopySector = vfat + ((unsigned long)vfatCopy * vdisk.fatsize);
       move.l    8(A6),D0
       and.l     #255,D2
       move.l    D2,-(A7)
       move.l    24(A2),-(A7)
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,-4(A6)
; if (!fsSectorWrite(vfatCopySector, gDataBuffer, FALSE))
       clr.l     -(A7)
       pea       _gDataBuffer.L
       move.l    -4(A6),-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     @mmsjos_fsWriteFatSector_6
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra.s     @mmsjos_fsWriteFatSector_8
@mmsjos_fsWriteFatSector_6:
       addq.b    #1,D2
       bra       @mmsjos_fsWriteFatSector_3
@mmsjos_fsWriteFatSector_5:
; }
; return RETURN_OK;
       clr.b     D0
@mmsjos_fsWriteFatSector_8:
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; static unsigned char fsDeleteDirEntryChain(unsigned long vDirSector, unsigned short vDirEntry)
; {
@mmsjos_fsDeleteDirEntryChain:
       link      A6,#-8
       movem.l   D2/D3/D4/D5/A2/A3,-(A7)
       lea       _gDataBuffer.L,A2
       move.w    14(A6),D2
       and.l     #65535,D2
       lea       _vdisk.L,A3
       move.l    8(A6),D5
; unsigned long vScanSector;
; unsigned long vSectorInCluster;
; unsigned short vScanEntry;
; unsigned short vLastEntryInSector;
; if (!fsSectorRead(vDirSector, gDataBuffer))
       move.l    A2,-(A7)
       move.l    D5,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     @mmsjos_fsDeleteDirEntryChain_1
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       @mmsjos_fsDeleteDirEntryChain_3
@mmsjos_fsDeleteDirEntryChain_1:
; gDataBuffer[vDirEntry] = DIR_DEL;
       and.l     #65535,D2
       move.b    #229,0(A2,D2.L)
; gDataBuffer[vDirEntry + 20] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     20(A0,A2.L)
; gDataBuffer[vDirEntry + 21] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     21(A0,A2.L)
; gDataBuffer[vDirEntry + 26] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     26(A0,A2.L)
; gDataBuffer[vDirEntry + 27] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     27(A0,A2.L)
; gDataBuffer[vDirEntry + 28] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     28(A0,A2.L)
; gDataBuffer[vDirEntry + 29] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     29(A0,A2.L)
; gDataBuffer[vDirEntry + 30] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     30(A0,A2.L)
; gDataBuffer[vDirEntry + 31] = 0x00;
       and.l     #65535,D2
       move.l    D2,A0
       clr.b     31(A0,A2.L)
; if (!fsSectorWrite(vDirSector, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D5,-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     @mmsjos_fsDeleteDirEntryChain_4
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra       @mmsjos_fsDeleteDirEntryChain_3
@mmsjos_fsDeleteDirEntryChain_4:
; vScanSector = vDirSector;
       move.l    D5,D4
; vScanEntry = vDirEntry;
       move.w    D2,D3
; vLastEntryInSector = (vdisk.sectorSize - 32);
       move.w    22(A3),D0
       sub.w     #32,D0
       move.w    D0,-2(A6)
; while (1)
@mmsjos_fsDeleteDirEntryChain_6:
; {
; if (vScanEntry >= 32)
       cmp.w     #32,D3
       blo.s     @mmsjos_fsDeleteDirEntryChain_9
; {
; vScanEntry -= 32;
       sub.w     #32,D3
       bra       @mmsjos_fsDeleteDirEntryChain_10
@mmsjos_fsDeleteDirEntryChain_9:
; }
; else
; {
; vSectorInCluster = (vScanSector - vdisk.data) % vdisk.SecPerClus;
       move.l    D4,D0
       move.l    A3,D1
       add.l     #12,D1
       move.l    D1,A0
       sub.l     (A0),D0
       move.l    A3,D1
       add.l     #31,D1
       move.l    D1,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-6(A6)
; if (vSectorInCluster == 0)
       move.l    -6(A6),D0
       bne.s     @mmsjos_fsDeleteDirEntryChain_11
; break;
       bra       @mmsjos_fsDeleteDirEntryChain_8
@mmsjos_fsDeleteDirEntryChain_11:
; vScanSector--;
       subq.l    #1,D4
; vScanEntry = vLastEntryInSector;
       move.w    -2(A6),D3
@mmsjos_fsDeleteDirEntryChain_10:
; }
; if (!fsSectorRead(vScanSector, gDataBuffer))
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     @mmsjos_fsDeleteDirEntryChain_13
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       @mmsjos_fsDeleteDirEntryChain_3
@mmsjos_fsDeleteDirEntryChain_13:
; if (gDataBuffer[vScanEntry] == DIR_EMPTY || gDataBuffer[vScanEntry] == DIR_DEL)
       and.l     #65535,D3
       move.b    0(A2,D3.L),D0
       beq.s     @mmsjos_fsDeleteDirEntryChain_17
       and.l     #65535,D3
       move.b    0(A2,D3.L),D0
       and.w     #255,D0
       cmp.w     #229,D0
       bne.s     @mmsjos_fsDeleteDirEntryChain_15
@mmsjos_fsDeleteDirEntryChain_17:
; break;
       bra       @mmsjos_fsDeleteDirEntryChain_8
@mmsjos_fsDeleteDirEntryChain_15:
; if (gDataBuffer[vScanEntry + 11] != ATTR_LONG_NAME)
       and.l     #65535,D3
       move.l    D3,A0
       move.b    11(A0,A2.L),D0
       cmp.b     #15,D0
       beq.s     @mmsjos_fsDeleteDirEntryChain_18
; break;
       bra.s     @mmsjos_fsDeleteDirEntryChain_8
@mmsjos_fsDeleteDirEntryChain_18:
; gDataBuffer[vScanEntry] = DIR_DEL;
       and.l     #65535,D3
       move.b    #229,0(A2,D3.L)
; if (!fsSectorWrite(vScanSector, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     @mmsjos_fsDeleteDirEntryChain_20
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra.s     @mmsjos_fsDeleteDirEntryChain_3
@mmsjos_fsDeleteDirEntryChain_20:
       bra       @mmsjos_fsDeleteDirEntryChain_6
@mmsjos_fsDeleteDirEntryChain_8:
; }
; return RETURN_OK;
       clr.b     D0
@mmsjos_fsDeleteDirEntryChain_3:
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // FAT32 Functions
; //-----------------------------------------------------------------------------
; unsigned char fsMountDisk(void)
; {
       xdef      _fsMountDisk
_fsMountDisk:
       movem.l   A2/A3,-(A7)
       lea       _vdisk.L,A2
       lea       _gDataBuffer.L,A3
; // LER MBR
; if (!fsSectorRead((unsigned long)0x0000,gDataBuffer))
       move.l    A3,-(A7)
       clr.l     -(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsMountDisk_1
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra       fsMountDisk_3
fsMountDisk_1:
; vdisk.firsts  = (((unsigned long)gDataBuffer[457] << 24) & 0xFF000000);
       move.b    457(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #-16777216,D0
       move.l    D0,(A2)
; vdisk.firsts |= (((unsigned long)gDataBuffer[456] << 16) & 0x00FF0000);
       move.b    456(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       and.l     #16711680,D0
       or.l      D0,(A2)
; vdisk.firsts |= (((unsigned long)gDataBuffer[455] << 8) & 0x0000FF00);
       move.b    455(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       and.l     #65280,D0
       or.l      D0,(A2)
; vdisk.firsts |= ((unsigned long)gDataBuffer[454] & 0x000000FF);
       move.b    454(A3),D0
       and.l     #255,D0
       and.l     #255,D0
       or.l      D0,(A2)
; // LER FIRST CLUSTER
; if (!fsSectorRead(vdisk.firsts,gDataBuffer))
       move.l    A3,-(A7)
       move.l    (A2),-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsMountDisk_4
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra       fsMountDisk_3
fsMountDisk_4:
; vdisk.reserv  = (unsigned short)gDataBuffer[15] << 8;
       move.b    15(A3),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.w    D0,28(A2)
; vdisk.reserv |= (unsigned short)gDataBuffer[14];
       move.b    14(A3),D0
       and.w     #255,D0
       or.w      D0,28(A2)
; vdisk.fat = vdisk.reserv + vdisk.firsts;
       move.w    28(A2),D0
       and.l     #65535,D0
       add.l     (A2),D0
       move.l    D0,4(A2)
; vdisk.sectorSize  = (unsigned long)gDataBuffer[12] << 8;
       move.b    12(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.w    D0,22(A2)
; vdisk.sectorSize |= (unsigned long)gDataBuffer[11];
       move.b    11(A3),D0
       and.l     #255,D0
       or.w      D0,22(A2)
; vdisk.NumberOfFATs = gDataBuffer[16];
       move.b    16(A3),30(A2)
; vdisk.SecPerClus = gDataBuffer[13];
       move.b    13(A3),31(A2)
; if (vdisk.NumberOfFATs == 0)
       move.b    30(A2),D0
       bne.s     fsMountDisk_6
; vdisk.NumberOfFATs = 1;
       move.b    #1,30(A2)
fsMountDisk_6:
; vdisk.fatsize  = (unsigned long)gDataBuffer[39] << 24;
       move.b    39(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,24(A2)
; vdisk.fatsize |= (unsigned long)gDataBuffer[38] << 16;
       move.b    38(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,24(A2)
; vdisk.fatsize |= (unsigned long)gDataBuffer[37] << 8;
       move.b    37(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,24(A2)
; vdisk.fatsize |= (unsigned long)gDataBuffer[36];
       move.b    36(A3),D0
       and.l     #255,D0
       or.l      D0,24(A2)
; vdisk.root  = (unsigned long)gDataBuffer[47] << 24;
       move.b    47(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,8(A2)
; vdisk.root |= (unsigned long)gDataBuffer[46] << 16;
       move.b    46(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,8(A2)
; vdisk.root |= (unsigned long)gDataBuffer[45] << 8;
       move.b    45(A3),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,8(A2)
; vdisk.root |= (unsigned long)gDataBuffer[44];
       move.b    44(A3),D0
       and.l     #255,D0
       or.l      D0,8(A2)
; vdisk.type = FAT32;
       move.b    #3,32(A2)
; vdisk.data = vdisk.firsts + vdisk.reserv + ((unsigned long)vdisk.NumberOfFATs * vdisk.fatsize);
       move.l    (A2),D0
       move.w    28(A2),D1
       and.l     #65535,D1
       add.l     D1,D0
       move.b    30(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    24(A2),-(A7)
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,12(A2)
; vclusterdir = vdisk.root;
       move.l    8(A2),_vclusterdir.L
; return RETURN_OK;
       clr.b     D0
fsMountDisk_3:
       movem.l   (A7)+,A2/A3
       rts
; }
; //-------------------------------------------------------------------------
; void fsSetClusterDir (unsigned long vclusdiratu) {
       xdef      _fsSetClusterDir
_fsSetClusterDir:
       link      A6,#0
; vclusterdir = vclusdiratu;
       move.l    8(A6),_vclusterdir.L
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned long fsGetClusterDir (void) {
       xdef      _fsGetClusterDir
_fsGetClusterDir:
; return vclusterdir;
       move.l    _vclusterdir.L,D0
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsCreateFile(char * vfilename)
; {
       xdef      _fsCreateFile
_fsCreateFile:
       link      A6,#0
; // Verifica ja existe arquivo com esse nome
; if (fsFindInDir(vfilename, TYPE_ALL) < ERRO_D_START)
       pea       255
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       bhs.s     fsCreateFile_1
; return ERRO_B_FILE_FOUND;
       move.b    #232,D0
       bra.s     fsCreateFile_3
fsCreateFile_1:
; // Cria o arquivo com o nome especificado
; if (fsFindInDir(vfilename, TYPE_CREATE_FILE) >= ERRO_D_START)
       pea       4
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsCreateFile_4
; return ERRO_B_CREATE_FILE;
       move.b    #230,D0
       bra.s     fsCreateFile_3
fsCreateFile_4:
; return RETURN_OK;
       clr.b     D0
fsCreateFile_3:
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsOpenFile(char * vfilename)
; {
       xdef      _fsOpenFile
_fsOpenFile:
       link      A6,#-32
       move.l    A2,-(A7)
       lea       -26(A6),A2
; unsigned short vdirdate, vbytepic;
; unsigned char ds1307[7], ix, vlinha[12], vtemp[5];
; // Abre o arquivo especificado
; if (fsFindInDir(vfilename, TYPE_FILE) >= ERRO_D_START)
       pea       2
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsOpenFile_1
; return ERRO_B_FILE_NOT_FOUND;
       move.b    #224,D0
       bra       fsOpenFile_3
fsOpenFile_1:
; // Ler Data/Hora do PIC
; // TBD
; ds1307[3] = 01;
       move.b    #1,3(A2)
; ds1307[4] = 01;
       move.b    #1,4(A2)
; ds1307[5] = 2024;
       move.b    #232,5(A2)
; // Converte para a Data/Hora da FAT32
; vdirdate = datetimetodir(ds1307[3], ds1307[4], ds1307[5], CONV_DATA);
       pea       1
       move.b    5(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    4(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    3(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _datetimetodir
       add.w     #16,A7
       move.w    D0,-30(A6)
; // Grava nova data no lastaccess
; vdir.LastAccessDate  = vdirdate;
       move.w    -30(A6),_vdir+16.L
; if (fsUpdateDir() != RETURN_OK)
       jsr       _fsUpdateDir
       tst.b     D0
       beq.s     fsOpenFile_4
; return ERRO_B_UPDATE_DIR;
       move.b    #233,D0
       bra.s     fsOpenFile_3
fsOpenFile_4:
; return RETURN_OK;
       clr.b     D0
fsOpenFile_3:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsCloseFile(char * vfilename, unsigned char vupdated)
; {
       xdef      _fsCloseFile
_fsCloseFile:
       link      A6,#-32
       movem.l   D2/A2/A3,-(A7)
       lea       -26(A6),A2
       lea       _vdir.L,A3
; unsigned short vdirdate, vdirtime, vbytepic;
; unsigned char ds1307[7], vtemp[5], ix, vlinha[12];
; if (fsFindInDir(vfilename, TYPE_FILE) < ERRO_D_START) {
       pea       2
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       bhs       fsCloseFile_1
; if (vupdated) {
       tst.b     15(A6)
       beq       fsCloseFile_5
; // Ler Data/Hora do DS1307 - I2C
; // TBD
; ds1307[3] = 01;
       move.b    #1,3(A2)
; ds1307[4] = 01;
       move.b    #1,4(A2)
; ds1307[5] = 2024;
       move.b    #232,5(A2)
; ds1307[0] = 00;
       clr.b     (A2)
; ds1307[1] = 00;
       clr.b     1(A2)
; ds1307[2] = 00;
       clr.b     2(A2)
; // Converte para a Data/Hora da FAT32
; vdirtime = datetimetodir(ds1307[0], ds1307[1], ds1307[2], CONV_HORA);
       pea       2
       move.b    2(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    (A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _datetimetodir
       add.w     #16,A7
       move.w    D0,-30(A6)
; vdirdate = datetimetodir(ds1307[3], ds1307[4], ds1307[5], CONV_DATA);
       pea       1
       move.b    5(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    4(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    3(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _datetimetodir
       add.w     #16,A7
       move.w    D0,D2
; // Grava nova data no lastaccess e nova data/hora no update date/time
; vdir.LastAccessDate  = vdirdate;
       move.w    D2,16(A3)
; vdir.UpdateTime = vdirtime;
       move.w    -30(A6),20(A3)
; vdir.UpdateDate = vdirdate;
       move.w    D2,18(A3)
; if (fsUpdateDir() != RETURN_OK)
       jsr       _fsUpdateDir
       tst.b     D0
       beq.s     fsCloseFile_5
; return ERRO_B_UPDATE_DIR;
       move.b    #233,D0
       bra.s     fsCloseFile_7
fsCloseFile_5:
       bra.s     fsCloseFile_2
fsCloseFile_1:
; }
; }
; else
; return ERRO_B_NOT_FOUND;
       move.b    #255,D0
       bra.s     fsCloseFile_7
fsCloseFile_2:
; return RETURN_OK;
       clr.b     D0
fsCloseFile_7:
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned long fsInfoFile(char * vfilename, unsigned char vtype)
; {
       xdef      _fsInfoFile
_fsInfoFile:
       link      A6,#0
       movem.l   D2/D3/A2/A3/A4,-(A7)
       lea       _vdir.L,A2
       lea       _vretpath.L,A3
       lea       _vclusterdir.L,A4
; unsigned long vinfo = ERRO_D_NOT_FOUND, vtemp;
       moveq     #-1,D2
; if (fsFindDirPath(vfilename, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
       clr.l     -(A7)
       move.l    8(A6),-(A7)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     fsInfoFile_1
; {
; verro = 1;
       move.b    #1,_verro.L
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A3),(A4)
; return vinfo;
       move.l    D2,D0
       bra       fsInfoFile_3
fsInfoFile_1:
; }
; vclusterdir = vretpath.ClusterDir;
       move.l    14(A3),(A4)
; // retornar as informa?es conforme solicitado.
; if (fsFindInDir(vretpath.Name, TYPE_FILE) < ERRO_D_START) {
       pea       2
       move.l    A3,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       bhs       fsInfoFile_4
; switch (vtype) {
       move.b    15(A6),D0
       and.l     #255,D0
       subq.l    #1,D0
       blo       fsInfoFile_7
       cmp.l     #4,D0
       bhs       fsInfoFile_7
       asl.l     #1,D0
       move.w    fsInfoFile_8(PC,D0.L),D0
       jmp       fsInfoFile_8(PC,D0.W)
fsInfoFile_8:
       dc.w      fsInfoFile_9-fsInfoFile_8
       dc.w      fsInfoFile_10-fsInfoFile_8
       dc.w      fsInfoFile_11-fsInfoFile_8
       dc.w      fsInfoFile_12-fsInfoFile_8
fsInfoFile_9:
; case INFO_SIZE:
; vinfo = vdir.Size;
       move.l    26(A2),D2
; break;
       bra       fsInfoFile_7
fsInfoFile_10:
; case INFO_CREATE:
; vtemp = (vdir.CreateDate << 16) | vdir.CreateTime;
       move.w    12(A2),D0
       and.l     #65535,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.w    14(A2),D1
       and.l     #65535,D1
       or.l      D1,D0
       move.l    D0,D3
; vinfo = (vtemp);
       move.l    D3,D2
; break;
       bra.s     fsInfoFile_7
fsInfoFile_11:
; case INFO_UPDATE:
; vtemp = (vdir.UpdateDate << 16) | vdir.UpdateTime;
       move.w    18(A2),D0
       and.l     #65535,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.w    20(A2),D1
       and.l     #65535,D1
       or.l      D1,D0
       move.l    D0,D3
; vinfo = (vtemp);
       move.l    D3,D2
; break;
       bra.s     fsInfoFile_7
fsInfoFile_12:
; case INFO_LAST:
; vinfo = vdir.LastAccessDate;
       move.w    16(A2),D0
       and.l     #65535,D0
       move.l    D0,D2
; break;
fsInfoFile_7:
       bra.s     fsInfoFile_5
fsInfoFile_4:
; }
; }
; else
; {
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A3),(A4)
; return ERRO_D_NOT_FOUND;
       moveq     #-1,D0
       bra.s     fsInfoFile_3
fsInfoFile_5:
; }
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A3),(A4)
; return vinfo;
       move.l    D2,D0
fsInfoFile_3:
       movem.l   (A7)+,D2/D3/A2/A3/A4
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsDelFile(char * vfilename)
; {
       xdef      _fsDelFile
_fsDelFile:
       link      A6,#0
; // Apaga o arquivo solicitado
; if (fsFindInDir(vfilename, TYPE_DEL_FILE) >= ERRO_D_START)
       pea       6
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsDelFile_1
; return ERRO_B_APAGAR_ARQUIVO;
       move.b    #231,D0
       bra.s     fsDelFile_3
fsDelFile_1:
; return RETURN_OK;
       clr.b     D0
fsDelFile_3:
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsRenameFile(char * vfilename, char * vnewname)
; {
       xdef      _fsRenameFile
_fsRenameFile:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/A2,-(A7)
       move.l    12(A6),D4
       lea       _vdir.L,A2
; unsigned long vclusterfile;
; unsigned short ikk;
; unsigned char ixx, iyy;
; // Verificar se nome j?nao existe
; vclusterfile = fsFindInDir(vnewname, TYPE_ALL);
       pea       255
       move.l    D4,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       move.l    D0,D5
; if (vclusterfile < ERRO_D_START)
       cmp.l     #-16,D5
       bhs.s     fsRenameFile_1
; return ERRO_B_FILE_FOUND;
       move.b    #232,D0
       bra       fsRenameFile_3
fsRenameFile_1:
; // Procura arquivo a ser renomeado
; vclusterfile = fsFindInDir(vfilename, TYPE_FILE);
       pea       2
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       move.l    D0,D5
; if (vclusterfile >= ERRO_D_START)
       cmp.l     #-16,D5
       blo.s     fsRenameFile_4
; return ERRO_B_FILE_NOT_FOUND;
       move.b    #224,D0
       bra       fsRenameFile_3
fsRenameFile_4:
; // Altera nome na estrutura vdir
; memset(vdir.Name, 0x20, 8);
       pea       8
       pea       32
       move.l    A2,-(A7)
       jsr       _memset
       add.w     #12,A7
; memset(vdir.Ext, 0x20, 3);
       pea       3
       pea       32
       moveq     #8,D1
       add.l     A2,D1
       move.l    D1,-(A7)
       jsr       _memset
       add.w     #12,A7
; iyy = 0;
       clr.b     D3
; for (ixx = 0; ixx <= strlen(vnewname); ixx++) {
       clr.b     D2
fsRenameFile_6:
       and.l     #255,D2
       move.l    D4,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     D0,D2
       bhi       fsRenameFile_8
; if (vnewname[ixx] == '\0')
       move.l    D4,A0
       and.l     #255,D2
       move.b    0(A0,D2.L),D0
       bne.s     fsRenameFile_9
; break;
       bra       fsRenameFile_8
fsRenameFile_9:
; else if (vnewname[ixx] == '.')
       move.l    D4,A0
       and.l     #255,D2
       move.b    0(A0,D2.L),D0
       cmp.b     #46,D0
       bne.s     fsRenameFile_11
; iyy = 8;
       moveq     #8,D3
       bra       fsRenameFile_12
fsRenameFile_11:
; else {
; if (iyy <= 7)
       cmp.b     #7,D3
       bhi.s     fsRenameFile_13
; vdir.Name[iyy] = vnewname[ixx];
       move.l    D4,A0
       and.l     #255,D2
       and.l     #255,D3
       move.b    0(A0,D2.L),0(A2,D3.L)
       bra.s     fsRenameFile_14
fsRenameFile_13:
; else {
; ikk = iyy - 8;
       and.w     #255,D3
       move.w    D3,D0
       subq.w    #8,D0
       move.w    D0,-2(A6)
; vdir.Ext[ikk] = vnewname[ixx];
       move.l    D4,A0
       and.l     #255,D2
       move.w    -2(A6),D0
       and.l     #65535,D0
       lea       0(A2,D0.L),A1
       move.b    0(A0,D2.L),8(A1)
fsRenameFile_14:
; }
; iyy++;
       addq.b    #1,D3
fsRenameFile_12:
       addq.b    #1,D2
       bra       fsRenameFile_6
fsRenameFile_8:
; }
; }
; // Altera o nome, as demais informacoes nao alteram
; if (fsUpdateDir() != RETURN_OK)
       jsr       _fsUpdateDir
       tst.b     D0
       beq.s     fsRenameFile_15
; return ERRO_B_UPDATE_DIR;
       move.b    #233,D0
       bra.s     fsRenameFile_3
fsRenameFile_15:
; return RETURN_OK;
       clr.b     D0
fsRenameFile_3:
       movem.l   (A7)+,D2/D3/D4/D5/A2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsLoadSerialToFile(char * vfilename, char * vPosMem)
; {
       xdef      _fsLoadSerialToFile
_fsLoadSerialToFile:
       link      A6,#-140
       movem.l   D2/D3/D4/D5/D6/D7/A2,-(A7)
       move.l    8(A6),D3
       lea       -4(A6),A2
; unsigned long vSize, ix, vStep;
; unsigned char *xaddress = hexToLong(vPosMem);
       move.l    12(A6),-(A7)
       jsr       _hexToLong
       addq.w    #4,A7
       move.l    D0,D7
; unsigned char vBuffer[128];
; int iy;
; unsigned char vmovposyatu = 0;
       clr.b     D6
; VDP_COORD vcursor;
; unsigned long vSizeTotalRec;
; vSizeTotalRec = lstmGetSize();
       move.l    1178,A0
       jsr       (A0)
       move.l    D0,D5
; if (vfilename == 0)
       tst.l     D3
       bne.s     fsLoadSerialToFile_1
; {
; printText("Error, file name must be provided!!\r\n\0");
       pea       @mmsjos_63.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return ERRO_B_WRITE_FILE;;
       move.b    #237,D0
       bra       fsLoadSerialToFile_3
fsLoadSerialToFile_1:
; }
; // Verifica se o arquivo existe
; if (fsFindInDir(vfilename, TYPE_FILE) < ERRO_D_START)
       pea       2
       move.l    D3,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       bhs.s     fsLoadSerialToFile_4
; {
; // Se existir, apaga
; fsDelFile(vfilename);
       move.l    D3,-(A7)
       jsr       _fsDelFile
       addq.w    #4,A7
fsLoadSerialToFile_4:
; }
; // Cria o Arquivo
; fsCreateFile(vfilename);
       move.l    D3,-(A7)
       jsr       _fsCreateFile
       addq.w    #4,A7
; // Recebe os dados via Serial
; if (!loadSerialToMem2(vPosMem, 1))
       pea       1
       move.l    12(A6),-(A7)
       move.l    1210,A0
       jsr       (A0)
       addq.w    #8,A7
       tst.b     D0
       bne       fsLoadSerialToFile_6
; {
; // Abre Arquivo
; printText("Opening File...\r\n\0");
       pea       @mmsjos_64.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fsOpenFile(vfilename);
       move.l    D3,-(A7)
       jsr       _fsOpenFile
       addq.w    #4,A7
; // Grava no Arquivo
; printText("Writing File...\r\n\0");
       pea       @mmsjos_65.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printChar(218,1);
       pea       1
       pea       218
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; for (ix = 0; ix < 20; ix++)
       clr.l     D2
fsLoadSerialToFile_8:
       cmp.l     #20,D2
       bhs.s     fsLoadSerialToFile_10
; printChar(196,1);
       pea       1
       pea       196
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       fsLoadSerialToFile_8
fsLoadSerialToFile_10:
; printChar(191,1);
       pea       1
       pea       191
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printChar(179,1);
       pea       1
       pea       179
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; for (ix = 0; ix < 20; ix++)
       clr.l     D2
fsLoadSerialToFile_11:
       cmp.l     #20,D2
       bhs.s     fsLoadSerialToFile_13
; printChar(' ',1);
       pea       1
       pea       32
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       fsLoadSerialToFile_11
fsLoadSerialToFile_13:
; printChar(179,1);
       pea       1
       pea       179
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printChar(192,1);
       pea       1
       pea       192
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; for (ix = 0; ix < 20; ix++)
       clr.l     D2
fsLoadSerialToFile_14:
       cmp.l     #20,D2
       bhs.s     fsLoadSerialToFile_16
; printChar(196,1);
       pea       1
       pea       196
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       fsLoadSerialToFile_14
fsLoadSerialToFile_16:
; printChar(217,1);
       pea       1
       pea       217
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; vcursor = vdp_get_cursor();
       move.l    A2,A0
       move.l    A0,-(A7)
       move.l    1170,A1
       jsr       (A1)
       move.l    (A7)+,A0
       move.l    D0,A1
       move.l    (A1)+,(A0)+
; vmovposyatu = vcursor.y;
       move.l    A2,D0
       move.l    D0,A0
       move.b    1(A0),D6
; vStep = vSizeTotalRec / 20;
       move.l    D5,-(A7)
       pea       20
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-136(A6)
; vdp_set_cursor(1, (vcursor.y - 2));
       move.l    A2,D1
       move.l    D1,A0
       move.b    1(A0),D1
       subq.b    #2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       1
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; for (ix = 0; ix < vSizeTotalRec; ix += 128)
       clr.l     D2
fsLoadSerialToFile_17:
       cmp.l     D5,D2
       bhs       fsLoadSerialToFile_19
; {
; for (iy = 0; iy < 128; iy++)
       clr.l     D4
fsLoadSerialToFile_20:
       cmp.l     #128,D4
       bge       fsLoadSerialToFile_22
; {
; if (ix > 0 && ((ix + iy) % vStep) == 0)
       cmp.l     #0,D2
       bls.s     fsLoadSerialToFile_23
       move.l    D2,D0
       add.l     D4,D0
       move.l    D0,-(A7)
       move.l    -136(A6),-(A7)
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     fsLoadSerialToFile_23
; printChar(254, 1);
       pea       1
       pea       254
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
fsLoadSerialToFile_23:
; vBuffer[iy] = *xaddress;
       move.l    D7,A0
       lea       -132(A6),A1
       move.b    (A0),0(A1,D4.L)
; xaddress += 1;
       addq.l    #1,D7
       addq.l    #1,D4
       bra       fsLoadSerialToFile_20
fsLoadSerialToFile_22:
; }
; if (fsWriteFile(vfilename, ix, vBuffer, 128) != RETURN_OK)
       pea       128
       pea       -132(A6)
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       jsr       _fsWriteFile
       add.w     #16,A7
       tst.b     D0
       beq.s     fsLoadSerialToFile_25
; return ERRO_B_WRITE_FILE;
       move.b    #237,D0
       bra       fsLoadSerialToFile_3
fsLoadSerialToFile_25:
       add.l     #128,D2
       bra       fsLoadSerialToFile_17
fsLoadSerialToFile_19:
; }
; vdp_set_cursor(0, vmovposyatu);
       and.l     #255,D6
       move.l    D6,-(A7)
       clr.l     -(A7)
       move.l    1118,A0
       jsr       (A0)
       addq.w    #8,A7
; // Fecha Arquivo
; printText("\r\nClosing File...\r\n\0");
       pea       @mmsjos_66.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; fsCloseFile(vfilename, 0);
       clr.l     -(A7)
       move.l    D3,-(A7)
       jsr       _fsCloseFile
       addq.w    #8,A7
       bra.s     fsLoadSerialToFile_7
fsLoadSerialToFile_6:
; }
; else
; {
; printText("Serial Load Error...");
       pea       @mmsjos_67.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return ERRO_B_WRITE_FILE;
       move.b    #237,D0
       bra.s     fsLoadSerialToFile_3
fsLoadSerialToFile_7:
; }
; return RETURN_OK;
       clr.b     D0
fsLoadSerialToFile_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsLoadSerialToRun(char * vfilename)
; {
       xdef      _fsLoadSerialToRun
_fsLoadSerialToRun:
       link      A6,#-164
       move.l    D2,-(A7)
; unsigned long vSize, ix, vStep;
; unsigned char vBuffer[128], sqtdtam[20];
; int iy;
; unsigned char *vEnderExec;
; vEnderExec = malloc(1024);
       pea       1024
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,D2
; // Recebe os dados via Serial
; if (!loadSerialToMem2(vEnderExec, 1))
       pea       1
       move.l    D2,-(A7)
       move.l    1210,A0
       jsr       (A0)
       addq.w    #8,A7
       tst.b     D0
       bne       fsLoadSerialToRun_1
; {
; itoa(vEnderExec,sqtdtam,16);
       pea       16
       pea       -24(A6)
       move.l    D2,-(A7)
       jsr       _itoa
       add.w     #12,A7
; printText("Running at \0");
       pea       @mmsjos_68.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText(sqtdtam);
       pea       -24(A6)
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; printText("h\r\n\0");
       pea       @mmsjos_57.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; runOSMemory = vEnderExec;
       move.l    D2,_runOSMemory.L
; runFromOsCmd();
       jsr       _runFromOsCmd
; free(vEnderExec);
       move.l    D2,-(A7)
       jsr       _free
       addq.w    #4,A7
       bra.s     fsLoadSerialToRun_2
fsLoadSerialToRun_1:
; }
; else
; {
; printText("Serial Load Error...");
       pea       @mmsjos_67.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return ERRO_B_WRITE_FILE;
       move.b    #237,D0
       bra.s     fsLoadSerialToRun_3
fsLoadSerialToRun_2:
; }
; return RETURN_OK;
       clr.b     D0
fsLoadSerialToRun_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; // Rotina para escrever/ler no disco
; //-------------------------------------------------------------------------
; unsigned char fsRWFile(unsigned long vclusterini, unsigned long voffset, unsigned char *buffer, unsigned char vtype)
; {
       xdef      _fsRWFile
_fsRWFile:
       link      A6,#-528
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.b    23(A6),D4
       and.l     #255,D4
       lea       _vdisk.L,A2
       lea       _gDataBuffer.L,A3
       move.l    8(A6),D6
       move.l    16(A6),A5
; unsigned long vdata, vclusternew, vfat;
; unsigned short vpos, vsecfat, voffsec, voffclus, vtemp1, vtemp2, ikk, ikj;
; unsigned char vSectorSwap[MEDIA_SECTOR_SIZE];
; unsigned short vSwapSize;
; vSwapSize = vdisk.sectorSize;
       move.w    22(A2),-2(A6)
; if (vSwapSize > MEDIA_SECTOR_SIZE)
       move.w    -2(A6),D0
       cmp.w     #512,D0
       bls.s     fsRWFile_1
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra       fsRWFile_3
fsRWFile_1:
; // Calcula offset de setor e cluster
; voffsec = voffset / vdisk.sectorSize;
       move.w    22(A2),D0
       and.l     #65535,D0
       move.l    12(A6),-(A7)
       move.l    D0,-(A7)
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,-522(A6)
; voffclus = voffsec / vdisk.SecPerClus;
       move.w    -522(A6),D0
       move.b    31(A2),D1
       and.w     #255,D1
       and.l     #65535,D0
       divu.w    D1,D0
       move.w    D0,-520(A6)
; vclusternew = vclusterini;
       move.l    D6,D2
; // Procura o cluster onde esta o setor a ser lido
; for (vpos = 0; vpos < voffclus; vpos++) {
       clr.w     D3
fsRWFile_4:
       cmp.w     -520(A6),D3
       bhs       fsRWFile_6
; // Em operacao de escrita, preserva o buffer em RAM porque funcoes FAT usam gDataBuffer.
; if (vtype == OPER_WRITE) {
       cmp.b     #2,D4
       bne.s     fsRWFile_7
; memcpy(vSectorSwap, buffer, vSwapSize);
       move.w    -2(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.l    A5,-(A7)
       pea       -514(A6)
       jsr       _memcpy
       add.w     #12,A7
fsRWFile_7:
; }
; vclusternew = fsFindNextCluster(vclusterini, NEXT_FIND);
       pea       5
       move.l    D6,-(A7)
       jsr       _fsFindNextCluster
       addq.w    #8,A7
       move.l    D0,D2
; // Se for leitura e o offset der dentro do ultimo cluster, sai
; if (vtype == OPER_READ && vclusternew == LAST_CLUSTER_FAT32)
       cmp.b     #1,D4
       bne.s     fsRWFile_9
       cmp.l     #268435455,D2
       bne.s     fsRWFile_9
; return RETURN_OK;
       clr.b     D0
       bra       fsRWFile_3
fsRWFile_9:
; // Se for gravacao e o offset der dentro do ultimo cluster, cria novo cluster
; if ((vtype == OPER_WRITE || vtype == OPER_READWRITE) && vclusternew == LAST_CLUSTER_FAT32) {
       cmp.b     #2,D4
       beq.s     fsRWFile_13
       cmp.b     #3,D4
       bne       fsRWFile_18
fsRWFile_13:
       cmp.l     #268435455,D2
       bne       fsRWFile_18
; // Calcula novo cluster livre
; vclusternew = fsFindClusterFree(FREE_USE);
       pea       2
       jsr       _fsFindClusterFree
       addq.w    #4,A7
       move.l    D0,D2
; if (vclusternew == ERRO_D_DISK_FULL)
       cmp.l     #-12,D2
       bne.s     fsRWFile_14
; return ERRO_B_DISK_FULL;
       move.b    #235,D0
       bra       fsRWFile_3
fsRWFile_14:
; // Procura Cluster atual para altera?o
; vsecfat = vclusterini / 128;
       move.l    D6,-(A7)
       pea       128
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,-524(A6)
; vfat = vdisk.fat + vsecfat;
       move.l    4(A2),D0
       move.w    -524(A6),D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    D0,-528(A6)
; if (!fsSectorRead(vfat, gDataBuffer))
       move.l    A3,-(A7)
       move.l    -528(A6),-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsRWFile_16
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra       fsRWFile_3
fsRWFile_16:
; // Grava novo cluster no cluster atual
; vpos = (vclusterini - ( 128 * vsecfat)) * 4;
       move.l    D6,D0
       move.w    -524(A6),D1
       mulu.w    #128,D1
       and.l     #65535,D1
       sub.l     D1,D0
       move.l    D0,-(A7)
       pea       4
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,D3
; gDataBuffer[vpos] = (unsigned char)(vclusternew & 0xFF);
       move.l    D2,D0
       and.l     #255,D0
       and.l     #65535,D3
       move.b    D0,0(A3,D3.L)
; ikk = vpos + 1;
       move.w    D3,D0
       addq.w    #1,D0
       move.w    D0,D5
; gDataBuffer[ikk] = (unsigned char)((vclusternew / 0x100) & 0xFF);
       move.l    D2,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D5
       move.b    D0,0(A3,D5.L)
; ikk = vpos + 2;
       move.w    D3,D0
       addq.w    #2,D0
       move.w    D0,D5
; gDataBuffer[ikk] = (unsigned char)((vclusternew / 0x10000) & 0xFF);
       move.l    D2,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D5
       move.b    D0,0(A3,D5.L)
; ikk = vpos + 3;
       move.w    D3,D0
       addq.w    #3,D0
       move.w    D0,D5
; gDataBuffer[ikk] = (unsigned char)((vclusternew / 0x1000000) & 0xFF);
       move.l    D2,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D5
       move.b    D0,0(A3,D5.L)
; if (fsWriteFatSector(vfat) != RETURN_OK)
       move.l    -528(A6),-(A7)
       jsr       @mmsjos_fsWriteFatSector
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsRWFile_18
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra       fsRWFile_3
fsRWFile_18:
; }
; vclusterini = vclusternew;
       move.l    D2,D6
; // Em operacao de escrita, restaura o buffer salvo em RAM.
; if (vtype == OPER_WRITE) {
       cmp.b     #2,D4
       bne.s     fsRWFile_20
; memcpy(buffer, vSectorSwap, vSwapSize);
       move.w    -2(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       pea       -514(A6)
       move.l    A5,-(A7)
       jsr       _memcpy
       add.w     #12,A7
fsRWFile_20:
       addq.w    #1,D3
       bra       fsRWFile_4
fsRWFile_6:
; }
; }
; // Posiciona no setor dentro do cluster para ler/gravar
; vtemp1 = ((vclusternew - 2) * vdisk.SecPerClus);
       move.l    D2,D0
       subq.l    #2,D0
       move.b    31(A2),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,A4
; vtemp2 = vdisk.data;
       move.l    12(A2),D0
       move.w    D0,-518(A6)
; vdata = vtemp1 + vtemp2;
       move.l    A4,D0
       move.w    -518(A6),D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    D0,D7
; vtemp1 = (voffclus * vdisk.SecPerClus);
       move.w    -520(A6),D0
       move.b    31(A2),D1
       and.w     #255,D1
       mulu.w    D1,D0
       move.w    D0,A4
; vdata += voffsec - vtemp1;
       move.w    -522(A6),D0
       and.l     #65535,D0
       sub.l     A4,D0
       add.l     D0,D7
; if (vtype == OPER_READ || vtype == OPER_READWRITE) {
       cmp.b     #1,D4
       beq.s     fsRWFile_24
       cmp.b     #3,D4
       bne.s     fsRWFile_22
fsRWFile_24:
; // Le o setor e coloca no buffer
; if (!fsSectorRead(vdata, buffer))
       move.l    A5,-(A7)
       move.l    D7,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsRWFile_25
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra.s     fsRWFile_3
fsRWFile_25:
       bra.s     fsRWFile_27
fsRWFile_22:
; }
; else {
; // Grava o buffer no setor
; if (!fsSectorWrite(vdata, buffer, FALSE))
       clr.l     -(A7)
       move.l    A5,-(A7)
       move.l    D7,-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     fsRWFile_27
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra.s     fsRWFile_3
fsRWFile_27:
; }
; return RETURN_OK;
       clr.b     D0
fsRWFile_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; // Retorna um buffer de "vsize" (max 255) Bytes, a partir do "voffset".
; //-------------------------------------------------------------------------
; unsigned short fsReadFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer)
; {
       xdef      _fsReadFile
_fsReadFile:
       link      A6,#-20
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.l    12(A6),D2
       lea       _vdisk.L,A2
       move.w    22(A6),D7
       and.l     #65535,D7
; unsigned short ix, iy, vsizebf = 0;
       clr.w     D5
; unsigned short vsize, vsetor = 0, vsizeant = 0;
       move.w    #0,A5
       move.w    #0,A4
; unsigned short voffsec, vtemp, ikk, ikj;
; unsigned long vclusterini;
; unsigned char sqtdtam[10];
; vclusterini = fsFindInDir(vfilename, TYPE_FILE);
       pea       2
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       move.l    D0,-14(A6)
; if (vclusterini >= ERRO_D_START)
       move.l    -14(A6),D0
       cmp.l     #-16,D0
       blo.s     fsReadFile_1
; return 0;	// Erro na abertura/Arquivo nao existe
       clr.w     D0
       bra       fsReadFile_3
fsReadFile_1:
; // Verifica se o offset eh maior ou igual ao tamanho do arquivo
; if (voffset >= vdir.Size)
       cmp.l     _vdir+26.L,D2
       blo.s     fsReadFile_4
; return 0;
       clr.w     D0
       bra       fsReadFile_3
fsReadFile_4:
; // Verifica se offset vai precisar gravar mais de 1 setor (entre 2 setores)
; vtemp = voffset / vdisk.sectorSize;
       move.w    22(A2),D0
       and.l     #65535,D0
       move.l    D2,-(A7)
       move.l    D0,-(A7)
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,A3
; voffsec = (voffset - (vdisk.sectorSize * (vtemp)));
       move.l    D2,D0
       move.w    22(A2),D1
       move.l    D0,-(A7)
       move.w    A3,D0
       mulu.w    D0,D1
       move.l    (A7)+,D0
       and.l     #65535,D1
       sub.l     D1,D0
       move.w    D0,D4
; if ((voffsec + vsizebuffer) > vdisk.sectorSize)
       move.w    D4,D0
       add.w     D7,D0
       cmp.w     22(A2),D0
       bls.s     fsReadFile_6
; vsetor = 1;
       move.w    #1,A5
fsReadFile_6:
; /*itoa(vsetor, sqtdtam, 10);
; printText(sqtdtam, *vcorf, *vcorb);
; printText(".\n\0");*/
; /*itoa(voffsec, sqtdtam, 10);
; printText(sqtdtam, *vcorf, *vcorb);
; printText(".\n\0");*/
; /*itoa(vdisk.sectorSize, sqtdtam, 10);
; printText(sqtdtam, *vcorf, *vcorb);
; printText(".\n\0");*/
; /*itoa(voffset, sqtdtam, 10);
; printText(sqtdtam, *vcorf, *vcorb);
; printText(".\n\0");*/
; /*itoa(vsizebuffer, sqtdtam, 10);
; printText(sqtdtam, *vcorf, *vcorb);
; printText(".\n\0");*/
; for (ix = 0; ix <= vsetor; ix++) {
       clr.w     -20(A6)
fsReadFile_8:
       move.w    A5,D0
       cmp.w     -20(A6),D0
       blo       fsReadFile_10
; vtemp = voffset / vdisk.sectorSize;
       move.w    22(A2),D0
       and.l     #65535,D0
       move.l    D2,-(A7)
       move.l    D0,-(A7)
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,A3
; voffsec = (voffset - (vdisk.sectorSize * (vtemp)));
       move.l    D2,D0
       move.w    22(A2),D1
       move.l    D0,-(A7)
       move.w    A3,D0
       mulu.w    D0,D1
       move.l    (A7)+,D0
       and.l     #65535,D1
       sub.l     D1,D0
       move.w    D0,D4
; // Ler setor do offset
; if (fsRWFile(vclusterini, voffset, gDataBuffer, OPER_READ) != RETURN_OK)
       pea       1
       pea       _gDataBuffer.L
       move.l    D2,-(A7)
       move.l    -14(A6),-(A7)
       jsr       _fsRWFile
       add.w     #16,A7
       tst.b     D0
       beq.s     fsReadFile_11
; return vsizebf;
       move.w    D5,D0
       bra       fsReadFile_3
fsReadFile_11:
; // Verifica tamanho a ser gravado
; if ((voffsec + vsizebuffer) <= vdisk.sectorSize)
       move.w    D4,D0
       add.w     D7,D0
       cmp.w     22(A2),D0
       bhi.s     fsReadFile_13
; vsize = vsizebuffer - vsizeant;
       move.w    D7,D0
       sub.w     A4,D0
       move.w    D0,D3
       bra.s     fsReadFile_14
fsReadFile_13:
; else
; vsize = vdisk.sectorSize - voffsec;
       move.w    22(A2),D0
       sub.w     D4,D0
       move.w    D0,D3
fsReadFile_14:
; vsizebf += vsize;
       add.w     D3,D5
; if (vsizebf > (vdir.Size - voffset))
       and.l     #65535,D5
       move.l    _vdir+26.L,D0
       sub.l     D2,D0
       cmp.l     D0,D5
       bls.s     fsReadFile_15
; vsizebf = vdir.Size - voffset;
       move.l    _vdir+26.L,D0
       sub.l     D2,D0
       move.w    D0,D5
fsReadFile_15:
; /*itoa(vsize, sqtdtam, 10);
; printText(sqtdtam, *vcorf, *vcorb);
; printText(".\n\0");*/
; if (vsetor == 0)
       move.w    A5,D0
       bne.s     fsReadFile_17
; vsize = vsizebuffer;
       move.w    D7,D3
fsReadFile_17:
; // Retorna os dados no buffer
; for (iy = 0; iy < vsize; iy++) {
       clr.w     D6
fsReadFile_19:
       cmp.w     D3,D6
       bhs.s     fsReadFile_21
; ikk = vsizeant + iy;
       move.w    A4,D0
       add.w     D6,D0
       move.w    D0,-18(A6)
; ikj = voffsec + iy;
       move.w    D4,D0
       add.w     D6,D0
       move.w    D0,-16(A6)
; buffer[ikk] = gDataBuffer[ikj];
       move.w    -16(A6),D0
       and.l     #65535,D0
       lea       _gDataBuffer.L,A0
       move.l    16(A6),A1
       move.w    -18(A6),D1
       and.l     #65535,D1
       move.b    0(A0,D0.L),0(A1,D1.L)
       addq.w    #1,D6
       bra       fsReadFile_19
fsReadFile_21:
; }
; vsizeant = vsize;
       move.w    D3,A4
; voffset += vsize;
       and.l     #65535,D3
       add.l     D3,D2
       addq.w    #1,-20(A6)
       bra       fsReadFile_8
fsReadFile_10:
; }
; return vsizebf;
       move.w    D5,D0
fsReadFile_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; // buffer a ser gravado nao pode ter mais que 512 bytes
; //-------------------------------------------------------------------------
; unsigned char fsWriteFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer)
; {
       xdef      _fsWriteFile
_fsWriteFile:
       link      A6,#-8
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.l    12(A6),D2
       lea       _vdisk.L,A2
       move.b    23(A6),D6
       and.w     #255,D6
       lea       _gDataBuffer.L,A5
; unsigned char vsetor = 0, ix, iy;
       clr.b     -6(A6)
; unsigned short vsize, vsizeant = 0;
       move.w    #0,A4
; unsigned short voffsec, vtemp, ikk, ikj;
; unsigned long vclusterini;
; vclusterini = fsFindInDir(vfilename, TYPE_FILE);
       pea       2
       move.l    8(A6),-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       move.l    D0,A3
; if (vclusterini >= ERRO_D_START)
       move.l    A3,D0
       cmp.l     #-16,D0
       blo.s     fsWriteFile_1
; return ERRO_B_FILE_NOT_FOUND;	// Erro na abertura/Arquivo nao existe
       move.b    #224,D0
       bra       fsWriteFile_3
fsWriteFile_1:
; // Verifica se offset vai precisar gravar mais de 1 setor (entre 2 setores)
; vtemp = voffset / vdisk.sectorSize;
       move.w    22(A2),D0
       and.l     #65535,D0
       move.l    D2,-(A7)
       move.l    D0,-(A7)
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,D7
; voffsec = (voffset - (vdisk.sectorSize * (vtemp)));
       move.l    D2,D0
       move.w    22(A2),D1
       mulu.w    D7,D1
       and.l     #65535,D1
       sub.l     D1,D0
       move.w    D0,D3
; if ((voffsec + vsizebuffer) > vdisk.sectorSize)
       move.w    D3,D0
       and.w     #255,D6
       add.w     D6,D0
       cmp.w     22(A2),D0
       bls.s     fsWriteFile_4
; vsetor = 1;
       move.b    #1,-6(A6)
fsWriteFile_4:
; for (ix = 0; ix <= vsetor; ix++) {
       clr.b     -5(A6)
fsWriteFile_6:
       move.b    -5(A6),D0
       cmp.b     -6(A6),D0
       bhi       fsWriteFile_8
; vtemp = voffset / vdisk.sectorSize;
       move.w    22(A2),D0
       and.l     #65535,D0
       move.l    D2,-(A7)
       move.l    D0,-(A7)
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,D7
; voffsec = (voffset - (vdisk.sectorSize * (vtemp)));
       move.l    D2,D0
       move.w    22(A2),D1
       mulu.w    D7,D1
       and.l     #65535,D1
       sub.l     D1,D0
       move.w    D0,D3
; //*tempData = vclusterini;
; // Ler setor do offset
; if (fsRWFile(vclusterini, voffset, gDataBuffer, OPER_READWRITE) != RETURN_OK)
       pea       3
       move.l    A5,-(A7)
       move.l    D2,-(A7)
       move.l    A3,-(A7)
       jsr       _fsRWFile
       add.w     #16,A7
       tst.b     D0
       beq.s     fsWriteFile_9
; return ERRO_B_READ_FILE;
       move.b    #236,D0
       bra       fsWriteFile_3
fsWriteFile_9:
; //memcpy(tempData2,gDataBuffer,512);
; // Verifica tamanho a ser gravado
; if ((voffsec + vsizebuffer) <= vdisk.sectorSize)
       move.w    D3,D0
       and.w     #255,D6
       add.w     D6,D0
       cmp.w     22(A2),D0
       bhi.s     fsWriteFile_11
; vsize = vsizebuffer - vsizeant;
       move.b    D6,D0
       and.w     #255,D0
       sub.w     A4,D0
       move.w    D0,D5
       bra.s     fsWriteFile_12
fsWriteFile_11:
; else
; vsize = vdisk.sectorSize - voffsec;
       move.w    22(A2),D0
       sub.w     D3,D0
       move.w    D0,D5
fsWriteFile_12:
; // Prepara buffer para grava?o
; for (iy = 0; iy < vsize; iy++) {
       clr.b     D4
fsWriteFile_13:
       and.w     #255,D4
       cmp.w     D5,D4
       bhs       fsWriteFile_15
; ikk = iy + voffsec;
       move.b    D4,D0
       and.w     #255,D0
       add.w     D3,D0
       move.w    D0,-4(A6)
; ikj = vsizeant + iy;
       move.w    A4,D0
       and.w     #255,D4
       add.w     D4,D0
       move.w    D0,-2(A6)
; gDataBuffer[ikk] = buffer[ikj];
       move.l    16(A6),A0
       move.w    -2(A6),D0
       and.l     #65535,D0
       move.w    -4(A6),D1
       and.l     #65535,D1
       move.b    0(A0,D0.L),0(A5,D1.L)
       addq.b    #1,D4
       bra       fsWriteFile_13
fsWriteFile_15:
; }
; //*(tempData + 1) = vclusterini;
; //memcpy(tempData3,gDataBuffer,512);
; // Grava setor
; if (fsRWFile(vclusterini, voffset, gDataBuffer, OPER_WRITE) != RETURN_OK)
       pea       2
       move.l    A5,-(A7)
       move.l    D2,-(A7)
       move.l    A3,-(A7)
       jsr       _fsRWFile
       add.w     #16,A7
       tst.b     D0
       beq.s     fsWriteFile_16
; return ERRO_B_WRITE_FILE;
       move.b    #237,D0
       bra       fsWriteFile_3
fsWriteFile_16:
; vsizeant = vsize;
       move.w    D5,A4
; if (vsetor == 1)
       move.b    -6(A6),D0
       cmp.b     #1,D0
       bne.s     fsWriteFile_18
; voffset += vsize;
       and.l     #65535,D5
       add.l     D5,D2
fsWriteFile_18:
       addq.b    #1,-5(A6)
       bra       fsWriteFile_6
fsWriteFile_8:
; }
; if ((voffset + vsizebuffer) > vdir.Size) {
       move.l    D2,D0
       and.l     #255,D6
       add.l     D6,D0
       cmp.l     _vdir+26.L,D0
       bls.s     fsWriteFile_22
; vdir.Size = voffset + vsizebuffer;
       move.l    D2,D0
       and.l     #255,D6
       add.l     D6,D0
       move.l    D0,_vdir+26.L
; if (fsUpdateDir() != RETURN_OK)
       jsr       _fsUpdateDir
       tst.b     D0
       beq.s     fsWriteFile_22
; return ERRO_B_UPDATE_DIR;
       move.b    #233,D0
       bra.s     fsWriteFile_3
fsWriteFile_22:
; }
; return RETURN_OK;
       clr.b     D0
fsWriteFile_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsMakeDir(char * vdirname)
; {
       xdef      _fsMakeDir
_fsMakeDir:
       link      A6,#0
       movem.l   A2/A3,-(A7)
       lea       _vretpath.L,A2
       lea       _vclusterdir.L,A3
; if (fsFindDirPath(vdirname, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
       clr.l     -(A7)
       move.l    8(A6),-(A7)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     fsMakeDir_1
; return ERRO_B_CREATE_DIR;
       move.b    #239,D0
       bra       fsMakeDir_3
fsMakeDir_1:
; if (!isValidFilename(vretpath.Name))
       move.l    A2,-(A7)
       jsr       _isValidFilename
       addq.w    #4,A7
       tst.l     D0
       bne.s     fsMakeDir_4
; return ERRO_B_INVALID_NAME;
       move.b    #228,D0
       bra       fsMakeDir_3
fsMakeDir_4:
; vclusterdir = vretpath.ClusterDir;
       move.l    14(A2),(A3)
; // Verifica ja existe arquivo/dir com esse nome
; if (fsFindInDir(vretpath.Name, TYPE_ALL) < ERRO_D_START)
       pea       255
       move.l    A2,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       bhs.s     fsMakeDir_6
; {
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),(A3)
; return ERRO_B_DIR_FOUND;
       move.b    #238,D0
       bra.s     fsMakeDir_3
fsMakeDir_6:
; }
; // Cria o dir solicitado
; if (fsFindInDir(vretpath.Name, TYPE_CREATE_DIR) >= ERRO_D_START)
       pea       5
       move.l    A2,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsMakeDir_8
; {
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),(A3)
; return ERRO_B_CREATE_DIR;
       move.b    #239,D0
       bra.s     fsMakeDir_3
fsMakeDir_8:
; }
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),(A3)
; return RETURN_OK;
       clr.b     D0
fsMakeDir_3:
       movem.l   (A7)+,A2/A3
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; // [<folder>/<folder>/<folder>/]<file>
; //-------------------------------------------------------------------------
; unsigned char fsFindDirPath(char * vpath, char vtype)
; {
       xdef      _fsFindDirPath
_fsFindDirPath:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/D7/A2,-(A7)
       lea       _vclusterdir.L,A2
       move.l    8(A6),D4
; unsigned long vclusterdirnew, vclusterdirant;
; int ix, iy;
; unsigned char vret = FIND_PATH_RET_FOLDER;
       moveq     #1,D5
; vclusterdirant = vclusterdir;
       move.l    (A2),D7
; vclusterdirnew = vclusterdir;
       move.l    (A2),D2
; vretpath.ClusterDirAtu = vclusterdir;
       move.l    (A2),_vretpath+18.L
; ix = 0;
       clr.l     D3
; // Verifica se eh diretorio raiz
; if (vpath[0] == '/')
       move.l    D4,A0
       move.b    (A0),D0
       cmp.b     #47,D0
       bne.s     fsFindDirPath_1
; {
; vclusterdirnew = vdisk.root;
       move.l    _vdisk+8.L,D2
; vclusterdir = vclusterdirnew;
       move.l    D2,(A2)
; ix++;
       addq.l    #1,D3
fsFindDirPath_1:
; }
; // Loop ateh a ultima pasta
; if (vpath[1] != 0x00)
       move.l    D4,A0
       move.b    1(A0),D0
       beq       fsFindDirPath_7
; {
; while(1)
fsFindDirPath_5:
; {
; iy = 0;
       clr.l     D6
; while(vpath[ix] != 0x00 && vpath[ix] != '/')
fsFindDirPath_8:
       move.l    D4,A0
       move.b    0(A0,D3.L),D0
       beq.s     fsFindDirPath_10
       move.l    D4,A0
       move.b    0(A0,D3.L),D0
       cmp.b     #47,D0
       beq.s     fsFindDirPath_10
; {
; vretpath.Name[iy] = vpath[ix];
       move.l    D4,A0
       lea       _vretpath.L,A1
       move.b    0(A0,D3.L),0(A1,D6.L)
; ix++;
       addq.l    #1,D3
; iy++;
       addq.l    #1,D6
       bra       fsFindDirPath_8
fsFindDirPath_10:
; }
; vretpath.Name[iy] = '\0';
       lea       _vretpath.L,A0
       clr.b     0(A0,D6.L)
; if (vpath[ix] == 0x00 && vtype == FIND_PATH_PART)
       move.l    D4,A0
       move.b    0(A0,D3.L),D0
       bne.s     fsFindDirPath_11
       move.b    15(A6),D0
       bne.s     fsFindDirPath_11
; break;
       bra       fsFindDirPath_7
fsFindDirPath_11:
; vclusterdirnew = fsFindInDir(vretpath.Name, TYPE_DIRECTORY);
       pea       1
       pea       _vretpath.L
       jsr       _fsFindInDir
       addq.w    #8,A7
       move.l    D0,D2
; if (vclusterdir != 2 && vclusterdirnew == 0 && vretpath.Name[0] == '.' && vretpath.Name[1] == '.')
       move.l    (A2),D0
       cmp.l     #2,D0
       beq.s     fsFindDirPath_13
       tst.l     D2
       bne.s     fsFindDirPath_13
       move.b    _vretpath.L,D0
       cmp.b     #46,D0
       bne.s     fsFindDirPath_13
       move.b    _vretpath+1.L,D0
       cmp.b     #46,D0
       bne.s     fsFindDirPath_13
; vclusterdirnew = 2;
       moveq     #2,D2
fsFindDirPath_13:
; if (vclusterdirnew >= ERRO_D_START)
       cmp.l     #-16,D2
       blo.s     fsFindDirPath_15
; {
; if (fsFindInDir(vretpath.Name, TYPE_FILE) >= ERRO_D_START)
       pea       2
       pea       _vretpath.L
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsFindDirPath_17
; {
; vret = FIND_PATH_RET_ERROR;
       move.b    #255,D5
; //                    vretpath.ClusterDir = ERRO_D_START;
; vretpath.ClusterDir = vclusterdir;
       move.l    (A2),_vretpath+14.L
       bra.s     fsFindDirPath_18
fsFindDirPath_17:
; }
; else
; {
; vret = FIND_PATH_RET_FILE;
       moveq     #2,D5
; vretpath.ClusterDir = vclusterdir;
       move.l    (A2),_vretpath+14.L
fsFindDirPath_18:
; }
; vclusterdir = vclusterdirant;
       move.l    D7,(A2)
; return vret;
       move.b    D5,D0
       bra.s     fsFindDirPath_19
fsFindDirPath_15:
; }
; vclusterdir = vclusterdirnew;
       move.l    D2,(A2)
; vretpath.ClusterDir = vclusterdirnew;
       move.l    D2,_vretpath+14.L
; if (vpath[ix] == 0x00)
       move.l    D4,A0
       move.b    0(A0,D3.L),D0
       bne.s     fsFindDirPath_20
; break;
       bra.s     fsFindDirPath_7
fsFindDirPath_20:
; ix++;
       addq.l    #1,D3
       bra       fsFindDirPath_5
fsFindDirPath_7:
; }
; }
; vclusterdir = vclusterdirant;
       move.l    D7,(A2)
; vretpath.ClusterDir = vclusterdirnew;
       move.l    D2,_vretpath+14.L
; return vret;
       move.b    D5,D0
fsFindDirPath_19:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsChangeDir(char * vdirname)
; {
       xdef      _fsChangeDir
_fsChangeDir:
       link      A6,#0
       move.l    D2,-(A7)
; unsigned long vclusterdirnew;
; // Troca o diretorio conforme especificado
; /*if (vdirname[0] == '/' && vdirname[1] == '\0')
; vclusterdirnew = vdisk.root;
; else
; {*/
; if (fsFindDirPath(vdirname, FIND_PATH_LAST) == FIND_PATH_RET_ERROR)
       pea       1
       move.l    8(A6),-(A7)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     fsChangeDir_1
; return ERRO_B_DIR_NOT_FOUND;
       move.b    #229,D0
       bra.s     fsChangeDir_3
fsChangeDir_1:
; vclusterdirnew = vretpath.ClusterDir;
       move.l    _vretpath+14.L,D2
; //}
; // Coloca o novo diretorio como atual
; vclusterdir = vclusterdirnew;
       move.l    D2,_vclusterdir.L
; vretpath.ClusterDirAtu = vclusterdirnew;
       move.l    D2,_vretpath+18.L
; return RETURN_OK;
       clr.b     D0
fsChangeDir_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsRemoveDir(char * vdirname)
; {
       xdef      _fsRemoveDir
_fsRemoveDir:
       link      A6,#0
       movem.l   D2/A2/A3,-(A7)
       lea       _vretpath.L,A2
       lea       _vclusterdir.L,A3
; unsigned char vretEmpty;
; if (fsFindDirPath(vdirname, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
       clr.l     -(A7)
       move.l    8(A6),-(A7)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     fsRemoveDir_1
; return ERRO_B_DIR_NOT_FOUND;
       move.b    #229,D0
       bra       fsRemoveDir_3
fsRemoveDir_1:
; vclusterdir = vretpath.ClusterDir;
       move.l    14(A2),(A3)
; /*printText("Aqui 2 - ");
; printText(vretpath.Name);
; printText("\r\n");*/
; if (fsFindInDir(vretpath.Name, TYPE_DIRECTORY) >= ERRO_D_START)
       pea       1
       move.l    A2,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsRemoveDir_4
; {
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),(A3)
; return ERRO_B_DIR_NOT_FOUND;
       move.b    #229,D0
       bra       fsRemoveDir_3
fsRemoveDir_4:
; }
; vretEmpty = fsCheckDirEmpty(vdir.FirstCluster);
       move.l    _vdir+22.L,-(A7)
       jsr       @mmsjos_fsCheckDirEmpty
       addq.w    #4,A7
       move.b    D0,D2
; if (vretEmpty != RETURN_OK)
       tst.b     D2
       beq.s     fsRemoveDir_6
; {
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),(A3)
; return vretEmpty;
       move.b    D2,D0
       bra.s     fsRemoveDir_3
fsRemoveDir_6:
; }
; // Apaga o diretorio conforme especificado
; if (fsFindInDir(vretpath.Name, TYPE_DEL_DIR) >= ERRO_D_START)
       pea       7
       move.l    A2,-(A7)
       jsr       _fsFindInDir
       addq.w    #8,A7
       cmp.l     #-16,D0
       blo.s     fsRemoveDir_8
; {
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),(A3)
; return ERRO_B_DIR_NOT_FOUND;
       move.b    #229,D0
       bra.s     fsRemoveDir_3
fsRemoveDir_8:
; }
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),(A3)
; return RETURN_OK;
       clr.b     D0
fsRemoveDir_3:
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsPwdDir(unsigned char *vdirpath) {
       xdef      _fsPwdDir
_fsPwdDir:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; if (vclusterdir == vdisk.root) {
       move.l    _vclusterdir.L,D0
       cmp.l     _vdisk+8.L,D0
       bne.s     fsPwdDir_1
; vdirpath[0] = '/';
       move.l    D2,A0
       move.b    #47,(A0)
; vdirpath[1] = '\0';
       move.l    D2,A0
       clr.b     1(A0)
       bra.s     fsPwdDir_2
fsPwdDir_1:
; }
; else {
; vdirpath[0] = 'o';
       move.l    D2,A0
       move.b    #111,(A0)
; vdirpath[1] = '\0';
       move.l    D2,A0
       clr.b     1(A0)
fsPwdDir_2:
; }
; return RETURN_OK;
       clr.b     D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; void fsGetDirAtuData(FAT32_DIR *pDir)
; {
       xdef      _fsGetDirAtuData
_fsGetDirAtuData:
       link      A6,#0
; memcpy(pDir, &vdir, sizeof(FAT32_DIR));
       pea       37
       pea       _vdir.L
       move.l    8(A6),-(A7)
       jsr       _memcpy
       add.w     #12,A7
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; static unsigned char fsCheckDirEmpty(unsigned long vdircluster)
; {
@mmsjos_fsCheckDirEmpty:
       link      A6,#-8
       movem.l   D2/D3/D4/D5/D6/A2/A3,-(A7)
       lea       _gDataBuffer.L,A2
       lea       _vdisk.L,A3
; unsigned long vclusteratual, vclusternext, vdata, vtemp1, vtemp2;
; unsigned short ix, iz;
; vclusteratual = vdircluster;
       move.l    8(A6),D4
; while (1)
@mmsjos_fsCheckDirEmpty_1:
; {
; vtemp1 = ((vclusteratual - 2) * vdisk.SecPerClus);
       move.l    D4,D0
       subq.l    #2,D0
       move.b    31(A3),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-8(A6)
; vtemp2 = vdisk.data;
       move.l    12(A3),-4(A6)
; vdata = vtemp1 + vtemp2;
       move.l    -8(A6),D0
       add.l     -4(A6),D0
       move.l    D0,D6
; for (iz = 0; iz < vdisk.SecPerClus; iz++)
       clr.w     D5
@mmsjos_fsCheckDirEmpty_4:
       move.b    31(A3),D0
       and.w     #255,D0
       cmp.w     D0,D5
       bhs       @mmsjos_fsCheckDirEmpty_6
; {
; if (!fsSectorRead(vdata, gDataBuffer))
       move.l    A2,-(A7)
       move.l    D6,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     @mmsjos_fsCheckDirEmpty_7
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra       @mmsjos_fsCheckDirEmpty_9
@mmsjos_fsCheckDirEmpty_7:
; for (ix = 0; ix < vdisk.sectorSize; ix += 32)
       clr.w     D2
@mmsjos_fsCheckDirEmpty_10:
       cmp.w     22(A3),D2
       bhs       @mmsjos_fsCheckDirEmpty_12
; {
; if (gDataBuffer[ix] == DIR_EMPTY)
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       bne.s     @mmsjos_fsCheckDirEmpty_13
; return RETURN_OK;
       clr.b     D0
       bra       @mmsjos_fsCheckDirEmpty_9
@mmsjos_fsCheckDirEmpty_13:
; if (gDataBuffer[ix] == DIR_DEL)
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       cmp.w     #229,D0
       bne.s     @mmsjos_fsCheckDirEmpty_15
; continue;
       bra       @mmsjos_fsCheckDirEmpty_11
@mmsjos_fsCheckDirEmpty_15:
; if (gDataBuffer[ix + 11] == ATTR_LONG_NAME)
       and.l     #65535,D2
       move.l    D2,A0
       move.b    11(A0,A2.L),D0
       cmp.b     #15,D0
       bne.s     @mmsjos_fsCheckDirEmpty_17
; return ERRO_B_DIR_NOT_EMPTY;
       move.b    #240,D0
       bra       @mmsjos_fsCheckDirEmpty_9
@mmsjos_fsCheckDirEmpty_17:
; if (gDataBuffer[ix] == '.' && gDataBuffer[ix + 1] == 0x20)
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       cmp.b     #46,D0
       bne.s     @mmsjos_fsCheckDirEmpty_19
       and.l     #65535,D2
       move.l    D2,A0
       move.b    1(A0,A2.L),D0
       cmp.b     #32,D0
       bne.s     @mmsjos_fsCheckDirEmpty_19
; continue;
       bra       @mmsjos_fsCheckDirEmpty_11
@mmsjos_fsCheckDirEmpty_19:
; if (gDataBuffer[ix] == '.' && gDataBuffer[ix + 1] == '.' && gDataBuffer[ix + 2] == 0x20)
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       cmp.b     #46,D0
       bne.s     @mmsjos_fsCheckDirEmpty_21
       and.l     #65535,D2
       move.l    D2,A0
       move.b    1(A0,A2.L),D0
       cmp.b     #46,D0
       bne.s     @mmsjos_fsCheckDirEmpty_21
       and.l     #65535,D2
       move.l    D2,A0
       move.b    2(A0,A2.L),D0
       cmp.b     #32,D0
       bne.s     @mmsjos_fsCheckDirEmpty_21
; continue;
       bra.s     @mmsjos_fsCheckDirEmpty_11
@mmsjos_fsCheckDirEmpty_21:
; return ERRO_B_DIR_NOT_EMPTY;
       move.b    #240,D0
       bra       @mmsjos_fsCheckDirEmpty_9
@mmsjos_fsCheckDirEmpty_11:
       add.w     #32,D2
       bra       @mmsjos_fsCheckDirEmpty_10
@mmsjos_fsCheckDirEmpty_12:
; }
; vdata++;
       addq.l    #1,D6
       addq.w    #1,D5
       bra       @mmsjos_fsCheckDirEmpty_4
@mmsjos_fsCheckDirEmpty_6:
; }
; vclusternext = fsFindNextCluster(vclusteratual, NEXT_FIND);
       pea       5
       move.l    D4,-(A7)
       jsr       _fsFindNextCluster
       addq.w    #8,A7
       move.l    D0,D3
; if (vclusternext >= ERRO_D_START)
       cmp.l     #-16,D3
       blo.s     @mmsjos_fsCheckDirEmpty_23
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra.s     @mmsjos_fsCheckDirEmpty_9
@mmsjos_fsCheckDirEmpty_23:
; if (vclusternext == LAST_CLUSTER_FAT32)
       cmp.l     #268435455,D3
       bne.s     @mmsjos_fsCheckDirEmpty_25
; break;
       bra.s     @mmsjos_fsCheckDirEmpty_3
@mmsjos_fsCheckDirEmpty_25:
; vclusteratual = vclusternext;
       move.l    D3,D4
       bra       @mmsjos_fsCheckDirEmpty_1
@mmsjos_fsCheckDirEmpty_3:
; }
; return RETURN_OK;
       clr.b     D0
@mmsjos_fsCheckDirEmpty_9:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned long fsFindInDir(char * vname, unsigned char vtype)
; {
       xdef      _fsFindInDir
_fsFindInDir:
       link      A6,#-80
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _gDataBuffer.L,A2
       lea       _vdisk.L,A3
; unsigned long vfat, vdata, vclusterfile, vclusterdirnew, vclusteratual, vtemp1, vtemp2;
; unsigned char fnameName[9], fnameExt[4];
; unsigned short im, ix, iy, iz, vpos, vsecfat, ventrydir, ixold;
; unsigned short vdirdate, vdirtime, ikk, ikj, vtemp, vbytepic;
; unsigned char vcomp, iw, ds1307[7], iww, vtempt[5], vlinha[5];
; unsigned char sqtdtam[10];
; memset(fnameName, 0x20, 8);
       pea       8
       pea       32
       pea       -64(A6)
       jsr       _memset
       add.w     #12,A7
; memset(fnameExt, 0x20, 3);
       pea       3
       pea       32
       pea       -54(A6)
       jsr       _memset
       add.w     #12,A7
; if (vname != NULL) {
       clr.b     D0
       and.l     #255,D0
       cmp.l     8(A6),D0
       beq       fsFindInDir_9
; if (vname[0] == '.' && vname[1] == '.') {
       move.l    8(A6),A0
       move.b    (A0),D0
       cmp.b     #46,D0
       bne.s     fsFindInDir_3
       move.l    8(A6),A0
       move.b    1(A0),D0
       cmp.b     #46,D0
       bne.s     fsFindInDir_3
; fnameName[0] = vname[0];
       move.l    8(A6),A0
       move.b    (A0),-64+0(A6)
; fnameName[1] = vname[1];
       move.l    8(A6),A0
       move.b    1(A0),-64+1(A6)
       bra       fsFindInDir_9
fsFindInDir_3:
; }
; else if (vname[0] == '.') {
       move.l    8(A6),A0
       move.b    (A0),D0
       cmp.b     #46,D0
       bne.s     fsFindInDir_5
; fnameName[0] = vname[0];
       move.l    8(A6),A0
       move.b    (A0),-64+0(A6)
       bra       fsFindInDir_9
fsFindInDir_5:
; }
; else {
; iy = 0;
       move.w    #0,A5
; for (ix = 0; ix <= strlen(vname); ix++) {
       clr.w     D3
fsFindInDir_7:
       and.l     #65535,D3
       move.l    8(A6),-(A7)
       jsr       _strlen
       addq.w    #4,A7
       cmp.l     D0,D3
       bhi       fsFindInDir_9
; if (vname[ix] == '\0')
       move.l    8(A6),A0
       and.l     #65535,D3
       move.b    0(A0,D3.L),D0
       bne.s     fsFindInDir_10
; break;
       bra       fsFindInDir_9
fsFindInDir_10:
; else if (vname[ix] == '.')
       move.l    8(A6),A0
       and.l     #65535,D3
       move.b    0(A0,D3.L),D0
       cmp.b     #46,D0
       bne.s     fsFindInDir_12
; iy = 8;
       move.w    #8,A5
       bra       fsFindInDir_13
fsFindInDir_12:
; else {
; for (iww = 0; iww <= 56; iww++) {
       clr.b     -23(A6)
fsFindInDir_14:
       move.b    -23(A6),D0
       cmp.b     #56,D0
       bhi.s     fsFindInDir_16
; if (strValidChars[iww] == vname[ix])
       move.b    -23(A6),D0
       and.l     #255,D0
       lea       _strValidChars.L,A0
       move.l    8(A6),A1
       and.l     #65535,D3
       move.b    0(A0,D0.L),D1
       cmp.b     0(A1,D3.L),D1
       bne.s     fsFindInDir_17
; break;
       bra.s     fsFindInDir_16
fsFindInDir_17:
       addq.b    #1,-23(A6)
       bra       fsFindInDir_14
fsFindInDir_16:
; }
; if (iww > 56)
       move.b    -23(A6),D0
       cmp.b     #56,D0
       bls.s     fsFindInDir_19
; return ERRO_D_INVALID_NAME;
       moveq     #-11,D0
       bra       fsFindInDir_21
fsFindInDir_19:
; if (iy <= 7)
       move.w    A5,D0
       cmp.w     #7,D0
       bhi.s     fsFindInDir_22
; fnameName[iy] = vname[ix];
       move.l    8(A6),A0
       and.l     #65535,D3
       move.b    0(A0,D3.L),-64(A6,A5.L)
       bra.s     fsFindInDir_23
fsFindInDir_22:
; else {
; ikk = iy - 8;
       move.w    A5,D0
       subq.w    #8,D0
       move.w    D0,D2
; fnameExt[ikk] = vname[ix];
       move.l    8(A6),A0
       and.l     #65535,D3
       and.l     #65535,D2
       move.b    0(A0,D3.L),-54(A6,D2.L)
fsFindInDir_23:
; }
; iy++;
       addq.w    #1,A5
fsFindInDir_13:
       addq.w    #1,D3
       bra       fsFindInDir_7
fsFindInDir_9:
; }
; }
; }
; }
; vfat = vdisk.fat;
       move.l    4(A3),-80(A6)
; vtemp1 = ((vclusterdir - 2) * vdisk.SecPerClus);
       move.l    _vclusterdir.L,D0
       subq.l    #2,D0
       move.b    31(A3),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-72(A6)
; vtemp2 = vdisk.data;
       move.l    12(A3),-68(A6)
; vdata = vtemp1 + vtemp2;
       move.l    -72(A6),D0
       add.l     -68(A6),D0
       move.l    D0,D4
; vclusterfile = ERRO_D_NOT_FOUND;
       moveq     #-1,D7
; vclusterdirnew = vclusterdir;
       move.l    _vclusterdir.L,D5
; ventrydir = 0;
       clr.w     -44(A6)
; while (vdata != LAST_CLUSTER_FAT32)
fsFindInDir_24:
       cmp.l     #268435455,D4
       beq       fsFindInDir_26
; {
; for (iw = 0; iw < vdisk.SecPerClus; iw++)
       clr.b     -31(A6)
fsFindInDir_27:
       move.b    -31(A6),D0
       cmp.b     31(A3),D0
       bhs       fsFindInDir_29
; {
; if (!fsSectorRead(vdata, gDataBuffer))
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsFindInDir_30
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       fsFindInDir_21
fsFindInDir_30:
; for (ix = 0; ix < vdisk.sectorSize; ix += 32)
       clr.w     D3
fsFindInDir_32:
       cmp.w     22(A3),D3
       bhs       fsFindInDir_34
; {
; for (iy = 0; iy < 8; iy++)
       move.w    #0,A5
fsFindInDir_35:
       move.w    A5,D0
       cmp.w     #8,D0
       bhs.s     fsFindInDir_37
; {
; ikk = ix + iy;
       move.w    D3,D0
       add.w     A5,D0
       move.w    D0,D2
; *(vdir.Name + iy) = gDataBuffer[ikk];
       and.l     #65535,D2
       lea       _vdir.L,A0
       move.b    0(A2,D2.L),0(A5,A0.L)
       addq.w    #1,A5
       bra       fsFindInDir_35
fsFindInDir_37:
; }
; for (iy = 0; iy < 3; iy++)
       move.w    #0,A5
fsFindInDir_38:
       move.w    A5,D0
       cmp.w     #3,D0
       bhs.s     fsFindInDir_40
; {
; ikk = ix + 8 + iy;
       move.w    D3,D0
       addq.w    #8,D0
       add.w     A5,D0
       move.w    D0,D2
; *(vdir.Ext + iy) = gDataBuffer[ikk];
       and.l     #65535,D2
       lea       _vdir.L,A0
       add.l     A5,A0
       move.b    0(A2,D2.L),8(A0)
       addq.w    #1,A5
       bra       fsFindInDir_38
fsFindInDir_40:
; }
; ikk = ix + 11;
       move.w    D3,D0
       add.w     #11,D0
       move.w    D0,D2
; vdir.Attr = gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),_vdir+11.L
; ikk = ix + 15;
       move.w    D3,D0
       add.w     #15,D0
       move.w    D0,D2
; vdir.CreateTime  = (unsigned short)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.w    D0,_vdir+14.L
; ikk = ix + 14;
       move.w    D3,D0
       add.w     #14,D0
       move.w    D0,D2
; vdir.CreateTime |= (unsigned short)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       or.w      D0,_vdir+14.L
; ikk = ix + 17;
       move.w    D3,D0
       add.w     #17,D0
       move.w    D0,D2
; vdir.CreateDate  = (unsigned short)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.w    D0,_vdir+12.L
; ikk = ix + 16;
       move.w    D3,D0
       add.w     #16,D0
       move.w    D0,D2
; vdir.CreateDate |= (unsigned short)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       or.w      D0,_vdir+12.L
; ikk = ix + 19;
       move.w    D3,D0
       add.w     #19,D0
       move.w    D0,D2
; vdir.LastAccessDate  = (unsigned short)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.w    D0,_vdir+16.L
; ikk = ix + 18;
       move.w    D3,D0
       add.w     #18,D0
       move.w    D0,D2
; vdir.LastAccessDate |= (unsigned short)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       or.w      D0,_vdir+16.L
; ikk = ix + 23;
       move.w    D3,D0
       add.w     #23,D0
       move.w    D0,D2
; vdir.UpdateTime  = (unsigned short)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.w    D0,_vdir+20.L
; ikk = ix + 22;
       move.w    D3,D0
       add.w     #22,D0
       move.w    D0,D2
; vdir.UpdateTime |= (unsigned short)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       or.w      D0,_vdir+20.L
; ikk = ix + 25;
       move.w    D3,D0
       add.w     #25,D0
       move.w    D0,D2
; vdir.UpdateDate  = (unsigned short)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       lsl.w     #8,D0
       move.w    D0,_vdir+18.L
; ikk = ix + 24;
       move.w    D3,D0
       add.w     #24,D0
       move.w    D0,D2
; vdir.UpdateDate |= (unsigned short)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.w     #255,D0
       or.w      D0,_vdir+18.L
; ikk = ix + 21;
       move.w    D3,D0
       add.w     #21,D0
       move.w    D0,D2
; vdir.FirstCluster  = (unsigned long)gDataBuffer[ikk] << 24;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,_vdir+22.L
; ikk = ix + 20;
       move.w    D3,D0
       add.w     #20,D0
       move.w    D0,D2
; vdir.FirstCluster |= (unsigned long)gDataBuffer[ikk] << 16;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,_vdir+22.L
; ikk = ix + 27;
       move.w    D3,D0
       add.w     #27,D0
       move.w    D0,D2
; vdir.FirstCluster |= (unsigned long)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,_vdir+22.L
; ikk = ix + 26;
       move.w    D3,D0
       add.w     #26,D0
       move.w    D0,D2
; vdir.FirstCluster |= (unsigned long)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       or.l      D0,_vdir+22.L
; ikk = ix + 31;
       move.w    D3,D0
       add.w     #31,D0
       move.w    D0,D2
; vdir.Size  = (unsigned long)gDataBuffer[ikk] << 24;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,_vdir+26.L
; ikk = ix + 30;
       move.w    D3,D0
       add.w     #30,D0
       move.w    D0,D2
; vdir.Size |= (unsigned long)gDataBuffer[ikk] << 16;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,_vdir+26.L
; ikk = ix + 29;
       move.w    D3,D0
       add.w     #29,D0
       move.w    D0,D2
; vdir.Size |= (unsigned long)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,_vdir+26.L
; ikk = ix + 28;
       move.w    D3,D0
       add.w     #28,D0
       move.w    D0,D2
; vdir.Size |= (unsigned long)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       or.l      D0,_vdir+26.L
; vdir.DirClusSec = vdata;
       move.l    D4,_vdir+30.L
; vdir.DirEntry = ix;
       move.w    D3,_vdir+34.L
; if (vtype == TYPE_FIRST_ENTRY && vdir.Attr != 0x0F) {
       move.b    15(A6),D0
       cmp.b     #8,D0
       bne.s     fsFindInDir_45
       move.b    _vdir+11.L,D0
       cmp.b     #15,D0
       beq.s     fsFindInDir_45
; if (vdir.Name[0] != DIR_DEL) {
       move.b    _vdir.L,D0
       and.w     #255,D0
       cmp.w     #229,D0
       beq.s     fsFindInDir_45
; if (vdir.Name[0] != DIR_EMPTY) {
       move.b    _vdir.L,D0
       beq.s     fsFindInDir_45
; vclusterfile = vdir.FirstCluster;
       move.l    _vdir+22.L,D7
; vdata = LAST_CLUSTER_FAT32;
       move.l    #268435455,D4
; break;
       bra       fsFindInDir_34
fsFindInDir_45:
; }
; }
; }
; if (vtype == TYPE_EMPTY_ENTRY || vtype == TYPE_CREATE_FILE || vtype == TYPE_CREATE_DIR) {
       move.b    15(A6),D0
       cmp.b     #3,D0
       beq.s     fsFindInDir_49
       move.b    15(A6),D0
       cmp.b     #4,D0
       beq.s     fsFindInDir_49
       move.b    15(A6),D0
       cmp.b     #5,D0
       bne       fsFindInDir_47
fsFindInDir_49:
; if (vdir.Name[0] == DIR_EMPTY || vdir.Name[0] == DIR_DEL) {
       move.b    _vdir.L,D0
       beq.s     fsFindInDir_52
       move.b    _vdir.L,D0
       and.w     #255,D0
       cmp.w     #229,D0
       bne       fsFindInDir_50
fsFindInDir_52:
; vclusterfile = ventrydir;
       move.w    -44(A6),D0
       and.l     #65535,D0
       move.l    D0,D7
; if (vtype != TYPE_EMPTY_ENTRY) {
       move.b    15(A6),D0
       cmp.b     #3,D0
       beq       fsFindInDir_53
; vclusterfile = fsFindClusterFree(FREE_USE);
       pea       2
       jsr       _fsFindClusterFree
       addq.w    #4,A7
       move.l    D0,D7
; if (vclusterfile >= ERRO_D_START)
       cmp.l     #-16,D7
       blo.s     fsFindInDir_55
; return ERRO_D_NOT_FOUND;
       moveq     #-1,D0
       bra       fsFindInDir_21
fsFindInDir_55:
; if (!fsSectorRead(vdata, gDataBuffer))
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsFindInDir_57
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       fsFindInDir_21
fsFindInDir_57:
; for (iz = 0; iz <= 10; iz++) {
       clr.w     D6
fsFindInDir_59:
       cmp.w     #10,D6
       bhi       fsFindInDir_61
; if (iz <= 7) {
       cmp.w     #7,D6
       bhi.s     fsFindInDir_62
; ikk = ix + iz;
       move.w    D3,D0
       add.w     D6,D0
       move.w    D0,D2
; gDataBuffer[ikk] = fnameName[iz];
       and.l     #65535,D6
       and.l     #65535,D2
       move.b    -64(A6,D6.L),0(A2,D2.L)
       bra.s     fsFindInDir_63
fsFindInDir_62:
; }
; else {
; ikk = ix + iz;
       move.w    D3,D0
       add.w     D6,D0
       move.w    D0,D2
; ikj = iz - 8;
       move.w    D6,D0
       subq.w    #8,D0
       move.w    D0,-38(A6)
; gDataBuffer[ikk] = fnameExt[ikj];
       move.w    -38(A6),D0
       and.l     #65535,D0
       and.l     #65535,D2
       move.b    -54(A6,D0.L),0(A2,D2.L)
fsFindInDir_63:
       addq.w    #1,D6
       bra       fsFindInDir_59
fsFindInDir_61:
; }
; }
; if (vtype == TYPE_CREATE_FILE)
       move.b    15(A6),D0
       cmp.b     #4,D0
       bne.s     fsFindInDir_64
; gDataBuffer[ix + 11] = 0x00;
       and.l     #65535,D3
       move.l    D3,A0
       clr.b     11(A0,A2.L)
       bra.s     fsFindInDir_65
fsFindInDir_64:
; else
; gDataBuffer[ix + 11] = ATTR_DIRECTORY;
       and.l     #65535,D3
       move.l    D3,A0
       move.b    #16,11(A0,A2.L)
fsFindInDir_65:
; // Ler Data/Hora do DS1307 - I2C
; ds1307[3] = 01;
       move.b    #1,-30+3(A6)
; ds1307[4] = 01;
       move.b    #1,-30+4(A6)
; ds1307[5] = 2024;
       move.b    #232,-30+5(A6)
; ds1307[0] = 00;
       clr.b     -30+0(A6)
; ds1307[1] = 00;
       clr.b     -30+1(A6)
; ds1307[2] = 00;
       clr.b     -30+2(A6)
; // Converte para a Data/Hora da FAT32
; vdirtime = datetimetodir(ds1307[0], ds1307[1], ds1307[2], CONV_HORA);
       pea       2
       move.b    -30+2(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -30+1(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -30+0(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _datetimetodir
       add.w     #16,A7
       move.w    D0,-40(A6)
; vdirdate = datetimetodir(ds1307[3], ds1307[4], ds1307[5], CONV_DATA);
       pea       1
       move.b    -30+5(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -30+4(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -30+3(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _datetimetodir
       add.w     #16,A7
       move.w    D0,A4
; // Coloca dados no buffer para gravacao
; ikk = ix + 12;
       move.w    D3,D0
       add.w     #12,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;	// case
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; ikk = ix + 13;
       move.w    D3,D0
       add.w     #13,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;	// creation time in ms
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; ikk = ix + 14;
       move.w    D3,D0
       add.w     #14,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdirtime & 0xFF);	// creation time (ds1307)
       move.w    -40(A6),D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 15;
       move.w    D3,D0
       add.w     #15,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdirtime >> 8) & 0xFF);
       move.w    -40(A6),D0
       lsr.w     #8,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 16;
       move.w    D3,D0
       add.w     #16,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdirdate & 0xFF);	// creation date (ds1307)
       move.w    A4,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 17;
       move.w    D3,D0
       add.w     #17,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 18;
       move.w    D3,D0
       add.w     #18,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdirdate & 0xFF);	// last access	(ds1307)
       move.w    A4,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 19;
       move.w    D3,D0
       add.w     #19,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 22;
       move.w    D3,D0
       add.w     #22,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdirtime & 0xFF);	// time update (ds1307)
       move.w    -40(A6),D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 23;
       move.w    D3,D0
       add.w     #23,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdirtime >> 8) & 0xFF);
       move.w    -40(A6),D0
       lsr.w     #8,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 24;
       move.w    D3,D0
       add.w     #24,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdirdate & 0xFF);	// date update (ds1307)
       move.w    A4,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 25;
       move.w    D3,D0
       add.w     #25,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 26;
       move.w    D3,D0
       add.w     #26,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vclusterfile & 0xFF);
       move.l    D7,D0
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 27;
       move.w    D3,D0
       add.w     #27,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vclusterfile / 0x100) & 0xFF);
       move.l    D7,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 20;
       move.w    D3,D0
       add.w     #20,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vclusterfile / 0x10000) & 0xFF);
       move.l    D7,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 21;
       move.w    D3,D0
       add.w     #21,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vclusterfile / 0x1000000) & 0xFF);
       move.l    D7,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = ix + 28;
       move.w    D3,D0
       add.w     #28,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; ikk = ix + 29;
       move.w    D3,D0
       add.w     #29,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; ikk = ix + 30;
       move.w    D3,D0
       add.w     #30,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; ikk = ix + 31;
       move.w    D3,D0
       add.w     #31,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFindInDir_66
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra       fsFindInDir_21
fsFindInDir_66:
; if (vtype == TYPE_CREATE_DIR) {
       move.b    15(A6),D0
       cmp.b     #5,D0
       bne       fsFindInDir_75
; // Posicionar na nova posicao do diretorio
; vtemp1 = ((vclusterfile - 2) * vdisk.SecPerClus);
       move.l    D7,D0
       subq.l    #2,D0
       move.b    31(A3),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-72(A6)
; vtemp2 = vdisk.data;
       move.l    12(A3),-68(A6)
; vdata = vtemp1 + vtemp2;
       move.l    -72(A6),D0
       add.l     -68(A6),D0
       move.l    D0,D4
; // Limpar novo cluster do diretorio (Zerar)
; memset(gDataBuffer, 0x00, vdisk.sectorSize);
       move.w    22(A3),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       move.l    A2,-(A7)
       jsr       _memset
       add.w     #12,A7
; for (iz = 0; iz < vdisk.SecPerClus; iz++) {
       clr.w     D6
fsFindInDir_70:
       move.b    31(A3),D0
       and.w     #255,D0
       cmp.w     D0,D6
       bhs.s     fsFindInDir_72
; if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFindInDir_73
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra       fsFindInDir_21
fsFindInDir_73:
; vdata++;
       addq.l    #1,D4
       addq.w    #1,D6
       bra       fsFindInDir_70
fsFindInDir_72:
; }
; vtemp1 = ((vclusterfile - 2) * vdisk.SecPerClus);
       move.l    D7,D0
       subq.l    #2,D0
       move.b    31(A3),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-72(A6)
; vtemp2 = vdisk.data;
       move.l    12(A3),-68(A6)
; vdata = vtemp1 + vtemp2;
       move.l    -72(A6),D0
       add.l     -68(A6),D0
       move.l    D0,D4
; // Criar diretorio . (atual)
; memset(gDataBuffer, 0x00, vdisk.sectorSize);
       move.w    22(A3),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       move.l    A2,-(A7)
       jsr       _memset
       add.w     #12,A7
; ix = 0;
       clr.w     D3
; gDataBuffer[0] = '.';
       move.b    #46,(A2)
; gDataBuffer[1] = 0x20;
       move.b    #32,1(A2)
; gDataBuffer[2] = 0x20;
       move.b    #32,2(A2)
; gDataBuffer[3] = 0x20;
       move.b    #32,3(A2)
; gDataBuffer[4] = 0x20;
       move.b    #32,4(A2)
; gDataBuffer[5] = 0x20;
       move.b    #32,5(A2)
; gDataBuffer[6] = 0x20;
       move.b    #32,6(A2)
; gDataBuffer[7] = 0x20;
       move.b    #32,7(A2)
; gDataBuffer[8] = 0x20;
       move.b    #32,8(A2)
; gDataBuffer[9] = 0x20;
       move.b    #32,9(A2)
; gDataBuffer[10] = 0x20;
       move.b    #32,10(A2)
; gDataBuffer[11] = 0x10;
       move.b    #16,11(A2)
; gDataBuffer[12] = 0x00;	// case
       clr.b     12(A2)
; gDataBuffer[13] = 0x00;	// creation time in ms
       clr.b     13(A2)
; gDataBuffer[14] = (unsigned char)(vdirtime & 0xFF);	// creation time (ds1307)
       move.w    -40(A6),D0
       and.w     #255,D0
       move.b    D0,14(A2)
; gDataBuffer[15] = (unsigned char)((vdirtime >> 8) & 0xFF);
       move.w    -40(A6),D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,15(A2)
; gDataBuffer[16] = (unsigned char)(vdirdate & 0xFF);	// creation date (ds1307)
       move.w    A4,D0
       and.w     #255,D0
       move.b    D0,16(A2)
; gDataBuffer[17] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,17(A2)
; gDataBuffer[18] = (unsigned char)(vdirdate & 0xFF);	// last access	(ds1307)
       move.w    A4,D0
       and.w     #255,D0
       move.b    D0,18(A2)
; gDataBuffer[19] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,19(A2)
; gDataBuffer[22] = (unsigned char)(vdirtime & 0xFF);	// time update (ds1307)
       move.w    -40(A6),D0
       and.w     #255,D0
       move.b    D0,22(A2)
; gDataBuffer[23] = (unsigned char)((vdirtime >> 8) & 0xFF);
       move.w    -40(A6),D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,23(A2)
; gDataBuffer[24] = (unsigned char)(vdirdate & 0xFF);	// date update (ds1307)
       move.w    A4,D0
       and.w     #255,D0
       move.b    D0,24(A2)
; gDataBuffer[25] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,25(A2)
; gDataBuffer[26] = (unsigned char)(vclusterfile & 0xFF);
       move.l    D7,D0
       and.l     #255,D0
       move.b    D0,26(A2)
; gDataBuffer[27] = (unsigned char)((vclusterfile / 0x100) & 0xFF);
       move.l    D7,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,27(A2)
; gDataBuffer[20] = (unsigned char)((vclusterfile / 0x10000) & 0xFF);
       move.l    D7,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,20(A2)
; gDataBuffer[21] = (unsigned char)((vclusterfile / 0x1000000) & 0xFF);
       move.l    D7,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,21(A2)
; gDataBuffer[28] = 0x00;
       clr.b     28(A2)
; gDataBuffer[29] = 0x00;
       clr.b     29(A2)
; gDataBuffer[30] = 0x00;
       clr.b     30(A2)
; gDataBuffer[31] = 0x00;
       clr.b     31(A2)
; // Criar diretorio .. (anterior)
; ix = 32;
       moveq     #32,D3
; gDataBuffer[32] = '.';
       move.b    #46,32(A2)
; gDataBuffer[33] = '.';
       move.b    #46,33(A2)
; gDataBuffer[34] = 0x20;
       move.b    #32,34(A2)
; gDataBuffer[35] = 0x20;
       move.b    #32,35(A2)
; gDataBuffer[36] = 0x20;
       move.b    #32,36(A2)
; gDataBuffer[37] = 0x20;
       move.b    #32,37(A2)
; gDataBuffer[38] = 0x20;
       move.b    #32,38(A2)
; gDataBuffer[39] = 0x20;
       move.b    #32,39(A2)
; gDataBuffer[40] = 0x20;
       move.b    #32,40(A2)
; gDataBuffer[41] = 0x20;
       move.b    #32,41(A2)
; gDataBuffer[42] = 0x20;
       move.b    #32,42(A2)
; gDataBuffer[43] = 0x10;
       move.b    #16,43(A2)
; gDataBuffer[44] = 0x00;	// case
       clr.b     44(A2)
; gDataBuffer[45] = 0x00;	// creation time in ms
       clr.b     45(A2)
; gDataBuffer[46] = (unsigned char)(vdirtime & 0xFF);	// creation time (ds1307)
       move.w    -40(A6),D0
       and.w     #255,D0
       move.b    D0,46(A2)
; gDataBuffer[47] = (unsigned char)((vdirtime >> 8) & 0xFF);
       move.w    -40(A6),D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,47(A2)
; gDataBuffer[48] = (unsigned char)(vdirdate & 0xFF);	// creation date (ds1307)
       move.w    A4,D0
       and.w     #255,D0
       move.b    D0,48(A2)
; gDataBuffer[49] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,49(A2)
; gDataBuffer[50] = (unsigned char)(vdirdate & 0xFF);	// last access	(ds1307)
       move.w    A4,D0
       and.w     #255,D0
       move.b    D0,50(A2)
; gDataBuffer[51] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,51(A2)
; gDataBuffer[54] = (unsigned char)(vdirtime & 0xFF);	// time update (ds1307)
       move.w    -40(A6),D0
       and.w     #255,D0
       move.b    D0,54(A2)
; gDataBuffer[55] = (unsigned char)((vdirtime >> 8) & 0xFF);
       move.w    -40(A6),D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,55(A2)
; gDataBuffer[56] = (unsigned char)(vdirdate & 0xFF);	// date update (ds1307)
       move.w    A4,D0
       and.w     #255,D0
       move.b    D0,56(A2)
; gDataBuffer[57] = (unsigned char)((vdirdate >> 8) & 0xFF);
       move.w    A4,D0
       lsr.w     #8,D0
       and.w     #255,D0
       move.b    D0,57(A2)
; gDataBuffer[58] = (unsigned char)(vclusterdir & 0xFF);
       move.l    _vclusterdir.L,D0
       and.l     #255,D0
       move.b    D0,58(A2)
; gDataBuffer[59] = (unsigned char)((vclusterdir / 0x100) & 0xFF);
       move.l    _vclusterdir.L,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,59(A2)
; gDataBuffer[52] = (unsigned char)((vclusterdir / 0x10000) & 0xFF);
       move.l    _vclusterdir.L,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,52(A2)
; gDataBuffer[53] = (unsigned char)((vclusterdir / 0x1000000) & 0xFF);
       move.l    _vclusterdir.L,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,53(A2)
; gDataBuffer[60] = 0x00;
       clr.b     60(A2)
; gDataBuffer[61] = 0x00;
       clr.b     61(A2)
; gDataBuffer[62] = 0x00;
       clr.b     62(A2)
; gDataBuffer[63] = 0x00;
       clr.b     63(A2)
; if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFindInDir_75
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra       fsFindInDir_21
fsFindInDir_75:
; }
; vdata = LAST_CLUSTER_FAT32;
       move.l    #268435455,D4
; break;
       bra       fsFindInDir_34
fsFindInDir_53:
; }
; vdata = LAST_CLUSTER_FAT32;
       move.l    #268435455,D4
; break;
       bra       fsFindInDir_34
fsFindInDir_50:
       bra       fsFindInDir_105
fsFindInDir_47:
; }
; }
; else if (vtype != TYPE_FIRST_ENTRY) {
       move.b    15(A6),D0
       cmp.b     #8,D0
       beq       fsFindInDir_105
; if (vdir.Name[0] != DIR_EMPTY && vdir.Name[0] != DIR_DEL) {
       move.b    _vdir.L,D0
       beq       fsFindInDir_105
       move.b    _vdir.L,D0
       and.w     #255,D0
       cmp.w     #229,D0
       beq       fsFindInDir_105
; vcomp = 1;
       move.b    #1,-32(A6)
; for (iz = 0; iz <= 10; iz++) {
       clr.w     D6
fsFindInDir_81:
       cmp.w     #10,D6
       bhi       fsFindInDir_83
; if (iz <= 7) {
       cmp.w     #7,D6
       bhi.s     fsFindInDir_84
; if (fnameName[iz] != vdir.Name[iz]) {
       and.l     #65535,D6
       and.l     #65535,D6
       lea       _vdir.L,A0
       move.b    -64(A6,D6.L),D0
       cmp.b     0(A0,D6.L),D0
       beq.s     fsFindInDir_86
; vcomp = 0;
       clr.b     -32(A6)
; break;
       bra.s     fsFindInDir_83
fsFindInDir_86:
       bra.s     fsFindInDir_88
fsFindInDir_84:
; }
; }
; else {
; ikk = iz - 8;
       move.w    D6,D0
       subq.w    #8,D0
       move.w    D0,D2
; if (fnameExt[ikk] != vdir.Ext[ikk]) {
       and.l     #65535,D2
       and.l     #65535,D2
       lea       _vdir.L,A0
       add.l     D2,A0
       move.b    -54(A6,D2.L),D0
       cmp.b     8(A0),D0
       beq.s     fsFindInDir_88
; vcomp = 0;
       clr.b     -32(A6)
; break;
       bra.s     fsFindInDir_83
fsFindInDir_88:
       addq.w    #1,D6
       bra       fsFindInDir_81
fsFindInDir_83:
; }
; }
; }
; if (vcomp) {
       tst.b     -32(A6)
       beq       fsFindInDir_105
; if (vtype == TYPE_ALL || (vtype == TYPE_FILE && vdir.Attr != ATTR_DIRECTORY) || (vtype == TYPE_DIRECTORY && vdir.Attr == ATTR_DIRECTORY)) {
       move.b    15(A6),D0
       and.w     #255,D0
       cmp.w     #255,D0
       beq.s     fsFindInDir_94
       move.b    15(A6),D0
       cmp.b     #2,D0
       bne.s     fsFindInDir_95
       move.b    _vdir+11.L,D0
       cmp.b     #16,D0
       bne.s     fsFindInDir_94
fsFindInDir_95:
       move.b    15(A6),D0
       cmp.b     #1,D0
       bne.s     fsFindInDir_92
       move.b    _vdir+11.L,D0
       cmp.b     #16,D0
       bne.s     fsFindInDir_92
fsFindInDir_94:
; vclusterfile = vdir.FirstCluster;
       move.l    _vdir+22.L,D7
; break;
       bra       fsFindInDir_34
fsFindInDir_92:
; }
; else if (vtype == TYPE_NEXT_ENTRY) {
       move.b    15(A6),D0
       cmp.b     #9,D0
       bne.s     fsFindInDir_96
; vtype = TYPE_FIRST_ENTRY;
       move.b    #8,15(A6)
       bra       fsFindInDir_105
fsFindInDir_96:
; }
; else if (vtype == TYPE_DEL_FILE || vtype == TYPE_DEL_DIR) {
       move.b    15(A6),D0
       cmp.b     #6,D0
       beq.s     fsFindInDir_100
       move.b    15(A6),D0
       cmp.b     #7,D0
       bne       fsFindInDir_105
fsFindInDir_100:
; // Guardando Cluster Atual
; vclusteratual = vdir.FirstCluster;
       move.l    _vdir+22.L,-76(A6)
; // Apaga a entrada principal e as entradas LFN imediatamente anteriores.
; if (fsDeleteDirEntryChain(vdata, ix) != RETURN_OK)
       and.l     #65535,D3
       move.l    D3,-(A7)
       move.l    D4,-(A7)
       jsr       @mmsjos_fsDeleteDirEntryChain
       addq.w    #8,A7
       tst.b     D0
       beq.s     fsFindInDir_101
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra       fsFindInDir_21
fsFindInDir_101:
; // Apagando vestigios na FAT
; while (1) {
fsFindInDir_103:
; // Procura Proximo Cluster e ja zera
; vclusterdirnew = fsFindNextCluster(vclusteratual, NEXT_FREE);
       pea       3
       move.l    -76(A6),-(A7)
       jsr       _fsFindNextCluster
       addq.w    #8,A7
       move.l    D0,D5
; if (vclusterdirnew >= ERRO_D_START)
       cmp.l     #-16,D5
       blo.s     fsFindInDir_106
; return ERRO_D_NOT_FOUND;
       moveq     #-1,D0
       bra       fsFindInDir_21
fsFindInDir_106:
; if (vclusterdirnew == LAST_CLUSTER_FAT32) {
       cmp.l     #268435455,D5
       bne.s     fsFindInDir_108
; vclusterfile = LAST_CLUSTER_FAT32;
       move.l    #268435455,D7
; vdata = LAST_CLUSTER_FAT32;
       move.l    #268435455,D4
; break;
       bra.s     fsFindInDir_105
fsFindInDir_108:
; }
; // Tornar cluster atual o proximo
; vclusteratual = vclusterdirnew;
       move.l    D5,-76(A6)
       bra       fsFindInDir_103
fsFindInDir_105:
; }
; }
; }
; }
; }
; if (vdir.Name[0] == DIR_EMPTY) {
       move.b    _vdir.L,D0
       bne.s     fsFindInDir_110
; vdata = LAST_CLUSTER_FAT32;
       move.l    #268435455,D4
; break;
       bra.s     fsFindInDir_34
fsFindInDir_110:
       add.w     #32,D3
       bra       fsFindInDir_32
fsFindInDir_34:
; }
; }
; if (vclusterfile < ERRO_D_START || vdata == LAST_CLUSTER_FAT32)
       cmp.l     #-16,D7
       blo.s     fsFindInDir_114
       cmp.l     #268435455,D4
       bne.s     fsFindInDir_112
fsFindInDir_114:
; break;
       bra.s     fsFindInDir_29
fsFindInDir_112:
; ventrydir++;
       addq.w    #1,-44(A6)
; vdata++;
       addq.l    #1,D4
       addq.b    #1,-31(A6)
       bra       fsFindInDir_27
fsFindInDir_29:
; }
; // Se conseguiu concluir a operacao solicitada, sai do loop
; if (vclusterfile < ERRO_D_START || vdata == LAST_CLUSTER_FAT32)
       cmp.l     #-16,D7
       blo.s     fsFindInDir_117
       cmp.l     #268435455,D4
       bne.s     fsFindInDir_115
fsFindInDir_117:
; break;
       bra       fsFindInDir_26
fsFindInDir_115:
; else {
; // Posiciona na FAT, o endereco da pasta atual
; vsecfat = vclusterdirnew / 128;
       move.l    D5,-(A7)
       pea       128
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,-46(A6)
; vfat = vdisk.fat + vsecfat;
       move.l    4(A3),D0
       move.w    -46(A6),D1
       and.l     #65535,D1
       add.l     D1,D0
       move.l    D0,-80(A6)
; if (!fsSectorRead(vfat, gDataBuffer))
       move.l    A2,-(A7)
       move.l    -80(A6),-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsFindInDir_118
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       fsFindInDir_21
fsFindInDir_118:
; vtemp = vclusterdirnew - ( 128 * vsecfat);
       move.l    D5,D0
       move.w    -46(A6),D1
       mulu.w    #128,D1
       and.l     #65535,D1
       sub.l     D1,D0
       move.w    D0,-36(A6)
; vpos = vtemp * 4;
       move.w    -36(A6),D0
       mulu.w    #4,D0
       move.w    D0,-48(A6)
; ikk = vpos + 3;
       move.w    -48(A6),D0
       addq.w    #3,D0
       move.w    D0,D2
; vclusterdirnew  = (unsigned long)gDataBuffer[ikk] << 24;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,D5
; ikk = vpos + 2;
       move.w    -48(A6),D0
       addq.w    #2,D0
       move.w    D0,D2
; vclusterdirnew |= (unsigned long)gDataBuffer[ikk] << 16;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,D5
; ikk = vpos + 1;
       move.w    -48(A6),D0
       addq.w    #1,D0
       move.w    D0,D2
; vclusterdirnew |= (unsigned long)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,D5
; ikk = vpos;
       move.w    -48(A6),D2
; vclusterdirnew |= (unsigned long)gDataBuffer[ikk];
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       or.l      D0,D5
; if (vclusterdirnew != LAST_CLUSTER_FAT32) {
       cmp.l     #268435455,D5
       beq.s     fsFindInDir_120
; // Devolve a proxima posicao para procura/uso
; vtemp1 = ((vclusterdirnew - 2) * vdisk.SecPerClus);
       move.l    D5,D0
       subq.l    #2,D0
       move.b    31(A3),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-72(A6)
; vtemp2 = vdisk.data;
       move.l    12(A3),-68(A6)
; vdata = vtemp1 + vtemp2;
       move.l    -72(A6),D0
       add.l     -68(A6),D0
       move.l    D0,D4
       bra       fsFindInDir_123
fsFindInDir_120:
; }
; else {
; // Se for para criar uma nova entrada no diretorio e nao tem mais espaco
; // Cria uma nova entrada na Fat
; if (vtype == TYPE_EMPTY_ENTRY || vtype == TYPE_CREATE_FILE || vtype == TYPE_CREATE_DIR) {
       move.b    15(A6),D0
       cmp.b     #3,D0
       beq.s     fsFindInDir_124
       move.b    15(A6),D0
       cmp.b     #4,D0
       beq.s     fsFindInDir_124
       move.b    15(A6),D0
       cmp.b     #5,D0
       bne       fsFindInDir_122
fsFindInDir_124:
; vclusterdirnew = fsFindClusterFree(FREE_USE);
       pea       2
       jsr       _fsFindClusterFree
       addq.w    #4,A7
       move.l    D0,D5
; if (vclusterdirnew < ERRO_D_START) {
       cmp.l     #-16,D5
       bhs       fsFindInDir_125
; if (!fsSectorRead(vfat, gDataBuffer))
       move.l    A2,-(A7)
       move.l    -80(A6),-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsFindInDir_127
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       fsFindInDir_21
fsFindInDir_127:
; gDataBuffer[vpos] = (unsigned char)(vclusterdirnew & 0xFF);
       move.l    D5,D0
       and.l     #255,D0
       move.w    -48(A6),D1
       and.l     #65535,D1
       move.b    D0,0(A2,D1.L)
; ikk = vpos + 1;
       move.w    -48(A6),D0
       addq.w    #1,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vclusterdirnew / 0x100) & 0xFF);
       move.l    D5,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = vpos + 2;
       move.w    -48(A6),D0
       addq.w    #2,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vclusterdirnew / 0x10000) & 0xFF);
       move.l    D5,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; ikk = vpos + 3;
       move.w    -48(A6),D0
       addq.w    #3,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vclusterdirnew / 0x1000000) & 0xFF);
       move.l    D5,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A2,D2.L)
; if (fsWriteFatSector(vfat) != RETURN_OK)
       move.l    -80(A6),-(A7)
       jsr       @mmsjos_fsWriteFatSector
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsFindInDir_129
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra       fsFindInDir_21
fsFindInDir_129:
; // Posicionar na nova posicao do diretorio
; vtemp1 = ((vclusterdirnew - 2) * vdisk.SecPerClus);
       move.l    D5,D0
       subq.l    #2,D0
       move.b    31(A3),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-72(A6)
; vtemp2 = vdisk.data;
       move.l    12(A3),-68(A6)
; vdata = vtemp1 + vtemp2;
       move.l    -72(A6),D0
       add.l     -68(A6),D0
       move.l    D0,D4
; // Limpar novo cluster do diretorio (Zerar)
; memset(gDataBuffer, 0x00, vdisk.sectorSize);
       move.w    22(A3),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       move.l    A2,-(A7)
       jsr       _memset
       add.w     #12,A7
; for (iz = 0; iz < vdisk.SecPerClus; iz++) {
       clr.w     D6
fsFindInDir_131:
       move.b    31(A3),D0
       and.w     #255,D0
       cmp.w     D0,D6
       bhs.s     fsFindInDir_133
; if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFindInDir_134
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra       fsFindInDir_21
fsFindInDir_134:
; vdata++;
       addq.l    #1,D4
       addq.w    #1,D6
       bra       fsFindInDir_131
fsFindInDir_133:
; }
; vtemp1 = ((vclusterdirnew - 2) * vdisk.SecPerClus);
       move.l    D5,D0
       subq.l    #2,D0
       move.b    31(A3),D1
       and.l     #255,D1
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    D0,-72(A6)
; vtemp2 = vdisk.data;
       move.l    12(A3),-68(A6)
; vdata = vtemp1 + vtemp2;
       move.l    -72(A6),D0
       add.l     -68(A6),D0
       move.l    D0,D4
       bra.s     fsFindInDir_126
fsFindInDir_125:
; }
; else {
; vclusterdirnew = LAST_CLUSTER_FAT32;
       move.l    #268435455,D5
; vclusterfile = ERRO_D_NOT_FOUND;
       moveq     #-1,D7
; vdata = vclusterdirnew;
       move.l    D5,D4
fsFindInDir_126:
       bra.s     fsFindInDir_123
fsFindInDir_122:
; }
; }
; else {
; vdata = vclusterdirnew;
       move.l    D5,D4
fsFindInDir_123:
       bra       fsFindInDir_24
fsFindInDir_26:
; }
; }
; }
; }
; return vclusterfile;
       move.l    D7,D0
fsFindInDir_21:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsUpdateDir()
; {
       xdef      _fsUpdateDir
_fsUpdateDir:
       movem.l   D2/D3/D4/A2/A3,-(A7)
       lea       _vdir.L,A2
       lea       _gDataBuffer.L,A3
; unsigned char iy;
; unsigned short ventry, ikk;
; if (!fsSectorRead(vdir.DirClusSec, gDataBuffer))
       move.l    A3,-(A7)
       move.l    30(A2),-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsUpdateDir_1
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra       fsUpdateDir_3
fsUpdateDir_1:
; ventry = vdir.DirEntry;
       move.w    34(A2),D3
; for (iy = 0; iy < 8; iy++) {
       clr.b     D4
fsUpdateDir_4:
       cmp.b     #8,D4
       bhs.s     fsUpdateDir_6
; ikk = ventry + iy;
       move.w    D3,D0
       and.w     #255,D4
       add.w     D4,D0
       move.w    D0,D2
; gDataBuffer[ikk] = vdir.Name[iy];
       and.l     #255,D4
       and.l     #65535,D2
       move.b    0(A2,D4.L),0(A3,D2.L)
       addq.b    #1,D4
       bra       fsUpdateDir_4
fsUpdateDir_6:
; }
; for (iy = 0; iy < 3; iy++) {
       clr.b     D4
fsUpdateDir_7:
       cmp.b     #3,D4
       bhs.s     fsUpdateDir_9
; ikk = ventry + 8 + iy;
       move.w    D3,D0
       addq.w    #8,D0
       and.w     #255,D4
       add.w     D4,D0
       move.w    D0,D2
; gDataBuffer[ikk] = vdir.Ext[iy];
       and.l     #255,D4
       lea       0(A2,D4.L),A0
       and.l     #65535,D2
       move.b    8(A0),0(A3,D2.L)
       addq.b    #1,D4
       bra       fsUpdateDir_7
fsUpdateDir_9:
; }
; ikk = ventry + 18;
       move.w    D3,D0
       add.w     #18,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdir.LastAccessDate & 0xFF);	// last access	(ds1307)
       move.w    16(A2),D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 19;
       move.w    D3,D0
       add.w     #19,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdir.LastAccessDate / 0x100) & 0xFF);
       move.w    16(A2),D0
       and.l     #65535,D0
       divu.w    #256,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 22;
       move.w    D3,D0
       add.w     #22,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdir.UpdateTime & 0xFF);	// time update (ds1307)
       move.w    20(A2),D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 23;
       move.w    D3,D0
       add.w     #23,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdir.UpdateTime / 0x100) & 0xFF);
       move.w    20(A2),D0
       and.l     #65535,D0
       divu.w    #256,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 24;
       move.w    D3,D0
       add.w     #24,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdir.UpdateDate & 0xFF);	// date update (ds1307)
       move.w    18(A2),D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 25;
       move.w    D3,D0
       add.w     #25,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdir.UpdateDate / 0x100) & 0xFF);
       move.w    18(A2),D0
       and.l     #65535,D0
       divu.w    #256,D0
       and.w     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 28;
       move.w    D3,D0
       add.w     #28,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)(vdir.Size & 0xFF);
       move.l    26(A2),D0
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 29;
       move.w    D3,D0
       add.w     #29,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdir.Size / 0x100) & 0xFF);
       move.l    26(A2),-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 30;
       move.w    D3,D0
       add.w     #30,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdir.Size / 0x10000) & 0xFF);
       move.l    26(A2),-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; ikk = ventry + 31;
       move.w    D3,D0
       add.w     #31,D0
       move.w    D0,D2
; gDataBuffer[ikk] = (unsigned char)((vdir.Size / 0x1000000) & 0xFF);
       move.l    26(A2),-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       and.l     #65535,D2
       move.b    D0,0(A3,D2.L)
; if (!fsSectorWrite(vdir.DirClusSec, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A3,-(A7)
       move.l    30(A2),-(A7)
       jsr       _fsSectorWrite
       add.w     #12,A7
       tst.b     D0
       bne.s     fsUpdateDir_10
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra.s     fsUpdateDir_3
fsUpdateDir_10:
; return RETURN_OK;
       clr.b     D0
fsUpdateDir_3:
       movem.l   (A7)+,D2/D3/D4/A2/A3
       rts
; }
; //-------------------------------------------------------------------------
; unsigned long fsFindNextCluster(unsigned long vclusteratual, unsigned char vtype)
; {
       xdef      _fsFindNextCluster
_fsFindNextCluster:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/D7/A2,-(A7)
       lea       _gDataBuffer.L,A2
       move.b    15(A6),D5
       and.l     #255,D5
; unsigned long vfat, vclusternew;
; unsigned short vpos, vsecfat, ikk;
; vsecfat = vclusteratual / 128;
       move.l    8(A6),-(A7)
       pea       128
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,D7
; vfat = vdisk.fat + vsecfat;
       move.l    _vdisk+4.L,D0
       and.l     #65535,D7
       add.l     D7,D0
       move.l    D0,D6
; if (!fsSectorRead(vfat, gDataBuffer))
       move.l    A2,-(A7)
       move.l    D6,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsFindNextCluster_1
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       fsFindNextCluster_3
fsFindNextCluster_1:
; vpos = (vclusteratual - ( 128 * vsecfat)) * 4;
       move.l    8(A6),D0
       move.w    D7,D1
       mulu.w    #128,D1
       and.l     #65535,D1
       sub.l     D1,D0
       move.l    D0,-(A7)
       pea       4
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.w    D0,D3
; ikk = vpos + 3;
       move.w    D3,D0
       addq.w    #3,D0
       move.w    D0,D2
; vclusternew  = (unsigned long)gDataBuffer[ikk] << 24;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,D4
; ikk = vpos + 2;
       move.w    D3,D0
       addq.w    #2,D0
       move.w    D0,D2
; vclusternew |= (unsigned long)gDataBuffer[ikk] << 16;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,D4
; ikk = vpos + 1;
       move.w    D3,D0
       addq.w    #1,D0
       move.w    D0,D2
; vclusternew |= (unsigned long)gDataBuffer[ikk] << 8;
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,D4
; vclusternew |= (unsigned long)gDataBuffer[vpos];
       and.l     #65535,D3
       move.b    0(A2,D3.L),D0
       and.l     #255,D0
       or.l      D0,D4
; if (vtype != NEXT_FIND) {
       cmp.b     #5,D5
       beq       fsFindNextCluster_10
; if (vtype == NEXT_FREE) {
       cmp.b     #3,D5
       bne       fsFindNextCluster_6
; gDataBuffer[vpos] = 0x00;
       and.l     #65535,D3
       clr.b     0(A2,D3.L)
; ikk = vpos + 1;
       move.w    D3,D0
       addq.w    #1,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; ikk = vpos + 2;
       move.w    D3,D0
       addq.w    #2,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
; ikk = vpos + 3;
       move.w    D3,D0
       addq.w    #3,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x00;
       and.l     #65535,D2
       clr.b     0(A2,D2.L)
       bra       fsFindNextCluster_8
fsFindNextCluster_6:
; }
; else if (vtype == NEXT_FULL) {
       cmp.b     #4,D5
       bne       fsFindNextCluster_8
; gDataBuffer[vpos] = 0xFF;
       and.l     #65535,D3
       move.b    #255,0(A2,D3.L)
; ikk = vpos + 1;
       move.w    D3,D0
       addq.w    #1,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0xFF;
       and.l     #65535,D2
       move.b    #255,0(A2,D2.L)
; ikk = vpos + 2;
       move.w    D3,D0
       addq.w    #2,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0xFF;
       and.l     #65535,D2
       move.b    #255,0(A2,D2.L)
; ikk = vpos + 3;
       move.w    D3,D0
       addq.w    #3,D0
       move.w    D0,D2
; gDataBuffer[ikk] = 0x0F;
       and.l     #65535,D2
       move.b    #15,0(A2,D2.L)
fsFindNextCluster_8:
; }
; if (fsWriteFatSector(vfat) != RETURN_OK)
       move.l    D6,-(A7)
       jsr       @mmsjos_fsWriteFatSector
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsFindNextCluster_10
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra.s     fsFindNextCluster_3
fsFindNextCluster_10:
; }
; return vclusternew;
       move.l    D4,D0
fsFindNextCluster_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned long fsFindClusterFree(unsigned char vtype)
; {
       xdef      _fsFindClusterFree
_fsFindClusterFree:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/A2/A3,-(A7)
       lea       _gDataBuffer.L,A2
       lea       _vdisk.L,A3
; unsigned long vclusterfree = 0x00, cc, vfat;
       clr.l     D6
; unsigned short jj, ikk, ikk2, ikk3;
; vfat = vdisk.fat;
       move.l    4(A3),D5
; for (cc = 0; cc < vdisk.fatsize; cc++) {
       clr.l     D4
fsFindClusterFree_1:
       cmp.l     24(A3),D4
       bhs       fsFindClusterFree_3
; // LER FAT SECTOR
; if (!fsSectorRead(vfat, gDataBuffer))
       move.l    A2,-(A7)
       move.l    D5,-(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsFindClusterFree_4
; return ERRO_D_READ_DISK;
       moveq     #-15,D0
       bra       fsFindClusterFree_6
fsFindClusterFree_4:
; // Procura Cluster Livre dentro desse setor
; for (jj = 0; jj < vdisk.sectorSize; jj += 4) {
       clr.w     D2
fsFindClusterFree_7:
       cmp.w     22(A3),D2
       bhs       fsFindClusterFree_9
; ikk = jj + 1;
       move.w    D2,D0
       addq.w    #1,D0
       move.w    D0,D3
; ikk2 = jj + 2;
       move.w    D2,D0
       addq.w    #2,D0
       move.w    D0,-4(A6)
; ikk3 = jj + 3;
       move.w    D2,D0
       addq.w    #3,D0
       move.w    D0,-2(A6)
; if (gDataBuffer[jj] == 0x00 && gDataBuffer[ikk] == 0x00 && gDataBuffer[ikk2] == 0x00 && gDataBuffer[ikk3] == 0x00)
       and.l     #65535,D2
       move.b    0(A2,D2.L),D0
       bne.s     fsFindClusterFree_10
       and.l     #65535,D3
       move.b    0(A2,D3.L),D0
       bne.s     fsFindClusterFree_10
       move.w    -4(A6),D0
       and.l     #65535,D0
       move.b    0(A2,D0.L),D0
       bne.s     fsFindClusterFree_10
       move.w    -2(A6),D0
       and.l     #65535,D0
       move.b    0(A2,D0.L),D0
       bne.s     fsFindClusterFree_10
; break;
       bra.s     fsFindClusterFree_9
fsFindClusterFree_10:
; vclusterfree++;
       addq.l    #1,D6
       addq.w    #4,D2
       bra       fsFindClusterFree_7
fsFindClusterFree_9:
; }
; // Se achou algum setor livre, sai do loop
; if (jj < vdisk.sectorSize)
       cmp.w     22(A3),D2
       bhs.s     fsFindClusterFree_12
; break;
       bra.s     fsFindClusterFree_3
fsFindClusterFree_12:
; // Soma mais 1 para procurar proximo cluster
; vfat++;
       addq.l    #1,D5
       addq.l    #1,D4
       bra       fsFindClusterFree_1
fsFindClusterFree_3:
; }
; if (cc > vdisk.fatsize)
       cmp.l     24(A3),D4
       bls.s     fsFindClusterFree_14
; vclusterfree = ERRO_D_DISK_FULL;
       moveq     #-12,D6
       bra       fsFindClusterFree_18
fsFindClusterFree_14:
; else {
; if (vtype == FREE_USE) {
       move.b    11(A6),D0
       cmp.b     #2,D0
       bne       fsFindClusterFree_18
; gDataBuffer[jj] = 0xFF;
       and.l     #65535,D2
       move.b    #255,0(A2,D2.L)
; ikk = jj + 1;
       move.w    D2,D0
       addq.w    #1,D0
       move.w    D0,D3
; gDataBuffer[ikk] = 0xFF;
       and.l     #65535,D3
       move.b    #255,0(A2,D3.L)
; ikk = jj + 2;
       move.w    D2,D0
       addq.w    #2,D0
       move.w    D0,D3
; gDataBuffer[ikk] = 0xFF;
       and.l     #65535,D3
       move.b    #255,0(A2,D3.L)
; ikk = jj + 3;
       move.w    D2,D0
       addq.w    #3,D0
       move.w    D0,D3
; gDataBuffer[ikk] = 0x0F;
       and.l     #65535,D3
       move.b    #15,0(A2,D3.L)
; if (fsWriteFatSector(vfat) != RETURN_OK)
       move.l    D5,-(A7)
       jsr       @mmsjos_fsWriteFatSector
       addq.w    #4,A7
       tst.b     D0
       beq.s     fsFindClusterFree_18
; return ERRO_D_WRITE_DISK;
       moveq     #-14,D0
       bra.s     fsFindClusterFree_6
fsFindClusterFree_18:
; }
; }
; return (vclusterfree);
       move.l    D6,D0
fsFindClusterFree_6:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsFormat (long int serialNumber, char * volumeID)
; {
       xdef      _fsFormat
_fsFormat:
       link      A6,#-16
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _gDataBuffer.L,A2
       lea       _fsSectorWrite.L,A4
       move.l    12(A6),A5
; unsigned short    j;
; unsigned long   secCount, RootDirSectors;
; unsigned long   root, fat, firsts, fatsize, test;
; unsigned long   Index;
; unsigned char    SecPerClus;
; unsigned char *  dataBufferPointer = gDataBuffer;
       move.l    A2,-4(A6)
; // Ler MBR
; if (!fsSectorRead(0x00, gDataBuffer))
       move.l    A2,-(A7)
       clr.l     -(A7)
       jsr       _fsSectorRead
       addq.w    #8,A7
       tst.b     D0
       bne.s     fsFormat_1
; return ERRO_B_READ_DISK;
       move.b    #225,D0
       bra       fsFormat_3
fsFormat_1:
; secCount  = (unsigned long)gDataBuffer[461] << 24;
       move.b    461(A2),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,D3
; secCount |= (unsigned long)gDataBuffer[460] << 16;
       move.b    460(A2),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,D3
; secCount |= (unsigned long)gDataBuffer[459] << 8;
       move.b    459(A2),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,D3
; secCount |= (unsigned long)gDataBuffer[458];
       move.b    458(A2),D0
       and.l     #255,D0
       or.l      D0,D3
; firsts  = (unsigned long)gDataBuffer[457] << 24;
       move.b    457(A2),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       move.l    D0,D4
; firsts |= (unsigned long)gDataBuffer[456] << 16;
       move.b    456(A2),D0
       and.l     #255,D0
       lsl.l     #8,D0
       lsl.l     #8,D0
       or.l      D0,D4
; firsts |= (unsigned long)gDataBuffer[455] << 8;
       move.b    455(A2),D0
       and.l     #255,D0
       lsl.l     #8,D0
       or.l      D0,D4
; firsts |= (unsigned long)gDataBuffer[454];
       move.b    454(A2),D0
       and.l     #255,D0
       or.l      D0,D4
; *(dataBufferPointer + 450) = 0x0B;
       move.l    -4(A6),A0
       move.b    #11,450(A0)
; if (!fsSectorWrite (0x00, gDataBuffer, TRUE))
       pea       1
       move.l    A2,-(A7)
       clr.l     -(A7)
       jsr       (A4)
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFormat_4
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra       fsFormat_3
fsFormat_4:
; //-------------------
; if (secCount >= 0x000EEB7F && secCount <= 0x01000000)	// 512 MB to 8 GB, 8 sectors per cluster
       cmp.l     #977791,D3
       blo.s     fsFormat_6
       cmp.l     #16777216,D3
       bhi.s     fsFormat_6
; SecPerClus = 8;
       moveq     #8,D7
       bra.s     fsFormat_12
fsFormat_6:
; else if (secCount > 0x01000000 && secCount <= 0x02000000) // 8 GB to 16 GB, 16 sectors per cluster
       cmp.l     #16777216,D3
       bls.s     fsFormat_8
       cmp.l     #33554432,D3
       bhi.s     fsFormat_8
; SecPerClus = 16;
       moveq     #16,D7
       bra.s     fsFormat_12
fsFormat_8:
; else if (secCount > 0x02000000 && secCount <= 0x04000000) // 16 GB to 32 GB, 32 sectors per cluster
       cmp.l     #33554432,D3
       bls.s     fsFormat_10
       cmp.l     #67108864,D3
       bhi.s     fsFormat_10
; SecPerClus = 32;
       moveq     #32,D7
       bra.s     fsFormat_12
fsFormat_10:
; else if (secCount > 0x04000000) // More than 32 GB, 64 sectors per cluster
       cmp.l     #67108864,D3
       bls.s     fsFormat_12
; SecPerClus = 64;
       moveq     #64,D7
fsFormat_12:
; //-------------------
; //-------------------
; fatsize = (secCount - 0x26);
       move.l    D3,D0
       sub.l     #38,D0
       move.l    D0,D5
; fatsize = (fatsize / ((256 * SecPerClus + 2) / 2));
       move.b    D7,D0
       and.w     #255,D0
       lsl.w     #8,D0
       addq.w    #2,D0
       and.l     #65535,D0
       divu.w    #2,D0
       ext.l     D0
       move.l    D5,-(A7)
       move.l    D0,-(A7)
       jsr       ULDIV
       move.l    (A7),D5
       addq.w    #8,A7
; fat = 0x26 + firsts;
       moveq     #38,D0
       ext.w     D0
       ext.l     D0
       add.l     D4,D0
       move.l    D0,A3
; root = fat + (2 * fatsize);
       move.l    A3,D0
       move.l    D5,-(A7)
       pea       2
       jsr       ULMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,-12(A6)
; //-------------------
; // Formata MicroSD
; memset (gDataBuffer, 0x00, MEDIA_SECTOR_SIZE);
       pea       512
       clr.l     -(A7)
       move.l    A2,-(A7)
       jsr       _memset
       add.w     #12,A7
; // Non-file system specific values
; gDataBuffer[0] = 0xEB;         //Jump instruction
       move.b    #235,(A2)
; gDataBuffer[1] = 0x3C;
       move.b    #60,1(A2)
; gDataBuffer[2] = 0x90;
       move.b    #144,2(A2)
; gDataBuffer[3] =  'M';         //OEM Name
       move.b    #77,3(A2)
; gDataBuffer[4] =  'M';
       move.b    #77,4(A2)
; gDataBuffer[5] =  'S';
       move.b    #83,5(A2)
; gDataBuffer[6] =  'J';
       move.b    #74,6(A2)
; gDataBuffer[7] =  ' ';
       move.b    #32,7(A2)
; gDataBuffer[8] =  'F';
       move.b    #70,8(A2)
; gDataBuffer[9] =  'A';
       move.b    #65,9(A2)
; gDataBuffer[10] = 'T';
       move.b    #84,10(A2)
; gDataBuffer[11] = 0x00;             //Sector size
       clr.b     11(A2)
; gDataBuffer[12] = 0x02;
       move.b    #2,12(A2)
; gDataBuffer[13] = SecPerClus;   //Sectors per cluster
       move.b    D7,13(A2)
; gDataBuffer[14] = 0x26;         //Reserved sector count
       move.b    #38,14(A2)
; gDataBuffer[15] = 0x00;
       clr.b     15(A2)
; fat = 0x26 + firsts;
       moveq     #38,D0
       ext.w     D0
       ext.l     D0
       add.l     D4,D0
       move.l    D0,A3
; gDataBuffer[16] = 0x02;         //number of FATs
       move.b    #2,16(A2)
; gDataBuffer[17] = 0x00;          //Max number of root directory entries - 512 files allowed
       clr.b     17(A2)
; gDataBuffer[18] = 0x00;
       clr.b     18(A2)
; gDataBuffer[19] = 0x00;         //total sectors
       clr.b     19(A2)
; gDataBuffer[20] = 0x00;
       clr.b     20(A2)
; gDataBuffer[21] = 0xF8;         //Media Descriptor
       move.b    #248,21(A2)
; gDataBuffer[22] = 0x00;         //Sectors per FAT
       clr.b     22(A2)
; gDataBuffer[23] = 0x00;
       clr.b     23(A2)
; gDataBuffer[24] = 0x3F;         //Sectors per track
       move.b    #63,24(A2)
; gDataBuffer[25] = 0x00;
       clr.b     25(A2)
; gDataBuffer[26] = 0xFF;         //Number of heads
       move.b    #255,26(A2)
; gDataBuffer[27] = 0x00;
       clr.b     27(A2)
; // Hidden sectors = sectors between the MBR and the boot sector
; gDataBuffer[28] = (unsigned char)(firsts & 0xFF);
       move.l    D4,D0
       and.l     #255,D0
       move.b    D0,28(A2)
; gDataBuffer[29] = (unsigned char)((firsts / 0x100) & 0xFF);
       move.l    D4,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,29(A2)
; gDataBuffer[30] = (unsigned char)((firsts / 0x10000) & 0xFF);
       move.l    D4,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,30(A2)
; gDataBuffer[31] = (unsigned char)((firsts / 0x1000000) & 0xFF);
       move.l    D4,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,31(A2)
; // Total Sectors = same as sectors in the partition from MBR
; gDataBuffer[32] = (unsigned char)(secCount & 0xFF);
       move.l    D3,D0
       and.l     #255,D0
       move.b    D0,32(A2)
; gDataBuffer[33] = (unsigned char)((secCount / 0x100) & 0xFF);
       move.l    D3,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,33(A2)
; gDataBuffer[34] = (unsigned char)((secCount / 0x10000) & 0xFF);
       move.l    D3,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,34(A2)
; gDataBuffer[35] = (unsigned char)((secCount / 0x1000000) & 0xFF);
       move.l    D3,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,35(A2)
; // Sectors per FAT
; gDataBuffer[36] = (unsigned char)(fatsize & 0xFF);
       move.l    D5,D0
       and.l     #255,D0
       move.b    D0,36(A2)
; gDataBuffer[37] = (unsigned char)((fatsize / 0x100) & 0xFF);
       move.l    D5,-(A7)
       pea       256
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,37(A2)
; gDataBuffer[38] = (unsigned char)((fatsize / 0x10000) & 0xFF);
       move.l    D5,-(A7)
       pea       65536
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,38(A2)
; gDataBuffer[39] = (unsigned char)((fatsize / 0x1000000) & 0xFF);
       move.l    D5,-(A7)
       pea       16777216
       jsr       ULDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,39(A2)
; gDataBuffer[40] = 0x00;         //Active FAT
       clr.b     40(A2)
; gDataBuffer[41] = 0x00;
       clr.b     41(A2)
; gDataBuffer[42] = 0x00;         //File System version
       clr.b     42(A2)
; gDataBuffer[43] = 0x00;
       clr.b     43(A2)
; gDataBuffer[44] = 0x02;         //First cluster of the root directory
       move.b    #2,44(A2)
; gDataBuffer[45] = 0x00;
       clr.b     45(A2)
; gDataBuffer[46] = 0x00;
       clr.b     46(A2)
; gDataBuffer[47] = 0x00;
       clr.b     47(A2)
; gDataBuffer[48] = 0x01;         //FSInfo
       move.b    #1,48(A2)
; gDataBuffer[49] = 0x00;
       clr.b     49(A2)
; gDataBuffer[50] = 0x00;         //Backup Boot Sector
       clr.b     50(A2)
; gDataBuffer[51] = 0x00;
       clr.b     51(A2)
; gDataBuffer[52] = 0x00;         //Reserved for future expansion
       clr.b     52(A2)
; gDataBuffer[53] = 0x00;
       clr.b     53(A2)
; gDataBuffer[54] = 0x00;
       clr.b     54(A2)
; gDataBuffer[55] = 0x00;
       clr.b     55(A2)
; gDataBuffer[56] = 0x00;
       clr.b     56(A2)
; gDataBuffer[57] = 0x00;
       clr.b     57(A2)
; gDataBuffer[58] = 0x00;
       clr.b     58(A2)
; gDataBuffer[59] = 0x00;
       clr.b     59(A2)
; gDataBuffer[60] = 0x00;
       clr.b     60(A2)
; gDataBuffer[61] = 0x00;
       clr.b     61(A2)
; gDataBuffer[62] = 0x00;
       clr.b     62(A2)
; gDataBuffer[63] = 0x00;
       clr.b     63(A2)
; gDataBuffer[64] = 0x00;         // Physical drive number
       clr.b     64(A2)
; gDataBuffer[65] = 0x00;         // Reserved (current head)
       clr.b     65(A2)
; gDataBuffer[66] = 0x29;         // Signature code
       move.b    #41,66(A2)
; gDataBuffer[67] = (unsigned char)(serialNumber & 0xFF);
       move.l    8(A6),D0
       and.l     #255,D0
       move.b    D0,67(A2)
; gDataBuffer[68] = (unsigned char)((serialNumber / 0x100) & 0xFF);
       move.l    8(A6),-(A7)
       pea       256
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       and.l     #255,D0
       move.b    D0,68(A2)
; gDataBuffer[69] = (unsigned char)((serialNumber / 0x10000) & 0xFF);
       move.l    8(A6),D0
       asr.l     #8,D0
       asr.l     #8,D0
       and.l     #255,D0
       move.b    D0,69(A2)
; gDataBuffer[70] = (unsigned char)((serialNumber / 0x1000000) & 0xFF);
       move.l    8(A6),D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       and.l     #255,D0
       move.b    D0,70(A2)
; // Volume ID
; if (volumeID != NULL)
       clr.b     D0
       and.l     #255,D0
       move.l    A5,D1
       cmp.l     D0,D1
       beq       fsFormat_14
; {
; for (Index = 0; (*(volumeID + Index) != 0) && (Index < 11); Index++)
       clr.l     D2
fsFormat_16:
       move.b    0(A5,D2.L),D0
       beq.s     fsFormat_18
       cmp.l     #11,D2
       bhs.s     fsFormat_18
; {
; gDataBuffer[Index + 71] = *(volumeID + Index);
       move.l    D2,A0
       move.b    0(A5,D2.L),71(A0,A2.L)
       addq.l    #1,D2
       bra       fsFormat_16
fsFormat_18:
; }
; while (Index < 11)
fsFormat_19:
       cmp.l     #11,D2
       bhs.s     fsFormat_21
; {
; gDataBuffer[71 + Index++] = 0x20;
       move.l    D2,A0
       addq.l    #1,D2
       move.b    #32,71(A0,A2.L)
       bra       fsFormat_19
fsFormat_21:
       bra.s     fsFormat_24
fsFormat_14:
; }
; }
; else
; {
; for (Index = 0; Index < 11; Index++)
       clr.l     D2
fsFormat_22:
       cmp.l     #11,D2
       bhs.s     fsFormat_24
; {
; gDataBuffer[Index+71] = 0;
       move.l    D2,A0
       clr.b     71(A0,A2.L)
       addq.l    #1,D2
       bra       fsFormat_22
fsFormat_24:
; }
; }
; gDataBuffer[82] = 'F';
       move.b    #70,82(A2)
; gDataBuffer[83] = 'A';
       move.b    #65,83(A2)
; gDataBuffer[84] = 'T';
       move.b    #84,84(A2)
; gDataBuffer[85] = '3';
       move.b    #51,85(A2)
; gDataBuffer[86] = '2';
       move.b    #50,86(A2)
; gDataBuffer[87] = ' ';
       move.b    #32,87(A2)
; gDataBuffer[88] = ' ';
       move.b    #32,88(A2)
; gDataBuffer[89] = ' ';
       move.b    #32,89(A2)
; gDataBuffer[510] = 0x55;
       move.b    #85,510(A2)
; gDataBuffer[511] = 0xAA;
       move.b    #170,511(A2)
; if (!fsSectorWrite(firsts, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D4,-(A7)
       jsr       (A4)
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFormat_25
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra       fsFormat_3
fsFormat_25:
; // Erase the FAT
; memset (gDataBuffer, 0x00, MEDIA_SECTOR_SIZE);
       pea       512
       clr.l     -(A7)
       move.l    A2,-(A7)
       jsr       _memset
       add.w     #12,A7
; gDataBuffer[0] = 0xF8;          //BPB_Media byte value in its low 8 bits, and all other bits are set to 1
       move.b    #248,(A2)
; gDataBuffer[1] = 0xFF;
       move.b    #255,1(A2)
; gDataBuffer[2] = 0xFF;
       move.b    #255,2(A2)
; gDataBuffer[3] = 0x0F;
       move.b    #15,3(A2)
; gDataBuffer[4] = 0xFF;          //Disk is clean and no read/write errors were encountered
       move.b    #255,4(A2)
; gDataBuffer[5] = 0xFF;
       move.b    #255,5(A2)
; gDataBuffer[6] = 0xFF;
       move.b    #255,6(A2)
; gDataBuffer[7] = 0xFF;
       move.b    #255,7(A2)
; gDataBuffer[8]  = 0xFF;         //Root Directory EOF
       move.b    #255,8(A2)
; gDataBuffer[9]  = 0xFF;
       move.b    #255,9(A2)
; gDataBuffer[10] = 0xFF;
       move.b    #255,10(A2)
; gDataBuffer[11] = 0x0F;
       move.b    #15,11(A2)
; for (j = 1; j != 0xFFFF; j--)
       moveq     #1,D6
fsFormat_27:
       cmp.w     #65535,D6
       beq       fsFormat_29
; {
; if (!fsSectorWrite (fat + (j * fatsize), gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    A3,D1
       and.l     #65535,D6
       move.l    D6,-(A7)
       move.l    D5,-(A7)
       move.l    D0,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    (A7)+,D0
       add.l     D0,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFormat_30
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra       fsFormat_3
fsFormat_30:
       subq.w    #1,D6
       bra       fsFormat_27
fsFormat_29:
; }
; memset (gDataBuffer, 0x00, 12);
       pea       12
       clr.l     -(A7)
       move.l    A2,-(A7)
       jsr       _memset
       add.w     #12,A7
; for (Index = fat + 1; Index < (fat + fatsize); Index++)
       move.l    A3,D0
       addq.l    #1,D0
       move.l    D0,D2
fsFormat_32:
       move.l    A3,D0
       add.l     D5,D0
       cmp.l     D0,D2
       bhs       fsFormat_34
; {
; for (j = 1; j != 0xFFFF; j--)
       moveq     #1,D6
fsFormat_35:
       cmp.w     #65535,D6
       beq       fsFormat_37
; {
; if (!fsSectorWrite (Index + (j * fatsize), gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    D2,D1
       and.l     #65535,D6
       move.l    D6,-(A7)
       move.l    D5,-(A7)
       move.l    D0,-(A7)
       jsr       ULMUL
       move.l    (A7),D0
       addq.w    #8,A7
       move.l    (A7)+,D0
       add.l     D0,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFormat_38
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra       fsFormat_3
fsFormat_38:
       subq.w    #1,D6
       bra       fsFormat_35
fsFormat_37:
       addq.l    #1,D2
       bra       fsFormat_32
fsFormat_34:
; }
; }
; // Erase the root directory
; for (Index = 1; Index < SecPerClus; Index++)
       moveq     #1,D2
fsFormat_40:
       and.l     #255,D7
       cmp.l     D7,D2
       bhs.s     fsFormat_42
; {
; if (!fsSectorWrite (root + Index, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    -12(A6),D1
       add.l     D2,D1
       move.l    D1,-(A7)
       jsr       (A4)
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFormat_43
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra       fsFormat_3
fsFormat_43:
       addq.l    #1,D2
       bra       fsFormat_40
fsFormat_42:
; }
; // Create a drive name entry in the root dir
; Index = 0;
       clr.l     D2
; while ((*(volumeID + Index) != 0) && (Index < 11))
fsFormat_45:
       move.b    0(A5,D2.L),D0
       beq.s     fsFormat_47
       cmp.l     #11,D2
       bhs.s     fsFormat_47
; {
; gDataBuffer[Index] = *(volumeID + Index);
       move.b    0(A5,D2.L),0(A2,D2.L)
; Index++;
       addq.l    #1,D2
       bra       fsFormat_45
fsFormat_47:
; }
; while (Index < 11)
fsFormat_48:
       cmp.l     #11,D2
       bhs.s     fsFormat_50
; {
; gDataBuffer[Index++] = ' ';
       move.l    D2,D0
       addq.l    #1,D2
       move.b    #32,0(A2,D0.L)
       bra       fsFormat_48
fsFormat_50:
; }
; gDataBuffer[11] = 0x08;
       move.b    #8,11(A2)
; gDataBuffer[17] = 0x11;
       move.b    #17,17(A2)
; gDataBuffer[19] = 0x11;
       move.b    #17,19(A2)
; gDataBuffer[23] = 0x11;
       move.b    #17,23(A2)
; if (!fsSectorWrite (root, gDataBuffer, FALSE))
       clr.l     -(A7)
       move.l    A2,-(A7)
       move.l    -12(A6),-(A7)
       jsr       (A4)
       add.w     #12,A7
       tst.b     D0
       bne.s     fsFormat_51
; return ERRO_B_WRITE_DISK;
       move.b    #226,D0
       bra.s     fsFormat_3
fsFormat_51:
; return RETURN_OK;
       clr.b     D0
fsFormat_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsSectorRead(unsigned long vsector, unsigned char* vbuffer){
       xdef      _fsSectorRead
_fsSectorRead:
       link      A6,#-24
       movem.l   D2/D3/D4/D5/A2/A3/A4,-(A7)
       lea       _fsSendByte.L,A2
       lea       -22(A6),A3
       lea       _fsRecByte.L,A4
       move.l    8(A6),D5
; unsigned char vbytes[4], dd, vByte = 0;
       clr.b     D2
; unsigned int ix, cc;
; unsigned long vsectorok;
; unsigned char sqtdtam[11];
; vsectorok = (vsector & 0xFF000000) >> 24;
       move.l    D5,D0
       and.l     #-16777216,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,D3
; vbytes[0] = (unsigned char)vsectorok;
       move.b    D3,(A3)
; vsectorok = (vsector & 0x00FF0000) >> 16;
       move.l    D5,D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,D3
; vbytes[1] = (unsigned char)vsectorok;
       move.b    D3,1(A3)
; vsectorok = (vsector & 0x0000FF00) >> 8;
       move.l    D5,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D0,D3
; vbytes[2] = (unsigned char)vsectorok;
       move.b    D3,2(A3)
; vsectorok = vsector & 0x000000FF;
       move.l    D5,D0
       and.l     #255,D0
       move.l    D0,D3
; vbytes[3] = (unsigned char)vsectorok;
       move.b    D3,3(A3)
; // Envia comando resetar e abortar tudo
; fsSendByte('a', FS_CMD);
       clr.l     -(A7)
       pea       97
       jsr       (A2)
       addq.w    #8,A7
; // Comando recebido ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     fsSectorRead_1
; return 0;
       clr.b     D0
       bra       fsSectorRead_3
fsSectorRead_1:
; // Envia Cluster
; fsSendByte(vbytes[0], FS_PAR);
       pea       2
       move.b    (A3),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; fsSendByte(vbytes[1], FS_PAR);
       pea       2
       move.b    1(A3),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; fsSendByte(vbytes[2], FS_PAR);
       pea       2
       move.b    2(A3),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; fsSendByte(vbytes[3], FS_PAR);
       pea       2
       move.b    3(A3),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; // Envia offset
; fsSendByte(0x00, FS_PAR);
       pea       2
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; fsSendByte(0x00, FS_PAR);
       pea       2
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; // Envia Qtd (512)
; fsSendByte(0x02, FS_PAR);
       pea       2
       pea       2
       jsr       (A2)
       addq.w    #8,A7
; fsSendByte(0x00, FS_PAR);
       pea       2
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; // Envia comando
; fsSendByte('r', FS_CMD);
       clr.l     -(A7)
       pea       114
       jsr       (A2)
       addq.w    #8,A7
; // Comando recebido ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     fsSectorRead_4
; return 0;
       clr.b     D0
       bra       fsSectorRead_3
fsSectorRead_4:
; // Comando Executado ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     fsSectorRead_6
; return 0;
       clr.b     D0
       bra.s     fsSectorRead_3
fsSectorRead_6:
; // Carrega Dados Recebidos
; for (cc = 0; cc < 512 ; cc++)
       clr.l     D4
fsSectorRead_8:
       cmp.l     #512,D4
       bhs.s     fsSectorRead_10
; {
; vByte = fsRecByte(FS_DATA);
       pea       1
       jsr       (A4)
       addq.w    #4,A7
       move.b    D0,D2
; *(vbuffer + cc) = vByte;
       move.l    12(A6),A0
       move.b    D2,0(A0,D4.L)
       addq.l    #1,D4
       bra       fsSectorRead_8
fsSectorRead_10:
; }
; return 1;
       moveq     #1,D0
fsSectorRead_3:
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3/A4
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned char fsSectorWrite(unsigned long vsector, unsigned char* vbuffer, unsigned char vtipo){
       xdef      _fsSectorWrite
_fsSectorWrite:
       link      A6,#-24
       movem.l   D2/D3/D4/D5/A2/A3/A4,-(A7)
       lea       -22(A6),A2
       lea       _fsSendByte.L,A3
       move.l    8(A6),D5
       lea       _fsRecByte.L,A4
; unsigned char vbytes[4], dd, vByte = 0;
       clr.b     D2
; unsigned int ix, cc;
; unsigned long vsectorok;
; unsigned char sqtdtam[11];
; vsectorok = (vsector & 0xFF000000) >> 24;
       move.l    D5,D0
       and.l     #-16777216,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,D3
; vbytes[0] = (unsigned char)vsectorok;
       move.b    D3,(A2)
; vsectorok = (vsector & 0x00FF0000) >> 16;
       move.l    D5,D0
       and.l     #16711680,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,D3
; vbytes[1] = (unsigned char)vsectorok;
       move.b    D3,1(A2)
; vsectorok = (vsector & 0x0000FF00) >> 8;
       move.l    D5,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D0,D3
; vbytes[2] = (unsigned char)vsectorok;
       move.b    D3,2(A2)
; vsectorok = vsector & 0x000000FF;
       move.l    D5,D0
       and.l     #255,D0
       move.l    D0,D3
; vbytes[3] = (unsigned char)vsectorok;
       move.b    D3,3(A2)
; // Envia comando resetar e abortar tudo
; fsSendByte('a', FS_CMD);
       clr.l     -(A7)
       pea       97
       jsr       (A3)
       addq.w    #8,A7
; // Comando recebido ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     fsSectorWrite_1
; return 0;
       clr.b     D0
       bra       fsSectorWrite_3
fsSectorWrite_1:
; // Envia Buffer
; for (cc = 0; cc < 512 ; cc++)
       clr.l     D4
fsSectorWrite_4:
       cmp.l     #512,D4
       bhs.s     fsSectorWrite_6
; {
; vByte = *(vbuffer + cc);
       move.l    12(A6),A0
       move.b    0(A0,D4.L),D2
; fsSendByte(vByte, FS_DATA);
       pea       1
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D4
       bra       fsSectorWrite_4
fsSectorWrite_6:
; }
; // Envia Cluster
; fsSendByte(vbytes[0], FS_PAR);
       pea       2
       move.b    (A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; fsSendByte(vbytes[1], FS_PAR);
       pea       2
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; fsSendByte(vbytes[2], FS_PAR);
       pea       2
       move.b    2(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; fsSendByte(vbytes[3], FS_PAR);
       pea       2
       move.b    3(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A3)
       addq.w    #8,A7
; // Envia comando
; fsSendByte('w', FS_CMD);
       clr.l     -(A7)
       pea       119
       jsr       (A3)
       addq.w    #8,A7
; // Comando recebido ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     fsSectorWrite_7
; return 0;
       clr.b     D0
       bra.s     fsSectorWrite_3
fsSectorWrite_7:
; // Comando Executado ok ?
; vByte = fsRecByte(FS_CMD);
       clr.l     -(A7)
       jsr       (A4)
       addq.w    #4,A7
       move.b    D0,D2
; if (vByte != ALL_OK)
       tst.b     D2
       beq.s     fsSectorWrite_9
; return 0;
       clr.b     D0
       bra.s     fsSectorWrite_3
fsSectorWrite_9:
; return 1;
       moveq     #1,D0
fsSectorWrite_3:
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3/A4
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void catFile(unsigned char *parquivo) {
       xdef      _catFile
_catFile:
       link      A6,#-24
       movem.l   D2/D3/D4/D5,-(A7)
       move.l    8(A6),D5
; unsigned short vbytepic;
; unsigned char *mcfgfileptr = 0x00, *mcfgfilebase = 0x00, vqtd = 1;
       clr.l     D2
       clr.l     D3
       move.b    #1,-19(A6)
; unsigned char *parqptr = parquivo;
       move.l    D5,-18(A6)
; unsigned long vsizefile, vsizefilemalloc;
; unsigned char sqtdtam[10];
; while (*parqptr++)
catFile_1:
       move.l    -18(A6),A0
       addq.l    #1,-18(A6)
       tst.b     (A0)
       beq.s     catFile_3
; vqtd++;
       addq.b    #1,-19(A6)
       bra       catFile_1
catFile_3:
; vsizefilemalloc = fsInfoFile(parquivo, INFO_SIZE);
       pea       1
       move.l    D5,-(A7)
       jsr       _fsInfoFile
       addq.w    #8,A7
       move.l    D0,-14(A6)
; mcfgfilebase = malloc(vsizefilemalloc);
       move.l    -14(A6),-(A7)
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,D3
; if (!mcfgfilebase) {
       tst.l     D3
       bne.s     catFile_4
; printText("No memory to load file...\r\n\0");
       pea       @mmsjos_55.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
; return;
       bra       catFile_6
catFile_4:
; }
; mcfgfileptr = mcfgfilebase;
       move.l    D3,D2
; vsizefile = loadFile(parquivo, (unsigned long*)mcfgfileptr);   // 12K espaco pra carregar arquivo. Colocar logica pra pegar tamanho e alocar espaco
       move.l    D2,-(A7)
       move.l    D5,-(A7)
       jsr       _loadFile
       addq.w    #8,A7
       move.l    D0,D4
; if (!verro) {
       tst.b     _verro.L
       bne       catFile_7
; /*itoa(vsizefile, sqtdtam, 10);
; printText(sqtdtam);
; printText("\r\n\0");*/
; while (vsizefile > 0) {
catFile_9:
       cmp.l     #0,D4
       bls       catFile_11
; /*itoa(vsizefile, sqtdtam, 10);
; printText(sqtdtam);
; printText("\r\n\0");*/
; if (*mcfgfileptr == 0x0D) {
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #13,D0
       bne.s     catFile_12
; printText("\r\0");
       pea       @mmsjos_69.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       catFile_20
catFile_12:
; }
; else if (*mcfgfileptr == 0x0A) {
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #10,D0
       bne.s     catFile_14
; printText("\r\n\0");
       pea       @mmsjos_1.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
       bra       catFile_20
catFile_14:
; }
; else if (*mcfgfileptr == 0x1A || *mcfgfileptr == 0x00) {
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #26,D0
       beq.s     catFile_18
       move.l    D2,A0
       move.b    (A0),D0
       bne.s     catFile_16
catFile_18:
; break;
       bra       catFile_11
catFile_16:
; }
; else {
; if (*mcfgfileptr >= 0x20 && *mcfgfileptr < 0xFF)
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #32,D0
       blo.s     catFile_19
       move.l    D2,A0
       move.b    (A0),D0
       and.w     #255,D0
       cmp.w     #255,D0
       bhs.s     catFile_19
; printChar(*mcfgfileptr, 1);
       pea       1
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
       bra.s     catFile_20
catFile_19:
; else
; printChar(0x20, 1);
       pea       1
       pea       32
       move.l    1062,A0
       jsr       (A0)
       addq.w    #8,A7
catFile_20:
; }
; mcfgfileptr++;
       addq.l    #1,D2
; vsizefile--;
       subq.l    #1,D4
       bra       catFile_9
catFile_11:
       bra.s     catFile_8
catFile_7:
; }
; }
; else {
; printText("Loading file error...\r\n\0");
       pea       @mmsjos_70.L
       move.l    1058,A0
       jsr       (A0)
       addq.w    #4,A7
catFile_8:
; }
; free(mcfgfilebase);
       move.l    D3,-(A7)
       jsr       _free
       addq.w    #4,A7
catFile_6:
       movem.l   (A7)+,D2/D3/D4/D5
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned long loadFile(unsigned char *parquivo, unsigned short* xaddress)
; {
       xdef      _loadFile
_loadFile:
       link      A6,#-528
       movem.l   D2/D3/D4/A2/A3/A4,-(A7)
       lea       _vretpath.L,A2
       lea       -526(A6),A3
       lea       _verro.L,A4
; unsigned short cc, dd;
; unsigned char vbuffer[512];
; unsigned int vbytegrava = 0;
       clr.l     D4
; unsigned short xdado = 0, xcounter = 0;
       clr.w     -14(A6)
       clr.w     -12(A6)
; unsigned short vcrc, vcrcpic, vloop;
; unsigned long vsizeR, vsizefile = 0;
       clr.l     D2
; //*tempData = parquivo;
; //*(tempData + 1) = xaddress;
; vsizefile = 0;
       clr.l     D2
; verro = 0;
       clr.b     (A4)
; if (fsFindDirPath(parquivo, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
       clr.l     -(A7)
       move.l    8(A6),-(A7)
       jsr       _fsFindDirPath
       addq.w    #8,A7
       and.w     #255,D0
       cmp.w     #255,D0
       bne.s     loadFile_1
; {
; verro = 1;
       move.b    #1,(A4)
; return vsizefile;
       move.l    D2,D0
       bra       loadFile_3
loadFile_1:
; }
; vclusterdir = vretpath.ClusterDir;
       move.l    14(A2),_vclusterdir.L
; if (fsOpenFile(vretpath.Name) == RETURN_OK)
       move.l    A2,-(A7)
       jsr       _fsOpenFile
       addq.w    #4,A7
       tst.b     D0
       bne       loadFile_4
; {
; while (1)
loadFile_6:
; {
; vsizeR = fsReadFile(vretpath.Name, vsizefile, vbuffer, 512);
       pea       512
       move.l    A3,-(A7)
       move.l    D2,-(A7)
       move.l    A2,-(A7)
       jsr       _fsReadFile
       add.w     #16,A7
       and.l     #65535,D0
       move.l    D0,-4(A6)
; if (vsizeR != 0)
       move.l    -4(A6),D0
       beq       loadFile_9
; {
; for (dd = 0; dd < 512; dd += 2)
       clr.w     D3
loadFile_11:
       cmp.w     #512,D3
       bhs       loadFile_13
; {
; vbytegrava = (unsigned short)vbuffer[dd] << 8;
       and.l     #65535,D3
       move.b    0(A3,D3.L),D0
       and.l     #255,D0
       lsl.l     #8,D0
       move.l    D0,D4
; vbytegrava = vbytegrava | (vbuffer[dd + 1] & 0x00FF);
       and.l     #65535,D3
       move.l    D3,A0
       move.b    1(A0,A3.L),D0
       and.w     #255,D0
       and.w     #255,D0
       ext.l     D0
       or.l      D0,D4
; // Grava Dados na Posição Especificada
; *xaddress = vbytegrava;
       move.l    12(A6),A0
       move.w    D4,(A0)
; xaddress += 1;
       addq.l    #2,12(A6)
       addq.w    #2,D3
       bra       loadFile_11
loadFile_13:
; }
; vsizefile += 512;
       add.l     #512,D2
       bra.s     loadFile_10
loadFile_9:
; }
; else
; break;
       bra.s     loadFile_8
loadFile_10:
       bra       loadFile_6
loadFile_8:
; }
; // Fecha o Arquivo
; fsCloseFile(vretpath.Name, 0);
       clr.l     -(A7)
       move.l    A2,-(A7)
       jsr       _fsCloseFile
       addq.w    #8,A7
       bra.s     loadFile_5
loadFile_4:
; }
; else
; verro = 1;
       move.b    #1,(A4)
loadFile_5:
; vclusterdir = vretpath.ClusterDirAtu;
       move.l    18(A2),_vclusterdir.L
; return vsizefile;
       move.l    D2,D0
loadFile_3:
       movem.l   (A7)+,D2/D3/D4/A2/A3/A4
       unlk      A6
       rts
; }
; //-------------------------------------------------------------------------
; unsigned short datetimetodir(unsigned char hr_day, unsigned char min_month, unsigned char sec_year, unsigned char vtype)
; {
       xdef      _datetimetodir
_datetimetodir:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; unsigned short vconv = 0, vtemp;
       clr.w     D2
; if (vtype == CONV_DATA) {
       move.b    23(A6),D0
       cmp.b     #1,D0
       bne       datetimetodir_1
; vtemp = sec_year - 1980;
       move.b    19(A6),D0
       and.w     #255,D0
       sub.w     #1980,D0
       move.w    D0,D3
; vconv  = (unsigned short)(vtemp & 0x7F) << 9;
       move.w    D3,D0
       and.w     #127,D0
       lsl.w     #8,D0
       lsl.w     #1,D0
       move.w    D0,D2
; vconv |= (unsigned short)(min_month & 0x0F) << 5;
       move.b    15(A6),D0
       and.b     #15,D0
       and.w     #255,D0
       lsl.w     #5,D0
       or.w      D0,D2
; vconv |= (unsigned short)(hr_day & 0x1F);
       move.b    11(A6),D0
       and.b     #31,D0
       and.w     #255,D0
       or.w      D0,D2
       bra       datetimetodir_2
datetimetodir_1:
; }
; else {
; vconv  = (unsigned short)(hr_day & 0x1F) << 11;
       move.b    11(A6),D0
       and.b     #31,D0
       and.w     #255,D0
       lsl.w     #8,D0
       lsl.w     #3,D0
       move.w    D0,D2
; vconv |= (unsigned short)(min_month & 0x3F) << 5;
       move.b    15(A6),D0
       and.b     #63,D0
       and.w     #255,D0
       lsl.w     #5,D0
       or.w      D0,D2
; vtemp = sec_year / 2;
       move.b    19(A6),D0
       and.l     #65535,D0
       divu.w    #2,D0
       and.w     #255,D0
       move.w    D0,D3
; vconv |= (unsigned short)(vtemp & 0x1F);
       move.w    D3,D0
       and.w     #31,D0
       or.w      D0,D2
datetimetodir_2:
; }
; return vconv;
       move.w    D2,D0
       movem.l   (A7)+,D2/D3
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
; void strncpy2( char* _dst, const char* _src, int _n )
; {
       xdef      _strncpy2
_strncpy2:
       link      A6,#0
       move.l    D2,-(A7)
; int i = 0;
       clr.l     D2
; while(i != _n)
strncpy2_1:
       cmp.l     16(A6),D2
       beq.s     strncpy2_3
; {
; *_dst = *_src;
       move.l    12(A6),A0
       move.l    8(A6),A1
       move.b    (A0),(A1)
; _dst++;
       addq.l    #1,8(A6)
; _src++;
       addq.l    #1,12(A6)
; i++;
       addq.l    #1,D2
       bra       strncpy2_1
strncpy2_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; //-----------------------------------------------------------------------------
; int isValidFilename(char *filename)
; {
       xdef      _isValidFilename
_isValidFilename:
       link      A6,#-76
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       -14(A6),A2
       lea       -4(A6),A3
       move.l    8(A6),D5
       lea       _strncpy2.L,A4
       lea       _strchr.L,A5
; char valid_chars[60];
; int len, i;
; char name_part[9];
; char ext_part[4];
; char *dot;
; int name_len = 0, ext_len = 0;
       clr.l     D4
       clr.l     D6
; strcpy(valid_chars,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$&'()@^_`{}~");
       pea       @mmsjos_71.L
       pea       -74(A6)
       jsr       _strcpy
       addq.w    #8,A7
; len = strlen(filename);
       move.l    D5,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D3
; // Verificar comprimento total
; if (len == 0 || len > 12) {
       tst.l     D3
       beq.s     isValidFilename_3
       cmp.l     #12,D3
       ble.s     isValidFilename_1
isValidFilename_3:
; return 0;
       clr.l     D0
       bra       isValidFilename_4
isValidFilename_1:
; }
; // Dividir o nome e a extensão (se existir)
; name_part[0] = '\0';
       clr.b     (A2)
; ext_part[0] = '\0';
       clr.b     (A3)
; dot = strchr(filename, '.');
       pea       46
       move.l    D5,-(A7)
       jsr       (A5)
       addq.w    #8,A7
       move.l    D0,D7
; if (dot) {
       tst.l     D7
       beq       isValidFilename_5
; // Nome e extensão devem ser separados pelo ponto
; name_len = dot - filename;
       move.l    D7,D0
       sub.l     D5,D0
       move.l    D0,D4
; ext_len = len - name_len - 1;
       move.l    D3,D0
       sub.l     D4,D0
       subq.l    #1,D0
       move.l    D0,D6
; if (name_len == 0 || name_len > 8 || ext_len > 3) {
       tst.l     D4
       beq.s     isValidFilename_9
       cmp.l     #8,D4
       bgt.s     isValidFilename_9
       cmp.l     #3,D6
       ble.s     isValidFilename_7
isValidFilename_9:
; return 0; // Nome ou extensão inválidos
       clr.l     D0
       bra       isValidFilename_4
isValidFilename_7:
; }
; strncpy2(name_part, filename, name_len);
       move.l    D4,-(A7)
       move.l    D5,-(A7)
       move.l    A2,-(A7)
       jsr       (A4)
       add.w     #12,A7
; name_part[name_len] = 0x00;
       clr.b     0(A2,D4.L)
; strncpy2(ext_part, dot + 1, ext_len);
       move.l    D6,-(A7)
       move.l    D7,D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       move.l    A3,-(A7)
       jsr       (A4)
       add.w     #12,A7
; ext_part[ext_len] = 0x00;
       clr.b     0(A3,D6.L)
       bra.s     isValidFilename_6
isValidFilename_5:
; } else {
; // Sem ponto, apenas o nome principal
; if (len > 8) {
       cmp.l     #8,D3
       ble.s     isValidFilename_10
; return 0;
       clr.l     D0
       bra       isValidFilename_4
isValidFilename_10:
; }
; strncpy2(name_part, filename, len);
       move.l    D3,-(A7)
       move.l    D5,-(A7)
       move.l    A2,-(A7)
       jsr       (A4)
       add.w     #12,A7
; name_part[len] = 0x00;
       clr.b     0(A2,D3.L)
isValidFilename_6:
; }
; // Validar o nome
; for (i = 0; name_part[i] != '\0'; i++) {
       clr.l     D2
isValidFilename_12:
       move.b    0(A2,D2.L),D0
       beq       isValidFilename_14
; if (!strchr(valid_chars, toupper(name_part[i]))) {
       move.l    D0,-(A7)
       move.l    D0,-(A7)
       move.b    0(A2,D2.L),D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -74(A6)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     isValidFilename_15
; return 0;
       clr.l     D0
       bra       isValidFilename_4
isValidFilename_15:
       addq.l    #1,D2
       bra       isValidFilename_12
isValidFilename_14:
; }
; }
; // Validar a extensão (se houver)
; for (i = 0; ext_part[i] != '\0'; i++) {
       clr.l     D2
isValidFilename_17:
       move.b    0(A3,D2.L),D0
       beq       isValidFilename_19
; if (!strchr(valid_chars, toupper(ext_part[i]))) {
       move.l    D0,-(A7)
       move.l    D0,-(A7)
       move.b    0(A3,D2.L),D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       pea       -74(A6)
       jsr       (A5)
       addq.w    #8,A7
       tst.l     D0
       bne.s     isValidFilename_20
; return 0;
       clr.l     D0
       bra.s     isValidFilename_4
isValidFilename_20:
       addq.l    #1,D2
       bra       isValidFilename_17
isValidFilename_19:
; }
; }
; return 1; // Tudo está correto
       moveq     #1,D0
isValidFilename_4:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; // Função para verificar se um nome de arquivo corresponde ao padrão
; unsigned char matches_wildcard(const char *pattern, const char *filename)
; {
       xdef      _matches_wildcard
_matches_wildcard:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.l    8(A6),D2
       move.l    12(A6),D3
; while (*pattern && *filename)
matches_wildcard_1:
       move.l    D2,A0
       tst.b     (A0)
       beq       matches_wildcard_3
       move.l    D3,A0
       tst.b     (A0)
       beq       matches_wildcard_3
; {
; if (*pattern == '*')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #42,D0
       bne       matches_wildcard_4
; {
; // Avança no padrão e tenta corresponder com todos os sufixos possíveis
; pattern++;
       addq.l    #1,D2
; if (!*pattern)
       move.l    D2,A0
       tst.b     (A0)
       bne.s     matches_wildcard_6
; return 1; // '*' no final combina com qualquer coisa
       moveq     #1,D0
       bra       matches_wildcard_18
matches_wildcard_6:
; while (*filename)
matches_wildcard_9:
       move.l    D3,A0
       tst.b     (A0)
       beq.s     matches_wildcard_11
; {
; if (matches_wildcard(pattern, filename))
       move.l    D3,-(A7)
       move.l    D2,-(A7)
       jsr       _matches_wildcard
       addq.w    #8,A7
       tst.b     D0
       beq.s     matches_wildcard_12
; return 1;
       moveq     #1,D0
       bra       matches_wildcard_18
matches_wildcard_12:
; filename++;
       addq.l    #1,D3
       bra       matches_wildcard_9
matches_wildcard_11:
; }
; return 0;
       clr.b     D0
       bra       matches_wildcard_18
matches_wildcard_4:
; }
; else if (*pattern == '?' || *pattern == *filename)
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #63,D0
       beq.s     matches_wildcard_16
       move.l    D2,A0
       move.l    D3,A1
       move.b    (A0),D0
       cmp.b     (A1),D0
       bne.s     matches_wildcard_14
matches_wildcard_16:
; {
; // '?' combina com qualquer caractere ou caracteres iguais
; pattern++;
       addq.l    #1,D2
; filename++;
       addq.l    #1,D3
       bra.s     matches_wildcard_15
matches_wildcard_14:
; }
; else
; {
; return 0;
       clr.b     D0
       bra.s     matches_wildcard_18
matches_wildcard_15:
       bra       matches_wildcard_1
matches_wildcard_3:
; }
; }
; // Retorna true se ambos terminarem juntos
; return (!*pattern && !*filename);
       move.l    D2,A0
       tst.b     (A0)
       bne.s     matches_wildcard_17
       move.l    D3,A0
       tst.b     (A0)
       bne.s     matches_wildcard_17
       moveq     #1,D0
       bra.s     matches_wildcard_18
matches_wildcard_17:
       clr.l     D0
matches_wildcard_18:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; // Função principal para filtrar arquivos
; //-----------------------------------------------------------------------------
; void filter_files(const char *pattern, const char **file_list, int file_count, char **result_list, int *result_count)
; {
       xdef      _filter_files
_filter_files:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int count = 0, i;
       clr.l     D3
; for (i = 0; i < file_count; i++)
       clr.l     D2
filter_files_1:
       cmp.l     16(A6),D2
       bge       filter_files_3
; {
; if (matches_wildcard(pattern, file_list[i]))
       move.l    12(A6),A0
       move.l    D2,D1
       lsl.l     #2,D1
       move.l    0(A0,D1.L),-(A7)
       move.l    8(A6),-(A7)
       jsr       _matches_wildcard
       addq.w    #8,A7
       tst.b     D0
       beq.s     filter_files_4
; {
; result_list[count++] = file_list[i];
       move.l    12(A6),A0
       move.l    D2,D0
       lsl.l     #2,D0
       move.l    20(A6),A1
       move.l    D3,D1
       addq.l    #1,D3
       lsl.l     #2,D1
       move.l    0(A0,D0.L),0(A1,D1.L)
filter_files_4:
       addq.l    #1,D2
       bra       filter_files_1
filter_files_3:
; }
; }
; *result_count = count;
       move.l    24(A6),A0
       move.l    D3,(A0)
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned char contains_wildcards(const char *pattern)
; {
       xdef      _contains_wildcards
_contains_wildcards:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; while (*pattern)
contains_wildcards_1:
       move.l    D2,A0
       tst.b     (A0)
       beq.s     contains_wildcards_3
; {
; if (*pattern == '*' || *pattern == '?')
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #42,D0
       beq.s     contains_wildcards_6
       move.l    D2,A0
       move.b    (A0),D0
       cmp.b     #63,D0
       bne.s     contains_wildcards_4
contains_wildcards_6:
; {
; return 1;
       moveq     #1,D0
       bra.s     contains_wildcards_7
contains_wildcards_4:
; }
; pattern++;
       addq.l    #1,D2
       bra       contains_wildcards_1
contains_wildcards_3:
; }
; return 0;
       clr.b     D0
contains_wildcards_7:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned long fsMalloc(unsigned long vMemSize)
; {
       xdef      _fsMalloc
_fsMalloc:
       link      A6,#-4
; unsigned char * mMemDef;
; mMemDef = malloc(vMemSize);
       move.l    8(A6),-(A7)
       jsr       _malloc
       addq.w    #4,A7
       move.l    D0,-4(A6)
; return mMemDef;
       move.l    -4(A6),D0
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; void fsFree(unsigned long vAddress)
; {
       xdef      _fsFree
_fsFree:
       link      A6,#0
; free(vAddress);
       move.l    8(A6),-(A7)
       jsr       _free
       addq.w    #4,A7
       unlk      A6
       rts
; }
; #ifdef __SO_ST_MFP__
; //-----------------------------------------------------------------------------
; void fsSetMfp(unsigned int Config, unsigned char Value, unsigned char TypeSet)
; {
       xdef      _fsSetMfp
_fsSetMfp:
       link      A6,#0
; if (TypeSet)
       tst.b     19(A6)
       beq.s     fsSetMfp_1
; *(vmfp + Config) = Value;
       move.l    _vmfp.L,A0
       move.l    8(A6),D0
       move.b    15(A6),0(A0,D0.L)
       bra.s     fsSetMfp_2
fsSetMfp_1:
; else
; *(vmfp + Config) |= Value;
       move.l    _vmfp.L,A0
       move.l    8(A6),D0
       move.b    15(A6),D1
       or.b      D1,0(A0,D0.L)
fsSetMfp_2:
       unlk      A6
       rts
; }
; //-----------------------------------------------------------------------------
; unsigned int fsGetMfp(unsigned int Config)
; {
       xdef      _fsGetMfp
_fsGetMfp:
       link      A6,#-4
; unsigned int retValue;
; retValue = *(vmfp + Config);
       move.l    _vmfp.L,A0
       move.l    8(A6),D0
       move.b    0(A0,D0.L),D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; return retValue;
       move.l    -4(A6),D0
       unlk      A6
       rts
; }
; #endif
       section   const
@mmsjos_1:
       dc.b      13,10,0
@mmsjos_2:
       dc.b      77,77,83,74,45,79,83,32,118,49,46,48,97,48,50
       dc.b      0
@mmsjos_3:
       dc.b      80,111,119,101,114,101,100,32,98,121,32,117
       dc.b      67,47,79,83,45,73,73,32,118,50,46,57,49,0
@mmsjos_4:
       dc.b      69,114,114,111,114,58,32,0
@mmsjos_5:
       dc.b      70,105,108,101,32,110,111,116,32,102,111,117
       dc.b      110,100,0
@mmsjos_6:
       dc.b      82,101,97,100,105,110,103,32,100,105,115,107
       dc.b      0
@mmsjos_7:
       dc.b      87,114,105,116,105,110,103,32,100,105,115,107
       dc.b      0
@mmsjos_8:
       dc.b      79,112,101,110,105,110,103,32,100,105,115,107
       dc.b      0
@mmsjos_9:
       dc.b      73,110,118,97,108,105,100,32,70,111,108,100
       dc.b      101,114,32,111,114,32,70,105,108,101,32,78,97
       dc.b      109,101,0
@mmsjos_10:
       dc.b      68,105,114,101,99,116,111,114,121,32,110,111
       dc.b      116,32,102,111,117,110,100,0
@mmsjos_11:
       dc.b      67,114,101,97,116,105,110,103,32,102,105,108
       dc.b      101,0
@mmsjos_12:
       dc.b      68,101,108,101,116,105,110,103,32,102,105,108
       dc.b      101,0
@mmsjos_13:
       dc.b      70,105,108,101,32,97,108,114,101,97,100,121
       dc.b      32,101,120,105,115,116,0
@mmsjos_14:
       dc.b      85,112,100,97,116,105,110,103,32,100,105,114
       dc.b      101,99,116,111,114,121,0
@mmsjos_15:
       dc.b      79,102,102,115,101,116,32,114,101,97,100,0
@mmsjos_16:
       dc.b      68,105,115,107,32,102,117,108,108,0
@mmsjos_17:
       dc.b      82,101,97,100,105,110,103,32,102,105,108,101
       dc.b      0
@mmsjos_18:
       dc.b      87,114,105,116,105,110,103,32,102,105,108,101
       dc.b      0
@mmsjos_19:
       dc.b      68,105,114,101,99,116,111,114,121,32,97,108
       dc.b      114,101,97,100,121,32,101,120,105,115,116,0
@mmsjos_20:
       dc.b      67,114,101,97,116,105,110,103,32,100,105,114
       dc.b      101,99,116,111,114,121,0
@mmsjos_21:
       dc.b      68,105,114,101,99,116,111,114,121,32,110,111
       dc.b      116,32,101,109,112,116,121,0
@mmsjos_22:
       dc.b      78,111,116,32,102,111,117,110,100,0
@mmsjos_23:
       dc.b      32,45,32,85,110,107,110,111,119,110,32,67,111
       dc.b      100,101,0
@mmsjos_24:
       dc.b      33,13,10,0
@mmsjos_25:
       dc.b      80,111,119,101,114,101,100,32,98,121,32,117
       dc.b      67,47,79,83,45,73,73,32,118,50,46,57,49,13,10
       dc.b      0
@mmsjos_26:
       dc.b      85,116,105,108,105,116,121,32,40,99,41,32,50
       dc.b      48,49,52,45,50,48,50,54,13,10,0
@mmsjos_27:
       dc.b      47,0
@mmsjos_28:
       dc.b      79,107,13,10,0
@mmsjos_29:
       dc.b      35,62,0
@mmsjos_30:
       dc.b      0
@mmsjos_31:
       dc.b      67,76,83,0
@mmsjos_32:
       dc.b      67,76,69,65,82,0
@mmsjos_33:
       dc.b      81,85,73,84,0
@mmsjos_34:
       dc.b      86,69,82,0
@mmsjos_35:
       dc.b      77,71,85,73,0
@mmsjos_36:
       dc.b      80,87,68,0
@mmsjos_37:
       dc.b      76,83,0
@mmsjos_38:
       dc.b      82,77,0
@mmsjos_39:
       dc.b      67,80,0
@mmsjos_40:
       dc.b      70,105,108,101,32,110,111,116,32,102,111,117
       dc.b      110,100,46,13,10,0
@mmsjos_41:
       dc.b      70,105,108,101,32,110,111,116,32,102,111,117
       dc.b      110,100,46,46,13,10,0
@mmsjos_42:
       dc.b      82,69,78,0
@mmsjos_43:
       dc.b      102,105,108,101,32,110,111,116,32,102,111,117
       dc.b      110,100,46,13,10,0
@mmsjos_44:
       dc.b      77,68,0
@mmsjos_45:
       dc.b      67,68,0
@mmsjos_46:
       dc.b      82,68,0
@mmsjos_47:
       dc.b      83,84,79,70,0
@mmsjos_48:
       dc.b      56,49,48,48,48,48,0
@mmsjos_49:
       dc.b      83,84,79,82,0
@mmsjos_50:
       dc.b      68,65,84,69,0
@mmsjos_51:
       dc.b      84,73,77,69,0
@mmsjos_52:
       dc.b      70,79,82,77,65,84,0
@mmsjos_53:
       dc.b      77,79,68,69,0
@mmsjos_54:
       dc.b      67,65,84,0
@mmsjos_55:
       dc.b      78,111,32,109,101,109,111,114,121,32,116,111
       dc.b      32,108,111,97,100,32,102,105,108,101,46,46,46
       dc.b      13,10,0
@mmsjos_56:
       dc.b      76,111,97,100,105,110,103,32,70,105,108,101
       dc.b      32,105,110,32,0
@mmsjos_57:
       dc.b      104,13,10,0
@mmsjos_58:
       dc.b      76,111,97,100,105,110,103,32,70,105,108,101
       dc.b      32,69,114,114,111,114,46,46,46,13,10,0
@mmsjos_59:
       dc.b      73,110,118,97,108,105,100,32,67,111,109,109
       dc.b      97,110,100,32,111,114,32,70,105,108,101,32,78
       dc.b      97,109,101,13,10,0
@mmsjos_60:
       dc.b      32,32,68,97,116,101,32,105,115,32,0
@mmsjos_61:
       dc.b      32,32,84,105,109,101,32,105,115,32,0
@mmsjos_62:
       dc.b      70,111,114,109,97,116,32,100,105,115,107,32
       dc.b      119,97,115,32,115,117,99,99,101,115,115,102
       dc.b      117,108,108,121,13,10,0
@mmsjos_63:
       dc.b      69,114,114,111,114,44,32,102,105,108,101,32
       dc.b      110,97,109,101,32,109,117,115,116,32,98,101
       dc.b      32,112,114,111,118,105,100,101,100,33,33,13
       dc.b      10,0
@mmsjos_64:
       dc.b      79,112,101,110,105,110,103,32,70,105,108,101
       dc.b      46,46,46,13,10,0
@mmsjos_65:
       dc.b      87,114,105,116,105,110,103,32,70,105,108,101
       dc.b      46,46,46,13,10,0
@mmsjos_66:
       dc.b      13,10,67,108,111,115,105,110,103,32,70,105,108
       dc.b      101,46,46,46,13,10,0
@mmsjos_67:
       dc.b      83,101,114,105,97,108,32,76,111,97,100,32,69
       dc.b      114,114,111,114,46,46,46,0
@mmsjos_68:
       dc.b      82,117,110,110,105,110,103,32,97,116,32,0
@mmsjos_69:
       dc.b      13,0
@mmsjos_70:
       dc.b      76,111,97,100,105,110,103,32,102,105,108,101
       dc.b      32,101,114,114,111,114,46,46,46,13,10,0
@mmsjos_71:
       dc.b      65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
       dc.b      80,81,82,83,84,85,86,87,88,89,90,48,49,50,51
       dc.b      52,53,54,55,56,57,33,35,36,38,39,40,41,64,94
       dc.b      95,96,123,125,126,0
       xdef      _strValidChars
_strValidChars:
       dc.b      48,49,50,51,52,53,54,55,56,57,65,66,67,68,69
       dc.b      70,71,72,73,74,75,76,77,78,79,80,81,82,83,84
       dc.b      85,86,87,88,89,90,94,38,39,64,123,125,91,93
       dc.b      44,36,61,33,45,35,40,41,37,46,43,126,95,0
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
       section   bss
       xdef      _runOSMemory
_runOSMemory:
       ds.b      4
       xdef      _vdir
_vdir:
       ds.b      37
       xdef      _vdisk
_vdisk:
       ds.b      34
       xdef      _vclusterdir
_vclusterdir:
       ds.b      4
       xdef      _vbuf
_vbuf:
       ds.b      128
       xdef      _gDataBuffer
_gDataBuffer:
       ds.b      512
       xdef      _verroSo
_verroSo:
       ds.b      2
       xdef      _vdiratu
_vdiratu:
       ds.b      128
       xdef      _vdiratuidx
_vdiratuidx:
       ds.b      2
       xdef      _verro
_verro:
       ds.b      1
       xdef      _vretpath
_vretpath:
       ds.b      22
       xdef      _vretpath2
_vretpath2:
       ds.b      22
       xdef      _vMemAloc
_vMemAloc:
       ds.b      30
       xdef      __allocp
__allocp:
       ds.b      4
       xdef      _StkInput
_StkInput:
       ds.b      2048
       xdef      _StkMgui
_StkMgui:
       ds.b      4096
       xdef      _StkTask01
_StkTask01:
       ds.b      4096
       xdef      _StkTask02
_StkTask02:
       ds.b      4096
       xdef      _StkTask03
_StkTask03:
       ds.b      4096
       xdef      _StkTask04
_StkTask04:
       ds.b      4096
       xdef      _StkTask05
_StkTask05:
       ds.b      4096
       xdef      _StkTask06
_StkTask06:
       ds.b      4096
       xdef      _shared_sem
_shared_sem:
       ds.b      4
       xref      _memcpy
       xref      _strcpy
       xref      _itoa
       xref      LDIV
       xref      LMUL
       xref      _free
       xref      _vmfp
       xref      _OSTaskSuspend
       xref      _strlen
       xref      _Reg_IMRA
       xref      _startMGI
       xref      ULMUL
       xref      _malloc
       xref      _OSTimeDlyHMSM
       xref      _OSTaskDel
       xref      _memset
       xref      _OSInit
       xref      _OSStart
       xref      _OSSemPost
       xref      _OSTaskCreate
       xref      _toupper
       xref      _strchr
       xref      _Reg_IERA
       xref      _runFromOsCmd
       xref      _OSSemPend
       xref      _strcmp
       xref      _OSTaskQuery
       xref      ULDIV
       xref      _OSSemCreate
