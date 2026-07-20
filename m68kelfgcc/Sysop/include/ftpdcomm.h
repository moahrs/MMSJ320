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
#define X_START_BURST        1
#define X_USE_1K             0

#ifndef MFTP_XFER_MAX
#define MFTP_XFER_MAX        262144UL
#endif

#define MFTP_FILENAME_MAX    96

#ifndef MFTP_STATUS
#define MFTP_STATUS(s)
#define MFTP_STATUS_CMD(c,a)
#define MFTP_STATUS_XFER(s)
#define MFTP_STATUS_BYTES(l,b)
#endif

static MMSJ_CONSOLE mftpOldConsole;
static unsigned char mftpConsoleInstalled = 0;
static unsigned char mftpXBlock[1024];

typedef struct
{
    unsigned long cluster;
    unsigned char dirPath[128];
} MFTP_DIR_STATE;

static void mftpSaveDirState(MFTP_DIR_STATE *state)
{
    state->cluster = fsGetClusterDir();
    state->dirPath[0] = 0;
    fsPwdDir(state->dirPath);
}

static void mftpRestoreDirState(MFTP_DIR_STATE *state)
{
    unsigned char cmd[132];

    if (state->dirPath[0])
    {
        strcpy((char *)cmd, "CD ");
        strncat((char *)cmd, (char *)state->dirPath, sizeof(cmd) - 4);
        cmd[sizeof(cmd) - 1] = 0;
        fsOsCommand(cmd);
    }

    fsSetClusterDir(state->cluster);
}

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
        {
            if (mftpLocalAbort())
                return -1;
        }

        if (c == 13 || c == 10)
        {
            buf[pos] = 0;

            if (pos == 0)
                continue;

            if (!strncmp(buf, "EVT;", 4))
            {
                pos = 0;
                continue;
            }

            mftpPuts((unsigned char*)"\r\n");
            return pos;
        }

        if (c == X_EOT)
        {
            if (pos >= 4)
            {
                buf[pos] = 0;
                if (!strncmp(buf, "EVT;", 4))
                    pos = 0;
            }
            continue;
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
    unsigned char started;
    char saveName[MFTP_FILENAME_MAX];

    mftpCopyCleanFileName(saveName, fileName);
    if (saveName[0] == 0)
    {
        MFTP_STATUS("PUT without file");
        mprintf("Use: PUT <arquivo>\r\n");
        return 0;
    }

    fileBuf = (unsigned char *)msmalloc(MFTP_XFER_MAX);
    if (!fileBuf)
    {
        MFTP_STATUS("No memory");
        mprintf("Sem memoria para receber arquivo.\r\n");
        return 0;
    }

    expected = 1;
    retry = 0;
    fileSize = 0;
    started = 0;

    mprintf("MFTP-XFER PUT %s MAX %lu\r\n", saveName, MFTP_XFER_MAX);
    MFTP_STATUS_BYTES("Received", 0);
    MFTP_STATUS_XFER("Draining input");
    mftpDrainInput(20000L);
    MFTP_STATUS_XFER("Sending CRC");
    mftpXSendStartBurst();
    MFTP_STATUS_XFER("Waiting first block");

    while (1)
    {
        if (mftpLocalAbort())
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            MFTP_STATUS_XFER("Cancelled");
            mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
            return 0;
        }

        if (!started)
        {
            MFTP_STATUS_XFER("Waiting first block");
            writeSerial(X_CRC);
        }

        if (!mftpXWait(&c, X_TIMEOUT_POLL))
        {
            if (mftpAbortRequested)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                MFTP_STATUS_XFER("Cancelled");
                mprintf("\r\nCancelado por CTRL+ALT+X.\r\n");
                return 0;
            }

            retry++;
            if (retry >= X_START_RETRY_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                MFTP_STATUS_XFER("Timeout");
                mprintf("\r\nTimeout XMODEM.\r\n");
                return 0;
            }

            if (started)
                writeSerial(X_NAK);

            continue;
        }

        retry = 0;

        if (c == X_EOT)
        {
            writeSerial(X_ACK);

            MFTP_STATUS_XFER("Saving");
            MFTP_STATUS_BYTES("Received", fileSize);
            mprintf("\r\nSalvando %lu bytes em %s...\r\n", fileSize, saveName);
            ret = mftpSaveFile(saveName, fileBuf, fileSize);
            if (ret != RETURN_OK)
            {
                msfree(fileBuf);
                MFTP_STATUS_XFER("Save error");
                mprintf("Erro salvando arquivo. ret=%u\r\n", ret);
                return 0;
            }

            msfree(fileBuf);
            MFTP_STATUS_XFER("Receive done");
            MFTP_STATUS_BYTES("Received", fileSize);
            mprintf("OK recebido %lu bytes.\r\n", fileSize);
            return 1;
        }

        if (c == X_CAN || c == X_ESC)
        {
            msfree(fileBuf);
            MFTP_STATUS_XFER("Remote cancel");
            MFTP_STATUS_BYTES("Received", fileSize);
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

        started = 1;

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
                MFTP_STATUS_XFER("Too large");
                mprintf("\r\nArquivo maior que MFTP_XFER_MAX.\r\n");
                return 0;
            }

            memcpy(fileBuf + fileSize, mftpXBlock, blockLen);
            fileSize += blockLen;
            MFTP_STATUS_XFER("Receiving");
            MFTP_STATUS_BYTES("Received", fileSize);
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
            MFTP_STATUS_XFER("Block error");
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
        MFTP_STATUS("GET without file");
        mprintf("Use: GET <arquivo>\r\n");
        return 0;
    }

    fileBuf = (unsigned char *)msmalloc(MFTP_XFER_MAX);
    if (!fileBuf)
    {
        MFTP_STATUS("No memory");
        mprintf("Sem memoria para carregar arquivo.\r\n");
        return 0;
    }

    fileSize = loadFile((unsigned char *)sendName, fileBuf);
    if (fileSize <= 0)
    {
        msfree(fileBuf);
        MFTP_STATUS_XFER("Load error");
        mprintf("Erro carregando arquivo: %s\r\n", sendName);
        return 0;
    }

    if ((unsigned long)fileSize > MFTP_XFER_MAX)
    {
        msfree(fileBuf);
        MFTP_STATUS_XFER("Too large");
        mprintf("Arquivo maior que MFTP_XFER_MAX.\r\n");
        return 0;
    }

    mprintf("MFTP-XFER GET %s SIZE %ld\r\n", sendName, fileSize);
    MFTP_STATUS_XFER("Waiting receiver");
    MFTP_STATUS_BYTES("Sent", 0);
    delayms(100);

    retry = 0;
    while (1)
    {
        if (mftpLocalAbort())
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            MFTP_STATUS_XFER("Cancelled");
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
                MFTP_STATUS_XFER("Remote cancel");
                mprintf("\r\nCancelado pelo remoto.\r\n");
                return 0;
            }
        }

        retry++;
        if (retry >= X_RETRY_MAX)
        {
            msfree(fileBuf);
            MFTP_STATUS_XFER("Timeout receiver");
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

        if (X_USE_1K && ((unsigned long)fileSize - pos) > 128UL)
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
                MFTP_STATUS_XFER("Cancelled");
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
                MFTP_STATUS_XFER("Timeout ACK");
                MFTP_STATUS_BYTES("Sent", pos);
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
                MFTP_STATUS_XFER("Remote cancel");
                MFTP_STATUS_BYTES("Sent", pos);
                mprintf("\r\nCancelado pelo remoto. Enviados %lu bytes.\r\n", pos);
                return 0;
            }

            retry++;
            if (retry >= X_RETRY_MAX)
            {
                writeSerial(X_CAN);
                msfree(fileBuf);
                MFTP_STATUS_XFER("Too many retries");
                mprintf("\r\nMuitas tentativas.\r\n");
                return 0;
            }
        }

        MFTP_STATUS_XFER("Sending");
        MFTP_STATUS_BYTES("Sent", pos);
        blkNo++;
    }

    retry = 0;
    while (1)
    {
        if (mftpLocalAbort())
        {
            writeSerial(X_CAN);
            msfree(fileBuf);
            MFTP_STATUS_XFER("Cancelled");
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
            MFTP_STATUS_XFER("Timeout EOT");
            mprintf("\r\nTimeout EOT.\r\n");
            return 0;
        }
    }

    msfree(fileBuf);
    MFTP_STATUS_XFER("Send done");
    MFTP_STATUS_BYTES("Sent", fileSize);
    mprintf("\r\nOK enviado %ld bytes.\r\n", fileSize);
    return 1;
}

static void readResponseProc(unsigned char *s)
{
    unsigned char c;
    unsigned char line[128];
    unsigned char pos;
    unsigned long idleTimeout;
    unsigned long charTimeout;

    s[0] = 0;
    idleTimeout = 800000L;   /* espera primeira resposta */
    pos = 0;

    while (1)
    {
        if (mftpReadByteTimeout(&c, idleTimeout))
            break;

        mprintf("Timeout aguardando resposta.\r\n");
        return;
    }

    while (1)
    {
        if (c == '\r')
        {
        }
        else if (c == '\n' || c == 0x04)
        {
            line[pos] = 0;
            if (!strncmp(line, "OK;", 3) || !strncmp(line, "ERR;", 4) || !strncmp(line, "ERROR", 5))
            {
                strcpy(s, line);
                return;
            }
            pos = 0;
        }
        else
        {
            if (pos < sizeof(line) - 1)
                line[pos++] = c;
        }

        charTimeout = 120000L;   /* timeout entre chars */

        if (!mftpReadByteTimeout(&c, charTimeout))
            break;
    }

    line[pos] = 0;
    if (!strncmp(line, "OK;", 3) || !strncmp(line, "ERR;", 4) || !strncmp(line, "ERROR", 5))
        strcpy(s, line);
}
