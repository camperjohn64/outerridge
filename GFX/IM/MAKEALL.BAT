call makepal
call makeasm
call makelzw
call makenums
call maketext
call makecopy

cd\su
call makegif

cd \as\raw
qb /run dark.bas
qb /run blue.bas
call dk.bat
cd \as\data
call maker.bat
cd ..
outridge -d
