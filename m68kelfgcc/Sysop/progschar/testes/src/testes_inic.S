.section .text

.global start
.global tstIntsOff
.global tstIntsOn
.extern main

start:
            jmp     main

__exit:
_exit:
            trap    #15
            .word   0
            jmp     start

tstIntsOff:
       move.w  #0x2700,%sr
       rts

tstIntsOn:
       move.w  #0x2300,%sr
       rts
