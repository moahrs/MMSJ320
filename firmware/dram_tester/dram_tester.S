; EDO-RAM Refresh, Leitura e Gravação - Arduino Mega (ATmega2560)
; Baseado no ciclo CBR (CAS Before RAS)

;.include "m2560def.inc" ; Arquivo de definição para ATmega2560

#define __SFR_OFFSET 0

#include   "avr/io.h"

#define maxAddress 1048576

.global write_func
.global read_func
.global write_block_func
.global read_block_func
.global cbr_rfsh_func_unique_int
.global cbr_rfsh_func_unique
.global cbr_rfsh_func_start
.global cbr_rfsh_func

; ----------------------------------------------------------------------
; write_func()
; Compatibilidade com o teste antigo:
; escreve bloco 0 com valor 0xFFFF.
; ----------------------------------------------------------------------
write_func:
    ldi r24, 0x00      ; bloco 0
    ldi r22, 0xFF      ; valor low
    ldi r23, 0xFF      ; valor high
    rjmp write_block_func

; ----------------------------------------------------------------------
; write_block_func(uint8_t bloco, uint16_t valor)
;
; AVR-GCC:
;   r24     = bloco 64K
;   r22:r23 = valor de 16 bits
;             r22 = D0-D7
;             r23 = D8-D15
;
; Guardamos o valor em r16/r17 porque r22/r23 são usados
; como temporários e também pelas rotinas de refresh.
; r16/r17 são preservados com push/pop.
; ----------------------------------------------------------------------
write_block_func:
    push r16
    push r17

    mov r19, r24       ; r19 = bloco/endereço A16-A23
    mov r16, r22       ; r16 = dado baixo  D0-D7  -> PORTF
    mov r17, r23       ; r17 = dado alto   D8-D15 -> PORTK
    ; Configuração dos registradores
    ; r23 - Registrador temporário
    ; r24 - Registrador para contagem de linhas
    ; r18 - Registrador temporário
    ; r19 - Registrador para endereço mais mais significativo - A16 - A20
    ; r20 - Registrador para endereço mais significativo - A8 - A15
    ; r21 - Registrador para endereço menos significativo - A0 - A7

    ; Configuração dos pinos
    ldi r23, 0xFF
    out DDRA, r23         ; Configura PORTA (MA0-MA7) como saída
    out DDRC, 0x07         ; Configura PORTC (MA8-MA10) como saída
    out DDRB, 0x0F         ; Configura PORTB (RAS, CAS) como saída
    sts DDRL, 0x01         ; Configura PORTL (WE) como saída

    ; Inicializa pinos em estado alto
    ldi r23, 0xFF
    out PORTA, r23        ; Desativa todas as linhas de endereços
    out PORTC, 0x07
    out PORTB, 0x0F        ; RAS e CAS desativados
    sts PORTL, 0x01        ; WE desativado

    ldi r23, 0xFF
    out DDRF, r23         ; Configura PORTF (D0-D7) como saída
    sts DDRK, r23         ; Configura PORTK (D8-D15) como saída

    ; Coloca o dado recebido na porta
    ; r16 = D0-D7, r17 = D8-D15
    out PORTF, r16
    sts PORTK, r17

    ; Grava 1 bloco de 64KB indicado por r19
    ldi r20, 0x00
    ldi r21, 0x00

write_loop:
    ; Configura primeiro estágio do endereço (A0-A10)
    cli
    out PORTA, r21    ; MA0-MA7
    mov r23, r20
    andi r23, 0x07
    out PORTC, r23        ; MA8-MA10

    ; Ativa RAS
    ; cbi PORTB, 0           ; RAS0 baixo
    cbi PORTB, 1           ; RAS2 baixo
    nop
    nop
    nop

    ; Configura segundo estágio do endereço (A11-A20)
    mov r23, r20
    lsr r23
    lsr r23
    lsr r23           ; r23 = A11-A15 nos bits 0-4

    mov r18, r19
    andi r18, 0x07    ; r18 = A16-A18
    lsl r18
    lsl r18
    lsl r18
    lsl r18
    lsl r18           ; r18 = A16-A18 nos bits 5-7

    add r23, r18
    out PORTA, r23    ; MA0-MA7 = A11-A18

    mov r18, r19
    lsr r18
    lsr r18
    lsr r18
    andi r18, 0x07
    out PORTC, r18    ; MA8-MA10 = A19-A21

    ; Ativa WE
    lds r23,PORTL
    andi r23, 0xFE
    sts PORTL, r23      ; WE baixo
    nop

    ; Ativa CAS
    cbi PORTB, 2           ; CAS0-2 baixo
    cbi PORTB, 3           ; CAS1-3 baixo
    nop
    nop

    ; Desativa WE
    lds r23,PORTL
    ori r23, 0x01
    sts PORTL, r23           ; WE alto

    ; Desativa CAS
    sbi PORTB, 2           ; CAS0-2 alto
    sbi PORTB, 3           ; CAS1-3 alto

    ; Desativa RAS
    ; sbi PORTB, 0           ; RAS0 alto
    sbi PORTB, 1           ; RAS2 alto

    sei

    ; Incrementa o endereço
    inc r21
    cpi r21, 0x00
    breq write_next_r20
    rjmp write_loop

write_next_r20:
    ; call cbr_rfsh_func_short      ; Chama Refresh Após 256 Bytes processados

    inc r20
    cpi r20, 0x00
    breq write_next_r19
    rjmp write_loop

write_next_r19:
    ; call cbr_rfsh_func      ; Chama Refresh Após 64k processados

    inc r19
    ; cpi r19, 0x10   ; era 0x10
    ;breq write_done
    ;rjmp write_loop

write_done:
    clr r1
    pop r17
    pop r16
    ret

; ----------------------------------------------------------------------
; read_func()
; Compatibilidade com o teste antigo:
; lê bloco 0 esperando valor 0xFFFF.
; ----------------------------------------------------------------------
read_func:
    ldi r24, 0x00      ; bloco 0
    ldi r22, 0xFF      ; valor low esperado
    ldi r23, 0xFF      ; valor high esperado
    rjmp read_block_func

; ----------------------------------------------------------------------
; read_block_func(uint8_t bloco, uint16_t valor)
;
; AVR-GCC:
;   r24     = bloco 64K
;   r22:r23 = valor esperado de 16 bits
;             r22 = D0-D7 esperado
;             r23 = D8-D15 esperado
; ----------------------------------------------------------------------
read_block_func:
    push r16
    push r17

    mov r19, r24       ; r19 = bloco/endereço A16-A23
    mov r16, r22       ; r16 = esperado baixo  D0-D7
    mov r17, r23       ; r17 = esperado alto   D8-D15
    ; Configuração dos registradores
    ; r23 - Registrador temporário
    ; r24 - Registrador para contagem de linhas
    ; r18 - Registrador temporário
    ; r19 - Registrador para endereço mais mais significativo - A16 - A20
    ; r20 - Registrador para endereço mais significativo - A8 - A15
    ; r21 - Registrador para endereço menos significativo - A0 - A7

    ; Configuração dos pinos
    ldi r23, 0xFF
    out DDRA, r23         ; Configura PORTA (MA0-MA7) como saída
    out DDRC, 0x07         ; Configura PORTC (MA8-MA10) como saída
    out DDRB, 0x0F         ; Configura PORTB (RAS, CAS) como saída
    sts DDRL, 0x01         ; Configura PORTL (WE) como saída

    ; Inicializa pinos em estado alto
    ldi r23, 0xFF
    out PORTA, r23        ; Desativa todas as linhas de endereços
    out PORTC, 0x07
    out PORTB, 0x0F        ; RAS e CAS desativados
    sts PORTL, 0x01        ; WE desativado

    ldi r23, 0x00
    out DDRF, r23         ; Configura PORTF (D0-D7) como entrada
    sts DDRK, r23         ; Configura PORTK (D8-D15) como entrada

    ; Coloca dado na porta
    out PORTF, r23        ; sem pull-off
    sts PORTK, r23        ; sem pull-off

    ; Lê 1 bloco de 64KB indicado por r19
    ldi r20, 0x00
    ldi r21, 0x00

read_loop:
    ; Configura primeiro estágio do endereço (A0-A10)
    cli
    out PORTA, r21    ; MA0-MA7
    mov r23, r20
    andi r23, 0x07
    out PORTC, r23        ; MA8-MA10

    ; Ativa RAS
    ; cbi PORTB, 0           ; RAS0 baixo
    cbi PORTB, 1           ; RAS2 baixo
    nop
    nop

    ; Configura segundo estágio do endereço (A11-A20)
    mov r23, r20
    lsr r23
    lsr r23
    lsr r23           ; Shift para obter A11-A15
    mov r18, r19
    andi r18, 0x07
    lsl r18
    lsl r18
    lsl r18
    lsl r18
    lsl r18           ; Shift pra obter A16-A18
    add r23, r18      ; Obter A11-A18 pra MA0-A7
    out PORTA, r23    ; MA0-MA7 (para A11-A18)
    mov r18, r19
    lsr r18
    lsr r18
    lsr r18           ; Shift para obter A11-A15
    andi r18, 0x07
    out PORTC, r18    ; MA8-MA10 (para A19-A20)

    ; Ativa WE = alto para leitura
    lds r23, PORTL
    ori r23, 0x01
    sts PORTL, r23
    nop

    ; Ativa CAS
    cbi PORTB, 2           ; CAS0-2 baixo
    cbi PORTB, 3           ; CAS1-3 baixo
    nop
    nop

    ; Lê os dados
    in r18, PINF          ; D0-D7
    lds r23, PINK          ; D8-D15

    ; Verifica o dado lido contra o valor esperado
    ; r18 = D0-D7 lido, r23 = D8-D15 lido
    ; r16 = D0-D7 esperado, r17 = D8-D15 esperado
    cp r18, r16
    breq read_check_high
    rjmp error_read

read_check_high:
    cp r23, r17
    breq read_ok_data
    rjmp error_read

read_ok_data:

    nop

    ; Desativa CAS
    sbi PORTB, 2           ; CAS0-2 alto
    sbi PORTB, 3           ; CAS1-3 alto

    ; Desativa RAS
    ; sbi PORTB, 0           ; RAS0 alto
    sbi PORTB, 1           ; RAS2 alto
    
    sei
    
    ; Incrementa o endereço
    inc r21
    cpi r21, 0x00
    breq read_next_r20
    rjmp read_loop

read_next_r20:
    ; call cbr_rfsh_func_short

    inc r20
    cpi r20, 0x00
    breq read_next_r19
    rjmp read_loop

read_next_r19:
    ; call cbr_rfsh_func

    inc r19
    ; cpi r19, 0x10   ; era 0x10
    ;breq write_done
    ;rjmp read_loop

read_done:
    ldi r22,0x01
    ldi r23,0x00
    ldi r24,0x00
    ldi r25,0x00
    clr r1
    pop r17
    pop r16
    ret

    ; Refresh
    ;r25 - Registrador para parte alta do contador de linhas
    ;r22 - Registrador para parte baixa do contador de linhas

cbr_rfsh_func_short:
    ldi r25, 1
    ldi r22, 64
    rjmp refresh_loop

cbr_rfsh_func_unique_int:
    push r23
    in   r23, 0x3F      ; SREG
    push r23

    ; garante WE alto
    lds r23, PORTL
    ori r23, 0x01
    sts PORTL, r23

    ; CAS baixo primeiro = CBR
    cbi PORTB, 2
    cbi PORTB, 3
    nop
    nop

    ; RAS baixo depois
    cbi PORTB, 0
    nop
    nop
    nop
    nop

    ; RAS alto
    sbi PORTB, 0
    nop
    nop

    ; CAS alto
    sbi PORTB, 2
    sbi PORTB, 3
    nop
    nop

    pop  r23
    out  0x3F, r23      ; SREG
    pop  r23

    clr r1
    ret

cbr_rfsh_func_unique:
    ldi r25, 1   ; Total de linhas para refresh
    ldi r22, 1
    rjmp refresh_loop
    
cbr_rfsh_func_start:
    ldi r25, 0
    ldi r22, 8
    rjmp refresh_loop_start

refresh_loop_start:
refresh_ciclo_start:
    ; garante WE alto
    lds r23, PORTL
    ori r23, 0x01
    sts PORTL, r23

    ; CAS baixo primeiro = CBR
    cbi PORTB, 2
    cbi PORTB, 3
    nop
    nop

    ; RAS baixo depois
    cbi PORTB, 0
    nop
    nop
    nop
    nop

    ; RAS alto
    sbi PORTB, 0
    nop
    nop

    ; CAS alto
    sbi PORTB, 2
    sbi PORTB, 3
    nop
    nop

    dec r22
    brne refresh_ciclo_start

    clr r1
    ret

cbr_rfsh_func:
    ldi r25, 2048 >> 8 ; Parte alta do contador
    ldi r22, 2048 & 0xFF ; Parte baixa do contador

refresh_loop:

refresh_ciclo:
    ; garante WE alto durante CBR
    lds r23, PORTL
    ori r23, 0x01
    sts PORTL, r23

    ; Ativar CAS
    cbi PORTB, 2           ; CAS0-2 baixo
    cbi PORTB, 3           ; CAS1-3 baixo
    nop                    ; Pequeno atraso (~62.5ns a 16 MHz)

    ; Ativar RAS
    ; cbi PORTB, 0           ; RAS0 baixo
    cbi PORTB, 1           ; RAS2 baixo
    nop
    nop
    nop
    nop
    nop

    ; Delay para r23o de acesso
    ldi r23, 2
wait_delay:
    dec r23
    brne wait_delay

    ; Desativar CAS e RAS
    sbi PORTB, 2           ; CAS0-2 alto
    sbi PORTB, 3           ; CAS1-3 alto
    ; sbi PORTB, 0           ; RAS0 alto
    sbi PORTB, 1           ; RAS2 alto

    ; Próxima linha
    dec r22
    cpi r22, 0x00
    brne refresh_ciclo
    dec r25
    cpi r25, 0x00
    brne refresh_ciclo
    clr r1
    ret

error_read:
    sbi PORTB, 2
    sbi PORTB, 3
    sbi PORTB, 0

    sei

    ldi r22, 0xEE
    mov r24, r23      ; dado alto lido
    mov r23, r18      ; dado baixo lido
    mov r25, r19      ; bloco

    clr r1
    pop r17
    pop r16
    ret
