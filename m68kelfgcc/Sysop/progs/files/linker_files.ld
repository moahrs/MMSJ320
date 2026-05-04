ENTRY(start)

SECTIONS
{
    . = 0x00000000;

    .text :
    {
        *(.text*)
    }

    .rodata :
    {
        *(.rodata*)
    }

    .data :
    {
        __data_load_start = .;
        __data_start = .;
        *(.data*)
        __data_end = .;
        __data_load_end = .;
    }

    .bss (NOLOAD) :
    {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    }

    __stack = . + 0x1000;
    __ungetbuf = __stack;
    heap = __stack + 0x1000;
    __end = .;
}