.section .text

.global start
.extern main

start:
            jmp     main

__exit:
_exit:
            trap    #15
            .word   0
            jmp     start