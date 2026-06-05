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

#include "ftpd.h"

#define MFTPD_MAGIC 0x4D465450UL /* MFTP */

static MMSJ_CONSOLE mftpOldConsole;
static unsigned char mftpConsoleInstalled = 0;

int serialBufGet(unsigned char *c)
{
    if (serRxHead == serRxTail)
        return 0;

    *c = serRxBuf[serRxTail];
  
    serRxTail++;
    if (serRxTail >= SER_RX_SIZE)
        serRxTail = 0;

    return 1;
}

static unsigned char serialReadByte(unsigned char *pByte)
{
    return serialBufGet(pByte);
}

static void mftpPutc(unsigned char c, char pMove)
{
    writeSerial(c);
}

void mftpPuts(unsigned char *s)
{
    while (*s)
        mftpPutc(*s++, 1);
}

static int mftpKbhit(void)
{
    unsigned char c;
    return serialBufGet(&c); /* cuidado: isso consome; melhor fazer peek depois */
}

static int mftpGetc(void)
{
    unsigned char c;

    while (!serialBufGet(&c))
        ;

    return c;
}

static int mftpReadLine(char *buf, int max)
{
    int pos;
    unsigned char c;

    pos = 0;

    while (1)
    {
        while (!serialBufGet(&c))
            ;

        if (c == 13 || c == 10)
        {
            buf[pos] = 0;
            mftpPuts((unsigned char*)"\r\n");
            return pos;
        }

        if (c == 8)
        {
            if (pos > 0)
            {
                pos--;
                mftpPuts((unsigned char*)"\b \b");
            }
            continue;
        }

        if (pos < max - 1)
        {
            buf[pos++] = c;
            mftpPutc(c, 1); /* eco */
        }
    }
}

static void mftpConsoleInstall(void)
{
    mftpOldConsole = *activeConsole;

    activeConsole->magic = MFTPD_MAGIC;
    activeConsole->flags = 0;
    activeConsole->putc  = mftpPutc;
    activeConsole->getc  = NULL;
    activeConsole->kbhit = NULL;

    mftpConsoleInstalled = 1;
}

static void mftpConsoleUninstall(void)
{
    if (mftpConsoleInstalled)
    {
        *activeConsole = mftpOldConsole;
        mftpConsoleInstalled = 0;
    }
}

/* -------------------------------------------------- */
/* MAIN                                               */
/* -------------------------------------------------- */

int main(void)
{
    char cmd[80];

    mftpConsoleInstall();

    mftpPuts((unsigned char*)"MMSJ-MFTP READY\r\n");
    mftpPuts((unsigned char*)"Type HELP\r\n\r\n");

    while (1)
    {
        mftpPuts((unsigned char*)"MFTP> ");

        mftpReadLine(cmd, sizeof(cmd));

        if (!strcmp(cmd, "HELP"))
        {
            mftpPuts((unsigned char*)"Commands:\r\n");
            mftpPuts((unsigned char*)"  VER\r\n");
            mftpPuts((unsigned char*)"  DIR\r\n");
            mftpPuts((unsigned char*)"  QUIT\r\n");
        }
        else if (!strcmp(cmd, "DIR"))
        {
            fsOsCommand((unsigned char*)"LS");
        }
        else if (!strcmp(cmd, "VER"))
        {
            fsOsCommand((unsigned char*)"VER");
        }
        else if (!strcmp(cmd, "QUIT"))
        {
            mftpPuts((unsigned char*)"BYE\r\n");
            break;
        }
        else
        {
            mftpPuts((unsigned char*)"ERR Unknown command\r\n");
        }
    }

    mftpConsoleUninstall();

    return 0;
}
