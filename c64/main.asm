                    !cpu 6510

DEBUG = 0
RELEASE = 1
MODE = 0
; ==============================================================================
ENABLE              = 0x20
ENABLE_JMP          = 0x4C
DISABLE             = 0x2C

BLACK               = 0x00
WHITE               = 0x01
RED                 = 0x02
CYAN                = 0x03
PURPLE              = 0x04
GREEN               = 0x05
BLUE                = 0x06
YELLOW              = 0x07
ORANGE              = 0x08
BROWN               = 0x09
PINK                = 0x0A
DARK_GREY           = 0x0B
GREY                = 0x0C
LIGHT_GREEN         = 0x0D
LIGHT_BLUE          = 0x0E
LIGHT_GREY          = 0x0F

MEMCFG              = 0x35
; ------------------------------------------------------------------------------
;                   BADLINEs (0xD011 default)
;                   -------------------------
;                   00 : 0x33
;                   01 : 0x3B
;                   02 : 0x43
;                   03 : 0x4B
;                   04 : 0x53
;                   05 : 0x5B
;                   06 : 0x63
;                   07 : 0x6B
;                   08 : 0x73
;                   09 : 0x7B
;                   10 : 0x83
;                   11 : 0x8B
;                   12 : 0x93
;                   13 : 0x9B
;                   14 : 0xA3
;                   15 : 0xAB
;                   16 : 0xB3
;                   17 : 0xBB
;                   18 : 0xC3
;                   19 : 0xCB
;                   20 : 0xD3
;                   21 : 0xDB
;                   22 : 0xE3
;                   23 : 0xEB
;                   24 : 0xF3
; ------------------------------------------------------------------------------
IRQ_LINE0           = 0x00
IRQ_LINE1           = 0xAA
IRQ_LINE2           = 0xFD
; ==============================================================================
zp_start            = 0x02
flag_irq_ready      = zp_start
current_mode        = flag_irq_ready+1
pause_flag          = current_mode+1

; ==============================================================================
KEY_CRSRUP          = 0x91
KEY_CRSRDOWN        = 0x11
KEY_CRSRLEFT        = 0x9D
KEY_CRSRRIGHT       = 0x1D
KEY_RETURN          = 0x0D
KEY_STOP            = 0x03

getin               = 0xFFE4
keyscan             = 0xEA87
; ==============================================================================
code_start          = 0x0810
vicbank0            = 0x0000
charset0            = vicbank0+0x1000
charset1            = vicbank0+0x3000
vidmem0             = vicbank0+0x0400
sprite_data         = vicbank0+0x0F00
sprite_base         = <((sprite_data-vicbank0)/0x40)
dd00_val0           = <!(vicbank0/0x4000) & 3
d018_val0           = <(((vidmem0-vicbank0)/0x400) << 4)+ <(((charset0-vicbank0)/0x800) << 1)
d018_val1           = <(((vidmem0-vicbank0)/0x400) << 4)+ <(((charset1-vicbank0)/0x800) << 1)
data_start          = 0x3000
music_init          = 0x1000
music_play          = music_init+3

POS_TIME            = vidmem0 + 0x355
; ==============================================================================
                    !macro flag_set .flag {
                        lda #1
                        sta .flag
                    }
                    !macro flag_clear .flag {
                        lda #0
                        sta .flag
                    }
                    !macro flag_get .flag {
                        lda .flag
                    }
; ==============================================================================
                    *= data_start
chardata:           !bin "exochar3a.prg",,2
src_vid:            !bin "roly_tmp07.scr",16*40
                    !scr "                                        "
                    !scr "   prochaine station: village de untz   "
                    !scr "   "
                    !fi 40-6, 0
                    !scr "   "
                    !scr "               use 8580!                "
                    !scr "                                        "
                    !scr "             "
                    ;POS_TIME = vidmem0 + (src_vid - *)
                    !scr "00:00 / 03:16"
                    !scr "              "
                    !scr "                                        "
                    !scr "                                        "
                    !scr "f1: "
                    !scr "compo / loop  f3: restart  f5: pause"
src_col:            !bin "roly_tmp07.col",16*40
                    !fi 40,0
                    !fi 40,CYAN
                    !fi 40,CYAN
                    !fi 40,PINK
                    !fi 40,0
                    !fi 19,WHITE
                    !fi 21,YELLOW
                    !fi 40,0
                    !fi 40,0
                    !fi 40,LIGHT_BLUE

                    *= chardata
                    !byte %00000000
                    !byte %11111111
                    !byte %00000000
                    !byte %00000000
                    !byte %00000000
                    !byte %00000000
                    !byte %00000000
                    !byte %00000000
; ==============================================================================
                    *= sprite_data
                    !bin "overlays.bin"
; ==============================================================================
                    *= music_init
                    !bin "village-24.sid",,0x7E
; ==============================================================================
                    *= code_start
                    lda #0x7F
                    sta 0xDC0D
                    lda #MEMCFG
                    sta 0x01
                    lda #0x0B
                    sta 0xD011
                    jmp init_code
; ==============================================================================
                    !zone IRQ
                    NUM_IRQS = 0x03
irq:                !if MEMCFG = 0x35 {
                        sta .irq_savea+1
                        stx .irq_savex+1
                        sty .irq_savey+1
                        lda 0x01
                        sta .irq_save0x01+1
                        lda #0x35
                        sta 0x01
                    }
irq_next:           jmp irq0
irq_end:            lda 0xD012
-                   cmp 0xD012
                    beq -
.irq_index:         ldx #0
                    lda irq_tab_lo,x
                    sta irq_next+1
                    lda irq_tab_hi,x
                    sta irq_next+2
                    lda irq_lines,x
                    sta 0xD012
                    inc .irq_index+1
                    lda .irq_index+1
                    cmp #NUM_IRQS
                    bne +
                    lda #0
                    sta .irq_index+1
+                   asl 0xD019
                    !if MEMCFG = 0x37 {
                        jmp 0xEA31
                    }
                    !if MEMCFG = 0x36 {
                        jmp 0xEA81
                    }
                    !if MEMCFG = 0x35 {
.irq_save0x01:          lda #0x35
                        sta 0x01
                        cmp #0x36
                        beq +
.irq_savea:             lda #0
.irq_savex:             ldx #0
.irq_savey:             ldy #0
                        rti
+                       jmp 0xEA81
                    }

irq0:               +flag_set flag_irq_ready
                    lda #BLACK
                    sta 0xD020
                    lda #BLACK
                    sta 0xD021
                    lda #d018_val0
                    sta 0xD018
                    jsr print_mode
                    jmp irq_end

irq1:               ldx #3
-                   dex
                    bpl -
                    lda #LIGHT_BLUE
                    sta 0xD020
                    sta 0xD021
                    lda #d018_val1
                    sta 0xD018
                    ldx #1
-                   dex
                    bpl -
                    lda #CYAN
                    sta 0xD020
                    sta 0xD021
                    ldx #9
-                   dex
                    bpl -
                    lda #LIGHT_BLUE
                    sta 0xD020
                    sta 0xD021
                    ldx #9
-                   dex
                    bpl -
                    lda #BLUE
                    sta 0xD020
                    sta 0xD021
                    jsr colorcycle
                    jsr anim_sprites
                    jsr change_sprites
                    jmp irq_end

irq2:               ldx #3
-                   dex
                    bpl -
                    lda #PURPLE
                    sta 0xD020
enable_music:       jsr music_play
                    lda #BLUE
                    sta 0xD020
enable_timer:       jsr timer
                    jsr check_end
                    lda #0x1B
                    sta 0xD011
                    jmp irq_end

irq_tab_lo:         !byte <irq0, <irq1, <irq2
irq_tab_hi:         !byte >irq0, >irq1, >irq2
irq_lines:          !byte IRQ_LINE0, IRQ_LINE1, IRQ_LINE2
; ==============================================================================
init_code:          jsr init_nmi
                    jsr init_zp
                    jsr init_vic
                    jsr init_music
                    jsr init_irq
                    jmp mainloop

init_irq:           lda irq_lines
                    sta 0xD012
                    lda #<irq
                    sta 0x0314
                    !if MEMCFG = 0x35 {
                        sta 0xFFFE
                    }
                    lda #>irq
                    sta 0x0315
                    !if MEMCFG = 0x35 {
                        sta 0xFFFF
                    }
                    lda 0xD011
                    and #%01101111
                    ora #%00000000
                    sta 0xD011
                    lda #0x01
                    sta 0xD019
                    sta 0xD01A
                    rts

init_nmi:           lda #<nmi
                    sta 0x0318
                    !if MEMCFG = 0x35 {
                        sta 0xFFFA
                    }
                    lda #>nmi
                    sta 0x0319
                    !if MEMCFG = 0x35 {
                        sta 0xFFFB
                    }
                    rts

init_vic:           lda #dd00_val0
                    sta 0xDD00
                    lda #d018_val0
                    sta 0xD018
                    ldx #0
-                   lda src_vid+(0x000),x
                    sta vidmem0+(0x000),x
                    lda src_col+(0x000),x
                    sta 0xD800+(0x000),x
                    lda src_vid+(0x100),x
                    sta vidmem0+(0x100),x
                    lda src_col+(0x100),x
                    sta 0xD800+(0x100),x
                    lda src_vid+(0x200),x
                    sta vidmem0+(0x200),x
                    lda src_col+(0x200),x
                    sta 0xD800+(0x200),x
                    lda src_vid+(0x2E8),x
                    sta vidmem0+(0x2E8),x
                    lda src_col+(0x2E8),x
                    sta 0xD800+(0x2E8),x
                    inx
                    bne -

                    lda #LIGHT_GREY
                    sta 0xD800+(24*40)+0
                    sta 0xD800+(24*40)+1
                    sta 0xD800+(24*40)+2

                    sta 0xD800+(24*40)+18
                    sta 0xD800+(24*40)+19
                    sta 0xD800+(24*40)+20

                    sta 0xD800+(24*40)+31
                    sta 0xD800+(24*40)+32
                    sta 0xD800+(24*40)+33

                    jsr sprites_init
                    rts

init_music:         lda #0
                    tax
                    tay
                    jsr music_init
                    rts

init_zp:            lda #0
                    sta flag_irq_ready
                    sta current_mode
                    sta pause_flag
                    rts
; ==============================================================================
                    !zone MAINLOOP
mainloop:           jsr wait_irq
is_end:             lda #0
                    beq +
                    lda #0
                    sta is_end+1
                    jsr init_music
+                   jsr keyboard_get
                    jmp mainloop
; ==============================================================================
                    !zone NMI
nmi:                lda #0x37               ; restore 0x01 standard value
                    sta 0x01
                    lda #0                  ; if AR/RR present
                    sta 0xDE00              ; reset will lead to menu
                    jmp 0xFCE2              ; reset
; ==============================================================================
                    !zone WAIT
wait_irq:           +flag_clear flag_irq_ready
.wait_irq:          +flag_get flag_irq_ready
                    beq .wait_irq
                    rts
; ==============================================================================
                    !zone TIMER
                    t0 = POS_TIME+0x4
                    t1 = POS_TIME+0x3
                    t2 = POS_TIME+0x1
                    t3 = POS_TIME+0x0
                    SECONDS_VAL = 49
timer:              lda #SECONDS_VAL
                    beq +
                    dec timer+1
                    rts
+                   lda #SECONDS_VAL
                    sta timer+1
                    clc
                    inc t0
                    lda t0
                    cmp #0x3A
                    bne +
                    lda #0x30
                    sta t0
                    inc t1
                    lda t1
                    cmp #0x36
                    bne +
                    lda #0x30
                    sta t1
                    inc t2
                    lda t2
                    cmp #0x3A
                    bne +
                    lda #0x30
                    sta t2
                    inc t3
                    lda t3
                    cmp #0x3A
                    bne +
                    lda #0x30
                    sta t3
+                   rts
                    e0 = POS_TIME+0xC
                    e1 = POS_TIME+0xB
                    e2 = POS_TIME+0x9
                    e3 = POS_TIME+0x8
check_end:          !if MODE = 1 {
                        rts
                    } else {
                        nop
                    }
                    lda t3
                    cmp e3
                    bne +
                    lda t2
                    cmp e2
                    bne +
                    lda t1
                    cmp e1
                    bne +
                    lda t0
                    cmp e0
                    bne +
                    lda #DISABLE
                    sta enable_music
                    sta enable_timer
                    lda #1
                    sta is_end+1
+                   rts
; ==============================================================================
                    !zone KEYBOARD
keyboard_get:
.debounce:          lda #0
                    beq +
                    dec .debounce+1
                    rts
+                   lda #0x00             ; set data direction for keyboard
                    sta 0xDC03            ; PORT B : INPUT
                    lda #0xFF
                    sta 0xDC02            ; PORT A : OUTPUT
.key_f1:            lda #%11111110        ; check keyboard for
                    sta 0xDC00            ; F1

                    lda 0xDC01
                    and #%00010000
                    sta 0xDC01
                    bne .key_f3           ; no -> skip
                                          ; yes:

                    lda current_mode      ; change current mode flag
                    eor #(0 XOR 1)
                    sta current_mode

                    lda check_end         ; switch end check routine
                    eor #(0x60 XOR 0xea)  ; RTS or NOP
                    sta check_end

                    lda enable_music
                    cmp #DISABLE          ; check if music has already ended
                    bne +                 ; if no -> skip

                    lda pause_flag        ; if yes: check pause flag
                    bne +                 ; if set -> skip
                    jmp .restart          ; if not set -> restart tune
+                   jmp .exit

.key_f3:            lda #%11111110        ; check keyboard for
                    sta 0xDC00            ; F3

                    lda 0xDC01
                    and #%00100000
                    sta 0xDC01
                    bne .key_f5           ; no -> skip
.restart:                                 ; yes:
                    jsr tune_restart      ; restart tune
                    jmp .exit

.key_f5:            lda #%11111110        ; check keyboard for
                    sta 0xDC00            ; F5

                    lda 0xDC01
                    and #%01000000
                    sta 0xDC01
                    bne ++

                    lda enable_music
                    eor #(ENABLE XOR DISABLE)
                    sta enable_music

                    lda enable_timer
                    eor #(ENABLE XOR DISABLE)
                    sta enable_timer

                    lda pause_flag
                    eor #(0 XOR 1)
                    sta pause_flag

                    lda enable_music
                    cmp #DISABLE
                    bne +

                    lda #0x00
                    sta 0xD418
+
.exit:              lda #0x10
                    sta .debounce+1
++                  rts
; ==============================================================================
tune_restart:       sei
                    lda #0x0B
                    sta 0xD011

                    jsr init_music

                    lda #0
                    sta pause_flag        ; clear pause flag

                    lda #'0'              ; reset min/sec counter
                    sta t0
                    sta t1
                    sta t2
                    sta t3

                    lda #49               ; reset frames counter
                    sta timer+1

                    lda #ENABLE           ; enable music and counter
                    sta enable_music
                    sta enable_timer

                    lda current_mode      ; check current mode
                    beq +
                    lda #0x60             ; if 1 (loop) -> RTS
                    !byte 0x2C
+                   lda #0xEA             ; if 0 (compo) -> NOP
                    sta check_end         ; at the start of check end routine

                    lda #0x1B
                    sta 0xD011
                    asl 0xD019
                    cli
                    rts
; ==============================================================================
                    !zone PRINT
print_mode:         lda current_mode
                    beq +
                    lda #GREY
                    sta 0xD800+(24*40)+4
                    sta 0xD800+(24*40)+5
                    sta 0xD800+(24*40)+6
                    sta 0xD800+(24*40)+7
                    sta 0xD800+(24*40)+8

                    lda #WHITE
                    sta 0xD800+(24*40)+12
                    sta 0xD800+(24*40)+13
                    sta 0xD800+(24*40)+14
                    sta 0xD800+(24*40)+15
                    rts
+                   lda #WHITE
                    sta 0xD800+(24*40)+4
                    sta 0xD800+(24*40)+5
                    sta 0xD800+(24*40)+6
                    sta 0xD800+(24*40)+7
                    sta 0xD800+(24*40)+8

                    lda #GREY
                    sta 0xD800+(24*40)+12
                    sta 0xD800+(24*40)+13
                    sta 0xD800+(24*40)+14
                    sta 0xD800+(24*40)+15
                    rts
; ==============================================================================
                    !zone COLORCYLE
                    COLCYCLESPEED = 3

colorcycle:         lda #COLCYCLESPEED
                    beq +
                    dec colorcycle+1
                    rts
+                   lda #COLCYCLESPEED
                    sta colorcycle+1
                    jsr shift_cycletab
                    lda cycletab
                    sta 0xD800+(0*40)+7
                    sta 0xD800+(1*40)+6
                    sta 0xD800+(2*40)+5
                    sta 0xD800+(3*40)+4
                    sta 0xD800+(4*40)+3
                    sta 0xD800+(5*40)+2
                    sta 0xD800+(6*40)+1
                    sta 0xD800+(7*40)+0
                    sta 0xD800+(0*40)+32
                    sta 0xD800+(1*40)+33
                    sta 0xD800+(2*40)+34
                    sta 0xD800+(3*40)+35
                    sta 0xD800+(4*40)+36
                    sta 0xD800+(5*40)+37
                    sta 0xD800+(6*40)+38
                    sta 0xD800+(7*40)+39
                    sta 0xD800+0x01C4+0
                    sta 0xD800+(9*40)+1
                    sta 0xD800+(9*40)+38
                    lda cycletab+1
                    sta 0xD800+(0*40)+6
                    sta 0xD800+(1*40)+5
                    sta 0xD800+(2*40)+4
                    sta 0xD800+(3*40)+3
                    sta 0xD800+(4*40)+2
                    sta 0xD800+(5*40)+1
                    sta 0xD800+(6*40)+0
                    sta 0xD800+(0*40)+33
                    sta 0xD800+(1*40)+34
                    sta 0xD800+(2*40)+35
                    sta 0xD800+(3*40)+36
                    sta 0xD800+(4*40)+37
                    sta 0xD800+(5*40)+38
                    sta 0xD800+(6*40)+39
                    sta 0xD800+0x01C4+1
                    sta 0xD800+(10*40)+1
                    sta 0xD800+(10*40)+38
                    lda cycletab+2
                    sta 0xD800+(0*40)+5
                    sta 0xD800+(1*40)+4
                    sta 0xD800+(2*40)+3
                    sta 0xD800+(3*40)+2
                    sta 0xD800+(4*40)+1
                    sta 0xD800+(5*40)+0
                    sta 0xD800+(0*40)+34
                    sta 0xD800+(1*40)+35
                    sta 0xD800+(2*40)+36
                    sta 0xD800+(3*40)+37
                    sta 0xD800+(4*40)+38
                    sta 0xD800+(5*40)+39
                    sta 0xD800+0x01C4+2
                    sta 0xD800+(11*40)+1
                    sta 0xD800+(11*40)+38
                    lda cycletab+3
                    sta 0xD800+(0*40)+4
                    sta 0xD800+(1*40)+3
                    sta 0xD800+(2*40)+2
                    sta 0xD800+(3*40)+1
                    sta 0xD800+(4*40)+0
                    sta 0xD800+(0*40)+35
                    sta 0xD800+(1*40)+36
                    sta 0xD800+(2*40)+37
                    sta 0xD800+(3*40)+38
                    sta 0xD800+(4*40)+39
                    sta 0xD800+0x01C4+3
                    sta 0xD800+(12*40)+1
                    sta 0xD800+(12*40)+38
                    lda cycletab+4
                    sta 0xD800+(0*40)+3
                    sta 0xD800+(1*40)+2
                    sta 0xD800+(2*40)+1
                    sta 0xD800+(3*40)+0
                    sta 0xD800+(0*40)+36
                    sta 0xD800+(1*40)+37
                    sta 0xD800+(2*40)+38
                    sta 0xD800+(3*40)+39
                    sta 0xD800+0x01C4+4
                    sta 0xD800+(13*40)+1
                    sta 0xD800+(13*40)+38
                    lda cycletab+5
                    sta 0xD800+(0*40)+2
                    sta 0xD800+(1*40)+1
                    sta 0xD800+(2*40)+0
                    sta 0xD800+(0*40)+37
                    sta 0xD800+(1*40)+38
                    sta 0xD800+(2*40)+39
                    sta 0xD800+0x01C4+5
                    sta 0xD800+(14*40)+1
                    sta 0xD800+(14*40)+38
                    lda cycletab+6
                    sta 0xD800+(0*40)+1
                    sta 0xD800+(1*40)+0
                    sta 0xD800+(0*40)+38
                    sta 0xD800+(1*40)+39
                    sta 0xD800+0x01C4+6
                    lda cycletab+7
                    sta 0xD800+(0*40)+0
                    sta 0xD800+(0*40)+39
                    rts

shift_cycletab:     lda cycletab
                    sta cycletab_buffer
                    ldx #0
-                   lda cycletab+1,x
                    sta cycletab,x
                    inx
                    cpx #0xE
                    bne -
                    rts
cycletab:           !byte BROWN         ; 0
                    !byte RED           ; 1
                    !byte PURPLE        ; 2
                    !byte ORANGE        ; 3
                    !byte PINK          ; 4
                    !byte LIGHT_GREY    ; 5
                    !byte YELLOW        ; 6
                    !byte WHITE         ; 7
                    !byte YELLOW        ; 8
                    !byte LIGHT_GREY    ; 9
                    !byte PINK          ; A
                    !byte ORANGE        ; B
                    !byte PURPLE        ; C
                    !byte RED           ; D
cycletab_buffer:    !byte 0x00
; ==============================================================================
                    !zone SPRITES
sprites_init:       lda #<sprite_base
                    sta vidmem0+0x3F8
                    sta vidmem0+0x3F9
                    sta vidmem0+0x3FA
                    sta vidmem0+0x3FB
                    sta vidmem0+0x3FC
                    lda #BLACK
                    sta 0xD027
                    sta 0xD028
                    sta 0xD029
                    sta 0xD02A
                    sta 0xD02B
                    lda #0
                    sta 0xD017
                    sta 0xD01B
                    sta 0xD01C
                    sta 0xD01D
                    jsr fetch_current
                    jsr place_sprites
                    rts
fetch_current:      ldx current_ringtab_pt
                    lda rand_ringtab,x
                    sta current_ringtab+0
                    inx
                    lda rand_ringtab,x
                    sta current_ringtab+1
                    inx
                    lda rand_ringtab,x
                    sta current_ringtab+2
                    inx
                    lda rand_ringtab,x
                    sta current_ringtab+3
                    inx
                    lda rand_ringtab,x
                    sta current_ringtab+4
                    inx
                    lda rand_ringtab,x
                    bpl +
                    ldx #0
+                   stx current_ringtab_pt
                    rts
place_sprites:      lda #0
                    sta d010_val+1
                    lda current_ringtab
                    tax
                    lda spr_ringtab_x,x
                    sta 0xD000
                    lda spr_ringtab_y,x
                    sta 0xD001
                    lda spr_ringtab_msb,x
                    beq +
                    lda #%00000001
                    sta d010_val+1
+                   lda current_ringtab+1
                    tax
                    lda spr_ringtab_x,x
                    sta 0xD002
                    lda spr_ringtab_y,x
                    sta 0xD003
                    lda spr_ringtab_msb,x
                    beq +
                    lda d010_val+1
                    ora #%00000010
                    sta d010_val+1
+                   lda current_ringtab+2
                    tax
                    lda spr_ringtab_x,x
                    sta 0xD004
                    lda spr_ringtab_y,x
                    sta 0xD005
                    lda spr_ringtab_msb,x
                    beq +
                    lda d010_val+1
                    ora #%00000100
                    sta d010_val+1
+                   lda current_ringtab+3
                    tax
                    lda spr_ringtab_x,x
                    sta 0xD006
                    lda spr_ringtab_y,x
                    sta 0xD007
                    lda spr_ringtab_msb,x
                    beq +
                    lda d010_val+1
                    ora #%00001000
                    sta d010_val+1
+                   lda current_ringtab+4
                    tax
                    lda spr_ringtab_x,x
                    sta 0xD008
                    lda spr_ringtab_y,x
                    sta 0xD009
                    lda spr_ringtab_msb,x
                    beq d010_val
                    lda d010_val+1
                    ora #%00010000
                    sta d010_val+1
d010_val:           lda #0
                    sta 0xD010
                    lda #%00011111
                    sta 0xD015
                    rts
                    ANIMSPRITESSPEED = 3
anim_sprites:       lda #ANIMSPRITESSPEED
                    beq +
                    dec anim_sprites+1
                    rts
+                   lda #ANIMSPRITESSPEED
                    sta anim_sprites+1
                    ldy #4
-                   lda current_animtab,y
                    tax
                    lda anim_tab,x
                    sta vidmem0+0x03F8,y
                    inx
                    cpx #0x08
                    bne +
                    ldx #0
+                   txa
                    sta current_animtab,y
                    dey
                    bpl -
                    rts
                    CHANGESPRITESPEED = 6*3
change_sprites:     lda #CHANGESPRITESPEED
                    beq +
                    dec change_sprites+1
                    rts
+                   lda #CHANGESPRITESPEED
                    sta change_sprites+1
                    jsr fetch_current
                    jsr place_sprites
                    rts
anim_tab:           !byte sprite_base, sprite_base+2, sprite_base+1
                    !byte sprite_base+3, sprite_base+3
                    !byte sprite_base+1, sprite_base+2, sprite_base
current_animtab:    !byte 0x00, 0x03, 0x00, 0x04, 0x07
spr_ringtab_x:      !byte 0x73, 0xE3, 0xB3, 0x03, 0x83
                    !byte 0x23, 0x3B, 0xFB, 0x2B, 0x2B
spr_ringtab_y:      !byte 0x35, 0x35, 0x3D, 0x3D, 0x45
                    !byte 0x4D, 0x55, 0x55, 0x65, 0x6D
spr_ringtab_msb:    !byte 0x00, 0x00, 0x00, 0x01, 0x00
                    !byte 0x01, 0x00, 0x00, 0x01, 0x00
rand_ringtab:       !byte 9, 0, 6, 2, 1, 8, 5, 4, 3, 7
                    !byte 4, 5, 3, 8, 2, 0, 1, 7, 9, 6
                    !byte 3, 1, 7, 4, 5, 0, 2, 6, 9, 8
                    !byte 6, 9, 1, 4, 0, 5, 3, 2, 7, 8
                    !byte 3, 1, 9, 7, 8, 4, 2, 6, 5, 0
                    !byte 7, 3, 1, 9, 8, 4, 6, 0, 2, 5
                    !byte 0, 2, 9, 1, 8, 4, 5, 3, 7, 6
                    !byte 8, 1, 3, 0, 2, 5, 9, 7, 4, 6
                    !byte 7, 6, 3, 0, 9, 2, 5, 8, 4, 1
                    !byte 5, 3, 9, 7, 2, 0, 1, 8, 4, 6
                    !byte 0xFF
current_ringtab:    !byte 0x00, 0x00, 0x00, 0x00, 0x00
current_ringtab_pt: !byte 0x00
; ==============================================================================
