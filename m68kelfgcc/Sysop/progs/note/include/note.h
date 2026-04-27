// Note Viewer - Definicoes, Globais e Ponteiros de Funcao
// Padrao: todas as funcoes locais sao chamadas via ponteiro (compatibilidade IDE68K)

// Layout de Tela (255x191)
// Titulo   : y=0..12  (showWindow)
// Texto    : y=15..164 (15 linhas x 10px)
// Separador: y=173
// Botao    : y=178..188 (Close)
// Scrollbar: x=246..253, y=15..164

#define NOTE_Y_TEXT      15      // Y de inicio da area de texto
#define NOTE_LINE_H      10      // Altura de cada linha em pixels
#define NOTE_VISIBLE     15      // Numero de linhas visiveis
#define NOTE_TEXT_X       3      // X de inicio do texto
#define NOTE_CHARS_LINE  39      // Maximo de caracteres por linha visivel
#define NOTE_MAX_LINES   500     // Maximo de linhas indexadas

#define NOTE_SCRL_X     246      // X inicial da barra de rolagem
#define NOTE_SCRL_Y      15      // Y inicial da barra de rolagem
#define NOTE_SCRL_H     150      // Altura da trilha da barra de rolagem
#define NOTE_SCRL_W       7      // Largura da barra de rolagem

#define NOTE_CLOSE_X    100      // X do botao Close
#define NOTE_CLOSE_Y    178      // Y do botao Close
#define NOTE_CLOSE_W     56      // Largura do botao Close
#define NOTE_CLOSE_H     10      // Altura do botao Close

// Variaveis Globais
unsigned char  *noteTextBuf;     // Buffer com o conteudo do arquivo
unsigned long   noteBufSize;     // Tamanho do arquivo em bytes
unsigned long  *noteLines;       // Array (dinamico) de offsets de inicio de cada linha
unsigned short  noteLineCount;   // Total de linhas no arquivo
unsigned short  noteTopLine;     // Linha do topo da tela (scroll vertical)
unsigned short  noteHOffset;     // Offset horizontal (scroll horizontal)
unsigned char   nvcorfg;         // Cor do texto
unsigned char   nvcorbg;         // Cor do fundo

// Prototipos das funcoes locais (definicao real em note.c)
void drawNoteDef(void);
void displayNotePageDef(void);
void drawScrollBarDef(void);

// Ponteiros de funcao locais (padrao IDE68K)
void (*drawNote)(void);
void (*displayNotePage)(void);
void (*drawScrollBar)(void);

// Ponteiros para funcoes da stdlib (chamadas via ponteiro para evitar problemas IDE68K)
char * (*nmystrcpy)(char *, char *);
void * (*nmymemset)(void *, int, int);
char * (*nmyitoa)(int, char *, int);
