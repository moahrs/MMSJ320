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

void (*lHello)(void);

char * (*myitoa)(int, char *, int);
char * (*myltoa)(long, char *, int);

unsigned char mouseMoveX;
unsigned char mouseMoveY;
unsigned char mouseStat;

//-----------------------------------------------------------------------------
// Principal
//-----------------------------------------------------------------------------
void main(void)
{
    int ix;
    unsigned char sqtdtam[10];

    lHello = listHello;
    myitoa = itoa;
    myltoa = ltoa;

    //unsigned char sqtdtam[10];
    // mostra msgs na tela
    printText("Hellooooooooo...\r\n\0");

    for(ix=0;ix<90000;ix++);

    lHello();

    while(1)
    {
        if (readMouse(&mouseStat, &mouseMoveX, &mouseMoveY))
        {
            printText("*[");
            myitoa(mouseStat, sqtdtam, 16);
            printText(sqtdtam);
            printText("]-[");
            myitoa(mouseMoveX, sqtdtam, 16);
            printText(sqtdtam);
            printText("]-[");
            myitoa(mouseMoveY, sqtdtam, 16);
            printText(sqtdtam);
            printText("]-[");
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