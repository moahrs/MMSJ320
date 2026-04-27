/* basic_inic.S - startup BASIC para m68k-elf
 * Endereco de carga (org) definido no linker:
 *   .text 0x00870000 em linker_basic.ld
 */

            .section .text

            .global start
            .extern main
            .extern __data_load_start
            .extern __data_start
            .extern __data_end
            .extern __bss_start
            .extern __bss_end
start:
            /* Copia .data da imagem (flash) para RAM */
            lea     __data_load_start,%a0
            lea     __data_start,%a1
            lea     __data_end,%a2
1:
            cmpa.l  %a2,%a1
            bge     2f
            move.b  (%a0)+,(%a1)+
            bra     1b

            /* Zera .bss em RAM */
2:
            lea     __bss_start,%a0
            lea     __bss_end,%a1
3:
            cmpa.l  %a1,%a0
            bge     4f
            clr.b   (%a0)+
            bra     3b

4:
            jmp     main

__exit:
_exit:
            lea     __stack,%a7
            trap    #15
            .word   0
            jmp     main

            .section .data
            .balign 2

            .global __heap
__heap:
            .long   heap

            .section .bss
            .balign 2
            .space  4096
__stack:
__ungetbuf:
            .space  4

            .section .heap
            .balign 2
heap:
