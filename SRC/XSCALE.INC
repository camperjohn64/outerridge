;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : xscale.inc
; Included from: 3D1.ASM, 3D2.ASM, 3D3.ASM
; Description  : bitmap Scaling routines - non-cartisian plotting
;
; Routine uses only 4 plane changes for entire bitmap!  Routine is currently
; hardcoded to handle 64x64 only, but that could be easily modified.  First
; 2 words of bitmap are x and y size of bitmap (dw 64,64)
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         public _xscale2
         public _xref1
         public _xref2
         public _hackx

_hackx   dd 0
_xref1   dd 0
_xref2   dd 0
         dd 0
         dd 0
         dd 0


 raq dd 25
 ddddd dd 0

_xclipl          dd 0
_xclipr          dd 320
_yclipt          dd 0
_yclipb          dd 400-58
_scale_xdestsize dd 0
_scale_ydestsize dd 0
_scale_xlocation dd 0
_scale_ylocation dd 0
_bitmapxsize     dd 0
_bitmapysize     dd 0

_xcoarsestep     dd 0
_xfinestep       dd 0
_xactualstep     dd 0
_xbits           dd 0
_ycoarsestep     dd 0
_yfinestep       dd 0
_yactualstep     dd 0
_ybits           dd 0
_right_edge      dd 0
_bottom_edge     dd 0

_scale_plane     db 0
_planes_left     db 0
_original_edi    dd 0
_ylength         dd 0
_ytempbits       dd 0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

done:
         ret
_xscale2:
         cmp _scale_destwidth, 1            ; if destination width is less than 2
         jl s done                          ;     then don't draw it.

         cmp _scale_destheight, 1           ; if destination height is less than 2
         jl s done                          ;     then don't draw it.
         xor eax,eax
         mov ax,_scale_destwidth
         mov _scale_xdestsize,eax
         mov ax,_scale_destheight
         mov _scale_ydestsize,eax

         movsx eax,_scale_destx
         mov _scale_xlocation,eax
         movsx eax,_scale_desty
         mov _scale_ylocation,eax

        ;cmp _scale_xdestsize, 2            ; if destination width is less than 2
        ;jl s done                          ;     then don't draw it.

        ;cmp _scale_ydestsize, 2            ; if destination width is less than 2
        ;jl s done                          ;     then don't draw it.

         mov ebx, _scale_ylocation          ; if it is completely below the
         mov edx, _yclipb
         cmp ebx, edx                       ; lower clip bondry,
         jge done                           ;     then don't draw it.

         inc _scale_ydestsize
         add ebx, _scale_ydestsize          ; if it is above clip boundries
         cmp ebx, _yclipt
         jle done

         mov eax, _scale_xlocation          ; if it is to the right, abort
         mov ecx, _xclipr
         cmp eax, ecx
         jge done

         inc _scale_xdestsize
         add eax, _scale_xdestsize          ; if it is completely to the left
         mov ebp, _xclipl
         inc ebp
         cmp eax, ebp                       ;     then don't draw it.
         jle done

         inc ecx
         cmp eax, ecx
         jl  short sc_okright
         mov eax, ecx
sc_okright:
         add eax,2
         mov _right_edge,eax

         cmp ebx, edx
         jle short sc_okbottom
         mov ebx, edx
sc_okbottom:
         mov _bottom_edge,ebx

         xor eax,eax

         mov esi, _bitmap                   ; make esi point to bitmap data
         lodsw                              ; lodsd for 32bit sizes
         mov _bitmapxsize,eax
         push eax
         lodsw
         mov _bitmapysize,eax
         mov _bitmap,esi                    ; update location for bitmap load

         mov ecx,_scale_ydestsize           ; ystep is amount to go per unit
         xor edx,edx
         shl eax,16
         idiv ecx
         mov _yactualstep,eax
         mov ebx,eax
         shr eax,16
         shl eax,6                          ; * 64 for outer ridge only!
         mov _ycoarsestep,eax
         shl ebx,16
         mov _yfinestep,ebx
         shr ebx,2
         mov _ybits,ebx

         pop eax
         mov ecx,_scale_xdestsize           ; xstep is amount to go per unit
         xor edx,edx
         shl eax,16
         dec ecx
         idiv ecx
         mov _xactualstep,eax
         shl eax,2
         mov ebx,eax
         shr eax,16
         mov _xcoarsestep,eax
         shl ebx,16
         mov _xfinestep,ebx
         shr ebx,2
         mov _xbits,ebx

         mov eax,_yclipt
         mov ebx,_scale_ylocation
         cmp eax,ebx
         jle short sc_nocliptop

         mov _scale_ylocation,eax
         sub eax,ebx
         mov ebx,_yactualstep
         imul ebx
         mov word ptr _ybits + 2,ax
         shr eax,16
         shl eax,6                          ; * 64 for outer ridge only!
         add _bitmap,eax                    ; add to bitmap load offset
sc_nocliptop:

         mov eax,_xclipl
         mov ebx,_scale_xlocation
         cmp eax,ebx
         jle short sc_noclipleft

         mov _scale_xlocation,eax
         sub eax,ebx
         mov ebx,_xactualstep
         shl eax,2
         inc eax
         imul ebx
         shr eax,2
         mov word ptr _xbits + 2,ax
         shr eax,16
         add _bitmap,eax
sc_noclipleft:

         mov _planes_left,4
         mov edi,_scale_ylocation
         mov edi,_fastimultable[edi*4]      ; i = 0:rept yscreen:dd i:i=i+xscreen/4:endm
         add edi,_current_page
         mov eax,_scale_xlocation
         mov ecx,eax
         shr eax,2
         add edi,eax
         mov edx, sc_index                  ; point the vga sequencer to the map
         mov al, map_mask                   ; mask register, so that we only need
         out dx, al                         ; to send out 1 byte per column.
         inc edx                            ; move to the sequencer's data register.
         and cl, 3                          ; calculate the starting plane.
         mov al, 11h
         shl al, cl                         ; plane =  (11h << (x and 3))
         out dx, al                         ; select the first plane.
         mov _scale_plane,al
         mov edx, sc_data                   ; tell the vga what column we're in
         out dx, al
         mov edx,_xref1
         mov ebp,_xfinestep
         mov ebx,_xcoarsestep
         mov _original_edi,edi
         mov eax,_bottom_edge
         sub eax,_scale_ylocation
         mov _bottom_edge,eax
         mov _ylength,eax
         mov eax,_ybits
         mov _ytempbits,eax
         mov esi,_bitmap
sc_more:
         mov eax,_right_edge
         sub eax,_scale_xlocation
         shr eax,2
         or eax,eax
         jle short _abort_loop
         mov ah,xactual/4                   ; 360/4 (max x)
         sub ah,al
         shr eax,8                          ; mov al,ah:xor ah,ah
         shl eax,4                          ; eax = number of loops for scale
         add eax,offset _unrolled_loop      ; eax = eax * 16 + loop
sc_down:
         push eax edi esi
         push eax
         xor eax,eax
         mov ecx,_xbits
         ret                                ; jump to unrolled loop
_return_from_loop:                          ; and ends up here
         pop esi edi
         add esi,_ycoarsestep
         mov eax,_yfinestep
         add _ytempbits,eax
         jnc short sc_noaddtoedi
         add esi,64                         ; * 64 for outer ridge only!
sc_noaddtoedi:
         add edi,xactual/4
         pop eax
         dec _ylength
         jnz short sc_down
_abort_loop:
         mov eax,_bottom_edge
         mov _ylength,eax
         mov eax,_ybits
         mov _ytempbits,eax
         inc _scale_xlocation
         mov eax,_xactualstep
         mov ecx,eax
         shl eax,16
         add _xbits,eax
         adc _bitmap,0
         shr ecx,16
         add _bitmap,ecx
         mov esi,_bitmap

         rol _scale_plane,1
         adc _original_edi,0                ; go on to next screen column
         mov edi,_original_edi
         mov al,_scale_plane
         push edx
         mov edx, sc_data                   ; tell the vga what column we're in
         out dx, al                         ; by updating the map mask register
         pop edx
         dec _planes_left
         jnz sc_more

         ret

_unrolled_loop:
         rept xactual/4
         local sc_skipit
         mov al,[esi]
         or al,al
         jz short sc_skipit
         mov al,[edx+eax]
         mov [edi],al
sc_skipit:
         inc edi
         add ecx,ebp
         adc esi,ebx
         endm
         jmp _return_from_loop

