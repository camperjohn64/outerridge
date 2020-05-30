\lib\3dvect.lib :stars.obj  xmode.obj     joystick.obj\
                 fade.obj   function.obj  explode.obj\
                 game.obj   irq.obj       clear.obj

TASM_OPTIONS = /ml /zi

stars.obj    : stars.asm equ.inc
  tasm $(TASM_OPTIONS) stars
  tlib lib\3dvect -+stars.obj

xmode.obj    : xmode.asm
  tasm $(TASM_OPTIONS) xmode
  tlib lib\3dvect -+xmode.obj

joystick.obj : joystick.asm
  tasm $(TASM_OPTIONS) joystick
  tlib lib\3dvect -+joystick.obj

fade.obj     : fade.asm equ.inc
  tasm $(TASM_OPTIONS) fade
  tlib lib\3dvect -+fade.obj

function.obj : function.asm equ.inc
  tasm $(TASM_OPTIONS) function
  tlib lib\3dvect -+function.obj

explode.obj  : explode.asm equ.inc
  tasm $(TASM_OPTIONS) explode
  tlib lib\3dvect -+explode.obj

irq.obj      : irq.asm
  tasm $(TASM_OPTIONS) irq
  tlib lib\3dvect -+irq.obj

game.obj     : game.asm equ.inc
  tasm $(TASM_OPTIONS) game
  tlib lib\3dvect -+game.obj

clear.obj    : clear.asm
  tasm $(TASM_OPTIONS) clear
  tlib lib\3dvect -+clear.obj

