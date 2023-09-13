* = $0801
;sysline:	
	!byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00 ;= SYS 2061

*= $080d 
	sei             
	jsr $e544
	sta $d020
	lda #0
	sta $d021
	lda #31
	sta $d018
	lda #11
	sta $0286

	lda #<text
	ldy #>text                        
	jsr $ab1e

    lda #<irq
    ldx #>irq
    sta $314
    stx $315
    lda #$1b
    ldx #$00
    ldy #$7f 
    sta $d011
    stx $d012
    sty $dc0d
    lda #$01
    sta $d01a
    sta $d019
	 
init; set time, here 3:06 -> $33,$30,$36
	lda #$33
	sta $63d
	sta $63d+7
	
	lda #$31
	sta $63f
	sta $63f+7


	lda #$36
	sta $640
	sta $640+7

	lda #$00
	sta $d020

	jsr $1000

	cli
hold         
	sei
-	lda $d012
	cmp #$5e
	bne -
	
rastercol1	
	ldy #$0
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	sty $D021
	sty $d020

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

rastercol2	
	ldy #$0	
	sty $D020
	sty $d021
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

rastercol3
	ldy #$0

	sty $D020
	sty $d021

	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop

	
	
	
-	lda $d012
	cmp #$c5
	bne -
rastercol4	
	ldy #$0		
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop

	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop

	sty $D021
	sty $d020

	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop
	nop
	nop

rastercol5	
	ldy #$0	
	sty $D020
	sty $d021
	
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop

rastercol6
	ldy #$0

	sty $D020
	sty $d021

	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop
	nop	
	nop		
	nop			
	nop					
	nop
	nop

	
	
	
	
	
	
	
	ldy #$00
	sty $d020
	sty $d021
		
-	lda $d012
	cmp #$ff
	bne -
	
modify; 3 bytes, die erstmal nix machen, später kommt hier JMP SKIP rein 
	nop
	nop
	nop

timecounter
	ldx #49
	dex
	bne ++
	dec $0640
	lda $0640
	cmp #$2f
	bne +
	lda #$39
	sta $0640

	dec $063f
	lda $063f
	cmp #$2f
	bne +
;	brk
	lda #$35
	sta $63f
	dec $63d
	
	lda $63d
	cmp #$2f
	beq +++

+	ldx #50
++	stx timecounter+1


	
+

skip

	dec framecounter+1
framecounter	
	ldx #08
	bne +
	ldx #08
	stx framecounter+1
;	inc colorpointer+1
colorpointer
	lda #$00
	and #%00000111
	tax
	lda colortable,x
	sta rastercol1+1
	inx
	lda colortable,x
	sta rastercol2+1
	inx
	lda colortable,x
	sta rastercol3+1
	
	lda colortable,x
	sta rastercol4+1
	inx
	lda colortable,x
	sta rastercol5+1
	inx
	lda colortable,x
	sta rastercol6+1

modify2; später durch NOP ersetzt, damit IRQ ausbleibt	
+	cli
	

	
	jmp hold

+++	
	lda #$30; character "0"
	sta $63d
	sta $63f
	sta $640

	lda #$4C; opcode für JMP
	sta modify
	lda #<skip; lowbyte
	sta modify+1
	lda #>skip; hibyte; ergibt zusammen JMP SKIP
	sta modify+2
	lda #$ea; opcode NOP 
	sta modify2
	sei
	jmp hold
;	jmp init;

irq
	lda #$01
	sta $d019
	jsr $1003
	jmp $ea31


colortable
	!byte 14,3,1,3,14

text:

	!byte $0d,$14
	!byte $0d,$0d,$0d,$0d,$0d,$0d,$0d
	!pet " prochaine station: village de untz"
	!byte $0d,$0d,$0d
	!pet " done by r0ly / mayday!"
	!byte $0d,$0d
	!pet " sid model 8580"
	!byte $0d,$0d
	!pet " replaytime: x:xx / x:xx"
	!byte $0d,$0d
	!pet " released at nordlicht on 09-09-2023"
	!byte $0d,$14
	!byte $0d,$00

*= $1000
   	!bin "village-24.sid",,126;$7c+2
   	
*= $3800
	!bin "exochar3a.prg",,2