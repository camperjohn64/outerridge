if %6.==. goto exit

@echo off
echo BIF>ttreeq.bif
echo filename %1.%2>xx.xx
copy /Y ttreeq.bif+xx.xx
echo width      %5>xx.xx
copy /Y ttreeq.bif+xx.xx
echo height     %6>xx.xx
copy /Y ttreeq.bif+xx.xx
echo header       0>xx.xx
copy /Y ttreeq.bif+xx.xx
echo channels     1>xx.xx
copy /Y ttreeq.bif+xx.xx
echo order        g>xx.xx
copy /Y ttreeq.bif+xx.xx
echo leftpadding  0>xx.xx
copy /Y ttreeq.bif+xx.xx
echo rightpadding 0>xx.xx
copy /Y ttreeq.bif+xx.xx

del xx.xx
echo on

alchemy -o -b -g ttreeq.bif xxccddq.gif

del ttreeq.bif

gifstrip xxccddq.gif %3.%4

del xxccddq.gif

testlzw %3.%4 testqq.xxx
fc /b %1.%2 testqq.xxx

del testqq.xxx
:exit
@echo off
echo syntax for compression:  compit name extension
echo note: no . between name and extension
echo.
echo example: compit techno mod lxx bin 455 234
echo.
echo this will compress techno.mod into lxx.bin for use with the _decode_lzw
echo routine (not the LZW.EXE public domain program, but the .GIF format LZW
echo decompression method)
