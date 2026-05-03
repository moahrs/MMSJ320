ENTRY(start)

PHDRS
{
    text PT_LOAD FLAGS(5);
    data PT_LOAD FLAGS(6);
}

SECTIONS
{
    PROVIDE(__TEXT_ORIGIN = 0x00880000);

    .text __TEXT_ORIGIN : { *(.text*) } :text
    .rodata : { *(.rodata*) } :text

    .data 0x0062C000 : AT(ADDR(.rodata) + SIZEOF(.rodata))
    {
        __data_start = .;
        *(.data*)
        __data_end = .;
    } :data
    __data_load_start = LOADADDR(.data);
    __data_load_end = LOADADDR(.data) + SIZEOF(.data);

    .bss 0x0062C800 (NOLOAD) :
    {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } :data

    __stack = 0x0062E000;
    __ungetbuf = __stack;
    heap = 0x00840000;

    .heap 0x00840000 (NOLOAD) : { *(.heap) } :data
}