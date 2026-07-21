#include <ctype.h>
#include <string.h>
#define MMSJ320API_DECLARE_ONLY
#include "mmsj320api.h"
#undef MMSJ320API_DECLARE_ONLY
#include "mmsj320mfp.h"
#include "mmsjos.h"
#include "mmsj320vdp.h"
#include "monitorapi.h"
#include "netapi.h"
#include "telnet.h"

#define TELNET_RX_FULL_BIT       0x10
#define TELNET_TIMER_A_BIT       0x20
#define TELNET_POLL_DIVIDER      100
#define TELNET_LINE_SIZE         128
#define TELNET_CONTROL_SIZE      80
#define TELNET_KEY_QUEUE_SIZE    64

#define TELNET_IAC               255
#define TELNET_DONT              254
#define TELNET_DO                253
#define TELNET_WONT              252
#define TELNET_WILL              251
#define TELNET_SB                250
#define TELNET_SE                240

#define TELNET_OPT_ECHO          1
#define TELNET_OPT_SGA           3
#define TELNET_OPT_NAWS          31

static volatile unsigned char telnetPollDue;
static volatile unsigned char telnetTimerCount;
static unsigned char telnetInitialized;
static unsigned char telnetEnabled;
static unsigned char telnetSuspended;
static unsigned char telnetConnected;
static unsigned char telnetLine[TELNET_LINE_SIZE];
static unsigned char telnetLinePos;
static unsigned char telnetControl[TELNET_CONTROL_SIZE];
static unsigned char telnetControlPos;
static unsigned char telnetIacState;
static unsigned char telnetEscState;
static unsigned short telnetEscParam;
static unsigned char telnetLastOut;
static unsigned long telnetDirCluster;
static unsigned char telnetDirPath[128];
static unsigned short telnetDirIndex;
static MMSJ_KEYEVENT telnetKeyQueue[TELNET_KEY_QUEUE_SIZE];
static volatile unsigned char telnetKeyHead;
static volatile unsigned char telnetKeyTail;
static unsigned char telnetProgramMode;
static FILES_DIR telnetListDir[128];

static void telnetQueueKey(unsigned char code, unsigned char ascii,
                           unsigned char flags)
{
    unsigned char next;

    next = telnetKeyHead + 1;
    if (next >= TELNET_KEY_QUEUE_SIZE)
        next = 0;
    if (next == telnetKeyTail)
        return;

    telnetKeyQueue[telnetKeyHead].code = code;
    telnetKeyQueue[telnetKeyHead].ascii = ascii;
    telnetKeyQueue[telnetKeyHead].flags = flags;
    telnetKeyQueue[telnetKeyHead].raw = 0;
    telnetKeyHead = next;
}

static void telnetTimerEnable(void)
{
    telnetTimerCount = 0;
    telnetPollDue = 0;
    hookTable[HOOK_TIMER_A].addr = (unsigned long (*)(void))telnetTimerHook;
    hookTable[HOOK_TIMER_A].flags = HOOKF_ACTIVE;
    hookTable[HOOK_TIMER_A].magic = HOOK_MAGIC;

    /* Timer A pertence ao monitor. Apenas garantimos que sua interrupcao
       continue habilitada; periodo e registradores do timer nao sao alterados. */
    *(vmfp + Reg_IERA) |= TELNET_TIMER_A_BIT;
    *(vmfp + Reg_IMRA) |= TELNET_TIMER_A_BIT;
}

static void telnetTimerDisable(void)
{
    if (hookTable[HOOK_TIMER_A].addr == (unsigned long (*)(void))telnetTimerHook)
    {
        hookTable[HOOK_TIMER_A].magic = 0;
        hookTable[HOOK_TIMER_A].flags = 0;
        hookTable[HOOK_TIMER_A].addr = 0;
    }

    /* Nao desabilitar IERA/IMRA: o monitor usa Timer A para SysClockms. */
    telnetTimerCount = 0;
    telnetPollDue = 0;
}

static unsigned char telnetContains(const unsigned char *text, const char *find)
{
    unsigned short i;
    unsigned short j;

    if (!find[0])
        return 1;

    i = 0;
    while (text[i])
    {
        j = 0;
        while (find[j] && text[i + j] == (unsigned char)find[j])
            j++;
        if (!find[j])
            return 1;
        i++;
    }

    return 0;
}

static int telnetRxGet(unsigned char *c)
{
    if (serRxHead == serRxTail)
        return 0;

    *c = serRxBuf[serRxTail];
    serRxTail++;
    if (serRxTail >= NETAPI_RX_SIZE)
        serRxTail = 0;

    return 1;
}

static void telnetRxHook(void)
{
    unsigned char c;
    unsigned short next;

    c = *(vmfp + Reg_UDR);
    netApiLastByte = c;
    netApiHookCount++;

    next = serRxHead + 1;
    if (next >= NETAPI_RX_SIZE)
        next = 0;

    if (next == serRxTail)
    {
        serRxLost++;
        return;
    }

    serRxBuf[serRxHead] = c;
    serRxHead = next;
}

static void telnetRxReset(void)
{
    volatile unsigned char dummy;
    unsigned short limit;

    serRxHead = 0;
    serRxTail = 0;
    serRxLost = 0;
    netApiHookCount = 0;
    netApiLastByte = 0;

    limit = 1024;
    while ((*(vmfp + Reg_RSR) & 0x80) && limit)
    {
        dummy = *(vmfp + Reg_UDR);
        limit--;
    }
}

static void telnetNetEnable(void)
{
    *(vmfp + Reg_IMRA) &= (unsigned char)~TELNET_RX_FULL_BIT;
    *(vmfp + Reg_IERA) &= (unsigned char)~TELNET_RX_FULL_BIT;

    telnetRxReset();
    netApiMagic = NETAPI_MAGIC_VALUE;
    netApiHookMem = (unsigned long)telnetRxHook;
    netApiHookSize = 0;
    netApiHookOwned = 0;
    netApiEnabled = 1;

    hookTable[HOOK_REC_BUF_FULL].addr = (unsigned long (*)(void))telnetRxHook;
    hookTable[HOOK_REC_BUF_FULL].flags = HOOKF_ACTIVE | HOOKF_SKIP_OS;
    hookTable[HOOK_REC_BUF_FULL].magic = HOOK_MAGIC;

    *(vmfp + Reg_IERA) |= TELNET_RX_FULL_BIT;
    *(vmfp + Reg_IMRA) |= TELNET_RX_FULL_BIT;
}

static void telnetRawPutc(unsigned char c)
{
    writeSerial(c);
    if (c == TELNET_IAC)
        writeSerial(c);
}

static void telnetPutc(unsigned char c, char pMove)
{
    (void)pMove;

    if (c == '\n' && telnetLastOut != '\r')
        telnetRawPutc('\r');

    telnetRawPutc(c);
    telnetLastOut = c;
}

static void telnetPuts(const unsigned char *s)
{
    while (*s)
        telnetPutc(*s++, 1);
}

static void telnetSendOption(unsigned char command, unsigned char option)
{
    writeSerial(TELNET_IAC);
    writeSerial(command);
    writeSerial(option);
}

static void telnetSendPrompt(void)
{
    telnetPuts((unsigned char *)"\r\nMMSJ:");
    telnetPuts(telnetDirPath);
    telnetPuts((unsigned char *)"> ");
}

static void telnetSessionOpen(void)
{
    telnetConnected = 1;
    telnetLinePos = 0;
    telnetIacState = 0;
    telnetEscState = 0;
    telnetEscParam = 0;
    telnetLastOut = 0;
    telnetDirCluster = vclusterdir;
    strcpy((char *)telnetDirPath, (char *)vdiratu);
    telnetDirIndex = vdiratuidx;

    telnetSendOption(TELNET_WILL, TELNET_OPT_ECHO);
    telnetSendOption(TELNET_WILL, TELNET_OPT_SGA);
    telnetSendOption(TELNET_DO, TELNET_OPT_SGA);
    telnetSendOption(TELNET_DO, TELNET_OPT_NAWS);
    telnetPuts((unsigned char *)"\033[2J\033[H");
    telnetPuts((unsigned char *)"MMSJ-OS Telnet\r\n");
    telnetPuts((unsigned char *)"Type HELP for available commands.\r\n");
    telnetSendPrompt();
}

static void telnetSessionClosed(void)
{
    telnetConnected = 0;
    telnetLinePos = 0;
    telnetControlPos = 0;
    telnetIacState = 0;
    telnetEscState = 0;
    telnetEscParam = 0;
}

static unsigned char telnetCommandIs(const unsigned char *cmd, const char *name)
{
    unsigned short i;

    i = 0;
    while (name[i] && cmd[i])
    {
        if (toupper(cmd[i]) != name[i])
            return 0;
        i++;
    }

    return (name[i] == 0 && (cmd[i] == 0 || cmd[i] == ' ' || cmd[i] == '\t'));
}

static unsigned char telnetCommandAllowed(const unsigned char *cmd)
{
    return telnetCommandIs(cmd, "VER") ||
           telnetCommandIs(cmd, "LS") ||
           telnetCommandIs(cmd, "DIR") ||
           telnetCommandIs(cmd, "PWD") ||
           telnetCommandIs(cmd, "CD");
}

static void telnetHelp(void)
{
    telnetPuts((unsigned char *)
        "Commands: VER, LS, DIR, PWD, CD, CAT, DATE, TIME\r\n"
        "          CLS, CLEAR, EXIT, QUIT\r\n"
        "Contingency mode: write/delete/program commands are disabled.\r\n");
}

static unsigned char *telnetCommandArg(unsigned char *cmd)
{
    while (*cmd && *cmd != ' ' && *cmd != '\t')
        cmd++;

    while (*cmd == ' ' || *cmd == '\t')
        cmd++;

    return cmd;
}

static void telnetSaveLocalDir(unsigned long *cluster, unsigned short *dirIndex,
                               unsigned char *path, RET_PATH *retPath,
                               RET_PATH *retPath2, FAT32_DIR *dir)
{
    *cluster = vclusterdir;
    *dirIndex = vdiratuidx;
    strcpy((char *)path, (char *)vdiratu);
    *retPath = vretpath;
    *retPath2 = vretpath2;
    *dir = vdir;
}

static void telnetRestoreLocalDir(unsigned long cluster, unsigned short dirIndex,
                                  unsigned char *path, RET_PATH retPath,
                                  RET_PATH retPath2, FAT32_DIR dir)
{
    vclusterdir = cluster;
    vdiratuidx = dirIndex;
    strcpy((char *)vdiratu, (char *)path);
    vretpath = retPath;
    vretpath2 = retPath2;
    vdir = dir;
}

static void telnetUseRemoteDir(void)
{
    vclusterdir = telnetDirCluster;
    vdiratuidx = telnetDirIndex;
    strcpy((char *)vdiratu, (char *)telnetDirPath);
}

static void telnetStoreRemoteDir(void)
{
    telnetDirCluster = vclusterdir;
    telnetDirIndex = vdiratuidx;
    strcpy((char *)telnetDirPath, (char *)vdiratu);
}

static void telnetPrintVer(void)
{
    telnetPuts((unsigned char *)"MMSJ-OS/68K\r\n");
    telnetPuts((unsigned char *)"CPU      68HC000\r\n");
    telnetPuts((unsigned char *)"VIDEO    TMS9118\r\n");
    telnetPuts((unsigned char *)"DISK     FAT32\r\n");
}

static void telnetPrintPwd(void)
{
    telnetPuts(telnetDirPath);
    telnetPuts((unsigned char *)"\r\n");
}

static void telnetChangeDir(unsigned char *cmd)
{
    unsigned long localCluster;
    unsigned short localDirIndex;
    unsigned char localDirPath[128];
    RET_PATH localRetPath;
    RET_PATH localRetPath2;
    FAT32_DIR localDir;
    unsigned char *arg;
    unsigned char ret;

    arg = telnetCommandArg(cmd);
    if (!arg[0])
    {
        telnetPrintPwd();
        return;
    }

    telnetSaveLocalDir(&localCluster, &localDirIndex, localDirPath,
                       &localRetPath, &localRetPath2, &localDir);
    telnetUseRemoteDir();

    ret = fsChangeDir((char *)arg);
    if (ret == RETURN_OK)
        telnetStoreRemoteDir();
    else
        telnetPuts((unsigned char *)"Directory not found.\r\n");

    telnetRestoreLocalDir(localCluster, localDirIndex, localDirPath,
                          localRetPath, localRetPath2, localDir);
}

static void telnetListFiles(unsigned char *cmd)
{
    unsigned long localCluster;
    unsigned short localDirIndex;
    unsigned char localDirPath[128];
    RET_PATH localRetPath;
    RET_PATH localRetPath2;
    FAT32_DIR localDir;
    unsigned char *arg;
    unsigned short ix;
    char pNameFile[16];

    arg = telnetCommandArg(cmd);

    telnetSaveLocalDir(&localCluster, &localDirIndex, localDirPath,
                       &localRetPath, &localRetPath2, &localDir);
    telnetUseRemoteDir();

    fsListDir(telnetListDir, arg);

    ix = 0;
    while (ix < 128 && telnetListDir[ix].Name[0] != 0)
    {
        if (telnetListDir[ix].Attr[1] == 'V')
        {
            telnetPuts((unsigned char *)"          Disk name is ");
            telnetPuts(telnetListDir[ix].Name);
            telnetPuts(telnetListDir[ix].Ext);
            telnetPuts((unsigned char *)"\r\n\r\n");
        }
        else
        {
            strcpy(pNameFile, (char *)telnetListDir[ix].Name);
            if (telnetListDir[ix].Ext[0] != 0)
            {
                strcat(pNameFile, ".");
                strcat(pNameFile, (char *)telnetListDir[ix].Ext);
            }

            if (telnetListDir[ix].Attr[1] == 'D')
                strcat(pNameFile, "/");

            telnetPuts((unsigned char *)"    ");
            if (telnetListDir[ix].Attr[1] == 'D')
                telnetPuts((unsigned char *)"     ");
            else
                telnetPuts(telnetListDir[ix].Size);
            telnetPuts((unsigned char *)" ");
            telnetPuts(telnetListDir[ix].Modify);
            telnetPuts((unsigned char *)" ");
            telnetPuts((unsigned char *)pNameFile);
            telnetPuts((unsigned char *)"\r\n");
        }
        ix++;
    }

    telnetRestoreLocalDir(localCluster, localDirIndex, localDirPath,
                          localRetPath, localRetPath2, localDir);
}

static void telnetRunCommand(unsigned char *cmd)
{
    MMSJ_CONSOLE oldConsole;
    MMSJ_CONSOLE remoteConsole;
    unsigned long localCluster;
    unsigned short localDirIndex;
    unsigned char localDirPath[128];
    RET_PATH localRetPath;
    RET_PATH localRetPath2;
    FAT32_DIR localDir;
    unsigned long commandResult;

    if (telnetCommandIs(cmd, "HELP"))
    {
        telnetHelp();
        return;
    }

    if (telnetCommandIs(cmd, "CLS") || telnetCommandIs(cmd, "CLEAR"))
    {
        telnetPuts((unsigned char *)"\033[2J\033[H");
        return;
    }

    if (telnetCommandIs(cmd, "QUIT") || telnetCommandIs(cmd, "EXIT"))
    {
        telnetPuts((unsigned char *)"BYE\r\n");
        writeSerial('+');
        writeSerial('+');
        writeSerial('+');
        telnetSessionClosed();
        return;
    }

    if (!telnetCommandAllowed(cmd))
    {
        telnetPuts((unsigned char *)"Unauthorized in Telnet.\r\n");
        return;
    }

    if (telnetCommandIs(cmd, "VER"))
    {
        telnetPrintVer();
        return;
    }

    if (telnetCommandIs(cmd, "PWD"))
    {
        telnetPrintPwd();
        return;
    }

    if (telnetCommandIs(cmd, "CD"))
    {
        telnetChangeDir(cmd);
        return;
    }

    if (telnetCommandIs(cmd, "LS") || telnetCommandIs(cmd, "DIR"))
    {
        telnetListFiles(cmd);
        return;
    }

    telnetPuts((unsigned char *)"Command disabled in Telnet contingency mode.\r\n");
    return;

    if (telnetCommandIs(cmd, "DIR"))
    {
        unsigned short i;

        cmd[0] = 'L';
        cmd[1] = 'S';
        i = 3;
        while (cmd[i])
        {
            cmd[i - 1] = cmd[i];
            i++;
        }
        cmd[i - 1] = 0;
    }

    localCluster = vclusterdir;
    localDirIndex = vdiratuidx;
    strcpy((char *)localDirPath, (char *)vdiratu);
    localRetPath = vretpath;
    localRetPath2 = vretpath2;
    localDir = vdir;

    vclusterdir = telnetDirCluster;
    vdiratuidx = telnetDirIndex;
    strcpy((char *)vdiratu, (char *)telnetDirPath);

    oldConsole = *activeConsole;
    remoteConsole.magic = TELNET_CONSOLE_MAGIC;
    remoteConsole.flags = 0;
    remoteConsole.putc = telnetPutc;
    remoteConsole.getc = 0;
    remoteConsole.kbhit = 0;
    *activeConsole = remoteConsole;

    telnetProgramMode = 1;
    telnetKeyHead = 0;
    telnetKeyTail = 0;
    commandResult = fsOsCommand(cmd);
    telnetProgramMode = 0;
    if (commandResult != 0 && commandResult != 99)
        mprintf("Command failed: %lu\r\n", commandResult);

    telnetDirCluster = vclusterdir;
    telnetDirIndex = vdiratuidx;
    strcpy((char *)telnetDirPath, (char *)vdiratu);

    *activeConsole = oldConsole;
    vclusterdir = localCluster;
    vdiratuidx = localDirIndex;
    strcpy((char *)vdiratu, (char *)localDirPath);
    vretpath = localRetPath;
    vretpath2 = localRetPath2;
    vdir = localDir;
}

static void telnetLineComplete(void)
{
    telnetLine[telnetLinePos] = 0;

    if (!strcmp((char *)telnetLine, "EVT;DISCONNECT"))
    {
        telnetSessionClosed();
        return;
    }

    telnetPuts((unsigned char *)"\r\n");
    if (telnetLinePos)
        telnetRunCommand(telnetLine);

    telnetLinePos = 0;
    if (telnetConnected)
        telnetSendPrompt();
}

static void telnetProcessConnectedByte(unsigned char c)
{
    if (telnetIacState)
    {
        if (telnetIacState == 1)
        {
            if (c == TELNET_IAC)
                telnetIacState = 0;
            else if (c == TELNET_SB)
                telnetIacState = 3;
            else if (c == TELNET_WILL || c == TELNET_WONT ||
                     c == TELNET_DO || c == TELNET_DONT)
                telnetIacState = 2;
            else
                telnetIacState = 0;
        }
        else if (telnetIacState == 2)
            telnetIacState = 0;
        else if (telnetIacState == 3)
        {
            if (c == TELNET_IAC)
                telnetIacState = 4;
        }
        else if (telnetIacState == 4)
            telnetIacState = (c == TELNET_SE) ? 0 : 3;
        return;
    }

    if (c == TELNET_IAC)
    {
        telnetIacState = 1;
        return;
    }

    if (telnetEscState)
    {
        if (telnetEscState == 1 && c == '[')
        {
            telnetEscState = 2;
            telnetEscParam = 0;
        }
        else if (telnetEscState == 2 && c >= '0' && c <= '9')
            telnetEscParam = (unsigned short)(telnetEscParam * 10 + (c - '0'));
        else if (telnetEscState == 2 && c >= 0x40 && c <= 0x7E)
        {
            if (telnetProgramMode)
            {
                if (c == 'A') telnetQueueKey(KEY_UP, 0, KEY_NONE);
                else if (c == 'B') telnetQueueKey(KEY_DOWN, 0, KEY_NONE);
                else if (c == 'C') telnetQueueKey(KEY_RIGHT, 0, KEY_NONE);
                else if (c == 'D') telnetQueueKey(KEY_LEFT, 0, KEY_NONE);
                else if (c == 'H') telnetQueueKey(KEY_HOME, 0, KEY_NONE);
                else if (c == 'F') telnetQueueKey(KEY_END, 0, KEY_NONE);
                else if (c == '~' && telnetEscParam == 2) telnetQueueKey(KEY_INSERT, 0, KEY_NONE);
                else if (c == '~' && telnetEscParam == 3) telnetQueueKey(KEY_DELETE, 0, KEY_NONE);
                else if (c == '~' && telnetEscParam == 5) telnetQueueKey(KEY_PAGEUP, 0, KEY_NONE);
                else if (c == '~' && telnetEscParam == 6) telnetQueueKey(KEY_PAGEDOWN, 0, KEY_NONE);
            }
            telnetEscState = 0;
        }
        else if (telnetEscState == 1)
            telnetEscState = 0;
        return;
    }

    if (c == 0x1B)
    {
        telnetEscState = 1;
        return;
    }

    if (c == 0x04)
        return;

    if (telnetProgramMode)
    {
        if (c == '\n')
            return;
        if (c >= 1 && c <= 26 && c != '\r' && c != '\t' && c != 0x08)
            telnetQueueKey((unsigned char)('A' + c - 1), c, KEY_CTRL);
        else
            telnetQueueKey(c, c, KEY_NONE);
        return;
    }

    if (c == '\r' || c == '\n')
    {
        if (c == '\n' && telnetLinePos == 0)
            return;
        telnetLineComplete();
        return;
    }

    if (c == 0 || c == 0x7F || c == 0x08)
    {
        if ((c == 0x7F || c == 0x08) && telnetLinePos)
        {
            telnetLinePos--;
            telnetPuts((unsigned char *)"\b \b");
        }
        return;
    }

    if (c >= 0x20 && c < 0x7F && telnetLinePos < TELNET_LINE_SIZE - 1)
    {
        telnetLine[telnetLinePos++] = c;
        telnetPutc(c, 1);
    }
}

static void telnetProcessControlByte(unsigned char c)
{
    /* Clientes como PuTTY iniciam enviando IAC. Isso tambem serve como
       confirmacao de conexao caso o EVT;CONNECT do ESP32 se perca. */
    if (c == TELNET_IAC)
    {
        telnetControlPos = 0;
        telnetSessionOpen();
        telnetProcessConnectedByte(c);
        return;
    }

    if (c == 0x04 || c == '\r' || c == '\n')
    {
        if (telnetControlPos)
        {
            telnetControl[telnetControlPos] = 0;
            if (!strncmp((char *)telnetControl, "EVT;CONNECT;", 12))
                telnetSessionOpen();
            telnetControlPos = 0;
        }
        return;
    }

    if (telnetControlPos < TELNET_CONTROL_SIZE - 1)
        telnetControl[telnetControlPos++] = c;
}

static unsigned char telnetWaitResponse(unsigned char *response, unsigned short max,
                                        unsigned long timeout)
{
    unsigned char c;
    unsigned short pos;

    pos = 0;
    while (timeout--)
    {
        if (!telnetRxGet(&c))
            continue;

        if (c == 0x04)
        {
            response[pos] = 0;
            return 1;
        }

        if (c != '\r' && c != '\n' && pos < max - 1)
            response[pos++] = c;
    }

    response[pos] = 0;
    return 0;
}

static void telnetStartListen(void)
{
    unsigned char response[64];

    telnetRxReset();
    writeLongSerial((unsigned char *)"ATLISTEN?\r");
    if (!telnetWaitResponse(response, sizeof(response), 800000UL))
        return;

    if (telnetContains(response, "OK;LISTEN;"))
    {
        telnetRxReset();
        return;
    }

    telnetRxReset();
    writeLongSerial((unsigned char *)"ATLISTEN\r");
    telnetWaitResponse(response, sizeof(response), 800000UL);
    telnetRxReset();
}

static void telnetStopListen(void)
{
    unsigned char response[64];

    if (telnetConnected)
    {
        telnetPuts((unsigned char *)"\r\nServer suspending Telnet.\r\n");
        writeSerial('+');
        writeSerial('+');
        writeSerial('+');
        telnetSessionClosed();
        telnetWaitResponse(response, sizeof(response), 800000UL);
    }

    telnetRxReset();
    writeLongSerial((unsigned char *)"ATRESETTCP\r");
    telnetWaitResponse(response, sizeof(response), 800000UL);
    telnetRxReset();
}

void telnetTimerHook(void)
{
    telnetTimerCount++;
    if (telnetTimerCount >= TELNET_POLL_DIVIDER)
    {
        telnetTimerCount = 0;
        telnetPollDue = 1;
    }
}

void telnetInitVars(void)
{
    telnetPollDue = 0;
    telnetTimerCount = 0;
    telnetInitialized = 0;
    telnetEnabled = 0;
    telnetSuspended = 0;
    telnetConnected = 0;
    telnetLinePos = 0;
    telnetControlPos = 0;
    telnetIacState = 0;
    telnetEscState = 0;
    telnetEscParam = 0;
    telnetLastOut = 0;
    telnetDirCluster = vclusterdir;
    strcpy((char *)telnetDirPath, (char *)vdiratu);
    telnetDirIndex = vdiratuidx;
    telnetKeyHead = 0;
    telnetKeyTail = 0;
    telnetProgramMode = 0;
}

void telnetInit(void)
{
    if (telnetInitialized)
        return;

    telnetNetEnable();
    telnetTimerDisable();
    telnetInitialized = 1;
}

void telnetPoll(void)
{
    unsigned char c;

    if (!telnetEnabled || telnetSuspended)
        return;

    /* O timer garante a chamada periodica. Se o RX ja tem dados, atende
       imediatamente para nao depender de uma borda especifica do timer. */
    if (!telnetPollDue && serRxHead == serRxTail)
        return;

    telnetPollDue = 0;
    while (telnetRxGet(&c))
    {
        if (telnetConnected)
            telnetProcessConnectedByte(c);
        else
            telnetProcessControlByte(c);
    }
}

unsigned char telnetConsoleActive(void)
{
    return (activeConsole->magic == TELNET_CONSOLE_MAGIC);
}

unsigned char telnetIsEnabled(void)
{
    return telnetEnabled;
}

unsigned char telnetSetEnabled(unsigned char enabled)
{
    if (enabled)
    {
        if (telnetEnabled && !telnetSuspended)
            return 1;

        telnetInit();
        telnetEnabled = 1;
        telnetSuspended = 0;
        telnetNetEnable();
        telnetStartListen();
        telnetTimerEnable();
        return 1;
    }

    if (telnetEnabled || telnetSuspended)
        telnetStopListen();

    telnetEnabled = 0;
    telnetSuspended = 0;
    telnetSessionClosed();
    telnetTimerDisable();
    return 1;
}

unsigned char telnetSuspend(void)
{
    if (!telnetEnabled || telnetSuspended)
        return 0;

    telnetStopListen();
    telnetTimerDisable();
    telnetSuspended = 1;
    return 1;
}

void telnetResume(unsigned char wasEnabled)
{
    if (!wasEnabled || !telnetEnabled)
        return;

    telnetSuspended = 0;
    telnetNetEnable();
    telnetStartListen();
    telnetTimerEnable();
}

unsigned char telnetPauseLocalCommand(void)
{
    if (!telnetEnabled || telnetSuspended || telnetConnected)
        return 0;

    *(vmfp + Reg_IMRA) &= (unsigned char)~TELNET_RX_FULL_BIT;
    *(vmfp + Reg_IERA) &= (unsigned char)~TELNET_RX_FULL_BIT;

    if (hookTable[HOOK_REC_BUF_FULL].addr == (unsigned long (*)(void))telnetRxHook)
    {
        hookTable[HOOK_REC_BUF_FULL].magic = 0;
        hookTable[HOOK_REC_BUF_FULL].flags = 0;
        hookTable[HOOK_REC_BUF_FULL].addr = 0;
    }

    telnetTimerDisable();
    telnetRxReset();
    telnetSuspended = 1;

    *(vmfp + Reg_IERA) |= TELNET_RX_FULL_BIT;
    *(vmfp + Reg_IMRA) |= TELNET_RX_FULL_BIT;

    return 1;
}

void telnetResumeLocalCommand(unsigned char wasPaused)
{
    if (!wasPaused || !telnetEnabled)
        return;

    telnetSuspended = 0;
    telnetNetEnable();
    telnetTimerEnable();
}

unsigned char telnetGetKey(MMSJ_KEYEVENT *keyEvent)
{
    if (!telnetProgramMode || telnetKeyHead == telnetKeyTail)
        return 0;

    *keyEvent = telnetKeyQueue[telnetKeyTail];
    telnetKeyTail++;
    if (telnetKeyTail >= TELNET_KEY_QUEUE_SIZE)
        telnetKeyTail = 0;
    return 1;
}
