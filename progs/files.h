typedef struct FILES_DIR
{
    unsigned char        Name[9];
    unsigned char        Ext[4];
    unsigned char        Modify[12];
    unsigned char        Size[8];
	  unsigned char		Attr[5];
    unsigned char        posy;
} FILES_DIR;

typedef struct LIST_DIR 
{
  FILES_DIR dir[150];
  int pos;
} LIST_DIR;

LIST_DIR *dfile;  // Lista de arquivos carregados da pasta atual
unsigned char *vMemTotal;
unsigned char *clinha;
unsigned short *vpos;
unsigned short *vposold;
unsigned char *dFileCursor;
unsigned char *vcorfg;
unsigned char *vcorbg;

// DEFINE FUNCOES
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
int  (*mytoupper)(int);
char * (*myitoa)(int, char *, int);
char * (*myltoa)(long, char *, int);

unsigned long (*myvRetAlloc)(unsigned long pMemInic, unsigned long *pSizeAlloc, unsigned long pSizeOf);
