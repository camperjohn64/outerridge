make -flib\3d1
make -flib\main

make -flib\3dvect
make -flib\user
make -flib\sfx

tlink /3 /x pmode 3d1 main, outridge ,, lib\3dvect lib\sfx lib\user

