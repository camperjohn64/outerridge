;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
;        Filename     : Math.inc
;        Included from: 3D1.ASM, 3D2.ASM, 3D3.ASM
;        Description  : General math functions.
;
;        Written by: John McCarthy
;                    1316 Redwood Lane
;                    Pickering, Ontario.
;                    Canada, Earth, Milky Way (for those out-of-towners)
;                    L1X 1C5
;
;        Internet/Usenet:  BRIAN.MCCARTHY@CANREM.COM
;                Fidonet:  Brian McCarthy 1:229/15
;          RIME/Relaynet: ->CRS
;
;        Home phone, (905) 831-1944, don't call at 2 am eh!
;
; Send me your protected mode source code!
; Send me your Objects!
; But most of all, Send me a postcard!!!!
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         public _user3d                     ; calculate 3d ?actual*?/z (both x and y)
         public _user3dx                    ; xactual*x/z
         public _user3dy                    ; yactual*y/z
         public _rotate_by_camera           ; 32 bit _rotate_point using _ematrix
         public _zsolve                     ; solve single equation variable
         public _ysolve
         public _xsolve
         public _cosine
         public _sine
         public _arctan
         public _setsincose                 ; set camera matrix
         public _calc_angles                ; calculate angles between objects di,si
         public _calc_middle                ; calculate angles of ebx,ecx,ebp into x,y
         public _inverse_rotate             ; rotate point backwards through angles Z,X and Y
         public _rotate_x                   ; perform rotation along selected axis, AX = angle
         public _rotate_y
         public _rotate_z
         public _point_z                    ; align z angle to point EBX,ECX and EBP
         public _sqrt                       ; eax=sqr(eax), thanks to TRAN!

         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _user3d - scale 3d point into 2d point
; In:
;    EBX - x point
;    ECX - y point
;    EBP - z point
; Out:
;    EBX - x point
;    ECX - y point
;    EBP - z point
;
; Notes:
;
; fast ratios found in macros.inc since
; multiplication has been substituted with fast lea
;
; trashes eax,edx,edi
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_user3d:                                    ; bp must always be non-zero
         cmul eax,ebx,ratiox                ; use fast constant multiply

         idiv ebp
         mov ebx,eax

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _user3dy - scale 3d point into 2d point on x axis only
; In:
;    ECX - y point
;    EBP - z point
; Out:
;    ECX - y point
;    EBP - z point
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
_user3dy:
         cmul eax,ecx,ratioy

         idiv ebp
         mov ecx,eax

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _user3dx - scale 3d point into 2d point on y axis only
; In:
;    EDI - x point
;    ESI - z point
; Out:
;    EDI - x point
;    ESI - z point
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_user3dx:                                   ; bp must always be non-zero
         cmul eax,edi,ratiox

         idiv esi
         mov edi,eax

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _rotate_by_camera - 32 bit _rotate_point point using _ematrix
; In:
;    EBX - x point
;    ECX - y point
;    EBP - z point
;     _ematrix - 32 bit rotation matrix - set up by "_setsincose" routine
; Out:
;    EBX - x point
;    ECX - y point
;    EBP - z point
;
; Notes:
;
; point rotation for eye - solves all x,y,z parameters
; camera rotation is 32 bit and uses _ematrix
;
; remember , matrix offsets are:
;
;  0 1 2     multiply those by 4 for the doubleword address of the matrix
;  3 4 5
;  6 7 8
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4

_rotate_by_camera:
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

         mov eax,_ematrix+20
         imul ebp
         shrd eax,edx,14
         mov esi,eax
         mov eax,_ematrix+16
         imul ecx
         shrd eax,edx,14
         add esi,eax
         mov eax,_ematrix+12
         imul ebx
         shrd eax,edx,14
         add esi,eax                        ; si = new y

         mov eax,_ematrix+32
         imul ebp
         shrd eax,edx,14
         mov ebp,eax
         mov eax,_ematrix+28
         imul ecx
         shrd eax,edx,14
         add ebp,eax
         mov eax,_ematrix+24
         imul ebx
         shrd eax,edx,14
         add ebp,eax                        ; bp = new z

         mov ecx,esi
         mov ebx,edi

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _zsolve - 32 bit rotate point using _ematrix - solve one variable only
; In:
;    EBX - x point
;    ECX - y point
;    EBP - z point
;    _ematrix - 32 bit rotation matrix - set up by "_setsincose" routine
;
; Out:
;    EBX - x point (same as entry)
;    ECX - y point (same as entry)
;    EBP - z point (same as entry)
;    ESI - new z point/location
;
; Notes:
;
; solve z from _ematrix - same as above _rotate_by_camera but only solves z for fast
; test of where object is - result is in esi
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4

_zsolve:
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
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _xsolve - 32 bit rotate point using _ematrix - solve one variable only
; In:
;    EBX - x point
;    ECX - y point
;    EBP - z point
;    _ematrix - 32 bit rotation matrix - set up by "_setsincose" routine
;
; Out:
;    EBX - x point (same as entry)
;    ECX - y point (same as entry)
;    EBP - z point (same as entry)
;    EDI - new x point/location
;
; Notes:
; If object z test from above routine is positive, this routine will solve
; the rest of the rotation matrix.  this is so we don't waste time solving
; for x and y locations if the object is behind the camera anyway.
; Saves imuls.
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4
_xsolve:
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
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _ysolve - 32 bit rotate point using _ematrix - solve one variable only
; In:
;    EBX - x point
;    ECX - y point
;    EBP - z point
;    ESI - new z point
;    EDI - new x point
;    _ematrix - 32 bit rotation matrix - set up by "_setsincose" routine
;
; Out:
;    EBX - x new point from EDI
;    ECX - y new point
;    EBP - z new point from ESI
;
; Notes:
;
; Solve y from _ematrix - same as above _xsolve but solves y for fast
; test of where object is.  Final variables are then cleaned up to
; immitate the _rotate_by_camera function in parts.
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4
_ysolve:
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

         mov ebx,edi                        ; final test, move into appropriate regs
         mov ebp,esi

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
;   _sine - 16 bit theta to 32bit sin(@)
; In:
;     AX - theta  0 - 65536 (0-360)
; Out:
;    EAX - sin (@)   (-4000h to 4000h)
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _cosine - 16 bit theta to 32bit cos(@)
; In:
;     AX - theta  0 - 65536 (0-360)
; Out:
;    EAX - cos (@)   (-4000h to 4000h)
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Notes:
; calculate sin into eax, from ax, smashes bx
; after imul by sin, shr eax,14 to compensate for decimal factor!
;  eg:
;    mov eax,sin(@)
;    mov ebx,32bitnumber
;    imul ebx
;    shrd eax,edx,14
;    eax = ebx*sin(@)
;
;    mov ax,sin(@)
;    mov bx,16bitnumber
;    imul bx
;    shrd ax,dx,14
;    eax = bx*sin(@)
;
; eax is only a sign extended ax and will contain either ffffxxxx or 0000xxxx
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4

_cosine:
         add ax,4000h
_sine:
         shr ax,2
         cmp ax,2000h
         jge s q3o4                         ; quadrant 3 or 4

         cmp ax,1000h
         jl s q0                            ; quad 1

         mov ebx,1fffh
         sub bx,ax
         xor eax,eax
         mov ax,w sinus[ebx*2]
         ret
q0:
         and eax,0ffffh
         mov ebx,eax
         mov ax,w sinus[ebx*2]
         ret
q3o4:
         cmp ax,3000h
         jl s q3
         mov ebx,3fffh
         sub bx,ax
         xor eax,eax
         mov ax,w sinus[ebx*2]
         neg eax
         ret
q3:
         and eax,0fffh
         mov ebx,eax                       ; quad 3
         mov ax,w sinus[ebx*2]
         neg eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Arctan - 32 bit rise/run to 16bit arctan(rise/run)
; In:
;    EAX - Run
;    ECX - Rise
; Out:
;     AX - arctan(ECX/EAX)
;
; Notes:
; smashes cx,ax,dx,si
; arctan(ecx/0) is valid and tested for
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4

_arctan:
         or eax,eax
         jl s qd2or3
         je findmax
         or ecx,ecx
         jge s halftax                      ; quadrant 1
         neg ecx                            ; quadrant 4, ax=-ax
         call halftan
         neg ax
         shl eax,2
         ret
qd2or3:
         neg eax
         or ecx,ecx
         jge s qd2
         neg ecx                            ; quad 3, ax=ax+8192
         call halftan
         add ax,8192
         shl eax,2
         ret
qd2:
         call halftan
         neg ax
         add ax,8192
         shl eax,2
         ret
halftax:
         call halftan
         shl eax,2
         ret

         align 4

halftan:
         xor edx,edx

; cx=rise  positive
; ax=run   positive

         cmp eax,ecx
         jl s opptan                        ; greater than 45 degrees, other side...

         xchg ecx,eax                       ; ax<cx
         shld edx,eax,11                    ; *2048 edx = high dword for divide
         shl eax,11                         ; *2048
         div ecx
         movzx esi,ax
         mov ax,w negtan[esi*2]             ; resulting angle (0-512 is 0-45) in ax
         ret

         align 4

opptan:
         shld edx,eax,11                    ; *2048 edx = high dword for divide
         shl eax,11                         ; *2048

         div ecx
         movzx esi,ax                       ; ax remainder
         mov cx,w negtan[esi*2]
         mov eax,1000h
         sub ax,cx                          ; resulting angle (2048-4096 is 45-90) in ax
         ret

findmax:
         mov eax,16384
         or ecx,ecx
         jge _ret
         neg eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _setsincose - generate rotation matrix for  y,x,z  camera rotation
;
; In:
;    eyeax - camera x angle (0-65536)
;    eyeay - camera y angle (0-65536)
;    eyeaz - camera z angle (0-65536)
; Out:
;    _vmatrix - resulting rotation matrix including camera matrix
;
; Notes:
; called only once every frame.  completed in 12 multiplys
; matrix is also used for objects with no rotation (always angle 0,0,0)
;
; where is my postcard! see readme.doc for info.
;
;              x                    y                    z
;
; x=  cz * cy + sx * sy * sz     -cx * sz     - sy * cz + sx * cy * sz
;
; y=  sz * cy - sx * sy * cz      cx * cz     - sy * sz - sx * cy * cz
;
; z=         cx * sy                 sx                cx * cy
;
;
;  matrix offsets: (doublewords)
;
;     x  y  z
;
; x    0  4  8
; y   12 16 20
; z   24 28 32
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4

_setsincose:
         cli
         mov ax,eyeax
         call _cosine
         mov _ecosx,eax                     ; _ecosx and such are used by object rotation
         mov ax,eyeax                      ; _ematrix is used to find where object is
         call _sine
         mov _esinx,eax
         mov [_ematrix+28],eax
         mov ebp,eax                        ; bp = sx

         if usez eq yes
         mov ax,eyeaz
         call _cosine
         mov _ecosz,eax
         mov edi,eax                        ; di = cz
         mov ax,eyeaz
         call _sine
         mov _esinz,eax
         mov edx,eax                        ; dx = sz
         endif

         if usez eq no
         mov edi,4000h                      ; di = cos 0
         mov _ecosz,4000h
         xor edx,edx                        ; dx = sin 0
         mov _esinz,0
         endif

         mov ax,eyeay
         call _cosine
         mov _ecosy,eax
         mov ax,eyeay
         call _sine
         mov _esiny,eax                      ; ax = sy

         mov ebx,edx                        ; save sz

         mov ecx,eax                        ; save sy

         imul ebx                           ; bx = sy * sz
         shrd eax,edx,14
         mov ebx,eax
         neg ebx
         mov [_ematrix+20],ebx
         neg ebx

         mov eax,ecx                        ; si = - (cz * sy)
         imul edi
         shrd eax,edx,14
         mov esi,eax
         neg esi
         mov [_ematrix+8],esi

         mov eax,_ecosy

         imul edi                           ; di = cy * cz
         shrd eax,edx,14
         mov edi,eax
         mov [_ematrix+0],edi

         mov eax,_esinz
         mov ecx,_ecosy

         imul ecx                           ; cx = sz * cy
         shrd eax,edx,14
         mov ecx,eax
         mov [_ematrix+12],ecx

         mov eax,ebp
         imul esi
         shrd eax,edx,14
         mov esi,eax
         add [_ematrix+12],esi

         mov eax,ebp
         imul edi
         shrd eax,edx,14
         mov edi,eax
         neg edi
         add [_ematrix+20],edi

         mov eax,ebp
         imul ebx
         shrd eax,edx,14
         mov ebx,eax
         add [_ematrix+0],ebx

         mov eax,ebp
         imul ecx
         shrd eax,edx,14
         mov ecx,eax
         add [_ematrix+8],ecx

         mov esi,_ecosx

         mov eax,_ecosy
         imul esi                           ; cx * cy
         shrd eax,edx,14
         mov [_ematrix+32],eax

         mov eax,_esiny
         imul esi                           ; cx * sy
         shrd eax,edx,14
         mov [_ematrix+24],eax

         mov eax,_esinz
         imul esi                           ;-cx * sz
         shrd eax,edx,14
         neg eax
         mov [_ematrix+4],eax

         mov eax,_ecosz
         imul esi                           ; cx * cz
         shrd eax,edx,14
         mov [_ematrix+16],eax

         neg _esinx                         ; reverse angles for object rotation
         neg _esiny

         sti
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; _sqrt: Routine courtesy TRAN
;
; In:
;   EAX - number to take root of
; Out:
;   EAX - root
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
_sqrtbasetbl db 0,1,4,9,16,25,36,49,64,81,100,121,144,169,196,225

         align 4
_sqrt:
         pushad
         mov ebp,eax
         bsr ebx,eax
         jnz short _sqrtf0
         xor ebx,ebx
_sqrtf0:
         shr ebx,3
         lea eax,[ebx*8]
         mov cl,32
         sub cl,al
         rol ebp,cl
         mov eax,ebp
         movzx eax,al
         mov edi,offset _sqrtbasetbl
         mov ecx,10h
_sqrtl0:
         scasb
         je short _sqrtl0d
         jb short _sqrtl0d2
         loop _sqrtl0
         inc edi
_sqrtl0d2:
         dec edi
         inc cl
_sqrtl0d:
         movzx edx,byte ptr [edi-1]
         dec cl
         xor cl,0fh
         mov edi,ecx
         mov ecx,ebx
         jecxz short _sqrtdone
         sub eax,edx
_sqrtml:
         shld eax,ebp,8
         rol ebp,8
         mov ebx,edi
         shl ebx,5
         xor edx,edx
         mov esi,eax
         div ebx
         rol edi,4
         add edi,eax
         add ebx,eax
_sqrtf2:
         imul eax,ebx
         mov edx,eax
         mov eax,esi
         sub eax,edx
         jc short _sqrtf1
         loop _sqrtml
_sqrtdone:
         mov [esp+28],edi
         popad
         ret
_sqrtf1:
         dec ebx
         dec edi
         movzx eax,bl
         and al,1fh
         jmp _sqrtf2

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _calc_angles: Calculate angles between objects esi and edi.
; In:
;    SI - # of object to look at
;    DI - # of object to look from
; Out:
;    AX - x angle
;    BX - y angle
;
; Notes:
;   Angles are from point of view of DI.
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         align 4

temp5    dd 0
temp6    dd 0

         extrn _get_displacement:near

_calc_angles:
         call _get_displacement
         mov di,_vzs[edi*2]

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _calc_middle: Calculate angles to static point
; In:
;    EBX - x location
;    ECX - y location
;    EBP - z location
; Out:
;    AX - x angle
;    BX - y angle
;
; Notes:
;   Booga Boo
;
;   Y = arctan (x/z)
;   X = arctan ((x*sin(Y) + Z cos(Y)))/y)
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_calc_middle:
         push ecx ebx ebp

         mov ecx,ebx                        ; first get z,x plane, (y angle)
         mov eax,ebp

         call _arctan

         mov temp6,eax                      ; save y angle
         call _cosine                       ; set up 32bit sin/cos multipliers
         mov temp5,eax
         mov eax,temp6
         call _sine

         pop ebp ebx                        ; now compute sqr(z^2+x^2) through y rotation

         imul ebx                           ; use angle from calculation above
         shrd eax,edx,14
         mov edi,eax
         mov eax,temp5
         imul ebp
         shrd eax,edx,14
         add eax,edi                        ; di = new z = run

         pop ecx

         call _arctan                       ; get ax=arctan(y/sqr(z^2+x^2))

         mov ebx,temp6                      ; bx = y angle , ax = x angle
         ret

         align 4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Inverse Rotate by Camera
; In:
;  EBX = x
;  ECX = y
;  EBP = z
;  ESI => indexer to angles (object number)
; Out:
;  EBX = x
;  ECX = y
;  EBP = z
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

icosx    dd 0
isinx    dd 0
icosy    dd 0
isiny    dd 0
icosz    dd 0
isinz    dd 0
ix       dd 0
iy       dd 0
iz       dd 0

_inverse_rotate:
         push esi ebx ecx ebp

         mov ax,_vxs[esi*2]
         neg ax
         call _cosine
         mov icosx,eax

         mov ax,_vxs[esi*2]
         neg ax
         call _sine
         mov isinx,eax

         mov ax,_vys[esi*2]
         neg ax
         call _cosine
         mov icosy,eax

         mov ax,_vys[esi*2]
         neg ax
         call _sine
         mov isiny,eax

         mov ax,_vzs[esi*2]
         neg ax
         call _cosine
         mov icosz,eax

         mov ax,_vzs[esi*2]
         neg ax
         call _sine
         mov isinz,eax

         pop ebp ecx ebx

         mov eax,ebx
         imul icosz
         shrd eax,edx,14
         mov esi,eax
         mov eax,ecx
         imul isinz
         shrd eax,edx,14
         sub esi,eax
         mov ix,esi

         mov eax,ebx
         imul isinz
         shrd eax,edx,14
         mov esi,eax
         mov eax,ecx
         imul icosz
         shrd eax,edx,14
         add esi,eax
         mov iy,esi

         mov ebx,ix
         mov ecx,iy

         mov eax,ecx
         imul icosx
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul isinx
         shrd eax,edx,14
         sub esi,eax
         mov iy,esi

         mov eax,ecx
         imul isinx
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul icosx
         shrd eax,edx,14
         add esi,eax
         mov iz,esi

         mov ecx,iy
         mov ebp,iz

         mov eax,ebx
         imul icosy
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul isiny
         shrd eax,edx,14
         sub esi,eax
         mov ix,esi

         mov eax,ebx
         imul isiny
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul icosy
         shrd eax,edx,14
         add esi,eax
         mov iz,esi

         mov ebx,ix
         mov ebp,iz

         pop esi
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Rotate point along X axis
; In:
;  ECX = Y
;  EBP = Z
;   AX = angle to rotate by
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_rotate_x:
         push ebx ecx ebp ax
         call _cosine
         mov icosx,eax

         pop ax
         call _sine
         mov isinx,eax

         pop ebp ecx ebx

         mov eax,ecx
         imul icosx
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul isinx
         shrd eax,edx,14
         sub esi,eax
         mov iy,esi

         mov eax,ecx
         imul isinx
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul icosx
         shrd eax,edx,14
         add esi,eax

         mov ebp,esi
         mov ecx,iy
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Rotate point along Y axis
; In:
;  EBX = X
;  EBP = Z
;   AX = angle to rotate by
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_rotate_y:
         push ebx ecx ebp ax
         call _cosine
         mov icosy,eax

         pop ax
         call _sine
         mov isiny,eax

         pop ebp ecx ebx

         mov eax,ebx
         imul icosy
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul isiny
         shrd eax,edx,14
         sub esi,eax
         mov ix,esi

         mov eax,ebx
         imul isiny
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul icosy
         shrd eax,edx,14
         add esi,eax

         mov ebp,esi
         mov ebx,ix
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Rotate point along Z axis
; In:
;  EBX = X
;  ECX = Y
;   AX = angle to rotate by
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_rotate_z:
         push ebx ecx ebp ax
         call _cosine
         mov icosz,eax

         pop ax
         call _sine
         mov isinz,eax

         pop ebp ecx ebx

         mov eax,ebx
         imul icosz
         shrd eax,edx,14
         mov esi,eax
         mov eax,ecx
         imul isinz
         shrd eax,edx,14
         sub esi,eax
         mov ix,esi

         mov eax,ebx
         imul isinz
         shrd eax,edx,14
         mov esi,eax
         mov eax,ecx
         imul icosz
         shrd eax,edx,14
         add esi,eax

         mov ecx,esi
         mov ebx,ix
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _Point_Z: Calculate Z roll direction to line object up with point
; In:
;  EBX = x point
;  ECX = y point
;  EBP = z point
;   AX = current Y angle of object
;   DI = current X angle of object
; Out:
;   AX = Z angle
; Notes:
;   u = x*cos(Y) - z*sin(Y)
;   v = x*sin(Y) + z*cos(Y)
;   y = y*cos(X) - v*sin(X)
;   Z = arctan (u/y)         = AX
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_point_z:
         push esi edi ebx ax
         call _cosine
         mov icosy,eax
         pop ax
         call _sine
         mov isiny,eax

         pop ebx
         imul ebp
         shrd eax,edx,14
         mov esi,eax
         neg esi
         mov eax,icosy
         imul ebx
         shrd eax,edx,14
         add esi,eax
         mov ix,esi

         mov eax,ebx
         imul isiny
         shrd eax,edx,14
         mov esi,eax
         mov eax,ebp
         imul icosy
         shrd eax,edx,14
         add esi,eax

         mov ax,di
         call _cosine
         mov icosx,eax
         mov ax,di
         call _sine
         mov isinx,eax
         mov eax,ecx
         imul icosx
         shrd eax,edx,14
         mov edi,eax
         mov eax,esi
         imul isinx
         shrd eax,edx,14
         sub edi,eax

         mov eax,edi
         mov ecx,ix
         call _arctan
         pop edi esi
         ret

