del outridge.wad
del mods.wad
call add2wad SENGINE.SND
call add2wad SBUMP0.SND
call add2wad SBUMP1.SND
call add2wad SCANNON.SND
call add2wad SDEAD.SND
call add2wad SELECTRO.SND
call add2wad SEXP0.SND
call add2wad SEXP1.SND
call add2wad SEXP2.SND
call add2wad SEXP3.SND
call add2wad SCHANGE.SND
call add2wad SGOTIT1.SND
call add2wad SGOTIT2.SND
call add2wad SGOTIT3.SND
call add2wad SZOOM.SND
call add2wad SNUKE.SND
call add2wad SBEEP.SND
call add2wad OUTRIDGE.OPN
call add2wad DARK.LOZ
call add2wad EXPLODE.LOZ
call add2wad COCKPIT.LOZ
call add2wad TEXT.LOZ
call add2wad TAS1.LOZ
call add2wad TAS2.LOZ
call add2wad TAS3.LOZ
call add2wad TAS4.LOZ
call add2wad TAS5.LOZ
call add2mod MOD1.MOD
call add2mod MOD2.MOD
call add2mod MOD3.MOD
call add2mod MOD4.MOD
call add2mod MOD5.MOD
call add2mod MOD6.MOD
call fakemod MOD7.MOD
call add2mod ORDER.LOZ
call add2mod BESTELL.LOZ
call add2mod CH.LOZ
call add2mod TABLES.LOZ
call add2mod PROG.LOZ
copy /b outridge.wad+mods.wad ..\outridge.wad
cut ..\outridge.wad
del outridge.wad
del cc.wad
del ..\outridge.cfg
