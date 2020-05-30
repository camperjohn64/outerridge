;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : equ.inc
; Included from: 3D1.ASM, 3D2.ASM, 3D3.ASM
; Description  : Conditional assembley variables and general constants.
;              : No data is here, just parameters
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

yes             equ 0
no              equ -1
registered      equ yes
crack           equ no

debug           equ yes

; possibilities for versions
;
;  registered equ yes ; registered version
;  crack      equ no
;
;  registered equ no  ; pirate version
;  crack      equ yes
;
;  registered equ no  ; real shareware version
;  crack      equ no

; unregistered version:

; god mode not available
; bitmaps removed:
;  super-schnot weapon
;  super-schnot bonus
;  rocket
;  rocket bonus
;  mega power (green)
;  only 4 asteroids instead of 5
; rocket sound removed (snuke.snd)
; badguy2 removed (along with graphics)
; # of mod files cut from 7 to 3

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; constants for optimal conditional assembley
; don't pay for features you'll never use! (timewise)
; these are the most signifigant factors in determining speed!!
; note:_bitmaps also slow things down...
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

usez            equ yes        ; z camera rotations ommited if no, saves 12 imuls
                               ; this speeds up computation in "_compound" matrix
div_256         equ 0          ; will all locations be divided by 256? (set to 8 or 0)

; thats the end of conditional assembley constants!

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; colour crap
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

txtcol   equ 255

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; commands for _mode
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_all_off        equ 0
_run_game       equ 1
_back_from_dead equ 2
_anew           equ 4
_exitnow        equ 5
_dointro        equ 6
_dointroloop    equ 7
_donewgame      equ 8
_force_order    equ 9

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; bitmap definitions
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

g_schnot1       equ 19 ; grn1234
g_schnot2       equ 23 ; blue1234
g_cannon        equ 27
g_rocket        equ 28
g_bonuses       equ 29 ; blue,grn,cannon,rocket,super-schnot,warp,?,//
g_camo1         equ 38 ; sphere nme
g_camo2         equ 39 ; 39 to 44 (total 6 frames)
nextavailable   equ 45

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; compiled bitmap definitions
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

cb_clear     equ 0
cb_top       equ 1
cb_target    equ 2
cb_bottom    equ 3
cb_dash      equ 4
cb_gtype     equ 5
cb_ammo1     equ 6
cb_ammo2     equ 7
cb_ammo3     equ 8
cb_mission   equ 9
cb_shields   equ 10
cb_score     equ 11

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _type definitions
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

t_big_asteroid    equ  0
t_medium_asteroid equ  1
t_small_asteroid  equ  2
t_max_asteroid    equ  2

t_player          equ  3

t_bonus1          equ  4
t_bonus2          equ  5
t_cannon_bonus    equ  6
t_rocket_bonus    equ  7
t_schnot2_bonus   equ  8
t_hyper           equ  9
t_question        equ 10
t_extraship       equ 11
t_lightning       equ 12
t_max_bonus       equ 12

t_badguy1         equ 13 ; schnot thrower
t_badguy2         equ 14 ; cannon dude
t_badguy3         equ 15 ; mine sphere
t_badguy4         equ 16 ; mine hexagonal
t_badmax          equ 17

t_schnot1         equ 18
t_cannons         equ 19
t_rocket          equ 20
t_schnot2         equ 21
t_max_gun         equ 22

t_explosion       equ 32

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Short Originate definitions
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

d_player        equ -1         ; player shot weapon
d_nme           equ -2         ; nme shot weapon

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; variables for object routines
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

tolerance       equ 300        ; max center of gravity offset for objects/ratio (onscreen pixel distance)
ztruncate       equ 200        ; if z< ztruncate, z=ztruncate:for _make3d (16 bit distance)
minz            equ 500        ; minimum z before object can be seen:for _make1obj (16 bit distance)
maxz            equ 2500000    ; maximum distance in any axis object can be seen (24 bit distance)
followtol       equ 15         ; tolerance if already looking at object,_cam_newfollow (angle)
cockpitsize     equ 900
spedd           equ 37         ; acceleration during normal play
speds           equ 3
speddh          equ 16         ; acceleration during hyperspace run
spedsh          equ 5

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; object constants
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

maxobjects      equ 290        ; number of objects possible on screen at once
maxasteroids    equ 260        ; number of asteroids possible on screen at once

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; data definition allocation
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

numberofbitmaps equ 288        ; number of bitmaps to allocate space for
numberofpals    equ 64         ; number of selectable palette cross refnce tables

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Channels for samples
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

explode_chan    equ 4
fire_chan       equ 5
change_chan     equ 6
thrust_chan     equ 7
death_chan      equ 8
gotit_chan      equ 9
nme_chan        equ 10

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; commands for _onoff[esi]
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

mainobject_on   equ 1

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; where is the camera in the list
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

cameraobject    equ 0          ; camera is zero'th object in list

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; ===== general xmode constants =====
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

false           equ 0
true            equ -1
nil             equ 0

b               equ byte ptr
w               equ word ptr
d               equ dword ptr
o               equ offset
f               equ far ptr
s               equ short
?x4             equ <?,?,?,?>
?x3             equ <?,?,?>

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; ===== vga register values =====
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

vga_segment     equ d 0a0000h  ; vga memory segment (ok, this is protected mode, right?, so this is the actual address - hahahaha to all you real mode losers...)

attrib_ctrl     equ 03c0h      ; vga attribute controller
gc_index        equ 03ceh      ; vga graphics controller
sc_index        equ 03c4h      ; vga sequencer controller
sc_data         equ 03c5h      ; vga sequencer data port
crtc_index      equ 03d4h      ; vga crt controller
crtc_data       equ 03d5h      ; vga crt controller data
misc_output     equ 03c2h      ; vga misc register
input_1         equ 03dah      ; input status #1 register

dac_write_addr  equ 03c8h      ; vga dac write addr register
dac_read_addr   equ 03c7h      ; vga dac read addr register
pel_data_reg    equ 03c9h      ; vga dac/pel data register r/w

pixel_pan_reg   equ 033h       ; attrib index: pixel pan reg
map_mask        equ 002h       ; sequ index: write map mask reg
read_map        equ 004h       ; gc index: read map register
start_disp_hi   equ 00ch       ; crtc index: display start hi
start_disp_lo   equ 00dh       ; crtc index: display start lo

map_mask_plane1 equ 00102h     ; map register + plane 1
map_mask_plane2 equ 01102h     ; map register + plane 2
all_planes_on   equ 00f02h     ; map register + all bit planes

chain4_off      equ 00604h     ; chain 4 mode off
async_reset     equ 00100h     ; (a)synchronous reset
sequ_restart    equ 00300h     ; sequencer restart

latches_on      equ 00008h     ; bit mask + data from latches
latches_off     equ 0ff08h     ; bit mask + data from cpu

vert_retrace    equ 08h        ; input_1: vertical retrace bit
plane_bits      equ 03h        ; bits 0-1 of xpos = plane #
all_planes      equ 0fh        ; all bit planes selected
char_bits       equ 0fh        ; bits 0-3 of character data

get_char_ptr    equ 01130h     ; vga bios func: get char set
rom_8x8_lo      equ 03h        ; rom 8x8 char set lo pointer
rom_8x8_hi      equ 04h        ; rom 8x8 char set hi pointer

num_modes       equ 8          ; # of mode x variations

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; mode x definitions
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

xmode           equ 1
xmax            equ 160     ; right colomn just beyond screen for clipping
xmin            equ -160    ; left coloumn on screen, x's must be "and 0fffch"
ymax            equ 200-58  ; lower row just beyond screen
ymin            equ -200    ; upper row on screen
xactual         equ 320     ; guess...
yactual         equ 400

_xcenter        equ 160     ; screen center x,y for actual screen point (0,0)
_ycenter        equ 200     ; make sure clipping still stays inside screen

ratiox          equ 320     ; aspect ratio for 3d conversion (zoom)
ratioy          equ 464     ; make x and y different to fine tune (draw circle)
pages           equ 2       ; # of video pages mode will support, (don't modify)

