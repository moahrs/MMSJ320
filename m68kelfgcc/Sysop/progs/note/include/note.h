// Note Editor - Definicoes e globais

#define NOTE_MENU_Y      14
#define NOTE_MENU_H      10

#define NOTE_Y_TEXT      28
#define NOTE_LINE_H      10
#define NOTE_VISIBLE     13
#define NOTE_TEXT_X      3
#define NOTE_CHARS_LINE  39

#define NOTE_CHAR_W      5
#define NOTE_CHAR_H      8

#define NOTE_SCRL_X      246
#define NOTE_SCRL_Y      28
#define NOTE_SCRL_H      130
#define NOTE_SCRL_W      7

#define NOTE_SCRL_H_X    2
#define NOTE_SCRL_H_Y    162
#define NOTE_SCRL_H_H    6
#define NOTE_SCRL_H_W    244

#define NOTE_STATUS_Y    178

unsigned char  *noteTextBuf;
unsigned long   noteBufSize;
unsigned long  *noteLines;
unsigned short  noteLineCount;
unsigned short  noteTopLine;
unsigned short  noteHOffset;
unsigned char   nvcorfg;
unsigned char   nvcorbg;
