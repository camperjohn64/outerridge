;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : 3d1.asm
; Included from: Main Assembley Module
; Description  : 3d vector routines - fast sort method
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

radarz   equ 100
radarcz  equ 75
radarx   equ 72
shift1   equ 12
shift2   equ 11
m512     equ 1024*2/3
m1024    equ m512 * 2

         .386p
         jumps

code32   segment para public use32
         assume cs:code32, ds:code32

; define externals

         include pmode.ext                  ; protected mode externals
         include xmode.ext                  ; xmode externals by matt pritchard
         include irq.ext
         include game.ext

;        extrn _nullpalette:dword
         extrn sinus:word
         extrn negtan:word

         include macros.inc
         include equ.inc

         include vars1.inc                  ; labels and such
         include xscale.inc
         align 4
         include math.inc                   ; rotate,cos,sin,arctan...

         public _makeobjs
         public _make1obj
         public _init_tables
         public _fastimultable              ; fast imul table, dw 0-319 * 200
         public _copy_virtual_objects       ; copy real objects to virtual list

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _make1obj: Handle plotting of object ESI
; In:
;   ESI -> object #
; OUT:null
; Notes:
; Routine assumes object is already ON!  note: esi not si!
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

noa4:
         cmp esi,(radarcz - radarz)*m512
         jl short noa1
         cmp esi,(radarcz)*m512
         jge short noa1
         cmp edi,(-radarx/2)*m1024
         jl short noa1
         cmp edi,(radarx/2)*m1024
         jge short noa1
         call _ysolve
         lea ebx,[ebx+ebx*2]
         lea ecx,[ecx+ecx*2]
         lea ebp,[ebp+ebp*2]
         sar ebx,shift1
         sar ecx,shift2
         sar ebp,shift2
         mov eax,currobj
         mov xradar[eax*4],ebx
         mov yradar[eax*4],ecx
         mov zradar[eax*4],ebp
         mov whatdone[eax],1
         ret
noa1:
         mov esi,currobj
         mov whatdone[esi],0
         ret
noa5:
         cmp ebp,(radarcz - radarz)*m512
         jl short noa1
         cmp ebp,(radarcz)*m512
         jge short noa1
         cmp ebx,(-radarx/2)*m1024
         jl short noa1
         cmp ebx,(radarx/2)*m1024
         jge short noa1
         lea ebx,[ebx+ebx*2]
         lea ecx,[ecx+ecx*2]
         lea ebp,[ebp+ebp*2]
         sar ebx,shift1
         sar ecx,shift2
         sar ebp,shift2
         mov eax,currobj
         mov xradar[eax*4],ebx
         mov yradar[eax*4],ecx
         mov zradar[eax*4],ebp
         mov whatdone[eax],1
         ret
noa3:
         cmp esi,(radarcz - radarz)*m512
         jl short noa7
         cmp esi,(radarcz)*m512
         jge short noa7
         call _xsolve
         cmp edi,(-radarx/2)*m1024
         jl short noa7
         cmp edi,(radarx/2)*m1024
         jge short noa7
         call _ysolve
         lea ebx,[ebx+ebx*2]
         lea ecx,[ecx+ecx*2]
         lea ebp,[ebp+ebp*2]
         sar ebx,shift1
         sar ecx,shift2
         sar ebp,shift2
         mov eax,currobj
         mov xradar[eax*4],ebx
         mov yradar[eax*4],ecx
         mov zradar[eax*4],ebp
         mov whatdone[eax],1
         ret
noa7:
         mov esi,currobj
noa2:
         mov whatdone[esi],0
         ret

_make1obj:
         mov currobj,esi

         mov ebx,v_xs[esi*4]                ; displacement
         sub ebx,eyex
         mov ecx,v_ys[esi*4]
         sub ecx,eyey
         mov ebp,v_zs[esi*4]
         sub ebp,eyez

         mov edi,maxz*256
         cmp ebx,edi                        ; check if within visible space
         jnl s noa2                         ; if object miles away, don't bother
         cmp ebp,edi
         jnl s noa2
         cmp ecx,edi
         jnl s noa2
         neg edi
         cmp ebp,edi
         jl s noa2
         cmp ebx,edi
         jl s noa2
         cmp ecx,edi
         jl s noa2

        ;call _zsolve                       ; figure out camera displacement
         mov eax,_ematrix+32
         imul ebp
         shrd eax,edx,14
         mov esi,eax
         mov eax,_ematrix+28
         imul ecx
         shrd eax,edx,14
         add esi,eax
         mov eax,_ematrix+24
         imul ebx
         shrd eax,edx,14
         add esi,eax                        ; si = new z

         cmp esi,minz+cockpitsize           ; check if behind camera, miminum dist.
         jl noa3
         sub esi,cockpitsize

        ;call _xsolve
         mov eax,_ematrix+8
         imul ebp
         shrd eax,edx,14
         mov edi,eax
         if usez eq yes
         mov eax,_ematrix+4
         imul ecx
         shrd eax,edx,14
         add edi,eax
         endif
         mov eax,_ematrix+0
         imul ebx
         shrd eax,edx,14
         add edi,eax                        ; di = new x
         mov xad,edi                        ; store 3d offsets

         cmul eax,edi,ratiox
         idiv esi

         cmp eax,xmit                       ; tolerance is max object size/ratio
         jl noa4
         cmp eax,xmat
         jge noa4

         push eax
        ;call _ysolve                       ; solve y and set correct regs
         mov eax,_ematrix+16
         imul ecx
         shrd eax,edx,14
         mov ecx,eax
         mov eax,_ematrix+12
         imul ebx
         shrd eax,edx,14
         add ecx,eax
         mov eax,_ematrix+20
         imul ebp
         shrd eax,edx,14
         add ecx,eax                        ; cx = new y

         mov edx,ecx
         cmul eax,edx,ratioy
         idiv esi

         pop edx
         mov ebx,edi
         mov ebp,esi

         cmp eax,ymit
         jl noa5
         cmp eax,ymat
         jge noa5

         mov yad,ecx
         mov ebx,edx                        ; final test, move into appropriate regs

         mov zad,ebp
         mov zedthis,ebp                    ; store z for next sort
         mov esi,currobj                    ; pop original object number

         mov edx,xad
         cmp edx,(-radarx/2)*m1024
         jl short noaf
         cmp edx,(radarx/2)*m1024
         jge short noaf
         lea edx,[edx+edx*2]
         sar edx,shift1
         mov xradar[esi*4],edx
         mov edx,ebp
         cmp edx,(radarcz - radarz)*m512
         jl short noaf
         cmp edx,(radarcz)*m512
         jge short noaf
         lea edx,[edx+edx*2]
         sar edx,shift2
         mov zradar[esi*4],edx
         mov whatdone[esi],1
         lea ecx,[ecx+ecx*2]
         sar ecx,shift2
         mov yradar[esi*4],ecx
noaf:
         mov ecx,eax
         push ebx ecx                       ; save actual center of bitmap and command

         mov eax,31
         mov edx,ebp
         cmp v_whatshape[esi*2],19          ; explosions are always bright!
         jb short notpulsate
         sub ebp,40000
         jc short okpalx1
         mov ebx,ebp
         shr ebx,10
         sub eax,ebx
         jnc short okpalx1
         xor eax,eax
okpalx1:
         cmp _type[esi],t_badguy3
         je short pulsate
         cmp _type[esi],t_badguy4
         je short pulsate
         cmp v_whatshape[esi*2],g_camo1
         jae short notpulsate
         cmp v_whatshape[esi*2],g_bonuses
         jb short notpulsate
pulsate:
         mov bp,_timerq[esi*2]
         mov ecx,ebp
         shr ebp,2
         shr ecx,8
         push cx
         and ecx,018h
         add ebp,ecx
         and ebp,31
         pop cx
         and ecx,60h
         add ebp,ecx
         sub al,_pulsate_tables[ebp]
         cmp al,32
         jb short notpulsate
         xor al,al
notpulsate:
         mov dword ptr [_xref2],eax
         mov ebp,edx

         mov ebx,xad                        ; calc size of bitmap
         mov ecx,yad

         shl esi,1                          ; si = word
         movzx edx,v_bitobjx[esi]           ; get addition for bitmap size
         sub ebx,edx
         sub ecx,edx

         mov si,v_whatshape[esi]
         shl esi,2                          ; si = dword
         sub ebx,60
         sub ecx,60

         mov eax,_bitbase[esi]
         mov _bitmap,eax

         call _make3d                       ; ebx,ecx = top corner of bitmap in 2d

         pop ebp eax                        ; bp = y, ax = x center
         sub bp,cx                          ; bp = y height/2
         sub ax,bx                          ; ax = x width/2
         mov _scale_destheight,bp
         mov _scale_destwidth,ax

         movsx edx,bp
         movsx edi,ax
         shr edi,1
         shr edx,1
         add cx,dx
         add bx,di

         add bx,_xcent
         add cx,_ycent
         mov _scale_destx,bx
         mov _scale_desty,cx

         cmp cx,100
         jl short doonlyxsc

         mov eax,_xref2
         mov ebp,_xreftable[eax*4]
         mov dword ptr [_xref1],ebp
         jmp _xscale2

doonlyxsc:
         push [_bitmap]
         mov _yclipt,100
         mov eax,_xref2
         mov ebp,_xreftable[eax*4]
         mov dword ptr [_xref1],ebp
         call _xscale2
         pop [_bitmap]
         mov _yclipt,0
         mov _yclipb,100
         mov _xclipl,320-72
         mov eax,_xref2
         mov ebp,_xreftable[eax*4+32*4]
         mov dword ptr [_xref1],ebp
         push [_bitmap]
         call _xscale2
         pop [_bitmap]
         cmp _scale_destx,320-72
         jge short outonly
         mov _xclipl,72
         mov _xclipr,320-72
         mov eax,_xref2
         mov ebp,_xreftable[eax*4]
         mov dword ptr [_xref1],ebp
         push [_bitmap]
         call _xscale2
         pop [_bitmap]
         cmp _scale_destx,72
         jge short outonly
         mov _xclipl,0
         mov _xclipr,72
         mov eax,_xref2
         mov ebp,_xreftable[eax*4 + 32 * 4]
         mov dword ptr [_xref1],ebp
         call _xscale2
outonly:
         mov _xclipl,0
         mov _xclipr,320
         mov _yclipb,400-58
         ret

         align 4

_pulsate_tables label byte
         db 20,20,0,0,20,20,0,0,20,20,0,0,20,20,0,0,20,20,0,0,20,20,0,0,20,20,0,0,20,20,0,0
         db 20,20,20,20,0,0,0,0,0,0,0,0,0,0,0,0,20,20,20,20,0,0,0,0,0,0,0,0,0,0,0,0
         db 0,0,0,0,17,16,14,12,11,9,8,6,4,3,1,0,0,0,0,0,17,16,14,12,11,9,8,6,4,3,1,0
         db 32 dup (0)

         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Setmakeorder: Initialize original order for plotting objects
;  In=Out=null
; Notes:  This is called by _init_tables so there is no need for you to do it.
; This  must  be  called  once  at  the  beginging of the program  to  define
; in what order the objects must be plotted (back to front).   The  order  is
; constantly being re-arranged as objects move in front an behind one another
; If you want to do windowing, save the makeorder table for each window.
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

setmakeorder:

         i=0
         rept maxobjects                    ; macro to produce unrolled loop
         mov makeorder+i*4,i+1              ; set makeorder to 0,1,2,3,4
         mov finalzed+i*4,i
         i=i+1
         endm

         ret

         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _makeobjs: Make/plot all objects on _current_page
;  In=Out=null
; Notes: Called from your mainline animation routine, falls through to sort
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_makeobjs:
         xor eax,eax
         mov ecx,maxobjects+1
         mov edi,offset whatdone
         rep stosb
         xor ecx,ecx
plotagain:
         mov esi,makeorder[ecx*4]
         test v_onoff[esi],mainobject_on    ; check on/off
         jz s itsoff

         push ecx
         call _make1obj
         pop ecx
         mov eax,zedthis                    ; get z and save for re_sort
itsoff:
         mov finalzed[ecx*4],eax
         inc ecx
         cmp ecx,maxobjects
         jne short plotagain

         call _doradar

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Re_sort:Bubble sort for entire objects, fastest when already sorted (assumed)
;  In=Out=null
; Notes: No need to ever call this routine as _makeobjs falls through to here.
; This routine sorts the objects make order by the previous Z distance.
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         basedif equ makeorder-finalzed
         align 4
re_quick_sort:
         mov eax,0
         mov ebx,maxobjects
         dec ebx
         align 4
re_qsort:
         mov edi,eax                        ; i := l;
         mov esi,ebx                        ; j := r;
         mov ecx,ebx
         add ecx,eax
         shr ecx,1
         mov ecx,finalzed[ecx*4]            ; x :=
         align 4
re_whilei:                                  ; while a[i] < x do i := i + 1;
         cmp finalzed[edi*4],ecx
         jle re_whilej
         inc edi
         jmp re_whilei
         align 4
re_whilej:                                  ; while x < a[j] do j := j - 1;
         cmp ecx,finalzed[esi*4]
         jle re_ifij
         dec esi
         jmp re_whilej
         align 4
re_ifij:                                    ; if i <= j then
         cmp edi,esi
         jg re_repeatij
         mov edx,finalzed[edi*4]            ; y := a[i]; a[i] := a[j]; a[j] := y;
         xchg edx,finalzed[esi*4]
         mov finalzed[edi*4],edx
         mov edx,makeorder[edi*4]
         xchg edx,makeorder[esi*4]
         mov makeorder[edi*4],edx
         inc edi                            ; i := i + 1; j := j - 1;
         dec esi
         align 4
re_repeatij:                                ; until i > j;
         cmp edi,esi
         jle re_whilei
         cmp eax,esi                        ; if l < j then Sort(l, j);
         jge re_nextcmp
         push edi ebx
         mov ebx,esi
         call re_qsort
         pop ebx edi
         align 4
re_nextcmp:
         cmp edi,ebx                        ; if i < r then Sort(i, r);
         jge re_qsortexit
         mov eax,edi
         call re_qsort
re_qsortexit:
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _init_tables: Initialize ordering before beginning 3d animation
;  In=Out=null
; Notes: Called by YOU. Different routines between 3d1,3d2 and 3d3
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_tables:
         call setmakeorder
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Table of values for fast multiplication by screen width
; eg  mov eax,[esi*4+_fastimultable] ; eax = esi*320
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_fastimultable label dword
         i=0
         rept yactual
         dd i*(xactual/4)
         i=i+1
         endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Hey! where is my postcard! see readme.doc file and send me that postcard!
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Copy real objects to virtual objects.  You MUST call this routine before
; you draw your objects or they will be in the same place as last time.
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_copy_virtual_objects:
         cli
         cld
         mov edi,o v_whatshape
         mov esi,o _whatshape
         mov ecx,((2+2+4+4+4+1)*(maxobjects+1))+6+6
         rep movsb

         sti
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; make radar screens
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_doradar:
         mov edi,6000
         add edi, _current_page             ; point to active vga page

         mov al,15
         mov edx, sc_index+1                ; point the vga sequencer to the map
         out dx,al

         mov eax,colfron2
         mov ecx,4
         rep stosd
         stosw

         mov edi,4062
         add edi, _current_page             ; point to active vga page

         mov al,15
         mov edx, sc_index+1                ; point the vga sequencer to the map
         out dx,al

         mov eax,colfron2
         mov ecx,4
         rep stosd
         stosw
         mov al,1
         mov edx, sc_index+1                ; point the vga sequencer to the map
         out dx,al
         mov ebx,9
         add ebx,_current_page

         mov al,colfron1                    ; scanner colour
         mov ah,20
againxr:
         mov [ebx+80*0],al
         mov [ebx+80*1],al
         mov [ebx+80*2],al
         mov [ebx+80*3],al
         mov [ebx+80*4],al
         mov [ebx+80*0+62],al
         mov [ebx+80*1+62],al
         mov [ebx+80*2+62],al
         mov [ebx+80*3+62],al
         mov [ebx+80*4+62],al
         add ebx,80*5
         dec ah
         jnz short againxr

         mov al,colourtable+3
         mov edi,_current_page
         mov [edi + 6009],al
         mov [edi + 6009+80],al
         mov [edi + 4071],al
         mov [edi + 4071+80],al

         mov edi,maxobjects
rplotagain:
         dec edi
         jz outahere
rplotagain2:
         cmp whatdone[edi],1
         jne short rplotagain

         mov whatdone[edi],0
         mov ebx,xradar[edi*4]
         mov ebp,zradar[edi*4]

         mov esi,yradar[edi*4]
         cmp esi,-(radarz/2)
         jl short rplotagain
         cmp esi,(radarz/2)
         jge short rplotagain

         sub ebp,radarcz-1
         neg ebp
         add ebx,radarx/2
         mov eax,[ebp*4+_fastimultable]     ; get offset to start of line
         mov cl, bl                         ; copy to extract plane # from
         shr ebx, 2                         ; x offset (bytes) = xpos/4
         add ebx, _current_page             ; point to active vga page
         push ebx
         add ebx, eax                       ; offset = width*ypos + xpos/4

         and cl, plane_bits                 ; get plane bits
         xor al,al
         inc al
         shl al,cl
         mov edx, sc_index+1                ; point the vga sequencer to the map
         out dx,al

         xor eax,eax
         xor ecx,ecx
         mov al,_type[edi]
         mov cl,colourtable[eax]
         cmp al,3
         jae short okcol
         mov eax,esi
         add eax,radarz/2
         shr eax,1
         mov edx,eax
         shr edx,2
         add eax,edx
         cmp al,32
         jb short okshade1
         neg al
         add al,63
okshade1:
         mov ebp,_xreftable[eax*4 + 32*4]
         mov cl,[ebp + ecx]
         mov b [ebx],cl                     ; draw left pixel
         mov b [ebx+80],cl                  ; draw pixel

         mov cl,221
         mov eax,zradar[edi*4]
         add eax,radarz - radarcz
         shr eax,1
         mov edx,eax
         shr edx,2
         add eax,edx
         cmp al,32
         jb short okshade2
         neg al
         add al,63
okshade2:
         mov ebp,_xreftable[eax*4 + 32*4]
         mov cl,[ebp + ecx]
         pop ebx
         add esi,radarz/2
         mov ebp,[esi*4+_fastimultable]     ; get offset to start of line
         mov b [ebx+ebp+62],cl              ; draw pixel
         mov b [ebx+ebp+80+62],cl           ; draw pixel
         dec edi
         jnz rplotagain2
outahere:
         ret
okcol:
         mov b [ebx],cl                     ; draw pixel
         mov b [ebx+80],cl                  ; draw pixel

         pop ebx
         add esi,radarz/2
         mov ebp,[esi*4+_fastimultable]     ; get offset to start of line
         mov b [ebx+ebp+62],cl              ; draw pixel
         mov b [ebx+ebp+80+62],cl           ; draw pixel

         dec edi
         jnz rplotagain2
         ret

code32   ends
         end
