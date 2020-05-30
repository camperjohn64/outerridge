TASM_OPTIONS = /ml /zi

lib\sfx.lib   : gus.obj fx.obj mod.obj

gus.obj   : gus.asm
            tasm $(TASM_OPTIONS) gus
            tlib lib\sfx -+gus

mod.obj   : mod.asm
            tasm $(TASM_OPTIONS) mod
            tlib lib\sfx -+mod

fx.obj    : fx.asm
            tasm $(TASM_OPTIONS) fx
            tlib lib\sfx -+fx
