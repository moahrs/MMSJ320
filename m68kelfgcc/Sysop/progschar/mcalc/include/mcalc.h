#ifndef SHEET_H
#define SHEET_H

/* ===== begin vc_screen.h ===== */

#define VC_COLOR_FG      15
#define VC_COLOR_BG      1

#define VC_COLOR_INV_FG  VC_COLOR_BG
#define VC_COLOR_INV_BG  VC_COLOR_FG

#define KEY_UP      17
#define KEY_DOWN    19
#define KEY_LEFT    18
#define KEY_RIGHT   20

extern unsigned char vc_fgcolor;
extern unsigned char vc_bgcolor;
extern int curscr;

void vc_cls(void);
void vc_gotoxy(int y, int x);
void vc_getmaxyx(int screen, int *py, int *px);
int  vc_getkey(void);
void vc_refresh(void);
void vc_attron(int attr);
void vc_attroff(int attr);
double vc_pow(double base, int exp);
int vc_div_int(int n, int d);

#define A_REVERSE  1
#define COLOR_PAIR(n)  (n)

#define clear()         vc_cls()
#define refresh()       vc_refresh()
#define move(y,x)       vc_gotoxy((y),(x))
#define getch()         vc_getkey()
#define attron(a)       vc_attron((a))
#define attroff(a)      vc_attroff((a))

#define VC_EMPTY 0
#define VC_TEXT  1
#define VC_NUM   2

#define VC_ROWS 256
#define VC_COLS 64
#define VC_MAX_CELLS 1024
#define VC_TEXT_POOL_SIZE 32768

typedef struct {
    unsigned char used;
    unsigned char type;
    unsigned short text_off;
    unsigned short text_len;
    long value;
} VC_CELL;

static unsigned short vc_table[VC_ROWS][VC_COLS];
static VC_CELL vc_cells[VC_MAX_CELLS];

static char vc_text_pool[VC_TEXT_POOL_SIZE];
static unsigned short vc_text_next;

/* ===== end vc_screen.h ===== */

/* ===== begin data.h ===== */

struct cell_s {
	int row;
	int col;
	int contents;
	union data_s *data;
    long cached_value;
    unsigned char cache_valid;
    unsigned char formatAlign;
    unsigned char formatDisp;
};

union data_s {
	long int num;
	double value;
	char *label;
};

typedef struct cell_s *cell;
typedef union data_s *data;

#define SHEET_ROWS 256
#define SHEET_COLS 64

#define SHEET_MAX_CELLS 1024
#define SHEET_TEXT_POOL_SIZE 32768

#define CELL_INT    0
#define CELL_FLOAT  1
#define CELL_LABEL  2
#define CELL_FORMULA 3

#define FORMAT_ALIGN_LEFT  'L'
#define FORMAT_ALIGN_RIGHT 'R'

#define FORMAT_DISP_GENERAL 'G'
#define FORMAT_DISP_CURRENCY '$'
#define FORMAT_DISP_INTEGER 'I'
#define FORMAT_DISP_FIXED 'F'

#define SHEET_COL_WIDTH_MIN 3
#define SHEET_COL_WIDTH_MAX 25
#define SHEET_COL_WIDTH_DEFAULT 8

#define SHEET_GRID_X 4
#define SHEET_GRID_Y 4

static unsigned char defaultAlign;
static unsigned char defaultDisp;

char *p;  // ponteiro global da expressão
static int eval_depth = 0;

void skip_spaces(void);
long parse_number();
long get_cell_value(int row, int col, cell table[256][64]);
long parse_cell(cell table[256][64]);
long parse_factor(cell table[256][64]);
long parse_term(cell table[256][64]);
long eval_formula(char *expr, cell table[256][64]);
long parse_expr(cell table[256][64]);

static struct cell_s sheet_cell_pool[SHEET_MAX_CELLS];
static union data_s sheet_data_pool[SHEET_MAX_CELLS];
static unsigned char sheet_cell_used[SHEET_MAX_CELLS];

static char sheet_text_pool[SHEET_TEXT_POOL_SIZE];
static unsigned short sheet_text_next = 0;

static cell sheet_table[256][64];

void init_table(void);
void set_data(char *input, int row, int col, cell table[256][64]);
void print_data(int row, int col, int draw_size, cell table[256][64], char *out);
void get_raw(int row, int col, int entry_size, cell (*table)[64], char *out);
static int sheet_parse_cell_ref(char *cellref, int *out_row1, int *out_col1);
/* ===== end data.h ===== */

/* ===== begin functions.h ===== */

int to_num(char c);

/* ===== end functions.h ===== */

/* ===== begin layout.h ===== */

/*extern static int draw_size;
extern static int x_start;
extern static int y_start;*/

int draw_screenyx();
void draw_axes(int y, int x);
void draw_cells(int row, int col, int max_y, int max_x, int draw_size, cell table[256][64]);
void setup();
void color_on();
void color_off();

/* ===== end layout.h ===== */

/* ===== begin input.h ===== */

void draw_input();
void parse_input();

/* ===== end input.h ===== */

/* ===== begin cursor.h ===== */

void fill_in(int y, int x, int row, int col);
void refill(int y, int x, int row, int col);
void input();
int entry(int ch, char tp);
void set_icon(int row, int col);

/* ===== end cursor.h ===== */


/* ===== predeclaracoes ===== */
void vc_start(void);
void set_icon(int row, int col);
void fill_in(int y, int x, int row, int col);
void refill(int y, int x, int row, int col);
int  to_num(char c);
void to_char(int i, char *out);
void set_data(char *input, int row, int col, cell table[256][64]);
void color_on(void);
void color_off(void);
int  draw_screenyx(void);
void setup(void);
void draw_input(void);
void parse_input(void);
/* ===== fim predeclaracoes ===== */

double strtod(const char *str, char **endptr)
{
    double dbnum = 0;
    return dbnum;
}

long my_atol(char *s)
{
    long v;
    int neg;

    v = 0;
    neg = 0;

    while (*s == ' ')
        s++;

    if (*s == '-') {
        neg = 1;
        s++;
    }

    while (*s >= '0' && *s <= '9') {
        v = (v * 10) + (*s - '0');
        s++;
    }

    return neg ? -v : v;
}

MGUI_SET_FONT addrSetFontUseG2; // Endereco da funcao setFontUseG2, para ser usada por programas externos

#endif

