#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define RT_FONTDIR 0x8007
#define RT_FONT    0x8008

typedef unsigned char  U8;
typedef unsigned short U16;
typedef unsigned long  U32;

typedef struct
{
    U32 fonFileOffset;
    U32 fonFileSize;

    U32 fntOffset;
    U32 fntSize;

    U16 dfVersion;
    U32 dfSize;

    U16 dfPixWidth;
    U16 dfPixHeight;
    U16 dfWidthBytes;
    U16 dfMaxWidth;

    U8  dfFirstChar;
    U8  dfLastChar;
    U8  dfDefaultChar;
    U8  dfBreakChar;

    U32 dfBitsOffset;
    U32 bitsFileOffset;

    U16 alignShift;
} FON_INFO;

static U16 rd16(U8 *p)
{
    return (U16)p[0] | ((U16)p[1] << 8);
}

static U32 rd32(U8 *p)
{
    return (U32)p[0] |
           ((U32)p[1] << 8) |
           ((U32)p[2] << 16) |
           ((U32)p[3] << 24);
}

static U8 *load_file(const char *name, U32 *size)
{
    FILE *fp;
    U8 *buf;
    long sz;

    fp = fopen(name, "rb");
    if (!fp)
        return NULL;

    fseek(fp, 0, SEEK_END);
    sz = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    if (sz <= 0)
    {
        fclose(fp);
        return NULL;
    }

    buf = (U8 *)malloc((unsigned long)sz);
    if (!buf)
    {
        fclose(fp);
        return NULL;
    }

    if (fread(buf, 1, (unsigned long)sz, fp) != (unsigned long)sz)
    {
        free(buf);
        fclose(fp);
        return NULL;
    }

    fclose(fp);

    *size = (U32)sz;
    return buf;
}

int fon_find_first_font(U8 *file, U32 fileSize, FON_INFO *info)
{
    U32 neOffset;
    U32 resTable;
    U16 alignShift;
    U32 p;
    U16 typeId;
    U16 count;
    U32 i;

    U16 rnOffset;
    U16 rnLength;
    U32 realOffset;
    U32 realLength;

    U8 *fnt;

    memset(info, 0, sizeof(FON_INFO));

    if (fileSize < 0x40)
        return 1;

    if (file[0] != 'M' || file[1] != 'Z')
        return 2;

    neOffset = rd32(file + 0x3C);

    if (neOffset + 0x40 >= fileSize)
        return 3;

    if (file[neOffset] != 'N' || file[neOffset + 1] != 'E')
        return 4;

    /*
       NE + 0x24 = offset da Resource Table,
       relativo ao começo do NE.
    */
    resTable = neOffset + rd16(file + neOffset + 0x24);

    if (resTable + 2 >= fileSize)
        return 5;

    alignShift = rd16(file + resTable);
    p = resTable + 2;

    info->alignShift = alignShift;

    while (p + 8 < fileSize)
    {
        typeId = rd16(file + p);
        p += 2;

        if (typeId == 0x0000)
            break;

        count = rd16(file + p);
        p += 2;

        /*
           DWORD reserved
        */
        p += 4;

        for (i = 0; i < count; i++)
        {
            if (p + 12 > fileSize)
                return 6;

            rnOffset = rd16(file + p + 0);
            rnLength = rd16(file + p + 2);

            realOffset = ((U32)rnOffset) << alignShift;
            realLength = ((U32)rnLength) << alignShift;

            if (typeId == RT_FONT)
            {
                if (realOffset + realLength > fileSize)
                    return 0;

                info->fonFileOffset = realOffset;
                info->fonFileSize   = realLength;

                info->fntOffset = realOffset;
                info->fntSize   = realLength;

                fnt = file + realOffset;

                /*
                   Header FNT Windows 2.x/3.x bitmap.
                   Offsets relativos ao começo do FNT.
                */
                info->dfVersion     = rd16(fnt + 0x00);
                info->dfSize        = rd32(fnt + 0x02);

                info->dfPixWidth    = rd16(fnt + 0x56);
                info->dfPixHeight   = rd16(fnt + 0x58);
                info->dfMaxWidth    = rd16(fnt + 0x5D);

                info->dfFirstChar   = fnt[0x5F];
                info->dfLastChar    = fnt[0x60];
                info->dfDefaultChar = fnt[0x61];
                info->dfBreakChar   = fnt[0x62];

                info->dfWidthBytes  = rd16(fnt + 0x63);

                info->dfBitsOffset  = rd32(fnt + 0x71);
                info->bitsFileOffset = realOffset + info->dfBitsOffset;

                if (info->bitsFileOffset >= fileSize)
                    return 7;

                return 0;
            }

            /*
               cada resource entry tem 12 bytes
            */
            p += 12;
        }
    }

    return 9;
}

int main(int argc, char **argv)
{
    U8 *buf;
    U32 size;
    FON_INFO fi;

    if (argc < 2)
    {
        printf("Uso: %s arquivo.fon\n", argv[0]);
        return 1;
    }

    buf = load_file(argv[1], &size);
    if (!buf)
    {
        printf("Erro lendo arquivo.\n");
        return 1;
    }

    int verro = fon_find_first_font(buf, size, &fi);

    if (verro)
    {
        printf("Fonte nao encontrada. erro %d\n", verro);
        free(buf);
        return 1;
    }

    printf("FNT offset      : 0x%08lX\n", fi.fntOffset);
    printf("FNT size        : 0x%08lX\n", fi.fntSize);
    printf("align shift     : %u\n", fi.alignShift);

    printf("dfVersion       : 0x%04X\n", fi.dfVersion);
    printf("dfSize          : %lu\n", fi.dfSize);

    printf("width           : %u\n", fi.dfPixWidth);
    printf("height          : %u\n", fi.dfPixHeight);
    printf("max width       : %u\n", fi.dfMaxWidth);
    printf("width bytes     : %u\n", fi.dfWidthBytes);

    printf("first char      : 0x%02X\n", fi.dfFirstChar);
    printf("last char       : 0x%02X\n", fi.dfLastChar);

    printf("bits offset FNT : 0x%08lX\n", fi.dfBitsOffset);
    printf("bits offset file: 0x%08lX\n", fi.bitsFileOffset);

    free(buf);
    return 0;
}
