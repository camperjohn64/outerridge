        .386p
code32  segment para public use32
start:

colourtable label byte

         db 221    ; 0  t_big_asteroid
         db 221    ; 1  t_medium_asteroid
         db 221    ; 2  t_small_asteroid
         db 126    ; 3  t_player
         db 206    ; 4  t_bonus1
         db 209    ; 5  t_bonus2
         db 96     ; 6  t_cannon_bonus
         db 190    ; 7  t_rocket_bonus
         db 234    ; 8  t_schnot2_bonus
         db 235    ; 9  t_hyper
         db 208    ; 10 t_question
         db 109    ; 11 t_extraship
         db 234    ; 12 t_lightning
         db 172    ; 13 t_badguy1
         db 208    ; 14 t_badguy2
         db 172    ; 15 t_badguy3
         db 208    ; 16 t_badguy4
         db 255    ; 17
         db 204    ; 18 t_schnot1
         db 226    ; 19 t_cannons
         db 109    ; 20 t_rocket
         db 196    ; 21 t_schnot2
         db 255    ; 22
         db 255    ; 23
         db 255    ; 24
         db 255    ; 25
         db 255    ; 26
         db 255    ; 27
         db 255    ; 28
         db 255    ; 29
         db 255    ; 30
         db 255    ; 31
         db 253    ; 32 t_explosion

compilelist label dword
         dd offset _number0 - offset compilelist
         dd offset _number1 - offset compilelist
         dd offset _number2 - offset compilelist
         dd offset _number3 - offset compilelist
         dd offset _number4 - offset compilelist
         dd offset _number5 - offset compilelist
         dd offset _number6 - offset compilelist
         dd offset _number7 - offset compilelist
         dd offset _number8 - offset compilelist
         dd offset _number9 - offset compilelist
         dd offset _bignum0 - offset compilelist
         dd offset _bignum1 - offset compilelist
         dd offset _bignum2 - offset compilelist
         dd offset _bignum3 - offset compilelist
         dd offset _bignum4 - offset compilelist
         dd offset _bignum5 - offset compilelist
         dd offset _bignum6 - offset compilelist
         dd offset _bignum7 - offset compilelist
         dd offset _bignum8 - offset compilelist
         dd offset _bignum9 - offset compilelist
         dd offset _sdash   - offset compilelist
         dd offset _bdash   - offset compilelist

offsets  dw 0,0     ; 0
         dw 1,0     ; 1
         dw 0,0     ; 2
         dw 0,0     ; 3
         dw 0,0     ; 4
         dw 0,0     ; 5
         dw 0,0     ; 6
         dw 1,0     ; 7
         dw 0,0     ; 8
         dw 0,0     ; 9
         dw 0,0     ; 0
         dw 2,1     ; 1
         dw 1,0     ; 2
         dw 0,0     ; 3
         dw 0,1     ; 4
         dw 0,1     ; 5
         dw 1,1     ; 6
         dw 1,1     ; 7
         dw 0,0     ; 8
         dw 1,0     ; 9
         dw 0,4     ; sd
         dw 0,0     ; bd

colback1 db 3
colback2 dd 03030303h
colfron1 db 8
colfron2 dd 08080808h

_star_colour    dd 0a28a49c1h               ; colours for 4 stars

hackcolour db 0FAh
           db 0F5h
           db 0EEh
           db 0E2h
           db 0D6h
           db 0BBh
           db 0A7h
           db 086h

_sfxcomplist:
         db 0 ;  "SENGINE.SND"   ;  buy this game
         db 1 ;  "SBUMP0.SND"    ;  sex
         db 0 ;  "SBUMP1.SND"    ;  blood
         db 1 ;  "SCANNON.SND"   ;  fuck me
         db 0 ;  "SDEAD.SND"     ;  i like this game, i think i will play again
         db 0 ;  "SELECTRO.SND"  ;  loser
         db 1 ;  "SEXP0.SND"     ;  mother and i are one
         db 1 ;  "SEXP1.SND"     ;  fuck
         db 1 ;  "SEXP2.SND"     ;  great sex
         db 1 ;  "SEXP3.SND"     ;  i am excited
         db 0 ;  "SCHANGE.SND"   ;  don't stop playing
         db 1 ;  "SGOTIT1.SND"   ;  cunt
         db 1 ;  "SGOTIT2.SND"   ;  fuck
         db 1 ;  "SGOTIT3.SND"   ;  whore
         db 1 ;  "SZOOM.SND"     ;  i want to buy this game
         db 1 ;  "SNUKE.SND"     ;  buy this game
         db 1 ;  "SBEEP.SND"     ;  sex

_maxmods db 7

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Really small font numbers
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

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



code32  ends
        end start
