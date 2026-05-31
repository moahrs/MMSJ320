#ifndef NETAPI_H
#define NETAPI_H

/* Area fixa compartilhada entre programas relocaveis.
   Comeca apos o hookTable do monitor.c (0x0060F7BC..0x0060F954). */

#define NETAPI_MAGIC_VALUE       0x4E455431UL   // NET1

#define NETAPI_BASE_ADDR         0x0060F960UL
#define NETAPI_MAGIC_ADDR        0x0060F960UL
#define NETAPI_HOOK_MEM_ADDR     0x0060F964UL
#define NETAPI_HOOK_SIZE_ADDR    0x0060F968UL
#define NETAPI_RX_HEAD_ADDR      0x0060F96CUL
#define NETAPI_RX_TAIL_ADDR      0x0060F96EUL
#define NETAPI_RX_LOST_ADDR      0x0060F970UL
#define NETAPI_ENABLED_ADDR      0x0060F972UL
#define NETAPI_HOOK_COUNT_ADDR   0x0060F974UL
#define NETAPI_LAST_BYTE_ADDR    0x0060F978UL
#define NETAPI_RX_BUF_ADDR       0x0060F980UL

#define NETAPI_RX_SIZE           4096

#define netApiMagic              (*(volatile unsigned long *)NETAPI_MAGIC_ADDR)
#define netApiHookMem            (*(volatile unsigned long *)NETAPI_HOOK_MEM_ADDR)
#define netApiHookSize           (*(volatile unsigned long *)NETAPI_HOOK_SIZE_ADDR)
#define netApiEnabled            (*(volatile unsigned char *)NETAPI_ENABLED_ADDR)
#define netApiHookCount          (*(volatile unsigned long *)NETAPI_HOOK_COUNT_ADDR)
#define netApiLastByte           (*(volatile unsigned char *)NETAPI_LAST_BYTE_ADDR)

#define serRxHead                (*(volatile unsigned short *)NETAPI_RX_HEAD_ADDR)
#define serRxTail                (*(volatile unsigned short *)NETAPI_RX_TAIL_ADDR)
#define serRxLost                (*(volatile unsigned short *)NETAPI_RX_LOST_ADDR)
#define serRxBuf                 ((volatile unsigned char *)NETAPI_RX_BUF_ADDR)

#endif
