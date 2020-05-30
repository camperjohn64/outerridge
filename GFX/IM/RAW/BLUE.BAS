'INPUT " Palette file           : "; d$
'IF d$ = "" THEN d$ = "pal.pal"
'
'INPUT " Range        default 16: "; rng
'IF rng = 0 THEN rng = 16
'
'INPUT " XRef file name         : "; c$
'IF c$ = "" THEN c$ = "darken.xrf"

d$ = "makepal.pal"
c$ = "blue.inc"
rng = 32

DIM r%(256 * rng + 256), g%(256 * rng + 256), b%(256 * rng + 256)

GOSUB getpal

' Now find all conbinations for glenz/transparent polygons
' Colours with total intensity less than 15 are scrapped (63+63+63=189 max)

pels% = 256 * rng

' Find darkest colour ii% - (for low intensity scrapping)

dd% = 5000
ii% = 1

 FOR z% = 1 TO 255
  d% = r%(z%) + g%(z%) + b%(z%)
  IF d% < dd% THEN dd% = d%: ii% = z%
 NEXT z%

PRINT
PRINT " Generating darker colours"

 FOR x% = 0 TO rng - 1
 i = (x%) / (rng - 1)

  FOR z% = 0 TO 255
  qq% = z% + x% * 256 + 256

  r%(qq%) = (r%(z%) * i * .45):  ' this is the actual darken calculation
  g%(qq%) = (g%(z%) * i * .45)
  b%(qq%) = (b%(z%) * i * .45) + 5

  NEXT z%
 NEXT x%

dist% = 2

PRINT pels%; "new colours calculated"

' Collect and output cross referancing tables

PRINT "Writing cross referancing tables"

OPEN c$ FOR OUTPUT AS #1

 FOR z% = 0 TO rng - 2
 PRINT #1, "blue"; LTRIM$(RTRIM$(STR$(z%))); TAB(10); "db ";

  cc% = 0

  FOR x% = 0 TO 255
  qq% = 256 + z% * 256 + x%

   uu = 500000

   vv% = 0
   oo% = 255

  ' IF x% >= 32 AND x% < 192 THEN vv% = 32: oo% = 191
   IF z% = 31 THEN jj% = x%: GOTO skipit

   FOR rr% = vv% TO oo%
    ff = ABS(r%(rr%) - r%(qq%)) + ABS(g%(rr%) - g%(qq%)) + ABS(b%(rr%) - b%(qq%))
    IF ff < uu THEN uu = ff: jj% = rr%
   NEXT rr%
skipit:
   IF jj% = 0 THEN jj% = ii%
   PRINT #1, LTRIM$(RTRIM$(STR$(jj%)));
   cc% = cc% + 1
   IF cc% < 16 THEN PRINT #1, ",";
   IF cc% = 16 THEN PRINT #1, "": cc% = 0: IF x% <> 255 THEN PRINT #1, TAB(10); "db ";

  NEXT x%
  PRINT #1, ""
 NEXT z%

CLOSE #1
END

getpal:
OPEN d$ FOR BINARY AS #1

P$ = SPACE$(256 * 3): GET #1, , P$

FOR a = 0 TO 256 - 1
r%(a) = ASC(MID$(P$, a * 3 + 1, 1))
g%(a) = ASC(MID$(P$, a * 3 + 2, 1))
b%(a) = ASC(MID$(P$, a * 3 + 3, 1))
NEXT a

CLOSE #1
RETURN

