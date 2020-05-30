        .386p
code32  segment para public use32

include \as\equ.inc

start:

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Explosions
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

dw 64,64
include gif\ex0.inc
dw 64,64
include gif\ex1.inc
dw 64,64
include gif\ex3.inc
dw 64,64
include gif\ex4.inc
dw 64,64
include gif\ex5.inc
dw 64,64
include gif\ex6.inc
dw 64,64
include gif\ex7.inc
dw 64,64
include gif\ex8.inc
dw 64,64
include gif\ex9.inc
dw 64,64
include gif\exa.inc
dw 64,64
include gif\exb.inc
dw 64,64
include gif\exc.inc
dw 64,64
include gif\exd.inc
dw 64,64
include gif\exe.inc
dw 64,64
include gif\exf.inc
dw 64,64
include gif\exg.inc
dw 64,64
include gif\exh.inc
dw 64,64
include gif\exi.inc
dw 64,64
include gif\exj.inc

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Schnot 1
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

dw 64,64
include gif\blastj.inc
dw 64,64
include gif\blastk.inc
dw 64,64
include gif\blastl.inc
dw 64,64
include gif\blastm.inc

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Schnot 2
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

 if registered eq yes
dw 64,64
include gif\blastn.inc
dw 64,64
include gif\blasto.inc
dw 64,64
include gif\blastp.inc
dw 64,64
include gif\blastq.inc
 elseif registered eq no
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
 endif

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Cannon
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

dw 64,64
include gif\sphere.inc

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Rocket
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

 if registered eq yes
dw 64,64
include gif\rocket.inc
 elseif registered eq no
dw 64,64
db 64*64 dup (0)
 endif

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Bonuses
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

dw 64,64
include gif\bonus1.inc           ; blue sphere
dw 64,64
include gif\bonus2.inc           ; green sphere
dw 64,64
include gif\bonusca.inc

 if registered eq yes
dw 64,64
include gif\bonusro.inc          ; rockets
dw 64,64
include gif\bonusss.inc          ; super rotz
 elseif registered eq no
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
 endif

dw 64,64
include gif\bonush.inc           ; "exit"

 if registered eq yes
dw 64,64
include gif\bonusds.inc          ; "?"
dw 64,64                         ; "W" extra ship
include gif\bonusxm.inc
dw 64,64                         ; lightning rod
include gif\bonuslk.inc
 elseif registered eq no
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
 endif

dw 64,64
include gif\camo1.inc

 if registered eq yes
dw 64,64                         ; rotating bad guy (hexagonal)
include gif\camo20.inc
dw 64,64
include gif\camo21.inc
dw 64,64
include gif\camo22.inc
dw 64,64
include gif\camo23.inc
dw 64,64
include gif\camo24.inc
dw 64,64
include gif\camo25.inc
 elseif registered eq no
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
dw 64,64
db 64*64 dup (0)
 endif

code32  ends
        end start
