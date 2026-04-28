ENTRY(start)

PHDRS
{
    text PT_LOAD FLAGS(5); /* R-X */
    data PT_LOAD FLAGS(6); /* RW- */
}

SECTIONS
{
    PROVIDE(__TEXT_ORIGIN = 0x00800000);

    .text __TEXT_ORIGIN :
    {
        *(code)
        *(.text*)
    } :text

    .rodata :
    {
        *(const)
        *(.rodata*)
    } :text

    .data :
    {
        __data_start = .;
        *(data)
        *(.data*)
        __data_end = .;
    } :data

    .bss 0x008D1000 (NOLOAD) :
    {
        __bss_start = .;
        *(bss)
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } :data

    __stack = .;
    __ungetbuf = __stack;

    .heap 0x00820000 (NOLOAD) :
    {
        heap = .;
        *(heap)
        *(.heap)
        . = 0x00050000;
        heap_end = . - 1;
    } :data
}
