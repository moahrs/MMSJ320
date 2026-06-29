ENTRY(start)

PHDRS
{
    text PT_LOAD FLAGS(5);
    data PT_LOAD FLAGS(6);
}

SECTIONS
{
    .text 0x00000000 :
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

    .bss 0x00600400 (NOLOAD) :
    {
        __bss_start = .;
        *(bss)
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } :data

    __stack = 0x00600400;
    __ungetbuf = 0x00600400;

    .heap 0x00810000 (NOLOAD) :
    {
        heap = .;
        *(heap)
        *(.heap)
        . = 0x00860000 - 0x00810000;
        heap_end = . - 1;
    } :data
}
