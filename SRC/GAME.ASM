;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : Game.asm
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
         include control.ext
         include gus.ext
         include explode.ext
         include irq.ext
         include file.ext
         include fx.ext
         include mod.ext
         include clear.ext
         include stars.ext
         include nme.ext
         include c.ext
         include piccy.ext

         include macros.inc
         include equ.inc
         include lang.ext

         public _determine_volume
         public _determine_panning
         public _rnd
         public _make_world_a_cube
         public _put_dash
         public _fade_to_game
         public _rnd_rotate
         public _rnd_speed
         public _rnd_middle
         public _handle_ship_rotate
         public _ship_x
         public _ship_y
         public _ship_z
         public _ship_dx
         public _ship_dy
         public _ship_dz
         public _decay_ship_angles
         public _handle_thrust
         public _add_explosion
         public _make_rocket_explode
         public _add_random_speed
         public _speed_up
         public _get_speed
         public _turn_asteroids
         public _set_type
         public _init_new_game
         public _make_asteroid_explode
         public _add_rnd_speed
         public _tktimer
         public _kill_player
         public _save_picture
         public _check_picture
         public _temp_god
         public _godmode
         public _make_red
         public _handle_player_death
         public _add_an_asteroid
         public _debugit
         public _debug_calc
         public _pcxit
         public _show_time
         public _bonus_timer
         public _bonus_stat
         public _bonus_value
         public _player_toughness
        ;public _number0
        ;public _number1
        ;public _number2
        ;public _number3
        ;public _number4
        ;public _number5
        ;public _number6
        ;public _number7
        ;public _number8
        ;public _number9
        ;public _bignum0
        ;public _bignum1
        ;public _bignum2
        ;public _bignum3
        ;public _bignum4
        ;public _bignum5
        ;public _bignum6
        ;public _bignum7
        ;public _bignum8
        ;public _bignum9
        ;public _sdash
        ;public _bdash
         public _blow_up_bonuses
         public _bonus_probability
         public _maxmov
         public _spedd
         public _speds
         public _hyper
         public _hyperlen
         public _hyptimer
         public _speds
         public _dropit
         public _retrig_thrust
         public _hurt_fraction
         public _drop_interior
         public _player_score
         public _ammo1
         public _ammo2
         public _ammo3
         public _minimum_asteroid_check
         public _min_check
         public _must_destroy
         public _has_destroyed
         public _apply_new_gun_bitmap
         public _ammo
         public _destroy
         public _lasthealth
         public _bottom_score
         public _what_level
         public _statsq
         public _statsw
         public _skill
         public _nme_sup
         public _nme_t1
         public _nme_t2
         public _nme_max
         public _nme_on
         public _nme_speed
         public _hyperspeed
         public _update_score
         public _b_scoretable
         public _a_scoretable
         public _s_scoretable
         public _n_scoretable
         public _b_neg
         public _restart_timer
         public _retrig_game
         public _old_text
         public _top_text
         public _ship_text
         public _old_len
         public _update_top_text
         public _original_nme_t1
         public _ships_left
         public _global_timer
         public _global_framenumber
         public _hurt_effect
         public _drop_cockpit
         public _superfast
         public _bonus9
         public _selected_level
         public _warp_level
         public _bonus_t
         public _bonus_v
         public _ammo_v
         public _scores_v
         public _bonus_p
         public _lls
         public _lles
         public _currentmod
         public _update_bot
         public _smooth_out_averages
         public _find_average
         public _difficulty
         public _min_asteroids
         public _extramancount

; adjustments for level difficulty:
;
; _ammo1
; _ammo2
; _ammo3
; _?_scoretable
; _bonus_probability ; probability tables and bonus_stat
; _blow_up_bonuses   ; yes/no
; _min_asteroids of asteroids in level
; _maxmov during hyperspace
; _hyperlen
; _must_destroy
; _nme_t1
; _nme_t2
; _statsq ; lo = cannon dudes
; _statsw ; lo = mine layers
; _nme_sup = yes/no
; _nme_speed = 400
; _nme_max   = 3
; _nme_on
; _skill ; aim of bad guy

_lls:
_ammo_v            db 0             ; ammunition value tables
_scores_v          db 0             ; scores tables
_min_asteroids     dw 50            ; minimum number of asteroids on screen
_must_destroy      dw 75            ; number of asteroids player must destroy before done level
_bonus_stat        dw 55000         ; probability that bonus will arrive. higher = more bonuses
_bonus_p           db 0             ; indexer for bonus probability tables
_bonus_t           db 0             ; bonus timer tables
_bonus_v           db 0             ; bonus value tables
_statsq            dw 32768         ; stats for camo1 or camo2, lo = camo2, hi = camo1
_statsw            dw 32768         ; stats for mine layer or shooter, low = mine layers
_skill             dw 4000          ; high = higher probability of nme shooting player, 4000 = med, 6000 = hard, 1000 = super easy
_nme_speed         dd 400           ; speed of nme
_nme_sup           db no            ; nme uses super schnot? (yes,no)
_original_nme_t1   dw 2800
_nme_t2            dw 500           ; timer between nme's (after nme death)
_nme_max           db 3             ; maximum number of nme's on at one time
_nme_on            db no            ; nme in level ?
_hyperspeed        dd 3400          ; speed when going through hyperspace
_hyperlen          dw 1000          ; length of time in hyperspace
_hurt_fraction     dd 256           ; ratio of hurt that asteroid has to player.  smaller = easier
_currentmod        db 0
_lle:

_bonus_timer       dw 550,430,650   ; length of time bonus stays on screen
                   dw 700,650,800
                   dw 500,450,400
_bonus_value       dw 700,1400,0    ; health value of bonuses
                   dw 0,0,2100
                   dw 1400,0,0

_lles              dd offset _lle - offset _lls

_bonus_probability dd offset level1 ; pointer to bonus probability tables
_nme_t1            dw 2800          ; start/original timer for nme appearance
_ammo1             dw 35            ; ammunition added when bonus scooped
_ammo2             dw 5
_ammo3             dw 150
_b_scoretable      dd 200,400,250,750,1000,1500,1500,2000,1000
_a_scoretable      dd 100,200,400
_s_scoretable      dd 1,20,50,15
_n_scoretable      dd 1000,2000
_b_neg             dd 1000          ; score subtracted when bonus destroyed
_blow_up_bonuses   db yes           ; bonuses will blow up after level 10

_has_destroyed     dw 0             ; how much has player destoyed so far
_what_level        db 0             ; current level player is at (#)
_player_toughness  dw 7000          ; player toughness at level start, _toughness[0] = during game
_player_score      dd 0             ; players current score
_hyper             db no            ; hyperspace flag
_hyptimer          dw 0             ; timer during jump to hyperspace
_min_check         db yes
_restart_timer     dw 0
_ships_left        db 0
_superfast         dw 0
_selected_level    db 1
_warp_level        db 1
_difficulty        db 1             ; 0 = easy, 1 = normal, 2 = schnotter
_extramancount     dd 0             ; number of extra men to appear per level

level1 db 0,0   ; bonus probability tables, first byte is logical mask
level6 db 15,0,0,1,1,2,2,3,3,4,4,6,6,7,7,8,8

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Determine GUS & SB volume for object
; In:
;    EBX - relative x point of object to determine left/right sound panning of
;    ECX - relative y point
;    EBP - relative z point
; Out:
;    AL = volume (distance 0-15)
; Notes:
;  This point you wish to determine panning for must be relative to the
;  camera.  Eg: subtract camera location before call.
;
;  If you're runing a SB:
;   mov esi,object #
;   call _get_location
;   call _subtract_camera
;   call _determine_volume
;   mov bl,al               ; <=
;   call _play_sample
;
;  If you're runing a GUS:
;   mov esi,object #
;   call _get_location
;   call _subtract_camera
;   call _determine_volume
;   call _determine_panning ; <= this also works with SB, but calculation is useless
;   call _play_sample
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_determine_volume:
         mov eax,ebx                        ; find largest distance
         or eax,eax
         jge s dpno_neg1
         neg eax
dpno_neg1:
         mov esi,ecx
         or esi,esi
         jge s dpno_neg2
         neg esi
dpno_neg2:
         mov edi,ebp
         or edi,edi
         jge s dpno_neg3
         neg edi
dpno_neg3:
         add eax,edi
         add eax,esi

         shr eax,div_256+14
         cmp eax,15
         jge dp_novolumeanyway              ; no volume, no need for pan calculation

         and al,0fh
         xor al,0fh
         clc
         ret

dp_novolumeanyway:
         xor eax,eax
         xor ebx,ebx
         stc
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Determine GUS panning for object
; In:
;    EBX - relative x point of object to determine left/right sound panning of
;    ECX - relative y point
;    EBP - relative z point
;    AX = volume (distance 0-15, from routine above)
; Out:
;    BH = panning position (0-15)
;    BL = volume after distance adjust (0-15)
; Notes:
;  A call to _setsincose MUST have taken place for this routine to work
;  correctly!  This point you wish to determine panning  for   must  be
;  relative to the camera.  Eg: subtract camera location before call.
;
;  Total time: 8 multiplies, 1 divide.
;
;  Done bother to call this routine if you have a SB, as SB doesnt have
;  left/right anyway.
;
;  The panning routine aborts if the volume is zero!
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_determine_panning:
         or ax,ax
         jz _ret

         push ax

         if div_256 eq 8
         shr ebx,8                          ; account for decimal places
         test ebx,00800000h
         jz s pm_1
         or ebx, 0ff000000h
pm_1:
         shr ecx,8
         test ecx,00800000h
         jz s pm_2
         or ecx, 0ff000000h
pm_2:
         shr ebp,8
         test ebp,00800000h
         jz s pm_3
         or ebp, 0ff000000h
pm_3:
         endif

         call _zsolve
         call _xsolve

         pop bx

         dec esi                            ; prevent z = 0
         add esi,1
         adc esi,0
         cmp esi,0
         jge s dp_noneg
         neg esi

         mov eax,esi
         shr eax,div_256+13
         cmp al,3
         jbe dp_nox
         mov al,03h
dp_nox:
         inc al
         sub bl,al                          ; if sound is behind, decrease volume
         jnc dp_noneg
         xor ebx,ebx
         ret                                ; no volume anyway
dp_noneg:
         call _make3dx

         mov eax,edi
         neg eax
         add eax,32
         shr eax,4+div_256/4

         add ax,8                           ; panning center (balance control)

         mov bh,0
         cmp ax,15
         jg _ret
         mov bh,15
         cmp ax,0
         jl _ret
         sub bh,al
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Randomize number
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

randomnumber    dd 5fe6c809h

_rnd:
         xor eax,randomnumber
         xor eax,edx
         xchg al,ah
         add eax,0cd9c9a8fh
         xor eax,esi
         add eax,edi
         xor eax,0526dafb2h
         add eax,ecx
         xor eax,ebx
         add eax,ebp
         mov randomnumber,eax
         in al,64
         shl eax,8
         in al,65
         shl eax,8
         in al,64
         shl eax,8
         in al,64
         add eax,6a1c32b4h
         add randomnumber,eax
         mov eax,randomnumber
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make the world a big cube (3d wrap around effect)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_mwact   db 1                               ; timer
_mwacr   db 7                               ; reset

var1 = 70000

_make_world_a_cube:
         dec _mwact                         ; timer saves CPU time for useless routine
         jnz _ret

         mov al,_mwacr
         mov _mwact,al

         mov ecx,maxobjects+1
         mov ebx,eax
         shr ebx,1
         xor esi,esi
         mov eax,var1
         mov ebx,eax
         neg ebx
         mov ebp,_eyex
         mov edi,_eyey
mwac:
         test _onoff[esi],mainobject_on
         jz short mwnmz

         mov edx,_xs[esi*4]
         sub edx,ebp
         cmp edx,eax
         jl short mwnx

         mov edx,ebx
         jmp short mwnwx
mwnx:
         cmp edx,ebx
         jg short mwnmx

         mov edx,eax
mwnwx:
         add edx,ebp
         mov _xs[esi*4],edx
mwnmx:
         mov edx,_ys[esi*4]
         sub edx,edi
         cmp edx,eax
         jl short mwny

         mov edx,ebx
         jmp short mwnwy
mwny:
         cmp edx,ebx
         jg short mwnmy

         mov edx,eax
mwnwy:
         add edx,edi
         mov _ys[esi*4],edx
mwnmy:
         mov edx,_zs[esi*4]
         sub edx,_eyez
         cmp edx,eax
         jl short mwnz

         mov edx,ebx
         jmp short mwnwz
mwnz:
         cmp edx,ebx
         jg short mwnmz

         mov edx,eax
mwnwz:
         add edx,_eyez
         mov _zs[esi*4],edx
mwnmz:
         inc esi
         loop short mwac

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Put dashboard at bottom
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_put_dash:
         mov edi, _current_page
         mov al,1
         call _compiled_cockpit[cb_dash*4]
         mov edi, _current_page
         mov al,1
         call _compiled_cockpit[cb_clear*4]
         call _copy_virtual_objects
         call _setsincose                   ; set rotation multipliers for eye
         call _star_plot                    ; plot background stars
         call _makeobjs                     ; plot all objects in sides table
         call _drop_interior

         mov _update_bot,1
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Draw ship interior according to control bits
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_drop_interior:
         test _cockpit_control,1
         jz short nobase1
         mov edi,_current_page
         mov al,1
         call _compiled_cockpit[cb_top*4]
         mov edi,_current_page
         mov al,1
         call _compiled_cockpit[cb_bottom*4]
nobase1:
         test _cockpit_control,2
         jz short nobase2
         cmp _menu_item,2
         ja short nobase2
         cmp _menu_item,2
         je short tryflashhigh
dotophta:
         mov edi,_current_page
         mov al,1
         call _compiled_cockpit[cb_target*4]
nobase2:
         ret

tryflashhigh:
         test _irq_tracespast,0200h
         jz short dotophta
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Fade to game
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_fade_to_game:
         mov esi,_title_palette
         mov bh,3
         mov bl,200
         call _fade_palette_read
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Calculate a random asteroid rotation speed
; In:
;  EBX = Asteroid size
; Out:
;  EAX = random addition
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_rnd_rotate:
         push ebx
_rnd_rotate2:
         call _rnd
         and eax,00ffh
         sub eax,007fh

         cmp eax,minx[ebx*4]
         jg short okl
         cmp eax,maxx[ebx*4]
         jg short _rnd_rotate2
okl:
         mov ebx,eax
         mov eax,2048
         cdq
         idiv ebx
         pop ebx

         cmp eax,mmx[ebx*4]
         jg _ret
         cmp eax,mqx[ebx*4]
         jl _ret
         jmp _rnd_rotate

minx     dd 64,48,32
maxx     dd -64,-48,-32
mmx      dd 10,25,40
mqx      dd -10,-25,-40

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; get random speed for asteroid
; In:
;  ESI = object to set
;  EDI = object size (0,1,2) 0 = largest
; Out:
;  EBX = x speed
;  ECX = y speed
;  EBP = z speed
;
; rnd_middle:
; In:
;  EAX = angle
;  EDI = angle
;  EBP = speed
; Out:
;  EBX = x speed
;  ECX = y speed
;  EBP = z speed
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_rnd_speed:
         call _rnd
         and eax,sizetbl[edi*4]
         cmp eax,sizemax[edi*4]
         ja short _rnd_speed

         add eax,sizemin[edi*4]
         movzx ebx,_difficulty
         mov ebx,_percent_speed[ebx*4]
         imul ebx
         shr eax,16
         mov ebp,eax

         call _rnd                          ; angle for asteroid to move
         mov edi,eax
         call _rnd

_rnd_middle:
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

         mov eax,edi
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

sizetbl  dd 127,255,255     ; logical AND speed
sizemax  dd 127,130,130     ; max variance from minumum speed  (variance+min=max)
sizemin  dd 150,270,486     ; min speed
_percent_speed dd 52428 ;  80%
               dd 65536 ; 100%
               dd 85196 ; 130%

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle ship rotation
;
; ship_x = amount to shift on X
; ship_y = amount to shift on Y
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         joystickobject equ 0

_ship_x  dw 0
_ship_y  dw 0
_ship_z  dw 0
_ship_dx dw 0
_ship_dy dw 0
_ship_dz dw 0
xxca     dw 0
xxcb     dw 0

_handle_ship_rotate:
         mov cx,_ship_x
         or cx,_ship_y
         je _ret

         cmp _inverse_keys,yes
         jne short _noinv
         cmp _what_level,0
         je short _noinv
         neg _ship_x
_noinv:
         mov ebx,0
         mov ecx,0
         mov ebp,1200000

         mov ax,_ship_y
         call _rotate_y
         mov ax,_ship_x
         call _rotate_x

         mov esi,joystickobject
         call _inverse_rotate
         call _calc_middle

         mov xxca,ax
         mov xxcb,bx

         mov ebx,0
         mov ecx,120000
         mov ebp,0

         mov ax,_ship_y
         call _rotate_y
         mov ax,_ship_x
         call _rotate_x

         mov esi,joystickobject
         call _inverse_rotate
         mov esi,joystickobject
         push ebx
         mov ax,xxca
         mov bx,xxcb
         mov _eyeax,ax
         mov _eyeay,bx
         mov ax,_eyeay
         mov di,_eyeax
         pop ebx
         call _point_z
         mov _eyeaz,ax
         mov ax,_eyeaz
         mov ax,_ship_z
         add _eyeaz,ax
         cmp _inverse_keys,yes
         jne short _noinv2
         cmp _what_level,0
         je short _noinv2
         neg _ship_x
_noinv2:
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Simulate Ship angular momentum
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

nums equ 3

_decay_ship_angles:
         mov ax,_ship_dx
         sub ax,_ship_x
         je short nextx
         movsx eax,ax

         jl short dsa_makebigx
         shr eax,nums
         inc ax
         add _ship_x,ax
         jmp short nextx
dsa_makebigx:
         shr eax,nums
         dec ax
         add _ship_x,ax
nextx:
         mov ax,_ship_dy
         sub ax,_ship_y
         je short nexty
         movsx eax,ax

         jl short dsa_makebigy
         shr eax,nums
         inc ax
         add _ship_y,ax
         jmp short nexty
dsa_makebigy:
         shr eax,nums
         dec ax
         add _ship_y,ax
nexty:
         mov ax,_ship_dz
         sub ax,_ship_z
         je short nextz
         movsx eax,ax

         jl short dsa_makebigz
         shr eax,nums
         inc ax
         add _ship_z,ax
         jmp short nextz
dsa_makebigz:
         shr eax,nums
         dec ax
         add _ship_z,ax
nextz:
         xor eax,eax
         mov _ship_dx,ax
         mov _ship_dy,ax
         mov _ship_dz,ax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle thrust
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_spedd   dd spedd
_speds   db speds
_maxmov  dd 0
_thr     dd 0

_handle_thrust:
         cmp _hyper,yes
         je short mustgrip
         cmp _what_level,0
         je short mustgrip
         cmp _tmethod,0
         jne ht_float
mustgrip:
         cmp _game_run,yes                  ; if player is dead make X max
         je short nodeadyet
         mov eax,_maxmov
         shr eax,2
         mov _xadds,eax
         ret
nodeadyet:
         mov ebx,_thr
         cmul eax,ebx,63
         shr eax,6
         movsx eax,ax
         mov _thr,eax

         cmp _thrust,yes
         jne short _noaddt

         mov _thrust,no
         mov _vcvol[thrust_chan],15
         or  _vccmnd[thrust_chan],vol

         mov eax,_maxmov
         sub eax,_thr
         mov cl,_speds
         shr eax,cl
         add eax,_thr

         cmp eax,_maxmov
         jg short _noaddt

         mov _thr,eax
_noaddt:
         mov ebp,_thr
         xor esi,esi
         call _set_speed
         call _set_xyzadds
         jmp decaysound

ht_float:
         cmp _mode,1
         jne _ret

         mov ebx,_eyexadds
         cmul eax,ebx,63
         shr eax,6
         movsx eax,ax
         add eax,1
         dec eax
         adc eax,0
         mov _eyexadds,eax

         mov ebx,_eyeyadds
         cmul eax,ebx,63
         shr eax,6
         movsx eax,ax
         add eax,1
         dec eax
         adc eax,0
         mov _eyeyadds,eax

         mov ebx,_eyezadds
         cmul eax,ebx,63
         shr eax,6
         movsx eax,ax
         add eax,1
         dec eax
         adc eax,0
         mov _eyezadds,eax

         cmp _thrust,no
         je short decaysound

         mov _thrust,no
         mov _vcvol[thrust_chan],15
         or  _vccmnd[thrust_chan],vol

         mov ebx,_maxmov
         mov ecx,ebx
         neg ecx

         cmp _xadds[0],ebx
         jg short outq
         cmp _xadds[0],ecx
         jl short outq

         cmp _yadds[0],ebx
         jg short outq
         cmp _yadds[0],ecx
         jl short outq

         cmp _zadds[0],ebx
         jg short outq
         cmp _zadds[0],ecx
         jl short outq

         mov ebp,_spedd
         xor esi,esi
         call _set_speed
         add _xadds[0],ebx
         add _yadds[0],ecx
         add _zadds[0],ebp
outq:
         ret

decaysound:
         cmp _vcvol[thrust_chan],0
         je _ret

         dec _vcvol[thrust_chan]
         or  _vccmnd[thrust_chan],vol
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Add explosion
; In:
;  EBX = x point
;  ECX = y point
;  EBP = z point
;  EAX = size of explosion to add
;  ESI = x direction
;  EDI = y direction
;  EDX = z direction
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_add_explosion:
         push esi edi edx
         push eax
         call _rnd
         and eax,1
         mov edx,[_explo+eax*4]
         pop esi
         mov edi,esi
         mov al,explode_chan
         call _make_explosion
         pop ecx
         pop ebx
         pop eax
         jc short endf
         mov _xadds[esi*4],eax
         mov _yadds[esi*4],ebx
         mov _zadds[esi*4],ecx
endf:
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make rocket explode
;  ESI = object number to explode
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

bbq      db 0
rrx      dd 0
rry      dd 0
rrz      dd 0

_make_rocket_explode:
         call _rnd
         and al,3
         add al,3
         mov bbq,al

         call _get_location
         call _get_speed
         mov rrx,ebx
         mov rry,ecx
         mov rrz,ebp
mre_loop1:
         push esi edi edx
         call _rnd
         and eax,0ffh
         sub eax,07fh
         add edi,eax
         call _rnd
         and eax,0ffh
         sub eax,07fh
         add esi,eax
         call _rnd
         and eax,0ffh
         sub eax,07fh
         add edx,eax
         call _rnd
         and eax,3
         add eax,8
         call _add_explosion
         pop edx edi esi
         mov ebx,rrx
         mov ecx,rry
         mov ebp,rrz

         dec bbq
         jnz short mre_loop1

         mov ecx,maxasteroids+1
         xor esi,esi
         mov eax,_rocketd
         mov edx,eax
         shr edx,1
mre_loop2:
         dec ecx
         jz _ret

         inc esi
         cmp _onoff[esi],0
         je short mre_loop2
         cmp _type[esi],t_badmax
         ja short mre_loop2
         cmp _type[esi],t_max_asteroid
         jbe short mre_got
         cmp _type[esi],t_max_bonus
         jbe short mre_loop2
mre_got:
         mov edi,rrx
         sub edi,_xs[esi*4]
         posit edi
         cmp edi,eax
         jg short mre_loop2

         mov ebx,rry
         sub ebx,_ys[esi*4]
         posit ebx
         cmp ebx,eax
         jg short mre_loop2

         mov ebp,rrz
         sub ebp,_zs[esi*4]
         posit ebp
         cmp ebp,eax
         jg short mre_loop2

         mov eax,_s_scoretable[2*4]
         add _player_score,eax
         mov _update_score,yes

         mov ax,_power+2*2
         sub _toughness[esi*2],ax
         jc short setdead

         cmp edi,edx
         jg mre_loop2
         cmp ebx,edx
         jg mre_loop2
         cmp ebp,edx
         jg mre_loop2

         sub _toughness[esi*2],ax
         jnc mre_loop2
setdead:
         mov _toughness[esi*2],d_player
         jmp mre_loop2

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Add random speed to ESI, EDI, EDX
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_add_random_speed:
         push eax
         call _rnd
         and eax,7fh
         sub eax,3fh
         add esi,eax
         call _rnd
         and eax,7fh
         sub eax,3fh
         add edi,eax
         call _rnd
         and eax,7fh
         sub eax,3fh
         add edx,eax
         pop eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Speed up object ESI    1300/1024 to 1555/1024 ratio
; EDI = base amount to speed up by, 1024 = 1:1 ratio
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_speed_up:
         push eax edx ebx edi

         call _rnd
         and eax,255
         add eax,edi
         mov ebx,eax
         mov eax,_xadds[esi*4]
         imul ebx
         shrd eax,edx,10
         mov _xadds[esi*4],eax

         call _rnd
         and eax,255
         add eax,edi
         mov ebx,eax
         mov eax,_yadds[esi*4]
         imul ebx
         shrd eax,edx,10
         mov _yadds[esi*4],eax

         call _rnd
         and eax,255
         add eax,edi
         mov ebx,eax
         mov eax,_zadds[esi*4]
         imul ebx
         shrd eax,edx,10
         mov _zadds[esi*4],eax

         pop edi ebx edx eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Get speed of object ESI into non standard registers
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_get_speed:
         mov edx,_zadds[esi*4]
         mov edi,_yadds[esi*4]
         mov esi,_xadds[esi*4]
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Irq to turn asteroids
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_turn_asteroids:
         xor esi,esi
         mov ecx,maxobjects
ta_loop:
         inc esi
         mov al,_type[esi]
         cmp al,t_max_bonus
         ja short nstore
         cmp al,t_max_asteroid
         ja decit

         mov bx,_timerq[esi*2]
         mov ax,_whatreal[esi*2]
         add ax,bx
         mov _whatreal[esi*2],ax

         shr ax,6
         cmp al,48
         jl s nowrap1
         sub _whatreal[esi*2],3072
         jmp s newas
nowrap1:
         cmp al,0
         jge s newas
         add _whatreal[esi*2],3072
newas:
         mov ax,_whatreal[esi*2]
         shr ax,6
         add ax,_whatbase[esi*2]
         mov _whatshape[esi*2],ax
nstoid:
         dec ecx
         jnz ta_loop

         ret
nstore:
         cmp al,t_badguy2
         je short rotatehex1
         cmp al,t_badguy3
         je short decfor
         cmp al,t_badguy4
         jne short nstoid

rotatehex2:
         mov ax,si
         and ax,1
         shl ax,13
         sub ax,4096
         add _whatreal[esi*2],ax
         mov ax,_whatreal[esi*2]
         xor edx,edx
         mov bx,10923  ; 65536/6 frames
         div bx
         add ax,g_camo2
         mov _whatshape[esi*2],ax
decfor:
         dec _timerq[esi*2]
         jmp short nstoid
decit:
         dec _timerq[esi*2]
         test _timerq[esi*2],400h
         jz short nstoid
         cmp _blow_up_bonuses,yes
         je short nstoid
         add _timerq[esi*2],512
         jmp short nstoid

rotatehex1:
         mov ax,_timerq[esi*2]
         add _whatreal[esi*2],ax
         mov ax,_whatreal[esi*2]
         xor edx,edx
         mov bx,10923  ; 65536/6 frames for hexagonal dude
         div bx
         add ax,g_camo2
         mov _whatshape[esi*2],ax
         jmp nstoid

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Set size based on type
; In:
;  ESI = object
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_set_type:
         call _rnd
         mov cx,ax
         xor eax,eax
         mov al,_type[esi]
         and cx,rndmask[eax*2]
         add cx,toughv[eax*2]
         mov _toughness[esi*2],cx
         mov bx,sizeq[eax*2]
         jmp _set_bitmap_scaling

sizeq    dw 9000,4000,1500
toughv   dw 10000,5000,1800
rndmask  dw 2047,1023,511

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; New game
; In:
;  AL - level to start at -1 (eg 0 for new game, -1 for demo, 7 for 6...)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_new_game:
         mov _irq_tracespast,0
         mov _gameoversay,0
         mov _vzadds,0
         mov _hyper,no
         mov _thrust,no
         mov _restart,no
         mov _restart_timer,150
         mov _mode,_run_game
         mov _gun3pow,no
         mov _gunspow,no
         mov _ships_left,3                  ; player gets 4 ships to start
         mov _player_score,0
         mov _what_level,al
         call _next_level_please
         mov al,_what_level
         cmp al,_highest_level
         jbe short aeqww
         mov _highest_level,al
aeqww:
         or al,al
         jnz short _retrig_game
         cmp _menu_item,1
         je short _retrig_demo_text
         cmp _menu_item,0
         jne short _retrig_game
_retrig_demo_text:
         mov _menu_item,2

_retrig_game:
         call _reset_nme
         movzx eax,_difficulty
         neg eax
         add eax,3
         mov _extramancount,eax
         mov eax,maxmov
         mov _maxmov,eax
         mov _speds,speds
         mov _spedd,spedd
         mov _ship_text,210
         mov _stimer,25
         mov _superfast,0
         mov dword ptr _sspeedtable,033c1904h ; reset weapon speed
         mov _apply_new_gun_bitmap,yes
         mov _temp_god,25
         mov _type[0],t_player
         mov _onoff[0],1
         mov _lasthealth,yes
         mov _destroy,yes
         mov _ammo[1],yes
         mov _ammo[2],yes
         mov _ammo[3],yes
         mov _tktimer,1                     ; timer for asteroid death checking
         mov d _gungot[0],1
         mov d _shots_left[1*2],0
         mov _shots_left[3*2],0
         mov _min_check,yes
         mov _update_score,yes

         mov ax,_player_toughness
         mov _toughness,ax                  ; players toughness
         mov _lasthealth,yes

         call _rnd                          ; random angle for player
         mov _eyeaz,ax
         shr eax,16
         mov _eyeay,ax

_retrig_thrust:
         cmp _mode,2
         je _ret
         cmp _mode,3
         je _ret

         mov ax,0
         mov dl,thrust_chan
         mov bl,0
         mov bh,8
         mov cl,loop_on+loop_bi
         mov ch,17
         jmp _play_sample

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Add random speed to object esi
; EBX = mask
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_add_rnd_speed:
         mov ecx,ebx
         shr ecx,1
         call _rnd
         and eax,ebx
         sub eax,ecx
         add _xadds[esi*4],eax
         call _rnd
         and eax,ebx
         sub eax,ecx
         add _yadds[esi*4],eax
         call _rnd
         and eax,ebx
         sub eax,ecx
         add _zadds[esi*4],eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Test and Make Objects explode (Finally got to this routine!!)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

xtype    db 0
xxx      dd 0
xyy      dd 0
xzz      dd 0
xdirx    dd 0
xdiry    dd 0
xdirz    dd 0
reago    db 0
retest   db 0
_tktimer dw 1       ; timer for checking to explode asteroid

_make_asteroid_explode:
         dec _tktimer
         jnz _ret
         mov _tktimer,1

         call _rnd
         and al,1
         jz short doforward

         mov esi,maxasteroids+1

find12explode1:
         dec esi
         jz _ret
         test _onoff[esi],mainobject_on
         jz s find12explode1
         mov al,_type[esi]
         cmp al,t_badmax
         ja s find12explode1
         cmp _toughness[esi*2],0
         jl s expthi1
         cmp al,t_player
         jbe short find12explode1
         cmp al,t_badguy3
         je short testbang1
         cmp al,t_badguy4
         je short testbang1
         cmp al,t_badguy1
         jae short find12explode1
testbang1:
         test _timerq[esi*2],0400h
         jz short find12explode1
         jmp short expthi1

doforward:
         xor esi,esi
         mov ecx,maxasteroids+1

find12explode2:
         inc esi
         dec ecx
         jz _ret
         test _onoff[esi],mainobject_on
         jz s find12explode2
         mov al,_type[esi]
         cmp al,t_badmax
         ja s find12explode2
         cmp _toughness[esi*2],0
         jl s expthi1
         cmp al,t_player
         jbe short find12explode2
         cmp al,t_badguy3
         je short testbang2
         cmp al,t_badguy4
         je short testbang2
         cmp al,t_badguy1
         jae short find12explode2
testbang2:
         test _timerq[esi*2],0400h
         jz short find12explode2

expthi1:
         mov xtype,al
         mov _min_check,yes
         mov _tktimer,7                     ; when asteroid to explode is found, don't
                                            ; check again until time passes
         cmp al,t_max_bonus
         ja short onmehitit
         cmp _toughness[esi*2],d_player
         jne short onmehitit
         mov _update_score,yes
         mov ebx,_b_neg
         sub _player_score,ebx
         cmp al,t_max_asteroid
         ja short onmehitit
         add _player_score,ebx
         inc _has_destroyed                 ; wowee, player has killed asteroid
         mov _destroy,yes                   ; tell mainline to update status bar
         movzx eax,al
         mov eax,_a_scoretable[eax*4]
         add _player_score,eax
         mov _update_score,yes
onmehitit:
         call _rnd
         and al,3
         add al,4
         cmp xtype,t_badguy1
         jb short notinc1
         add al,2
notinc1:
         mov reago,al
         mov _onoff[esi],0
         mov _whatshape[esi*2],0
         xor eax,eax
         mov al,_type[esi]
         cmp al,t_badguy1
         jb short notremovebadguy
         mov _nmetype[esi],1                ; when _nmetype = 1, irq removes NME
         cmp _toughness[esi*2],d_player
         jne short notremovebadguy
         mov edx,_n_scoretable
         add _player_score,edx
         mov _update_score,yes
         cmp al,t_badguy2
         ja short notremovebadguy
         sub _player_score,edx
         mov edx,_n_scoretable[1*4]
         add _player_score,edx
notremovebadguy:
         call _get_location
         call _get_speed

         mov xxx,ebx
         mov xyy,ecx
         mov xzz,ebp
         mov xdirx,esi
         mov xdiry,edi
         mov xdirz,edx

         cmp al,t_badguy3
         jb short add_exp_l
         inc reago
         sub al,t_badguy3

          if registered eq yes
         or eax,eax
         jnz short add_nasty
         cmp _nme_sup,yes
         jne short add_nasty
         mov eax,3
          endif

add_nasty:                                  ; make mine explode
         push ebx ecx ebp eax
         call _get_random_shoot_angle
         call _shoot_from
         pop eax ebp ecx ebx
         dec reago
         jnz short add_nasty

         cmp xtype,t_badguy2
         je _ret
         cmp xtype,t_badguy4
         je _ret

         call _rnd
         and al,3
         add al,3
         mov reago,al
         xor eax,eax
         mov al,xtype
         mov esi,xdirx
         mov edi,xdiry
         mov edx,xdirz

add_exp_l:                                  ; add graphic explosions
         pushad
         mov edx,eax
         call _rnd
         mov bx,expsizeq[edx*2]
         shr bx,3
         and ax,bx
         add ax,expsizeq[edx*2]
         mov ebx,xxx
         mov edx,xdirz
         call _add_explosion
         xor eax,eax
         mov al,xtype
         mov ebx,xtypexs[eax*4]
         call _add_rnd_speed
         popad

         dec reago
         jnz short add_exp_l

         cmp xtype,2
         jae maybeaddspecial

         inc xtype
jjhh:
         call _rnd
         and al,3
         cmp al,3
         je jjhh

         cmp xtype,t_small_asteroid
         je short nocrunch
         and al,1
nocrunch:
         add al,3
         mov reago,al

more_same:
         call _search_next_available_object ; add more asteroids because big one exploded
         cmp esi,maxasteroids
         jae _ret
         mov _toughness[esi*2],0
         mov ebx,xxx
         mov ecx,xyy
         mov ebp,xzz
         call _put_object
         mov _onoff[esi],mainobject_on
         mov al,xtype
         mov _type[esi],al ;***
         call _set_type

againrndtype:
         call _rnd
         and ax,7
          if registered eq yes
         cmp ax,5
          elseif registered eq no
         cmp ax,4
          endif
         jge againrndtype

         lea eax,[eax*2+eax]
         shl ax,4
         add ax,48
         mov _whatbase[esi*2],ax
         mov _whatshape[esi*2],ax
         mov _whatreal[esi*2],0
         xor eax,eax
         movzx ebx,xtype
         call _rnd_rotate
         mov _timerq[esi*2],ax

         mov ebx,xdirx
         mov ecx,xdiry
         mov ebp,xdirz
         call _set_xyzadds
         xor eax,eax
         mov al,xtype
         mov edi,axspeeds[eax*4]
         call _speed_up
         xor eax,eax
         mov al,xtype
         mov ebx,qxspeeds[eax*4]
         call _add_rnd_speed

         dec reago
         jnz more_same

maybeaddspecial:                            ; maybe add special
         jne _ret
         cmp _hyper,yes
         je _ret

         mov retest,0
         mov ebx,xxx                        ; make sure bonus does not appear "on" player
         mov ecx,xyy
         mov ebp,xzz
         sub ebx,_xs
         sub ecx,_ys
         sub ebp,_zs
         posit ebx
         posit ecx
         posit ebp
         mov edx,_sizes
         shl edx,2
         cmp ebx,edx
         ja short maybyes
         cmp ecx,edx
         ja short maybyes
         cmp ebp,edx
         jb _ret
maybyes:
         mov ax,_has_destroyed              ; add "H" bonus
         cmp ax,_must_destroy
         jb short johhre
         call _rnd
         test al,1
         jz short johhre
         call _part1
         mov eax,t_hyper-t_bonus1
         call _part3
johhre:
         call _rnd
         cmp ax,65536-327                   ; 0.005 percent of the time we give an extra ship
         jbe short notextraman
         cmp _extramancount,0
         je short notextraman
         dec _extramancount
         call _part1
         mov eax,t_extraship-t_bonus1
         call _part3
         call _rnd
notextraman:
         and ax,65535
         mov cl,retest
         shr ax,cl
         xor ax,65535
         cmp ax,_bonus_stat                 ; bonus_stat smaller = fewer bonuses
         jae _ret

         call _part1
         call _part2
         call _part3
         jmp short johhre                   ; maybe add more than bonus (very rare though)

; explosion size: ast1,2,3,nul,bonus1,2,3,4,5,6,7,camo1,camo2,mine1,mine2
expsizeq dw 27,19,10,0,10,10,10,13,15,16,13,13,13,9,9,6,6
xtypexs  dd 1023,511,255,0,2047,2047,2047,2047,2047,2047,2047,2047,2047,1023,1023,1023,1023 ; random speed addition for explosions
axspeeds dd 2000,2000,1000                  ; acceleration of asteroids
qxspeeds dd 127,127,127                     ; random addition mask for asteroid speed

_part1:
         call _search_next_available_object
         cmp esi,maxasteroids
         jae _ret
         mov ax,1000
         mov _toughness[esi*2],ax
         mov ebx,xxx
         mov ecx,xyy
         mov ebp,xzz
         call _put_object
         mov _onoff[esi],mainobject_on
         mov bx,1300
         jmp _set_bitmap_scaling

_part2:
         call _rnd                          ; now add special bonus
         mov ebx,_bonus_probability
         and al,[ebx]
         movzx eax,al
         mov al,[ebx+1+eax]
         ret
_part3:
         movzx ebx,al
         add al,t_bonus1
         mov _type[esi],al  ;****
         add ax,g_bonuses-t_bonus1          ; bitmap g_bonuses point to bonuses
         mov _whatshape[esi*2],ax
         call _rnd
         and ax,63+07800h                   ; timer=0yyq qxxx xxxx xxxx, where qq=offset pulse, yy=pulse type xx = time till death
         add ax,_bonus_timer[ebx*2]         ; length of time bonus stays on screen
         mov _timerq[esi*2],ax
         mov ebx,xdirx
         mov ecx,xdiry
         mov ebp,xdirz
         call _set_xyzadds
         xor eax,eax
         mov al,xtype
         mov edi,axspeeds[eax*4]
         call _speed_up
         xor eax,eax
         mov al,xtype
         mov ebx,qxspeeds[eax*4]
         call _add_rnd_speed

         inc retest
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Dump screen to PCX file
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_save_picture db 0
lastcnt  db 0
lastval  dw 256
memstor  dd 0

_check_picture:
         cmp _save_picture,1
         jne _ret
         cmp _ouch,1
         je _ret
         mov _activate_controls,no
         mov lastval,256

testagain:
         mov edx,offset e_pcxname
         call _openfile
         jc short saveit
         call _closefile
         inc e_pcxname+6
         cmp e_pcxname+6,"9"+1
         jne short testagain
         mov e_pcxname+6,"0"
         inc e_pcxname+5
         jmp short testagain
saveit:
         call _closefile
         mov edx,offset e_pcxname
         call _createfile
         mov ecx,69
         mov edx,offset pcx
         call _writefile

         mov ax,59
morewiret:
         mov ecx,1
         mov edx,offset zeroval
         push eax
         call _writefile
         pop eax
         dec ax
         jnz short morewiret

         xor ax,ax
         xor bx,bx
         mov edx,_lomembase
         mov memstor,edx

_capture_loop:
         push ax
         push bx

         shr ax,1
         push ax
         push bx
         call _read_point
         cmp al,1
         jne short nosub
         dec al
nosub:
         mov cl,al
         xor ch,ch

         cmp lastval,cx
         jne short flush
         inc lastcnt
         cmp lastcnt,040h
         jne nextpixl
         mov lastcnt,0ffh
         mov esi,offset lastcnt
         mov edi,memstor
         movsw
         add memstor,2
         jmp short firstpixl
flush:
         cmp lastval,256
         je short firstpixl
         push cx
         cmp lastcnt,1
         jne short multi
         cmp lastval,0c0h
         jae multi
         mov esi,offset lastval
         mov ecx,1
         jmp nextgg
multi:
         or lastcnt,0c0h
         mov esi,offset lastcnt
         mov ecx,2
nextgg:
         mov edi,memstor
         rep movsb
         mov memstor,edi
         pop cx
firstpixl:
         mov lastval,cx
         mov lastcnt,1
nextpixl:
         pop bx ax
         inc ax
         cmp ax,640
         jne _capture_loop
         xor ax,ax
         inc bx
         cmp bx,400
         jne _capture_loop

         cmp lastcnt,1
         jne short multi2
         cmp lastval,0c0h
         jae multi2
         mov esi,offset lastval
         mov ecx,1
         jmp nextgg2
multi2:
         or lastcnt,0c0h
         mov esi,offset lastcnt
         mov ecx,2
nextgg2:
         mov edi,memstor
         rep movsb
         mov ecx,edi
         mov edx,_lomembase
         sub ecx,edx
         call _writefile

         mov edi,offset _palette2
         xor al,al
         mov ecx,768
         call _get_palette                  ; get palette

         mov esi,offset _palette2
         mov edi,_lomembase
         mov ecx,768

         mov al,12
         stosb
morepalout:
         lodsb
         shl al,2
         stosb
         loop short morepalout

         mov edx,_lomembase
         mov ecx,769
         call _writefile
         call _closefile

         mov _save_picture,0
         mov _activate_controls,yes
         cmp _pcxit,yes
         je _ret
         mov ax,word ptr [e_pcxname+5]
         mov word ptr [g_pcxname+5],ax
         mov _top_text,offset _messagep
         ret

;pcx      db 00ah,005h,001h,008h,000h,000h,000h,000h
;         db 07fh,002h,08fh,001h,000h,000h,000h,000h
;         db 000h,000h,000h,008h,000h,000h,008h,000h
;         db 008h,000h,000h,029h,000h,008h,010h,008h
;
;         db 008h,000h,018h,000h,000h,010h,008h,000h
;         db 000h,000h,05ah,010h,008h,010h,029h,000h
;         db 000h,018h,008h,008h,031h,000h,000h,010h
;         db 010h,008h,020h,008h,008h,010h,010h,010h
;zeroval  db 000h,001h,040h,001h,001h

pcx db 00ah,005h,001h,008h,000h,000h,000h,000h
   db 07fh,002h,08fh,001h,080h,002h,0e0h,001h
   db 000h,000h,000h,000h,000h,004h,008h,000h
   db 000h,000h,000h,018h,008h,000h,008h,000h

   db 000h,020h,010h,000h,000h,000h,008h,008h
   db 000h,000h,038h,008h,008h,000h,018h,000h
   db 000h,010h,000h,018h,018h,000h,008h,000h
   db 010h,000h,010h,008h,000h,020h,000h,000h

zeroval  db 000h,001h,080h,002h,000h


_messagep  dd o e_messagep , o g_messagep

e_messagep db "PCX Screen Dump as "
e_pcxname  db "OUTER00.PCX",0

g_messagep db "PCX Bild als "
g_pcxname  db "OUTER00.PCX abgelegt",0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Kill off user
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_temp_god db 1

_kill_player:
         dec _temp_god
         jnz _ret

         inc _temp_god

         mov ecx,maxasteroids
         xor edi,edi
ck_loop:
         dec ecx
         jz _ret
         inc edi
         cmp _type[edi],t_badmax
         ja s ck_loop
         cmp _onoff[edi],0
         je s ck_loop

         xor eax,eax
         mov al,_type[edi]
         mov ebx,_sizes[eax*4]
         add ebx,cockpitsize*2

         mov ebp,_eyex                      ; get displacement of esi to edi
         sub ebp,_xs[edi*4]
         cmp ebp,ebx
         jg short ck_loop
         mov edx,ebx
         neg edx
         cmp ebp,edx
         jl short ck_loop

         mov ebp,_eyey
         sub ebp,_ys[edi*4]
         cmp ebp,ebx
         jg short ck_loop
         cmp ebp,edx
         jl short ck_loop

         mov eax,_eyez
         sub eax,_zs[edi*4]
         cmp eax,ebx
         jg short ck_loop
         cmp eax,edx
         jl short ck_loop

         push ecx edi
         call _hurt_player
         pop edi ecx
         jmp ck_loop

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Cause player to bump against asteroid edi
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_godmode db no            ; god mode flag

_hurt_player:
         mov al,_type[edi]
         cmp al,t_max_asteroid
         jbe _hurt_him_bad
         cmp al,t_badguy1
         jae _hurt_him_bad

         movzx eax,al
         sub al,t_bonus1
         push eax eax                       ; save bonus type

         push edi                           ; player gets sphere/health

         mov edi,offset _palette2
         xor al,al
         mov ecx,768
         call _get_palette                  ; get palette
         xor esi,esi
morefadeinc:
         add [_palette2+esi],25
         cmp [_palette2+esi],64
         jb short notrun2
         mov [_palette2+esi],63
notrun2:
         inc esi
         cmp esi,6
         jne short morefadeinc
         mov esi,_title_palette
         mov edi,offset _palette2
         mov bh,1
         mov ah,130
         call _fade_palette

         pop edi

         mov _onoff[edi],0                  ; turn captured bonus off

         pop edx
againsam:
         call _rnd
         and eax,3
         add al,bonussam[edx]
         cmp al,bonusand[edx]
         ja short againsam
         mov dl,gotit_chan
         mov bl,15
         mov bh,7
         xor cl,cl
         mov ch,24
         call _play_sample

         pop eax
         cmp al,6                           ; test if random "?" bonus
         jne short nouestion
         call _rnd
         and eax,7
         mov al,rndbonus7table[eax]
nouestion:
         mov ebx,messages[eax*4]
         mov _top_text,ebx
         mov bx,_bonus_value[eax*2]
         add _toughness[0],bx
         mov _lasthealth,yes
         mov bx,_player_toughness
         shl bx,1                           ; maximum player health = 2*_player_toughness
         cmp _toughness[0],bx
         jbe short godothingy
         mov _toughness[0],bx               ; if carry, force to maximum value
godothingy:
         mov ebx,_b_scoretable[eax*4]
         add _player_score,ebx
         mov _update_score,yes
         jmp [_perform_bonus_function+eax*4] ; jump to appropriate bonus function

bonus1:
bonus2:
         ret

bonus3:
         mov _ammo[1],yes
         cmp _gungot[1],1                   ; cannons
         je short gotitalready1
         mov _nextgun,1
gotitalready1:
         cmp _shots_left[1*2],0
         jne short hasalready1
         cmp _guntype,0
         jne short hasalready1
         mov _nextgun,1
hasalready1:
         mov _gungot[1],1
         mov ax,_ammo1
         add _shots_left[1*2],ax
         mov ax,_max_ammo[1*2]
         cmp _shots_left[1*2],ax
         jbe short notrim1
         mov _shots_left[1*2],ax
notrim1:
         ret
bonus4:
         mov _ammo[2],yes
         cmp _gungot[2],1
         je short gotitalready2
         mov _nextgun,2
gotitalready2:
         cmp _shots_left[2*2],0
         jne short hasalready2
         cmp _guntype,0
         jne short hasalready2
         mov _nextgun,2
hasalready2:
         mov _gungot[2],1
         mov ax,_ammo2
         add _shots_left[2*2],ax
         mov ax,_max_ammo[2*2]
         cmp _shots_left[2*2],ax
         jbe short notrim2
         mov _shots_left[2*2],ax
notrim2:
         ret
bonus5:
         mov _ammo[3],yes
         cmp _gungot[3],1
         je short gotitalready3
         mov _nextgun,3
gotitalready3:
         cmp _shots_left[3*2],0
         jne short hasalready3
         cmp _guntype,0
         jne short hasalready3
         mov _nextgun,3
hasalready3:
         mov _gungot[3],1
         mov ax,_ammo3
         add _shots_left[3*2],ax
         mov ax,_max_ammo[3*2]
         cmp _shots_left[3*2],ax
         jbe short notrim3
         mov _shots_left[3*2],ax
notrim3:
         ret
bonus6:
         cmp _what_level,0
         je _ret                            ; don't hyperspace if in demo mode
         mov eax,_hyperspeed
         mov _maxmov,eax                    ; hyper to next level
         mov ecx,maxobjects-1
desbloop:
         mov al,_type[ecx+1]
         cmp al,t_max_asteroid
         jbe short noclear
         mov _toughness[ecx*2+2],d_nme
noclear:
         loop short desbloop

         call _smooth_out_averages
         mov _hyper,yes
         mov ax,_hyperlen
         mov _hyptimer,ax
         mov _speds,spedsh
         mov _spedd,speddh
         mov _nme_on,no                     ; no nme's during hyper
         mov _bonus_stat,0                  ; no bonuses during hyper
         jmp _retrig_thrust
bonus7:                                     ; "?" bonus
         call bonus5
         mov al,_gun3pow
         add al,_gunspow
         cmp al,no+yes
         je _ret
         mov _gun3pow,yes
         mov _gunspow,no
         mov _guntype,3
         mov _nextgun,3
         jmp _select_middle

 if registered eq yes
rndbonus7table db 0,1,2,3,4,6,7,8
 elseif registered eq no
rndbonus7table db 0,1,2,1,0,2,7,8
 endif

bonus8:
         inc _ships_left
         mov _ship_text,210
         ret                                ; extra man bonus

_bonus9:
         mov ax,_player_toughness
         cmp _toughness[0],ax
         jae short noresettt
         mov _toughness[0],ax
noresettt:
         mov _superfast,2500
         mov dword ptr _sspeedtable,02070402h
         ret                                ; superfast weapons

messages dd o _messagepower1                ; blue
         dd o _messagepower2                ; grn
         dd o _messagepower3                ; can
         dd o _messagepower4                ; rckt
         dd o _messagepower5                ; super
         dd o _messagepower6                ; "H"
         dd o _messaged                     ; "?"
         dd o _messagepower8                ; extra ship
         dd o _messagef                     ; superfast weapons

 if registered eq yes
bonussam db 11,11,11,11,14,11,14,14,11 ; sample #'s to play for bonus captured
bonusand db 13,13,13,13,14,13,14,14,14 ; max bonus sample
 elseif registered eq no
bonussam db 11,11,11,11,14,11,14,14,11 ; sample #'s to play for bonus captured
bonusand db 12,12,12,12,14,12,14,14,12
 endif

_perform_bonus_function label dword
         dd offset bonus1
         dd offset bonus2
         dd offset bonus3
         dd offset bonus4
         dd offset bonus5
         dd offset bonus6
         dd offset bonus7
         dd offset bonus8
         dd offset _bonus9

_hurt_him_bad:
         call _rnd
         and ax,63
         add ax,1500

         mov ax,_toughness[edi*2]
         shr _toughness[edi*2],1            ; remove toughness from asteroid
         sub _toughness[edi*2],800
         jnc short nodead
         mov ax,5000
nodead:
         sub ax,_toughness[edi*2]

         cmp _godmode,yes                   ; hahahahaha hehehe grrr!!!
         je _ret

         neg _xadds[0]
         neg _yadds[0]
         neg _zadds[0]
         neg _thr
         sar _thr,1

         cmp _hyper,yes
         jne short nodie
         cmp _thr,700
         jb short nodie
         mov ax,15000                       ; hyperspaced player is dead for sure
nodie:
         movzx eax,ax
         mov ebx,_hurt_fraction
         imul ebx
         shr eax,10
         sub _toughness[0],ax               ; remove toughness from player
         cmp _toughness[0],0
         jge short not0
         mov _toughness[0],0
not0:
         mov _lasthealth,yes
         shr ax,3
         mov ah,140
         call _make_red
_hurt_effect:
         call _rnd                          ; make ship spin when hit
         and ax,0fffh
         sub ax,07ffh
         add _ship_y,ax
         shr eax,16
         and ax,0fffh
         sub ax,07ffh
         add _ship_x,ax

         call _rnd
         and ax,1
         add ax,1
         mov dl,death_chan
         mov bl,15
         mov bh,7
         xor cl,cl
         mov ch,24
         call _play_sample

         mov _temp_god,25
         ret

inctable db 0,0,0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle player death
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_handle_player_death:
         cmp _toughness,0
         jg _ret

         mov _restart_timer,50 ;150

         cmp _what_level,0
         je short dogameoverthingy

         dec _ships_left
         jnz short nootheridea

dogameoverthingy:
         cmp _menu_item,0
         je _reptb
         cmp _menu_item,3
         jae _repta
_reptb:
         mov _menu_item,1
_repta:
         mov _gameoversay,300
         mov _restart_timer,650
         cmp _what_level,0
         je short nootheridea
         mov eax,_player_score
         cmp eax,d _names+30*10-4
         jbe short nootheridea
         mov _restart_timer,140
nootheridea:
         mov _superfast,0
         mov _apply_new_gun_bitmap,yes
         mov _gun3pow,no
         mov _gunspow,no
         mov dword ptr _sspeedtable,033c1904h ; reset weapon speed
         xor _game_run,yes+no
         mov _toughness,0
         mov _hyper,no
         mov _thrust,no
         mov _restart,no
         mov _mode,_back_from_dead
         mov _vccmnd[thrust_chan],vol
         mov _vcvol[thrust_chan],0

         call _rnd
         mov bx,230
         test ax,1
         jz short noneg2
         neg bx
noneg2:
         mov _vyadds,bx
         mov bx,185
         test ax,2
         jz short noneg3
         neg bx
noneg3:
         mov _vzadds,bx

         xor ax,ax
         mov _ship_x,0
         mov _ship_y,0
         mov _ship_z,0

         mov ax,4
         mov dl,death_chan
         mov bl,15
         mov bh,7
         xor cl,cl
         mov ch,24
         call _play_sample

         mov al,63
         mov ah,90
         call _make_red
         jmp _mod_stop

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make palette all red
; In: AL = amount to make red
;     AH = rate of fade
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

jobg     db 0

_make_red:
         cmp al,63
         jbe short noabovetrim
         mov al,63
noabovetrim:
         mov jobg,ah
         shr jobg,1
         mov inctable,al
         shr al,2
         mov inctable+1,al
         mov inctable+2,al

         push ax
         mov edi,offset _palette2
         xor al,al
         mov ecx,768
         call _get_palette                  ; get palette

         xor ecx,ecx                        ; make it red
         xor edi,edi
rednessloop:
         mov al,_palette2[ecx]
         add al,inctable[edi]
         cmp al,63
         jbe short ntop
         mov al,63
         or edi,edi
         jnz s ntop
         mov _palette2[ecx],al
         add ecx,2
         jmp nowwrap
ntop:
         mov _palette2[ecx],al
         inc edi
         cmp edi,3
         jne short nowwrap
         xor edi,edi
nowwrap:
         inc ecx
         cmp ecx,768
         jb short rednessloop

         mov esi,_title_palette
         mov edi,offset _palette2
         mov bh,1
         pop ax
         mov bl,ah
         shr jobg,2
         sub bl,jobg
         mov jobg,0
         cmp bl,90
         ja _fade_palette
         mov bl,90
         jmp _fade_palette

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Find out which asteroids which are too plentyful
; Out:
;  AL = asteroid type
;  AH = number of asteroids
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_find_average:
         xor ebx,ebx
         mov _whops[0],eax
         mov _whops[4],eax
         mov _whops[8],eax
         mov ecx,maxasteroids

average_loopa:
         cmp _onoff[ecx],0
         je short noadd2averagea
         movzx eax,_type[ecx]
         cmp al,3
         jae short noadd2averagea
         inc _whops[eax*4]
noadd2averagea:
         loop short average_loopa

         xor eax,eax
         mov ebx,_whops[0]
         cmp ebx,_whops[4]
         jnb short _wh1a
         mov ebx,_whops[4]
         inc al
_wh1a:
         cmp ebx,_whops[8]
         jnb short _wh2a
         mov al,2
_wh2a:
         mov ah,byte ptr _whops[eax*4]
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Wipe out asteroids which are too plentyful
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_smooth_out_averages:
         call _find_average
         mov ecx,maxasteroids
         shr ah,1
av_loop2:
         cmp _onoff[ecx],0
         je short noadd2av
         cmp al,_type[ecx]
         jne short noadd2av
         mov _toughness[ecx*2],-2
         dec ah
         jz short retttt
noadd2av:
         loop short av_loop2
retttt:
         mov ecx,maxasteroids               ; now remove 1/4 of asteroids in scene
av_loop3:
        ;cmp _onoff[ecx],0                  ; by blowing them up...
        ;je short noadd3av
        ;mov _toughness[ecx*2],-2
         mov _onoff[ecx],0                  ; or by making them disappear
noadd3av:
         sub ecx,4
         or ecx,ecx
         jg short av_loop3
retttx:
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Add a randomly sized asteroid to scene
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_whops   dd 0,0,0

_add_an_asteroid:
         call _search_next_available_object
         call _init_object
         xor ebx,ebx
         mov _whops[0],eax
         mov _whops[4],eax
         mov _whops[8],eax
         mov ecx,maxasteroids

average_loop:
         cmp _onoff[ecx],0
         je short noadd2average
         movzx eax,_type[ecx]
         cmp al,3
         jae short noadd2average
         inc _whops[eax*4]
noadd2average:
         loop short average_loop

         xor eax,eax
         mov ebx,_whops
         cmp ebx,_whops[4]
         jb short _wh1
         mov ebx,_whops[4]
         inc al
_wh1:
         cmp ebx,_whops[8]
         jb short _wh2
         mov al,2
_wh2:
         mov _type[esi],al ;***
         call _set_type

againrndtyp:
         call _rnd
         and ax,7
          if registered eq yes
         cmp ax,5
          elseif registered eq no
         cmp ax,4
          endif
         jge againrndtyp

         lea eax,[eax*2+eax]
         shl ax,4
         add ax,48
         mov _whatbase[esi*2],ax
         mov _whatshape[esi*2],ax
         mov _whatreal[esi*2],0
         movzx ebx,_type[esi]
         call _rnd_rotate
         mov _timerq[esi*2],ax

         call _rnd
         mov ebx,40000
         mov ecx,40000
         mov ebp,40000

         test al,1
         jz short nntr1
         neg ebx
nntr1:
         test al,2
         jz short nntr2
         neg ecx
nntr2:
         test al,4
         jz short nntr4
         neg ebp
nntr4:
         add ebx,_eyex
         add ecx,_eyey
         add ebp,_eyez
         call _put_object

         movzx edi,_type[esi]
         call _rnd_speed
         call _set_xyzadds
         jmp _set_object_on

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Show frames/second at screen bottom
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_debugit db no
_debugti dd 0
_pcxit   db no
_debug_calc db 0

_show_time:
         mov eax,_debugti
         mov ebx,_irq_framenumber
         mov _debugti,ebx
         sub ebx,eax
         mov _debug_calc,bl

         cmp _debugit,no
         je _ret

         out_8 sc_data, 1

         mov edi,_current_page
         add edi,31920           ; (320*400-320)/4

         mov cl,16
         sub cl,bl

         cmp bl,0
         jle short skipthis_1
         cmp bl,16
         jb short gl_lp1
         mov bl,16
gl_lp1:
         mov byte ptr [edi],255
         inc edi
         dec bl
         jnz short gl_lp1

skipthis_1:
         cmp cl,0
         jle short skipthis_2
         cmp cl,16
         jb short gl_lp2
         mov cl,16
gl_lp2:
         mov byte ptr [edi],0
         inc edi
         dec cl
         jnz short gl_lp2

skipthis_2:
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Update text line at screen top
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_top_text dd 0
_old_text dd 0
_old_len  dd 0
_txttimer dd 0
_ship_text dd 0
_global_framenumber dd 0
oldnum db 01

_update_top_text:
         cmp _ship_text,0
         je huquq

         mov al,_ships_left
         cmp oldnum,al
         je short hjkasdq
         mov oldnum,al
         movzx eax,al
         call _cv32
         mov bl,al
         and al,0fh
         add al,"0"
         shr bl,4
         add bl,"0"
         mov edx,_language
         mov edx,_shipnum[edx*4]
         mov [edx+0],bl
         mov [edx+1],al
hjkasdq:
         cmp _menu_item,3
         jae huquq
         cmp _menu_item,2
         jne short nottestgog
         test _irq_tracespast,0200h
         jnz short huquq
nottestgog:
         mov edx,_language
         push dword ptr _shipsay[edx*4]
         pushw 320-8
         pushw 99
         pushw 263              ; screen middle, just below target ()
         pushw 255
         call _tprint_str
huquq:
         cmp _top_text,0
         je short notnewassign
         mov edi,_top_text
         mov edx,_language
         mov edi,[edx*4+edi]
         mov _old_text,edi
         xor ecx,ecx
         xor ebx,ebx
         xor eax,eax
moreadjust:
         mov al,[edi]
         mov bl,_charlentbl[eax]
         add ecx,ebx
         inc edi
         cmp al,0
         jne short moreadjust

         mov eax,xactual
         sub eax,ecx
         shr eax,1
         add eax,3
         mov _old_len,eax
         mov edx,_global_framenumber
         add edx,210
         mov _txttimer,edx
         mov _top_text,0

notnewassign:
         cmp _old_text,0
         je _ret
         cmp _menu_item,3
         jae _ret

         mov eax,_global_framenumber
         cmp eax,_txttimer
         ja short delret
         cmp _menu_item,2
         jne short nottestgog2
         test _irq_tracespast,0200h
         jnz _ret
nottestgog2:
         push _old_text
         pushw 320-8
         mov eax,_old_len
         pushw ax
         pushw 250              ; screen middle, just below target ()
         pushw 255
         call _tprint_str
         ret
delret:
         mov _old_text,0
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Put number at location
; ESI = number of compiled bitmap to call
; EAX = number to put
; EBX = x location
; ECX = y location
; EBP = size of numbers
;      -  0 = small numbers
;      - 10 = big numbers
;  DL = # of digits
;  DH = width
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

vvcc  dd 0    ; x position of number
vvyy  dd 0    ; y position of number
width dd 8    ; width of number (usually 4 or 8)
numst db 0,0  ; # of digits
paged dd 0
xxxx  dd 0
bigus dd 0
cmnum dd 0

_dropit:
         call _testdl
         mov cmnum,esi
         mov bigus,ebp
         mov byte ptr width,dh
         mov vvcc,ebx
         mov vvyy,ecx
         mov numst+0,dl
         mov numst+1,dl
         mov ebx,vvcc
         mov xxxx,ebx
         call _cv32

         mov ecx,_current_page
         mov paged,ecx

         push eax eax
         mov edi,ecx
         mov eax,1
         mov esi,cmnum
         call [_compiled_cockpit+esi*4]
         pop eax
morebop1:
         call dropchar3
         shr eax,4
         dec numst
         jnz short morebop1

         mov ebx,xxxx
         mov vvcc,ebx

         movzx ebx,_active_page
         xor bl,1
         shl ebx, 2                         ; scale page # to dword
         mov eax, _page_addr[ebx]           ; get offset to page
         mov paged, eax                     ; and set for future mov's

         mov edi,eax
         mov eax,1
         mov esi,cmnum
         call [_compiled_cockpit+esi*4]

         pop eax
morebop2:
         call dropchar3
         shr eax,4
         dec numst+1
         jnz short morebop2

         ret

dropchar3:
         push eax eax
         mov ebx,vvcc
         mov ecx,vvyy
         call _compile_xy
         mov edi,paged
         add edi,esi
         pop ebp
         and ebp,0fh
         add ebp,bigus
         call [_compiled_numbers+ebp*4]
         mov eax,width
         sub vvcc,eax
         pop eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make sure there are a minimum number of asteroids
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_minimum_asteroid_check:
         cmp _min_check,yes
         jne _ret

         xor ecx,ecx
         mov bx,_min_asteroids
         or bx,bx
         je _ret
mincheck:
         inc ecx
         cmp ecx,maxobjects+1+1
         je _add_an_asteroid
         cmp _onoff[ecx],0
         je short mincheck
         cmp _type[ecx],t_max_asteroid
         ja short mincheck
         dec bx
         jne short mincheck

         mov _min_check,no
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Show cheapo health and ammo
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_health_bar_length  equ 100
_destroy_bar_length equ 100

_update_bot   db 1
_apply_new_gun_bitmap db yes
_lasthealth   db yes
_ammo         db yes,yes,yes,yes
_destroy      db yes
_update_score db yes
_global_timer db 0
_oxmap        dd 0
vvmis         db 0
ccvr          db 0
ccvx          db 0

_bottom_score:
         cmp _update_bot,no
         je skipbotup

         dec _update_bot
         mov edi,_current_page
         mov al,1
         call _compiled_cockpit[cb_dash*4]
         xor eax,eax
         mov word ptr _destroy,ax
         mov _apply_new_gun_bitmap,al
         mov dword ptr _ammo,eax
         mov _lasthealth,al
         cmp _language,0
         je short skipbotup
         push dword ptr [_texttables+48*4]
         push word ptr 17
         push word ptr 350
         call _tdraw_bitmap
         push dword ptr [_texttables+49*4]
         push word ptr 241
         push word ptr 350
         call _tdraw_bitmap
         push dword ptr [_texttables+50*4]
         push word ptr 148
         push word ptr 350
         call _tdraw_bitmap

skipbotup:
         cmp _update_score,yes
         jne upscor

         xor ecx,ecx
         mov edx,9999999
         mov _update_score,no
         mov eax,_player_score
         cmp eax,edx
         jbe short nonega
         inc ecx
         mov ebx,eax
         neg eax
         cmp ebx,0fe000000h
         ja short nonega
         dec ecx
         mov eax,edx
nonega:
         push ecx
         mov ebx,76-9
         mov ecx,368
         mov dl,7
         mov dh,10
         mov ebp,10
         mov esi,cb_score
         call _dropit
         pop eax
         or eax,eax
         je short upscor
         mov edi,_current_page
         add edi,80*381+2
         mov al,1
         call _compiled_numbers[21*4] ; draw negative score!
         movzx ebx,_active_page
         xor bl,1
         mov edi, _page_addr[ebx*4]
         add edi,80*381+2
         mov al,1
         call _compiled_numbers[21*4]
upscor:
         mov ax,_must_destroy
         cmp _has_destroyed,ax
         jb  short tetstmmu
         mov al,_global_timer
         test al,00020h
         jz short removemis2
         cmp _destroy,yes
         je short updest2
         cmp vvmis,0
         je updest
updest2:
         mov esi,cb_mission
         call _drop_cockpit
         mov vvmis,0
         jmp updest
removemis2:
         cmp _destroy,yes
         je short updest3
         cmp vvmis,1
         je short updest
updest3:
         mov vvmis,1
         jmp short removemis
tetstmmu:
         cmp _destroy,yes
         jne short updest
removemis:
         mov _destroy,no
         movzx eax,_has_destroyed
         mov ebx,_destroy_bar_length
         cmp ax,_must_destroy
         jge short max_perlevel
         mul ebx
         xor edx,edx
         mov bx,_must_destroy
         div ebx
         mov ebx,eax
max_perlevel:
         mov eax,ebx
         mov ebx,126-9
         mov ecx,368
         mov dl,3
         mov dh,10
         mov ebp,10
         mov esi,cb_mission
         cmp al,100
         jne short noteg
         mov di,_must_destroy
         cmp _has_destroyed,di
         jae short noteg
         mov ax,99
noteg:
         call _dropit
updest:
         cmp _toughness[0],769              ; flash if <10% health
         ja short noflashh
         mov al,_global_timer
         test al,00020h
         jz short removemis4
         cmp _lasthealth,yes
         je short upammox
         cmp ccvr,0
         je upammo
upammox:
         mov esi,cb_shields
         call _drop_cockpit
         mov ccvr,0
         jmp upammo
removemis4:
         cmp _lasthealth,yes
         je short upammox2
         cmp ccvr,1
         je upammo
upammox2:
         mov ccvr,1
         jmp short removemis3
noflashh:
         cmp _lasthealth,yes
         jne short upammo
removemis3:
         mov _lasthealth,no
         movzx eax,_toughness[0]
         or eax,eax
         jge short nonege
         xor eax,eax
nonege:
         mov ebx,_health_bar_length
         add ebx,ebx
         shr ax,1
         cmp ax,_player_toughness
         jge short max_healevel
         mov ax,_toughness[0]
         or ax,ax
         jge s oopad
         xor ax,ax
oopad:
         shr ebx,1
         mul ebx
         xor edx,edx
         mov bx,_player_toughness
         div ebx
         mov ebx,eax
max_healevel:
         or ebx,ebx
         jne short nodeadq
         mov _toughness[0],0
nodeadq:
         mov eax,ebx
         mov ebx,183-9
         mov ecx,368
         mov dl,3
         mov dh,10
         mov ebp,10
         mov esi,cb_shields
         call _dropit
upammo:
         cmp _ammo[1],yes
         jne short upammo2

         mov _ammo[1],no
         movzx eax,_shots_left[2]
         mov ebx,314-7
         mov ecx,350
         mov dl,3
         mov dh,7
         xor ebp,ebp
         mov esi,cb_ammo1
         cmp _gungot[1],0
         call _dropittest
upammo2:
         cmp _ammo[2],yes
         jne short upammo4

         mov _ammo[2],no
         movzx eax,_shots_left[4]
         mov ebx,314-7
         mov ecx,366
         mov dl,3
         mov dh,7
         xor ebp,ebp
         mov esi,cb_ammo2
         cmp _gungot[2],0
         call _dropittest
upammo4:
         cmp _ammo[3],yes
         jne short upammo6

         mov _ammo[3],no
         movzx eax,_shots_left[6]
         mov ebx,314-7
         mov ecx,382
         mov dl,4
         mov dh,7
         xor ebp,ebp
         mov esi,cb_ammo3
         cmp _gungot[3],0
         call _dropittest
upammo6:
         cmp _superfast,0
         je short testbooga
         cmp _superfast,300
         je short testbo
         ja short normtck
         cmp _superfast,200
         ja _ret
normtck:
         mov al,_global_timer
         mov bl,08h
         cmp _superfast,200
         jb short bigtim
         shl bl,2
bigtim:
         test al,bl
         jz short testbo
         cmp ccvx,1
         je short testbooga
         mov ccvx,1
         mov _oxmap,37
         jmp short renewma
testbo:
         cmp ccvx,0
         je short testbooga
         mov ccvx,0
         jmp short renewba

testbooga:
         cmp _apply_new_gun_bitmap,yes
         jne noupbitmap
renewba:
         movzx eax,_guntype
         mov al,_gunmap[eax]
         mov _oxmap,eax
renewma:
         mov ax,_cliplt
         mov bx,_cliprt
         mov cx,_cliptp
         mov dx,_clipbt
         push ax bx cx dx
         mov ax,_gundash+0
         mov bx,_gundash+2
         mov cx,_gundash+4
         mov dx,_gundash+6
         mov _cliplt,ax
         mov _cliprt,cx
         mov _cliptp,bx
         mov _clipbt,dx
         dec ax
         mov _scale_destx,ax
         push ax
         sub ax,cx
         neg ax
         mov _scale_destwidth,ax
         push ax
         mov _scale_desty,bx
         push bx
         sub bx,dx
         neg bx
         mov _scale_destheight,bx
         push bx

         mov eax,_xreftable[31*4]
         mov _xref1,eax
         mov _xref2,eax

         mov eax,_oxmap
         mov esi,_bitbase[eax*4]
         mov _bitmap,esi
         mov _hackx,4

         mov edi,_current_page
         mov al,1
         call [_compiled_cockpit+cb_gtype*4]
         extrn _xscale3:near
         call _xscale3
         pop dx cx bx ax
         mov _scale_destx,ax
         mov _scale_destwidth,bx
         mov _scale_desty,cx
         mov _scale_destheight,dx
         movzx ebx,_active_page
         xor bl,1
         mov eax, _page_addr[ebx*4]
         mov _current_page, eax
         mov edi,eax
         mov al,1
         call [_compiled_cockpit+cb_gtype*4]
         call _xscale3
         movzx ebx,_active_page
         mov eax, _page_addr[ebx*4]
         mov _current_page, eax

         pop dx cx bx ax
         mov _hackx,0
         mov _cliplt,ax
         mov _cliprt,bx
         mov _cliptp,cx
         mov _clipbt,dx
         mov _apply_new_gun_bitmap,no

noupbitmap:
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Test to put numbers or dashes if equal
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_dropittest:
         jne _dropit

         mov cmnum,esi
         mov bigus,ebp
         mov byte ptr width,dh
         mov vvcc,ebx
         mov vvyy,ecx
         mov numst+0,3;dl
         mov numst+1,3;dl
         mov ebx,vvcc
         mov xxxx,ebx

         mov ecx,_current_page
         mov paged,ecx

         mov edi,ecx
         mov eax,1
         mov esi,cmnum
         call [_compiled_cockpit+esi*4]

morebop3:
         call dropdash
         dec numst
         jnz short morebop3

         mov ebx,xxxx
         mov vvcc,ebx

         movzx ebx,_active_page
         xor bl,1
         shl ebx, 2                         ; scale page # to dword
         mov eax, _page_addr[ebx]           ; get offset to page
         mov paged, eax                     ; and set for future mov's

         mov edi,eax
         mov eax,1
         mov esi,cmnum
         call [_compiled_cockpit+esi*4]

morebop4:
         call dropdash
         dec numst+1
         jnz short morebop4

         ret

dropdash:
         mov ebx,vvcc
         mov ecx,vvyy
         call _compile_xy
         mov edi,paged
         add edi,esi
         mov ecx,20
         cmp bigus,10
         jne short nogiddash
         inc ecx
nogiddash:
         call [_compiled_numbers+ecx*4]
         mov eax,width
         sub vvcc,eax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Find length of EAX number
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_testdl:
         movzx edi,dl
         cmp eax,num10s[edi*4-4]
         jae _ret
         dec dl
         jmp _testdl

num10s   dd 0,10,100,1000,10000,100000,1000000

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Draw cockpit interior # ebx on both pages
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_drop_cockpit:
         mov edi,_current_page
         mov al,1
         call _compiled_cockpit[esi*4]
         movzx ebx,_active_page
         xor bl,1
         mov edi, _page_addr[ebx*4]
         mov al,1
         jmp _compiled_cockpit[esi*4]

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; External WAD stuff for .EXE
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         public colourtable
         public _star_colour
         public offsets
         public compilelist
         public hackcolour
         public colback1
         public colback2
         public colfron1
         public colfron2
         public _sfxcomplist
         public wad_version
         public _maxmods

wad_version db 0,0

colourtable label byte

         db 33 dup (0)

        ;db 221    ; 0  t_big_asteroid
        ;db 221    ; 1  t_medium_asteroid
        ;db 221    ; 2  t_small_asteroid
        ;db 126    ; 3  t_player
        ;db 206    ; 4  t_bonus1
        ;db 209    ; 5  t_bonus2
        ;db 96     ; 6  t_cannon_bonus
        ;db 190    ; 7  t_rocket_bonus
        ;db 234    ; 8  t_schnot2_bonus
        ;db 235    ; 9  t_hyper
        ;db 208    ; 10 t_question
        ;db 109    ; 11 t_extraship
        ;db 234    ; 12 t_lightning
        ;db 172    ; 13 t_badguy1
        ;db 208    ; 14 t_badguy2
        ;db 172    ; 15 t_badguy3
        ;db 208    ; 16 t_badguy4
        ;db 255    ; 17
        ;db 204    ; 18 t_schnot1
        ;db 226    ; 19 t_cannons
        ;db 109    ; 20 t_rocket
        ;db 196    ; 21 t_schnot2
        ;db 255    ; 22
        ;db 255    ; 23
        ;db 255    ; 24
        ;db 255    ; 25
        ;db 255    ; 26
        ;db 255    ; 27
        ;db 255    ; 28
        ;db 255    ; 29
        ;db 255    ; 30
        ;db 255    ; 31
        ;db 253    ; 32 t_explosion

colback1 db 0;3
colback2 dd 0;03030303h
colfron1 db 0;8
colfron2 dd 0;08080808h

_star_colour    dd 0;0a28a49c1h               ; colours for 4 stars

hackcolour db 0;0FAh
           db 0;0F5h
           db 0;0EEh
           db 0;0E2h
           db 0;0D6h
           db 0;0BBh
           db 0;0A7h
           db 0;086h

compilelist label dword
         dd 0;offset _number0 - offset compilelist
         dd 0;offset _number1 - offset compilelist
         dd 0;offset _number2 - offset compilelist
         dd 0;offset _number3 - offset compilelist
         dd 0;offset _number4 - offset compilelist
         dd 0;offset _number5 - offset compilelist
         dd 0;offset _number6 - offset compilelist
         dd 0;offset _number7 - offset compilelist
         dd 0;offset _number8 - offset compilelist
         dd 0;offset _number9 - offset compilelist
         dd 0;offset _bignum0 - offset compilelist
         dd 0;offset _bignum1 - offset compilelist
         dd 0;offset _bignum2 - offset compilelist
         dd 0;offset _bignum3 - offset compilelist
         dd 0;offset _bignum4 - offset compilelist
         dd 0;offset _bignum5 - offset compilelist
         dd 0;offset _bignum6 - offset compilelist
         dd 0;offset _bignum7 - offset compilelist
         dd 0;offset _bignum8 - offset compilelist
         dd 0;offset _bignum9 - offset compilelist
         dd 0;offset _sdash   - offset compilelist
         dd 0;offset _bdash   - offset compilelist

offsets  dw 0,0;0,0     ; 0
         dw 0,0;1,0     ; 1
         dw 0,0;0,0     ; 2
         dw 0,0;0,0     ; 3
         dw 0,0;0,0     ; 4
         dw 0,0;0,0     ; 5
         dw 0,0;0,0     ; 6
         dw 0,0;1,0     ; 7
         dw 0,0;0,0     ; 8
         dw 0,0;0,0     ; 9
         dw 0,0;0,0     ; 0
         dw 0,0;2,1     ; 1
         dw 0,0;1,0     ; 2
         dw 0,0;0,0     ; 3
         dw 0,0;0,1     ; 4
         dw 0,0;0,1     ; 5
         dw 0,0;1,1     ; 6
         dw 0,0;1,1     ; 7
         dw 0,0;0,0     ; 8
         dw 0,0;1,0     ; 9
         dw 0,0;0,4     ; sd
         dw 0,0;0,0     ; bd

_sfxcomplist:
         db 0;0 ;  "SENGINE.SND"   ;  buy this game
         db 0;1 ;  "SBUMP0.SND"    ;  sex
         db 0;0 ;  "SBUMP1.SND"    ;  blood
         db 0;1 ;  "SCANNON.SND"   ;  fuck me
         db 0;0 ;  "SDEAD.SND"     ;  i like this game, i think i will play again
         db 0;0 ;  "SELECTRO.SND"  ;  loser
         db 0;1 ;  "SEXP0.SND"     ;  mother and i are one
         db 0;1 ;  "SEXP1.SND"     ;  fuck
         db 0;1 ;  "SEXP2.SND"     ;  great sex
         db 0;1 ;  "SEXP3.SND"     ;  i am excited
         db 0;0 ;  "SCHANGE.SND"   ;  don't stop playing
         db 0;1 ;  "SGOTIT1.SND"   ;  cunt
         db 0;1 ;  "SGOTIT2.SND"   ;  fuck
         db 0;1 ;  "SGOTIT3.SND"   ;  whore
         db 0;1 ;  "SZOOM.SND"     ;  i want to buy this game
         db 0;1 ;  "SNUKE.SND"     ;  buy this game
         db 0;1 ;  "SBEEP.SND"     ;  sex

_maxmods db 2

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Really small font numbers
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

db 3000 dup (0)

comment %
_number0:
   dw 7,13
   include n0.inc
_number1:
   dw 4,13
   include n1.inc
_number2:
   dw 6,13
   include n2.inc
_number3:
   dw 6,13
   include n3.inc
_number4:
   dw 7,13
   include n4.inc
_number5:
   dw 6,13
   include n5.inc
_number6:
   dw 6,13
   include n6.inc
_number7:
   dw 6,13
   include n7.inc
_number8:
   dw 7,13
   include n8.inc
_number9:
   dw 6,13
   include n9.inc
_sdash:
   dw 6,3
   include nd.inc

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Big numbers
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_bignum0:
   dw 9,26
   include b0.inc
_bignum1:
   dw 5,24
   include b1.inc
_bignum2:
   dw 8,25
   include b2.inc
_bignum3:
   dw 9,26
   include b3.inc
_bignum4:
   dw 9,24
   include b4.inc
_bignum5:
   dw 8,25
   include b5.inc
_bignum6:
   dw 8,25
   include b6.inc
_bignum7:
   dw 8,25
   include b7.inc
_bignum8:
   dw 9,26
   include b8.inc
_bignum9:
   dw 9,25
   include b9.inc
_bdash:
   dw 8,4
   include bd.inc
%
         ends
         end
