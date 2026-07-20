/* mftpcli.cpp - cliente PC/TCP para o MFTP do MMSJ320.
   Borland C++ 5.5 / Win32 console.

   Uso:
     mftpcli <host> [porta]

   Ex:
     mftpcli 192.168.0.50 23

   Comandos:
     dir, cd, pwd, ver, help, quit
     put <arquivo-local> [arquivo-remoto]
     get <arquivo-remoto> [arquivo-local]
*/

#include <winsock.h>
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <ctype.h>

#define X_SOH   0x01
#define X_STX   0x02
#define X_EOT   0x04
#define X_ACK   0x06
#define X_NAK   0x15
#define X_CAN   0x18
#define X_CRC   'C'
#define X_SUB   0x1A

#define X_BLOCK_128   128
#define X_BLOCK_1K    1024
#define X_USE_1K      0
#define X_RETRY_MAX   10

#define NET_TIMEOUT_SHORT_MS   100
#define NET_CONNECT_TIMEOUT_MS 8000
#define X_TIMEOUT_FIRST_MS     90000
#define X_TIMEOUT_CHAR_MS      9000
#define X_TIMEOUT_ACK_MS       10000

static SOCKET gSock = INVALID_SOCKET;

static int strieq(const char *a, const char *b)
{
    while (*a && *b)
    {
        if (toupper((unsigned char)*a) != toupper((unsigned char)*b))
            return 0;
        a++;
        b++;
    }
    return *a == 0 && *b == 0;
}

static char *skipSpaces(char *s)
{
    while (*s == ' ' || *s == '\t')
        s++;
    return s;
}

static void trimRight(char *s)
{
    int n;

    n = (int)strlen(s);
    while (n > 0 && (s[n - 1] == ' ' || s[n - 1] == '\t' ||
                     s[n - 1] == '\r' || s[n - 1] == '\n'))
    {
        s[n - 1] = 0;
        n--;
    }
}

static void splitCommand(char *line, char **cmd, char **arg1, char **arg2)
{
    char *p;

    trimRight(line);
    p = skipSpaces(line);
    *cmd = p;

    while (*p && *p != ' ' && *p != '\t')
        p++;
    if (*p)
        *p++ = 0;

    p = skipSpaces(p);
    *arg1 = p;
    while (*p && *p != ' ' && *p != '\t')
        p++;
    if (*p)
        *p++ = 0;

    *arg2 = skipSpaces(p);
}

static const char *baseName(const char *path)
{
    const char *p;
    const char *last;

    last = path;
    for (p = path; *p; p++)
    {
        if (*p == '\\' || *p == '/' || *p == ':')
            last = p + 1;
    }
    return last;
}

static void copyRemoteName(char *dst, const char *src, int max)
{
    int ix;

    ix = 0;
    while (*src && ix < max - 1)
    {
        if (*src == '\\')
            dst[ix] = '/';
        else
            dst[ix] = (char)toupper((unsigned char)*src);

        src++;
        ix++;
    }

    dst[ix] = 0;
}

static int tcpConnect(const char *host, unsigned short port)
{
    struct sockaddr_in addr;
    struct hostent *he;
    unsigned long ip;
    unsigned long nonBlock;
    fd_set writeSet;
    fd_set exceptSet;
    struct timeval tv;
    int r;
    int sel;
    int err;
    int errLen;

    gSock = socket(AF_INET, SOCK_STREAM, 0);
    if (gSock == INVALID_SOCKET)
    {
        printf("Erro criando socket.\n");
        return 0;
    }

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);

    ip = inet_addr(host);
    if (ip == INADDR_NONE)
    {
        he = gethostbyname(host);
        if (!he)
        {
            printf("Host nao encontrado: %s\n", host);
            return 0;
        }
        memcpy(&addr.sin_addr, he->h_addr, he->h_length);
    }
    else
    {
        addr.sin_addr.s_addr = ip;
    }

    nonBlock = 1;
    ioctlsocket(gSock, FIONBIO, &nonBlock);

    r = connect(gSock, (struct sockaddr *)&addr, sizeof(addr));
    if (r != 0)
    {
        err = WSAGetLastError();
        if (err != WSAEWOULDBLOCK)
        {
            printf("Erro conectando em %s:%u.\n", host, port);
            return 0;
        }

        FD_ZERO(&writeSet);
        FD_ZERO(&exceptSet);
        FD_SET(gSock, &writeSet);
        FD_SET(gSock, &exceptSet);

        tv.tv_sec = NET_CONNECT_TIMEOUT_MS / 1000;
        tv.tv_usec = (NET_CONNECT_TIMEOUT_MS % 1000) * 1000;

        sel = select(0, NULL, &writeSet, &exceptSet, &tv);
        if (sel <= 0 || FD_ISSET(gSock, &exceptSet))
        {
            printf("Timeout conectando em %s:%u.\n", host, port);
            return 0;
        }

        err = 0;
        errLen = sizeof(err);
        getsockopt(gSock, SOL_SOCKET, SO_ERROR, (char *)&err, &errLen);
        if (err != 0)
        {
            printf("Erro conectando em %s:%u.\n", host, port);
            return 0;
        }
    }

    nonBlock = 0;
    ioctlsocket(gSock, FIONBIO, &nonBlock);

    return 1;
}

static void tcpClose(void)
{
    if (gSock != INVALID_SOCKET)
    {
        closesocket(gSock);
        gSock = INVALID_SOCKET;
    }
}

static int netWaitReadable(DWORD timeoutMs)
{
    fd_set r;
    struct timeval tv;

    FD_ZERO(&r);
    FD_SET(gSock, &r);

    tv.tv_sec = (long)(timeoutMs / 1000);
    tv.tv_usec = (long)((timeoutMs % 1000) * 1000);

    return select(0, &r, NULL, NULL, &tv) > 0;
}

static int netReadByteTimeout(unsigned char *c, DWORD timeoutMs)
{
    int r;

    if (!netWaitReadable(timeoutMs))
        return 0;

    r = recv(gSock, (char *)c, 1, 0);
    return r == 1;
}

static int xmodemReadResponse(unsigned char *resp, DWORD timeoutMs)
{
    unsigned char c;
    DWORD start;

    start = GetTickCount();
    while ((GetTickCount() - start) < timeoutMs)
    {
        if (!netReadByteTimeout(&c, NET_TIMEOUT_SHORT_MS))
            continue;

        if (c == X_ACK || c == X_NAK || c == X_CRC || c == X_CAN)
        {
            *resp = c;
            return 1;
        }
    }

    return 0;
}

static int netWriteData(const unsigned char *buf, int len)
{
    int sent;
    int r;

    sent = 0;
    while (sent < len)
    {
        r = send(gSock, (const char *)buf + sent, len - sent, 0);
        if (r <= 0)
            return 0;
        sent += r;
    }
    return 1;
}

static int netWriteByte(unsigned char c)
{
    return netWriteData(&c, 1);
}

static int netWriteText(const char *s)
{
    return netWriteData((const unsigned char *)s, (int)strlen(s));
}

static void netSendLine(const char *s)
{
    netWriteText(s);
    netWriteByte('\r');
}

static void drainNetwork(DWORD quietMs)
{
    unsigned char c;
    DWORD last;

    last = GetTickCount();
    while ((GetTickCount() - last) < quietMs)
    {
        if (netReadByteTimeout(&c, 10))
            last = GetTickCount();
    }
}

static int waitForPromptMs(DWORD timeoutMs)
{
    unsigned char c;
    const char *prompt;
    int matched;
    DWORD start;

    prompt = "MFTP> ";
    matched = 0;
    start = GetTickCount();

    while ((GetTickCount() - start) < timeoutMs)
    {
        if (kbhit())
        {
            int k = getch();
            if (k == 27)
            {
                printf("\nCancelado localmente.\n");
                return 0;
            }
        }

        if (!netReadByteTimeout(&c, NET_TIMEOUT_SHORT_MS))
            continue;

        putchar(c);
        fflush(stdout);

        if (c == (unsigned char)prompt[matched])
        {
            matched++;
            if (prompt[matched] == 0)
                return 1;
        }
        else
        {
            matched = (c == (unsigned char)prompt[0]) ? 1 : 0;
        }
    }

    return 0;
}

static int waitForPrompt(void)
{
    return waitForPromptMs(8000);
}

static int waitForPromptAfterXfer(void)
{
    printf("Aguardando conclusao no MMSJ320...\n");
    return waitForPromptMs(300000);
}

static int waitForXferReady(void)
{
    unsigned char c;
    DWORD start;
    char line[180];
    int len;
    const char *prompt;
    int matched;

    start = GetTickCount();
    len = 0;
    prompt = "MFTP> ";
    matched = 0;

    while ((GetTickCount() - start) < 8000)
    {
        if (!netReadByteTimeout(&c, 100))
            continue;

        putchar(c);
        fflush(stdout);

        if (c == (unsigned char)prompt[matched])
        {
            matched++;
            if (prompt[matched] == 0)
                return 0;
        }
        else
        {
            matched = (c == (unsigned char)prompt[0]) ? 1 : 0;
        }

        if (c == '\r')
            continue;

        if (c == '\n')
        {
            line[len] = 0;
            if (strstr(line, "MFTP-XFER"))
                return 1;
            if (strstr(line, "MFTP>"))
                return 0;
            len = 0;
            continue;
        }

        if (len < (int)sizeof(line) - 1)
            line[len++] = (char)c;
    }

    printf("\nTimeout aguardando MFTP-XFER.\n");
    return 0;
}

static unsigned short xmodemCrc16(const unsigned char *buf, int len)
{
    unsigned short crc;
    int i;
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

static long fileSizeOf(FILE *fp)
{
    long pos;
    long size;

    pos = ftell(fp);
    fseek(fp, 0, SEEK_END);
    size = ftell(fp);
    fseek(fp, pos, SEEK_SET);
    return size;
}

static int localFileExists(const char *fileName)
{
    FILE *fp;

    fp = fopen(fileName, "rb");
    if (!fp)
        return 0;

    fclose(fp);
    return 1;
}

static int localCanCancel(void)
{
    if (kbhit())
    {
        int k;
        k = getch();
        if (k == 27)
        {
            netWriteByte(X_CAN);
            netWriteByte(X_CAN);
            printf("\nCancelado localmente.\n");
            return 1;
        }
    }

    return 0;
}

static void printProgress(const char *prefix, long done, long total)
{
    int pct;

    if (total > 0)
        pct = (int)((done * 100L) / total);
    else
        pct = 0;
    if (pct > 100)
        pct = 100;

    printf("\r%s %ld/%ld bytes %d%%", prefix, done, total, pct);
    fflush(stdout);
}

static int xmodemSendFile(const char *fileName)
{
    FILE *fp;
    long total;
    long sent;
    unsigned char c;
    unsigned char block[X_BLOCK_1K];
    unsigned char blkNo;
    int retry;
    int n;
    int blockLen;
    unsigned short crc;

    fp = fopen(fileName, "rb");
    if (!fp)
    {
        printf("Erro abrindo arquivo local: %s\n", fileName);
        return 0;
    }

    total = fileSizeOf(fp);
    sent = 0;

    printf("Aguardando receptor XMODEM...\n");
    retry = 0;
    while (1)
    {
        if (localCanCancel())
        {
            fclose(fp);
            return 0;
        }

        if (netReadByteTimeout(&c, X_TIMEOUT_FIRST_MS))
        {
            if (c == X_CRC || c == X_NAK)
            {
                drainNetwork(50);
                break;
            }
            if (c == X_CAN)
            {
                fclose(fp);
                printf("Cancelado pelo remoto.\n");
                return 0;
            }
        }

        retry++;
        if (retry >= X_RETRY_MAX)
        {
            fclose(fp);
            printf("Timeout esperando receptor.\n");
            return 0;
        }
    }

    blkNo = 1;
    while (sent < total)
    {
        if (localCanCancel())
        {
            fclose(fp);
            return 0;
        }

        if (X_USE_1K && (total - sent) > 128L)
            blockLen = X_BLOCK_1K;
        else
            blockLen = X_BLOCK_128;

        n = (int)fread(block, 1, blockLen, fp);
        while (n < blockLen)
            block[n++] = X_SUB;

        retry = 0;
        while (1)
        {
            if (localCanCancel())
            {
                fclose(fp);
                return 0;
            }

            netWriteByte((unsigned char)(blockLen == X_BLOCK_1K ? X_STX : X_SOH));
            netWriteByte(blkNo);
            netWriteByte((unsigned char)(255 - blkNo));
            netWriteData(block, blockLen);

            crc = xmodemCrc16(block, blockLen);
            netWriteByte((unsigned char)(crc >> 8));
            netWriteByte((unsigned char)(crc & 0xFF));

            if (!xmodemReadResponse(&c, X_TIMEOUT_ACK_MS))
            {
                retry++;
                if (retry >= X_RETRY_MAX)
                {
                    netWriteByte(X_CAN);
                    fclose(fp);
                    printf("\nTimeout ACK.\n");
                    return 0;
                }
                printf("\nRetry bloco %u por timeout ACK (%d/%d)\n", blkNo, retry, X_RETRY_MAX);
                continue;
            }

            if (c == X_ACK)
                break;

            if (c == X_CAN)
            {
                fclose(fp);
                printf("\nCancelado pelo remoto.\n");
                return 0;
            }

            retry++;
            if (retry >= X_RETRY_MAX)
            {
                netWriteByte(X_CAN);
                fclose(fp);
                printf("\nMuitas tentativas.\n");
                return 0;
            }
            printf("\nRetry bloco %u por %s (%d/%d)\n", blkNo, c == X_CRC ? "CRC" : "NAK", retry, X_RETRY_MAX);
        }

        sent += blockLen;
        if (sent > total)
            sent = total;
        blkNo++;
        printProgress("Enviando", sent, total);
    }

    retry = 0;
    while (1)
    {
        if (localCanCancel())
        {
            fclose(fp);
            return 0;
        }

        netWriteByte(X_EOT);
        if (xmodemReadResponse(&c, X_TIMEOUT_ACK_MS))
        {
            if (c == X_ACK)
                break;

            if (c == X_CAN)
            {
                fclose(fp);
                printf("\nCancelado pelo remoto.\n");
                return 0;
            }
        }

        retry++;
        if (retry >= X_RETRY_MAX)
        {
            fclose(fp);
            printf("\nTimeout EOT.\n");
            return 0;
        }
    }

    fclose(fp);
    printf("\nOK enviado %ld bytes.\n", total);
    return 1;
}

static int xmodemRecvFile(const char *fileName)
{
    FILE *fp;
    unsigned char c;
    unsigned char blkNo;
    unsigned char blkInv;
    unsigned char block[X_BLOCK_1K];
    unsigned char crcHi;
    unsigned char crcLo;
    unsigned short crcRecv;
    unsigned short crcCalc;
    unsigned char expected;
    int retry;
    int blockLen;
    int i;
    long received;
    int started;

    fp = fopen(fileName, "wb");
    if (!fp)
    {
        printf("Erro criando arquivo local: %s\n", fileName);
        return 0;
    }

    expected = 1;
    retry = 0;
    received = 0;
    started = 0;

    printf("Recebendo XMODEM em %s...\n", fileName);
    while (1)
    {
        if (localCanCancel())
        {
            fclose(fp);
            return 0;
        }

        if (!started)
            netWriteByte(X_CRC);

        if (!netReadByteTimeout(&c, X_TIMEOUT_FIRST_MS))
        {
            retry++;
            if (retry >= X_RETRY_MAX)
            {
                netWriteByte(X_CAN);
                fclose(fp);
                printf("\nTimeout XMODEM.\n");
                return 0;
            }

            if (started)
                netWriteByte(X_NAK);

            continue;
        }

        retry = 0;

        if (c == X_EOT)
        {
            netWriteByte(X_ACK);
            fclose(fp);
            printf("\nOK recebido %ld bytes.\n", received);
            return 1;
        }

        if (c == X_CAN)
        {
            fclose(fp);
            printf("\nCancelado pelo remoto.\n");
            return 0;
        }

        if (c == X_SOH)
            blockLen = X_BLOCK_128;
        else if (c == X_STX)
            blockLen = X_BLOCK_1K;
        else
        {
            netWriteByte(X_NAK);
            continue;
        }

        started = 1;

        if (!netReadByteTimeout(&blkNo, X_TIMEOUT_CHAR_MS) ||
            !netReadByteTimeout(&blkInv, X_TIMEOUT_CHAR_MS))
        {
            netWriteByte(X_NAK);
            continue;
        }

        for (i = 0; i < blockLen; i++)
        {
            if (!netReadByteTimeout(&block[i], X_TIMEOUT_CHAR_MS))
            {
                netWriteByte(X_NAK);
                goto next_block;
            }
        }

        if (!netReadByteTimeout(&crcHi, X_TIMEOUT_CHAR_MS) ||
            !netReadByteTimeout(&crcLo, X_TIMEOUT_CHAR_MS))
        {
            netWriteByte(X_NAK);
            continue;
        }

        crcRecv = (((unsigned short)crcHi) << 8) | crcLo;
        crcCalc = xmodemCrc16(block, blockLen);

        if ((unsigned char)(blkNo + blkInv) != 0xFF || crcRecv != crcCalc)
        {
            netWriteByte(X_NAK);
            continue;
        }

        if (blkNo == expected)
        {
            fwrite(block, 1, blockLen, fp);
            received += blockLen;
            expected++;
            netWriteByte(X_ACK);
            printf("\rRecebendo %ld bytes", received);
            fflush(stdout);
        }
        else if (blkNo == (unsigned char)(expected - 1))
        {
            netWriteByte(X_ACK);
        }
        else
        {
            netWriteByte(X_CAN);
            fclose(fp);
            printf("\nBloco fora de ordem.\n");
            return 0;
        }

next_block:
        ;
    }
}

static void showHelp(void)
{
    printf("Comandos locais:\n");
    printf("  help\n");
    printf("  dir | pwd | ver | cd <dir>\n");
    printf("  put <arquivo-local> [arquivo-remoto]\n");
    printf("  get <arquivo-remoto> [arquivo-local]\n");
    printf("  quit\n");
    printf("Obs: put/get iniciam XMODEM-1K/CRC automaticamente.\n");
}

int main(int argc, char **argv)
{
    WSADATA wsa;
    char line[260];
    char remoteCmd[260];
    char *cmd;
    char *arg1;
    char *arg2;
    unsigned short port;

    if (argc < 2)
    {
        printf("Uso: mftpcli <host> [porta]\n");
        printf("Ex : mftpcli 192.168.0.50 23\n");
        return 1;
    }

    port = 23;
    if (argc >= 3)
        port = (unsigned short)atoi(argv[2]);

    if (WSAStartup(0x0101, &wsa) != 0)
    {
        printf("Erro inicializando WinSock.\n");
        return 1;
    }

    if (!tcpConnect(argv[1], port))
    {
        tcpClose();
        WSACleanup();
        return 1;
    }

    printf("Conectado em %s:%u.\n", argv[1], port);
    printf("Se o FTPD ja estiver rodando no 68000, vou sincronizar o prompt.\n");
    netWriteByte('\r');
    if (!waitForPromptMs(1500))
        printf("Sem prompt ainda. Rode o FTPD no 68000 e use os comandos normalmente.\n");

    while (1)
    {
        printf("\nlocal> ");
        if (!fgets(line, sizeof(line), stdin))
            break;

        splitCommand(line, &cmd, &arg1, &arg2);
        if (*cmd == 0)
            continue;

        if (strieq(cmd, "help") || strieq(cmd, "?"))
        {
            showHelp();
            continue;
        }

        if (strieq(cmd, "quit") || strieq(cmd, "exit"))
        {
            netSendLine("QUIT");
            waitForPromptMs(1500);
            break;
        }

        if (strieq(cmd, "put"))
        {
            const char *localName;
            char remoteName[180];

            if (*arg1 == 0)
            {
                printf("Uso: put <arquivo-local> [arquivo-remoto]\n");
                continue;
            }

            localName = arg1;
            copyRemoteName(remoteName, (*arg2) ? arg2 : baseName(arg1), sizeof(remoteName));
            if (!localFileExists(localName))
            {
                printf("Arquivo local nao existe: %s\n", localName);
                continue;
            }

            sprintf(remoteCmd, "PUT %s", remoteName);
            drainNetwork(100);
            netSendLine(remoteCmd);
            if (!waitForXferReady() || !xmodemSendFile(localName))
                netWriteByte(X_CAN);
            waitForPromptAfterXfer();
            continue;
        }

        if (strieq(cmd, "get"))
        {
            char remoteName[180];
            const char *localName;

            if (*arg1 == 0)
            {
                printf("Uso: get <arquivo-remoto> [arquivo-local]\n");
                continue;
            }

            copyRemoteName(remoteName, arg1, sizeof(remoteName));
            localName = (*arg2) ? arg2 : baseName(remoteName);
            sprintf(remoteCmd, "GET %s", remoteName);
            drainNetwork(100);
            netSendLine(remoteCmd);
            if (!waitForXferReady() || !xmodemRecvFile(localName))
                netWriteByte(X_CAN);
            waitForPromptAfterXfer();
            continue;
        }

        if (strieq(cmd, "dir"))
            strcpy(remoteCmd, "DIR");
        else if (strieq(cmd, "pwd"))
            strcpy(remoteCmd, "PWD");
        else if (strieq(cmd, "ver"))
            strcpy(remoteCmd, "VER");
        else if (strieq(cmd, "cd"))
        {
            if (*arg1 == 0)
            {
                printf("Uso: cd <dir>\n");
                continue;
            }
            sprintf(remoteCmd, "CD %s", arg1);
        }
        else
        {
            printf("Comando desconhecido. Use help.\n");
            continue;
        }

        drainNetwork(100);
        netSendLine(remoteCmd);
        waitForPrompt();
    }

    tcpClose();
    WSACleanup();
    return 0;
}
