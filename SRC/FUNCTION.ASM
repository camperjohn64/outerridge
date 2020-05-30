;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : move.asm
; Included from: Main Assembley Module
; Description  : Automatic object movement routines/functions
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
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         .386p

code32   segment para public use32
         assume cs:code32, ds:code32

         include pmode.ext                  ; protected mode externals by TRAN
         include irq.ext                    ; irq timing externals
         include 3d.ext
         include macros.inc
         include equ.inc

         public _updvectors                 ; update vector positions/angles
         public _get_displacement           ; calculate difference between object si and di
         public _put_object                 ; put object si at ebx,ecx,ebp
         public _get_location               ; get location of object esi
         public _set_shape                  ; set shape of object si to ax
         public _set_object_on              ; set main object si to on
         public _set_bitmap_scaling         ; set bitmap base scaling for this object
         public _search_next_available_object ; find next available object for use
         public _init_object                ; initialize/clear object for use
         public _set_speed                  ; calculate velocity based on angles
         public _set_xyzadds                ; set object world velocity values for location
         public _nullpalette                ; only a null cross reference palette
         public _subtract_camera            ; subtract camera location from x,y,z
         public _relative_velocity          ; calc relative velocity of objects si and di
         public _add_xyzadds                ; add velocity of object esi to ebx,ecx,ebp
         public _get_xyzadds                ; get xyzadds of object esi

         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _updvectors: Update vector locations/angles (also does camera)
;
; In:
;    null
; Out:
;    null
;
; Notes:
; Routine is now called by irq, so animation/game continues in background. Much
; better method than using _irq_traces_past
;
; IRQ maintains a universal speed from 486dx66 machine to 386sx25 machine.
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4
_updvectors:
         mov ecx,maxobjects+1
         xor esi,esi
updateloop:
         mov eax,_xadds[esi]
         add _xs[esi],eax
         mov eax,_yadds[esi]
         add _ys[esi],eax
         mov eax,_zadds[esi]
         add _zs[esi],eax
         add esi,4
         dec ecx
         jnz short updateloop

         mov ax,_vxadds
         add _eyeax,ax
         mov ax,_vyadds
         add _eyeay,ax
         mov ax,_vzadds
         add _eyeaz,ax

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;_put_object: Set object location
;In:
;   EBX - x point
;   ECX - y point
;   EBP - z point
;    SI - object #
;Out=In
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
         align 4
_put_object:
         movzx esi,si
         mov _xs[esi*4],ebx
         mov _ys[esi*4],ecx
         mov _zs[esi*4],ebp
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;_get_location: Get object location
;In:
;   ESI - object #
;Out:
;   EBX - x point
;   ECX - y point
;   EBP - z point
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
         align 4
_get_location:
         movzx esi,si
         mov ebx,_xs[esi*4]
         mov ecx,_ys[esi*4]
         mov ebp,_zs[esi*4]
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; set_shape: Set object shape
; In:
;     AX - shape of object (this later is used as an indexer in the _objbase table)
;     SI - object #
; Out=In
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
         align 4
_set_shape:
         movzx esi,si
         mov _whatshape[esi*2],ax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; set_object_on: Turn object on
; In:
;     SI - object # to make visible
; Out=In
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
         align 4
_set_object_on:
         movzx esi,si
         or _onoff[esi],mainobject_on
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; set_bitmap_scaling: Set scaling factors for bitmaps (explosions)
; In:
;     SI - object #
;     BX - x scaling factor for bitmap
; Out=In
;
;Notes: This determines the bitmaps "Size" in the virtual world.
;       You do not have to make this smaller as the bitmap gets farther away,
;       as this is done automatically.
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
         align 4
_set_bitmap_scaling:
         movzx esi,si
         mov _bitobjx[esi*2],bx             ; bitmap scaling (gets added to _bitx)
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; search_next_available_object: Find an object which is not in use
; In:
;   null
; Out:
;  CF = 1 - no free objects
;   ESI - ?
;  CF = 0 - free object found
;   ESI - # of free object to be defined as you please
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
         align 4
_search_next_available_object:
         xor esi,esi
search_loop:
         inc esi
         cmp esi,maxobjects
         je abort_srch
         test _onoff[esi],mainobject_on
         jnz short search_loop

         clc
         ret

abort_srch:
         stc                                ; carry set if no new object available (all are already used)
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; init_object: reset all parameters of an object.
; In:
;    SI - # of object to reset
; Out:
;   null
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
         align 4
_init_object:
         movzx esi,si
         xor eax,eax
         mov _onoff[esi],al
         mov _xs[esi*4],eax
         mov _ys[esi*4],eax
         mov _zs[esi*4],eax
         mov _xadds[esi*4],eax
         mov _yadds[esi*4],eax
         mov _zadds[esi*4],eax
         mov _whatshape[esi*2],ax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _get_displacement: figure out displacement between two objects
; In:
;     SI - # of object to look at
;     DI - # of object to look from
; Out:
;    EBX - x distance (signed)
;    ECX - y distance
;    EBP - z distance
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_get_displacement:
         and edi,0000ffffh                  ; faster than movzx (but dont quote me on it)
         and esi,0000ffffh

         mov ebx,_xs[esi*4]                 ; get displacement of esi to edi
         sub ebx,_xs[edi*4]
         mov ecx,_ys[esi*4]
         sub ecx,_ys[edi*4]
         mov ebp,_zs[esi*4]
         sub ebp,_zs[edi*4]
         ret

         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _set_speed: "Move object in direction it is pointing"
;              Set speed of object si to ebp*angle, then set _lcount to di
;
; In:
;    SI = object # to set speed of
;   EBP = signed speed (10000 is good, 1 is dead slow, 10000000 is light speed, fffff000 = 4096 reverse)
; Out:
;    EBX = x velocity
;    ECX = x velocity
;    EBP = x velocity
;
; Notes:
;    EBX= (- cosx * siny) * ebp
;    ECX=        (- sinx) * ebp
;    EBP=   (cosx * cosy) * ebp
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_set_speed:
         movzx esi,si

         mov ax,_eyeax[esi*2]
         neg ax
         push eax
         call _cosine
         mov ecx,eax                        ; cx = cos x
         pop eax
         call _sine

         neg eax
         imul ebp                           ; set y speed
         shrd eax,edx,14
         push eax

         mov ax,_eyeay[esi*2]
         neg ax
         push eax
         call _cosine
         mov edx,eax                        ; dx = cos y
         pop eax
         call _sine

         mov ebx,edx                        ; save because imul trashes dx

         imul ecx                           ; ax = sy * cx
         shrd eax,edx,14                    ; shr eax,14 compensates for cos decimals
         imul ebp
         shrd eax,edx,14
         neg eax
         push eax

         mov eax,ebx
         imul ecx
         shrd eax,edx,14
         imul ebp
         shrd eax,edx,14

         mov ebp,eax
         pop ebx
         pop ecx

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _set_xyzadds:  Set velocity of object SI in world co-ordinates
; In:
;  EBX - x velocity
;  ECX - y velocity
;  EBP - z velocity
;   DI - time for travel (_lcount)
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_set_xyzadds:
         movzx esi,si
         mov _xadds[esi*4],ebx
         mov _yadds[esi*4],ecx
         mov _zadds[esi*4],ebp
         ret

         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Default/Null cross referencing palette: eg 1=1, 7=7, 221=221...
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
_nullpalette:
;         i=0
;         rept 256
;         db i
;         i=i+1
;         endm
;
         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Subtract camera: Make x,y,z relative to camera.
; In:
;   EBX = x location
;   ECX = y location
;   EBP = z location
; Out:
;   EBX = x location
;   ECX = y location
;   EBP = z location
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_subtract_camera:
         sub ebx,_eyex
         sub ecx,_eyey
         sub ebp,_eyez
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _Relative_velocity: Get difference in velocities between object si and di
; In:
;  ESI = object #
;  EDI = object #
; Out:
;  EBX - x speed difference
;  ECX - y speed difference
;  EBP - z speed difference
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
_relative_velocity:
         movzx edi,di
         movzx esi,si

         mov ebx,_xadds[esi*4]
         mov ecx,_yadds[esi*4]
         mov ebp,_zadds[esi*4]

         sub ebx,_xadds[edi*4]
         sub ecx,_yadds[edi*4]
         sub ebp,_zadds[edi*4]

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Add velocity EBX,ECX,EBP to object ESI
; In:
;  ESI = object #
;  EBX - x speed
;  ECX - y speed
;  EBP - z speed
; Out:
;  EBX - x new speed
;  ECX - y new speed
;  EBP - z new speed
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_add_xyzadds:
         add ebx,_xadds[esi*4]
         add ecx,_yadds[esi*4]
         add ebp,_zadds[esi*4]

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Get velocity of object ESI
; In:
;  ESI = object #
; Out:
;  EBX - x speed
;  ECX - y speed
;  EBP - z speed
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_get_xyzadds:
         mov ebx,_xadds[esi*4]
         mov ecx,_yadds[esi*4]
         mov ebp,_zadds[esi*4]

         ret

code32   ends
         end
