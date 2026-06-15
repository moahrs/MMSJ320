#ifndef NETCOMM_RUNTIME_H
#define NETCOMM_RUNTIME_H

#include "mmsj320mfp.h"
#include "netapi.h"

#ifndef HOOK_REC_BUF_FULL
#define HOOK_REC_BUF_FULL 31
#endif

#ifndef HOOK_MAGIC
#define HOOK_MAGIC 0x4D4A
#endif

#ifndef HOOKF_ACTIVE
#define HOOKF_ACTIVE 1
#endif

#ifndef HOOKF_SKIP_OS
#define HOOKF_SKIP_OS 2
#endif

#ifndef SER_RX_SIZE
#define SER_RX_SIZE NETAPI_RX_SIZE
#endif

#ifndef MFP_RX_FULL_BIT
#define MFP_RX_FULL_BIT 0x10
#endif

typedef struct
{
    unsigned long magic;
    unsigned long flags;
    void (*addr)(void);
} NET_HOOK;

void netCommInstallHook(int hookNum, void (*func)(void));
void netCommEnable(void);
void netCommDisable(void);
void netCommFlush(void);
void netCommResetInput(void);
int  netCommGet(unsigned char *c);
int  netCommWait(unsigned char *c, unsigned long timeoutSpin);
void netCommRxHook(void);

#endif
