;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
; Filename     : More.inc
; Included from: Main assembley module
; Description  : Irq palette fading routines
;
; Written by: John McCarthy
;             1316 Redwood Lane
;             Pickering, Ontario.
;             Canada, Earth, Milky Way (for those out-of-towners)
;             L1X 1C5
;
; Internet/Usenet:  BRIAN.MCCARTHY@CANREM.COM
;         Fidonet:  Brian McCarthy 1:229/15
;   RIME/Relaynet: ->CRS
;
; Home phone, (905) 831-1944, don't call at 2 am eh!
;
; John Mccarthy would really love to work for a company programming Robots
; or doing some high intensive CPU work.  Hint. Hint.
;
; Send me your protected mode source code!
; Send me your Objects!
; But most of all, Send me a postcard!!!!
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

         .386p
         jumps

code32   segment para public use32
         assume cs:code32, ds:code32

; define externals

         include pmode.ext                  ; protected mode externals
         include irq.ext
         include macros.inc
         include equ.inc
         include kb.ext

         public _slidebytes                 ; TRAN's slide byte routine
         public _slidewords                 ; slide word routine
         public _fade_all                   ; fade palette to a common colour
         public _fade_palette               ; fade from esi to edi
         public _palette1                   ; temp storage palettes (768 bytes each)
         public _palette2
         public _sourcepal
         public _destpal
         public _fadestep
         public _fadestatus
         public _fade_palette_read          ; fade from current palette to pal at ESI
         public _wait_for_fade              ; wait for irq fade to complete
         public _get_palette                ; get palette from video card
         public _put_palette                ; put palette to video card
         public _stop_fade

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Slide a block of bytes closer to another block in value
; In:
;   BL - max value to slide by (usually 1)
;   ECX - number of bytes to slide
;   ESI - block to slide towards
;   EDI - block to slide
; Out:
;   CF=1 - no changes made
;   CF=0 - at least one change made
; Notes: Routine courtesy of TRAN from HELL.EXE
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_slidebytes:
         pushad
         xor bh,bh
slidebytesml:
         mov al,[edi]
         mov ah,[esi]
         cmp al,ah
         je short slidebytesmlc
         mov bh,1
         jb short slidebytesmlf0
         sub ah,al
         neg ah
         cmp ah,bl
         jbe short slidebytesmlf2
         mov ah,bl
slidebytesmlf2:
         neg ah
         jmp short slidebytesmlf1
slidebytesmlf0:
         sub ah,al
         cmp ah,bl
         jbe short slidebytesmlf1
         mov ah,bl
slidebytesmlf1:
         add al,ah
         mov [edi],al
slidebytesmlc:
         inc edi
         inc esi
         loop slidebytesml
         sub bh,1
         popad
         ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Slide a block of words closer to another block in value
; In:
;   BX - max value to slide by (1 = really slow slide)
;   ECX - number of words to slide
;   ESI - block to slide towards
;   EDI - block to slide
; Out:
;   CF=1 - no changes made
;   CF=0 - at least one change made
; Notes: Idea courtesy of TRAN from _slidebytes
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_slidewords:
         pushad
         xor dh,dh
slidewordsml:
         mov ax,[edi]
         mov bp,[esi]
         cmp ax,bp
         je short slidewordsmlc
         mov dh,1
         jb short slidewordsmlf0
         sub bp,ax
         neg bp
         cmp bp,bx
         jbe short slidewordsmlf2
         mov bp,bx
slidewordsmlf2:
         neg bp
         jmp short slidewordsmlf1
slidewordsmlf0:
         sub bp,ax
         cmp bp,bx
         jbe short slidewordsmlf1
         mov bp,bx
slidewordsmlf1:
         add ax,bp
         mov [edi],ax
slidewordsmlc:
         add edi,2
         add esi,2
         loop slidewordsml
         sub dh,1
         popad
         ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Data for IRQ controlled palette fading routines
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

number_of_colours equ 256

_palette1 db number_of_colours*3 dup (0)
_palette2 db number_of_colours*3 dup (0)
_sourcepal  dd 0
_destpal    dd 0
_fadestep   dd 0
_fadestatus db 0
fadecount   db 0
irqnum      dd -1

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; _Fade_palette_read: IRQ Fade from current palette to new palette at ESI
; In:
;  ESI = palette to fade to
;   BH - how much to fade each pel        (usually 1)
;   BL - how often should fade be applied (255 = every IRQ)
; Out: null
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_fade_palette_read:
         call _stop_fade
         mov _fadestep,ebx

         mov edi,offset _palette2           ; get current palette from card (yeah, i know its slow)
         mov ecx,number_of_colours*3
         xor al,al
         call _get_palette

         mov edi,offset _palette2
         jmp _fade_palette

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; _Fade_all: IRQ Fade palette to a common single colour
; In:
;  EAX = colour to fade to (xx,rd,gr,bl)
;   BH - how much to fade each pel
;   BL - how often should fade be applied (1 = very slow)
; Out: null
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_fade_all:
         call _stop_fade
         mov _fadestep,ebx
         mov ecx,number_of_colours
         mov edi,offset _palette1
         mov bl,al
         shr eax,8
fd_lp:
         mov [edi+0],ah
         mov [edi+1],al
         mov [edi+2],bl
         add edi,3
         loop fd_lp

         mov edi,offset _palette2           ; get current palette from card (yeah, i know its slow)
         mov ecx,number_of_colours*3
         xor al,al
         call _get_palette

         mov esi,offset _palette1
         mov edi,offset _palette2
         mov ebx,_fadestep

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; _Fade_palette: Fade palette from palette ESI to palette EDI
; In:
;  ESI - palette to fade to
;  EDI - palette to fade from
;   BH - how much to fade each pel
;   BL - how often should fade be applied (255 = every IRQ)
; Out: null
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_fade_palette:
         pushad
         call _stop_fade

         mov _destpal,edi
         mov edi,offset _palette1           ; copy palette to modify into buffer
         mov _sourcepal,edi
         mov _fadestep,ebx

         mov ecx,number_of_colours*3
         rep movsb

         mov fadecount,0
         mov _fadestatus,-1
         call _irq_findcontrol
         mov irqnum,ecx
         mov _irqcontrol[ecx*4],offset irqfade
         popad
         ret

irqfade:
         mov al,b _fadestep
         add fadecount,al
         jnc no_changeyet

         mov esi,_sourcepal
         mov edi,_destpal
         mov bl,b _fadestep+1
         mov ecx,number_of_colours*3
         call _slidebytes
         jc no_more_fade

         cld
         mov edx,dac_write_addr
         xor al,al
         out dx,al
         mov esi,_destpal
         inc edx
         mov ecx,number_of_colours*3
         rep outsb
         ret

no_more_fade:
         call _stop_fade
         mov _fadestatus,0
no_changeyet:
         ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Wait for fade to complete
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_wait_for_fade:
         mov _kbhit,0
_wait_for_fade2:
         test _fadestatus,-1                ; wait until fade is complete
         jz _ret
         cmp _kbhit,0
         je short _wait_for_fade2
         mov b _fadestep+1,64
         mov _kbhit,0
         ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; _Get_Palette - get current palette from video card
; In:
;   EDI - destination location
;    AL - start pel
;   ECX - number of pels to get (max 768)
; Out: ?
; Notes: Listen, I know this routine is duplicated in xmode.asm but I hate
;        stack frames.
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_get_palette:
         pushad
         mov edx, dac_read_addr             ; read block of pals
         out dx, al
         mov edx, pel_data_reg

againinport:
         insb
         nop
         nop
         nop
         nop
         loop againinport
         popad
         ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; _Put_Palette - put new palette to video card
; In:
;   ESI - palette location
;    AL - start pel
;   ECX - number of pels to write (max 768)
; Out: ?
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_put_palette:
         pushad
         mov edx, dac_write_addr
         out dx, al
         mov edx, pel_data_reg
againoutport:
         outsb
         nop
         nop
         nop
         nop
         loop againoutport
         popad
         ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Stop fading
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_stop_fade:
         cmp irqnum,-1
         je _ret
         push ecx
         mov ecx,irqnum
         mov _irqcontrol[ecx*4],offset _ret
         mov irqnum,-1
         pop ecx
         ret

code32   ends
         end
