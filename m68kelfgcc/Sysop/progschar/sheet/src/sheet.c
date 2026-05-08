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


static unsigned char bufOut[128];
unsigned char vc_fgcolor = VC_COLOR_FG;
unsigned char vc_bgcolor = VC_COLOR_BG;
int curscr = 1;
static unsigned char vc_reverse_on = 0;

static unsigned char vc_font_w(void)
{
	unsigned char w = 6;
	extern MGUI_SET_FONT addrSetFontUseG2;
	if (addrSetFontUseG2.w > 0 && addrSetFontUseG2.w <= 8)
		w = addrSetFontUseG2.w;
	return w;
}

static unsigned char vc_font_h(void)
{
	unsigned char h = 8;
	extern MGUI_SET_FONT addrSetFontUseG2;
	if (addrSetFontUseG2.h > 0 && addrSetFontUseG2.h <= 8)
		h = addrSetFontUseG2.h;
	return h;
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
    *px = 40;
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
        vdp_textcolor(vc_bgcolor, vc_fgcolor);
        vc_reverse_on = 1;
    }
}

void vc_attroff(int attr)
{
    (void)attr;

    if (vc_reverse_on)
    {
        vdp_textcolor(vc_fgcolor, vc_bgcolor);
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

void init_table(void)
{
    memset(sheet_table, 0, sizeof(sheet_table));
    table = sheet_table;
}


///Called by the driver file, sets up the layout and sets all various x and y values
///Calls input(), which handles all user input
void vc_start() {
    unsigned long *memLoadFont;
    unsigned long *memSaveFont;

    memLoadFont = (unsigned long *)msmalloc(4096);
    memSaveFont = (unsigned long *)msmalloc(4096);
    loadFontUseG2(0, "/MGUI/FONTS/EVE5X8.FON", memLoadFont, memSaveFont);
    setFontUseG2(0);
    getFontUseG2(&addrSetFontUseG2);
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

	move(4, 3);
	mprintf("        ");
	move(4, 3);
	x = 3;
	y = 4;
	row = 1;
	col = 1;
	vc_getmaxyx(curscr, &max_y, &max_x);
	entry_size = max_x - 12;
	refresh();
	init_table();
	input();
	
	char ch = getch();

    msfree(memSaveFont);
    vdp_init(VDP_MODE_TEXT, VDP_BLACK, 0, 0);
    vdp_textcolor(VDP_WHITE, VDP_BLACK);

    clearScr();

    printText("Ok\r\n\0");
    printText("#>");

    showCursor();    
}


void set_icon(int row, int col) {
	int i;

	color_on();
	char letters[3];
    to_char(col - 1, letters);
	//mprintf("%u", strlen(letters));
	move(0, 1);
	if (col < 27) {
		mprintf(" ");
	}
	mprintf("%s", letters);
	mprintf("%d  ", row); //padding to make sure any other numbers are overwritten
	
	//TODO add the indicator for <L> (label), <V> (value), etc
	move(0, 6);
	if (table[row-1][col-1] != NULL) {
		mprintf("<");
		if (table[row-1][col-1]->contents < 2)
			mprintf("V");
		else
			mprintf("L");
		mprintf(">");
	} else {
		mprintf("   ");
	}
	//TODO replace this with the data entry for the next thing, clear the rest
	char inside[entry_size + 1];
	get_raw(row, col, entry_size, table, inside);
	if (inside[0] == '\0') {
		for (i = 9; i < max_x; i++) {
			mprintf(" ");
		}
	} else {
		mprintf("  %s", inside);
		for (i = 11; i < max_x; i++) {
			mprintf(" ");
		}
	}
	
	color_off();
}


///Gets entry when anything besides the arrow keys are typed
///Handles screen sizing automatically, will not scroll past size of screen
void entry(int ch) {
	char entry_line[128];
	int typed;
	int i;

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

	while((ch = getch()) != 13) {
		if (ch == 127) {
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
	}
	
	move(2, 0);
	for (i = 0; i < max_x; i++) {
		mprintf(" ");
	}
	set_icon(row, col);
	
	move(y, x);
	set_data(entry_line, row, col, table);
	fill_in(y, x, row, col);
	set_icon(row, col);
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
	while(1) 
    {
        ch = getch();
		if (ch >= 17 && ch <= 20) {
			getch(); //Arrow keys are in the form of [[A, this clears out the second bracket
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
					draw_cells(corner_row-1, corner_col, max_y, max_x, draw_size, &table);
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
					draw_cells(corner_row + 1, corner_col, max_y, max_x, draw_size, &table);
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
					draw_cells(corner_row, corner_col + 1, max_y, max_x, draw_size, &table);
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
					draw_cells(corner_row, corner_col - 1, max_y, max_x, draw_size, &table);
					col--;
					corner_col--;
					set_icon(row, col);
					fill_in(y, x, row, col);
					move(y, x);
				}
			}
		} else if (ch != 0 && ch <= 127) {
			entry(ch);
			//refill(y, x);
		} else if (ch & 0xFF00) {
            flag = (ch & 0xFF00) >> 8;
            ch = ch & 0x00FF;
            if (flag == KEY_CTRL_ALT) {
                if (ch == 'X' || ch == 'x') {
                    break; // Exit on Ctrl + Alt + X
                }
                // Handle Ctrl + Alt + Key combinations here
            } else if (flag == KEY_CTRL) {
                // Handle Ctrl + Key combinations here
            } else if (flag == KEY_ALT) {
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

    vdp_init(VDP_MODE_G2, vc_bgcolor, 0, 0);
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
	char *p = strchr(alphabet, toupper((unsigned char) c));

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
void set_data(char *input, int row, int col, cell table[256][64])
{
    cell c;
    char *txt;
    long int num;

    if (input == 0 || input[0] == 0)
        return;

    c = sheet_get_or_create_cell(row, col, table);

    if (c == 0)
        return;

    if (input[0] == 34) {
        txt = sheet_store_text(input + 1);

        if (txt == 0)
            return;

        c->contents = CELL_LABEL;
        c->data->label = txt;

        if (c->data->label[strlen(c->data->label) - 1] == '"')
            c->data->label[strlen(c->data->label) - 1] = 0;

        return;
    }

    if (input[0] >= '0' && input[0] <= '9') {
        num = strtol(input, 0, 10);

        c->contents = CELL_INT;
        c->data->num = num;

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
        msprintf(create, sizeof(create), "%ld", print->data->num);

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

    if (from->contents == CELL_LABEL) {
        strncat(out, from->data->label, entry_size);
        return;
    }

    if (from->contents == CELL_INT) {
        msprintf(out, entry_size, "%ld", from->data->num);
        return;
    }
}

/* ===== end data.c ===== */

/* ===== begin layout.c ===== */



void color_on() {
	attron(COLOR_PAIR(2));
}

void color_off() {
	attroff(COLOR_PAIR(2));
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
	attron(COLOR_PAIR(2));
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
	//move(4, 4);
	//draw_cells(start_y, start_x);
}

///Draws the data inside the cells  
void draw_cells(int row, int col, int max_y, int max_x, int draw_size, cell (**table)[64]) {
	//make sure to keep track of cursor position locally
	int i;
	int j;
	int draw = (max_x - 3) / draw_size;
	color_off();
	for (i = 0; i < (max_y - 4); i++) {
		move(4 + i, 3);
		for (j = 0; j < draw; j++) {
			char out[draw_size + 1];
			print_data(row+i, col+j, draw_size, *table, out);
			mprintf("%s", out);
			//mprintf("AAAAAAAA");
		}
	}
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
	attron(COLOR_PAIR(2));

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
	attroff(COLOR_PAIR(2));
	for (x = 0; x < max_x; x++) {
		mprintf(" ");
	}
	attron(COLOR_PAIR(2));
	
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
					attron(COLOR_PAIR(2));
					
				} else {
					attroff(COLOR_PAIR(2));
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


