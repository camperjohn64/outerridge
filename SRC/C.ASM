;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : C.asm
; Included from: Main Assembley module
; Description  : Main OutRidge Game Controller Routines
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
         include game.ext
         include piccy.ext

         include macros.inc
         include equ.inc
         include lang.ext

         public _mode
         public _mode_handler
         public _retrig_volumes
         public _next_level_please
         public _retrig_level
         public _start_game
         public _stop_game
         public _reset_blue
         public _menu_icons
         public _menu_things
         public _main_index
         public _options_index
         public _edit_index
         public _handle_rotating_menu_icon
         public _wipe_field
         public _menu_pause
         public _check_score
         public _hscore
         public _cursorx
         public _under
         public _chrtime
         public _level_tables
         public _level_end
         public _diff_index
         public _reset_language

_mode    db 1
_hscore  dd 0                               ; offset to high score start
_cursorx dd 0
_under   db " "
_chrtime db 0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Handle turning things on/off during different game modes
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_mode_handler:
         movzx eax,_mode
         jmp _mode_tables[eax*4]

_mode_tables dd o _ret               ; nothing is happening
             dd o _ret               ; game is running
             dd o _wait              ; back from death
             dd o _back              ; back from death part ii
             dd o _ret               ; asteroid smashes screen
             dd o _ret               ; exit_now
             dd o _ret               ; title show
             dd o _ret               ; title wait
             dd o _ret               ; new game
             dd o _orderit           ; force ordering screen at level 10 (shareware)

_orderit:
         call _start_demo
         mov _menu_item,9
         ret

_wait:
         cmp _gameoversay,0
         jle short notdec1
         dec _gameoversay
         jne short notdec1
         dec _gameoversay
notdec1:
         dec _restart_timer
         jnz _ret

         inc _mode
         mov _restart,no

         ret
_back:
         cmp _menu_item,7
         je _ret
         cmp _menu_item,1                   ; check if game over
         jne short gotaba

         call _check_score                  ; test high score
         cmp _what_level,0
         je gotaba
         cmp _high_index,10                 ; 10 = no high score, skip input
         je short gotaba
         mov _menu_item,7                   ; set menu to high score and wait for input
gotaba:
         cmp _gameoversay,0
         jle short notdec2
         dec _gameoversay
         jne short notdec2
         dec _gameoversay
notdec2:
         cmp _what_level,0
         je short demolevel

         cmp _restart,yes
         jne _ret

demolevel:
         call _wipe_field
         mov _game_run,no
         mov _always_run,no
         mov _vzadds,0
         call _reset_nme
         mov _mode,_anew
         call _retrig_volumes
         xor eax,eax
         mov _top_text,eax
         mov _old_text,eax
         mov _old_len,eax

         cmp _what_level,0
         je short dogameoverthingy2
         cmp _ships_left,0
         jne _ret

dogameoverthingy2:
         mov _mode,_dointro
         ret

_retrig_volumes:
         or _vccmnd[4],vol
         or _vccmnd[5],vol
         or _vccmnd[6],vol
         or _vccmnd[7],vol
         or _vccmnd[8],vol
         or _vccmnd[9],vol
         or _vccmnd[10],vol
         or _vccmnd[11],vol
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Send player to next level
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_next_level_please:
         inc _what_level
         mov al,_what_level
         cmp al,_highest_level
         jbe short highg
         mov _highest_level,al
highg:
         cmp _what_level,100
         jbe short notresetl
         mov _what_level,30
notresetl:
         mov _has_destroyed,0
         mov _blow_up_bonuses,no
         cmp _what_level,0
         je short noblowbonus2
         cmp _difficulty,2
         je short noblowbonus2
         cmp _what_level,5
         jbe short _retrig_level
      if registered eq no
         mov _mode,9
      endif
noblowbonus2:
         mov _blow_up_bonuses,yes
_retrig_level:
         movzx eax,_what_level

         push eax
         call _cv32
         shl ax,4
         shr al,4
         add ax,"00"
         xchg al,ah
         mov edx,_language
         mov edx,_numlevel[edx*4]
         mov [edx],ax
         pop eax
hgfb:
         cmp eax,44
         jbe short nothdfa
         sub eax,24
         jmp short hgfb
nothdfa:
         push eax
         imul eax,48
         lea esi,[eax+offset _level_tables]
         mov ecx,_lles
         mov edi,offset _lls
         rep movsb
         pop eax

         mov edx,_language
         mov edi,_level_names[edx*4]
         or al,al
         je short demofirstname
         mov bl,al
         mov ecx,10000
         xor al,al
nextname:
         repnz scasb
         dec bl
         jnz short nextname
demofirstname:
         mov esi,edi
         mov edi,_numlevel[edx*4]
         add edi,5
         mov ecx,25
         rep movsb
         mov _top_text,offset _say_level
         mov _thrust,no
         mov _shot,no
         mov _hyper,no

         movzx eax,_ammo_v                  ; copy ammunition
         imul eax,6
         lea esi,[eax+offset _ammoset]
         mov edi,offset _ammo1
         movsd
         movsw

         movzx esi,_bonus_t                 ; copy bonus timers
         imul esi,18
         movzx ebx,_difficulty
         add esi,_bonus_timer_difficulty[ebx*4]
         mov edi,offset _bonus_timer
         mov ecx,18
         rep movsb

         movzx eax,_bonus_v                 ; copy bonus health values
         imul eax,18
         lea esi,[eax+offset _bonus_vset]
         mov edi,offset _bonus_value
         mov ecx,18
         rep movsb

         movzx eax,_scores_v                ; copy score values
         imul eax,19*4
         lea esi,[eax+offset _score_set]
         mov edi,offset _b_scoretable
         mov ecx,19
         rep movsd

         xor ebx,ebx
         movzx ecx,_bonus_p                 ; set bonus probability offset
         mov eax,offset _selections
         jcxz short gotlocfb
getnextbl:
         mov bl,[eax]
         add bl,2
         add eax,ebx
         loop short getnextbl
gotlocfb:
         mov _bonus_probability,eax

         call _load_mod
         call _play_mod

       if registered eq no
         mov _nme_sup,no
         mov _statsw,50000
         mov _statsq,-1
       endif

         call _reset_nme

         xor eax,eax
         mov al,_difficulty
         mov ebx,_must_destroy_percent[eax*4]
         mov ax,_must_destroy
         imul ebx
         shr eax,16
         mov _must_destroy,ax

         xor eax,eax
         mov al,_difficulty
         mov ebx,_nme_skill_percent[eax*4]
         mov ax,_skill
         imul ebx
         shr eax,16
         mov _skill,ax

         xor eax,eax
         mov al,_difficulty
         mov ebx,_hurt_percent[eax*4]
         mov eax,_hurt_fraction
         imul ebx
         shr eax,16
         mov _hurt_fraction,eax

         xor eax,eax
         mov al,_difficulty
         mov ebx,_ast_percent[eax*4]
         mov ax,_min_asteroids
         imul ebx
         shr eax,16
         mov _min_asteroids,ax

         xor eax,eax
         mov al,_difficulty
         mov ebx,_percent_speed[eax*4]
         mov eax,1300
         imul ebx
         shr eax,16
         mov maxmov,eax

         xor eax,eax
         mov al,_difficulty
         mov ebx,_hyp_percent[eax*4]
         mov ax,_hyperlen
         imul ebx
         shr eax,16
         mov _hyperlen,ax
         mov eax,_hyperspeed
         imul ebx
         shr eax,16
         mov _hyperspeed,eax

         mov ax,_original_nme_t1
         mov _nme_t1,ax
         mov _statsw,65535
         mov _statsw,65535

         mov _kbtype,offset _config_keyboard
         cmp _what_level,0                  ; test if level 0, dummy level
         jne _ret

         mov _kbtype,offset _dummy_control
         jmp _reset_dummy

_must_destroy_percent dd 52428 ;80%  ; number of asteroids player must destroy
                      dd 65536 ;100%
                      dd 78643 ;120%

_hurt_percent dd 65536 ;100% ; amount player is hurt
              dd 78643 ;120%
              dd 98304 ;150%

_nme_skill_percent dd 65536 ;100%
                   dd 91750 ;140%
                   dd 117964;180%

_ast_percent  dd 52428 ;80%  ; number of extra asteroids
              dd 65536 ;100%
              dd 76643 ;120%

_hyp_percent dd 39322 ;60%
             dd 52428 ;80%
             dd 65536 ;100%

_percent_speed dd 65536 ; 100%
               dd 65536 ; 100%
               dd 85196 ; 130%

_ammoset   dw 50,20,200
           dw 40,10,150
           dw 30,7,100
           dw 25,5,75
           dw 20,3,50
           dw 15,2,30

_bonus_timer_difficulty dd offset _bonus_1set,offset _bonus_2set,offset _bonus_3set

_bonus_1set dw 750,630,800   ; length of time bonus stays on screen
            dw 800,800,800
            dw 700,550,600

            dw 350,580,700
            dw 500,780,750
            dw 640,500,550

            dw 350,510,650
            dw 500,750,700
            dw 580,400,500

            dw 450,460,600
            dw 600,700,650
            dw 500,300,400

            dw 350,370,500
            dw 500,500,500
            dw 350,250,250

_bonus_2set dw 650,530,750   ; length of time bonus stays on screen
            dw 780,750,800
            dw 600,450,500

            dw 550,430,650
            dw 700,650,800
            dw 500,250,400

            dw 350,580,700
            dw 500,780,750
            dw 640,500,550

            dw 250,230,350
            dw 300,300,400
            dw 250,150,200

            dw 150,150,250
            dw 200,200,300
            dw 200,100,100

_bonus_3set dw 550,430,650   ; length of time bonus stays on screen
            dw 700,650,800
            dw 500,250,400

            dw 350,370,550
            dw 500,650,600
            dw 350,200,300

            dw 250,230,350
            dw 300,300,400
            dw 250,150,200

            dw 200,200,300
            dw 250,250,350
            dw 200,100,150

            dw 100,100,100
            dw 100,100,100
            dw 100,100,75

_bonus_vset dw 700,1400,0    ; health value of bonuses
            dw 0,0,2100
            dw 1400,0,0

            dw 700,1400,0
            dw 0,0,1400
            dw 700,0,0

            dw 350,700,0
            dw 0,0,700
            dw 700,0,0

            dw 210,420,0
            dw 0,0,420
            dw 420,0,0

            dw 70,140,0
            dw 0,0,350
            dw 350,0,0

_score_set  dd 200,400,250,750,1000,1500,1500,2000,1000
            dd 100,200,400
            dd 1,20,50,15
            dd 1000,2000
            dd 1000

            dd 100,200,150,350,500,750,750,1000,500
            dd 50,100,200
            dd 1,10,25,5
            dd 500,1000
            dd 1500

; bonus probability tables, first byte is logical mask

 if registered eq yes

_selections db 0,0                                 ; 0
            db 1,0,1                               ; 1
            db 1,0,2                               ; 2
            db 3,0,0,1,2                           ; 3
            db 7,0,0,0,1,2,2,2,3                   ; 4
            db 7,0,0,1,1,2,2,3,3                   ; 5
            db 15,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,4  ; 6
            db 15,0,0,0,0,1,1,1,2,2,2,3,3,3,4,4,4  ; 7
            db 15,0,0,0,0,1,1,2,2,2,3,3,4,4,4,4,6  ; 8
            db 15,0,0,0,1,1,2,2,2,3,3,4,4,4,6,6,6  ; 9
            db 15,0,0,0,1,1,2,2,2,3,3,4,4,6,6,6,7  ; 10
            db 15,0,0,0,1,1,2,2,2,3,3,4,4,6,6,7,7  ; 11
            db 7,2,2,2,2,2,2,0,1                   ; 12
            db 7,3,3,3,3,3,3,0,1                   ; 13
            db 7,4,4,4,4,4,4,0,1                   ; 14
            db 7,6,6,6,6,6,6,0,1                   ; 15

 elseif registered eq no

_selections db 0,0                                 ; 0
            db 1,0,1                               ; 1
            db 1,0,2                               ; 2
            db 3,0,0,1,2                           ; 3
            db 7,0,0,0,1,2,2,2,2                   ; 4
            db 7,0,0,1,1,2,2,1,0                   ; 5
            db 15,0,0,0,0,1,1,1,1,2,2,2,2,2,1,2,1  ; 6
            db 15,0,0,0,0,1,1,1,2,2,2,2,1,0,2,1,0  ; 7
            db 15,0,0,0,0,1,1,2,2,2,2,1,0,2,1,0,1  ; 8
            db 15,0,0,0,1,1,2,2,2,2,2,1,0,2,1,0,1  ; 9
            db 15,0,0,0,1,1,2,2,2,2,1,0,2,1,0,2,1  ; 10
            db 15,0,0,0,1,1,2,2,2,2,1,0,2,1,0,2,1  ; 11
            db 7,2,2,2,2,2,2,0,1                   ; 12
            db 7,1,1,1,1,1,1,0,1                   ; 13
            db 7,0,0,0,0,0,0,0,1                   ; 14
            db 7,1,2,1,0,2,1,0,1                   ; 15
 endif

_level_tables:
 include levels.inc
_level_end:

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Start/Stop game (between main menu and operational game)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_start_game:
         call _init_game
         call _init_always
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Stop Game
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_stop_game:
         call _uninit_game
         call _uninit_always
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Reset Blue Colour
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_reset_blue:
          if registered eq yes or crack eq yes
         pushw 3
         pushw 22
         pushw 0
         pushw 0
         call _set_dac_register
          endif
          if registered eq no
         pushw 1
         pushw 0
         pushw 0
         pushw 20
         call _set_dac_register
          endif
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Draw icons according to table at EAX
; eg dw x,y,icon #
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_menu_icons:
         mov bl,_diff_index
         mov _diff_index+1,bl
         mov bx,[eax]
         cmp bx,-1
         je _ret
         mov cx,[eax+2]
         movzx edx,word ptr [eax+4]
         push eax
         push dword ptr _texttables[edx*4]
         push bx
         push cx
         call _tdraw_bitmap
         pop eax
         add eax,6
         jmp _menu_icons

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Main selection menu
;
;   AACHIEVE   0
;   ABLICK     1
;   ABLOCK     2
;   ACOLON     3
;   ACONTROL   4
;   ADEMO      5
;   AEFFECTS   6
;   AGAME      7
;   AGRIP      8
;   AHIGHS     9
;   AHOW      10
;   AINVERSE  11
;   AJOY      12
;   AKEY      13
;   AMOUSE    14
;   AMUSIC    15
;   ANEW      16
;   ANORMAL   17
;   AOPTIONS  18
;   AQUIT     19
;   ASPEED    20
;   AROTATE   21
;   ASLIDE    22
;   ATHRUST   23
;   ATYPE     24
;   AVOLUME   25
;   AWARP2L   26
;   AOVER     27
;   APAUSE    28
;   AS        29
;   AENDE     30
;   ATAST     31
;   AMAUS     32
;   AMUSIK    33
;   AFLIEGE   34
;   ATOP      35
;   ADREH     36
;   AER       37
;   ANEUES    38
;   AGRIFFIG  39
;   ASPIEL    40
;   AEFFEKTE  41
;   ASCHUB    42
;   AGES      43
;   ABEST     44
;   AEINGABE  45
;   AGLEITEN  46
;   AUMGEK    47
;   APATCH1   48   ; punkte
;   APATCH2   49   ; rakete/kanone
;   APATCH3   50   ; schild
;   AEASY     51
;   ASCHNOT   52
;   ALEICHT   53
;   AABROTZ   54
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_show_main_menu:
         mov eax,offset _text_newgame
         jmp _menu_icons

_text_newgame:
         dw 110,070,16   ; New
ger6:
         dw 150,070,7    ; Game
         dw 110,100,18   ; Option (s)
         dw 163,108,29   ;
ger4:
         dw 110,130,10   ; How to Order
ger5:
         dw 110,162,5    ; Demo
         dw 110,190,9    ; High Scores
         dw 110,220,26   ; Warp to Level
ger3:
         dw 110,250,19   ; Quit
ger1:
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Show Options Screen
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_show_options:
         mov eax,_key_scaling
         or eax,eax
         jnl short nasda
         neg eax
         push eax
         xor ebx,ebx
         cmp _language,0
         je short dothisb
         mov ebx,-75
dothisb:
         add ebx,214
         mov ecx,105
         call _compile_xy
         mov edi,_current_page
         add edi,esi
         call _compiled_numbers[21*4]
         pop eax
nasda:
         xor ebx,ebx
         cmp _language,0
         je short dothisa
         mov ebx,-75
dothisa:
         add ebx,244
         mov ecx,92
         mov dl,3
         mov dh,10
         mov ebp,10
         mov esi,12
         call _dropit

         mov edi,offset wumpa
         mov al,_mod_vol
         call _oonta
         mov edi,offset wumpb
         mov al,_sfx_vol
         call _oonta

         movzx eax,_ctrl
         mov al,_ctrltype[eax]
         mov b _ctrol,al

         mov _ctrol-2,58
         cmp al,14
         je short notinv
         cmp al,12
         je short jodf
         cmp _language,1
         je short notinv
jodf:
         mov _ctrol-2,56
notinv:
         movzx eax,_tmethod
         add eax,_language
         add eax,_language
         mov bl,tttables[eax]
         mov b goofy1+2+2,bl

         movsx eax,_inverse_keys
         and eax,1
         add eax,_language
         add eax,_language
         mov bl,xttables[eax]
         mov b goofy2+2+2,bl
         mov bx,xtooffs[eax*2]
         mov w goofy2+2,bx

         mov eax,rtz
         cmp _language,1
         je short fgkjs
         inc eax
fgkjs:
         mov goofy1+2,ax

         mov eax,offset _options_menu
         jmp _menu_icons
_oonta:
         mov bl,2
         xor ecx,ecx
         xor edx,edx
moer2:
         cmp al,cl
         ja short not2
         mov bl,1
not2:
         mov [edx+edi],bl
         inc ecx
         add edx,6
         cmp ecx,15
         jne short moer2
         ret

tttables db 8,22,39,46
xttables db 17,11,17,47
xtooffs  dw rtu+0,rtu+3,rtu+0,rtu+0

_ctrltype db 13,12,14      ; key, joy, mouse

_options_menu:
         dw 70,055,4       ; Controller Type
ger22:
         dw 197,065,3      ; ":"
ger26:
         dw 204,56
_ctrol   dw 12

         dw 70,90,4        ; Controller speed
ger23:
         dw 208,100,3      ; ":"

         rtx =  123
         dw 70,rtx,15      ; Music
ger8:
         dw 122,rtx,25     ; Volume
         dw 186,rtx+10,3
          dw 70 ,rtx+31
wumpa     dw 1
          dw 81 ,rtx+31,1
          dw 92 ,rtx+31,1
          dw 103,rtx+31,1
          dw 114,rtx+31,1
          dw 125,rtx+31,1
          dw 136,rtx+31,1
          dw 147,rtx+31,1
          dw 158,rtx+31,1
          dw 169,rtx+31,1
          dw 180,rtx+31,1
          dw 191,rtx+31,1
          dw 202,rtx+31,1
          dw 213,rtx+31,1
          dw 224,rtx+31,1

         rty = 176
         dw 70,rty,6       ; Effects
ger9:
         dw 128,rty,25     ; Volume
         dw 192,rty+10,3
          dw 70 ,rty+31
wumpb     dw 1
          dw 81 ,rty+31,1
          dw 92 ,rty+31,1
          dw 103,rty+31,1
          dw 114,rty+31,1
          dw 125,rty+31,1
          dw 136,rty+31,1
          dw 147,rty+31,1
          dw 158,rty+31,1
          dw 169,rty+31,1
          dw 180,rty+31,1
          dw 191,rty+31,1
          dw 202,rty+31,1
          dw 213,rty+31,1
          dw 224,rty+31,1

         rtu = 229
         dw 70,rtu,21      ; Rotation
ger25:
         dw 185,rtu+10,3
goofy2   dw 193,rtu,17     ; 17 or 11 (Normal or Inverse)

         rtz = 262
         dw 70,rtz,23      ; Thrust
ger24:
         dw 170,rtz+10,3
goofy1   dw 178,rtz+1,22   ; 22 or 8 (Sliding or Gripping)

ger21:
         dw 157,058,24     ; Type
         dw 145,rtu+2,24   ; Type
         dw 130,rtz+2,24   ; Type
         dw 157,90,20      ; Speed
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Ask user for "Warp to Level?"
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_yposofwarp dd 0

_show_warp:
         mov eax,offset _warp_text
         call _menu_icons

         movzx eax,_warp_level
         mov ebx,225+25
         call donumthingy
         movzx eax,_highest_level
         mov ebx,135+25

donumthingy:
         mov _yposofwarp,ebx
         call _cv32
         mov ebx,eax
         shr bl,4
         and ebx,0fh
         and eax,0fh
         push eax
         push ebx
         mov ebx,148
         mov ecx,_yposofwarp
         call _compile_xy
         mov edi,_current_page
         add edi,esi
         pop ebp
         call _compiled_numbers[10*4+ebp*4]
         mov ebx,160
         mov ecx,_yposofwarp
         call _compile_xy
         mov edi,_current_page
         add edi,esi
         pop ebp
         jmp _compiled_numbers[10*4+ebp*4]

_warp_text:
         dw 64,99+25,0        ; highest level achieved
ger10:
         dw 255,108+25,3      ; :
         dw 99,189+25,26      ; warp to level
ger7:
         dw 218,198+25,3
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Show "Game Over" at screen top
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_show_game_over:
         cmp _gameoversay,-1
         je short flashit
         test _gameoversay,20h
         jz _ret
flashit:
         mov eax,offset _game_over
         jmp _menu_icons

_game_over:
         dw 113,140,7
ger27:
         dw 166,140,27
ger2:
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Show "Demo" at screen top
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_show_demo:
         test _irq_tracespast,0200h
         jnz _display_high_scores

         mov eax,offset _demo_text
         jmp _menu_icons

_demo_text:
         dw 137,50,5
         dw -1

_icon_indexers db 0
               db 0
               db 0
_main_index    db 0
_options_index db 0
_warp_index    db 0
               db 0
_high_index    db 0
_edit_index    db 0
               db 0
_diff_index    db 1
               db 1

_icon_offsets dd o _nullit
              dd o _nullit
              dd o _nullit
              dd o _main_icons
              dd o _options_icons
              dd o _warp_icons
              dd o _nullit
              dd o _high_score_locations
              dd o _edit_locations
              dd o _nullit
              dd o _ask_locations
              dd o _ask_locations

_ask_locations dw 95,160      ; Easy
               dw 95,190      ; Normal
               dw 95,223      ; Schnotter

 i = 3
 j = 30

_edit_locations:
   dw 55,50+00*i-j-10
   dw 55,60+01*i-j-10
   dw 55,70+02*i-j-10
   dw 55,80+03*i-j-10
   dw 55,90+04*i-j-10
   dw 55,100+05*i-j-10
   dw 55,110+06*i-j-10
   dw 55,120+07*i-j-10
   dw 55,130+08*i-j-10
   dw 55,140+09*i-j-10
   dw 55,150+10*i-j-10
   dw 55,160+11*i-j-10
   dw 55,170+12*i-j-10
   dw 55,180+13*i-j-10
   dw 55,190+14*i-j-10
   dw 55,200+15*i-j-10
   dw 55,210+16*i-j-10
   dw 55,220+17*i-j-10
   dw 55,230+18*i-j-10
   dw 55,240+19*i-j-10
   dw 55,250+20*i-j-10
   dw 55,260+21*i-j-10

_nullit     dw 0,0

_main_icons dw 85,070      ; New
            dw 85,100      ; Options
            dw 85,130      ; How to Order
            dw 85,162      ; Demo
            dw 85,190      ; High Scores
            dw 85,220      ; Warp to Level
            dw 85,250      ; Quit

_options_icons dw 45,55
               dw 45,90
               dw 45,rtx
               dw 45,rty
               dw 45,rtu
               dw 45,rtz

_high_score_locations:
               dw 15,0
               dw 15,0
               dw 15,0
               dw 15,0
               dw 15,0
               dw 15,0
               dw 15,0
               dw 15,0
               dw 15,0
               dw 15,0
               dw 0,0

_warp_icons  dw 123,225+25

_menu_things dd o _ret                 ; 0
             dd o _show_game_over      ; 1
             dd o _show_demo           ; 2
             dd o _show_main_menu      ; 3
             dd o _show_options        ; 4
             dd o _show_warp           ; 5
             dd o _display_high_scores ; 6
             dd o _new_high_score      ; 7
             dd o _level_editor        ; 8
             dd o _how_to_order        ; 9
             dd o _show_difficulty     ; 10
             dd o _show_difficulty_warp; 11

_xicon dw 0
_yicon dw 0
_icont dw 0
_ox    dw 0
_yx    db 0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make cursor a rotating asteroid
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

zapox:
         mov _ox,0
         inc _yx
         ret

_handle_rotating_menu_icon:
         cmp _menu_item,2
         jbe short zapox

         movzx eax,_menu_item
         mov edx,_icon_offsets[eax*4]
         movzx ebx,_icon_indexers[eax]
         mov word ptr ax,[edx+ebx*4]
         mov word ptr bx,[edx+ebx*4+2]
         or ax,ax
         je short zapox
         mov _xicon,ax
         sub bx,2
         mov _yicon,bx

         cmp _ox,0
         jne short selnewof
againrndtyp2:
         call _rnd
         and eax,7
          if registered eq yes
         cmp al,5
          elseif registered eq no
         cmp al,4
          endif
         jge short againrndtyp2
         imul eax,48
         add ax,48
         mov _ox,ax
selnewof:
         mov eax,_irq_tracespast
         mov ebx,48
         test _yx,1
         jne short notnegux
         cdq
         idiv ebx
         neg dx
         add dx,47
         jmp short nofdsaf
notnegux:
         cdq
         idiv ebx
nofdsaf:
         add dx,_ox
         mov eax, _bitbase[edx*4]
         mov _bitmap,eax

         mov eax,_xreftable[31*4]
         mov dword ptr [_xref1],eax
         mov dword ptr [_xref2],eax
         mov _scale_destwidth,20
         mov _scale_destheight,32
         mov ax,_xicon
         mov bx,_yicon
         mov _scale_destx,ax
         mov _scale_desty,bx
         jmp _xscale2

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Wipe all asteroids from scene
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_wipe_field:
         mov esi,maxobjects+1
notrta:
         call _init_object
         dec esi
         cmp esi,-1
         jne short notrta

         call _in_transit
         jmp _reset_nme

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Say Pause
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_menu_pause:
         mov eax,offset _pause_text
         jmp _menu_icons

_pause_text:
         dw 137,10,28
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Display High Scores
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_new_high_score:
         mov eax,offset _new_high_text
         call _menu_icons
         jmp short noold

_display_high_scores:
         mov eax,offset _high_text
         call _menu_icons
noold:
         mov ecx,offset _names
         mov esi,0
morenames:
         push esi ecx
         push ecx
         pushw 180
         pushw 40
         lea eax,[esi*8+esi]
         lea eax,[esi*8+eax+120+14]
         push ax
         pushw 255
         call _tprint_str
         pop ecx esi
         add ecx,26
         mov eax,[ecx]
         push esi ecx
         mov ebx,270
         xor ebp,ebp
         lea edx,[esi*8+esi]
         lea ecx,[esi*8+edx+117+14]
         mov word ptr _high_score_locations[esi*4+2],cx
         sub word ptr _high_score_locations[esi*4+2],7
         mov esi,12
         mov dx,0707h
         call _dropit
         pop ecx esi
         inc esi
         add ecx,4
         cmp esi,10
         jne short morenames

         ret

_high_text:
         dw 112,50,9
         dw 197,59,29
         dw -1

_new_high_text:
         dw 99,53,16
         dw 139,50,9
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Check if high score should be inserted into list
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_check_score:
         mov edx,10
         mov ebx,_player_score
         mov eax,30*10
_csloop:
         cmp ebx,dword ptr [_names+eax-4]
         jle short donecheck

         cmp edx,10
         je short nomoe
         mov ecx,30
         lea edi,[eax+_names]
         lea esi,[eax+_names-30]
         rep movsb
nomoe:
         dec edx
         mov ecx,25
         push eax
         lea edi,[eax+_names-30]
         mov al," "
         rep stosb
         xor al,al
         stosb
         mov eax,ebx
         stosd
         pop eax
         sub eax,30
         mov _hscore,eax
         cmp _what_level,0
         jne short nodemohhigh
         mov dword ptr _names[eax],"omeD"
nodemohhigh:
         or dl,dl
         jnz short _csloop

donecheck:
         mov _high_index,dl
         mov _cursorx,0
         mov _under," "
         mov _chrtime,0
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Cheapo Level Editor
;
; Each Level = 48 bytes long
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_level_editor:
if debug eq yes
         mov edi,offset rb
         movzx eax,_what_level
         push eax
         call _write_byte
         pop eax

         imul eax,48
         lea esi,[eax+offset _level_tables]
         mov ebp,offset write_tables
writels:
         mov edi,[ebp]
         cmp edi,-1
         je short blabawasy
         mov eax,[ebp+4]
         mov eax,[eax+esi]
         mov ecx,[ebp+8]
         call dword ptr [_write_type+ecx*4]
         add ebp,12
         jmp short writels

blabawasy:
         mov esi,offset _level_text
         call _write_text
         ret

write_tables:
         dd offset rc,  0, 0  ; db  _ammo_v
         dd offset rd,  1, 0  ; db  _scores_v
         dd offset re,  2, 0  ; dw  _min_asteroids
         dd offset rf,  4, 1  ; dw  _must_destroy
         dd offset rg,  6, 1  ; dw  _bonus_stat
         dd offset rh,  8, 0  ; db  _bonus_p
         dd offset ri,  9, 0  ; db  _bonus_t
         dd offset rj, 10, 0  ; db  _bonus_v
         dd offset rk, 11, 1  ; dw  _statsq
         dd offset rl, 13, 1  ; dw  _statsw
         dd offset rm, 15, 1  ; dw  _skill
         dd offset rn, 17, 1  ; dd  _nme_speed
         dd offset ro, 21, 0  ; db  _nme_sup
         dd offset rp, 22, 1  ; dw  _original_nme_t1
         dd offset rq, 24, 1  ; dw  _nme_t2
         dd offset rr, 26, 0  ; db  _nme_max
         dd offset rs, 27, 0  ; db  _nme_on
         dd offset rt, 28, 1  ; dd  _hyperspeed
         dd offset ru, 32, 1  ; dw  _hyperlen
         dd offset rv, 34, 1  ; dd  _hurt_fraction
         dd offset rw, 38, 0  ; dd  _curentmod
         dd -1

_write_type:
         dd offset _write_byte
         dd offset _write_word

_level_text:
ra db 255,80,0
   dw 50+00*i-j
         db "Level"
         db 255,200,0
         dw 50+00*i-j
         db ":000"
rb db 255,80,0
   dw 60+01*i-j
         db "Ammo V"
         db 255,200,0
         dw 60+01*i-j
         db ":000"
rc db 255,80,0
   dw 70+02*i-j
         db "Scores V"
         db 255,200,0
         dw 70+02*i-j
         db ":000"
rd db 255,80,0
   dw 80+03*i-j
         db "Min Asteroids"
         db 255,200,0
         dw 80+03*i-j
         db ":000"
re db 255,80,0
   dw 90+04*i-j
         db "Must Destroy"
         db 255,200,0
         dw 90+04*i-j
         db ":00000"
rf db 255,80,0
   dw 100+05*i-j
         db "Bonus Probability"
         db 255,200,0
         dw 100+05*i-j
         db ":00000"
rg db 255,80,0
   dw 110+06*i-j
         db "Bonus P"
         db 255,200,0
         dw 110+06*i-j
         db ":000"
rh db 255,80,0
   dw 120+07*i-j
         db "Bonus T"
         db 255,200,0
         dw 120+07*i-j
         db ":000"
ri db 255,80,0
   dw 130+08*i-j
         db "Bonus V"
         db 255,200,0
         dw 130+08*i-j
         db ":000"
rj db 255,80,0
   dw 140+09*i-j
         db "Nme 1/2 lo2"
         db 255,200,0
         dw 140+09*i-j
         db ":00000"
rk db 255,80,0
   dw 150+10*i-j
         db "Nme m/s lom"
         db 255,200,0
         dw 150+10*i-j
         db ":00000"
rl db 255,80,0
   dw 160+11*i-j
         db "Nme Skill"
         db 255,200,0
         dw 160+11*i-j
         db ":00000"
rm db 255,80,0
   dw 170+12*i-j
         db "Nme Speed"
         db 255,200,0
         dw 170+12*i-j
         db ":00000"
rn db 255,80,0
   dw 180+13*i-j
         db "Nme Sup"
         db 255,200,0
         dw 180+13*i-j
         db ":000"
ro db 255,80,0
   dw 190+14*i-j
         db "Nme T1"
         db 255,200,0
         dw 190+14*i-j
         db ":00000"
rp db 255,80,0
   dw 200+15*i-j
         db "Nme T2"
         db 255,200,0
         dw 200+15*i-j
         db ":00000"
rq db 255,80,0
   dw 210+16*i-j
         db "Nme Max"
         db 255,200,0
         dw 210+16*i-j
         db ":000"
rr db 255,80,0
   dw 220+17*i-j
         db "Nme On"
         db 255,200,0
         dw 220+17*i-j
         db ":000"
rs db 255,80,0
   dw 230+18*i-j
         db "Hyperspeed"
         db 255,200,0
         dw 230+18*i-j
         db ":00000"
rt db 255,80,0
   dw 240+19*i-j
         db "Hyperlen"
         db 255,200,0
         dw 240+19*i-j
         db ":00000"
ru db 255,80,0
   dw 250+20*i-j
         db "Hurt Fraction"
         db 255,200,0
         dw 250+20*i-j
         db ":00000"
rv db 255,80,0
   dw 260+21*i-j
         db "MOD"
         db 255,200,0
         dw 260+21*i-j
         db ":000"
rw:
         db 0

_write_byte:
         sub edi,3
         movzx eax,al
         call _fix_number
         mov [edi+1],ax
         mov [edi+0],bh
         ret

_write_word:
         sub edi,5
         movzx eax,ax
         call _fix_number
         mov [edi+3],ax
         mov [edi+1],bx
         mov [edi+0],cl
         ret

_fix_number:
         call _cv32
         mov ecx,eax
         movzx ebx,ah
         movzx eax,al
         shl eax,4
         shr al,4
         add ax,"00"
         shl ebx,4
         shr bl,4
         add bx,"00"
         shr ecx,12
         movzx ecx,cl
         shr cl,4
         add cx,"00"
         xchg al,ah
         xchg bl,bh
endif
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Display how to order screen
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_how_to_order:
         call _display_how_to_order
         mov eax,offset _how_order
         jmp _menu_icons

_how_order dw 105,68,10   ; How to Order
           dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Reset all menus according to german or english
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_reset_language:
         mov edx,_language
         mov esi,offset _gerstart
gerloop:
         mov eax,[esi]
         cmp eax,-1
         je _ret

         mov bl,[esi+4+edx]
         mov [eax],bl
         add esi,6
         jmp gerloop

_gerstart dd offset ger1-2
          db 19,30
          dd offset ger2-2
          db 27,30
          dd offset ger3-2
          db 26,34
          dd offset ger4-2
          db 29,37
          dd offset ger4-4
          db 108,109
          dd offset ger5-2
          db 10,44
          dd offset ger6-2
          db 16,38
          dd offset ger6+0
          db 150,165
          dd offset ger6+2
          db 70,67
          dd offset ger6+4
          db 7,40
          dd offset _how_order
          db 105,123
          dd offset _how_order+4
          db 10,44
          dd offset ger7-2
          db 26,34
          dd offset ger7-6
          db 99,89
          dd offset ger7
          db 218,231
          dd offset ger8-2
          db 15,33
          dd offset ger9-2
          db 6,41
          dd offset _ctrltype
          db 13,31
          dd offset _ctrltype+2
          db 14,32
          dd offset ger10-2
          db 0,35
          dd offset ger10-6
          db 64,89
          dd offset ger10
          db 255,231
          dd offset ger21
          db 157,-1
          dd offset ger21+1
          db 0,-1
          dd offset ger22-2
          db 4,45
          dd offset ger23-2
          db 4,43
          dd offset ger24-2
          db 23,42
          dd offset ger25-2
          db 21,36
          dd offset ger22
          db 197,138
          dd offset ger23
          db 208,133
          dd offset ger24
          db 170,119
          dd offset ger25
          db 185,109
          dd offset ger26
          db 204,145
          dd offset goofy1
          db 178,127
          dd offset goofy2
          db 193,117
          dd offset ger27-2
          db 7,40
          dd offset _game_over
          db 113,120
          dd offset ger27
          db 166,159
          dd offset ger46+4
          db 7,40
          dd offset ger48+4
          db 51,53
          dd offset ger50+4
          db 51,53
          dd offset ger49+4
          db 52,54
          dd offset ger51+4
          db 52,54
          dd offset ger46-2
          db 16,38
          dd offset ger46+2
          db 100,98
          dd offset ger48+2
          db 160,158
          dd offset ger50+2
          db 160,158
          dd offset ger46
          db 150,157
          dd offset _text_difficulty
          db 110,105
          dd offset ger52
          db 218,231
          dd offset ger52-6
          db 99,89
          dd offset ger52-2
          db 26,34

          dd -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Display appropriate HOW TO ORDER screen
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_display_how_to_order:
         mov edx,_language
         mov edi,_order_text[edx*4]
_clo:
         mov ax,[edi]
         shl eax,16
         mov ax,[edi+2]
         add edi,4
         push edi edi
         mov cx,300
         push cx
         push eax
         pushw 255
         call _tprint_str
         pop edi
         mov ecx,3000
         xor al,al
         repnz scasb
         mov al,[edi]
         cmp al,-1
         jne short _clo
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Show/Ask for difficulty level before new game
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_show_difficulty:
         mov eax,offset _text_difficulty
         jmp _menu_icons

_text_difficulty:
         dw 110,101,16   ; New
ger46:
         dw 150,100,7    ; Game
ger47:
         dw 198,109,3    ; ":"
ger48:
         dw 120,160,51   ; Easy
         dw 120,190,17   ; Normal
ger49:
         dw 120,223,52   ; Schnotter
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Show/Ask for difficulty level before warp to level
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_show_difficulty_warp:
         mov eax,offset _text_difficulty_warp
         jmp _menu_icons

_text_difficulty_warp:
         dw 99,100,26    ; warp to level
ger52:
         dw 218,109,3    ; ":"
ger50:
         dw 120,160,51   ; Easy
         dw 120,190,17   ; Normal
ger51:
         dw 120,223,52   ; Schnotter
         dw -1

         ends
         end
