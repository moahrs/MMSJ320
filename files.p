 

 














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
extern unsigned char kbdKeyBuffer[66]; 
extern unsigned char kbdScanCodePtrR; 
extern unsigned char kbdScanCodePtrW; 
extern unsigned char kbdScanCodeBuf[66]; 
extern unsigned char scanCode;
extern unsigned char vBufReceived; 
extern unsigned char vbuf[128]; 
extern unsigned char MseMovPtrR; 
extern unsigned char MseMovPtrW; 
extern unsigned char MseMovBuffer[66]; 
extern unsigned long vSizeTotalRec;
extern unsigned short startBasic;



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
void redrawMain(void);
void desenhaMenu(void);
unsigned char editortela(void);
unsigned char new_menu(void);
void TrocaSpriteMouse(unsigned char vicone);
void MostraIcone(unsigned short xi, unsigned short yi, unsigned char vicone, unsigned char colorfg, unsigned char colorbg);
void runFromMguiCmd(void);
void importFile(void);
void putImagePbmP4(unsigned long* memoria, unsigned short ix, unsigned short iy);




void showWindow(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton);
void fillin(unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo);
unsigned char button(unsigned char *title, unsigned short xib, unsigned short yib, unsigned short width, unsigned short height, unsigned char vtipo);
void radioset(unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
void togglebox(unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);








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
typedef unsigned char (*buttonType)(unsigned char* title, unsigned short xib, unsigned short yib, unsigned short pwidth, unsigned short height, unsigned char vtipo);






























































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



typedef struct FILES_DIR
{
 unsigned char Name[9];
 unsigned char Ext[4];
 unsigned char Modify[12];
 unsigned char Size[8];
 unsigned char Attr[5];
 unsigned char posy;
} FILES_DIR;

typedef struct LIST_DIR 
{
 FILES_DIR dir[150];
 int pos;
} LIST_DIR;

LIST_DIR *dfile; 
unsigned char *vMemTotal;
unsigned char *clinha;
unsigned short *vpos;
unsigned short *vposold;
unsigned char *dFileCursor;
unsigned char *vcorfg;
unsigned char *vcorbg;


void linhastatusDef(unsigned char vtipomsgs, unsigned char * vmsgs);
void SearchFileDef(void);
void carregaDirDef(void);
void listaDirDef(void);

void (*linhastatus)(unsigned char vtipomsgs, unsigned char * vmsgs);
void (*SearchFile)(void);
void (*carregaDir)(void);
void (*listaDir)(void);

char * (*mystrcpy)(char *, char *);
char * (*mystrcat)(char *, char *);
void * (*mymemset)(void *, int, int);
int (*mytoupper)(int);
char * (*myitoa)(int, char *, int);
char * (*myltoa)(long, char *, int);

unsigned long (*myvRetAlloc)(unsigned long pMemInic, unsigned long *pSizeAlloc, unsigned long pSizeOf);






void main(void)
{
 unsigned char vcont, ix, iy, cc, dd, ee, cnum[20], *cfileptr, *cfilepos;
 unsigned char ikk, vnomefile[128], vnomefilenew[15], avdm2, avdm, avdl, vopc, vresp;
 unsigned long vtotbytes = 0;
 unsigned char vstring[64], vwb, my, corOpcFile, corOpcFileExec, corOpcDir, corDisable;
 unsigned long vSizeAloc = 0, izz;
 unsigned char sqtdtam[10];
 VDP_COLOR vdpcolor;
 MGUI_SAVESCR vsavescr;
 MGUI_MOUSE mouseData;
 MGUI_SAVESCR windowScr;

 linhastatus = linhastatusDef;
 carregaDir = carregaDirDef;
 listaDir = listaDirDef;
 SearchFile = SearchFileDef;
 myitoa = itoa;
 myltoa = ltoa;
 mytoupper = toupper;
 mystrcpy = strcpy;
 mystrcat = strcat;
 mymemset = memset;
 myvRetAlloc = vRetAlloc;

 
 vMemTotal = ((fsMallocType *)(unsigned long)0x00800032)[22] (1024);

 
 vpos = vMemTotal;
 vposold = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vpos));
 dFileCursor = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vposold));
 vcorfg = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(dFileCursor));
 vcorbg = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vcorfg));
 clinha = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(vcorbg));
 dfile = myvRetAlloc(vMemTotal, &vSizeAloc, sizeof(clinha) * 32); 

 
 ((getColorDataType *)(unsigned long)0x00805576)[30] (&vdpcolor);
 *vcorfg = vdpcolor.fg;
 *vcorbg = vdpcolor.bg;

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (2);

 ((SaveScreenNewType *)(unsigned long)0x00805576)[3] (&windowScr, 0, 0, 255, 191);

 
 ((showWindowType *)(unsigned long)0x00805576)[20] ("File Explorer v0.2\0", 0, 0, 255, 191, 0x00);

 vcont = 1;
 *vpos = 0;
 *vposold = 0xFF;
 vnomefile[0] = 0x00;

 
 ((FillRectType *)(unsigned long)0x00805576)[7] (0,18,255,10,*vcorbg);
 ((DrawRectType *)(unsigned long)0x00805576)[9] (0,18,255,10,*vcorfg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (16,20,8,"Name\0", *vcorfg, *vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (66,20,8,"Ext\0", *vcorfg, *vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (90,20,8,"Modify\0", *vcorfg, *vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (165,20,8,"Size\0", *vcorfg, *vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (200,20,8,"Atrib\0", *vcorfg, *vcorbg);

 
 carregaDir();

 
 listaDir();

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (1);

 
 while (vcont)
 {
 ((setPosPressedType *)(unsigned long)0x00805576)[25] (0,0); 

 while (1)
 {
 ((getMouseDataType *)(unsigned long)0x00805576)[26] (&mouseData);

 if (mouseData.mouseButton == 0x02 || mouseData.mouseBtnDouble == 0x01) 
 {
 if (mouseData.vposty >= 34 && mouseData.vposty <= 170)
 {
 ee = 99;
 dd = 0;
 while (ee == 99)
 {
 if (mouseData.vposty >= clinha[dd] && mouseData.vposty <= (clinha[dd] + 10) && clinha[dd] != 0)
 ee = dd;

 dd++;

 if (dd > 13)
 break;
 }

 corOpcFile = 9;
 corOpcFileExec = 9;
 corOpcDir = 9;
 corDisable = 9;

 if (ee != 99)
 {
 ((MostraIconeType *)(unsigned long)0x00805576)[22] (8, clinha[ee], 6, 12, *vcorbg);

 if (dfile->dir[ee].Attr[0] == ' ')
 {
 corOpcFile = *vcorfg;

 if (dfile->dir[ee].Ext[0] == 'B' && dfile->dir[ee].Ext[1] == 'I' && dfile->dir[ee].Ext[2] == 'N')
 corOpcFileExec = *vcorfg;
 }
 else
 corOpcDir = *vcorfg;
 }
 else
 corOpcDir = *vcorfg;

 if (!mouseData.mouseBtnDouble)
 {
 if (ee != 99)
 my = clinha[ee] + 8;
 else
 my = mouseData.vposty;

 if (my + 46 > 190)
 my = my - 52;

 
 ((SaveScreenNewType *)(unsigned long)0x00805576)[3] (&vsavescr,30,my,52,46);

 ((FillRectType *)(unsigned long)0x00805576)[7] (30,my,50,44,*vcorbg);
 ((DrawRectType *)(unsigned long)0x00805576)[9] (30,my,50,44,*vcorfg);

 if (corOpcFile == *vcorfg)
 {
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+2,8,"Delete",*vcorfg,*vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+10,8,"Rename",*vcorfg,*vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+18,8,"Copy",*vcorfg,*vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+26,8,"Execute",corOpcFileExec,*vcorbg);
 }
 else
 {
 if (ee != 99)
 corDisable = *vcorfg;

 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+2,8,"Open",corDisable,*vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+10,8,"New",*vcorfg,*vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+18,8,"Remove",corDisable,*vcorbg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+26,8," ",9,*vcorbg);
 }

 ((DrawLineType *)(unsigned long)0x00805576)[8] (30,my+34,80,my+34,*vcorfg);
 ((writesxyType *)(unsigned long)0x00805576)[0] (33,my+36,8,"Close",*vcorfg,*vcorbg);

 vopc = 99;

 while (1)
 {
 ((getMouseDataType *)(unsigned long)0x00805576)[26] (&mouseData);

 if (mouseData.mouseButton == 0x01) 
 {
 if (mouseData.vpostx >= 31 && mouseData.vpostx <= 138)
 {
 if (mouseData.vposty >= my+2 && mouseData.vposty <= my+8 && corOpcFile == *vcorfg)
 {
 vopc = 0;
 break;
 }
 else if (mouseData.vposty >= my+10 && mouseData.vposty <= my+17 && corOpcFile == *vcorfg)
 {
 vopc = 1;
 break;
 }
 else if (mouseData.vposty >= my+18 && mouseData.vposty <= my+25 && corOpcFile == *vcorfg)
 {
 vopc = 2;
 break;
 }
 else if (ee != 99 && mouseData.vposty >= my+2 && mouseData.vposty <= my+8 && corOpcDir == *vcorfg)
 {
 vopc = 3;
 break;
 }
 else if (mouseData.vposty >= my+10 && mouseData.vposty <= my+17 && corOpcDir == *vcorfg)
 {
 vopc = 4;
 break;
 }
 else if (ee != 99 && mouseData.vposty >= my+18 && mouseData.vposty <= my+25 && corOpcDir == *vcorfg)
 {
 vopc = 5;
 break;
 }
 else if (mouseData.vposty >= my+26 && mouseData.vposty <= my+33 && corOpcFileExec == *vcorfg)
 {
 vopc = 6;
 break;
 }
 else if (mouseData.vposty >= my+44 && mouseData.vposty <= my+51)
 {
 vopc = 7;
 break;
 }
 }
 }

 ((OSTimeDlyHMSMType *)(unsigned long)0x00800032)[20] (0, 0, 0, 100);
 }

 ((RestoreScreenType *)(unsigned long)0x00805576)[4] (vsavescr);
 }
 else
 {
 if (ee != 99)
 {
 if (corOpcDir == *vcorfg) 
 vopc = 3;
 else if (corOpcFileExec == *vcorfg) 
 vopc = 6;
 }
 }

 
 if (vopc == 0 || vopc == 5) 
 {
 
 if (vopc == 0)
 vresp = ((messageType *)(unsigned long)0x00805576)[18] ("Confirm\nDelete File ?\0",(0x04 | 0x08), 0);
 else
 vresp = ((messageType *)(unsigned long)0x00805576)[18] ("Confirm\nRemove Directory ?\0",(0x04 | 0x08), 0);

 ((FillRectType *)(unsigned long)0x00805576)[7] (8,clinha[ee],8,8,*vcorbg);

 if (vresp == 0x04)
 {
 mystrcpy(vnomefile,dfile->dir[ee].Name);
 if (dfile->dir[ee].Ext[0] != 0x00)
 {
 mystrcat(vnomefile,".");
 mystrcat(vnomefile,dfile->dir[ee].Ext);
 }


 if (vopc == 0)
 {
 linhastatus(4, vnomefile);
 vresp = ((fsDelFileType *)(unsigned long)0x00800032)[14] (vnomefile);
 }
 else
 {
 linhastatus(6, vnomefile);
 vresp = ((fsRemoveDirType *)(unsigned long)0x00800032)[19] (vnomefile);
 }

 if (vresp >= 0xFFFFFFF0)
 {
 if (vopc == 0)
 ((messageType *)(unsigned long)0x00805576)[18] ("Delete File Error.\0",(0x40), 0);
 else
 ((messageType *)(unsigned long)0x00805576)[18] ("Remove Directory Error.\0",(0x40), 0);
 }
 else
 {
 carregaDir();
 listaDir();
 }
 }

 break;
 }
 else if (vopc == 1 || vopc == 2 || vopc == 4) 
 {
 
 linhastatus(1, "\0");

 
 vstring[0] = '\0';

 ((SaveScreenNewType *)(unsigned long)0x00805576)[3] (&vsavescr,10,40,240,60);

 switch (vopc)
 {
 case 1:
 linhastatus(5, "\0");
 ((showWindowType *)(unsigned long)0x00805576)[20] ("Rename File",10,40,240,50, 0x00);
 ((writesxyType *)(unsigned long)0x00805576)[0] (12,57,8,"   New Name:",*vcorfg,*vcorbg);
 break;
 case 2:
 linhastatus(8, "\0");
 ((showWindowType *)(unsigned long)0x00805576)[20] ("Copy File",10,40,240,50, 0x00);
 ((writesxyType *)(unsigned long)0x00805576)[0] (12,57,8,"Destination:",*vcorfg,*vcorbg);
 break;
 case 4:
 linhastatus(9, "\0");
 ((showWindowType *)(unsigned long)0x00805576)[20] ("Create Directory",10,40,240,50, 0x00);
 ((writesxyType *)(unsigned long)0x00805576)[0] (12,57,8,"   Dir Name:",*vcorfg,*vcorbg);
 break;
 }

 ((fillinType *)(unsigned long)0x00805576)[29] (&vstring, 80, 57, 130, 0x00);
 ((buttonType *)(unsigned long)0x00805576)[31] ("OK", 18, 78, 44, 10, 0x00);
 ((buttonType *)(unsigned long)0x00805576)[31] ("CANCEL", 66, 78, 44, 10, 0x00);

 while (1)
 {
 ((fillinType *)(unsigned long)0x00805576)[29] (&vstring, 80, 57, 130, 0x01);

 if (((buttonType *)(unsigned long)0x00805576)[31] ("OK", 18, 78, 44, 10, 0x01))
 {
 vwb = 0x01;
 break;
 }

 if (((buttonType *)(unsigned long)0x00805576)[31] ("CANCEL", 66, 78, 44, 10, 0x01))
 {
 vwb = 0x02;
 break;
 }

 ((OSTimeDlyHMSMType *)(unsigned long)0x00800032)[20] (0, 0, 0, 100);
 }

 ((RestoreScreenType *)(unsigned long)0x00805576)[4] (vsavescr);

 if (vwb == 0x01) {
 ix = 0;
 while(vstring[ix])
 {
 vnomefilenew[ix] = mytoupper(vstring[ix]);
 ix++;
 }

 vstring[ix] = 0x00;

 switch (vopc)
 {
 case 1:
 mystrcpy(vnomefile,"Confirm\nRename File ?\n\0");
 break;
 case 2:
 mystrcpy(vnomefile,"Confirm\nCopy File ?\n\0");
 break;
 case 4:
 mystrcpy(vnomefile,"Confirm\nCreate Directory ?\n\0");
 break;
 }

 mystrcat(vnomefile, vstring);

 vresp = ((messageType *)(unsigned long)0x00805576)[18] (vnomefile,(0x04 | 0x08), 0);

 if (vresp == 0x04)
 {
 if (ee != 99)
 {
 if (vopc == 1)
 {
 mystrcpy(vnomefile,dfile->dir[ee].Name);
 }
 else if (vopc == 2)
 {
 mystrcpy(vnomefile,"CP ");
 mystrcat(vnomefile,dfile->dir[ee].Name);
 }

 if (dfile->dir[ee].Ext[0] != 0x00)
 {
 mystrcat(vnomefile,".");
 mystrcat(vnomefile,dfile->dir[ee].Ext);
 }
 }

 switch (vopc)
 {
 case 1:
 linhastatus(5, vnomefile);
 vresp = ((fsRenameFileType *)(unsigned long)0x00800032)[15] (vnomefile,vnomefilenew);
 break;
 case 2:
 linhastatus(8, vnomefile);
 mystrcat(vnomefile," ");
 mystrcat(vnomefile,vnomefilenew);
 vresp = ((fsOsCommandType *)(unsigned long)0x00800032)[6] (vnomefile);
 break;
 case 4:
 linhastatus(9, vnomefile);
 vresp = ((fsMakeDirType *)(unsigned long)0x00800032)[17] (vnomefilenew);
 break;
 }

 if (vresp >= 0xFFFFFFF0)
 {
 switch (vopc)
 {
 case 1:
 ((messageType *)(unsigned long)0x00805576)[18] ("Rename File Error.\0",(0x40), 0);
 break;
 case 2:
 ((messageType *)(unsigned long)0x00805576)[18] ("Copy File Error.\0",(0x40), 0);
 break;
 case 4:
 ((messageType *)(unsigned long)0x00805576)[18] ("Create Directory Error.\0",(0x40), 0);
 break;
 }
 }
 else
 {
 carregaDir();
 listaDir();
 }
 }
 }

 linhastatus(0, "\0");

 if (ee != 99)
 ((FillRectType *)(unsigned long)0x00805576)[7] (8,clinha[ee],8,8,*vcorbg);

 break;
 }
 else if (vopc == 3) 
 {
 ((FillRectType *)(unsigned long)0x00805576)[7] (8,clinha[ee],8,8,*vcorbg);

 mystrcpy(vnomefile,dfile->dir[ee].Name);

 if (dfile->dir[ee].Ext[0] != 0x00)
 {
 mystrcat(vnomefile,".");
 mystrcat(vnomefile,dfile->dir[ee].Ext);
 }

 linhastatus(5, vnomefile);

 vresp = ((fsChangeDirType *)(unsigned long)0x00800032)[18] (vnomefile);

 if (vresp >= 0xFFFFFFF0)
 {
 ((messageType *)(unsigned long)0x00805576)[18] ("Change Directory Error.\0",(0x40), 0);
 }
 else
 {
 carregaDir();
 listaDir();
 }

 linhastatus(0, "\0");

 break;
 }
 else if (vopc == 6) 
 {
 ((FillRectType *)(unsigned long)0x00805576)[7] (8,clinha[ee],8,8,*vcorbg);

 mystrcpy(vnomefile,dfile->dir[ee].Name);
 mystrcat(vnomefile,".");
 mystrcat(vnomefile,dfile->dir[ee].Ext);

 linhastatus(5, vnomefile);

 
 

 linhastatus(0, "\0");

 break;
 }
 else if (vopc == 7) 
 {
 if (ee != 99)
 ((FillRectType *)(unsigned long)0x00805576)[7] (8,clinha[ee],8,8,*vcorbg);

 break;
 }
 }
 }
 else if (mouseData.mouseButton == 0x01) 
 {
 if (mouseData.vposty > 170) {
 
 if (mouseData.vpostx > 5 && mouseData.vpostx <= 20) { 
 *vposold = *vpos;
 if (*vpos < 14)
 *vpos = 0;
 else
 *vpos = *vpos - 14;

 listaDir();

 break;
 }
 else if (mouseData.vpostx >= 25 && mouseData.vpostx <= 40) { 
 *vposold = *vpos;
 *vpos = *vpos + 14;

 listaDir();

 break;
 }
 else if (mouseData.vpostx >= 100 && mouseData.vpostx <= 120) { 
 break;
 }
 else if (mouseData.vpostx >= 200 && mouseData.vpostx <= 220) { 
 linhastatus(7,"\0");
 vcont = 0;
 break;
 }
 }
 }

 ((OSTimeDlyHMSMType *)(unsigned long)0x00800032)[20] (0, 0, 0, 100);
 }

 if (vcont)
 ((OSTimeDlyHMSMType *)(unsigned long)0x00800032)[20] (0, 0, 0, 100);
 }

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (2);

 ((RestoreScreenType *)(unsigned long)0x00805576)[4] (windowScr);

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (1);

 ((fsFreeType *)(unsigned long)0x00800032)[11] (vMemTotal);
}


void linhastatusDef(unsigned char vtipomsgs, unsigned char * vmsgs)
{
 ((FillRectType *)(unsigned long)0x00805576)[7] (2,176,252,13,*vcorbg);
 ((DrawRectType *)(unsigned long)0x00805576)[9] (0,175,255,15,*vcorfg);

 switch (vtipomsgs) {
 case 0:
 ((MostraIconeType *)(unsigned long)0x00805576)[22] (10, 180, 5,*vcorfg, *vcorbg); 
 ((MostraIconeType *)(unsigned long)0x00805576)[22] (30, 180, 6,*vcorfg, *vcorbg); 
 ((MostraIconeType *)(unsigned long)0x00805576)[22] (107, 180, 7,*vcorfg, *vcorbg); 
 ((MostraIconeType *)(unsigned long)0x00805576)[22] (207, 180, 4,*vcorfg, *vcorbg); 
 break;
 case 1:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"wait...\0",*vcorfg,*vcorbg);
 break;
 case 2:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"processing...\0",*vcorfg,*vcorbg);
 break;
 case 3:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"file not found...\0",*vcorfg,*vcorbg);
 break;
 case 4:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"Deleting file...\0",*vcorfg,*vcorbg);
 break;
 case 5:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"Renaming file...\0",*vcorfg,*vcorbg);
 break;
 case 6:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"Deleting Directory...\0",*vcorfg,*vcorbg);
 break;
 case 7:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"Exiting...\0",*vcorfg,*vcorbg);
 break;
 case 8:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"Copying File...\0",*vcorfg,*vcorbg);
 break;
 case 9:
 ((writesxyType *)(unsigned long)0x00805576)[0] (7,180,8,"Creating Directory...\0",*vcorfg,*vcorbg);
 break;
 }

 if (*vmsgs)
 ((writesxyType *)(unsigned long)0x00805576)[0] (151,180,8,vmsgs,*vcorfg,*vcorbg);
}


void carregaDirDef(void)
{
 unsigned char vcont, ikk, ix, iy, cc, dd, ee, cnum[20];
 unsigned char vnomefile[32], dsize;
 unsigned char sqtdtam[10], cuntam;
 unsigned long vtotbytes = 0, vqtdtam;
 FILES_DIR ddir;
 FAT32_DIR vdirfiles;

 
 *dFileCursor = 0;
 dsize = sizeof(FILES_DIR);
 dfile->pos = 0;

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (2);

 
 if (((fsFindInDirType *)(unsigned long)0x00800032)[21] ('\0', 0x08) < 0xFFFFFFF0)
 {
 while (1)
 {
 ((fsGetDirAtuDataType *)(unsigned long)0x00800032)[0] (&vdirfiles);

 if (vdirfiles.Attr != 0x08 && (vdirfiles.Name[0] != '.' || (vdirfiles.Name[0] == '.' && vdirfiles.Name[1] == '.' )))
 {
 
 for (cc = 0; cc <= 7; cc++)
 {
 if (vdirfiles.Name[cc] > 32)
 ddir.Name[cc] = vdirfiles.Name[cc];
 else
 ddir.Name[cc] = '\0';
 }

 ddir.Name[8] = '\0';

 
 for (cc = 0; cc <= 2; cc++)
 {
 if (vdirfiles.Ext[cc] > 32)
 ddir.Ext[cc] = vdirfiles.Ext[cc];
 else
 ddir.Ext[cc] = '\0';
 }

 ddir.Ext[3] = '\0';

 
 
 vqtdtam = (vdirfiles.UpdateDate & 0x01E0) >> 5;
 if (vqtdtam < 1 || vqtdtam > 12)
 vqtdtam = 1;

 vqtdtam--;

 ddir.Modify[0] = vmesc[vqtdtam][0];
 ddir.Modify[1] = vmesc[vqtdtam][1];
 ddir.Modify[2] = vmesc[vqtdtam][2];
 ddir.Modify[3] = '/';

 
 vqtdtam = vdirfiles.UpdateDate & 0x001F;
 mymemset(sqtdtam, 0x0, 10);
 myitoa(vqtdtam, sqtdtam, 10);

 if (vqtdtam < 10) {
 ddir.Modify[4] = '0';
 ddir.Modify[5] = sqtdtam[0];
 }
 else {
 ddir.Modify[4] = sqtdtam[0];
 ddir.Modify[5] = sqtdtam[1];
 }
 ddir.Modify[6] = '/';

 
 vqtdtam = ((vdirfiles.UpdateDate & 0xFE00) >> 9) + 1980;
 mymemset(sqtdtam, 0x0, 10);
 myitoa(vqtdtam, sqtdtam, 10);

 ddir.Modify[7] = sqtdtam[0];
 ddir.Modify[8] = sqtdtam[1];
 ddir.Modify[9] = sqtdtam[2];
 ddir.Modify[10] = sqtdtam[3];

 ddir.Modify[11] = '\0';

 
 if (vdirfiles.Attr != 0x10) {
 
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

 
 mymemset(sqtdtam, 0x0, 10);
 myitoa(vqtdtam, sqtdtam, 10);

 
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

 
 if (vdirfiles.Attr == 0x10) {
 ddir.Attr[0] = '<';
 ddir.Attr[1] = 'D';
 ddir.Attr[2] = 'I';
 ddir.Attr[3] = 'R';
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

 dfile->dir[*dFileCursor] = ddir;
 dfile->pos = *dFileCursor;
 *dFileCursor = *dFileCursor + 1;
 }

 
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

 if (((fsFindInDirType *)(unsigned long)0x00800032)[21] (vnomefile, 0x09) >= 0xFFFFFFF0)
 break;
 }
 }

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (1);
}


void listaDirDef(void)
{
 unsigned short pposy, vretfs, dd, ww;
 unsigned char ee, cc,ix, cstring[10];

 linhastatus(1, "\0");

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (2);

 for (dd = 0; dd <= 13; dd++)
 clinha[dd] = 0x00;

 pposy = 34;
 dd = *vpos;

 if (dd < 0)
 dd = 0;

 if (dd >= *dFileCursor)
 dd = (*dFileCursor - 1);

 ee = 14;
 cc = 0;

 while(1)
 {
 for (ix = 0; ix < 8; ix++)
 {
 if (dfile->dir[dd].Name[ix] == 0x00)
 cstring[ix] = 0x20;
 else
 cstring[ix] = dfile->dir[dd].Name[ix];
 }
 cstring[8] = '\0';

 
 ((writesxyType *)(unsigned long)0x00805576)[0] (16,pposy,6,cstring,*vcorfg,*vcorbg);

 for (ix = 0; ix < 3; ix++)
 {
 if (dfile->dir[dd].Ext[ix] == 0x00)
 cstring[ix] = 0x20;
 else
 cstring[ix] = dfile->dir[dd].Ext[ix];
 }
 cstring[3] = '\0';

 
 ((writesxyType *)(unsigned long)0x00805576)[0] (66,pposy,6,cstring,*vcorfg,*vcorbg);

 
 ((writesxyType *)(unsigned long)0x00805576)[0] (90,pposy,6,dfile->dir[dd].Modify,*vcorfg,*vcorbg);

 
 ((writesxyType *)(unsigned long)0x00805576)[0] (165,pposy,6,dfile->dir[dd].Size,*vcorfg,*vcorbg);

 
 ((writesxyType *)(unsigned long)0x00805576)[0] (200,pposy,6,dfile->dir[dd].Attr,*vcorfg,*vcorbg);

 clinha[cc] = pposy;
 pposy += 10;
 dd++;
 cc++;
 ee--;

 if (dd == *dFileCursor)
 break;

 if (ee == 0)
 break;
 }

 if (ee > 0) {
 dd = 14 - ee;
 dd = dd * 10;
 dd = dd + 34;
 ww = ee * 10;
 ((FillRectType *)(unsigned long)0x00805576)[7] (5,dd,249,ww,*vcorbg);
 }

 ((TrocaSpriteMouseType *)(unsigned long)0x00805576)[21] (1);

 linhastatus(0, "\0");
}


void SearchFileDef(void)
{
}
