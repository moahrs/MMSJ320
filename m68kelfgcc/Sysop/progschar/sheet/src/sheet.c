/* sheet.c - fonte consolidado */

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"

#include "sheet.h"

/* ===== MotoFFP bridge ===== */
/* Variaveis globais usadas pelos stubs em sheet_fpp.S */
unsigned long  sheet_fppD7;          /* valor D7 (FFP) */
unsigned long  sheet_fppD6;          /* valor D6 (FFP) */
unsigned char *sheet_fppBuf;         /* ponteiro para buffer string */

/* Declaracoes dos stubs assembly (sheet_fpp.S) */
extern void FP_TO_STR(void);
extern void STR_TO_FP(void);
extern void FPP_SUM(void);
extern void FPP_SUB(void);
extern void FPP_MUL(void);
extern void FPP_DIV(void);
extern void FPP_PWR(void);
extern void FPP_CMP(void);
extern void FPP_INT(void);
extern void FPP_FPP(void);
extern void FPP_SIN(void);
extern void FPP_COS(void);
extern void FPP_TAN(void);
extern void FPP_SINH(void);
extern void FPP_COSH(void);
extern void FPP_TANH(void);
extern void FPP_SQRT(void);
extern void FPP_LN(void);
extern void FPP_EXP(void);
extern void FPP_ABS(void);
extern void FPP_NEG(void);

/* Converte string ASCII para FFP 32-bit */
unsigned long floatStringToFpp(const char *pFloat)
{
    sheet_fppBuf = (unsigned char *)pFloat;
    STR_TO_FP();
    return sheet_fppD7;
}

/* Converte FFP 32-bit para string ASCII (formato +.DDDDDDDDEsDD) */
int fppTofloatString(unsigned long pFpp, unsigned char *buf)
{
    sheet_fppBuf = buf;
    sheet_fppD7  = pFpp;
    FP_TO_STR();
    return 0;
}

unsigned long fppSum(unsigned long d7, unsigned long d6)
{
    sheet_fppD7 = d7; sheet_fppD6 = d6;
    FPP_SUM();
    return sheet_fppD7;
}

unsigned long fppSub(unsigned long d7, unsigned long d6)
{
    sheet_fppD7 = d7; sheet_fppD6 = d6;
    FPP_SUB();
    return sheet_fppD7;
}

unsigned long fppMul(unsigned long d7, unsigned long d6)
{
    sheet_fppD7 = d7; sheet_fppD6 = d6;
    FPP_MUL();
    return sheet_fppD7;
}

unsigned long fppDiv(unsigned long d7, unsigned long d6)
{
    sheet_fppD7 = d7; sheet_fppD6 = d6;
    FPP_DIV();
    return sheet_fppD7;
}

unsigned long fppReal(long v)
{
    sheet_fppD7 = (unsigned long)v;
    FPP_FPP();
    return sheet_fppD7;
}

static void fppToCompactString(unsigned long pFpp, char *out, int outSize)
{
    char sci[16];
    char digits[9];
    char temp[32];
    int exponent;
    int decimalPos;
    int digitCount;
    int outPos;
    int i;
    int firstNonZero;

    if (outSize <= 0)
        return;

    out[0] = 0;
    memset(sci, 0, sizeof(sci));
    fppTofloatString(pFpp, (unsigned char *)sci);

    if (sci[0] == 0) {
        strncpy(out, "0", outSize - 1);
        out[outSize - 1] = 0;
        return;
    }

    for (i = 0; i < 8; i++)
        digits[i] = sci[2 + i];
    digits[8] = 0;

    exponent = ((sci[12] - '0') * 10) + (sci[13] - '0');
    if (sci[11] == '-')
        exponent = -exponent;

    digitCount = 8;
    while (digitCount > 1 && digits[digitCount - 1] == '0')
        digitCount--;

    decimalPos = exponent;
    outPos = 0;

    if (sci[0] == '-' && outPos < (int)sizeof(temp) - 1)
        temp[outPos++] = '-';

    if (decimalPos <= 0) {
        if (outPos < (int)sizeof(temp) - 1)
            temp[outPos++] = '0';
        if (digitCount > 0 && outPos < (int)sizeof(temp) - 1)
            temp[outPos++] = '.';

        while (decimalPos < 0 && outPos < (int)sizeof(temp) - 1) {
            temp[outPos++] = '0';
            decimalPos++;
        }

        for (i = 0; i < digitCount && outPos < (int)sizeof(temp) - 1; i++)
            temp[outPos++] = digits[i];
    } else {
        firstNonZero = 0;
        while (firstNonZero < digitCount - 1 && digits[firstNonZero] == '0')
            firstNonZero++;

        if (decimalPos < firstNonZero + 1)
            decimalPos = firstNonZero + 1;

        for (i = firstNonZero; i < decimalPos && outPos < (int)sizeof(temp) - 1; i++) {
            if (i < digitCount)
                temp[outPos++] = digits[i];
            else
                temp[outPos++] = '0';
        }

        if (decimalPos < digitCount && outPos < (int)sizeof(temp) - 1) {
            temp[outPos++] = '.';
            for (i = decimalPos; i < digitCount && outPos < (int)sizeof(temp) - 1; i++)
                temp[outPos++] = digits[i];
        }
    }

    while (outPos > 1 && temp[outPos - 1] == '0' && temp[outPos - 2] != '.')
        outPos--;
    if (outPos > 1 && temp[outPos - 1] == '.')
        outPos--;

    temp[outPos] = 0;
    strncpy(out, temp, outSize - 1);
    out[outSize - 1] = 0;
}

static void fitNumberToWidth(char *s, int width)
{
    char *dot;
    int len;

    if (width <= 0)
        return;

    len = (int)strlen(s);
    if (len <= width)
        return;

    dot = strchr(s, '.');
    if (dot) {
        while ((int)strlen(s) > width) {
            len = (int)strlen(s);
            if (len <= 0)
                break;

            if (s[len - 1] == '.') {
                s[len - 1] = 0;
                break;
            }

            s[len - 1] = 0;

            len = (int)strlen(s);
            if (len > 0 && s[len - 1] == '.') {
                s[len - 1] = 0;
                break;
            }
        }
    }
}

/* mscalloc: equivalente a mscalloc usando msmalloc */
void *mscalloc(unsigned int nmemb, unsigned int size)
{
    unsigned int total = nmemb * size;
    void *ptr = msmalloc(total);
    if (ptr)
        memset(ptr, 0, total);
    return ptr;
}

/* ===== begin vc_screeen.c ===== */
/* vc_screen.c */


static unsigned char bufCmd[128];
unsigned char vc_fgcolor = VC_COLOR_FG;
unsigned char vc_bgcolor = VC_COLOR_BG;
int curscr = 1;
static unsigned char vc_reverse_on = 0;
MGUI_SET_FONT addrSetFontUseG2;

static unsigned char vc_font_w(void)
{
	unsigned char w = 6;
	if (addrSetFontUseG2.w > 0 && addrSetFontUseG2.w <= 8)
		w = addrSetFontUseG2.w;
	return w;
}

static unsigned char vc_font_h(void)
{
	unsigned char h = 8;
	if (addrSetFontUseG2.h > 0 && addrSetFontUseG2.h <= 8)
		h = addrSetFontUseG2.h;
	return h;
}

static unsigned char sheet_ascii_upper(unsigned char c)
{
    if (c >= 'a' && c <= 'z')
        return (unsigned char)(c - ('a' - 'A'));
    return c;
}

double vc_pow(double base, int exp) {
    double result = 1.0;
    int i;
    for (i = 0; i < exp; i++) {
        result *= base;
    }
    return result;
}

void vc_cls(void)
{
    clearScrW(VDP_BLACK);
}

void vc_gotoxy(int y, int x)
{
	unsigned char fw = vc_font_w();
	unsigned char fh = vc_font_h();

	vdp_set_cursor((unsigned short)(x * fw), (unsigned short)(y * fh));
}

void vc_getmaxyx(int screen, int *py, int *px)
{
    *py = 24;
    *px = 50;
}

int vc_getkey(void)
{
    int key;
    MMSJ_KEYEVENT k;

    key = KEY_NONE;
    
    if (mmsjKeyGet(&k))
    {            
        if (!(k.flags & KEY_CTRL))
        {
            key = k.ascii;
        }
        else 
            key = k.raw;
    }

    return key;
}

void vc_refresh(void)
{
    /* no G2 provavelmente n??o precisa fazer nada */
}

void vc_attron(int attr)
{
    (void)attr;

    if (!vc_reverse_on)
    {
        setColorVideoG2(vc_bgcolor, vc_fgcolor);
        vc_reverse_on = 1;
    }
}

void vc_attroff(int attr)
{
    (void)attr;

    if (vc_reverse_on)
    {
        setColorVideoG2(vc_fgcolor, vc_bgcolor);
        vc_reverse_on = 0;
    }
}
/* ===== end vc_screeen.c ===== */

/* ===== begin cursor.c ===== */

//These don't really need to be static, I'm just a slave to my java habits
//Ok don't yell at me I just didn't feel like throwing all these values around
static int col; //The column of the cursor
static int row; //The row of the cursor
static int x; //The on-screen position of the actual cursor
static int y; // -----------------------------------------
static int max_x; //bounds of the screen
static int max_y; //(how big it is)
static int corner_row; //the row and column in the upper left corner
static int corner_col; //---------------------------------------
static int entry_size;

static cell (*table)[64];

//static cell **table;
static int count = 0;

static int draw_size;
static int x_start;
static int y_start;

static int x_pos = 0;
static int y_pos = 0;
static int x_real = 4;
static int y_real = 4;

static unsigned char sheet_recalc_visited[SHEET_ROWS][SHEET_COLS];
static unsigned char sheet_screen_dirty[SHEET_ROWS][SHEET_COLS];

static int sheet_formula_refs_cell(char *expr, int row1, int col1);
static void sheet_recalc_dependents_rec(int src_row1, int src_col1, cell table[256][64], int depth);
static void sheet_recalc_all_formulas(cell table[256][64]);
static void sheet_recalc_from_cell(int row1, int col1, cell table[256][64]);
static void sheet_refresh_visible_dirty_cells(int top_row, int left_col, int max_y, int max_x, int draw_size, cell table[256][64]);

void init_table(void)
{
    memset(sheet_table, 0, sizeof(sheet_table));
    memset(sheet_cell_used, 0, sizeof(sheet_cell_used));
    memset(sheet_cell_pool, 0, sizeof(sheet_cell_pool));
    memset(sheet_data_pool, 0, sizeof(sheet_data_pool));
    memset(sheet_text_pool, 0, sizeof(sheet_text_pool));
    memset(sheet_recalc_visited, 0, sizeof(sheet_recalc_visited));
    memset(sheet_screen_dirty, 0, sizeof(sheet_screen_dirty));
    sheet_text_next = 0;
    table = sheet_table;
}


///Called by the driver file, sets up the layout and sets all various x and y values
///Calls input(), which handles all user input
void vc_start() {
    unsigned long *memLoadFont;
    unsigned long *memSaveFont;

    memLoadFont = (unsigned long *)msmalloc(4096);
    memSaveFont = (unsigned long *)msmalloc(4096);

    if (loadFontUseG2(0, "/MGUI/FONTS/EVE5X8.FON", memLoadFont, memSaveFont))
    {
        msfree(memLoadFont);
        msfree(memSaveFont);
        setModeVideoOS(VDP_MODE_TEXT);
        clearScr();
        mprintf("Failed to load font 5x8.");
        return;
    }

    if (!setFontUseG2(0))
    {
        msfree(memLoadFont);
        msfree(memSaveFont);
        setModeVideoOS(VDP_MODE_TEXT);
        clearScr();
        mprintf("Failed to set font 5x8.");
        return;
    }

    if (!getFontUseG2(&addrSetFontUseG2))
    {
        msfree(memLoadFont);
        msfree(memSaveFont);
        setModeVideoOS(VDP_MODE_TEXT);
        clearScr();
        mprintf("Failed to get font 5x8.");
        return;
    }

    msfree(memLoadFont);

    draw_size = 8;
	draw_screenyx();
	//will need to be fixed once I implement column sizing
	draw_axes(1, 1);
	corner_row = 1;
	corner_col = 1;
	//draw_screenyx();
	refresh();
	//char cursor[9] = "        ";
	//draw_axes(20, 20);

    x = SHEET_GRID_X;
    y = SHEET_GRID_Y;
    move(y, x);    
	mprintf("        ");
    move(y, x);    
	row = 1;
	col = 1;
	vc_getmaxyx(curscr, &max_y, &max_x);
	entry_size = max_x - 12;
	refresh();
	init_table();
	input();
	
	char ch = getch();

    msfree(memSaveFont);
    setModeVideoOS(VDP_MODE_TEXT);
    clearScr();
}

void set_icon(int row, int col)
{
    int i;
    int p;
    char letters[3];
    char inside[128];

    memset(inside, 0, sizeof(inside));

    color_on();

    /* limpa linha 0 inteira */
    move(0, 0);
    for (i = 0; i < max_x; i++)
        mprintf(" ");

    /* endereço da célula */
    to_char(col - 1, letters);

    move(0, 1);
    if (col < 27)
        mprintf(" ");

    mprintf("%s%d", letters, row);

    /* tipo */
    move(0, 6);
    if (table[row - 1][col - 1] != 0) {
        mprintf("(");
        if (table[row - 1][col - 1]->contents != 2)
            mprintf("V");
        else
            mprintf("L");
        mprintf(")");
    } else {
        mprintf("   ");
    }

    /* conteúdo bruto */
    get_raw(row, col, entry_size, table, inside);

    move(0, 10);
    mprintf("%s", inside);

    /* limpa resto da linha depois do conteúdo */
    p = 10 + strlen(inside);
    move(0, p);
    for (i = p; i < max_x; i++)
        mprintf(" ");

    color_off();
}

///Gets entry when anything besides the arrow keys are typed
///Handles screen sizing automatically, will not scroll past size of screen
int entry(int ch, char tp) {
	char entry_line[128];
	int typed;
	int i;
    int vret = 0;

    memset(entry_line, 0, sizeof(entry_line));

    color_on();
	typed = 0;
	move(2, 0);
	if (ch >= 32 && ch <= 122) {
		color_off();
		for (i = 1; i < max_x; i++) {
			mprintf(" ");
		}
		move(2, 1);
		mprintf("%c", ch);
		entry_line[typed] = ch;
		typed++;
	}

    ch = getch();
	while(ch != 13 && (tp || (!tp && !(ch >= 17 && ch <= 20)))) {    // Return and Arraow keys end entry
		if (ch == 8 || ch == 127) {
			if (typed > 0) {
				move(2, typed);
				mprintf(" ");
				move(2, typed);
				entry_line[typed] = 0;
				typed--;
			}
		} else if (ch == 27){
			return;
		} else {
			if (typed < entry_size && ch <= 122 && ch >= 32) {
				mprintf("%c", ch);
				entry_line[typed] = ch;
				typed++;
			} /*else if (ch == '\033') {
				//flushinp();
				getch(); //clearing out arrow key notation
				getch();
			}*/
		}

        ch = getch();
	}

    if (!tp && ch >= 17 && ch <= 20)
        vret = ch;

	move(2, 0);
	for (i = 0; i < max_x; i++) {
		mprintf(" ");
	}

    if (!tp)
    {
        set_icon(row, col);	
        move(y, x);
        set_data(entry_line, row, col, table);
        sheet_recalc_from_cell(row, col, table);
        sheet_refresh_visible_dirty_cells(corner_row, corner_col, max_y, max_x, draw_size, table);
        fill_in(y, x, row, col);
        set_icon(row, col);
    }
    else
    {
        int src = 0;
        int dst = 0;

        if (entry_line[0] == '>')
            src = 1;

        while (entry_line[src] && dst < (int)sizeof(bufCmd) - 1) {
            bufCmd[dst] = sheet_ascii_upper((unsigned char)entry_line[src]);
            src++;
            dst++;
        }
        bufCmd[dst] = 0;

        vret = 1;
    }

    return vret;
}

///Draw the cursor at the new location with the data inside
void fill_in(int y, int x, int row, int col) {
	color_on();
	move(y, x);
	char print[draw_size + 1];
    print_data(row, col, draw_size, table, print);
	mprintf("%s", print);
	move(y, x);
}


//Rewrite the cell that just had the cursor whlie keeping the data
void refill(int y, int x, int row, int col) {
	color_off();
	move(y, x);
	char print[draw_size + 1];
	print_data(row, col, draw_size, table, print);
	mprintf("%s", print);
	move(y, x);
	color_on();
}

void input() {
	int ch;
    int flag;
    int vret = 0;
	while(1) 
    {
        if (!vret)
            ch = getch();
        else
        {
            ch = vret;
            vret = 0;
        }

		if (ch >= 17 && ch <= 20) 
        {
			if (ch == KEY_UP) { //up
				if (row > 1 && row > corner_row) {
					refill(y, x, row, col);
					move(y-1, x);
					row--;
					y--;
					//mprintf("        ");
					fill_in(y, x, row, col);
					set_icon(row, col); //This should have been a one time thing
					move(y, x);         //But it broke everything when I tried it
				} else if(corner_row > 1) {                             
					draw_axes(corner_row-1, corner_col);
					draw_cells(corner_row-1, corner_col, max_y, max_x, draw_size, table);
					row--;
					corner_row--;
					set_icon(row, col);
					move(y, x);
					fill_in(y, x, row, col);
				}
			} else if(ch == KEY_DOWN) { //down
				if (y < max_y - 1) {
					refill(y, x, row, col);
					move(y+1, x);
					row++;
					y++;
					fill_in(y, x, row, col);
					set_icon(row, col);
					move(y, x);
				} else if (row < 254) {
					draw_axes(corner_row + 1, corner_col);
					draw_cells(corner_row + 1, corner_col, max_y, max_x, draw_size, table);
					row++;
					corner_row++;
					fill_in(y, x, row, col);
					set_icon(row, col);
					move(y, x);
					//TODO
				}
			} else if (ch == KEY_RIGHT) { //right
				if (x <= max_x - (2 * draw_size)) {
					refill(y, x, row, col);
					move(y, x+draw_size);
					col++;
					x+=draw_size;
					fill_in(y, x, row, col);
					set_icon(row, col);
					move(y, x);
				} else if(col < 63) {
					draw_axes(corner_row, corner_col + 1);
					draw_cells(corner_row, corner_col + 1, max_y, max_x, draw_size, table);
					col++;
					corner_col++;
					set_icon(row, col);
					fill_in(y, x, row, col);
					move(y, x);
				}
			} else if (ch == KEY_LEFT) { //left
				if (x >= draw_size) {
					refill(y, x, row, col);
					move(y, x-draw_size);
					//mprintf("        ");
					col--;
					x-=draw_size;
					set_icon(row, col);
					fill_in(y, x, row, col);
					move(y, x);
				} else if(col > 1) {
					draw_axes(corner_row, corner_col - 1);
					draw_cells(corner_row, corner_col - 1, max_y, max_x, draw_size, table);
					col--;
					corner_col--;
					set_icon(row, col);
					fill_in(y, x, row, col);
					move(y, x);
				}
			}
		}
        else if (ch == '/') 
        {
            // Menu mode

            // List letters menu in the row 1 (inverted)

            // Letter is Valid
            
        }
        else if (ch == KEY_HOME) 
        {
            // Go to A1 Cell
            row = 1;
            col = 1;

            if (row < corner_row || row > corner_row + (max_y - 5))
                corner_row = (row < (max_y - 5)) ? 1 : (row - (max_y - 5) / 2);

            if (col < corner_col || col > corner_col + vc_div_int(max_x - 4, draw_size))
                corner_col = (col < 10) ? 1 : (col - 10);

            draw_axes(corner_row, corner_col);
            draw_cells(corner_row, corner_col, max_y, max_x, draw_size, table);
            x = SHEET_GRID_X + ((col - corner_col) * draw_size);
            y = SHEET_GRID_Y + ((row - corner_row));
            move(y, x);
            set_icon(row, col);
            fill_in(y, x, row, col);
            move(y, x);
        }
        else if (ch == '>') 
        {
            // Go to Cell
			vret = entry(ch, 1);
            if (vret)
            {
                int new_row;
                int new_col;
                
                vret = 0;

                if (sheet_parse_cell_ref((char *)bufCmd, &new_row, &new_col))
                {
                    row = new_row;
                    col = new_col;

                    if (row < 1 || row > SHEET_ROWS || col < 1 || col > SHEET_COLS) {
                        row = 1;
                        col = 1;
                    }

                    if (row < corner_row || row > corner_row + (max_y - 5))
                        corner_row = (row < (max_y - 5)) ? 1 : (row - (max_y - 5) / 2);

                    if (col < corner_col || col > corner_col + vc_div_int(max_x - 4, draw_size))
                        corner_col = (col < 10) ? 1 : (col - 10);

                    draw_axes(corner_row, corner_col);
                    draw_cells(corner_row, corner_col, max_y, max_x, draw_size, table);
                    x = SHEET_GRID_X + ((col - corner_col) * draw_size);
                    y = SHEET_GRID_Y + ((row - corner_row));
                    move(y, x);
                    set_icon(row, col);
                    fill_in(y, x, row, col);
                    move(y, x);
                }
            }
        }
        else if (ch != 0 && ch <= 127) 
        {
			vret = entry(ch, 0);
			//refill(y, x);
		} 
        else if (ch & 0xFF00) 
        {
            flag = (ch & 0xFF00) >> 8;
            ch = ch & 0x00FF;
            if (flag == KEY_CTRL_ALT) 
            {
                if (ch == 'X' || ch == 'x') 
                {
                    break; // Exit on Ctrl + Alt + X
                }
            } 
            else if (flag == KEY_CTRL) 
            {
                if (ch == KEY_UP) // Go to A1 Cell
                {
                    // TBD                    
                }
                else if (ch == KEY_DOWN) // Go to last cell
                {
                    // TBD
                }
                else if (ch == KEY_LEFT) // Go to first column of current row
                {
                    // TBD
                }
                else if (ch == KEY_RIGHT) // Go to last column of current row
                {
                    // TBD
                }
            } 
            else if (flag == KEY_ALT) 
            {
                // Handle Alt + Key combinations here
            }
        }
	} 
}

void initscr(void)
{
	VDP_COLOR vdpcolor;

	getColorData(&vdpcolor);
	vc_fgcolor = VDP_WHITE;
	vc_bgcolor = VDP_BLACK;

    setModeVideoOS(VDP_MODE_G2);
    vdp_set_bdcolor(vc_bgcolor);
}

void main(char *argc, char **argv) {
	initscr();
	refresh();
	setup();
	vc_start();
} 
/* ===== end cursor.c ===== */

/* ===== begin functions.c ===== */


//I can't take credit for the implementation of this,
//credit to caf on StackOverflow for this elagant solution
int to_num(char c) {
	int n = -1;

	static const char *const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    char *p = strchr(alphabet, (int)sheet_ascii_upper((unsigned char)c));

	if (p != NULL) {
		n = p - alphabet;
	}
	return n;
}

void to_char(int i, char *out) {
    memset(out, 0, 3 * sizeof(char));
	static const char *const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	if (i < 26) {
		strncpy(out, alphabet + i, 1);
		out[1] = '\0';
	} else {
		int tens = (i / 26) - 1;
		strncpy(out, alphabet + tens, 1);
		int ones = i % 26;
		strncat(out, alphabet + ones, 1);
	}
	out[2] = '\0';
}
/* ===== end functions.c ===== */

/* ===== begin data.c ===== */

static cell sheet_get_or_create_cell(int row, int col, cell table[256][64])
{
    int i;
    cell c;

    c = table[row - 1][col - 1];

    if (c != 0)
        return c;

    for (i = 0; i < SHEET_MAX_CELLS; i++) {
        if (!sheet_cell_used[i]) {
            sheet_cell_used[i] = 1;

            memset(&sheet_cell_pool[i], 0, sizeof(struct cell_s));
            memset(&sheet_data_pool[i], 0, sizeof(union data_s));

            sheet_cell_pool[i].row = row;
            sheet_cell_pool[i].col = col;
            sheet_cell_pool[i].data = &sheet_data_pool[i];

            table[row - 1][col - 1] = &sheet_cell_pool[i];

            return &sheet_cell_pool[i];
        }
    }

    return 0;
}

static char *sheet_store_text(char *src)
{
    unsigned short len;
    unsigned short off;

    len = strlen(src);

    if ((unsigned long)sheet_text_next + len + 1 >= SHEET_TEXT_POOL_SIZE)
        return 0;

    off = sheet_text_next;

    strcpy(&sheet_text_pool[off], src);

    sheet_text_next += len + 1;

    return &sheet_text_pool[off];
}

//should this be void? idk
void set_data(char *inputCell, int row, int col, cell table[256][64])
{
    cell c;
    char *txt;
    long int num;
    int i;

    while (*inputCell == ' ')
        inputCell++;

    if (inputCell == 0 || inputCell[0] == 0)
        return;

    c = sheet_get_or_create_cell(row, col, table);

    if (c == 0)
        return;

    // Labels
    if (inputCell[0] == 34 || (inputCell[0] >= 0x41 && inputCell[0] <= 0x5A) || (inputCell[0] >= 0x61 && inputCell[0] <= 0x7A)) {
        if (inputCell[0] == 34)     // "
            txt = sheet_store_text(inputCell + 1);
        else
            txt = sheet_store_text(inputCell);

        if (txt == 0)
            return;

        c->contents = CELL_LABEL;
        c->data->label = txt;
        c->cache_valid = 0;
        c->cached_value = 0;

        if (c->data->label[strlen(c->data->label) - 1] == '"')
            c->data->label[strlen(c->data->label) - 1] = 0;

        return;
    }

    // Numbers
    if ((inputCell[0] >= '0' && inputCell[0] <= '9') ||
        ((inputCell[0] == '+' || inputCell[0] == '-') &&
         ((inputCell[1] >= '0' && inputCell[1] <= '9') || inputCell[1] == '.')) ||
        (inputCell[0] == '.' && (inputCell[1] >= '0' && inputCell[1] <= '9'))) {
        num = (long)floatStringToFpp(inputCell);   // my_atol(inputCell);
        c->contents = CELL_INT;
        c->data->num = num;
        c->cache_valid = 0;
        c->cached_value = num;

        return;
    }

    // Formulas (not implemented yet, but this is where they would go)
    if (inputCell[0] == 0x3D)     // =
    {
        txt = sheet_store_text(inputCell + 1);

        if (txt == 0)
            return;

        /* normaliza a formula para maiusculas (A..Z) */
        i = 0;
        while (txt[i] != 0) {
            if (txt[i] >= 'a' && txt[i] <= 'z')
                txt[i] = txt[i] - ('a' - 'A');
            i++;
        }

        c->contents = CELL_FORMULA;
        c->data->label = txt;
        c->cache_valid = 0;
        c->cached_value = 0;

        return;
    }
}

///return the format in which the data of a cell at row and col should be displayed
void print_data(int row, int col, int draw_size, cell table[256][64], char *out)
{
    int i;
    cell print;
    char create[16];

    memset(out, 0, draw_size + 1);

    print = table[row - 1][col - 1];

    if (print == 0) {
        for (i = 0; i < draw_size; i++)
            strcat(out, " ");
        return;
    }

    if (print->contents == CELL_LABEL) {
        strncat(out, print->data->label, draw_size);

        while ((int)strlen(out) < draw_size)
            strcat(out, " ");

        return;
    }

    if (print->contents == CELL_INT) {
        fppToCompactString((unsigned long)print->data->num, create, sizeof(create));
        fitNumberToWidth(create, draw_size);

        if ((int)strlen(create) > draw_size) {
            for (i = 0; i < draw_size - 3; i++)
                strcat(out, " ");
            strcat(out, ">>>");
            return;
        }

        for (i = strlen(create); i < draw_size; i++)
            strcat(out, " ");

        strcat(out, create);
        return;
    }

    if (print->contents == CELL_FORMULA) {
        long val;

        if (print->cache_valid)
            val = print->cached_value;
        else {
            val = eval_formula(print->data->label, table);
            print->cached_value = val;
            print->cache_valid = 1;
        }

        char tmp[16];
        fppToCompactString((unsigned long)val, tmp, sizeof(tmp));
        fitNumberToWidth(tmp, draw_size);

        if ((int)strlen(tmp) > draw_size) {
            for (i = 0; i < draw_size - 3; i++)
                strcat(out, " ");
            strcat(out, ">>>");
            return;
        }

        for (i = strlen(tmp); i < draw_size; i++)
            strcat(out, " ");

        strcat(out, tmp);
        return;
    }

    for (i = 0; i < draw_size; i++)
        strcat(out, " ");
}

void get_raw(int row, int col, int entry_size, cell (*table)[64], char *out)
{
    cell from;

    memset(out, 0, entry_size + 1);

    from = table[row - 1][col - 1];

    if (from == 0)
        return;

    if (from->contents == CELL_LABEL || from->contents == CELL_FORMULA) {
        strncat(out, from->data->label, entry_size);
        return;
    }

    if (from->contents == CELL_INT) {
        fppToCompactString((unsigned long)from->data->num, out, entry_size + 1);
        return;
    }
}

/* ===== end data.c ===== */

/* ===== begin layout.c ===== */



void color_on() {
	attron(0);
}

void color_off() {
	attroff(0);
}
///Draw the axes, with y as the starting row and x as the starting column (converted to letters)
///This function is a goddamn mess and I should never touch it once it works
void draw_axes(int yn, int xn) {
	int a;
	int j;
	xn--; //don't
	yn--; //ask
	x_start = xn;
	y_start = yn;
	int max_x, max_y;
	vc_getmaxyx(curscr, &max_y, &max_x);
	move(4, 0);
	int b = 4;
	attron(0);
	for (a = yn+1; a < max_y - 3 + yn; a++) {
		if (a >= 100) {
			mprintf("%d", a);
		} else if (a >= 10) {
			mprintf(" %d", a);
		} else {
			mprintf("  %d", a);
		}
		
		move(b + 1, 0);
		b++;
	}
	
	move(3, 3);
	
	int k = 0;
    char letters[3];
	while ( ((k+1) * draw_size) + 3 < max_x) {
		for (j = 0; j < draw_size; j++) {
			if (k + xn < 26) {
				if (j != ((draw_size / 2)) )
					mprintf(" ");
				else {
                    to_char(k + xn, letters);
					mprintf("%s", letters);
				}			
			} else {
				if (j != (int) ((draw_size - 0.5) / 2)) {
					mprintf(" ");
				} else {
                    to_char(k + xn, letters);
					mprintf("%s", letters);
					j++;
				}
			}

		}
		k++;
	}

    // Fill last columns with " "
    while ( ((k) * draw_size) + 3 < max_x) {
        for (j = 0; j < draw_size; j++) {
            mprintf(" ");
        }
        k++;
    }
	//move(4, 4);
	//draw_cells(start_y, start_x);
}

///Draws the data inside the cells  
void draw_cells(int row, int col, int max_y, int max_x, int draw_size, cell table[256][64])
{
    int i;
    int j;
    int drawj;
    char out[draw_size + 1];

    color_on();
    move(1,0);
    mprintf("Processing...");
    color_off();

    drawj = vc_div_int(max_x - 3, draw_size);
    //drawj = (max_x - 3) / draw_size;

    for (i = 0; i < (max_y - 4); i++) {
        move(4 + i, 4);

        for (j = 0; j < drawj; j++) {
            print_data(row + i, col + j, draw_size, table, out);
            mprintf("%s", out);
        }
    }

    color_on();
    move(1,0);
    mprintf("             ");
    color_off();
}


///Initial setup for the screen, at some point I might make this work with
///the modular drawing functions. However, that day is not today
int draw_screenyx() {
	int x;
	int max_x, max_y;
	move(0, 0);
//	start_color();
	//Background: 36, 76, 122
	//Foreground: 143, 199, 240 
	//init_color(VDP_BLACK, 141, 297, 477);
/*	init_color(VDP_BLACK, 187, 39, 141);
	init_color(VDP_DARK_BLUE, 334, 627, 845);
	init_pair(2, VDP_BLACK, VDP_DARK_BLUE); //Light background
	init_pair(1, VDP_DARK_BLUE, VDP_BLACK); //Dark background*/
	attron(0);

	mprintf("  A1      ");
	vc_getmaxyx(curscr, &max_y, &max_x);

	move(0, 6);
	for (x = 6; x < max_x; x++) {
		mprintf(" ");
	}
	move(1, 0);
	for (x = 0; x < max_x; x++) {
		mprintf(" ");
	}
	attroff(0);
	move(2, 0);
	for (x = 0; x < max_x; x++) {
		mprintf(" ");
	}
	attron(0);
	
	move(3, 0);
	mprintf("   ");
	draw_axes(1, 1);
	refresh();
	return 0;
}

void setup() {
	//noecho();
	//curs_set(0);
	draw_size = 8;
}

/*
int main(void) {
	draw_size = 8;
	initscr();
	refresh();
	noecho();
	curs_set(0);
	draw_size = 8;
	
	//attron(COLOR_PAIR(1));
	//mprintf("Works              ");
	//attroff(COLOR_PAIR(1));

	draw_screenyx();
	refresh();
	char cursor[9] = "        ";
	draw_axes(20, 20);
	char ch = getch();
	endwin();
	return 0;
}
*/
/* ===== end layout.c ===== */

/* ===== begin input.c ===== */


void draw_input() {

}


void parse_input() {
	char ch;
	int i;
	int max_x, max_y;
	vc_getmaxyx(curscr, &max_y, &max_x);
	while ((ch = getch()) != '\n') {
		if (ch == '\033') {
			getch();
			int real = getch();
			if (real == 'A') { //up
				if (y_pos == y_start) {
					//shift
					if (y_start != 0) 
						draw_axes(y_start - 1, x);
					//draw cursor
					move(x_real, y_real);
					attron(0);
					
				} else {
					attroff(0);
					for (i = 0; i < draw_size; i++) {
						mprintf(" ");
					}
					move(x_real, y_real);
				}
			} else if (real == 'B') { //down
				if (y_pos - y_start + 4 >= max_y) {
					//shift
				} else {
					
				}
			} else if (real == 'C') { //right
				if ( ((x_pos - x_start) * draw_size) + 3  ) {
					//shift
				} else {
					
				}
			} else if (real == 'D') { //left
				if (x_pos == x_start) {
					//shift
				} else {
					
				}
			}
		} else {
			
		}
	}
}
/* ===== end input.c ===== */

//-------------------------------------------------------
// Parse cell reference string like "B5", "AB110" into row1, col1 (1-indexed)
// Returns 1 on success, 0 on failure
int sheet_parse_cell_ref(char *cellref, int *out_row1, int *out_col1)
{
    char *q;
    char cq;
    int col1;
    int row1;

    if (!cellref || cellref[0] == 0)
        return 0;

    q = cellref;
    col1 = 0;
    row1 = 0;

    while (*q == ' ' || *q == '\t')
        q++;

    if (*q == '>' || *q == '/')
        q++;

    while (*q == ' ' || *q == '\t')
        q++;

    cq = (char)sheet_ascii_upper((unsigned char)*q);
    while (cq >= 'A' && cq <= 'Z') {
        col1 = (col1 * 26) + (cq - 'A' + 1);
        q++;
        cq = (char)sheet_ascii_upper((unsigned char)*q);
    }

    while (*q >= '0' && *q <= '9') {
        row1 = (row1 * 10) + (*q - '0');
        q++;
    }

    if (col1 <= 0 || row1 <= 0 || *q != 0)
        return 0;

    *out_row1 = row1;
    *out_col1 = col1;

    return 1;
}

//-------------------------------------------------------
// Somente para divisoes pequenas
//-------------------------------------------------------
int vc_div_int(int n, int d)
{
    int q;
    int neg;

    q = 0;
    neg = 0;

    if (d == 0)
        return 0;

    if (n < 0) {
        n = -n;
        neg = !neg;
    }

    if (d < 0) {
        d = -d;
        neg = !neg;
    }

    while (n >= d) {
        n -= d;
        q++;
    }

    if (neg)
        q = -q;

    return q;
}

//-------------------------------------------------------
static int parse_cell_ref_ptr(char **pp, int *out_row0, int *out_col0)
{
    char *q;
    int col1;
    int row1;
    int has_col;
    int has_row;

    q = *pp;
    col1 = 0;
    row1 = 0;
    has_col = 0;
    has_row = 0;

    while (*q >= 'A' && *q <= 'Z') {
        col1 = (col1 * 26) + (*q - 'A' + 1);
        has_col = 1;
        q++;
    }

    while (*q >= '0' && *q <= '9') {
        row1 = (row1 * 10) + (*q - '0');
        has_row = 1;
        q++;
    }

    if (!has_col || !has_row || row1 <= 0 || col1 <= 0)
        return 0;

    *out_row0 = row1 - 1;
    *out_col0 = col1 - 1;
    *pp = q;

    return 1;
}

//-------------------------------------------------------
static long parse_sum_function(cell table[256][64])
{
    char *q;
    int r1;
    int c1;
    int r2;
    int c2;
    int rr;
    int cc;
    long sum, numVal;

    q = p;

    if (q[0] != 'S' || q[1] != 'U' || q[2] != 'M')
        return 0;

    q += 3;

    while (*q == ' ')
        q++;

    if (*q != '(') {
        p = q;
        return 0;
    }

    q++;

    while (*q == ' ')
        q++;

    if (!parse_cell_ref_ptr(&q, &r1, &c1)) {
        p = q;
        return 0;
    }

    while (*q == ' ')
        q++;

    if (*q == ':') {
        q++;

        while (*q == ' ')
            q++;

        if (!parse_cell_ref_ptr(&q, &r2, &c2)) {
            p = q;
            return 0;
        }
    } else {
        r2 = r1;
        c2 = c1;
    }

    while (*q == ' ')
        q++;

    if (*q == ')')
        q++;

    if (r1 > r2) {
        rr = r1;
        r1 = r2;
        r2 = rr;
    }

    if (c1 > c2) {
        cc = c1;
        c1 = c2;
        c2 = cc;
    }

    sum = 0;

    for (rr = r1; rr <= r2; rr++) {
        for (cc = c1; cc <= c2; cc++) {
            numVal = get_cell_value(rr, cc, table);
            sum = (long)fppSum((unsigned long)sum, (unsigned long)numVal); //sum += get_cell_value(rr, cc, table);
        }
    }

    p = q;
    return sum;
}

//-------------------------------------------------------
long parse_number()
{
    char numBuf[32];
    int ix;
    int seenDot;

    ix = 0;
    seenDot = 0;

    if ((*p == '+' || *p == '-') && ix < (int)sizeof(numBuf) - 1) {
        numBuf[ix++] = *p;
        p++;
    }

    while (((*p >= '0' && *p <= '9') || (*p == '.')) && ix < (int)sizeof(numBuf) - 1) {
        if (*p == '.') {
            if (seenDot)
                break;
            seenDot = 1;
        }

        numBuf[ix++] = *p;
        p++;
    }

    numBuf[ix] = 0;

    if (ix == 0)
        return 0;

    return (long)floatStringToFpp(numBuf);
}

//-------------------------------------------------------
long get_cell_value(int row, int col, cell table[256][64])
{
    cell c;

    if (row < 0 || row >= SHEET_ROWS || col < 0 || col >= SHEET_COLS)
        return 0;

    c = table[row][col];

    if (!c)
        return 0;

    if (c->contents == CELL_INT)
        return c->data->num;

    if (c->contents == CELL_FORMULA) {
        if (c->cache_valid)
            return c->cached_value;

        c->cached_value = eval_formula(c->data->label, table);
        c->cache_valid = 1;
        return c->cached_value;
    }

    return 0; // depois expandimos
}

//-------------------------------------------------------
long parse_cell(cell table[256][64])
{
    int row0;
    int col0;
    char *q;

    q = p;

    if (!parse_cell_ref_ptr(&q, &row0, &col0))
        return 0;

    p = q;

    return get_cell_value(row0, col0, table);
}

//-------------------------------------------------------
long parse_factor(cell table[256][64])
{
    long v;

    skip_spaces();

    if (*p == '(') {
        p++;
        v = parse_expr(table);
        skip_spaces();
        if (*p == ')')
            p++;
        return v;
    }

    if (p[0] == 'S' && p[1] == 'U' && p[2] == 'M')
        return parse_sum_function(table);

    if (*p >= 'A' && *p <= 'Z')
        return parse_cell(table);

    if (*p >= '0' && *p <= '9')
        return parse_number();

    if (*p == '.' && p[1] >= '0' && p[1] <= '9')
        return parse_number();

    if ((*p == '+' || *p == '-') &&
        ((p[1] >= '0' && p[1] <= '9') || (p[1] == '.' && p[2] >= '0' && p[2] <= '9')))
        return parse_number();

    /* caractere inválido: avança para não travar */
    if (*p != 0)
        p++;

    return 0;
}

//-------------------------------------------------------
long parse_term(cell table[256][64])
{
    long v;
    long v2;
    char op;

    v = parse_factor(table);

    while (1) {
        skip_spaces();

        if (*p != '*' && *p != '/')
            break;

        op = *p;
        p++;

        v2 = parse_factor(table);

        if (op == '*')
            v = (long)fppMul((unsigned long)v, (unsigned long)v2); // v *= v2;
        else
            v = (v2 != 0) ? (long)fppDiv((unsigned long)v, (unsigned long)v2) /*vc_div_int(v, v2)*/ : 0;
    }

    return v;
}

//-------------------------------------------------------
long parse_expr(cell table[256][64])
{
    long v;
    long v2;
    char op;

    v = parse_term(table);

    while (1) {
        skip_spaces();

        if (*p != '+' && *p != '-')
            break;

        op = *p;
        p++;

        v2 = parse_term(table);

        if (op == '+')
            v = (long)fppSum((unsigned long)v, (unsigned long)v2); // v += v2;
        else
            v = (long)fppSub((unsigned long)v, (unsigned long)v2); // v -= v2;
    }

    return v;
}

//-------------------------------------------------------
long eval_formula(char *expr, cell table[256][64])
{
    long r;
    char *saved_p;

    if (eval_depth > 8)
        return 0;

    eval_depth++;

    saved_p = p;
    p = expr;
    r = parse_expr(table);
    p = saved_p;

    eval_depth--;

    return r;
}

//-------------------------------------------------------
void skip_spaces(void)
{
    while (*p == ' ')
        p++;
}

//-------------------------------------------------------
static int sheet_formula_refs_cell(char *expr, int row1, int col1)
{
    int i;

    i = 0;

    while (expr[i] != 0) {
        if (expr[i] >= 'A' && expr[i] <= 'Z') {
            int c;
            int r;

            c = 0;
            while (expr[i] >= 'A' && expr[i] <= 'Z') {
                c = (c * 26) + (expr[i] - 'A' + 1);
                i++;
            }

            if (expr[i] >= '0' && expr[i] <= '9') {
                r = 0;
                while (expr[i] >= '0' && expr[i] <= '9') {
                    r = (r * 10) + (expr[i] - '0');
                    i++;
                }

                if (r == row1 && c == col1)
                    return 1;

                continue;
            }
        }

        i++;
    }

    return 0;
}

//-------------------------------------------------------
static void sheet_recalc_dependents_rec(int src_row1, int src_col1, cell table[256][64], int depth)
{
    int i;

    if (depth > 16)
        return;

    for (i = 0; i < SHEET_MAX_CELLS; i++) {
        cell c;
        int rr;
        int cc;

        if (!sheet_cell_used[i])
            continue;

        c = &sheet_cell_pool[i];

        if (c->contents != CELL_FORMULA)
            continue;

        if (!c->data || !c->data->label)
            continue;

        if (!sheet_formula_refs_cell(c->data->label, src_row1, src_col1))
            continue;

        rr = c->row;
        cc = c->col;

        if (rr < 1 || rr > SHEET_ROWS || cc < 1 || cc > SHEET_COLS)
            continue;

        if (sheet_recalc_visited[rr - 1][cc - 1])
            continue;

        sheet_recalc_visited[rr - 1][cc - 1] = 1;
        c->cache_valid = 0;
        c->cached_value = eval_formula(c->data->label, table);
        c->cache_valid = 1;
        sheet_screen_dirty[rr - 1][cc - 1] = 1;

        sheet_recalc_dependents_rec(rr, cc, table, depth + 1);
    }
}

//-------------------------------------------------------
static void sheet_recalc_from_cell(int row1, int col1, cell table[256][64])
{
    cell c;

    if (row1 < 1 || row1 > SHEET_ROWS || col1 < 1 || col1 > SHEET_COLS)
        return;

    memset(sheet_recalc_visited, 0, sizeof(sheet_recalc_visited));
    memset(sheet_screen_dirty, 0, sizeof(sheet_screen_dirty));

    c = table[row1 - 1][col1 - 1];
    if (c && c->contents == CELL_FORMULA) {
        c->cache_valid = 0;
        c->cached_value = eval_formula(c->data->label, table);
        c->cache_valid = 1;
    }

    sheet_screen_dirty[row1 - 1][col1 - 1] = 1;
    sheet_recalc_dependents_rec(row1, col1, table, 0);
    sheet_recalc_all_formulas(table);
}

//-------------------------------------------------------
static void sheet_recalc_all_formulas(cell table[256][64])
{
    int i;

    /*
     * Safety pass: keeps off-screen formula chains consistent.
     * We recalc only formula cells (no full draw), then repaint only dirty visibles.
     */
    for (i = 0; i < SHEET_MAX_CELLS; i++) {
        cell c;

        if (!sheet_cell_used[i])
            continue;

        c = &sheet_cell_pool[i];

        if (c->contents != CELL_FORMULA)
            continue;

        if (!c->data || !c->data->label)
            continue;

        c->cache_valid = 0;
        c->cached_value = eval_formula(c->data->label, table);
        c->cache_valid = 1;

        if (c->row >= 1 && c->row <= SHEET_ROWS && c->col >= 1 && c->col <= SHEET_COLS)
            sheet_screen_dirty[c->row - 1][c->col - 1] = 1;
    }
}

//-------------------------------------------------------
static void sheet_refresh_visible_dirty_cells(int top_row, int left_col, int max_y, int max_x, int draw_size, cell table[256][64])
{
    int i;
    int j;
    int drawj;
    char out[16];

    drawj = vc_div_int(max_x - 3, draw_size);

    for (i = 0; i < (max_y - 4); i++) {
        int rr = top_row + i;

        if (rr < 1 || rr > SHEET_ROWS)
            continue;

        for (j = 0; j < drawj; j++) {
            int cc = left_col + j;

            if (cc < 1 || cc > SHEET_COLS)
                continue;

            if (!sheet_screen_dirty[rr - 1][cc - 1])
                continue;

            move(4 + i, 4 + (j * draw_size));
            print_data(rr, cc, draw_size, table, out);
            mprintf("%s", out);
            sheet_screen_dirty[rr - 1][cc - 1] = 0;
        }
    }
}
