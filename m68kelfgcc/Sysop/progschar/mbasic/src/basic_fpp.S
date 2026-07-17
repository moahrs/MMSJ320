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
            .extern FFPATAN
            .extern FFPSIN
            .extern FFPSINH
            .extern FFPSQRT
            .extern FFPSUB
            .extern FFPTAN
            .extern FFPTANH
            .extern floatBufferStr
            .extern floatNumD7
            .extern floatNumD6

            .macro SAVE_ALL
            movem.l %d0-%d7/%a0-%a5,-(%sp)
            .endm

            .macro RESTORE_ALL
            movem.l (%sp)+,%d0-%d7/%a0-%a5
            .endm

            .macro LOAD_D7
            move.l  floatNumD7,%a0
            move.l  (%a0),%d7
            .endm

            .macro LOAD_D6
            move.l  floatNumD6,%a0
            move.l  (%a0),%d6
            .endm

            .macro STORE_D7
            move.l  floatNumD7,%a0
            move.l  %d7,(%a0)
            .endm

            .macro LOAD_BUFFER_A0
            move.l  floatBufferStr,%a0
            move.l  (%a0),%a0
            .endm

            .global FP_TO_STR
FP_TO_STR:
            SAVE_ALL
            LOAD_D7
            move.w  #0,-(%sp)
            jsr     FFPFPA
            moveq   #7,%d0
            LOAD_BUFFER_A0
1:
            move.w  (%sp)+,(%a0)+
            dbra    %d0,1b
            RESTORE_ALL
            rts

            .global STR_TO_FP
STR_TO_FP:
            SAVE_ALL
            LOAD_BUFFER_A0
            jsr     FFPAFP
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_SUM
FPP_SUM:
            SAVE_ALL
            LOAD_D7
            LOAD_D6
            jsr     FFPADD
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_SUB
FPP_SUB:
            SAVE_ALL
            LOAD_D7
            LOAD_D6
            jsr     FFPSUB
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_MUL
FPP_MUL:
            SAVE_ALL
            LOAD_D7
            LOAD_D6
            jsr     FFPMUL2
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_DIV
FPP_DIV:
            SAVE_ALL
            LOAD_D7
            LOAD_D6
            jsr     FFPDIV
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_PWR
FPP_PWR:
            SAVE_ALL
            LOAD_D7
            LOAD_D6
            jsr     FFPPWR
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_CMP
FPP_CMP:
            SAVE_ALL
            LOAD_D7
            LOAD_D6
            jsr     FFPCMP
            move    %sr,%d7
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_INT
FPP_INT:
            SAVE_ALL
            LOAD_D7
            jsr     FFPFPI
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_FPP
FPP_FPP:
            SAVE_ALL
            LOAD_D7
            jsr     FFPIFP
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_SIN
FPP_SIN:
            SAVE_ALL
            LOAD_D7
            jsr     FFPSIN
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_COS
FPP_COS:
            SAVE_ALL
            LOAD_D7
            jsr     FFPCOS
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_TAN
FPP_TAN:
            SAVE_ALL
            LOAD_D7
            jsr     FFPTAN
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_ATN
FPP_ATN:
            SAVE_ALL
            LOAD_D7
            jsr     FFPATAN
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_SINH
FPP_SINH:
            SAVE_ALL
            LOAD_D7
            jsr     FFPSINH
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_COSH
FPP_COSH:
            SAVE_ALL
            LOAD_D7
            jsr     FFPCOSH
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_TANH
FPP_TANH:
            SAVE_ALL
            LOAD_D7
            jsr     FFPTANH
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_SQRT
FPP_SQRT:
            SAVE_ALL
            LOAD_D7
            jsr     FFPSQRT
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_LN
FPP_LN:
            SAVE_ALL
            LOAD_D7
            jsr     FFPLOG
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_EXP
FPP_EXP:
            SAVE_ALL
            LOAD_D7
            jsr     FFPEXP
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_ABS
FPP_ABS:
            SAVE_ALL
            LOAD_D7
            jsr     FFPABS
            STORE_D7
            RESTORE_ALL
            rts

            .global FPP_NEG
FPP_NEG:
            SAVE_ALL
            LOAD_D7
            jsr     FFPNEG
            STORE_D7
            RESTORE_ALL
            rts

            .global fppBasGT
            .global fppBasLT
            .global fppBasGE
            .global fppBasLE
            .global fppBasEQ
            .global fppBasNE

fppBasGT:
        move.l  4(%sp),%d7
        move.l  8(%sp),%d6
        jsr     FFPCMP
        bgt.s   .fppBasGT_true
        moveq   #0,%d0
        rts
.fppBasGT_true:
        moveq   #1,%d0
        rts


fppBasLT:
        move.l  4(%sp),%d7
        move.l  8(%sp),%d6
        jsr     FFPCMP
        blt.s   .fppBasLT_true
        moveq   #0,%d0
        rts
.fppBasLT_true:
        moveq   #1,%d0
        rts


fppBasGE:
        move.l  4(%sp),%d7
        move.l  8(%sp),%d6
        jsr     FFPCMP
        bge.s   .fppBasGE_true
        moveq   #0,%d0
        rts
.fppBasGE_true:
        moveq   #1,%d0
        rts


fppBasLE:
        move.l  4(%sp),%d7
        move.l  8(%sp),%d6
        jsr     FFPCMP
        ble.s   .fppBasLE_true
        moveq   #0,%d0
        rts
.fppBasLE_true:
        moveq   #1,%d0
        rts


fppBasEQ:
        move.l  4(%sp),%d7
        move.l  8(%sp),%d6
        jsr     FFPCMP
        beq.s   .fppBasEQ_true
        moveq   #0,%d0
        rts
.fppBasEQ_true:
        moveq   #1,%d0
        rts


fppBasNE:
        move.l  4(%sp),%d7
        move.l  8(%sp),%d6
        jsr     FFPCMP
        bne.s   .fppBasNE_true
        moveq   #0,%d0
        rts
.fppBasNE_true:
        moveq   #1,%d0
        rts

; entrada:
;   D7 = esquerda
;   D6 = direita
;
; saída:
*   D7 = -1  se esquerda < direita
*   D7 =  0  se esquerda = direita
*   D7 =  1  se esquerda > direita

        .global  fppBasCMP

fppBasCMP:
        SAVE_ALL

        LOAD_D7
        LOAD_D6

        tst.b   %d6
        bpl.s   fppBasCMP_pos

        tst.b   %d7
        bpl.s   fppBasCMP_pos

        * ambos negativos: comparação invertida, igual Motorola
        cmp.b   %d7,%d6
        bne.s   fppBasCMP_result
        cmp.l   %d7,%d6
        bra.s   fppBasCMP_result

fppBasCMP_pos:
        cmp.b   %d6,%d7
        bne.s   fppBasCMP_result
        cmp.l   %d6,%d7

fppBasCMP_result:
        beq.s   fppBasCMP_eq
        bgt.s   fppBasCMP_gt

fppBasCMP_lt:
        moveq   #-1,%d7
        move.l  %d7,%d0
        STORE_D7
        RESTORE_ALL
        rts

fppBasCMP_eq:
        moveq   #0,%d7
        move.l  %d7,%d0
        STORE_D7
        RESTORE_ALL
        rts

fppBasCMP_gt:
        moveq   #1,%d7
        move.l  %d7,%d0
        STORE_D7
        RESTORE_ALL
        rts
