/* ponte FFP para BASIC (GAS) */

            .section .text

            .extern FFPABS
            .extern FFPADD
            .extern FFPAFP
            .extern FFPCMP
            .extern FFPCOS
            .extern FFPCOSH
            .extern FFPDIV
            .extern FFPEXP
            .extern FFPFPA
            .extern FFPFPI
            .extern FFPIFP
            .extern FFPLOG
            .extern FFPMUL2
            .extern FFPNEG
            .extern FFPPWR
            .extern FFPSIN
            .extern FFPSINH
            .extern FFPSQRT
            .extern FFPSUB
            .extern FFPTAN
            .extern FFPTANH

            .equ FLOAT_NUM_D7,   0x008FEE9E
            .equ FLOAT_NUM_D6,   0x008FEE96
            .equ FLOAT_BUFFER,   0x008FEFA6

            .macro SAVE_ALL
            movem.l %d0-%d7/%a0-%a5,-(%sp)
            .endm

            .macro RESTORE_ALL
            movem.l (%sp)+,%d0-%d7/%a0-%a5
            .endm

            .global FP_TO_STR
FP_TO_STR:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            move.w  #0,-(%sp)
            jsr     FFPFPA
            moveq   #7,%d0
            move.l  FLOAT_BUFFER,%a0
1:
            move.w  (%sp)+,(%a0)+
            dbra    %d0,1b
            RESTORE_ALL
            rts

            .global STR_TO_FP
STR_TO_FP:
            SAVE_ALL
            move.l  FLOAT_BUFFER,%a0
            jsr     FFPAFP
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_SUM
FPP_SUM:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            move.l  FLOAT_NUM_D6,%d6
            jsr     FFPADD
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_SUB
FPP_SUB:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            move.l  FLOAT_NUM_D6,%d6
            jsr     FFPSUB
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_MUL
FPP_MUL:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            move.l  FLOAT_NUM_D6,%d6
            jsr     FFPMUL2
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_DIV
FPP_DIV:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            move.l  FLOAT_NUM_D6,%d6
            jsr     FFPDIV
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_PWR
FPP_PWR:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            move.l  FLOAT_NUM_D6,%d6
            jsr     FFPPWR
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_CMP
FPP_CMP:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            move.l  FLOAT_NUM_D6,%d6
            jsr     FFPCMP
            move    %sr,%d7
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_INT
FPP_INT:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPFPI
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_FPP
FPP_FPP:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPIFP
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_SIN
FPP_SIN:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPSIN
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_COS
FPP_COS:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPCOS
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_TAN
FPP_TAN:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPTAN
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_SINH
FPP_SINH:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPSINH
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_COSH
FPP_COSH:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPCOSH
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_TANH
FPP_TANH:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPTANH
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_SQRT
FPP_SQRT:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPSQRT
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_LN
FPP_LN:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPLOG
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_EXP
FPP_EXP:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPEXP
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_ABS
FPP_ABS:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPABS
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts

            .global FPP_NEG
FPP_NEG:
            SAVE_ALL
            move.l  FLOAT_NUM_D7,%d7
            jsr     FFPNEG
            move.l  %d7,FLOAT_NUM_D7
            RESTORE_ALL
            rts
