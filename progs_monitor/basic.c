/********************************************************************************
*    Programa    : basic.c
*    Objetivo    : MMSJ-Basic para o MMSJ320
*    Criado em   : 10/10/2022
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 10/10/2022  0.1     Moacir Jr.   Criacao Versao Beta
* 26/06/2023  0.4     Moacir Jr.   Simplificacoes e ajustres
* 27/06/2023  0.4a    Moacir Jr.   Adaptar processos de for-next e if-then-else
* 01/07/2023  0.4b    Moacir Jr.   Ajuste de Bugs
* 03/07/2023  0.5     Moacir Jr.   Colocar Logica Ponto Flutuante
* 10/07/2023  0.5a    Moacir Jr.   Colocar Funcoes Graficas
* 11/07/2023  0.5b    Moacir Jr.   Colocar DATA-READ
* 20/07/2023  1.0     Moacir Jr.   Versao para publicacao
* 21/07/2023  1.0a    Moacir Jr.   Ajustes de memoria e bugs
* 23/07/2023  1.0b    Moacir Jr.   Ajustes bugs no for...next e if...then
* 24/07/2023  1.0c    Moacir Jr.   Retirada "BYE" message. Ajustes de bugs no gosub...return
* 25/07/2023  1.0d    Moacir Jr.   Ajuste no basInputGet, quando Get, mandar 1 pro inputLine e sem manipulacoa cursor
* 20/01/2024  1.0e    Moacir Jr.   Colocar para iniciar direto no Basic
* 14/04/2026  1.1a03  Moacir Jr.   Ajustes para por cache variaveis e simplificar parse, retirando recursividade
* 18/04/2026  2.0a02  Moacir Jr.   Novas funcoes. Basic Proprio. Ajustes gerais.
* 19/04/2026  2.0a03  Moacir Jr.   While e WEND. Ajustes gerais.
* 20/04/2026  2.0a04  Moacir Jr.   Dual chamada, pelo monitor, e pelo mmsjos.
* 22/04/2026  2.0a05  Moacir Jr.   Buffer video, hex, oct, bin e save e load no disco
*--------------------------------------------------------------------------------
* Variables Simples: start at 00800000
*   --------------------------------------------------------
*   Type ($ = String, # = Real, % = Integer)
*   Name (2 Bytes, 1st and 2nd letters of the name)
*   --------------- --------------- ------------------------
*   Integer         Real            String
*   --------------- --------------- ------------------------
*   0x00            0x00            Length
*   Value MSB       Value MSB       Pointer to String (High)
*   Value           Value           Pointer to String
*   Value           Value           Pointer to String
*   Value LSB       Value LSB       Pointer to String (Low)
*   --------------- --------------- ------------------------
*   Total: 8 Bytes
*--------------------------------------------------------------------------------
*
*--------------------------------------------------------------------------------
* To do
*
*--------------------------------------------------------------------------------
*
*********************************************************************************/
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "../mmsj320api.h"
#include "../mmsj320vdp.h"
#include "../mmsj320mfp.h"
#include "../monitor.h"
#include "../mmsjos.h"
#include "../mgui.h"
#include "../monitorapi.h"
#include "../mmsjosapi.h"
#include "basic.h"

#define versionBasic "2.0a05"
//#define __TESTE_TOKENIZE__ 1
//#define __DEBUG_ARRAYS__ 1

//#define RUN_ON_FLASH 0
#define USE_ITERATIVE_PARSER // Comente para usar o parser antigo

#define SIMPLE_VAR_CACHE_SLOTS 8
#define PARSER_STACK_SIZE 32
#define PAINT_STACK_SIZE 4096
#define MAX_WHILE_STACK   16
#define BASIC_VDP_RAM_SIZE 0x4000
#define BASIC_VDP_BUFFER_VRAM 0
#define BASIC_VDP_BUFFER_RAM 1

//#define BASIC_DEBUG_ON 0

unsigned char *vvdgBASd = 0x00400041; // VDP TMS9118 Data Mode
unsigned char *vvdgBASc = 0x00400043; // VDP TMS9118 Registers/Address Mode

//--------------------------------------------------------------------------------------
// Editor em modo de tela cheia
//--------------------------------------------------------------------------------------
#define INPUT_BASIC_TELA 1
#define VDP_COLS        40
#define VDP_ROWS        24
#define VDP_MAX_LINE    256

#define KEY_ENTER       13
#define KEY_BACKSPACE   8
#define KEY_DELETE      127

#define KEY_LEFT        18
#define KEY_RIGHT       20
#define KEY_UP          17
#define KEY_DOWN        19
#define VDP_EDIT_CURSOR_CHAR   0xFE
#define VDP_EDIT_BLINK_TICKS   3500

int vdpEditCurX;
int vdpEditCurY;

char vdpEditLine[VDP_MAX_LINE];
static unsigned char vdpEditCursorBackup = 0x00;
static unsigned char vdpEditCursorVisible = 0;
static unsigned short vdpEditBlinkCount = 0;
static int vdpEditLineLen = 0;
static int vdpEditCursorPos = 0;
static int vdpEditLineStartX = 0;
static int vdpEditLineStartY = 0;
static int vdpEditLineEndY = 0;

static int vdpEditFindNextInputRow(void);
static void vdpEditCursorOff(void);
static void vdpEditCursorOn(void);
static void vdpEditCursorToggle(void);
static int vdpEditReadLogicalLineAt(int x, int y, char *dest, int maxLen, int *pStartX, int *pStartY, int *pEndY);

static unsigned int textPatternTable = 0x0000;
static unsigned int textNameTable = 0x0800;
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------

static unsigned char lastVarCacheName0[SIMPLE_VAR_CACHE_SLOTS] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
static unsigned char lastVarCacheName1[SIMPLE_VAR_CACHE_SLOTS] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
static unsigned char *lastVarCacheAddr[SIMPLE_VAR_CACHE_SLOTS] = {0,0,0,0,0,0,0,0};
static unsigned char paintStackX[PAINT_STACK_SIZE];
static unsigned char paintStackY[PAINT_STACK_SIZE];
static unsigned int paintPatternTable = 0x0000;
static unsigned int paintColorTable = 0x2000;
static unsigned char *paintVdpData = (unsigned char *)0x00400041;
static unsigned char basicVdpBufferEnabled = 0;
static unsigned char *while_ptr_stack[MAX_WHILE_STACK];
static int while_sp = 0;
unsigned char verro;

/*static unsigned char valStack[32][50];
static unsigned char opStack[PARSER_STACK_SIZE];
static unsigned char opPrecStack[PARSER_STACK_SIZE];
static char valTypeStack[PARSER_STACK_SIZE];
static unsigned char temp[50];
static int opTop = -1, valTop = -1;*/

static void invalidateFindVariableCache(void)
{
    int ix;

    for (ix = 0; ix < SIMPLE_VAR_CACHE_SLOTS; ix++)
    {
        lastVarCacheName0[ix] = 0x00;
        lastVarCacheName1[ix] = 0x00;
        lastVarCacheAddr[ix] = 0;
    }
}

static void clearRuntimeData(unsigned char *pForStack)
{
    invalidateFindVariableCache();
    memset(pStartSimpVar, 0x00, vMemTotalSimpVar);
    memset(pStartArrayVar, 0x00, vMemTotalArrayVar);
    memset(pForStack, 0x00, 0x800);
}

static void basVideoResetBufferState(void)
{
    basicVdpBufferEnabled = 0;
    if (pStartVdpBuffer)
        memset(pStartVdpBuffer, 0x00, BASIC_VDP_RAM_SIZE);
}

static unsigned char basVideoActiveBuffer(void)
{
    if (basicVdpBufferEnabled)
        return BASIC_VDP_BUFFER_RAM;

    return BASIC_VDP_BUFFER_VRAM;
}

static unsigned char basVideoReadByte(unsigned char bufferId, unsigned int address)
{
    if (address >= BASIC_VDP_RAM_SIZE)
        return 0x00;

    if (bufferId == BASIC_VDP_BUFFER_RAM)
        return pStartVdpBuffer[address];

    setReadAddress(address);
    setReadAddress(address);
    return *vvdgBASd;
}

static void basVideoWriteByte(unsigned char bufferId, unsigned int address, unsigned char value)
{
    if (address >= BASIC_VDP_RAM_SIZE)
        return;

    if (bufferId == BASIC_VDP_BUFFER_RAM)
    {
        pStartVdpBuffer[address] = value;
        return;
    }

    setWriteAddress(address);
    *vvdgBASd = value;
}

static void basVideoPlotHiresToBuffer(unsigned char bufferId, unsigned char x, unsigned char y, unsigned char color1, unsigned char color2)
{
    unsigned int offset;
    unsigned int posX;
    unsigned int posY;
    unsigned int modY;
    unsigned char pixel;
    unsigned char color;

    posX = (unsigned int)(8 * (x / 8));
    posY = (unsigned int)(256 * (y / 8));
    modY = (unsigned int)(y % 8);
    offset = posX + modY + posY;

    pixel = basVideoReadByte(bufferId, paintPatternTable + offset);
    color = basVideoReadByte(bufferId, paintColorTable + offset);

    if (color1 != 0x00)
    {
        pixel |= 0x80 >> (x % 8);
        color = (color & 0x0F) | (color1 << 4);
    }
    else
    {
        pixel &= ~(0x80 >> (x % 8));
        color = (color & 0xF0) | (color2 & 0x0F);
    }

    basVideoWriteByte(bufferId, paintPatternTable + offset, pixel);
    basVideoWriteByte(bufferId, paintColorTable + offset, color);
}

static void basVideoPlotHires(unsigned char x, unsigned char y, unsigned char color1, unsigned char color2)
{
    basVideoPlotHiresToBuffer(basVideoActiveBuffer(), x, y, color1, color2);
}

static unsigned char basVideoReadPixelFromBuffer(unsigned char bufferId, unsigned char x, unsigned char y)
{
    unsigned int offset;
    unsigned char pixel;
    unsigned char color;

    offset = (unsigned int)(8 * (x / 8)) + (unsigned int)(y % 8) + (unsigned int)(256 * (y / 8));
    pixel = basVideoReadByte(bufferId, paintPatternTable + offset);
    color = basVideoReadByte(bufferId, paintColorTable + offset);

    if (pixel & (0x80 >> (x % 8)))
        return (color >> 4) & 0x0F;

    return color & 0x0F;
}

static unsigned char basVideoReadPixel(unsigned char x, unsigned char y)
{
    return basVideoReadPixelFromBuffer(basVideoActiveBuffer(), x, y);
}

static void basVideoCopyRect(unsigned char orig, unsigned char dest, unsigned char x1, unsigned char y1, unsigned char x2, unsigned char y2)
{
    unsigned int y;
    unsigned int byteXStart;
    unsigned int byteXEnd;
    unsigned int byteX;
    unsigned int bitStart;
    unsigned int bitEnd;
    unsigned int bit;
    unsigned int posY;
    unsigned int modY;
    unsigned int offset;
    unsigned int posX;
    unsigned char mask;
    unsigned char srcPattern;
    unsigned char srcColor;
    unsigned char dstPattern;
    unsigned char dstColor;

    byteXStart = ((unsigned int)x1) >> 3;
    byteXEnd = ((unsigned int)x2) >> 3;

    for (y = y1; y <= y2; y++)
    {
        posY = (unsigned int)(256 * (y / 8));
        modY = (unsigned int)(y % 8);

        for (byteX = byteXStart; byteX <= byteXEnd; byteX++)
        {
            bitStart = 0;
            bitEnd = 7;

            if (byteX == byteXStart)
                bitStart = (unsigned int)(x1 & 0x07);

            if (byteX == byteXEnd)
                bitEnd = (unsigned int)(x2 & 0x07);

            mask = 0x00;
            for (bit = bitStart; bit <= bitEnd; bit++)
                mask |= (unsigned char)(0x80 >> bit);

            posX = byteX << 3;
            offset = posX + modY + posY;

            srcPattern = basVideoReadByte(orig, paintPatternTable + offset);
            srcColor = basVideoReadByte(orig, paintColorTable + offset);

            if (mask == 0xFF)
            {
                dstPattern = srcPattern;
                dstColor = srcColor;
            }
            else
            {
                /* Borda parcial: limpa byte inteiro e copia apenas os bits do recorte. */
                dstPattern = (unsigned char)(srcPattern & mask);
                dstColor = (unsigned char)(srcColor & 0xF0);
            }

            basVideoWriteByte(dest, paintPatternTable + offset, dstPattern);
            basVideoWriteByte(dest, paintColorTable + offset, dstColor);

            if (byteX == 31)
                break;
        }

        if (y == 191)
            break;
    }
}

static void basPaintSyncTables(void)
{
    vdp_get_cfg(&paintPatternTable, &paintColorTable);
}

static unsigned int spriteHandleCache[256] = {0};
static unsigned char spriteSizeSelBas = 0;

static void basSpriteResetCache(void)
{
    memset(spriteHandleCache, 0x00, sizeof(spriteHandleCache));
}

static unsigned int basSpritePatternLimit(void)
{
    if (spriteSizeSelBas)
        return 63;

    return 255;
}

static unsigned int basSpritePatternBytes(void)
{
    if (spriteSizeSelBas)
        return 32;

    return 8;
}

static unsigned int basSpriteResolveHandle(unsigned char spriteNumber)
{
    unsigned int handle;

    if (vdpModeBas == VDP_MODE_TEXT)
        return 0;

    handle = spriteHandleCache[spriteNumber];
    return handle;
}

//-----------------------------------------------------------------------------
// Principal
//-----------------------------------------------------------------------------
void main(void)
{
    unsigned char vRetInput;
    VDP_COLOR vdpcolor;
    unsigned char countTec = 0, vByte;
    unsigned char *vTemp;
    unsigned char *vBufptr = &vbufInput;
    unsigned char sqtdtam[20];

    // Timer para o Random
    *(vmfp + Reg_TADR) = 0xF5;  // 245
    *(vmfp + Reg_TACR) = 0x02;  // prescaler de 10. total 2,4576Mhz/10*245 = 1003KHz

    // Se veio do mmsjos, 1, então usa os que o mmsjos passou usando malloc
    if (*startBasic)
    {
        pStartSimpVar   = *startBasic0;   // Area Variaveis Simples
        pStartArrayVar  = *startBasic0 + 0x02000;   // Area Arrays
        pStartString    = *startBasic0 + 0x06000;   // Area Strings
        pStartProg      = *startBasic0 + 0x08000;   // Area Programa  deve ser 0x00810000
        pStartVdpBuffer = *startBasic0 + 0x10000;   // Area de Buffer para trabalhar os dados do video antes de enviar pra VRAM
        pStartXBasLoad  = *startBasic0 + 0x04000;   // Area onde será importado o programa em basic texto a ser tokenizado depois
        pStartStack     = *startBasic0 + 0x10000;   // Area variaveis sistema e stack pointer

        vMemTotalSimpVar = 8192;
        vMemTotalArrayVar = 24576;
        vMemTotalString = 32768;
        vMemTotalProg = 65536;
        vMemTotalXBasLoad = 65536;
        vMemTotalStack = 8192;

        if (*startBasic == 1)
            OSTaskSuspend(TASK_MMSJOS_MAIN);
    }
    else
    {
        #ifdef RUN_ON_FLASH
            pStartSimpVar        = 0x00800000;   // Area Variaveis Simples
            pStartArrayVar       = 0x00803000;   // Area Arrays
            pStartString         = 0x00810000;   // Area Strings
            pStartProg           = 0x00830000;   // Area Programa  deve ser 0x00810000
            pStartVdpBuffer      = 0x00870000;   // Area de Buffer para trabalhar os dados do video antes de enviar pra VRAM
            pStartXBasLoad       = 0x00890000;   // Area onde será importado o programa em basic texto a ser tokenizado depois
            pStartStack          = 0x008FE000;   // Area variaveis sistema e stack pointer

            vMemTotalSimpVar = 12288;
            vMemTotalArrayVar = 53248;
            vMemTotalString = 131072;
            vMemTotalProg = 393216;
            vMemTotalXBasLoad = 450560;
            vMemTotalStack = 8192;
        #else
            pStartSimpVar        = 0x00800000;   // Area Variaveis Simples
            pStartArrayVar       = 0x00803000;   // Area Arrays
            pStartString         = 0x00810000;   // Area Strings
            pStartProg           = 0x00830000;   // Area Programa  deve ser 0x00810000
            pStartVdpBuffer      = 0x00850000;   // Area de Buffer para trabalhar os dados do video antes de enviar pra VRAM
            pStartXBasLoad       = 0x008B0000;   // Area onde será importado o programa em basic texto a ser tokenizado depois
            pStartStack          = 0x008FE000;   // Area variaveis sistema e stack pointer

            vMemTotalSimpVar = 12288;
            vMemTotalArrayVar = 53248;
            vMemTotalString = 131072;
            vMemTotalProg = 393216;
            vMemTotalXBasLoad = 131072;
            vMemTotalStack = 8192;
        #endif
    }

    vMemTotalVdpBuffer = 16384;

    if (!*startBasic || *startBasic == 1)
    {
        if (!*startBasic)
            clearScr();
        else
            printText("\r\n\0");

        printText("MMSJ-BASIC v"versionBasic);
        printText("\r\n\0");

        printText("Utility (c) 2022-2026\r\n\0");

        printText("OK\r\n\0");
    }

    vbufInput[0] = '\0';
    *pProcess = 0x01;
    *pTypeLine = 0x00;
    *nextAddrLine = pStartProg;
    *firstLineNumber = 0;
    *addrFirstLineNumber = 0;
    *traceOn = 0;
    *debugOn = 0;
    *debug2on = 0;
    *lastHgrX = 0;
    *lastHgrY = 0;
    spriteSizeSelBas = 0;
    basVideoResetBufferState();
    //vdpcolor = vdp_get_color();
    vdpcolor.fg = VDP_WHITE;
    vdpcolor.bg = VDP_BLACK;
    vdpModeBas = VDP_MODE_TEXT; // Text
    fgcolorBasAnt = vdpcolor.fg;
    bgcolorBasAnt = vdpcolor.bg;
    vdpMaxCols = 39;
    vdpMaxRows = 23;

    if (*paramBasic == 0x00)
    {
        #ifdef INPUT_BASIC_TELA
            vdpEditLine[0] = 0x00;
            vdpEditLineLen = 0;
            vdpEditCursorPos = 0;
            vdpEditLineStartX = 0;
            vdpEditLineStartY = vdpEditFindNextInputRow();
            vdpEditLineEndY = vdpEditLineStartY;
            vdpEditCurX = vdpEditLineStartX;
            vdpEditCurY = vdpEditLineStartY;
            vdp_set_cursor(vdpEditCurX, vdpEditCurY);
            vdpEditCursorVisible = 0;
            vdpEditBlinkCount = 0;
            vdpEditCursorOn();

            while (*pProcess)
            {
                vRetInput = readChar();   // tua rotina que lê uma tecla

                if (vRetInput == 0x00)
                {
                    vdpEditBlinkCount++;
                    if (vdpEditBlinkCount >= VDP_EDIT_BLINK_TICKS)
                    {
                        vdpEditBlinkCount = 0;
                        vdpEditCursorToggle();
                    }

                    continue;
                }

                vdpEditBlinkCount = 0;
                vdpEditCursorOff();

                if (vRetInput == 0x1B)
                {
                    // ESC
                    vdpEditCursorOn();
                    break;
                }

                // Aqui não chama inputLineBasic. Aqui você processa tecla por tecla direto na tela.
                vdpEditProcessKey(vRetInput);

                vdpEditCursorOn();
            }
        #else
            // Prompt de comandos
            while (*pProcess)
            {
                vRetInput = inputLineBasic(128,'$');

                if (vbufInput[0] != 0x00 && (vRetInput == 0x0D || vRetInput == 0x0A))
                {
                    printText("\r\n\0");

                    processLine();

                    vbufInput[0] = 0x00;
                    vBufptr = &vbufInput;

                    if (!*pTypeLine && *pProcess)
                        printText("\r\nOK\0");

                    if (!*pTypeLine && *pProcess)
                        printText("\r\n\0");   // printText("\r\n>\0");
                }
                else if (vRetInput != 0x1B)
                {
                    printText("\r\n\0");
                }
            }
        #endif
    }
    else
    {
        // Carregar Arquivo do disco na memoria
        if (*startBasic != 2)
        {
            printText("Loading...\r\n");
        }

        // Limpando memoria
        memset(pStartXBasLoad,0x1A,vMemTotalXBasLoad);
        // Carrega do disco
        verro = 0x00;
        loadFile(paramBasic, (unsigned long*)pStartXBasLoad);
        if (!verro)
        {
            // Processar
            if (*startBasic != 2)
            {
                printText("Done.\r\n");
                printText("Processing...\r\n");
            }

            vTemp = pStartXBasLoad;

            while (1)
            {
                vByte = *vTemp++;

                if (vByte != 0x1A)
                {
                    if (vByte != 0xD && vByte != 0x0A)
                        *vBufptr++ = vByte;
                    else
                    {
                        vTemp++;
                        *vBufptr = 0x00;
                        vBufptr = &vbufInput;
                        if (*vbufInput == 0x00)
                            break;
                        processLine();
                    }
                }
                else
                    break;
            }

            vbufInput[0] = 0x00;
            vBufptr = &vbufInput;

            // Executar, se nao houve erros
            if (*startBasic != 2)
            {
                printText("Running...\r\n");
            }

            *vTemp = 0x00;
            runProg(vTemp);
        }
        else
        {
            printText("Loading File Error...\r\n\0");
        }
    }

    printText("\r\n\0");

    if (*startBasic == 1)
    {
        printText("Ok\r\n\0");
        printText("#>");
        OSTaskResume(TASK_MMSJOS_MAIN);
    }
}

/******************************************************************************************/
/* Secao de Processamento da linha, tokenização e execução                                */
/******************************************************************************************/
//-----------------------------------------------------------------------------
// pQtdInput - Quantidade a ser digitada, min 1 max 255
// pTipo - Tipo de entrada:
//                  input : $ - String, % - Inteiro (sem ponto), # - Real (com ponto), @ - Sem Cursor e Qualquer Coisa e sem enter
//                   edit : S - String, I - Inteiro (sem ponto), R - Real (com ponto)
//-----------------------------------------------------------------------------
unsigned char inputLineBasic(unsigned int pQtdInput, unsigned char pTipo)
{
    unsigned char *vbufptr = &vbufInput;
    unsigned char vtec, vtecant;
    int vRetProcCmd, iw, ix;
    int countCursor = 0;
    char pEdit = 0, pIns = 0, vbuftemp, vbuftemp2;
    int iPos = 0, iz = 0;
    unsigned short vantX, vantY;

    if (pQtdInput == 0)
        pQtdInput = 512;

    vtecant = 0x00;
    vbufptr = &vbufInput;

    // Entrada normal sempre começa com buffer limpo.
    if (pTipo != 'S' && pTipo != 'I' && pTipo != 'R')
        memset(vbufInput, 0x00, sizeof(vbufInput));

    // Se for Linha editavel apresenta a linha na tela
    if (pTipo == 'S' || pTipo == 'I' || pTipo == 'R')
    {
        // Apresenta a linha na tela, e posiciona o cursor na tela na primeira posicao valida
        iw = strlen(vbufInput) / 40;

        printText(vbufInput);

        videoCursorPosRowY -= iw;
        videoCursorPosColX = 0;
        pEdit = 1;
        iPos = 0;
        pIns = 0xFF;

        vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
    }

    if (pTipo != '@')
        showCursor();

    while (1)
    {
        // Piscar Cursor
        if (pTipo != '@')
        {
            switch (countCursor)
            {
                case 6000:
                    hideCursor();
                    if (pEdit)
                        printChar(vbufInput[iPos],0);
                    break;
                case 12000:
                    showCursor();
                    countCursor = 0;
                    break;
            }
            countCursor++;
        }

        // Inicia leitura
        vtec = readChar();

        if (pTipo == '@')
            return vtec;

        // Se nao for string ($ e S) ou Tudo (@), só aceita numeros
        if (pTipo != '$' && pTipo != 'S' && pTipo != '@' && vtec != '.' && vtec > 0x1F && (vtec < 0x30 || vtec > 0x39))
            vtec = 0;

        // So aceita ponto de for numero real (# ou R) ou string ($ ou S) ou tudo (@)
        if (vtec == '.' && pTipo != '#' && pTipo != '$' &&  pTipo != 'R' && pTipo != 'S' && pTipo != '@')
            vtec = 0;

        if (vtec)
        {
            // Prevenir sujeira no buffer ou repeticao
            if (vtec == vtecant)
            {
                if (countCursor % 300 != 0)
                    continue;
            }

            if (pTipo != '@')
            {
                hideCursor();

                if (pEdit)
                    printChar(vbufInput[iPos],0);
            }

            vtecant = vtec;

            if (vtec >= 0x20 && vtec != 0x7F)   // Caracter Printavel menos o DELete
            {
                if (!pEdit)
                {
                    // Digitcao Normal
                    if (vbufptr > &vbufInput + pQtdInput)
                    {
                        *vbufptr--;

                        if (pTipo != '@')
                            printChar(0x08, 1);
                    }

                    if (pTipo != '@')
                        printChar(vtec, 1);

                    *vbufptr++ = vtec;
                    *vbufptr = '\0';
                }
                else
                {
                    iw = strlen(vbufInput);

                    // Edicao de Linha
                    if (!pIns)
                    {
                        // Sem insercao de caracteres
                        if (iw < pQtdInput)
                        {
                            if (vbufInput[iPos] == 0x00)
                                vbufInput[iPos + 1] = 0x00;

                            vbufInput[iPos] = vtec;

                            printChar(vbufInput[iPos],0);
                        }
                    }
                    else
                    {
                        // Com insercao de caracteres
                        if ((iw + 1) <= pQtdInput)
                        {
                            // Copia todos os caracteres mais 1 pro final
                            vbuftemp2 = vbufInput[iPos];
                            vbuftemp = vbufInput[iPos + 1];
                            vantX = videoCursorPosColX;
                            vantY = videoCursorPosRowY;

                            printChar(vtec,1);

                            for (ix = iPos; ix <= iw ; ix++)
                            {
                                vbufInput[ix + 1] = vbuftemp2;
                                vbuftemp2 = vbuftemp;
                                vbuftemp = vbufInput[ix + 2];
                                printChar(vbufInput[ix + 1],1);
                            }

                            vbufInput[iw + 1] = 0x00;
                            vbufInput[iPos] = vtec;

                            videoCursorPosColX = vantX;
                            videoCursorPosRowY = vantY;
                            vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                        }
                    }

                    if (iw <= pQtdInput)
                    {
                        iPos++;
                        videoCursorPosColX = videoCursorPosColX + 1;
                        vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                    }
                }
            }
            /*else if (pEdit && vtec == 0x11)    // UpArrow (17)
            {
                // TBD
            }
            else if (pEdit && vtec == 0x13)    // DownArrow (19)
            {
                // TBD
            }*/
            else if (pEdit && vtec == 0x12)    // LeftArrow (18)
            {
                if (iPos > 0)
                {
                    printChar(vbufInput[iPos],0);
                    iPos--;
                    if (videoCursorPosColX == 0)
                        videoCursorPosColX = 255;
                    else
                        videoCursorPosColX = videoCursorPosColX - 1;
                    vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                }
            }
            else if (pEdit && vtec == 0x14)    // RightArrow (20)
            {
                if (iPos < strlen(vbufInput))
                {
                    printChar(vbufInput[iPos],0);
                    iPos++;
                    videoCursorPosColX = videoCursorPosColX + 1;
                    vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                }
            }
            else if (vtec == 0x15)  // Insert
            {
                pIns = ~pIns;
            }
            else if ((vtec == 0x08 || vtec == 0x7F) && !pEdit)  // Backspace/Delete
            {
                // Digitcao Normal
                if (vbufptr > &vbufInput)
                {
                    vbufptr--;
                    *vbufptr = 0x00;

                    if (pTipo != '@')
                        printChar(0x08, 1);
                }
            }
            else if ((vtec == 0x08 || vtec == 0x7F) && pEdit)  // Backspace
            {
                iw = strlen(vbufInput);

                if ((vtec == 0x08 && iPos > 0) || vtec == 0x7F)
                {
                    if (vtec == 0x08)
                    {
                        iPos--;

                        if (videoCursorPosColX == 0)
                            videoCursorPosColX = 255;
                        else
                            videoCursorPosColX = videoCursorPosColX - 1;
                        vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                    }

                    vantX = videoCursorPosColX;
                    vantY = videoCursorPosRowY;

                    for (ix = iPos; ix < iw ; ix++)
                    {
                        vbufInput[ix] = vbufInput[ix + 1];
                        printChar(vbufInput[ix],1);
                    }

                    vbufInput[ix] = 0x00;

                    videoCursorPosColX = vantX;
                    videoCursorPosRowY = vantY;
                    vdp_set_cursor(videoCursorPosColX, videoCursorPosRowY);
                }
            }
            else if (vtec == 0x1B)   // ESC
            {
                // Limpa a linha, esvazia o buffer e retorna tecla
                while (vbufptr > &vbufInput)
                {
                    *vbufptr--;
                    *vbufptr = 0x00;

                    if (pTipo != '@')
                        hideCursor();

                    if (pTipo != '@')
                        printChar(0x08, 1);

                    if (pTipo != '@')
                        showCursor();
                }
                hideCursor();

                return vtec;
            }
            else if (vtec == 0x0D || vtec == 0x0A ) // CR ou LF
            {
                return vtec;
            }

            if (pTipo != '@')
                showCursor();
        }
        else
        {
            vtecant = 0x00;
        }
    }

    return 0x00;
}

//-----------------------------------------------------------------------------
// Process line previous input after return
// If have number in start, is to store in program, if not, is command to execute
//-----------------------------------------------------------------------------
void processLine(void)
{
    unsigned char linhacomando[32], vloop, vToken;
    unsigned char *blin = &vbufInput;
    unsigned short varg = 0;
    unsigned short ix, iy, iz, ikk, kt;
    unsigned short vbytepic = 0, vrecfim;
    unsigned char cuntam, vLinhaArg[255], vparam2[16], vpicret;
    char vSpace = 0;
    int vReta;
    typeInf vRetInf;
    unsigned short vTam = 0;
    unsigned char *pSave = *nextAddrLine;
    unsigned long vNextAddr = 0;
    unsigned char vTimer;
    unsigned char vBuffer[20];
    unsigned char *vTempPointer;
    unsigned char sqtdtam[20];

    // Separar linha entre comando e argumento
    linhacomando[0] = '\0';
    vLinhaArg[0] = '\0';
    ix = 0;
    iy = 0;
    while (*blin)
    {
        if (!varg && *blin >= 0x20 && *blin <= 0x2F)
        {
            varg = 0x01;
            linhacomando[ix] = '\0';
            iy = ix;
            ix = 0;

            if (*blin != 0x20)
                vLinhaArg[ix++] = *blin;
            else
                vSpace = 1;
        }
        else
        {
            if (!varg)
                linhacomando[ix] = *blin;
            else
                vLinhaArg[ix] = *blin;
            ix++;
        }

        *blin++;
    }

    if (!varg)
    {
        linhacomando[ix] = '\0';
        iy = ix;
    }
    else
        vLinhaArg[ix] = '\0';

    vpicret = 0;

    // Processar e definir o que fazer
    if (linhacomando[0] != 0)
    {
        // Se for numero o inicio da linha, eh entrada de programa, senao eh comando direto
        if (linhacomando[0] >= 0x31 && linhacomando[0] <= 0x39) // 0 nao é um numero de linha valida
        {
            *pTypeLine = 0x01;

            // Entrada de programa
            tokenizeLine(vLinhaArg);
            saveLine(linhacomando, vLinhaArg);
        }
        else
        {
            *pTypeLine = 0x00;

            for (iz = 0; iz < iy; iz++)
                linhacomando[iz] = toupper(linhacomando[iz]);

            // Comando Direto
            if (!strcmp(linhacomando,"CLS") && iy == 3)
            {
                clearScr();
            }
            else if (!strcmp(linhacomando,"NEW") && iy == 3)
            {
                *pStartProg = 0x00;
                *(pStartProg + 1) = 0x00;
                *(pStartProg + 2) = 0x00;

                *nextAddrLine = pStartProg;
                *firstLineNumber = 0;
                *addrFirstLineNumber = 0;

                *nextAddrSimpVar = pStartSimpVar;
                *nextAddrArrayVar = pStartArrayVar;
                *nextAddrString = pStartString;

                clearRuntimeData((unsigned char*)forStack);
            }
            else if (!strcmp(linhacomando,"EDIT") && iy == 4)
            {
                editLine(vLinhaArg);
            }
            else if (!strcmp(linhacomando,"LIST") && iy == 4)
            {
                listProg(vLinhaArg, 0);
            }
            else if (!strcmp(linhacomando,"LISTP") && iy == 5)
            {
                listProg(vLinhaArg, 1);
            }
            else if (!strcmp(linhacomando,"RUN") && iy == 3)
            {
                runProg(vLinhaArg);
            }
            else if (!strcmp(linhacomando,"DEL") && iy == 3)
            {
                delLine(vLinhaArg);
            }
            else if (!strcmp(linhacomando,"LOAD") && iy == 4 && *startBasic == 1)
            {
                loadBasFile(vLinhaArg);
            }
            else if (!strcmp(linhacomando,"SAVE") && iy == 4 && *startBasic == 1)
            {
                saveBasFile(vLinhaArg);
            }
            else if (!strcmp(linhacomando,"XLOAD") && iy == 5)
            {
                basXBasLoad();
            }
            else if (!strcmp(linhacomando,"XLOAD1K") && iy == 7)
            {
                basXBasLoad1k();
            }
            else if (!strcmp(linhacomando,"TIMER") && iy == 5)
            {
                // Ler contador A do 68901
                vTimer = *(vmfp + Reg_TADR);

                // Devolve pra tela
                itoa(vTimer,vBuffer,10);
                printText("Timer: ");
                printText(vBuffer);
                printText("ms\r\n\0");
            }
            else if (!strcmp(linhacomando,"TRACEON") && iy == 7)
            {
                *traceOn = 1;
            }
            else if (!strcmp(linhacomando,"TRACEOFF") && iy == 8)
            {
                *traceOn = 0;
            }
            else if (!strcmp(linhacomando,"DEBUGON") && iy == 7)
            {
                *debugOn = 1;
            }
            else if (!strcmp(linhacomando,"DEBUGOFF") && iy == 8)
            {
                *debugOn = 0;
            }
            else if (!strcmp(linhacomando,"LISTMEM") && iy == 7)
            {
                itoa(pStartSimpVar,sqtdtam,16);
                printText("pStartSimpVar  \0"); printText(sqtdtam); printText("h\r\n\0");
                itoa(pStartArrayVar,sqtdtam,16);
                printText("pStartArrayVar \0"); printText(sqtdtam); printText("h\r\n\0");
                itoa(pStartString,sqtdtam,16);
                printText("pStartString   \0"); printText(sqtdtam); printText("h\r\n\0");
                itoa(pStartProg,sqtdtam,16);
                printText("pStartProg     \0"); printText(sqtdtam); printText("h\r\n\0");
                itoa(pStartXBasLoad,sqtdtam,16);
                printText("pStartXBasLoad \0"); printText(sqtdtam); printText("h\r\n\0");
                itoa(pStartStack,sqtdtam,16);
                printText("pStartStack    \0"); printText(sqtdtam); printText("h\r\n\0");
            }
            // *************************************************
            // ESSE COMANDO NAO VAI EXISTIR QUANDO FOR PRA BIOS
            // *************************************************
            else if (!strcmp(linhacomando,"QUIT") && iy == 4)
            {
                *pProcess = 0x00;
            }
            // *************************************************
            // *************************************************
            // *************************************************
            else
            {
                // Tokeniza a linha toda
                strcpy(vRetInf.tString, linhacomando);

                if (vSpace)
                    strcat(vRetInf.tString, " ");

                strcat(vRetInf.tString, vLinhaArg);

if (*debugOn)
{
    writeLongSerial("Aqui 434.666.0 [\0");
    writeLongSerial(vRetInf.tString);
    writeLongSerial("]-[");
    writeLongSerial(linhacomando);
    writeLongSerial("]\r\n\0");
}

                tokenizeLine(vRetInf.tString);

                // Salva a linha pra ser interpretada
                    vTam = strlen(vRetInf.tString);
                vNextAddr = comandLineTokenized + (vTam + 6);

                *comandLineTokenized = ((vNextAddr & 0xFF0000) >> 16);
                *(comandLineTokenized + 1) = ((vNextAddr & 0xFF00) >> 8);
                *(comandLineTokenized + 2) =  (vNextAddr & 0xFF);

                // Grava numero da linha
                *(comandLineTokenized + 3) = 0xFF;
                *(comandLineTokenized + 4) = 0xFF;

                // Grava linha tokenizada
                for(kt = 0; kt < vTam; kt++)
                    *(comandLineTokenized + (kt + 5)) = vRetInf.tString[kt];

                // Grava final linha 0x00
                *(comandLineTokenized + (vTam + 5)) = 0x00;
                *(comandLineTokenized + (vTam + 6)) = 0x00;
                *(comandLineTokenized + (vTam + 7)) = 0x00;
                *(comandLineTokenized + (vTam + 8)) = 0x00;

                *nextAddrSimpVar = pStartSimpVar;
                *nextAddrArrayVar = pStartArrayVar;
                *nextAddrString = pStartString;
                invalidateFindVariableCache();
                *vMaisTokens = 0;
                *vParenteses = 0x00;
                *vTemIf = 0x00;
                *vTemThen = 0;
                *vTemElse = 0;
                *vTemIfAndOr = 0x00;

                *pointerRunProg = comandLineTokenized + 5;

                vRetInf.tString[0] = 0x00;
                *ftos=0;
                *gtos=0;
                *vErroProc = 0;
                *randSeed = *(vmfp + Reg_TADR);
                do
                {
                    *doisPontos = 0;
                    *vInicioSentenca = 1;
                    vTempPointer = *pointerRunProg;
                    *pointerRunProg = *pointerRunProg + 1;
                    vReta = executeToken(*vTempPointer);
                } while (*doisPontos);

#ifndef __TESTE_TOKENIZE__
                if (vdpModeBas != VDP_MODE_TEXT)
                    basText();
#endif
                if (*vErroProc)
                {
                    showErrorMessage(*vErroProc, 0);
                }
            }
        }
    }
}

//-----------------------------------------------------------------------------
// Transforma linha em tokens, se existirem
//-----------------------------------------------------------------------------
void tokenizeLine(unsigned char *pTokenized)
{
    unsigned char vLido[255], vLidoCaps[255], vAspas, vAchou = 0;
    unsigned char *blin = pTokenized;
    unsigned short ix, iy, kt, iz, iw;
    unsigned char vToken, vLinhaArg[255], vparam2[16], vpicret;
    char vBuffer [sizeof(long)*8+1];
    char vFirstComp = 0;
    char isToken;
    char vTemRem = 0;
//    unsigned char sqtdtam[20];

    // Separar linha entre comando e argumento
    vLinhaArg[0] = '\0';
    vLido[0]  = '\0';
    ix = 0;
    iy = 0;
    vAspas = 0;

    while (1)
    {
        vLido[ix] = '\0';

        if (*blin == 0x22)
            vAspas = !vAspas;

        // Se for quebrador sequencia, verifica se é um token
        if ((!vTemRem && !vAspas && strchr(" ;,+-<>()/*^=:",*blin)) || !*blin)
        {
            // Montar comparacoes "<>", ">=" e "<="
            if (((*blin == 0x3C || *blin == 0x3E) && (!vFirstComp && (*(blin + 1) == 0x3E || *(blin + 1) == 0x3D))) || (vFirstComp && *blin == 0x3D) || (vFirstComp && *blin == 0x3E))
            {
                if (!vFirstComp)
                {
                    for(kt = 0; kt < ix; kt++)
                        vLinhaArg[iy++] = vLido[kt];
                    vLido[0] = 0x00;
                    ix = 0;
                    vFirstComp = 1;
                }

                vLido[ix++] = *blin;

                if (ix < 2)
                {
                    blin++;

                    continue;
                }

                vFirstComp = 0;
            }

            if (vLido[0])
            {
                vToken = 0;
/*writeLongSerial("Aqui 332.666.2-[");
itoa(ix,sqtdtam,10);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*blin,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

                if (ix > 1)
                {
                    // Transforma em Caps pra comparar com os tokens
                    for (kt = 0; kt < ix; kt++)
                        vLidoCaps[kt] = toupper(vLido[kt]);

                    vLidoCaps[ix] = 0x00;

                    iz = strlen(vLidoCaps);

					// Compara pra ver se é um token
					for(kt = 0; kt < keywords_count; kt++)
					{
						iw = strlen(keywords[kt].keyword);

                        if (iw == 2 && iz == iw)
                        {
                            if (vLidoCaps[0] == keywords[kt].keyword[0] && vLidoCaps[1] == keywords[kt].keyword[1])
                            {
                                vToken = keywords[kt].token;
                                break;
                            }
                        }
                        else if (iz==iw)
                        {
                            if (strncmp(vLidoCaps, keywords[kt].keyword, iw) == 0)
                            {
                                vToken = keywords[kt].token;
                                break;
                            }
                        }
					}
                }

                if (vToken)
                {
                    if (vToken == 0x8C) // REM
                        vTemRem = 1;

                    vLinhaArg[iy++] = vToken;

                    //if (*blin == 0x28 || *blin == 0x29)
                    //    vLinhaArg[iy++] = *blin;

                    //if (*blin == 0x3A)  // :
                    if (*blin && *blin != 0x20 && vToken < 0xF0 && !vTemRem)
                        vLinhaArg[iy++] = toupper(*blin);
                }
                else
                {
                    for(kt = 0; kt < ix; kt++)
                        vLinhaArg[iy++] = vLido[kt];

                    if (*blin && *blin != 0x20)
                        vLinhaArg[iy++] = toupper(*blin);
                }
            }
            else
            {
                if (*blin && *blin != 0x20)
                    vLinhaArg[iy++] = toupper(*blin);
            }

            if (!*blin)
                break;

            vLido[0] = '\0';
            ix = 0;
        }
        else
        {
            if (!vAspas && !vTemRem)
                vLido[ix++] = toupper(*blin);
            else
                vLido[ix++] = *blin;
        }

        blin++;
    }

    vLinhaArg[iy] = 0x00;

    for(kt = 0; kt < iy; kt++)
        pTokenized[kt] = vLinhaArg[kt];

    pTokenized[iy] = 0x00;
}

//-----------------------------------------------------------------------------
// Salva a linha no formato:
// NN NN NN LL LL xxxxxxxxxxxx 00
// onde:
//      NN NN NN         = endereco da proxima linha
//      LL LL            = Numero da linha
//      xxxxxxxxxxxxxx   = Linha Tokenizada
//      00               = Indica fim da linha
//-----------------------------------------------------------------------------
void saveLine(unsigned char *pNumber, unsigned char *pTokenized)
{
    unsigned short vTam = 0, kt;
    unsigned char *pSave = *nextAddrLine;
    unsigned long vNextAddr = 0, vAntAddr = 0, vNextAddr2 = 0;
    unsigned short vNumLin = 0;
    unsigned char *pAtu = *nextAddrLine, *pLast = *nextAddrLine;

    vNumLin = atoi(pNumber);

    if (*firstLineNumber == 0)
    {
        *firstLineNumber = vNumLin;
        *addrFirstLineNumber = pStartProg;
    }
    else
    {
        vNextAddr = findNumberLine(vNumLin, 0, 0);

        if (vNextAddr > 0)
        {
            pAtu = vNextAddr;

            if (((*(pAtu + 3) << 8) | *(pAtu + 4)) == vNumLin)
            {
                printText("Line number already exists\r\n\0");
                return;
            }

            vAntAddr = findNumberLine(vNumLin, 1, 0);
        }
    }

    vTam = strlen(pTokenized);
    if (vTam)
    {
        // Calcula nova posicao da proxima linha
        if (vNextAddr == 0)
        {
            *nextAddrLine += (vTam + 6);
            vNextAddr = *nextAddrLine;

            *addrLastLineNumber = pSave;
        }
        else
        {
            if (*firstLineNumber > vNumLin)
            {
                *firstLineNumber = vNumLin;
                *addrFirstLineNumber = *nextAddrLine;
            }

            *nextAddrLine += (vTam + 6);
            vNextAddr2 = *nextAddrLine;

            if (vAntAddr != vNextAddr)
            {
                pLast = vAntAddr;
                vAntAddr = pSave;
                *pLast       = ((vAntAddr & 0xFF0000) >> 16);
                *(pLast + 1) = ((vAntAddr & 0xFF00) >> 8);
                *(pLast + 2) =  (vAntAddr & 0xFF);
            }

            pLast = *addrLastLineNumber;
            *pLast       = ((vNextAddr2 & 0xFF0000) >> 16);
            *(pLast + 1) = ((vNextAddr2 & 0xFF00) >> 8);
            *(pLast + 2) =  (vNextAddr2 & 0xFF);
        }

        pAtu = *nextAddrLine;
        *pAtu       = 0x00;
        *(pAtu + 1) = 0x00;
        *(pAtu + 2) = 0x00;
        *(pAtu + 3) = 0x00;
        *(pAtu + 4) = 0x00;

        // Grava endereco proxima linha
        *pSave++ = ((vNextAddr & 0xFF0000) >> 16);
        *pSave++ = ((vNextAddr & 0xFF00) >> 8);
        *pSave++ =  (vNextAddr & 0xFF);

        // Grava numero da linha
        *pSave++ = ((vNumLin & 0xFF00) >> 8);
        *pSave++ = (vNumLin & 0xFF);

        // Grava linha tokenizada
        for(kt = 0; kt < vTam; kt++)
            *pSave++ = *pTokenized++;

        // Grava final linha 0x00
        *pSave = 0x00;
    }
}

static unsigned short basBuildListTextLine(unsigned char *pTokenLine, unsigned char *pOutLine, unsigned short pOutMax, unsigned short *pWrapRows)
{
    unsigned short vNumLin;
    char sNumLin[sizeof(short) * 8 + 1];
    unsigned char vToken;
    unsigned char vFirstByte;
    int ix, iy, iz;

    vNumLin = (*(pTokenLine + 3) << 8) | *(pTokenLine + 4);
    pTokenLine += 5;
    ix = 0;

    itoa(vNumLin, sNumLin, 10);
    iz = 0;
    while (sNumLin[iz] && ix < (pOutMax - 1))
        pOutLine[ix++] = sNumLin[iz++];

    if (ix < (pOutMax - 1))
        pOutLine[ix++] = 0x20;

    vFirstByte = 1;

    while (*pTokenLine && ix < (pOutMax - 3))
    {
        vToken = *pTokenLine++;

        if (vToken >= 0x80)
        {
            iy = findToken(vToken);
            iz = 0;

            if (!vFirstByte)
            {
                if (isalphas(*(pTokenLine - 2)) || isdigitus(*(pTokenLine - 2)) || *(pTokenLine - 2) == ')')
                    pOutLine[ix++] = 0x20;
            }
            else
                vFirstByte = 0;

            while (keywords[iy].keyword[iz] && ix < (pOutMax - 1))
                pOutLine[ix++] = keywords[iy].keyword[iz++];

            if (*pTokenLine != '=' && (vToken < 0xC0 || vToken > 0xEF) && ix < (pOutMax - 1))
                pOutLine[ix++] = 0x20;
        }
        else
        {
            pOutLine[ix++] = vToken;

            if (vToken == 0x22 && *pTokenLine >= 0x80 && ix < (pOutMax - 1))
                pOutLine[ix++] = 0x20;
        }
    }

    pOutLine[ix] = '\0';

    if (pWrapRows)
        *pWrapRows = strlen(pOutLine) / 40;

    if (ix < (pOutMax - 2))
    {
        pOutLine[ix++] = '\r';
        pOutLine[ix++] = '\n';
        pOutLine[ix] = '\0';
    }

    return (unsigned short)ix;
}

//-----------------------------------------------------------------------------
// Sintaxe:
//      LIST                : lista tudo
//      LIST <num>          : lista só a linha <num>
//      LIST <num>-         : lista a partir da linha <num>
//      LIST <numA>-<numB>  : lista o intervalo de <numA> até <numB>, inclusive
//
//      LISTP : mesmo que LIST, mas com pausa a cada scroll
//-----------------------------------------------------------------------------
void listProg(unsigned char *pArg, unsigned short pPause)
{
    // Default listar tudo
    unsigned short pIni = 0, pFim = 0xFFFF;
    unsigned char *vStartList = pStartProg;
    unsigned long vNextList;
    unsigned short vNumLin;
    unsigned char vtec;
    unsigned char vLinhaList[255], sNumPar[10];
    unsigned short iw = 0;
    int ix, iy, iz, vPauseRowCounter;
    unsigned char sqtdtam[20];

    if (pArg[0] != 0x00 && strchr(pArg,'-') != 0x00)
    {
        ix = 0;
        iy = 0;

        // listar intervalo
        while (pArg[ix] != '-')
            sNumPar[iy++] = pArg[ix++];

        sNumPar[iy] = 0x00;

        pIni = atoi(sNumPar);

        iy = 0;
        ix++;

        while (pArg[ix])
            sNumPar[iy++] = pArg[ix++];

        sNumPar[iy] = 0x00;

        if (sNumPar[0])
            pFim = atoi(sNumPar);
        else
            pFim = 0xFFFF;
    }
    else if (pArg[0] != 0x00)
    {
        // listar 1 linha
        pIni = atoi(pArg);
        pFim = pIni;
    }

    vStartList = findNumberLine(pIni, 0, 0);

    // Nao achou numero de linha inicial
    if (!vStartList)
    {
        printText("Non-existent line number\r\n\0");
        return;
    }

    vNextList = vStartList;
    vPauseRowCounter = 0;

    while (1)
    {
        // Guarda proxima posicao
        vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);

        if (vNextList)
        {
            // Pega numero da linha
            vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);

            if (vNumLin > pFim)
                break;

            basBuildListTextLine(vStartList, vLinhaList, sizeof(vLinhaList), &iw);

            printText(vLinhaList);

            vPauseRowCounter = vPauseRowCounter + 1 + iw;

            if (pPause && vPauseRowCounter >= vdpMaxRows)
            {
                printText("press any key to continue\0");
                vtec = inputLineBasic(1,"@");
                vPauseRowCounter = 0;
                printText("\r\n\0");
                if (vtec == 0x1B)   // ESC
                    break;
            }

            vStartList = vNextList;
        }
        else
            break;
    }
}

//-----------------------------------------------------------------------------
// Sintaxe:
//      DEL <num>          : apaga só a linha <num>
//      DEL <num>-         : apaga a partir da linha <num> até o fim
//      DEL <numA>-<numB>  : apaga o intervalo de <numA> até <numB>, inclusive
//-----------------------------------------------------------------------------
void delLine(unsigned char *pArg)
{
    unsigned short pIni = 0, pFim = 0xFFFF;
    unsigned char *vStartList = pStartProg;
    unsigned long vDelAddr, vAntAddr, vNewAddr;
    unsigned short vNumLin;
    char sNumLin [sizeof(short)*8+1];
    unsigned char vLinhaList[255], sNumPar[10], vToken;
    int ix, iy, iz;

    if (pArg[0] != 0x00 && strchr(pArg,'-') != 0x00)
    {
        ix = 0;
        iy = 0;

        // listar intervalo
        while (pArg[ix] != '-')
            sNumPar[iy++] = pArg[ix++];

        sNumPar[iy] = 0x00;

        pIni = atoi(sNumPar);

        iy = 0;
        ix++;

        while (pArg[ix])
            sNumPar[iy++] = pArg[ix++];

        sNumPar[iy] = 0x00;

        if (sNumPar[0])
            pFim = atoi(sNumPar);
        else
            pFim = 0xFFFF;
    }
    else if (pArg[0] != 0x00)
    {
        pIni = atoi(pArg);
        pFim = pIni;
    }
    else
    {
        printText("Syntax Error !");
        return;
    }

    vDelAddr = findNumberLine(pIni, 0, 1);

    if (!vDelAddr)
    {
        printText("Non-existent line number\r\n\0");
        return;
    }

    while (1)
    {
        vStartList = vDelAddr;

        // Guarda proxima posicao
        vNewAddr = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);

        if (!vNewAddr)
            break;

        // Pega numero da linha
        vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);

        if (vNumLin > pFim)
            break;

        vAntAddr = findNumberLine(vNumLin, 1, 1);

        // Apaga a linha atual
        *vStartList       = 0x00;
        *(vStartList + 1) = 0x00;
        *(vStartList + 2) = 0x00;
        *(vStartList + 3) = 0x00;
        *(vStartList + 4) = 0x00;

        vStartList += 5;

        while (*vStartList)
            *vStartList++ = 0x00;

        vStartList = vAntAddr;
        *vStartList++ = ((vNewAddr & 0xFF0000) >> 16);
        *vStartList++ = ((vNewAddr & 0xFF00) >> 8);
        *vStartList++ =  (vNewAddr & 0xFF);

        // Se for a primeira linha, reposiciona na proxima
        if (*firstLineNumber == vNumLin)
        {
            if (vNewAddr)
            {
                vStartList = vNewAddr;

                // Pega numero da linha
                vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);

                *firstLineNumber = vNumLin;
                *addrFirstLineNumber = vNewAddr;
            }
            else
            {
                *pStartProg = 0x00;
                *(pStartProg + 1) = 0x00;
                *(pStartProg + 2) = 0x00;

                *nextAddrLine = pStartProg;
                *firstLineNumber = 0;
                *addrFirstLineNumber = 0;
            }
        }

        if (!vNewAddr)
            break;

        vDelAddr = vNewAddr;
    }
}


//-----------------------------------------------------------------------------
// Sintaxe:
//      EDIT <num>          : Edita conteudo da linha <num>
// PS Ainda precisa ser ajustado
//-----------------------------------------------------------------------------
void editLine(unsigned char *pNumber)
{
    int pIni = 0, ix, iy, iz, iw, ivv, vNumLin, pFim;
    unsigned char *vStartList = pStartProg, *vNextList;
    unsigned char vRetInput;
    char sNumLin [sizeof(short)*8+1], vFirstByte;
    unsigned char vLinhaList[255], sNumPar[10], vToken;

    if (pNumber[0] != 0x00)
    {
        // rodar desde uma linha especifica
        pIni = atoi(pNumber);
    }
    else
    {
        printText("Syntax Error !");
        return;
    }

    vStartList = findNumberLine(pIni, 0, 0);

    // Nao achou numero de linha inicial
    if (!vStartList)
    {
        printText("Non-existent line number\r\n\0");
        return;
    }

    // Carrega a linha no buffer
    // Guarda proxima posicao
    vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
	ix = 0;
    ivv = 0;

    if (vNextList)
    {
        // Pega numero da linha
        vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);

        vStartList += 5;

        // Coloca numero da linha na listagem
        itoa(vNumLin, sNumLin, 10);
        iz = 0;

        while (sNumLin[iz++])
        {
            vLinhaList[ivv] = sNumLin[ivv];
            ivv++;
        }

        vLinhaList[ivv] = '\r';
        vLinhaList[ivv + 1] = '\n';
        vLinhaList[ivv + 2] = '\0';

        printText(vLinhaList);

        vFirstByte = 1;
        vbufInput[ix] = 0x00;
        ix = 0;

        // Pega caracter a caracter da linha
        while (*vStartList)
        {
            vToken = *vStartList++;

            // Verifica se é token, se for, muda pra escrito
            if (vToken >= 0x80)
            {
                // Procura token na lista
                iy = findToken(vToken);
                iz = 0;

                if (!vFirstByte)
                {
                    if (isalphas(*(vStartList - 2)) || isdigitus(*(vStartList - 2)) || *(vStartList - 2) == ')')
                        vbufInput[ix++] = 0x20;
                }
                else
                    vFirstByte = 0;

                while (keywords[iy].keyword[iz])
                {
                    vbufInput[ix++] = keywords[iy].keyword[iz++];
                }

                // Se nao for intervalo de funcao, coloca espaço depois do comando
                if (*vStartList != '=' && (vToken < 0xC0 || vToken > 0xEF))
                    vbufInput[ix++] = 0x20;
            }
            else
            {
                vbufInput[ix++] = vToken;

                // Se nao for aspas e o proximo for um token, inclui um espaço
                if (vToken == 0x22 && *vStartList >=0x80)
                    vbufInput[ix++] = 0x20;            }
        }
    }

    vbufInput[ix] = '\0';

    // Edita a linha no buffer, usando o inputLineBasic do monitor.c
    vRetInput = inputLineBasic(128,'S'); // S - String Linha Editavel

    if (vbufInput[0] != 0x00 && (vRetInput == 0x0D || vRetInput == 0x0A))
    {
        vLinhaList[ivv++] = 0x20;
        ix = strlen(vbufInput);

        for(iz = 0; iz <= ix; iz++)
            vLinhaList[ivv++] = vbufInput[iz];

        vLinhaList[ivv] = 0x00;

        for(iz = 0; iz <= ivv; iz++)
            vbufInput[iz] = vLinhaList[iz];

        printText("\r\n\0");

        // Apaga a linha atual
        delLine(pNumber);

        // Reinsere a linha editada
        processLine();

        printText("\r\nOK\0");

        printText("\r\n\0");
    }
    else if (vRetInput != 0x1B)
    {
        printText("\r\nAborted !!!\r\n\0");
    }
}

//-----------------------------------------------------------------------------
// Sintaxe:
//      RUN                : Executa o programa a partir da primeira linha do prog
//      RUN <num>          : Executa a partir da linha <num>
//-----------------------------------------------------------------------------
void runProg(unsigned char *pNumber)
{
    // Default rodar desde a primeira linha
    int pIni = 0, ix;
    unsigned char *vStartList = pStartProg;
    unsigned long vNextList;
    unsigned short vNumLin;
    unsigned int vInt;
    unsigned char vString[255], vTipoRet;
    unsigned long vReal;
    typeInf vRetInf;
    unsigned int vReta;
    char sNumLin [sizeof(short)*8+1];
    char vBuffer [sizeof(long)*8+1];
    unsigned char *vPointerChangedPointer;
    unsigned char *pForStack = forStack;
    unsigned char sqtdtam[20];
    unsigned char *vTempPointer;
    unsigned char vBufRec;

    *nextAddrSimpVar = pStartSimpVar;
    *nextAddrArrayVar = pStartArrayVar;
    *nextAddrString = pStartString;

    clearRuntimeData(pForStack);

    if (pNumber[0] != 0x00)
    {
        // rodar desde uma linha especifica
        pIni = atoi(pNumber);
    }

    vStartList = findNumberLine(pIni, 0, 0);

    // Nao achou numero de linha inicial
    if (!vStartList)
    {
        printText("Non-existent line number\r\n\0");
        return;
    }

    vNextList = vStartList;

    *ftos=0;
    *gtos=0;
    *changedPointer = 0;
    *vDataPointer = 0;
    *randSeed = *(vmfp + Reg_TADR);
    *onErrGoto = 0;

    while (1)
    {
        if (*changedPointer!=0)
            vStartList = *changedPointer;

        // Guarda proxima posicao
        vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
        *nextAddr = vNextList;

        if (vNextList)
        {
            // Pega numero da linha
            vNumLin = (*(vStartList + 3) << 8) | *(vStartList + 4);

            vStartList += 5;

            // Pega caracter a caracter da linha
            *changedPointer = 0;
            *vMaisTokens = 0;
            *vParenteses = 0x00;
            *vTemIf = 0x00;
            *vTemThen = 0;
            *vTemElse = 0;
            *vTemIfAndOr = 0x00;
            vRetInf.tString[0] = 0x00;

            *pointerRunProg = vStartList;

            *vErroProc = 0;

            do
            {
                vBufRec = readChar();
                if (vBufRec==27)
                {
                    // volta para modo texto
#ifndef __TESTE_TOKENIZE__
                    if (vdpModeBas != VDP_MODE_TEXT)
                        basText();
#endif
                    // mostra mensagem de para subita
                    printText("\r\nStopped at ");
                    itoa(vNumLin, sNumLin, 10);
                    printText(sNumLin);
                    printText("\r\n");

                    // sai do laço
                    *nextAddr = 0;
                    break;
                }

                *doisPontos = 0;
                *vParenteses = 0x00;
                *vInicioSentenca = 1;

                if (*traceOn)
                {
                    printText("\r\nExecuting at ");
                    itoa(vNumLin, sNumLin, 10);
                    printText(sNumLin);
                    printText("\r\n");
                }

                vTempPointer = *pointerRunProg;
                *pointerRunProg = *pointerRunProg + 1;
                vReta = executeToken(*vTempPointer);

                if (*vErroProc)
                {
                    if (*onErrGoto == 0)
                        break;

                    *vErroProc = 0;
                    *changedPointer = *onErrGoto;
                }

                if (*changedPointer!=0)
                {
                    vPointerChangedPointer = *changedPointer;

                    if (*vPointerChangedPointer == 0x3A)
                    {
                        *pointerRunProg = *changedPointer;
                        *changedPointer = 0;
                    }
                }

                vTempPointer = *pointerRunProg;
                if (*vTempPointer != 0x00)
                {
                    if (*vTempPointer == 0x3A)
                    {
                        *doisPontos = 1;
                        *pointerRunProg = *pointerRunProg + 1;
                    }
                    else
                    {
                        if (*doisPontos && *vTempPointer <= 0x80)
                        {
                            // nao faz nada
                        }
                        else
                        {
                            nextToken();
                            if (*vErroProc) break;
                        }
                    }
                }
            } while (*doisPontos);

            if (*vErroProc)
            {
#ifndef __TESTE_TOKENIZE__
                if (vdpModeBas != VDP_MODE_TEXT)
                    basText();
#endif
                showErrorMessage(*vErroProc, vNumLin);
                break;
            }

            if (*nextAddr == 0)
                break;

            vNextList = *nextAddr;

            vStartList = vNextList;
        }
        else
            break;
    }

#ifndef __TESTE_TOKENIZE__
    if (vdpModeBas != VDP_MODE_TEXT)
        basText();
#endif
}

//-----------------------------------------------------------------------------
// Mostra mensagem de erro de acordo com o codigo do erro e numero da linha
//-----------------------------------------------------------------------------
void showErrorMessage(unsigned int pError, unsigned int pNumLine)
{
    char sNumLin [sizeof(short)*8+1];

    printText("\r\n");
    printText(listError[pError]);

    if (pNumLine > 0)
    {
        itoa(pNumLine, sNumLin, 10);

        printText(" at ");
        printText(sNumLin);
    }

    printText(" !\r\n\0");

    *vErroProc = 0;
}

//--------------------------------------------------------------------------------------
// Load basic program in memory, throught xmodem protocol
// Syntaxe:
//          XBASLOAD
//--------------------------------------------------------------------------------------
int basXBasLoad(void)
{
    unsigned char vRet = 0;
    unsigned char vByte = 0;
    unsigned char *vTemp = pStartXBasLoad;
    unsigned char *vBufptr = &vbufInput;

    printText("Loading Basic Program...\r\n");

    // Limpando memoria
    memset(pStartXBasLoad,0x1A,vMemTotalXBasLoad);
    // Carrega programa em outro ponto da memoria
    vRet = loadSerialToMem(pStartXBasLoad,0);

    // Se tudo OK, tokeniza como se estivesse sendo digitado
    if (!vRet)
    {
        printText("Done.\r\n");
        printText("Processing...\r\n");

        while (1)
        {
            vByte = *vTemp++;

            if (vByte != 0x1A)
            {
                if (vByte != 0xD && vByte != 0x0A)
                    *vBufptr++ = vByte;
                else
                {
                    vTemp++;
                    *vBufptr = 0x00;
                    vBufptr = &vbufInput;
                    if (*vbufInput == 0x00)
                        break;
                    processLine();
                }
            }
            else
                break;
        }

        printText("Done.\r\n");
    }
    else
    {
        if (vRet == 0xFE)
            *vErroProc = 19;
        else
            *vErroProc = 20;
    }

    vbufInput[0] = 0x00;
    vBufptr = &vbufInput;

    return 0;
}

//--------------------------------------------------------------------------------------
// Load basic program in memory, throught xmodem protocol with 1K blocks and CRC
// Syntaxe:
//          XBASLOAD1K
//--------------------------------------------------------------------------------------
int basXBasLoad1k(void)
{
    unsigned char vRet = 0;
    unsigned char vByte = 0;
    unsigned char *vTemp = pStartXBasLoad;
    unsigned char *vBufptr = &vbufInput;
    unsigned char sqtdtam[20];

    printText("Loading Basic Program 1k...\r\n");

    // Limpando memoria
    memset(pStartXBasLoad,0x1A,vMemTotalXBasLoad);
    // Carrega programa em outro ponto da memoria
    vRet = loadSerialToMem2(pStartXBasLoad,0);

    // Se tudo OK, tokeniza como se estivesse sendo digitado
    if (!vRet)
    {
        printText("Done.\r\n");
        printText("Processing...\r\n");

        while (1)
        {
            vByte = *vTemp++;

            if (vByte != 0x1A)
            {
                if (vByte != 0xD && vByte != 0x0A)
                    *vBufptr++ = vByte;
                else
                {
                    vTemp++;
                    *vBufptr = 0x00;
                    vBufptr = &vbufInput;
                    if (*vbufInput == 0x00)
                        break;
                    processLine();
                }
            }
            else
            {

                break;
            }
        }

        printText("Done.\r\n");
    }
    else
    {
        if (vRet == 0xFE)
            *vErroProc = 19;
        else
            *vErroProc = 20;
    }

    vbufInput[0] = 0x00;
    vBufptr = &vbufInput;

    return 0;
}

/***************************************************************************************/
/* Secao CORE - Processamento das linhas apos RUN ou ENTER no processline sem numero   */
/* Controle do fluxo de execucao e ordem de leitura dentro da linha processando        */
/***************************************************************************************/

//-----------------------------------------------------------------------------
// Executa cada token, chamando as funcoes de acordo
//-----------------------------------------------------------------------------
int executeToken(unsigned char pToken)
{
    char vReta = 0;
#ifndef __TESTE_TOKENIZE__
    unsigned char *pForStack = forStack;
    int ix;

    switch (pToken)
    {
        case 0x00:  // End of Line
            vReta = 0;
            break;
        case 0x80:  // Let
            vReta = basLet();
            break;
        case 0x81:  // Print
            vReta = basPrint();
            break;
        case 0x82:  // IF
            vReta = basIf();
            break;
        case 0x83:  // THEN - nao faz nada
            vReta = 0;
            break;
        case 0x85:  // FOR
            vReta = basFor();
            break;
        case 0x86:  // TO - nao faz nada
            vReta = 0;
            break;
        case 0x87:  // NEXT
            vReta = basNext();
            break;
        case 0x88:  // STEP - nao faz nada
            vReta = 0;
            break;
        case 0x89:  // GOTO
            vReta = basGoto();
            break;
        case 0x8A:  // GOSUB
            vReta = basGosub();
            break;
        case 0x8B:  // RETURN
            vReta = basReturn();
            break;
        case 0x8C:  // REM - Ignora todas a linha depois dele
            vReta = 0;
            break;
        case 0x8D:  // SPRITESET
            vReta = basSpriteSet();
            break;
        case 0x8E:  // SPRITEPUT
            vReta = basSpritePut();
            break;
        case 0x8F:  // DIM
            vReta = basDim();
            break;
        case 0x90:  // BUFSHOW
            vReta = basBufShow();
            break;
        case 0x91:  // ON
            vReta = basOnVar();
            break;
        case 0x92:  // Input
            vReta = basInputGet(250);
            break;
        case 0x93:  // Get
            vReta = basInputGet(1);
            break;
        case 0x94:  // SPRITECOLOR
            vReta = basSpriteColor();
            break;
        case 0x95:  // LOCATE
            vReta = basLocate();
            break;
        case 0x96:  // CLS
            // Limpa dependendo do modo de video, se for texto limpa a tela, se for grafico limpa o grafico
            if (vdpModeBas == VDP_MODE_TEXT)
                clearScr();
            else if (vdpModeBas == VDP_MODE_G2)
                fillRect(0, 0, 255, 191, bgcolorBas);
            break;
        case 0x97:  // CLEAR - Clear all variables
            clearRuntimeData(pForStack);

            vReta = 0;
            break;
        case 0x98:  // DATA - Ignora toda a linha depois dele, READ vai ler essa linha
            vReta = 0;
            break;
        case 0x99:  // Read
            vReta = basRead();
            break;
        case 0x9A:  // Restore
            vReta = basRestore();
            break;
        case 0x9B:  // BUFVDGON
            vReta = basBufVdg(1);
            break;
        case 0x9C:  // BUFVDGOFF
            vReta = basBufVdg(0);
            break;
        case 0x9D:  // BUFCOPY
            vReta = basBufCopy();
            break;
        case 0x9E:  // END
            vReta = basEnd();
            break;
        case 0x9F:  // STOP
            vReta = basStop();
            break;
        case 0xB0:  // SCREEN
            vReta = basScreen();
            break;
        case 0xB1:  // CIRCLE
            vReta = basCircle();
            break;
        case 0xB2:  // RECT
            vReta = basRect();
            break;
        case 0xB3:  // COLOR
            vReta = basColor();
            break;
        case 0xB4:  // PLOT
            vReta = basPlot();
            break;
        case 0xB5:  // FILL
            vReta = basFill();
            break;
        case 0xB6:  // RESERVED
            vReta = 0;
            break;
        case 0xB7:  // SPRITEPOS
            vReta = basSpritePos();
            break;
        case 0xB8:  // PAINT
            vReta = basPaint();
            break;
        case 0xB9:  // LINE
            vReta = basLine();
            break;
        case 0xBA:  // AT - Nao faz nada
            vReta = 0;
            break;
        case 0xBB:  // ONERR
            vReta = basOnErr();
            break;
        case 0xBC:  // WHILE
            vReta = basWhile();
            break;
        case 0xBD:  // WEND
            vReta = basWend();
            break;
        case 0xC4:  // ASC
            vReta = basAsc();
            break;
        case 0xC5:  // HEX$
            vReta = basHex();
            break;
        case 0xC6:  // BIN$
            vReta = basBin();
            break;
        case 0xC7:  // OCT$
            vReta = basOct();
            break;
        case 0xCD:  // PEEK
            vReta = basPeekPoke('R');
            break;
        case 0xCE:  // POKE
            vReta = basPeekPoke('W');
            break;
        case 0xD1:  // RND
            vReta = basRnd();
            break;
        case 0xDB:  // Len
            vReta = basLen();
            break;
        case 0xDC:  // Val
            vReta = basVal();
            break;
        case 0xDD:  // Str$
            vReta = basStr();
            break;
        case 0xDE:  // SPRITEOVER
            vReta = basSpriteOver();
            break;
        case 0xE0:  // POINT
            vReta = basPoint();
            break;
        case 0xE1:  // Chr$
            vReta = basChr();
            break;
        case 0xE2:  // Fre(0)
            vReta = basFre();
            break;
        case 0xE3:  // Sqrt
            vReta = basTrig(6);
            break;
        case 0xE4:  // Sin
            vReta = basTrig(1);
            break;
        case 0xE5:  // Cos
            vReta = basTrig(2);
            break;
        case 0xE6:  // Tan
            vReta = basTrig(3);
            break;
        case 0xE7:  // Log
            vReta = basTrig(4);
            break;
        case 0xE8:  // Exp
            vReta = basTrig(5);
            break;
        case 0xE9:  // SPC
            vReta = basSpc();
            break;
        case 0xEA:  // Tab
            vReta = basTab();
            break;
        case 0xEB:  // Mid$
            vReta = basLeftRightMid('M');
            break;
        case 0xEC:  // Right$
            vReta = basLeftRightMid('R');
            break;
        case 0xED:  // Left$
            vReta = basLeftRightMid('L');
            break;
        case 0xEE:  // INT
            vReta = basInt();
            break;
        case 0xEF:  // ABS
            vReta = basAbs();
            break;
        default:
            if (pToken < 0x80)  // variavel sem LET
            {
                *pointerRunProg = *pointerRunProg - 1;
                vReta = basLet();
            }
            else // Nao forem operadores logicos
            {
                *vErroProc = 14;
                vReta = 14;
            }
    }
#endif
    return vReta;
}

//--------------------------------------------------------------------------------------
// Procura o proximo token ou componente da linha sendo processada
//--------------------------------------------------------------------------------------
int nextToken(void)
{
    unsigned char *temp;
    int vRet, ccc;
    unsigned char sqtdtam[20];
    unsigned char *vTempPointer;

    *token_type = 0;
    *tok = 0;
    temp = token;

    vTempPointer = *pointerRunProg;
    if (*vTempPointer >= 0x80 && *vTempPointer < 0xF0)   // is a command
    {
        *tok = *vTempPointer;
        *token_type = COMMAND;
        *token = *vTempPointer;
        *(token + 1) = 0x00;

        return *token_type;
    }

    if (*vTempPointer == '\0') { // end of file
        *token = 0;
        *tok = FINISHED;
        *token_type = DELIMITER;

        return *token_type;
    }

    while(*vTempPointer == ' ' || *vTempPointer == '\t') // skip over white space
    {
        *pointerRunProg = *pointerRunProg + 1;
        vTempPointer = *pointerRunProg;
    }

    if (*vTempPointer == '\r') { // crlf
        *pointerRunProg = *pointerRunProg + 2;
        *tok = EOL;
        *token = '\r';
        *(token + 1) = '\n';
        *(token + 2) = 0;
        *token_type = DELIMITER;

        return *token_type;
    }

    if ((*vTempPointer == '+' || *vTempPointer == '-' || *vTempPointer == '*' ||
         *vTempPointer == '^' || *vTempPointer == '/' || *vTempPointer == '=' ||
         *vTempPointer == ';' || *vTempPointer == ':' || *vTempPointer == ',' ||
         *vTempPointer == '>' || *vTempPointer == '<' || *vTempPointer >= 0xF0)) { // delimiter
        *temp = *vTempPointer;
        *pointerRunProg = *pointerRunProg + 1; // advance to next position
        temp++;
        *temp = 0;
        *token_type = DELIMITER;

        return *token_type;
    }

    if (*vTempPointer == 0x28 || *vTempPointer == 0x29)
    {
        if (*vTempPointer == 0x28)
            *token_type = OPENPARENT;
        else
            *token_type = CLOSEPARENT;

        *token = *vTempPointer;
        *(token + 1) = 0x00;

        *pointerRunProg = *pointerRunProg + 1;

        return *token_type;
    }

    if (*vTempPointer == ":")
    {
        *doisPontos = 1;
        *token_type = DOISPONTOS;

        return *token_type;
    }

    if (*vTempPointer == '"') { // quoted string
        *pointerRunProg = *pointerRunProg + 1;
        vTempPointer = *pointerRunProg;

        while(*vTempPointer != '"'&& *vTempPointer != '\r')
        {
            *temp++ = *vTempPointer;
            *pointerRunProg = *pointerRunProg + 1;
            vTempPointer = *pointerRunProg;
        }

        if (*vTempPointer == '\r')
        {
            *vErroProc = 14;
            return 0;
        }

        *pointerRunProg = *pointerRunProg + 1;
        *temp = 0;
        *token_type = QUOTE;

        return *token_type;
    }

    if (isdigitus(*vTempPointer)) { // number
        while(!isdelim(*vTempPointer) && (*vTempPointer < 0x80 || *vTempPointer >= 0xF0))
        {
            *temp++ = *vTempPointer;
            *pointerRunProg = *pointerRunProg + 1;
            vTempPointer = *pointerRunProg;
        }
        *temp = '\0';
        *token_type = NUMBER;

        return *token_type;
    }

    if (isalphas(*vTempPointer)) { // var or command
        while(!isdelim(*vTempPointer) && (*vTempPointer < 0x80 || *vTempPointer >= 0xF0))
        {
            *temp++ = *vTempPointer;
            *pointerRunProg = *pointerRunProg + 1;
            vTempPointer = *pointerRunProg;
        }

        *temp = '\0';
        *token_type = VARIABLE;

        return *token_type;
    }

    *temp = '\0';

    // see if a string is a command or a variable
    if (*token_type == STRING) {
        *token_type = VARIABLE;
    }

    return *token_type;
}

//-----------------------------------------------------------------------------
// Procura o token na lista de keywords e devolve a posicao, se nao encontrar,
// devolve 14 (token desconhecido)
//-----------------------------------------------------------------------------
int findToken(unsigned char pToken)
{
    unsigned char kt;

    // Procura o Token na lista e devolve a posicao
    for(kt = 0; kt < keywords_count; kt++)
    {
        if (keywords[kt].token == pToken)
            return kt;
    }

    // Procura o Token nas operacões de 1 char
    /*for(kt = 0; kt < keywordsUnique_count; kt++)
    {
        if (keywordsUnique[kt].token == pToken)
            return (kt + 0x80);
    }*/

    return 14;
}

//-----------------------------------------------------------------------------
// Procura o numero da linha na lista de linhas do programa e devolve o endereco,
// se nao encontrar, devolve 0
//-----------------------------------------------------------------------------
unsigned long findNumberLine(unsigned short pNumber, unsigned char pTipoRet, unsigned char pTipoFind)
{
    unsigned char *vStartList = *addrFirstLineNumber;
    unsigned char *vLastList = *addrFirstLineNumber;
    unsigned short vNumber = 0;
    char vBuffer [sizeof(long)*8+1];

    if (pNumber)
    {
        while(vStartList)
        {
            vNumber = ((*(vStartList + 3) << 8) | *(vStartList + 4));

            if ((!pTipoFind && vNumber < pNumber) || (pTipoFind && vNumber != pNumber))
            {
                vLastList = vStartList;
                vStartList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);
            }
            else
                break;
        }
    }

    if (!pTipoRet)
        return vStartList;
    else
        return vLastList;
}

//--------------------------------------------------------------------------------------
// Return true if c is a alphabetical (A-Z or a-z).
//--------------------------------------------------------------------------------------
int isalphas(unsigned char c)
{
    if ((c>0x40 && c<0x5B) || (c>0x60 && c<0x7B))
       return 1;

    return 0;
}

//--------------------------------------------------------------------------------------
// Return true if c is a number (0-9).
//--------------------------------------------------------------------------------------
int isdigitus(unsigned char c)
{
    if (c>0x2F && c<0x3A)
       return 1;

    return 0;
}

//--------------------------------------------------------------------------------------
// Return true if c is a delimiter.
//--------------------------------------------------------------------------------------
int isdelim(unsigned char c)
{
    if (c >= 0xF0 || c == 0 || c == '\r' || c == '\t' || c == ' ' ||
        c == ';' || c == ',' || c == '+' || c == '-' || c == '<' ||
        c == '>' || c == '(' || c == ')' || c == '/' || c == '*' ||
        c == '^' || c == '=' || c == ':')
        return 1;

    return 0;
}

//--------------------------------------------------------------------------------------
// Return 1 if c is space or tab.
//--------------------------------------------------------------------------------------
int iswhite(unsigned char c)
{
    if (c==' ' || c=='\t')
       return 1;

    return 0;
}

//--------------------------------------------------------------------------------------
// Return a token to input stream.
//--------------------------------------------------------------------------------------
void putback(void)
{
    unsigned char *t;

    if (*token_type==COMMAND)    // comando nao faz isso
        return;

    t = token;
    while (*t++)
        *pointerRunProg = *pointerRunProg - 1;
}

//--------------------------------------------------------------------------------------
// Return compara 2 strings
//--------------------------------------------------------------------------------------
int ustrcmp(char *X, char *Y)
{
    while (*X)
    {
        // if characters differ, or end of the second string is reached
        if (*X != *Y) {
            break;
        }

        // move to the next pair of characters
        X++;
        Y++;
    }

    // return the ASCII difference after converting `char*` to `unsigned char*`
    return *(unsigned char*)X - *(unsigned char*)Y;
}

//--------------------------------------------------------------------------------------
// Entry point into parser.
//--------------------------------------------------------------------------------------
void getExp(unsigned char *result)
{
    unsigned char sqtdtam[10];

    #ifdef USE_ITERATIVE_PARSER
        parseExpr(result);

        if (*vErroProc) return;

        putback(); // return last token read to input stream

        return;
    #else
        nextToken();
        if (*vErroProc) return;

        if (!*token && *token_type != QUOTE) {
            *vErroProc = 2;
            return;
        }

        level2(result);
        if (*vErroProc) return;

        putback(); // return last token read to input stream

        return;
    #endif
}

// -----------------------------------------------------------------------------
// Precedência dos operadores
// -----------------------------------------------------------------------------
int getPrec(unsigned char op)
{
    switch (op)
    {
        case '(':
            return 0;
        case 0xF4:
            return 1; // OR
        case 0xF3:
            return 2; // AND
        case '=':
        case '<':
        case '>':
        case 0xF5:
        case 0xF6:
        case 0xF7:
            return 3; // comparadores
        case '+':
        case '-':
            return 4;
        case '*':
        case '/':
            return 5;
        case '^':
            return 6;
        default:
            return 0;
    }
}

// -----------------------------------------------------------------------------
// Associatividade: ^ é direita, resto esquerda
// -----------------------------------------------------------------------------
int isRightAssoc(char op) {
    return (op == '^');
}

// -----------------------------------------------------------------------------
// Parser iterativo (experimental, ativado por USE_ITERATIVE_PARSER)
// -----------------------------------------------------------------------------
void parseExpr(unsigned char *result) {
    unsigned char op, currentOp;
    char typeA, typeB;
    unsigned char tokenType, tokenChar, valueType;
    unsigned char *a, *b;
    unsigned char *vRet;
    unsigned long numberValue;
    unsigned char *numberBytes;
    unsigned char tokenLen;
    unsigned char *commandPointer;
    int expectValue = 1; // Para detectar unário
    char pendingUnary = 0; // 0: nenhum, '+': unário +, '-': unário -
    int currentPrec, topPrec;
    unsigned char sqtdtam[20];
    unsigned char valStack[32][50];
    unsigned char opStack[PARSER_STACK_SIZE];
    unsigned char opPrecStack[PARSER_STACK_SIZE];
    char valTypeStack[PARSER_STACK_SIZE];
    unsigned char temp[50];
    unsigned char tokenVarAtu[3];
    unsigned char tokenVarAtuLen;
    int opTop = -1, valTop = -1;

    nextToken();
    if (*vErroProc) return;
    if (!*token && *token_type != QUOTE) {
        *vErroProc = 2;
        return;
    }

    while (1) {
        tokenType = *token_type;
        tokenChar = *token;

        if (expectValue) {
            if (tokenType == DELIMITER && (tokenChar == '+' || tokenChar == '-')) {
                pendingUnary = tokenChar;
                nextToken();
                if (*vErroProc) return;
                continue;
            }

            if (tokenType == NUMBER || tokenType == VARIABLE || tokenType == QUOTE || tokenType == COMMAND) {
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.5 - [\0");
itoa(tokenType,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(tokenChar,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif
                if (tokenType == VARIABLE) {
                    tokenLen = 0;
                    while (token[tokenLen])
                        tokenLen++;

                    if (tokenLen < 3)
                    {
                        valueType = VARTYPEDEFAULT;

                        if (tokenLen == 2 && token[1] < 0x30)
                            valueType = token[1];
                    }
                    else
                    {
                        valueType = token[2];
                    }

#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.0 - [\0");
itoa(*(char*)token,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*(char*)(token + 1),sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif
                    tokenVarAtuLen = tokenLen;
                    tokenVarAtu[0] = token[0];
                    tokenVarAtu[1] = token[1];
                    tokenVarAtu[2] = token[2];
                    vRet = find_var((char*)tokenVarAtu);
                    if (vRet == 0)
                    {
                        if (*vErroProc == 0)
                            *vErroProc = 4;
                        return;
                    }

                    if (tokenLen < 3)
                        valueType = valueType;   // *value_type;
                    else
                        valueType = tokenVarAtu[2];

                    if (valueType == '$')
                        strcpy((char*)temp, (char*)vRet);
                    else
                    {
                        temp[0] = vRet[0];
                        temp[1] = vRet[1];
                        temp[2] = vRet[2];
                        temp[3] = vRet[3];
                        temp[4] = 0x00;
                    }

#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.1 - [\0");
itoa(*(unsigned int*)vRet,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*(unsigned int*)temp,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(tokenLen,sqtdtam,10);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeSerial(valueType);
writeLongSerial("]\r\n\0");
}
#endif
                    nextToken();
                    if (*vErroProc) return;
                }
                else if (tokenType == QUOTE) {
                    valueType = '$';
                    strcpy((char*)temp, (char*)token);
                    nextToken();
                    if (*vErroProc) return;
                }
                else if (tokenType == NUMBER) {
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.87 - [\0");
itoa(*token,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeLongSerial(valueType);
writeLongSerial("]\r\n\0");
}
#endif
                    if (strchr((char*)token, '.'))
                    {
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.88\r\n\0");
}
#endif
                        valueType = '#';
                        numberValue = floatStringToFpp(token);
                        if (*vErroProc) return;
                    }
                    else
                    {
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.89\r\n\0");
}
#endif
                        valueType = '%';
                        numberValue = atoi((char*)token);
                    }
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.90\r\n\0");
}
#endif

                    numberBytes = (unsigned char*)&numberValue;
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.91 - [\0");
itoa(numberValue,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(numberBytes[0],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(numberBytes[1],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(numberBytes[2],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(numberBytes[3],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif
                    temp[0] = numberBytes[0];
                    temp[1] = numberBytes[1];
                    temp[2] = numberBytes[2];
                    temp[3] = numberBytes[3];
                    temp[4] = 0x00;

#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.91 - [\0");
itoa(temp[0],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(temp[1],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(temp[2],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(temp[3],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif

                    nextToken();
                    if (*vErroProc) return;
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.92\r\n\0");
}
#endif
                }
                else {
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.77 - [\0");
itoa(*pointerRunProg,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif
                    commandPointer = *pointerRunProg;
                    *token = *commandPointer;
                    *pointerRunProg = *pointerRunProg + 1;
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.78 - [\0");
itoa(commandPointer,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*commandPointer,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*token,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif
                    executeToken(*commandPointer);
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.79 - [\0");
itoa(*pointerRunProg,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif
                    if (*vErroProc) return;

                    valueType = *value_type;

                    if (valueType == '$')
                        strcpy((char*)temp, (char*)token);
                    else
                    {
                        temp[0] = token[0];
                        temp[1] = token[1];
                        temp[2] = token[2];
                        temp[3] = token[3];
                        temp[4] = 0x00;
                    }

                    nextToken();
                    if (*vErroProc) return;
                }
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.93\r\n\0");
}
#endif

                if (pendingUnary) {
                    if (valueType == '$') {
                        *vErroProc = 16;
                        return;
                    }

                    if (valueType == '#')
                        unaryReal(pendingUnary, (int*)temp);
                    else
                        unaryInt(pendingUnary, (int*)temp);

                    pendingUnary = 0;
                }
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.94\r\n\0");
}
#endif

                if (valTop + 1 >= PARSER_STACK_SIZE) {
                    *vErroProc = 14;
                    return;
                }
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.95\r\n\0");
}
#endif

                valTop++;
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.96\r\n\0");
}
#endif

                if (valueType == '$')
                    strcpy((char*)valStack[valTop], (char*)temp);
                else
                {
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.97 - [\0");
itoa(valTop,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*(unsigned int*)temp,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif

                    *(unsigned int*)valStack[valTop] = *(unsigned int*)temp;
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.98 - [\0");
writeLongSerial("**** DAR TEMPO ****[\0");
writeLongSerial("]-[");
itoa(*(unsigned int*)valStack[valTop],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif
                    valStack[valTop][4] = 0x00;
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.99\r\n\0");
}
#endif

                }

#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.3 - [\0");
writeLongSerial("**** DAR TEMPO ****[\0");
writeLongSerial("]-[");
itoa(*(unsigned int*)temp,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(valTop,sqtdtam,10);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*(unsigned int*)valStack[valTop],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif

                valTypeStack[valTop] = valueType;
                expectValue = 0;

                continue;
            }

            if (tokenChar == '(') {
                if (pendingUnary) {
                    if (pendingUnary == '-') {
                        if (valTop + 1 >= PARSER_STACK_SIZE) {
                            *vErroProc = 14;
                            return;
                        }

                        valTop++;
                        *(unsigned int*)valStack[valTop] = 0;
                        valTypeStack[valTop] = '%';

                        if (opTop + 1 >= PARSER_STACK_SIZE) {
                            *vErroProc = 14;
                            return;
                        }

                        opTop++;
                        opStack[opTop] = '-';
                        opPrecStack[opTop] = 2;
                    }

                    pendingUnary = 0;
                }

                if (opTop + 1 >= PARSER_STACK_SIZE) {
                    *vErroProc = 14;
                    return;
                }

                opTop++;
                opStack[opTop] = '(';
                opPrecStack[opTop] = 0;

                nextToken();
                if (*vErroProc) return;

                continue;
            }
        }

        if (tokenChar == ')') {
            char foundOpenParen = 0;

            while (opTop >= 0) {
                if (opStack[opTop] == '(') {
                    foundOpenParen = 1;
                    break;
                }

                op = opStack[opTop--];

                if (valTop < 1) {
                    *vErroProc = 14;
                    return;
                }

                b = valStack[valTop];
                typeB = valTypeStack[valTop];
                valTop--;

                a = valStack[valTop];
                typeA = valTypeStack[valTop];

#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.4 - [\0");
itoa(*(unsigned int*)a,sqtdtam,10);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeSerial(typeA);
writeLongSerial("]-[");
itoa(*(unsigned int*)b,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeSerial(typeB);
writeLongSerial("]-[");
writeSerial(op);
writeLongSerial("]\r\n\0");
}
#endif

                if (typeA != typeB) {
                    if (typeA == '$' || typeB == '$') {
                        *vErroProc = 16;
                        return;
                    }

                    if (typeA == '#') {
                        *(unsigned int*)b = fppReal(*(unsigned int*)b);
                        typeB = '#';
                    }
                    else {
                        *(unsigned int*)a = fppReal(*(unsigned int*)a);
                        typeA = '#';
                    }
                }

                if (op == 0xF3 || op == 0xF4) {
                    if (typeA == '$' || typeB == '$') {
                        *vErroProc = 16;
                        return;
                    }

                    if (op == 0xF3)
                        *(int*)a = (*(int*)a && *(int*)b);
                    else
                        *(int*)a = (*(int*)a || *(int*)b);

                    valTypeStack[valTop] = '%';
                } else if (op == '=' || op == '<' || op == '>' || op == 0xF5 || op == 0xF6 || op == 0xF7) {
                    if (typeA == '$')
                        logicalString(op, a, b);
                    else if (typeA == '#')
                        logicalNumericFloat(op, a, b);
                    else
                        logicalNumericInt(op, a, b);

                    valTypeStack[valTop] = '%';
                } else {
                    if (typeA == '#')
                        arithReal(op, a, b);
                    else if (typeA == '%')
                        arithInt(op, a, b);
                    else if (typeA == '$')
                    {
                        if (op == '+')
                            strcat(a,b);
                        else  {
                            *vErroProc = 27;
                            return;
                        }
                    }

                    valTypeStack[valTop] = typeA;
                }
            }

            if (foundOpenParen) {
                opTop--;

                nextToken();
                if (*vErroProc) return;

                expectValue = 0;
                continue;
            }

            break;
        }

        if (tokenChar == '+' || tokenChar == '-' || tokenChar == '*' || tokenChar == '/' || tokenChar == '^' ||
            tokenChar == '=' || tokenChar == '<' || tokenChar == '>' || tokenChar == 0xF5 || tokenChar == 0xF6 || tokenChar == 0xF7 ||
            tokenChar == 0xF3 || tokenChar == 0xF4) {
            currentOp = tokenChar;
            currentPrec = getPrec(currentOp);

            while (opTop >= 0) {
                topPrec = opPrecStack[opTop];

                if (topPrec < currentPrec)
                    break;

                if (currentOp == '^' && topPrec == currentPrec)
                    break;

                op = opStack[opTop--];

                if (valTop < 1) {
                    *vErroProc = 14;
                    return;
                }

                b = valStack[valTop];
                typeB = valTypeStack[valTop];
                valTop--;

                a = valStack[valTop];
                typeA = valTypeStack[valTop];

#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.2 - [\0");
itoa(*(unsigned int*)a,sqtdtam,10);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeSerial(typeA);
writeLongSerial("]-[");
itoa(*(unsigned int*)b,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeSerial(typeB);
writeLongSerial("]-[");
writeSerial(op);
writeLongSerial("]\r\n\0");
}
#endif

                if (typeA != typeB) {
                    if (typeA == '$' || typeB == '$') {
                        *vErroProc = 16;
                        return;
                    }

                    if (typeA == '#')
                    {
                        *(unsigned int*)b = fppReal(*(unsigned int*)b);
                        typeB = '#';
                    }
                    else {
                        *(unsigned int*)a = fppReal(*(unsigned int*)a);
                        typeA = '#';
                    }
                }

                if (op == 0xF3 || op == 0xF4) {
                    if (typeA == '$' || typeB == '$') {
                        *vErroProc = 16;
                        return;
                    }

                    if (op == 0xF3)
                        *(int*)a = (*(int*)a && *(int*)b);
                    else
                        *(int*)a = (*(int*)a || *(int*)b);

                    valTypeStack[valTop] = '%';
                } else if (op == '=' || op == '<' || op == '>' || op == 0xF5 || op == 0xF6 || op == 0xF7) {
                    if (typeA == '$')
                        logicalString(op, a, b);
                    else if (typeA == '#')
                        logicalNumericFloat(op, a, b);
                    else
                        logicalNumericInt(op, a, b);

                    valTypeStack[valTop] = '%';
                } else {
                    if (typeA == '#')
                        arithReal(op, a, b);
                    else if (typeA == '%')
                        arithInt(op, a, b);
                    else if (typeA == '$')
                    {
                        if (op == '+')
                            strcat(a,b);
                        else  {
                            *vErroProc = 27;
                            return;
                        }
                    }

                    valTypeStack[valTop] = typeA;
                }
            }

            if (opTop + 1 >= PARSER_STACK_SIZE) {
                *vErroProc = 14;
                return;
            }

            opTop++;
            opStack[opTop] = currentOp;
            opPrecStack[opTop] = (unsigned char)currentPrec;

            nextToken();
            if (*vErroProc) return;

            expectValue = 1;

            continue;
        }

        break;
    }

    while (opTop >= 0) {
        op = opStack[opTop--];

        if (op == '(') {
            *vErroProc = 15;
            return;
        }

        if (valTop < 1) {
            *vErroProc = 14;
            return;
        }

        b = valStack[valTop];
        typeB = valTypeStack[valTop];
        valTop--;

        a = valStack[valTop];
        typeA = valTypeStack[valTop];

        if (typeA != typeB) {
            if (typeA == '$' || typeB == '$') {
                *vErroProc = 16;
                return;
            }

            if (typeA == '#') {
                *(unsigned int*)b = fppReal(*(unsigned int*)b);
                typeB = '#';
            }
            else {
                *(unsigned int*)a = fppReal(*(unsigned int*)a);
                typeA = '#';
            }
        }

        if (op == 0xF3 || op == 0xF4) {
            if (typeA == '$' || typeB == '$') {
                *vErroProc = 16;
                return;
            }

            if (op == 0xF3)
                *(int*)a = (*(int*)a && *(int*)b);
            else
                *(int*)a = (*(int*)a || *(int*)b);

            valTypeStack[valTop] = '%';
        } else if (op == '=' || op == '<' || op == '>' || op == 0xF5 || op == 0xF6 || op == 0xF7) {
            if (typeA == '$')
                logicalString(op, a, b);
            else if (typeA == '#')
                logicalNumericFloat(op, a, b);
            else
                logicalNumericInt(op, a, b);

            valTypeStack[valTop] = '%';
        } else {
            if (typeA == '#')
                arithReal(op, a, b);
            else if (typeA == '%')
                arithInt(op, a, b);
            else if (typeA == '$')
            {
                if (op == '+')
                    strcat(a,b);
                else  {
                    *vErroProc = 27;
                    return;
                }
            }

            valTypeStack[valTop] = typeA;
        }
    }
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.78 - [\0");
itoa(valTop,sqtdtam,10);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}
#endif

    if (valTop < 0) {
        *vErroProc = 14;
        return;
    }
#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 888.666.79\r\n\0");
}
#endif

    *value_type = valTypeStack[valTop];

    if (*value_type == '$')
        strcpy((char*)result, (char*)valStack[valTop]);
    else
        *(unsigned int*)result = *(unsigned int*)valStack[valTop];

    return;
}

//--------------------------------------------------------------------------------------
//  Add or subtract two terms real/int or string.
//--------------------------------------------------------------------------------------
void level2(unsigned char *result)
{
    char  op;
    unsigned char hold[50];
    unsigned char valueTypeAnt;
    unsigned int *lresult = result;
    unsigned int *lhold = hold;
    unsigned char* sqtdtam[10];

    level3(result);
    if (*vErroProc) return;

    op = *token;

    while(op == '+' || op == '-') {
        nextToken();
        if (*vErroProc) return;

        valueTypeAnt = *value_type;

        level3(&hold);
        if (*vErroProc) return;

        if (*value_type != valueTypeAnt)
        {
            if (*value_type == '$' || valueTypeAnt == '$')
            {
                *vErroProc = 16;
                return;
            }
        }

        // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
        if (*value_type == '$' && valueTypeAnt == '$' && op == '+')
            strcat(result,&hold);
        else if ((*value_type == '$' || valueTypeAnt == '$') && op == '-')
        {
            *vErroProc = 16;
            return;
        }
        else
        {
            if (*value_type != valueTypeAnt)
            {
                if (*value_type == '$' || valueTypeAnt == '$')
                {
                    *vErroProc = 16;
                    return;
                }
                else if (*value_type == '#')
                {
                    *lresult = fppReal(*lresult);
                }
                else
                {
                    *lhold = fppReal(*lhold);
                    *value_type = '#';
                }
            }

            if (*value_type == '#')
                arithReal(op, result, &hold);
            else
                arithInt(op, result, &hold);
        }

        op = *token;
    }

    return;
}

//--------------------------------------------------------------------------------------
// Multiply or divide two factors real/int.
//--------------------------------------------------------------------------------------
void level3(unsigned char *result)
{
    char  op;
    unsigned char hold[50];
    unsigned int *lresult = result;
    unsigned int *lhold = hold;
    char value_type_ant=0;
    unsigned char* sqtdtam[10];

    do
    {
        level30(result);
        if (*vErroProc) return;
        if (*token==0xF3||*token==0xF4)
        {
            nextToken();
            if (*vErroProc) return;
        }
        else
            break;
    }
    while (1);

    op = *token;
    while(op == '*' || op == '/' || op == '%') {
        if (*value_type == '$')
        {
            *vErroProc = 16;
            return;
        }

        nextToken();
        if (*vErroProc) return;

        value_type_ant = *value_type;

        level4(&hold);
        if (*vErroProc) return;

        // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
        if (*value_type == '$' || value_type_ant == '$')
        {
            *vErroProc = 16;
            return;
        }

        if (*value_type != value_type_ant)
        {
            if (*value_type == '#')
            {
                *lresult = fppReal(*lresult);
            }
            else
            {
                *lhold = fppReal(*lhold);
                *value_type = '#';
            }
        }

        // se valor inteiro e for divisao, obrigatoriamente devolve valor real
        if (*value_type == '%' && op == '/')
        {
            *lresult = fppReal(*lresult);
            *lhold = fppReal(*lhold);
            *value_type = '#';
        }

        if (*value_type == '#')
            arithReal(op, result, &hold);
        else
            arithInt(op, result, &hold);

        op = *token;
    }

    return;
}

//--------------------------------------------------------------------------------------
// Is a NOT
//--------------------------------------------------------------------------------------
void level30(unsigned char *result)
{
    char  op;
    int *iLog = result;

    op = 0;
    if (*token == 0xF8) // NOT
    {
        op = *token;
        nextToken();
        if (*vErroProc) return;
    }

    level31(result);
    if (*vErroProc) return;

    if (op)
    {
        if (*value_type == '$' || *value_type == '#')
        {
            *vErroProc = 16;
            return;
        }

        *iLog = !*iLog;
    }

    return;
}

//--------------------------------------------------------------------------------------
// Process logic conditions AND or OR.
//--------------------------------------------------------------------------------------
void level31(unsigned char *result)
{
    unsigned char  op;
    unsigned char hold[50];
    char value_type_ant=0;
    int *rVal = result;
    int *hVal = hold;
    unsigned char* sqtdtam[10];

    level32(result);
    if (*vErroProc) return;

    op = *token;
    if (op==0xF3 /* AND */|| op==0xF4 /* OR */) {
        nextToken();
        if (*vErroProc) return;

        level32(&hold);
        if (*vErroProc) return;

/*writeLongSerial("Aqui 333.666.0-[");
itoa(op,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*rVal,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*hVal,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

        if (op==0xF3)
            *rVal = (*rVal && *hVal);
        else
            *rVal = (*rVal || *hVal);

/*riteLongSerial("Aqui 333.666.1-[");
itoa(op,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*rVal,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/
    }

    return;
}

//--------------------------------------------------------------------------------------
// Process logic conditions
//--------------------------------------------------------------------------------------
void level32(unsigned char *result)
{
    unsigned char  op;
    unsigned char hold[50];
    unsigned char value_type_ant=0;
    unsigned int *lresult = result;
    unsigned int *lhold = hold;
    unsigned char sqtdtam[20];

    level4(result);
    if (*vErroProc) return;

    op = *token;
    if (op=='=' || op=='<' || op=='>' || op==0xF5 /* >= */ || op==0xF6 /* <= */|| op==0xF7 /* <> */) {
//        if (op==0xF5 /* >= */ || op==0xF6 /* <= */|| op==0xF7)
//            pointerRunProg++;

        nextToken();
        if (*vErroProc) return;

        value_type_ant = *value_type;

        level4(&hold);
        if (*vErroProc) return;

        if ((value_type_ant=='$' && *value_type!='$') || (value_type_ant != '$' && *value_type == '$'))
        {
            *vErroProc = 16;
            return;
        }

        // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
        if (*value_type != value_type_ant)
        {
            if (*value_type == '#')
            {
                *lresult = fppReal(*lresult);
            }
            else
            {
                *lhold = fppReal(*lhold);
                *value_type = '#';
            }
        }

        if (*value_type == '$')
            logicalString(op, result, &hold);
        else if (*value_type == '#')
            logicalNumericFloat(op, result, &hold);
        else
            logicalNumericInt(op, result, &hold);
    }

    return;
}

//--------------------------------------------------------------------------------------
// Process integer exponent real/int.
//--------------------------------------------------------------------------------------
void level4(unsigned char *result)
{
    unsigned char hold[50];
    unsigned int *lresult = result;
    unsigned int *lhold = hold;
    char value_type_ant=0;

    level5(result);
    if (*vErroProc) return;

    if (*token== '^') {
        if (*value_type == '$')
        {
            *vErroProc = 16;
            return;
        }

        nextToken();
        if (*vErroProc) return;

        value_type_ant = *value_type;

        level4(&hold);
        if (*vErroProc) return;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return;
        }

        // Se forem diferentes os 2, se for um deles string, da erro, se nao, passa o inteiro para real
        if (*value_type != value_type_ant)
        {
            if (*value_type == '#')
            {
                *lresult = fppReal(*lresult);
            }
            else
            {
                *lhold = fppReal(*lhold);
                *value_type = '#';
            }
        }

        if (*value_type == '#')
            arithReal('^', result, &hold);
        else
            arithInt('^', result, &hold);
    }

    return;
}

//--------------------------------------------------------------------------------------
// Is a unary + or -.
//--------------------------------------------------------------------------------------
void level5(unsigned char *result)
{
    char  op;

    op = 0;
    if (*token_type==DELIMITER && (*token=='+' || *token=='-')) {
        op = *token;
        nextToken();
        if (*vErroProc) return;
    }

    level6(result);
    if (*vErroProc) return;

    if (op)
    {
        if (*value_type == '$')
        {
            *vErroProc = 16;
            return;
        }

        if (*value_type == '#')
            unaryReal(op, result);
        else
            unaryInt(op, result);
    }

    return;
}

//--------------------------------------------------------------------------------------
// Process parenthesized expression real/int/string or function.
//--------------------------------------------------------------------------------------
void level6(unsigned char *result)
{
    if ((*token == '(') && (*token_type == OPENPARENT)) {
        nextToken();
        if (*vErroProc) return;

        level2(result);
        if (*token != ')')
        {
            *vErroProc = 15;
            return;
        }

        nextToken();
        if (*vErroProc) return;
    }
    else
    {
        primitive(result);
        return;
    }

    return;
}

//--------------------------------------------------------------------------------------
// Find value of number or variable.
//--------------------------------------------------------------------------------------
void primitive(unsigned char *result)
{
    unsigned long ix;
    unsigned char* vix = &ix;
    unsigned char* vRet;
    unsigned char sqtdtam[10];
    unsigned char *vTempPointer;
    unsigned char tokenLen = 0;

    switch(*token_type) {
        case VARIABLE:
            while (token[tokenLen])
                tokenLen++;

            if (tokenLen < 3)
            {
                *value_type=VARTYPEDEFAULT;

                if (tokenLen == 2 && *(token + 1) < 0x30)
                    *value_type = *(token + 1);
            }
            else
            {
                *value_type = *(token + 2);
            }

            vRet = find_var(token);
            if (*vErroProc) return;
            if (*value_type == '$')  // Tipo da variavel
                strcpy(result,vRet);
            else
            {
                for (ix = 0;ix < 5;ix++)
                    result[ix] = vRet[ix];
            }
            nextToken();
            if (*vErroProc) return;
            return;
        case QUOTE:
            *value_type='$';
            strcpy(result,token);
            nextToken();
            if (*vErroProc) return;
            return;
        case NUMBER:
            if (strchr(token,'.'))  // verifica se eh numero inteiro ou real
            {
                *value_type='#'; // Real
                ix=floatStringToFpp(token);
                if (*vErroProc) return;
            }
            else
            {
                *value_type='%'; // Inteiro
                ix=atoi(token);
            }

            vix = &ix;

            result[0] = vix[0];
            result[1] = vix[1];
            result[2] = vix[2];
            result[3] = vix[3];

            nextToken();
            if (*vErroProc) return;
            return;
        case COMMAND:
            vTempPointer = *pointerRunProg;
            *token = *vTempPointer;
            *pointerRunProg = *pointerRunProg + 1;
            executeToken(*vTempPointer);  // Retorno do resultado da funcao deve voltar pela variavel token. *value_type tera o tipo de retorno
            if (*vErroProc) return;

            if (*value_type == '$')  // Tipo do retorno
                strcpy(result,token);
            else
            {
                for (ix = 0; ix < 4; ix++)
                {
                    result[ix] = *(token + ix);
                }
            }

            nextToken();
            if (*vErroProc) return;
            return;
        default:
            *vErroProc = 14;
            return;
    }

    return;
}

//--------------------------------------------------------------------------------------
// Perform the specified arithmetic inteiro.
//--------------------------------------------------------------------------------------
void arithInt(char o, char *r, char *h)
{
    int t, ex;
    int *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
    int *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
    char* vRval = rVal;

    switch(o) {
        case '-':
            *rVal = *rVal - *hVal;
            break;
        case '+':
            *rVal = *rVal + *hVal;
            break;
        case '*':
            *rVal = *rVal * *hVal;
            break;
        case '/':
            *rVal = (*rVal)/(*hVal);
            break;
        case '^':
            ex = *rVal;
            if (*hVal==0) {
                *rVal = 1;
                break;
            }
            ex = powNum(*rVal,*hVal);
            *rVal = ex;
            break;
    }

    r[0] = vRval[0];
    r[1] = vRval[1];
    r[2] = vRval[2];
    r[3] = vRval[3];
    r[4] = 0x00;
}


//--------------------------------------------------------------------------------------
// Perform the specified arithmetic real.
//--------------------------------------------------------------------------------------
void arithReal(char o, char *r, char *h)
{
    int t, ex;
    unsigned long *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
    unsigned long *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
    char* vRval = rVal;

    switch(o) {
        case '-':
            *rVal = fppSub(*rVal, *hVal);
            break;
        case '+':
            *rVal = fppSum(*rVal, *hVal);
            break;
        case '*':
            *rVal = fppMul(*rVal, *hVal);
            break;
        case '/':
            *rVal = fppDiv(*rVal, *hVal);
            break;
        case '^':
            *rVal = fppPwr(*rVal, *hVal);
            break;
    }

    r[4] = 0x00;
}

//--------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------
void logicalNumericFloat(unsigned char o, char *r, char *h)
{
    int t, ex;
    unsigned long *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
    unsigned long *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));
    unsigned long oCCR = 0;

    oCCR = fppComp(*rVal, *hVal);

    *rVal = 0;
    *value_type = '%';

    switch(o) {
        case '=':
            if (oCCR & 0x04)    // Z=1
                *rVal = 1;
            break;
        case '>':
            if (!(oCCR & 0x08) && !(oCCR & 0x04))   // N=0 e Z=0
                *rVal = 1;
            break;
        case '<':
            if ((oCCR & 0x08) && !(oCCR & 0x04))   // N=1 e Z=0
                *rVal = 1;
            break;
        case 0xF5:  // >=
            if (!(oCCR & 0x08) || (oCCR & 0x04))   // N=0 ou Z=1
                *rVal = 1;
            break;
        case 0xF6:  // <=
            if ((oCCR & 0x08) || (oCCR & 0x04))   // N=1 ou Z=1
                *rVal = 1;
            break;
        case 0xF7:  // <>
            if (!(oCCR & 0x04)) // z=0
                *rVal = 1;
            break;
    }
}

//--------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------
char logicalNumericFloatLong(unsigned char o, long r, long h)
{
    char ex = 0;
    unsigned long oCCR = 0;

    oCCR = fppComp(r, h);

    *value_type = '%';

    switch(o) {
        case '=':
            if (oCCR & 0x04)    // Z=1
                ex = 1;
            break;
        case '>':
            if (!(oCCR & 0x08) && !(oCCR & 0x04))   // N=0 e Z=0
                ex = 1;
            break;
        case '<':
            if ((oCCR & 0x08) && !(oCCR & 0x04))   // N=1 e Z=0
                ex = 1;
            break;
        case 0xF5:  // >=
            if (!(oCCR & 0x08) || (oCCR & 0x04))   // N=0 ou Z=1
                ex = 1;
            break;
        case 0xF6:  // <=
            if ((oCCR & 0x08) || (oCCR & 0x04))   // N=1 ou Z=1
                ex = 1;
            break;
        case 0xF7:  // <>
            if (!(oCCR & 0x04)) // z=0
                ex = 1;
            break;
    }

    return ex;
}

//--------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------
void logicalNumericInt(unsigned char o, char *r, char *h)
{
    int t, ex;
    int *rVal = r; //(int)((int)(r[0] << 24) | (int)(r[1] << 16) | (int)(r[2] << 8) | (int)(r[3]));
    int *hVal = h; //(int)((int)(h[0] << 24) | (int)(h[1] << 16) | (int)(h[2] << 8) | (int)(h[3]));

    switch(o) {
        case '=':
            *rVal = (*rVal == *hVal);
            break;
        case '>':
            *rVal = (*rVal > *hVal);
            break;
        case '<':
            *rVal = (*rVal < *hVal);
            break;
        case 0xF5:
            *rVal = (*rVal >= *hVal);
            break;
        case 0xF6:
            *rVal = (*rVal <= *hVal);
            break;
        case 0xF7:
            *rVal = (*rVal != *hVal);
            break;
    }
}

//--------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------
void logicalString(unsigned char o, char *r, char *h)
{
    int t, ex;
    int *rVal = r;

    ex = ustrcmp(r,h);
    *value_type = '%';

    switch(o) {
        case '=':
            *rVal = (ex == 0);
            break;
        case '>':
            *rVal = (ex > 0);
            break;
        case '<':
            *rVal = (ex < 0);
            break;
        case 0xF5:
            *rVal = (ex >= 0);
            break;
        case 0xF6:
            *rVal = (ex <= 0);
            break;
        case 0xF7:
            *rVal = (ex != 0);
            break;
    }
}

//--------------------------------------------------------------------------------------
// Reverse the sign.
//--------------------------------------------------------------------------------------
void unaryInt(char o, int *r)
{
    if (o=='-')
        *r = -(*r);
}

//--------------------------------------------------------------------------------------
// Reverse the sign.
//--------------------------------------------------------------------------------------
void unaryReal(char o, int *r)
{
    if (o=='-')
    {
        *r = fppNeg(*r);
    }
}

//--------------------------------------------------------------------------------------
// Find the value of a variable.
//--------------------------------------------------------------------------------------
unsigned char* find_var(char *s)
{
    static unsigned char vTempPool[4][250];
    static unsigned char vTempDepth = 0;
    unsigned char *vTemp;
    unsigned char vLen = 0;

    vTemp = vTempPool[vTempDepth & 0x03];
    vTempDepth++;

    while (s[vLen])
        vLen++;

    *vErroProc = 0x00;

    if (!isalphas(*s)){
        *vErroProc = 4; // not a variable
        vTempDepth--;
        return 0;
    }

    if (vLen < 3)
    {
        vTemp[0] = *s;
        vTemp[2] = VARTYPEDEFAULT;

        if (vLen == 2 && *(s + 1) < 0x30)
            vTemp[2] = *(s + 1);

        if (vLen == 2 && isalphas(*(s + 1)))
            vTemp[1] = *(s + 1);
        else
            vTemp[1] = 0x00;
    }
    else
    {
        vTemp[0] = *s++;
        vTemp[1] = *s++;
        vTemp[2] = *s;
    }

    if (!findVariable(vTemp))
    {
        *vErroProc = 4; // not a variable
        vTempDepth--;
        return 0;
    }

    vTempDepth--;
    return vTemp;
}

//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
void forPush(for_stack i)
{
    if (*ftos>FOR_NEST)
    {
        *vErroProc = 10;
        return;
    }

    *(forStack + *ftos) = i;
    *ftos = *ftos + 1;
}

//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
for_stack forPop(void)
{
    for_stack i;

    *ftos = *ftos - 1;

    if (*ftos<0)
    {
        *vErroProc = 11;
        return(*forStack);
    }

    i=*(forStack + *ftos);

    return(i);
}

//-----------------------------------------------------------------------------
// GOSUB stack push function.
//-----------------------------------------------------------------------------
void gosubPush(unsigned long i)
{
    if (*gtos>SUB_NEST)
    {
        *vErroProc = 12;
        return;
    }

    *(gosubStack + *gtos)=i;

    *gtos = *gtos + 1;
}

//-----------------------------------------------------------------------------
// GOSUB stack pop function.
//-----------------------------------------------------------------------------
unsigned long gosubPop(void)
{
    unsigned long i;

    *gtos = *gtos - 1;

    if (*gtos<0)
    {
        *vErroProc = 13;
        return 0;
    }

    i=*(gosubStack + *gtos);

    return i;
}

//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
unsigned int powNum(unsigned int pbase, unsigned char pexp)
{
    unsigned int iz, vRes = pbase;

    if (pexp > 0)
    {
        pexp--;

        for(iz = 0; iz < pexp; iz++)
        {
            vRes = vRes * pbase;
        }
    }
    else
        vRes = 1;

    return vRes;
}

//-----------------------------------------------------------------------------
// FUNCOES PONTO FLUTUANTE
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Convert from String to Float Single-Precision
//-----------------------------------------------------------------------------
unsigned long floatStringToFpp(unsigned char* pFloat)
{
    unsigned long vFpp;

    *floatBufferStr = pFloat;
    STR_TO_FP();
    vFpp = *floatNumD7;

    return vFpp;
}

//-----------------------------------------------------------------------------
// Convert from Float Single-Precision to String
//-----------------------------------------------------------------------------
int fppTofloatString(unsigned long pFpp, unsigned char *buf)
{
    *floatBufferStr = buf;
    *floatNumD7 = pFpp;
    FP_TO_STR();

    return 0;
}

//-----------------------------------------------------------------------------
// Float Function to SUM D7+D6
//-----------------------------------------------------------------------------
unsigned long fppSum(unsigned long pFppD7, unsigned long pFppD6)
{
    *floatNumD7 = pFppD7;
    *floatNumD6 = pFppD6;
    FPP_SUM();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function to Subtraction D7-D6
//-----------------------------------------------------------------------------
unsigned long fppSub(unsigned long pFppD7, unsigned long pFppD6)
{
    *floatNumD7 = pFppD7;
    *floatNumD6 = pFppD6;
    FPP_SUB();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function to Mul D7*D6
//-----------------------------------------------------------------------------
unsigned long fppMul(unsigned long pFppD7, unsigned long pFppD6)
{
    *floatNumD7 = pFppD7;
    *floatNumD6 = pFppD6;
    FPP_MUL();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function to Division D7/D6
//-----------------------------------------------------------------------------
unsigned long fppDiv(unsigned long pFppD7, unsigned long pFppD6)
{
    *floatNumD7 = pFppD7;
    *floatNumD6 = pFppD6;
    FPP_DIV();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function to Power D7^D6
//-----------------------------------------------------------------------------
unsigned long fppPwr(unsigned long pFppD7, unsigned long pFppD6)
{
    *floatNumD7 = pFppD7;
    *floatNumD6 = pFppD6;
    FPP_PWR();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Convert Float to Int
//-----------------------------------------------------------------------------
long fppInt(unsigned long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_INT();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Convert Int to Float
//-----------------------------------------------------------------------------
unsigned long fppReal(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_FPP();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return SIN
//-----------------------------------------------------------------------------
unsigned long fppSin(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_SIN();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return COS
//-----------------------------------------------------------------------------
unsigned long fppCos(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_COS();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return TAN
//-----------------------------------------------------------------------------
unsigned long fppTan(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_TAN();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return SIN Hiperb
//-----------------------------------------------------------------------------
unsigned long fppSinH(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_SINH();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return COS Hiperb
//-----------------------------------------------------------------------------
unsigned long fppCosH(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_COSH();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return TAN Hiperb
//-----------------------------------------------------------------------------
unsigned long fppTanH(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_TANH();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return Sqrt
//-----------------------------------------------------------------------------
unsigned long fppSqrt(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_SQRT();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return TAN Hiperb
//-----------------------------------------------------------------------------
unsigned long fppLn(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_LN();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return Exp
//-----------------------------------------------------------------------------
unsigned long fppExp(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_EXP();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return ABS
//-----------------------------------------------------------------------------
unsigned long fppAbs(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_ABS();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function Return Neg
//-----------------------------------------------------------------------------
unsigned long fppNeg(long pFppD7)
{
    *floatNumD7 = pFppD7;
    FPP_NEG();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Float Function to Comp 2 float values D7-D6
//-----------------------------------------------------------------------------
unsigned long fppComp(unsigned long pFppD7, unsigned long pFppD6)
{
    *floatNumD7 = pFppD7;
    *floatNumD6 = pFppD6;

    FPP_CMP();

    return *floatNumD7;
}

//-----------------------------------------------------------------------------
// Processa Parametros do comando/funcao Basic
// Parametros:
//      tipoRetorno: 0 - Valor Final, 1 - Nome Variavel
//      temParenteses: 1 - tem, 0 - nao
//      qtdParam: Quanto parametros tem 1 a 255
//      tipoParams: Array com o tipo de cada param ($, % e #)ex: 3 params = [$,%,%]
//      retParams: Pointer para o retorno dos parametros para a função Utilizar
//-----------------------------------------------------------------------------
int procParam(unsigned char tipoRetorno, unsigned char temParenteses, unsigned char tipoSeparador, unsigned char qtdParam, unsigned char *tipoParams,  unsigned char *retParams)
{
    int ix, iy;
    unsigned char answer[200], varTipo, vTipoParam;
    char last_delim, last_token_type = 0;
    unsigned char sqtdtam[10];
    long *vConvVal;
    long *vValor = answer;
    unsigned char *vTempRetParam = retParams;

    nextToken();
    if (*vErroProc) return 0;

    // Se obriga parenteses, primeiro caracter deve ser abre parenteses
    if (temParenteses)
    {
        if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
        {
            *vErroProc = 15;
            return 0;
        }

        nextToken();
        if (*vErroProc) return 0;
    }

    if (qtdParam == 255)
        *retParams++ = 0x00;

    for (ix = 0; ix < qtdParam; ix++)
    {
        if (qtdParam < 255)
            vTipoParam = tipoParams[ix];
        else
            vTipoParam = tipoParams[0];

        if (tipoRetorno == 0)
        {
            // Valor Final
            if (*token_type == QUOTE)  /* se o parametro nao pedir string, error */
            {
                if (vTipoParam != '$')
                {
                    *vErroProc = 16;
                    return 0;
                }

                // Transfere a String pro retorno do parametro
                iy = 0;
                while (token[iy])
                    *retParams++ = token[iy++];

                *retParams++ = 0x00;
            }
            else
            {
                /* is expression */
                last_token_type = *token_type;

                putback();

                getExp(&answer);
                if (*vErroProc) return 0;

                if (*value_type == '$')
                {
                    if (vTipoParam != '$')   /* se o parametro nao pedir string, error */
                    {
                        *vErroProc = 16;
                        return 0;
                    }

                    // Transfere a String pro retorno do parametro
                    iy = 0;
                    while (answer[iy])
                        *retParams++ = answer[iy++];

                    *retParams++ = 0x00;
                }
                else
                {
                    if (vTipoParam == '$')   /* se nao é uma string, mas o parametro pedir string, error */
                    {
                        *vErroProc = 16;
                        return 0;
                    }

                    // Converter aqui pro valor solicitado (de int pra dec e dec pra int). @ = nao converte
                    if (vTipoParam != '@' && vTipoParam != *value_type)
                    {
                        if (vTipoParam == '%')
                            vConvVal = fppInt(*vValor);
                        else
                            vConvVal = fppReal(*vValor);

                        *vValor = vConvVal;
                    }

                    // Transfere o numero gerado para o retorno do parametro
                    *retParams++ = answer[0];
                    *retParams++ = answer[1];
                    *retParams++ = answer[2];
                    *retParams++ = answer[3];

                    // Se for @, o proximo byte desse valor é o tipo
                    if (vTipoParam == '@')
                        *retParams++ = *value_type;
                }
            }
        }
        else
        {
            // Nome Variavel
            if (!isalphas(*token)) {
                *vErroProc = 4;
                return 0;
            }

            if (strlen(token) < 3)
            {
                *varName = *token;
                varTipo = VARTYPEDEFAULT;

                if (strlen(token) == 2 && *(token + 1) < 0x30)
                    varTipo = *(token + 1);

                if (strlen(token) == 2 && isalphas(*(token + 1)))
                    *(varName + 1) = *(token + 1);
                else
                    *(varName + 1) = 0x00;

                *(varName + 2) = varTipo;
            }
            else
            {
                *varName = *token;
                *(varName + 1) = *(token + 1);
                *(varName + 2) = *(token + 2);
                varTipo = *(varName + 2);
            }

            answer[0] = varTipo;
        }

        if ((ix + 1) != qtdParam)
        {
            // Verifica se tem separador
            if (tipoSeparador == 0 && qtdParam != 255)
            {
                *vErroProc = 27;
                return 0;
            }

            nextToken();
            if (*vErroProc) return 0;

            // Se for um separador diferente do definido
            if (*token != tipoSeparador)
            {
                // Se for qtd definida, erro
                if (qtdParam != 255)
                {
                    *vErroProc = 18;
                    return 0;
                }
                else
                {
                    *vTempRetParam = (ix + 1);
                    break;
                }
            }

            nextToken();
            if (*vErroProc) return 0;
        }
    }

    last_delim = *token;

    if (temParenteses)
    {
        if (qtdParam == 1)
        {
            nextToken();
            if (*vErroProc) return 0;
        }

        // Ultimo caracter deve ser fecha parenteses
        if (*token_type != CLOSEPARENT)
        {
            *vErroProc = 15;
            return 0;
        }
    }

    if (qtdParam != 1 && tipoRetorno == 0)
    {
        if (*token != 0xBA && *token != 0x86)   // AT and TO token's
        {
            nextToken();
            if (*vErroProc) return 0;

            if (*token == ':' || *token == tipoSeparador)
                putback();
        }
    }

    return 0;
}

/*****************************************************************************/
/* CONTROLE DE VARIAVEIS                                                     */
/*****************************************************************************/

//-----------------------------------------------------------------------------
// Calcula o endereco do valor dentro da area de dados de uma variavel array.
// Retorna 0 em caso de erro de limite e ajusta vErroProc.
//-----------------------------------------------------------------------------
static unsigned char* getArrayValuePointer(unsigned char ixDim, unsigned char* vLista, unsigned char* vDim, unsigned char vTamValue)
{
    int ix;
    int iw;
    unsigned char ixDimAnt;
    unsigned char* vPosValueVar;
    unsigned short iDim;
    unsigned long vOffSet;

    iw = (ixDim - 1);
    ixDimAnt = 1;
    vPosValueVar = 0;

    for (ix = ((ixDim - 1) * 2 ); ix >= 0; ix -= 2)
    {
        iDim = ((vLista[ix + 8] << 8) | vLista[ix + 9]);

        if (vDim[iw] > iDim)
        {
            *vErroProc = 21;
            return 0;
        }

        vPosValueVar = vPosValueVar + ((vDim[iw] - 1 ) * ixDimAnt * vTamValue);
        ixDimAnt = ixDimAnt * iDim;
        iw--;
    }

    vOffSet = vLista;
    vPosValueVar = vPosValueVar + (vOffSet + 8 + (ixDim * 2));

    return vPosValueVar;
}

//-----------------------------------------------------------------------------
// Retornos: -1 - Erro, 0 - Nao Existe, 1 - eh um valor numeral
//           [endereco > 1] - Endereco da variavel
//
//           se retorno > 1: pVariable vai conter o valor numeral (qdo 1) ou
//                           o conteudo da variavel (qdo endereco)
//-----------------------------------------------------------------------------
long findVariable(unsigned char* pVariable)
{
    unsigned char* vLista = pStartSimpVar;
    unsigned char* vTemp = pStartSimpVar;
    unsigned char vVarName0 = pVariable[0];
    unsigned char vVarName1 = pVariable[1];
    long vEnder = 0;
    int ix = 0, iy = 0, iz = 0;
    unsigned char vDim[88];
    unsigned int vTempDim = 0;
    unsigned long vOffSet;
    unsigned char ixDim = 0;
    unsigned char vArray = 0;
    unsigned long vPosNextVar = 0;
    unsigned char* vPosValueVar = 0;
    unsigned char vTamValue = 4;
    unsigned char *vTempPointer;
    unsigned char *pDst;
    unsigned char *pSrc;
    unsigned char sqtdtam[20];
    int vCacheIx;
    unsigned char *cacheName0Ptr;
    unsigned char *cacheName1Ptr;
    unsigned char **cacheAddrPtr;

    // Verifica se eh array (tem parenteses logo depois do nome da variavel)

/*if (*debugOn)
{
writeLongSerial("Aqui 333.666.0 varName-[");
itoa(pVariable[0],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pVariable[1],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");
}*/

    vTempPointer = *pointerRunProg;
    if (*vTempPointer == 0x28)
    {
        // Define que eh array
        vArray = 1;

        // Procura as dimensoes
        nextToken();
        if (*vErroProc) return 0;

        // Erro, primeiro caracter depois da variavel, deve ser abre parenteses
        if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
        {
            *vErroProc = 15;
            return 0;
        }

        do
        {
            nextToken();
            if (*vErroProc) return 0;

            if (*token_type == QUOTE) { // is string, error
                *vErroProc = 16;
                return 0;
            }

            else { // is expression

                putback();

                getExp(&vTempDim);

/*if (*debugOn)
{
writeLongSerial("Aqui 333.666.99 varName-[");
itoa(vTempDim,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*vErroProc,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*token,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");
}*/

                if (*vErroProc) return 0;

                if (*value_type == '$')
                {
                    *vErroProc = 16;
                    return 0;
                }

                if (*value_type == '#')
                {
                    vTempDim = fppInt(vTempDim);
                    *value_type = '%';
                }

                vDim[ixDim] = vTempDim + 1;

                ixDim++;
            }

            if (*token == ',')
            {
/*if (*debugOn)
{
writeLongSerial("Aqui 333.666.98 varName-\r\n\0");
}*/

                *pointerRunProg = *pointerRunProg + 1;

                vTempPointer = *pointerRunProg;
/*if (*debugOn)
{
writeLongSerial("Aqui 333.666.97 varName-\r\n\0");
itoa(*pointerRunProg,sqtdtam,16);
writeLongSerial(sqtdtam);
}*/
            }
            else
                break;

        } while(1);

        // Deve ter pelo menos 1 elemento
        if (ixDim < 1)
        {
            *vErroProc = 21;
            return 0;
        }

        nextToken();
        if (*vErroProc) return 0;

        // Ultimo caracter deve ser fecha parenteses
        if (*token_type!=CLOSEPARENT)
        {
            *vErroProc = 15;
            return 0;
        }
    }

    // Procura na lista geral de variaveis simples / array
    if (vArray)
        vLista = pStartArrayVar;
    else
        vLista = pStartSimpVar;

    if (1)  // (!vArray) // sem array por enquanto, para ajustar tamanho variavel no cache
    {
        cacheName0Ptr = lastVarCacheName0;
        cacheName1Ptr = lastVarCacheName1;
        cacheAddrPtr = lastVarCacheAddr;

        for (vCacheIx = 0; vCacheIx < SIMPLE_VAR_CACHE_SLOTS; vCacheIx++)
        {
            if (*cacheAddrPtr &&
                *cacheName0Ptr == vVarName0 &&
                *cacheName1Ptr == vVarName1)
            {
                vLista = *cacheAddrPtr;

                *value_type = *vLista;

                if (vArray)
                {
                    if (*vLista == '$')
                        vTamValue = 5;

                    // Verifica se os tamanhos da dimensao informada e da variavel sao iguais
                    if (ixDim != vLista[7])
                    {
                        *vErroProc = 21;
                        return 0;
                    }

                    vPosValueVar = getArrayValuePointer(ixDim, vLista, vDim, vTamValue);
                    if (*vErroProc)
                        return 0;
                }
                else
                {
                    vPosValueVar = vLista + 3;
                }

                if (*vLista == '$')
                {
                    vOffSet  = (((unsigned long)*(vPosValueVar + 1) << 24) & 0xFF000000);
                    vOffSet |= (((unsigned long)*(vPosValueVar + 2) << 16) & 0x00FF0000);
                    vOffSet |= (((unsigned long)*(vPosValueVar + 3) << 8) & 0x0000FF00);
                    vOffSet |= ((unsigned long)*(vPosValueVar + 4) & 0x000000FF);
                    vTempPointer = vOffSet;
                    iy = *vPosValueVar;
                    pDst = pVariable;
                    pSrc = vTempPointer;
                    for (ix = 0; ix < iy; ix++)
                    {
                        *pDst++ = *pSrc++;
                    }
                    *pDst = 0x00;
                }
                else
                {
                    if (!vArray)
                        vPosValueVar++;

                    pVariable[0] = *(vPosValueVar);
                    pVariable[1] = *(vPosValueVar + 1);
                    pVariable[2] = *(vPosValueVar + 2);
                    pVariable[3] = *(vPosValueVar + 3);
                    pVariable[4] = 0x00;
                }

                return (long)vLista;
            }

            cacheAddrPtr++;
            cacheName0Ptr++;
            cacheName1Ptr++;
        }
    }

    while(1)
    {
        vPosNextVar  = (((unsigned long)*(vLista + 3) << 24) & 0xFF000000);
        vPosNextVar |= (((unsigned long)*(vLista + 4) << 16) & 0x00FF0000);
        vPosNextVar |= (((unsigned long)*(vLista + 5) << 8) & 0x0000FF00);
        vPosNextVar |= ((unsigned long)*(vLista + 6) & 0x000000FF);
        *value_type = *vLista;

        if (*(vLista + 1) == pVariable[0] && *(vLista + 2) ==  pVariable[1])
        {
            // Pega endereco da variavel pra delvover
            if (vArray)
            {
                if (*vLista == '$')
                    vTamValue = 5;

                // Verifica se os tamanhos da dimensao informada e da variavel sao iguais
                if (ixDim != vLista[7])
                {
                    *vErroProc = 21;
                    return 0;
                }

                vPosValueVar = getArrayValuePointer(ixDim, vLista, vDim, vTamValue);
                if (*vErroProc)
                    return 0;

                vEnder = vPosValueVar;
            }
            else
            {
                vPosValueVar = vLista + 3;
                vEnder = vLista;
            }

            // Pelo tipo da variavel, ja retorna na variavel de nome o conteudo da variavel
            if (*vLista == '$')
            {
/*if (*debugOn)
{
writeLongSerial("Aqui 333.666.0-[");
writeSerial(*vLista);
writeLongSerial("]-[");
itoa(vPosValueVar,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");
}*/
                vOffSet  = (((unsigned long)*(vPosValueVar + 1) << 24) & 0xFF000000);
                vOffSet |= (((unsigned long)*(vPosValueVar + 2) << 16) & 0x00FF0000);
                vOffSet |= (((unsigned long)*(vPosValueVar + 3) << 8) & 0x0000FF00);
                vOffSet |= ((unsigned long)*(vPosValueVar + 4) & 0x000000FF);
                vTemp = vOffSet;

                iy = *vPosValueVar;
                pDst = pVariable;
                pSrc = vTemp;

/*if (*debugOn)
{
writeLongSerial("Aqui 333.666.1-[");
itoa(vTemp,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
}*/
                for (ix = 0; ix < iy; ix++)
                {
/*if (*debugOn)
{
itoa(ix,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
        itoa((unsigned long)(pDst - pVariable),sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
        itoa(*pSrc,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
}*/
                      *pDst = *pSrc;
/*if (*debugOn)
{
        itoa(*pDst,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
}*/
                      pDst++;
                      pSrc++;
                }
/*if (*debugOn)
{
writeLongSerial("]\r\n");
}*/

                  *pDst = 0x00;

/*if (*debugOn)
{
writeLongSerial("Aqui 333.666.2-[");
itoa(vOffSet,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pVariable[0],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pVariable[1],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pVariable[2],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pVariable[3],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");
}*/
            }
            else
            {
                if (!vArray)
                    vPosValueVar++;

                pVariable[0] = *(vPosValueVar);
                pVariable[1] = *(vPosValueVar + 1);
                pVariable[2] = *(vPosValueVar + 2);
                pVariable[3] = *(vPosValueVar + 3);
                pVariable[4] = 0x00;
            }

            if (!vArray)
            {
                for (ix = (SIMPLE_VAR_CACHE_SLOTS - 1); ix > 0; ix--)
                {
                    lastVarCacheName0[ix] = lastVarCacheName0[ix - 1];
                    lastVarCacheName1[ix] = lastVarCacheName1[ix - 1];
                    lastVarCacheAddr[ix] = lastVarCacheAddr[ix - 1];
                }
                lastVarCacheName0[0] = vVarName0;
                lastVarCacheName1[0] = vVarName1;
                lastVarCacheAddr[0] = vLista;
            }

            return vEnder;
        }

        if (vArray)
            vLista = vPosNextVar;
        else
            vLista += 8;

        if ((!vArray && vLista >= pStartArrayVar) || (vArray && vLista >= pStartProg) || *vLista == 0x00)
            break;
    }

    return 0;
}

//-----------------------------------------------------------------------------
// Cria a Variavel NO ENDEREÇO DEFINIDO POR nextAddrSimpVar OU nextAddrArrayVar,
// DE ACORDO COM O TIPO E NOME INFORMADOS
//-----------------------------------------------------------------------------
char createVariable(unsigned char* pVariable, unsigned char* pValor, char pType)
{
    char vRet = 0;
    long vTemp = 0;
    char vBuffer [sizeof(long)*8+1];
    unsigned char* vNextSimpVar;
    char vLenVar = 0;

    vTemp = *nextAddrSimpVar;
    vNextSimpVar = *nextAddrSimpVar;

    vLenVar = strlen(pVariable);

    *vNextSimpVar++ = pType;
    *vNextSimpVar++ = pVariable[0];
    *vNextSimpVar++ = pVariable[1];

    vRet = updateVariable(vNextSimpVar, pValor, pType, 0);
    *nextAddrSimpVar += 8;

    return vRet;
}

//-----------------------------------------------------------------------------
// Atualiza o valor da Variavel no ENDEREÇO DEFINIDO POR nextAddrSimpVar OU nextAddrArrayVar,
// DE ACORDO COM O TIPO E NOME INFORMADOS
//-----------------------------------------------------------------------------
char updateVariable(unsigned long* pVariable, unsigned char* pValor, char pType, char pOper)
{
    long vNumVal = 0;
    int ix, iz = 0;
    char vBuffer [sizeof(long)*8+1];
    unsigned char* vNextSimpVar;
    unsigned char* vNextString;
    char pNewStr = 0;
    unsigned long vOffSet;
//    unsigned char* sqtdtam[20];

    vNextSimpVar = pVariable;
    *atuVarAddr = pVariable;

/*writeLongSerial("Aqui 333.666.0-[");
itoa(pVariable,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pValor,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pType,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

    if (pType == '#' || pType == '%')   // Real ou Inteiro
    {
        if (vNextSimpVar < pStartArrayVar)
            *vNextSimpVar++ = 0x00;

        *vNextSimpVar++ = pValor[0];
        *vNextSimpVar++ = pValor[1];
        *vNextSimpVar++ = pValor[2];
        *vNextSimpVar++ = pValor[3];
    }
    else // String
    {
        iz = strlen(pValor);    // Tamanho da strings

/*writeLongSerial("Aqui 333.666.1-[");
itoa(*vNextSimpVar,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(iz,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pOper,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/
        // Se for o mesmo tamanho ou menor, usa a mesma posicao
        if (*vNextSimpVar <= iz && pOper)
        {
            vOffSet  = (((unsigned long)*(vNextSimpVar + 1) << 24) & 0xFF000000);
            vOffSet |= (((unsigned long)*(vNextSimpVar + 2) << 16) & 0x00FF0000);
            vOffSet |= (((unsigned long)*(vNextSimpVar + 3) << 8) & 0x0000FF00);
            vOffSet |= ((unsigned long)*(vNextSimpVar + 4) & 0x000000FF);
            vNextString = vOffSet;

            if (pOper == 2 && vNextString == 0)
            {
                vNextString = *nextAddrString;
                pNewStr = 1;
            }
        }
        else
            vNextString = *nextAddrString;

        vNumVal = vNextString;
/*writeLongSerial("Aqui 333.666.2-[");
itoa(nextAddrString,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vNextString,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vNumVal,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

        for (ix = 0; ix < iz; ix++)
        {
            *vNextString++ = pValor[ix];
        }

/*writeLongSerial("Aqui 333.666.3-[");
itoa(nextAddrString,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vNextString,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vNumVal,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

        if (*vNextSimpVar > iz || !pOper || pNewStr)
            *nextAddrString = vNextString;

/*writeLongSerial("Aqui 333.666.4-[");
itoa(vNextString,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vNumVal,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

        *vNextSimpVar++ = iz;

/*writeLongSerial("Aqui 333.666.5-[");
itoa(vNextString,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

        *vNextSimpVar++ = ((vNumVal & 0xFF000000) >>24);
        *vNextSimpVar++ = ((vNumVal & 0x00FF0000) >>16);
        *vNextSimpVar++ = ((vNumVal & 0x0000FF00) >>8);
        *vNextSimpVar++ = (vNumVal & 0x000000FF);
/*writeLongSerial("Aqui 333.666.6-[");
itoa(vNextString,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/
    }

/*    *(vNextSimpVar + 1) = 0x00;
    *(vNextSimpVar + 2) = 0x00;
    *(vNextSimpVar + 3) = 0x00;
    *(vNextSimpVar + 4) = 0x00;*/

    return 0;
}

//--------------------------------------------------------------------------------------
// Cria a Variavel Array NO ENDEREÇO DEFINIDO POR nextAddrArrayVar, DE ACORDO COM O TIPO,
// NOME E DIMENSÕES INFORMADOS
//--------------------------------------------------------------------------------------
char createVariableArray(unsigned char* pVariable, char pType, unsigned int pNumDim, unsigned int *pDim)
{
    char vRet = 0;
    long vTemp = 0;
    unsigned char* vTempC = &vTemp;
    char vBuffer [sizeof(long)*8+1];
    unsigned char* vNextArrayVar;
    char vLenVar = 0;
    int ix, vTam;
    long vAreaFree = vMemTotalArrayVar - (*nextAddrArrayVar - pStartArrayVar);
    long vSizeTotal = 0;
    unsigned char sqtdtam[20];

    vTemp = *nextAddrArrayVar;
    vNextArrayVar = *nextAddrArrayVar;

    vLenVar = strlen(pVariable);

    *vNextArrayVar++ = pType;
    *vNextArrayVar++ = pVariable[0];
    *vNextArrayVar++ = pVariable[1];
    vTam = 0;

    for (ix = 0; ix < pNumDim; ix++)
    {
        // Somando mais 1, porque 0 = 1 em quantidade e e em posicao (igual ao c)
        pDim[ix] = pDim[ix] /*+ 1*/ ;

        // Definir o tamanho do campo de dados do array
        if (vTam == 0)
            vTam = pDim[ix] /*- 1*/ ;
        else
            vTam = vTam * (pDim[ix] /*- 1*/ );

/*writeLongSerial("Aqui 333.666.0-[");
itoa(vTam,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(ix,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pDim[ix],sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/
    }

/*writeLongSerial("Aqui 333.666.1-[");
itoa(vTam,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(pNumDim,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

    if (pType == '$')
        vTam = vTam * 5;
    else
        vTam = vTam * 4;

/*writeLongSerial("Aqui 333.666.2-[");
itoa(pType,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vTam,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/

    vSizeTotal = vTam + 8;
    vSizeTotal = vSizeTotal + (pNumDim *2);

#ifdef BASIC_DEBUG_ON
if (*debugOn)
{
writeLongSerial("Aqui 333.666.3-[");
itoa(pStartArrayVar,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*nextAddrArrayVar,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vAreaFree,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vMemTotalArrayVar,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vSizeTotal,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");
}
#endif

    if (vSizeTotal > vAreaFree)
    {
        *vErroProc = 22;
        return 0;
    }

    // Coloca setup do array
    vTemp = vTemp + vTam + 8 + (pNumDim * 2);
    *vNextArrayVar++ = vTempC[0];
    *vNextArrayVar++ = vTempC[1];
    *vNextArrayVar++ = vTempC[2];
    *vNextArrayVar++ = vTempC[3];
    *vNextArrayVar++ = pNumDim;

    for (ix = 0; ix < pNumDim; ix++)
    {
        *vNextArrayVar++ = (pDim[ix] >> 8);
        *vNextArrayVar++ = (pDim[ix] & 0xFF);
    }

    // Limpa area de dados (zera)
    for (ix = 0; ix < vTam; ix++)
        *(vNextArrayVar + ix) = 0x00;

    *nextAddrArrayVar = vTemp;

    return 0;
}

//--------------------------------------------------------------------------------------
//  SAVE <name> salva program basic atual na memoria, no disco
//--------------------------------------------------------------------------------------
int saveBasFile(unsigned char* pArquivo)
{
    unsigned char fileName[32];
    unsigned short ix;
    unsigned long vNextList;
    unsigned char *vStartList;
    unsigned char vLinhaList[255];
    unsigned long vOffset;
    unsigned short vLen, vChunk, vPos;
    unsigned long vClusterOld;

    if (*startBasic != 1)
    {
        *vErroProc = 27;
        return 0;
    }

    if (!pArquivo || !*pArquivo)
    {
        *vErroProc = 14;
        return 0;
    }

    // FS local trabalha com short name em uppercase.
    ix = 0;
    while (pArquivo[ix] && ix < (sizeof(fileName) - 1))
    {
        fileName[ix] = toupper(pArquivo[ix]);
        ix++;
    }
    fileName[ix] = 0x00;

    vClusterOld = fsGetClusterDir();
    fsChangeDir("/");

    if (fsOpenFile(fileName) == RETURN_OK)
    {
        if (fsDelFile(fileName) != RETURN_OK)
        {
            fsSetClusterDir(vClusterOld);
            *vErroProc = 27;
            return 0;
        }
    }

    if (fsCreateFile(fileName) != RETURN_OK)
    {
        fsSetClusterDir(vClusterOld);
        *vErroProc = 27;
        return 0;
    }

    vStartList = pStartProg;
    vOffset = 0;

    while (1)
    {
        vNextList = (*(vStartList) << 16) | (*(vStartList + 1) << 8) | *(vStartList + 2);

        if (!vNextList)
            break;

        vLen = basBuildListTextLine(vStartList, vLinhaList, sizeof(vLinhaList), 0);
        vPos = 0;
        while (vPos < vLen)
        {
            vChunk = (unsigned short)(vLen - vPos);
            if (vChunk > 128)
                vChunk = 128;

            if (fsWriteFile(fileName, vOffset, &vLinhaList[vPos], (unsigned char)vChunk) != RETURN_OK)
            {
                fsCloseFile(fileName, 0);
                fsSetClusterDir(vClusterOld);
                *vErroProc = 27;
                return 0;
            }

            vOffset += vChunk;
            vPos += vChunk;
        }

        vStartList = (unsigned char *)vNextList;
    }

    fsCloseFile(fileName, 1);
    fsSetClusterDir(vClusterOld);

    return 0;
}

//--------------------------------------------------------------------------------------
//  LOAD <name> carrega um programa do disco
//--------------------------------------------------------------------------------------
int loadBasFile(unsigned char* pArquivo)
{
    unsigned char fileName[32];
    unsigned short ix;
    unsigned char countTec = 0, vByte;
    unsigned char *vTemp;
    unsigned char *vBufptr = &vbufInput;
    unsigned long vClusterOld;

    if (*startBasic != 1)
    {
        *vErroProc = 27;
        return 0;
    }

    if (!pArquivo || !*pArquivo)
    {
        *vErroProc = 14;
        return 0;
    }

    ix = 0;
    while (pArquivo[ix] && ix < (sizeof(fileName) - 1))
    {
        fileName[ix] = toupper(pArquivo[ix]);
        ix++;
    }
    fileName[ix] = 0x00;

    // Limpa programa atual antes de carregar o novo.
    *pStartProg = 0x00;
    *(pStartProg + 1) = 0x00;
    *(pStartProg + 2) = 0x00;
    *nextAddrLine = pStartProg;
    *firstLineNumber = 0;
    *addrFirstLineNumber = 0;
    *nextAddrSimpVar = pStartSimpVar;
    *nextAddrArrayVar = pStartArrayVar;
    *nextAddrString = pStartString;
    clearRuntimeData((unsigned char*)forStack);

    // Carregar Arquivo do disco na memoria
    if (*startBasic != 2)
        printText("Loading...\r\n");

    // Limpando memoria
    memset(pStartXBasLoad,0x1A,vMemTotalXBasLoad);
    // Carrega do disco
    verro = 0x00;
    vClusterOld = fsGetClusterDir();
    fsChangeDir("/");
    loadFile(fileName, (unsigned long*)pStartXBasLoad);
    fsSetClusterDir(vClusterOld);
    if (!verro)
    {
        // Processar
        if (*startBasic != 2)
            printText("Processing...\r\n");

        vTemp = pStartXBasLoad;

        while (1)
        {
            vByte = *vTemp++;

            if (vByte != 0x1A)
            {
                if (vByte != 0xD && vByte != 0x0A)
                    *vBufptr++ = vByte;
                else
                {
                    vTemp++;
                    *vBufptr = 0x00;
                    vBufptr = &vbufInput;
                    if (*vbufInput == 0x00)
                        break;
                    processLine();
                }
            }
            else
                break;
        }

        if (*startBasic != 2)
            printText("Done.\r\n");
    }
    else
    {
        printText("Loading File Error...\r\n\0");
    }

    vbufInput[0] = 0x00;
    vBufptr = &vbufInput;

    return 0;
}

/*****************************************************************************/
/* FUNCOES BASIC                                                             */
/*****************************************************************************/

//-----------------------------------------------------------------------------
// Joga pra tela Texto.
// Syntaxe:
//      Print "<Texto>"/<value>[, "<Texto>"/<value>][; "<Texto>"/<value>]
//-----------------------------------------------------------------------------
int basPrint(void)
{
    unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
    char sNumLin [sizeof(short)*8+1];
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[200];
    long *lVal = answer;
    int  *iVal = answer;
    int len=0, spaces;
    char last_delim, last_token_type = 0;
    unsigned char sqtdtam[10];

    do {
        nextToken();
        if (*vErroProc) return 0;

        if (*tok == EOL || *tok == FINISHED)
            break;

        if (*token_type == QUOTE) { // is string
            printText(token);

            nextToken();
            if (*vErroProc) return 0;
        }
        else if (*token!=':') { // is expression
            last_token_type = *token_type;

            putback();

            getExp(&answer);
            if (*vErroProc) return 0;

            if (*value_type != '$')
            {
                if (*value_type == '#')
                {
                    // Real
                    fppTofloatString(*lVal, answer);
                    if (*vErroProc) return 0;
                }
                else
                {
                    // Inteiro
                    itoa(*iVal, answer, 10);
                }
            }

            printText(answer);

            nextToken();
            if (*vErroProc) return 0;
        }

        last_delim = *token;

        if (*token==',') {
            // compute number of spaces to move to next tab
            spaces = 8 - (len % 8);
            while(spaces) {
                printChar(' ',1);
                spaces--;
            }
        }
        else if (*token==';' || *token=='+')
            /* do nothing */;
        else if (*token==':')
        {
            *pointerRunProg = *pointerRunProg - 1;
        }
        else if (*tok!=EOL && *tok!=FINISHED && *token!=':')
        {
            *vErroProc = 14;
            return 0;
        }
    } while (*token==';' || *token==',' || *token=='+');

    if (*tok == EOL || *tok == FINISHED || *token==':') {
        if (last_delim != ';' && last_delim!=',')
            printText("\r\n");
    }

    return 0;
}

//-----------------------------------------------------------------------------
// Devolve o caracter ligado ao codigo ascii passado
// Syntaxe:
//      CHR$(<codigo ascii>)
//-----------------------------------------------------------------------------
int basChr(void)
{
    unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
    char sNumLin [sizeof(short)*8+1];
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[10];
    long *lVal = answer;
    int  *iVal = answer;
    int len=0, spaces;
    char last_delim, last_token_type = 0;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        last_token_type = *token_type;

        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }

        // Inteiro
        if (*iVal<0 || *iVal>255)
        {
            *vErroProc = 5;
            return 0;
        }
    }

    last_delim = *token;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    *token=(char)*iVal;
    *(token + 1)=0x00;
    *value_type='$';

    return 0;
}

//-----------------------------------------------------------------------------
// Devolve o numerico da string
// Syntaxe:
//      VAL(<string>)
//-----------------------------------------------------------------------------
int basVal(void)
{
    unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
    char sNumLin [sizeof(short)*8+1];
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[20];
    int  iVal = answer;
    int vValue = 0;
    int len=0, spaces;
    char last_delim, last_value_type=' ', last_token_type = 0;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        if (strchr(token,'.'))  // verifica se eh numero inteiro ou real
        {
            last_value_type='#'; // Real
            iVal=floatStringToFpp(token);
            if (*vErroProc) return 0;
        }
        else
        {
            last_value_type='%'; // Inteiro
            iVal=atoi(token);
        }
    }
    else { /* is expression */
        last_token_type = *token_type;

        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type != '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (strchr(answer,'.'))  // verifica se eh numero inteiro ou real
        {
            last_value_type='#'; // Real
            iVal=floatStringToFpp(answer);
            if (*vErroProc) return 0;
        }
        else
        {
            last_value_type='%'; // Inteiro
            iVal=atoi(answer);
        }
    }

    last_delim = *token;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    *token=((int)(iVal & 0xFF000000) >> 24);
    *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
    *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
    *(token + 3)=(iVal & 0x000000FF);

    *value_type = last_value_type;

    return 0;
}

//-----------------------------------------------------------------------------
// Devolve a string do numero
// Syntaxe:
//      STR$(<Numero>)
//-----------------------------------------------------------------------------
int basStr(void)
{
    unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
    char sNumLin [sizeof(short)*8+1];
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[50];
    long *lVal = answer;
    int  *iVal = answer;
    int len=0, spaces;
    char last_delim, last_token_type = 0;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        last_token_type = *token_type;

        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }
    }

    last_delim = *token;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    if (*value_type=='#')    // real
    {
        fppTofloatString(*iVal,token);
        if (*vErroProc) return 0;
    }
    else    // Inteiro
    {
        itoa(*iVal,token,10);
    }

    *value_type='$';

    return 0;
}

static int basBaseString(unsigned char pBase, unsigned char pSuffix)
{
    unsigned char answer[20];
    int *iVal = answer;
    int len;

    nextToken();
    if (*vErroProc) return 0;

    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE)
    {
        *vErroProc = 16;
        return 0;
    }

    putback();

    getExp(&answer);
    if (*vErroProc) return 0;

    if (*value_type != '%')
    {
        *vErroProc = 16;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type != CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    itoa(*iVal, token, pBase);
    len = strlen(token);
    *(token + len) = pSuffix;
    *(token + len + 1) = 0x00;

    *value_type = '$';

    return 0;
}

int basHex(void)
{
    return basBaseString(16, 'h');
}

int basBin(void)
{
    return basBaseString(2, 'b');
}

int basOct(void)
{
    return basBaseString(8, 'o');
}

//-----------------------------------------------------------------------------
// Devolve o tamanho da string
// Syntaxe:
//      LEN(<string>)
//-----------------------------------------------------------------------------
int basLen(void)
{
    unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
    char sNumLin [sizeof(short)*8+1];
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[200];
    int iVal = 0;
    int vValue = 0;
    int len=0, spaces;
    char last_delim, last_token_type = 0;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        iVal=strlen(token);
    }
    else { /* is expression */
        last_token_type = *token_type;

        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type != '$')
        {
            *vErroProc = 16;
            return 0;
        }

        iVal=strlen(answer);
    }

    last_delim = *token;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    *token=((int)(iVal & 0xFF000000) >> 24);
    *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
    *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
    *(token + 3)=(iVal & 0x000000FF);

    *value_type='%';

    return 0;
}

//-----------------------------------------------------------------------------
// Devolve qtd memoria usuario disponivel
// Syntaxe:
//      FRE(0)
//-----------------------------------------------------------------------------
int basFre(void)
{
    unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
    char sNumLin [sizeof(short)*8+1];
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[50];
    long *lVal = answer;
    int  *iVal = answer;
    long vTotal = 0;
    char vBuffer [sizeof(long)*8+1];
    int len=0, spaces;
    char last_delim;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*iVal!=0)
        {
            *vErroProc = 5;
            return 0;
        }
    }

    last_delim = *token;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    // Calcula Quantidade de Memoria e printa na tela
    vTotal = (pStartArrayVar - pStartSimpVar) + (pStartString - pStartArrayVar);
/*    printText("Memory Free for: \r\n\0");
     ltoa(vTotal, vBuffer, 10);
    printText("     Variables: \0");
    printText(vBuffer);
    printText("Bytes\r\n\0");

    vTotal = pStartProg - *nextAddrArrayVar;
    ltoa(vTotal, vBuffer, 10);
    printText("        Arrays: \0");
    printText(vBuffer);
    printText("Bytes\r\n\0");

    vTotal = pStartXBasLoad - *nextAddrLine;
    ltoa(vTotal, vBuffer, 10);
    printText("       Program: \0");
    printText(vBuffer);
    printText("Bytes\r\n\0");*/

    *token=((int)(vTotal & 0xFF000000) >> 24);
    *(token + 1)=((int)(vTotal & 0x00FF0000) >> 16);
    *(token + 2)=((int)(vTotal & 0x0000FF00) >> 8);
    *(token + 3)=(vTotal & 0x000000FF);

    *value_type='%';

    return 0;
}

//--------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------
int basTrig(unsigned char pFunc)
{
    unsigned long vReal = 0, vResult = 0;
    unsigned char sqtdtam[20];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    putback();

    getExp(&vReal); //

    if (*value_type == '$')
    {
        *vErroProc = 16;
        return 0;
    }
    else if (*value_type != '#')
    {
        *value_type='#'; // Real
        vReal=fppReal(vReal);
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    switch (pFunc)
    {
        case 1: // sin
            vResult = fppSin(vReal);
            break;
        case 2: // cos
            vResult = fppCos(vReal);
            break;
        case 3: // tan
            vResult = fppTan(vReal);
            break;
        case 4: // log (ln)
            vResult = fppLn(vReal);
            break;
        case 5: // exp
            vResult = fppExp(vReal);
            break;
        case 6: // sqrt
            vResult = fppSqrt(vReal);
            break;
        default:
            *vErroProc = 14;
            return 0;
    }


    *token=((int)(vResult & 0xFF000000) >> 24);
    *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
    *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
    *(token + 3)=(vResult & 0x000000FF);

    *value_type = '#';

    return 0;
}

//--------------------------------------------------------------------------------------
//  ASC("x") devolve o codigo ascii do caracter
//--------------------------------------------------------------------------------------
int basAsc(void)
{
    unsigned char answer[20];
    int  iVal = answer;
    char last_delim;

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        if (strlen(token)>1)
        {
            *vErroProc = 6;
            return 0;
        }

        iVal = *token;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type != '$')
        {
            *vErroProc = 16;
            return 0;
        }

        iVal = *answer;
    }

    last_delim = *token;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    *token=((int)(iVal & 0xFF000000) >> 24);
    *(token + 1)=((int)(iVal & 0x00FF0000) >> 16);
    *(token + 2)=((int)(iVal & 0x0000FF00) >> 8);
    *(token + 3)=(iVal & 0x000000FF);

    *value_type = '%';

    return 0;
}

//--------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------
int basLeftRightMid(char pTipo)
{
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[200], vTemp[200];
    int vqtd = 0, vstart = 0;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        strcpy(vTemp, token);
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type != '$')
        {
            *vErroProc = 16;
            return 0;
        }

        strcpy(vTemp, answer);
    }

    nextToken();
    if (*vErroProc) return 0;

    // Deve ser uma virgula para Receber a qtd, e se for mid = a posiao incial
    if (*token!=',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        if (pTipo=='M')
        {
            getExp(&vstart);
            vqtd=strlen(vTemp);
        }
        else
            getExp(&vqtd);

        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }
    }

    if (pTipo == 'M')
    {
        // Deve ser uma virgula para Receber a qtd
        if (*token==',')
        {
            nextToken();
            if (*vErroProc) return 0;

            if (*token_type == QUOTE) { /* is string, error */
                *vErroProc = 16;
                return 0;
            }
            else { /* is expression */
                //putback();

                getExp(&vqtd);

                if (*vErroProc) return 0;

                if (*value_type == '$')
                {
                    *vErroProc = 16;
                    return 0;
                }
            }
        }
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    if (vqtd > strlen(vTemp))
    {
        if (pTipo=='M')
            vqtd = (strlen(vTemp) - vstart) + 1;
        else
            vqtd = strlen(vTemp);
    }

    if (pTipo == 'L') // Left$
    {
        for (ix = 0; ix < vqtd; ix++)
            *(token + ix) = vTemp[ix];
        *(token + ix) = 0x00;
    }
    else if (pTipo == 'R') // Right$
    {
        iy = strlen(vTemp);
        iz = (iy - vqtd);
        iw = 0;
        for (ix = iz; ix < iy; ix++)
            *(token + iw++) = vTemp[ix];
        *(token + iw)=0x00;
    }
    else  // Mid$
    {
        iy = strlen(vTemp);
        iw=0;
        vstart--;

        for (ix = vstart; ix < iy; ix++)
        {
            if (iw <= iy && vqtd-- > 0)
                *(token + iw++) = vTemp[ix];
            else
                break;
        }

        *(token + iw) = 0x00;
    }

    *value_type = '$';

    return 0;
}

//--------------------------------------------------------------------------------------
//  Comandos de memoria
//      Leitura de Memoria:   peek(<endereco>)
//      Gravacao em endereco: poke(<endereco>,<byte>)
//--------------------------------------------------------------------------------------
int basPeekPoke(char pTipo)
{
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[30], vTemp[30];
    unsigned char *vEnd = 0;
    unsigned int vByte = 0;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&vEnd);

        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }
    }

    // Deve ser uma virgula para Receber a qtd
    if (pTipo == 'W')
    {
        if (*token==',')
        {
            nextToken();
            if (*vErroProc) return 0;

            if (*token_type == QUOTE) { /* is string, error */
                *vErroProc = 16;
                return 0;
            }
            else { /* is expression */
                //putback();

                getExp(&vByte);

                if (*vErroProc) return 0;

                if (*value_type == '$')
                {
                    *vErroProc = 16;
                    return 0;
                }
            }
        }
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    if (pTipo == 'R')
    {
        *token = 0;
        *(token + 1) = 0;
        *(token + 2) = 0;
        *(token + 3) = *vEnd;
    }
    else
    {
        *vEnd = (char)vByte;
    }

    *value_type = '%';

    return 0;
}


//--------------------------------------------------------------------------------------
//  Array (min 1 dimensoes)
//      Sintaxe:
//              DIM (<dim 1>[,<dim 2>[,<dim 3>,<dim 4>,...,<dim n>])
//--------------------------------------------------------------------------------------
int basDim(void)
{
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[30], vTemp[30];
    unsigned char sqtdtam[10];
    unsigned int vDim[88], ixDim = 0, vTempDim = 0;
    unsigned char varTipo;
    long vRetFV;

    nextToken();
    if (*vErroProc) return 0;

    // Pega o nome da variavel
    if (!isalphas(*token)) {
        *vErroProc = 4;
        return 0;
    }

    if (strlen(token) < 3)
    {
        *varName = *token;
        varTipo = VARTYPEDEFAULT;

        if (strlen(token) == 2 && *(token + 1) < 0x30)
            varTipo = *(token + 1);

        if (strlen(token) == 2 && isalphas(*(token + 1)))
            *(varName + 1) = *(token + 1);
        else
            *(varName + 1) = 0x00;

        *(varName + 2) = varTipo;
    }
    else
    {
        *varName = *token;
        *(varName + 1) = *(token + 1);
        *(varName + 2) = *(token + 2);
        iz = strlen(token) - 1;
        varTipo = *(varName + 2);
    }

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter depois da variavel, deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    do
    {
        nextToken();
        if (*vErroProc) return 0;

        if (*token_type == QUOTE) { /* is string, error */
            *vErroProc = 16;
            return 0;
        }
        else { /* is expression */
            putback();

            getExp(&vTempDim);
            if (*vErroProc) return 0;

            if (*value_type == '$')
            {
                *vErroProc = 16;
                return 0;
            }

            if (*value_type == '#')
            {
                vTempDim = fppInt(vTempDim);
                *value_type = '%';
            }

            vTempDim += 1; // porque nao é de 1 a x, é de 0 a x, entao é x + 1
            vDim[ixDim] = vTempDim;

            ixDim++;
        }

        if (*token == ',')
        {
            *pointerRunProg = *pointerRunProg + 1;
        }
        else
            break;
    } while(1);

    // Deve ter pelo menos 1 elemento
    if (ixDim < 1)
    {
        *vErroProc = 21;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    // assign the value
    vRetFV = findVariable(varName);
    // Se nao existe a variavel, cria variavel e atribui o valor
    if (!vRetFV)
        createVariableArray(varName, varTipo, ixDim, vDim);
    else
    {
        *vErroProc = 23;
        return 0;
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Processar condição
// Syntaxe:
//          if <condition> then <command>
//--------------------------------------------------------------------------------------
int basIf(void)
{
    unsigned int vCond = 0;
    unsigned char *vTempPointer;

    getExp(&vCond); // get target value

    if (*value_type == '$' || *value_type == '#') {
        *vErroProc = 16;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token!=0x83)
    {
        *vErroProc = 8;
        return 0;
    }

    if (vCond)
    {
        // Vai pro proximo comando apos o Then e continua
        *pointerRunProg = *pointerRunProg + 1;

        // simula ":" para continuar a execucao
        *doisPontos = 1;
    }
    else
    {
        // Ignora toda a linha
        vTempPointer = *pointerRunProg;
        while (*vTempPointer)
        {
            *pointerRunProg = *pointerRunProg + 1;
            vTempPointer = *pointerRunProg;
        }
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Laço se condicao True, processa o que tem dentro, até o wend
// Syntaxe:
//          while <condition>
//          <commands>
//          wend
//--------------------------------------------------------------------------------------
unsigned char *topWhile(void)
{
    if (while_sp <= 0)
        return (unsigned char *)0;

    return while_ptr_stack[while_sp - 1];
}

int pushWhile(unsigned char *ptr)
{
    unsigned char sqtdtam[20];
    if (while_sp >= MAX_WHILE_STACK)
        return 0;

    while_ptr_stack[while_sp] = ptr;
    while_sp++;

    return 1;
}

int verifyWhile(unsigned char *ptr)
{
    if (while_sp == 0)
        return 0;

    if (while_ptr_stack[while_sp - 1] == ptr)
        return 1;

    return 0;
}

int popWhile(void)
{
    unsigned char sqtdtam[20];
    if (while_sp <= 0)
        return 0;

    while_sp--;

    return 1;
}

int basWhile(void)
{
    unsigned char *pWhile;
    unsigned int vCond = 0;
    unsigned char *vTempPointer;
    unsigned char sqtdtam[20];
    unsigned char vPosWend = 0;

    pWhile = *pointerRunProg;
    pWhile -= 6;

    getExp(&vCond); // get target value

    if (*value_type == '$' || *value_type == '#') {
        *vErroProc = 16;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (vCond)
    {
        if (!verifyWhile(pWhile))
        {
            if (!pushWhile(pWhile))
            {
                *vErroProc = 29;
                return 0;
            }
        }
    }
    else
    {
        popWhile();

        vTempPointer = *pointerRunProg;

        while(1) // Search WEND
        {
            *pointerRunProg = *pointerRunProg + 1;
            vTempPointer = *pointerRunProg;

            if (*vTempPointer == 0xBC) // WHILE
                vPosWend++;

            if (*vTempPointer == 0xBD)
            {
                if (vPosWend)
                    vPosWend--;
                else
                    break;
            }
        }

        *pointerRunProg = *pointerRunProg + 2;

        *changedPointer = *pointerRunProg;
    }

    return 0;
}

int basWend(void)
{
    unsigned char *pWhile;
    int retCond;
    unsigned char sqtdtam[20];

    pWhile = topWhile();

    if (pWhile == (unsigned char *)0){
        *vErroProc = 28;
        return 0;
    }

    *changedPointer = pWhile;

    return 0;
}

//--------------------------------------------------------------------------------------
// Atribuir valor a uma variavel/array - comando opcional.
// Syntaxe:
//            [LET] <variavel/array(x[,y])> = <string/valor>
//--------------------------------------------------------------------------------------
int basLet(void)
{
    long vRetFV, iz;
    unsigned char varTipo;
    unsigned char value[200];
    unsigned long *lValue = &value;
    unsigned char sqtdtam[10];
    unsigned char vArray = 0;
    unsigned char *vTempPointer;

    /* get the variable name */
    nextToken();
    if (*vErroProc) return 0;

    if (!isalphas(*token)) {
        *vErroProc = 4;
        return 0;
    }

    if (strlen(token) < 3)
    {
        *varName = *token;
        varTipo = VARTYPEDEFAULT;

        if (strlen(token) == 2 && *(token + 1) < 0x30)
            varTipo = *(token + 1);

        if (strlen(token) == 2 && isalphas(*(token + 1)))
            *(varName + 1) = *(token + 1);
        else
            *(varName + 1) = 0x00;

        *(varName + 2) = varTipo;
    }
    else
    {
        *varName = *token;
        *(varName + 1) = *(token + 1);
        *(varName + 2) = *(token + 2);
        iz = strlen(token) - 1;
        varTipo = *(varName + 2);
    }

    // verifica se é array (abre parenteses no inicio)
    vTempPointer = *pointerRunProg;
    if (*vTempPointer == 0x28)
    {
        vRetFV = findVariable(varName);
        if (*vErroProc) return 0;

        if (!vRetFV)
        {
            *vErroProc = 4;
            return 0;
        }

        vArray = 1;
    }

    // get the equals sign
    nextToken();
    if (*vErroProc) return 0;

    if (*token!='=') {
        *vErroProc = 3;
        return 0;
    }
    /* get the value to assign to varName */
    getExp(&value);

    if (varTipo == '#' && *value_type != '#')
        *lValue = fppReal(*lValue);

    // assign the value
    if (!vArray)
    {
        vRetFV = findVariable(varName);
        // Se nao existe a variavel, cria variavel e atribui o valor
        if (!vRetFV)
            createVariable(varName, value, varTipo);
        else // se ja existe, altera
            updateVariable((vRetFV + 3), value, varTipo, 1);
    }
    else
    {
        updateVariable(vRetFV, value, varTipo, 2);
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Entrada pelo teclado de numeros/caracteres ateh teclar ENTER (INPUT)
// Entrada pelo teclado de um unico caracter ou numero (GET)
// Entrada dos dados de acordo com o tipo de variavel $(qquer), %(Nums), #(Nums & '.')
// Syntaxe:
//          INPUT ["texto",]<variavel> : A variavel sera criada se nao existir
//          GET <variavel> : A variavel sera criada se nao existir
//--------------------------------------------------------------------------------------
int basInputGet(unsigned char pSize)
{
    unsigned char vAspas = 0, vVirgula = 0, vTemp[250];
    char sNumLin [sizeof(short)*8+1];
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[200], vtec;
    long *lVal = answer;
    int  *iVal = answer;
    char vTemTexto = 0;
    int len=0, spaces;
    char last_delim;
    unsigned char *buffptr = &vbufInput;
    long vRetFV;
    unsigned char varTipo;
    char vArray = 0;
    unsigned char *vTempPointer;

    do {
        nextToken();
        if (*vErroProc) return 0;

        if (*tok == EOL || *tok == FINISHED)
            break;

        if (*token_type == QUOTE) /* is string */
        {
            if (vTemTexto)
            {
                *vErroProc = 14;
                return 0;
            }

            printText(token);

            nextToken();
            if (*vErroProc) return 0;

            vTemTexto = 1;
        }
        else /* is expression */
        {
            // Verifica se comeca com letra, pois tem que ser uma variavel agora
            if (!isalphas(*token))
            {
                *vErroProc = 4;
                return 0;
            }

            if (strlen(token) < 3)
            {
                *varName = *token;
                varTipo = VARTYPEDEFAULT;

                if (strlen(token) == 2 && *(token + 1) < 0x30)
                    varTipo = *(token + 1);

                if (strlen(token) == 2 && isalphas(*(token + 1)))
                    *(varName + 1) = *(token + 1);
                else
                    *(varName + 1) = 0x00;

                *(varName + 2) = varTipo;
            }
            else
            {
                *varName = *token;
                *(varName + 1) = *(token + 1);
                *(varName + 2) = *(token + 2);
                iz = strlen(token) - 1;
                varTipo = *(varName + 2);
            }

            answer[0] = 0x00;
            vbufInput[0] = 0x00;

            if (pSize == 1)
            {
                // GET
                for (ix = 0; ix < 15000; ix++)
                {
                    vtec = readChar();
                    if (vtec)
                        break;
                }
//                vtec = inputLineBasic(1,'@');    // Qualquer coisa

                if (varTipo != '$' && vtec)
                {
                    if (!isdigitus(vtec))
                        vtec = 0;
                }

                answer[0] = vtec;
                answer[1] = 0x00;
            }
            else
            {
                // INPUT
                vtec = inputLineBasic(255,varTipo);

                if (vbufInput[0] != 0x00 && (vtec == 0x0D || vtec == 0x0A))
                {
                    ix = 0;

                    while (*buffptr)
                    {
                        answer[ix++] = *buffptr++;
                        answer[ix] = 0x00;
                    }
                }

                printText("\r\n");
            }

            if (varTipo!='$')
            {
                if (varTipo=='#')  // verifica se eh numero inteiro ou real
                {
                    iVal=floatStringToFpp(answer);
                    if (*vErroProc) return 0;
                }
                else
                {
                    iVal=atoi(answer);
                }

                answer[0]=((int)(*iVal & 0xFF000000) >> 24);
                answer[1]=((int)(*iVal & 0x00FF0000) >> 16);
                answer[2]=((int)(*iVal & 0x0000FF00) >> 8);
                answer[3]=(char)(*iVal & 0x000000FF);
            }

            vTempPointer = *pointerRunProg;
            if (*vTempPointer == 0x28)
            {
                vRetFV = findVariable(varName);
                if (*vErroProc) return 0;

                if (!vRetFV)
                {
                    *vErroProc = 4;
                    return 0;
                }

                vArray = 1;
            }

            if (!vArray)
            {
                // assign the value
                vRetFV = findVariable(varName);

                // Se nao existe variavel e inicio sentenca, cria variavel e atribui o valor
                if (!vRetFV)
                    createVariable(varName, answer, varTipo);
                else // se ja existe, altera
                    updateVariable((vRetFV + 3), answer, varTipo, 1);
            }
            else
            {
                updateVariable(vRetFV, answer, varTipo, 2);
            }

            vTemTexto=2;
            nextToken();
            if (*vErroProc) return 0;
        }

        last_delim = *token;

        if (vTemTexto==1 && *token==';')
            /* do nothing */;
        else if (vTemTexto==1 && *token!=';')
        {
            *vErroProc = 14;
            return 0;
        }
        else if (vTemTexto!=1 && *token==';')
        {
            *vErroProc = 14;
            return 0;
        }
        else if (*tok!=EOL && *tok!=FINISHED && *token!=':')
        {
            *vErroProc = 14;
            return 0;
        }
    } while (*token==';');

    return 0;
}

//--------------------------------------------------------------------------------------
char forFind(for_stack *i, unsigned char* endLastVar)
{
    int ix;
    unsigned char sqtdtam[10];
    for_stack *j;

    j = forStack;

    for(ix = 0; ix < *ftos; ix++)
    {
        if (j[ix].nameVar[0] == endLastVar[1] && j[ix].nameVar[1] == endLastVar[2])
        {
            *i = j[ix];

            return ix;
        }
        else if (!j[ix].nameVar[0])
            return -1;
    }

    return -1;
}

//--------------------------------------------------------------------------------------
// Inicio do laco de repeticao
// Syntaxe:
//          FOR <variavel> = <inicio> TO <final> [STEP <passo>] : A variavel sera criada se nao existir
//--------------------------------------------------------------------------------------
int basFor(void)
{
    for_stack i, *j;
    int value=0;
    long *endVarCont;
    long iStep = 1;
    long iTarget = 0;
    unsigned char* endLastVar;
    unsigned char sqtdtam[10];
    char vRetVar = -1;
    unsigned char *vTempPointer;
    char vResLog1 = 0, vResLog2 = 0;
    char vResLog3 = 0, vResLog4 = 0;

    basLet();
    if (*vErroProc) return 0;

    endLastVar = *atuVarAddr - 3;
    endVarCont = *atuVarAddr + 1;

    vRetVar = forFind(&i, endLastVar);

    if (vRetVar < 0)
    {
        i.nameVar[0]=endLastVar[1];
        i.nameVar[1]=endLastVar[2];
        i.nameVar[2]=endLastVar[0];
    }

    if (i.nameVar[2] == '#')
        i.step = fppReal(iStep);
    else
        i.step = iStep;

    i.endVar = endVarCont;

    nextToken();
    if (*vErroProc) return 0;

    if (*tok!=0x86) /* read and discard the TO */
    {
        *vErroProc = 9;
        return 0;
    }

    *pointerRunProg = *pointerRunProg + 1;

    getExp(&iTarget); /* get target value */

    if (i.nameVar[2] == '#' && *value_type == '%')
        i.target = fppReal(iTarget);
    else
        i.target = iTarget;

    if (*tok==0x88) /* read STEP */
    {
        *pointerRunProg = *pointerRunProg + 1;

        getExp(&iStep); /* get target value */

        if (i.nameVar[2] == '#' && *value_type == '%')
            i.step = fppReal(iStep);
        else
            i.step = iStep;
    }

    endVarCont=i.endVar;

    // if loop can execute at least once, push info on stack     //    if ((i.step > 0 && *endVarCont <= i.target) || (i.step < 0 && *endVarCont >= i.target))
    if (i.nameVar[2] == '#')
    {
        vResLog1 = logicalNumericFloatLong(0xF6 /* <= */, *endVarCont, i.target);
        vResLog2 = logicalNumericFloatLong(0xF5 /* >= */, *endVarCont, i.target);
        vResLog3 = logicalNumericFloatLong('>', i.step, 0);
        vResLog4 = logicalNumericFloatLong('<', i.step, 0);
    }
    else
    {
        vResLog1 = (*endVarCont <= i.target);
        vResLog2 = (*endVarCont >= i.target);
        vResLog3 = (i.step > 0);
        vResLog4 = (i.step < 0);
    }

    if (vResLog3 && vResLog1 || (vResLog4 && vResLog2))
    {
        vTempPointer = *pointerRunProg;
        if (*vTempPointer==0x3A) // ":"
        {
            i.progPosPointerRet = *pointerRunProg;
        }
        else
            i.progPosPointerRet = *nextAddr;

        if (vRetVar < 0)
            forPush(i);
        else
        {
            j = (forStack + vRetVar);
            j->target = i.target;
            j->step = i.step;
            j->endVar = i.endVar;
            j->progPosPointerRet = i.progPosPointerRet;
        }
    }
    else  /* otherwise, skip loop code alltogether */
    {
        vTempPointer = *pointerRunProg;
        while(*vTempPointer != 0x87) // Search NEXT
        {
            *pointerRunProg = *pointerRunProg + 1;
            vTempPointer = *pointerRunProg;

            // Verifica se chegou no next
            if (*vTempPointer == 0x87)
            {
                // Verifica se tem letra, se nao tiver, usa ele
                if (*(vTempPointer + 1)!=0x00)
                {
                    // verifica se é a mesma variavel que ele tem
                    if (*(vTempPointer + 1) != i.nameVar[0])
                    {
                        *pointerRunProg = *pointerRunProg + 1;
                        vTempPointer = *pointerRunProg;
                    }
                    else
                    {
                        if (*(vTempPointer + 2) != i.nameVar[1] && *(vTempPointer + 2) != i.nameVar[2])
                        {
                            *pointerRunProg = *pointerRunProg + 1;
                            vTempPointer = *pointerRunProg;
                        }
                    }
                }
            }
        }

        *changedPointer = *pointerRunProg;
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Final/Incremento do Laco de repeticao, voltando para o commando/linha após o FOR
// Syntaxe:
//          NEXT [<variavel>]
//--------------------------------------------------------------------------------------
int basNext(void)
{
    unsigned char sqtdtam[10];
    for_stack i;
    int *endVarCont;
    unsigned char answer[3];
    char vRetVar = -1;
    unsigned char *vTempPointer;
    char vResLog1 = 0, vResLog2 = 0;
    char vResLog3 = 0, vResLog4 = 0;

/*writeLongSerial("Aqui 777.666.0-[");
itoa(*pointerRunProg,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(*pointerRunProg,sqtdtam,16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n");*/
    vTempPointer = *pointerRunProg;
    if (isalphas(*vTempPointer))
    {
        // procura pela variavel no forStack
        nextToken();
        if (*vErroProc) return 0;

        if (*token_type != VARIABLE)
        {
            *vErroProc = 4;
            return 0;
        }

        answer[1] = *token;

        if (strlen(token) == 1)
        {
            answer[0] = 0x00;
            answer[2] = 0x00;
        }
        else if (strlen(token) == 2)
        {
            if (*(token + 1) < 0x30)
            {
                answer[0] = *(token + 1);
                answer[2] = 0x00;
            }
            else
            {
                answer[0] = 0x00;
                answer[2] = *(token + 1);
            }
        }
        else
        {
            answer[0] = *(token + 2);
            answer[2] = *(token + 1);
        }

        vRetVar = forFind(&i,answer);

        if (vRetVar < 0)
        {
            *vErroProc = 11;
            return 0;
        }
    }
    else // faz o pop da pilha
        i = forPop(); // read the loop info

    endVarCont = i.endVar;

    if (i.nameVar[2] == '#')
    {
        *endVarCont = fppSum(*endVarCont,i.step); // inc/dec, using step, control variable
    }
    else
        *endVarCont = *endVarCont + i.step; // inc/dec, using step, control variable

    if (i.nameVar[2] == '#')
    {
        vResLog1 = logicalNumericFloatLong('>', *endVarCont, i.target);
        vResLog2 = logicalNumericFloatLong('<', *endVarCont, i.target);
        vResLog3 = logicalNumericFloatLong('>', i.step, 0);
        vResLog4 = logicalNumericFloatLong('<', i.step, 0);
    }
    else
    {
        vResLog1 = (*endVarCont > i.target);
        vResLog2 = (*endVarCont < i.target);
        vResLog3 = (i.step > 0);
        vResLog4 = (i.step < 0);
    }


    // compara se ja chegou no final  //     if ((i.step > 0 && *endVarCont>i.target) || (i.step < 0 && *endVarCont<i.target))
    if ((vResLog3 && vResLog1) || (vResLog4 && vResLog2))
        return 0 ;  // all done

    *changedPointer = i.progPosPointerRet;  // loop

    if (vRetVar < 0)
        forPush(i);  // otherwise, restore the info

    return 0;
}

//--------------------------------------------------------------------------------------
// Salta para uma linha se erro
// Syntaxe:
//          ON <VAR> GOSUB <num.linha 1>,<num.linha 2>,...,,<num.linha n>
//          ON <VAR> GOTO <num.linha 1>,<num.linha 2>,...,<num.linha n>
//--------------------------------------------------------------------------------------
int basOnVar(void)
{
    unsigned char* vNextAddrGoto;
    unsigned int vNumLin = 0;
    unsigned char *vTempPointer;
    unsigned int vSalto;
    unsigned int iSalto = 0;
    unsigned int ix;

    vTempPointer = *pointerRunProg;
    if (isalphas(*vTempPointer))
    {
        // procura pela variavel no forStack
        nextToken();
        if (*vErroProc) return 0;

        if (*token_type != VARIABLE)
        {
            *vErroProc = 4;
            return 0;
        }

        putback();

        getExp(&iSalto);
        if (*vErroProc) return 0;

        if (*value_type != '%')
        {
            *vErroProc = 16;
            return 0;
        }

        if (iSalto == 0 || iSalto > 255)
        {
            *vErroProc = 5;
            return 0;
        }
    }
    else
    {
        *vErroProc = 4;
        return 0;
    }

    vTempPointer = *pointerRunProg;

    // Se nao for goto ou gosub, erro
    if (*vTempPointer != 0x89 && *vTempPointer != 0x8A)
    {
        *vErroProc = 14;
        return 0;
    }

    vSalto = *vTempPointer;
    ix = 0;
    *pointerRunProg = *pointerRunProg + 1;

    while (1)
    {
        getExp(&vNumLin); // get target value

        if (*value_type == '$' || *value_type == '#') {
            *vErroProc = 16;
            return 0;
        }

        ix++;

        if (ix == iSalto)
            break;

        nextToken();
        if (*vErroProc) return 0;

        // Deve ser uma virgula
        if (*token!=',')
        {
            *vErroProc = 18;
            return 0;
        }

        nextToken();
        if (*vErroProc) return 0;

        putback();
    }

    if (ix == 0 || ix > iSalto)
    {
        *vErroProc = 14;
        return 0;
    }

    vNextAddrGoto = findNumberLine(vNumLin, 0, 0);

    if (vSalto == 0x89)
    {
        // GOTO
        if (vNextAddrGoto > 0)
        {
            if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
            {
                *changedPointer = vNextAddrGoto;
                return 0;
            }
            else
            {
                *vErroProc = 7;
                return 0;
            }
        }
        else
        {
            *vErroProc = 7;
            return 0;
        }
    }
    else
    {
        // GOSUB
        if (vNextAddrGoto > 0)
        {
            if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
            {
                gosubPush(*nextAddr);
                *changedPointer = vNextAddrGoto;
                return 0;
            }
            else
            {
                *vErroProc = 7;
                return 0;
            }
        }
        else
        {
            *vErroProc = 7;
            return 0;
        }
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Salta para uma linha se erro
// Syntaxe:
//          ONERR GOTO <num.linha>
//--------------------------------------------------------------------------------------
int basOnErr(void)
{
    unsigned char* vNextAddrGoto;
    unsigned int vNumLin = 0;
    unsigned char sqtdtam[10];
    unsigned char *vTempPointer;

    vTempPointer = *pointerRunProg;

    // Se nao for goto, erro
    if (*vTempPointer != 0x89)
    {

        *vErroProc = 14;
        return 0;
    }

    // soma mais um pra ir pro numero da linha
    *pointerRunProg = *pointerRunProg + 1;

    getExp(&vNumLin); // get target value

    if (*value_type == '$' || *value_type == '#') {
        *vErroProc = 17;
        return 0;
    }

    vNextAddrGoto = findNumberLine(vNumLin, 0, 0);

    if (vNextAddrGoto > 0)
    {
        if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
        {
            *onErrGoto = vNextAddrGoto;
            return 0;
        }
        else
        {
            *vErroProc = 7;
            return 0;
        }
    }
    else
    {
        *vErroProc = 7;
        return 0;
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Salta para uma linha, sem retorno
// Syntaxe:
//          GOTO <num.linha>
//--------------------------------------------------------------------------------------
int basGoto(void)
{
    unsigned char* vNextAddrGoto;
    unsigned int vNumLin = 0;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED)
    {
        *vErroProc = 14;
        return 0;
    }

    putback();

    getExp(&vNumLin); // get target value

    if (*value_type == '$' || *value_type == '#') {
        *vErroProc = 17;
        return 0;
    }

    vNextAddrGoto = findNumberLine(vNumLin, 0, 0);

    if (vNextAddrGoto > 0)
    {
        if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
        {
            *changedPointer = vNextAddrGoto;
            return 0;
        }
        else
        {
            *vErroProc = 7;
            return 0;
        }
    }
    else
    {
        *vErroProc = 7;
        return 0;
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Salta para uma linha e guarda a posicao atual para voltar
// Syntaxe:
//          GOSUB <num.linha>
//--------------------------------------------------------------------------------------
int basGosub(void)
{
    unsigned char* vNextAddrGoto;
    unsigned int vNumLin = 0;

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED)
    {
        *vErroProc = 14;
        return 0;
    }

    putback();

    getExp(&vNumLin); // get target valuedel 20

    if (*value_type == '$' || *value_type == '#') {
        *vErroProc = 17;
        return 0;
    }

    vNextAddrGoto = findNumberLine(vNumLin, 0, 0);

    if (vNextAddrGoto > 0)
    {
        if ((unsigned int)(((unsigned int)*(vNextAddrGoto + 3) << 8) | *(vNextAddrGoto + 4)) == vNumLin)
        {
            gosubPush(*nextAddr);
            *changedPointer = vNextAddrGoto;
            return 0;
        }
        else
        {
            *vErroProc = 7;
            return 0;
        }
    }
    else
    {
        *vErroProc = 7;
        return 0;
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Retorna de um Gosub
// Syntaxe:
//          RETURN
//--------------------------------------------------------------------------------------
int basReturn(void)
{
    unsigned long i;

    i = gosubPop();

    *changedPointer = i;

    return 0;
}

//--------------------------------------------------------------------------------------
// Retorna um numero real como inteiro
// Syntaxe:
//          INT(<number real>)
//--------------------------------------------------------------------------------------
int basInt(void)
{
    int vReal = 0, vResult = 0;

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    putback();

    getExp(&vReal); //

    if (*value_type == '$')
    {
        *vErroProc = 16;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    if (*value_type == '#')
        vResult = fppInt(vReal);
    else
        vResult = vReal;

    *value_type='%';

    *token=((int)(vResult & 0xFF000000) >> 24);
    *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
    *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
    *(token + 3)=(vResult & 0x000000FF);

    return 0;
}

//--------------------------------------------------------------------------------------
// Retorna um numero absoluto como inteiro
// Syntaxe:
//          ABS(<number real>)
//--------------------------------------------------------------------------------------
int basAbs(void)
{
    int vReal = 0, vResult = 0;

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    putback();

    getExp(&vReal); //

    if (*value_type == '$')
    {
        *vErroProc = 16;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    if (*value_type == '#')
        vResult = fppAbs(vReal);
    else
    {
        vResult = vReal;

        if (vResult < 1)
            vResult = vResult * (-1);
    }

    *value_type='%';

    *token=((int)(vResult & 0xFF000000) >> 24);
    *(token + 1)=((int)(vResult & 0x00FF0000) >> 16);
    *(token + 2)=((int)(vResult & 0x0000FF00) >> 8);
    *(token + 3)=(vResult & 0x000000FF);

    return 0;
}

//--------------------------------------------------------------------------------------
// Retorna um numero randomicamente
// Syntaxe:
//          RND(<number>)
//--------------------------------------------------------------------------------------
int basRnd(void)
{
    unsigned long vRand;
    int vReal = 0, vResult = 0;
    unsigned char vTRand[20];
    unsigned char vSRand[20];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    putback();

    getExp(&vReal); //

    if (*value_type == '$')
    {
        *vErroProc = 16;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type != CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    if (vReal == 0)
    {
        vRand = *randSeed;
    }
    else if (vReal >= -1 && vReal < 0)
    {
        vRand = *(vmfp + Reg_TADR);
        vRand = (vRand << 3);
        vRand += 0x466;
        vRand -= ((*(vmfp + Reg_TADR)) * 3);
        *randSeed = vRand;
    }
    else if (vReal > 0 && vReal <= 1)
    {
        vRand = *randSeed;
        vRand = (vRand << 3);
        vRand += 0x466;
        vRand -= ((*(vmfp + Reg_TADR)) * 3);
        *randSeed = vRand;
    }
    else
    {
        *vErroProc = 5;
        return 0;
    }

    itoa(vRand, vTRand, 10);
    vSRand[0] = '0';
    vSRand[1] = '.';
    vSRand[2] = 0x00;

    strcat(vSRand, vTRand);

    vRand = floatStringToFpp(vSRand);

    *value_type='#';

    *token=((int)(vRand & 0xFF000000) >> 24);
    *(token + 1)=((int)(vRand & 0x00FF0000) >> 16);
    *(token + 2)=((int)(vRand & 0x0000FF00) >> 8);
    *(token + 3)=(vRand & 0x000000FF);

    return 0;
}

//--------------------------------------------------------------------------------------
// Posiciona o cursor na tela atual.
// Syntaxe:
//          LOCATE <x>,<y>
//--------------------------------------------------------------------------------------
int basLocate(void)
{
    int vColumn = 0;
    int vRow = 0;
    unsigned char answer[20];
    int *iVal = answer;

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }
    }

    vColumn = *iVal;

    if (vColumn < 0 || vColumn > vdpMaxCols)
    {
        *vErroProc = 5;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }
    }

    vRow = *iVal;

    if (vRow < 0 || vRow > vdpMaxRows)
    {
        *vErroProc = 5;
        return 0;
    }

    vdp_set_cursor(vColumn, vRow);

    return 0;
}

//--------------------------------------------------------------------------------------
// Finaliza o programa sem erro
// Syntaxe:
//          END
//--------------------------------------------------------------------------------------
int basEnd(void)
{
    *nextAddr = 0;

    return 0;
}

//--------------------------------------------------------------------------------------
// Finaliza o programa com erro
// Syntaxe:
//          STOP
//--------------------------------------------------------------------------------------
int basStop(void)
{
    *vErroProc = 1;

    return 0;
}

//--------------------------------------------------------------------------------------
// Retorna 'n' Espaços
// Syntaxe:
//          SPC <numero>
//--------------------------------------------------------------------------------------
int basSpc(void)
{
    unsigned int vSpc = 0;
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[20];
    int  *iVal = answer;
    unsigned char vTab, vColumn;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    vSpc=(char)*iVal;

    for (ix = 0; ix < vSpc; ix++)
        *(token + ix) = ' ';

    *(token + ix) = 0;
    *value_type = '$';

    return 0;
}

//--------------------------------------------------------------------------------------
// Advance 'n' columns
// Syntaxe:
//          TAB <numero>
//--------------------------------------------------------------------------------------
int basTab(void)
{
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[20];
    int  *iVal = answer;
    unsigned char vTab, vColumn;
    unsigned char sqtdtam[10];

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }
    }

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    vTab=(char)*iVal;

    vColumn = videoCursorPosColX;

    if (vTab>vColumn)
    {
        vColumn = vColumn + vTab;

        while (vColumn>vdpMaxCols)
        {
            vColumn = vColumn - vdpMaxCols;
            if (videoCursorPosRowY < vdpMaxRows)
                videoCursorPosRowY += 1;
        }

        vdp_set_cursor(vColumn, videoCursorPosRowY);
    }

    *token = ' ';
    *value_type='$';

    return 0;
}

//--------------------------------------------------------------------------------------
// Screen Mode Switch
// Syntaxe:
//          SCREEN <mode>, [spriteSize]
//              Mode: (0,1,2)
//                  0: Text Screen Mode (40 cols x 24 rows)
//                  1: Low Resolution Screen Mode (64x48)
//                  2: High Resolution Screen Mode (256x192)
//
//              SpriteSize: (0,1,2,3)
//                  0: 8x8 pixels (standard).  (Default)
//                  1: 8x8 pixels (magnified to 16x16).
//                  2: 16x16 pixels (standard).
//                  3: 16x16 pixels (magnified to 32x32).
//--------------------------------------------------------------------------------------
int basScreen(void)
{
    unsigned char answer[20];
    int *iVal = answer;
    int vModeAux;
    int vModeSpriteAux = 99;
    char vSpriteSize = 0;
    char vSpriteMag = 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*tok == EOL || *tok == FINISHED)
    {
        *vErroProc = 18;
        return 0;
    }

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }

    putback();

    getExp(&answer);
    if (*vErroProc) return 0;

    if (*value_type == '$')
    {
        *vErroProc = 16;
        return 0;
    }

    if (*value_type == '#')
    {
        *iVal = fppInt(*iVal);
        *value_type = '%';
    }

    nextToken();
    if (*vErroProc) return 0;

    vModeAux = *iVal;

    if (vModeAux < 0 || vModeAux > 2)
    {
        *vErroProc = 5;
        return 0;
    }

    if (*token == ',')
    {
        nextToken();
        if (*vErroProc) return 0;

        if (*tok == EOL || *tok == FINISHED)
        {
            *vErroProc = 18;
            return 0;
        }

        if (*token_type == QUOTE) { /* is string, error */
            *vErroProc = 16;
            return 0;
        }

        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }

        vModeSpriteAux = *iVal;

        if (vModeSpriteAux < 0 || vModeSpriteAux > 3)
        {
            *vErroProc = 5;
            return 0;
        }
    }
    else
        putback();

    switch (vModeSpriteAux)
    {
        case 0:
            vSpriteSize = 0;
            vSpriteMag = 0;
            break;
        case 1:
            vSpriteSize = 0;
            vSpriteMag = 1;
            break;
        case 2:
            vSpriteSize = 1;
            vSpriteMag = 0;
            break;
        case 3:
            vSpriteSize = 1;
            vSpriteMag = 1;
            break;
    }

    switch (vModeAux)
    {
        case 0:
            basicVdpBufferEnabled = 0;
            if (vdpModeBas != VDP_MODE_TEXT)
                basText();
            break;
        case 1:
            basicVdpBufferEnabled = 0;
            if (vdpModeBas != VDP_MODE_MULTICOLOR)
            {
                vdp_init(VDP_MODE_MULTICOLOR, 0, vSpriteSize, vSpriteMag);
                vdpMaxCols = 63;
                vdpMaxRows = 47;
                vdpModeBas = VDP_MODE_MULTICOLOR;
                spriteSizeSelBas = vSpriteSize;
                basSpriteResetCache();
            }
            break;
        case 2:
            if (vdpModeBas != VDP_MODE_G2)
            {
                vdp_init(VDP_MODE_G2, 0x0, vSpriteSize, vSpriteMag);
                vdpMaxCols = 255;
                vdpMaxRows = 191;
                vdpModeBas = VDP_MODE_G2;
                vdp_set_bdcolor(VDP_BLACK);
                bgcolorBas = VDP_BLACK;
                spriteSizeSelBas = vSpriteSize;
                basPaintSyncTables();
                basSpriteResetCache();
            }
            else
            {
                basPaintSyncTables();
            }
            break;
    }

    return 0;
}

int basText(void)
{
    fgcolorBas = VDP_WHITE;
    bgcolorBas = VDP_BLACK;
    basicVdpBufferEnabled = 0;
    vdp_init(VDP_MODE_TEXT, (fgcolorBas<<4) | (bgcolorBas & 0x0f), 0, 0);
    vdpMaxCols = 39;
    vdpMaxRows = 23;
    vdpModeBas = VDP_MODE_TEXT;
    spriteSizeSelBas = 0;
    basSpriteResetCache();
    clearScr();
    return 0;
}

//--------------------------------------------------------------------------------------
// Muda as cores atuais de frente e fundo.
// Syntaxe:
//          COLOR <foreground>,<background>
//          COLOR ,<background>
//          COLOR <foreground>
//--------------------------------------------------------------------------------------
int basColor(void)
{
    unsigned char answer[20];
    int  *iVal = answer;
    int foreground = fgcolorBas;
    int background = bgcolorBas;

    nextToken();
    if (*vErroProc) return 0;

    if (*tok == EOL || *tok == FINISHED)
    {
        *vErroProc = 18;
        return 0;
    }

    if (*token != ',')
    {
        if (*token_type == QUOTE) { /* is string, error */
            *vErroProc = 16;
            return 0;
        }

        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }

        foreground = *iVal;

        if (foreground < 0 || foreground > 15)
        {
            *vErroProc = 5;
            return 0;
        }

        nextToken();
        if (*vErroProc) return 0;
    }

    if (*token == ',')
    {
        nextToken();
        if (*vErroProc) return 0;

        if (*tok == EOL || *tok == FINISHED)
        {
            *vErroProc = 18;
            return 0;
        }

        if (*token_type == QUOTE) { /* is string, error */
            *vErroProc = 16;
            return 0;
        }

        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }

        background = *iVal;

        if (background < 0 || background > 15)
        {
            *vErroProc = 5;
            return 0;
        }
    }
    else
        putback();

    fgcolorBas = (unsigned char)foreground;
    bgcolorBas = (unsigned char)background;

    vdp_textcolor(fgcolorBas, bgcolorBas);

    *value_type='%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Desenha um circulo ou ovoide.
// Syntaxe:
//          CIRCLE x,y,rh[,rv]
//--------------------------------------------------------------------------------------
static void basPlotEllipsePoints(int x0, int y0, int dx, int dy)
{
    basVideoPlotHires((unsigned char)(x0 + dx), (unsigned char)(y0 + dy), fgcolorBas, bgcolorBas);
    basVideoPlotHires((unsigned char)(x0 - dx), (unsigned char)(y0 + dy), fgcolorBas, bgcolorBas);
    basVideoPlotHires((unsigned char)(x0 + dx), (unsigned char)(y0 - dy), fgcolorBas, bgcolorBas);
    basVideoPlotHires((unsigned char)(x0 - dx), (unsigned char)(y0 - dy), fgcolorBas, bgcolorBas);
}

static void basReadNumericArg(int *pValue)
{
    unsigned char answer[20];
    int  *iVal = answer;

    if (*token_type == QUOTE)
    {
        *vErroProc = 16;
        return;
    }

    if (*token_type == DELIMITER && (*token == '\r' || *token == 0x00))
    {
        *vErroProc = 2;
        return;
    }

    putback();

    getExp(&answer);
    if (*vErroProc) return;

    if (*value_type == '$')
    {
        *vErroProc = 16;
        return;
    }

    if (*value_type == '#')
    {
        *iVal = fppInt(*iVal);
        *value_type = '%';
    }

    *pValue = *iVal;
}

int basBufVdg(unsigned char pEnabled)
{
    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    basPaintSyncTables();
    basicVdpBufferEnabled = pEnabled ? 1 : 0;
    *value_type = '%';

    return 0;
}

int basBufCopy(void)
{
    int values[6];
    int ix;
    int temp;
    unsigned char origin;
    unsigned char dest;

    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    basPaintSyncTables();

    for (ix = 0; ix < 6; ix++)
    {
        nextToken();
        if (*vErroProc) return 0;

        basReadNumericArg(&values[ix]);
        if (*vErroProc) return 0;

        if (ix < 5)
        {
            nextToken();
            if (*vErroProc) return 0;

            if (*token != ',')
            {
                *vErroProc = 18;
                return 0;
            }
        }
    }

    origin = (unsigned char)values[0];
    dest = (unsigned char)values[1];

    if (origin > 1 || dest > 1)
    {
        *vErroProc = 5;
        return 0;
    }

    if (values[2] < 0 || values[2] > 255 || values[4] < 0 || values[4] > 255 ||
        values[3] < 0 || values[3] > 191 || values[5] < 0 || values[5] > 191)
    {
        *vErroProc = 25;
        return 0;
    }

    if (values[4] < values[2])
    {
        temp = values[2];
        values[2] = values[4];
        values[4] = temp;
    }

    if (values[5] < values[3])
    {
        temp = values[3];
        values[3] = values[5];
        values[5] = temp;
    }

    basVideoCopyRect(origin, dest, (unsigned char)values[2], (unsigned char)values[3], (unsigned char)values[4], (unsigned char)values[5]);

    *value_type = '%';

    return 0;
}

int basBufShow(void)
{
    int values[4];
    int ix;
    int temp;

    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    basPaintSyncTables();

    for (ix = 0; ix < 4; ix++)
    {
        nextToken();
        if (*vErroProc) return 0;

        basReadNumericArg(&values[ix]);
        if (*vErroProc) return 0;

        if (ix < 3)
        {
            nextToken();
            if (*vErroProc) return 0;

            if (*token != ',')
            {
                *vErroProc = 18;
                return 0;
            }
        }
    }

    if (values[0] < 0 || values[0] > 255 || values[2] < 0 || values[2] > 255 ||
        values[1] < 0 || values[1] > 191 || values[3] < 0 || values[3] > 191)
    {
        *vErroProc = 25;
        return 0;
    }

    if (values[2] < values[0])
    {
        temp = values[0];
        values[0] = values[2];
        values[2] = temp;
    }

    if (values[3] < values[1])
    {
        temp = values[1];
        values[1] = values[3];
        values[3] = temp;
    }

    basVideoCopyRect(1, 0, (unsigned char)values[0], (unsigned char)values[1], (unsigned char)values[2], (unsigned char)values[3]);

    *value_type = '%';

    return 0;
}

int basCircle(void)
{
    int centerX = 0, centerY = 0, horizontalRadius = 0, verticalRadius = 0;
    long rx2, ry2, twoRx2, twoRy2, d1, d2, dx, dy;
    int x, y;

    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&centerX);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&centerY);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&horizontalRadius);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token == ',')
    {
        nextToken();
        if (*vErroProc) return 0;

        basReadNumericArg(&verticalRadius);
        if (*vErroProc) return 0;
    }
    else
    {
        verticalRadius = horizontalRadius;

        putback();
    }

    if (horizontalRadius < 0)
        horizontalRadius = -horizontalRadius;

    if (verticalRadius < 0)
        verticalRadius = -verticalRadius;

    if (horizontalRadius == 0 && verticalRadius == 0)
    {
        basVideoPlotHires((unsigned char)centerX, (unsigned char)centerY, fgcolorBas, bgcolorBas);
    }
    else if (horizontalRadius == 0)
    {
        for (y = -verticalRadius; y <= verticalRadius; y++)
            basVideoPlotHires((unsigned char)centerX, (unsigned char)(centerY + y), fgcolorBas, bgcolorBas);
    }
    else if (verticalRadius == 0)
    {
        for (x = -horizontalRadius; x <= horizontalRadius; x++)
            basVideoPlotHires((unsigned char)(centerX + x), (unsigned char)centerY, fgcolorBas, bgcolorBas);
    }
    else
    {
        rx2 = (long)horizontalRadius * (long)horizontalRadius;
        ry2 = (long)verticalRadius * (long)verticalRadius;
        twoRx2 = rx2 << 1;
        twoRy2 = ry2 << 1;

        x = 0;
        y = verticalRadius;
        dx = 0;
        dy = twoRx2 * y;
        d1 = ry2 - (rx2 * verticalRadius) + (rx2 / 4);

        while (dx < dy)
        {
            basPlotEllipsePoints(centerX, centerY, x, y);

            if (d1 < 0)
            {
                x++;
                dx += twoRy2;
                d1 += dx + ry2;
            }
            else
            {
                x++;
                y--;
                dx += twoRy2;
                dy -= twoRx2;
                d1 += dx - dy + ry2;
            }
        }

        d2 = (ry2 * (long)(x * x)) + (ry2 * x) + (ry2 / 4) + (rx2 * (long)(y * y)) - (twoRx2 * y) + rx2 - (rx2 * ry2);

        while (y >= 0)
        {
            basPlotEllipsePoints(centerX, centerY, x, y);

            if (d2 > 0)
            {
                y--;
                dy -= twoRx2;
                d2 += rx2 - dy;
            }
            else
            {
                x++;
                y--;
                dx += twoRy2;
                dy -= twoRx2;
                d2 += dx - dy + rx2;
            }
        }
    }

    *value_type = '%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Desenha um retangulo de x1,y1 ate x2,y2
// Syntaxe:
//          RECT x1,y1,x2,y2
//--------------------------------------------------------------------------------------
int basRect(void)
{
    int x1 = 0, y1 = 0, x2 = 0, y2 = 0, temp;
    int ix, iy, left, right, top, bottom;

    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&x1);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&y1);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&x2);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&y2);
    if (*vErroProc) return 0;

    left = x1;
    right = x2;
    top = y1;
    bottom = y2;

    if (right < left)
    {
        temp = left;
        left = right;
        right = temp;
    }

    if (bottom < top)
    {
        temp = top;
        top = bottom;
        bottom = temp;
    }

    for (ix = left; ix <= right; ix++)
        basVideoPlotHires((unsigned char)ix, (unsigned char)top, fgcolorBas, bgcolorBas);

    for (iy = top; iy <= bottom; iy++)
        basVideoPlotHires((unsigned char)left, (unsigned char)iy, fgcolorBas, bgcolorBas);

    if (bottom != top)
    {
        for (ix = left; ix <= right; ix++)
            basVideoPlotHires((unsigned char)ix, (unsigned char)bottom, fgcolorBas, bgcolorBas);
    }

    if (right != left)
    {
        for (iy = top; iy <= bottom; iy++)
            basVideoPlotHires((unsigned char)right, (unsigned char)iy, fgcolorBas, bgcolorBas);
    }

    *value_type = '%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Flood fill a partir de um ponto ate encontrar bordas de outra cor.
// Syntaxe:
//          PAINT x,y,c
//--------------------------------------------------------------------------------------
static unsigned char basPaintReadPixel(unsigned char x, unsigned char y)
{
    return basVideoReadPixel(x, y);
}

static int basPaintPush(unsigned int *stackTop, unsigned char x, unsigned char y)
{
    if (*stackTop >= PAINT_STACK_SIZE)
    {
        *vErroProc = 21;
        return 0;
    }

    paintStackX[*stackTop] = x;
    paintStackY[*stackTop] = y;
    *stackTop = *stackTop + 1;
    return 1;
}

static int basPaintQueueRow(unsigned int *stackTop, unsigned char left, unsigned char right, unsigned char y, unsigned char targetColor)
{
    unsigned int x = left;

    while (x <= right)
    {
        if (basPaintReadPixel((unsigned char)x, y) == targetColor)
        {
            if (!basPaintPush(stackTop, (unsigned char)x, y))
                return 0;

            while (x <= right && basPaintReadPixel((unsigned char)x, y) == targetColor)
                x++;
        }

        x++;
    }

    return 1;
}

int basPaint(void)
{
    int xValue = 0, yValue = 0, colorValue = 0;
    unsigned char startX, startY, fillColor, targetColor;
    unsigned int stackTop = 0;
    int left, right, x, y;

    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    basPaintSyncTables();

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&xValue);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&yValue);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&colorValue);
    if (*vErroProc) return 0;

    if (xValue < 0 || xValue > vdpMaxCols || yValue < 0 || yValue > vdpMaxRows)
    {
        *vErroProc = 25;
        return 0;
    }

    if (colorValue < 0 || colorValue > 15)
    {
        *vErroProc = 5;
        return 0;
    }

    startX = (unsigned char)xValue;
    startY = (unsigned char)yValue;
    fillColor = (unsigned char)colorValue;
    targetColor = basPaintReadPixel(startX, startY);

    if (targetColor == fillColor)
    {
        *value_type = '%';
        return 0;
    }

    if (!basPaintPush(&stackTop, startX, startY))
        return 0;

    while (stackTop > 0)
    {
        stackTop--;
        x = paintStackX[stackTop];
        y = paintStackY[stackTop];

        if (basPaintReadPixel((unsigned char)x, (unsigned char)y) != targetColor)
            continue;

        left = x;
        while (left > 0 && basPaintReadPixel((unsigned char)(left - 1), (unsigned char)y) == targetColor)
            left--;

        right = x;
        while (right < vdpMaxCols && basPaintReadPixel((unsigned char)(right + 1), (unsigned char)y) == targetColor)
            right++;

        for (x = left; x <= right; x++)
            basVideoPlotHires((unsigned char)x, (unsigned char)y, fillColor, 0);

        if (y > 0)
        {
            if (!basPaintQueueRow(&stackTop, (unsigned char)left, (unsigned char)right, (unsigned char)(y - 1), targetColor))
                return 0;
        }

        if (y < vdpMaxRows)
        {
            if (!basPaintQueueRow(&stackTop, (unsigned char)left, (unsigned char)right, (unsigned char)(y + 1), targetColor))
                return 0;
        }
    }

    *value_type = '%';
    return 0;
}

//--------------------------------------------------------------------------------------
// Pinta um retangulo de x1,y1 ate x2,y2 com uma determinada cor
// Syntaxe:
//          FILL <x1>,<y1>,<x2>,<y2>,<color>
//--------------------------------------------------------------------------------------
void fillRect(int x1, int y1, int x2, int y2, int fillColor)
{
    unsigned char t, fillIsBackground;
    unsigned char startBit, endBit;
    unsigned char maskLeft, maskRight, maskSingle;
    unsigned char colorByte;
    unsigned char pixel;
    unsigned int startByte, endByte;
    unsigned int y;
    unsigned int rowBase;
    unsigned int offset;
    unsigned int bx;
    unsigned char bufferId;

    /* Ajusta coordenadas */
    if (x1 > x2)
    {
        t = x1;
        x1 = x2;
        x2 = t;
    }

    if (y1 > y2)
    {
        t = y1;
        y1 = y2;
        y2 = t;
    }

    fillColor &= 0x0F;
    bufferId = basVideoActiveBuffer();

    colorByte = (fillColor << 4) | bgcolorBas;
    fillIsBackground = (fillColor == bgcolorBas) ? 1 : 0;

    startByte = ((unsigned int)(x1 >> 3)) << 3;
    endByte   = ((unsigned int)(x2 >> 3)) << 3;

    startBit = x1 & 0x07;
    endBit   = x2 & 0x07;

    maskLeft   = (unsigned char)(0xFF >> startBit);
    maskRight  = (unsigned char)(0xFF << (7 - endBit));
    maskSingle = (unsigned char)(maskLeft & maskRight);

    for (y = y1; y <= y2; y++)
    {
        rowBase = (((unsigned int)(y >> 3)) << 8) + (y & 0x07);

        if (startByte == endByte)
        {
            offset = rowBase + startByte;
            pixel = basVideoReadByte(bufferId, paintPatternTable + offset);

            if (fillIsBackground)
                pixel &= (unsigned char)(~maskSingle);
            else
                pixel |= maskSingle;

            basVideoWriteByte(bufferId, paintPatternTable + offset, pixel);
            basVideoWriteByte(bufferId, paintColorTable + offset, colorByte);
        }
        else
        {
            /* byte inicial */
            offset = rowBase + startByte;
            pixel = basVideoReadByte(bufferId, paintPatternTable + offset);

            if (fillIsBackground)
                pixel &= (unsigned char)(~maskLeft);
            else
                pixel |= maskLeft;

            basVideoWriteByte(bufferId, paintPatternTable + offset, pixel);
            basVideoWriteByte(bufferId, paintColorTable + offset, colorByte);

            /* bytes centrais */
            for (bx = startByte + 8; bx < endByte; bx += 8)
            {
                offset = rowBase + bx;
                basVideoWriteByte(bufferId, paintPatternTable + offset, fillIsBackground ? 0x00 : 0xFF);
                basVideoWriteByte(bufferId, paintColorTable + offset, colorByte);
            }

            /* byte final */
            offset = rowBase + endByte;
            pixel = basVideoReadByte(bufferId, paintPatternTable + offset);

            if (fillIsBackground)
                pixel &= (unsigned char)(~maskRight);
            else
                pixel |= maskRight;

            basVideoWriteByte(bufferId, paintPatternTable + offset, pixel);
            basVideoWriteByte(bufferId, paintColorTable + offset, colorByte);
        }
    }
}

int basFill (void)
{
    int x1 = 0, y1 = 0;
    int x2 = 0, y2 = 0;
    int fillColor = 0;

    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&x1);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&y1);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&x2);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&y2);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token == ',')
    {
        nextToken();
        if (*vErroProc) return 0;

        basReadNumericArg(&fillColor);
        if (*vErroProc) return 0;
    }
    else
    {
        putback();
    }

    fillRect(x1, y1, x2, y2, fillColor);

    return 0;
}

//--------------------------------------------------------------------------------------
// Carrega dados do sprite para a tabela de padroes.
// Syntaxe:
//          SPRITESET <number>,<var$>
//--------------------------------------------------------------------------------------
int basSpriteSet(void)
{
    int spriteNumber = 0;
    unsigned char answer[256];
    unsigned char spriteData[32];
    unsigned int spriteLimit;
    unsigned int spriteBytes;
    unsigned int copyBytes;

    if (vdpModeBas == VDP_MODE_TEXT)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&spriteNumber);
    if (*vErroProc) return 0;

    spriteLimit = basSpritePatternLimit();
    if (spriteNumber < 0 || spriteNumber > (int)spriteLimit)
    {
        *vErroProc = 5;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*tok == EOL || *tok == FINISHED)
    {
        *vErroProc = 18;
        return 0;
    }

    memset(spriteData, 0x00, sizeof(spriteData));
    spriteBytes = basSpritePatternBytes();

    if (*token_type == QUOTE)
    {
        copyBytes = strlen((char *)token);
        if (copyBytes > spriteBytes)
            copyBytes = spriteBytes;
        memcpy(spriteData, token, copyBytes);
    }
    else
    {
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type != '$')
        {
            *vErroProc = 16;
            return 0;
        }

        copyBytes = strlen((char *)answer);
        if (copyBytes > spriteBytes)
            copyBytes = spriteBytes;
        memcpy(spriteData, answer, copyBytes);
    }

    vdp_set_sprite_pattern((unsigned char)spriteNumber, spriteData);
    *value_type = '%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Ativa um sprite, define o plano, a posicao e a cor inicial.
// Syntaxe:
//          SPRITEPUT <number>,<plano>,<x>,<y>,<cor>
//--------------------------------------------------------------------------------------
int basSpritePut(void)
{
    int spriteNumber = 0;
    int plane = 0;
    int xValue = 0;
    int yValue = 0;
    int colorValue = 0;
    unsigned int spriteLimit;
    unsigned int spriteHandle;

    if (vdpModeBas == VDP_MODE_TEXT)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&spriteNumber);
    if (*vErroProc) return 0;

    spriteLimit = basSpritePatternLimit();
    if (spriteNumber < 0 || spriteNumber > (int)spriteLimit)
    {
        *vErroProc = 5;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&plane);
    if (*vErroProc) return 0;

    if (plane < 0 || plane > 31)
    {
        *vErroProc = 5;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&xValue);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&yValue);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&colorValue);
    if (*vErroProc) return 0;

    if (xValue < 0 || xValue > 255 || yValue < 0 || yValue > 191)
    {
        *vErroProc = 25;
        return 0;
    }

    if (colorValue < 0 || colorValue > 15)
    {
        *vErroProc = 5;
        return 0;
    }

    spriteHandle = vdp_sprite_init((unsigned char)spriteNumber, (unsigned char)plane, (unsigned char)colorValue);
    spriteHandleCache[(unsigned char)spriteNumber] = spriteHandle;
    vdp_sprite_set_position(spriteHandle, (unsigned int)xValue, (unsigned char)yValue);

    *value_type = '%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Altera apenas a cor de um sprite ja ativado.
// Syntaxe:
//          SPRITECOLOR <number>,<cor>
//--------------------------------------------------------------------------------------
int basSpriteColor(void)
{
    int spriteNumber = 0;
    int colorValue = 0;
    unsigned int spriteLimit;
    unsigned int spriteHandle;

    if (vdpModeBas == VDP_MODE_TEXT)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&spriteNumber);
    if (*vErroProc) return 0;

    spriteLimit = basSpritePatternLimit();
    if (spriteNumber < 0 || spriteNumber > (int)spriteLimit)
    {
        *vErroProc = 5;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&colorValue);
    if (*vErroProc) return 0;

    if (colorValue < 0 || colorValue > 15)
    {
        *vErroProc = 5;
        return 0;
    }

    spriteHandle = basSpriteResolveHandle((unsigned char)spriteNumber);
    if (spriteHandle == 0)
    {
        *vErroProc = 5;
        return 0;
    }

    vdp_sprite_color(spriteHandle, (unsigned char)colorValue);
    *value_type = '%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Altera a posicao de um sprite ja ativado.
// Syntaxe:
//          SPRITEPOS <number>,<x>,<y>
//--------------------------------------------------------------------------------------
int basSpritePos(void)
{
    int spriteNumber = 0;
    int xValue = 0;
    int yValue = 0;
    unsigned int spriteLimit;
    unsigned int spriteHandle;

    if (vdpModeBas == VDP_MODE_TEXT)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&spriteNumber);
    if (*vErroProc) return 0;

    spriteLimit = basSpritePatternLimit();
    if (spriteNumber < 0 || spriteNumber > (int)spriteLimit)
    {
        *vErroProc = 5;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&xValue);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&yValue);
    if (*vErroProc) return 0;

    if (xValue < 0 || xValue > 255 || yValue < 0 || yValue > 191)
    {
        *vErroProc = 25;
        return 0;
    }

    spriteHandle = basSpriteResolveHandle((unsigned char)spriteNumber);
    if (spriteHandle == 0)
    {
        *vErroProc = 5;
        return 0;
    }

    vdp_sprite_set_position(spriteHandle, (unsigned int)xValue, (unsigned char)yValue);
    *value_type = '%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Verifica colisao entre dois sprites.
// Syntaxe:
//          SPRITEOVER(<numsprite1>,<numsprite2>)
//--------------------------------------------------------------------------------------
int basSpriteOver(void)
{
    int spriteNumber1 = 0;
    int spriteNumber2 = 0;
    unsigned int spriteLimit;
    unsigned int spriteHandle1;
    unsigned int spriteHandle2;
    Sprite_attributes spritePos1;
    Sprite_attributes spritePos2;
    unsigned char collision1;
    unsigned char collision2;
    unsigned int result = 0;

    if (vdpModeBas == VDP_MODE_TEXT)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&spriteNumber1);
    if (*vErroProc) return 0;

    spriteLimit = basSpritePatternLimit();
    if (spriteNumber1 < 0 || spriteNumber1 > (int)spriteLimit)
    {
        *vErroProc = 5;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    basReadNumericArg(&spriteNumber2);
    if (*vErroProc) return 0;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    if (spriteNumber2 < 0 || spriteNumber2 > (int)spriteLimit)
    {
        *vErroProc = 5;
        return 0;
    }

    spriteHandle1 = basSpriteResolveHandle((unsigned char)spriteNumber1);
    if (spriteHandle1 == 0)
    {
        *vErroProc = 5;
        return 0;
    }

    spriteHandle2 = basSpriteResolveHandle((unsigned char)spriteNumber2);
    if (spriteHandle2 == 0)
    {
        *vErroProc = 5;
        return 0;
    }

    if (spriteHandle1 != spriteHandle2)
    {
        spritePos1 = vdp_sprite_get_position(spriteHandle1);
        spritePos2 = vdp_sprite_get_position(spriteHandle2);

        collision1 = (vdp_sprite_set_position(spriteHandle1, (unsigned int)spritePos1.x, (unsigned char)spritePos1.y) & VDP_FLAG_COIN) ? 1 : 0;
        collision2 = (vdp_sprite_set_position(spriteHandle2, (unsigned int)spritePos2.x, (unsigned char)spritePos2.y) & VDP_FLAG_COIN) ? 1 : 0;


        result = (collision1 && collision2) ? 1 : 0;
    }

    *value_type = '%';

    *token = ((int)(result & 0xFF000000) >> 24);
    *(token + 1) = ((int)(result & 0x00FF0000) >> 16);
    *(token + 2) = ((int)(result & 0x0000FF00) >> 8);
    *(token + 3) = (result & 0x000000FF);

    return 0;
}

//--------------------------------------------------------------------------------------
// Coloca um dot ou preenche uma area com a color previamente definida
// Syntaxe:
//          PLOT <x entre 0 e 63/255>, <y entre 0 e 47/191>
//--------------------------------------------------------------------------------------
int basPlot(void)
{
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[20];
    int  *iVal = answer;
    unsigned char vx, vy;
    unsigned char sqtdtam[10];

    if (vdpModeBas == VDP_MODE_TEXT)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }
    }

    vx=(char)*iVal;

    if (*token != ',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        //putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '#')
        {
            *iVal = fppInt(*iVal);
            *value_type = '%';
        }
    }

    vy=(char)*iVal;

    if (vdpModeBas == VDP_MODE_G2)
        basVideoPlotHires(vx, vy, fgcolorBas, bgcolorBas);
    else
        vdp_plot_color(vx, vy, fgcolorBas);

    *value_type='%';

    return 0;
}

//--------------------------------------------------------------------------------------
//
// Syntaxe:
//
//--------------------------------------------------------------------------------------
int basPoint(void)
{
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[20];
    int *iVal = answer;
    int *tval = token;
    unsigned char vx, vy;
    unsigned char sqtdtam[10];

    if (vdpModeBas == VDP_MODE_TEXT)
    {
        *vErroProc = 24;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    // Erro, primeiro caracter deve ser abre parenteses
    if (*tok == EOL || *tok == FINISHED || *token_type != OPENPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type != '%')
        {
            *vErroProc = 16;
            return 0;
        }
    }

    vx=(char)*iVal;

    nextToken();
    if (*vErroProc) return 0;

    if (*token!=',')
    {
        *vErroProc = 18;
        return 0;
    }

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) { /* is string, error */
        *vErroProc = 16;
        return 0;
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;

        if (*value_type != '%')
        {
            *vErroProc = 16;
            return 0;
        }
    }

    vy=(char)*iVal;

    nextToken();
    if (*vErroProc) return 0;

    // Ultimo caracter deve ser fecha parenteses
    if (*token_type!=CLOSEPARENT)
    {
        *vErroProc = 15;
        return 0;
    }

    // Ler Aqui.. a cor e devolver em *tval
    if (vdpModeBas == VDP_MODE_G2)
        *tval = basVideoReadPixel(vx, vy);
    else
        *tval = vdp_read_color_pixel(vx,vy);

    *value_type='%';

    return 0;
}

//--------------------------------------------------------------------------------------
//
// Syntaxe:
//     LINE x,y TO x,y [TO x,y...]
//--------------------------------------------------------------------------------------
int basLine(void)
{
    int ix = 0, iy = 0, iz = 0, iw = 0, vToken;
    unsigned char answer[20];
    int  *iVal = answer;
    int rivx, rivy;
    unsigned long riy, rlvx, rlvy, vDiag;
    unsigned char vx, vy, vtemp;
    unsigned char sqtdtam[10];
    unsigned char vOper = 0;
    int x,y,addx,addy,dx,dy;
    long P;

    if (vdpModeBas != VDP_MODE_G2)
    {
        *vErroProc = 24;
        return 0;
    }

    do
    {
        nextToken();
        if (*vErroProc) return 0;

        if (*token != 0x86)
        {
            if (*token_type == QUOTE) { // is string, error
                *vErroProc = 16;
                return 0;
            }
            else { // is expression
                putback();

                getExp(&answer);
                if (*vErroProc) return 0;

                if (*value_type == '$')
                {
                    *vErroProc = 16;
                    return 0;
                }

                if (*value_type == '#')
                {
                    *iVal = fppInt(*iVal);
                    *value_type = '%';
                }
            }

            vx = (unsigned char)*iVal;

            if (*token != ',')
            {
                *vErroProc = 18;
                return 0;
            }

            nextToken();
            if (*vErroProc) return 0;

            if (*token_type == QUOTE) { // is string, error
                *vErroProc = 16;
                return 0;
            }
            else { // is expression
                //putback();

                getExp(&answer);
                if (*vErroProc) return 0;

                if (*value_type == '$')
                {
                    *vErroProc = 16;
                    return 0;
                }

                if (*value_type == '#')
                {
                    *iVal = fppInt(*iVal);
                    *value_type = '%';
                }
            }

            vy = (unsigned char)*iVal;

            if (!vOper)
                vOper = 1;
        }
        else
        {
           // *pointerRunProg = *pointerRunProg + 1;
        }

        if (*tok == EOL || *tok == FINISHED || *token == 0x86)    // Fim de linha, programa ou token
        {
            if (!vOper)
            {
                vOper = 2;
            }
            else if (vOper == 1)
            {
                *lastHgrX = vx;
                *lastHgrY = vy;

                if (*token != 0x86)
                    basVideoPlotHires(vx, vy, fgcolorBas, bgcolorBas);
            }
            else if (vOper == 2)
            {
                if (vx == *lastHgrX && vy == *lastHgrY)
                    basVideoPlotHires(vx, vy, fgcolorBas, bgcolorBas);
                else
                {
                    dx = (vx - *lastHgrX);
                    dy = (vy - *lastHgrY);

                    if (dx < 0)
                        dx = dx * (-1);

                    if (dy < 0)
                        dy = dy * (-1);

                    x = *lastHgrX;
                    y = *lastHgrY;

                    if(*lastHgrX > vx)
                       addx = -1;
                    else
                       addx = 1;

                    if(*lastHgrY > vy)
                      addy = -1;
                    else
                      addy = 1;

                    if(dx >= dy)
                    {
                        P = (2 * dy) - dx;

                        for(ix = 1; ix <= (dx + 1); ix++)
                        {
                            basVideoPlotHires(x, y, fgcolorBas, 0);

                            if (P < 0)
                            {
                                P = P + (2 * dy);
                                x = (x + addx);
                            }
                            else
                            {
                                P = P + (2 * dy) - (2 * dx);
                                x = x + addx;
                                y = y + addy;
                            }
                        }
                    }
                    else
                    {
                        P = (2 * dx) - dy;

                        for(ix = 1; ix <= (dy +1); ix++)
                        {
                            basVideoPlotHires(x, y, fgcolorBas, 0);

                            if (P < 0)
                            {
                                P = P + (2 * dx);
                                y = y + addy;
                            }
                            else
                            {
                                P = P + (2 * dx) - (2 * dy);
                                x = x + addx;
                                y = y + addy;
                            }
                        }
                    }
                }

                *lastHgrX = vx;
                *lastHgrY = vy;
            }

            if (*token == 0x86)
            {
                *pointerRunProg = *pointerRunProg + 1;
            }
        }

        vOper = 2;
   } while (*token == 0x86); // TO Token

    *value_type='%';

    return 0;
}

//--------------------------------------------------------------------------------------
// Ler dados no comando DATA
// Syntaxe:
//          READ <variavel>
//--------------------------------------------------------------------------------------
int basRead(void)
{
    int ix = 0, iy = 0, iz = 0;
    unsigned char answer[100];
    int  *iVal = answer;
    unsigned char varTipo, vArray = 0;
    unsigned char sqtdtam[10];
    unsigned long vTemp;
    unsigned char *vTempLine;
    long vRetFV;
    unsigned char *vTempPointer;

    // Pega a variavel
    nextToken();
    if (*vErroProc) return 0;

    if (*tok == EOL || *tok == FINISHED)
    {
        *vErroProc = 4;
        return 0;
    }

    if (*token_type == QUOTE) { /* is string */
        *vErroProc = 4;
        return 0;
    }
    else { /* is expression */
        // Verifica se comeca com letra, pois tem que ser uma variavel
        if (!isalphas(*token))
        {
            *vErroProc = 4;
            return 0;
        }

        if (strlen(token) < 3)
        {
            *varName = *token;
            varTipo = VARTYPEDEFAULT;

            if (strlen(token) == 2 && *(token + 1) < 0x30)
                varTipo = *(token + 1);

            if (strlen(token) == 2 && isalphas(*(token + 1)))
                *(varName + 1) = *(token + 1);
            else
                *(varName + 1) = 0x00;

            *(varName + 2) = varTipo;
        }
        else
        {
            *varName = *token;
            *(varName + 1) = *(token + 1);
            *(varName + 2) = *(token + 2);
            iz = strlen(token) - 1;
            varTipo = *(varName + 2);
        }
    }

    // Procurar Data
    if (*vDataPointer == 0)
    {
        // Primeira Leitura, procura primeira ocorrencia
        *vDataLineAtu = *addrFirstLineNumber;

        do
        {
            *vDataPointer = *vDataLineAtu;

            vTempLine = *vDataPointer;
            if (*(vTempLine + 5) == 0x98)    // Token do comando DATA é o primeiro comando da linha
            {
                *vDataPointer = (*vDataLineAtu + 6);
                *vDataFirst = *vDataLineAtu;
                break;
            }

            vTempLine = *vDataLineAtu;
            vTemp  = ((*vTempLine & 0xFF) << 16);
            vTemp |= ((*(vTempLine + 1) & 0xFF) << 8);
            vTemp |= (*(vTempLine + 2) & 0xFF);

            *vDataLineAtu = vTemp;
            vTempLine = *vDataLineAtu;

        } while (*vTempLine);
    }

    if (*vDataPointer == 0xFFFFFFFF)
    {
        *vErroProc = 26;
        return 0;
    }

    *vDataBkpPointerProg = *pointerRunProg;

    *pointerRunProg = *vDataPointer;

    nextToken();
    if (*vErroProc) return 0;

    if (*token_type == QUOTE) {
        strcpy(answer,token);
        *value_type = '$';
    }
    else { /* is expression */
        putback();

        getExp(&answer);
        if (*vErroProc) return 0;
    }

    // Pega ponteiro atual (proximo numero/char)
    *vDataPointer = *pointerRunProg + 1;

    // Devolve ponteiro anterior
    *pointerRunProg = *vDataBkpPointerProg;

    // Se nao foi virgula, é final de linha, procura proximo comando data
    if (*token != ',')
    {
        do
        {
            vTempLine = *vDataLineAtu;
            vTemp  = ((*(vTempLine) & 0xFF) << 16);
            vTemp |= ((*(vTempLine + 1) & 0xFF) << 8);
            vTemp |= (*(vTempLine + 2) & 0xFF);

            *vDataLineAtu = vTemp;
            vTempLine = *vDataLineAtu;
            if (!*vDataLineAtu)
            {
                *vDataPointer = 0xFFFFFFFF;
                break;
            }

            *vDataPointer = *vDataLineAtu;

            vTempLine = *vDataPointer;
            if (*(vTempLine + 5) == 0x98)    // Token do comando DATA é o primeiro comando da linha
            {
                *vDataPointer = (*vDataLineAtu + 6);
                break;
            }

            vTempLine = *vDataLineAtu;
        } while (*vTempLine);
    }

    if (varTipo != *value_type)
    {
        if (*value_type == '$' || varTipo == '$')
        {
            *vErroProc = 16;
            return 0;
        }

        if (*value_type == '%')
            *iVal = fppReal(*iVal);
        else
            *iVal = fppInt(*iVal);

        *value_type = varTipo;
    }

    vTempPointer = *pointerRunProg;
    if (*vTempPointer == 0x28)
    {
        vRetFV = findVariable(varName);
        if (*vErroProc) return 0;

        if (!vRetFV)
        {
            *vErroProc = 4;
            return 0;
        }

        vArray = 1;
    }

    if (!vArray)
    {
        // assign the value
        vRetFV = findVariable(varName);

        // Se nao existe variavel e inicio sentenca, cria variavel e atribui o valor
        if (!vRetFV)
            createVariable(varName, answer, varTipo);
        else // se ja existe, altera
            updateVariable((vRetFV + 3), answer, varTipo, 1);
    }
    else
    {
        updateVariable(vRetFV, answer, varTipo, 2);
    }

    return 0;
}

//--------------------------------------------------------------------------------------
// Volta ponteiro do READ para o primeiro item dos comandos DATA
// Syntaxe:
//          RESTORE
//--------------------------------------------------------------------------------------
int basRestore(void)
{
    *vDataLineAtu = *vDataFirst;
    *vDataPointer = (*vDataLineAtu + 6);

    return 0;
}

//--------------------------------------------------------------------------------------
// Editor em modo de tela cheia
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// ENDERECO X/Y NA NAME TABLE
//--------------------------------------------------------------------------------------
unsigned int vdpXYAddr(int x, int y)
{
    return textNameTable + (y * VDP_COLS) + x;
}

//--------------------------------------------------------------------------------------
// LEITURA / ESCRITA DE CARACTERE NA TELA
//--------------------------------------------------------------------------------------
unsigned char vdpReadCharAt(int x, int y)
{
    unsigned int addr;
    unsigned char ch;

    if (x < 0 || x >= VDP_COLS)
        return 0x00;

    if (y < 0 || y >= VDP_ROWS)
        return 0x00;

    addr = vdpXYAddr(x, y);

    setReadAddress(addr);

    //ch = *vvdgBASd; // dummy, se precisar
    ch = *vvdgBASd;

    return ch;
}

void vdpWriteCharAt(int x, int y, unsigned char ch)
{
    unsigned int addr;

    if (x < 0 || x >= VDP_COLS)
        return;

    if (y < 0 || y >= VDP_ROWS)
        return;

    addr = vdpXYAddr(x, y);

    setWriteAddress(addr);
    *vvdgBASd = ch;
}

static int vdpEditFindNextInputRow(void)
{
    int y;
    int x;
    int lastUsed;
    unsigned char ch;

    lastUsed = -1;

    for (y = 0; y < VDP_ROWS; y++)
    {
        for (x = 0; x < VDP_COLS; x++)
        {
            ch = vdpReadCharAt(x, y);
            if (ch != 0x00)
            {
                lastUsed = y;
                break;
            }
        }
    }

    y = lastUsed + 1;
    if (y < 0)
        y = 0;
    if (y >= VDP_ROWS)
        y = VDP_ROWS - 1;

    return y;
}

static void vdpEditCursorOff(void)
{
    unsigned char sqtdtam[20];
    if (!vdpEditCursorVisible)
        return;

if (*debugOn)
{
writeLongSerial("Aqui 06660.666.0 [\0");
itoa(vdpEditCurX, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vdpEditCurY, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeSerial(vdpEditCursorBackup);
writeLongSerial("]\r\n\0");
}

    vdpWriteCharAt(vdpEditCurX, vdpEditCurY, vdpEditCursorBackup);
    vdpEditCursorVisible = 0;
}

static void vdpEditCursorOn(void)
{
    unsigned char sqtdtam[20];

    if (vdpEditCursorVisible)
        return;

    vdpEditCursorBackup = vdpReadCharAt(vdpEditCurX, vdpEditCurY);
if (*debugOn)
{
writeLongSerial("Aqui 06661.666.0[\0");
itoa(vdpEditCurX, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vdpEditCurY, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
writeSerial(vdpEditCursorBackup);
writeLongSerial("]\r\n\0");
}

    vdpWriteCharAt(vdpEditCurX, vdpEditCurY, VDP_EDIT_CURSOR_CHAR);
    vdpEditCursorVisible = 1;
    vdp_set_cursor(vdpEditCurX, vdpEditCurY);
}

static void vdpEditCursorToggle(void)
{
    if (vdpEditCursorVisible)
        vdpEditCursorOff();
    else
        vdpEditCursorOn();
}


//--------------------------------------------------------------------------------------
// CURSOR
//--------------------------------------------------------------------------------------
void vdpEditMoveCursor(int x, int y)
{
    if (x < 0)
        x = 0;

    if (x >= VDP_COLS)
        x = VDP_COLS - 1;

    if (y < 0)
        y = 0;

    if (y >= VDP_ROWS)
        y = VDP_ROWS - 1;

    vdpEditCurX = x;
    vdpEditCurY = y;

    vdp_set_cursor(vdpEditCurX, vdpEditCurY);
}

static void vdpEditGetLogicalBounds(int x, int y, int *pStartX, int *pStartY, int *pEndY)
{
    char temp[VDP_COLS + 1];
    int startY;
    int endY;
    int lenLine;
    int startX;
    int ix;

    startY = y;

    while (startY > 0)
    {
        lenLine = vdpReadTrimmedPhysicalLine(startY - 1, temp, VDP_COLS + 1);

        if (lenLine < VDP_COLS)
            break;

        startY--;
    }

    endY = startY;

    while (endY < (VDP_ROWS - 1))
    {
        lenLine = vdpReadTrimmedPhysicalLine(endY, temp, VDP_COLS + 1);

        if (lenLine < VDP_COLS)
            break;

        endY++;
    }

    startX = x;
    if (startX < 0)
        startX = 0;
    if (startX >= VDP_COLS)
        startX = VDP_COLS - 1;

    while (startX > 0)
    {
        if (vdpReadCharAt(startX - 1, startY) == 0x00)
            break;

        startX--;
    }

    *pStartX = startX;
    *pStartY = startY;
    *pEndY = endY;
}

static int vdpEditGetLogicalCursorPos(int startX, int startY, int lineLen)
{
    int cursorPos;
    int firstWidth;

    firstWidth = VDP_COLS - startX;

    if (vdpEditCurY == startY)
        cursorPos = vdpEditCurX - startX;
    else
        cursorPos = firstWidth + ((vdpEditCurY - startY - 1) * VDP_COLS) + vdpEditCurX;

    if (cursorPos < 0)
        cursorPos = 0;

    if (cursorPos > lineLen)
        cursorPos = lineLen;

    return cursorPos;
}

static void vdpEditSetCursorFromLogicalPos(int startX, int startY, int lineLen, int cursorPos)
{
    int firstWidth;
    int localPos;
    unsigned char sqtdtam[20];
if (*debugOn)
{
writeLongSerial("Aqui 06660.666.0 [\0");
itoa(startX, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(startY, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(lineLen, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(cursorPos, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}

    if (cursorPos < 0)
        cursorPos = 0;

    if (cursorPos > lineLen)
        cursorPos = lineLen;

    firstWidth = VDP_COLS - startX;

    if (cursorPos < firstWidth)
    {
        vdpEditCurY = startY;
        vdpEditCurX = startX + cursorPos;
    }
    else
    {
        localPos = cursorPos - firstWidth;
        vdpEditCurY = startY + 1 + (localPos / VDP_COLS);
        vdpEditCurX = localPos % VDP_COLS;
    }

    if (vdpEditCurY >= VDP_ROWS)
    {
        vdpEditCurY = VDP_ROWS - 1;
        vdpEditCurX = VDP_COLS - 1;
    }

    if (vdpEditCurX < 0)
        vdpEditCurX = 0;

    if (vdpEditCurX >= VDP_COLS)
        vdpEditCurX = VDP_COLS - 1;

if (*debugOn)
{
writeLongSerial("Aqui 06660.666.1 [\0");
itoa(vdpEditCurX, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]-[");
itoa(vdpEditCurY, sqtdtam, 16);
writeLongSerial(sqtdtam);
writeLongSerial("]\r\n\0");
}

    vdp_set_cursor(vdpEditCurX, vdpEditCurY);
}

static void vdpEditRenderLogicalLine(int startX, int startY, int oldEndY, char *line, int cursorPos)
{
    int lenLine;
    int rowsUsed;
    int newEndY;
    int maxEndY;
    int y;
    int x;
    int pos;
    int firstWidth;

    lenLine = strlen(line);
    rowsUsed = 1;
    firstWidth = VDP_COLS - startX;

    if (lenLine > firstWidth)
        rowsUsed = 1 + (((lenLine - firstWidth) + (VDP_COLS - 1)) / VDP_COLS);

    newEndY = startY + rowsUsed - 1;

    if (newEndY >= VDP_ROWS)
        newEndY = VDP_ROWS - 1;

    maxEndY = oldEndY;
    if (newEndY > maxEndY)
        maxEndY = newEndY;

    for (y = startY; y <= maxEndY && y < VDP_ROWS; y++)
    {
        for (x = (y == startY ? startX : 0); x < VDP_COLS; x++)
            vdpWriteCharAt(x, y, 0x00);
    }

    pos = 0;
    for (y = startY; y <= newEndY && y < VDP_ROWS; y++)
    {
        for (x = (y == startY ? startX : 0); x < VDP_COLS && pos < lenLine; x++)
            vdpWriteCharAt(x, y, line[pos++]);
    }

    vdpEditLineEndY = newEndY;
    vdpEditSetCursorFromLogicalPos(startX, startY, lenLine, cursorPos);
}


//--------------------------------------------------------------------------------------
// SCROLL LENDO/ESCREVENDO VRAM
//--------------------------------------------------------------------------------------
void vdpEditScrollUp(void)
{
    int x;
    int y;
    unsigned char ch;

    for (y = 0; y < VDP_ROWS - 1; y++)
    {
        for (x = 0; x < VDP_COLS; x++)
        {
            ch = vdpReadCharAt(x, y + 1);
            vdpWriteCharAt(x, y, ch);
        }
    }

    for (x = 0; x < VDP_COLS; x++)
        vdpWriteCharAt(x, VDP_ROWS - 1, 0x00);

    if (vdpEditCurY > 0)
        vdpEditCurY--;
}

//--------------------------------------------------------------------------------------
// ESCREVER CARACTERE DIGITADO
//--------------------------------------------------------------------------------------
void vdpEditPutChar(unsigned char ch)
{
    int ix;

    vdpEditLoadLineFromCursor();

    if (vdpEditLineLen >= (VDP_MAX_LINE - 1))
        return;

    for (ix = vdpEditLineLen; ix >= vdpEditCursorPos; ix--)
        vdpEditLine[ix + 1] = vdpEditLine[ix];

    vdpEditLine[vdpEditCursorPos] = ch;
    vdpEditLineLen++;
    vdpEditCursorPos++;
    vdpEditRenderLogicalLine(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineEndY, vdpEditLine, vdpEditCursorPos);
}

//--------------------------------------------------------------------------------------
// BACKSPACE / DELETE
//--------------------------------------------------------------------------------------
void vdpEditBackspace(void)
{
    int ix;

    vdpEditLoadLineFromCursor();

    if (vdpEditCursorPos <= 0 || vdpEditLineLen <= 0)
        return;

    vdpEditCursorPos--;

    for (ix = vdpEditCursorPos; ix < vdpEditLineLen; ix++)
        vdpEditLine[ix] = vdpEditLine[ix + 1];

    vdpEditLineLen--;
    vdpEditRenderLogicalLine(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineEndY, vdpEditLine, vdpEditCursorPos);
}

void vdpEditDelete(void)
{
    int ix;

    vdpEditLoadLineFromCursor();

    if (vdpEditCursorPos >= vdpEditLineLen || vdpEditLineLen <= 0)
        return;

    for (ix = vdpEditCursorPos; ix < vdpEditLineLen; ix++)
        vdpEditLine[ix] = vdpEditLine[ix + 1];

    vdpEditLineLen--;
    vdpEditRenderLogicalLine(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineEndY, vdpEditLine, vdpEditCursorPos);
}

//--------------------------------------------------------------------------------------
// MOVIMENTO DO CURSOR
//--------------------------------------------------------------------------------------
void vdpEditCursorLeft(void)
{
    if (vdpEditLineLen <= 0)
    {
        if (vdpEditCurX > 0)
            vdpEditCurX--;
        else if (vdpEditCurY > 0)
        {
            vdpEditCurY--;
            vdpEditCurX = VDP_COLS - 1;
        }

        vdp_set_cursor(vdpEditCurX, vdpEditCurY);
        return;
    }

    if (vdpEditCursorPos > 0)
        vdpEditCursorPos--;

    vdpEditSetCursorFromLogicalPos(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineLen, vdpEditCursorPos);
}

void vdpEditCursorRight(void)
{
    if (vdpEditLineLen <= 0)
    {
        if (vdpEditCurX < (VDP_COLS - 1))
            vdpEditCurX++;
        else if (vdpEditCurY < (VDP_ROWS - 1))
        {
            vdpEditCurY++;
            vdpEditCurX = 0;
        }

        vdp_set_cursor(vdpEditCurX, vdpEditCurY);
        return;
    }

    if (vdpEditCursorPos < vdpEditLineLen)
        vdpEditCursorPos++;

    vdpEditSetCursorFromLogicalPos(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineLen, vdpEditCursorPos);
}

void vdpEditCursorUp(void)
{
    int firstWidth;
    int absCol;
    int localPos;
    int rowIdx;

    if (vdpEditLineLen <= 0)
    {
        if (vdpEditCurY > 0)
            vdpEditCurY--;

        vdp_set_cursor(vdpEditCurX, vdpEditCurY);
        return;
    }

    firstWidth = VDP_COLS - vdpEditLineStartX;

    if (vdpEditCursorPos < firstWidth)
    {
        rowIdx = 0;
        absCol = vdpEditLineStartX + vdpEditCursorPos;
    }
    else
    {
        localPos = vdpEditCursorPos - firstWidth;
        rowIdx = 1 + (localPos / VDP_COLS);
        absCol = localPos % VDP_COLS;
    }

    if (rowIdx > 0)
    {
        rowIdx--;

        if (rowIdx == 0)
        {
            if (absCol < vdpEditLineStartX)
                absCol = vdpEditLineStartX;

            vdpEditCursorPos = absCol - vdpEditLineStartX;
        }
        else
        {
            vdpEditCursorPos = firstWidth + ((rowIdx - 1) * VDP_COLS) + absCol;
        }
    }

    vdpEditSetCursorFromLogicalPos(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineLen, vdpEditCursorPos);
}

void vdpEditCursorDown(void)
{
    int firstWidth;
    int absCol;
    int localPos;
    int rowIdx;

    if (vdpEditLineLen <= 0)
    {
        if (vdpEditCurY < (VDP_ROWS - 1))
            vdpEditCurY++;

        vdp_set_cursor(vdpEditCurX, vdpEditCurY);
        return;
    }

    firstWidth = VDP_COLS - vdpEditLineStartX;

    if (vdpEditCursorPos < firstWidth)
    {
        rowIdx = 0;
        absCol = vdpEditLineStartX + vdpEditCursorPos;
    }
    else
    {
        localPos = vdpEditCursorPos - firstWidth;
        rowIdx = 1 + (localPos / VDP_COLS);
        absCol = localPos % VDP_COLS;
    }

    rowIdx++;

    if (rowIdx == 0)
        vdpEditCursorPos = absCol - vdpEditLineStartX;
    else
        vdpEditCursorPos = firstWidth + ((rowIdx - 1) * VDP_COLS) + absCol;

    if (vdpEditCursorPos > vdpEditLineLen)
        vdpEditCursorPos = vdpEditLineLen;

    vdpEditSetCursorFromLogicalPos(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineLen, vdpEditCursorPos);
}


//--------------------------------------------------------------------------------------
// LER LINHA FISICA DO VDP
//--------------------------------------------------------------------------------------
int vdpReadPhysicalLine(int y, char *dest, int maxLen)
{
    int x;
    int p;
    unsigned char ch;

    p = 0;

    for (x = 0; x < VDP_COLS; x++)
    {
        ch = vdpReadCharAt(x, y);

        if (p < maxLen - 1)
        {
            dest[p] = ch;
            p++;
        }
    }

    dest[p] = 0;

    return p;
}


//--------------------------------------------------------------------------------------
// TRIM A DIREITA
//--------------------------------------------------------------------------------------
void vdpTrimRight(char *s)
{
    int i;

    i = 0;

    while (s[i])
        i++;

    i--;

    while (i >= 0 && s[i] == ' ')
    {
        s[i] = 0;
        i--;
    }
}

static int vdpReadTrimmedPhysicalLine(int y, char *dest, int maxLen)
{
    vdpReadPhysicalLine(y, dest, maxLen);
    vdpTrimRight(dest);
    return strlen(dest);
}

static int vdpEditReadLogicalLineAt(int x, int y, char *dest, int maxLen, int *pStartX, int *pStartY, int *pEndY)
{
    char temp[VDP_COLS + 1];
    int startX = 0;
    int startY = 0;
    int endY = 0;
    int p;
    int ix;
    int lenLine;

    vdpEditGetLogicalBounds(x, y, &startX, &startY, &endY);

    p = 0;

    for (ix = startX; ix < VDP_COLS; ix++)
    {
        temp[ix - startX] = vdpReadCharAt(ix, startY);
    }
    temp[VDP_COLS - startX] = 0x00;

    for (ix = 0; temp[ix] && p < (maxLen - 1); ix++)
        dest[p++] = temp[ix];

    lenLine = ix;

    y = startY + 1;
    while (lenLine == (VDP_COLS - startX) && y < VDP_ROWS)
    {
        vdpReadPhysicalLine(y, temp, VDP_COLS + 1);

        for (ix = 0; temp[ix] && p < (maxLen - 1); ix++)
            dest[p++] = temp[ix];

        lenLine = ix;
        if (lenLine < VDP_COLS)
            break;

        y++;
    }

    dest[p] = 0x00;

    if (pStartX)
        *pStartX = startX;
    if (pStartY)
        *pStartY = startY;
    if (pEndY)
        *pEndY = y > endY ? y : endY;

    return p;
}

static void vdpEditLoadLineFromCursor(void)
{
    if (vdpEditLineLen > 0)
        return;

    vdpEditLineLen = vdpEditReadLogicalLineAt(
        vdpEditCurX,
        vdpEditCurY,
        vdpEditLine,
        VDP_MAX_LINE,
        &vdpEditLineStartX,
        &vdpEditLineStartY,
        &vdpEditLineEndY
    );

    vdpEditCursorPos = vdpEditGetLogicalCursorPos(vdpEditLineStartX, vdpEditLineStartY, vdpEditLineLen);
}


//--------------------------------------------------------------------------------------
// TESTA SE LINHA PARECE COMECO DE LINHA BASIC
// Ex: "10 PRINT", "100 GOTO", etc.
//--------------------------------------------------------------------------------------
int vdpLineStartsWithNumber(char *s)
{
    int i;
    int found;

    i = 0;
    found = 0;

    while (s[i] == ' ')
        i++;

    while (s[i] >= '0' && s[i] <= '9')
    {
        found = 1;
        i++;
    }

    return found;
}


//--------------------------------------------------------------------------------------
// LER LINHA LOGICA DO VDP
//
// Ideia:
// - sobe ate achar uma linha que começa com numero
// - junta essa linha e as linhas abaixo
// - para quando encontrar outra linha que começa com numero
//--------------------------------------------------------------------------------------
int vdpReadLogicalBasicLine(int y, char *dest, int maxLen)
{
    char temp[VDP_COLS + 1];
    int startY;
    int p;
    int i;
    int lenLine;

    startY = y;

    while (startY > 0)
    {
        lenLine = vdpReadTrimmedPhysicalLine(startY - 1, temp, VDP_COLS + 1);

        if (lenLine < VDP_COLS)
            break;

        startY--;
    }

    p = 0;

    y = startY;

    while (y < VDP_ROWS)
    {
        lenLine = vdpReadTrimmedPhysicalLine(y, temp, VDP_COLS + 1);

        i = 0;

        while (temp[i])
        {
            if (p < maxLen - 1)
            {
                dest[p] = temp[i];
                p++;
            }

            i++;
        }

        if (lenLine < VDP_COLS)
            break;

        y++;
    }

    dest[p] = 0;
    vdpTrimRight(dest);

    return p;
}

//--------------------------------------------------------------------------------------
// ENTER
//--------------------------------------------------------------------------------------
void vdpEditEnter(void)
{
    unsigned short vNumLin;
    unsigned long vLineAddr;
    unsigned char *pLineAddr;

    if (vdpEditLineLen > 0)
    {
        memcpy(vbufInput, vdpEditLine, vdpEditLineLen);
        *(vbufInput + vdpEditLineLen) = 0x00;

        if (vdpLineStartsWithNumber(vbufInput))
        {
            vNumLin = atoi(vbufInput);
            vLineAddr = findNumberLine(vNumLin, 0, 0);

            if (vLineAddr)
            {
                pLineAddr = (unsigned char *)vLineAddr;

                if (((*(pLineAddr + 3) << 8) | *(pLineAddr + 4)) == vNumLin)
                    delLine(vbufInput);
            }
        }

        printText("\r\n\0");
        processLine();

        if (!*pTypeLine && *pProcess)
            printText("\r\nOK\0");

        if (!*pTypeLine && *pProcess)
            printText("\r\n\0");
    }
    else
    {
        printText("\r\n\0");
    }

    vbufInput[0] = 0x00;
    vdpEditLine[0] = 0x00;
    vdpEditLineLen = 0;
    vdpEditCursorPos = 0;

    vdpEditLineStartX = 0;
    vdpEditLineStartY = vdpEditFindNextInputRow();
    vdpEditLineEndY = vdpEditLineStartY;
    vdpEditCurX = vdpEditLineStartX;
    vdpEditCurY = vdpEditLineStartY;

    vdp_set_cursor(vdpEditCurX, vdpEditCurY);
}

//--------------------------------------------------------------------------------------
// PROCESSAR TECLA
//--------------------------------------------------------------------------------------
void vdpEditProcessKey(int key)
{
    if (key == KEY_ENTER || key == 0x0A)
    {
        vdpEditEnter();
    }
    else if (key == KEY_BACKSPACE)
    {
        vdpEditBackspace();
    }
    else if (key == KEY_DELETE || key == 0x7F || key == 0x04)
    {
        vdpEditDelete();
    }
    else if (key == KEY_LEFT)
    {
        vdpEditCursorLeft();
    }
    else if (key == KEY_RIGHT)
    {
        vdpEditCursorRight();
    }
    else if (key == KEY_UP)
    {
        vdpEditCursorUp();
    }
    else if (key == KEY_DOWN)
    {
        vdpEditCursorDown();
    }
    else
    {
        if (key >= 32 && key <= 126)
            vdpEditPutChar((unsigned char)key);
    }
}

void vdpEditReadEnterLine(char *dest, int maxLen)
{
    int len;

    len = vdpEditLineLen;
    if (len >= (maxLen - 1))
        len = maxLen - 1;

    memcpy(dest, vdpEditLine, len);
    dest[len] = 0x00;
}