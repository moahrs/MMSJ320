 

 














extern unsigned char _ctype[];


















int toupper(int);
int tolower(int);




 




void *memset(void *, int, int);
void *memcpy(void *, void *, int);
char *strcat(char *, char *);
char *strchr(char *, int);
int strcmp(char *, char *);
char *strcpy(char *, char *);
int strcspn(char *, char *);
int strlen(char *);
char *strupr(char *);
char *strlwr(char *);
char *strncat(char *, char *);
int strncmp(char *, char *, int);
char *strncpy(char *, char *, int);
char *strpbrk(char *, char *);
char *strrchr(char *, int);
int strspn(char *, char *);
char *strtok(char *, char *);



 








char *ltoa(long, char *, int);
char *ultoa(unsigned long, char *, int);
char *itoa(int, char *, int);
int atoi(char *);
long atol(char *);
long strtol(char *, char **, int);
double strtod(char *, char **);
void exit(int);






 
typedef struct 
{
 unsigned char x; 
 unsigned char y; 
 unsigned char name_ptr; 
 unsigned char ecclr; 
} Sprite_attributes;

typedef struct
{
 unsigned char x;
 unsigned char y;
 unsigned char maxx;
 unsigned char maxy;
} VDP_COORD;

typedef struct
{
 unsigned char fg;
 unsigned char bg;
} VDP_COLOR;

typedef struct
{
 unsigned int pattern;
 unsigned int color;
} VDP_MODE_SETUP;

extern unsigned char *vvdgd; 
extern unsigned char *vvdgc; 

extern unsigned char fgcolor; 
extern unsigned char bgcolor; 
extern unsigned char videoBufferQtdY; 
extern unsigned int color_table;
extern unsigned int sprite_attribute_table; 
extern unsigned long videoFontes; 
extern unsigned short videoCursorPosCol; 
extern unsigned short videoCursorPosRow; 
extern unsigned short videoCursorPosColX; 
extern unsigned short videoCursorPosRowY; 
extern unsigned char videoCursorBlink; 
extern unsigned char videoCursorShow; 
extern unsigned int name_table;
extern unsigned char vdp_mode; 
extern unsigned char videoScroll; 
extern unsigned char videoScrollDir; 
extern unsigned int pattern_table;
extern unsigned char sprite_size_sel;
extern unsigned char vdpMaxCols; 
extern unsigned char vdpMaxRows;
extern unsigned char fgcolorAnt; 
extern unsigned char bgcolorAnt; 
extern unsigned int sprite_pattern_table;
extern unsigned int color_table_size;



































extern void setRegister(unsigned char registerIndex, unsigned char value);
extern unsigned char read_status_reg(void);
extern void setWriteAddress(unsigned int address);
extern void setReadAddress(unsigned int address);
extern char vdp_read_color_pixel(unsigned char x, unsigned char y);

 
extern int vdp_init(unsigned char mode, unsigned char color, unsigned char big_sprites, unsigned char magnify);

 
extern int vdp_init_textmode(unsigned char fg, unsigned char bg);


 
extern int vdp_init_g1(unsigned char fg, unsigned char bg);

 
extern int vdp_init_g2(unsigned char big_sprites, unsigned char scale_sprites);

 
extern int vdp_init_multicolor(void);


 
extern void vdp_colorize(unsigned char fg, unsigned char bg);

 
extern void vdp_plot_hires(unsigned char x, unsigned char y, unsigned char color1, unsigned char color2);

 
extern void vdp_plot_color(unsigned char x, unsigned char y, unsigned char color);

 


 
extern void vdp_set_bdcolor(unsigned char color);

 
extern void vdp_set_pattern_color(unsigned int index, unsigned char fg, unsigned char bg);

 
extern void vdp_set_cursor(unsigned char pcol, unsigned char prow);
extern VDP_COORD vdp_get_cursor(void);
extern VDP_COLOR vdp_get_color(void);
extern void vdp_get_cfg(unsigned int *pat, unsigned int *cor);
extern unsigned long getVideoFontes(void);

 
extern void vdp_set_cursor_pos(unsigned char direction);

 
extern void vdp_textcolor(unsigned char fg, unsigned char bg);

 
extern void vdp_write(unsigned char chr);

 
extern void vdp_set_sprite_pattern(unsigned char number, const unsigned char *sprite);

 
extern void vdp_sprite_color(unsigned int addr, unsigned char color);

 
extern Sprite_attributes vdp_sprite_get_attributes(unsigned int addr);

 
extern Sprite_attributes vdp_sprite_get_position(unsigned int addr);

 
extern unsigned int vdp_sprite_init(unsigned char name, unsigned char priority, unsigned char color);

 
extern unsigned char vdp_sprite_set_position(unsigned int addr, unsigned int x, unsigned char y);










 



 






extern void geraScroll(void);
extern void clearScr(void);
extern void printChar(unsigned char pchr, unsigned char pmove);
extern void printText(unsigned char *msg);







extern unsigned char *vmfp; 
extern unsigned char *mfpgpdr;
extern unsigned char *mfpddr;
















extern unsigned short Reg_UCR ; 
extern unsigned short Reg_UDR ; 
extern unsigned short Reg_RSR ; 
extern unsigned short Reg_TSR ; 


extern unsigned short Reg_VR ; 
extern unsigned short Reg_IERA; 
extern unsigned short Reg_IERB; 
extern unsigned short Reg_IPRA; 
extern unsigned short Reg_IPRB; 
extern unsigned short Reg_IMRA; 
extern unsigned short Reg_IMRB; 
extern unsigned short Reg_ISRA; 
extern unsigned short Reg_ISRB; 


extern unsigned short Reg_TADR; 
extern unsigned short Reg_TBDR; 
extern unsigned short Reg_TCDR; 
extern unsigned short Reg_TDDR; 
extern unsigned short Reg_TACR; 
extern unsigned short Reg_TBCR; 
extern unsigned short Reg_TCDCR; 


extern unsigned short Reg_GPDR; 
extern unsigned short Reg_AER ; 
extern unsigned short Reg_DDR ; 













 


extern unsigned long runMemory;
extern unsigned char kbdKeyPtrR; 
extern unsigned char kbdKeyPtrW; 
extern unsigned char kbdKeyBuffer[64]; 
extern unsigned char kbdScanCodePtrR; 
extern unsigned char kbdScanCodePtrW; 
extern unsigned char kbdScanCodeBuf[64]; 
extern unsigned char scanCode;
extern unsigned char vBufReceived; 
extern unsigned char vbuf[128]; 
extern unsigned char MseMovPtrR; 
extern unsigned char MseMovPtrW; 
extern unsigned char MseMovBuffer[64]; 
extern unsigned long vSizeTotalRec;



extern void delayms(int pTimeMS);
extern void delayus(int pTimeUS);
extern unsigned char readChar(void);
extern unsigned char inputLine(unsigned int pQtdInput, unsigned char pTipo);
extern void writeSerial(unsigned char pchr);
extern void writeLongSerial(unsigned char *msg);
extern unsigned long lstmGetSize(void);
extern unsigned char loadSerialToMem(unsigned char *pEnder, unsigned char ptipo);
extern void pokeMem(unsigned char *pEnder, unsigned char *pByte);
extern void dumpMem (unsigned char *pEnder, unsigned char *pqtd, unsigned char *pCols);
extern void dumpMem2 (unsigned char *pEnder, unsigned char *pqtd);
extern void dumpMemWin (unsigned char *pEnder, unsigned char *pqtd, unsigned char *pCols);
extern unsigned long hexToLong(char *pHex);
extern unsigned long pow(int val, int pot);
extern int hex2int(char ch);
extern void asctohex(unsigned char a, unsigned char *s);
extern unsigned char readMouse(unsigned char *vStat, unsigned char *vMovX, unsigned char *vMovY);



























 













typedef struct
{
 unsigned short firsts; 
 unsigned short fat; 
 unsigned short root; 
 unsigned short data; 
 unsigned short maxroot; 
 unsigned short maxcls; 
 unsigned short RootEntiesCount; 
 unsigned short numheads; 
 unsigned short sectorSize; 
 unsigned short secperfat; 
 unsigned short secpertrack; 
 unsigned short fatsize; 
 unsigned char NumberOfFATs; 
 unsigned short reserv; 
 unsigned char SecPerClus; 
 unsigned char type; 
 unsigned char mount; 
} DISK12;

typedef struct
{
 unsigned long firsts; 
 unsigned long fat; 
 unsigned long root; 
 unsigned long data; 
 unsigned short maxroot; 
 unsigned long maxcls; 
 unsigned short sectorSize; 
 unsigned long fatsize; 
 unsigned short reserv; 
 unsigned char SecPerClus; 
 unsigned char type; 
 unsigned char mount; 
} DISK;

typedef struct
{
 unsigned char Name[8];
 unsigned char Ext[3];
 unsigned char Attr;
 unsigned short CreateDate;
 unsigned short CreateTime;
 unsigned short LastAccessDate;
 unsigned short UpdateDate;
 unsigned short UpdateTime;
 unsigned long FirstCluster;
 unsigned long Size;
 unsigned long DirClusSec; 
 unsigned short DirEntry; 
 unsigned char Updated;
} FAT32_DIR;


typedef struct
{
 unsigned char Name[8];
 unsigned char Ext[3];
} FILE_NAME;

typedef struct
{
 char Name[13];
 unsigned long ClusterDir;
 unsigned long ClusterDirAtu;
} RET_PATH;

typedef struct
{
 unsigned long *prev; 
 char name[11]; 
 unsigned long address; 
 unsigned long size; 
 char status; 
 unsigned long *next; 
} MEM_ALOC;

extern FAT32_DIR vdir;
extern DISK vdisk;
extern unsigned long vclusterdir;
extern unsigned char vbuf[128]; 
extern unsigned char gDataBuffer[512]; 
extern unsigned short verroSo;
extern unsigned char vdiratu[128]; 
extern unsigned short vdiratuidx; 
extern unsigned char verro;
extern RET_PATH vretpath;
extern RET_PATH vretpath2;
extern MEM_ALOC vMemAloc;








 




















































































































extern const unsigned char strValidChars[];

extern const unsigned char vmesc[12][3];


extern unsigned long fsInit(void);
extern void fsVer(void);
extern void printDiskError(unsigned char pError);
extern unsigned char fsMountDisk(void);
extern unsigned long fsOsCommand(unsigned char * linhaParametro);
extern unsigned char fsFormat (long int serialNumber, char * volumeID);
extern void fsSetClusterDir (unsigned long vclusdiratu);
extern unsigned long fsGetClusterDir (void);
extern unsigned char fsSectorWrite(unsigned long vsector, unsigned char* vbuffer, unsigned char vtipo);
extern unsigned char fsSectorRead(unsigned long vsector, unsigned char* vbuffer);
extern int fsRecSerial(unsigned char* pByte, unsigned char pTimeOut);
extern int fsSendSerial(unsigned char pByte);
extern int fsSendByte(unsigned char vByte, unsigned char pType);
extern unsigned char fsRecByte(unsigned char pType);
extern int fsSendLongSerial(unsigned char *msg);
extern void fsConvClusterToTHS(unsigned short cluster, unsigned char* vtrack, unsigned char* vside, unsigned char* vsector);
extern void fsReadDir(unsigned short ix, unsigned short vdata);


extern unsigned char fsCreateFile(char * vfilename);
extern unsigned char fsOpenFile(char * vfilename);
extern unsigned char fsCloseFile(char * vfilename, unsigned char vupdated);
extern unsigned long fsInfoFile(char * vfilename, unsigned char vtype);
extern unsigned char fsRWFile(unsigned long vclusterini, unsigned long voffset, unsigned char *buffer, unsigned char vtype);
extern unsigned short fsReadFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer);
extern unsigned char fsWriteFile(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer);
extern unsigned char fsDelFile(char * vfilename);
extern unsigned char fsRenameFile(char * vfilename, char * vnewname);
extern void runFromOsCmd(void);
extern unsigned long loadFile(unsigned char *parquivo, unsigned short* xaddress);
extern void catFile(unsigned char *parquivo);
extern unsigned char fsLoadSerialToFile(char * vfilename, char * vPosMem);
extern unsigned char fsFindDirPath(char * vpath, char vtype);
extern void fsGetDirAtuData(FAT32_DIR *pDir);
extern unsigned long fsMalloc(unsigned long vMemSize);
extern void fsFree(unsigned long vAddress);
extern void runFromMGUI(unsigned long vEnderExec);


extern unsigned char fsMakeDir(char * vdirname);
extern unsigned char fsChangeDir(char * vdirname);
extern unsigned char fsRemoveDir(char * vdirname);
extern unsigned char fsPwdDir(unsigned char *vdirpath);


extern unsigned short fsLoadFat(unsigned short vclusteratual);
extern unsigned long fsFindInDir(char * vname, unsigned char vtype);
extern unsigned char fsUpdateDir(void);
extern unsigned long fsFindNextCluster(unsigned long vclusteratual, unsigned char vtype);
extern unsigned long fsFindClusterFree(unsigned char vtype);
extern unsigned int bcd2dec(unsigned int bcd);
extern int getDateTimeAtu(void);
extern unsigned short datetimetodir(unsigned char hr_day, unsigned char min_month, unsigned char sec_year, unsigned char vtype);
extern unsigned long pow(int val, int pot);
extern int hex2int(char ch);
extern unsigned long hexToLong(char *pHex);
extern void strncpy2( char* _dst, const char* _src, int _n );
extern int isValidFilename(char *filename) ;
extern unsigned char matches_wildcard(const char *pattern, const char *filename);
extern unsigned char contains_wildcards(const char *pattern);


extern void memInit(void);

 






typedef struct
{
 unsigned long pat;
 unsigned long cor;
 unsigned long size;
 unsigned short xi;
 unsigned short yi;
 unsigned short xf;
 unsigned short yf;
} MGUI_SAVESCR;

typedef struct
{
 unsigned char mouseButton;
 unsigned char mouseBtnDouble;
 unsigned char mouseX;
 unsigned char mouseY;
 unsigned char vpostx;
 unsigned char vposty;
} MGUI_MOUSE;

typedef struct
{
 unsigned char fg;
 unsigned char bg;
} MGUI_COLOR;

extern unsigned char memPosConfig; 
extern unsigned char *imgsMenuSys; 
extern unsigned char vFinalOS; 
extern unsigned char vcorwf; 
extern unsigned char vcorwb; 
extern unsigned char vcorwb2; 
extern unsigned char fgcolorMgui; 
extern unsigned char bgcolorMgui; 
extern unsigned long mousePointer;
extern unsigned int spthdlmouse;
extern unsigned int mouseX;
extern unsigned char mouseY;
extern unsigned char mouseStat;
extern char mouseMoveX;
extern char mouseMoveY;
extern unsigned char mouseBtnPres;
extern unsigned char mouseBtnPresDouble;
extern unsigned char statusVdpSprite;
extern unsigned long mouseHourGlass;
extern unsigned long iconesMenuSys;
extern unsigned short vpostx;
extern unsigned short vposty;
extern unsigned short pposx;
extern unsigned short pposy;
extern unsigned short vxgmax;
extern unsigned int mgui_pattern_table;
extern unsigned int mgui_color_table;
extern unsigned long mguiVideoFontes;
extern unsigned char fgcolorMgui;
extern unsigned char bgcolorMgui;

















































void writesxy(unsigned short x, unsigned short y, unsigned char sizef, unsigned char *msgs, unsigned short pcolor, unsigned short pbcolor);
void writecxy(unsigned char sizef, unsigned char pbyte, unsigned short pcolor, unsigned short pbcolor);
void locatexy(unsigned short xx, unsigned short yy);
MGUI_SAVESCR SaveScreen(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
void SaveScreenNew(MGUI_SAVESCR *mguiSave, unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
void RestoreScreen(MGUI_SAVESCR vEnderSave);
void SetDot(unsigned short x, unsigned short y, unsigned short color);
void SetByte(unsigned short ix, unsigned short iy, unsigned char pByte, unsigned short pfcolor, unsigned short pbcolor);
void FillRect(unsigned char xi, unsigned char yi, unsigned short pwidth, unsigned char pheight, unsigned char pcor);
void DrawLine(unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2, unsigned short color);
void DrawRect(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight, unsigned short color);
void DrawRoundRect(unsigned int xi, unsigned int yi, unsigned int pwidth, unsigned int pheight, unsigned char radius, unsigned char color);
void DrawCircle(unsigned short x0, unsigned short y0, unsigned char r, unsigned char pfil, unsigned short pcor);
void PutIcone(unsigned int* vimage, unsigned short x, unsigned short y, unsigned char numSprite);
void InvertRect(unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
void SelRect(unsigned short x, unsigned short y, unsigned short pwidth, unsigned short pheight);
void PutImage(unsigned char* cimage, unsigned short x, unsigned short y);
void LoadIconLib(unsigned char* cfile);
unsigned long readMousePs2 (void);
void VerifyMouse(void);
void setPosPressed(unsigned char vppostx, unsigned char vpposty);
void getMouseData(MGUI_MOUSE *pmouseData);
void getColorData(MGUI_COLOR *pColor);
unsigned char waitButton(void);
unsigned char message(char* bstr, unsigned char bbutton, unsigned short btime);




void startMGI(void);
void drawButtons(unsigned short xib, unsigned short yib);
void drawButtonsnew(unsigned char *vbuttons, unsigned char *pbbutton, unsigned short xib, unsigned short yib);
void showWindow(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton);
void redrawMain(void);
void desenhaMenu(void);
unsigned char editortela(void);
unsigned char new_menu(void);
void TrocaSpriteMouse(unsigned char vicone);
void MostraIcone(unsigned short xi, unsigned short yi, unsigned char vicone, unsigned char colorfg, unsigned char colorbg);
void runFromMguiCmd(void);
void importFile(void);
void putImagePbmP4(unsigned long* memoria, unsigned short ix, unsigned short iy);
void radioset(unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
void togglebox(unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);




void fillin(unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo);








typedef int (*processCmdType)(void);
typedef void (*clearScrType)(void);
typedef void (*printTextType)(unsigned char *msg);
typedef void (*printCharType)(unsigned char pchr, unsigned char pmove);
typedef void (*delaymsType)(int pTimeMS);
typedef unsigned char (* loadSerialToMemType)(unsigned char *pEnder, unsigned char ptipo);
typedef unsigned char (* readCharType)(void);
typedef void (*hideCursorType)(void);
typedef void (*showCursorType)(void);
typedef unsigned char (* inputLineType)(unsigned int pQtdInput, unsigned char pTipo);
typedef void (*modeVideoType)(unsigned char *pMode);
typedef int (*vdp_initType)(unsigned char mode, unsigned char color, unsigned char big_sprites, unsigned char magnify);
typedef void (*vdp_colorizeType)(unsigned char fg, unsigned char bg);
typedef void (*vdp_plot_hiresType)(unsigned char x, unsigned char y, unsigned char color1, unsigned char color2);
typedef void (*vdp_plot_colorType)(unsigned char x, unsigned char y, unsigned char color);
typedef void (*vdp_set_bdcolorType)(unsigned char color);
typedef void (*vdp_set_pattern_colorType)(unsigned int index, unsigned char fg, unsigned char bg);
typedef void (*vdp_set_cursorType)(unsigned char pcol, unsigned char prow);
typedef void (*vdp_set_cursor_posType)(unsigned char direction);
typedef void (*vdp_textcolorType)(unsigned char fg, unsigned char bg);
typedef void (*vdp_writeType)(unsigned char chr);
typedef void (*vdp_set_sprite_patternType)(unsigned char number, const unsigned char *sprite);
typedef void (*vdp_sprite_colorType)(unsigned int addr, unsigned char color);
typedef Sprite_attributes (*vdp_sprite_get_attributesType)(unsigned int addr);
typedef Sprite_attributes (*vdp_sprite_get_positionType)(unsigned int addr);
typedef unsigned int (*vdp_sprite_initType)(unsigned char name, unsigned char priority, unsigned char color);
typedef unsigned char (*vdp_sprite_set_positionType)(unsigned int addr, unsigned int x, unsigned char y);
typedef void (*writeLongSerialType)(unsigned char *msg);
typedef void (*writeSerialType)(unsigned char pchr);
typedef char (*vdp_read_color_pixelType)(unsigned char x, unsigned char y);
typedef VDP_COORD (*vdp_get_cursorType)(void);
typedef VDP_COLOR (*vdp_get_colorType)(void);
typedef unsigned long (*lstmGetSizeType)(void);
typedef void (*vdp_get_cfgType)(unsigned int *pat, unsigned int *cor);
typedef void (*setRegisterType)(unsigned char registerIndex, unsigned char value);
typedef unsigned char (*read_status_regType)(void);
typedef void (*setWriteAddressType)(unsigned int address);
typedef void (*setReadAddressType)(unsigned int address);
typedef unsigned long (*getVideoFontesType)(void);
typedef unsigned char (*readMouseType)(unsigned char *vStat, unsigned char *vMovX, unsigned char *vMovY);



















































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
typedef unsigned char (*fsFreeType)(unsigned long vAddress);
typedef unsigned short (*fsReadFileType)(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned short vsizebuffer);
typedef unsigned char (*fsWriteFileType)(char * vfilename, unsigned long voffset, unsigned char *buffer, unsigned char vsizebuffer);
typedef unsigned char (*fsDelFileType)(char * vfilename);
typedef unsigned char (*fsRenameFileType)(char * vfilename, char * vnewname);
typedef unsigned long (*loadFileType)(unsigned char *parquivo, unsigned short* xaddress);
typedef unsigned char (*fsMakeDirType)(char * vdirname);
typedef unsigned char (*fsChangeDirType)(char * vdirname);
typedef unsigned char (*fsRemoveDirType)(char * vdirname);
typedef unsigned char (*fsPwdDirType)(unsigned char *vdirpath);
typedef unsigned long (*fsFindInDirType)(char * vname, unsigned char vtype);
typedef unsigned long (*fsMallocType)(unsigned long vMemSize);
typedef unsigned long (*fsFindNextClusterType)(unsigned long vclusteratual, unsigned char vtype);
typedef unsigned long (*fsFindClusterFreeType)(unsigned char vtype);
typedef unsigned char (*OSTimeDlyHMSMType)(unsigned char hours, unsigned char minutes, unsigned char seconds, unsigned int ms);


typedef void (*writesxyType)(unsigned short x, unsigned short y, unsigned char sizef, unsigned char *msgs, unsigned short pcolor, unsigned short pbcolor);
typedef void (*writecxyType)(unsigned char sizef, unsigned char pbyte, unsigned short pcolor, unsigned short pbcolor);
typedef void (*locatexyType)(unsigned short xx, unsigned short yy);
typedef void (*SaveScreenNewType)(MGUI_SAVESCR *mguiSave, unsigned short xi, unsigned short yi, unsigned short pwidth, unsigned short pheight);
typedef void (*RestoreScreenType)(MGUI_SAVESCR vEnderSave);
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
typedef void (*LoadIconLibType)(unsigned char* cfile);
typedef unsigned char (*waitButtonType)(void);
typedef unsigned char (*messageType)(char* bstr, unsigned char bbutton, unsigned short btime);
typedef void (*drawButtonsnewType)(unsigned char *vbuttons, unsigned char *pbbutton, unsigned short xib, unsigned short yib);
typedef void (*showWindowType)(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton);
typedef void (*TrocaSpriteMouseType)(unsigned char vicone);
typedef void (*MostraIconeType)(unsigned short xi, unsigned short yi, unsigned char vicone, unsigned char colorfg, unsigned char colorbg);
typedef void (*importFileType)(void);
typedef void (*putImagePbmP4Type)(unsigned long* memoria, unsigned short ix, unsigned short iy);
typedef void (*setPosPressedType)(unsigned char vppostx, unsigned char vpposty);
typedef void (*getMouseDataType)(MGUI_MOUSE *pmouseData);
typedef void (*toggleboxType)(unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
typedef void (*radiosetType)(unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
typedef void (*fillinType)(unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo);
typedef void (*getColorDataType)(MGUI_COLOR *pColor);





























































const unsigned char strValidChars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^&'@{}[],$=!-#()%.+~_";

const unsigned char vmesc[12][3] = {{'J','a','n'},{'F','e','b'},{'M','a','r'},
 {'A','p','r'},{'M','a','y'},{'J','u','n'},
 {'J','u','l'},{'A','u','g'},{'S','e','p'},
 {'O','c','t'},{'N','o','v'},{'D','e','c'}};








unsigned long vRetAlloc(unsigned long pMemInic, unsigned long *pSizeAlloc, unsigned long pSizeOf)
{
 *pSizeAlloc = *pSizeAlloc + pSizeOf;
 return (pMemInic + *pSizeAlloc);
}




void listHello(void);

unsigned char vmouseStat;
unsigned char vmouseMoveX;
unsigned char vmouseMoveY;

unsigned char *vMseMovPtrR = 0x00600512; 
unsigned char *vMseMovPtrW = 0x00600514; 




void main(void)
{
 int ix;
 unsigned char sqtdtam[10];

 
 
 ((printTextType *)(unsigned long)0x0000041A)[2] ("Hellooooooooo...\r\n\0");

 for(ix=0;ix<90000;ix++);

 listHello();

 while(1)
 {
 if (((readMouseType *)(unsigned long)0x0000041A)[39] (&vmouseStat, &vmouseMoveX, &vmouseMoveY))
 {
 ((printTextType *)(unsigned long)0x0000041A)[2] ("*[");
 itoa(vmouseStat, sqtdtam, 16);
 ((printTextType *)(unsigned long)0x0000041A)[2] (sqtdtam);
 ((printTextType *)(unsigned long)0x0000041A)[2] ("]-[");
 itoa(vmouseMoveX, sqtdtam, 16);
 ((printTextType *)(unsigned long)0x0000041A)[2] (sqtdtam);
 ((printTextType *)(unsigned long)0x0000041A)[2] ("]-[");
 itoa(vmouseMoveY, sqtdtam, 16);
 ((printTextType *)(unsigned long)0x0000041A)[2] (sqtdtam);
 ((printTextType *)(unsigned long)0x0000041A)[2] ("]-[");
 itoa(*vMseMovPtrR, sqtdtam, 10);
 ((printTextType *)(unsigned long)0x0000041A)[2] (sqtdtam);
 ((printTextType *)(unsigned long)0x0000041A)[2] ("]-[");
 itoa(*vMseMovPtrW, sqtdtam, 10);
 ((printTextType *)(unsigned long)0x0000041A)[2] (sqtdtam);
 ((printTextType *)(unsigned long)0x0000041A)[2] ("]*\r\n\0");
 }

 if (((readCharType *)(unsigned long)0x0000041A)[6] () == 0x1B)
 break;
 }
}

void listHello(void)
{
 int ix;

 for (ix=0;ix<5;ix++)
 ((printTextType *)(unsigned long)0x0000041A)[2] ("Hello................\r\n\0");
}
