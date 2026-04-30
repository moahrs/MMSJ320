#define EDIT_COLS        40
#define EDIT_ROWS        23

#define EDIT_TOP_MENU     0
#define EDIT_TOP_LINE     1
#define EDIT_TEXT_Y       2

#define EDIT_STATUS_LINE  21
#define EDIT_STATUS_Y     22

#define EDIT_TEXT_ROWS    19

#define EDIT_FILE_ADDR    ((char *)0x00840000)
#define EDIT_MAX_FILE     65536
#define EDIT_MAX_LINES    1024

#define KEY_ESC     27
#define KEY_ENTER   13

#define KEY_UP      17
#define KEY_DOWN    19
#define KEY_LEFT    18
#define KEY_RIGHT   20

#define KEY_BACKSPACE 8
#define KEY_DELETE    127
#define KEY_ENTER     13

#define KEY_NONE     0
#define CURSOR_CHAR  254
#define CURSOR_DELAY 8000

#define KEY_CTRL        0xA1
#define KEY_ALT         0xC0
#define KEY_CTRL_SHIFT  0xD0
#define KEY_ALT_SHIFT   0xC8
#define KEY_CTRL_ALT    0xA8

#define KEY_CTRL_K  11  // Funcoes de Arquivo e bloco
#define KEY_CTRL_Q  19  // Funcoes de Pesquisa e rapidas
#define ED_HELP_LINES 5

int edHelpMode;   /* 0=normal, 1=^K, 2=^Q */

int edCmdModeK;
int edCmdModeQ;
int edDirty;
char edFileName[128];

char *edFileBuf;
char *edLinePtr[EDIT_MAX_LINES];
char textToFind[128];
char textToChange[128];
char edMessage[80];

int edNumLines;
int edCurLine;
int edCurCol;
int edVScroll;
int edHScroll;
int edFileSize;

void edDrawCommandHelp(void);
void edRestoreNormalTop(char *filename);
void edLoop(char *filename);
void edAdjustScroll(void); 
void edPrintSpaces(int qtd);
void edDrawLine(int y);
void edDrawHeader(char *filename);
void edDrawStatus(void);
int edLineLen(int line);
void edBuildLines(void);
void edDrawText(void);
void edPlaceCursor(void);
void edMoveLeft(void);
void edMoveRight(void);
void edMoveUp(void);
void edMoveDown(void);
int edBackspace(void);
int edDelete(void);
int edInsertEnter(void);
char edGetCharAtCursor(void);
void edDrawCursor(int show);
int edGetCursorOffset(void);
int edInsertChar(char c);
void edClearToEndLine(int used);
int edSaveFile(void);
int edOpenFile(void);
int edCanExit(void);
void edSetMessage(char *msg);
void edClearLine(int y);

//void vdp_set_cursor(int x, int y);      /* use a sua rotina real */
//void ClearScr(void);         /* use a sua rotina real */