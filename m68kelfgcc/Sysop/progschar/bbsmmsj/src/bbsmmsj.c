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

static char bbsUsers[BBS_USERS_MAX][BBS_USER_MAX + 1];
static char bbsPasses[BBS_USERS_MAX][BBS_PASS_MAX + 1];
static unsigned char bbsUserCount = 0;
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
    bbsPuts("Specs:\r\n");
    bbsPuts("  Motorola 68000 @ 9MHz   MMSJOS 1.0\r\n");
    bbsPuts("  TMS9118 ANSI Terminal   RAM 1280KB\r\n");
    bbsPuts("  Located in Brazil\r\n\r\n");
    bbsPuts("  Uptime ");
    bbsPuts(up);
    bbsPuts("\r\n  Max Perm Users online 1\r\n");
    bbsAnsiNormal();
    bbsPuts("\r\n");
    bbsPuts(" New account : type NEW as user\r\n");
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
        bbsPuts("User: ");

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
    bbsAnsiColor(0, 3);
    bbsPuts("Node 1");
    bbsAnsiColor(1, 4);
    bbsPuts("  Uptime ");
    bbsPuts(up);
    bbsPuts(" \r\n");
    bbsAnsiNormal();
    bbsPuts("┌───────────────────────────────────────\r\n");
    bbsPuts("│ User: ");
    bbsAnsiColor(0, 6);
    bbsPuts(currentUser);
    bbsAnsiNormal();
    bbsPuts("\r\n└───────────────────────────────────────\r\n");
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

static int bbsMessages(void)
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

static int bbsFiles(void)
{
    bbsAnsiClear();
    bbsAnsiColor(0, 3);
    bbsPuts("┌──────────────────────────────────────┐\r\n");
    bbsPuts("│                Files                 │\r\n");
    bbsPuts("└──────────────────────────────────────┘\r\n\r\n");
    bbsAnsiNormal();
    bbsPuts("File area is not implemented yet.");
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
    bbsPuts("CPU       : Motorola 68000\r\n");
    bbsPuts("Clock     : 9MHz\r\n");
    bbsPuts("RAM       : 1280KB\r\n");
    bbsPuts("Video     : TMS9118\r\n");
    bbsPuts("OS        : MMSJOS\r\n");
    bbsPuts("BASIC     : v2.1\r\n");
    bbsPuts("Uptime    : ");
    bbsPuts(up);
    bbsCrLf();
    bbsPuts("Users     : ");
    bbsPrintDec((unsigned long)bbsUserCount + 1UL);
    bbsCrLf();
    bbsPuts("Messages  : 42\r\n");
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
            st = bbsMessages();
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
