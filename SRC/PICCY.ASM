;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Game Piccy explode
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         .386p
         jumps

code32   segment para public use32
         assume cs:code32, ds:code32

         include pmode.ext
         include fade.ext
         include irq.ext
         include init.ext
         include fx.ext
         include gus.ext
         include xmode.ext
         include game.ext
         include file.ext
         include 3d.ext
         include loadgif.ext
         include macros.inc
         include equ.inc
         include kb.ext
         include control.ext

         public _game_intro
         public _write_text
         public _fancy_fade1
         public _xscale3
         public _sub
         public _ouch

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Main GAME intro
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_game_intro:
         mov eax,_title_palette             ; exit if picture not loaded correctly
         or eax,_title_picture
         jz _ret

         mov edx,_title_picture
         xor eax,eax
         push edx
         push eax
         call _draw_bitmap
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Tile gif number eax
;  EAX = number of GIF to plot
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

tspeed   db 1
tcol     db 255
txx      dw 10
tyy      dw 10
ccqx     dd 0
dubsax   dd 0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Write text to screen following macros for speed and colour
;  ESI => text to plot
;
; commands:
;  255 = new position dw x,y
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_write_text:
         lodsb

         cmp al,0
         je _ret
nonewspeed:
         cmp al,255
         jne short nonewloc
         lodsw
         mov txx,ax
         lodsw
         mov tyy,ax
         jmp short _write_text
nonewloc:
         xor ah,ah
         push esi

         push ax
         push ax
         pushw txx
         pushw tyy
         pushw 0
         call _tgprintc
         pop ax
         movzx eax,al
         xor ecx,ecx
         mov cl,_charlentbl[eax]
         add txx,cx

         pop esi
         jmp _write_text

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Slide one screen onto another
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

ggff dd 26
addgd dd 0
xad dd 0

_fancy_fade1:
         mov eax,_xreftable[31*4]
         mov dword ptr _xref3,eax
         mov dword ptr _xref4,eax
         call _rnd
          if registered eq yes
         and eax,7
         cmp al,5
         jae _fancy_fade1
          elseif registered eq no
         and eax,3
          endif
         inc eax
         imul eax,48
         mov addgd,eax
         mov ggff,26

         movzx ebx,_active_page
         xor bl,1
         mov eax, _page_addr[ebx*4]
         mov _current_page, eax

         call _rnd
         and eax,3
         mov ch,al
         add ch,26
         mov eax,1
         mov al,_gunsound[eax]
         mov dl,fire_chan
         mov bh,8
         mov bl,15
         mov cl,0
         call _play_sample

         mov ax,_cliplt
         mov bx,_cliprt
         mov cx,_cliptp
         mov dx,_clipbt
         push ax bx cx dx
         mov _cliplt,0
         mov _cliprt,xactual-1
         mov _cliptp,0
         mov _clipbt,yactual-1

         mov ax,2
         mov _scale_destwidth,ax
         mov ax,4
         mov _scale_destheight,ax
         mov ax,xactual/2
         mov _scale_destx,ax
         mov ax,yactual/2
         mov _scale_desty,ax
         xor eax,eax
kll:
         mov ebx,eax
         imul ebx,9
         sub _scale_destx,bx
         sub _scale_desty,bx
         sub _scale_desty,bx
         shl bx,1
         add _scale_destwidth,bx
         add _scale_destheight,bx
         add _scale_destheight,bx
         sub ggff,eax
         mov eax,ggff
         cmp eax,48
         jb short okgff
         sub eax,48
         cmp eax,48
         jb short okgff
         mov eax,47
okgff:
         add eax,addgd
         mov esi,_bitbase[eax*4]
         mov _bitmap,esi
         mov eax,_irq_tracespast
         push eax
         mov ax,_scale_destwidth
         mov bx,_scale_destheight
         mov cx,_scale_destx
         mov dx,_scale_desty
         push ax bx cx dx
         call _xscale3
         call _sync_display
         pop dx cx bx ax
         mov _scale_destwidth,ax
         mov _scale_destheight,bx
         mov _scale_destx,cx
         mov _scale_desty,dx
         pop eax
         sub eax,_irq_tracespast
         neg eax
         cmp ggff,0
         jg  kll

         pop dx cx bx ax
         mov _cliplt,ax
         mov _cliprt,bx
         mov _cliptp,cx
         mov _clipbt,dx

         call _rnd
         mov ch,ah
         and eax,3
         add al,6        ; sample #6 starts 4 explosion sounds
         mov dl,explode_chan
         mov cl,0
         mov bh,8
         mov bl,15
         and ch,7
         add ch,23
         call _play_sample

         mov eax,03f3f2ch
         call _wipeoffpalette
         call _fade_to_game
         call _flip_page

         mov ax,_display_page
         push ax
         xor ax,1
         push ax
         call _copy_page
done:
         ret
_xscale3:
         cmp _scale_destwidth, 2            ; if destination width is less than 2
         jl s done                          ;     then don't draw it.

         cmp _scale_destheight, 2           ; if destination height is less than 2
         jl s done                          ;     then don't draw it.

         mov ax, _scale_desty               ; if it is completely below the
         cmp ax, _clipbt                    ; lower clip bondry,
         jg s done                          ;     then don't draw it.

         add ax, _scale_destheight          ; if it is above clip boundries
         dec ax                             ;     then don't draw it.
         cmp ax, _cliptp
         jl s done

         mov ax, _scale_destx               ; if it is to the right of the
         mov cx, _cliprt                    ; right clip boundry
         cmp ax, _cliprt                    ;     then don't draw it.
         jg s done

         add ax, _scale_destwidth           ; if it is completely to the left
         dec ax                             ; of the left clip boundry,
         cmp ax, _cliplt                    ;     then don't draw it.
         jl done

         mov esi, _bitmap                   ; make esi point to _bitmap data
         lodsw                              ; get source x width
         mov sourcewidth,ax
         lodsw                              ; get source y height
         mov sourceheight,ax

         mov ax, _scale_destwidth           ; clippedwidth is initially set to
         mov clippedwidth, ax               ; the requested dest width.

         add ax,ax                          ; initialize the x decision var
         neg ax                             ; to be -2*_scale_destwidth
         mov decisionx, ax                  ;

         mov ax, _scale_destheight          ; clippedheight is initially set to
         mov clippedheight, ax              ; the requested dest size.

         add ax,ax                          ; initialize the y decision var
         neg ax                             ; to be -2*_scale_destheight
         mov decisiony, ax                  ;

         movsx eax, _cliptp                 ; if y is below the top
         mov edx, eax                       ; clipping boundry, then we don't
         sub dx, _scale_desty               ; need to clip the top, so we can
         js s notopclip2                    ; jump over the clipping stuff.

         mov _scale_desty, ax               ; this block performs clipping on the
         sub clippedheight, dx              ; top of the _bitmap.  i have heavily
        ;movsx ecx, sourceheight            ; optimized this block to use only 4

         mov ecx,edx ;*
         shl ecx,6

        ;imul ecx, edx                      ; 32-bit registers, so i'm not even
         mov eax, ecx                       ; gonna try to explain what it's doing.
         cdq                                ; but i can tell you what results from
         movsx ebx, _scale_destheight       ; this:  the decisiony var is updated
         idiv ebx                           ; to start at the right clipped row.
        ;movsx edx, sourcewidth             ; y is moved to the top clip

         mov edx,eax ;*
         shl edx,6

        ;imul edx, eax                      ; boundry. clippedheight is lowered since
         add esi, edx                       ; we won't be drawing all the requested
         imul eax, ebx                      ; rows. esi is changed to point over
         sub ecx, eax                       ; the _bitmap data that is clipped off.
         sub ecx, ebx                       ;
         add ecx, ecx                       ;
         mov decisiony, cx                  ; <end of top clipping block>

notopclip2:
         mov ax, _scale_desty               ; if the _bitmap doesn't extend over the
         add ax, clippedheight              ; bottom clipping boundry, then we
         dec ax                             ; don't need to clip the bottom, so we
         cmp ax, _clipbt                    ; can jump over the bottom clip code.
         jle s nobottomclip2

         mov ax, _clipbt                    ; clip off the bottom by reducing the
         sub ax, _scale_desty               ; clippedheight so that the _bitmap won't
         inc ax                             ; extend over the lower clipping
         mov clippedheight, ax              ; boundry.

nobottomclip2:
         movsx eax, _cliplt                 ; if x is to the left of the
         mov edx, eax                       ; top clipping boundry, then we don't
         sub dx, _scale_destx               ; need to clip the left, so we can
         js s noleftclip2                   ; jump over the clipping stuff.

         mov _scale_destx, ax               ; this block performs clipping on the
         sub clippedwidth, dx               ; left of the _bitmap.  i have heavily
        ;movsx ecx, sourcewidth             ; optimized this block to use only 4

         mov ecx,edx ;*
         shl ecx,6

        ;imul ecx, edx                      ; 32-bit registers, so i'm not even
         mov eax, ecx                       ; gonna try to explain what it's doing.
         cdq                                ; but i can tell you what results from
         movsx ebx, _scale_destwidth        ; this:  the decisionx var is updated
         idiv ebx                           ; to start at the right clipped column.
         add esi, eax                       ; x is moved to the left clip
         sub ebx,_hackx
         imul eax, ebx                      ; boundry. clippedwidth is reduced since
         sub ecx, eax                       ; we won't be drawing all the requested
         sub ecx, ebx                       ; cols. esi is changed to point over
         add ecx, ecx                       ; the _bitmap data that is clipped off.
         mov decisionx, cx                  ; <end of left clipping block >

noleftclip2:
         mov ax, _scale_destx               ; if the _bitmap doesn't extend over the
         add ax, clippedwidth               ; right clipping boundry, then we
         dec ax                             ; don't need to clip the right, so we
         cmp ax, _cliprt                    ; can jump over the right clip code.
         jle s noclipright2

         mov ax, _cliprt                    ; clip off the right by reducing the
         sub ax, _scale_destx               ; clippedwidth so that the _bitmap won't
         inc ax                             ; extend over the right clipping
         mov clippedwidth, ax               ; boundry.

         ;calculate starting video address
noclipright2:
         movsx edi, _scale_desty            ; we are going to set edi to start point
         mov edi,_fastimultable[edi*4] ; *
        ;imul edi, xactual/4
         movsx eax, _scale_destx            ; the offset edi is
         mov cx, ax                         ; calculated by:
         shr eax, 2                         ; edi = y*80+x/2
         add eax, _current_page
         add edi,eax                        ; edi is ready!

         mov dx, sc_index                   ; point the vga sequencer to the map
         mov al, map_mask                   ; mask register, so that we only need
         out dx, al                         ; to send out 1 byte per column.

         inc dx                             ; move to the sequencer's data register.
         and cx, 3                          ; calculate the starting plane. this is
         mov al, 11h                        ; just:
         shl al, cl                         ; plane =  (11h << (x and 3))
         out dx, al                         ; select the first plane.

         xor ecx,ecx
         mov cx, sourcewidth                ; use cx for source width
         mov xad, ecx
         shl sourcewidth,1

         movzx eax,al

         align 4                            ; since this point gets jumped to a lot,
         ; make sure that it is dword aligned.
rowloop2:
         push esi                           ; save the starting source index
         push edi                           ; save the starting dest index
         push eax                           ; save the current plane mask
         push ebp                           ; save the current base pointer

         movzx ecx, clippedheight              ; use al for row counter (0-239)
         mov bx, decisiony                  ; use bx for decision variable
         mov dx, sourceheight               ; use dx for source height * 2
         add dx, dx
         mov bp, _scale_destheight          ; use bp for dest height * 2
         add bp, bp
         mov al, [esi]                      ; get the first source pixel
         or al,al
         jz null_loop                       ; if zero, perform null loop

         db 8ah,80h
_xref3   db 0,0,0,0

         align 4                            ; common jump point... align for speed.
columnloop2:
         mov [edi], al                      ; draw a pixel
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns s incsourcerow2
         mov [edi], al                      ; draw a pixel
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns s incsourcerow2
         mov [edi], al                      ; draw a pixel
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns s incsourcerow2
         mov [edi], al                      ; draw a pixel
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns s incsourcerow2

         mov [edi], al                      ; draw a pixel
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         js s columnloop2                   ; draw this source pixel again

incsourcerow2:
         add esi, xad                       ; move to the next source pixel
         sub bx, bp                         ; decrement the decision variable
         jns s incsourcerow2                ; see if we need to skip another source pixel
         mov al, [esi]                      ; get the next source pixel
         or al,al
         jz s null_loop

         db 8ah,80h
_xref4   db 0,0,0,0
         jmp s columnloop2                  ; start drawing this pixel

donewithcol2:
         pop ebp                             ; restore bp to access variables
         pop eax                            ; restore al = plane mask
         pop edi                            ; restore di to top row of screen
         pop esi                            ; restore si to top row of source bits

         rol al, 1                          ; move to next plane
         adc edi, 0                         ; go on to next screen column
         mov edx, sc_data                   ; tell the vga what column we're in
         out dx, al                         ; by updating the map mask register

         mov bx, decisionx                  ; use bx for the x decision variable
         add bx, sourcewidth                ; increment the x decision variable
         js s nextcol2                      ; jump if we're still in the same source col.
         mov dx, _scale_destwidth           ; dx = w * 2
         add dx, dx
incsourcecol2:
         inc esi                            ; move to next source column
         sub bx, dx                         ; decrement x decision variable
         jns s incsourcecol2                ; see if we skip another source column
nextcol2:
         mov decisionx, bx                  ; free up bx for colloop
         dec clippedwidth                   ; if we're not at last column
         jnz rowloop2                       ;    then do another column
done2:
         ret                                ; we're done!

         align 4                            ; common jump point... align for speed.
null_loop:
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns s incsourcerow2
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns s incsourcerow2
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns   incsourcerow2
         dec ecx                            ; decrement line counter
         jz s donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns   incsourcerow2
         dec ecx                            ; decrement line counter
         jz   donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns   incsourcerow2
         dec ecx                            ; decrement line counter
         jz   donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns   incsourcerow2
         dec ecx                            ; decrement line counter
         jz   donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns   incsourcerow2
         dec ecx                            ; decrement line counter
         jz   donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         jns   incsourcerow2

         dec ecx                            ; decrement line counter
         jz   donewithcol2                  ; see if we're done with this column
         add edi, xactual/4                 ; go on to the next screen row
         add bx, dx                         ; increment the decision variable
         js   null_loop                     ; perform more increments
         jmp   incsourcerow2

sourcewidth        dw ?                     ; workspace for icon scale routine
sourceheight       dw ?
decisionx          dw ?
decisiony          dw ?
clippedwidth       dw ?
clippedheight      dw ?

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_sub:
         mov _ouch,0
         cmp _inpause,yes
         je _ret
         cmp _save_picture,1
         je _ret
         cmp _debug_calc,4
         ja _ret
         dec serdec
         jnz _ret
         inc serdec
         call _rnd
         and al,0b5h
         jnz _ret
         and ah,7fh
         mov numadd,ah
         mov serdec,25
         mov edx, dac_read_addr
         xor al,al
         out dx, al
         add dl,2
         mov ecx,5
kasd:
         in al,dx
         or al,al
         jnz _ret
         loop short kasd
         in al,dx
         dec al
         jnz _ret

         inc _ouch
         out_8 sc_data, all_planes          ; write to all planes
         mov esi,offset _nsat
morelodb:
         xor eax,eax
         lodsb
         cmp al,-1
         je _ret
         mov ebx,eax
         mov bl,numadd
         mov jds,7
moreloda:
         mov dl,[esi]
         inc esi
         xor ecx,ecx
         inc cl
         mov ebp,7
sb_nk:
         sal dl,cl
         jnc short sb_sk
         mov edi,_fastimultable[ebx*4 + 100*4]
         add edi,eax
         add edi,_current_page
againwp:
         mov byte ptr [edi+0*80],cl
         mov byte ptr [edi+1*80],cl
         mov byte ptr [edi+2*80],cl
         mov byte ptr [edi+3*80],cl
         mov byte ptr [edi+4*80],cl
         mov byte ptr [edi+5*80],cl
         mov byte ptr [edi+6*80],cl
         mov byte ptr [edi+7*80],cl
sb_sk:
         inc al
         dec ebp
         jnz sb_nk
         sub al,7
         add bl,8
         sub bl,cl
         dec jds
         jnz short moreloda
         jz short morelodb

jds      db 0
serdec   dw 1000
numadd   db 45
_ouch    db 0

_nsat    db 0
         db 11111001b
         db 11001100b
         db 11001101b
         db 11111000b
         db 11001101b
         db 11001100b
         db 11111001b
         db 7
         db 11001100b
         db 11001101b
         db 11001100b
         db 11001101b
         db 11001100b
         db 11001101b
         db 01111001b
         db 14
         db 11001100b
         db 11001101b
         db 11001100b
         db 01111001b
         db 00110001b
         db 00110000b
         db 00110001b
         db 22
         db 11111100b
         db 00110001b
         db 00110000b
         db 00110001b
         db 00110000b
         db 00110001b
         db 00110001b
         db 29
         db 11001100b
         db 11001101b
         db 11001100b
         db 11111101b
         db 11001100b
         db 11001101b
         db 11001101b
         db 36
         db 11111101b
         db 00110000b
         db 00110001b
         db 00110001b
         db 00110000b
         db 00110001b
         db 11111101b
         db 43
         db 01111000b
         db 11001101b
         db 11000000b
         db 01111001b
         db 00001100b
         db 11001101b
         db 01111000b
         db 52
         db 01111000b
         db 11001101b
         db 11000000b
         db 11011101b
         db 11001101b
         db 11001100b
         db 01111001b
         db 59
         db 01111001b
         db 11001100b
         db 11001101b
         db 11111101b
         db 11001100b
         db 11001101b
         db 11001100b
         db 66
         db 11000110b
         db 11111111b
         db 11010110b
         db 11010111b
         db 11000110b
         db 11000111b
         db 11000110b
         db 74
         db 11111101b
         db 11000000b
         db 11000001b
         db 11111000b
         db 11000001b
         db 11000000b
         db 11111101b
         db -1

code32   ends
         end
