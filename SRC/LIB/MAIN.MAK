TASM_OPTIONS = /ml /zi

main.obj     : main.asm equ.inc\

 tasm $(TASM_OPTIONS) main
