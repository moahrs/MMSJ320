#ifndef TELRBT_H
#define TELRBT_H

#define TELRBT_X 2
#define TELRBT_Y 2
#define TELRBT_W 252
#define TELRBT_H 188

#define TELRBT_FONT 8
#define TELRBT_LINE_H 8

#define TELRBT_CLOSE_X 200
#define TELRBT_CLOSE_Y 172
#define TELRBT_CLOSE_W 44
#define TELRBT_CLOSE_H 13

#define TELRBT_RX_LINE_MAX 256
#define TELRBT_FIELD_MAX   24
#define TELRBT_LAST_MAX    33
#define TELRBT_LOG_FILE    "/DOCS/RBT200.MCA"
#define TELRBT_LOG_MAX     32768UL
#define TELRBT_LOG_FLUSH_EVERY 10
#define TELRBT_LOG_COLS    40

typedef struct
{
    unsigned char tick[TELRBT_FIELD_MAX];
    unsigned char seq[TELRBT_FIELD_MAX];
    unsigned char event[TELRBT_FIELD_MAX];
    unsigned char state[TELRBT_FIELD_MAX];

    unsigned char host[TELRBT_FIELD_MAX];
    unsigned char port[TELRBT_FIELD_MAX];
    unsigned char localPort[TELRBT_FIELD_MAX];
    unsigned char positions[TELRBT_FIELD_MAX];
    unsigned char verticalLevels[TELRBT_FIELD_MAX];

    unsigned char heading[TELRBT_FIELD_MAX];
    unsigned char turn[TELRBT_FIELD_MAX];
    unsigned char clearance[TELRBT_FIELD_MAX];
    unsigned char score[TELRBT_FIELD_MAX];
    unsigned char required[TELRBT_FIELD_MAX];
    unsigned char target[TELRBT_FIELD_MAX];
    unsigned char targetTurn[TELRBT_FIELD_MAX];
    unsigned char accumulated[TELRBT_FIELD_MAX];

    unsigned char leftDir[TELRBT_FIELD_MAX];
    unsigned char leftSpeed[TELRBT_FIELD_MAX];
    unsigned char rightDir[TELRBT_FIELD_MAX];
    unsigned char rightSpeed[TELRBT_FIELD_MAX];
    unsigned char motorTarget[TELRBT_FIELD_MAX];

    unsigned char speed[TELRBT_FIELD_MAX];
    unsigned char distance[TELRBT_FIELD_MAX];
    unsigned char caution[TELRBT_FIELD_MAX];
    unsigned char maxRunUs[TELRBT_FIELD_MAX];
    unsigned char durationUs[TELRBT_FIELD_MAX];
    unsigned char wheelL[TELRBT_FIELD_MAX];
    unsigned char wheelR[TELRBT_FIELD_MAX];

    unsigned char reason[TELRBT_FIELD_MAX];
    unsigned char fails[TELRBT_FIELD_MAX];
    unsigned char penalty[TELRBT_FIELD_MAX];
    unsigned char direction[TELRBT_FIELD_MAX];
    unsigned char mode[TELRBT_FIELD_MAX];
    unsigned char operation[TELRBT_FIELD_MAX];
    unsigned char count[TELRBT_FIELD_MAX];
    unsigned char faults[TELRBT_FIELD_MAX];
    unsigned char value[TELRBT_FIELD_MAX];
    unsigned char moveResult[TELRBT_FIELD_MAX];
    unsigned char finishType[TELRBT_FIELD_MAX];

    unsigned char status[TELRBT_FIELD_MAX];
    unsigned char udp[TELRBT_FIELD_MAX];
    unsigned char last[TELRBT_LAST_MAX];
    unsigned long packets;
    unsigned long badPackets;
} TELRBT_STATE;

#endif
