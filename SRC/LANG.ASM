;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
; Filename     : LANG.asm
; Included from: Main Assembley module
; Description  : Main OutRidge Game Language Text Strings
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

         .386p
         jumps

         bv3r = 3dh
         bv4r = 3eh
         bv5r = 3ch
         bv6r = 3bh
         bv7r = 3ah
         bv3u = 1dh
         bv4u = 1eh
         bv5u = 1ch
         bv6u = 1bh
         bv7u = 1ah
         bv8u = 1fh

code32   segment para public use32
         assume cs:code32, ds:code32

         include equ.inc

         public _messaged
         public _messagef
         public _message1
         public _modvol
         public _message2
         public _sfxvol
         public _message8
         public _message9
         public _message3a
         public _message3b
         public _messageca
         public _messagecb
         public _messagee
         public _scaletext
         public _messageg
         public _messagepower1
         public _messagepower2
         public _messagepower3
         public _messagepower4
         public _messagepower5
         public _messagepower6
         public _messagepower8
         public _shipsay
         public _badfile1
         public _nomemmod
         public _badwad
         public _moufnd
         public _mouno
         public _loemem
         public _shipnum
         public _say_level
         public _numlevel
         public _level_names
         public _message5
         public _message6a
         public _message6b
         public _messageaa
         public _messageab
         public _message4
         public _message7
         public _messageb
         public _messaged
         public _messagef
         public _messagel
         public _end_text1
         public _end_text2
         public _mousething
         public _order_text

_mousething    dd o e_mousename    , o g_mousename
_messaged      dd o e_messaged     , o g_messaged
_messagef      dd o e_messagef     , o g_messagef
_message1      dd o e_message1     , o g_message1
_modvol        dd o e_modvol       , o g_modvol
_message2      dd o e_message2     , o g_message2
_sfxvol        dd o e_sfxvol       , o g_sfxvol
_message8      dd o e_message8     , o g_message8
_message9      dd o e_message9     , o g_message9
_message3a     dd o e_message3a    , o g_message3a
_message3b     dd o e_message3b    , o g_message3b
_messageca     dd o e_messageca    , o g_messageca
_messagecb     dd o e_messagecb    , o g_messagecb
_messagee      dd o e_messagee     , o g_messagee
_scaletext     dd o e_scaletext    , o g_scaletext
_messageg      dd o e_messageg     , o g_messageg
_messagepower1 dd o e_messagepower1, o g_messagepower1
_messagepower2 dd o e_messagepower2, o g_messagepower2
_messagepower3 dd o e_messagepower3, o g_messagepower3
_messagepower4 dd o e_messagepower4, o g_messagepower4
_messagepower5 dd o e_messagepower5, o g_messagepower5
_messagepower6 dd o e_messagepower6, o g_messagepower6
_messagepower8 dd o e_messagepower8, o g_messagepower8
_shipsay       dd o e_shipsay      , o g_shipsay
_badfile1      dd o e_badfile1     , o g_badfile1
_nomemmod      dd o e_nomemmod     , o g_nomemmod
_badwad        dd o e_badwad       , o g_badwad
_moufnd        dd o e_moufnd       , o g_moufnd
_mouno         dd o e_mouno        , o g_mouno
_loemem        dd o e_loemem       , o g_loemem
_shipnum       dd o e_shipnum      , o g_shipnum
_say_level     dd o e_say_level    , o g_say_level
_numlevel      dd o e_numlevel     , o g_numlevel
_level_names   dd o e_level_names  , o g_level_names
_message5      dd o e_message5     , o g_message5
_message6a     dd o e_message6a    , o g_message6a
_message6b     dd o e_message6b    , o g_message6b
_messageaa     dd o e_messageaa    , o g_messageaa
_messageab     dd o e_messageab    , o g_messageab
_message4      dd o e_message4     , o g_message4
_message7      dd o e_message7     , o g_message7
_messageb      dd o e_messageb     , o g_messageb
_messagel      dd o e_messagel     , o g_messagel
_end_text1     dd o e_end_text1    , o g_end_text1
_end_text2     dd o e_end_text2    , o g_end_text2
_order_text    dd o e_order_text   , o g_order_text

e_mousename db "_Init_Mouse: $"
e_message1  db "MOD Volume:"
e_modvol    db 15 dup (0),0
e_message2  db "Sound Effects Volume:"
e_sfxvol    db 15 dup (0),0
e_message8  db "Mouse Control Selected",0
e_message9  db "Joystick Control Selected and Calibrated",0
e_message3a db "Thrust Method:SLIDING",0
e_message3b db "Thrust Method:GRIPPING",0
e_messageca db "Inverse Control",0
e_messagecb db "Normal Control",0
e_messagee  db "Controller Speed Adjust: "
e_scaletext db "000",0
e_messageg  db "No NME's",0

 if registered eq yes
e_message5  db "New MOD Selected",0
e_message6a db "God Mode ON",0
e_message6b db "God Mode OFF",0
e_messageaa db "Bonuses WILL Blow Up",0
e_messageab db "Bonuses WILL NOT Blow Up",0
e_message4  db "Bonus City!",0
e_message7  db "All Asteroids Full Stop",0
e_messageb  db "You're A Total Cheater",0
e_messaged  db "Dual Super Schnot! WOW!",0
e_messagef  db "Superfast Weapons",0
 elseif registered eq no
e_messageaa:
e_messageab:
e_message4:
e_message7:
e_messageb:
e_messaged:
e_messagef:
e_message6a:
e_message6b:
e_message5  db "Cheat Keys Unavailable In SHAREWARE Version",0
 endif

e_messagepower1 db "PowerUP!",0
e_messagepower2 db "Double Power!",0
e_messagepower3 db "Dual Cannons!",0
e_messagepower4 db "Yes, Rockets, GRRRR...",0
e_messagepower5 db "Oh my GOD, It's the All Illusive Super-Schnot!",0
e_messagepower6 db "Level Complete - Entering Hyperspace",0
e_messagepower8 db "Extra Ship!",0
e_shipsay       db "Ships Remaining: "
e_shipnum       db "01",0
e_say_level     db "Entering Sector "
e_numlevel      db "00 - ",26 dup (0)

e_badfile1 db 13,10,"Fill out the ORDER.DOC form and send to:",13,10
           db 13,10," GraphicWares         or    Wizard Software"
           db 13,10," c/o Jeff Lawton            c/o Ralph Trynor"
           db 13,10," 2411 Chapman Ct.           P.O. Box 1129"
           db 13,10," Augusta, GA. 30909         Westbrook, ME. 04098-1129"
           db 13,10," USA                        USA"
           db 13,10,""
           db 13,10,"          Orders : (800) 688-7049"
           db 13,10,"      FAX orders : (207) 856-1602"
           db 13,10,"    Tech support : (706) 737-2235 (207) 856-1603"
           db 13,10,"   Support BBS's : (706) 737-2190 (207) 856-7186"
           db 13,10,"$"

e_messagel db "English Language Selected",0
e_nomemmod db "Not enough GUS memory for MODs",13,10,"$"
e_badwad   db 13,10,"Bad external .WAD file: Aborting.",13,10,"$"
e_moufnd   db "Detected",13,10,"$"
e_mouno    db "Not Detected",13,10,"$"
e_loemem   db 13,10,"Not enough memory!",13,10,13,10
           db "Need 1,723,668 bytes free (GUS or No Sound)",13,10
           db "  or 2,103,668 bytes free (Sound Blaster)",13,10,"$"

e_end_text1:
 if registered eq yes or crack eq yes
db 1
db "                ",2,bv4r,"OUTER RIDGE",2,0,", a killer 3-D game by John McCarthy.",1
db "        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ",1
db "             YOU ARE PLAYING THE REGISTERED VERSION OF ",2,bv4r,"OUTER RIDGE!",2,0,1
db 1
db "       If you haven't paid for ",2,bv4r,"OUTER RIDGE",2,0,", may you be cursed by the  god",1
db "       of eternal foot odor. We can't make these games for free you know!",1
db "       Do you really want to end up in jail?  It's cold and damp in those",1
db "       little cells.  And the food is  worse than  in  the  hospital.  So",1
db "       send us some cash - and be quick about it.  Fill out the ",2,bv7r,"ORDER.DOC",2,0,1
db "       form and mail it today!",1
db 1
db "       If you have registered ",2,bv4r,"OUTER RIDGE",2,0,", our accountants thank you. And",1
db "       all the people we owe money to also  thank  you.   The  registered",1
db "       version of ",2,bv4r,"OUTER RIDGE",2,0," can be ordered from:",1
db 1
db "         ",2,bv6r,"GraphicWares",2,0,"              or    ",2,bv6r,"Wizard Software",2,0,1
db "         ",2,bv6r,"2411 Chapman Ct.",2,0,"                ",2,bv6r,"P.O. Box 1129",2,0,1
db "         ",2,bv6r,"Augusta, GA. 30909, USA",2,0,"         ",2,bv6r,"Westbrook, ME. 04098-1129, USA",2,0,1
db 1
db "         ",2,bv5r,"Voice Orders :",2,0," (800) 688-7049, ",2,bv5r,"FAX Orders:",2,0," (207) 856-1602",1
db "         ",2,bv5r,"Tech Support :",2,0," (706) 737-2235, (207) 856-1603",1
db "         ",2,bv5r,"Support BBS's:",2,0," (706) 737-2190, (207) 856-7186",1
db 0

 endif
e_end_text2:
 if registered eq no

db 1
db "                ",2,bv4u,"OUTER RIDGE",2,0,", a killer 3-D game by John McCarthy.",1
db "        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ",1
db "              YOU ARE PLAYING THE SHAREWARE VERSION OF ",2,bv4u,"OUTER RIDGE!",2,0,1
db 1
db "       This shareware version of ",2,bv4u,"OUTER RIDGE",2,0," may be  freely  distributed.",1
db "       Go on, upload it.  It's really big and you'll  get  lots  of  file",1
db "       points (to download  other  stuff).  Although I don't know why you",1
db "       would want to play anything else but this.  So  don't  let  anyone",1
db "       else beat you to it.  UPLOAD it today!",1
db 1
db "       Of course the alternative is to ",2,bv7u,"ORDER",2,0," the  ",2,bv5u,"REGISTERED",2,0,"  version  of",1
db "       ",2,bv4u,"OUTER RIDGE",2,0,".  More great weapons that couldn't  possibly  exist in",1
db "       real life, more graphics, harder levels, even  cheat  codes!  Fill",1
db "       out the ",2,bv7u,"ORDER.DOC",2,0," file to get the full version of ",2,bv4u,"OUTER RIDGE!",2,0,1
db 1
db "         ",2,bv6u,"GraphicWares",2,0,"              or    ",2,bv6u,"Wizard Software",2,0,1
db "         ",2,bv6u,"2411 Chapman Ct.",2,0,"                ",2,bv6u,"P.O. Box 1129",2,0,1
db "         ",2,bv6u,"Augusta, GA. 30909, USA",2,0,"         ",2,bv6u,"Westbrook, ME. 04098-1129, USA",2,0,1
db 1
db "         ",2,bv5u,"Voice Orders :",2,0," (800) 688-7049, ",2,bv5u,"FAX Orders:",2,0," (207) 856-1602",1
db "         ",2,bv5u,"Tech Support :",2,0," (706) 737-2235, (207) 856-1603",1
db "         ",2,bv5u,"Support BBS's:",2,0," (706) 737-2190, (207) 856-7186",1
db 0
 endif

g_level_names:
e_level_names:
           db "DEMO",0
           db "Shoot 10 Asteroids",0
           db "Don't Stand Still",0
           db "Cannons Can Kill",0
           db "Suicide Run",0
           db "Death Door",0
           db "Bonus Blow Up",0
           db "Solo Guild",0
           db "Krake",0
           db "DOOMed",0
           db "Schnot City",0
           db "Slimed",0
           db "Hero's Demise",0
           db "Crushed",0
           db "Virus on D:",0
           db "Schmooze",0
           db "Black Blood",0
           db "Barbourosa",0
           db "Plak SiMMs",0
           db "Busted Guts",0
           db "Toughest Yet!",0
           db "NME Hell",0
           db "X-Machine",0
           db "Grind",0
           db "Pulp Masters",0
           db "Gusher",0
           db "Treskelion",0
           db "Simply Impossible",0
           db "Vicious Circle",0
           db "Fat Man",0
           db "Little Boy",0
           db "Slam 'n Run",0
           db "Nuked",0
           db "Burned Alive",0
           db "Slammed",0
           db "Flame Face",0
           db "Brain Food",0
           db "Scorched",0
           db "Skeleton",0
           db "Eternal Void",0
           db "Dark Invader",0
           db "Death Bed",0
           db "Bonus Sector",0

g_mousename db "_Init_Maus: $"
g_message1  db "MUSIK Volume:"
g_modvol    db 15 dup (0),0
g_message2  db "Sound Effekte Volume:"
g_sfxvol    db 15 dup (0),0
g_message8  db "Maus Steuerung",0
g_message9  db "Joystick Steuerung. Kalibriert",0
g_message3a db "Schub Methode: GLEITEN",0
g_message3b db "Schub Methode: GRIFFIG",0
g_messageca db "Steuerung Umgekehrt",0
g_messagecb db "Steuerung NORMAL",0
g_messagee  db "Geschw. Justierung: "
g_scaletext db "000",0
g_messageg  db "Keine NME's",0

 if registered eq yes
g_message5  db "Neue Musik",0
g_message6a db "Gott Modus AN",0
g_message6b db "Gott Modus AUS",0
g_messageaa db "Bonus zerplatzt",0
g_messageab db "Bonus zerplatzt nicht",0
g_message4  db "Bonus Stadt!",0
g_message7  db "Alle Asteroiden volle Kanne",0
g_messageb  db "Du hast komplett Betrogen",0
g_messaged  db "Doppelter Super ROTZ! WOW",0
g_messagef  db "Superschnelle Waffen",0
 elseif registered eq no
g_messageaa:
g_messageab:
g_message4:
g_message7:
g_messageb:
g_messaged:
g_messagef:
g_message6a:
g_message6b:
g_message5  db "Cheats in der SHAREWARE nicht vorhanden!",0
 endif

g_messagepower1 db "PowerUP!",0
g_messagepower2 db "Doppel Power!",0
g_messagepower3 db "Doppel Kanonen!",0
g_messagepower4 db "Ja, Raketen, GRRRR...",0
g_messagepower5 db "Oh weia! Das ist der totale Super-ROTZ!",0
g_messagepower6 db "Level komplett - ab in den Hyperraum",0
g_messagepower8 db "Extra Schiff!",0
g_shipsay       db "Restliche Schiffe: "
g_shipnum       db "01",0
g_say_level     db "Eindringen in Sektor "
g_numlevel      db "00 - ",26 dup (0)

g_badfile1 db 13,10,"Fllen Sie einfach die Datei BESTELL.TXT aus,"
           db 13,10,"faxen uns diese zu, oder rufen uns an.",13,10
           db 13,10,"  Jergen Egeling Computer  oder   ZAC-SOFT"
           db 13,10,"  Waldstr. 49                      Thomas Kuhn"
           db 13,10,"  Deutschland                      Postfach 150"
           db 13,10,"  76133 Karlsruhe                  CH 8903 Birmensdorf"
           db 13,10,"  Tel.: 0729 20 31 83              Tel.: 01 737 07 94"
           db 13,10,"  FAX : 0729 20 31 85              FAX : 01 737 32 01"
           db 13,10,"$"

g_messagel db "Deutsche Sprache",0
g_nomemmod db "Nicht genug GUS Speicher!",13,10,"$"
g_badwad   db 13,10,"Falsche .WAD Datei: Abbruch!",13,10,"$"
g_moufnd   db "Gefunden",13,10,"$"
g_mouno    db "Nicht gefunden",13,10,"$"
g_loemem   db 13,10,"Nicht genug Speicher!",13,10,13,10
           db "Brauche 1,723,668 bytes frei (GUS oder Kein Sound)",13,10
           db "   oder 2,103,668 bytes frei (Sound Blaster)",13,10,"$"

g_end_text1:
 if registered eq yes or crack eq yes

db 1
db "                ",2,bv4r,"OUTER RIDGE",2,0,", a killer 3-D game by John McCarthy.",1
db "        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ",1
db "             SIE SPIELEN DIE REGISTRIERTE VERSION VON ",2,bv4r,"OUTER RIDGE!",2,0,1
db 1
db "       Wenn Sie nicht im Besitz einer  gltigen Lizenz  sind,  dann  ver-",1
db "       stoáen  Sie  gegen  das Copyrightgesetz. Zus„tzlich wird Sie unser",1
db "       Vodoo Priester mit 14  Tagen  Durchfall  belegen!  Sie k”nnen  dem",1
db "       nur entgehen, wenn Sie noch heute die Datei ",2,bv7r,"BESTELL.TXT",2,0,"  ausfllen",1
db "       und uns zuschicken. Oder rufen Sie bei uns an.",1
db 1
db "       Wenn  Sie  registrierter  Benutzer sind, dann m”chten wir uns noch",1
db "       einmal recht herzlich bei Ihnen bedanken.",1
db 1
db "       Wir  hoffen  ",2,bv4r,"OUTER RIDGE",2,0,"  macht  Ihnen beim Spielen so viel Freude",1
db "       wie es uns Freude beim Programmieren gemacht hat.",1
db 1
db "               ",2,bv6r,"Jergen Egeling Computer            ZAC-SOFT",2,0,1
db "               ",2,bv6r,"Waldstr. 49                         Thomas Kuhn",2,0,1
db "               ",2,bv6r,"D 76133 Karlsruhe                   Postfach 150",2,0,1
db "               ",2,bv5r,"Tel.: ",2,0,"0721 9 20 31 83               ",2,bv6r,"CH 8903 Birmensdorf",2,0,1
db "               ",2,bv5r,"FAX : ",2,0,"0721 9 20 31 85               ",2,bv5r,"Tel.: ",2,0,"01 737 07 94",1
db "               ",2,bv5r,"BBS : ",2,0,"0721 37 46 25                 ",2,bv5r,"FAX : ",2,0,"01 737 32 01",1
db 0

 endif
g_end_text2:
 if registered eq no

db 1
db "                ",2,bv4u,"OUTER RIDGE",2,0,", a killer 3-D game by John McCarthy.",1
db "        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ",1
db "             SIE SPIELEN DIE SHAREWARE VERSION VON ",2,bv4u,"OUTER RIDGE",2,0,"!",1
db 1
db "       Diese   Shareware   Version   von  ",2,bv4u,"OUTER  RIDGE",2,0,"  k”nnen  Sie  frei",1
db "       weiterkopieren,  solange  Sie  sich  an  die  Lizenzvereinbarungen",1
db "       halten,  die  in  der Datei ",2,bv3u,"LIZENZ.TXT",2,0," zusammengefasst sind. Geben",1
db "       Sie  das  Programm  an  Ihre  Freunde  weiter,  und  laden Sie das",1
db "       Programm auf so viele BBS wie m”glich.",1
db 1
db "       Natrlich  sollten  Sie  sich auch registrieren. Sie erhalten dann",1
db "       MEHR  WAFFEN,  MEHR  MUSIC,  MEHR GRAFIK und Tricks, mit denen Sie",1
db "       immer weiter kommen.",1
db 1
db "       Fllen Sie einfach die Datei ",2,bv7u,"BESTELL.TXT",2,0," aus, faxen uns diese  zu,",1
db "       oder rufen uns an.",1
db 1
db "               ",2,bv6u,"Jergen Egeling Computer            ZAC-SOFT",2,0,1
db "               ",2,bv6u,"Waldstr. 49                         Thomas Kuhn",2,0,1
db "               ",2,bv6u,"76133 Karlsruhe                     Postfach 150",2,0,1
db "               ",2,bv5u,"Tel.: ",2,0,"0721 9 20 31 83               ",2,bv6u,"CH 8903 Birmensdorf",2,0,1
db "               ",2,bv5u,"FAX : ",2,0,"0721 9 20 31 85               ",2,bv5u,"Tel.: ",2,0,"01 737 07 94",1
db "      ",2,bv8u,"         ",2,bv5u,"BBS : ",2,bv8u,"0721 37 46 25                 ",2,bv5u,"FAX : ",2,bv8u,"01 737 32 01     ",1
db 0
 endif

e_order_text:
         dw 25,110+15
         db "Order   the  registered   version   of   OUTER",0
         dw 25,122+15
         db "RIDGE today! Complete the ORDER.DOC form",0
         dw 25,134+15
         db "and send it to:",0
         dw 55,155+15
         db "GraphicWares",0
         dw 55,167+15
         db "2411 Chapman Ct.",0
         dw 55,179+15
         db "Augusta, GA. 30909, USA",0
         dw 45,198+15
         db "or:",0
         dw 55,216+15
         db "Wizard Software",0
         dw 55,229+15
         db "P.O. Box 1129",0
         dw 55,241+15
         db "Westbrook, ME. 04098-1129, USA",0
         dw 55,265+15
         db "Voice Orders",0
         dw 139,265+15
         db ": 1-800-688-7049",0
         dw 55,277+15
         db "FAX Orders",0
         dw 139,277+15
         db ": 207-856-1602",0
         dw -1

g_order_text:
         dw 30,110+15
         db "Bestellen Sie noch heute die registrierte",0
         dw 30,122+15
         db "Version von outer ridge!  Lesen  die  Datei",0
         dw 30,134+15
         db "bestell.txt und bestell.ch!",0
         dw 55,155+15
         db "J",5,"ergen Egeling Computer",0
         dw 55,167+15
         db "Waldstr. 49",0
         dw 55,179+15
         db "D 76133 Karlsruhe",0
         dw 55,179+12+15
         db "Tel",0
         dw 79,179+12+15
         db ": 0721 9 20 31 83",0
         dw 55,179+24+15
         db "FAX",0
         dw 79,179+24+15
         db ": 0721 9 20 31 85",0
         dw 45,198+15+15+12
         db "oder:",0
         dw 55,216+15+15+12
         db "ZAC-SOFT",0
         dw 55,229+15+15+12
         db "Thomas Kuhn",0
         dw 55,241+15+15+12
         db "Postfach 150",0
         dw 55,253+15+15+12
         db "CH 8903 Birmensdorf",0
         dw 55,253+12+15+15+12
         db "Tel",0
         dw 79,253+12+15+15+12
         db ": 01 737 07 94",0
         dw 55,253+24+15+15+12
         db "FAX",0
         dw 79,253+24+15+15+12
         db ": 01 737 32 01",0
         dw -1

         ends
         end
