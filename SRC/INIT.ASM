;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Initalization of game
;
; _lomembase
;  file_buffer     4000h
;  DMA (if SB)     1024d
;
; _himembase
;  Sound effect data (if SB)   .snd size
;  Title screen+palette        128772
;  Darken cross referance tbls 4096
;  Explosion bitmaps           110700
;  Dashboard                   128008
;  Mod file                    Current mod size
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

gussize  equ 1723668
sbsize   equ 180000
modsize  equ 200000

versiona  = "1"   ; version #
versionb  = "0"

         .386p
code32   segment para public use32
         assume cs:code32, ds:code32

         include xmode.ext
         include pmode.ext
         include gus.ext
         include fx.ext
         include irq.ext
         include kb.ext
         include file.ext
         include loadgif.ext
         include equ.inc
         include mod.ext
         include clear.ext
         include macros.inc
         include game.ext
         include 3d.ext
         include function.ext
         include control.ext
         include explode.ext
         include xmouse.ext
         include argc.ext
         include nme.ext
         include c.ext
         include lang.ext

         public _putdosmsg
         public _init_wad
         public _init_dos4gw
         public _saybullshit
         public _initsound
         public _init_game
         public _uninit_game
         public _game_run
         public _load_sounds
         public _init_irq
         public _init_file_buffer
         public _init_keyboard
         public _load_title
         public _title_picture
         public _title_palette
         public _wadname
         public _init_mods
         public _say_version
         public _modsok
         public _loaded
         public _load_mod
         public _play_mod
         public _load_dash
         public _sounds
         public _set_vgacard
         public _multisync_wait
         public _compile_bitmap
         public _save_cfg
         public _init_dark
         public _init_explosions
         public _wipe_video
         public _cv32
         public _dos_hex32
         public _dos_ret
         public _dos_string4
         public _mod_vol
         public _sfx_vol
         public _always_run
         public _init_mouse
         public _ctrl
         public _cotr
         public _vmode
         public _init_bitmaps
         public _tmethod
         public _rocketd
         public _sizes
         public _cannons
         public _power
         public _say_memory
         public _init_command_line
         public _compiled_numbers
         public _init_always
         public _uninit_always
         public _exitgame
         public _compiled_cockpit
         public _cockpit_control
         public _inverse_keys
         public _memit
         public _gundash
         public _highest_level
         public _check_cfg_save
         public _text
         public _init_text_icons
         public _texttables
         public _order
         public _vc32
         public _names
         public _save_order
         public _load_levels
         public _save_levels
         public _language
         public _load_tables

         public _mouse_shotmask
         public _mouse_thrmask
         public _mouse_chgmask
         public _kb_up
         public _kb_down
         public _kb_l
         public _kb_r
         public _kb_thr
         public _kb_fire
         public _kb_chg
         public _joy_shotmask
         public _joy_thrmask
         public _joy_chgmask
         public _key_scaling
         public _restart_mask_k
         public _restart_mask_j
         public _restart_mask_m
         public _init_exe

         public _cardtype
         public _cardirq
         public _cardport

_vmode   db xmode
_wadname db "OUTRIDGE.WAD",0,70 dup(0)
_oldname db "OUTRIDGE.WAD",0
_initnam db "OUTRIDGE.CFG",0
_modsok  db -1
_loaded  db -1
_sounds  db -1
_memit   db no

_compiled_cockpit dd 13 dup (offset _ret)   ; compiled cockpit routines.
_compiled_numbers dd 22 dup (offset _ret)   ; routines for compiled numbers, small and big

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Put message to DOS, EDX => MSG
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_putdosmsg:
         push ax
         push edx
         add edx,_code32a
         mov al,dl
         and ax,0fh
         shr edx,4
         mov v86r_ds,dx
         mov v86r_dx,ax
         mov v86r_ah,9
         mov al,21h
         int 33h
         pop edx
         pop ax
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make DOS4GW look-alike header
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_dos4gw:
         call _mode03
         call _reset_blue

          if registered eq yes
         mov esi,offset topmsg2
          elseif registered eq no
         mov esi,offset topmsg1
          endif
          if crack eq yes
          call _getdate
          jnc short sayfake2
         mov esi,offset topmsg2
sayfake2:
          endif
         mov ecx,78
         rlp edi,0b8000h
         rep movsw

         mov edx,offset returnch
         call _putdosmsg

         ret

returnch db 13,10,"$"

          if registered eq no
bv = 1fh
topmsg1  db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv                          ; Outer Ridge 3D: Beta
         db " ",bv
         db "O",bv
         db "u",bv
         db "t",bv
         db "e",bv
         db "r",bv
         db " ",bv
         db "R",bv
         db "i",bv
         db "d",bv
         db "g",bv
         db "e",bv
         db ":",bv
         db " ",bv                          ; middle
         db "V",bv
         db versiona,bv
         db ".",bv
         db versionb,bv
         db " ",bv
         db "S",bv
         db "h",bv
         db "a",bv
         db "r",bv
         db "e",bv
         db "w",bv
         db "a",bv
         db "r",bv
         db "e",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv

          endif
          if registered eq yes or crack eq yes
bv = 3fh
topmsg2  db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv                          ; Outer Ridge 3D: Registered
         db " ",bv
         db "O",bv
         db "u",bv
         db "t",bv
         db "e",bv
         db "r",bv
         db " ",bv
         db "R",bv
         db "i",bv
         db "d",bv
         db "g",bv
         db "e",bv
         db ":",bv
         db " ",bv
         db "V",bv
         db versiona,bv
         db ".",bv
         db versionb,bv
         db " ",bv
         db "R",bv
         db "e",bv
         db "g",bv
         db "i",bv
         db "s",bv
         db "t",bv
         db "e",bv
         db "r",bv
         db "e",bv
         db "d",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
         db " ",bv
          endif

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Make user wonder....
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_saybullshit:
         mov edx,o init_message
         call _putdosmsg

         ret

init_message:
         db "Error: Bullshit Overflow",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Init sound
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_initsound:
         mov edx,offset sound_msg0
         call _putdosmsg

         mov _sounds,-1
         mov _modsok,-1

         cmp _sfxtype,0
         je no_sound

         mov al,_sbirq
         add al,"0"
         mov _saysbirq,al
         mov ax,_sbport
         shr al,4
         add al,"0"
         mov _saysbprt,al

         mov al,_gusirq
         cmp al,10
         jb short notirq10a
         sub al,10
         mov _saygusirq,"1"
notirq10a:
         add al,"0"
         mov _saygusirq+1,al
         mov ax,_gusport
         shr al,4
         add al,"0"
         mov _saygusprt,al

         mov edx,_lomembase                 ; DMA buffer        * ALL this data is ignored *
         mov ebx, 768                       ; DMA buffer size   *  if the user has a GUS   *
         mov ecx, 22000                     ; sample rate
         mov eax,_himembase
         call _sfx_init                     ; call this for both soundcards (SB and GUS)
         imul ebx,sbsize+modsize            ; bytes of sample memory required (0 if GUS)
         add _lomembase,eax                 ; bump up low memory because of DMA (0 if GUS)
         add _himembase,ebx                 ; bump up hi memory because of samples required (0 if GUS)

         mov al,_sfx_vol
         mov _mix_volume[4],al
         mov _mix_volume[5],al
         mov _mix_volume[6],al
         mov _mix_volume[7],al
         mov _mix_volume[8],al
         mov _mix_volume[9],al
         mov _mix_volume[10],al
         mov _mix_volume[11],al

         xor eax,eax
         mov al,_sfxtype
         mov edx,msgoff[eax*4]
         call _putdosmsg
         clc
         ret
no_sound:
         mov edx,offset sound_msg1
         call _putdosmsg
         stc
         ret

msgoff   dd offset sound_msg1
         dd offset sound_msg2
         dd offset sound_msg3

sound_msg0 db "_Init_Sound: $"
sound_msg1 db "No Sound",13,10,"$"
sound_msg2 db "Gravis Ultrasound, IRQ: "
_saygusirq db " 0, Port: 2"
_saygusprt db "20",13,10,"$"
sound_msg3 db "Sound Blaster, IRQ: "
_saysbirq  db "0, Port: 2"
_saysbprt  db "20",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load sounds from disk
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_load_sounds:
         mov _sounds,-1
         cmp _sfxtype,0
         je _ret

         mov edx,offset load_msg0
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov edi,offset _samlist
         mov edx,_lomembase
          if registered eq yes
         mov ecx,17                         ; number of sound effects to load
          elseif registered eq no
         mov ecx,17
          endif
         mov eax,offset _sfxcomplist
         call _load_lib
         pushf
         call _closefile
         popf
         jc badshit

         mov _sounds,0

         mov edx,offset init_ok
         jmp _putdosmsg

load_msg0 db "_Load_Sounds: $"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Initialize timer IRQ
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_irq:
         mov edx,offset init_msgirq
         call _putdosmsg

         call _irq_setpmirq                 ; set irq running - must be done at start for palette fading
         mov ax, 23684                      ; 1193180/(50 frames a second)
         call _irq_set_timer

         call _irq_findcontrol
         mov _irqcontrol[ecx*4],o _always
         ret

init_msgirq db "_Init_IRQ:",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; File_buffer_init:
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_file_buffer:
         mov eax,_lomembase
         mov _filebufloc,eax
         mov _filebuflen,4000h
         add _lomembase,4000h
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Initalize Keyboard
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_keyboard:
         mov edx,offset init_key
         call _putdosmsg

         jmp _initkb

init_key db "_Init_Keyboard:",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load title
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_load_title:
         mov _title_picture,0
         mov _title_palette,0

         mov edx,offset load_title
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         mov edx,_language
         mov edx,_badwad[edx*4]
         jc _putdosmsg

         mov eax,_title
         xor bl,bl
         call _lseekfile
         mov edx,_language
         mov edx,_badwad[edx*4]
         jc _putdosmsg

         mov edx,_lomembase
         mov eax,offset _readfile
         mov ecx,edx
         add ecx,128772
         call _loadgif                      ; file remains open and is decoded from disk
         mov eax,edx
         mov edx,_language
         mov edx,_badwad[edx*4]
         jc _putdosmsg
         mov _title_picture,eax
         mov _title_palette,ebx
         mov [ebx+2],01000000h

         add _lomembase,128772
         call _closefile

         mov edx,offset init_ok
         jmp _putdosmsg

_title_picture dd 0
_title_palette dd 0

load_title db "_Load_Title: $"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Mod Init
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_mods:
         call _mod_init

         mov _modsok,-1
         mov edx,offset init_mods
         call _putdosmsg

         mov eax,dword ptr _mod_off
         or eax,dword ptr _mod_off+4
         or eax,dword ptr _mod_off+8
         jz badshit

         cmp _sfxtype,1
         jne short im_l
         cmp _sfxram,262144-1
         mov edx,_language
         mov edx,_nomemmod[edx*4]
         jb _putdosmsg
im_l:
         mov al,_mod_vol
         mov _mix_volume[0],al
         mov _mix_volume[1],al
         mov _mix_volume[2],al
         mov _mix_volume[3],al

         mov _modsok,0
         mov edx,offset init_ok
         jmp _putdosmsg

init_mods db "_Init_Mods: $"
init_ok  db "Ok",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Say version type
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_say_version:

if       registered eq yes
         mov edx,offset versionx
         jmp _putdosmsg

versionx db "_Say_Version:",13,10
         db "==============================================================================",13,10
         db "                   This is NOT SHAREWARE, do not distribute!",13,10
         db "            Please report software piracy to the SPA: 1-800-388-PIR8",13,10
         db "==============================================================================",13,10
         db "               Dies ist KEINE SHAREWARE! NICHT WEITERKOPIEREN!",13,10
         db "                        Bitte melden Sie Raubkopieen!",13,10
         db "==============================================================================",13,10
         db "$"
endif

if       registered eq no and crack eq yes
         call _getdate
         jc short sayfake
         mov edx,offset versionx
         jmp _putdosmsg
sayfake:
         mov edx,offset versionq
         jmp _putdosmsg

versionq db "_Say_Version:",13,10
         db "==============================================================================",13,10
         db "                   This is NOT SHAREWARE, do not distribute!",13,10
         db "            Please report software piracy to the SPA: 1-800-388-PIR8",13,10
         db "==============================================================================",13,10
         db "               Dies ist KEINE SHAREWARE! NICHT WEITERKOPIEREN!",13,10
         db "                        Bitte melden Sie Raubkopieen!",13,10
         db "==============================================================================",13,10
         db "$"
versionx db "_Say_Version:",13,10
         db "==============================================================================",13,10
         db "                 This version is SHAREWARE, please distribute!",13,10
         db "                To order, complete and send the ORDER.DOC file",13,10
         db "==============================================================================",13,10
         db "                 Dies ist Shareware. Bitte weiterkolpieren!",13,10
         db "            Bitte lesen SIE die Datein BESTELL.TXT zum Bestellen!",13,10
;        db 13,10
;        db "       Wouldn't the REGISTERED version make a great CHRISTMAS PRESENT?",13,10
         db "==============================================================================",13,10
         db "$"
endif

if       registered eq no and crack eq no

         mov edx,offset versionx
         jmp _putdosmsg

versionx db "_Say_Version:",13,10
         db "==============================================================================",13,10
         db "                 This version is SHAREWARE, please distribute!",13,10
         db "                To order, complete and send the ORDER.DOC file",13,10
         db "==============================================================================",13,10
         db "                 Dies ist Shareware. Bitte weiterkolpieren!",13,10
         db "            Bitte lesen SIe die Datein BESTELL.TXT zum Bestellen!",13,10
         db "==============================================================================",13,10
         db "$"
endif

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load next mod file
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

loadedmod   db -1

_load_mod:
         cmp _sfxtype,0
         je _ret

         cmp _what_level,18
         jbe short norandommod
         in al,64
         mov _currentmod,al

norandommod:
         mov al,_currentmod
againcheck:
         cmp al,_maxmods
         jb short oksizemod
         sub al,_maxmods
         jmp short againcheck
oksizemod:
         mov _currentmod,al

         cmp al,loadedmod
         je _ret
         mov loadedmod,al

         mov _loaded,-1
         cmp _modsok,-1
         je _ret

         mov al,_activate_controls
         push ax
         mov _activate_controls,no

         movzx eax,_currentmod
         push eax eax
         mov edx,offset _wadname
         call _openfile

         pop eax
         xor bl,bl
         mov eax,_mod_off[eax*8]
         call _lseekfile

         pop eax
         mov ecx,_lomembase
         mov edx,_himembase
         mov eax,offset _readfile
         call _loadgif_lzw
         jc short mod_error

         mov _fakeloc,edx
         add edx,215000
         mov eax,offset fakeread
         call _mod_load
         jc short mod_error
         sub _sfxmem,ebx

         call _closefile

         pop ax
         mov _activate_controls,al
         mov _loaded,0
         clc
         ret

_fakeloc dd 0

fakeread:
         pushad
         mov edi,edx
         mov esi,_fakeloc
         rep movsb
         popad
         add _fakeloc,ecx
         clc
         mov eax,ecx
         ret

mod_error:
         call _closefile
         stc
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Play mod
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_play_mod:
         cmp _sfxtype,0
         je _ret

         mov _activate_controls,no
         call _load_mod
         cmp _loaded,-1
         je _kjhar
         mov eax,offset _ret
         call _mod_play
_kjhar:
         mov _activate_controls,yes
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Init Dashboard
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

locb     dd offset thelist
locc     dd 1
prebb    dd 0

_load_dash:
         mov edx,offset load_dash
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_dash
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edi,_lomembase
         add edi,6000h
         mov prebb,edi
         mov eax,01900140h                    ; 320 x 400
         stosd
         mov edx,edi
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw                  ; file remains open and is decoded from disk
         jc badshit
         call _closefile
againbmx:
         mov edi,locb
         mov ax,[edi+0]
         cmp ax,-1
         je short don_comping

         mov bx,[edi+2]
         mov cx,[edi+4]
         mov dx,[edi+6]

         mov _cliplt,ax
         mov _cliprt,cx
         mov _cliptp,bx
         mov _clipbt,dx

         mov eax,prebb
         xor ebx,ebx
         xor ecx,ecx
         xor dl,dl
         mov ebp,_himembase
         call _compile_foreground

         mov _himembase,edi
         mov eax,locc
         mov _compiled_cockpit[eax*4],ebp
         inc locc
         add locb,8
         jmp short againbmx

don_comping:
         mov _cliplt,_xcenter+xmin
         mov _cliprt,_xcenter+xmax-1
         mov _cliptp,_ycenter+ymin
         mov _clipbt,_ycenter+ymax-1

         mov edx,offset init_ok
         jmp _putdosmsg

load_dash db "_Load_Cockpit: $"

thelist  dw 0,0,320,160     ; 1
         dw 0,161,320,230   ; 2
         dw 0,231,320,342   ; 3
         dw 0,343,320,400   ; 4
_gundash dw 203,350,231,394 ; 5 guntype
         dw 290,350,314,362 ; 6 cannon
         dw 290,366,314,378 ; 7 rocket
         dw 282,382,314,394 ; 8 super-s
         dw 97,368,126,395  ; 9 mission
         dw 154,368,182,395 ; 10 shields
         dw 6,368,76,395    ; 11 score
         dw -1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Init wad
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_wad:
         xor eax,eax
         mov edx,offset _wadname
         call _cchekstr
         mov edx,offset _wadname
         call _openfile
         pushf
         call _closefile
         popf
         jnc short usenewwad
nonewwad:
         mov esi,offset _oldname
         mov edi,offset _wadname
         mov ecx,14
         rep movsb
usenewwad:
         mov edx,offset wadsay
         call _putdosmsg
         mov esi,offset _wadname
xxzzqq:
         lodsb
         push esi
         or al,al
         jz short nomorestuf
         mov ah,"$"
         call _dos_string4
         pop esi
         jmp short xxzzqq

nomorestuf:
         pop esi
         call _dos_ret

         mov edx,offset initwad
         call _putdosmsg

         mov edx,offset _initnam
         call _openfile
         jnc in_loadit

_buildcfg:
         mov edx,offset _wadname
         mov ecx,offset _wad_lst
         mov ebp,offset _wad_off
         call _buildlist
         jc badshit
okwads:
         mov edx,offset init_ok
         mov _modsok,0
         call _putdosmsg
         call _set_volm
         clc
         ret

_check_cfg_save:
         mov al,"c"
         call _cchekswitchnc
         jc _ret
         call _sfx_find

_save_cfg:
         xor _activate_controls,no+yes
         mov edx,offset _initnam
         call _createfile
         mov edx,offset _wad_off
         mov ecx,offset _wad_end - offset _wad_off
         call _writefile
         call _closefile
         xor _activate_controls,yes+no
         clc
         ret
badshit:
         mov edx,_language
         mov edx,_badwad[edx*4]
         call _putdosmsg
         stc
         ret

in_loadit:
         call _filesize
         cmp eax, offset _wad_end - offset _wad_off
         jne _buildcfg

         mov edx,offset _wad_off
         mov ecx,offset _wad_end - offset _wad_off
         call _readfile
         jcxz short dead1
againxor1:
         xor byte ptr [edx],0a5h
         inc edx
         dec ecx
         jnz short againxor1
dead1:
         call _closefile
         mov eax,d _wad_off+0
         or  eax,d _wad_off+4
         or  eax,d _wad_off+8
         or  eax,d _wad_off+12
         or  eax,d _wad_off+16
         or  eax,d _wad_off+20
         jz _buildcfg
         jmp _buildcfg

         mov edx,offset _wadname
         call _openfile
         jc badshit
         call _closefile

         mov edx,offset wadokin
         call _putdosmsg
_set_volm:
         movzx eax,_ctrl
         mov eax,_cotr[eax*4]
         mov _joytype,eax
         mov al,_blaster_level
         mov _sbvolume,al
         clc
         ret

_cotr    dd offset _ret
         dd offset _config_joystick
         dd offset _config_mouse

initwad  db "_Init_WAD: [",41 dup (" "),"]",42 dup (8),"$"
wadokin  db "Loaded...",13,10,"$"
wadsay   db "_Wad_Name: $"

_wad_lst:
         db "SENGINE.SND",0                 ; 0
         db "SBUMP0.SND",0                  ; 1
         db "SBUMP1.SND",0                  ; 2
         db "SCANNON.SND",0                 ; 3
         db "SDEAD.SND",0                   ; 4
         db "SELECTRO.SND",0                ; 5
         db "SEXP0.SND",0                   ; 6
         db "SEXP1.SND",0                   ; 7
         db "SEXP2.SND",0                   ; 8
         db "SEXP3.SND",0                   ; 9
         db "SCHANGE.SND",0                 ; 10
         db "SGOTIT1.SND",0                 ; 11
         db "SGOTIT2.SND",0                 ; 12
         db "SGOTIT3.SND",0                 ; 13
         db "SZOOM.SND",0                   ; 14
         db "SNUKE.SND",0                   ; 15
         db "SBEEP.SND",0                   ; 16
         db "OUTRIDGE.OPN",0
         db "DARK.LOZ",0
         db "EXPLODE.LOZ",0
         db "COCKPIT.LOZ",0
         db "TEXT.LOZ",0
         db "TAS1.LOZ",0
         db "TAS2.LOZ",0
         db "TAS3.LOZ",0
         db "TAS4.LOZ",0
         db "TAS5.LOZ",0
         db "MOD1.MOD",0
         db "MOD2.MOD",0
         db "MOD3.MOD",0
         db "MOD4.MOD",0
         db "MOD5.MOD",0
         db "MOD6.MOD",0
         db "MOD7.MOD",0
         db "ORDER.LOZ",0
         db "BESTELL.LOZ",0
         db "CH.LOZ",0
         db "TABLES.LOZ",0
         db "PROG.LOZ",0
         db 0

         align 4

_wad_off:
_samlist dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
_title   dd 0,0
_dark    dd 0,0
_expl    dd 0,0
_dash    dd 0,0
_text    dd 0,0
_tas1    dd 0,0
_tas2    dd 0,0
_tas3    dd 0,0
_tas4    dd 0,0
_tas5    dd 0,0
_mod_off dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
         dd 0,0
_order   dd 0,0
_bestell dd 0,0
_bestch  dd 0,0
_tables  dd 0,0
_prog    dd 0,0
         dd 0,0
         dd 0,0    ; 41 total

_mod_vol  db 15
_sfx_vol  db 15
_ctrl     db 0            ; control type  0 = key, 1 = key + joy, 2 = key + mouse
_tmethod  db 0            ; thrust method 0 = gripping
_language dd 0            ; 0 = english, 1 = german
_cockpit_control db 111b  ; cockpit compiled bitmap controls
_inverse_keys    db no    ; airplane controls or regular controls
_mouse_shotmask  db 1
_mouse_thrmask   db 2
_mouse_chgmask   db 4
_kb_up           db 48h
_kb_down         db 50h
_kb_r            db 4dh
_kb_l            db 4bh
_kb_thr          db 1dh
_kb_fire         db 39h
_kb_chg          db 28
_joy_shotmask    db 1
_joy_thrmask     db 2
_joy_chgmask     db 4
_key_scaling     dd 100   ; keyboard scaling rate
_highest_level   db 1     ; highest level ever achieved by player
_restart_mask_k  db 39h
_restart_mask_j  db 2+1
_restart_mask_m  db 2+1
_cardtype        db 0
_cardirq         db 0
_cardport        dw 0
_blaster_level   db 72
_names           db "                         ",0,0,0,0,0 ; 25 spaces
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
                 db "                         ",0,0,0,0,0
_wad_end:

_rocketd dd 10000         ; rocket total destruction sphere
_sizes   dd 2600,1300,650,cockpitsize,650,650,650,650,650,650,650,650,650
         dd cockpitsize*3/2,cockpitsize*3/2,450,450 ; world sizes of asteroids 1,2,3,player,bonus1,2,3,4,5,6,7,8
            ;camo1,camo2,mine1,mine2
_cannons dd 60,230,5500,140 ; sizes of weapons
_power   dw 330,2600,6000,2000 ; power weapons have

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; set xmode
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_set_vgacard:
         call _set_vga_modex
         xor eax,eax
         call _wipeoffpalette
         pushw 1
         call _set_active_page
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Wait for my fantastic 17" NEC Multisync Monitor to sync to mode
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_multisync_wait:

         mov _irq_tracespast,0
         mov ecx,10000000
_mw:
         cmp _irq_tracespast,50
         loopne _mw

         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Generate compiled bitmap for screen clear, also numbers for score
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

radarz   equ 100
radarx   equ 72

currentcompile dd 0

_clearscreen:
         mov edi,_current_page
         add edi,8000
         out_8 sc_data, all_planes          ; write to all planes
         mov ecx,6860 - 8000/4
         xor eax,eax
         rep stosd
         mov edi,_current_page
         mov ebx,colback2
         xor eax,eax
         mov ebp,100
morewipe:
         mov [edi],ebx
         mov [edi+4],ebx
         mov [edi+8],ebx
         mov [edi+12],ebx
         mov [edi+16],bx
         mov [edi+62],ebx
         mov [edi+4+62],ebx
         mov [edi+8+62],ebx
         mov [edi+12+62],ebx
         mov [edi+16+62],bx
         add edi,18
         mov ecx,44/4
         rep stosd
         add edi,18
         dec ebp
         jne short morewipe

         ret

_compile_bitmap:
         mov edx,offset clearmap
         call _putdosmsg

         mov edi,offset _clearscreen
         mov _compiled_cockpit[cb_clear*4],edi
         mov edi,_himembase

nextcompileplease:                          ; compile numbers
         mov ebp,edi
         mov eax,currentcompile
         mov bx,offsets[eax*4+0]
         mov cx,offsets[eax*4+2]
         mov eax,compilelist[eax*4]
         xor dl,dl
         call _compile_foreground
         mov eax,currentcompile
         mov _compiled_numbers[eax*4],ebp
         inc currentcompile
         cmp currentcompile,22
         jne short nextcompileplease

         mov _himembase,edi
         ret

clearmap db "_Compile_Bitmap: ",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load Darkening tables
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_dark:
         mov edx,offset darkload
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_dark
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,_himembase
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw                  ; file remains open and is decoded from disk
         jc badshit
         call _closefile

         mov edx,_himembase
         mov eax,0
         mov ecx,63
idloop:
         mov _xreftable[eax*4],edx
         add edx,256
         inc eax
         loop short idloop

         sub edx,256
         mov _xreftable[63*4],edx

         add _himembase,7936 + 8192
         mov edx,offset init_ok
         jmp _putdosmsg

darkload db "_Load_Dark: $",0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Init explosion bitmaps
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_explosions:
         mov edx,offset explsay
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_expl
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,_himembase
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw                  ; file remains open and is decoded from disk
         jc badshit

         mov edx,_himembase
         add _himembase,ecx

         mov ecx,45                         ; 19 explosion bitmaps + 8 schnot + rocket + sphere + 7 bonus + 1 camo sphere + 6 camo hexagonal + 1 endlevel "H" + =(64*64+4)* 44
         xor eax,eax
exloop:
         mov _bitbase[eax*4],edx
         inc eax
         add edx,4100
         loop short exloop

         call _closefile
         mov edx,offset okexpl
         jmp _putdosmsg

explsay  db "_Load_Explosions: $"
okexpl   db "Boom!",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Wipe Video Memory
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_wipe_video:
         out_8 sc_data, all_planes          ; write to all planes
         rlp edi,0a0000h
         mov ecx,64000
         xor al,al
         rep stosb
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; write a return to DOS
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
_dos_ret:
         mov eax,00240a0dh

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; write eax to dos
; eg eax = "$!ih"  outputs hi!
;    eax = "NHOJ"  outputs JOHN
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_dos_string4:
         mov fv,eax
         mov edx,offset fv
         jmp _putdosmsg

fv       dd 0
         db "$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; write eax as 32bit hex
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_dos_hex32:
         call _vc32
         push ebp
         call _dos_string4
         pop eax
         jmp _dos_string4

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; convert eax = 12345678h  to eax = "4321"  ebp = "8765"
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_vc32:
         mov cl,28
         mov edx,8
         mov esi,eax
cvxl:
         shrd eax,ebp,8
         shr ebp,8
         mov edi,esi
         shr edi,cl
         and edi,0fh
         mov bl,chars[edi]
         shl ebx,24
         or ebp,ebx
         sub cl,4
         dec edx
         jnz short cvxl

         ret

chars    db "0123456789abcdef"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Convert ax from dec number to eax as hex
; eg ax=51324 decimal returns eax=51324h
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_cv32:
         push esi
         mov esi,8
         xor ecx,ecx
more_cv:
         xor edx,edx
         mov ebx,numbs[esi*4-4]
         div ebx
         or cl,al
         shl ecx,4
         mov eax,edx
         dec esi
         jnz short more_cv

         or cl,dl
         mov eax,ecx
         pop esi
         ret

numbs    dd 10,100,1000,10000,100000,1000000,10000000,100000000

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Init Mouse
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_init_mouse:
         mov edx,_language
         mov edx, _mousething[edx*4]
         call _putdosmsg

         pushw 100
         pushw 100
         pushw 0
         pushw 200
         pushw 0
         pushw 200
         call _show_mouse

         cmp _ismouse,0
         mov ecx,_language
         mov edx,_mouno[ecx*4]
         jne _putdosmsg
         mov edx,_moufnd[ecx*4]
         jmp _putdosmsg

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Turn on always irq
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_init_always:
         mov _always_run,yes
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Turn on always irq
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_uninit_always:
         mov _always_run,no
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Turn off game irq
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_uninit_game:
         mov _game_run,no
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Turn on game irq
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_init_game:
         mov _game_run,yes
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Main running irq's
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

_game_run   db no
_always_run db no

_always:
         mov _joy_up,no
         mov _joy_dn,no
         mov _joy_bt,no
         mov _joy_on,no
         mov _joy_lf,no
         mov _joy_rt,no
         mov _joy_es,no
         call [_joytype]                    ; get keys from controller
         call _handle_always_keys

         cmp _mode,_all_off
         je skiprun

         cmp _inpause,yes
         je skiprun

         call _updvectors                   ; move asteroids around

         inc _global_timer
         inc _global_framenumber

         cmp _game_run,yes
         jne short _game

         cmp _ship_text,0
         je short notdecaysay
         dec _ship_text
notdecaysay:
         cmp _superfast,0
         je short nohhf
         dec _superfast
         jnz short nohhf
         mov dword ptr _sspeedtable,033c1904h ; reset weapon speed
         mov _apply_new_gun_bitmap,yes
nohhf:
         mov _game_run,no
         call _nme_irq                      ; make nme's fire
         call _handle_shot                  ; test if _shot = yes
         call _select_new_gun               ; test if new gun selected
         call _kill_player                  ; test collision for player
         call _handle_ship_rotate           ; rotate ship based on input
         call _handle_player_death          ; if player is dead, spin out of control
         xor _game_run,no+yes               ; turn game run back on, only if not dead
_game:
         cmp _always_run,yes
         jne skiprun

         mov _always_run,no
         call [_kbtype]                     ; get keys from keyboard
         call _make_world_a_cube            ; make asteroids unit from player
         call _handle_explosions            ; animate/remove explosions
         call _handle_shot_irq              ; animate/remove shots
         call _handle_thrust                ; thrust ship if _thr = yes
         call _make_asteroid_explode        ; handle if asteroid toughness < 0
         call _shot_collision               ; test if shot collides with anything
         call _decay_ship_angles            ; decay speed of ship rotate/thrust
         call _turn_asteroids               ; rotate asteroid bitmaps
         call _minimum_asteroid_check       ; add asteroids to scene if needed
         mov _always_run,yes
skiprun:
         call _mode_handler
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Load Asteroid bitmaps
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

tasof    dd offset _tas1
curbit   dd 0
if registered eq yes
total_load db 5
elseif registered eq no
total_load db 4
endif

_init_bitmaps:
         mov edx,offset asthing
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit
loadlp:
         mov edx,offset dottas
         call _putdosmsg

         mov eax,tasof
         mov eax,[eax]
         add tasof,8
         inc dottas
         add curbit,48
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,_himembase
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw                  ; file remains open and is decoded from disk
         jc badshit

         mov ebp,_himembase
         add _himembase,ecx

         mov ecx,48
         mov esi,curbit
         xor eax,eax
         xor ebx,ebx
         mov ax,[ebp]
         mov bx,[ebp+2]
         cmp ax,64
         jne badshit
         cmp bx,64
         jne badshit
         imul ebx
         add eax,4

assign_loop:
         mov _bitbase[esi*4],ebp
         add ebp,eax
         inc esi
         loop short assign_loop

         dec total_load
         jnz loadlp

         call _closefile

         mov byte ptr dottas," "
         mov edx,offset dottas
         call _putdosmsg

         mov edx,offset init_ok
         jmp _putdosmsg

asthing  db "_Load_Asteroid_Bitmaps: $"
dottas   db "1$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Tell user about memory he has
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_say_memory:
         mov edx,offset memorytext
         call _putdosmsg

         mov eax,_himemtop
         sub eax,_himembase
         push eax
         push eax
         call _dos_hex32

         mov edx,offset commachar
         call _putdosmsg

         pop eax
         call _cv32
         mov cx,903h
         xor edx,edx
find00:
         dec ch
         jz outrq
         dec cl
         jnz short nocll1
         mov cl,3
nocll1:
         shld edx,eax,4
         shl eax,4
         or dl,dl
         jz short find00
outq:
         push eax ecx
         add dl,"0"
         mov ouch,dl
         mov edx,offset ouch
         call _putdosmsg
         pop ecx eax
         dec cl
         jnz short nocll0
         cmp ch,1
         je short nocll0
         push eax ecx
         mov edx,offset ouch2
         call _putdosmsg
         pop ecx eax
         mov cl,3
nocll0:
         xor edx,edx
         shld edx,eax,4
         shl eax,4
         dec ch
         jnz short outq

         mov edx,offset returnch
         call _putdosmsg

         call _sfx_find
         mov ebx,sbsize+gussize+modsize
         cmp _sfxtype,2
         je short sbblab
         mov ebx,gussize
sbblab:
         pop eax
         cmp eax,ebx
         jae short okout

         mov edx,_language
         mov edx,_loemem[edx*4]
         call _putdosmsg
         stc
         ret
outrq:
         mov eax,"0$$0"
         call _dos_string4
         pop eax
         stc
         ret
okout:
         clc
         ret

memorytext db "_Say_Memory: $"
           db "$"
commachar  db "h:$"
ouch       db " $"
ouch2      db ",$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Get command line arguments
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_command_line:
         mov _debugit,no
         mov al,"d"
         call _cchekswitchnc
         jc short nodebugmode
         mov _debugit,yes

         mov edx,offset debugmsg
         call _putdosmsg
nodebugmode:

         mov _pcxit,no
         mov al,"p"
         call _cchekswitchnc
         jc short nopcxmode
         mov _pcxit,yes
nopcxmode:

         mov _memit,no
         mov al,"m"
         call _cchekswitchnc
         jc short nomemmode
         mov _memit,yes
nomemmode:
         ret

         db "-debugmode",13,10
debugmsg db "Developers Mode ON",13,10,"$"

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Say endscreen
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

 if crack eq yes
zol db 0
 endif

 if registered eq yes or crack eq yes
bv1 = 3f00h
bv2 = 03dfh
bv3 = 03eh
 endif
 if registered eq no
bv1 = 1f00h
bv2 = 01dfh
bv3 = 01eh
 endif

_xxx     dd 0
_yyy     dd 0
_attrib  db 0

_exitgame:
         call _mode03
         call _reset_blue
         call _turn_screen_off
         call _multiple_returns
          if crack eq yes
         call _getdate
         mov zol,20h
         jc short adashare2
         mov zol,0
adashare2:
          endif
         call _put_colour_block_to_dos
         call _put_end_text
         call _turn_screen_on
         ret

_multiple_returns:
         mov ecx,23
         mov edx,offset returnch
moreretrs:
         call _putdosmsg
         loop short moreretrs
         ret

_put_end_text:
         mov edx,_language
          if crack eq yes
         cmp zol,20h
         je short adashare
         mov esi,_end_text2[edx*4]
         jmp short nextchar
adashare:
          endif
         mov esi,_end_text1[edx*4]
nextchar:
         lodsb
         or al,al
         jz _ret
         cmp al,1
         jne short notretchr
         inc _yyy
         mov _xxx,0
         jmp short nextchar
notretchr:
         cmp al,2
         jne short noattrib
         lodsb
         mov _attrib,al
         jmp short nextchar
noattrib:
         mov edi,_yyy
         lea edi,[edi*8]       ; edi = edi * 160
         shl edi,2
         lea edi,[edi*4+edi]
         add edi,_xxx
         add edi,_xxx
         add edi,0b8000h
         sub edi,_code32a
         stosb
         inc _xxx
         mov al,_attrib
         or al,al
         jz short nextchar
         stosb
         jmp short nextchar

_put_colour_block_to_dos:
         wide equ 68
         tall equ 23

         mov edx,tall
         rlp edi,0b8000h+(80-wide)
         mov ax,bv1
          if crack eq yes
         add ah,zol
          endif
rloop1:
         mov ecx,wide
moresot1:
         mov [edi+1],ah
         add edi,2
         loop moresot1
         add edi,(80-wide)*2
         dec edx
         jnz short rloop1

         mov ecx,wide
         mov ax,bv2
          if crack eq yes
         mov dl,zol
         shr dl,4
         add ah,dl
          endif
         rep stosw

         rlp edi,0b8000h
         mov ecx,11
         mov al,bv3
          if crack eq yes
         add al,zol
          endif
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Get system date (crack copy only)
; OUT:jc  say_fake_message
;     jnc say_real_message (shareware)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

 if crack eq yes
         public _getdate
_getdate:
         mov v86r_ah,2ah
         mov al,21h
         int 33h
         mov cx,v86r_cx  ; cx = year
         mov dx,v86r_dx  ; dh = month, dl = day
         cmp cx,1995
         jne short retx  ; 1995
         cmp dh,4        ; april
         ja short retx
         cmp dl,20       ; 15
         jae short retx
         stc             ;"registered"
         ret
retx:
         clc             ;"haha shareware only"
         ret
 endif

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load Text Icons
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_text_icons:
         mov edx,offset iconsay
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_text
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,_himembase
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw
         jc badshit

         mov edx,_himembase
         add _himembase,ecx

         mov ecx,55
         xor esi,esi
         mov edi,edx
txloop:
         mov _texttables[esi*4],edi
         xor eax,eax
         mov ax,[edi]
         mov bx,[edi+2]
         imul bx
         add ax,4
         add edi,eax
         inc esi
         loop short txloop

         call _closefile
         mov edx,offset init_ok
         jmp _putdosmsg

iconsay  db "_Load_Text_Icons: $"

_texttables dd 51 dup (0)

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Save ORDER.DOC
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_save_order:
         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_order
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,_lomembase
         add edx,4096*3
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw
         jc badshit
         call _closefile

         mov edx,offset l0_ordernam
         call _createfile
         mov edx,_lomembase
         add edx,4096*3
         call _writefile
         call _closefile

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_bestell
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,_lomembase
         add edx,4096*3
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw
         jc badshit
         call _closefile

         mov edx,offset l1_ordernam
         call _createfile
         mov edx,_lomembase
         add edx,4096*3
         call _writefile
         call _closefile

         mov edx,offset l2_ordernam
         call _createfile
         mov edx,_lomembase
         add edx,4096*3
         call _writefile
         call _closefile

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_bestch
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,_lomembase
         add edx,4096*3
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw
         jc badshit
         call _closefile

         mov edx,offset l3_ordernam
         call _createfile
         mov edx,_lomembase
         add edx,4096*3
         call _writefile
         call _closefile

         ret

l0_ordernam  db "ORDER.DOC",0
l1_ordernam  db "BESTELL.TXT",0
l2_ordernam  db "BESTELL.DEU",0
l3_ordernam  db "BESTELL.CH",0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load levels from disk if "LEVELS.WAD" found
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_load_levels:
         mov edx,offset _levname
         call _openfile
         jc _ret

         mov edx,offset levsay
         call _putdosmsg

         mov edx,offset _level_tables
         mov ecx,48*45
         call _readfile
         jcxz short dead2
againxor2:
         xor byte ptr [edx],0a5h
         inc edx
         dec ecx
         jnz short againxor2
dead2:
         jmp _closefile

levsay   db "   adding "
_levname db "LEVELS.WAD",0,13,10,"$"

_save_levels:
         xor _activate_controls,no+yes
         mov edx,offset _levname
         call _createfile
         mov edx,offset _level_tables
         mov ecx,48*45
         call _writefile
         call _closefile
         xor _activate_controls,yes+no
         ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load sine/cosine tables from WAD. (Relative Byte Encoded)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

         extrn sinus:word

_load_tables:
         mov edx,offset tabsay
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_tables
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,offset sinus + 6145
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw
         jc badshit
         call _closefile

         mov esi,offset sinus + 6145
         mov edi,offset sinus
         mov ecx,4096
         xor ebx,ebx
ldt_loop1:
         xor ah,ah
         lodsb
         add ax,bx
         mov bx,ax
         stosw
         loop short ldt_loop1

         xor bh,bh
         mov ecx,2049
ldt_loop2:
         xor ah,ah
         lodsb
         add ax,bx
         mov bx,ax
         stosw
         loop short ldt_loop2

         mov edx,offset init_ok
         jmp _putdosmsg

tabsay   db "_Load_SinCos: $",0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load .EXE specifics
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_init_exe:
         mov edx,offset exesay
         call _putdosmsg

         mov edx,offset _wadname
         call _openfile
         jc badshit

         mov eax,_prog
         xor bl,bl
         call _lseekfile
         jc badshit

         mov edx,offset wad_version
         mov eax,offset _readfile
         mov ecx,_lomembase
         call _loadgif_lzw
         jc badshit

         mov edi,offset compilelist
         mov esi,edi
         mov ecx,22
agains:
         add [edi],esi
         add edi,4
         loop short agains

         call _closefile
         mov edx,offset init_ok
         jmp _putdosmsg

exesay   db "_Init_EXE: $"

code32   ends
         end
