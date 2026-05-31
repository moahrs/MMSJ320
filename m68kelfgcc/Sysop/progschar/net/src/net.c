/* net.c - comandos de rede + COMM hook + XMODEM-CRC 128 bytes
   Versao MMSJOS: usa loadFile/saveFile/msmalloc/msfree, sem stdio.
*/

#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"

#include "net.h"
#include "netcomm.h"

#define X_SOH   0x01
#define X_EOT   0x04
#define X_ACK   0x06
#define X_NAK   0x15
#define X_CAN   0x18
#define X_CRC   'C'
#define X_SUB   0x1A

#define X_TIMEOUT_FIRST  9000000L
#define X_TIMEOUT_POLL   350000L
#define X_TIMEOUT_CHAR   900000L
#define X_RETRY_MAX      10
#define X_START_RETRY_MAX 80

/* Ajuste conforme RAM livre. XMODEM precisa guardar o arquivo inteiro
   porque o MMSJOS atual expõe saveFile(buffer,size). */
#ifndef NET_XFER_MAX
#define NET_XFER_MAX     262144UL
#endif

static unsigned short xmodemCrc16(unsigned char *buf, unsigned int len)
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

static void trimFirstParamSpace(void)
{
    unsigned int ix;

    ix = 0;
    while (paramBasic[ix] != 0x00)
    {
        paramBasic[ix] = paramBasic[ix + 1];
        ix++;
    }
}

static int startsWithNoCase(char *s, char *p)
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

static char *skipSpaces(char *s)
{
    while (*s == ' ' || *s == '\t')
        s++;
    return s;
}

static unsigned char serialReadByteTimeout(unsigned char *pByte, unsigned long pTimeoutSpin)
{
    return netCommWait(pByte, pTimeoutSpin);
}

static void readResponse(void)
{
    unsigned char c;
    unsigned long idleTimeout;
    unsigned long charTimeout;

    idleTimeout = 800000L;

    while (1)
    {
        if (serialReadByteTimeout(&c, idleTimeout))
            break;

        mprintf("Timeout aguardando resposta.\r\n");
        return;
    }

    while (1)
    {
        printChar(c, 1);

        charTimeout = 120000L;

        if (!serialReadByteTimeout(&c, charTimeout))
            break;

        if (c == 0x04)
            break;
    }
}

static int xWait(unsigned char *c, unsigned long timeout)
{
    return serialReadByteTimeout(c, timeout);
}

static int xRecvBytes(unsigned char *blk, unsigned int len)
{
    unsigned int i;
    unsigned char c;

    for (i = 0; i < len; i++)
    {
        if (!xWait(&c, X_TIMEOUT_CHAR))
            return 0;
        blk[i] = c;
    }

    return 1;
}

static int xmodemRecvFile(char *fileName)
{
    unsigned char *fileBuf;
    unsigned long fileSize;
    unsigned char c;
    unsigned char blkNo;
    unsigned char blkInv;
    unsigned char data[128];
    unsigned char crcHi;
    unsigned char crcLo;
    unsigned short crcRecv;
    unsigned short crcCalc;
    unsigned char expected;
    unsigned int retry;
    unsigned char ret;

    fileBuf = (unsigned char *)msmalloc(NET_XFER_MAX);
    if (!fileBuf)
    {
        mprintf("Sem memoria para receber arquivo.\r\n");
        return 0;
    }

    expected = 1;
    retry = 0;
    fileSize = 0;

    mprintf("XMODEM-CRC recebendo %s...\r\n", fileName);

    while (1)
    {
        writeSerial(X_CRC);

        if (!xWait(&c, X_TIMEOUT_POLL))
        {
            retry++;
            if (retry >= X_START_RETRY_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("Timeout XMODEM.\r\n");
                return 0;
            }
            continue;
        }

        retry = 0;

        if (c == X_EOT)
        {
            writeSerial(X_ACK);

            ret = saveFile((unsigned char *)fileName, fileBuf, fileSize);
            if (ret != RETURN_OK)
            {
                msfree(fileBuf);
                mprintf("Erro salvando arquivo. ret=%u\r\n", ret);
                return 0;
            }

            msfree(fileBuf);
            mprintf("Recebido %lu bytes.\r\n", fileSize);
            return 1;
        }

        if (c == X_CAN)
        {
            msfree(fileBuf);
            mprintf("Cancelado pelo remoto.\r\n");
            return 0;
        }

        if (c != X_SOH)
        {
            writeSerial(X_NAK);
            continue;
        }

        if (!xWait(&blkNo, X_TIMEOUT_CHAR) || !xWait(&blkInv, X_TIMEOUT_CHAR))
        {
            writeSerial(X_NAK);
            continue;
        }

        if (!xRecvBytes(data, 128))
        {
            writeSerial(X_NAK);
            continue;
        }

        if (!xWait(&crcHi, X_TIMEOUT_CHAR) || !xWait(&crcLo, X_TIMEOUT_CHAR))
        {
            writeSerial(X_NAK);
            continue;
        }

        crcRecv = (((unsigned short)crcHi) << 8) | crcLo;
        crcCalc = xmodemCrc16(data, 128);

        if ((unsigned char)(blkNo + blkInv) != 0xFF || crcRecv != crcCalc)
        {
            writeSerial(X_NAK);
            continue;
        }

        if (blkNo == expected)
        {
            if (fileSize + 128UL > NET_XFER_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("Arquivo maior que NET_XFER_MAX.\r\n");
                return 0;
            }

            memcpy(fileBuf + fileSize, data, 128);
            fileSize += 128;
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
            mprintf("Bloco fora de ordem. Esperado=%u recebido=%u\r\n", expected, blkNo);
            return 0;
        }
    }
}

static int xmodemSendFile(char *fileName)
{
    unsigned char *fileBuf;
    long fileSize;
    unsigned long pos;
    unsigned int n;
    unsigned char c;
    unsigned char block[128];
    unsigned char blkNo;
    unsigned int retry;
    unsigned short crc;
    unsigned int i;

    fileBuf = (unsigned char *)msmalloc(NET_XFER_MAX);
    if (!fileBuf)
    {
        mprintf("Sem memoria para carregar arquivo.\r\n");
        return 0;
    }

    fileSize = loadFile(fileName, fileBuf);
    if (fileSize <= 0)
    {
        msfree(fileBuf);
        mprintf("Erro carregando arquivo: %s\r\n", fileName);
        return 0;
    }

    if ((unsigned long)fileSize > NET_XFER_MAX)
    {
        msfree(fileBuf);
        mprintf("Arquivo maior que NET_XFER_MAX.\r\n");
        return 0;
    }

    mprintf("XMODEM-CRC enviando %s (%ld bytes)...\r\n", fileName, fileSize);

    retry = 0;
    while (1)
    {
        if (xWait(&c, X_TIMEOUT_FIRST))
        {
            if (c == X_CRC || c == X_NAK)
                break;
            if (c == X_CAN)
            {
                msfree(fileBuf);
                mprintf("Cancelado pelo remoto.\r\n");
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
        n = 0;
        while (n < 128 && pos < (unsigned long)fileSize)
            block[n++] = fileBuf[pos++];

        while (n < 128)
            block[n++] = X_SUB;

        retry = 0;
        while (1)
        {
            writeSerial(X_SOH);
            writeSerial(blkNo);
            writeSerial(255 - blkNo);

            for (i = 0; i < 128; i++)
                writeSerial(block[i]);

            crc = xmodemCrc16(block, 128);
            writeSerial((unsigned char)(crc >> 8));
            writeSerial((unsigned char)(crc & 0xFF));

            if (!xWait(&c, X_TIMEOUT_FIRST))
            {
                retry++;
                if (retry >= X_RETRY_MAX)
                {
                    writeSerial(X_CAN);
                    msfree(fileBuf);
                    mprintf("Timeout ACK.\r\n");
                    return 0;
                }
                continue;
            }

            if (c == X_ACK)
                break;

            if (c == X_CAN)
            {
                msfree(fileBuf);
                mprintf("Cancelado pelo remoto.\r\n");
                return 0;
            }

            retry++;
            if (retry >= X_RETRY_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                mprintf("Muitas tentativas.\r\n");
                return 0;
            }
        }

        blkNo++;
    }

    retry = 0;
    while (1)
    {
        writeSerial(X_EOT);

        if (xWait(&c, X_TIMEOUT_FIRST) && c == X_ACK)
            break;

        retry++;
        if (retry >= X_RETRY_MAX)
        {
            msfree(fileBuf);
            mprintf("Timeout EOT.\r\n");
            return 0;
        }
    }

    msfree(fileBuf);
    mprintf("Enviado %ld bytes.\r\n", fileSize);
    return 1;
}

static void showUsage(void)
{
    mprintf("Usage: NET <comandos>\r\n");
    mprintf("  NET AT\r\n");
    mprintf("  NET ATI\r\n");
    mprintf("  NET ATIP?\r\n");
    mprintf("  NET COMM ENABLE\r\n");
    mprintf("  NET COMM DISABLE\r\n");
    mprintf("  NET COMM STATUS\r\n");
    mprintf("  NET RECV <arquivo>\r\n");
    mprintf("  NET SEND <arquivo>\r\n");
}

int main(void)
{
    char *cmd;
    char *arg;

    if (*paramBasic == 0x00)
    {
        showUsage();
        return 0;
    }

    trimFirstParamSpace();
    cmd = skipSpaces(paramBasic);

    if (startsWithNoCase(cmd, "COMM"))
    {
        arg = skipSpaces(cmd + 4);

        if (startsWithNoCase(arg, "ENABLE"))
        {
            netCommEnable();
            mprintf("COMM ENABLED\r\n");
            return 0;
        }

        if (startsWithNoCase(arg, "DISABLE"))
        {
            netCommDisable();
            mprintf("COMM DISABLED\r\n");
            return 0;
        }

        if (startsWithNoCase(arg, "STATUS"))
        {
            mprintf("RX head=%u tail=%u lost=%u\r\n", serRxHead, serRxTail, serRxLost);
            mprintf("magic=%lx enabled=%u hookMem=%lx size=%lu\r\n",
                    netApiMagic, netApiEnabled, netApiHookMem, netApiHookSize);
            mprintf("hookCount=%lu last=%u IERA=%u IMRA=%u RSR=%u\r\n",
                    netApiHookCount, netApiLastByte,
                    *(vmfp + Reg_IERA), *(vmfp + Reg_IMRA), *(vmfp + Reg_RSR));
            return 0;
        }

        mprintf("Use: NET COMM ENABLE|DISABLE|STATUS\r\n");
        return 0;
    }

    if (startsWithNoCase(cmd, "RECV"))
    {
        arg = skipSpaces(cmd + 4);
        if (*arg == 0)
        {
            mprintf("Use: NET RECV <arquivo>\r\n");
            return 0;
        }

        netCommEnable();
        xmodemRecvFile(arg);
        return 0;
    }

    if (startsWithNoCase(cmd, "SEND"))
    {
        arg = skipSpaces(cmd + 4);
        if (*arg == 0)
        {
            mprintf("Use: NET SEND <arquivo>\r\n");
            return 0;
        }

        netCommEnable();
        xmodemSendFile(arg);
        return 0;
    }

    netCommEnable();
    writeLongSerial(cmd);
    writeSerial('\r');
    readResponse();

    return 0;
}
