alchemy -g -d0 radar.gif xxx.gif -o -fmakepal.gif
gif2raw xxx.gif xxx.raw
db xxx.raw prog1.inc
call makeraw prog
call compit prog raw prog loz 11 295
copy prog.loz \as\data
del xxx.gif
del xxx.raw
