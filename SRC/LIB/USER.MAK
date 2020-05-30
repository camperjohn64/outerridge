lib\user.lib  : file.obj kb.obj loadgif.obj init.obj piccy.obj control.obj\
                xmouse.obj argc.obj nme.obj c.obj lang.obj tables.obj\

TASM_OPTIONS = /ml /zi

kb.obj    : kb.asm
            tasm $(TASM_OPTIONS) kb
            tlib lib\user -+kb.obj

file.obj  : file.asm
            tasm $(TASM_OPTIONS) file
            tlib lib\user -+file.obj

loadgif.obj: loadgif.asm
             tasm $(TASM_OPTIONS) loadgif
             tlib lib\user -+loadgif.obj

init.obj  : init.asm equ.inc
            tasm $(TASM_OPTIONS) init
            tlib lib\user -+init.obj

piccy.obj : piccy.asm equ.inc
            tasm /m2 $(TASM_OPTIONS) piccy
            tlib lib\user -+piccy.obj

control.obj: control.asm equ.inc
             tasm $(TASM_OPTIONS) control
             tlib lib\user -+control.obj

xmouse.obj:  xmouse.asm
             tasm $(TASM_OPTIONS) xmouse
             tlib lib\user -+xmouse.obj

argc.obj:    argc.asm
             tasm $(TASM_OPTIONS) argc
             tlib lib\user -+argc.obj

nme.obj:     nme.asm equ.inc
             tasm $(TASM_OPTIONS) nme
             tlib lib\user -+nme.obj

c.obj:       c.asm equ.inc levels.inc
             tasm $(TASM_OPTIONS) c
             tlib lib\user -+c.obj

lang.obj:    lang.asm equ.inc
             tasm $(TASM_OPTIONS) lang
             tlib lib\user -+lang.obj

tables.obj:  tables.asm
             tasm $(TASM_OPTIONS) tables
             tlib lib\user -+tables.obj

