#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
#include "bbsmmsj.h"

#define TEL_IAC  255
#define TEL_DONT 254
#define TEL_DO   253
#define TEL_WONT 252
#define TEL_WILL 251
#define TEL_SB   250
#define TEL_SE   240

#define BBS_WAIT_REMOTE 800000L
#define BBS_WAIT_CHAR   120000L
#define BBS_IDLE_TIMEOUT_SECONDS 60UL
#define BBS_IDLE_TIMEOUT_LOOPS   (BBS_IDLE_TIMEOUT_SECONDS * 1000UL)

#define BBS_READ_ABORT   -1
#define BBS_READ_TIMEOUT -2
#define BBS_USERS_FILE   "/NETWRK/BBSUSER.TXT"
#define BBS_USERS_MAX    16
#define BBS_USERS_BUF    2048
#define BBS_MSG_DIR      "/NETWRK/MSGS"
#define BBS_MSG_BUF      4096
#define BBS_MSG_MAX_LIST 20

static char bbsUsers[BBS_USERS_MAX][BBS_USER_MAX + 1];
static char bbsPasses[BBS_USERS_MAX][BBS_PASS_MAX + 1];
static unsigned char bbsUserCount = 0;
static unsigned char bbsMsgBuf[BBS_MSG_BUF + 1];
static unsigned long bbsLoopTicks = 0;
static unsigned char bbsPendingByte = 0;
static unsigned char bbsPendingValid = 0;
static unsigned char bbsIgnoreNextLf = 0;

static void bbsPutc(unsigned char c)
{
    writeSerial(c);
}

static void bbsPuts(char *s)
{
    while (*s)
        bbsPutc((unsigned char)*s++);
}

static void bbsCrLf(void)
{
    bbsPuts("\r\n");
}

static void bbsAnsiClear(void)
{
    bbsPuts("\x1B[2J\x1B[H");
}

static void bbsAnsiNormal(void)
{
    bbsPuts("\x1B[0m");
}

static void bbsAnsiBright(void)
{
    bbsPuts("\x1B[1m");
}

/*
0  preto
1  vermelho
2  verde
3  amarelo / marrom
4  azul
5  magenta
6  ciano
7  branco / cinza claro
8  cinza escuro
9  vermelho claro
10 verde claro
11 amarelo claro
12 azul claro
13 magenta claro
14 ciano claro
15 branco brilhante
*/
static void bbsAnsiColor(unsigned char type, unsigned char color)
{
    unsigned char code;

    color &= 15;

    if (type)
        code = (color < 8) ? (40 + color) : (100 + (color - 8));
    else
        code = (color < 8) ? (30 + color) : (90 + (color - 8));

    bbsPuts("\x1B[");
    if (code >= 100) {
        bbsPutc((unsigned char)('0' + (code / 100)));
        code %= 100;
    }
    bbsPutc((unsigned char)('0' + (code / 10)));
    bbsPutc((unsigned char)('0' + (code % 10)));
    bbsPutc('m');
}

static unsigned char bbsLocalAbort(void)
{
    MMSJ_KEYEVENT k;

    if (!mmsjKeyGet(&k))
        return 0;

    if (k.flags == KEY_CTRL_ALT && k.code == 'X')
        return 1;

    return 0;
}

static unsigned char bbsGetSerial(unsigned char *c)
{
    bbsLoopTicks++;
    return netCommGet(c);
}

static void bbsTelReply(unsigned char cmd, unsigned char opt)
{
    bbsPutc(TEL_IAC);
    bbsPutc(cmd);
    bbsPutc(opt);
}

static void bbsTelnetInit(void)
{
    bbsTelReply(TEL_WILL, 1); /* ECHO */
    bbsTelReply(TEL_WILL, 3); /* SUPPRESS-GO-AHEAD */
    bbsTelReply(TEL_DO, 3);   /* SUPPRESS-GO-AHEAD */
}

static unsigned char bbsReadRemoteByte(unsigned char *out)
{
    unsigned char c;
    unsigned char cmd;
    unsigned char opt;

    if (bbsPendingValid) {
        *out = bbsPendingByte;
        bbsPendingValid = 0;
        return 1;
    }

    if (!bbsGetSerial(&c))
        return 0;

    if (c != TEL_IAC) {
        *out = c;
        return 1;
    }

    while (!bbsGetSerial(&cmd)) {
        if (bbsLocalAbort())
            return 0;
    }

    if (cmd == TEL_IAC) {
        *out = TEL_IAC;
        return 1;
    }

    if (cmd == TEL_DO || cmd == TEL_DONT || cmd == TEL_WILL || cmd == TEL_WONT) {
        while (!bbsGetSerial(&opt)) {
            if (bbsLocalAbort())
                return 0;
        }

        if (cmd == TEL_DO)
            bbsTelReply(TEL_WONT, opt);
        else if (cmd == TEL_WILL)
            bbsTelReply(TEL_DONT, opt);

        return 0;
    }

    if (cmd == TEL_SB) {
        while (1) {
            while (!bbsGetSerial(&c)) {
                if (bbsLocalAbort())
                    return 0;
            }
            if (c == TEL_IAC) {
                while (!bbsGetSerial(&cmd)) {
                    if (bbsLocalAbort())
                        return 0;
                }
                if (cmd == TEL_SE)
                    break;
            }
        }
    }

    return 0;
}

static void bbsUnreadRemoteByte(unsigned char c)
{
    bbsPendingByte = c;
    bbsPendingValid = 1;
}

static int bbsReadLine(char *buf, int maxLen, unsigned char password)
{
    int pos;
    unsigned char c;
    unsigned long idleLoops;

    pos = 0;
    buf[0] = 0;
    idleLoops = 0;

    while (1) {
        if (bbsLocalAbort())
            return BBS_READ_ABORT;

        if (!bbsReadRemoteByte(&c)) {
            delayms(1);
            idleLoops++;
            if (idleLoops >= BBS_IDLE_TIMEOUT_LOOPS)
                return BBS_READ_TIMEOUT;
            continue;
        }

        idleLoops = 0;

        if (bbsIgnoreNextLf && c == '\n') {
            bbsIgnoreNextLf = 0;
            continue;
        }
        bbsIgnoreNextLf = 0;

        if (c == '\n' && pos == 0)
            continue;

        if (c == '\r' || c == '\n') {
            buf[pos] = 0;
            bbsCrLf();

            if (c == '\r')
                bbsIgnoreNextLf = 1;

            return pos;
        }

        if (c == 8 || c == 127) {
            if (pos > 0) {
                pos--;
                bbsPuts("\b \b");
            }
            continue;
        }

        if (c >= 32 && c <= 126) {
            if (pos < maxLen - 1) {
                buf[pos++] = (char)c;
                if (password)
                    bbsPutc('*');
                else
                    bbsPutc(c);
            }
        }
    }
}

static int bbsReadMenuKey(void)
{
    unsigned char c;
    unsigned char key;
    unsigned long idleLoops;
    unsigned int drainLoops;

    idleLoops = 0;

    while (1) {
        if (bbsLocalAbort())
            return BBS_READ_ABORT;

        if (!bbsReadRemoteByte(&c)) {
            delayms(1);
            idleLoops++;
            if (idleLoops >= BBS_IDLE_TIMEOUT_LOOPS)
                return BBS_READ_TIMEOUT;
            continue;
        }

        idleLoops = 0;

        if (bbsIgnoreNextLf && c == '\n') {
            bbsIgnoreNextLf = 0;
            continue;
        }
        bbsIgnoreNextLf = 0;

        if (c == '\r') {
            bbsIgnoreNextLf = 1;
            continue;
        }

        if (c == '\n')
            continue;

        if (c >= 'a' && c <= 'z')
            c -= 32;

        if (c >= 32 && c <= 126) {
            key = c;
            bbsPutc(key);
            bbsCrLf();

            drainLoops = 0;
            while (drainLoops < 80) {
                if (!bbsReadRemoteByte(&c)) {
                    delayms(1);
                    drainLoops++;
                    continue;
                }
                if (c == '\r') {
                    bbsIgnoreNextLf = 1;
                    drainLoops = 0;
                    continue;
                }
                if (c == '\n') {
                    bbsIgnoreNextLf = 0;
                    break;
                }
            }

            return key;
        }
    }
}

static char bbsUpperChar(char c)
{
    if (c >= 'a' && c <= 'z')
        return c - 32;
    return c;
}

static int bbsStrEqNoCase(char *a, char *b)
{
    while (*a && *b) {
        if (bbsUpperChar(*a) != bbsUpperChar(*b))
            return 0;
        a++;
        b++;
    }

    return *a == 0 && *b == 0;
}

static void bbsCopyUpper(char *dst, char *src, int maxLen)
{
    int i;

    i = 0;
    while (src[i] && i < maxLen - 1) {
        dst[i] = bbsUpperChar(src[i]);
        i++;
    }
    dst[i] = 0;
}

static int bbsFindUser(char *user)
{
    int i;

    for (i = 0; i < bbsUserCount; i++) {
        if (bbsStrEqNoCase(user, bbsUsers[i]))
            return i;
    }

    return -1;
}

static unsigned char bbsUserExists(char *user)
{
    if (bbsStrEqNoCase(user, "ADMIN"))
        return 1;

    return bbsFindUser(user) >= 0;
}

static unsigned char bbsAddUser(char *user, char *pass)
{
    if (bbsUserCount >= BBS_USERS_MAX)
        return 0;

    if (bbsFindUser(user) >= 0)
        return 0;

    bbsCopyUpper(bbsUsers[bbsUserCount], user, BBS_USER_MAX + 1);
    strncpy(bbsPasses[bbsUserCount], pass, BBS_PASS_MAX);
    bbsPasses[bbsUserCount][BBS_PASS_MAX] = 0;
    bbsUserCount++;

    return 1;
}

static void bbsAppendChar(unsigned char *buf, unsigned short *pos, unsigned short max, unsigned char c)
{
    if (*pos < max) {
        buf[*pos] = c;
        *pos = *pos + 1;
        buf[*pos] = 0;
    }
}

static void bbsAppendStr(unsigned char *buf, unsigned short *pos, unsigned short max, char *s)
{
    while (*s && *pos < max)
        bbsAppendChar(buf, pos, max, (unsigned char)*s++);
}

static void bbsMakeMsgName(unsigned short num, char *out)
{
    out[0] = (char)('0' + ((num / 100000) % 10));
    out[1] = (char)('0' + ((num / 10000) % 10));
    out[2] = (char)('0' + ((num / 1000) % 10));
    out[3] = (char)('0' + ((num / 100) % 10));
    out[4] = (char)('0' + ((num / 10) % 10));
    out[5] = (char)('0' + (num % 10));
    out[6] = '.';
    out[7] = 'M';
    out[8] = 'S';
    out[9] = 'G';
    out[10] = 0;
}

static void bbsMakeMsgPath(unsigned short num, char *out)
{
    char name[12];

    bbsMakeMsgName(num, name);
    strcpy(out, BBS_MSG_DIR);
    strcat(out, "/");
    strcat(out, name);
}

static unsigned short bbsMsgNumFromDir(FILES_DIR *dir)
{
    unsigned short num;
    unsigned char ix;

    if (dir->Ext[0] != 'M' || dir->Ext[1] != 'S' || dir->Ext[2] != 'G')
        return 0;

    num = 0;
    for (ix = 0; ix < 6; ix++) {
        if (dir->Name[ix] < '0' || dir->Name[ix] > '9')
            return 0;
        num = (unsigned short)(num * 10 + (dir->Name[ix] - '0'));
    }

    return num;
}

static unsigned short bbsNextMsgNumber(void)
{
    FILES_DIR *pDir;
    unsigned char ix;
    unsigned short num;
    unsigned short maxNum;

    fsMakeDir(BBS_MSG_DIR);

    pDir = (FILES_DIR*)msmalloc(sizeof(FILES_DIR) * 128);
    if (!pDir)
        return 0;

    fsListDir(pDir, BBS_MSG_DIR);
    ix = 0;
    maxNum = 0;

    while (pDir[ix].Name[0] != 0) {
        num = bbsMsgNumFromDir(&pDir[ix]);
        if (num > maxNum)
            maxNum = num;
        ix++;
    }

    msfree(pDir);
    return (unsigned short)(maxNum + 1);
}

static unsigned char bbsHeaderEquals(char *msg, char *header, char *value)
{
    unsigned short hlen;
    unsigned short vlen;

    hlen = (unsigned short)strlen(header);
    vlen = (unsigned short)strlen(value);

    while (*msg) {
        if (!strncmp(msg, header, hlen)) {
            msg += hlen;
            while (*msg == ' ')
                msg++;
            return strncmp(msg, value, vlen) == 0 &&
                   (msg[vlen] == '\r' || msg[vlen] == '\n' || msg[vlen] == 0);
        }

        while (*msg && *msg != '\n')
            msg++;
        if (*msg == '\n')
            msg++;
    }

    return 0;
}

static void bbsHeaderCopy(char *msg, char *header, char *out, unsigned char maxLen)
{
    unsigned short hlen;
    unsigned char pos;

    out[0] = 0;
    hlen = (unsigned short)strlen(header);

    while (*msg) {
        if (!strncmp(msg, header, hlen)) {
            msg += hlen;
            while (*msg == ' ')
                msg++;

            pos = 0;
            while (*msg && *msg != '\r' && *msg != '\n' && pos < maxLen - 1)
                out[pos++] = *msg++;
            out[pos] = 0;
            return;
        }

        while (*msg && *msg != '\n')
            msg++;
        if (*msg == '\n')
            msg++;
    }
}

static unsigned char bbsLoadMsg(unsigned short num)
{
    char path[32];
    unsigned long size;

    bbsMakeMsgPath(num, path);
    size = fsInfoFile(path, INFO_SIZE);
    if (size == 0 || size >= ERRO_D_START || size > BBS_MSG_BUF)
        return 0;

    size = loadFile((unsigned char *)path, bbsMsgBuf);
    if (size == 0 || size >= ERRO_D_START || size > BBS_MSG_BUF)
        return 0;

    bbsMsgBuf[size] = 0;
    return 1;
}

static unsigned char bbsMsgIsToUser(unsigned short num, char *user)
{
    if (!bbsLoadMsg(num))
        return 0;

    return bbsHeaderEquals((char *)bbsMsgBuf, "To:", user);
}

static unsigned char bbsMsgIsUnreadToUser(unsigned short num, char *user)
{
    if (!bbsLoadMsg(num))
        return 0;

    return bbsHeaderEquals((char *)bbsMsgBuf, "To:", user) &&
           bbsHeaderEquals((char *)bbsMsgBuf, "Lido:", "Nao");
}

static void bbsMarkMsgRead(unsigned short num)
{
    char path[32];
    char *p;

    if (!bbsLoadMsg(num))
        return;

    p = (char *)bbsMsgBuf;
    while (*p && strncmp(p, "Lido: Nao", 9))
        p++;

    if (*p) {
        p[6] = 'S';
        p[7] = 'i';
        p[8] = 'm';
        bbsMakeMsgPath(num, path);
        saveFile((unsigned char *)path, bbsMsgBuf, (unsigned long)strlen((char *)bbsMsgBuf));
    }
}

static unsigned char bbsSaveUsers(void)
{
    static unsigned char buf[BBS_USERS_BUF];
    unsigned short pos;
    unsigned short len;
    unsigned char i;

    pos = 0;

    for (i = 0; i < bbsUserCount; i++) {
        len = (unsigned short)strlen(bbsUsers[i]);
        if (pos + len + 1 >= BBS_USERS_BUF)
            return 0;
        memcpy(buf + pos, bbsUsers[i], len);
        pos += len;
        buf[pos++] = ',';

        len = (unsigned short)strlen(bbsPasses[i]);
        if (pos + len + 2 >= BBS_USERS_BUF)
            return 0;
        memcpy(buf + pos, bbsPasses[i], len);
        pos += len;
        buf[pos++] = '\r';
        buf[pos++] = '\n';
    }

    return saveFile((unsigned char *)BBS_USERS_FILE, buf, (unsigned long)pos) == RETURN_OK;
}

static void bbsLoadUsers(void)
{
    static unsigned char buf[BBS_USERS_BUF + 1];
    unsigned long size;
    unsigned short i;
    unsigned short upos;
    unsigned short ppos;
    char user[BBS_USER_MAX + 1];
    char pass[BBS_PASS_MAX + 1];
    unsigned char inPass;

    bbsUserCount = 0;

    size = fsInfoFile(BBS_USERS_FILE, INFO_SIZE);
    if (size == 0 || size >= ERRO_D_START || size > BBS_USERS_BUF)
        return;

    size = loadFile((unsigned char *)BBS_USERS_FILE, buf);
    if (size == 0 || size >= ERRO_D_START || size > BBS_USERS_BUF)
        return;

    buf[size] = 0;

    upos = 0;
    ppos = 0;
    inPass = 0;
    user[0] = 0;
    pass[0] = 0;

    for (i = 0; i <= size; i++) {
        if (buf[i] == ',' && !inPass) {
            user[upos] = 0;
            inPass = 1;
            continue;
        }

        if (buf[i] == '\r' || buf[i] == '\n' || buf[i] == 0) {
            pass[ppos] = 0;
            if (user[0] && pass[0])
                bbsAddUser(user, pass);
            upos = 0;
            ppos = 0;
            inPass = 0;
            user[0] = 0;
            pass[0] = 0;
            continue;
        }

        if (inPass) {
            if (ppos < BBS_PASS_MAX)
                pass[ppos++] = (char)buf[i];
        } else {
            if (upos < BBS_USER_MAX)
                user[upos++] = bbsUpperChar((char)buf[i]);
        }
    }
}

static void bbsAppendDec(char *dst, unsigned long value)
{
    char tmp[16];
    int i;
    int p;

    if (value == 0) {
        strcat(dst, "0");
        return;
    }

    p = 0;
    while (value > 0 && p < 15) {
        tmp[p++] = (char)('0' + (value % 10));
        value = value / 10;
    }

    for (i = p - 1; i >= 0; i--)
        strncat(dst, &tmp[i], 1);
}

static void bbsPrintDec(unsigned long value)
{
    char tmp[16];

    tmp[0] = 0;
    bbsAppendDec(tmp, value);
    bbsPuts(tmp);
}

static void bbsAppend2(char *dst, int value)
{
    if (value < 0)
        value = 0;
    if (value > 99)
        value = value % 100;

    dst[0] = (char)('0' + (value / 10));
    dst[1] = (char)('0' + (value % 10));
    dst[2] = 0;
}

static void bbsFormatMsgDate(char *out)
{
    strcpy(out, "00/00/00 00:00");
}

static void bbsFormatUptime(char *out)
{
    unsigned long seconds;
    unsigned long days;
    unsigned long hours;
    unsigned long mins;
    char s[64];

    seconds = bbsLoopTicks / 750;

    days = seconds / 86400UL;
    hours = (seconds / 3600UL) % 24UL;
    mins = (seconds / 60UL) % 60UL;

    s[0] = 0;
    bbsAppendDec(s, days);
    strcat(s, "d ");
    if (hours < 10)
        strcat(s, "0");
    bbsAppendDec(s, hours);
    strcat(s, "h ");
    if (mins < 10)
        strcat(s, "0");
    bbsAppendDec(s, mins);
    strcat(s, "m");
    strcpy(out, s);
}

static unsigned char bbsReadResponseLine(char *line)
{
    unsigned char c;
    int pos;
    unsigned long timeout;

    pos = 0;
    line[0] = 0;
    timeout = BBS_WAIT_REMOTE;

    while (1) {
        if (bbsLocalAbort())
            return 0;

        if (!netCommWait(&c, timeout))
            return 0;

        if (c == '\r')
            continue;

        if (c == '\n' || c == 0x04) {
            if (pos == 0)
                continue;
            line[pos] = 0;
            return 1;
        }

        if (pos < BBS_LINE_MAX - 1)
            line[pos++] = (char)c;

        timeout = BBS_WAIT_CHAR;
    }
}

static unsigned char bbsWaitAtOk(void)
{
    char line[BBS_LINE_MAX];

    while (bbsReadResponseLine(line)) {
        if (strncmp(line, "OK", 2) == 0)
            return 1;
        if (strncmp(line, "ERR", 3) == 0)
            return 0;
    }

    return 0;
}

static void bbsReadAtResponse(char *out)
{
    char line[BBS_LINE_MAX];

    out[0] = 0;

    while (bbsReadResponseLine(line)) {
        if (!strncmp(line, "OK;", 3) || !strncmp(line, "ERR;", 4) || !strncmp(line, "ERROR", 5)) {
            strcpy(out, line);
            return;
        }
    }
}

static unsigned char bbsEnableListen(void)
{
    char resp[BBS_LINE_MAX];
    unsigned char listenOn;
    long timeout;

    printText("BBS: enabling network...\r\n");

    netCommEnable();
    netCommResetInput();

    writeLongSerial("+++");
    writeSerial('\r');
    delayms(50);
    netCommResetInput();

    writeLongSerial("ATRESETTCP");
    writeSerial('\r');
    bbsWaitAtOk();
    delayms(50);

    listenOn = 0;
    timeout = 8;

    printText("BBS: enabling listen...\r\n");
    while (timeout--) {
        netCommResetInput();
        writeLongSerial("ATLISTEN?");
        writeSerial('\r');

        bbsReadAtResponse(resp);
        printText("BBS ATLISTEN?: ");
        printText(resp);
        printText("\r\n");

        if (!strncmp(resp, "OK;OFF;NOETH", 12) || !strncmp(resp, "ERR;NOETH", 9))
            break;

        if (!strncmp(resp, "OK;LISTEN", 9)) {
            listenOn = 1;
            break;
        }

        if (!strncmp(resp, "OK;OFF", 6)) {
            netCommResetInput();
            writeLongSerial("ATLISTEN");
            writeSerial('\r');
            bbsReadAtResponse(resp);
            printText("BBS ATLISTEN : ");
            printText(resp);
            printText("\r\n");

            if (!strncmp(resp, "OK;LISTEN", 9)) {
                listenOn = 1;
                break;
            }

            if (!strncmp(resp, "OK;", 3) &&
                strncmp(resp, "OK;OFF;NOETH", 12)) {
                listenOn = 1;
                break;
            }

            delayms(50);
        }
    }

    if (listenOn)
        printText("BBS: telnet listener ready.\r\n");
    else
        printText("BBS: unable to enable listener.\r\n");

    netCommResetInput();
    return listenOn;
}

static unsigned char bbsResetSessionAndListen(void)
{
    printText("BBS: resetting caller session...\r\n");

    netCommResetInput();
    writeLongSerial("+++");
    writeSerial('\r');
    delayms(80);
    netCommResetInput();

    writeLongSerial("ATRESETTCP");
    writeSerial('\r');
    bbsWaitAtOk();
    delayms(80);

    return bbsEnableListen();
}

static int bbsPause(void)
{
    char tmp[4];

    bbsCrLf();
    bbsPuts("Press ENTER to continue...");
    return bbsReadLine(tmp, sizeof(tmp), 0);
}

static void bbsWelcomeScreen(void)
{
    char up[32];

    bbsFormatUptime(up);

    bbsAnsiClear();
    bbsAnsiNormal();
    bbsAnsiBright();
    bbsAnsiColor(0, 3);
    bbsPuts("Welcome to MMSJ-BBS ONLINE\r\n");
    bbsPuts("MMC-320, a Homebrew Computer like 80s\r\n\r\n");
    bbsAnsiNormal();
    bbsAnsiColor(0, 6);
    bbsPuts("SERVER NAME: MMSJ BBS\r\n");
    bbsPuts("       ADDR: mmc320.ddns.net\r\n");
    bbsPuts("       NODE: 1 (of 1)\r\n");
    bbsPuts("       ADMN: Moahrs\r\n");
    bbsPuts("   LOCATION: Brazil\r\n");
    bbsPuts("     UPTIME: ");
    bbsPuts(up);
    bbsAnsiNormal();
    bbsPuts("\r\n\r\n");
    bbsPuts("Connections through TELNET protocol are\r\n");
    bbsPuts("NOT secured or encrypted.\r\n");
    bbsPuts("D'ont use BBS passwd for other services.\r\n\r\n");
    bbsPuts("Enter User Name or 'New'\r\n");
 }

static int bbsWaitCaller(void)
{
    unsigned char c;

    printText("BBS: waiting caller. Press ENTER from telnet if screen is blank.\r\n");

    while (1) {
        if (bbsLocalAbort())
            return -1;

        if (bbsReadRemoteByte(&c)) {
            if (c != '\r' && c != '\n')
                bbsUnreadRemoteByte(c);
            return 1;
        }

        delayms(1);
    }
}

static unsigned char bbsKnownUser(char *user, char *pass)
{
    int ix;

    if (bbsStrEqNoCase(user, "ADMIN") && strcmp(pass, "zilog80") == 0)
        return 1;

    ix = bbsFindUser(user);
    if (ix >= 0 && strcmp(pass, bbsPasses[ix]) == 0)
        return 1;

    return 0;
}

static int bbsLogin(char *currentUser)
{
    char user[BBS_USER_MAX + 1];
    char pass[BBS_PASS_MAX + 1];
    int len;

    while (1) {
        bbsWelcomeScreen();
        bbsPuts("Login: ");

        len = bbsReadLine(user, sizeof(user), 0);
        if (len < 0)
            return len;

        if (len == 0)
            continue;

        if (bbsStrEqNoCase(user, "NEW")) {
            bbsPuts("New user name: ");
            len = bbsReadLine(user, sizeof(user), 0);
            if (len < 0)
                return len;
            if (len == 0)
                continue;

            if (bbsStrEqNoCase(user, "ADMIN") || bbsFindUser(user) >= 0) {
                bbsPuts("User already exists.");
                bbsCrLf();
                delayms(80);
                continue;
            }

            bbsPuts("New password : ");
            len = bbsReadLine(pass, sizeof(pass), 1);
            if (len < 0)
                return len;
            if (len == 0)
                continue;

            if (!bbsAddUser(user, pass) || !bbsSaveUsers()) {
                bbsPuts("Unable to save user file.");
                bbsCrLf();
                delayms(80);
                if (bbsUserCount > 0)
                    bbsUserCount--;
                continue;
            }

            strcpy(currentUser, bbsUsers[bbsUserCount - 1]);
            bbsCrLf();
            bbsPuts("User created. Welcome to MMSJ BBS.");
            bbsCrLf();
            delayms(80);
            return 1;
        }

        bbsPuts("Password: ");
        len = bbsReadLine(pass, sizeof(pass), 1);
        if (len < 0)
            return len;

        if (bbsKnownUser(user, pass)) {
            bbsCopyUpper(currentUser, user, BBS_USER_MAX + 1);
            return 1;
        }

        bbsCrLf();
        bbsPuts("Invalid user or password.");
        bbsCrLf();
        delayms(120);
    }
}

static void bbsShowMenu(char *currentUser)
{
    char up[32];

    bbsFormatUptime(up);
    bbsAnsiClear();
    bbsAnsiColor(0, 4);
    bbsPuts("█   █ █   █  ██  ████    ███  ███   ██ \r\n");
    bbsPuts("██ ██ ██ ██ █  █    █    █  █ █  █ █  █\r\n");
    bbsPuts("█ █ █ █ █ █ █       █ ██ █  █ █  █ █   \r\n");
    bbsPuts("█   █ █   █  ██     █    ███  ███   ██ \r\n");
    bbsPuts("█   █ █   █    █    █    █  █ █  █    █\r\n");
    bbsPuts("█   █ █   █ █  █ █  █    █  █ █  █ █  █\r\n");
    bbsPuts("█   █ █   █  ██   ██     ███  ███   ██ \r\n\r\n");
    bbsAnsiColor(1, 4);
    bbsPuts("                                        \r\n\r\n");
    bbsAnsiNormal();
    bbsAnsiColor(0, 3);
    bbsPuts("┌─┐                ┌─┐\r\n");
    bbsPuts("│1│");
    bbsAnsiNormal();
    bbsPuts(" Messages       ");
    bbsAnsiColor(0, 3);
    bbsPuts("");
    bbsPuts("│2│");
    bbsAnsiNormal();
    bbsPuts(" Files\r\n");
    bbsAnsiColor(0, 3);
    bbsPuts("│ │                │ │\r\n");
    bbsPuts("│3│");
    bbsAnsiNormal();
    bbsPuts(" Online Users   ");
    bbsAnsiColor(0, 3);
    bbsPuts("│4│");
    bbsAnsiNormal();
    bbsPuts(" System Info\r\n");
    bbsPuts("└─┘                └─┘\r\n");
    bbsAnsiColor(0, 3);
    bbsPuts("┌─┐\r\n");
    bbsPuts("│5│");
    bbsAnsiNormal();
    bbsPuts(" Logout\r\n");
    bbsPuts("└─┘\r\n");
    bbsPuts("────────────────────────────────────────\r\n");
    bbsAnsiColor(1, 4);
    bbsAnsiColor(0, 7);
    bbsPuts(" Select 1-5");
    bbsAnsiNormal();
    bbsPuts(":");
}

static int bbsCreateMessage(char *currentUser)
{
    char to[BBS_USER_MAX + 1];
    char subject[41];
    char line[81];
    char date[20];
    char path[32];
    unsigned short msgNum;
    unsigned short pos;
    int len;

    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│            New Message               │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiNormal();

    bbsPuts("To: ");
    len = bbsReadLine(to, sizeof(to), 0);
    if (len < 0)
        return len;
    if (len == 0)
        return 0;

    bbsCopyUpper(to, to, sizeof(to));
    if (!bbsUserExists(to)) {
        bbsPuts("User not found.");
        bbsCrLf();
        return bbsPause();
    }

    bbsPuts("Subject: ");
    len = bbsReadLine(subject, sizeof(subject), 0);
    if (len < 0)
        return len;

    msgNum = bbsNextMsgNumber();
    if (msgNum == 0) {
        bbsPuts("Unable to create message number.");
        bbsCrLf();
        return bbsPause();
    }

    bbsFormatMsgDate(date);
    pos = 0;
    bbsMsgBuf[0] = 0;
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, "From: ");
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, currentUser);
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, "\r\nTo: ");
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, to);
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, "\r\nSubject: ");
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, subject);
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, "\r\nDate: ");
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, date);
    bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, "\r\nLido: Nao\r\n\r\n");

    bbsPuts("\r\nType message. Single '.' line ends.\r\n\r\n");

    while (1) {
        len = bbsReadLine(line, sizeof(line), 0);
        if (len < 0)
            return len;
        if (strcmp(line, ".") == 0)
            break;

        bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, line);
        bbsAppendStr(bbsMsgBuf, &pos, BBS_MSG_BUF, "\r\n");

        if (pos >= BBS_MSG_BUF - 82) {
            bbsPuts("Message buffer full.");
            bbsCrLf();
            break;
        }
    }

    bbsMakeMsgPath(msgNum, path);
    if (saveFile((unsigned char *)path, bbsMsgBuf, (unsigned long)strlen((char *)bbsMsgBuf)) != RETURN_OK) {
        bbsPuts("Unable to save message.");
        bbsCrLf();
        return bbsPause();
    }

    bbsPuts("\r\nMessage saved as ");
    bbsPuts(path);
    bbsCrLf();
    return bbsPause();
}

static int bbsReadMessages(char *currentUser)
{
    FILES_DIR *pDir;
    unsigned short nums[BBS_MSG_MAX_LIST];
    unsigned char count;
    unsigned char ix;
    unsigned short num;
    char answer[8];
    char from[18];
    char subject[42];
    int len;
    int choice;

    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│            My Messages               │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiNormal();

    pDir = (FILES_DIR*)msmalloc(sizeof(FILES_DIR) * 128);
    if (!pDir) {
        bbsPuts("Out of memory.");
        bbsCrLf();
        return bbsPause();
    }

    fsMakeDir(BBS_MSG_DIR);
    fsListDir(pDir, BBS_MSG_DIR);

    ix = 0;
    count = 0;
    while (pDir[ix].Name[0] != 0 && count < BBS_MSG_MAX_LIST) {
        num = bbsMsgNumFromDir(&pDir[ix]);
        if (num && bbsMsgIsToUser(num, currentUser)) {
            nums[count] = num;
            bbsPrintDec((unsigned long)count + 1UL);
            bbsPuts(") ");
            bbsPuts(pDir[ix].Name);
            bbsPuts(".");
            bbsPuts(pDir[ix].Ext);
            bbsPuts(" ");

            bbsHeaderCopy((char *)bbsMsgBuf, "From:", from, sizeof(from));
            bbsHeaderCopy((char *)bbsMsgBuf, "Subject:", subject, sizeof(subject));
            bbsPuts(from);
            bbsPuts(" - ");
            bbsPuts(subject);
            if (bbsHeaderEquals((char *)bbsMsgBuf, "Lido:", "Nao"))
                bbsPuts(" *");
            bbsCrLf();
            count++;
        }
        ix++;
    }

    msfree(pDir);

    if (count == 0) {
        bbsPuts("No messages for you.");
        bbsCrLf();
        return bbsPause();
    }

    bbsPuts("\r\nRead number (0 back): ");
    len = bbsReadLine(answer, sizeof(answer), 0);
    if (len < 0)
        return len;

    choice = atoi(answer);
    if (choice <= 0 || choice > count)
        return 0;

    num = nums[choice - 1];
    if (!bbsLoadMsg(num)) {
        bbsPuts("Unable to load message.");
        bbsCrLf();
        return bbsPause();
    }

    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("Message ");
    bbsPrintDec(num);
    bbsPuts("\r\n────────────────────────────────────────\r\n");
    bbsAnsiNormal();
    bbsPuts((char *)bbsMsgBuf);
    bbsCrLf();
    bbsMarkMsgRead(num);
    return bbsPause();
}

static int bbsMessages(char *currentUser)
{
    int sel;
    int st;

    while (1) {
        bbsAnsiClear();
        bbsAnsiColor(0, 3);
        bbsPuts("┌──────────────────────────────────────┐\r\n");
        bbsPuts("│              Messages                │\r\n");
        bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
        bbsAnsiNormal();
        bbsPuts("┌─┐\r\n");
        bbsPuts("│C│ Create message\r\n");
        bbsPuts("│ │\r\n");
        bbsPuts("│R│ Read messages\r\n");
        bbsPuts("│ │\r\n");
        bbsPuts("│Q│ Back\r\n\r\n:");
        bbsPuts("└─┘\r\n");

        sel = bbsReadMenuKey();
        if (sel < 0)
            return sel;

        if (sel == 'C') {
            st = bbsCreateMessage(currentUser);
            if (st < 0)
                return st;
        } else if (sel == 'R') {
            st = bbsReadMessages(currentUser);
            if (st < 0)
                return st;
        } else if (sel == 'Q') {
            return 0;
        }
    }
}

static unsigned char bbsUnreadCount(char *currentUser)
{
    FILES_DIR *pDir;
    unsigned char ix;
    unsigned char count;
    unsigned short num;

    fsMakeDir(BBS_MSG_DIR);

    pDir = (FILES_DIR*)msmalloc(sizeof(FILES_DIR) * 128);
    if (!pDir)
        return 0;

    fsListDir(pDir, BBS_MSG_DIR);
    ix = 0;
    count = 0;

    while (pDir[ix].Name[0] != 0) {
        num = bbsMsgNumFromDir(&pDir[ix]);
        if (num && bbsMsgIsUnreadToUser(num, currentUser))
            count++;
        ix++;
    }

    msfree(pDir);
    return count;
}

static int bbsShowUnreadNotice(char *currentUser)
{
    unsigned char count;

    count = bbsUnreadCount(currentUser);
    if (count == 0)
        return 0;

    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│              Mailbox                 │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiNormal();
    bbsPuts("You have ");
    bbsPrintDec(count);
    bbsPuts(" unread message(s).\r\n");
    bbsPuts("Use Messages / Read to open them.\r\n");
    return bbsPause();
}

static int bbsMessagesOld(void)
{
    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│              Messages                │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiNormal();
    bbsPuts("Message area is not implemented yet.");
    bbsCrLf();
    return bbsPause();
}

/*
  Today:
     3 files per row
     14 rows

  future:
     Can choice file for download, typing the name, and using xmodem crc
*/
static int bbsFiles(void)
{
    char pNameFile[13];
    FILES_DIR *pDir;
    char ixr = 0, ixc = 0, ix;
    char ixn;
    unsigned char fileCount;

    bbsAnsiClear();
    bbsAnsiColor(0, 3);     // FG Amarelo
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│                Files                 │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiColor(0, 15);    // FG Branco
    bbsAnsiColor(1, 12);    // BG Azul Claro
    bbsPuts("/DOWNLOAD ─────────────────────────────\r\n");
    bbsAnsiNormal();

    pDir = (FILES_DIR*)msmalloc(sizeof(FILES_DIR) * 128);

    if (pDir != 0)
    {
        fsListDir(pDir, "/DOWNLOAD");
        ix = 0;
        fileCount = 0;

        while (pDir[ix].Name[0] != 0)
        {
            if (pDir[ix].Attr[1] != 'V' && pDir[ix].Attr[1] != 'D')
            {
                strcpy(pNameFile, pDir[ix].Name);

                if (pDir[ix].Ext[0] != 0)
                {
                    strcat(pNameFile, ".");
                    strcat(pNameFile, pDir[ix].Ext);
                }

                bbsPuts(pNameFile);

                ixn = strlen(pNameFile);
                while (ixn < 13)
                {
                    bbsPuts(" ");
                    ixn++;
                }

                ixc += 1;
                fileCount += 1;

                if (ixc == 3)
                {
                    ixr += 1;
                    ixc = 0;
                    bbsPuts("\r\n");
                    if (ixr == 14)
                        break;
                }
            }
            ix++;
        }

        msfree(pDir);
    }

    if (pDir == 0 || fileCount == 0)
    {
        bbsAnsiColor(0, 15);    // FG Branco
        bbsAnsiColor(1, 1);     // BG Vermelho
        bbsPuts("*** No files found\r\n");
        bbsAnsiNormal();
    }
    
    bbsCrLf();
    return bbsPause();
}

static int bbsOnlineUsers(char *currentUser)
{
    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│            Online Users              │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiNormal();
    bbsPuts(" 1. ");
    bbsPuts(currentUser);
    bbsPuts(" via Telnet\r\n\r\n");
    bbsPuts("────────────────────────────────────────\r\n");
    bbsPuts(" Total: 1\r\n");
    return bbsPause();
}

static int bbsSystemInfo(void)
{
    char up[32];

    bbsFormatUptime(up);
    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│         System Information           │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiNormal();
    bbsPuts("System    : MMC-320 Homebrew Computer\r\n");
    bbsPuts("CPU       : Motorola 68HC000 at 9MHz\r\n");
    bbsPuts("RAM       : 1280KB\r\n");
    bbsPuts("            System: 256KB  User: 1024KB\r\n");
    bbsPuts("Video     : TMS9118 VRAM 16KB\r\n");
    bbsPuts("OS        : MMSJ-OS\r\n");
    bbsPuts("BASIC     : v2.1\r\n");
    bbsPuts("Uptime    : ");
    bbsPuts(up);
    bbsCrLf();
    bbsPuts("Nodes     : 1\r\n");
    bbsPuts("Operator  : Moahrs\r\n");
    bbsPuts("Users     : ");
    bbsPrintDec((unsigned long)bbsUserCount + 1UL);
    bbsCrLf();
    bbsPuts("Messages  : 42\r\n");
    bbsPuts("Location  : Belo Horizonte, Brazil\r\n");
    return bbsPause();
}

static int bbsMenu(char *currentUser)
{
    int sel;
    int st;

    while (1) {
        bbsShowMenu(currentUser);
        sel = bbsReadMenuKey();
        if (sel < 0)
            return sel;

        if (sel == '1') {
            st = bbsMessages(currentUser);
            if (st < 0)
                return st;
        }
        else if (sel == '2') {
            st = bbsFiles();
            if (st < 0)
                return st;
        }
        else if (sel == '3') {
            st = bbsOnlineUsers(currentUser);
            if (st < 0)
                return st;
        }
        else if (sel == '4') {
            st = bbsSystemInfo();
            if (st < 0)
                return st;
        }
        else if (sel == '5') {
            bbsPuts("\r\nLogging out...\r\n");
            delayms(80);
            return 0;
        } else {
            bbsPuts("\r\nInvalid option.\r\n");
            delayms(80);
        }
    }
}

int main(void)
{
    char currentUser[BBS_USER_MAX + 1];
    int st;

    if (*startBasic == 1) {
        setModeVideoOS(VDP_MODE_TEXT);
        clearScr();
    }

    printText("MMSJ BBS starting...\r\n");
    printText("Press CTRL+ALT+X locally to exit.\r\n");

    bbsLoadUsers();

    if (!bbsEnableListen()) {
        printText("BBS stopped: network listener failed.\r\n");
        return 1;
    }

    while (!bbsLocalAbort()) {
        currentUser[0] = 0;
        st = bbsWaitCaller();
        if (st < 0)
            break;

        bbsTelnetInit();
        delayms(20);

        st = bbsLogin(currentUser);
        if (st == BBS_READ_ABORT)
            break;
        if (st == BBS_READ_TIMEOUT) {
            printText("BBS: login idle timeout.\r\n");
            if (!bbsResetSessionAndListen()) {
                printText("BBS stopped: unable to rearm listener.\r\n");
                break;
            }
            continue;
        }

        st = bbsShowUnreadNotice(currentUser);
        if (st == BBS_READ_ABORT)
            break;
        if (st == BBS_READ_TIMEOUT) {
            printText("BBS: session idle timeout.\r\n");
            if (!bbsResetSessionAndListen()) {
                printText("BBS stopped: unable to rearm listener.\r\n");
                break;
            }
            continue;
        }

        st = bbsMenu(currentUser);
        if (st == BBS_READ_ABORT)
            break;
        if (st == BBS_READ_TIMEOUT) {
            printText("BBS: session idle timeout.\r\n");
            if (!bbsResetSessionAndListen()) {
                printText("BBS stopped: unable to rearm listener.\r\n");
                break;
            }
            continue;
        }

        if (!bbsResetSessionAndListen()) {
            printText("BBS stopped: unable to rearm listener.\r\n");
            break;
        }
    }

    bbsPuts("\r\nMMSJ BBS shutting down.\r\n");
    delayms(20);
    netCommResetInput();
    writeLongSerial("+++");
    writeSerial('\r');
    delayms(50);
    netCommResetInput();
    writeLongSerial("ATRESETTCP");
    writeSerial('\r');
    delayms(50);

    printText("MMSJ BBS finished.\r\n");

    return 0;
}
