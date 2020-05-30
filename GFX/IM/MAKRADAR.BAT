alchemy -g radarcol.gif xxwwqq.gif -d0 -o -fmakepal.gif
gifstrip xxwwqq.gif xxwwqq.inc
db xxwwqq.inc radarcol.inc
copy radarcol.inc \as
del xxwwqq.*
del radarcol.inc

alchemy -g xmode.gif xxwwqq.gif -d0 -o -fmakepal.gif
gifstrip xxwwqq.gif xxwwqq.inc
db xxwwqq.inc xmodecol.inc
copy xmodecol.inc \as
del xxwwqq.*
del xmodecol.inc

