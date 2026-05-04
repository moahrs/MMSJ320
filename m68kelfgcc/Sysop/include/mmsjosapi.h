#ifndef MMSJOSAPI_H
#define MMSJOSAPI_H

// Function Shared Definitions
#define MMSJOS_FUNC_TABLE    0x00800034
#define MGUI_FUNC_TABLE      0x00803B24
#define MMSJOS_UCOSII_TABLE  0x0080D2D0

// MMSJOS Struct for Functions
typedef unsigned char (*fsGetDirAtuDataType)(FAT32_DIR *pDir);
typedef void (*fsSetClusterDirType)(unsigned long vclusdiratu);
typedef unsigned long (*fsGetClusterDirType)(void);
typedef unsigned char (*fsSectorWriteType)(unsigned long vsector, unsigned char* vbuffer, unsigned char vtipo);
typedef unsigned char (*fsSectorReadType)(unsigned long vsector, unsigned char* vbuffer);
typedef unsigned char (*fsFindDirPathType)(char * vpath, char vtype);
typedef unsigned long (*fsOsCommandType)(unsigned char * linhaParametro);
typedef unsigned char (*fsCreateFileType)(char * vfilename);
typedef unsigned char (*fsOpenFileType)(char * vfilename);
typedef unsigned char (*fsCloseFileType)(char * vfilename, unsigned char vupdated);
typedef unsigned long (*fsInfoFileType)(char * vfilename, unsigned char vtype);
typedef unsigned char (*msprintfType)(unsigned long vAddress);
typedef unsigned short (*fsReadFileType)(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer);
typedef unsigned char (*fsWriteFileType)(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer);
typedef unsigned char (*fsDelFileType)(char * vfilename);
typedef unsigned char (*fsRenameFileType)(char * vfilename, char * vnewname);
typedef unsigned long (*loadFileType)(unsigned char *parquivo, void* xaddress);
typedef unsigned char (*fsMakeDirType)(char * vdirname);
typedef unsigned char (*fsChangeDirType)(char * vdirname);
typedef unsigned char (*fsRemoveDirType)(char * vdirname);
typedef unsigned char (*fsPwdDirType)(unsigned char *vdirpath);
typedef unsigned long (*fsFindInDirType)(char * vname, unsigned char vtype);
typedef unsigned long (*mmsjKeyGetType)(MMSJ_KEYEVENT *k);
typedef unsigned long (*fsFindNextClusterType)(unsigned long vclusteratual, unsigned char vtype);
typedef unsigned long (*fsFindClusterFreeType)(unsigned char vtype);
typedef unsigned char (*OSTimeDlyHMSMType)(unsigned char hours, unsigned char minutes, unsigned char seconds, unsigned int ms);
typedef unsigned char (*OSTaskSuspendType)(unsigned char prio);
typedef unsigned char (*OSTaskResumeType)(unsigned char prio);

// MGUI Struct for Functions
typedef void (*writesxyType)(unsigned short x, unsigned short y, unsigned char sizef, unsigned char *msgs, unsigned short pcolor, unsigned short pbcolor);
typedef void (*writecxyType)(unsigned char sizef, unsigned char pbyte, unsigned short pcolor, unsigned short pbcolor);
typedef void (*locatexyType)(unsigned short xx, unsigned short yy);
typedef void (*SaveScreenNewType)(MGUI_SAVESCR *mguiSave, unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
typedef void (*RestoreScreenType)(MGUI_SAVESCR *mguiSave);
typedef void (*SetDotType)(unsigned short x, unsigned short y, unsigned short color);
typedef void (*SetByteType)(unsigned short ix, unsigned short iy, unsigned char pByte, unsigned short pfcolor, unsigned short pbcolor);
typedef void (*FillRectType)(unsigned char xi, unsigned char yi, unsigned short pwidth, unsigned char pheight, unsigned char pcor);
typedef void (*DrawLineType)(unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2, unsigned short color);
typedef void (*DrawRectType)(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight, unsigned short color);
typedef void (*DrawRoundRectType)(unsigned int xi, unsigned int yi, unsigned int pwidth, unsigned int pheight, unsigned char radius, unsigned char color);
typedef void (*DrawCircleType)(unsigned short x0, unsigned short y0, unsigned char r, unsigned char pfil, unsigned short pcor);
typedef void (*PutIconeType)(unsigned int* vimage, unsigned short x, unsigned short y, unsigned char numSprite);
typedef void (*InvertRectType)(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
typedef void (*SelRectType)(unsigned short x, unsigned short y, unsigned short pwidth, unsigned short pheight);
typedef void (*PutImageType)(unsigned char* cimage, unsigned short x, unsigned short y);
typedef void (*runFromMGUIType)(unsigned long vEnderExec);
typedef unsigned char (*waitButtonType)(void);
typedef unsigned char (*messageType)(char* bstr, unsigned char bbutton, unsigned short btime);
typedef void (*drawButtonsnewType)(unsigned char *vbuttons, unsigned char *pbbutton, unsigned short xib, unsigned short yib);
typedef void (*showWindowType)(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton);
typedef void (*TrocaSpriteMouseType)(unsigned char vicone);
typedef void (*MostraIconeType)(unsigned short xi, unsigned short yi, unsigned char vicone, unsigned char colorfg, unsigned char colorbg);
typedef char (*mguiCfgGetType)(char *section, char *key, char *vOutBuf, unsigned char vOutMax);
typedef void (*putImagePbmP4Type)(unsigned long* memoria, unsigned short ix, unsigned short iy);
typedef void (*setPosPressedType)(unsigned char vppostx, unsigned char vpposty);
typedef void (*getMouseDataType)(char ptipo, MGUI_MOUSE *pmouseData);
typedef void (*toggleboxType)(unsigned char id, unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
typedef void (*radiosetType)(unsigned char id, unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
typedef void (*fillinType)(unsigned char id, unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo);
typedef void (*getColorDataType)(MGUI_COLOR *pColor);
typedef unsigned char (*buttonType)(unsigned char id, unsigned char* title, unsigned short xib, unsigned short yib, unsigned short pwidth, unsigned short height, unsigned char vtipo);

// MMSJOS UCOSII Struct for Functions
typedef void *(*msmallocType)(unsigned long size);
typedef void *(*msreallocType)(void *ptr, unsigned long newSize);
typedef void (*msfreeType)(void *ptr);
typedef int (*loadMbinAndRunType)(char *filename, char porig);

// MMSJOS define functions
#define fsGetDirAtuData ((fsGetDirAtuDataType *)(unsigned long)MMSJOS_FUNC_TABLE)[0] // Índice da função
#define fsSetClusterDir ((fsSetClusterDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[1] // Índice da função
#define fsGetClusterDir ((fsGetClusterDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[2] // Índice da função
#define fsSectorWrite ((fsSectorWriteType *)(unsigned long)MMSJOS_FUNC_TABLE)[3] // Índice da função
#define fsSectorRead ((fsSectorReadType *)(unsigned long)MMSJOS_FUNC_TABLE)[4] // Índice da função
#define fsFindDirPath ((fsFindDirPathType *)(unsigned long)MMSJOS_FUNC_TABLE)[5] // Índice da função
#define fsOsCommand ((fsOsCommandType *)(unsigned long)MMSJOS_FUNC_TABLE)[6] // Índice da função
#define fsCreateFile ((fsCreateFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[7] // Índice da função
#define fsOpenFile ((fsOpenFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[8] // Índice da função
#define fsCloseFile ((fsCloseFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[9] // Índice da função
#define fsInfoFile ((fsInfoFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[10] // Índice da função
#define msprintf ((msprintfType *)(unsigned long)MMSJOS_FUNC_TABLE)[11] // Índice da função
#define fsReadFile ((fsReadFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[12] // Índice da função
#define fsWriteFile ((fsWriteFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[13] // Índice da função
#define fsDelFile ((fsDelFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[14] // Índice da função
#define fsRenameFile ((fsRenameFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[15] // Índice da função
#define loadFile ((loadFileType *)(unsigned long)MMSJOS_FUNC_TABLE)[16] // Índice da função
#define fsMakeDir ((fsMakeDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[17] // Índice da função
#define fsChangeDir ((fsChangeDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[18] // Índice da função
#define fsRemoveDir ((fsRemoveDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[19] // Índice da função
#define OSTimeDlyHMSM ((OSTimeDlyHMSMType *)(unsigned long)MMSJOS_FUNC_TABLE)[20] // Índice da função
#define fsFindInDir ((fsFindInDirType *)(unsigned long)MMSJOS_FUNC_TABLE)[21] // Índice da função
#define mmsjKeyGet ((mmsjKeyGetType *)(unsigned long)MMSJOS_FUNC_TABLE)[22] // Índice da função
#define fsFindNextCluster ((fsFindNextClusterType *)(unsigned long)MMSJOS_FUNC_TABLE)[23] // Índice da função
#define fsFindClusterFree ((fsFindClusterFreeType *)(unsigned long)MMSJOS_FUNC_TABLE)[24] // Índice da função
#define OSTaskSuspend ((OSTaskSuspendType *)(unsigned long)MMSJOS_FUNC_TABLE)[25] // Índice da função
#define OSTaskResume ((OSTaskResumeType *)(unsigned long)MMSJOS_FUNC_TABLE)[26] // Índice da função

// MGUI define functions
#define writesxy ((writesxyType *)(unsigned long)MGUI_FUNC_TABLE)[0] // Índice da função
#define writecxy ((writecxyType *)(unsigned long)MGUI_FUNC_TABLE)[1] // Índice da função
#define locatexy ((locatexyType *)(unsigned long)MGUI_FUNC_TABLE)[2] // Índice da função
#define SaveScreenNew ((SaveScreenNewType *)(unsigned long)MGUI_FUNC_TABLE)[3] // Índice da função
#define RestoreScreen ((RestoreScreenType *)(unsigned long)MGUI_FUNC_TABLE)[4] // Índice da função
#define SetDot ((SetDotType *)(unsigned long)MGUI_FUNC_TABLE)[5] // Índice da função
#define SetByte ((SetByteType *)(unsigned long)MGUI_FUNC_TABLE)[6] // Índice da função
#define FillRect ((FillRectType *)(unsigned long)MGUI_FUNC_TABLE)[7] // Índice da função
#define DrawLine ((DrawLineType *)(unsigned long)MGUI_FUNC_TABLE)[8] // Índice da função
#define DrawRect ((DrawRectType *)(unsigned long)MGUI_FUNC_TABLE)[9] // Índice da função
#define DrawRoundRect ((DrawRoundRectType *)(unsigned long)MGUI_FUNC_TABLE)[10] // Índice da função
#define DrawCircle ((DrawCircleType *)(unsigned long)MGUI_FUNC_TABLE)[11] // Índice da função
#define PutIcone ((PutIconeType *)(unsigned long)MGUI_FUNC_TABLE)[12] // Índice da função
#define InvertRect ((InvertRectType *)(unsigned long)MGUI_FUNC_TABLE)[13] // Índice da função
#define SelRect ((SelRectType *)(unsigned long)MGUI_FUNC_TABLE)[14] // Índice da função
#define fsPwdDir ((fsPwdDirType *)(unsigned long)MGUI_FUNC_TABLE)[15] // Índice da função
#define runFromMGUI ((runFromMGUIType *)(unsigned long)MGUI_FUNC_TABLE)[16] // Índice da função
#define waitButton ((waitButtonType *)(unsigned long)MGUI_FUNC_TABLE)[17] // Índice da função
#define message ((messageType *)(unsigned long)MGUI_FUNC_TABLE)[18] // Índice da função
#define drawButtonsnew ((drawButtonsnewType *)(unsigned long)MGUI_FUNC_TABLE)[19] // Índice da função
#define showWindow ((showWindowType *)(unsigned long)MGUI_FUNC_TABLE)[20] // Índice da função
#define TrocaSpriteMouse ((TrocaSpriteMouseType *)(unsigned long)MGUI_FUNC_TABLE)[21] // Índice da função
#define MostraIcone ((MostraIconeType *)(unsigned long)MGUI_FUNC_TABLE)[22] // Índice da função
#define mguiCfgGet ((mguiCfgGetType *)(unsigned long)MGUI_FUNC_TABLE)[23] // Índice da função
#define putImagePbmP4 ((putImagePbmP4Type *)(unsigned long)MGUI_FUNC_TABLE)[24] // Índice da função
#define setPosPressed ((setPosPressedType *)(unsigned long)MGUI_FUNC_TABLE)[25] // Índice da função
#define getMouseData ((getMouseDataType *)(unsigned long)MGUI_FUNC_TABLE)[26] // Índice da função
#define togglebox ((toggleboxType *)(unsigned long)MGUI_FUNC_TABLE)[27] // Índice da função
#define radioset ((radiosetType *)(unsigned long)MGUI_FUNC_TABLE)[28] // Índice da função
#define fillin ((fillinType *)(unsigned long)MGUI_FUNC_TABLE)[29] // Índice da função
#define getColorData ((getColorDataType *)(unsigned long)MGUI_FUNC_TABLE)[30] // Índice da função
#define button ((buttonType *)(unsigned long)MGUI_FUNC_TABLE)[31] // Índice da função

// MMSJOS UCOSII define Functions
#define msmalloc ((msmallocType *)(unsigned long)MMSJOS_UCOSII_TABLE)[0] // Índice da função
#define msrealloc ((msreallocType *)(unsigned long)MMSJOS_UCOSII_TABLE)[1] // Índice da função
#define msfree ((msfreeType *)(unsigned long)MMSJOS_UCOSII_TABLE)[2] // Índice da função
#define loadMbinAndRun ((loadMbinAndRunType *)(unsigned long)MMSJOS_UCOSII_TABLE)[3] // Índice da função

// Apoio
const unsigned char strValidChars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^&'@{}[],$=!-#()%.+~_";

const unsigned char vmesc[12][3] = {{'J','a','n'},{'F','e','b'},{'M','a','r'},
                                    {'A','p','r'},{'M','a','y'},{'J','u','n'},
                                    {'J','u','l'},{'A','u','g'},{'S','e','p'},
                                    {'O','c','t'},{'N','o','v'},{'D','e','c'}};


//---------------------------------------------------------------------------------------------
// Retorna a posicao de memoria da proxima variavel com base no tamanho da variavel anterior
//          pMemInic : Posicao da Memoria Total Alocada com malloc
//          pSizeAlloc : Atual tamanho já allocado das variaveis. Retorna nela mesma atualizada
//          pSizeOff : tanaho, sizeof, da variavel anterior
//---------------------------------------------------------------------------------------------
unsigned long vRetAlloc(unsigned long pMemInic, unsigned long *pSizeAlloc, unsigned long pSizeOf)
{
    *pSizeAlloc = *pSizeAlloc + pSizeOf;
    return (pMemInic + *pSizeAlloc);
}

#endif