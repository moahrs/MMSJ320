typedef struct FILES_DIR
{
    unsigned char        Name[9];
    unsigned char        Ext[4];
    unsigned char        Modify[12];
    unsigned char        Size[8];
  	  unsigned char		Attr[6];
    unsigned char        posy;
} FILES_DIR;

typedef struct LIST_DIR 
{
  FILES_DIR dir[150];
  int pos;
} LIST_DIR;

LIST_DIR *dfile = 1;
unsigned char *vMemTotal = 0x8FFF00;
unsigned char *clinha = 1;
unsigned short *vpos = 1;
unsigned short *vposold = 1;
unsigned char *dFileCursor = 1;
unsigned char *vcorfg = 1;
unsigned char *vcorbg = 1;

// DEFINE FUNCOES
void linhastatusDef(unsigned char vtipomsgs, unsigned char * vmsgs);
void SearchFileDef(void);
void carregaDirDef(void);
void listaDirDef(void);

void (*linhastatus)(unsigned char vtipomsgs, unsigned char * vmsgs) = 1;
void (*SearchFile)() = 1;
void (*carregaDir)() = 1;
void (*listaDir)() = 1;

enum {
  FILES_RELOC_LINESTATUS_DEF = 0,
  FILES_RELOC_SEARCHFILE_DEF,
  FILES_RELOC_CARREGADIR_DEF,
  FILES_RELOC_LISTADIR_DEF,
  FILES_RELOC_STRCPY,
  FILES_RELOC_STRCAT,
  FILES_RELOC_MEMSET,
  FILES_RELOC_TOUPPER,
  FILES_RELOC_ITOA,
  FILES_RELOC_LTOA,
  FILES_RELOC_VRETALLOC,
  FILES_RELOC_COUNT
};

extern unsigned long MMSJOS_FUNC_RELOC[FILES_RELOC_COUNT];

char * (*mystrcpy)(char *, char *) = 1;
char * (*mystrcat)(char *, char *) = 1;
void * (*mymemset)() = 1;
int  (*mytoupper)(int) = 1;
char * (*myitoa)(int, char *, int) = 1;
char * (*myltoa)(long, char *, int) = 1;

unsigned long (*myvRetAlloc)(unsigned long pMemInic, unsigned long *pSizeAlloc, unsigned long pSizeOf) = 1;
