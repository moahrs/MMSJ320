/********************************************************************************
*    Programa    : telrbt.c
*    Objetivo    : Painel MGUI para telemetria UDP do robo RBT200
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

#include "telrbt.h"

static TELRBT_STATE tel;
static unsigned char telFg;
static unsigned char telBg;
static unsigned char telMousePrev;
static unsigned char telConfigured;
static unsigned char telLogBuf[TELRBT_LOG_MAX];
static unsigned long telLogSize;
static unsigned char telLogDirty;
static unsigned char telLogSinceFlush;
static unsigned short telLogRow;

static const unsigned char *telLogHeaders[TELRBT_LOG_COLS] =
{
    (unsigned char *)"Tick",
    (unsigned char *)"Seq",
    (unsigned char *)"Event",
    (unsigned char *)"State",
    (unsigned char *)"Host",
    (unsigned char *)"Port",
    (unsigned char *)"LocalPort",
    (unsigned char *)"Positions",
    (unsigned char *)"VLevels",
    (unsigned char *)"Heading",
    (unsigned char *)"Turn",
    (unsigned char *)"Target",
    (unsigned char *)"TargetTurn",
    (unsigned char *)"MotorTarget",
    (unsigned char *)"Accum",
    (unsigned char *)"Clear",
    (unsigned char *)"Score",
    (unsigned char *)"Req",
    (unsigned char *)"Left",
    (unsigned char *)"LSpeed",
    (unsigned char *)"Right",
    (unsigned char *)"RSpeed",
    (unsigned char *)"Speed",
    (unsigned char *)"Dist",
    (unsigned char *)"Caution",
    (unsigned char *)"MaxRunUs",
    (unsigned char *)"DurationUs",
    (unsigned char *)"WheelL",
    (unsigned char *)"WheelR",
    (unsigned char *)"Reason",
    (unsigned char *)"Fails",
    (unsigned char *)"Penalty",
    (unsigned char *)"Direction",
    (unsigned char *)"Mode",
    (unsigned char *)"Operation",
    (unsigned char *)"Count",
    (unsigned char *)"Faults",
    (unsigned char *)"Value",
    (unsigned char *)"MoveResult",
    (unsigned char *)"FinishType"
};

static unsigned char telLogWidths[TELRBT_LOG_COLS] =
{
    12, 8, 20, 10, 16, 8, 10, 10, 8, 8,
    8, 10, 12, 12, 10, 8, 8, 8, 10, 8,
    10, 8, 8, 8, 8, 12, 12, 8, 8, 14,
    6, 8, 10, 8, 12, 8, 8, 8, 10, 10
};

static void telCopy(unsigned char *dst, const unsigned char *src, unsigned short max)
{
    unsigned short ix;

    ix = 0;
    if (!dst || max == 0)
        return;

    while (src && src[ix] && ix < max - 1)
    {
        dst[ix] = src[ix];
        ix++;
    }
    dst[ix] = 0;
}

static void telClearLine(unsigned short x, unsigned short y, unsigned short w)
{
    FillRect((unsigned char)x, (unsigned char)y, w, TELRBT_LINE_H, telBg);
}

static void telText(unsigned short x, unsigned short y, const unsigned char *s)
{
    writesxy(x, y, TELRBT_FONT, (unsigned char *)s, telFg, telBg);
}

static void telField(unsigned short x, unsigned short y, const unsigned char *label, unsigned char *value, unsigned short w)
{
    unsigned char line[48];

    telClearLine(x, y, w);
    line[0] = 0;
    strncat((char *)line, (char *)label, sizeof(line) - 1);
    strncat((char *)line, (char *)value, sizeof(line) - strlen((char *)line) - 1);
    line[sizeof(line) - 1] = 0;
    telText(x, y, line);
}

static void telBox(unsigned short x, unsigned short y, unsigned short w, unsigned short h, const unsigned char *title)
{
    FillRect((unsigned char)x, (unsigned char)y, w, (unsigned char)h, telBg);
    DrawRect(x, y, w, h, telFg);
    telText((unsigned short)(x + 4), (unsigned short)(y + 2), title);
}

static void telDrawButton(void)
{
    FillRect(TELRBT_CLOSE_X, TELRBT_CLOSE_Y, TELRBT_CLOSE_W, TELRBT_CLOSE_H, telBg);
    DrawRoundRect(TELRBT_CLOSE_X, TELRBT_CLOSE_Y, TELRBT_CLOSE_W, TELRBT_CLOSE_H, 1, telFg);
    telText((unsigned short)(TELRBT_CLOSE_X + 7), (unsigned short)(TELRBT_CLOSE_Y + 3), (unsigned char *)"Close");
}

static void telInitState(void)
{
    memset(&tel, 0, sizeof(tel));
    telCopy(tel.status, (unsigned char *)"Starting", TELRBT_FIELD_MAX);
    telCopy(tel.udp, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.seq, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.event, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.state, (unsigned char *)"WAIT", TELRBT_FIELD_MAX);
    telCopy(tel.tick, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.host, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.port, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.localPort, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.positions, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.verticalLevels, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.heading, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.turn, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.target, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.targetTurn, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.accumulated, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.clearance, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.score, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.required, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.leftDir, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.leftSpeed, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.rightDir, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.rightSpeed, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.motorTarget, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.speed, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.distance, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.caution, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.maxRunUs, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.durationUs, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.wheelL, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.wheelR, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.reason, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.fails, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.penalty, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.direction, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.mode, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.operation, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.count, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.faults, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.value, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.moveResult, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.finishType, (unsigned char *)"-", TELRBT_FIELD_MAX);
    telCopy(tel.last, (unsigned char *)"-", TELRBT_LAST_MAX);
}

static void telDrawStatic(void)
{
    showWindow((unsigned char *)"RBT200 Telemetry", TELRBT_X, TELRBT_Y, TELRBT_W, TELRBT_H, BTCLOSE);

    telBox(8, 18, 240, 24, (unsigned char *)"UDP");
    telBox(8, 45, 116, 48, (unsigned char *)"Direction / AI");
    telBox(132, 45, 116, 48, (unsigned char *)"Motors");
    telBox(8, 97, 116, 54, (unsigned char *)"Movement");
    telBox(132, 97, 116, 54, (unsigned char *)"Memory");
    telBox(8, 154, 184, 32, (unsigned char *)"Last packet");
    telDrawButton();
}

static void telDrawDynamic(void)
{
    unsigned char tmp[16];

    telField(14, 30, (unsigned char *)"Status: ", tel.status, 110);
    telField(122, 30, (unsigned char *)"UDP: ", tel.udp, 88);

    telField(14, 57, (unsigned char *)"State: ", tel.state, 104);
    telField(14, 67, (unsigned char *)"Head: ", tel.heading, 104);
    telField(14, 77, (unsigned char *)"Turn: ", tel.turn, 104);
    telField(14, 87, (unsigned char *)"Clear: ", tel.clearance, 104);

    telField(138, 57, (unsigned char *)"L: ", tel.leftDir, 104);
    telField(138, 67, (unsigned char *)"LSpeed: ", tel.leftSpeed, 104);
    telField(138, 77, (unsigned char *)"R: ", tel.rightDir, 104);
    telField(138, 87, (unsigned char *)"RSpeed: ", tel.rightSpeed, 104);

    telField(14, 109, (unsigned char *)"Speed: ", tel.speed, 104);
    telField(14, 119, (unsigned char *)"Dist: ", tel.distance, 104);
    telField(14, 129, (unsigned char *)"Caution: ", tel.caution, 104);
    telField(14, 139, (unsigned char *)"Wheel: ", tel.wheelL, 50);
    telField(70, 139, (unsigned char *)"/", tel.wheelR, 48);

    telField(138, 109, (unsigned char *)"Reason: ", tel.reason, 104);
    telField(138, 119, (unsigned char *)"Fails: ", tel.fails, 104);
    telField(138, 129, (unsigned char *)"Penalty: ", tel.penalty, 104);
    telField(138, 139, (unsigned char *)"Score: ", tel.score, 104);

    telField(14, 166, (unsigned char *)"Event: ", tel.event, 170);
    telField(14, 176, (unsigned char *)"Raw: ", tel.last, 170);

    telField(196, 154, (unsigned char *)"Seq: ", tel.seq, 50);
    ltoa((long)tel.packets, (char *)tmp, 10);
    telField(196, 164, (unsigned char *)"Pkt: ", tmp, 50);
}

static void telLogFlush(void)
{
    unsigned char ret;
    unsigned char cRetAux[32];

    if (!telLogDirty)
        return;

    telCopy(tel.status, (unsigned char *)"Saving log", TELRBT_FIELD_MAX);
    telField(14, 30, (unsigned char *)"Status: ", tel.status, 110);

    ret = saveFile((unsigned char *)TELRBT_LOG_FILE, telLogBuf, telLogSize);
    if (ret == RETURN_OK)
    {
        telLogDirty = 0;
        telLogSinceFlush = 0;
        telCopy(tel.status, (unsigned char *)"Log saved", TELRBT_FIELD_MAX);
    }
    else
    {
        msprintf(cRetAux,"[%i]Log save error",ret);
        telCopy(tel.status, (unsigned char *)cRetAux, TELRBT_FIELD_MAX);
    }

    telField(14, 30, (unsigned char *)"Status: ", tel.status, 110);
}

static void telLogPutChar(unsigned char c)
{
    if (telLogSize >= TELRBT_LOG_MAX - 1)
        return;

    telLogBuf[telLogSize++] = c;
    telLogBuf[telLogSize] = 0;
}

static void telLogPutStr(const unsigned char *s)
{
    while (s && *s && telLogSize < TELRBT_LOG_MAX - 1)
    {
        telLogBuf[telLogSize++] = *s;
        s++;
    }
    telLogBuf[telLogSize] = 0;
}

static void telLogPutUInt(unsigned long v)
{
    unsigned char tmp[16];

    ltoa((long)v, (char *)tmp, 10);
    telLogPutStr(tmp);
}

static void telLogNewLine(void)
{
    telLogPutChar('\n');
}

static void telLogCell(unsigned short row, unsigned short col, const unsigned char *value)
{
    if (telLogSize >= TELRBT_LOG_MAX - 96)
    {
        telCopy(tel.status, (unsigned char *)"Log full", TELRBT_FIELD_MAX);
        return;
    }

    telLogPutChar('C');
    telLogPutChar('\t');
    telLogPutUInt(row);
    telLogPutChar('\t');
    telLogPutUInt(col);
    telLogPutChar('\t');
    telLogPutChar('2');
    telLogPutChar('\t');
    telLogPutUInt((unsigned long)'L');
    telLogPutChar('\t');
    telLogPutUInt((unsigned long)'G');
    telLogPutChar('\t');
    telLogPutStr(value);
    telLogNewLine();
}

static void telLogHeader(void)
{
    unsigned short ix;

    telLogPutStr((unsigned char *)"MCALC1");
    telLogNewLine();
    telLogPutStr((unsigned char *)"D\t0\t71");
    telLogNewLine();

    for (ix = 0; ix < 64; ix++)
    {
        telLogPutStr((unsigned char *)"W\t");
        telLogPutUInt((unsigned long)(ix + 1));
        telLogPutChar('\t');
        if (ix < TELRBT_LOG_COLS)
            telLogPutUInt((unsigned long)telLogWidths[ix]);
        else
            telLogPutChar('8');
        telLogNewLine();
    }

    for (ix = 0; ix < TELRBT_LOG_COLS; ix++)
        telLogCell(1, (unsigned short)(ix + 1), telLogHeaders[ix]);
}

static void telLogReset(void)
{
    telLogSize = 0;
    telLogDirty = 0;
    telLogSinceFlush = 0;
    telLogRow = 2;

    telLogHeader();
    telLogDirty = 1;

    fsDelFile((char *)TELRBT_LOG_FILE);
    telLogFlush();
}

static void telLogAppend(void)
{
    if (telLogSize >= TELRBT_LOG_MAX - 1400)
    {
        telCopy(tel.status, (unsigned char *)"Log full", TELRBT_FIELD_MAX);
        return;
    }

    telLogCell(telLogRow, 1, tel.tick);
    telLogCell(telLogRow, 2, tel.seq);
    telLogCell(telLogRow, 3, tel.event);
    telLogCell(telLogRow, 4, tel.state);
    telLogCell(telLogRow, 5, tel.host);
    telLogCell(telLogRow, 6, tel.port);
    telLogCell(telLogRow, 7, tel.localPort);
    telLogCell(telLogRow, 8, tel.positions);
    telLogCell(telLogRow, 9, tel.verticalLevels);
    telLogCell(telLogRow, 10, tel.heading);
    telLogCell(telLogRow, 11, tel.turn);
    telLogCell(telLogRow, 12, tel.target);
    telLogCell(telLogRow, 13, tel.targetTurn);
    telLogCell(telLogRow, 14, tel.motorTarget);
    telLogCell(telLogRow, 15, tel.accumulated);
    telLogCell(telLogRow, 16, tel.clearance);
    telLogCell(telLogRow, 17, tel.score);
    telLogCell(telLogRow, 18, tel.required);
    telLogCell(telLogRow, 19, tel.leftDir);
    telLogCell(telLogRow, 20, tel.leftSpeed);
    telLogCell(telLogRow, 21, tel.rightDir);
    telLogCell(telLogRow, 22, tel.rightSpeed);
    telLogCell(telLogRow, 23, tel.speed);
    telLogCell(telLogRow, 24, tel.distance);
    telLogCell(telLogRow, 25, tel.caution);
    telLogCell(telLogRow, 26, tel.maxRunUs);
    telLogCell(telLogRow, 27, tel.durationUs);
    telLogCell(telLogRow, 28, tel.wheelL);
    telLogCell(telLogRow, 29, tel.wheelR);
    telLogCell(telLogRow, 30, tel.reason);
    telLogCell(telLogRow, 31, tel.fails);
    telLogCell(telLogRow, 32, tel.penalty);
    telLogCell(telLogRow, 33, tel.direction);
    telLogCell(telLogRow, 34, tel.mode);
    telLogCell(telLogRow, 35, tel.operation);
    telLogCell(telLogRow, 36, tel.count);
    telLogCell(telLogRow, 37, tel.faults);
    telLogCell(telLogRow, 38, tel.value);
    telLogCell(telLogRow, 39, tel.moveResult);
    telLogCell(telLogRow, 40, tel.finishType);

    telLogRow++;

    telLogDirty = 1;
    telLogSinceFlush++;

    if (telLogSinceFlush >= TELRBT_LOG_FLUSH_EVERY)
        telLogFlush();
}

static unsigned char telUpper(unsigned char c)
{
    if (c >= 'a' && c <= 'z')
        return (unsigned char)(c - 32);

    return c;
}

static int telStartsWithNoCase(const unsigned char *s, const unsigned char *prefix)
{
    while (*prefix)
    {
        if (telUpper(*s) != telUpper(*prefix))
            return 0;
        s++;
        prefix++;
    }
    return 1;
}

static unsigned char *telFindPacketStart(unsigned char *line)
{
    unsigned char *p;

    p = line;
    while (*p)
    {
        if (telStartsWithNoCase(p, (unsigned char *)"RBT200 "))
            return p;
        p++;
    }

    return 0;
}

static unsigned char *telFindValue(unsigned char *line, const unsigned char *key)
{
    unsigned short klen;
    unsigned char *p;

    klen = (unsigned short)strlen((char *)key);
    p = line;

    while (*p)
    {
        while (*p == ' ')
            p++;

        if (strncmp((char *)p, (char *)key, klen) == 0 && p[klen] == '=')
            return p + klen + 1;

        while (*p && *p != ' ')
            p++;
    }

    return 0;
}

static void telCopyValue(unsigned char *dst, unsigned short max, unsigned char *line, const unsigned char *key)
{
    unsigned char *v;
    unsigned short ix;

    v = telFindValue(line, key);
    if (!v)
        return;

    ix = 0;
    while (v[ix] && v[ix] != ' ' && v[ix] != '\r' && v[ix] != '\n' && ix < max - 1)
    {
        dst[ix] = v[ix];
        ix++;
    }
    dst[ix] = 0;
}

static void telSetStateFromEvent(void)
{
    if (strcmp((char *)tel.event, "telemetry_ready") == 0)
        telCopy(tel.state, (unsigned char *)"ONLINE", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "scan_start") == 0 ||
             strcmp((char *)tel.event, "scan_position") == 0 ||
             strcmp((char *)tel.event, "ai_cycle_start") == 0)
        telCopy(tel.state, (unsigned char *)"SCAN", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "scan_complete") == 0 ||
             strcmp((char *)tel.event, "ai_best") == 0)
        telCopy(tel.state, (unsigned char *)"DECIDE", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "ai_scan_only") == 0)
        telCopy(tel.state, (unsigned char *)"SCAN ONLY", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "no_safe_path") == 0)
        telCopy(tel.state, (unsigned char *)"NO PATH", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "turn_start") == 0 || strcmp((char *)tel.event, "turn_motors") == 0)
        telCopy(tel.state, (unsigned char *)"TURN", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "turn_complete") == 0)
        telCopy(tel.state, (unsigned char *)"TURN OK", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "turn_timeout") == 0 || strcmp((char *)tel.event, "turn_failed") == 0)
        telCopy(tel.state, (unsigned char *)"TURN FAIL", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "forward_start") == 0)
        telCopy(tel.state, (unsigned char *)"FORWARD", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "forward_obstacle") == 0)
        telCopy(tel.state, (unsigned char *)"OBSTACLE", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "forward_stuck") == 0)
        telCopy(tel.state, (unsigned char *)"STUCK", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "forward_max_run") == 0)
        telCopy(tel.state, (unsigned char *)"RESCAN", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "wheel_status") == 0)
    {
        if (strcmp((char *)tel.reason, "forward_start") == 0)
            telCopy(tel.state, (unsigned char *)"FORWARD", TELRBT_FIELD_MAX);
        else if (strcmp((char *)tel.reason, "obstacle") == 0)
            telCopy(tel.state, (unsigned char *)"OBSTACLE", TELRBT_FIELD_MAX);
        else if (strcmp((char *)tel.reason, "interrupted") == 0)
            telCopy(tel.state, (unsigned char *)"INTERRUPT", TELRBT_FIELD_MAX);
        else if (strcmp((char *)tel.reason, "max_run") == 0)
            telCopy(tel.state, (unsigned char *)"RESCAN", TELRBT_FIELD_MAX);
    }
    else if (strcmp((char *)tel.event, "backoff") == 0 || strcmp((char *)tel.event, "backward_start") == 0)
        telCopy(tel.state, (unsigned char *)"BACKOFF", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "backward_stop") == 0 || strcmp((char *)tel.event, "motor_stop") == 0)
        telCopy(tel.state, (unsigned char *)"STOPPED", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "escape") == 0)
        telCopy(tel.state, (unsigned char *)"ESCAPE", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "manual_move") == 0)
        telCopy(tel.state, (unsigned char *)"MANUAL", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "control_mode") == 0)
        telCopy(tel.state, tel.mode, TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "ai_interrupted") == 0)
        telCopy(tel.state, (unsigned char *)"INTERRUPT", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "laser_read_timeout") == 0)
        telCopy(tel.state, (unsigned char *)"LASER ERR", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "laser_read_recovered") == 0)
        telCopy(tel.state, (unsigned char *)"LASER OK", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "ai_cycle_complete") == 0)
        telCopy(tel.state, (unsigned char *)"CYCLE DONE", TELRBT_FIELD_MAX);
    else if (strcmp((char *)tel.event, "finish") == 0)
        telCopy(tel.state, (unsigned char *)"STOP", TELRBT_FIELD_MAX);
}

static void telParsePacket(unsigned char *line)
{
    unsigned char *pkt;

    telCopy(tel.last, line, TELRBT_LAST_MAX);

    pkt = telFindPacketStart(line);
    if (!pkt)
    {
        tel.badPackets++;
        telCopy(tel.status, (unsigned char *)"Bad packet", TELRBT_FIELD_MAX);
        return;
    }

    tel.packets++;
    telCopy(tel.status, (unsigned char *)"Receiving", TELRBT_FIELD_MAX);
    telCopy(tel.last, pkt, TELRBT_LAST_MAX);

    telCopyValue(tel.tick, TELRBT_FIELD_MAX, pkt, (unsigned char *)"tick");
    telCopyValue(tel.seq, TELRBT_FIELD_MAX, pkt, (unsigned char *)"seq");
    telCopyValue(tel.event, TELRBT_FIELD_MAX, pkt, (unsigned char *)"event");

    telCopyValue(tel.host, TELRBT_FIELD_MAX, pkt, (unsigned char *)"host");
    telCopyValue(tel.port, TELRBT_FIELD_MAX, pkt, (unsigned char *)"port");
    telCopyValue(tel.localPort, TELRBT_FIELD_MAX, pkt, (unsigned char *)"localPort");
    telCopyValue(tel.positions, TELRBT_FIELD_MAX, pkt, (unsigned char *)"positions");
    telCopyValue(tel.verticalLevels, TELRBT_FIELD_MAX, pkt, (unsigned char *)"verticalLevels");

    telCopyValue(tel.heading, TELRBT_FIELD_MAX, pkt, (unsigned char *)"heading");
    telCopyValue(tel.turn, TELRBT_FIELD_MAX, pkt, (unsigned char *)"turn");
    telCopyValue(tel.target, TELRBT_FIELD_MAX, pkt, (unsigned char *)"target");
    telCopyValue(tel.targetTurn, TELRBT_FIELD_MAX, pkt, (unsigned char *)"targetTurn");
    telCopyValue(tel.accumulated, TELRBT_FIELD_MAX, pkt, (unsigned char *)"accumulated");
    telCopyValue(tel.clearance, TELRBT_FIELD_MAX, pkt, (unsigned char *)"clearance");
    telCopyValue(tel.score, TELRBT_FIELD_MAX, pkt, (unsigned char *)"score");
    telCopyValue(tel.required, TELRBT_FIELD_MAX, pkt, (unsigned char *)"requiredClearance");
    telCopyValue(tel.required, TELRBT_FIELD_MAX, pkt, (unsigned char *)"required");

    telCopyValue(tel.leftDir, TELRBT_FIELD_MAX, pkt, (unsigned char *)"left");
    telCopyValue(tel.rightDir, TELRBT_FIELD_MAX, pkt, (unsigned char *)"right");
    telCopyValue(tel.leftDir, TELRBT_FIELD_MAX, pkt, (unsigned char *)"leftDir");
    telCopyValue(tel.leftSpeed, TELRBT_FIELD_MAX, pkt, (unsigned char *)"leftSpeed");
    telCopyValue(tel.rightDir, TELRBT_FIELD_MAX, pkt, (unsigned char *)"rightDir");
    telCopyValue(tel.rightSpeed, TELRBT_FIELD_MAX, pkt, (unsigned char *)"rightSpeed");
    telCopyValue(tel.speed, TELRBT_FIELD_MAX, pkt, (unsigned char *)"speed");
    telCopyValue(tel.motorTarget, TELRBT_FIELD_MAX, pkt, (unsigned char *)"motorTarget");

    telCopyValue(tel.distance, TELRBT_FIELD_MAX, pkt, (unsigned char *)"distance");
    telCopyValue(tel.caution, TELRBT_FIELD_MAX, pkt, (unsigned char *)"caution");
    telCopyValue(tel.maxRunUs, TELRBT_FIELD_MAX, pkt, (unsigned char *)"maxRunUs");
    telCopyValue(tel.durationUs, TELRBT_FIELD_MAX, pkt, (unsigned char *)"durationUs");
    telCopyValue(tel.wheelL, TELRBT_FIELD_MAX, pkt, (unsigned char *)"wheelL");
    telCopyValue(tel.wheelR, TELRBT_FIELD_MAX, pkt, (unsigned char *)"wheelR");

    telCopyValue(tel.reason, TELRBT_FIELD_MAX, pkt, (unsigned char *)"reason");
    telCopyValue(tel.fails, TELRBT_FIELD_MAX, pkt, (unsigned char *)"fails");
    telCopyValue(tel.penalty, TELRBT_FIELD_MAX, pkt, (unsigned char *)"penalty");
    telCopyValue(tel.direction, TELRBT_FIELD_MAX, pkt, (unsigned char *)"direction");
    telCopyValue(tel.mode, TELRBT_FIELD_MAX, pkt, (unsigned char *)"mode");
    telCopyValue(tel.operation, TELRBT_FIELD_MAX, pkt, (unsigned char *)"operation");
    telCopyValue(tel.count, TELRBT_FIELD_MAX, pkt, (unsigned char *)"count");
    telCopyValue(tel.faults, TELRBT_FIELD_MAX, pkt, (unsigned char *)"faults");
    telCopyValue(tel.value, TELRBT_FIELD_MAX, pkt, (unsigned char *)"value");
    telCopyValue(tel.moveResult, TELRBT_FIELD_MAX, pkt, (unsigned char *)"moveResult");
    telCopyValue(tel.finishType, TELRBT_FIELD_MAX, pkt, (unsigned char *)"type");

    if (strcmp((char *)tel.event, "wheel_status") == 0)
    {
        telCopy(tel.wheelL, tel.leftDir, TELRBT_FIELD_MAX);
        telCopy(tel.wheelR, tel.rightDir, TELRBT_FIELD_MAX);
    }

    telSetStateFromEvent();
    telLogAppend();
}

static void telReadSerialPackets(unsigned char *redraw)
{
    static unsigned char line[TELRBT_RX_LINE_MAX];
    static unsigned short pos = 0;
    unsigned char c;

    while (netCommGet(&c))
    {
        if (c == '\r')
            continue;

        if (c == '\n' || pos >= TELRBT_RX_LINE_MAX - 1)
        {
            line[pos] = 0;
            if (pos > 0)
            {
                telParsePacket(line);
                *redraw = 1;
            }
            pos = 0;
        }
        else
        {
            line[pos++] = c;
        }
    }
}

static void telReadResponse(unsigned char *s)
{
    unsigned char c;
    unsigned short ix;
    unsigned long timeout;

    ix = 0;
    timeout = 900000UL;
    s[0] = 0;

    while (timeout--)
    {
        if (!netCommGet(&c))
            continue;

        if (c == '\r')
            continue;

        if (c == '\n' || c == 0x04)
        {
            if (ix)
                break;
            continue;
        }

        if (ix < 63)
            s[ix++] = c;
    }

    s[ix] = 0;
}

static void telDefaultParam(unsigned char *host, unsigned char *port)
{
    unsigned char *p;
    unsigned char *dst;
    unsigned short ix;

    strcpy((char *)host, "192.168.1.50");
    strcpy((char *)port, "5000");

    if (!paramBasic || !paramBasic[0])
        return;

    p = paramBasic;
    while (*p == ' ')
        p++;

    if (*p == '/')
    {
        while (*p && *p != ' ')
            p++;
        while (*p == ' ')
            p++;
    }

    if (!*p)
        return;

    dst = host;
    ix = 0;
    while (*p && *p != ':' && *p != ' ' && ix < 31)
    {
        dst[ix++] = *p++;
    }
    dst[ix] = 0;

    if (*p == ':')
        p++;
    else
    {
        while (*p == ' ')
            p++;
    }

    if (*p)
    {
        ix = 0;
        while (*p && *p != ' ' && ix < 7)
            port[ix++] = *p++;
        port[ix] = 0;
    }
}

static void telSetupUdp(void)
{
    unsigned char host[32];
    unsigned char port[8];
    unsigned char cmd[56];
    unsigned char resp[64];
    unsigned char tryNo;
    unsigned char tryText[24];

    telDefaultParam(host, port);
    strcpy((char *)tel.udp, (char *)host);
    strcat((char *)tel.udp, ":");
    strcat((char *)tel.udp, (char *)port);
    tel.udp[19] = 0;
    netCommEnable();

    strcpy((char *)cmd, "ATUDP=");
    strcat((char *)cmd, (char *)host);
    strcat((char *)cmd, ":");
    strcat((char *)cmd, (char *)port);

    telConfigured = 0;
    resp[0] = 0;

    for (tryNo = 1; tryNo <= 5; tryNo++)
    {
        msprintf((char *)tryText, "UDP try %d/5", tryNo);
        telCopy(tel.status, tryText, TELRBT_FIELD_MAX);
        telField(14, 30, (unsigned char *)"Status: ", tel.status, 110);

        netCommResetInput();
        writeLongSerial((char *)cmd);
        writeSerial('\r');

        telReadResponse(resp);
        if (strncmp((char *)resp, "OK", 2) == 0)
        {
            telConfigured = 1;
            break;
        }

        delayms(50);
    }

    if (telConfigured)
    {
        telCopy(tel.status, (unsigned char *)"UDP ready", TELRBT_FIELD_MAX);
    }
    else
    {
        telCopy(tel.status, (unsigned char *)"UDP setup failed", TELRBT_FIELD_MAX);
        if (resp[0])
            telCopy(tel.last, resp, TELRBT_LAST_MAX);
    }

    telDrawDynamic();
}

static unsigned char telHandleMouse(void)
{
    MGUI_MOUSE m;

    getMouseData(0, &m);
    getMouseData(1, &m);

    if (m.mouseButton == 0x01 && telMousePrev != 0x01)
    {
        if (m.vpostx >= (TELRBT_X + TELRBT_W - 13) && m.vpostx <= (TELRBT_X + TELRBT_W - 3) &&
            m.vposty >= (TELRBT_Y + 2) && m.vposty <= (TELRBT_Y + 12))
            return 1;

        if (m.vpostx >= TELRBT_CLOSE_X && m.vpostx <= (TELRBT_CLOSE_X + TELRBT_CLOSE_W) &&
            m.vposty >= TELRBT_CLOSE_Y && m.vposty <= (TELRBT_CLOSE_Y + TELRBT_CLOSE_H))
            return 1;
    }

    telMousePrev = m.mouseButton;
    return 0;
}

static unsigned char telHandleKeyboard(void)
{
    unsigned int keyRaw;
    unsigned char code;
    unsigned char flags;

    keyRaw = (unsigned int)mguiListWindows[6].keyTec;
    if (keyRaw == 0)
        return 0;

    mguiListWindows[6].keyTec = 0;
    code = (unsigned char)(keyRaw & 0xFF);
    flags = (unsigned char)((keyRaw >> 8) & 0xFF);

    if (flags == KEY_CTRL_ALT && (code == 'X' || code == 'x'))
        return 1;

    return 0;
}

void main(void)
{
    MGUI_SAVESCR save;
    MGUI_COLOR color;
    unsigned char redraw;

    if (*startBasic != 2)
        return;

    TrocaSpriteMouse(MOUSE_POINTER);

    getColorData(&color);
    telFg = color.fg;
    telBg = color.bg;
    if (telFg == telBg)
        telFg = VDP_WHITE;

    telMousePrev = 0;
    telConfigured = 0;
    telInitState();

    SaveScreenNew(&save, TELRBT_X, TELRBT_Y, TELRBT_W, TELRBT_H);
    telDrawStatic();
    telDrawDynamic();
    telLogReset();
    telSetupUdp();
    telDrawDynamic();

    while (1)
    {
        if (telHandleMouse())
            break;
        if (telHandleKeyboard())
            break;

        redraw = 0;
        if (telConfigured)
            telReadSerialPackets(&redraw);
        if (redraw)
            telDrawDynamic();
    }

    telLogFlush();
    RestoreScreen(&save);
}
