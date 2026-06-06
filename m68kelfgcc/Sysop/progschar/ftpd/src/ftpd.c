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

#define X_SOH   0x01
#define X_STX   0x02
#define X_EOT   0x04
#define X_ACK   0x06
#define X_NAK   0x15
#define X_CAN   0x18
#define X_CRC   'C'
#define X_SUB   0x1A
#define X_ESC   0x1B

#define X_TIMEOUT_FIRST     2500000L
#define X_TIMEOUT_POLL       120000L
#define X_TIMEOUT_CHAR       350000L
#define X_RETRY_MAX          10
#define X_START_RETRY_MAX    25
#define X_START_BURST        6

#ifndef MFTP_XFER_MAX
#define MFTP_XFER_MAX        262144UL
#endif

#define MFTP_FILENAME_MAX    96

static MMSJ_CONSOLE mftpOldConsole;
static unsigned char mftpConsoleInstalled = 0;
static unsigned char mftpAbortRequested = 0;
static unsigned char mftpXBlock[1024];

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

static int mftpReadLine(char *buf, int max)
{
    int pos;
    unsigned char c;

    pos = 0;

    while (1)
    {
        while (!serialBufGet(&c))
        {
            if (mftpLocalAbort())
                return -1;
        }

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

static int mftpStartsWithNoCase(char *s, char *p)
{
    while (*p)
    {
        if (toupper(*s) != toupper(*p))
            return 0;
        s++;
        p++;
    }

    return 1;
}

static void mftpUpperText(char *s)
{
    while (*s)
    {
        *s = (char)toupper(*s);
        s++;
    }
}

static char *mftpSkipSpaces(char *s)
{
    while (*s == ' ' || *s == '\t')
        s++;
    return s;
}

static void mftpCopyCleanFileName(char *dst, char *src)
{
    unsigned int ix;
    unsigned int last;

    ix = 0;
    last = 0;

    while (*src == ' ' || *src == '\t')
        src++;

    while (*src && ix < MFTP_FILENAME_MAX - 1)
    {
        dst[ix] = *src++;
        if (dst[ix] == '\\')
            dst[ix] = '/';
        else
            dst[ix] = (char)toupper(dst[ix]);

        if (dst[ix] != ' ' && dst[ix] != '\t' && dst[ix] != '\r' && dst[ix] != '\n')
            last = ix + 1;

        ix++;
    }

    dst[last] = 0;
}

static unsigned char mftpReadByteTimeout(unsigned char *pByte, unsigned long timeoutSpin)
{
    while (timeoutSpin)
    {
        if (mftpLocalAbort())
            return 0;

        if (serialBufGet(pByte))
            return 1;

        timeoutSpin--;
    }

    return 0;
}

static void mftpDrainInput(unsigned long quietSpin)
{
    unsigned char c;
    unsigned long idle;

    idle = quietSpin;
    while (idle)
    {
        if (mftpLocalAbort())
            return;

        if (serialBufGet(&c))
            idle = quietSpin;
        else
            idle--;
    }
}

static unsigned short mftpXmodemCrc16(unsigned char *buf, unsigned int len)
{
    unsigned short crc;
    unsigned int i;
    unsigned char bit;

    crc = 0;

    while (len--)
    {
        crc ^= ((unsigned short)(*buf++)) << 8;

        for (i = 0; i < 8; i++)
        {
            bit = (crc & 0x8000) ? 1 : 0;
            crc <<= 1;
            if (bit)
                crc ^= 0x1021;
        }
    }

    return crc;
}

static int mftpXWait(unsigned char *c, unsigned long timeout)
{
    return mftpReadByteTimeout(c, timeout);
}

static int mftpXRecvBytes(unsigned char *blk, unsigned int len)
{
    unsigned int i;
    unsigned char c;

    for (i = 0; i < len; i++)
    {
        if (!mftpXWait(&c, X_TIMEOUT_CHAR))
            return 0;
        blk[i] = c;
    }

    return 1;
}

static void mftpXSendStartBurst(void)
{
    unsigned int i;

    for (i = 0; i < X_START_BURST; i++)
    {
        writeSerial(X_CRC);
        delayms(20);
    }
}

static unsigned char mftpSaveFile(char *fileName, unsigned char *buf, unsigned long size)
{
    unsigned char chunk[128];
    unsigned char ret;
    unsigned short iy;
    unsigned short chunkSize;
    unsigned long ix;
    unsigned long oldCluster;

    oldCluster = fsGetClusterDir();

    if (fsOpenFile(fileName) == RETURN_OK)
    {
        ret = fsDelFile(fileName);
        if (ret != RETURN_OK)
        {
            fsSetClusterDir(oldCluster);
            return ret;
        }
    }

    ret = fsCreateFile(fileName);
    if (ret != RETURN_OK)
    {
        fsSetClusterDir(oldCluster);
        return ret;
    }

    for (ix = 0; ix < size; ix += 128)
    {
        chunkSize = (unsigned short)(size - ix);
        if (chunkSize > 128)
            chunkSize = 128;

        for (iy = 0; iy < chunkSize; iy++)
            chunk[iy] = buf[ix + iy];

        ret = fsWriteFile(fileName, ix, chunk, (unsigned char)chunkSize);
        if (ret != RETURN_OK)
        {
            fsCloseFile(fileName, 0);
            fsSetClusterDir(oldCluster);
            return ret;
        }
    }

    fsCloseFile(fileName, 1);
    fsSetClusterDir(oldCluster);

    return RETURN_OK;
}

static int mftpRecvFile(char *fileName)
{
    unsigned char *fileBuf;
    unsigned long fileSize;
    unsigned char c;
    unsigned char blkNo;
    unsigned char blkInv;
    unsigned char crcHi;
    unsigned char crcLo;
    unsigned short crcRecv;
    unsigned short crcCalc;
    unsigned char expected;
    unsigned int retry;
    unsigned short blockLen;
    unsigned char ret;
    char saveName[MFTP_FILENAME_MAX];

    mftpCopyCleanFileName(saveName, fileName);
    if (saveName[0] == 0)
    {
        mprintf("Use: PUT <arquivo>\r\n");
        return 0;
    }

    fileBuf = (unsigned char *)msmalloc(MFTP_XFER_MAX);
    if (!fileBuf)
    {
        mprintf("Sem memoria para receber arquivo.\r\n");
        return 0;
    }

    expected = 1;
    retry = 0;
    fileSize = 0;

    mprintf("MFTP-XFER PUT %s MAX %lu\r\n", saveName, MFTP_XFER_MAX);
    mftpDrainInput(180000L);
    mftpXSendStartBurst();

    while (1)
    {
        if (mftpLocalAbort())
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
            return 0;
        }

        writeSerial(X_CRC);

        if (!mftpXWait(&c, X_TIMEOUT_POLL))
        {
            if (mftpAbortRequested)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
                return 0;
            }

            retry++;
            if (retry >= X_START_RETRY_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("\r\nTimeout XMODEM.\r\n");
                return 0;
            }
            continue;
        }

        retry = 0;

        if (c == X_EOT)
        {
            writeSerial(X_ACK);

            mprintf("\r\nSalvando %lu bytes em %s...\r\n", fileSize, saveName);
            ret = mftpSaveFile(saveName, fileBuf, fileSize);
            if (ret != RETURN_OK)
            {
                msfree(fileBuf);
                mprintf("Erro salvando arquivo. ret=%u\r\n", ret);
                return 0;
            }

            msfree(fileBuf);
            mprintf("OK recebido %lu bytes.\r\n", fileSize);
            return 1;
        }

        if (c == X_CAN || c == X_ESC)
        {
            msfree(fileBuf);
            mprintf("\r\nCancelado pelo remoto. Recebidos %lu bytes.\r\n", fileSize);
            return 0;
        }

        if (c == X_SOH)
            blockLen = 128;
        else if (c == X_STX)
            blockLen = 1024;
        else
        {
            writeSerial(X_NAK);
            continue;
        }

        if (!mftpXWait(&blkNo, X_TIMEOUT_CHAR) || !mftpXWait(&blkInv, X_TIMEOUT_CHAR))
        {
            writeSerial(X_NAK);
            continue;
        }

        if (!mftpXRecvBytes(mftpXBlock, blockLen))
        {
            writeSerial(X_NAK);
            continue;
        }

        if (!mftpXWait(&crcHi, X_TIMEOUT_CHAR) || !mftpXWait(&crcLo, X_TIMEOUT_CHAR))
        {
            writeSerial(X_NAK);
            continue;
        }

        crcRecv = (((unsigned short)crcHi) << 8) | crcLo;
        crcCalc = mftpXmodemCrc16(mftpXBlock, blockLen);

        if ((unsigned char)(blkNo + blkInv) != 0xFF || crcRecv != crcCalc)
        {
            writeSerial(X_NAK);
            continue;
        }

        if (blkNo == expected)
        {
            if (fileSize + (unsigned long)blockLen > MFTP_XFER_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("\r\nArquivo maior que MFTP_XFER_MAX.\r\n");
                return 0;
            }

            memcpy(fileBuf + fileSize, mftpXBlock, blockLen);
            fileSize += blockLen;
            expected++;
            writeSerial(X_ACK);
        }
        else if (blkNo == (unsigned char)(expected - 1))
        {
            writeSerial(X_ACK);
        }
        else
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            mprintf("\r\nBloco fora de ordem. Esperado=%u recebido=%u\r\n", expected, blkNo);
            return 0;
        }
    }
}

static int mftpSendFile(char *fileName)
{
    unsigned char *fileBuf;
    long fileSize;
    unsigned long pos;
    unsigned int n;
    unsigned char c;
    unsigned char blkNo;
    unsigned int retry;
    unsigned short crc;
    unsigned short blockLen;
    unsigned int i;
    char sendName[MFTP_FILENAME_MAX];

    mftpCopyCleanFileName(sendName, fileName);
    if (sendName[0] == 0)
    {
        mprintf("Use: GET <arquivo>\r\n");
        return 0;
    }

    fileBuf = (unsigned char *)msmalloc(MFTP_XFER_MAX);
    if (!fileBuf)
    {
        mprintf("Sem memoria para carregar arquivo.\r\n");
        return 0;
    }

    fileSize = loadFile((unsigned char *)sendName, fileBuf);
    if (fileSize <= 0)
    {
        msfree(fileBuf);
        mprintf("Erro carregando arquivo: %s\r\n", sendName);
        return 0;
    }

    if ((unsigned long)fileSize > MFTP_XFER_MAX)
    {
        msfree(fileBuf);
        mprintf("Arquivo maior que MFTP_XFER_MAX.\r\n");
        return 0;
    }

    mprintf("MFTP-XFER GET %s SIZE %ld\r\n", sendName, fileSize);

    retry = 0;
    while (1)
    {
        if (mftpLocalAbort())
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
            return 0;
        }

        if (mftpXWait(&c, X_TIMEOUT_FIRST))
        {
            if (c == X_CRC || c == X_NAK)
                break;
            if (c == X_CAN || c == X_ESC)
            {
                msfree(fileBuf);
                mprintf("\r\nCancelado pelo remoto.\r\n");
                return 0;
            }
        }

        retry++;
        if (retry >= X_RETRY_MAX)
        {
            msfree(fileBuf);
            mprintf("Timeout esperando receptor.\r\n");
            return 0;
        }
    }

    blkNo = 1;
    pos = 0;

    while (pos < (unsigned long)fileSize)
    {
        if (mftpLocalAbort())
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
            return 0;
        }

        if (((unsigned long)fileSize - pos) > 128UL)
            blockLen = 1024;
        else
            blockLen = 128;

        n = 0;
        while (n < blockLen && pos < (unsigned long)fileSize)
            mftpXBlock[n++] = fileBuf[pos++];

        while (n < blockLen)
            mftpXBlock[n++] = X_SUB;

        retry = 0;
        while (1)
        {
            if (mftpLocalAbort())
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
                return 0;
            }

            if (blockLen == 1024)
                writeSerial(X_STX);
            else
                writeSerial(X_SOH);

            writeSerial(blkNo);
            writeSerial(255 - blkNo);

            for (i = 0; i < blockLen; i++)
                writeSerial(mftpXBlock[i]);

            crc = mftpXmodemCrc16(mftpXBlock, blockLen);
            writeSerial((unsigned char)(crc >> 8));
            writeSerial((unsigned char)(crc & 0xFF));

            if (!mftpXWait(&c, X_TIMEOUT_FIRST))
            {
                retry++;
                if (retry >= X_RETRY_MAX)
                {
                    writeSerial(X_CAN);
                    msfree(fileBuf);
                    mprintf("\r\nTimeout ACK. Enviados %lu bytes.\r\n", pos);
                    return 0;
                }
                continue;
            }

            if (c == X_ACK)
                break;

            if (c == X_CAN || c == X_ESC)
            {
                msfree(fileBuf);
                mprintf("\r\nCancelado pelo remoto. Enviados %lu bytes.\r\n", pos);
                return 0;
            }

            retry++;
            if (retry >= X_RETRY_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("\r\nMuitas tentativas.\r\n");
                return 0;
            }
        }

        blkNo++;
    }

    retry = 0;
    while (1)
    {
        if (mftpLocalAbort())
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
            return 0;
        }

        writeSerial(X_EOT);

        if (mftpXWait(&c, X_TIMEOUT_FIRST) && c == X_ACK)
            break;

        retry++;
        if (retry >= X_RETRY_MAX)
        {
            msfree(fileBuf);
            mprintf("\r\nTimeout EOT.\r\n");
            return 0;
        }
    }

    msfree(fileBuf);
    mprintf("\r\nOK enviado %ld bytes.\r\n", fileSize);
    return 1;
}

/* -------------------------------------------------- */
/* MAIN                                               */
/* -------------------------------------------------- */

int main(void)
{
    char cmd[80];
    char *arg;
    int readLen;

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

    return 0;
}
