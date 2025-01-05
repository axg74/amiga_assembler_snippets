; set sprite position - calculates the control-words of an amiga hardware-sprite
; input-parameter:
; a0 = sprite-data
; d0 = x-pos.
; d1 = y-pos.
; d2 = sprite-height
set_sprite_position:
	add.w	#$91,d0                 ; <== to be modified with your values (display window start)
	add.w	#$29,d1                 ; <== to be modified with your values (display window start)
	clr.l	0(a0)					; clear sprite controll words
	move.b	d1,0(a0)				; vertical start position of the sprite
	btst	#0,d0
	beq.s	.no_h0
	bset	#0,3(a0)				; set h0
.no_h0:
	btst	#8,d1
	beq.s	.no_e8
	bset	#2,3(a0)				; set e8
.no_e8:
	lsr.w	#1,d0					; bits H8-H1
	move.b	d0,1(a0)				; first control-word horizontal position
	add.w	d2,d1
	addq.w	#1,d1
	move.b	d1,2(a0)				; second control-word vertical end-position
	btst	#8,d1
	beq.s	.no_l8
	bset	#1,3(a0)				; set l8
.no_l8:
	rts