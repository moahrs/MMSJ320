/********************************************************************************
*    Programa    : flashprg.c
*    Objetivo    : Gravador AT29C020 (LDS/UDS) via XMODEM-1K CRC
*    Criado em   : 19/04/2026
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
* AT29C020: gravacao direta por word (68000 UDS+LDS), setor 256 bytes.
* SDP desligado de fabrica; 1a gravacao com unlock AA/55/A0 ativa SDP permanente.
* Endereco flash >= 0x00020000 (monitor 0-1FFFF continua no Arduino Mega).
*--------------------------------------------------------------------------------*/

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "../mmsj320api.h"
#include "../mmsj320vdp.h"
#include "../mmsj320mfp.h"
#include "../monitor.h"
#include "../monitorapi.h"

#define FP_FLASH_MIN     0x00020000L
#define FP_FLASH_TOP     0x00080000L
#define FP_RAM_BASE      ((unsigned char *)0x00850000)
#define FP_RAM_MAX       0x00030000L
#define FP_SECTOR_SIZE   512

/* Unlock SDP/comando: word em endereco par -> LDS+UDS ao mesmo tempo (2x AT29C020) */
#define FP_CMD5555W ((volatile unsigned short *)0x0000AAAAUL)
#define FP_CMD2AAAW ((volatile unsigned short *)0x00005554UL)

static unsigned char fpSectorBuf[FP_SECTOR_SIZE];

static unsigned long fpHexToLong(const unsigned char *s);
static void fpPrintHex(unsigned long v);
static void fpPrintDec(unsigned long v);
static int fpReadHexAddr(unsigned long *pAddr);
static int fpAskYesNo(const unsigned char *msg);
extern void fpIntsOff(void);
extern void fpIntsOn(void);
static void fpSdpUnlock(void);
static int fpPollProgram(unsigned char *p, unsigned char data);
static int fpProgramSector(unsigned long secAddr, unsigned char *src, int useSdpUnlock);
static int fpProgramRange(unsigned long dst, unsigned char *src, unsigned long len, int useSdpUnlock);
static int fpVerifyRange(unsigned long dst, unsigned char *src, unsigned long len);
static unsigned long fpSectorBase(unsigned long addr);

static void fpPrintHex(unsigned long v)
{
    unsigned char buf[12];
    itoa(v, (char *)buf, 16);
    printText(buf);
}

static void fpPrintDec(unsigned long v)
{
    unsigned char buf[12];
    itoa(v, (char *)buf, 10);
    printText(buf);
}

static unsigned long fpHexToLong(const unsigned char *s)
{
    unsigned long v = 0;
    unsigned char c;

    while (*s == ' ' || *s == '\t')
        s++;

    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
        s += 2;

    while (*s)
    {
        c = *s++;
        if (c >= '0' && c <= '9')
            c = (unsigned char)(c - '0');
        else if (c >= 'A' && c <= 'F')
            c = (unsigned char)(c - 'A' + 10);
        else if (c >= 'a' && c <= 'f')
            c = (unsigned char)(c - 'a' + 10);
        else
            break;
        v = (v << 4) | c;
    }

    return v;
}

static int fpReadHexAddr(unsigned long *pAddr)
{
    unsigned char buf[16];
    unsigned char *p = buf;
    unsigned char c;
    int i = 0;

    buf[0] = 0;

    while (i < (int)(sizeof(buf) - 1))
    {
        c = readChar();
        if (c == 0x0D || c == 0x0A)
            break;
        if (c == 0x1B)
            return 0;
        if (c == 0x08 || c == 0x7F)
        {
            if (i > 0)
            {
                i--;
                p[i] = 0;
                printChar(0x08, 1);
            }
            continue;
        }
        if (c >= 0x20)
        {
            p[i++] = c;
            p[i] = 0;
            printChar(c, 1);
        }
    }

    printText("\r\n\0");
    *pAddr = fpHexToLong(buf);
    return (buf[0] != 0);
}

static int fpAskYesNo(const unsigned char *msg)
{
    unsigned char c;

    printText(msg);
    while (1)
    {
        c = readChar();
        if (c == 'Y' || c == 'y')
        {
            printText("Y\r\n\0");
            return 1;
        }
        if (c == 'N' || c == 'n')
        {
            printText("N\r\n\0");
            return 0;
        }
        if (c == 0x1B)
            return 0;
    }

    return 0;
}

static void fpSdpUnlock(void)
{
    *FP_CMD5555W = 0xAAAA;
    *FP_CMD2AAAW = 0x5555;
    *FP_CMD5555W = 0xA0A0;
}

/*static int fpSectorNeedsProgram(unsigned char *src)
{
    unsigned int i;

    for (i = 0; i < FP_SECTOR_SIZE; i++)
    {
        if (src[i] != 0xFF)
            return 1;
    }

    return 0;
}*/

static int fpSectorDiffers(unsigned long secAddr, unsigned char *src)
{
    unsigned int i;
    volatile unsigned char *flash = (volatile unsigned char *)secAddr;

    for (i = 0; i < FP_SECTOR_SIZE; i++)
    {
        if (flash[i] != src[i])
            return 1;
    }

    return 0;
}

static int fpPollProgramToggle(unsigned char *p)
{
    unsigned char v1;
    unsigned char v2;
    unsigned long t = 0;

    while (t < 0x00200000L)
    {
        v1 = *p;
        v2 = *p;
        if ((v1 & 0x40) != (v2 & 0x40))
        {
            t++;
            continue;
        }
        return 0;
    }

    return -2;
}

static int fpPollProgram(unsigned char *p, unsigned char data)
{
    unsigned char v1;
    unsigned char v2;
    unsigned long t = 0;

    if (data == 0xFF)
        return fpPollProgramToggle(p);

    while (t < 0x00200000L)
    {
        v1 = *p;
        if ((v1 & 0x80) == (data & 0x80))
            return 0;

        v2 = *p;
        if ((v1 & 0x40) == (v2 & 0x40))
            return -1;

        t++;
    }

    return -2;
}

/*static int fpLoadSector256(unsigned long secAddr, unsigned char *src)
{
    unsigned int i;
    unsigned char *flash = (unsigned char *)secAddr;

    // AT29C020: 256 byte loads no latch interno; depois erase+program do setor
    for (i = 0; i < FP_SECTOR_SIZE; i++)
        flash[i] = src[i];

    return fpPollProgram(flash + (FP_SECTOR_SIZE - 1), src[FP_SECTOR_SIZE - 1]);
}*/

static int fpLoadSector512(unsigned long secAddr, unsigned char *src)
{
    unsigned int i;
    volatile unsigned short *flash;
    unsigned short w;
    int r1, r2;

    flash = (volatile unsigned short *)secAddr;

    for (i = 0; i < FP_SECTOR_SIZE; i += 2)
    {
        w = ((unsigned short)src[i] << 8) |
             (unsigned short)src[i + 1];

        flash[i >> 1] = w;
    }

    r1 = fpPollProgram((unsigned char *)(secAddr + FP_SECTOR_SIZE - 2),
                       src[FP_SECTOR_SIZE - 2]);

    r2 = fpPollProgram((unsigned char *)(secAddr + FP_SECTOR_SIZE - 1),
                       src[FP_SECTOR_SIZE - 1]);

    if (r1 || r2)
        return -1;

    return 0;
}

static int fpProgramSector(unsigned long secAddr, unsigned char *src, int useSdpUnlock)
{
    if (!fpSectorDiffers(secAddr, src))
        return 0;

    if (useSdpUnlock)
        fpSdpUnlock();

    if (fpLoadSector512(secAddr, src))
        return -1;

    delayms(12);
    return 0;
}

static unsigned long fpSectorBase(unsigned long addr)
{
    return addr & ~(unsigned long)(FP_SECTOR_SIZE - 1);
}

static int fpProgramRange(unsigned long dst, unsigned char *src, unsigned long len, int useSdpUnlock)
{
    unsigned long sec;
    unsigned long secEnd;
    unsigned long end;
    unsigned long off;
    unsigned long imgEnd;

    if (dst & 1)
        return -10;

    end = fpSectorBase(dst + len - 1);
    imgEnd = dst + len;

    for (sec = fpSectorBase(dst); sec <= end; sec += FP_SECTOR_SIZE)
    {
        secEnd = sec + FP_SECTOR_SIZE;

        for (off = 0; off < FP_SECTOR_SIZE; off++)
            fpSectorBuf[off] = 0xFF;

        if (sec < dst)
            off = dst - sec;
        else
            off = 0;

        while (off < FP_SECTOR_SIZE && (sec + off) < imgEnd)
        {
            fpSectorBuf[off] = src[(sec + off) - dst];
            off++;
        }

        if ((sec & 0x3FFF) == 0)
        {
            printText("Sector 0x\0");
            fpPrintHex(sec);
            printText("\r\n\0");
        }

        if (fpProgramSector(sec, fpSectorBuf, useSdpUnlock))
            return -1;
    }

    return 0;
}

static int fpVerifyRange(unsigned long dst, unsigned char *src, unsigned long len)
{
    unsigned long i;
    unsigned char rv;

    for (i = 0; i < len; i++)
    {
        rv = *((unsigned char *)(dst + i));
        if (rv != src[i])
        {
            printText("Verify fail 0x\0");
            fpPrintHex(dst + i);
            printText(" wr=\0");
            fpPrintHex(src[i]);
            printText(" rd=\0");
            fpPrintHex(rv);
            printText("\r\n\0");
            return -1;
        }
    }

    return 0;
}

void main(void)
{
    unsigned long flashAddr = 0;
    unsigned long imgSize = 0;
    unsigned char loadRet;
    int useSdp = 0;
    int st;

    printText("\r\nMMSJ320 Flash Programmer (AT29C020)\r\n\0");
    printText("Sector load 256 bytes, addr >= 0x20000\r\n\0");

    printText("Flash start address (hex, even): \0");
    if (!fpReadHexAddr(&flashAddr))
    {
        printText("Aborted.\r\n\0");
        return;
    }

    useSdp = 1;

    if (flashAddr < FP_FLASH_MIN)
    {
        printText("Error: address < 0x20000\r\n\0");
        return;
    }

    if (flashAddr >= FP_FLASH_TOP)
    {
        printText("Error: address out of ROM\r\n\0");
        return;
    }

    if (flashAddr & 1)
    {
        printText("Error: address must be even\r\n\0");
        return;
    }

    printText("Target 0x\0");
    fpPrintHex(flashAddr);
    printText(" SDP=\0");
    printText(useSdp ? "ON\r\n\0" : "OFF\r\n\0");
    printText("RAM 0x\0");
    fpPrintHex((unsigned long)FP_RAM_BASE);
    printText("\r\nStart XMODEM now...\r\n\0");

    loadRet = loadSerialToMem2(FP_RAM_BASE, 1);

    if (loadRet != 0)
    {
        printText("XMODEM error \0");
        fpPrintHex(loadRet);
        printText("\r\n\0");
        return;
    }

    imgSize = lstmGetSize();

    if (imgSize == 0)
    {
        printText("Empty image.\r\n\0");
        return;
    }

    if (imgSize > FP_RAM_MAX)
    {
        printText("Image too big for RAM buffer.\r\n\0");
        return;
    }

    if ((flashAddr + imgSize) > FP_FLASH_TOP)
    {
        printText("Image does not fit in ROM.\r\n\0");
        return;
    }

    printText("Received \0");
    fpPrintDec(imgSize);
    printText(" bytes. Programming...\r\n\0");

    fpIntsOff();
    delayms(6);

    st = fpProgramRange(flashAddr, FP_RAM_BASE, imgSize, useSdp);

    if (st == 0)
        st = fpVerifyRange(flashAddr, FP_RAM_BASE, imgSize);

    fpIntsOn();

    if (st)
    {
        printText("Flash failed.\r\n\0");
        return;
    }

    printText("Flash OK. \0");
    fpPrintDec(imgSize);
    printText(" bytes at 0x\0");
    fpPrintHex(flashAddr);
    printText("\r\n\0");

    if (useSdp)
        printText("SDP enabled. Use unlock AA/55/A0 before each sector.\r\n\0");
}