.section .text

.global netCommRxHookResidentStart
.global netCommRxHookResidentEnd

/* Hook residente para HOOK_REC_BUF_FULL.
   Usa apenas enderecos absolutos fixos, portanto pode ser copiado para msmalloc(). */
netCommRxHookResidentStart:
        move.l  %d1,-(%sp)
        move.l  %d2,-(%sp)
        move.l  %a0,-(%sp)

        move.b  0x00401721,%d0       /* MFP UDR: 0x00400020 + 0x1701 */
        move.b  %d0,0x0060F978       /* netApiLastByte */
        addq.l  #1,0x0060F974        /* netApiHookCount */

        move.w  0x0060F96C,%d1       /* serRxHead */
        move.w  %d1,%d2
        addq.w  #1,%d2
        cmp.w   #4096,%d2
        bcs.s   1f
        clr.w   %d2
1:
        cmp.w   0x0060F96E,%d2       /* serRxTail */
        bne.s   2f
        addq.w  #1,0x0060F970        /* serRxLost */
        move.l  (%sp)+,%a0
        move.l  (%sp)+,%d2
        move.l  (%sp)+,%d1
        rts
2:
        lea     0x0060F980,%a0       /* serRxBuf */
        move.b  %d0,0(%a0,%d1.w)
        move.w  %d2,0x0060F96C       /* serRxHead */
        move.l  (%sp)+,%a0
        move.l  (%sp)+,%d2
        move.l  (%sp)+,%d1
        rts

netCommRxHookResidentEnd:
