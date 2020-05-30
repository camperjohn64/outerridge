;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : Main.asm
; Included from: Main Assembley Module
; Description  : Main demo of 3dvector library
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

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; define externals
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         include pmode.ext                  ; protected mode externals
         include xmode.ext                  ; xmode externals by matt pritchard
         include 3d.ext
         include irq.ext
         include stars.ext
         include file.ext
         include argc.ext
         include joystick.ext
         include fade.ext
         include kb.ext
         include function.ext
         include gus.ext
         include fx.ext
         include game.ext
         include explode.ext
         include loadgif.ext
         include init.ext
         include piccy.ext
         include mod.ext
         include control.ext
         include clear.ext
         include nme.ext
         include piccy.ext
         include c.ext

         include macros.inc
         include equ.inc
         include lang.ext

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; code
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

memtop   dd 0

         public _main
_main:

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         sti
        ;call _init_keyboard
        ;kk:
        ;call _getch
        ;cmp ax,14
        ;je _outs
        ;call _dos_hex32
        ;jmp kk
        ;
_outs:  ;
        ;call _resetkb
        ;jmp _exit
        ;call _exitgame
        ;jmp _exit

         call _check_cfg_save
         jnc _exit
         mov eax,_himembase
         mov memtop,eax
         call _init_dos4gw
         call _init_command_line
         call _say_version
         call _init_wad
         jc _exitbad0
         call _say_memory
         jc _exitbad0
         call _save_order
         jc _exitbad0
         call _init_exe
         jc _exitbad0
         call _load_levels
         call _init_mouse
         call _setup_env                    ; set up file envirionment (eg c:\temp\thisprog.exe )
         call _init_irq
         call _init_keyboard
         call _init_file_buffer
         call _initsound
         jc no_sounds
         call _load_sounds
         jc _exitbad
         call _init_mods
         jc _exitbad
no_sounds:
         call _reset_language
         call _compile_bitmap
         call _load_dash
         jc _exitbad
         call _init_explosions
         jc _exitbad
         call _init_bitmaps
         jc _exitbad
         call _init_dark
         jc _exitbad
         call _init_text_icons
         jc _exitbad
         call _load_tables
         jc _exitbad
         call _init_tables                  ; initialize 3d vector stuff
         call _joy_calibratejoystick
         call _load_title
         call _saybullshit

         cmp _memit,yes
         jne short nosaymemory
         mov eax,memtop
         call _dos_hex32
         mov edx,offset colonch
         call _putdosmsg
         mov eax,_himembase
         call _dos_hex32
         mov edx,offset colonch
         call _putdosmsg
         mov eax,_himembase
         sub eax,memtop
         call _dos_hex32
         mov edx,offset returnch
         call _putdosmsg
         waitesc
nosaymemory:

         call _set_vgacard
         call _wipe_video
         call _multisync_wait

         mov esi,_title_palette
         xor al,al
         mov ecx,768
         call _put_palette

         call _load_mod
         xor eax,eax
         call _wipeoffpalette
         call _joy_calibratejoystick
         mov _activate_controls,yes

         call _fade_to_game
         jmp _dointrot

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; the main loop
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_asteroids_loop:
         call _compiled_cockpit[cb_clear*4]
         call _sub
         call _copy_virtual_objects
         call _setsincose                   ; set rotation multipliers for eye
         call _star_plot                    ; plot background stars
         call _bottom_score
         call _makeobjs                     ; plot all objects in sides table
         call _update_top_text
         call _drop_interior
         movzx eax,_menu_item
         call _menu_things[eax*4]
         cmp _inpause,yes
         jne short notpausedisplay
         call _menu_pause
notpausedisplay:
         call _handle_rotating_menu_icon
         call _show_time
         call _check_picture
         call _flip_page                    ; flip video pages

         xor eax,eax
         mov al,_mode
         jmp [_mainnow+eax*4]

_mainnow dd o _ret
         dd o _restetintro
         dd o _asteroids_loop
         dd o _asteroids_loop
         dd o _doswap
         dd o _getoutnow
         dd o _dointrot
         dd o _lab1
         dd o _newgame
         dd o _newgame

_newgame:
         call _wipe_field
         call _put_dash
         mov al,_selected_level             ; level to start at -1
         dec al
         call _init_new_game
_doswap:
         call _retrig_game
         xor eax,eax
         mov _game_run,yes
         mov _always_run,yes
         mov _mode,_run_game
         mov _godmode,no
         mov _shot,no
         mov _nextgun,al
         mov _guntype,al
         call _retrig_level
         mov ax,_must_destroy
         cmp ax,_has_destroyed
         jae short noghh
         inc ax
         mov _has_destroyed,ax
noghh:
         shr _has_destroyed,1
         call _play_mod
         call _fancy_fade1
         call _start_game
         jmp _asteroids_loop

_inttime dd 0

_dointrot:
         call _stop_game
         call _retrig_thrust
         mov _what_level,0
         mov _currentmod,0
         call _game_intro
         call _fancy_fade1
         call _play_mod
         mov eax,_irq_tracespast
         add eax,450
         mov _inttime,eax
         mov _kbchar,0
         mov _mode,_dointroloop
_lab1:
         call _game_intro
         movzx eax,_menu_item
         cmp al,3
         jb short nomenuitem
         call _menu_things[eax*4]
         call _handle_rotating_menu_icon
nomenuitem:
         call _show_time
         call _check_picture
         call _flip_page
         mov eax,_inttime
         cmp eax,_irq_tracespast
         ja short lab2
         mov _mode,_donewgame
         mov _selected_level,0
         mov _dummy_timer,7300
lab2:
         xor eax,eax
         mov al,_mode
         jmp [_mainnow+eax*4]

_restetintro:
         mov eax,_dummy_timer
         cmp eax,_irq_tracespast
         ja short nintro
         mov _mode,_dointro
nintro:
         jmp _asteroids_loop

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; make endpage screen
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_getoutnow:
         call _resetkb
         call _irq_resetpmirq               ; reset irq vectors
         call _sfx_uninit                   ; done, clear soundcard
         call _save_cfg
         call _exitgame
         jmp _exit

_exitbad:
         call _resetkb
         call _irq_resetpmirq               ; reset irq vectors
         call _sfx_uninit                   ; done, clear soundcard
_exitbad0:
         mov edx,_language
         mov edx,_badfile1[edx*4]
         call _putdosmsg
         jmp _exit

colonch  db ":$"
returnch db 13,10,"$"

code32   ends
         end
