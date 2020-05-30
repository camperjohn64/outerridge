alchemy -a rocket.tga rocketb.tga -24 -b -o

del cc.*
del qq

split cockpit.tga qq cc.man cc.ww 18:96000:288000
del cc.ww

split blastl.tga cc.ww cc.qq2 18:12288
del cc.ww
split sphere.tga cc.ww cc.qq3 18:12288
del cc.ww
split rocket.tga cc.ww cc.qq4 18:12288
del cc.ww
split blastq.tga cc.ww cc.qq5 18:12288
del cc.ww
split bonus1.tga cc.ww cc.qq6 18:12288
del cc.ww
split bonus2.tga cc.ww cc.qq7 18:12288
del cc.ww
split bonusca.tga cc.ww cc.qq8 18:12288
del cc.ww
split bonusro.tga cc.ww cc.qq9 18:12288
del cc.ww

split ex0.tga cc.ww cc.qqa 18:12288
del cc.ww
split ex1.tga cc.ww cc.qqb 18:12288
del cc.ww
split ex3.tga cc.ww cc.qqc 18:12288
del cc.ww
split ex5.tga cc.ww cc.qqd 18:12288
del cc.ww
split ex7.tga cc.ww cc.qqe 18:12288
del cc.ww

split camo1.tga cc.ww cc.qqf 18:12288
del cc.ww
split camo20.tga cc.ww cc.qqg 18:12288
del cc.ww
split bonush.tga cc.ww cc.qqh 18:12288
del cc.ww
split bonusds.tga cc.ww cc.qqi 18:12288
del cc.ww

split bonusxm.tga cc.ww cc.qqj 18:12288
del cc.ww

split tas10000.tga cc.ww cc.q1a 18:6912
del cc.ww
split tas10010.tga cc.ww cc.q1b 18:6912
del cc.ww
split tas10020.tga cc.ww cc.q1c 18:6912
del cc.ww
split tas10030.tga cc.ww cc.q1d 18:6912
del cc.ww

split tas20000.tga cc.ww cc.q2a 18:6912
del cc.ww
split tas20010.tga cc.ww cc.q2b 18:6912
del cc.ww
split tas20020.tga cc.ww cc.q2c 18:6912
del cc.ww
split tas20030.tga cc.ww cc.q2d 18:6912
del cc.ww

split tas30000.tga cc.ww cc.q3a 18:6912
del cc.ww
split tas30010.tga cc.ww cc.q3b 18:6912
del cc.ww
split tas30020.tga cc.ww cc.q3c 18:6912
del cc.ww
split tas30030.tga cc.ww cc.q3d 18:6912
del cc.ww

split tas40000.tga cc.ww cc.q4a 18:6912
del cc.ww
split tas40010.tga cc.ww cc.q4b 18:6912
del cc.ww
split tas40020.tga cc.ww cc.q4c 18:6912
del cc.ww
split tas40030.tga cc.ww cc.q4d 18:6912
del cc.ww

split tas50000.tga cc.ww cc.q5a 18:6912
del cc.ww
split tas50010.tga cc.ww cc.q5b 18:6912
del cc.ww
split tas50020.tga cc.ww cc.q5c 18:6912
del cc.ww
split tas50030.tga cc.ww cc.q5d 18:6912
del cc.ww

copy /b head.tga+cc.man+cc.q??+cc.qq?+cc.man+cc.q?? makepal.tga
alchemy -g makepal.tga -d0 -z4 0 0 -o
del cc.*

palstrip makepal.gif makepal.pal
copy makepal.pal c:\as\raw
copy makepal.pal d:\pe

call zap gif
md gif

call makebw.bat

alchemy -g t*.tga -fmakepal.gif gif -d0
alchemy -g r*.tga -fmakepal.gif gif
alchemy -g s*.tga -fmakepal.gif gif
alchemy -g b*.tga -fmakepal.gif gif -d0
alchemy -g e*.tga -fmakepal.gif gif -d0
alchemy -g c*.tga -fmakepal.gif gif -d0
alchemy -g outridge.tga -fmakepal.gif -d0 -o

del qq
