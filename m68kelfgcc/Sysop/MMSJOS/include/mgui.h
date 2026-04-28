#ifndef MGUI_H
#define MGUI_H

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

extern unsigned char *memPosConfig; // Config file
extern unsigned char *imgsMenuSys; // Images PBM 16x16 each icone in order (64 Bytes Each)
extern unsigned char vFinalOS; // Atualizar sempre que a compilacao passar desse valor
extern unsigned char vcorwf; //
extern unsigned char vcorwb; //
extern unsigned char vcorwb2; //
extern unsigned char fgcolorMgui; //
extern unsigned char bgcolorMgui; //
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

#define BTNONE      0x00
#define BTOK        0x01
#define BTCANCEL    0x02
#define BTYES       0x04
#define BTNO        0x08
#define BTHELP      0x10
#define BTSTART     0x20
#define BTCLOSE     0x40

#define WINVERT     0x01
#define WINHORI     0x00

#define WINOPER     0x01
#define WINDISP     0x00

#define LINHAMENU      22
#define COLMENU       8
#define LINMENU       1

#define ICONSPERLINE   8  // Quantidade de Icones por linha
#define SPACEICONS     4  // Quantidade de Espaços entre os Icones Horizontal
#define COLINIICONS   40  // Linha Inicial dos Icones

#define MOUSE_POINTER 1
#define MOUSE_HOURGLASS 2

#define ICON_HOME  50
#define ICON_RUN  51
#define ICON_NEW  52
#define ICON_DEL  53
#define ICON_MMSJDOS  54
#define ICON_SETUP  55
#define ICON_EXIT  56
#define ICON_HOURGLASS  57

#define SIZE_LOAD_IMAGE_MEM 8192    // Max PBM file format for 256x192 area
#define SIZE_LOAD_ICONS_MEM 8192    // 128 incons 64 bytes
#define SIZE_LOAD_CFG_MEM    2048   // Max config file size (+1 byte for terminator)

#define TASK_MGUI_TELA    11
#define TASK_MGUI_MOUSE   12
#define TASK_MGUI_MESSAGE 19

// -------------------------------------------------------------------------------
// Config INI - Busca direta no buffer
// mguiCfgGet: busca 'key' dentro de '[section]' em 'buf', copia valor em vOutBuf.
// Retorna 1 em caso de sucesso, 0 se nao encontrado.
// Para usar como int: atoi(mguiCfgGet(buf, "SEC", "KEY", tmp, sizeof(tmp)))
// -------------------------------------------------------------------------------
char mguiCfgGet(char *section, char *key, char *vOutBuf, unsigned char vOutMax);

// -------------------------------------------------------------------------------
// Funcoes Graficas
// -------------------------------------------------------------------------------
#define DrawHoriLine(x, y, length, color) FillRect(x, y, length, 1, color)
#define DrawVertLine(x, y, length, color) FillRect(x, y, 1, length, color)

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

// -------------------------------------------------------------------------------
// Funcoes Exclusivas do MGI
// -------------------------------------------------------------------------------
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
void runBin(void);
void importFile(void);
void putImagePbmP4(unsigned char* memoria, unsigned short ix, unsigned short iy);

// -------------------------------------------------------------------------------
// Elementos
// -------------------------------------------------------------------------------
void showWindow(unsigned char* bstr, unsigned char x1, unsigned char y1, unsigned short pwidth, unsigned char pheight, unsigned char bbutton);
void fillin(unsigned char* vvar, unsigned short x, unsigned short y, unsigned short pwidth, unsigned char vtipo);
unsigned char button(unsigned char *title, unsigned short xib, unsigned short yib, unsigned short width, unsigned short height, unsigned char vtipo);
void radioset(unsigned char* vopt, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
void togglebox(unsigned char* bstr, unsigned char *vvar, unsigned short x, unsigned short y, unsigned char vtipo);
#endif