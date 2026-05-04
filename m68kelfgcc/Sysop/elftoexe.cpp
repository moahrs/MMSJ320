/* elf2exe_bcc.c
   Compativel com Borland C++ 5.5 Win32

   Uso:
     bcc32 elf2exe_bcc.c
     elf2exe_bcc files.elf files.exe
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define EI_NIDENT 16

#define SHT_PROGBITS 1
#define SHT_NOBITS   8
#define SHT_RELA 4
#define SHT_REL  9
#define R_68K_32 1

#define SHF_ALLOC    0x2

typedef unsigned char  U8;
typedef unsigned short U16;
typedef unsigned long  U32;

typedef struct
{
    U8  e_ident[EI_NIDENT];
    U16 e_type;
    U16 e_machine;
    U32 e_version;
    U32 e_entry;
    U32 e_phoff;
    U32 e_shoff;
    U32 e_flags;
    U16 e_ehsize;
    U16 e_phentsize;
    U16 e_phnum;
    U16 e_shentsize;
    U16 e_shnum;
    U16 e_shstrndx;
} ELF32_EHDR;

typedef struct
{
    U32 sh_name;
    U32 sh_type;
    U32 sh_flags;
    U32 sh_addr;
    U32 sh_offset;
    U32 sh_size;
    U32 sh_link;
    U32 sh_info;
    U32 sh_addralign;
    U32 sh_entsize;
} ELF32_SHDR;

static U16 be16(U8 *p)
{
    return ((U16)p[0] << 8) | (U16)p[1];
}

static U32 be32(U8 *p)
{
    return ((U32)p[0] << 24) |
           ((U32)p[1] << 16) |
           ((U32)p[2] << 8)  |
           ((U32)p[3]);
}

static void wr_be32(FILE *f, U32 v)
{
    U8 b[4];

    b[0] = (U8)((v >> 24) & 0xFF);
    b[1] = (U8)((v >> 16) & 0xFF);
    b[2] = (U8)((v >> 8) & 0xFF);
    b[3] = (U8)(v & 0xFF);

    fwrite(b, 1, 4, f);
}

static int read_file(FILE *f, long off, void *buf, U32 size)
{
    if (fseek(f, off, SEEK_SET) != 0)
        return 0;

    if (fread(buf, 1, size, f) != size)
        return 0;

    return 1;
}

static int cmp_u32(const void *a, const void *b)
{
    U32 aa;
    U32 bb;

    aa = *(U32 *)a;
    bb = *(U32 *)b;

    if (aa < bb)
        return -1;

    if (aa > bb)
        return 1;

    return 0;
}

static void parse_ehdr(U8 *b, ELF32_EHDR *e)
{
    memcpy(e->e_ident, b, EI_NIDENT);

    e->e_type      = be16(b + 16);
    e->e_machine   = be16(b + 18);
    e->e_version   = be32(b + 20);
    e->e_entry     = be32(b + 24);
    e->e_phoff     = be32(b + 28);
    e->e_shoff     = be32(b + 32);
    e->e_flags     = be32(b + 36);
    e->e_ehsize    = be16(b + 40);
    e->e_phentsize = be16(b + 42);
    e->e_phnum     = be16(b + 44);
    e->e_shentsize = be16(b + 46);
    e->e_shnum     = be16(b + 48);
    e->e_shstrndx  = be16(b + 50);
}

static void parse_shdr(U8 *b, ELF32_SHDR *s)
{
    s->sh_name      = be32(b + 0);
    s->sh_type      = be32(b + 4);
    s->sh_flags     = be32(b + 8);
    s->sh_addr      = be32(b + 12);
    s->sh_offset    = be32(b + 16);
    s->sh_size      = be32(b + 20);
    s->sh_link      = be32(b + 24);
    s->sh_info      = be32(b + 28);
    s->sh_addralign = be32(b + 32);
    s->sh_entsize   = be32(b + 36);
}

static int add_reloc(U32 **arr, U32 *count, U32 *cap, U32 off)
{
    U32 newcap;
    U32 *p;

    if (*count < *cap)
    {
        (*arr)[*count] = off;
        (*count)++;
        return 1;
    }

    if (*cap == 0)
        newcap = 128;
    else
        newcap = (*cap) * 2;

    p = (U32 *)realloc(*arr, newcap * sizeof(U32));

    if (!p)
        return 0;

    *arr = p;
    *cap = newcap;

    (*arr)[*count] = off;
    (*count)++;

    return 1;
}

int main(int argc, char **argv)
{
    FILE *fi;
    FILE *fo;

    U8 ehbuf[52];
    ELF32_EHDR eh;

    ELF32_SHDR *sh;
    U8 *shbuf;
    U8 *image;

    U32 imageSize;
    U32 bssStart;
    U32 bssEnd;
    U32 i;
    U32 j;
    U32 n;
    U32 end;
    U32 start;
    U32 r_offset;
    U32 r_info;
    U32 rtype;
    U32 w;

    U32 *relocs;
    U32 relocCount;
    U32 relocCap;

    U8 rbuf[12];

    if (argc != 3)
    {
        printf("Uso: elf2exe input.elf output.exe\n");
        return 1;
    }

    fi = fopen(argv[1], "rb");

    if (!fi)
    {
        printf("Erro abrindo ELF: %s\n", argv[1]);
        return 1;
    }

    if (!read_file(fi, 0, ehbuf, 52))
    {
        printf("Erro lendo ELF header\n");
        fclose(fi);
        return 1;
    }

    parse_ehdr(ehbuf, &eh);

    if (eh.e_ident[0] != 0x7F ||
        eh.e_ident[1] != 'E' ||
        eh.e_ident[2] != 'L' ||
        eh.e_ident[3] != 'F')
    {
        printf("Arquivo nao eh ELF\n");
        fclose(fi);
        return 1;
    }

    if (eh.e_ident[4] != 1)
    {
        printf("ELF nao eh 32 bits\n");
        fclose(fi);
        return 1;
    }

    if (eh.e_ident[5] != 2)
    {
        printf("ELF nao eh big-endian\n");
        fclose(fi);
        return 1;
    }

    if (eh.e_machine != 4)
    {
        printf("ELF nao parece ser m68k. e_machine=%lu\n", eh.e_machine);
        fclose(fi);
        return 1;
    }

    sh = (ELF32_SHDR *)calloc(eh.e_shnum, sizeof(ELF32_SHDR));

    if (!sh)
    {
        fclose(fi);
        return 1;
    }

    shbuf = (U8 *)malloc(eh.e_shentsize);

    if (!shbuf)
    {
        free(sh);
        fclose(fi);
        return 1;
    }

    for (i = 0; i < eh.e_shnum; i++)
    {
        if (!read_file(fi,
                       eh.e_shoff + (long)i * eh.e_shentsize,
                       shbuf,
                       eh.e_shentsize))
        {
            printf("Erro lendo section header\n");
            free(shbuf);
            free(sh);
            fclose(fi);
            return 1;
        }

        parse_shdr(shbuf, &sh[i]);
    }

    free(shbuf);

    imageSize = 0;
    bssStart = 0xFFFFFFFFUL;
    bssEnd = 0;

    for (i = 0; i < eh.e_shnum; i++)
    {
        if ((sh[i].sh_flags & SHF_ALLOC) == 0)
            continue;

        if (sh[i].sh_type == SHT_PROGBITS)
        {
            end = sh[i].sh_addr + sh[i].sh_size;

            if (end > imageSize)
                imageSize = end;
        }
        else if (sh[i].sh_type == SHT_NOBITS)
        {
            start = sh[i].sh_addr;
            end = sh[i].sh_addr + sh[i].sh_size;

            if (start < bssStart)
                bssStart = start;

            if (end > bssEnd)
                bssEnd = end;
        }
    }

    if (imageSize == 0)
    {
        printf("Nenhuma section PROGBITS alocavel encontrada\n");
        free(sh);
        fclose(fi);
        return 1;
    }

    if (bssStart == 0xFFFFFFFFUL)
    {
        bssStart = imageSize;
        bssEnd = imageSize;
    }

    image = (U8 *)calloc(1, imageSize);

    if (!image)
    {
        free(sh);
        fclose(fi);
        return 1;
    }

    for (i = 0; i < eh.e_shnum; i++)
    {
        if ((sh[i].sh_flags & SHF_ALLOC) == 0)
            continue;

        if (sh[i].sh_type == SHT_PROGBITS)
        {
            if (sh[i].sh_addr + sh[i].sh_size > imageSize)
            {
                printf("Section fora da imagem\n");
                free(image);
                free(sh);
                fclose(fi);
                return 1;
            }

            if (!read_file(fi,
                           sh[i].sh_offset,
                           image + sh[i].sh_addr,
                           sh[i].sh_size))
            {
                printf("Erro lendo section PROGBITS\n");
                free(image);
                free(sh);
                fclose(fi);
                return 1;
            }
        }
    }

    relocs = NULL;
    relocCount = 0;
    relocCap = 0;

    for (i = 0; i < eh.e_shnum; i++)
    {
        if (sh[i].sh_type != SHT_REL && sh[i].sh_type != SHT_RELA)
            continue;

        if (sh[i].sh_entsize == 0)
            continue;

        /* ignora reloc de debug; pega só reloc que aplica em section ALLOC */
        if (sh[i].sh_info >= eh.e_shnum)
            continue;

        if ((sh[sh[i].sh_info].sh_flags & SHF_ALLOC) == 0)
            continue;

        n = sh[i].sh_size / sh[i].sh_entsize;

        for (j = 0; j < n; j++)
        {
            if (!read_file(fi,
                        sh[i].sh_offset + (long)j * sh[i].sh_entsize,
                        rbuf,
                        sh[i].sh_entsize))
            {
                printf("Erro lendo relocation\n");
                free(relocs);
                free(image);
                free(sh);
                fclose(fi);
                return 1;
            }

            r_offset = be32(rbuf + 0);
            r_info   = be32(rbuf + 4);

            rtype = r_info & 0xFF;

            if (rtype == R_68K_32)
            {
                if (r_offset < imageSize)
                {
                    if (!add_reloc(&relocs, &relocCount, &relocCap, r_offset))
                    {
                        printf("Sem memoria para reloc table\n");
                        free(relocs);
                        free(image);
                        free(sh);
                        fclose(fi);
                        return 1;
                    }
                }
            }
        }
    }

    if (relocCount > 1)
    {
        qsort(relocs, relocCount, sizeof(U32), cmp_u32);

        w = 0;

        for (i = 0; i < relocCount; i++)
        {
            if (i == 0 || relocs[i] != relocs[i - 1])
            {
                relocs[w] = relocs[i];
                w++;
            }
        }

        relocCount = w;
    }

    fo = fopen(argv[2], "wb");

    if (!fo)
    {
        printf("Erro criando MBIN: %s\n", argv[2]);
        free(relocs);
        free(image);
        free(sh);
        fclose(fi);
        return 1;
    }

    fwrite("EXE ", 1, 4, fo);

    wr_be32(fo, 1);
    wr_be32(fo, imageSize);
    wr_be32(fo, bssEnd - imageSize);
    wr_be32(fo, eh.e_entry);
    wr_be32(fo, relocCount);

    fwrite(image, 1, imageSize, fo);

    for (i = 0; i < relocCount; i++)
        wr_be32(fo, relocs[i]);

    fclose(fo);
    fclose(fi);

    printf("MBIN gerado: %s\n", argv[2]);
    printf("entry     : 0x%08lX\n", eh.e_entry);
    printf("text/data : %lu bytes\n", imageSize);
    printf("bss       : %lu bytes\n", bssEnd - imageSize);
    printf("relocs    : %lu\n", relocCount);

    free(relocs);
    free(image);
    free(sh);

    return 0;
}