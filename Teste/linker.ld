ENTRY(_start)

MEMORY
{
    ROM (rx) : ORIGIN = 0x000000, LENGTH = 0x10000
    ROMINT (rx) : ORIGIN = 0x000280
    ROMMAIN (rx) : ORIGIN = 0x000400
    RAMSYS (rw) : ORIGIN = 0x600000, LENGTH = 0x2FFFF
    RAM (rw) : ORIGIN = 0x818000, LENGTH = 0xE7FFF
}

SECTIONS
{
    .text (READONLY) : {
        _start = .;        /* Label de início */
        *(.text)           /* Incluir todas as seções .text */
        *(.text.*)
        *(.rodata)         /* Dados de somente leitura */
        *(.rodata.*)
        _end = .;          /* Label de fim */
    } > ROM           /* Apenas leitura e execução */

    .interrupt (READONLY) : {
        _startinterr = .;        /* Label de início */
        *(.text)           /* Incluir todas as seções .text */
        *(.text.*)
        _endinterr = .;          /* Label de fim */
    } > ROMINT           /* Apenas leitura e execução */

    .mainprog (READONLY) : {
        _startmain = .;        /* Label de início */
        *(.text)           /* Incluir todas as seções .text */
        *(.text.*)
        _endmain = .;          /* Label de fim */
    } > ROMMAIN           /* Apenas leitura e execução */

    /* Ignorando .data, nenhuma alocação para variáveis inicializadas */
    /* .data é omitido */

    .bss : ALIGN(4) {
        _bss_start = .;        /* Início do .bss */
        *(.bss)
        *(.bss.*)
        _bss_end = .;          /* Fim do .bss */
    } > RAMSYS

    /* Heap para malloc */
    .heap (NOLOAD) : {
        _heap_start = .;
        . = . + 0x1000;        /* Tamanho do heap */
        _heap_end = .;
    } > RAM
}
