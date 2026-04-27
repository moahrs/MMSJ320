ENTRY(start)

PHDRS
{
    text PT_LOAD FLAGS(5); /* R-X */
    data PT_LOAD FLAGS(6); /* RW- */
}

SECTIONS
{
    /* Endereco de carga do codigo (pode ser sobrescrito via --defsym=__TEXT_ORIGIN=...) */
    PROVIDE(__TEXT_ORIGIN = 0x00870000);

    .text __TEXT_ORIGIN : { *(.text*) } :text
    .rodata : { *(.rodata*) } :text

    /* .data roda em RAM e eh carregado a partir da imagem em flash */
    .data 0x00617000 : AT(ADDR(.rodata) + SIZEOF(.rodata))
    {
        __data_start = .;
        *(.data*)
        __data_end = .;
    } :data
    __data_load_start = LOADADDR(.data);
    __data_load_end = LOADADDR(.data) + SIZEOF(.data);

    .bss 0x00618000 (NOLOAD) :
    {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } :data

    __stack = 0x00619000;
    __ungetbuf = __stack;
    heap = 0x008F0000;

    .heap 0x008F0000 (NOLOAD) : { *(.heap) } :data
}
