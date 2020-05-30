;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : Control.asm
; Included from: Main Assembley module
; Description  : Generic gaming routines
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

         joyfix equ no

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
         include nme.ext
         include c.ext

         include macros.inc
         include equ.inc
         include lang.ext

         public _shot
         public _guntype
         public _stimer
         public _restart
         public _handle_shot
         public _handle_shot_irq
         public _select_new_gun
         public _nextgun
         public _gungot
         public _config_joystick
         public _config_mouse
         public _config_keyboard
         public _reset_mouse
         public _changing
         public _thrust
         public _handle_always_keys
         public _explo
         public _kbtype
         public _joytype
         public _shot_collision
         public _start_gunshot
         public _select_middle
         public _sspeedtable

         public _shots_left
         public _max_ammo
         public _gun3pow
         public _gunspow
         public _inpause
         public _gunsped
         public _gunlen
         public _gunmap
         public _gunsound
         public _gs_who
         public _dummy_control
         public _dummy_mod
         public _dummy_tim
         public _dummy_lok
         public _reset_dummy
         public _menu_item
         public _gameoversay
         public _in_transit
         public _dummy_timer
         public _start_demo
         public _joy_up
         public _joy_dn
         public _joy_bt
         public _joy_on
         public _joy_lf
         public _joy_rt
         public _joy_es
         public maxmov

_gameoversay dw 0  ; timer
_menu_item  db 2
_guntype    db 0
_gungot     db 1,0,0,0
_shots_left dw 1,0,0,0
_max_ammo   dw 2000,400,100,2000
_nextgun    db 0
_shot       db no
_restart    db no
_changing   db 0
_thrust     db no
_kbtype     dd offset _config_keyboard
_joytype    dd offset _config_joystick
_selected_level_hold db 0
_joy_up     db no
_joy_dn     db no
_joy_bt     db no
_joy_on     db no
_joy_lf     db no
_joy_rt     db no
_joy_es     db no
maxmov      dd 1300

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Control shot through joystick
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_config_joystick:
         call _joy_cartisianjoystick

         if joyfix eq yes
         or ebx,ebx
         jle short noter
         shr ebx,2
noter:
         endif
         cmp bx,-25
         jg short nocheck3
         mov _joy_dn,yes
         mov _joy_on,yes
nocheck3:
         cmp bx,25
         jl short nocheck4
         mov _joy_up,yes
         mov _joy_on,yes
nocheck4:
         cmp ax,-25
         jg short nocheck5
         mov _joy_lf,yes
         mov _joy_on,yes
nocheck5:
         cmp ax,25
         jl short nocheck6
         mov _joy_rt,yes
         mov _joy_on,yes
nocheck6:
         cmp _what_level,0
         jne short boygat
         xor eax,eax
         xor ebx,ebx
boygat:
         neg ebx
         neg eax
         imul eax,_key_scaling
         imul ebx,_key_scaling
         sar eax,6+6
         sar ebx,6+6

         or ax,ax
         jz short noadjustjy
         mov _ship_dy,ax
noadjustjy:
         or bx,bx
         jz short noadjustjx
         mov _ship_dx,bx
noadjustjx:
         mov _ship_dz,0

         call _joy_justgetbutton

         test al,_joy_shotmask
         jnz short _noshotj
         cmp _what_level,0
         je short boygat1
         mov _shot,yes
boygat1:
         mov _joy_bt,yes
         mov _joy_on,yes
_noshotj:
         test al,_joy_thrmask
         jnz short _nothrfj
         cmp _what_level,0
         je short boygat2
         mov _thrust,yes
boygat2:
         mov _joy_es,yes
         mov _joy_on,yes
_nothrfj:
         test al,_joy_chgmask
         jnz short nochghoy
         cmp _what_level,0
         je short nochghoy

         cmp _changing,1
         je short nochghoy

         xor eax,eax
         mov al,_guntype

nxtselecxtion:
         inc al
         cmp al,4
         jne short otp
         xor al,al
otp:
         cmp _gungot[eax],1
         jne short nxtselecxtion

         mov _nextgun,al
         ret

nochghoy:
         test al,_restart_mask_j
         jnz _ret

         mov _restart,yes
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle Fire button shoot
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_stimer   db 1
_sspeedtable db 4,25,60,3    ; gun type timers
_gunsound db 5,3,15,5        ; sound to play for guntype
_gun3pow  db no              ; yes = dual super schnot
_gunspow  db no              ; gun saved pow
_gunsped  dd 1200,1000,850,1600
_gunlen   db 53,80,90,43     ; length shot travels (time in frames)
_gunmap   db g_schnot1,g_cannon,g_rocket,g_schnot2 ; bitmap for selected gun

gunlocat dd  200,400,1300+cockpitsize ; offset ship location for selected gun
         dd -400,400,1300+cockpitsize
         dd    0,300,1300+cockpitsize
         dd  200,400,1300+cockpitsize
gun1xor  db 1               ; cannon xor bit

exstart  dd 0,0,0

_handle_shot:
         dec _stimer
         jnz _ret

         mov _changing,0
         inc _stimer

         cmp _shot,yes
         jne _ret
         mov _shot,no

         movzx eax,_guntype
         cmp _shots_left[eax*2],0
         je scan_for_next_gun

         dec _shots_left[eax*2]
         mov _ammo[eax],yes
         mov _shots_left,1       ; schnot1 is always active!
         lea eax,[eax*2+eax]     ; eax = eax * 3
         mov ebx,[gunlocat+eax*4+0]
         mov ecx,[gunlocat+eax*4+4]
         mov ebp,[gunlocat+eax*4+8]
         cmp _guntype,3
         je short yes3gun
         cmp _guntype,1
         jae not0gun
         call _rnd
         and eax,255
         add ebx,eax
         sub ebx,127
         jmp yes0gun
yes3gun:
         cmp _gun3pow,yes
         jne yes0gun
         cmp _shots_left[3*2],0
         je yes0gun
         dec _shots_left[3*2]
         pushad
         neg ebx
         call _rnd
         and eax,1023
         add ebp,eax
         xor esi,esi
         call _inverse_rotate
         add ebx,_eyex
         add ecx,_eyey
         add ebp,_eyez
         mov exstart+0,ebx
         mov exstart+4,ecx
         mov exstart+8,ebp
         movzx edx,_guntype
         mov ah,_gunlen[edx]
         mov al,_gunmap[edx]
         movzx edi,_guntype
         mov esi,150
         cmp edi,1
         jne short sofargone
         add esi,240
sofargone:
         call _start_gunshot                ; weapon size (rocket, cannon, snot)
         jc popandout
         mov _gs_who[esi],d_player          ; who shot this shot
         push esi
         movzx eax,_guntype
         mov ebp,_gunsped[eax*4]
         xor esi,esi
         call _set_speed
         pop esi
         mov edi,esi
         call _set_xyzadds
         xor esi,esi
         call _get_xyzadds
         mov esi,edi
         call _add_xyzadds
         call _set_xyzadds
         popad
yes0gun:
         call _rnd
         and eax,511
         add ebp,eax
         sub ebp,200
not0gun:
         jne short nott1gun
         xor gun1xor,1
         cmp gun1xor,1
         jne short nott1gun
         neg ebx
nott1gun:
         xor esi,esi
         call _inverse_rotate
         add ebx,_eyex
         add ecx,_eyey
         add ebp,_eyez
         mov exstart+0,ebx
         mov exstart+4,ecx
         mov exstart+8,ebp
         movzx edx,_guntype
         mov ah,_gunlen[edx]
         mov al,_gunmap[edx]
         mov esi,150
         movzx edi,_guntype
         call _start_gunshot                ; weapon size (rocket, cannon, snot)
         jc _ret

         mov _gs_who[esi],d_player
         push esi
         cmp _sfxtype,0
         je short nosound

         mov ch,1
         cmp _guntype,0
         je short notrnds
         mov ch,8
         cmp _guntype,3
         je short notrnds
         call _rnd
         and eax,3
         mov ch,al
         sub ch,2
notrnds:
         add ch,28
         movzx eax,_guntype
         mov al,_gunsound[eax]
         mov dl,fire_chan
         mov bh,8
         mov bl,15
         mov cl,0
         call _play_sample
nosound:
         movzx eax,_guntype
         mov ebp,_gunsped[eax*4]
         xor esi,esi
         call _set_speed
         pop esi
         mov edi,esi
         call _set_xyzadds
         xor esi,esi
         call _get_xyzadds
         mov esi,edi
         call _add_xyzadds
         call _set_xyzadds

         movzx eax,_guntype
         mov al,_sspeedtable[eax]
         mov _stimer,al

         cmp _guntype,1
         jne _ret
         mov ah,gun1xor                     ; handle cannon explosions from ship
         shl ah,3
         add ah,4
         mov _vcpan[fire_chan],ah
         call _rnd
         mov ebx,exstart+0
         mov ecx,exstart+4
         mov ebp,exstart+8
         and eax,1
         mov edx,_explo[eax*4]
         mov esi,2
         mov edi,2
         call _start_explosion              ; explosion size (from cannon)
         push esi
         mov ebp,30                         ; explosion speed (from cannon)
         xor esi,esi
         call _set_speed
         pop esi
         mov edi,esi
         call _set_xyzadds
         xor esi,esi
         call _get_xyzadds
         mov esi,edi
         call _add_xyzadds
         call _set_xyzadds
         ret

scan_for_next_gun:
         mov ecx,3+1
scna:
         dec ecx
         mov _nextgun,cl
         jcxz _ret
         cmp _shots_left[ecx*2],0
         je short scna

         ret
popandout:
         popad
         ret

_explo   dd offset _explode_main0
         dd offset _explode_main1

_explode_main0:
         dw 11,140
         dw 11,160
         dw 11,170
         dw 11,180
         dw 12,190
         dw 12,200
         dw 12,208
         dw 12,215
         dw 0,220
         dw 0,230
         dw 0,230
         dw 0,230
         dw 0,220
         dw 0,210
         dw 1,205
         dw 1,200
         dw 1,197
         dw 1,193
         dw 1,184
         dw 2,178
         dw 2,175
         dw 2,172
         dw 2,169
         dw 3,166
         dw 3,163
         dw 3,161
         dw 3,159
         dw 4,156
         dw 4,154
         dw 4,152
         dw 4,146
         dw 5,142
         dw 5,138
         dw 5,133
         dw 5,130
         dw 6,125
         dw 6,120
         dw 6,115
         dw 6,110
         dw 7,105
         dw 7,100
         dw 7, 95
         dw 7, 90
         dw -1

_explode_main1:
         dw 15,140
         dw 15,150
         dw 15,160
         dw 15,170
         dw 13,180
         dw 13,190
         dw 13,200
         dw 13,210
         dw 18,220
         dw 18,230
         dw 18,230
         dw 18,230
         dw 18,220
         dw 14,210
         dw 14,204
         dw 14,199
         dw 14,193
         dw 14,185
         dw 14,185
         dw 16,178
         dw 16,172
         dw 16,172
         dw 17,166
         dw 17,159
         dw 17,155
         dw 8,152
         dw 8,146
         dw 8,142
         dw 9,138
         dw 9,130
         dw 9,127
         dw 10,125
         dw 10,123
         dw 10,122
         dw 10,120
         dw 6,111
         dw 6,104
         dw 6,101
         dw 6, 98
         dw 7, 93
         dw 7, 90
         dw 7, 85
         dw 7, 80
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Shoot single bullet
; In:
;  EBX = x
;  ECX = y
;  EBP = z
;   AL = bitmap #
;  ESI = x scale
;  EDI = gun 2 use
;   AH = number of frames to hold
; Out:
;  ESI = object
;  EDI = gs_object
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같


_gs_off   db maxobjects+1 dup (0)            ; on/off register
_gs_obj   dw maxobjects+1 dup (0)            ; which object does shot refer to...
_gs_frame db maxobjects+1 dup (0)            ; # of frames left till auto-destruct
_gs_who   db maxobjects+1 dup (0) ; esi      ; who shot object (object number)
_gs_onscr db 0                               ; number of shots on screen

retq:
         pop eax eax eax
         stc
         ret

_start_gunshot:
         push edi eax esi
         call _search_next_available_object
         jc short retq

         call _init_object

         pop eax
         mov _bitobjx[esi*2],ax             ; bitmap scaling (gets added to _bitx and _bity)
         call _put_object
         call _set_object_on

         xor edi,edi
         xor bl,bl
search_loop:
         inc edi
         cmp _gs_off[edi],bl
         jne short search_loop

         inc _gs_onscr
         pop eax

         mov _gs_frame[edi],ah
         xor ah,ah
         mov _whatshape[esi*2],ax
         mov _gs_off[edi],1
         mov eax,esi
         mov _gs_obj[edi*2],ax
         pop eax
         push esi edi
         add al,t_schnot1
         mov _type[esi],al ;***
         mov esi,edi
         call _fix_esimap
         pop edi esi
         clc
         ret

_fix_esimap:
         movzx edi,_gs_obj[esi*2]
         mov dl,_type[edi]
         cmp dl,t_schnot1
         je short doshotr
         cmp dl,t_schnot2
         jne _ret
doshotr:
         call _rnd
         xor ah,ah
         and al,3
         add al,g_schnot1
         cmp dl,t_schnot2
         jb short dothisxb
         add al,-g_schnot1+g_schnot2
dothisxb:
         mov _whatshape[edi*2],ax
         ret

gs_update_esi:
         call _fix_esimap
         dec _gs_frame[esi]
         jnz _ret

gs_remove:
         mov _gs_off[esi],0
         mov _onoff[edi],0
         dec _gs_onscr
         mov _whatshape[edi*2],0
         cmp _type[edi],t_rocket            ; if rocket bitmap, add explosion
         je short add_exprocket
         clc
         ret

add_exprocket:                              ; explode rocket if out of time
         push ecx esi ebx
         mov esi,edi
         call _make_rocket_explode
         pop ebx esi ecx
         clc
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle shot removal
;
; Call this routine once per frame update to animate the shots
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_handle_shot_irq:
         xor bl,bl
         movzx ecx,_gs_onscr
         jcxz _ret
         xor esi,esi
         dec esi
gs_loop:
         inc esi
         cmp _gs_off[esi],bl
         je short gs_loop

         call gs_update_esi
         loop short gs_loop

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Select new gun if _newgun <> _guntype
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_select_new_gun:
         mov al,_nextgun
         cmp _guntype,al
         je _ret

         movzx eax,al
         cmp _gungot[eax],1
         jne _ret

         mov _guntype,al
_select_middle:                             ; select middle sounds change sfx
         mov _stimer,40
         mov _changing,1

         mov ax,10                          ; sound # 10 is change gun
         mov dl,change_chan
         mov bl,15
         mov bh,7
         xor cl,cl
         mov ch,24
         call _play_sample

         mov _apply_new_gun_bitmap,yes
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Control shot through Mouse
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_config_mouse:
         cmp _ismouse,0
         jne _ret

         call _get_mouse_position

         sub dx,100
         sub cx,100

         if joyfix eq yes
         or cx,cx
         jle short noted
         shr cx,1
noted:
         endif

         cmp dx,-25
         jg short nocheck1
         mov _joy_dn,yes
         mov _joy_on,yes
nocheck1:
         cmp dx,25
         jl short nocheck2
         mov _joy_up,yes
         mov _joy_on,yes
nocheck2:
         cmp cx,-25
         jg short nocheck7
         mov _joy_lf,yes
         mov _joy_on,yes
nocheck7:
         cmp cx,25
         jl short nocheck8
         mov _joy_rt,yes
         mov _joy_on,yes
nocheck8:

         movsx ecx,cx
         movsx ebp,dx
         neg ebp
         neg ecx

         mov eax,_key_scaling
         imul ebp
         mov ebp,eax
         mov eax,_key_scaling
         imul ecx
         mov edx,ebp
         mov ecx,eax
         shr edx,3
         shr ecx,3

         cmp _what_level,0
         jne short noadjustmq
         xor cx,cx
         xor dx,dx
noadjustmq:

         or cx,cx
         jz short noadjustmy
         mov _ship_dy,cx
noadjustmy:
         or dx,dx
         jz short noadjustmx
         mov _ship_dx,dx
noadjustmx:
         mov _ship_dz,0

         cmp _what_level,0
         je short nochgmouse
         test bl,_mouse_chgmask
         jz short nochgmouse

         cmp _changing,1
         je short nochgmouse

         xor eax,eax
         mov al,_guntype

nextselecxtion:
         inc al
         cmp al,4
         jne short oktp
         xor al,al
oktp:
         cmp _gungot[eax],1
         jne short nextselecxtion

         mov _nextgun,al

nochgmouse:
         push bx                            ; save buttons

         mov al,33h
         mov v86r_ax,4                      ; re-position mouse at 0,0
         mov v86r_cx,100
         mov v86r_dx,100
         int 33h

         pop bx

         test bl,_mouse_thrmask
         jz short nothrm
         cmp _what_level,0
         je short nochgmouse1
         mov _thrust,yes
nochgmouse1:
         mov _joy_es,yes
         mov _joy_on,yes
nothrm:
         test bl,_mouse_shotmask
         jz short _nothrfm
         cmp _what_level,0
         je short nochgmouse2
         mov _shot,yes
nochgmouse2:
         mov _joy_bt,yes
         mov _joy_on,yes
_nothrfm:
         xor bl,_restart_mask_m
         test bl,_restart_mask_m
         jnz _ret
         mov _restart,yes

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Controls from keyboard
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_config_keyboard:
         mov _shot,no
         mov ebx,_key_scaling
         mov eax,160
         imul eax,ebx
         shr eax,6
         mov bx,ax
         mov cx,bx
         neg bx
         xor eax,eax

         mov al,_kb_r
         cmp _kbtbl0+eax,1
         jne short kb_l1
         mov _ship_dy,bx
kb_l1:
         mov al,_kb_l
         cmp _kbtbl0+eax,1
         jne short kb_l2
         mov _ship_dy,cx
kb_l2:
         mov al,_kb_up
         cmp _kbtbl0+eax,1
         jne short kb_l3
         mov _ship_dx,cx
kb_l3:
         mov al,_kb_down
         cmp _kbtbl0+eax,1
         jne short kb_l4
         mov _ship_dx,bx
kb_l4:
         mov al,_kb_fire
         cmp _kbtbl0+eax,1
         jne short kb_l5
         mov _shot,yes
kb_l5:
         mov al,_kb_thr
         cmp _kbtbl0+eax,1
         jne short kb_l6
         mov _thrust,yes
kb_l6:
         mov al,_restart_mask_k
         cmp _kbtbl0+eax,1
         jne short kb_lr
         mov _restart,yes
kb_lr:
         mov al,_kb_chg                     ; change guns by "enter"
         cmp _kbtbl0+eax,1
         jne short kb_l7
         cmp _changing,1
         je short kb_l7

         xor eax,eax
         mov al,_guntype

nextselection:
         inc al
         cmp al,4
         jne short oktpq
         xor al,al
oktpq:
         cmp _gungot[eax],1
         jne nextselection

         mov _nextgun,al
kb_l7:
         cmp _kbtbl0+2,1                    ; change guns by "123"
         jne short kb_l8
         cmp _gungot[0],1
         jne short kb_l8
         mov _nextgun,0
kb_l8:
         cmp _kbtbl0+3,1
         jne short kb_l9
         cmp _gungot[1],1
         jne short kb_l9
         mov _nextgun,1
kb_l9:
         cmp _kbtbl0+4,1
         jne short kb_la
         cmp _gungot[2],1
         jne short kb_la
         mov _nextgun,2
kb_la:
         cmp _kbtbl0+5,1                    ; super schnot2 flip flop selection
         jne short kb_lb
         cmp _gungot[3],1
         jne short kb_lb
         cmp _guntype,3
         jne short already
         cmp _gunspow,yes
         je short kb_lc
         cmp _gun3pow,yes
         jne short kb_lb
kb_lc:
         cmp _stimer,1
         jne short kb_lb
         mov al,_gun3pow
         xchg al,_gunspow
         mov _gun3pow,al
         call _select_middle
already:
         mov _nextgun,3
kb_lb:

         cmp _hyper,yes                     ; handle hyperspace run and finish
         jne short nomidlev
         mov _thrust,yes
         dec _hyptimer
         jnz short nomidlev

         mov _hyper,no                      ; hyperspace run finished...
         mov _spedd,spedd
         mov _speds,speds
         mov eax,maxmov
         mov _maxmov,eax
         mov _destroy,yes
         call _next_level_please
         call _retrig_thrust
    if registered eq no
         cmp _what_level,10
         jne nomidlev
         mov _mode,_force_order
    endif
nomidlev:
        ;jmp [_joytype]
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Reset mouse to center position
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_reset_mouse:
         cmp _ismouse,0
         jne _ret

         mov al,33h
         mov v86r_ax,4                      ; re-position mouse at 0,0
         mov v86r_cx,100
         mov v86r_dx,100
         int 33h
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle keys that are functional at all times
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

menu_fast equ 25
menu_slow equ 12

_inpause db no
_controller_menu_timer db 1

_handle_always_keys:
         cmp _menu_item,7
         jne short nohg
         call _flashhigh
nohg:
         dec _controller_menu_timer
         jnz nocontrolleroverride
         mov _controller_menu_timer,1

         xor eax,eax
         cmp _joy_on,yes
         jne nocontrolleroverride

         cmp _what_level,0
         jne short nodemostuff

         cmp _joy_bt,yes
         je short n8

nodemostuff:
         cmp _menu_item,2
         jbe short nocontrolleroverride

         cmp _joy_up,yes
         jne short n1
         mov ax,1ah
         mov _controller_menu_timer,menu_slow
n1:
         cmp _joy_dn,yes
         jne short n4
         mov ax,19h
         mov _controller_menu_timer,menu_slow
n4:
         cmp _joy_lf,yes
         jne short n6
         mov _controller_menu_timer,menu_slow
         mov ax,17h
n6:
         cmp _joy_rt,yes
         jne short n7
         mov _controller_menu_timer,menu_slow
         mov ax,18h
n7:
         cmp _joy_es,yes
         jne short n9
         mov _controller_menu_timer,menu_fast
         mov ax,14
n9:
         cmp _joy_bt,yes
         jne short n5
n8:
         mov _controller_menu_timer,menu_fast
         mov ax,13
n5:
         or eax,eax
         jnz short newchar

nocontrolleroverride:
         cmp _kbhit,0
         je _ret

         mov _kbhit,0
         mov ax,word ptr _kbchar
newchar:
         movzx ebx,_menu_item
         call _menu_calls[ebx*4]

         or eax,eax
         je _ret

         cmp ax,1                           ; english/german language
         jne short gotothehills
         mov _update_bot,1
         xor _language,1
         call _reset_language
         mov _top_text,offset _messagel
         jmp _outmenu

gotothehills:
         cmp ax,"q"+400h
         jne s noalarmout
yesalarmout:
         mov _mode,_exitnow
         ret
noalarmout:
         cmp ax,"e"+400h
         je s yesalarmout

         cmp ax,4                           ; controller scaling adjust up
         jne short noupscale1
         inc _key_scaling
         jmp short newscaleshow
noupscale1:
         cmp ax,3                           ; controller scaling adjust down
         jne short noupscale2
         dec _key_scaling
newscaleshow:
         mov eax,_key_scaling
         mov cl," "
         or eax,eax
         jge short noitsneg
         mov cl,"-"
         neg eax
noitsneg:
         mov edx,_language
         mov edx,_scaletext[edx*4]
         dec edx
         mov [edx],cl
         call _cv32
         mov cl,al
         and ax,0f0fh
         and cl,00f0h
         shr cl,4
         add ax,"00"
         add cl,"0"
         mov edx,_language
         mov edx,_scaletext[edx*4]
         mov [edx+2],al
         mov [edx+1],cl
         mov [edx+0],ah
         mov _top_text,offset _messagee
         jmp _outmenu
noupscale2:

         cmp ax,7
         jne short noinverse

         xor _inverse_keys,yes+no
         mov _top_text,offset _messageca
         cmp _inverse_keys,yes
         je _outmenu
         mov _top_text,offset _messagecb
         jmp _outmenu
noinverse:
         cmp ax,41bh                        ; pause button
         jne nopause

         cmp _mode,_dointroloop
         je _outmenu

         call _reset_mouse
         xor _inpause,yes+no
         cmp _inpause,yes
         jne short handlebackon

         xor eax,eax
         mov dword ptr _mix_volume[0],eax ; clear 4 mod channels
         mov _mix_volume[thrust_chan],al  ; clear thrust channel
         or dword ptr _vccmnd[0],01010101h
         or _vccmnd[thrust_chan],vol
         jmp _outmenu

handlebackon:
         mov al,_mod_vol
         mov ah,al
         mov bx,ax
         shl eax,16
         mov ax,bx
         mov dword ptr _mix_volume[0],eax
         mov al,_sfx_vol
         mov _mix_volume[thrust_chan],al
         or dword ptr _vccmnd[0],01010101h
         or _vccmnd[thrust_chan],vol
         call _outmenu
         jmp _retrig_thrust
nopause:
         cmp ax,6                           ; f6, cockpit graphics control
         jne short notcockpitadjust
         mov al,_cockpit_control
         and eax,3
         mov al,nextconfig[eax]
         and _cockpit_control,255-3
         or  _cockpit_control,al
         jmp _outmenu

notcockpitadjust:
         cmp ax,11
         jne short nomod1

         cmp _mod_vol,0
         je _outmenu

         dec _mod_vol                       ; f11, mod volume down
         mov _top_text,offset _message1
         jmp short modmod
nomod1:
         cmp ax,12
         jne short nomod2

         cmp _mod_vol,15
         je _outmenu

         inc _mod_vol                       ; f12, mod volume up
         mov _top_text,offset _message1
modmod:
         mov al,_mod_vol
         mov _mix_volume[0],al
         mov _mix_volume[1],al
         mov _mix_volume[2],al
         mov _mix_volume[3],al
         or _vccmnd[0],vol
         or _vccmnd[1],vol
         or _vccmnd[2],vol
         or _vccmnd[3],vol
         mov bl,_mod_vol
         mov edx,offset _modvol
         call _volume_bars
         jmp _outmenu
nomod2:
         cmp ax,9
         jne short nosfx1

         cmp _sfx_vol,0
         je _outmenu                        ; f9  sfx vol down

         dec _sfx_vol
         mov _top_text,offset _message2
         jmp short modsfx
nosfx1:
         cmp ax,10
         jne nosfx2

         cmp _sfx_vol,15
         je _outmenu                        ; f10 sfx vol up

         inc _sfx_vol
         mov _top_text,offset _message2
modsfx:
         mov al,_sfx_vol
         mov _mix_volume[4],al
         mov _mix_volume[5],al
         mov _mix_volume[6],al
         mov _mix_volume[7],al
         mov _mix_volume[8],al
         mov _mix_volume[9],al
         mov _mix_volume[10],al
         mov _mix_volume[11],al
         or _vccmnd[4],vol
         or _vccmnd[5],vol
         or _vccmnd[6],vol
         or _vccmnd[7],vol
         or _vccmnd[8],vol
         or _vccmnd[9],vol
         or _vccmnd[10],vol
         or _vccmnd[11],vol

         mov bl,_sfx_vol
         mov edx,offset _sfxvol
         call _volume_bars
         call _outmenu
         cmp _sfx_vol,1
         je _retrig_thrust
         ret
nosfx2:
         cmp ax,"m"
         jne nomouseactivate

         mov _ctrl,2
         mov _joytype,offset _config_mouse

         call _reset_mouse
         mov _top_text,offset _message8
         jmp _outmenu

nomouseactivate:
         cmp ax,"j"
         jne nojoyactivate

         mov _ctrl,1
         mov _joytype,offset _config_joystick

         mov _top_text,offset _message9
         call _joy_calibratejoystick
         jmp _outmenu

nojoyactivate:
         cmp ax,8
         jne noflipthrust

         xor _tmethod,1
         mov _top_text,offset _message3a
         cmp _tmethod,1
         je _outmenu
         mov _top_text,offset _message3b
         jmp _outmenu

noflipthrust:

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Cheat keys follow
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         cmp ax,"Y"+300h
         je _save_levels

         cmp ax,"D"+300h
         jne noondebuels
         mov _debugit,yes
         jmp _outmenu

noondebuels:
         cmp ax,2                           ; F2 = pcx dump
         je short save_picture
         cmp ax,300h+"P"
         jne short no_picture
save_picture:
         mov _save_picture,1
         jmp _outmenu

no_picture:
         cmp _debugit,yes
         jne _ret

         cmp ax,300h+"F"
         jne short no_fas

         mov _top_text,offset _messagef
 if registered eq yes
         call _bonus9
 endif
         jmp _outmenu

no_fas:
 if registered eq yes
         cmp ax,300h+"K"
         jne short no_kil

         mov _lasthealth,yes
         sub _toughness[0],70
         cmp _toughness[0],0
         jge short nogag
         mov _toughness[0],0
         ret
nogag:
         mov al,15
         call _make_red
         call _hurt_effect
         jmp _outmenu
no_kil:
         cmp ax,300h+"L"
         jne short no_lev

         inc _highest_level
         jmp _outmenu
no_lev:
 endif
         cmp ax,300h+"G"
         jne short no_gid

         mov _top_text,offset _message6b
 if registered eq yes
         xor _godmode,yes+no
         cmp _godmode,yes
         jne _outmenu
         mov _top_text,offset _message6a
         mov ax,_player_toughness
         mov _toughness[0],ax
         mov _lasthealth,yes
         mov _player_score,0
         mov _update_score,yes
 endif
         jmp _outmenu
no_gid:
         cmp ax,300h+"N"
         jne short no_nmes
         mov _nme_on,no
         mov _top_text,offset _messageg
         jmp _outmenu
no_nmes:
         cmp ax,300h+"M"
         jne short nonewmod

 if registered eq yes
         mov _activate_controls,no
         call _mod_stop
         mov al,_currentmod
         inc al
         cmp al,_maxmods
         jnae short lm_rnd
         xor al,al
lm_rnd:
         mov _currentmod,al

         call _load_mod
         call _play_mod
         mov _activate_controls,yes
 endif
         mov _top_text,offset _message5
         jmp _outmenu
nonewmod:
         cmp ax,300h+"B"
         jne short nobisblow

         mov _top_text,offset _messageaa
 if registered eq yes
         xor _blow_up_bonuses,yes+no
         cmp _blow_up_bonuses,yes
         je _outmenu
         mov _top_text,offset _messageab
 endif
         jmp _outmenu
nobisblow:
         cmp ax,300h+"C"
         jne short nocitblow

 if registered eq yes
         mov _bonus_stat,d_nme
         mov _player_score,0
         mov _update_score,yes
 endif
         mov _top_text,offset _message4
         jmp _outmenu
nocitblow:
         cmp ax,300h+"S"
         jne short nostop

 if registered eq yes
         mov ecx,maxobjects
         mov edi,offset _xadds
         xor eax,eax
         rep stosd
         mov ecx,maxobjects
         mov edi,offset _yadds
         xor eax,eax
         rep stosd
         mov ecx,maxobjects
         mov edi,offset _zadds
         xor eax,eax
         rep stosd
 endif
         mov _top_text,offset _message7
         jmp _outmenu
nostop:
         cmp ax,300h+"A"
         jne short noammo

 if registered eq yes
         mov d _gungot[0],01010101h
         mov edi,offset _shots_left
         mov esi,offset _max_ammo
         mov ecx,4
         rep movsw
         mov _ammo[1],yes
         mov _ammo[2],yes
         mov _ammo[3],yes
         mov _player_score,0
         mov _update_score,yes
 endif
         mov _top_text,offset _messageb
         jmp _outmenu
noammo:
         cmp ax,300h+"E"
         jne short noschonot

 if registered eq yes
         mov _gungot[3],1
         mov ax,_max_ammo[3*2]
         mov _shots_left[3*2],ax
         mov _gun3pow,yes
         mov _nextgun,3
         mov _guntype,3
         call _select_middle
         mov _player_score,0
         mov _update_score,yes
 endif
         mov _top_text,offset _messaged
         jmp _outmenu
noschonot:
 if registered eq yes
         cmp ax,300h+"W"
         jne short nodummynow

         xor _kbtype,offset _dummy_control
         xor _kbtype,offset _config_keyboard
         call _reset_dummy
 endif
nodummynow:

; more keyboard controls here...

         ret

nextconfig db 01b,11b,00b,10b

_menu_calls dd o _checkescp ; 0
            dd o _checkesc  ; 1
            dd o _checkesc  ; 2
            dd o _domain    ; 3
            dd o _dooptions ; 4
            dd o _dowarp    ; 5
            dd o _dohigh    ; 6
            dd o _donewhigh ; 7
            dd o _level_ed  ; 8
            dd o _dohow     ; 9
            dd o _asklevel  ; 10
            dd o _asklevel  ; 11

_level_ed:
         cmp al,"z"
         jne short nozdec
         dec _what_level
         jmp gfs3
nozdec:
         cmp al,"x"
         jne short noxinc
         inc _what_level
         jmp gfs3
noxinc:
         cmp al,13h
         jne short nohome
         call _getloc
         call _zerotype[eax*4]
         jmp gfs3
nohome:
         cmp al,14h
         jne short noendinsight
         call _getloc
         mov ecx,1000
againplease3:
         call _dectype[eax*4]
         loop againplease3
         jmp gfs3

noendinsight:
         cmp al,"+"
         jne short ooga1
         inc _what_level
         jmp gfs3
ooga1:
         cmp al,"-"
         jne short ooga2
         dec _what_level
         jmp gfs3
ooga2:
         cmp al,14
         jne short noescedit

         call shotn
         mov eax,"Y"+300h
         ret

noescedit:
         cmp al,1ah
         jne short noupc2
         mov al,_edit_index
         inc al
         jmp short edt_main
noupc2:
         cmp al,19h
         jne short nodnc2
         mov al,_edit_index
         dec al
edt_main:
         cmp al,22
         jne short gfs4
         xor al,al
gfs4:
         cmp al,-1
         jne short gfs5
         mov al,21
gfs5:
         mov _edit_index,al
         jmp gfs3

nodnc2:
         cmp al,17h
         jne short notlefte
         call _getloc
         call _dectype[eax*4]
         jmp gfs3
notlefte:
         cmp al,18h
         jne short notrifht

         call _getloc
         call _inctype[eax*4]
         jmp gfs3
notrifht:
         cmp al,16h
         jne short notlefty
         call _getloc
         mov ecx,100
againplease2:
         call _dectype[eax*4]
         loop againplease2
         jmp gfs3
notlefty:
         cmp al,15h
         jne _ret

         call _getloc
         mov ecx,100
againplease1:
         call _inctype[eax*4]
         loop againplease1
         jmp gfs3

_getloc:
         movzx ebx,_what_level
         imul ebx,48
         movzx eax,_edit_index
         or eax,eax
         je short adjustlevel
         dec eax
         movzx ecx,_editoff[eax]
         mov al,_edittype[eax]
         lea edi,[_level_tables+ebx+ecx]
         ret

adjustlevel:
         mov edi,offset _what_level
         mov eax,0
         ret

_zerotype dd offset _zerbyte
          dd offset _zerword
          dd offset _zerdword

_zerbyte:
         mov byte ptr [edi],0
         ret
_zerword:
         mov word ptr [edi],0
         ret
_zerdword:
         mov dword ptr [edi],0
         ret

_dectype dd offset _decbyte
         dd offset _decword
         dd offset _decdword

_decbyte:
         dec byte ptr [edi]
         ret
_decword:
         dec word ptr [edi]
         ret
_decdword:
         dec dword ptr [edi]
         ret

_inctype dd offset _incbyte
         dd offset _incword
         dd offset _incdword

_incbyte:
         inc byte ptr [edi]
         ret
_incword:
         inc word ptr [edi]
         ret
_incdword:
         inc dword ptr [edi]
         ret

_editoff db  0
         db  1
         db  2
         db  4
         db  6
         db  8
         db  9
         db 10
         db 11
         db 13
         db 15
         db 17
         db 21
         db 22
         db 24
         db 26
         db 27
         db 28
         db 32
         db 34
         db 38

_edittype db 0
          db 0
          db 0
          db 1
          db 1
          db 0
          db 0
          db 0
          db 1
          db 1
          db 1
          db 2
          db 0
          db 1
          db 1
          db 0
          db 0
          db 2
          db 1
          db 2
          db 0

_batwidth   db 10000000b
            db 11000000b
            db 11100000b
            db 11110000b
            db 11111000b
            db 11111100b
            db 11111110b

_flashhigh:
         inc _chrtime
         test _chrtime,0fh
         jnz short notchange
         test _chrtime,10h
         jz short _blockit
         mov edi,_hscore
         add edi,offset _names
         add edi,_cursorx
         movzx ecx,byte ptr [edi]
         mov byte ptr [edi],3
         mov _under,cl
         movzx edx,_charlentbl[ecx]
         mov _charlentbl[3],dl
         mov dh,_batwidth[edx-2]
         mov edi,offset _spaceagefnt+8+8+8
         lea esi,[_spaceagefnt+ecx*8]
         mov dl,8
moverefd:
         movsb
         xor [edi-1],dh
         dec dl
         jnz short moverefd
         jmp short notchange
_blockit:
         mov edi,_hscore
         add edi,offset _names
         add edi,_cursorx
         mov bl,_under
         mov [edi],bl
notchange:
         ret

_donewhigh:
         push eax
         call _blockit
         mov _chrtime,0fh
  if registered eq no
         call _outmenu
  elseif registered eq yes
         mov ax,13
         call _ipmenu
  endif
         pop eax

         cmp al,14
         jne short noecpout1
noecpout2:
         mov _menu_item,1
         mov _mode,_dointro
         mov _what_level,0
         ret

noecpout1:
         cmp al,13
         je short noecpout2

         cmp al,17h
         jne short noecpout3
_017:
         cmp _cursorx,0
         je short outx
         dec _cursorx
outx:
         xor eax,eax
         ret

noecpout3:
         cmp al," "
         je short yes1
         cmp al,"'"
         je short yes1
         cmp al,":"
         ja short non3
         cmp al,","
         jae short yes1
         cmp al,"!"
         je short yes1
         cmp al,'"'
         je short yes1
non3:
         cmp al,"A"
         jb short non1
         cmp al,"Z"
         jbe short yes1
non1:
         cmp al,"a"
         jb short non2
         cmp al,"z"
         ja short non2
yes1:
         mov edi,_hscore
         add edi,offset _names
         add edi,_cursorx
         mov [edi],al
         mov al,18h
non2:
         cmp al,18h
         jne short noecpout4
         mov eax,_cursorx
         cmp al,22
         jge short outx
         inc _cursorx
         jmp short outx

noecpout4:
         cmp al,12h
         jne short noecpout5
_012:
         mov ecx,24
         mov ebx,_cursorx
         sub ecx,ebx
         jcxz short notedl
         mov edi,_hscore
         add edi,offset _names
agiandel:
         mov al,[edi+1+ebx]
         mov [edi+ebx],al
         inc ebx
         dec ecx
         jnz short agiandel
notedl:
         mov b [edi+24]," "
         jmp outx

noecpout5:
         cmp al,13h
         jne short noecpout6
         mov _cursorx,0
         jmp outx

noecpout6:
         cmp al,14h
         jne short noecpout7
         mov eax,22
         mov _cursorx,eax
         jmp outx

noecpout7:
         cmp al,10h
         jne short noecpout8

         call _017
         call _012
         jmp outx
noecpout8:
         ret

_saved_pause_status db yes

_checkescp:
         cmp ax,14
         jne _ret

         mov _saved_pause_status,yes
         cmp _what_level,0
         je short shotn
         mov al,_inpause
         cmp al,yes
         je short shotn
         call shotn
         mov _saved_pause_status,no
         mov eax,41bh
         ret

blab     db 0

_dohow:
         cmp ax,14
         je short dookhow
         cmp ax,13
         jne _ret
dookhow:
         mov _update_bot,1
         xor _language,1
         call _reset_language
         xor blab,1
         cmp blab,0
         jne short _outmenu
         je short shotn

_checkesc:
         cmp _what_level,0
         jne short _dohigh
         cmp ax,13
         je short shotn
_dohigh:
         cmp ax,14
         jne _ret
shotn:
         mov _menu_item,3
_outmenu:
         mov ax,12
_ipmenu:
         mov dl,death_chan
         mov bl,15
         mov bh,7
         xor cl,cl
         mov ch,24
         call _play_sample
         xor eax,eax
         ret

_dooptions:
         cmp al,"c"
         jne short at01
         cmp _options_index,0
         jne short oiga
         mov _options_index,1
         jmp gfs3
oiga:
         mov _options_index,0
         jmp gfs3
at01:
         cmp al,"m"
         jne short at02
         mov _options_index,2
         jmp gfs3
at02:
         cmp al,"e"
         jne short at03
         mov _options_index,3
         jmp gfs3
at03:
         cmp al,"d"
         je short isgermand
         cmp al,"r"
         jne short at04
isgermand:
         mov _options_index,4
         jmp gfs3
at04:
         cmp al,"s"
         je short isgermans
         cmp al,"t"
         jne short at05
isgermans:
         mov _options_index,5
         jmp gfs3
at05:
         cmp al,14
         je shotn

         cmp al,19h
         jne short sdaup
         mov al,_options_index
         dec al
         jmp modoptions
sdaup:
         cmp al,1ah
         jne short sdadn
         mov al,_options_index
         inc al
modoptions:
         cmp al,-1
         jne short ksf
         mov al,5
ksf:
         cmp al,6
         jne short ksf2
         xor al,al
ksf2:
         mov _options_index,al
         jmp gfs3
sdadn:
         cmp ax,13
         je short noret13chr1
         cmp al,17h
         jne short noret13chr2
         movzx eax,_options_index
         call [_opn18+eax*4]
         jmp _outmenu
noret13chr2:
         cmp al,18h
         jne short noret13chr3
noret13chr1:
         movzx eax,_options_index
         call [_opn17+eax*4]
         jmp _outmenu
noret13chr3:
         cmp ax,3
         je short asdq
         cmp ax,4
         je short asdq
         cmp ax,"j"
         je short asdq
         cmp ax,"m"
         jne short noksel
asdq:
         push ax
         call _outmenu
         pop ax
         ret
noksel:
         cmp ax,7
         jb short noksel3
         cmp ax,12
         jbe short asdq
noksel3:
         ret

_opn17   dd o flipcontrol1
         dd o incsped
         dd o incmod
         dd o incsfx
         dd o fliptyp
         dd o flipthr

_opn18   dd o flipcontrol2
         dd o decsped
         dd o decmod
         dd o decsfx
         dd o fliptyp
         dd o flipthr

flipcontrol1:
         inc _ctrl
         cmp _ctrl,3
         jne short joad2
         mov _ctrl,0
         jmp short joad2
flipcontrol2:
         dec _ctrl
         cmp _ctrl,-1
         jne short joad2
         mov _ctrl,2
joad2:
         movzx eax,_ctrl
         mov eax,_cotr[eax*4]
         mov _joytype,eax

         call _joy_calibratejoystick
         jmp _reset_mouse
incmod:
         cmp _mod_vol,15
         je _ret
         inc _mod_vol
         jmp modmod
incsfx:
         cmp _sfx_vol,15
         je _ret
         inc _sfx_vol
         jmp modsfx
decmod:
         cmp _mod_vol,0
         je _ret
         dec _mod_vol
         jmp modmod
decsfx:
         cmp _sfx_vol,0
         je _ret
         dec _sfx_vol
         jmp modsfx
fliptyp:
         xor _inverse_keys,yes+no
         ret
flipthr:
         xor _tmethod,1
         ret
decsped:
         dec _key_scaling
         ret
incsped:
         inc _key_scaling
         ret

_dowarp:
         cmp al,14
         jne _selwarp

         mov _menu_item,3
         jmp _outmenu
_selwarp:
         cmp al,1ah
         je short nwlft2
         cmp al,17h
         jne short nwlft
nwlft2:
         cmp _warp_level,1
         jbe gfs3
         dec _warp_level
         jmp gfs3
nwlft:
         cmp al,19h
         je _najksd2
         cmp al,18h
         jne _najksd
_najksd2:
         mov al,_highest_level
         dec al
         cmp _warp_level,al
         jae gfs3
         inc _warp_level
         jmp gfs3
_najksd:
         cmp al,13
         jne _ret
         mov al,_warp_level
         mov _selected_level_hold,al
         mov _menu_item,11
         jmp _outmenu

_asklevel:
         cmp ax,"e"
         jne short noteasy1
         mov _diff_index,0
         jmp gfs3
noteasy1:
         cmp ax,"n"
         jne short noteasy2
         mov _diff_index,1
         jmp gfs3
noteasy2:
         cmp ax,"s"
         jne short noteasy3
         mov _diff_index,2
         jmp gfs3
noteasy3:
         cmp ax,"l"
         jne short noteasy4
         mov _diff_index,0
         jmp gfs3
noteasy4:
         cmp ax,"a"
         jne short noteasy5
         mov _diff_index,2
         jmp gfs3
noteasy5:
         cmp ax,14
         je outmain

         cmp al,1ah
         jne short noupcq
         mov al,_diff_index
         inc al
         jmp short lev_main
noupcq:
         cmp al,19h
         jne short nodncq
         mov al,_diff_index
         dec al
lev_main:
         cmp al,3
         jne short gfsq
         xor al,al
gfsq:
         cmp al,-1
         jne short gfs6
         mov al,2
gfs6:
         mov _diff_index,al
         jmp gfs3
nodncq:
         cmp ax,13
        ;je iuwqr1
        ;cmp al,18h
         jne _ret
iuwqr1:
         mov al,_selected_level_hold
         mov _selected_level,al
         call _outmenu
         movzx eax,_diff_index
         mov _difficulty,al
 if registered eq no
         cmp al,2
         jne short not_schnotter_mode
         mov _menu_item,9
         ret
not_schnotter_mode:
 endif
         call _set_diffculty_based_on_eax
         jmp _start_new_game_cause_robert_wants_to_play_doom

_domain:
  if debug eq yes
         cmp ax,"U"+300h
         jne short thisisbunk1
         mov _menu_item,8
         jmp _outmenu

thisisbunk1:
         cmp ax,"Y"+300h
         jne short thisisbunk2


thisisbunk2:
  endif
         cmp al,"n"
         jne short aa00
         mov _main_index,0
         jmp gfs3
aa00:
         cmp al,"o"
         jne short aa01
         mov _main_index,1
         jmp gfs3
aa01:
         cmp al,"b"
         je short lkjadq
         cmp al,"h"
         jne short aa02
         cmp _language,1
         je short jjhhff
         cmp _main_index,2
         jne short lkjadq
jjhhff:
         mov _main_index,4
         jmp gfs3
lkjadq:
         mov _main_index,2
         jmp gfs3
aa02:
         cmp al,"d"
         jne short aa03
         mov _main_index,3
         jmp gfs3
aa03:
         cmp al,"f"
         je short aay4
         cmp al,"w"
         jne short aa04
aay4:
         mov _main_index,5
         jmp gfs3
aa04:
         cmp ax,"e"
         je short aac5
         cmp ax,"q"
         jne short aa05
aac5:
         mov _main_index,6
         jmp gfs3
aa05:
         cmp al,14
         jne _moreselect
outmain:
         cmp _saved_pause_status,no
         jne short notpausecausedemo
         call notpausecausedemo
         mov _saved_pause_status,yes
         xor eax,eax
         cmp _inpause,no
         je _ret
         mov eax,41bh
         ret

notpausecausedemo:
         mov _menu_item,1
         cmp _gameoversay,0
         jne _outmenu
         cmp _mode,2
         je short _kjaq
         cmp _mode,3
         je short _kjaq
         inc _menu_item
         cmp _what_level,0
         je _outmenu
_kjaq:
         mov _menu_item,0
         jmp _outmenu

_moreselect:
         cmp al,1ah
         jne short noupc
         mov al,_main_index
         inc al
         jmp short mod_main
noupc:
         cmp al,19h
         jne short nodnc
         mov al,_main_index
         dec al
mod_main:
         cmp al,7
         jne short gfsg
         xor al,al
gfsg:
         cmp al,-1
         jne short gfs2
         mov al,6
gfs2:
         mov _main_index,al
gfs3:
         mov ax,10
         mov dl,gotit_chan
         mov bh,8
         mov bl,15
         mov cl,0
         mov ch,24
         call _play_sample
         xor eax,eax
         ret
nodnc:
         cmp ax,13
        ;je iuwqr
        ;cmp al,18h
         jne _ret
iuwqr:
         call _outmenu
         movzx eax,_main_index
         call [_main_function+eax*4]
         cmp eax,41bh
         je _ret
         xor eax,eax
         ret

_start_demo:
         call _mod_stop
         mov _selected_level,0
         jmp short jaseq

_start_new_game_cause_robert_wants_to_play_doom:
         call _mod_stop
jaseq:
         mov _dummy_timer,-1
         mov _menu_item,0
         call _in_transit
         mov _mode,_donewgame
         mov _temp_god,25
         mov eax,41bh
         cmp _inpause,yes
         je _ret
         xor eax,eax
         ret

_in_transit:
         call _reset_mouse
         mov _changing,1
         mov _stimer,5
         mov _gs_onscr,0
         mov ecx,(maxobjects+1)*5
         xor al,al
         mov edi,offset _gs_off
         rep stosb
         jmp _stop_game

_main_function dd o _ask_level
               dd o _setoptions
               dd o _sethow
               dd o _start_demo
               dd o _sethigh
               dd o _showwarp
               dd o _quitnow

jmp _start_new_game_cause_robert_wants_to_play_doom

_ask_level:
         mov _selected_level_hold,1
         mov _menu_item,10
         ret

_sethow:
         mov _menu_item,9
         ret

_sethigh:
         mov _menu_item,6
         ret

_setoptions:
         mov _menu_item,4
         ret

_showwarp:
         mov _menu_item,5
         cmp _selected_level,0
         jne _ret
         mov _selected_level,1
         ret

_quitnow:
         mov _mode,_exitnow
         xor eax,eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Fix volume bars
; In:
;  EDX => 15 bytes for volume
;   BL = 0 to 15
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_volume_bars:
          mov edi,_language
          mov edx,[edx+edi*4]
          mov edi,edx
          mov ecx,15
          mov al,2
          rep stosb
          mov edi,edx
          mov cl,bl
          dec al
          rep stosb
          ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle collision detection for shots
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

kl_handlc dd 0
kl_handls dd 0
maxast    dd 0
boxsize   dd 0
gtypeq    dd 0

outhc:
         ret

_shot_collision:
         cmp _gs_onscr,0
         je s outhc

         mov ecx,maxobjects+1               ; find highest object number
findlowest:
         dec ecx
         jz s outhc
         cmp _onoff[ecx],0
         jne s findlowest

         mov maxast,ecx                     ; highest object number

         mov ecx,maxobjects+1
         mov esi,-1

kill_loop:
         dec ecx
         jz s outhc
         inc esi
         cmp _gs_off[esi],0
         je short kill_loop

         mov kl_handlc,ecx
         mov kl_handls,esi

         xor ebx,ebx
         xor eax,eax
         mov bx,_gs_obj[esi*2]
         mov al,_type[ebx]
         sub al,t_schnot1
         mov gtypeq,eax
         mov ebx,_cannons[eax*4]
         cmp al,2
         je rocketcalculation
rocketcalculationreturn:
         mov boxsize,ebx

         mov edi,-1
         mov ecx,maxast
         mov si,_gs_obj[esi*2]
         xor eax,eax
         shl esi,2
ck_loop:
         dec ecx
         jz nodestruct
         inc edi
         cmp _type[edi],t_badmax
         ja s ck_loop
         cmp _onoff[edi],0
         je s ck_loop

         xor eax,eax
         mov al,_type[edi]
         mov ebx,_sizes[eax*4]
         add ebx,boxsize

         mov ebp,_xs[esi]                   ; get displacement of esi to edi
         sub ebp,_xs[edi*4]
         cmp ebp,ebx
         jg short ck_loop
         mov edx,ebx
         neg edx
         cmp ebp,edx
         jl short ck_loop

         mov ebp,_ys[esi]
         sub ebp,_ys[edi*4]
         cmp ebp,ebx
         jg short ck_loop
         cmp ebp,edx
         jl short ck_loop

         mov eax,_zs[esi]
         sub eax,_zs[edi*4]
         cmp eax,ebx
         jg short ck_loop
         cmp eax,edx
         jl short ck_loop

         shr esi,2
         cmp gtypeq,t_rocket-t_schnot1      ; rockets are special
         je nodestructbecauserocket
         cmp _type[edi],t_player
         jne short no_playerhit

         mov eax,gtypeq
         cmp _godmode,yes
         je noflak

         push edi esi
         mov al,rednessnme[eax]
         mov ah,140
         call _make_red

         call _hurt_effect
         call _rnd                          ; make ship spin when hit
         and ax,0fffh
         sub ax,07ffh
         add _ship_y,ax
         shr eax,16
         and ax,0fffh
         sub ax,07ffh
         add _ship_x,ax
         pop esi edi

         cmp _game_run,yes
         jne short noflak

no_playerhit:
         mov dl,_gs_who[esi]                ; let enemies know if player hit them
         or _who_hurt[edi],dl

         cmp dl,d_player
         jne short noaddscore
         mov eax,gtypeq
         mov eax,_s_scoretable[eax*4]
         cmp _type[edi],t_bonus1
         jb short addscore
         cmp _type[edi],t_max_bonus
         ja short addscore
         neg eax
addscore:
         add _player_score,eax
         mov _update_score,yes
noaddscore:
         mov eax,gtypeq
         mov bx,_power[eax*2]
         or edi,edi
         jne short noplaydie
         mov _lasthealth,yes
noplaydie:
         sub _toughness[edi*2],bx
         jnc short noflak

         mov dh,-1
         mov _toughness[edi*2],dx           ; if toughness = -2, nme hit
noflak:
         push esi edi

         call _rnd
         mov ebx,_xs[esi*4]
         mov ecx,_ys[esi*4]
         mov ebp,_zs[esi*4]
         and eax,1
         mov edx,_explo[eax*4]
         mov eax,gtypeq
         mov esi,expssiz[eax*4]
         mov edi,esi
         mov al,explode_chan

         call _make_explosion

         pop edi
         mov ebx,_xadds[edi*4]
         mov ecx,_yadds[edi*4]
         mov ebp,_zadds[edi*4]
         mov _xadds[esi*4],ebx
         mov _yadds[esi*4],ecx
         mov _zadds[esi*4],ebp
         pop esi

pop_rocket:
         mov edi,esi
         mov esi,kl_handls
         call gs_remove

nodestruct:
         mov ecx,kl_handlc
         mov esi,kl_handls
         jmp kill_loop

nodestructbecauserocket:
         cmp _type[edi],t_badmax
         ja short nodestruct
         cmp _type[edi],t_max_bonus
         ja short nodes_4
         cmp _type[edi],t_max_asteroid
         ja short nodestruct
nodes_4:
         posit eax
         posit ebp
         add eax,ebp
         mov ebp,_zs[esi*4]
         sub ebp,_zs[edi*4]
         posit ebp
         add eax,ebp
         cmp eax,800
         jb pop_rocket

         push eax
         mov ebp,_xs[esi*4]
         add ebp,_xadds[esi*4]
         sub ebp,_xs[edi*4]
         sub ebp,_xadds[esi*4]
         posit ebp
         mov eax,_ys[esi*4]
         add eax,_yadds[esi*4]
         sub eax,_ys[edi*4]
         sub eax,_yadds[esi*4]
         posit eax
         add eax,ebp
         mov ebp,_zs[esi*4]
         add ebp,_zadds[esi*4]
         sub ebp,_zs[edi*4]
         sub ebp,_zadds[esi*4]
         posit ebp
         add eax,ebp

         pop ebp
         cmp ebp,eax
         jl pop_rocket                      ; if rocket goes away from asteroid, blow it up now!
         shl esi,2
         jmp ck_loop

rocketcalculation:
         mov al,_gunlen+2                   ; generate rocket detection cone
         sub al,_gs_frame[esi]
         imul ebx
         shr eax,6                          ; idiv eax,128
         mov ebx,eax
         jmp rocketcalculationreturn

expssiz     dd 7,15,17,7                    ; explosion sizes for gun types
rednessnme  db 25,40,60,40

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Dummy demo mode guy - man this code is hairy
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_dummy_mod db 0
_dummy_tim db 100
_dummy_lok dd 0
_dummy_hth dw 7000
_dummy_timer dd 0

ggff       db no

_dummy_control:
         mov _shot,no
         movzx eax,_dummy_mod
         call [_dummy_list+eax*4]

         mov esi,_dummy_lok
         cmp _type[esi],t_schnot1
         jae _select_new_target
         or esi,esi
         je _ret
         cmp _onoff[esi],0
         je _select_new_target

         mov ebx,_eyex
         sub ebx,_xs[esi*4]                 ; displacement to selected target
         mov ecx,_eyey
         sub ecx,_ys[esi*4]
         mov ebp,_eyez
         sub ebp,_zs[esi*4]
         posit ebx
         cmp ebx,29000
         ja thnnq
         posit ecx
         cmp ecx,29000
         ja thnnq
         posit ebp
         cmp ebp,29000
         ja thnnq
imback:
         mov eax,ebx
         add eax,ecx
         add eax,ebp
         movzx edi,_guntype
         mov edi,_gunsped[edi*4]
         cdq
         idiv edi
         mov edi,eax
         movsx edi,di
         mov esi,_dummy_lok
         mov ebx,_eyex
         sub ebx,_xs[esi*4]                 ; displacement to selected target
         mov eax,_xadds[esi*4]              ; velocity - look 10 frames ahead
         imul edi
         sub ebx,eax
         mov ecx,_eyey
         sub ecx,_ys[esi*4]
         mov eax,_yadds[esi*4]
         imul edi
         sub ecx,eax
         mov ebp,_eyez
         sub ebp,_zs[esi*4]
         mov eax,_zadds[esi*4]
         imul edi
         sub ebp,eax
         call _zsolve
         call _xsolve
         call _ysolve
         posit ebp
         inc ebp
         shl ebx,10
         shl ecx,10
         mov eax,ebx
         add eax,100000
         cdq
         idiv ebp
         mov ebx,eax
         mov eax,ecx
         add eax,100000
         cdq
         idiv ebp
         mov ecx,eax
normallock:
         cmp bx,400
         jl short notruncate1
         mov bx,400
         mov _shot,no
notruncate1:
         cmp bx,-400
         jg short notruncate2
         mov bx,-400
         mov _shot,no
notruncate2:
         cmp cx,400
         jl short notruncate3
         mov cx,400
         mov _shot,no
notruncate3:
         cmp cx,-400
         jg short notruncate4
         mov cx,-400
         mov _shot,no
notruncate4:
         cmp ggff,yes
         je s skipstore

         mov _ship_dy,bx
         mov _ship_dx,cx
skipstore:
         mov ax,_toughness[0]
         cmp _dummy_hth,ax
         je _ret
         mov _dummy_hth,ax
         call d_tim
         mov _dummy_mod,2
         ret
thnnq:
         call d_tim
         mov _dummy_mod,2
         jmp imback

_select_new_target:
         xor ecx,ecx
snt_lop1:
         inc ecx
         cmp ecx,maxobjects
         je s snt_as
         cmp _onoff[ecx],0
         je s snt_lop1
         cmp _type[ecx],t_bonus1
         jb s snt_lop1
         cmp _type[ecx],t_max_bonus
         ja s snt_lop1
         mov _dummy_lok,ecx
         call d_tim
         mov _dummy_mod,2
         ret
snt_as:
         xor ecx,ecx
snt_lop2:
         inc ecx
         cmp ecx,maxobjects
         je s snt_nme
         cmp _onoff[ecx],0
         je s snt_lop2
         cmp _type[ecx],t_badguy1
         jb s snt_lop2
         cmp _type[ecx],t_badmax
         ja s snt_lop2
         mov _dummy_lok,ecx
         cmp _whatshape[ecx*2],g_cannon
         jne s jjgg
jjgg:
         call d_tim
         mov _dummy_mod,1
         ret
snt_nme:
         xor ecx,ecx
snt_lop3:
         inc ecx
         cmp ecx,maxobjects
         je s _out
         cmp _onoff[ecx],0
         je s snt_lop3
         cmp _type[ecx],t_max_asteroid
         ja s snt_lop3
         mov _dummy_lok,ecx
         call d_tim
         mov _dummy_mod,1
         ret
_out:
         mov _dummy_lok,0
         mov _dummy_mod,0
         ret

_dummy_list dd offset d_wait    ; 0
            dd offset d_shoot   ; 1
            dd offset d_thrust  ; 2
d_wait:
         dec _dummy_tim
         jnz _ret
         jmp _select_new_target

d_shoot:
         mov esi,_dummy_lok
         cmp _type[esi],t_max_asteroid
         jbe s nreta
         cmp _type[esi],t_max_bonus
         jbe s ddzag
nreta:
         mov _shot,yes
         dec _dummy_tim
         jnz _ret
ddzag:
         call d_tim
         mov _dummy_mod,2
         ret

d_thrust:
         mov esi,_dummy_lok
         cmp _type[esi],t_small_asteroid
         jae s forcest
         test _irq_tracespast,3
         jnz s nostths
forcest:
         test _irq_tracespast,1
         jnz s nostths
         mov _thrust,yes
nostths:
         mov esi,_dummy_lok
         or esi,esi
         je s thnn
         cmp _onoff[esi],0
         je s thnn

         mov ebx,_eyex
         sub ebx,_xs[esi*4]                 ; displacement to selected target
         mov ecx,_eyey
         sub ecx,_ys[esi*4]
         mov ebp,_eyez
         sub ebp,_zs[esi*4]
         posit ebx
         cmp ebx,23000
         ja s thnn
         posit ecx
         cmp ecx,23000
         ja s thnn
         posit ebp
         cmp ebp,23000
         jna s dqdd
thnn:
         dec _dummy_tim
         jnz _ret
dqdd:
         call d_tim
         mov _dummy_mod,1
         ret
d_tim:
         call _rnd
         and al,63
         add al,48
         mov _dummy_tim,al
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Reset dummy for another demo run
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_reset_dummy:
         mov _dummy_mod,0
         mov _dummy_tim,100
         mov _dummy_lok,0
         mov ax,_player_toughness
         mov _dummy_hth,ax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; set difficuly level based on eax
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_set_diffculty_based_on_eax:
         mov esi,_powerlist[eax*4]
         mov edi,offset _cannons
         mov ecx,4*4 + 4*2
         rep movsb

         mov ebx,_rocket_sphere[eax*4]
         mov _rocketd,ebx

         ret

_powerlist dd o e0
           dd o e1
           dd o e2

e0       dd 120,460,8000,220    ; sizes of weapons
         dw 990,7800,14000,6000 ; power weapons have
e1       dd 105,400,7500,200
         dw 880,6650,12000,5000
e2       dd 90,345,7000,180
         dw 770,5500,10000,4000

_rocket_sphere dd 18000,13000,8000

         ends
         end
