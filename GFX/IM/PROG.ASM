        include \as\equ.inc

        .386p
code32  segment para public use32
start:

ver      db 1 ; version 1
reg      db registered ; registered wad or not

colourtable label byte
         include prog1.inc

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

 if registered eq yes
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
 elseif registered eq no
         db 0 ;  "SENGINE.SND"
         db 1 ;  "SBUMP0.SND"
         db 0 ;  "SBUMP1.SND"
         db 1 ;  "SCANNON.SND"
         db 0 ;  "SDEAD.SND"
         db 0 ;  "SELECTRO.SND"
         db 1 ;  "SEXP0.SND"
         db 1 ;  "SEXP1.SND"
         db 1 ;  "SEXP2.SND"
         db 1 ;  "SEXP3.SND"
         db 0 ;  "SCHANGE.SND"
         db 1 ;  "SGOTIT1.SND"
         db 1 ;  "SGOTIT2.SND"
         db 0 ;  "SGOTIT3.SND"
         db 0 ;  "SZOOM.SND"
         db 0 ;  "SNUKE.SND"
         db 0 ;  "SBEEP.SND"
 endif

 if registered eq yes
_maxmods db 6
 elseif registered eq no
_maxmods db 2
 endif

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Really small font numbers
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_number0:
   dw 7,13
   include gif\n0.inc
_number1:
   dw 4,13
   include gif\n1.inc
_number2:
   dw 6,13
   include gif\n2.inc
_number3:
   dw 6,13
   include gif\n3.inc
_number4:
   dw 7,13
   include gif\n4.inc
_number5:
   dw 6,13
   include gif\n5.inc
_number6:
   dw 6,13
   include gif\n6.inc
_number7:
   dw 6,13
   include gif\n7.inc
_number8:
   dw 7,13
   include gif\n8.inc
_number9:
   dw 6,13
   include gif\n9.inc
_sdash:
   dw 6,3
   include gif\nd.inc

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Big numbers
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_bignum0:
   dw 9,26
   include gif\b0.inc
_bignum1:
   dw 5,24
   include gif\b1.inc
_bignum2:
   dw 8,25
   include gif\b2.inc
_bignum3:
   dw 9,26
   include gif\b3.inc
_bignum4:
   dw 9,24
   include gif\b4.inc
_bignum5:
   dw 8,25
   include gif\b5.inc
_bignum6:
   dw 8,25
   include gif\b6.inc
_bignum7:
   dw 8,25
   include gif\b7.inc
_bignum8:
   dw 9,26
   include gif\b8.inc
_bignum9:
   dw 9,25
   include gif\b9.inc
_bdash:
   dw 8,4
   include gif\bd.inc

code32  ends
        end start
