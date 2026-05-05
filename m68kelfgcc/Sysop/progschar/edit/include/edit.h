#define EDIT_COLS        40
#define EDIT_ROWS        23

#define EDIT_TOP_MENU     0
#define EDIT_TOP_LINE     1
#define EDIT_TEXT_Y       2

#define EDIT_STATUS_LINE  21
#define EDIT_STATUS_Y     22

#define EDIT_TEXT_ROWS    19

//#define EDIT_FILE_ADDR    ((char *)0x00840000)
#define EDIT_MAX_FILE     32768
#define EDIT_MAX_LINES    1024

#define CURSOR_CHAR  254
#define CURSOR_DELAY 8000

#define ED_HELP_LINES 5

#define ED_INPUT_MAX 30

#define ED_BLOCK_NONE   0
#define ED_BLOCK_MARKED 1

#define EDIT_CLIP_MAX EDIT_MAX_FILE

#define ED_MSG_TICKS 4000   /* ajusta pro teu loop */

char edTempMessage[80];
int edMsgActive;
int edMsgTimer;

unsigned char edClipBuf[EDIT_CLIP_MAX];
unsigned long edClipSize;

char edMessage[40];
char edSearchText[ED_INPUT_MAX];

int edBlockMode;
int edBlockStartLine;
int edBlockStartCol;
int edBlockEndLine;
int edBlockEndCol;
int edHelpMode;   /* 0=normal, 1=^K, 2=^Q */

int edCmdModeK;
int edCmdModeQ;
int edCmdModeL;
int edDirty;
char edFileName[128];

char *edFileBuf;
char *edLinePtr[EDIT_MAX_LINES];
char textToFind[128];
char textToChange[128];

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
void edDrawLine(int y,char c);
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
int edSaveFileAs(unsigned char* vParamName);
int edOpenFile(unsigned char* vParamName);
int edCanExit(void);
void edSetMessage(char *msg);
void edClearLine(int y);
int edInputStatus(char *prompt, char *out, int maxLen);
int edFindFromCursor(int repeat);
int edMatchAt(int pos, char *txt);
static char edToUpper(char c);
int edSaveToFile(char* vfilename, unsigned char* buf, int size);
void edToUpperCase(char* str);
void edBlockBegin(void);
void edBlockEnd(void);
unsigned long edGetOffsetFromLineCol(int line, int col);
void edSetCursorFromOffset(unsigned long off);
int edGetBlockRange(unsigned long *start, unsigned long *end);
int edBlockDel(void);
int edBlockCopy(void);
int edBlockMove(void);
