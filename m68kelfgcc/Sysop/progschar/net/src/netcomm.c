#include <string.h>
#include "netcomm.h"

static NET_HOOK *netHookTable = (NET_HOOK *)0x0060F7BC;

typedef void *(*NET_MSMALLOC_TYPE)(unsigned long size);
typedef void (*NET_MSFREE_TYPE)(void *ptr);

#define NET_MMSJOS_FUNC_TABLE 0x00800034UL
#define netMsMalloc ((NET_MSMALLOC_TYPE *)(unsigned long)NET_MMSJOS_FUNC_TABLE)[27]
#define netMsFree   ((NET_MSFREE_TYPE *)(unsigned long)NET_MMSJOS_FUNC_TABLE)[29]

extern unsigned char netCommRxHookResidentStart[];
extern unsigned char netCommRxHookResidentEnd[];

static void netCopyHookCode(unsigned char *dst, unsigned char *src, unsigned long size)
{
    while (size)
    {
        *dst++ = *src++;
        size--;
    }
}

static void *netCommEnsureResidentHook(void)
{
    unsigned long size;
    unsigned char *mem;

    if (netApiMagic == NETAPI_MAGIC_VALUE && netApiEnabled && netApiHookMem != 0)
        return (void *)netApiHookMem;

    if (netApiMagic == NETAPI_MAGIC_VALUE && !netApiEnabled)
    {
        netApiHookMem = 0;
        netApiHookSize = 0;
        netApiMagic = 0;
    }

    size = (unsigned long)(netCommRxHookResidentEnd - netCommRxHookResidentStart);
    mem = (unsigned char *)netMsMalloc(size);
    if (!mem)
        return 0;

    netCopyHookCode(mem, netCommRxHookResidentStart, size);

    netApiMagic = NETAPI_MAGIC_VALUE;
    netApiHookMem = (unsigned long)mem;
    netApiHookSize = size;
    netApiHookCount = 0;
    netApiLastByte = 0;
    netApiEnabled = 0;

    return mem;
}

void netCommInstallHook(int hookNum, void (*func)(void))
{
    netHookTable[hookNum].addr   = func;
    netHookTable[hookNum].flags  = HOOKF_ACTIVE | HOOKF_SKIP_OS;
    netHookTable[hookNum].magic  = HOOK_MAGIC;
}

void netCommFlush(void)
{
    volatile unsigned char dummy;

    serRxHead = 0;
    serRxTail = 0;
    serRxLost = 0;
    netApiHookCount = 0;
    netApiLastByte = 0;

    while (*(vmfp + Reg_RSR) & 0x80)
    {
        dummy = *(vmfp + Reg_UDR);
    }
}

void netCommRxHook(void)
{
    unsigned char c;
    unsigned int next;

    c = *(vmfp + Reg_UDR);
    netApiLastByte = c;
    netApiHookCount++;

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
    void *hookMem;

    hookMem = netCommEnsureResidentHook();
    if (!hookMem)
        return;

    *(vmfp + Reg_IMRA) &= (unsigned char)~MFP_RX_FULL_BIT;
    *(vmfp + Reg_IERA) &= (unsigned char)~MFP_RX_FULL_BIT;
    netCommFlush();

    netApiMagic = NETAPI_MAGIC_VALUE;
    netCommInstallHook(HOOK_REC_BUF_FULL, (void (*)(void))hookMem);

    *(vmfp + Reg_IERA) |= MFP_RX_FULL_BIT;
    *(vmfp + Reg_IMRA) |= MFP_RX_FULL_BIT;
    netApiEnabled = 1;
}

void netCommDisable(void)
{
    *(vmfp + Reg_IMRA) &= (unsigned char)~MFP_RX_FULL_BIT;
    *(vmfp + Reg_IERA) &= (unsigned char)~MFP_RX_FULL_BIT;

    netHookTable[HOOK_REC_BUF_FULL].magic = 0;
    netHookTable[HOOK_REC_BUF_FULL].flags = 0;
    netHookTable[HOOK_REC_BUF_FULL].addr = 0;

    netCommFlush();

    if (netApiMagic == NETAPI_MAGIC_VALUE && netApiHookMem != 0)
    {
        netMsFree((void *)netApiHookMem);
        netApiHookMem = 0;
        netApiHookSize = 0;
    }

    netApiEnabled = 0;
    netApiMagic = 0;
}
