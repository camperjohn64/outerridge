        .386p
code32  segment para public use32
start:


include dark.inc

i = 0
rept 256
db i
i=i+1
endm

include blue.inc


code32  ends
        end start
