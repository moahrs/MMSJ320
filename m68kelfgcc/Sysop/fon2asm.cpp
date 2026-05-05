/*
   fon2asm.cpp

   Uso:
      fon2asm fonte5x8.fon fonte5x8.a68 _fontesMatrix5x8 0x065A
*/

#include <stdio.h>
#include <stdlib.h>

#define NUM_CHARS 256
#define BYTES_PER_CHAR 8

static const char *char_comment(int c)
{
    static char buf[32];

    if (c == 0x20)
        return "Blank";

    if (c >= 0x21 && c <= 0x7E)
    {
        sprintf(buf, "%c", c);
        return buf;
    }

    sprintf(buf, "0x%02X", c);
    return buf;
}

int main(int argc, char *argv[])
{
    FILE *fin;
    FILE *fout;
    long offset;
    unsigned char font[NUM_CHARS][BYTES_PER_CHAR];
    int c;
    int y;

    int invert_bits = 0;
    int invert_lines = 0;

    if (argc < 5)
    {
        printf("Uso:\n");
        printf("  %s entrada.fon saida.a68 label offset\n", argv[0]);
        printf("\nExemplo:\n");
        printf("  %s system5x8.fon font5x8.a68 _fontesMatrix5x8 0x065A\n", argv[0]);
        return 1;
    }

    offset = strtol(argv[4], NULL, 0);

    fin = fopen(argv[1], "rb");
    if (!fin)
    {
        printf("Erro abrindo entrada.\n");
        return 1;
    }

    fout = fopen(argv[2], "w");
    if (!fout)
    {
        printf("Erro criando saida.\n");
        fclose(fin);
        return 1;
    }

    if (fseek(fin, offset, SEEK_SET) != 0)
    {
        printf("Erro no fseek.\n");
        fclose(fin);
        fclose(fout);
        return 1;
    }

    if (fread(font, 1, NUM_CHARS * BYTES_PER_CHAR, fin) !=
        NUM_CHARS * BYTES_PER_CHAR)
    {
        printf("Erro lendo fonte.\n");
        fclose(fin);
        fclose(fout);
        return 1;
    }

    fprintf(fout, "%s:\n", argv[3]);
    fprintf(fout, "\t; Dados da Fonte extraida de %s\n\n", argv[1]);
    fprintf(fout, "\t; font data\n");

    for (c = 0; c < NUM_CHARS; c++)
    {
        fprintf(fout, "\tdc.b ");

        for (y = 0; y < BYTES_PER_CHAR; y++)
        {
            int src_y;
            unsigned char b;

            src_y = invert_lines ? (BYTES_PER_CHAR - 1 - y) : y;
            b = font[c][src_y];

            if (invert_bits)
            {
                unsigned char r;
                int i;

                r = 0;
                for (i = 0; i < 8; i++)
                {
                    r <<= 1;
                    r |= b & 1;
                    b >>= 1;
                }

                b = r;
            }

            fprintf(fout, "$%02X", b);

            if (y < BYTES_PER_CHAR - 1)
                fprintf(fout, ",");
        }

        if (c == 0x20)
            fprintf(fout, " ; 0x%02X : Blank\n", c);
        else if (c >= 0x21 && c <= 0x7E)
            fprintf(fout, " ; %c\n", c);
        else
            fprintf(fout, " ; 0x%02X\n", c);
    }

    fclose(fin);
    fclose(fout);

    printf("Arquivo gerado: %s\n", argv[2]);
    return 0;
}