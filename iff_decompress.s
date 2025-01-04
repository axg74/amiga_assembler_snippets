; decoding an IFF-file (DPaint4) with 4 bitplanes (16 colors)
; and display with custom copperlist
start:	
    lea	$dff000,a5

	lea	pic_iff,a0
	lea	colors,a1
	bsr	iff_get_color_palette
	
	move.l	#screen,a0
	move.l	#40*256-1,d7
.clear_screen:
	clr.l	(a0)+
	dbf	d7,.clear_screen

	lea	pic_iff,a0
	lea	screen,a1
.search_body:
	cmp.l	#"BODY",(a0)
	beq.s	.body_found
	addq.l	#2,a0
	bra.s	.search_body
.body_found:
	addq.l	#4,a0	

	move.l	(a0)+,d7		; body-length in bytes	
	subq.l	#1,d7
.decompress:
	clr.l	d0
	move.b	(a0)+,d0
	tst.b	d0
	bmi.s	.compressed_byte
.fill1:
	move.b	(a0)+,(a1)+		; uncompressed byte
	subq.l	#1,d7			; body length -1
	dbf	d0,.fill1
	bra.s	.next
.compressed_byte:
	neg.b	d0

	clr.l	d2
	move.b	(a0)+,d2
	subq.l	#1,d7			; body length -1
.copy:
	move.b	d2,(a1)+
	dbf	d0,.copy
.next:
	dbf	d7,.decompress	
	
	move.w	$2(a5),d0
	or.w	#$8000,d0
	move.w	d0,dmasave

	move.w	$1c(a5),d0
	or.w	#$8000,d0
	move.w	d0,intenasave
	
	move.w	#$7fff,$96(a5)
	move.w	#$7fff,$9a(a5)
	
	move.l	#screen,d0
	lea     planes,a0
	moveq	#4-1,d7
.initbpl:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0
	addq.l	#8,a0
	dbf	d7,.initbpl
		
	move.w	#$83e0,$96(a5)

	move.l	#copperliste,$80(a5)
	move.w	#0,$88(a5)
	
.loop:	
    btst	#6,$bfe001
	bne.s	.loop

	move.l	4,a6
	lea	gfxname,a1
	clr.l	d0
	clr.l	d1
	jsr	-552(a6)
	move.l	d0,a1
	move.l	38(a1),$80(a5)
	move.w	#0,$88(a5)
	jsr	-414(a6)
	move.w	#$7fff,$96(a5)
	move.w	#$7fff,$9a(a5)
	move.w	dmasave,$96(a5)
	move.w	intenasave,$9a(a5)
	moveq	#0,d0
	rts

; a0 = iff-data
; a1 = copperlist colors
iff_get_color_palette:
.search_cmap:
	cmp.l	#"CMAP",(a0)
	beq.s	.cmap_found
	addq.l	#2,a0
	bra.s	.search_cmap
.cmap_found:
	addq.l	#4,a0
	
	move.l	(a0)+,d7
	divu	#3,d7
	subq.w	#1,d7
.loop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a0)+,d0	; red
	move.b	(a0)+,d1	; green
	move.b	(a0)+,d2	; blue
	lsl.l	#4,d0
	lsr.l	#4,d2
	or.w	d0,d1
	or.w	d1,d2
	move.w	d2,2(a1)
	add.l	#4,a1	
	dbf	d7,.loop
	rts

gfxname:	dc.b	"graphics.library",0
	        even

dmasave:	dc.w	0
intenasave:	dc.w	0

	        section data,data_c
copperliste:
            dc.w	$008e,$2981,$0090,$29c1
            dc.w	$0092,$0038,$0094,$00d0

sprites:
            dc.w	$0120,$0000,$0122,$0000
            dc.w	$0124,$0000,$0126,$0000
            dc.w	$0128,$0000,$012a,$0000
            dc.w	$012c,$0000,$012e,$0000
            dc.w	$0130,$0000,$0132,$0000
            dc.w	$0134,$0000,$0136,$0000
            dc.w	$0138,$0000,$013a,$0000
            dc.w	$013c,$0000,$013e,$0000
planes:	
            dc.w	$00e0,$0000,$00e2,$0000
            dc.w	$00e4,$0000,$00e6,$0000
            dc.w	$00e8,$0000,$00ea,$0000
            dc.w	$00ec,$0000,$00ee,$0000
            dc.w	$00f0,$0000,$00f2,$0000
            
            dc.w	$0100,$4200,$0102,$0000
            dc.w	$0104,$0000,$0106,$0000
            dc.w	$01fc,$0000
            dc.w	$0108,120
            dc.w	$010a,120
colors:
            dc.w	$0180,$0000,$0182,$0fff,$0184,$0f00,$0186,$00f0
            dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
            dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
            dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
            dc.w	$ffff,$fffe
	
pic_iff:    incbin	"picture.iff"

	        section ram,bss_c
screen:	    ds.b	40*256*4