;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : explode.asm
; Included from: Main Assembley Module
; Description  : Explosion handler
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
; Send me your protected mode source code!
; Send me your Objects!
; But most of all, Send me a postcard!!!!
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         .386p
         jumps

code32   segment para public use32
         assume cs:code32, ds:code32

         include pmode.ext                  ; protected mode externals by TRAN
         include 3d.ext
         include function.ext
         include game.ext
         include fx.ext
         include gus.ext

         include macros.inc
         include equ.inc

         public _handle_explosions
         public _start_explosion
         public _make_explosion

ex_off   dd maxobjects dup (0)
ex_sx    dw maxobjects dup (0)

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Start explosion (no sound)
; In:
;  EDX => dw explosion table: dw bitmap#, xscale,yscale  (-1 terminated)
;   EBX - x location
;   ECX - y location
;   EBP - z location
;   SI => additional x scaling for explosion.
; Out:
;  CS - no object free for explosion
;  CC - object exploded!
;   ESI => object # of explosion (in case you want to add velocity, whatever)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_start_explosion:
         push esi
         call _search_next_available_object
         pop eax
         jc _ret

         mov ex_sx[esi*2],ax
         mov ex_off[esi*4],edx

         call _init_object
         call _put_object

ex_update_esi:
         mov edi,ex_off[esi*4]
         mov ax,[edi]
         cmp ax,-1
         jz short ex_remove

         mov _whatshape[esi*2],ax
         mov _type[esi],t_explosion
         mov ax,[edi+2]
         mul ex_sx[esi*2]
         mov _bitobjx[esi*2],ax
         add ex_off[esi*4],4
         mov _onoff[esi],mainobject_on
         clc
         ret

ex_remove:
         mov ex_off[esi*4],0
         mov _onoff[esi],0
         clc
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle explosions:
;
; Call this routine once per frame update to animate the explosions
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_handle_explosions:
         xor ebx,ebx
         mov ecx,maxobjects
         mov esi,ecx
ex_loop:
         dec esi
         cmp ex_off[esi*4],ebx
         loope short ex_loop
         jcxz _ret
         call ex_update_esi
         jmp short ex_loop

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make an explosion (with sound sample and panning)
; In:
;  EBX = x
;  ECX = y
;  EBP = z
;   AL = channel for sound
;  EDX = explosion sequence
;  ESI = x scaling
; Out:
;  CF = 1, explosion not available
;  CF = 0  BOOM!
;    ESI = object number
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_make_explosion:
         push eax ebx ecx ebp
         call _start_explosion
         jc contxx

         pop ebp ecx ebx eax
         push esi eax

         cmp _sfxtype,0
         je nosound
         call _subtract_camera
         call _determine_volume
         jc short nopan          ; volume = 0 if CF = 1
         cmp _sfxtype,1          ; sound blaster doesnt need panning
         jne short nopan
         call _determine_panning
nopan:
         call _rnd
         mov ch,ah
         and eax,3
         add al,6        ; sample #6 starts 4 explosion sounds
         pop edx         ; get channel
         xor cl,cl
         and ch,7
         add ch,23
         call _play_sample
         pop esi
         clc
         ret
nosound:
         pop eax esi
         clc
         ret
contxx:
         pop ebp ecx ebx eax
         ret

code32   ends
         end
