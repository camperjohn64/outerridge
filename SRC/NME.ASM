;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : NME.asm
; Included from: Main Assembley module
; Description  : Enemy controller
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
         jumps

code32   segment para public use32
         assume cs:code32, ds:code32

         include pmode.ext                  ; protected mode externals by TRAN
         include 3d.ext
         include xmode.ext
         include function.ext
         include init.ext
         include fade.ext
         include joystick.ext
         include explode.ext
         include game.ext
         include gus.ext
         include fx.ext
         include xmouse.ext
         include kb.ext
         include mod.ext
         include irq.ext
         include control.ext

         include macros.inc
         include equ.inc

         public _shoot_from
         public _add_nme
         public _timerx
         public _who_hurt
         public _obj_num
         public _get_random_shoot_angle
         public _add_mine
         public _nmes
         public _nmetype
         public _nme_irq
         public _reset_nme

         t_none       equ 0
         t_dead       equ 1
         t_shooter    equ 2
         t_cannon     equ 3
         t_mine_sch   equ 4
         t_mine_can   equ 5

xdir     dd 0,0,0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Shoot gun (badguy)
; In:
;  EAX = type
;  EBX = x point
;  ECX = y point
;  EBP = z point
;  ESI = X angle
;  EDI = Y angle
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

gun2use  dd 0
rxstart  dd 0,0,0
gunsped  dd 650,600,500,820
gunlen   db 100,120,130,80   ; length shot travels (time in frames)

_shoot_from:
         mov _eyeax+2,si
         mov _eyeay+2,di
         mov gun2use,eax
         mov rxstart+0,ebx
         mov rxstart+4,ecx
         mov rxstart+8,ebp
         mov edx,eax
         mov ah,gunlen[edx]
         mov al,_gunmap[edx]
         mov esi,500
         mov edi,gun2use
         cmp edi,1
         jne short nofargone
         add esi,200
nofargone:
         call _start_gunshot                ; weapon size (rocket, cannon, snot)
         jc _ret                            ; can't fire rocket

         mov _gs_who[esi],d_nme             ; who shot this shot
         push esi
         cmp _sfxtype,0
         je short nosound

         mov ebx,rxstart+0
         mov ecx,rxstart+4
         mov ebp,rxstart+8
         call _subtract_camera
         call _determine_volume
         jc short nopan          ; volume = 0 if CF = 1
         cmp _sfxtype,1          ; sound blaster doesnt need panning
         jne short nopan
         call _determine_panning
nopan:
         mov ch,1
         cmp gun2use,0
         je short notrnds
         mov ch,8
         cmp gun2use,3
         je short notrnds
         call _rnd
         and eax,3
         mov ch,al
         sub ch,2
notrnds:
         add ch,28
         mov eax,gun2use
         mov al,_gunsound[eax]
         mov dl,nme_chan
         mov cl,0
         call _play_sample
nosound:
         mov eax,gun2use
         mov ebp,gunsped[eax*4]
         mov esi,1
         call _set_speed
         pop esi
         call _set_xyzadds
         shl ebx,2
         shl ecx,2
         shl ebp,2
         add _xs[esi*4],ebx
         add _ys[esi*4],ecx
         add _zs[esi*4],ebp

         cmp gun2use,1
         jne _ret

         call _rnd
         mov ebx,rxstart+0
         mov ecx,rxstart+4
         mov ebp,rxstart+8
         and eax,1
         mov edx,_explo[eax*4]
         mov esi,7
         mov edi,7
         call _start_explosion              ; explosion size (from cannon)
         push esi
         mov ebp,170                        ; explosion speed (from cannon)
         mov esi,1
         call _set_speed
         pop esi
         call _set_xyzadds
         shl ebx,2
         shl ecx,2
         shl ebp,2
         add _xs[esi*4],ebx
         add _ys[esi*4],ecx
         add _zs[esi*4],ebp
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make random NME appear
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_nmes     dd 0
_obj_num  dd maxobjects+1 dup (0)  ; edi
_who_hurt db maxobjects+1 dup (0)  ; esi
_angx     dw maxobjects+1 dup (0)  ; esi
_nmetype  db maxobjects+1 dup (0)  ; esi, 0 = null, 1 = dead, 2 = sch, 3 = can
_nmepat   db maxobjects+1 dup (0)  ; esi
_timerx   db maxobjects+1 dup (1)  ; esi

_add_nme:
         cmp _nme_on,no
         je _ret

          if registered eq yes
         call _rnd
         xor ecx,ecx
         cmp ax,_statsq
         seta cl
         add cl,t_badguy1
          elseif registered eq no
         mov cl,t_badguy1
          endif

         push ecx
         call _rnd
         mov ebx,40000
         mov ecx,ebx
         mov ebp,ebx

         test al,1
         jz short nnta1
         neg ebx
nnta1:
         test al,2
         jz short nnta2
         neg ecx
nnta2:
         test al,4
         jz short nnta4
         neg ebp
nnta4:
         add ebx,_eyex
         add ecx,_eyey
         add ebp,_eyez
         push ebx ecx ebp
         call _rnd
         mov edi,eax
         call _rnd
         mov ebp,_nme_speed
         call _rnd_middle
         mov esi,ebx
         mov edi,ecx
         mov eax,ebp
         pop ebp ecx ebx edx
         call _plop_nme
         jc _ret

         xor edi,edi
         dec edi
search_loop:
         inc edi
         cmp edi,maxobjects
         je _ret
         cmp _obj_num[edi*4],0
         jne short search_loop

         inc _nmes
         mov _obj_num[edi*4],esi
         mov _who_hurt[esi],d_nme
         mov bl,_type[esi]
         add bl,-t_badguy1+2
          if registered eq yes
         call _rnd
         cmp ax,_statsw
         seta cl
         add bl,cl
         add bl,cl
          endif
         mov _nmetype[esi],bl
         and al,15
         mov _timerx[esi],al
         mov _nmepat[esi],1
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Add mine to scene
; In:
;  EDX = mine type, 0 or 1
;  EBX = x point
;  ECX = y point
;  EBP = z point
; Out:
;  ESI = object
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_add_mine:
          if registered eq yes
         xor esi,esi
         xor edi,edi
         xor eax,eax
         add edx,2
         call _plop_nme
         jc _ret
         call _rnd
         and al,63
         mov byte ptr _angx[esi*2],al
          endif
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Add badguy to scene
; In:
;  EDX = type (t_badguy1,2,3,4)
;  EBX = x point
;  ECX = y point
;  EBP = z point
;  ESI = direction vector X
;  EDI = direction vector Y
;  EAX = direction vector Z
; Out:
;  ESI = object
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_plop_nme:
         mov xdir[0],esi
         mov xdir[4],edi
         mov xdir[8],eax
         call _search_next_available_object
         jc _ret
         call _init_object
         call _put_object

         mov _type[esi],dl
         mov ax,mapq[(edx-t_badguy1)*2]
         mov _whatshape[esi*2],ax

         call _set_object_on
         mov ax,toughq[(edx-t_badguy1)*2]
         mov _toughness[esi*2],ax

         mov eax,xdir+0
         mov _xadds[esi*4],eax
         mov eax,xdir+4
         mov _zadds[esi*4],eax
         mov eax,xdir+8
         mov _yadds[esi*4],eax

         xor eax,eax
         mov al,_type[esi]
         mov ax,sizr[(eax-t_badguy1)*2]
         mov _bitobjx[esi*2],ax
         mov _nmepat[esi],1

         call _rnd
         mov _whatreal[esi*2],ax
         mov bl,al
         and eax,2047
         add eax,2800
         cmp eax,3200
         ja short oksiz1
         xor eax,eax
oksiz1:
         test bl,1
         jz short abo1
         neg eax
abo1:
         cmp _type[esi],t_badguy2
         ja short dotimerthingy
         mov _timerq[esi*2],ax
         clc
         ret

dotimerthingy:
         call _rnd
         and ax,63+07800h                   ; timer=0yyq qxxx xxxx xxxx, where qq=offset pulse, yy=pulse type xx = time till death
         add ax,110                         ; length of time mine stays on screen
         mov _timerq[esi*2],ax
         clc
         ret

toughq   dw 12000,20000,50,50
sizr     dw 2000,2000,800,800
rndtmask dw 0,3,0,3
mapq     dw g_camo1,g_camo2,g_camo1,g_camo2

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; get random angle for shoot (may go toward player)
; In:
;  EBX = x location of NME
;  ECX = y location of NME
;  EBP = z location of NME
; Out:
;  SI = angle (may or may not point towards player)
;  DI = angle
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_get_random_shoot_angle_pre_calc:
         mov edx,eax
         call _rnd
         xor esi,esi
         cmp _skill,ax
         ja short hooser
         and eax,127
         or eax,eax
         je short hooser
warp_my_girl:
         cmp _onoff[eax],0
         jne shoot_asteroid
         dec eax
         jnz short warp_my_girl

shoot_asteroid:
         mov esi,eax
hooser:
         ret

_get_random_shoot_angle:
         call _get_random_shoot_angle_pre_calc

kill_him_hahahahohohohehehe:
         push ebx ecx ebp edx
         sub ebx,_eyex[esi*4]
         sub ecx,_eyey[esi*4]
         sub ebp,_eyez[esi*4]
         neg ebx
         neg ecx
         neg ebp
         call _calc_middle
         mov si,ax
         mov di,bx
         call _rnd
         mov ebx,eax
         shr ebx,16
         and ax,01ffh
         sub ax,00ffh
         add si,ax
         and bx,01ffh
         sub bx,00ffh
         add di,bx
         pop eax ebp ecx ebx
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; NME_irq
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_nme_irq:
         mov ecx,_nmes
         jcxz short _maybeadd
         cmp _toughness[0],0
         je _ret

         xor edi,edi
         xor eax,eax
morenmes:
         mov esi,_obj_num[edi*4]
         mov al,_nmetype[esi]
         call _nmelist[eax*4]
         inc edi
         dec ecx
         jnz short morenmes

_maybeadd:
         dec _nme_t1
         jnz _ret

         mov ax,_nme_t2
         mov _nme_t1,ax

         mov al,byte ptr _nmes
         cmp _nme_max,al
         ja _add_nme

         ret

_nmelist dd offset _nme_donothing
         dd offset _nme_remove
         dd offset _nme_shnot
         dd offset _nme_cannon
         dd offset _mine_1
         dd offset _mine_2

_nme_donothing:
         inc ecx
         ret

_nme_remove:
         dec _nmes
         mov _nmetype[esi],0
         mov _obj_num[edi*4],0
         ret

_nme_shnot:
         pushad
         call _nme_speed_calc
         popad
         mov al,5
         mov ah,100
         mov bl,5
         call _find_time
         jc _ret
         push ecx edi
         call _get_location
         mov si,_angx[esi*2]
         call kill_him_hahahahohohohehehe
         xor eax,eax
          if registered eq yes
         cmp _nme_sup,yes
         jne short no_super_schnot
         mov eax,3
          endif
no_super_schnot:
         call _shoot_from
         pop edi ecx
         xor eax,eax
         ret

_nme_cannon:
         pushad
         call _nme_speed_calc
         popad
         cmp _nme_sup,yes
         jne short notbalstem
         call _rnd
         and al,3
         add al,3
         mov bl,al
         mov ax,3407h
         jmp short across
notbalstem:
         mov al,35
         mov ah,35
         mov bl,2
across:
         call _find_time
         jc _ret
         push ecx edi
         call _get_location
         mov si,_angx[esi*2]
         call kill_him_hahahahohohohehehe
         mov eax,1
         call _shoot_from
         pop edi ecx
         xor eax,eax
         ret
_mine_1:
          if registered eq yes
         pushad
         call _nme_speed_calc
         popad
         dec byte ptr _angx[esi*2]
         jne short nomakebeep1
         call _sbeep
         mov byte ptr _angx[esi*2],72
nomakebeep1:
         mov al,45
         mov ah,255
         mov bl,6
         call _find_time
         jc _ret
         push ecx edi
         call _get_location
         mov edx,t_badguy1
         call _add_mine
         pop edi ecx
         xor eax,eax
          endif
         ret
_mine_2:
          if registered eq yes
         pushad
         call _nme_speed_calc
         popad
         dec byte ptr _angx[esi*2]
         jne short nomakebeep2
         call _sbeep
         mov byte ptr _angx[esi*2],72
nomakebeep2:
         mov al,45
         mov ah,255
         mov bl,5
         call _find_time
         jc _ret
         push ecx edi
         call _get_location
         mov edx,t_badguy2
         call _add_mine
         pop edi ecx
         xor eax,eax
          endif
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; time nme shots
; In:
;  AL = regular timer
;  AH = pause timer
;  BL = number of shots between pauses
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_find_time:
         dec _timerx[esi]
         jnz short cnt2
         mov _timerx[esi],al
         dec _nmepat[esi]
         jnz short cnt1
         mov _timerx[esi],ah
         mov _nmepat[esi],bl
         push ecx edi esi
         call _get_location
        ;mov eax,_xadds[esi*4]
        ;shl eax,9
        ;add ebx,eax
        ;mov eax,_yadds[esi*4]
        ;shl eax,9
        ;add ecx,eax
        ;mov eax,_zadds[esi*4]
        ;shl eax,9
        ;add ebp,eax
         cmp _who_hurt[esi],d_player
         jne short not_angry
         xor esi,esi
         jmp short overboard
not_angry:
         call _get_random_shoot_angle_pre_calc
overboard:
         pop eax
         mov _angx[eax*2],si
         pop edi ecx
cnt2:
         xor eax,eax
         stc
         ret
cnt1:
         xor eax,eax
         clc
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Play beep sound for miner
; In: ESI = object
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_sbeep:
          if registered eq yes
         cmp _toughness[0],0
         je _ret
         cmp _sfxtype,0
         je _ret
         push edi ecx esi
         call _get_location
         call _subtract_camera
         call _determine_volume
         jc short nopanq         ; volume = 0 if CF = 1
         cmp _sfxtype,1          ; sound blaster doesnt need panning
         jne short nopanq
         call _determine_panning
nopanq:
         pop ecx
         push ecx
         mov ch,cl
         mov ax,16       ; sample 16 is sbeep
         mov dl,nme_chan ; get channel
         xor cl,cl
         and ch,7
         add ch,23
         call _play_sample

         pop esi ecx edi
          endif
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Reset NME after death/new level
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_reset_nme:
         mov ax,_original_nme_t1
         mov _nme_t1,ax
         mov _nmes,0
         mov ecx,(maxobjects+1)*9
         xor eax,eax
         mov edi,offset _obj_num
         rep stosb
         mov ecx,(maxobjects+1)*1
         mov al,1
         rep stosb

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Remove bad NME's
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         mov ecx,maxobjects+1
nmerrloop:
         dec ecx
         jz _ret
         cmp _onoff[ecx],0
         je short nmerrloop

         cmp _bitobjx[ecx*2],2000
         je short checkdead
         cmp _bitobjx[ecx*2],800
         jne short nmerrloop

checkdead:
         mov _onoff[ecx],0
         mov _bitobjx[ecx*2],0
         jmp nmerrloop

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Set NME speed based on location and direction to player
; In:
;  ESI = object
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

tempspe  dd 0

_nme_speed_calc:
         call _rnd
         test eax,127
         jnz _ret

         mov eax,_nme_speed
         mov tempspe,eax
         push esi esi
         call _rnd
         movsx ebx,al
         movsx ecx,ah
         shl ebx,5
         shl ecx,5
         mov ebp,29000
         xor esi,esi
         call _inverse_rotate
         add ebx,_eyex
         add ecx,_eyey
         add ebp,_eyez
         pop esi
         sub ebx,_xs[esi*4]
         sub ecx,_ys[esi*4]
         sub ebp,_zs[esi*4]
         mov eax,ebx
         posit eax
         mov edi,ecx
         posit edi
         mov esi,ebp
         posit edx
         add eax,edi
         add eax,edx
         cmp eax,10000
         jb short getoutahere
         cmp eax,30000
         ja short nodivit
         shr tempspe,2
nodivit:
         call _calc_middle
         mov _eyeax[2],ax
         mov _eyeay[2],bx
         mov esi,1
         mov ebp,tempspe
         call _set_speed
         pop esi
         mov _xadds[esi*4],ebx
         mov _yadds[esi*4],ecx
         mov _zadds[esi*4],ebp
         ret

getoutahere:
         pop esi
         ret

         ends
         end
