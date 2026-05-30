#include <string.h>
#include "netcomm.h"

volatile unsigned char serRxBuf[SER_RX_SIZE];
volatile unsigned int serRxHead = 0;
volatile unsigned int serRxTail = 0;
volatile unsigned int serRxLost = 0;

static NET_HOOK *netHookTable = (NET_HOOK *)0x0060F7BC;

void netCommInstallHook(int hookNum, void (*func)(void))
{
    netHookTable[hookNum].addr   = func;
    netHookTable[hookNum].flags  = HOOKF_ACTIVE | HOOKF_SKIP_OS;
    netHookTable[hookNum].magic  = HOOK_MAGIC;
}

void netCommFlush(void)
{
    serRxHead = 0;
    serRxTail = 0;
    serRxLost = 0;

    while (*(vmfp + Reg_RSR) & 0x80)
    {
        volatile unsigned char dummy;
        dummy = *(vmfp + Reg_UDR);
    }
}

void netCommRxHook(void)
{
    unsigned char c;
    unsigned int next;

    c = *(vmfp + Reg_UDR);

    next = serRxHead + 1;
    if (next >= SER_RX_SIZE)
        next = 0;

    if (next == serRxTail)
    {
        serRxLost++;
        return;
    }

    serRxBuf[serRxHead] = c;
    serRxHead = next;
}

int netCommGet(unsigned char *c)
{
    if (serRxHead == serRxTail)
        return 0;

    *c = serRxBuf[serRxTail];

    serRxTail++;
    if (serRxTail >= SER_RX_SIZE)
        serRxTail = 0;

    return 1;
}

int netCommWait(unsigned char *c, unsigned long timeoutSpin)
{
    while (timeoutSpin)
    {
        if (netCommGet(c))
            return 1;

        timeoutSpin--;
    }

    return 0;
}

void netCommEnable(void)
{
    netCommFlush();
    netCommInstallHook(HOOK_REC_BUF_FULL, netCommRxHook);

    *(vmfp + Reg_IERA) |= MFP_RX_FULL_BIT;
    *(vmfp + Reg_IMRA) |= MFP_RX_FULL_BIT;
}

void netCommDisable(void)
{
    *(vmfp + Reg_IMRA) &= (unsigned char)~MFP_RX_FULL_BIT;
    *(vmfp + Reg_IERA) &= (unsigned char)~MFP_RX_FULL_BIT;

    netHookTable[HOOK_REC_BUF_FULL].magic = 0;
    netHookTable[HOOK_REC_BUF_FULL].flags = 0;
    netHookTable[HOOK_REC_BUF_FULL].addr = 0;

    netCommFlush();
}
