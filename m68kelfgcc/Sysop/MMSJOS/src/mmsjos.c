/********************************************************************************
*    Programa    : mmsjos.c
*    Objetivo    : MMSJOS - Versao vintage compatible
*    Criado em   : 11/03/2024
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 18/12/2024  0.1     Moacir Jr.   Criação Versão Beta
*                                  Adaptar para FAT32 com uno e SD CARD
* 25/12/2024  0.2     Moacir Jr.   Carregar Dados da Serial e Gravar no Arquivo
* 04/01/2025  0.3     Moacir Jr.   Receber pasta no nome do arquivo "<pasta>/<file>"
* 08/01/2025  0.4     Moacir Jr.   Implementar wildcards "*?" para LS, RM e CP
* 18/01/2025  0.5     Moacir Jr.   Adaptar uC/OS-II - RTOS
* 13/04/2026  1.0a03  Moacir Jr.   Ajustes no malloc/realloc/free e inclusao do xmodem 1k crc
*                                  Ajustes no cat, fat, rd, rm e prompt
* 20/04/2026  1.0a04  Moacir Jr.   Ajustes chamar basic com malloc e passagem de parametros
* 28/04/2026  1.0a05  Moacir Jr.   Convertido para m68k-elf-gcc e retirada do malloc/realloc/free
* 10/05/2026  1.0a06  Moacir Jr.   Remover uC/OS-II - RTOS
********************************************************************************/
#include <ctype.h>
#include <string.h>
#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
#if defined(USE_MALLOC)
#include <malloc.h>
#endif
#endif
#if !defined(USE_MALLOC) && !defined(USE_MSMALLOC)
#define ADDR_LOAD_FILE 0x00840000
#endif
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitor.h"
#include "monitorapi.h"

unsigned long runOSMemory;

#define MMSJ_HEAP_LIMIT 0x008CFFFFUL
#define MPRINTF_BUF_SIZE 128
//#define ENABLE_UPDATE_LAST_ACCESS 1

#ifdef USE_MSMALLOC
#define HEAP_START  ((unsigned char*)0x00820000)
#define HEAP_SIZE   0x000AFFFFUL   /* 704 KB */

typedef struct MEMBLOCK {
    unsigned long size;
    unsigned char used;
    struct MEMBLOCK *next;
} MEMBLOCK;

static MEMBLOCK *heapFirst = 0;
#endif

//---------------------------------
// Compatibilidade com Basic
//---------------------------------
void OSTaskSuspend(int taskId)
{

}

void OSTaskResume(int taskId)
{

}
//---------------------------------

unsigned char vdp_mode; // Modo de video 0 = caracter (32 x 24), 1 = grafico (256 x 192)

#define RT_FONTDIR 0x8007
#define RT_FONT    0x8008

static unsigned int rd16(unsigned char *p)
{
    return (unsigned int)p[0] | ((unsigned int)p[1] << 8);
}

static unsigned long rd32(unsigned char *p)
{
    return (unsigned long)p[0] |
           ((unsigned long)p[1] << 8) |
           ((unsigned long)p[2] << 16) |
           ((unsigned long)p[3] << 24);
}

#ifdef USE_RELOC_LOAD_PROGS
typedef struct
{
    char magic[4];
    unsigned long version;
    unsigned long textDataSize;
    unsigned long bssSize;
    unsigned long entryOffset;
    unsigned long relocCount;
} MBIN_HEADER;

typedef void (*PROG_ENTRY)(void);

int loadMbinAndRun(char *filename, char porig)
{
    MBIN_HEADER h;
    unsigned char *fileBuf;
    unsigned char *codeBase;
    unsigned char *relocPtr;
    unsigned long fullBufSize;
    unsigned long fullFileSize;
    unsigned long i;
    unsigned long relocOffset;
    unsigned long *pFix;
    unsigned char *vEnderExec;
    unsigned char tmp[20];
    unsigned long dbgRet;

    /* Passo 1: lê só o header para obter os tamanhos */
    loadFileSize(filename, &h, sizeof(MBIN_HEADER));

    if (h.magic[0] != 'E' ||
        h.magic[1] != 'X' ||
        h.magic[2] != 'E' ||
        h.magic[3] != ' ')
    {
        return -1;
    }

    /* Tamanho do arquivo no disco */
    fullFileSize = sizeof(MBIN_HEADER) + h.textDataSize + h.relocCount * 4UL;

    /* Buffer único: header + código + max(bss, tabela de reloc) + bss
       O código fica em fileBuf+sizeof(MBIN_HEADER); o BSS vem logo depois.
       A tabela de reloc (que está no arquivo logo após o código) será
       usada primeiro e depois sobrescrita pelo memset do BSS. */
    fullBufSize = sizeof(MBIN_HEADER) + h.textDataSize + h.bssSize;

    if (fullFileSize > fullBufSize)
        fullBufSize = fullFileSize;   /* garante espaço para a tabela de reloc */

    fileBuf = msmalloc(fullBufSize);

    if (!fileBuf)
        return -2;

    /* Carrega o arquivo inteiro (header + código + tabela de reloc) */
    {
        dbgRet = loadFileSize(filename, fileBuf, fullFileSize);
    }

    /* codeBase aponta diretamente para o início do código dentro do buffer,
       pulando o header - sem memcpy */
    codeBase = fileBuf + sizeof(MBIN_HEADER);

    relocPtr = codeBase + h.textDataSize;

    for (i = 0; i < h.relocCount; i++)
    {
        relocOffset = *(unsigned long *)(relocPtr + i * 4UL);

        if (relocOffset + 4 > h.textDataSize)
        {
            msfree(fileBuf);
            return -11;
        }

        pFix = (unsigned long *)(codeBase + relocOffset);

        *pFix = *pFix + (unsigned long)codeBase;
    }

    memset(codeBase + h.textDataSize, 0, h.bssSize);

    vEnderExec = codeBase + h.entryOffset;

    if (((unsigned long)vEnderExec & 1) != 0)
    {
        msfree(fileBuf);
        return -10;
    }

    if (porig == 1)
    {
        runFromOsCmd((unsigned long)vEnderExec);
        
        msfree(fileBuf);
    }
    else if (porig == 2)
    {
        strcat(paramBasic, ",");
        ltoa((unsigned long)vEnderExec, tmp, 10);
        strcat(paramBasic, tmp);

        runFromMGUI((unsigned long)vEnderExec, (unsigned long)fileBuf);
    }

    printText("\r\n\0");

    return 0;
}
#endif

FAT32_DIR vdir;
DISK  vdisk;
unsigned long vclusterdir;
unsigned char vbuf[128]; // Buffer Linha Digitavel, maximo de 128 caracteres -
unsigned char  gDataBuffer[512]; // The global data sector buffer to 0x00609FF7
unsigned short  verroSo;
unsigned char  vdiratu[128]; // Buffer de pasta atual 128 bytes
unsigned short  vdiratuidx; // Pointer Buffer de pasta atual 128 bytes (SO FUNCIONA NA RAM)
unsigned char verro;
RET_PATH vretpath;
RET_PATH vretpath2;
MEM_ALOC vMemAloc;

//--- KeyBOard Functions
int mmsjKeyHit(void);
int mmsjKeyPost(MMSJ_KEYEVENT *k);
int mmsjKeyGet(MMSJ_KEYEVENT *k);

//--- FAT16 Functions
unsigned long fsInit(void);
void fsVer(void);
void printDiskError(unsigned char pError);
unsigned char fsMountDisk(void);
unsigned long fsOsCommand(unsigned char * linhaParametro);
unsigned char fsFormat (long int serialNumber, char * volumeID);
void fsSetClusterDir (unsigned long vclusdiratu);
unsigned long fsGetClusterDir (void);
unsigned char fsSectorWrite(unsigned long vsector, unsigned char* vbuffer, unsigned char vtipo);
unsigned char fsSectorRead(unsigned long vsector, unsigned char* vbuffer);
int fsRecSerial(unsigned char* pByte, unsigned char pTimeOut);
int fsSendSerial(unsigned char pByte);
int fsSendByte(unsigned char vByte, unsigned char pType);
unsigned char fsRecByte(unsigned char pType);
int fsSendLongSerial(unsigned char *msg);
void fsConvClusterToTHS(unsigned short cluster, unsigned char* vtrack, unsigned char* vside, unsigned char* vsector);
void fsReadDir(unsigned short ix, unsigned short vdata);

// Funcoes de Manipulacao de Arquivos
unsigned char fsCreateFile(char * vfilename);
unsigned char fsOpenFile(char * vfilename);
unsigned char fsCloseFile(char * vfilename, unsigned char vupdated);
unsigned long fsInfoFile(char * vfilename, unsigned char vtype);
unsigned char fsRWFile(unsigned long vclusterini, unsigned long voffset, unsigned char *buffer, unsigned char vtype);
unsigned short fsReadFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer);
unsigned char fsWriteFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer);
unsigned char fsDelFile(char * vfilename);
unsigned char fsRenameFile(char * vfilename, char * vnewname);
void runFromOsCmd(unsigned long vEnderExec);
unsigned long loadFile(unsigned char *parquivo, void* xaddress);
unsigned long loadFileSize(unsigned char *parquivo, void* xaddress, unsigned long xsize);
unsigned char saveFile(unsigned char *parquivo, void* xaddress, unsigned long xsize);
void catFile(unsigned char *parquivo);
unsigned char fsLoadSerialToFile(char * vfilename);
unsigned char fsLoadSerialToRun(char * vfilename);
unsigned char fsFindDirPath(char * vpath, char vtype);
void fsGetDirAtuData(FAT32_DIR *pDir);
unsigned long fsMalloc(unsigned long vMemSize);
void fsFree(unsigned long vAddress);
void runFromMGUI(unsigned long vEnderExec, unsigned long vFileBuf);
static unsigned char fsCheckDirEmpty(unsigned long vdircluster);

// Funcoes de Manipulacao de Diretorios
unsigned char fsMakeDir(char * vdirname);
unsigned char fsChangeDir(char * vdirname);
unsigned char fsRemoveDir(char * vdirname);
unsigned char fsPwdDir(unsigned char *vdirpath);

// Funcoes de Apoio
unsigned short fsLoadFat(unsigned short vclusteratual);
unsigned long fsFindInDir(char * vname, unsigned char vtype);
unsigned char fsUpdateDir(void);
unsigned long fsFindNextCluster(unsigned long vclusteratual, unsigned char vtype);
unsigned long fsFindClusterFree(unsigned char vtype);
unsigned int bcd2dec(unsigned int bcd);
int getDateTimeAtu(void);
unsigned short datetimetodir(unsigned char hr_day, unsigned char min_month, unsigned char sec_year, unsigned char vtype);
unsigned long pow(int val, int pot);
int hex2int(char ch);
unsigned long hexToLong(char *pHex);
void strncpy2( char* _dst, const char* _src, int _n );
int isValidFilename(char *filename) ;
unsigned char matches_wildcard(const char *pattern, const char *filename);
unsigned char contains_wildcards(const char *pattern);
int getFontUseG2(MGUI_SET_FONT *fonInfo);
int setFontUseG2(unsigned char vpos);
int loadFontUseG2(unsigned char vpos, unsigned char *fileName, unsigned char *bufLoad, unsigned char *bufSave);

#ifdef USE_MSPRINTF_MMSJOS
void mprintf_ulong_hex(unsigned long v);
void mprintf_long_dec(long v);
void mprintf_ulong_dec(unsigned long v);
void mprintf(const char *fmt, ...);
#endif

#ifdef __SO_ST_MFP__
void fsSetMfp(unsigned int Config, unsigned char Value, unsigned char TypeSet);
unsigned int fsGetMfp(unsigned int Config);
#endif

MGUI_SET_FONT addrSetFontUseG2; // Endereco da funcao setFontUseG2, para ser usada por programas externos
MGUI_SET_FONT listFontsUseG2[4]; 

const unsigned char strValidChars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^&'@{}[],$=!-#()%.+~_";

const unsigned char vmesc[12][3] = {{'J','a','n'},{'F','e','b'},{'M','a','r'},
                                    {'A','p','r'},{'M','a','y'},{'J','u','n'},
                                    {'J','u','l'},{'A','u','g'},{'S','e','p'},
                                    {'O','c','t'},{'N','o','v'},{'D','e','c'}};

// Funcoes de Alocacao de Memoria
char memInit(void);

HEADER *_allocp;

#define versionMMSJOS "1.0a06"
#define STOF_RX_BUFFER_SIZE (512UL * 1024UL)
#define FS_SECTOR_RETRY_COUNT 3
#define FS_ENABLE_WRITE_VERIFY 1

static unsigned char basicFuncArg[64];
static unsigned char mmsjosExecPath[256];

static void mmsjosSetDefaultExecPath(void);
static unsigned char mmsjosSaveConfig(void);
static void mmsjosLoadConfig(void);
static void mmsjosBuildExeName(const unsigned char *cmd, unsigned char *out, unsigned short outSize);
static unsigned char mmsjosFindExecutable(unsigned char *progName, unsigned char *outName, unsigned long *outCluster);
static void mmsjosBuildArgPath(const unsigned char *arg, unsigned char *out, unsigned short outSize);

void keyboardFunc(void *pdata);
void inputFunc(void *pdata);   
void mguiFunc(void *pdata);    
void basicFunc(void *pdata);   
void prog01Func(void *pdata);   

//-----------------------------------------------------------------------------
// FAT16 Functions
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
unsigned long fsInit(void)
{
    char verr = 0;

    if (fsMountDisk())
    {
        printDiskError(ERRO_B_OPEN_DISK);
        return ERRO_B_OPEN_DISK;
    }

    vdiratuidx = 1;
    vdiratu[0] = '/';
    vdiratu[vdiratuidx] = 0x00;

    return 0;
}

//-----------------------------------------------------------------------------
void fsVer(void)
{
    printText("\r\n\0");
    printText("MMSJ-OS v"versionMMSJOS);
    printText("\r\n\0");
}

//-----------------------------------------------------------------------------
static void mmsjosSetDefaultExecPath(void)
{
    strcpy((char *)mmsjosExecPath, "/;/EDIT;/MCALC");
}

//-----------------------------------------------------------------------------
static unsigned char mmsjosSaveConfig(void)
{
    unsigned char cfg[384];
    unsigned long len;

    cfg[0] = 0;
    strcat((char *)cfg, "PATH=");
    strcat((char *)cfg, (char *)mmsjosExecPath);
    strcat((char *)cfg, "\n");

    len = (unsigned long)strlen((char *)cfg);
    if (saveFile((unsigned char *)"MMSJOS.CFG", cfg, len) != RETURN_OK)
        return 0;

    return 1;
}

//-----------------------------------------------------------------------------
static void mmsjosLoadConfig(void)
{
    unsigned char cfg[384];
    unsigned long sz;
    char *line;
    char *next;

    mmsjosSetDefaultExecPath();

    sz = loadFile((unsigned char *)"MMSJOS.CFG", cfg);
    if (sz == 0)
    {
        mmsjosSaveConfig();
        return;
    }

    if (sz >= sizeof(cfg))
        sz = sizeof(cfg) - 1;

    cfg[sz] = 0;
    line = (char *)cfg;

    while (*line)
    {
        unsigned int i;

        next = strchr(line, '\n');
        if (next)
        {
            *next = 0;
            if (next > line && *(next - 1) == '\r')
                *(next - 1) = 0;
        }

        if (!strncmp(line, "PATH=", 5))
        {
            strncpy((char *)mmsjosExecPath, line + 5, sizeof(mmsjosExecPath) - 1);
            mmsjosExecPath[sizeof(mmsjosExecPath) - 1] = 0;

            for (i = 0; mmsjosExecPath[i] != 0; i++)
                mmsjosExecPath[i] = (unsigned char)toupper(mmsjosExecPath[i]);
        }

        if (!next)
            break;

        line = next + 1;
    }

    if (mmsjosExecPath[0] == 0)
        mmsjosSetDefaultExecPath();
}

//-----------------------------------------------------------------------------
static void mmsjosBuildExeName(const unsigned char *cmd, unsigned char *out, unsigned short outSize)
{
    unsigned short i;
    unsigned char hasDot;

    hasDot = 0;
    i = 0;
    while (cmd[i] != 0)
    {
        if (cmd[i] == '.')
            hasDot = 1;

        if (i < (unsigned short)(outSize - 1))
            out[i] = cmd[i];

        i++;
    }

    if (i >= (unsigned short)(outSize - 1))
        i = (unsigned short)(outSize - 1);

    out[i] = 0;

    if (!hasDot && i < (unsigned short)(outSize - 5))
    {
        out[i++] = '.';
        out[i++] = 'E';
        out[i++] = 'X';
        out[i++] = 'E';
        out[i] = 0;
    }
}

//-----------------------------------------------------------------------------
static void mmsjosBuildArgPath(const unsigned char *arg, unsigned char *out, unsigned short outSize)
{
    unsigned short pos;

    if (outSize == 0)
        return;

    out[0] = 0;

    if (!arg || arg[0] == 0)
        return;

    if (arg[0] == '/')
    {
        strncpy((char *)out, (const char *)arg, outSize - 1);
        out[outSize - 1] = 0;
        return;
    }

    strncpy((char *)out, (const char *)vdiratu, outSize - 1);
    out[outSize - 1] = 0;

    pos = (unsigned short)strlen((char *)out);
    if (pos == 0)
    {
        out[0] = '/';
        out[1] = 0;
        pos = 1;
    }

    if (pos > 0 && out[pos - 1] != '/' && pos < (unsigned short)(outSize - 1))
    {
        out[pos++] = '/';
        out[pos] = 0;
    }

    strncat((char *)out, (const char *)arg, outSize - 1 - pos);
}

//-----------------------------------------------------------------------------
static unsigned char mmsjosFindExecutable(unsigned char *progName, unsigned char *outName, unsigned long *outCluster)
{
    unsigned long curCluster;
    unsigned char pathBuf[256];
    unsigned char token[128];
    unsigned short i;

    curCluster = vclusterdir;

    if (strchr((char *)progName, '/'))
    {
        if (fsFindDirPath((char *)progName, FIND_PATH_LAST) != FIND_PATH_RET_ERROR)
        {
            vclusterdir = vretpath.ClusterDir;
            if (fsFindInDir(vretpath.Name, TYPE_FILE) < ERRO_D_START)
            {
                strcpy((char *)outName, vretpath.Name);
                *outCluster = vretpath.ClusterDir;
                vclusterdir = curCluster;
                return 1;
            }
        }

        vclusterdir = curCluster;
        return 0;
    }

    if (fsFindInDir((char *)progName, TYPE_FILE) < ERRO_D_START)
    {
        strcpy((char *)outName, (char *)progName);
        *outCluster = vclusterdir;
        vclusterdir = curCluster;
        return 1;
    }

    strncpy((char *)pathBuf, (char *)mmsjosExecPath, sizeof(pathBuf) - 1);
    pathBuf[sizeof(pathBuf) - 1] = 0;

    i = 0;
    while (pathBuf[i] != 0)
    {
        unsigned short t = 0;
        unsigned char candidate[160];
        unsigned short c = 0;

        while (pathBuf[i] == ';')
            i++;

        if (pathBuf[i] == 0)
            break;

        while (pathBuf[i] != 0 && pathBuf[i] != ';' && t < (unsigned short)(sizeof(token) - 1))
            token[t++] = pathBuf[i++];

        token[t] = 0;

        if (token[0] == 0)
            continue;

        strcpy((char *)candidate, (char *)token);
        c = (unsigned short)strlen((char *)candidate);
        if (c > 0 && candidate[c - 1] != '/')
        {
            candidate[c++] = '/';
            candidate[c] = 0;
        }
        strcat((char *)candidate, (char *)progName);

        if (fsFindDirPath((char *)candidate, FIND_PATH_LAST) != FIND_PATH_RET_ERROR)
        {
            vclusterdir = vretpath.ClusterDir;
            if (fsFindInDir(vretpath.Name, TYPE_FILE) < ERRO_D_START)
            {
                strcpy((char *)outName, vretpath.Name);
                *outCluster = vretpath.ClusterDir;
                vclusterdir = curCluster;
                return 1;
            }
        }
    }

    vclusterdir = curCluster;
    return 0;
}

//-----------------------------------------------------------------------------
void printDiskError(unsigned char pError)
{
    unsigned char sqtdtam[10];

    printText("Error: ");

    switch( pError )
    {
      case ERRO_B_FILE_NOT_FOUND    : printText("File not found"); break;
      case ERRO_B_READ_DISK         : printText("Reading disk"); break;
      case ERRO_B_WRITE_DISK        : printText("Writing disk"); break;
      case ERRO_B_OPEN_DISK         : printText("Opening disk"); break;
      case ERRO_B_INVALID_NAME      : printText("Invalid Folder or File Name"); break;
      case ERRO_B_DIR_NOT_FOUND     : printText("Directory not found"); break;
      case ERRO_B_CREATE_FILE       : printText("Creating file"); break;
      case ERRO_B_APAGAR_ARQUIVO    : printText("Deleting file"); break;
      case ERRO_B_FILE_FOUND        : printText("File already exist"); break;
      case ERRO_B_UPDATE_DIR        : printText("Updating directory"); break;
      case ERRO_B_OFFSET_READ       : printText("Offset read"); break;
      case ERRO_B_DISK_FULL         : printText("Disk full"); break;
      case ERRO_B_READ_FILE         : printText("Reading file"); break;
      case ERRO_B_WRITE_FILE        : printText("Writing file"); break;
      case ERRO_B_DIR_FOUND         : printText("Directory already exist"); break;
      case ERRO_B_CREATE_DIR        : printText("Creating directory"); break;
      case ERRO_B_DIR_NOT_EMPTY     : printText("Directory not empty"); break;
      case ERRO_B_NOT_FOUND         : printText("Not found"); break;
      default                       :
        itoa(pError, sqtdtam, 10);
        printText(sqtdtam);
        printText(" - Unknown Code");
        break;
    }

    printText("!\r\n\0");
}

//-----------------------------------------------------------------------------
void putPrompt(char pAddLine)
{
//    msprintf("#:%s>",vdiratu);
    printText("#:>");

    if (pAddLine)
        printText("\r\n\0");
}

//-----------------------------------------------------------------------------
// Main Function
//-----------------------------------------------------------------------------
void main(void)
{
    unsigned char vRetInput;
    int vRetProcCmd;
    unsigned long ixxx;

    *startBasic = 1;    // Inicia Basic vindo do MMSJOS com mensagens e textos
    
    vdp_mode = VDP_MODE_TEXT;

    clearScr();

    mprintf("OS> MMSJ-OS v%s\r\n",versionMMSJOS);
    mprintf("OS> Utility (c) 2014-2026\r\n\0");
    mprintf("OS> CPU 68HC000 AT 10MHz\r\n");
    mprintf("OS> TMS9118 Video Display\r\n");
    mprintf("      Graphic %dx%d\r\n", 256, 192);
    mprintf("      Text %dx%d\r\n", 40, 24);
    mprintf("OS> 68901 Multi Peripherical Controller\r\n");
    mprintf("      Timers Controller...\r\n");
    mprintf("      RS-232C at 9600bps...\r\n");
    mprintf("      KeyBoard/Mouse Controller...\r\n");
    mprintf("OS> Total Memory %dKB. Free %dKB\r\n", 1256, 1024);
    mprintf("OS> Starting Management Memory... %s.\r\n", !memInit() ? "Done" : "Error");
    mprintf("OS> Mounting Disk... %s.\r\n", !fsInit() ? "Done" : "Error");
    fsChangeDir("/");
    
    mprintf("OS> Loading MMSJOS Config File... ");
    mmsjosLoadConfig();
    mprintf("Done.\r\n");

    printText("Ok\r\n\0");
    putPrompt(0);

    vbuf[0] = '\0';

    mmsjKeyClear();

    showCursor();

    mmsjKeyClear();

    inputFunc(0);
}

//-----------------------------------------------------------------------------
int mmsjKeyPost(MMSJ_KEYEVENT *k)
{
    unsigned char next;

    next = keyHead + 1;
    if (next >= KEYBUF_SIZE)
        next = 0;

    /* buffer cheio */
    if (next == keyTail)
        return 0;

    keyBuf[keyHead] = *k;
    keyHead = next;

    return 1;
}

//-----------------------------------------------------------------------------
int mmsjKeyGet(MMSJ_KEYEVENT *k)
{
    keyboardFunc(0);

    if (keyHead == keyTail)
        return 0;

    *k = keyBuf[keyTail];

    keyTail++;
    if (keyTail >= KEYBUF_SIZE)
        keyTail = 0;

    return 1;
}

//-----------------------------------------------------------------------------
int mmsjKeyHit(void)
{
    return (keyHead != keyTail);
}

//-----------------------------------------------------------------------------
void mmsjKeyClear(void)
{
    unsigned char i;

    keyHead = 0;
    keyTail = 0;

    for (i = 0; i < KEYBUF_SIZE; i++)
    {
        keyBuf[i].code  = 0;
        keyBuf[i].flags = 0;
        keyBuf[i].ascii = 0;
        keyBuf[i].raw   = 0;
    }
}

//-----------------------------------------------------------------------------
void keyboardFunc(void *pdata)
{
    unsigned char keytec;
    MMSJ_KEYEVENT k;
    keytec = readChar();

    if (keytec != 0x00)
    {
        if (keytec == 0xEF) // CTRL/ALT/SHIFT + Tecla
        {
            k.flags = readChar();
            k.code = readChar();
            k.ascii = k.code;
            k.raw = (k.flags << 8) | k.code;
        }
        else // Char Normal Printavel ASCII ou Control (Backspace, Enter, etc)
        {
            k.flags = 0x00;
            k.code = keytec;
            k.ascii = keytec;
            k.raw = k.code & 0xFF;
        }
        mmsjKeyPost(&k);
    }
}

//-----------------------------------------------------------------------------
void inputFunc(void *pdata)
{
    unsigned char vtec, vtecant = 0;
    unsigned long vRetProcCmd;
    int countCursor = 0;
    unsigned char vbufptr = 0;
    MMSJ_KEYEVENT k;
    
    while (1)
    {
        vtec = 0x00;
        
        if (mmsjKeyGet(&k))
        {
            if (k.flags != 0x00) // CTRL/ALT/Etc
            {
            }
            else
                vtec = k.ascii;
        }

        if (vtec)
        {
            hideCursor();

            if (vtec >= 0x20 && vtec != 0x7F)   // Caracter Printavel menos o DeLete
            {
                // Digitcao Normal
                if (vbufptr > 127)
                {
                    vbufptr--;

                    printChar(0x08, 1);
                }

                printChar(vtec, 1);

                vbuf[vbufptr++] = vtec;
                vbuf[vbufptr] = '\0';
            }
            else if (vtec == 0x08)  // Backspace
            {
                if (vbufptr > 0)
                {
                    vbuf[vbufptr] = 0x00;
                    vbufptr--;

                    printChar(0x08, 1);
                }
            }
            else if (vtec == 0x0D || vtec == 0x0A)
            {
                vRetProcCmd = 1;

                printText("\r\n\0");

                vRetProcCmd = fsOsCommand("\0");

                vbuf[0] = '\0';
                vbufptr = 0x00;

                if (vRetProcCmd)
                    printText("\r\n\0");

                putPrompt(0);
            }

            showCursor();
        }

        vtecant = vtec;
    }
}

//-----------------------------------------------------------------------------
void mguiFunc(void *pData)
{
    startMGI();
}

//-----------------------------------------------------------------------------
void basicFunc(void *pData)
{
    unsigned char *linhaarg = (unsigned char*)pData;
    unsigned short ix;
    unsigned char kbdFuncSuspended;

    // Aloca espaço pro Basic // Area fixa para dados do BASIC: 0x00890000..0x008E0000
    *startBasic0 = msmalloc(262144); // 256 KBytes para o Basic, o suficiente para a maioria dos programas, e ainda sobra para o heap do MMSJOS

    if (!*startBasic0)
    {
        *startBasic0 = 0;

        // Erro
        if (*startBasic == 1)
            printText("No memory to run Basic...\r\n\0");
    }
    else
    {
        kbdFuncSuspended = 0;

        // Carrega parametros pro Basic
        memcpy(paramBasic, linhaarg, 64);
        if (*linhaarg)
        {
            for (ix = 0; ix < 254 && *(linhaarg + ix) != 0x00; ix++)
                *(paramBasic + ix) = toupper(*(linhaarg + ix));

            *(paramBasic + ix) = 0x00;
        }
        else
            *paramBasic = 0x00;

        // Run Basic
        runFromOsCmd(0x00020000); // Testes = 0x00870000, Producao = 0x00020000

        msfree(*startBasic0);

        *startBasic0 = 0;
        *paramBasic = 0;
    }
}

//-----------------------------------------------------------------------------
void prog01Func(void *pdata)
{
    unsigned long vAddrExec = ((unsigned long*)pdata)[0];
    unsigned long vFileBuf = ((unsigned long*)pdata)[1];
    unsigned char tmp[20];

    if (vAddrExec)
    {
        runFromOsCmd(vAddrExec);
    }

#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
    if (vAddrExec <= MMSJ_HEAP_LIMIT)
    {
        #ifdef USE_MALLOC
            if (!vFileBuf)
                free(vAddrExec);
            else
                free(vFileBuf);
        #else
            if (!vFileBuf)
                msfree(vAddrExec);
            else
                msfree(vFileBuf);
        #endif
    }
#endif            
}

//-----------------------------------------------------------------------------
unsigned long fsOsCommand(unsigned char * linhaParametro)
{
    unsigned char linhacomando[64], linhaarg[64], vloop;
    unsigned char *blin = vbuf, vbuffer[128], vlinha[40];
    unsigned short varg = 0;
    unsigned short ix, iy, iz, ikk, isrc;
    unsigned short vbytepic = 0, vrecfim;
    unsigned short vReadSize;
    unsigned char *vdirptr = (unsigned char*)&vdir;
    unsigned char sqtdtam[10], cuntam, vparam[32], vparam2[32], vparam3[32], vparam4[13], vparam5[13], vpicret;
    unsigned long vretfat, vclusterdiratu, vclusterdirsrc, vclusterdirdst, vsizefilemalloc;
    unsigned char *vEnderExec;
    long vqtdtam;
    unsigned long vsizeProg;
    unsigned char izzzz, logpath = 0, logcopyok;
    char cTemp[128];
    unsigned char vposTemp = 0, vrettype, logwildcard = 0;
    FILES_DIR *pDir;

    vretfat = RETURN_OK;

    // Se veio parametro pela linha de parametro, usa esse
    if (linhaParametro[0] != '\0')
        blin = linhaParametro;

    // Separar linha entre comando e argumento
    linhacomando[0] = '\0';
    linhaarg[0] = '\0';
    vparam[0] = '\0';
    vparam2[0] = '\0';
    ix = 0;
    iy = 0;
    while (*blin != 0)
    {
        if (!varg && *blin == 0x20)
        {
            varg = 0x01;
            linhacomando[ix] = '\0';
            iy = ix;
            ix = 0;
        }
        else
        {
            if (!varg)
                linhacomando[ix] = toupper(*blin);
            else
                linhaarg[ix] = toupper(*blin);
            ix++;
        }

        *blin++;
    }

    if (!varg)
    {
        linhacomando[ix] = '\0';
        iy = ix;
    }
    else
    {
        linhaarg[ix] = '\0';

        memset(vparam, 0x00, sizeof(vparam));
        memset(vparam2, 0x00, sizeof(vparam2));

        ikk = 0;
        isrc = 0;
        iz = 0;
        varg = 0;
        while (ikk < ix)
        {
            if (linhaarg[ikk] == 0x20)
            {
                if (!varg && isrc > 0)
                    varg = 1;
            }
            else
            {
                if (!varg)
                {
                    if (isrc < (sizeof(vparam) - 1))
                        vparam[isrc++] = linhaarg[ikk];
                }
                else
                {
                    if (iz < (sizeof(vparam2) - 1))
                        vparam2[iz++] = linhaarg[ikk];
                }
            }

            ikk++;
        }

        vparam[isrc] = '\0';
        vparam2[iz] = '\0';
    }

    if (linhaarg[0] == 0x00)
    {
        vparam[0] = '\0';
        vparam2[0] = '\0';
    }

    vpicret = 0;

/*writeLongSerial("Aqui 150\r\n\0");
writeLongSerial("Comando: ");  
writeLongSerial(linhacomando);
writeLongSerial("\r\n\0");
writeLongSerial("Arg: ");
writeLongSerial(linhaarg);
writeLongSerial("\r\n\0");*/

    // Processar e definir o que fazer
    if (linhacomando[0] != 0)
    {
        if (!strcmp(linhacomando,"CLS") && iy == 3)
        {
            clearScr();
        }
        else if (!strcmp(linhacomando,"CLEAR") && iy == 5)
        {
            clearScr();
        }
        else if (!strcmp(linhacomando,"QUIT") && iy == 4)
        {
            return 99;
        }
        else if (!strcmp(linhacomando,"VER") && iy == 3)
        {
            fsVer();
            printText("\r\n\0");
        }
        else if (!strcmp(linhacomando,"LS") && iy == 2)
        {
            char pNameFile[13];
            pDir = (FILES_DIR*)msmalloc(sizeof(FILES_DIR) * 128);
            fsListDir(pDir, linhaarg);
            ix = 0;

            while (pDir[ix].Name[0] != 0)
            {
                if (pDir[ix].Attr[1] == 'V')
                {
                    mprintf("          Disk name is %s%s\r\n\r\n\0", pDir[ix].Name, pDir[ix].Ext);
                }
                else
                {
                    strcpy(pNameFile, pDir[ix].Name);

                    if (pDir[ix].Ext[0] != 0)
                    {
                        strcat(pNameFile, ".");
                        strcat(pNameFile, pDir[ix].Ext);
                    }

                    if (pDir[ix].Attr[1] == 'D')
                        strcat(pNameFile, "/");

                    mprintf("    %s %s %s\r\n\0", (pDir[ix].Attr[1] == 'D' ? "     " : pDir[ix].Size), pDir[ix].Modify, pNameFile);
                }
                ix++;
            }

            msfree(pDir);
        }
        else if (!strcmp(linhacomando,"MGUI") && iy == 4)
        {
            mguiFunc(0);
            printText("\r\n\0");
        }
        else if (!strcmp(linhacomando,"PWD") && iy == 3)
        {
            printText(vdiratu);
            printText("\r\n\0");
        }
        else if (iy == 2 && (!strcmp(linhacomando,"XX") ||
                             !strcmp(linhacomando,"RM") ||
                             !strcmp(linhacomando,"CP")))
        {
            vclusterdiratu = vclusterdir;

            memcpy(vparam3, vparam, 32);

            if (vparam3[0] > 0x20)
            {
                // Acha o caminho final
                vrettype = fsFindDirPath(vparam3, FIND_PATH_LAST);

                // Verifica se tem wildcard
                logwildcard = contains_wildcards(vretpath.Name);

                // Verifica Erro
                if (vrettype == FIND_PATH_RET_ERROR && !logwildcard)
                {
                    if (linhaParametro[0] == '\0')
                        printText("File not found.\r\n\0");
                    return 0;
                }

                vclusterdir = vretpath.ClusterDir;
                iy = 0;
                iz = 0;
                for (ix = 0; ix < 12; ix++)
                {
                    if (iy)
                        iz++;

                    if (iz == 4)
                        break;

                    if (vretpath.Name[ix] == 0x00 || vretpath.Name[ix] == 0x20)
                        break;

                    if (vretpath.Name[ix] == '.')
                        iy = 1;
                }

                vretpath.Name[ix] = 0x00;
                memcpy(vparam3, vretpath.Name, 13);

                logpath = 1;
            }
            else
                vrettype = FIND_PATH_RET_FOLDER;

            if (fsFindInDir(NULL, TYPE_FIRST_ENTRY) >= ERRO_D_START)
            {
                printText("File not found..\r\n\0");
                if (strcmp(linhacomando,"XX"))
                    vretfat = ERRO_B_NOT_FOUND;
            }
            else
            {
                vclusterdirsrc = vclusterdir;

                while (1)
                {
                    // Pega nome do arquivo atual
                    for (ix = 0; ix <= 7; ix++)
                    {
                        vparam[ix] = vdir.Name[ix];
                        if (vparam[ix] == 0x20 || vparam[ix] == 0x00)
                        {
                            vparam[ix] = '\0';
                            break;
                        }
                    }

                    vparam[ix] = '\0';

                    if (vdir.Name[0] != '.')
                    {
                        vparam[ix] = '.';
                        ix++;
                        for (iy = 0; iy <= 2; iy++)
                        {
                            vparam[ix] = vdir.Ext[iy];
                            if (vparam[ix] == 0x20 || vparam[ix] == 0x00)
                            {
                                vparam[ix] = '\0';
                                break;
                            }
                            ix++;
                        }
                        vparam[ix] = '\0';
                    }

                    if (!strcmp(linhacomando,"XX"))
                    {
                        if (vrettype == FIND_PATH_RET_FOLDER || (vrettype != FIND_PATH_RET_FOLDER && matches_wildcard(vretpath.Name, vparam)))
                        {
                            if (vdir.Attr != ATTR_VOLUME)
                            {
                                memset(vbuffer, 0x0, 128);
                                vdirptr = (unsigned char*)&vdir;

                                for(ix = 40; ix <= 79; ix++)
                                    vbuffer[ix] = *vdirptr++;

                                if (vdir.Attr != ATTR_DIRECTORY)
                                {
                                    // Reduz o tamanho a unidade (GB, MB ou KB)
                                    vqtdtam = vdir.Size;

                                    if ((vqtdtam & 0xC0000000) != 0)
                                    {
                                        cuntam = 'G';
                                        vqtdtam = ((vqtdtam & 0xC0000000) >> 30) + 1;
                                    }
                                    else if ((vqtdtam & 0x3FF00000) != 0)
                                    {
                                        cuntam = 'M';
                                        vqtdtam = ((vqtdtam & 0x3FF00000) >> 20) + 1;
                                    }
                                    else if ((vqtdtam & 0x000FFC00) != 0)
                                    {
                                        cuntam = 'K';
                                        vqtdtam = ((vqtdtam & 0x000FFC00) >> 10) + 1;
                                    }
                                    else
                                        cuntam = ' ';

                                    // Transforma para decimal
                                    memset(sqtdtam, 0x0, 10);
                                    itoa(vqtdtam, sqtdtam, 10);

                                    // Primeira Parte da Linha do dir, tamanho
                                    for(ix = 0; ix <= 3; ix++)
                                    {
                                        if (sqtdtam[ix] == 0)
                                            break;
                                    }

                                    iy = (4 - ix);

                                    for(ix = 0; ix <= 3; ix++)
                                    {
                                        if (iy <= ix)
                                        {
                                            ikk = ix - iy;
                                            vbuffer[ix] = sqtdtam[ix - iy];
                                        }
                                        else
                                            vbuffer[ix] = ' ';
                                    }

                                    vbuffer[4] = cuntam;
                                }
                                else
                                {
                                    vbuffer[0] = ' ';
                                    vbuffer[1] = ' ';
                                    vbuffer[2] = ' ';
                                    vbuffer[3] = ' ';
                                    vbuffer[4] = '0';
                                }

                                vbuffer[5] = ' ';

                                // Segunda parte da linha do dir, data ult modif
                                // Mes
                                vqtdtam = (vdir.UpdateDate & 0x01E0) >> 5;
                                if (vqtdtam < 1 || vqtdtam > 12)
                                    vqtdtam = 1;

                                vqtdtam--;

                                vbuffer[6] = vmesc[vqtdtam][0];
                                vbuffer[7] = vmesc[vqtdtam][1];
                                vbuffer[8] = vmesc[vqtdtam][2];
                                vbuffer[9] = ' ';

                                // Dia
                                vqtdtam = vdir.UpdateDate & 0x001F;
                                memset(sqtdtam, 0x0, 10);
                                itoa(vqtdtam, sqtdtam, 10);

                                if (vqtdtam < 10)
                                {
                                    vbuffer[10] = '0';
                                    vbuffer[11] = sqtdtam[0];
                                }
                                else
                                {
                                    vbuffer[10] = sqtdtam[0];
                                    vbuffer[11] = sqtdtam[1];
                                }
                                vbuffer[12] = ' ';

                                // Ano
                                vqtdtam = ((vdir.UpdateDate & 0xFE00) >> 9) + 1980;
                                memset(sqtdtam, 0x0, 10);
                                itoa(vqtdtam, sqtdtam, 10);

                                vbuffer[13] = sqtdtam[0];
                                vbuffer[14] = sqtdtam[1];
                                vbuffer[15] = sqtdtam[2];
                                vbuffer[16] = sqtdtam[3];
                                vbuffer[17] = ' ';

                                // Terceira parte da linha do dir, nome.ext
                                ix = 18;
                                varg = 0;
                                while (vdir.Name[varg] != 0x20 && vdir.Name[varg] != 0x00 && varg <= 7)
                                {
                                    vbuffer[ix] = vdir.Name[varg];
                                    ix++;
                                    varg++;
                                }

                                vbuffer[ix] = '.';
                                ix++;

                                varg = 0;
                                while (vdir.Ext[varg] != 0x20 && vdir.Ext[varg] != 0x00 && varg <= 2)
                                {
                                    vbuffer[ix] = vdir.Ext[varg];
                                    ix++;
                                    varg++;
                                }

                                if (varg == 0)
                                {
                                    ix--;
                                    vbuffer[ix] = ' ';
                                    ix++;
                                }

                                // Quarta parte da linha do dir, "/" para diretorio
                                if (vdir.Attr == ATTR_DIRECTORY)
                                {
                                    ix--;
                                    vbuffer[ix] = '/';
                                    ix++;
                                }

                                vbuffer[ix] = '\0';

                                for(ix = 0; ix <= 39; ix++)
                                    vlinha[ix] = vbuffer[ix];
                            }
                            else
                            {
                                memset(vlinha, 0x20, 40);
                                vlinha[5]  = 'D';
                                vlinha[6]  = 'i';
                                vlinha[7]  = 's';
                                vlinha[8]  = 'k';
                                vlinha[9]  = ' ';
                                vlinha[10] = 'N';
                                vlinha[11] = 'a';
                                vlinha[12] = 'm';
                                vlinha[13] = 'e';
                                vlinha[14] = ' ';
                                vlinha[15] = 'i';
                                vlinha[16] = 's';
                                vlinha[17] = ' ';
                                ix = 18;
                                varg = 0;
                                while (vdir.Name[varg] != 0x00 && varg <= 7)
                                {
                                    vlinha[ix] = vdir.Name[varg];
                                    ix++;
                                    varg++;
                                }

                                varg = 0;
                                while (vdir.Ext[varg] != 0x00 && varg <= 2)
                                {
                                    vlinha[ix] = vdir.Ext[varg];
                                    ix++;
                                    varg++;
                                }

                                vlinha[ix] = '\0';
                            }

                            // Mostra linha
                            printText("\r\n\0");
                            printText(vlinha);
                        }

                        vretfat = RETURN_OK;

                        // Verifica se Tem mais arquivos no diretorio
                        if (fsFindInDir(vparam, TYPE_NEXT_ENTRY) >= ERRO_D_START)
                        {
                            printText("\r\n\0");
                            break;
                        }
                    }
                    else if (!strcmp(linhacomando,"RM"))
                    {
                        vretfat = RETURN_OK;
                        logcopyok = 1;

                        // Verifica se Tem mais arquivos no diretorio antes de deletar
                        if (fsFindInDir(vparam, TYPE_NEXT_ENTRY) >= ERRO_D_START)
                            logcopyok = 0;
                        else
                        {
                            // Pega o nome do proximo arquivo antes de deletar o atual
                            vparam2[0] = '\0';
                            for (ix = 0; ix <= 7; ix++)
                            {
                                vparam2[ix] = vdir.Name[ix];
                                if (vparam2[ix] == 0x20 || vparam2[ix] == 0x00)
                                {
                                    vparam2[ix] = '\0';
                                    break;
                                }
                            }

                            vparam2[ix] = '\0';

                            if (vdir.Name[0] != '.')
                            {
                                vparam2[ix] = '.';
                                ix++;
                                for (iy = 0; iy <= 2; iy++)
                                {
                                    vparam2[ix] = vdir.Ext[iy];
                                    if (vparam2[ix] == 0x20 || vparam2[ix] == 0x00)
                                    {
                                        vparam2[ix] = '\0';
                                        break;
                                    }
                                    ix++;
                                }
                                vparam2[ix] = '\0';
                            }
                        }

                        if (logwildcard)
                        {
                            if (matches_wildcard(vparam3, vparam))
                            {
                                if (linhaParametro[0] == '\0')
                                {
                                    printText(vparam);
                                    printText("\r\n\0");
                                }

                                vretfat = fsDelFile(vparam);
                            }

                            if (vretfat != RETURN_OK)
                                break;
                        }
                        else
                        {
                            vretfat = fsDelFile(vretpath.Name);
                            break;
                        }

                        if (!logcopyok)
                        {
                            if (linhaParametro[0] == '\0')
                                printText("\r\n\0");
                            break;
                        }
                        else
                        {
                            if (fsFindInDir(vparam2, TYPE_ALL) >= ERRO_D_START)
                            {
                                vretfat = ERRO_B_NOT_FOUND;
                                break;
                            }
                        }
                    }
                    else if (!strcmp(linhacomando,"CP"))
                    {
                        ikk = 0;
                        vretfat = RETURN_OK;
                        logcopyok = 1;

                        if (logwildcard)
                        {
                            if (!matches_wildcard(vparam3, vparam))
                                logcopyok = 0;
                        }
                        else
                            strcpy(vparam, vparam3);

                        vclusterdir = vclusterdirsrc;

                        if (logcopyok)
                        {
                            if (linhaParametro[0] == '\0')
                            {
                                printText(vparam);
                                printText("\r\n\0");
                            }

                            if (fsOpenFile(vparam) != RETURN_OK)
                            {
                                vretfat = ERRO_B_NOT_FOUND;
                            }
                            else
                            {
                                vclusterdir = vclusterdiratu;
                                vrettype = fsFindDirPath(vparam2, FIND_PATH_LAST); // nao tem comparacao com erro pois o arquivo destino pode nao existir
                                if (!isValidFilename(vretpath.Name))
                                    vretfat = ERRO_B_INVALID_NAME;
                                else
                                {
                                    if (vrettype == FIND_PATH_RET_FOLDER)
                                        strcpy(vparam4, vparam);
                                    else
                                        strcpy(vparam4, vretpath.Name);

                                    vclusterdirdst = vretpath.ClusterDir;
                                    vclusterdir = vclusterdirdst;

                                    strcpy(vparam5, "__CP__.TMP");

                                    // Limpa eventual temporario antigo no destino.
                                    if (fsOpenFile(vparam5) == RETURN_OK)
                                    {
                                        if (fsDelFile(vparam5) != RETURN_OK)
                                            vretfat = ERRO_B_APAGAR_ARQUIVO;
                                    }

                                    if (vretfat == RETURN_OK)
                                    {
                                        if (fsCreateFile(vparam5) != RETURN_OK)
                                            vretfat = ERRO_B_CREATE_FILE;
                                    }

                                    //memcpy(vdirdst, vdir, sizeof(FAT32_DIR));
                                }
                            }

                            while (vretfat == RETURN_OK)
                            {
                                vclusterdir = vclusterdirsrc;
                                vReadSize = fsReadFile(vparam, ikk, vbuffer, 128);
                                if (vReadSize > 0)
                                {
                                    vclusterdir = vclusterdirdst;
                                    if (fsWriteFile(vparam5, ikk, vbuffer, (unsigned char)vReadSize) != RETURN_OK)
                                    {
                                        vretfat = ERRO_B_WRITE_FILE;
                                        break;
                                    }

                                    ikk += vReadSize;
                                }
                                else
                                    break;
                            }

                            if (vretfat != RETURN_OK)
                            {
                                // Falhou no meio da copia: remove temporario e preserva destino antigo.
                                vclusterdir = vclusterdirdst;
                                fsDelFile(vparam5);
                                break;
                            }

                            // Commit da copia: substitui o destino somente apos concluir sem erro.
                            vclusterdir = vclusterdirdst;
                            if (fsOpenFile(vparam4) == RETURN_OK)
                            {
                                if (fsDelFile(vparam4) != RETURN_OK)
                                    vretfat = ERRO_B_APAGAR_ARQUIVO;
                            }

                            if (vretfat == RETURN_OK)
                            {
                                if (fsRenameFile(vparam5, vparam4) != RETURN_OK)
                                {
                                    fsDelFile(vparam5);
                                    vretfat = ERRO_B_CREATE_FILE;
                                }
                            }

                            if (vretfat != RETURN_OK)
                                break;

                            vclusterdir = vclusterdirsrc;
                        }

                        if (!logwildcard)
                            break;

                        // Verifica se Tem mais arquivos no diretorio
                        if (fsFindInDir(vparam, TYPE_NEXT_ENTRY) >= ERRO_D_START)
                        {
                            if (linhaParametro[0] == '\0')
                                printText("\r\n\0");
                            break;
                        }
                    }
                }
            }

            vclusterdir = vclusterdiratu;

            if (vretfat != RETURN_OK)
            {
                if (linhaParametro[0] == '\0')
                {
                    printDiskError(vretfat);
                    printText("\r\n\0");
                }
            }
        }
        else
        {
            if (!strcmp(linhacomando,"REN") && iy == 3) // Arquivo (somente 1, nao uar wildcard)
            {
                if (fsFindDirPath(vparam, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
                {
                    if (linhaParametro[0] == '\0')
                        printText("file not found.\r\n\0");
                    vretfat = ERRO_B_NOT_FOUND;
                }
                else
                {
                    if (!isValidFilename(vparam2))
                        vretfat = ERRO_B_INVALID_NAME;
                    else
                    {
                        vclusterdir = vretpath.ClusterDir;
                        vretfat = fsRenameFile(vretpath.Name, vparam2);
                    }
                }

                vclusterdir = vretpath.ClusterDirAtu;
            }
            else if (!strcmp(linhacomando,"MD") && iy == 2)
            {
                vretfat = fsMakeDir(linhaarg);
            }
            else if (!strcmp(linhacomando,"CD") && iy == 2)
            {
                vretfat = fsChangeDir(linhaarg);
            }
            else if (!strcmp(linhacomando,"RD") && iy == 2)
            {
                vretfat = fsRemoveDir(linhaarg);
            }
            else if (!strcmp(linhacomando,"STOF") && iy == 4) // Arquivo (usa 1 soh)
            {
                vretfat = fsLoadSerialToFile(linhaarg);  // Carrega da Serial para o Arquivo
            }
            else if (!strcmp(linhacomando,"STOR") && iy == 4) // Arquivo (usa 1 soh)
            {
                vretfat = fsLoadSerialToRun(linhaarg);  // Carrega da Serial para o Arquivo
            }
            else if (!strcmp(linhacomando,"DATE") && iy == 4)
            {
                // TBD
            }
            else if (!strcmp(linhacomando,"TIME") && iy == 4)
            {
                // TBD
            }
            else if (!strcmp(linhacomando,"FORMAT") && iy == 6)
            {
                vretfat = fsFormat(0x5678, linhaarg);
            }
            else if (!strcmp(linhacomando,"MODE") && iy == 4)
            {
                // A definir
                ix = 255;
            }
            else if (!strcmp(linhacomando,"CAT") && iy == 3) // Arquivo (usa 1 soh)
            {
                catFile(linhaarg);
                ix = 255;
            }
            else if (!strcmp(linhacomando,"BASIC") && iy == 5)
            {
                memset(basicFuncArg, 0x00, sizeof(basicFuncArg));
                if (linhaarg[0] != 0x00)
                    memcpy(basicFuncArg, linhaarg, sizeof(basicFuncArg) - 1);

                basicFunc((void *)basicFuncArg);
                
                if (*startBasic == 1)
                    printText("\r\n\0");
            }
            else if (!strcmp(linhacomando,"PATH") && iy == 4)
            {
                if (linhaarg[0] == 0x00)
                {
                    printText(mmsjosExecPath);
                    printText("\r\n\0");
                }
                else
                {
                    strncpy((char *)mmsjosExecPath, (char *)linhaarg, sizeof(mmsjosExecPath) - 1);
                    mmsjosExecPath[sizeof(mmsjosExecPath) - 1] = 0;

                    if (!mmsjosSaveConfig())
                        vretfat = ERRO_B_WRITE_FILE;
                }

                ix = 255;
            }
            else
            {
                unsigned char progName[80];
                unsigned char foundName[32];
                unsigned char execArg[128];
                unsigned long foundCluster;
                unsigned long oldCluster;

                mmsjosBuildExeName(linhacomando, progName, sizeof(progName));

                foundCluster = vclusterdir;
                if (mmsjosFindExecutable(progName, foundName, &foundCluster))
                {
                    oldCluster = vclusterdir;
                    vclusterdir = foundCluster;
                    vretpath.ClusterDirAtu = foundCluster; /* ensure loadFileSize starts from right dir */

                    #ifdef USE_RELOC_LOAD_PROGS
                        mmsjosBuildArgPath(linhaarg, execArg, sizeof(execArg));
                        paramBasic[0] = '\0';
                        strcpy(paramBasic, execArg);
                        if (loadMbinAndRun(foundName, 1) != 0)
                            printText("Error Executing File\r\n\0");
                    #else
                        // Slot fixo para apps gerais: 0x00880000
                        vEnderExec = 0x00880000;
                        itoa(vEnderExec,sqtdtam,16);
                        printText("Loading File in \0");
                        printText(sqtdtam);
                        printText("h\r\n\0");
                        vsizeProg = loadFile(foundName, (unsigned long*)vEnderExec);
                        mmsjosBuildArgPath(linhaarg, execArg, sizeof(execArg));
                        strcpy(paramBasic, execArg);
                        strcat(paramBasic, ",");
                        ltoa(vsizeProg, sqtdtam, 10);
                        strcat(paramBasic, sqtdtam);
                        if (!verro)
                            runFromOsCmd(vEnderExec);
                        else
                        {
                            if (linhaParametro[0] == '\0')
                                printText("Loading File Error...\r\n\0");
                        }
                    #endif

                    vclusterdir = oldCluster;

                    ix = 255;
                }
                else
                {
                    // Se nao tiver, mostra erro
                    if (linhaParametro[0] == '\0')
                        printText("Invalid Command or File Name\r\n\0");

                    ix = 255;
                }
            }

            if (ix != 255)
            {
                if (vpicret)
                {
                    for (varg = 0; varg < ix; varg++)
                        fsSendByte(linhaarg[varg], FS_DATA);

                    vbytepic = fsRecByte(FS_DATA);
                }

                if (((vpicret) && (vbytepic != RETURN_OK)) || ((!vpicret) && (vretfat != RETURN_OK)))
                {
                    if (linhaParametro[0] == '\0')
                    {
                        printDiskError(vretfat);
                        printText("\r\n\0");
                    }
                }
                else
                {
                    if (!strcmp(linhacomando,"DATE"))
                    {
                        /*for(ix = 0; ix <= 9; ix++)
                        {
                            recPic();
                            vlinha[ix] = vbytepic;
                        }*/

                        vlinha[ix] = '\0';
                        printText("  Date is \0");
                        printText(vlinha);
                        printText("\r\n\0");
                    }
                    else if (!strcmp(linhacomando,"TIME"))
                    {
                        /*for(ix = 0; ix <= 7; ix++)
                        {
                            recPic();
                            vlinha[ix] = vbytepic;
                        }*/

                        vlinha[ix] = '\0';
                        printText("  Time is \0");
                        printText(vlinha);
                        printText("\r\n\0");
                    }
                    else if (!strcmp(linhacomando,"FORMAT"))
                    {
                        if (linhaParametro[0] == '\0')
                            printText("Format disk was successfully\r\n\0");
                    }
                }
            }
        }
    }

    return vretfat;
}

//-----------------------------------------------------------------------------
void runFromMGUI(unsigned long vEnderExec, unsigned long vFileBuf)
{
    unsigned int ix, iy;
    unsigned char topIdx;
    signed int nextZ;
    signed int topZ;
    unsigned long vAddressExec[2];

    vAddressExec[0] = vEnderExec;
    vAddressExec[1] = vFileBuf;
    prog01Func((void *)vAddressExec);
}

//-----------------------------------------------------------------------------
// Delay Function
//-----------------------------------------------------------------------------
void delayus(int pTimeUS)
{
    unsigned int ix;

    for(ix = 0; ix <= pTimeUS; ix++);    // +/- 1us * pTimeMs parada
}

//-----------------------------------------------------------------------------
// Memory Allocation Functions
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Initialization
//-----------------------------------------------------------------------------
char memInit(void)
{
    // Alloc all memmory available minus reserved
#ifdef USE_MSMALLOC
    heapFirst = (MEMBLOCK*)HEAP_START;
    heapFirst->size = HEAP_SIZE - sizeof(MEMBLOCK);
    heapFirst->used = 0;
    heapFirst->next = 0;
#endif    

    return 0;
}

#ifdef USE_MSMALLOC
//-----------------------------------------------------------------------------
// Allocation Memory
//-----------------------------------------------------------------------------
void *msmalloc(unsigned long size)
{
    unsigned char sqtdtam[20];
    MEMBLOCK *blk;
    MEMBLOCK *newblk;

    if (size == 0)
        return 0;

    /* alinhamento em 2 bytes para 68000 */
    if (size & 1)
        size++;

    blk = heapFirst;

    while (blk)
    {
        if (!blk->used && blk->size >= size)
        {
            if (blk->size > size + sizeof(MEMBLOCK) + 4)
            {
                newblk = (MEMBLOCK*)((unsigned char*)blk + sizeof(MEMBLOCK) + size);
                newblk->size = blk->size - size - sizeof(MEMBLOCK);
                newblk->used = 0;
                newblk->next = blk->next;

                blk->size = size;
                blk->next = newblk;
            }

            blk->used = 1;

/*writeLongSerial("Alloc: [\0");
ltoa(blk, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[\0");            
ltoa(sizeof(MEMBLOCK), sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[\0");            
ltoa((blk + sizeof(MEMBLOCK)), sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");            */

            return (void*)((unsigned char*)blk + sizeof(MEMBLOCK));
        }

        blk = blk->next;
    }

    return 0;
}

//-----------------------------------------------------------------------------
// Re-Alloc Memory
//-----------------------------------------------------------------------------
void *msrealloc(void *ptr, unsigned long newSize)
{
    MEMBLOCK *blk;
    MEMBLOCK *next;
    MEMBLOCK *newblk;
    void *newptr;
    unsigned long copySize;
    unsigned char *src;
    unsigned char *dst;
    unsigned long i;

    if (ptr == 0)
        return msmalloc(newSize);

    if (newSize == 0)
    {
        msfree(ptr);
        return 0;
    }

    if (newSize & 1)
        newSize++;

    blk = (MEMBLOCK*)((unsigned char*)ptr - sizeof(MEMBLOCK));

    /* Caso 1: já cabe */
    if (blk->size >= newSize)
    {
        /* se sobrar bastante, divide */
        if (blk->size >= newSize + sizeof(MEMBLOCK) + 4)
        {
            newblk = (MEMBLOCK*)((unsigned char*)blk + sizeof(MEMBLOCK) + newSize);
            newblk->size = blk->size - newSize - sizeof(MEMBLOCK);
            newblk->used = 0;
            newblk->next = blk->next;

            blk->size = newSize;
            blk->next = newblk;
        }

        return ptr;
    }

    /* Caso 2: tenta crescer usando o próximo bloco livre */
    next = blk->next;

    if (next && !next->used &&
        ((unsigned char*)blk + sizeof(MEMBLOCK) + blk->size == (unsigned char*)next))
    {
        if (blk->size + sizeof(MEMBLOCK) + next->size >= newSize)
        {
            blk->size += sizeof(MEMBLOCK) + next->size;
            blk->next = next->next;

            /* se sobrar bastante depois de expandir, divide */
            if (blk->size >= newSize + sizeof(MEMBLOCK) + 4)
            {
                newblk = (MEMBLOCK*)((unsigned char*)blk + sizeof(MEMBLOCK) + newSize);
                newblk->size = blk->size - newSize - sizeof(MEMBLOCK);
                newblk->used = 0;
                newblk->next = blk->next;

                blk->size = newSize;
                blk->next = newblk;
            }

            return ptr;
        }
    }

    /* Caso 3: não dá para crescer ali, aloca outro e copia */
    newptr = msmalloc(newSize);

    if (newptr == 0)
        return 0;

    copySize = blk->size;

    if (copySize > newSize)
        copySize = newSize;

    src = (unsigned char*)ptr;
    dst = (unsigned char*)newptr;

    for (i = 0; i < copySize; i++)
        dst[i] = src[i];

    msfree(ptr);

    return newptr;
}

//-----------------------------------------------------------------------------
// Free Allocated Memory
//-----------------------------------------------------------------------------
void msfree(void *ptr)
{
    unsigned char sqtdtam[20];
    MEMBLOCK *blk;
    MEMBLOCK *cur;

    if (!ptr)
        return;

    blk = (MEMBLOCK*)((unsigned char*)ptr - sizeof(MEMBLOCK));
    blk->used = 0;

    /* junta blocos livres consecutivos */
    cur = heapFirst;

/*writeLongSerial("Free : [\0");
ltoa(ptr, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");            */

    while (cur && cur->next)
    {
        if (!cur->used && !cur->next->used)
        {
            cur->size += sizeof(MEMBLOCK) + cur->next->size;
            cur->next = cur->next->next;
        }
        else
        {
            cur = cur->next;
        }
    }
}
#endif

//-----------------------------------------------------------------------------
// Disk Functions
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Send byte to disk 
//-----------------------------------------------------------------------------
int fsSendByte(unsigned char vByte, unsigned char pType)
{
    asm volatile ("nop");
    asm volatile ("nop");

    if (pType == 0)
        *vdskc = vByte;
    else if (pType == 1)
        *vdskd = vByte;
    else if (pType == 2)
        *vdskp = vByte;

    return 1;
}

//-----------------------------------------------------------------------------
// Receive byte from disk
//-----------------------------------------------------------------------------
unsigned char fsRecByte(unsigned char pType)
{
    unsigned char vByte;
    unsigned int ix;

    asm volatile ("nop");
    asm volatile ("nop");

    if (pType == 0)
        vByte = *vdskc;
    else if (pType == 1)
        vByte = *vdskd;

    return vByte;
}

//-----------------------------------------------------------------------------
// Raw sector read/write (single attempt)
//-----------------------------------------------------------------------------
static unsigned char fsSectorReadRaw(unsigned long vsector, unsigned char* vbuffer)
{
    unsigned char vbytes[4], vByte = 0;
    unsigned int cc;
    unsigned long vsectorok;

    if (!vbuffer)
        return 0;

    vsectorok = (vsector & 0xFF000000) >> 24;
    vbytes[0] = (unsigned char)vsectorok;
    vsectorok = (vsector & 0x00FF0000) >> 16;
    vbytes[1] = (unsigned char)vsectorok;
    vsectorok = (vsector & 0x0000FF00) >> 8;
    vbytes[2] = (unsigned char)vsectorok;
    vsectorok = vsector & 0x000000FF;
    vbytes[3] = (unsigned char)vsectorok;

    // Envia comando resetar e abortar tudo
    fsSendByte('a', FS_CMD);

    // Comando recebido ok ?
    vByte = fsRecByte(FS_CMD);
    if (vByte != ALL_OK)
        return 0;

    // Envia Cluster
    fsSendByte(vbytes[0], FS_PAR);
    fsSendByte(vbytes[1], FS_PAR);
    fsSendByte(vbytes[2], FS_PAR);
    fsSendByte(vbytes[3], FS_PAR);
    // Envia offset
    fsSendByte(0x00, FS_PAR);
    fsSendByte(0x00, FS_PAR);
    // Envia Qtd (512)
    fsSendByte(0x02, FS_PAR);
    fsSendByte(0x00, FS_PAR);

    // Envia comando
    fsSendByte('r', FS_CMD);

    // Comando recebido ok ?
    vByte = fsRecByte(FS_CMD);
    if (vByte != ALL_OK)
        return 0;

    // Comando Executado ok ?
    vByte = fsRecByte(FS_CMD);
    if (vByte != ALL_OK)
        return 0;

    // Carrega Dados Recebidos
    for (cc = 0; cc < MEDIA_SECTOR_SIZE ; cc++)
        vbuffer[cc] = fsRecByte(FS_DATA);

    return 1;
}

static int fsBufferEquals(unsigned char *a, unsigned char *b, unsigned short size)
{
    unsigned short i;

    for (i = 0; i < size; i++) {
        if (a[i] != b[i])
            return 0;
    }

    return 1;
}

static unsigned char fsSectorWriteRaw(unsigned long vsector, unsigned char* vbuffer)
{
    unsigned char vbytes[4], vByte = 0;
    unsigned int cc;
    unsigned long vsectorok;

    if (!vbuffer)
        return 0;

    vsectorok = (vsector & 0xFF000000) >> 24;
    vbytes[0] = (unsigned char)vsectorok;
    vsectorok = (vsector & 0x00FF0000) >> 16;
    vbytes[1] = (unsigned char)vsectorok;
    vsectorok = (vsector & 0x0000FF00) >> 8;
    vbytes[2] = (unsigned char)vsectorok;
    vsectorok = vsector & 0x000000FF;
    vbytes[3] = (unsigned char)vsectorok;

    // Envia comando resetar e abortar tudo
    fsSendByte('a', FS_CMD);

    // Comando recebido ok ?
    vByte = fsRecByte(FS_CMD);
    if (vByte != ALL_OK)
        return 0;

    // Envia Buffer
    for (cc = 0; cc < MEDIA_SECTOR_SIZE ; cc++)
        fsSendByte(vbuffer[cc], FS_DATA);

    // Envia Cluster
    fsSendByte(vbytes[0], FS_PAR);
    fsSendByte(vbytes[1], FS_PAR);
    fsSendByte(vbytes[2], FS_PAR);
    fsSendByte(vbytes[3], FS_PAR);

    // Envia comando
    fsSendByte('w', FS_CMD);

    // Comando recebido ok ?
    vByte = fsRecByte(FS_CMD);
    if (vByte != ALL_OK)
        return 0;

    // Comando Executado ok ?
    vByte = fsRecByte(FS_CMD);
    if (vByte != ALL_OK)
        return 0;

    return 1;
}

//-----------------------------------------------------------------------------
// Write Fat Sector
//-----------------------------------------------------------------------------
static unsigned char fsWriteFatSector(unsigned long vfat)
{
    unsigned char vfatCopy;
    unsigned long vfatCopySector;

    if (vdisk.NumberOfFATs == 0)
        vdisk.NumberOfFATs = 1;

    for (vfatCopy = 0; vfatCopy < vdisk.NumberOfFATs; vfatCopy++)
    {
        vfatCopySector = vfat + ((unsigned long)vfatCopy * vdisk.fatsize);
        if (!fsSectorWrite(vfatCopySector, gDataBuffer, FALSE))
            return ERRO_D_WRITE_DISK;
    }

    return RETURN_OK;
}

//-----------------------------------------------------------------------------
static unsigned char fsDeleteDirEntryChain(unsigned long vDirSector, unsigned short vDirEntry)
{
    unsigned long vScanSector;
    unsigned long vSectorInCluster;
    unsigned short vScanEntry;
    unsigned short vLastEntryInSector;

    if (!fsSectorRead(vDirSector, gDataBuffer))
        return ERRO_D_READ_DISK;

    gDataBuffer[vDirEntry] = DIR_DEL;
    gDataBuffer[vDirEntry + 20] = 0x00;
    gDataBuffer[vDirEntry + 21] = 0x00;
    gDataBuffer[vDirEntry + 26] = 0x00;
    gDataBuffer[vDirEntry + 27] = 0x00;
    gDataBuffer[vDirEntry + 28] = 0x00;
    gDataBuffer[vDirEntry + 29] = 0x00;
    gDataBuffer[vDirEntry + 30] = 0x00;
    gDataBuffer[vDirEntry + 31] = 0x00;

    if (!fsSectorWrite(vDirSector, gDataBuffer, FALSE))
        return ERRO_D_WRITE_DISK;

    vScanSector = vDirSector;
    vScanEntry = vDirEntry;
    vLastEntryInSector = (vdisk.sectorSize - 32);

    while (1)
    {
        if (vScanEntry >= 32)
        {
            vScanEntry -= 32;
        }
        else
        {
            vSectorInCluster = (vScanSector - vdisk.data) % vdisk.SecPerClus;
            if (vSectorInCluster == 0)
                break;

            vScanSector--;
            vScanEntry = vLastEntryInSector;
        }

        if (!fsSectorRead(vScanSector, gDataBuffer))
            return ERRO_D_READ_DISK;

        if (gDataBuffer[vScanEntry] == DIR_EMPTY || gDataBuffer[vScanEntry] == DIR_DEL)
            break;

        if (gDataBuffer[vScanEntry + 11] != ATTR_LONG_NAME)
            break;

        gDataBuffer[vScanEntry] = DIR_DEL;

        if (!fsSectorWrite(vScanSector, gDataBuffer, FALSE))
            return ERRO_D_WRITE_DISK;
    }

    return RETURN_OK;
}

//-----------------------------------------------------------------------------
// FAT32 Functions
//-----------------------------------------------------------------------------
unsigned char fsMountDisk(void)
{
	// LER MBR
    if (!fsSectorRead((unsigned long)0x0000,gDataBuffer))
		return ERRO_B_READ_DISK;

    vdisk.firsts  = (((unsigned long)gDataBuffer[457] << 24) & 0xFF000000);
    vdisk.firsts |= (((unsigned long)gDataBuffer[456] << 16) & 0x00FF0000);
    vdisk.firsts |= (((unsigned long)gDataBuffer[455] << 8) & 0x0000FF00);
    vdisk.firsts |= ((unsigned long)gDataBuffer[454] & 0x000000FF);

    // LER FIRST CLUSTER
	if (!fsSectorRead(vdisk.firsts,gDataBuffer))
		return ERRO_B_READ_DISK;

    vdisk.reserv  = (unsigned short)gDataBuffer[15] << 8;
    vdisk.reserv |= (unsigned short)gDataBuffer[14];

	vdisk.fat = vdisk.reserv + vdisk.firsts;

    vdisk.sectorSize  = (unsigned long)gDataBuffer[12] << 8;
    vdisk.sectorSize |= (unsigned long)gDataBuffer[11];
	vdisk.NumberOfFATs = gDataBuffer[16];
	vdisk.SecPerClus = gDataBuffer[13];

    if (vdisk.NumberOfFATs == 0)
        vdisk.NumberOfFATs = 1;

    vdisk.fatsize  = (unsigned long)gDataBuffer[39] << 24;
    vdisk.fatsize |= (unsigned long)gDataBuffer[38] << 16;
    vdisk.fatsize |= (unsigned long)gDataBuffer[37] << 8;
    vdisk.fatsize |= (unsigned long)gDataBuffer[36];

    vdisk.root  = (unsigned long)gDataBuffer[47] << 24;
    vdisk.root |= (unsigned long)gDataBuffer[46] << 16;
    vdisk.root |= (unsigned long)gDataBuffer[45] << 8;
    vdisk.root |= (unsigned long)gDataBuffer[44];

	vdisk.type = FAT32;

    vdisk.data = vdisk.firsts + vdisk.reserv + ((unsigned long)vdisk.NumberOfFATs * vdisk.fatsize);

	vclusterdir = vdisk.root;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
void fsSetClusterDir (unsigned long vclusdiratu) {
    vclusterdir = vclusdiratu;
}

//-------------------------------------------------------------------------
unsigned long fsGetClusterDir (void) {
    return vclusterdir;
}

//-------------------------------------------------------------------------
unsigned char fsCreateFile(char * vfilename)
{
    if (!isValidFilename(vfilename))
        return ERRO_B_INVALID_NAME;

	// Verifica ja existe arquivo com esse nome
	if (fsFindInDir(vfilename, TYPE_ALL) < ERRO_D_START)
		return ERRO_B_FILE_FOUND;

	// Cria o arquivo com o nome especificado
	if (fsFindInDir(vfilename, TYPE_CREATE_FILE) >= ERRO_D_START)
		return ERRO_B_CREATE_FILE;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsOpenFile(char * vfilename)
{
	unsigned short vdirdate, vbytepic;
	unsigned char ds1307[7], ix, vlinha[12], vtemp[5];

	// Abre o arquivo especificado
	if (fsFindInDir(vfilename, TYPE_FILE) >= ERRO_D_START)
		return ERRO_B_FILE_NOT_FOUND;

	// Ler Data/Hora do PIC
    // TBD
    ds1307[3] = 01;
    ds1307[4] = 01;
    ds1307[5] = 2024;

	// Converte para a Data/Hora da FAT32
	vdirdate = datetimetodir(ds1307[3], ds1307[4], ds1307[5], CONV_DATA);

	// Grava nova data no lastaccess
	vdir.LastAccessDate  = vdirdate;

#ifdef ENABLE_UPDATE_LAST_ACCESS              
 	if (fsUpdateDir() != RETURN_OK)
		return ERRO_B_UPDATE_DIR;
#endif

	return RETURN_OK;
}


//-------------------------------------------------------------------------
unsigned char fsCloseFile(char * vfilename, unsigned char vupdated)
{
	unsigned short vdirdate, vdirtime, vbytepic;
	unsigned char ds1307[7], vtemp[5], ix, vlinha[12];

	if (fsFindInDir(vfilename, TYPE_FILE) < ERRO_D_START) {
		if (vupdated) {
			// Ler Data/Hora do DS1307 - I2C
            // TBD
            ds1307[3] = 01;
            ds1307[4] = 01;
            ds1307[5] = 2024;
            ds1307[0] = 00;
            ds1307[1] = 00;
            ds1307[2] = 00;

			// Converte para a Data/Hora da FAT32
			vdirtime = datetimetodir(ds1307[0], ds1307[1], ds1307[2], CONV_HORA);
			vdirdate = datetimetodir(ds1307[3], ds1307[4], ds1307[5], CONV_DATA);

			// Grava nova data no lastaccess e nova data/hora no update date/time
			vdir.LastAccessDate  = vdirdate;
			vdir.UpdateTime = vdirtime;
			vdir.UpdateDate = vdirdate;

#ifdef ENABLE_UPDATE_LAST_ACCESS              
			if (fsUpdateDir() != RETURN_OK)
				return ERRO_B_UPDATE_DIR;
#endif                
		}
	}
	else
		return ERRO_B_NOT_FOUND;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned long fsInfoFile(char * vfilename, unsigned char vtype)
{
	unsigned long vinfo = ERRO_D_NOT_FOUND, vtemp;

    if (fsFindDirPath(vfilename, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
    {
        verro = 1;

        vclusterdir = vretpath.ClusterDirAtu;

        return vinfo;
    }

    vclusterdir = vretpath.ClusterDir;

	// retornar as informa?es conforme solicitado.
	if (fsFindInDir(vretpath.Name, TYPE_FILE) < ERRO_D_START) {
		switch (vtype) {
			case INFO_SIZE:
				vinfo = vdir.Size;
				break;
			case INFO_CREATE:
			    vtemp = (vdir.CreateDate << 16) | vdir.CreateTime;
				vinfo = (vtemp);
				break;
			case INFO_UPDATE:
			    vtemp = (vdir.UpdateDate << 16) | vdir.UpdateTime;
				vinfo = (vtemp);
				break;
			case INFO_LAST:
				vinfo = vdir.LastAccessDate;
				break;
		}
	}
	else
    {
        vclusterdir = vretpath.ClusterDirAtu;

		return ERRO_D_NOT_FOUND;
    }

    vclusterdir = vretpath.ClusterDirAtu;

	return vinfo;
}

//-------------------------------------------------------------------------
unsigned char fsDelFile(char * vfilename)
{
	// Apaga o arquivo solicitado
	if (fsFindInDir(vfilename, TYPE_DEL_FILE) >= ERRO_D_START)
		return ERRO_B_APAGAR_ARQUIVO;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsRenameFile(char * vfilename, char * vnewname)
{
	unsigned long vclusterfile;
	unsigned short ikk;
	unsigned char ixx, iyy;

	// Verificar se nome j?nao existe
	vclusterfile = fsFindInDir(vnewname, TYPE_ALL);

	if (vclusterfile < ERRO_D_START)
		return ERRO_B_FILE_FOUND;

	// Procura arquivo a ser renomeado
	vclusterfile = fsFindInDir(vfilename, TYPE_FILE);

	if (vclusterfile >= ERRO_D_START)
		return ERRO_B_FILE_NOT_FOUND;

	// Altera nome na estrutura vdir
	memset(vdir.Name, 0x20, 8);
	memset(vdir.Ext, 0x20, 3);

	iyy = 0;
	for (ixx = 0; ixx <= strlen(vnewname); ixx++) {
		if (vnewname[ixx] == '\0')
			break;
		else if (vnewname[ixx] == '.')
			iyy = 8;
		else {
			if (iyy <= 7)
				vdir.Name[iyy] = vnewname[ixx];
			else {
			    ikk = iyy - 8;
				vdir.Ext[ikk] = vnewname[ixx];
			}

			iyy++;
		}
	}

	// Altera o nome, as demais informacoes nao alteram
	if (fsUpdateDir() != RETURN_OK)
		return ERRO_B_UPDATE_DIR;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsLoadSerialToFile(char * vfilename)
{
    unsigned long vSize, ix, vStep;
    unsigned long vNextProgress;
    unsigned char *xaddress;
    unsigned char *xaddressStart;
    unsigned char vBuffer[128];
    int iy;
    unsigned char vmovposyatu = 0;
    VDP_COORD vcursor;
    unsigned long vSizeTotalRec;
    unsigned short vChunkSize;
    unsigned char vProgressCount;

    vSizeTotalRec = 0;

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            xaddress = malloc(STOF_RX_BUFFER_SIZE);
        #else
            xaddress = msmalloc(STOF_RX_BUFFER_SIZE);
        #endif
    #else
        xaddress = (unsigned char *)ADDR_LOAD_FILE; // 128Kb Endereco fixo
    #endif

    xaddressStart = xaddress;

    if (!xaddress)
    {
        printText("No memory to receive file.\r\n\0");
        return ERRO_B_WRITE_FILE;
    }

    if (vfilename == 0)
    {
        printText("Error, file name must be provided!!\r\n\0");
#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            free(xaddressStart);
        #else
            msfree(xaddressStart);
        #endif
#endif
        return ERRO_B_WRITE_FILE;;
    }

    // Verifica se o arquivo existe
	if (fsFindInDir(vfilename, TYPE_FILE) < ERRO_D_START)
    {
        // Se existir, apaga
        if (fsDelFile(vfilename) != RETURN_OK)
        {
#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
            #if defined(USE_MALLOC)
                free(xaddressStart);
            #else
                msfree(xaddressStart);
            #endif
#endif
            return ERRO_B_WRITE_FILE;
        }
    }

    // Cria o Arquivo
    if (fsCreateFile(vfilename) != RETURN_OK)
    {
#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            free(xaddressStart);
        #else
            msfree(xaddressStart);
        #endif
#endif
        return ERRO_B_CREATE_FILE;
    }

    // Recebe os dados via Serial
    if (!loadSerialToMem2(xaddressStart, 1))
    {
        vSizeTotalRec = lstmGetSize();

        // Abre Arquivo
        printText("Opening File...\r\n\0");

        if (fsOpenFile(vfilename) != RETURN_OK)
        {
#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
            #if defined(USE_MALLOC)
                free(xaddressStart);
            #else
                msfree(xaddressStart);
            #endif
#endif
            return ERRO_B_WRITE_FILE;
        }

        // Grava no Arquivo
        printText("Writing File...\r\n\0");

        printChar(218,1);
        for (ix = 0; ix < 20; ix++)
            printChar(196,1);
        printChar(191,1);

        printText("\r\n\0");

        printChar(179,1);
        for (ix = 0; ix < 20; ix++)
            printChar(' ',1);
        printChar(179,1);

        printText("\r\n\0");

        printChar(192,1);
        for (ix = 0; ix < 20; ix++)
            printChar(196,1);
        printChar(217,1);

        printText("\r\n\0");

        vcursor = vdp_get_cursor_safe();

        vmovposyatu = vcursor.y;

        vStep = (vSizeTotalRec >= 20) ? (vSizeTotalRec / 20) : 0;
        vNextProgress = vStep;
        vProgressCount = 0;

        vdp_set_cursor(1, (vcursor.y - 2));

        for (ix = 0; ix < vSizeTotalRec; ix += 128)
        {
            vChunkSize = (unsigned short)(vSizeTotalRec - ix);
            if (vChunkSize > 128)
                vChunkSize = 128;

            for (iy = 0; iy < 128; iy++)
            {
                if (iy < vChunkSize)
                {
                    vBuffer[iy] = *xaddress;
                    xaddress += 1;
                }
            }

            if (fsWriteFile(vfilename, ix, vBuffer, (unsigned char)vChunkSize) != RETURN_OK)
            {
#if defined(USE_MALLOC) || defined(USE_MSMALLOC)
                #if defined(USE_MALLOC)
                    free(xaddressStart);
                #else
                    msfree(xaddressStart);
                #endif
#endif
                return ERRO_B_WRITE_FILE;
            }

            if (vStep > 0)
            {
                while (vProgressCount < 20 && (ix + vChunkSize) >= vNextProgress)
                {
                    printChar(219, 1);
                    vProgressCount++;
                    vNextProgress += vStep;
                }
            }
        }

        vdp_set_cursor(0, vmovposyatu);

        // Fecha Arquivo e atualiza metadata de escrita
        printText("\r\nClosing File...\r\n\0");

        fsCloseFile(vfilename, 1);

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            free(xaddressStart);
        #else
            msfree(xaddressStart);
        #endif
    #endif
    }
    else
    {
        printText("Serial Load Error...");

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            free(xaddressStart);
        #else
            msfree(xaddressStart);
        #endif
    #endif

        return ERRO_B_WRITE_FILE;
    }

    return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsLoadSerialToRun(char * vfilename)
{
    unsigned long vSize, ix, vStep;
    unsigned char vBuffer[128], sqtdtam[20];
    int iy;
    unsigned char *vEnderExec;

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            vEnderExec = malloc(1024);
        #else
            vEnderExec = msmalloc(1024);
        #endif
    #else
        vEnderExec = (unsigned char*)ADDR_LOAD_FILE;
    #endif

    // Recebe os dados via Serial
    if (!loadSerialToMem2(vEnderExec, 1))
    {
        itoa(vEnderExec,sqtdtam,16);
        printText("Running at \0");
        printText(sqtdtam);
        printText("h\r\n\0");
        runFromOsCmd(vEnderExec);
    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            free(vEnderExec);
        #else
            msfree(vEnderExec);
        #endif
    #endif
    }
    else
    {
        printText("Serial Load Error...");

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)
        #if defined(USE_MALLOC)
            free(vEnderExec);
        #else
            msfree(vEnderExec);
        #endif
    #endif

        return ERRO_B_WRITE_FILE;
    }

    return RETURN_OK;
}

/* Sector swap buffer fora da stack para nao estourar a task stack em fsRWFile */
static unsigned char vSectorSwap[MEDIA_SECTOR_SIZE];

//-------------------------------------------------------------------------
// Rotina para escrever/ler no disco
//-------------------------------------------------------------------------
unsigned char fsRWFile(unsigned long vclusterini, unsigned long voffset, unsigned char *buffer, unsigned char vtype)
{
	unsigned long vdata, vclusternew, vfat;
	unsigned long voffsec, voffclus;
	unsigned short vpos, vsecfat, vtemp1, vtemp2, ikk, ikj;
    unsigned short vSwapSize;
    unsigned char sqtdtam[10];

    vSwapSize = vdisk.sectorSize;
    if (vSwapSize > MEDIA_SECTOR_SIZE)
        return ERRO_B_READ_DISK;

	// Calcula offset de setor e cluster
	voffsec = voffset / vdisk.sectorSize;
	voffclus = voffsec / vdisk.SecPerClus;
	vclusternew = vclusterini;

	// Procura o cluster onde esta o setor a ser lido
	for (vpos = 0; vpos < voffclus; vpos++) {
        // Em operacao de escrita, preserva o buffer em RAM porque funcoes FAT usam gDataBuffer.
		if (vtype == OPER_WRITE) {
            memcpy(vSectorSwap, buffer, vSwapSize);
		}

		vclusternew = fsFindNextCluster(vclusterini, NEXT_FIND);

		// Se for leitura e o offset der dentro do ultimo cluster, sai
		if (vtype == OPER_READ && vclusternew == LAST_CLUSTER_FAT32)
			return RETURN_OK;

		// Se for gravacao e o offset der dentro do ultimo cluster, cria novo cluster
		if ((vtype == OPER_WRITE || vtype == OPER_READWRITE) && vclusternew == LAST_CLUSTER_FAT32) {
			// Calcula novo cluster livre
			vclusternew = fsFindClusterFree(FREE_USE);

			if (vclusternew == ERRO_D_DISK_FULL)
				return ERRO_B_DISK_FULL;

			// Procura Cluster atual para altera?o
			vsecfat = vclusterini / 128;
			vfat = vdisk.fat + vsecfat;

			if (!fsSectorRead(vfat, gDataBuffer))
				return ERRO_B_READ_DISK;

			// Grava novo cluster no cluster atual
			vpos = (vclusterini - ( 128 * vsecfat)) * 4;
			gDataBuffer[vpos] = (unsigned char)(vclusternew & 0xFF);
			ikk = vpos + 1;
			gDataBuffer[ikk] = (unsigned char)((vclusternew / 0x100) & 0xFF);
			ikk = vpos + 2;
			gDataBuffer[ikk] = (unsigned char)((vclusternew / 0x10000) & 0xFF);
			ikk = vpos + 3;
			gDataBuffer[ikk] = (unsigned char)((vclusternew / 0x1000000) & 0xFF);

            if (fsWriteFatSector(vfat) != RETURN_OK)
                return ERRO_B_WRITE_DISK;
		}

		vclusterini = vclusternew;

        // Em operacao de escrita, restaura o buffer salvo em RAM.
		if (vtype == OPER_WRITE) {
            memcpy(buffer, vSectorSwap, vSwapSize);
		}
	}

	// Posiciona no setor dentro do cluster para ler/gravar
	vtemp1 = ((vclusternew - 2) * vdisk.SecPerClus);
    vtemp2 = vdisk.data;
	vdata = vtemp1 + vtemp2;
	vtemp1 = (voffclus * vdisk.SecPerClus);
	vdata += voffsec - vtemp1;

	if (vtype == OPER_READ || vtype == OPER_READWRITE) {
		// Le o setor e coloca no buffer
		if (!fsSectorRead(vdata, buffer))
			return ERRO_B_READ_DISK;
	}
	else {
		// Grava o buffer no setor
		if (!fsSectorWrite(vdata, buffer, FALSE))
			return ERRO_B_WRITE_DISK;
	}

	return RETURN_OK;
}

//-------------------------------------------------------------------------
// Retorna um buffer de "vsize" (max 255) Bytes, a partir do "voffset".
//-------------------------------------------------------------------------
unsigned short fsReadFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer)
{
	unsigned short ix, iy, vsizebf = 0;
	unsigned short vsize, vsetor = 0, vsizeant = 0;
	unsigned short voffsec, vtemp, ikk, ikj;
	unsigned long vclusterini;
    unsigned long vbytesleft;
    unsigned char sqtdtam[10];

	vclusterini = fsFindInDir(vfilename, TYPE_FILE);

	if (vclusterini >= ERRO_D_START)
		return 0;	// Erro na abertura/Arquivo nao existe

	// Verifica se o offset eh maior ou igual ao tamanho do arquivo
	if (voffset >= vdir.Size)
		return 0;

    vbytesleft = vdir.Size - voffset;
    if (vsizebuffer > vbytesleft)
        vsizebuffer = (unsigned short)vbytesleft;

	// Verifica se offset vai precisar gravar mais de 1 setor (entre 2 setores)
	vtemp = voffset / vdisk.sectorSize;
	voffsec = (voffset - (vdisk.sectorSize * (vtemp)));

	if ((voffsec + vsizebuffer) > vdisk.sectorSize)
		vsetor = 1;

/*itoa(vsetor, sqtdtam, 10);
printText(sqtdtam, *vcorf, *vcorb);
printText(".\n\0");*/

/*itoa(voffsec, sqtdtam, 10);
printText(sqtdtam, *vcorf, *vcorb);
printText(".\n\0");*/

/*itoa(vdisk.sectorSize, sqtdtam, 10);
printText(sqtdtam, *vcorf, *vcorb);
printText(".\n\0");*/

/*itoa(voffset, sqtdtam, 10);
printText(sqtdtam, *vcorf, *vcorb);
printText(".\n\0");*/

/*itoa(vsizebuffer, sqtdtam, 10);
printText(sqtdtam, *vcorf, *vcorb);
printText(".\n\0");*/

	for (ix = 0; ix <= vsetor; ix++) {
    	vtemp = voffset / vdisk.sectorSize;
    	voffsec = (voffset - (vdisk.sectorSize * (vtemp)));

		// Ler setor do offset
		if (fsRWFile(vclusterini, voffset, gDataBuffer, OPER_READ) != RETURN_OK)
			return vsizebf;

		// Verifica tamanho a ser gravado
		if ((voffsec + vsizebuffer) <= vdisk.sectorSize)
			vsize = vsizebuffer - vsizeant;
		else
			vsize = vdisk.sectorSize - voffsec;

        vsizebf += vsize;

/*itoa(vsize, sqtdtam, 10);
printText(sqtdtam, *vcorf, *vcorb);
printText(".\n\0");*/

		// Retorna os dados no buffer
		for (iy = 0; iy < vsize; iy++) {
		    ikk = vsizeant + iy;
		    ikj = voffsec + iy;
			buffer[ikk] = gDataBuffer[ikj];
        }

		vsizeant = vsize;
		voffset += vsize;
	}

	return vsizebf;
}

//-------------------------------------------------------------------------
// buffer a ser gravado nao pode ter mais que 512 bytes
//-------------------------------------------------------------------------
unsigned char fsWriteFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer)
{
	unsigned char vsetor = 0, ix, iy;
	unsigned short vsize, vsizeant = 0;
	unsigned short voffsec, vtemp, ikk, ikj;
	unsigned long vclusterini;
    unsigned long vstartoff;

    vstartoff = voffset;

	vclusterini = fsFindInDir(vfilename, TYPE_FILE);

	if (vclusterini >= ERRO_D_START)
		return ERRO_B_FILE_NOT_FOUND;	// Erro na abertura/Arquivo nao existe

	// Verifica se offset vai precisar gravar mais de 1 setor (entre 2 setores)
	vtemp = voffset / vdisk.sectorSize;
	voffsec = (voffset - (vdisk.sectorSize * (vtemp)));

	if ((voffsec + vsizebuffer) > vdisk.sectorSize)
		vsetor = 1;

	for (ix = 0; ix <= vsetor; ix++) {
    	vtemp = voffset / vdisk.sectorSize;
    	voffsec = (voffset - (vdisk.sectorSize * (vtemp)));

//*tempData = vclusterini;

		// Ler setor do offset
		if (fsRWFile(vclusterini, voffset, gDataBuffer, OPER_READWRITE) != RETURN_OK)
			return ERRO_B_READ_FILE;
//memcpy(tempData2,gDataBuffer,512);
		// Verifica tamanho a ser gravado
		if ((voffsec + vsizebuffer) <= vdisk.sectorSize)
			vsize = vsizebuffer - vsizeant;
		else
			vsize = vdisk.sectorSize - voffsec;

		// Prepara buffer para grava?o
		for (iy = 0; iy < vsize; iy++) {
		    ikk = iy + voffsec;
		    ikj = vsizeant + iy;
			gDataBuffer[ikk] = buffer[ikj];
		}
//*(tempData + 1) = vclusterini;
//memcpy(tempData3,gDataBuffer,512);

		// Grava setor
		if (fsRWFile(vclusterini, voffset, gDataBuffer, OPER_WRITE) != RETURN_OK)
			return ERRO_B_WRITE_FILE;

		vsizeant = vsize;

		if (vsetor == 1)
			voffset += vsize;
	}

    if ((vstartoff + vsizebuffer) > vdir.Size) {
        vdir.Size = vstartoff + vsizebuffer;

		if (fsUpdateDir() != RETURN_OK)
			return ERRO_B_UPDATE_DIR;
	}

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsMakeDir(char * vdirname)
{
    if (fsFindDirPath(vdirname, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
        return ERRO_B_CREATE_DIR;

    if (!isValidFilename(vretpath.Name))
		return ERRO_B_INVALID_NAME;

    vclusterdir = vretpath.ClusterDir;

	// Verifica ja existe arquivo/dir com esse nome
	if (fsFindInDir(vretpath.Name, TYPE_ALL) < ERRO_D_START)
    {
        vclusterdir = vretpath.ClusterDirAtu;
		return ERRO_B_DIR_FOUND;
    }

	// Cria o dir solicitado
	if (fsFindInDir(vretpath.Name, TYPE_CREATE_DIR) >= ERRO_D_START)
    {
        vclusterdir = vretpath.ClusterDirAtu;
		return ERRO_B_CREATE_DIR;
    }

    vclusterdir = vretpath.ClusterDirAtu;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
// [<folder>/<folder>/<folder>/]<file>
//-------------------------------------------------------------------------
unsigned char fsFindDirPath(char * vpath, char vtype)
{
    unsigned long vclusterdirnew, vclusterdirant;
    int ix, iy;
    unsigned char vret = FIND_PATH_RET_FOLDER;

    vclusterdirant = vclusterdir;
    vclusterdirnew = vclusterdir;
    vretpath.ClusterDirAtu = vclusterdir;

    ix = 0;

    // Verifica se eh diretorio raiz
	if (vpath[0] == '/')
    {
		vclusterdirnew = vdisk.root;
        vclusterdir = vclusterdirnew;
        ix++;
    }

    // Loop ateh a ultima pasta
    if (vpath[1] != 0x00)
    {
        while(1)
        {
            iy = 0;

            while(vpath[ix] != 0x00 && vpath[ix] != '/')
            {
                vretpath.Name[iy] = vpath[ix];
                ix++;
                iy++;
            }

            vretpath.Name[iy] = '\0';

            if (vpath[ix] == 0x00 && vtype == FIND_PATH_PART)
                break;

            vclusterdirnew = fsFindInDir(vretpath.Name, TYPE_DIRECTORY);

            if (vclusterdir != 2 && vclusterdirnew == 0 && vretpath.Name[0] == '.' && vretpath.Name[1] == '.')

            vclusterdirnew = 2;

            if (vclusterdirnew >= ERRO_D_START)
            {
                if (fsFindInDir(vretpath.Name, TYPE_FILE) >= ERRO_D_START)
                {
                    vret = FIND_PATH_RET_ERROR;
//                    vretpath.ClusterDir = ERRO_D_START;
                    vretpath.ClusterDir = vclusterdir;
                }
                else
                {
                    vret = FIND_PATH_RET_FILE;
                    vretpath.ClusterDir = vclusterdir;
                }

                vclusterdir = vclusterdirant;
                return vret;
            }

            vclusterdir = vclusterdirnew;
            vretpath.ClusterDir = vclusterdirnew;

            if (vpath[ix] == 0x00)
                break;

            ix++;
        }
    }

    vclusterdir = vclusterdirant;

    vretpath.ClusterDir = vclusterdirnew;

    return vret;
}

//-------------------------------------------------------------------------
unsigned char fsChangeDir(char * vdirname)
{
	unsigned long vclusterdirnew;
    unsigned short vlen, ix;

	// Troca o diretorio conforme especificado
	/*if (vdirname[0] == '/' && vdirname[1] == '\0')
		vclusterdirnew = vdisk.root;
	else
    {*/
        if (fsFindDirPath(vdirname, FIND_PATH_LAST) == FIND_PATH_RET_ERROR)
    		return ERRO_B_DIR_NOT_FOUND;
        vclusterdirnew = vretpath.ClusterDir;
    //}

	// Coloca o novo diretorio como atual
	vclusterdir = vclusterdirnew;
    vretpath.ClusterDirAtu = vclusterdirnew;

    if (vdirname[0] == '/' || vclusterdir == vdisk.root)
    {
        if (vdirname[0] == '/' && vdirname[1] != '\0')
        {
            for (ix = 0; ix < (sizeof(vdiratu) - 1) && vdirname[ix] != '\0'; ix++)
                vdiratu[ix] = vdirname[ix];

            vdiratu[ix] = '\0';
            vlen = strlen(vdiratu);
            if (vlen > 1 && vdiratu[vlen - 1] == '/')
                vdiratu[vlen - 1] = '\0';
        }
        else
        {
            vdiratu[0] = '/';
            vdiratu[1] = '\0';
        }
    }
    else if (vdirname[0] == '.' && vdirname[1] == '.' && vdirname[2] == '\0')
    {
        vlen = strlen(vdiratu);
        if (vlen > 1)
        {
            if (vdiratu[vlen - 1] == '/')
            {
                vlen--;
                vdiratu[vlen] = '\0';
            }

            while (vlen > 1 && vdiratu[vlen - 1] != '/')
            {
                vlen--;
                vdiratu[vlen] = '\0';
            }

            if (vlen > 1 && vdiratu[vlen - 1] == '/')
                vdiratu[vlen - 1] = '\0';
        }
    }
    else if (!(vdirname[0] == '.' && vdirname[1] == '\0'))
    {
        vlen = strlen(vdiratu);
        if (vlen > 1 && vdiratu[vlen - 1] != '/')
        {
            strcat((char *)vdiratu, "/");
            vlen = strlen(vdiratu);
        }

        ix = 0;
        while (vdirname[ix] != '\0' && vlen < (sizeof(vdiratu) - 1))
        {
            vdiratu[vlen] = vdirname[ix];
            vlen++;
            ix++;
        }

        vdiratu[vlen] = '\0';
    }

    vdiratuidx = strlen(vdiratu);

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsRemoveDir(char * vdirname)
{
    unsigned char vretEmpty;

    if (fsFindDirPath(vdirname, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
        return ERRO_B_DIR_NOT_FOUND;

    vclusterdir = vretpath.ClusterDir;

    /*printText("Aqui 2 - ");
    printText(vretpath.Name);
    printText("\r\n");*/

	if (fsFindInDir(vretpath.Name, TYPE_DIRECTORY) >= ERRO_D_START)
    {
        vclusterdir = vretpath.ClusterDirAtu;
		return ERRO_B_DIR_NOT_FOUND;
    }

	vretEmpty = fsCheckDirEmpty(vdir.FirstCluster);
    if (vretEmpty != RETURN_OK)
    {
        vclusterdir = vretpath.ClusterDirAtu;
        return vretEmpty;
    }

	// Apaga o diretorio conforme especificado
	if (fsFindInDir(vretpath.Name, TYPE_DEL_DIR) >= ERRO_D_START)
    {
        vclusterdir = vretpath.ClusterDirAtu;
		return ERRO_B_DIR_NOT_FOUND;
    }

    vclusterdir = vretpath.ClusterDirAtu;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsPwdDir(unsigned char *vdirpath) {
    if (vclusterdir == vdisk.root) {
        vdirpath[0] = '/';
        vdirpath[1] = '\0';
    }
    else {
        memcpy(vdirpath, vdiratu, sizeof(vdiratu));
        vdirpath[sizeof(vdiratu) - 1] = '\0';
    }

	return RETURN_OK;
}

//-------------------------------------------------------------------------
void fsGetDirAtuData(FAT32_DIR *pDir)
{
    memcpy(pDir, &vdir, sizeof(FAT32_DIR));
}

//-------------------------------------------------------------------------
static unsigned char fsCheckDirEmpty(unsigned long vdircluster)
{
    unsigned long vclusteratual, vclusternext, vdata, vtemp1, vtemp2;
    unsigned short ix, iz;

    vclusteratual = vdircluster;

    while (1)
    {
        vtemp1 = ((vclusteratual - 2) * vdisk.SecPerClus);
        vtemp2 = vdisk.data;
        vdata = vtemp1 + vtemp2;

        for (iz = 0; iz < vdisk.SecPerClus; iz++)
        {
            if (!fsSectorRead(vdata, gDataBuffer))
                return ERRO_B_READ_DISK;

            for (ix = 0; ix < vdisk.sectorSize; ix += 32)
            {
                if (gDataBuffer[ix] == DIR_EMPTY)
                    return RETURN_OK;

                if (gDataBuffer[ix] == DIR_DEL)
                    continue;

                if (gDataBuffer[ix + 11] == ATTR_LONG_NAME)
                    return ERRO_B_DIR_NOT_EMPTY;

                if (gDataBuffer[ix] == '.' && gDataBuffer[ix + 1] == 0x20)
                    continue;

                if (gDataBuffer[ix] == '.' && gDataBuffer[ix + 1] == '.' && gDataBuffer[ix + 2] == 0x20)
                    continue;

                return ERRO_B_DIR_NOT_EMPTY;
            }

            vdata++;
        }

        vclusternext = fsFindNextCluster(vclusteratual, NEXT_FIND);
        if (vclusternext >= ERRO_D_START)
            return ERRO_B_READ_DISK;

        if (vclusternext == LAST_CLUSTER_FAT32)
            break;

        vclusteratual = vclusternext;
    }

    return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned long fsFindInDir(char * vname, unsigned char vtype)
{
	unsigned long vfat, vdata, vclusterfile, vclusterdirnew, vclusteratual, vtemp1, vtemp2;
	unsigned char fnameName[9], fnameExt[4];
    unsigned short im, ix, iy, iz, vpos, ventrydir, ixold;
    unsigned long vsecfat;
	unsigned short vdirdate, vdirtime, ikk, ikj, vtemp, vbytepic;
	unsigned char vcomp, iw, ds1307[7], iww, vtempt[5], vlinha[5];
    unsigned char sqtdtam[10];

	memset(fnameName, 0x20, 8);
	memset(fnameExt, 0x20, 3);

	if (vname != NULL) {
		if (vname[0] == '.' && vname[1] == '.') {
			fnameName[0] = vname[0];
			fnameName[1] = vname[1];
		}
		else if (vname[0] == '.') {
			fnameName[0] = vname[0];
		}
		else {
			iy = 0;
			for (ix = 0; ix <= strlen(vname); ix++) {
				if (vname[ix] == '\0')
					break;
				else if (vname[ix] == '.')
					iy = 8;
				else {
					for (iww = 0; iww <= 56; iww++) {
						if (strValidChars[iww] == vname[ix])
							break;
					}

					if (iww > 56)
						return ERRO_D_INVALID_NAME;

					if (iy <= 7)
						fnameName[iy] = vname[ix];
					else {
					    ikk = iy - 8;
						fnameExt[ikk] = vname[ix];
					}

					iy++;
				}
			}
		}
	}

	vfat = vdisk.fat;
	vtemp1 = ((vclusterdir - 2) * vdisk.SecPerClus);
    vtemp2 = vdisk.data;
	vdata = vtemp1 + vtemp2;

	vclusterfile = ERRO_D_NOT_FOUND;
	vclusterdirnew = vclusterdir;
	ventrydir = 0;

	while (vdata != LAST_CLUSTER_FAT32)
    {
		for (iw = 0; iw < vdisk.SecPerClus; iw++)
        {

      		if (!fsSectorRead(vdata, gDataBuffer))
				return ERRO_D_READ_DISK;

			for (ix = 0; ix < vdisk.sectorSize; ix += 32)
            {
				for (iy = 0; iy < 8; iy++)
                {
				    ikk = ix + iy;
					*(vdir.Name + iy) = gDataBuffer[ikk];
				}

				for (iy = 0; iy < 3; iy++)
                {
				    ikk = ix + 8 + iy;
					*(vdir.Ext + iy) = gDataBuffer[ikk];
                }

                ikk = ix + 11;
				vdir.Attr = gDataBuffer[ikk];

                ikk = ix + 15;
				vdir.CreateTime  = (unsigned short)gDataBuffer[ikk] << 8;
                ikk = ix + 14;
				vdir.CreateTime |= (unsigned short)gDataBuffer[ikk];

                ikk = ix + 17;
				vdir.CreateDate  = (unsigned short)gDataBuffer[ikk] << 8;
                ikk = ix + 16;
				vdir.CreateDate |= (unsigned short)gDataBuffer[ikk];

                ikk = ix + 19;
				vdir.LastAccessDate  = (unsigned short)gDataBuffer[ikk] << 8;
                ikk = ix + 18;
				vdir.LastAccessDate |= (unsigned short)gDataBuffer[ikk];

                ikk = ix + 23;
				vdir.UpdateTime  = (unsigned short)gDataBuffer[ikk] << 8;
                ikk = ix + 22;
				vdir.UpdateTime |= (unsigned short)gDataBuffer[ikk];

                ikk = ix + 25;
				vdir.UpdateDate  = (unsigned short)gDataBuffer[ikk] << 8;
                ikk = ix + 24;
				vdir.UpdateDate |= (unsigned short)gDataBuffer[ikk];

                ikk = ix + 21;
				vdir.FirstCluster  = (unsigned long)gDataBuffer[ikk] << 24;
                ikk = ix + 20;
				vdir.FirstCluster |= (unsigned long)gDataBuffer[ikk] << 16;
                ikk = ix + 27;
				vdir.FirstCluster |= (unsigned long)gDataBuffer[ikk] << 8;
                ikk = ix + 26;
				vdir.FirstCluster |= (unsigned long)gDataBuffer[ikk];

                ikk = ix + 31;
				vdir.Size  = (unsigned long)gDataBuffer[ikk] << 24;
                ikk = ix + 30;
				vdir.Size |= (unsigned long)gDataBuffer[ikk] << 16;
                ikk = ix + 29;
				vdir.Size |= (unsigned long)gDataBuffer[ikk] << 8;
                ikk = ix + 28;
				vdir.Size |= (unsigned long)gDataBuffer[ikk];

				vdir.DirClusSec = vdata;
				vdir.DirEntry = ix;

				if (vtype == TYPE_FIRST_ENTRY && vdir.Attr != 0x0F) {
					if (vdir.Name[0] != DIR_DEL) {
			 			if (vdir.Name[0] != DIR_EMPTY) {
							vclusterfile = vdir.FirstCluster;
    						vdata = LAST_CLUSTER_FAT32;
    						break;
    					}
					}
				}

				if (vtype == TYPE_EMPTY_ENTRY || vtype == TYPE_CREATE_FILE || vtype == TYPE_CREATE_DIR) {
					if (vdir.Name[0] == DIR_EMPTY || vdir.Name[0] == DIR_DEL) {
						vclusterfile = ventrydir;

						if (vtype != TYPE_EMPTY_ENTRY) {
							vclusterfile = fsFindClusterFree(FREE_USE);

							if (vclusterfile >= ERRO_D_START)
								return ERRO_D_NOT_FOUND;

						    if (!fsSectorRead(vdata, gDataBuffer))
								return ERRO_D_READ_DISK;

							for (iz = 0; iz <= 10; iz++) {
								if (iz <= 7) {
								    ikk = ix + iz;
									gDataBuffer[ikk] = fnameName[iz];
								}
								else {
								    ikk = ix + iz;
								    ikj = iz - 8;
									gDataBuffer[ikk] = fnameExt[ikj];
								}
							}

							if (vtype == TYPE_CREATE_FILE)
								gDataBuffer[ix + 11] = 0x00;
							else
								gDataBuffer[ix + 11] = ATTR_DIRECTORY;

							// Ler Data/Hora do DS1307 - I2C
                            ds1307[3] = 01;
                            ds1307[4] = 01;
                            ds1307[5] = 2024;
                            ds1307[0] = 00;
                            ds1307[1] = 00;
                            ds1307[2] = 00;

						    // Converte para a Data/Hora da FAT32
							vdirtime = datetimetodir(ds1307[0], ds1307[1], ds1307[2], CONV_HORA);
							vdirdate = datetimetodir(ds1307[3], ds1307[4], ds1307[5], CONV_DATA);

							// Coloca dados no buffer para gravacao
							ikk = ix + 12;
							gDataBuffer[ikk] = 0x00;	// case
							ikk = ix + 13;
							gDataBuffer[ikk] = 0x00;	// creation time in ms
							ikk = ix + 14;
							gDataBuffer[ikk] = (unsigned char)(vdirtime & 0xFF);	// creation time (ds1307)
							ikk = ix + 15;
							gDataBuffer[ikk] = (unsigned char)((vdirtime >> 8) & 0xFF);
							ikk = ix + 16;
							gDataBuffer[ikk] = (unsigned char)(vdirdate & 0xFF);	// creation date (ds1307)
							ikk = ix + 17;
							gDataBuffer[ikk] = (unsigned char)((vdirdate >> 8) & 0xFF);
							ikk = ix + 18;
							gDataBuffer[ikk] = (unsigned char)(vdirdate & 0xFF);	// last access	(ds1307)
							ikk = ix + 19;
							gDataBuffer[ikk] = (unsigned char)((vdirdate >> 8) & 0xFF);

							ikk = ix + 22;
							gDataBuffer[ikk] = (unsigned char)(vdirtime & 0xFF);	// time update (ds1307)
							ikk = ix + 23;
							gDataBuffer[ikk] = (unsigned char)((vdirtime >> 8) & 0xFF);
							ikk = ix + 24;
							gDataBuffer[ikk] = (unsigned char)(vdirdate & 0xFF);	// date update (ds1307)
							ikk = ix + 25;
							gDataBuffer[ikk] = (unsigned char)((vdirdate >> 8) & 0xFF);

							ikk = ix + 26;
						    gDataBuffer[ikk] = (unsigned char)(vclusterfile & 0xFF);
							ikk = ix + 27;
						    gDataBuffer[ikk] = (unsigned char)((vclusterfile / 0x100) & 0xFF);
							ikk = ix + 20;
						    gDataBuffer[ikk] = (unsigned char)((vclusterfile / 0x10000) & 0xFF);
							ikk = ix + 21;
						    gDataBuffer[ikk] = (unsigned char)((vclusterfile / 0x1000000) & 0xFF);

							ikk = ix + 28;
							gDataBuffer[ikk] = 0x00;
							ikk = ix + 29;
							gDataBuffer[ikk] = 0x00;
							ikk = ix + 30;
							gDataBuffer[ikk] = 0x00;
							ikk = ix + 31;
							gDataBuffer[ikk] = 0x00;

							if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
								return ERRO_D_WRITE_DISK;

							if (vtype == TYPE_CREATE_DIR) {
	  							// Posicionar na nova posicao do diretorio
                            	vtemp1 = ((vclusterfile - 2) * vdisk.SecPerClus);
                                	vtemp2 = vdisk.data;
                            	vdata = vtemp1 + vtemp2;

								// Limpar novo cluster do diretorio (Zerar)
								memset(gDataBuffer, 0x00, vdisk.sectorSize);

								for (iz = 0; iz < vdisk.SecPerClus; iz++) {
								    if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
										return ERRO_D_WRITE_DISK;
									vdata++;
								}

                            	vtemp1 = ((vclusterfile - 2) * vdisk.SecPerClus);
                                	vtemp2 = vdisk.data;
                            	vdata = vtemp1 + vtemp2;

	  							// Criar diretorio . (atual)
	  							memset(gDataBuffer, 0x00, vdisk.sectorSize);

	  							ix = 0;
	  							gDataBuffer[0] = '.';
	  							gDataBuffer[1] = 0x20;
	  							gDataBuffer[2] = 0x20;
	  							gDataBuffer[3] = 0x20;
	  							gDataBuffer[4] = 0x20;
	  							gDataBuffer[5] = 0x20;
	  							gDataBuffer[6] = 0x20;
	  							gDataBuffer[7] = 0x20;
	  							gDataBuffer[8] = 0x20;
	  							gDataBuffer[9] = 0x20;
	  							gDataBuffer[10] = 0x20;

	  							gDataBuffer[11] = 0x10;

								gDataBuffer[12] = 0x00;	// case
								gDataBuffer[13] = 0x00;	// creation time in ms
								gDataBuffer[14] = (unsigned char)(vdirtime & 0xFF);	// creation time (ds1307)
								gDataBuffer[15] = (unsigned char)((vdirtime >> 8) & 0xFF);
								gDataBuffer[16] = (unsigned char)(vdirdate & 0xFF);	// creation date (ds1307)
								gDataBuffer[17] = (unsigned char)((vdirdate >> 8) & 0xFF);
								gDataBuffer[18] = (unsigned char)(vdirdate & 0xFF);	// last access	(ds1307)
								gDataBuffer[19] = (unsigned char)((vdirdate >> 8) & 0xFF);

								gDataBuffer[22] = (unsigned char)(vdirtime & 0xFF);	// time update (ds1307)
								gDataBuffer[23] = (unsigned char)((vdirtime >> 8) & 0xFF);
								gDataBuffer[24] = (unsigned char)(vdirdate & 0xFF);	// date update (ds1307)
								gDataBuffer[25] = (unsigned char)((vdirdate >> 8) & 0xFF);

	  						    gDataBuffer[26] = (unsigned char)(vclusterfile & 0xFF);
	  						    gDataBuffer[27] = (unsigned char)((vclusterfile / 0x100) & 0xFF);
	  						    gDataBuffer[20] = (unsigned char)((vclusterfile / 0x10000) & 0xFF);
	  						    gDataBuffer[21] = (unsigned char)((vclusterfile / 0x1000000) & 0xFF);

	  							gDataBuffer[28] = 0x00;
	  							gDataBuffer[29] = 0x00;
	  							gDataBuffer[30] = 0x00;
	  							gDataBuffer[31] = 0x00;

	  							// Criar diretorio .. (anterior)
	  							ix = 32;
	  							gDataBuffer[32] = '.';
	  							gDataBuffer[33] = '.';
	  							gDataBuffer[34] = 0x20;
	  							gDataBuffer[35] = 0x20;
	  							gDataBuffer[36] = 0x20;
	  							gDataBuffer[37] = 0x20;
	  							gDataBuffer[38] = 0x20;
	  							gDataBuffer[39] = 0x20;
	  							gDataBuffer[40] = 0x20;
	  							gDataBuffer[41] = 0x20;
	  							gDataBuffer[42] = 0x20;

	  							gDataBuffer[43] = 0x10;

								gDataBuffer[44] = 0x00;	// case
								gDataBuffer[45] = 0x00;	// creation time in ms
								gDataBuffer[46] = (unsigned char)(vdirtime & 0xFF);	// creation time (ds1307)
								gDataBuffer[47] = (unsigned char)((vdirtime >> 8) & 0xFF);
								gDataBuffer[48] = (unsigned char)(vdirdate & 0xFF);	// creation date (ds1307)
								gDataBuffer[49] = (unsigned char)((vdirdate >> 8) & 0xFF);
								gDataBuffer[50] = (unsigned char)(vdirdate & 0xFF);	// last access	(ds1307)
								gDataBuffer[51] = (unsigned char)((vdirdate >> 8) & 0xFF);

								gDataBuffer[54] = (unsigned char)(vdirtime & 0xFF);	// time update (ds1307)
								gDataBuffer[55] = (unsigned char)((vdirtime >> 8) & 0xFF);
								gDataBuffer[56] = (unsigned char)(vdirdate & 0xFF);	// date update (ds1307)
								gDataBuffer[57] = (unsigned char)((vdirdate >> 8) & 0xFF);

	  						    gDataBuffer[58] = (unsigned char)(vclusterdir & 0xFF);
	  						    gDataBuffer[59] = (unsigned char)((vclusterdir / 0x100) & 0xFF);
	  						    gDataBuffer[52] = (unsigned char)((vclusterdir / 0x10000) & 0xFF);
	  						    gDataBuffer[53] = (unsigned char)((vclusterdir / 0x1000000) & 0xFF);

	  							gDataBuffer[60] = 0x00;
	  							gDataBuffer[61] = 0x00;
	  							gDataBuffer[62] = 0x00;
	  							gDataBuffer[63] = 0x00;

	  						    if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
	  								return ERRO_D_WRITE_DISK;
	              			}

							vdata = LAST_CLUSTER_FAT32;
							break;
						}

						vdata = LAST_CLUSTER_FAT32;
						break;
					}
				}
				else if (vtype != TYPE_FIRST_ENTRY) {
					if (vdir.Name[0] != DIR_EMPTY && vdir.Name[0] != DIR_DEL) {
						vcomp = 1;
						for (iz = 0; iz <= 10; iz++) {
							if (iz <= 7) {
								if (fnameName[iz] != vdir.Name[iz]) {
									vcomp = 0;
									break;
								}
							}
							else {
							    ikk = iz - 8;
								if (fnameExt[ikk] != vdir.Ext[ikk]) {
									vcomp = 0;
									break;
								}
							}
						}

						if (vcomp) {
							if (vtype == TYPE_ALL || (vtype == TYPE_FILE && vdir.Attr != ATTR_DIRECTORY) || (vtype == TYPE_DIRECTORY && vdir.Attr == ATTR_DIRECTORY)) {
		  						vclusterfile = vdir.FirstCluster;
		  						break;
	  						}
	  						else if (vtype == TYPE_NEXT_ENTRY) {
		  						vtype = TYPE_FIRST_ENTRY;
		  					}
	  						else if (vtype == TYPE_DEL_FILE || vtype == TYPE_DEL_DIR) {
								// Guardando Cluster Atual
								vclusteratual = vdir.FirstCluster;

              					// Apaga a entrada principal e as entradas LFN imediatamente anteriores.
                                if (fsDeleteDirEntryChain(vdata, ix) != RETURN_OK)
                      				return ERRO_D_WRITE_DISK;

				                // Apagando vestigios na FAT
	          					while (1) {
				                    // Procura Proximo Cluster e ja zera
			           			    vclusterdirnew = fsFindNextCluster(vclusteratual, NEXT_FREE);

					                if (vclusterdirnew >= ERRO_D_START)
					                    return ERRO_D_NOT_FOUND;

					                if (vclusterdirnew == LAST_CLUSTER_FAT32) {
						                vclusterfile = LAST_CLUSTER_FAT32;
						          		vdata = LAST_CLUSTER_FAT32;
						          		break;
					                }

			            			// Tornar cluster atual o proximo
			            			vclusteratual = vclusterdirnew;
	          					}
	  						}
						}
					}
				}

				if (vdir.Name[0] == DIR_EMPTY) {
					vdata = LAST_CLUSTER_FAT32;
					break;
				}
			}

			if (vclusterfile < ERRO_D_START || vdata == LAST_CLUSTER_FAT32)
				break;

			ventrydir++;
			vdata++;
		}
		// Se conseguiu concluir a operacao solicitada, sai do loop
		if (vclusterfile < ERRO_D_START || vdata == LAST_CLUSTER_FAT32)
			break;
		else {
//writeLongSerial("Aqui 28.0\r\n\0");
			// Posiciona na FAT, o endereco da pasta atual
			vsecfat = vclusterdirnew / 128;
			vfat = vdisk.fat + vsecfat;

		    if (!fsSectorRead(vfat, gDataBuffer))
				return ERRO_D_READ_DISK;

            vtemp = vclusterdirnew - ( 128 * vsecfat);
			vpos = vtemp * 4;
            ikk = vpos + 3;
			vclusterdirnew  = (unsigned long)gDataBuffer[ikk] << 24;
            ikk = vpos + 2;
			vclusterdirnew |= (unsigned long)gDataBuffer[ikk] << 16;
            ikk = vpos + 1;
			vclusterdirnew |= (unsigned long)gDataBuffer[ikk] << 8;
            ikk = vpos;
			vclusterdirnew |= (unsigned long)gDataBuffer[ikk];

            /* FAT32 entries use only 28 bits and EOC is in range 0x0FFFFFF8..0x0FFFFFFF */
            vclusterdirnew &= 0x0FFFFFFF;
            if (vclusterdirnew >= 0x0FFFFFF8)
                vclusterdirnew = LAST_CLUSTER_FAT32;

			if (vclusterdirnew != LAST_CLUSTER_FAT32) {

				// Devolve a proxima posicao para procura/uso
            	vtemp1 = ((vclusterdirnew - 2) * vdisk.SecPerClus);
                	vtemp2 = vdisk.data;
            	vdata = vtemp1 + vtemp2;
			}
			else {
				// Se for para criar uma nova entrada no diretorio e nao tem mais espaco
				// Cria uma nova entrada na Fat
				if (vtype == TYPE_EMPTY_ENTRY || vtype == TYPE_CREATE_FILE || vtype == TYPE_CREATE_DIR) {
					vclusterdirnew = fsFindClusterFree(FREE_USE);

					if (vclusterdirnew < ERRO_D_START) {
					    if (!fsSectorRead(vfat, gDataBuffer))
							return ERRO_D_READ_DISK;

					    gDataBuffer[vpos] = (unsigned char)(vclusterdirnew & 0xFF);
					    ikk = vpos + 1;
					    gDataBuffer[ikk] = (unsigned char)((vclusterdirnew / 0x100) & 0xFF);
					    ikk = vpos + 2;
					    gDataBuffer[ikk] = (unsigned char)((vclusterdirnew / 0x10000) & 0xFF);
					    ikk = vpos + 3;
					    gDataBuffer[ikk] = (unsigned char)((vclusterdirnew / 0x1000000) & 0xFF);

                        if (fsWriteFatSector(vfat) != RETURN_OK)
                            return ERRO_D_WRITE_DISK;

						// Posicionar na nova posicao do diretorio
                    	vtemp1 = ((vclusterdirnew - 2) * vdisk.SecPerClus);
                            	vtemp2 = vdisk.data;
                    	vdata = vtemp1 + vtemp2;

						// Limpar novo cluster do diretorio (Zerar)
						memset(gDataBuffer, 0x00, vdisk.sectorSize);

						for (iz = 0; iz < vdisk.SecPerClus; iz++) {
						    if (!fsSectorWrite(vdata, gDataBuffer, FALSE))
								return ERRO_D_WRITE_DISK;
							vdata++;
						}

                    	vtemp1 = ((vclusterdirnew - 2) * vdisk.SecPerClus);
                        	vtemp2 = vdisk.data;
                    	vdata = vtemp1 + vtemp2;
					}
					else {
						vclusterdirnew = LAST_CLUSTER_FAT32;
						vclusterfile = ERRO_D_NOT_FOUND;
						vdata = vclusterdirnew;
					}
				}
				else {
					vdata = vclusterdirnew;
				}
			}
		}
	}

	return vclusterfile;
}

//-------------------------------------------------------------------------
unsigned char fsUpdateDir()
{
	unsigned char iy;
	unsigned short ventry, ikk;

	if (!fsSectorRead(vdir.DirClusSec, gDataBuffer))
		return ERRO_B_READ_DISK;

    ventry = vdir.DirEntry;

	for (iy = 0; iy < 8; iy++) {
	    ikk = ventry + iy;
		gDataBuffer[ikk] = vdir.Name[iy];
	}

	for (iy = 0; iy < 3; iy++) {
	    ikk = ventry + 8 + iy;
		gDataBuffer[ikk] = vdir.Ext[iy];
	}

    ikk = ventry + 18;
	gDataBuffer[ikk] = (unsigned char)(vdir.LastAccessDate & 0xFF);	// last access	(ds1307)
    ikk = ventry + 19;
	gDataBuffer[ikk] = (unsigned char)((vdir.LastAccessDate / 0x100) & 0xFF);

    ikk = ventry + 22;
	gDataBuffer[ikk] = (unsigned char)(vdir.UpdateTime & 0xFF);	// time update (ds1307)
    ikk = ventry + 23;
	gDataBuffer[ikk] = (unsigned char)((vdir.UpdateTime / 0x100) & 0xFF);

    ikk = ventry + 24;
	gDataBuffer[ikk] = (unsigned char)(vdir.UpdateDate & 0xFF);	// date update (ds1307)
    ikk = ventry + 25;
	gDataBuffer[ikk] = (unsigned char)((vdir.UpdateDate / 0x100) & 0xFF);

    ikk = ventry + 28;
    gDataBuffer[ikk] = (unsigned char)(vdir.Size & 0xFF);
    ikk = ventry + 29;
    gDataBuffer[ikk] = (unsigned char)((vdir.Size / 0x100) & 0xFF);
    ikk = ventry + 30;
    gDataBuffer[ikk] = (unsigned char)((vdir.Size / 0x10000) & 0xFF);
    ikk = ventry + 31;
    gDataBuffer[ikk] = (unsigned char)((vdir.Size / 0x1000000) & 0xFF);

   if (!fsSectorWrite(vdir.DirClusSec, gDataBuffer, FALSE))
		return ERRO_B_WRITE_DISK;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned long fsFindNextCluster(unsigned long vclusteratual, unsigned char vtype)
{
	unsigned long vfat, vclusternew;
    unsigned short vpos, ikk;
    unsigned long vsecfat;

	vsecfat = vclusteratual / 128;
	vfat = vdisk.fat + vsecfat;

	if (!fsSectorRead(vfat, gDataBuffer))
		return ERRO_D_READ_DISK;

	vpos = (vclusteratual - ( 128 * vsecfat)) * 4;
	ikk = vpos + 3;
	vclusternew  = (unsigned long)gDataBuffer[ikk] << 24;
	ikk = vpos + 2;
	vclusternew |= (unsigned long)gDataBuffer[ikk] << 16;
	ikk = vpos + 1;
	vclusternew |= (unsigned long)gDataBuffer[ikk] << 8;
	vclusternew |= (unsigned long)gDataBuffer[vpos];

    /* FAT32 entries use only 28 bits and EOC is in range 0x0FFFFFF8..0x0FFFFFFF */
    vclusternew &= 0x0FFFFFFF;
    if (vclusternew >= 0x0FFFFFF8)
        vclusternew = LAST_CLUSTER_FAT32;

	if (vtype != NEXT_FIND) {
		if (vtype == NEXT_FREE) {
			gDataBuffer[vpos] = 0x00;
        	ikk = vpos + 1;
			gDataBuffer[ikk] = 0x00;
        	ikk = vpos + 2;
			gDataBuffer[ikk] = 0x00;
        	ikk = vpos + 3;
			gDataBuffer[ikk] = 0x00;
		}
		else if (vtype == NEXT_FULL) {
			gDataBuffer[vpos] = 0xFF;
        	ikk = vpos + 1;
			gDataBuffer[ikk] = 0xFF;
        	ikk = vpos + 2;
			gDataBuffer[ikk] = 0xFF;
        	ikk = vpos + 3;
			gDataBuffer[ikk] = 0x0F;
		}

        if (fsWriteFatSector(vfat) != RETURN_OK)
            return ERRO_D_WRITE_DISK;
	}

  return vclusternew;
}

//-------------------------------------------------------------------------
unsigned long fsFindClusterFree(unsigned char vtype)
{
  	unsigned long vclusterfree = 0x00, cc, vfat;
	unsigned short jj, ikk, ikk2, ikk3;

	vfat = vdisk.fat;

    for (cc = 0; cc < vdisk.fatsize; cc++) {
	    // LER FAT SECTOR
		if (!fsSectorRead(vfat, gDataBuffer))
			return ERRO_D_READ_DISK;

		// Procura Cluster Livre dentro desse setor
		for (jj = 0; jj < vdisk.sectorSize; jj += 4) {
		    ikk = jj + 1;
		    ikk2 = jj + 2;
		    ikk3 = jj + 3;
			if (gDataBuffer[jj] == 0x00 && gDataBuffer[ikk] == 0x00 && gDataBuffer[ikk2] == 0x00 && gDataBuffer[ikk3] == 0x00)
			    break;

			vclusterfree++;
		}

		// Se achou algum setor livre, sai do loop
		if (jj < vdisk.sectorSize)
			break;

		// Soma mais 1 para procurar proximo cluster
		vfat++;
	}

    if (cc >= vdisk.fatsize)
		vclusterfree = ERRO_D_DISK_FULL;
	else {
		if (vtype == FREE_USE) {
		    gDataBuffer[jj] = 0xFF;
		    ikk = jj + 1;
		    gDataBuffer[ikk] = 0xFF;
		    ikk = jj + 2;
		    gDataBuffer[ikk] = 0xFF;
		    ikk = jj + 3;
		    gDataBuffer[ikk] = 0x0F;

            if (fsWriteFatSector(vfat) != RETURN_OK)
                return ERRO_D_WRITE_DISK;
		}
	}

	return (vclusterfree);
}

//-------------------------------------------------------------------------
unsigned char fsFormat (long int serialNumber, char * volumeID)
{
    unsigned short    j;
    unsigned long   secCount, RootDirSectors;
    unsigned long   root, fat, firsts, fatsize, test;
    unsigned long   Index;
	unsigned char    SecPerClus;

    unsigned char *  dataBufferPointer = gDataBuffer;

	// Ler MBR
    if (!fsSectorRead(0x00, gDataBuffer))
		return ERRO_B_READ_DISK;

    secCount  = (unsigned long)gDataBuffer[461] << 24;
    secCount |= (unsigned long)gDataBuffer[460] << 16;
    secCount |= (unsigned long)gDataBuffer[459] << 8;
    secCount |= (unsigned long)gDataBuffer[458];

    firsts  = (unsigned long)gDataBuffer[457] << 24;
    firsts |= (unsigned long)gDataBuffer[456] << 16;
    firsts |= (unsigned long)gDataBuffer[455] << 8;
    firsts |= (unsigned long)gDataBuffer[454];

    *(dataBufferPointer + 450) = 0x0B;

    if (!fsSectorWrite (0x00, gDataBuffer, TRUE))
		return ERRO_B_WRITE_DISK;

	//-------------------

	if (secCount >= 0x000EEB7F && secCount <= 0x01000000)	// 512 MB to 8 GB, 8 sectors per cluster
		SecPerClus = 8;
	else if (secCount > 0x01000000 && secCount <= 0x02000000) // 8 GB to 16 GB, 16 sectors per cluster
		SecPerClus = 16;
	else if (secCount > 0x02000000 && secCount <= 0x04000000) // 16 GB to 32 GB, 32 sectors per cluster
		SecPerClus = 32;
	else if (secCount > 0x04000000) // More than 32 GB, 64 sectors per cluster
		SecPerClus = 64;
	//-------------------

	//-------------------
    fatsize = (secCount - 0x26);
    fatsize = (fatsize / ((256 * SecPerClus + 2) / 2));
    fat = 0x26 + firsts;
    root = fat + (2 * fatsize);
	//-------------------

	// Formata MicroSD
    memset (gDataBuffer, 0x00, MEDIA_SECTOR_SIZE);

    // Non-file system specific values
    gDataBuffer[0] = 0xEB;         //Jump instruction
    gDataBuffer[1] = 0x3C;
    gDataBuffer[2] = 0x90;
    gDataBuffer[3] =  'M';         //OEM Name
    gDataBuffer[4] =  'M';
    gDataBuffer[5] =  'S';
    gDataBuffer[6] =  'J';
    gDataBuffer[7] =  ' ';
    gDataBuffer[8] =  'F';
    gDataBuffer[9] =  'A';
    gDataBuffer[10] = 'T';

    gDataBuffer[11] = 0x00;             //Sector size
    gDataBuffer[12] = 0x02;

    gDataBuffer[13] = SecPerClus;   //Sectors per cluster

    gDataBuffer[14] = 0x26;         //Reserved sector count
    gDataBuffer[15] = 0x00;

	fat = 0x26 + firsts;

    gDataBuffer[16] = 0x02;         //number of FATs

    gDataBuffer[17] = 0x00;          //Max number of root directory entries - 512 files allowed
    gDataBuffer[18] = 0x00;

    gDataBuffer[19] = 0x00;         //total sectors
    gDataBuffer[20] = 0x00;

    gDataBuffer[21] = 0xF8;         //Media Descriptor

    gDataBuffer[22] = 0x00;         //Sectors per FAT
    gDataBuffer[23] = 0x00;

    gDataBuffer[24] = 0x3F;         //Sectors per track
    gDataBuffer[25] = 0x00;

    gDataBuffer[26] = 0xFF;         //Number of heads
    gDataBuffer[27] = 0x00;

    // Hidden sectors = sectors between the MBR and the boot sector
    gDataBuffer[28] = (unsigned char)(firsts & 0xFF);
    gDataBuffer[29] = (unsigned char)((firsts / 0x100) & 0xFF);
    gDataBuffer[30] = (unsigned char)((firsts / 0x10000) & 0xFF);
    gDataBuffer[31] = (unsigned char)((firsts / 0x1000000) & 0xFF);

    // Total Sectors = same as sectors in the partition from MBR
    gDataBuffer[32] = (unsigned char)(secCount & 0xFF);
    gDataBuffer[33] = (unsigned char)((secCount / 0x100) & 0xFF);
    gDataBuffer[34] = (unsigned char)((secCount / 0x10000) & 0xFF);
    gDataBuffer[35] = (unsigned char)((secCount / 0x1000000) & 0xFF);

	// Sectors per FAT
	gDataBuffer[36] = (unsigned char)(fatsize & 0xFF);
    gDataBuffer[37] = (unsigned char)((fatsize / 0x100) & 0xFF);
    gDataBuffer[38] = (unsigned char)((fatsize / 0x10000) & 0xFF);
    gDataBuffer[39] = (unsigned char)((fatsize / 0x1000000) & 0xFF);

    gDataBuffer[40] = 0x00;         //Active FAT
    gDataBuffer[41] = 0x00;

    gDataBuffer[42] = 0x00;         //File System version
    gDataBuffer[43] = 0x00;

    gDataBuffer[44] = 0x02;         //First cluster of the root directory
    gDataBuffer[45] = 0x00;
    gDataBuffer[46] = 0x00;
    gDataBuffer[47] = 0x00;

    gDataBuffer[48] = 0x01;         //FSInfo
    gDataBuffer[49] = 0x00;

    gDataBuffer[50] = 0x00;         //Backup Boot Sector
    gDataBuffer[51] = 0x00;

    gDataBuffer[52] = 0x00;         //Reserved for future expansion
    gDataBuffer[53] = 0x00;
    gDataBuffer[54] = 0x00;
    gDataBuffer[55] = 0x00;
    gDataBuffer[56] = 0x00;
    gDataBuffer[57] = 0x00;
    gDataBuffer[58] = 0x00;
    gDataBuffer[59] = 0x00;
    gDataBuffer[60] = 0x00;
    gDataBuffer[61] = 0x00;
    gDataBuffer[62] = 0x00;
    gDataBuffer[63] = 0x00;

    gDataBuffer[64] = 0x00;         // Physical drive number

    gDataBuffer[65] = 0x00;         // Reserved (current head)

    gDataBuffer[66] = 0x29;         // Signature code

    gDataBuffer[67] = (unsigned char)(serialNumber & 0xFF);
    gDataBuffer[68] = (unsigned char)((serialNumber / 0x100) & 0xFF);
    gDataBuffer[69] = (unsigned char)((serialNumber / 0x10000) & 0xFF);
    gDataBuffer[70] = (unsigned char)((serialNumber / 0x1000000) & 0xFF);

    // Volume ID
    if (volumeID != NULL)
    {
        for (Index = 0; (*(volumeID + Index) != 0) && (Index < 11); Index++)
        {
            gDataBuffer[Index + 71] = *(volumeID + Index);
        }
        while (Index < 11)
        {
            gDataBuffer[71 + Index++] = 0x20;
        }
    }
    else
    {
        for (Index = 0; Index < 11; Index++)
        {
            gDataBuffer[Index+71] = 0;
        }
    }

    gDataBuffer[82] = 'F';
    gDataBuffer[83] = 'A';
    gDataBuffer[84] = 'T';
    gDataBuffer[85] = '3';
    gDataBuffer[86] = '2';
    gDataBuffer[87] = ' ';
    gDataBuffer[88] = ' ';
    gDataBuffer[89] = ' ';

    gDataBuffer[510] = 0x55;
    gDataBuffer[511] = 0xAA;

	if (!fsSectorWrite(firsts, gDataBuffer, FALSE))
		return ERRO_B_WRITE_DISK;

    // Erase the FAT
    memset (gDataBuffer, 0x00, MEDIA_SECTOR_SIZE);

    gDataBuffer[0] = 0xF8;          //BPB_Media byte value in its low 8 bits, and all other bits are set to 1
    gDataBuffer[1] = 0xFF;
    gDataBuffer[2] = 0xFF;
    gDataBuffer[3] = 0x0F;

    gDataBuffer[4] = 0xFF;          //Disk is clean and no read/write errors were encountered
    gDataBuffer[5] = 0xFF;
    gDataBuffer[6] = 0xFF;
    gDataBuffer[7] = 0xFF;

    gDataBuffer[8]  = 0xFF;         //Root Directory EOF
    gDataBuffer[9]  = 0xFF;
    gDataBuffer[10] = 0xFF;
    gDataBuffer[11] = 0x0F;

    for (j = 1; j != 0xFFFF; j--)
    {
        if (!fsSectorWrite (fat + (j * fatsize), gDataBuffer, FALSE))
			return ERRO_B_WRITE_DISK;
    }

    memset (gDataBuffer, 0x00, MEDIA_SECTOR_SIZE);

    for (Index = fat + 1; Index < (fat + fatsize); Index++)
    {
        for (j = 1; j != 0xFFFF; j--)
        {
            if (!fsSectorWrite (Index + (j * fatsize), gDataBuffer, FALSE))
				return ERRO_B_WRITE_DISK;
        }
    }

    // Erase the root directory
    for (Index = 1; Index < SecPerClus; Index++)
    {
        if (!fsSectorWrite (root + Index, gDataBuffer, FALSE))
			return ERRO_B_WRITE_DISK;
    }

    // Create a drive name entry in the root dir
    memset(gDataBuffer, 0x00, MEDIA_SECTOR_SIZE);
    Index = 0;
    while ((*(volumeID + Index) != 0) && (Index < 11))
    {
        gDataBuffer[Index] = *(volumeID + Index);
        Index++;
    }
    while (Index < 11)
    {
        gDataBuffer[Index++] = ' ';
    }
    gDataBuffer[11] = 0x08;
    gDataBuffer[17] = 0x11;
    gDataBuffer[19] = 0x11;
    gDataBuffer[23] = 0x11;

    if (!fsSectorWrite (root, gDataBuffer, FALSE))
		return ERRO_B_WRITE_DISK;

	return RETURN_OK;
}

//-------------------------------------------------------------------------
unsigned char fsSectorRead(unsigned long vsector, unsigned char* vbuffer){
    unsigned char attempt;

    for (attempt = 0; attempt < FS_SECTOR_RETRY_COUNT; attempt++) {
        if (fsSectorReadRaw(vsector, vbuffer))
            return 1;
    }

    return 0;
}

//-------------------------------------------------------------------------
unsigned char fsSectorWrite(unsigned long vsector, unsigned char* vbuffer, unsigned char vtipo){
    unsigned char attempt;
    static unsigned char vSectorVerify[MEDIA_SECTOR_SIZE];

    (void)vtipo;

    for (attempt = 0; attempt < FS_SECTOR_RETRY_COUNT; attempt++) {
        if (!fsSectorWriteRaw(vsector, vbuffer))
            continue;

#if FS_ENABLE_WRITE_VERIFY
        if (!fsSectorReadRaw(vsector, vSectorVerify))
            continue;

        if (!fsBufferEquals(vbuffer, vSectorVerify, MEDIA_SECTOR_SIZE))
            continue;
#endif

        return 1;
    }

    return 0;
}

//-----------------------------------------------------------------------------
void catFile(unsigned char *parquivo) {
    unsigned long voffset, vsizeR, vclusterdiratu;
    unsigned short ix;
    unsigned char vbuffer[128];

    voffset = 0;
    if (fsFindDirPath(parquivo, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
    {
        printText("Loading file error...\r\n\0");
        return;
    }

    vclusterdiratu = vretpath.ClusterDirAtu;
    vclusterdir = vretpath.ClusterDir;

    if (fsOpenFile(vretpath.Name) != RETURN_OK)
    {
        vclusterdir = vclusterdiratu;
        printText("Loading file error...\r\n\0");
        return;
    }

    while (1)
    {
        vsizeR = fsReadFile(vretpath.Name, voffset, vbuffer, sizeof(vbuffer));

        if (vsizeR == 0)
            break;

        for (ix = 0; ix < vsizeR; ix++)
        {
            if (vbuffer[ix] == 0x0D)
                printText("\r\0");
            else if (vbuffer[ix] == 0x0A)
                printText("\r\n\0");
            else if (vbuffer[ix] == 0x1A || vbuffer[ix] == 0x00)
            {
                fsCloseFile(vretpath.Name, 0);
                vclusterdir = vclusterdiratu;
                return;
            }
            else if (vbuffer[ix] >= 0x20 && vbuffer[ix] < 0xFF)
                printChar(vbuffer[ix], 1);
            else
                printChar(0x20, 1);
        }

        voffset += vsizeR;
    }

    fsCloseFile(vretpath.Name, 0);
    vclusterdir = vclusterdiratu;

    printText("\r\n\0");
}

//-----------------------------------------------------------------------------
unsigned char saveFile(unsigned char *parquivo, void* xaddress, unsigned long xsize)
{
    unsigned char *xaddressb = (unsigned char *)xaddress;
    unsigned char vbuffer[128];
    unsigned long ix;
    unsigned short iy;
    unsigned short vChunkSize;
    unsigned long vclusterdiratuaux;

    if (!parquivo || !xaddress)
        return ERRO_B_WRITE_FILE;

    vclusterdiratuaux = vclusterdir;

    // Resolve caminho (aceita pasta + nome), e usa somente o nome final para criar/gravar.
    if (fsFindDirPath(parquivo, FIND_PATH_LAST) == FIND_PATH_RET_ERROR)
        return ERRO_B_NOT_FOUND;

    if (!isValidFilename(vretpath.Name))
        return ERRO_B_INVALID_NAME;

    vclusterdir = vretpath.ClusterDir;

    // Truncate real: se existir, remove para nao deixar lixo no final.
    if (fsOpenFile(vretpath.Name) == RETURN_OK)
    {
        if (fsDelFile(vretpath.Name) != RETURN_OK)
        {
            vclusterdir = vretpath.ClusterDirAtu;
            return ERRO_B_APAGAR_ARQUIVO;
        }
    }

    if (fsCreateFile(vretpath.Name) != RETURN_OK)
    {
        vclusterdir = vretpath.ClusterDirAtu;
        return ERRO_B_CREATE_FILE;
    }

    for (ix = 0; ix < xsize; ix += 128)
    {
        vChunkSize = (unsigned short)(xsize - ix);
        if (vChunkSize > 128)
            vChunkSize = 128;

        for (iy = 0; iy < vChunkSize; iy++)
            vbuffer[iy] = *xaddressb++;

        if (fsWriteFile(vretpath.Name, ix, vbuffer, (unsigned char)vChunkSize) != RETURN_OK)
        {
            fsCloseFile(vretpath.Name, 0);
            vclusterdir = vretpath.ClusterDirAtu;
            return ERRO_B_WRITE_FILE;
        }
    }

    fsCloseFile(vretpath.Name, 1);

    vclusterdir = vclusterdiratuaux;

    return RETURN_OK;
}

//-----------------------------------------------------------------------------
unsigned long loadFile(unsigned char *parquivo, void* xaddress)
{
    return (loadFileSize(parquivo, xaddress, 0));
}

unsigned long loadFileSize(unsigned char *parquivo, void* xaddress, unsigned long xsize)
{
    unsigned short cc, dd;
    unsigned char vbuffer[512];
    unsigned char *xaddressb = (unsigned char *)xaddress;
    unsigned int vbytegrava = 0;
    unsigned short xdado = 0, xcounter = 0;
    unsigned short vcrc, vcrcpic, vloop;
    unsigned long vsizeR, vsizefile = 0, vsizeDest;

//*tempData = parquivo;
//*(tempData + 1) = xaddress;

	vsizefile = 0;
    verro = 0;

    vclusterdir = vretpath.ClusterDirAtu;

    if (fsFindDirPath(parquivo, FIND_PATH_PART) == FIND_PATH_RET_ERROR)
    {
        verro = 1;
        return vsizefile;
    }

    vclusterdir = vretpath.ClusterDir;

    if (fsOpenFile(vretpath.Name) == RETURN_OK)
    {
		while (1)
        {
			vsizeR = fsReadFile(vretpath.Name, vsizefile, vbuffer, 512);

			if (vsizeR != 0)
            {
                if (xsize != 0 && (xsize - vsizefile) < vsizeR)
                    vsizeDest = xsize - vsizefile;
                else
                    vsizeDest = vsizeR;

                for (dd = 0; dd < vsizeDest; dd++)
                {
                    // Grava exatamente os bytes lidos para evitar sobrescrever heap.
                    *xaddressb++ = vbuffer[dd];
                }


                vsizefile += vsizeR;

                if (xsize != 0 && vsizefile >= xsize)
                    break;
			}
			else
				break;
		}

        // Fecha o Arquivo
    	fsCloseFile(vretpath.Name, 0);
    }
    else
        verro = 2;

    vclusterdir = vretpath.ClusterDirAtu;

    return vsizefile;
}

//-------------------------------------------------------------------------
unsigned short datetimetodir(unsigned char hr_day, unsigned char min_month, unsigned char sec_year, unsigned char vtype)
{
	unsigned short vconv = 0, vtemp;

	if (vtype == CONV_DATA) {
	    vtemp = sec_year - 1980;
		vconv  = (unsigned short)(vtemp & 0x7F) << 9;
		vconv |= (unsigned short)(min_month & 0x0F) << 5;
		vconv |= (unsigned short)(hr_day & 0x1F);
	}
	else {
		vconv  = (unsigned short)(hr_day & 0x1F) << 11;
		vconv |= (unsigned short)(min_month & 0x3F) << 5;
		vtemp = sec_year / 2;
		vconv |= (unsigned short)(vtemp & 0x1F);
	}

	return vconv;
}

//-----------------------------------------------------------------------------
unsigned long pow(int val, int pot)
{
    int ix;
    int base = val;

    if (val != 0)
    {
        if (pot == 0)
            val = 1;
        else if (pot == 1)
            val = base;
        else
        {
            for (ix = 0; ix <= pot; ix++)
            {
                if (ix >= 2)
                    val *= base;
            }
        }
    }

    return val;
}

//-----------------------------------------------------------------------------
int hex2int(char ch)
{
    if (ch >= '0' && ch <= '9')
        return ch - '0';
    if (ch >= 'A' && ch <= 'F')
        return ch - 'A' + 10;
    if (ch >= 'a' && ch <= 'f')
        return ch - 'a' + 10;
    return -1;
}

//-----------------------------------------------------------------------------
unsigned long hexToLong(char *pHex)
{
    int ix;
    unsigned char ilen = strlen(pHex) - 1;
    unsigned long pVal = 0;

    for (ix = ilen; ix >= 0; ix--)
    {
        pVal += hex2int(pHex[ilen - ix]) * pow(16, ix);
    }

    return pVal;
}

//-----------------------------------------------------------------------------
void strncpy2( char* _dst, const char* _src, int _n )
{
    int i = 0;
    while(i != _n)
    {
        *_dst = *_src;
        _dst++;
        _src++;
        i++;
    }
}

//-----------------------------------------------------------------------------
int isValidFilename(char *filename)
{
    char valid_chars[60];
    int len, i;
    char name_part[9];
    char ext_part[4];
    char *dot;
    int name_len = 0, ext_len = 0;

    strcpy(valid_chars,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$&'()@^_`{}~");

    len = strlen(filename);

    // Verificar comprimento total
    if (len == 0 || len > 12) {
        return 0;
    }

    // Dividir o nome e a extensão (se existir)
    name_part[0] = '\0';
    ext_part[0] = '\0';
    dot = strchr(filename, '.');

    if (dot) {
        // Nome e extensão devem ser separados pelo ponto
        name_len = dot - filename;
        ext_len = len - name_len - 1;

        if (name_len == 0 || name_len > 8 || ext_len > 3) {
            return 0; // Nome ou extensão inválidos
        }

        strncpy2(name_part, filename, name_len);
        name_part[name_len] = 0x00;
        strncpy2(ext_part, dot + 1, ext_len);
        ext_part[ext_len] = 0x00;
    } else {
        // Sem ponto, apenas o nome principal
        if (len > 8) {
            return 0;
        }
        strncpy2(name_part, filename, len);
        name_part[len] = 0x00;
    }

    // Validar o nome
    for (i = 0; name_part[i] != '\0'; i++) {
        if (!strchr(valid_chars, toupper(name_part[i]))) {
            return 0;
        }
    }

    // Validar a extensão (se houver)
    for (i = 0; ext_part[i] != '\0'; i++) {
        if (!strchr(valid_chars, toupper(ext_part[i]))) {
            return 0;
        }
    }

    return 1; // Tudo está correto
}

// Função para verificar se um nome de arquivo corresponde ao padrão
unsigned char matches_wildcard(const char *pattern, const char *filename)
{
    while (*pattern && *filename)
    {
        if (*pattern == '*')
        {
            // Avança no padrão e tenta corresponder com todos os sufixos possíveis
            pattern++;

            if (!*pattern)
                return 1; // '*' no final combina com qualquer coisa

            while (*filename)
            {
                if (matches_wildcard(pattern, filename))
                    return 1;

                filename++;
            }
            return 0;
        }
        else if (*pattern == '?' || *pattern == *filename)
        {
            // '?' combina com qualquer caractere ou caracteres iguais
            pattern++;
            filename++;
        }
        else
        {
            return 0;
        }
    }
    // Retorna true se ambos terminarem juntos
    return (!*pattern && !*filename);
}

//-----------------------------------------------------------------------------
// Função principal para filtrar arquivos
//-----------------------------------------------------------------------------
void filter_files(const char *pattern, const char **file_list, int file_count, char **result_list, int *result_count)
{
    int count = 0, i;
    for (i = 0; i < file_count; i++)
    {
        if (matches_wildcard(pattern, file_list[i]))
        {
            result_list[count++] = file_list[i];
        }
    }

    *result_count = count;
}

//-----------------------------------------------------------------------------
unsigned char contains_wildcards(const char *pattern)
{
    while (*pattern)
    {
        if (*pattern == '*' || *pattern == '?')
        {
            return 1;
        }
        pattern++;
    }
    return 0;
}

//-----------------------------------------------------------------------------
unsigned long fsMalloc(unsigned long vMemSize)
{
    unsigned long mMemDef;

    #if defined(USE_MALLOC) || defined(USE_MSMALLOC)    
        if (!vMemSize)
            return 0;

        mMemDef = (unsigned long)malloc(vMemSize);

        if (mMemDef && ((mMemDef + vMemSize - 1) > MMSJ_HEAP_LIMIT))
        {
            free((void *)mMemDef);
            mMemDef = 0;
        }
    #else
        mMemDef = 0;
    #endif
    
    return mMemDef;
}

//-----------------------------------------------------------------------------
void fsFree(unsigned long vAddress)
{
    if (!vAddress)
        return;

    free((void *)vAddress);
}

#ifdef __SO_ST_MFP__
//-----------------------------------------------------------------------------
void fsSetMfp(unsigned int Config, unsigned char Value, unsigned char TypeSet)
{
    if (TypeSet)
        *(vmfp + Config) = Value;
    else
        *(vmfp + Config) |= Value;
}

//-----------------------------------------------------------------------------
unsigned int fsGetMfp(unsigned int Config)
{
    unsigned int retValue;

    retValue = *(vmfp + Config);

    return retValue;
}
#endif

#ifdef USE_MSPRINTF_MMSJOS
//-----------------------------------------------------------------------------
void setColorVideoG2(unsigned char fgcolor, unsigned char bgcolor)
{
    fgcolorMgui = fgcolor;
    bgcolorMgui = bgcolor;
}

//-----------------------------------------------------------------------------
void setModeVideoOS(unsigned char mode)
{
    unsigned char vdpTColor;

    vdpTColor = (VDP_WHITE << 4) | VDP_BLACK;
    vdp_mode = mode;
    vdp_init(mode, vdpTColor, 0, 0);

    if (vdp_mode == VDP_MODE_TEXT)
        vdp_colorize(VDP_WHITE, VDP_BLACK);
    else    
        vdp_set_bdcolor(VDP_BLACK);

    vdp_get_cfg(&mgui_pattern_table, &mgui_color_table);
}

//-----------------------------------------------------------------------------
unsigned char getModeVideoOS(void)
{
    return vdp_mode;
}

//-----------------------------------------------------------------------------
void vdp_set_cursor_pos_G2(unsigned char direction)
{
    unsigned char pMoveId = 1;
    unsigned short videoCursorPosColX;  // Posicao atual do cursor na coluna (0 a 255)
    unsigned short videoCursorPosRowY;  // Posical atual do cursor na linha (0 a 191)
    VDP_COORD vcursor;

    vcursor = vdp_get_cursor_safe();
    videoCursorPosColX = vcursor.x;
    videoCursorPosRowY = vcursor.y; 

    switch (direction)
    {
        case VDP_CSR_UP:
            if (vdp_mode != VDP_MODE_TEXT)
                pMoveId = addrSetFontUseG2.h;
            vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY - pMoveId);
            break;
        case VDP_CSR_DOWN:
            if (vdp_mode != VDP_MODE_TEXT)
                pMoveId = addrSetFontUseG2.h;
            vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY + pMoveId);
            break;
        case VDP_CSR_LEFT:
            if (vdp_mode != VDP_MODE_TEXT)
                pMoveId = addrSetFontUseG2.w;
            vdp_set_cursor(videoCursorPosColX - pMoveId, videoCursorPosRowY);
            break;
        case VDP_CSR_RIGHT:
            if (vdp_mode != VDP_MODE_TEXT)
                pMoveId = addrSetFontUseG2.w;
            vdp_set_cursor(videoCursorPosColX + pMoveId, videoCursorPosRowY);
            break;
    }
}

//-----------------------------------------------------------------------------
void vdp_writeG2(unsigned char chr)
{
    unsigned int name_offset;       // Position in name table
    unsigned int pattern_offset;    // Offset of pattern in pattern table
    char i, ix;
    unsigned short vAntX, vAntY;
    unsigned char *tempFontes = addrSetFontUseG2.addr;
    unsigned long vEndFont, vEndPart;
    unsigned short videoCursorPosColX;  // Posicao atual do cursor na coluna (0 a 255)
    unsigned short videoCursorPosRowY;  // Posical atual do cursor na linha (0 a 191)
    unsigned char fgcolor, bgcolor, vendsizeh;
    VDP_COORD vcursor;
    VDP_COLOR vdpcolor;

    vcursor = vdp_get_cursor_safe();
    videoCursorPosColX = vcursor.x;
    videoCursorPosRowY = vcursor.y; 
    getColorData(&vdpcolor);
    fgcolor = vdpcolor.fg;
    bgcolor = vdpcolor.bg;

    name_offset = videoCursorPosRowY * (vdpMaxCols + 1) + videoCursorPosColX; // Position in name table
    pattern_offset = name_offset << 3;                    // Offset of pattern in pattern table

    if (vdp_mode == VDP_MODE_G2)
    {
        vEndPart = chr - addrSetFontUseG2.fc;
        vEndPart = vEndPart << 3;
        vAntY = videoCursorPosRowY;
        for (i = 0; i < addrSetFontUseG2.h; i++)
        {
            vEndFont = addrSetFontUseG2.addr;
            vEndFont += vEndPart + i;
            tempFontes = vEndFont;
            vAntX = videoCursorPosColX;
            vendsizeh = 8 - addrSetFontUseG2.w;
            for (ix = 7; ix >=vendsizeh; ix--)
            {
                vdp_plot_hires(videoCursorPosColX, videoCursorPosRowY, ((*tempFontes >> ix) & 0x01) ? fgcolor : 0, bgcolor);
                videoCursorPosColX = videoCursorPosColX + 1;
            }
            videoCursorPosColX = vAntX;
            videoCursorPosRowY = videoCursorPosRowY + 1;
        }
        videoCursorPosRowY = vAntY;
    }
    else if (vdp_mode == VDP_MODE_MULTICOLOR)
    {
        vEndPart = chr - addrSetFontUseG2.fc;
        vEndPart = vEndPart << 3;
        vAntY = videoCursorPosRowY;
        for (i = 0; i < addrSetFontUseG2.h; i++)
        {
            vEndFont = addrSetFontUseG2.addr;
            vEndFont += vEndPart + i;
            tempFontes = vEndFont;
            vAntX = videoCursorPosColX;
            vendsizeh = 8 - addrSetFontUseG2.w;
            for (ix = 7; ix >=vendsizeh; ix--)
            {
                vdp_plot_color(videoCursorPosColX, videoCursorPosRowY, ((*tempFontes >> ix) & 0x01) ? fgcolor : bgcolor);
                videoCursorPosColX = videoCursorPosColX + 1;
            }
            videoCursorPosColX = vAntX;
            videoCursorPosRowY = videoCursorPosRowY + 1;
        }
        videoCursorPosRowY = vAntY;
    }
}

//-----------------------------------------------------------------------------
void printCharG2(unsigned char pchr, unsigned char pmove)
{
    unsigned short videoCursorPosColX;  // Posicao atual do cursor na coluna (0 a 255)
    unsigned short videoCursorPosRowY;  // Posical atual do cursor na linha (0 a 191)
    unsigned char fgcolor, bgcolor;
    VDP_COORD vcursor;
    VDP_COLOR vdpcolor;

    vcursor = vdp_get_cursor_safe();
    videoCursorPosColX = vcursor.x;
    videoCursorPosRowY = vcursor.y; 
    getColorData(&vdpcolor);
    fgcolor = vdpcolor.fg;
    bgcolor = vdpcolor.bg;

    if (vdp_mode == VDP_MODE_TEXT || vdp_mode == VDP_MODE_G1)
    {
        // Usa processo normal com a fonte Default do monitor
        printChar(pchr, pmove);
    }
    else 
    {
        // Usa fonte selecionada
        switch (pchr)
        {
            case 0x0A:  // LF
                if (videoCursorPosRowY + 1 == 24)
                    printChar(pchr, pmove);    // Pra gerar Scroll, nao tenho acesso ao geraScroll
                else 
                {
                    videoCursorPosRowY = videoCursorPosRowY + 1;
                    vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                }
                break;
            case 0x0D:  // CR
                videoCursorPosColX = 0;
                vdp_set_cursor(0, videoCursorPosRowY);
                break;
            case 0x08:  // BackSpace
                if (videoCursorPosColX > 0)
                {
                    videoCursorPosColX = videoCursorPosColX - 1;
                    vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                }
                break;
            case 0xFF:  // Cursor
                vdp_write_gui(0xFE);
                break;
            default:
                vdp_write_gui(pchr);

                if (vdp_mode == VDP_MODE_TEXT)
                    vdp_colorize(fgcolor, bgcolor);

                if (pmove)
                {
                    vdp_set_cursor_pos_G2(VDP_CSR_RIGHT);

                    if (vdp_mode == VDP_MODE_TEXT && videoCursorPosRowY == 24)
                    {
                        videoCursorPosRowY = 23;
                        printChar(0x0A, pmove);    // Pra gerar Scroll, nao tenho acesso ao geraScroll
                    }
                }
        }
    }
}

//-----------------------------------------------------------------------------
void msprintf_puts(char **dst, char *s)
{
    if (!s)
        s = "(null)";

    while (*s)
    {
        **dst = *s;
        (*dst)++;
        s++;
    }
}

//-----------------------------------------------------------------------------
void msprintf_ulong_hex(char **dst, unsigned long v)
{
    char tmp[8];
    int n;
    int d;

    n = 0;

    if (v == 0)
    {
        **dst = '0';
        (*dst)++;
        return;
    }

    while (v && n < 8)
    {
        d = (int)(v & 0x0F);
        tmp[n++] = d < 10 ? '0' + d : 'A' + d - 10;
        v >>= 4;
    }

    while (n > 0)
    {
        **dst = tmp[--n];
        (*dst)++;
    }
}

//-----------------------------------------------------------------------------
void msprintf_ulong_dec(char **dst, unsigned long v)
{
    unsigned long divs[10];
    int i;
    int started;
    unsigned char digit;

    divs[0] = 1000000000UL;
    divs[1] = 100000000UL;
    divs[2] = 10000000UL;
    divs[3] = 1000000UL;
    divs[4] = 100000UL;
    divs[5] = 10000UL;
    divs[6] = 1000UL;
    divs[7] = 100UL;
    divs[8] = 10UL;
    divs[9] = 1UL;

    started = 0;

    for (i = 0; i < 10; i++)
    {
        digit = 0;

        while (v >= divs[i])
        {
            v -= divs[i];
            digit++;
        }

        if (digit || started || i == 9)
        {
            **dst = (char)('0' + digit);
            (*dst)++;
            started = 1;
        }
    }
}

//-----------------------------------------------------------------------------
void msprintf_long_dec(char **dst, long v)
{
    unsigned long u;

    if (v < 0)
    {
        **dst = '-';
        (*dst)++;

        u = (unsigned long)(-(v + 1));
        u++;
    }
    else
    {
        u = (unsigned long)v;
    }

    msprintf_ulong_dec(dst, u);
}

//-----------------------------------------------------------------------------
void msprintf(char *buffer, const char *fmt, ...)
{
    va_list ap;
    char *dst;
    char *s;
    int ival;
    long lval;
    unsigned long ulval;

    dst = buffer;

    va_start(ap, fmt);

    while (*fmt)
    {
        if (*fmt != '%')
        {
            *dst++ = *fmt++;
            continue;
        }

        fmt++;

        if (*fmt == 0)
            break;

        switch (*fmt)
        {
            case 's':
                s = va_arg(ap, char *);
                msprintf_puts(&dst, s);
                break;

            case 'c':
                ival = va_arg(ap, int);
                *dst++ = (char)ival;
                break;

            case 'd':
            case 'i':
                ival = va_arg(ap, int);
                msprintf_long_dec(&dst, (long)ival);
                break;

            case 'u':
                ulval = (unsigned long)va_arg(ap, unsigned int);
                msprintf_ulong_dec(&dst, ulval);
                break;

            case 'x':
            case 'X':
                ulval = (unsigned long)va_arg(ap, unsigned int);
                msprintf_ulong_hex(&dst, ulval);
                break;

            case 'l':
                fmt++;

                if (*fmt == 'd' || *fmt == 'i')
                {
                    lval = va_arg(ap, long);
                    msprintf_long_dec(&dst, lval);
                }
                else if (*fmt == 'u')
                {
                    ulval = va_arg(ap, unsigned long);
                    msprintf_ulong_dec(&dst, ulval);
                }
                else if (*fmt == 'x' || *fmt == 'X')
                {
                    ulval = va_arg(ap, unsigned long);
                    msprintf_ulong_hex(&dst, ulval);
                }
                else
                {
                    *dst++ = '%';
                    *dst++ = 'l';

                    if (*fmt)
                        *dst++ = *fmt;
                }
                break;

            case '%':
                *dst++ = '%';
                break;

            default:
                *dst++ = '%';
                *dst++ = *fmt;
                break;
        }

        fmt++;
    }

    *dst = 0;

    va_end(ap);
}

//-----------------------------------------------------------------------------
void mprintf_ulong_dec(unsigned long v)
{
    unsigned long divs[10];
    int i;
    int started;
    unsigned char digit;

    divs[0] = 1000000000UL;
    divs[1] = 100000000UL;
    divs[2] = 10000000UL;
    divs[3] = 1000000UL;
    divs[4] = 100000UL;
    divs[5] = 10000UL;
    divs[6] = 1000UL;
    divs[7] = 100UL;
    divs[8] = 10UL;
    divs[9] = 1UL;

    started = 0;

    for (i = 0; i < 10; i++)
    {
        digit = 0;

        while (v >= divs[i])
        {
            v -= divs[i];
            digit++;
        }

        if (digit || started || i == 9)
        {
            printCharG2('0' + digit, 1);
            started = 1;
        }
    }
}

//-----------------------------------------------------------------------------
void mprintf_long_dec(long v)
{
    unsigned long u;

    if (v < 0)
    {
        printCharG2('-', 1);

        u = (unsigned long)(-(v + 1));
        u++;
    }
    else
    {
        u = (unsigned long)v;
    }

    mprintf_ulong_dec(u);
}

//-----------------------------------------------------------------------------
void mprintf_ulong_hex(unsigned long v)
{
    char tmp[8];
    int n;
    int d;

    n = 0;

    if (v == 0)
    {
        printCharG2('0', 1);
        return;
    }

    while (v && n < 8)
    {
        d = (int)(v & 0x0F);

        if (d < 10)
            tmp[n] = (char)('0' + d);
        else
            tmp[n] = (char)('A' + d - 10);

        n++;
        v = v >> 4;
    }

    while (n > 0)
    {
        n--;
        printCharG2(tmp[n], 1);
    }
}

//-----------------------------------------------------------------------------
void mprintf(const char *fmt, ...)
{
    va_list ap;
    int v, ival;
    long lval;
    unsigned long ulval;
    char *s;
    char c;

    va_start(ap, fmt);

    while (*fmt)
    {
        if (*fmt != '%')
        {
            printCharG2(*fmt, 1);
            fmt++;
            continue;
        }

        fmt++;

        if (*fmt == 0)
            break;

        switch (*fmt)
        {
            case 's':
                s = va_arg(ap, char *);

                if (!s)
                    s = "(null)";

                while (*s)
                {
                    printCharG2(*s, 1);
                    s++;
                }
                break;

            case 'c':
                v = va_arg(ap, int);
                printCharG2((char)v, 1);
                break;

            case 'd':
            case 'i':
                ival = va_arg(ap, int);
                mprintf_long_dec((long)ival);
                break;

            case 'u':
                ulval = (unsigned long)va_arg(ap, unsigned int);
                mprintf_ulong_dec(ulval);
                break;

            case 'x':
            case 'X':
            {
                unsigned long u;
                char tmp[9];
                int n = 0;
                int d;

                u = (unsigned long)va_arg(ap, unsigned int);

                if (u == 0)
                {
                    printCharG2('0', 1);
                    break;
                }

                while (u)
                {
                    d = (int)(u & 0x0F);

                    if (d < 10)
                        tmp[n++] = (char)('0' + d);
                    else
                        tmp[n++] = (char)('A' + d - 10);

                    u >>= 4;
                }

                while (n > 0)
                    printCharG2(tmp[--n], 1);
                break;
            }
            case 'l':
                fmt++;

                if (*fmt == 'd' || *fmt == 'i')
                {
                    lval = va_arg(ap, long);
                    mprintf_long_dec(lval);
                }
                else if (*fmt == 'u')
                {
                    ulval = va_arg(ap, unsigned long);
                    mprintf_ulong_dec(ulval);
                }
                else if (*fmt == 'x' || *fmt == 'X')
                {
                    ulval = va_arg(ap, unsigned long);
                    mprintf_ulong_hex(ulval);
                }
                else
                {
                    printCharG2('%', 1);
                    printCharG2('l', 1);

                    if (*fmt)
                        printCharG2(*fmt, 1);
                }
                break;
            case '%':
                printCharG2('%', 1);
                break;

            default:
                printCharG2('%', 1);
                printCharG2(*fmt, 1);
                break;
        }

        fmt++;
    }

    va_end(ap);
}
#endif

//-----------------------------------------------------------------------------
int getFontUseG2(MGUI_SET_FONT *fonInfo)
{
    if (addrSetFontUseG2.name[0] == 0x00)
        return 0;   // Fonte nao encontrada

    strcpy(fonInfo->name, addrSetFontUseG2.name);
    fonInfo->fc = addrSetFontUseG2.fc;
    fonInfo->lc = addrSetFontUseG2.lc;
    fonInfo->w  = addrSetFontUseG2.w;
    fonInfo->h  = addrSetFontUseG2.h;
    fonInfo->addr = addrSetFontUseG2.addr;

    return 1;
}

//-----------------------------------------------------------------------------
int setFontUseG2(unsigned char vpos)
{
    if (vpos == 99)
    {
        strcpy(addrSetFontUseG2.name, "DEFAULT");
        addrSetFontUseG2.fc = 32;
        addrSetFontUseG2.lc = 255;
        addrSetFontUseG2.w  = 6;
        addrSetFontUseG2.h  = 8;
        addrSetFontUseG2.addr = getVideoFontes();
    }
    else
    {
        if (listFontsUseG2[vpos].name[0] == 0x00)
            return 0;   // Fonte nao encontrada

        strcpy(addrSetFontUseG2.name, listFontsUseG2[vpos].name);
        addrSetFontUseG2.fc   = listFontsUseG2[vpos].fc;
        addrSetFontUseG2.lc   = listFontsUseG2[vpos].lc;
        addrSetFontUseG2.w    = listFontsUseG2[vpos].w;
        addrSetFontUseG2.h    = listFontsUseG2[vpos].h;
        addrSetFontUseG2.addr = listFontsUseG2[vpos].addr;
    }

    return 1;
}

//-----------------------------------------------------------------------------
int loadFontUseG2(unsigned char vpos, unsigned char *fileName, unsigned char *bufLoad, unsigned char *bufSave)
{
    unsigned long cfgSize;
    long isizelastfont;
    int ix, iz;
    FON_INFO fi;
    unsigned char sqtdtam[20];

    // Carrega a fonte usando o nome completo (com caminho) para carregar a fonte na memoria. O loop para quando encontra
    cfgSize = loadFile(fileName, bufLoad);

    isizelastfont = vpos * 2053; // Cada fonte ocupa 2053 bytes (5 bytes de header + 256 chars * 8 bytes por char)

    // Processa a fonte, pegando os principais dados (altura, largura, etc) e depois copiando os dados da fonte para o local correto na memoria de fontes de video (bufSave), usando o formato necessario para as rotinas de desenho de texto do MGUI. O loop para quando encontra
    if (cfgSize && !readFontStruct(bufLoad, cfgSize, &fi))
    {
        // Somente Aceita Fontes no maximo 8x8 pixels por caracter
        if (fi.dfPixWidth > 8 || fi.dfPixHeight > 8)
            return 1;

        // Grava cabecalho
        *(bufSave + isizelastfont) = 0x00;
        *(bufSave + isizelastfont + 1) = 0;                       // First Char
        *(bufSave + isizelastfont + 2) = 255;                     // Last Char
        *(bufSave + isizelastfont + 3) = fi.dfPixWidth & 0xFF;    // Width
        *(bufSave + isizelastfont + 4) = fi.dfPixHeight & 0xFF;   // Height
        isizelastfont += 5;

        // Guarda Lista Carregada
        strcpy(listFontsUseG2[vpos].name, fi.fontName);                
        listFontsUseG2[vpos].fc = 0;
        listFontsUseG2[vpos].lc = 255;
        listFontsUseG2[vpos].w  = fi.dfPixWidth & 0xFF;
        listFontsUseG2[vpos].h  = fi.dfPixHeight & 0xFF;
        listFontsUseG2[vpos].addr = (bufSave + isizelastfont);

        // Se nao comeca no 0, coloca zeros até o primeiro
        if (fi.dfFirstChar > 0)
        {
            for (ix = 0; ix < fi.dfFirstChar; ix++)
            {
                // Copia os dados de cada char da fonte para o local correto na memoria de fontes de video (bufSave), usando o formato necessario para as rotinas de desenho de texto do MGUI. O loop para quando encontra
                for (iz = 0; iz < 8; iz++)
                    *(bufSave + ((ix * 8) + iz + isizelastfont)) = 0x00;
            }
        }

        // Copia caracteres
        for (ix = fi.dfFirstChar; ix <= fi.dfLastChar; ix++)
        {
            for (iz = 0; iz < 8; iz++)
            {
                *(bufSave + ((ix * 8) + iz + isizelastfont)) = *(bufLoad + (fi.bitsFileOffset + (ix * 8) + iz));
            }
        }

        // Se nao termina no 255, coloca zeros até o 255
        if (fi.dfLastChar < 255)
        {
            for (ix = fi.dfLastChar + 1; ix <= 255; ix++)
            {
                // Copia os dados de cada char da fonte para o local correto na memoria de fontes de video (bufSave), usando o formato necessario para as rotinas de desenho de texto do MGUI. O loop para quando encontra
                for (iz = 0; iz < 8; iz++)
                    *(bufSave + ((ix * 8) + iz + isizelastfont)) = 0x00;
            }
        }
    }
    else
        return 2;
    
    return 0;
}

//-----------------------------------------------------------------------------
int readFontStruct(unsigned char *file, unsigned long fileSize, FON_INFO *info)
{
    unsigned long neOffset;
    unsigned long resTable;
    unsigned int alignShift;
    unsigned long p;
    unsigned int typeId;
    unsigned int count;
    unsigned long i;

    unsigned int rnOffset;
    unsigned int rnLength;
    unsigned long realOffset;
    unsigned long realLength;

    unsigned char *fnt;

    memset(info, 0, sizeof(FON_INFO));

    if (fileSize < 0x40)
        return 1;

    if (file[0] != 'M' || file[1] != 'Z')
        return 2;

    neOffset = rd32(file + 0x3C);

    if (neOffset + 0x40 >= fileSize)
        return 3;

    if (file[neOffset] != 'N' || file[neOffset + 1] != 'E')
        return 4;

    /*
       NE + 0x24 = offset da Resource Table,
       relativo ao começo do NE.
    */
    resTable = neOffset + rd16(file + neOffset + 0x24);

    if (resTable + 2 >= fileSize)
        return 5;

    alignShift = rd16(file + resTable);
    p = resTable + 2;

    info->alignShift = alignShift;

    while (p + 8 < fileSize)
    {
        typeId = rd16(file + p);
        p += 2;

        if (typeId == 0x0000)
            break;

        count = rd16(file + p);
        p += 2;

        /*
           DWORD reserved
        */
        p += 4;

        for (i = 0; i < count; i++)
        {
            if (p + 12 > fileSize)
                return 6;

            rnOffset = rd16(file + p + 0);
            rnLength = rd16(file + p + 2);

            realOffset = ((unsigned long)rnOffset) << alignShift;
            realLength = ((unsigned long)rnLength) << alignShift;

            if (typeId == RT_FONT)
            {
                if (realOffset + realLength > fileSize)
                    return 0;

                info->fonFileOffset = realOffset;
                info->fonFileSize   = realLength;

                info->fntOffset = realOffset;
                info->fntSize   = realLength;

                fnt = file + realOffset;

                /*
                   Header FNT Windows 2.x/3.x bitmap.
                   Offsets relativos ao começo do FNT.
                */
                info->dfVersion     = rd16(fnt + 0x00);
                info->dfSize        = rd32(fnt + 0x02);

                info->dfPixWidth    = rd16(fnt + 0x56);
                info->dfPixHeight   = rd16(fnt + 0x58);
                info->dfMaxWidth    = rd16(fnt + 0x5D);

                info->dfFirstChar   = fnt[0x5F];
                info->dfLastChar    = fnt[0x60];
                info->dfDefaultChar = fnt[0x61];
                info->dfBreakChar   = fnt[0x62];

                info->dfWidthBytes  = rd16(fnt + 0x63);

                info->dfDevice = rd32(fnt + 0x65);
                info->dfFace   = rd32(fnt + 0x69);

                info->dfBitsOffset  = rd32(fnt + 0x71);
                info->bitsFileOffset = realOffset + info->dfBitsOffset;

                {
                    int n;
                    unsigned char *name;

                    info->fontName[0] = 0;

                    if (info->dfFace != 0 && info->dfFace < realLength)
                    {
                        name = fnt + info->dfFace;

                        for (n = 0; n < 19; n++)
                        {
                            if (info->dfFace + n >= realLength)
                                break;

                            if (name[n] == 0)
                                break;

                            info->fontName[n] = name[n];
                        }

                        info->fontName[n] = 0;
                    }
                }                

                if (info->bitsFileOffset >= fileSize)
                    return 7;

                return 0;
            }

            p += 12;
        }
    }

    return 9;
}

//-----------------------------------------------------------------------------
void fsListDir(FILES_DIR * dir, unsigned char *param)
{
    unsigned char vcont, ikk, ix, iy, cc, dd, ee, cnum[20];
    unsigned char vnomefile[32], dsize;
    unsigned char vname[20], sqtdtam[20], cuntam, errorName;
    unsigned long vtotbytes = 0, vqtdtam;
    unsigned char vrettype = 0, logwildcard = 0, logpath;
    unsigned long vclusterdiratu;
    unsigned int dFileCursor, vPosDir;
    FILES_DIR ddir;
    FAT32_DIR vdirfiles;

    // Leitura dos Arquivos
    dFileCursor = 0;
    dsize = sizeof(FILES_DIR);
    vPosDir = 0;
    dir[0].Name[0] = '\0';

    // Acessa Pasta a ser listada
    vclusterdiratu = vclusterdir;

    if (param[0] > 0x20)
    {
        // Acha o caminho final
        vrettype = fsFindDirPath(param, FIND_PATH_LAST);

        // Verifica se tem wildcard
        logwildcard = contains_wildcards(vretpath.Name);

        // Verifica Erro
        if (vrettype == FIND_PATH_RET_ERROR && !logwildcard)
            return;

        vclusterdir = vretpath.ClusterDir;
    }
    else
        vrettype = FIND_PATH_RET_FOLDER;

    // Logica de leitura Diretorio FAT32
    if (fsFindInDir(NULL, TYPE_FIRST_ENTRY) < ERRO_D_START)
    {
        while (1)
        {
            fsGetDirAtuData(&vdirfiles);

            if (1 /*vdirfiles.Attr != ATTR_VOLUME*/)
            {
                // Nome
                errorName = 0;
                for (cc = 0; cc <= 7; cc++)
                {
                    ddir.Name[cc] = 0x00;
                    if (vdirfiles.Name[cc] > 32 && vdirfiles.Name[cc] <= 127 )
                    {
                        ddir.Name[cc] = vdirfiles.Name[cc];
                    }
                    else if (vdirfiles.Name[cc] != 32)
                        errorName = 1;
                }

                ddir.Name[8] = '\0';

                // Extensao
                for (cc = 0; cc <= 2; cc++)
                {
                    ddir.Ext[cc] = 0x00;
                    if (vdirfiles.Ext[cc] > 32 && vdirfiles.Ext[cc] <= 127)
                    {
                        ddir.Ext[cc] = vdirfiles.Ext[cc];
                    }
                    else if (vdirfiles.Ext[cc] != 32)
                        errorName = 1;
                }

                ddir.Ext[3] = '\0';

                if (!errorName)
                {
                    strcpy(vname, ddir.Name);
                    strcat(vname, ".");
                    strcat(vname, ddir.Ext);
                    if (vrettype != FIND_PATH_RET_FOLDER && !matches_wildcard(vretpath.Name, vname))
                        errorName = 1;                     
                }

                if (!errorName)
                {
                    // Data Ultima Modificacao
                    // Mes
                    vqtdtam = (vdirfiles.UpdateDate & 0x01E0) >> 5;
                    if (vqtdtam < 1 || vqtdtam > 12)
                        vqtdtam = 1;

                    vqtdtam--;

                    if (vqtdtam < 1  && vqtdtam > 12)
                        vqtdtam = 1;

                    ddir.Modify[0] = vmesc[vqtdtam][0];
                    ddir.Modify[1] = vmesc[vqtdtam][1];
                    ddir.Modify[2] = vmesc[vqtdtam][2];
                    ddir.Modify[3] = '/';

                    // Dia
                    vqtdtam = vdirfiles.UpdateDate & 0x001F;
                    memset(sqtdtam, 0x0, 10);
                    itoa(vqtdtam, sqtdtam, 10);

                    if (vqtdtam < 10) {
                        ddir.Modify[4] = '0';
                        ddir.Modify[5] = sqtdtam[0];
                    }
                    else {
                        ddir.Modify[4] = sqtdtam[0];
                        ddir.Modify[5] = sqtdtam[1];
                    }
                    ddir.Modify[6] = '/';

                    // Ano
                    vqtdtam = ((vdirfiles.UpdateDate & 0xFE00) >> 9) + 1980;
                    memset(sqtdtam, 0x0, 10);
                    itoa(vqtdtam, sqtdtam, 10);

                    ddir.Modify[7] = sqtdtam[0];
                    ddir.Modify[8] = sqtdtam[1];
                    ddir.Modify[9] = sqtdtam[2];
                    ddir.Modify[10] = sqtdtam[3];

                    ddir.Modify[11] = '\0';

                    // Tamanho
                    if (vdirfiles.Attr != ATTR_DIRECTORY) {
                        // Reduz o tamanho a unidade (GB, MB ou KB)
                        vqtdtam = vdirfiles.Size;

                        if ((vqtdtam & 0xC0000000) != 0) {
                            cuntam = 'G';
                            vqtdtam = ((vqtdtam & 0xC0000000) >> 30) + 1;
                        }
                        else if ((vqtdtam & 0x3FF00000) != 0) {
                            cuntam = 'M';
                            vqtdtam = ((vqtdtam & 0x3FF00000) >> 20) + 1;
                        }
                        else if ((vqtdtam & 0x000FFC00) != 0) {
                            cuntam = 'K';
                            vqtdtam = ((vqtdtam & 0x000FFC00) >> 10) + 1;
                        }
                        else
                            cuntam = ' ';

                        // Transforma para decimal
                        memset(sqtdtam, 0x0, 10);
                        itoa(vqtdtam, sqtdtam, 10);

                        // Primeira Parte da Linha do dir, tamanho
                        for(ix = 0; ix <= 3; ix++) {
                            if (sqtdtam[ix] == 0)
                                break;
                        }

                        iy = (4 - ix);

                        for(ix = 0; ix <= 3; ix++) {
                            if (iy <= ix) {
                                ikk = ix - iy;
                                ddir.Size[ix] = sqtdtam[ikk];
                            }
                            else
                                ddir.Size[ix] = ' ';
                        }

                        ddir.Size[ix] = cuntam;
                    }
                    else {
                        ddir.Size[0] = ' ';
                        ddir.Size[1] = ' ';
                        ddir.Size[2] = ' ';
                        ddir.Size[3] = ' ';
                        ddir.Size[4] = '0';
                    }

                    ddir.Size[5] = '\0';

                    // Atributos
                    if (vdirfiles.Attr == ATTR_DIRECTORY) {
                        ddir.Attr[0] = '<';
                        ddir.Attr[1] = 'D';
                        ddir.Attr[2] = 'I';
                        ddir.Attr[3] = 'R';
                        ddir.Attr[4] = '>';
                    }
                    else if (vdirfiles.Attr == ATTR_VOLUME) {
                        ddir.Attr[0] = '<';
                        ddir.Attr[1] = 'V';
                        ddir.Attr[2] = 'O';
                        ddir.Attr[3] = 'L';
                        ddir.Attr[4] = '>';
                    }
                    else {
                        ddir.Attr[0] = ' ';
                        ddir.Attr[1] = ' ';
                        ddir.Attr[2] = ' ';
                        ddir.Attr[3] = ' ';
                        ddir.Attr[4] = ' ';
                    }

                    ddir.Attr[5] = '\0';

                    if (dFileCursor >= 32)
                        break;

                    strcpy(dir[dFileCursor].Name, ddir.Name);
                    strcpy(dir[dFileCursor].Ext, ddir.Ext);
                    strcpy(dir[dFileCursor].Modify, ddir.Modify);
                    strcpy(dir[dFileCursor].Size, ddir.Size);
                    strcpy(dir[dFileCursor].Attr, ddir.Attr);
                    dir[dFileCursor].Attr[5] = 0x00;

                    //dir[dFileCursor] = ddir;
                    vPosDir = dFileCursor;
                    dFileCursor = dFileCursor + 1;
                    dir[dFileCursor].Name[0] = '\0';
                }
            }

            // Verifica se tem mais Arquivos
			for (ix = 0; ix <= 7; ix++) {
			    vnomefile[ix] = vdirfiles.Name[ix];
				if (vnomefile[ix] == 0x20) {
					vnomefile[ix] = '\0';
					break;
			    }
			}

			vnomefile[ix] = '\0';

			if (vdirfiles.Name[0] != '.') {
			    vnomefile[ix] = '.';
			    ix++;
				for (iy = 0; iy <= 2; iy++) {
				    vnomefile[ix] = vdirfiles.Ext[iy];
					if (vnomefile[ix] == 0x20) {
						vnomefile[ix] = '\0';
						break;
				    }
				    ix++;
				}
				vnomefile[ix] = '\0';
			}

			if (fsFindInDir(vnomefile, TYPE_NEXT_ENTRY) >= ERRO_D_START)
				break;
        }
    }

    vclusterdir = vclusterdiratu;
}
