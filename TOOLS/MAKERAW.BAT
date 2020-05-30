tasm /kh10000 %1
tlink /3 /x %1
strip %1.exe %1.raw -i512
del %1.exe
del %1.obj
