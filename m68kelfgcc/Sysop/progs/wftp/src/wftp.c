/********************************************************************************
*    Programa    : wftp.c
*    Objetivo    : Interface MGUI para o servidor MFTP/FTPD
********************************************************************************/

#include <string.h>
#include <stdlib.h>

#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"
#include "mmsj320api.h"
#include "netcomm_runtime.h"

#include "wftp.h"

static unsigned char mftpAbortRequested = 0;
static unsigned char wftpCancelRequested = 0;
static unsigned char wftpMousePrev = 0;

static unsigned char mftpLocalAbort(void)
{
    unsigned char vRetCanc;

    vRetCanc = wftpAbortExtra();

    mftpAbortRequested = vRetCanc;

    return vRetCanc;
}

unsigned char wftpAbortExtra(void)
{
    MGUI_MOUSE m;
    unsigned int keyRaw;
    unsigned char code;
    unsigned char flags;

    if (wftpCancelRequested)
        return 1;

    getMouseData(0, &m);
    getMouseData(1, &m);

    if (m.mouseButton == 0x01 && wftpMousePrev != 0x01)
    {
        if (m.vpostx >= (WFTP_X + WFTP_W - 13) && m.vpostx <= (WFTP_X + WFTP_W - 3) &&
            m.vposty >= (WFTP_Y + 2) && m.vposty <= (WFTP_Y + 12))
        {
            wftpCancelRequested = 1;
            return 1;
        }

        if (m.vpostx >= WFTP_BTN_X && m.vpostx <= (WFTP_BTN_X + WFTP_BTN_W) &&
            m.vposty >= WFTP_BTN_Y && m.vposty <= (WFTP_BTN_Y + WFTP_BTN_H))
        {
            wftpCancelRequested = 1;
            return 1;
        }
    }
    wftpMousePrev = m.mouseButton;

    keyRaw = (unsigned int)mguiListWindows[6].keyTec;
    if (keyRaw)
    {
        mguiListWindows[6].keyTec = 0;
        code = (unsigned char)(keyRaw & 0xFF);
        flags = (unsigned char)((keyRaw >> 8) & 0xFF);

        if (flags == KEY_CTRL_ALT && (code == 'X' || code == 'x'))
        {
            wftpCancelRequested = 1;
            return 1;
        }
    }

    return 0;
}

#include "ftpdcomm.h"

static unsigned char wftpFg;
static unsigned char wftpBg;

static void wftpDrawButton(void)
{
    FillRect(WFTP_BTN_X, WFTP_BTN_Y, WFTP_BTN_W, WFTP_BTN_H, wftpBg);
    DrawRoundRect(WFTP_BTN_X, WFTP_BTN_Y, WFTP_BTN_W, WFTP_BTN_H, 1, wftpFg);
    writesxy(WFTP_BTN_X + 14, WFTP_BTN_Y + 4, 1, (unsigned char *)"Cancel", wftpFg, wftpBg);
}

static void wftpDrawWindow(void)
{
    showWindow("WFTP\0", WFTP_X, WFTP_Y, WFTP_W, WFTP_H, BTCLOSE);
    writesxy(WFTP_X + 31, WFTP_Y + 24, 1, (unsigned char *)"Running...", wftpFg, wftpBg);
    wftpDrawButton();
}

void procFtpd(void)
{
    char cmd[80];
    char *arg;
    int readLen;
    long vTimeOut = 8;
    unsigned char cCmd[128];
    char listenOn = 0;

    netCommEnable();

    // Verifica se esta em modo Listen, se sim, tira
    while(vTimeOut--)
    {
        writeLongSerial("ATLISTEN?");
        writeSerial('\r');
        
        readResponseProc(&cCmd);

        if (!strncmp(cCmd,"OK;",3))
        {
            if (!strncmp(cCmd,"OK;OFF",6))  // se bater, nao esta no Listen
            {
                // Liga
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
}

int main(void)
{
    MGUI_SAVESCR save;
    VDP_COLOR color;

    if (*startBasic != 2)
        return;

    TrocaSpriteMouse(MOUSE_POINTER);

    getColorData(&color);
    wftpFg = color.fg;
    wftpBg = color.bg;
    if (wftpFg == wftpBg)
        wftpFg = VDP_WHITE;

    wftpMousePrev = 0;
    wftpCancelRequested = 0;

    SaveScreenNew(&save, WFTP_X, WFTP_Y, WFTP_W, WFTP_H);
    wftpDrawWindow();

    procFtpd();

    RestoreScreen(&save);
    TrocaSpriteMouse(MOUSE_POINTER);

    return 0;
}
