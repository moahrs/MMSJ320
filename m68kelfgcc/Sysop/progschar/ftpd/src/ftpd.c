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
#include "netcomm_runtime.h"

#include "ftpd.h"

static unsigned char mftpAbortRequested = 0;

static unsigned char mftpLocalAbort(void)
{
    MMSJ_KEYEVENT k;

    if (mftpAbortRequested)
        return 1;

    if (!mmsjKeyGet(&k))
        return 0;

    if (k.flags == KEY_CTRL_ALT && k.code == 'X')
    {
        mftpAbortRequested = 1;
        return 1;
    }

    return 0;
}

#include "ftpdcomm.h"

/* -------------------------------------------------- */
/* MAIN                                               */
/* -------------------------------------------------- */

int main(void)
{
    char cmd[80];
    char *arg;
    int readLen;
    long vTimeOut = 8;
    unsigned char cCmd[128];
    char listenOn = 0;

    printText("Enabling Comm...\r\n");
    netCommEnable();

    // Verifica se esta em modo Listen, se sim, tira
    printText("Enabling Listen...\r\n");
    while(vTimeOut--)
    {
        netCommResetInput();
        writeLongSerial("ATLISTEN?");
        writeSerial('\r');
        
        readResponseProc(&cCmd);

        if (!strncmp(cCmd,"OK;",3))
        {
            if (!strncmp(cCmd,"OK;OFF",6))  // se bater, nao esta no Listen
            {
                // Liga
                netCommResetInput();
                writeLongSerial("ATLISTEN");
                writeSerial('\r');                    
                readResponseProc(&cCmd);
            }
            else
            {
                listenOn = 1;
                break;
            }
        }
    }

    if (!listenOn)
    {
        if (*startBasic == 1)
            mprintf("Unable to set Listen");

        return 1;
    }

    printText("Ready\r\n");

    mftpConsoleInstall();

    mftpPuts((unsigned char*)"MMSJ-MFTP READY\r\n");
    mftpPuts((unsigned char*)"Type HELP\r\n\r\n");

    while (1)
    {
        mftpPuts((unsigned char*)"MFTP> ");

        readLen = mftpReadLine(cmd, sizeof(cmd));
        if (readLen < 0)
        {
            mftpPuts((unsigned char*)"\r\nBYE\r\n");
            break;
        }

        arg = cmd;
        while (*arg && *arg != ' ' && *arg != '\t')
            arg++;
        if (*arg)
        {
            *arg = 0;
            arg++;
        }
        arg = mftpSkipSpaces(arg);
        mftpUpperText(cmd);

        printText(">");
        printText(cmd);
        printText(" ");
        printText(arg);
        printText("\r\n");

        if (mftpStartsWithNoCase(cmd, "HELP"))
        {
            mftpPuts((unsigned char*)"Commands:\r\n");
            mftpPuts((unsigned char*)"  VER\r\n");
            mftpPuts((unsigned char*)"  DIR\r\n");
            mftpPuts((unsigned char*)"  CD <dir>\r\n");
            mftpPuts((unsigned char*)"  PWD\r\n");
            mftpPuts((unsigned char*)"  PUT <arquivo>  (PC -> MMSJ)\r\n");
            mftpPuts((unsigned char*)"  GET <arquivo>  (MMSJ -> PC)\r\n");
            mftpPuts((unsigned char*)"  QUIT\r\n");
            mftpPuts((unsigned char*)"Cancel: envie CAN no XMODEM ou aguarde timeout.\r\n");
        }
        else if (mftpStartsWithNoCase(cmd, "DIR"))
        {
            fsOsCommand((unsigned char*)"LS");
        }
        else if (mftpStartsWithNoCase(cmd, "VER"))
        {
            fsOsCommand((unsigned char*)"VER");
        }
        else if (mftpStartsWithNoCase(cmd, "PWD"))
        {
            fsOsCommand((unsigned char*)"PWD");
        }
        else if (mftpStartsWithNoCase(cmd, "CD"))
        {
            if (*arg == 0)
                mftpPuts((unsigned char*)"Use: CD <dir>\r\n");
            else
            {
                char osCmd[96];
                strcpy(osCmd, "CD ");
                strncat(osCmd, arg, sizeof(osCmd) - 4);
                osCmd[sizeof(osCmd) - 1] = 0;
                fsOsCommand((unsigned char*)osCmd);
            }
        }
        else if (mftpStartsWithNoCase(cmd, "PUT"))
        {
            mftpRecvFile(arg);
        }
        else if (mftpStartsWithNoCase(cmd, "GET"))
        {
            mftpSendFile(arg);
        }
        else if (mftpStartsWithNoCase(cmd, "QUIT"))
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

    printText("Bye\r\n");

    return 0;
}
