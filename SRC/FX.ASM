;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Simple Sound FX routines - uses GUS.ASM routines, works on GUS and crappy SB
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

        .386p
code32  segment para public use32
        assume cs:code32, ds:code32

        include pmode.ext
        include gus.ext
        include irq.ext
        include file.ext
        include init.ext
        include loadgif.ext

        public _vcstarts
        public _play_sample
        public _load_lib

_vcstarts dd 40 dup (0) ; sample start locations (next is end) no maxmimum # of samples

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Play sample
; In:
;   AX = sample # to play
;   DL = channel (0-31)
;   BL = volume  (0-15)
;   BH = pan     (0-8)
;   CL = voice control (loop and stuff, usually 0)
;   CH = precalculated frequency (0-59)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_play_sample:
        cmp _sounds,-1
        je _ret

        movzx eax,ax
        movzx edx,dl

        mov edi,[_vcstarts+eax*4]
        mov ebp,[_vcstarts+4+eax*4]
        sub ebp,2
        add edi,2

        mov _vcsbeg[edx*4],edi
        mov _vclbeg[edx*4],edi
        mov _vclend[edx*4],ebp

        mov _vcpan+[edx],bh
        mov _vcvol+[edx],bl
        movzx eax,ch
        mov ax,_freqtbl[eax*2]
        mov _vcfreq[edx*2],ax
        mov _vccntrl[edx],cl
        mov _vccmnd[edx],play  ; command comes last
        ret

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Load samples from WAD (8bit, unsigned)
; In:
;  EDI => LSEEKFILE Offset and Length of samples to load
;  EDX => Buffer (must be able to contain largest sample+24576)
;  ECX => number of samples to load
;  EAX => compression flag list (eg db 0,0,1,1,0,1,1,0,0...)
; Out:
;  EBP = number of samples loaded
;   CF = 1 files not found/failed
; Note: routine is forced for maximum sample size of 50000! (for game "Outridge"
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_compflaglist dd 0
_savedcomploc dd 0

_load_lib:
        mov _savedcomploc,edx
        add edx,24576
        mov _compflaglist,eax
        xor ebp,ebp
        mov eax,_sfxmem
        mov _vcstarts,eax
        xchg ecx,edi
libloop:
        xor bl,bl
        mov eax,[ecx]
        call _lseekfile
        jc qerex
        mov ebx,[ecx+4]

        cmp ebx,50000                       ; force error if any samples>50000
        stc
        ja short qerex

        add ecx,8
        mov esi,_sfxmem
        mov _vcstarts[ebp*4+4],esi
        xchg ecx,ebx
        mov eax,_compflaglist
        cmp byte ptr [eax],1
        jne short donormalread
        push ebx edx esi ebp edi
        mov eax,offset _readfile
        mov ecx,_savedcomploc
        call _loadgif_lzw
        pop edi ebp esi edx ebx
        jmp short abortoverread
donormalread:
        call _readfile                      ; edx = loc, ecx = len, ebx = build
abortoverread:
        add _vcstarts[ebp*4+4],ecx
        inc _compflaglist
        xchg esi,ebx
        call _sfx_putram
        add _sfxmem,ecx
        xchg esi,ecx
        inc ebp
        dec edi
        jnz libloop

        clc
qerex:
        call _closefile
        ret

code32  ends
        end
