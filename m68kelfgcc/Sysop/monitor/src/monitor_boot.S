    .section .text
    .global start
    .global _exit
    .global __exit
    .global __putch
    .global __getch
    .global __kbhit
    .global monitor_func_table

    .extern _main
    .extern _fontesMatrix
    .extern _videoFontes
    .extern __allocp

    .org 0x0000
    .long 0x0063fffe
    .long start
    .long _erroBus
    .long _erroAddress
    .long _erroIllegal
    .long _erroZeroDivide
    .long _erroChk
    .long _erroTrapv
    .long _erroPrivilege
    .long _traceDebug
    .long _erroLineA
    .long _erroLineF
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000004c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x0000002c
    .long 0x00000030
    .long 0x00000034
    .long 0x00000038
    .long 0x0000003c
    .long 0x00000040
    .long 0x00000044
    .long 0x00000048
    .long 0x0000004c
    .long _trapFunc00
    .long _trapFunc01
    .long _trapFunc02
    .long _trapFunc03
    .long _trapFunc04
    .long _trapFunc05
    .long _trapFunc06
    .long _trapFunc07
    .long _trapFunc08
    .long _trapFunc09
    .long _trapFunc10
    .long _trapFunc11
    .long _trapFunc12
    .long _trapFunc13
    .long _trapFunc14
    .long _trapFunc15
    .long 0x00000090
    .long 0x00000094
    .long 0x00000098
    .long 0x0000009c
    .long 0x000000a0
    .long 0x000000a4
    .long 0x000000a8
    .long 0x000000ac
    .long 0x000000b0
    .long 0x000000b4
    .long 0x000000b8
    .long 0x000000bc
    .long 0x000000c0
    .long 0x000000c4
    .long 0x000000c8
    .long 0x000000cc

    .org 0x0280
    .long _intMfpGpi0
    .long _intMfpGpi1
    .long _intMfpGpi2
    .long _intMfpGpi3
    .long _intMfpTmrD
    .long _intMfpTmrC
    .long _intMfpGpi4
    .long _intMfpGpi5
    .long _intMfpTmrB
    .long _intMfpXmitErr
    .long _intMfpXmitBufEmpty
    .long _intMfpRecErr
    .long _intMfpRecBufFull
    .long _intMfpTmrA
    .long _intMfpGpi6
    .long _intMfpGpi7

    .org 0x0400
start:
    andw #0xf8ff,%sr
    movel #_fontesMatrix,%d1
    movel %d1,_videoFontes
    clrl __allocp
    bra _main

    .org 0x041a
monitor_func_table:
    .long _processCmd
    .long _clearScr
    .long _printText
    .long _printChar
    .long _delayms
    .long _loadSerialToMem
    .long _readChar
    .long _hideCursor
    .long _showCursor
    .long _inputLine
    .long _modeVideo
    .long _vdp_init
    .long _vdp_colorize
    .long _vdp_plot_hires
    .long _vdp_plot_color
    .long _vdp_set_bdcolor
    .long _vdp_set_pattern_color
    .long _vdp_set_cursor
    .long _vdp_set_cursor_pos
    .long _vdp_textcolor
    .long _vdp_write
    .long _vdp_set_sprite_pattern
    .long _vdp_sprite_color
    .long _vdp_sprite_get_attributes
    .long _vdp_sprite_get_position
    .long _vdp_sprite_init
    .long _vdp_sprite_set_position
    .long _writeLongSerial
    .long _writeSerial
    .long _vdp_read_color_pixel
    .long _vdp_get_cursor
    .long _vdp_get_color
    .long _lstmGetSize
    .long _vdp_get_cfg
    .long _setRegister
    .long _read_status_reg
    .long _setWriteAddress
    .long _setReadAddress
    .long _getVideoFontes
    .long _readMouse
    .long _loadSerialToMem2
    .long _mprintf

__exit:
_exit:
    bra __exit

__putch:
    rts

__getch:
    clrl %d0
    rts

__kbhit:
    clrl %d0
    rts
