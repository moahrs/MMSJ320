/********************************************************************************
*    Programa    : hello.c
*    Objetivo    : Hello para testes
*    Criado em   : 11/01/2025
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* Data        Versao  Responsavel  Motivo
* 11/01/2025  0.1     Moacir Jr.   Criacao Versao Beta
*--------------------------------------------------------------------------------*/

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "../mmsj320vdp.h"
#include "../mmsj320mfp.h"
#include "../monitor.h"
#include "../mmsjos.h"
#include "../mgui.h"
#include "../monitorapi.h"
#include "../mmsjosapi.h"

void listHello(void);

unsigned char vmouseStat;
unsigned char vmouseMoveX;
unsigned char vmouseMoveY;

unsigned char *vMseMovPtrR = 0x00600512; // Contador do ponteiro das dados do mouse recebidos
unsigned char *vMseMovPtrW = 0x00600514; // Contador do ponteiro das dados do mouse recebidos

//-----------------------------------------------------------------------------
// Principal
//-----------------------------------------------------------------------------
void main(void)
{
    int ix;
    unsigned char sqtdtam[10];

    //unsigned char sqtdtam[10];
    // mostra msgs na tela
    printText("Hellooooooooo...\r\n\0");

    for(ix=0;ix<90000;ix++);

    listHello();

    while(1)
    {
        if (readMouse(&vmouseStat, &vmouseMoveX, &vmouseMoveY))
        {
            printText("*[");
            itoa(vmouseStat, sqtdtam, 16);
            printText(sqtdtam);
            printText("]-[");
            itoa(vmouseMoveX, sqtdtam, 16);
            printText(sqtdtam);
            printText("]-[");
            itoa(vmouseMoveY, sqtdtam, 16);
            printText(sqtdtam);
            printText("]-[");
            itoa(*vMseMovPtrR, sqtdtam, 10);
            printText(sqtdtam);
            printText("]-[");
            itoa(*vMseMovPtrW, sqtdtam, 10);
            printText(sqtdtam);
            printText("]*\r\n\0");
        }

        if (readChar() == 0x1B)
            break;
    }
}

void listHello(void)
{
    int ix;

    for (ix=0;ix<5;ix++)
        printText("Hello................\r\n\0");
}