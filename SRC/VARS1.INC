;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : vars1.inc
; Included from: 3D1.ASM
; Description  : Defined Variables for 3D1.ASM
;
; Written by: John McCarthy
;             1316 Redwood Lane
;             Pickering, Ontario.
;             Canada, Earth, Milky Way (for those out-of-towners)
;             L1X 1C5
;
; Internet/Usenet:  BRIAN.MCCARTHY@CANREM.COM
;         Fidonet:  Brian McCarthy 1:229/15
;   RIME/Relaynet: ->CRS
;
; Home phone, (905) 831-1944, don't call at 2 am eh!
;
; John Mccarthy would really love to work for a company programming Robots
; or doing some high intensive CPU work.  Hint. Hint.
;
; Send me your protected mode source code!
; Send me your Objects!
; But most of all, Send me a postcard!!!!
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

                   align 4

; table of current limitations/restraints - to be used as reference by  user
; at run-time to determine if object code has been assembled with ample room
; for data/variables/point/surfaces etc...

                   align 4
_toughness         dw maxobjects+1 dup (0)
_bitbase           dd numberofbitmaps dup (0) ; memory locations of _bitmaps
_xreftable         dd numberofpals dup (0);o _nullpalette) ; offsets to palette cross referance tables

currobj            dd ?                     ; current object number (for shading)
xad                dd ?                     ; 3d offset of object
yad                dd ?
zad                dd ?

                   align 4

finalzed           dd maxobjects dup (?)    ; final z for sort routine
makeorder          dd maxobjects dup (?)    ; order for objects, bubble sorted
zedthis            dd ?                     ; final z temp

xradar             dd maxobjects+1 dup (0)  ; 2 = done all
yradar             dd maxobjects+1 dup (0)  ; 1 = done x and z
zradar             dd maxobjects+1 dup (0)  ; 0 = done z only
whatdone           db maxobjects+1 dup (0)

; temp storage for object routine

_type              db maxobjects+1 dup (0)
_timerq            dw maxobjects+1 dup (0)
_whatreal          dw maxobjects+1 dup (0)
_whatbase          dw maxobjects+1 dup (0)

; virtual locations/objects

                   align 4
v_whatshape        dw maxobjects+1 dup (0)  ; shapes of objects or bitmaps (0,1,2...)
v_bitobjx          dw maxobjects+1 dup (0)  ; bitmap additional scaling x
v_xs               dd maxobjects+1 dup (0)  ; locations of objects
v_ys               dd maxobjects+1 dup (0)
v_zs               dd maxobjects+1 dup (0)
v_vxs              dw 0,0                   ; angle of camera
v_vys              dw 0,0
v_vzs              dw 0,0
v_onoff            db maxobjects+1 dup (0)  ; is object on/off
                   dd 0                     ; buffer, leave this here dragon breath!

; variables for multiple object routine, you modify these!

                   align 4
_whatshape         dw maxobjects+1 dup (0)  ; shapes of objects or bitmaps (0,1,2...)
_bitobjx           dw maxobjects+1 dup (0)  ; bitmap additional scaling x
_xs                dd maxobjects+1 dup (0)  ; locations of objects
_ys                dd maxobjects+1 dup (0)
_zs                dd maxobjects+1 dup (0)
_vxs               dw 0,0                   ; angle of camera (then nme)
_vys               dw 0,0
_vzs               dw 0,0
_onoff             db maxobjects+1 dup (0)  ; is object on/off
                   dd 0

                   align 4

_xadds             dd maxobjects+1 dup (0)  ; linear velocities of objects
_yadds             dd maxobjects+1 dup (0)
_zadds             dd maxobjects+1 dup (0)
_vxadds            dw 0
_vyadds            dw 0
_vzadds            dw 0

; camera variables = was last object in object list, now is zero'th

eyex               equ d [v_xs+cameraobject*4] ; camera location (actual, dont modify)
eyey               equ d [v_ys+cameraobject*4]
eyez               equ d [v_zs+cameraobject*4]
eyeax              equ w [v_vxs+cameraobject*2] ; angles for camera
eyeay              equ w [v_vys+cameraobject*2]
eyeaz              equ w [v_vzs+cameraobject*2]

_eyex              equ d [_xs+cameraobject*4] ; camera location (virtual, modify these!)
_eyey              equ d [_ys+cameraobject*4]
_eyez              equ d [_zs+cameraobject*4]
_eyeax             equ w [_vxs+cameraobject*2] ; angles for camera
_eyeay             equ w [_vys+cameraobject*2]
_eyeaz             equ w [_vzs+cameraobject*2]

_eyexadds          equ d [_xadds+cameraobject*4] ; eye location velocity
_eyeyadds          equ d [_yadds+cameraobject*4]
_eyezadds          equ d [_zadds+cameraobject*4]

                   align 4

_ecosx             dd ?                     ; multipliers of eyeax and eyeaz
_esinx             dd ?                     ; reset at begining of each new frame
_ecosy             dd ?
_esiny             dd ?
_ecosz             dd ?
_esinz             dd ?


vcosx              dd ?                     ; temp storage for object matrix calculation
vsinx              dd ?                     ; can be used if needed during draw
vcosy              dd ?
vsiny              dd ?
vcosz              dd ?
vsinz              dd ?

_ematrix           dd 9 dup (?)             ; 3x3 rotation matrix for eye (32 bit)

; clipping variables in memory locations, pre-calculated!
; xactual and yactual basically don't change but clipping can to allow
; windows (rear view mirror, view airplanes menu, auxilary views, rear gunner)

_cliplt            dw _xcenter+xmin         ; _xcenter+xmin
_cliprt            dw _xcenter+xmax-1       ; _xcenter+xmax-1
_cliptp            dw _ycenter+ymin         ; _ycenter+ymin
_clipbt            dw _ycenter+ymax-1       ; _ycenter+ymax-1

_xcent             dw _xcenter
_ycent             dw _ycenter
_ycents1           dw _ycenter-1
_ycentp1           dw _ycenter+1

xmaxxcent          dw xmax+_xcenter

ymaxycent          dw ymax+_ycenter

_xmins             dw xmin
_xmins1            dw xmin-1
_xmaxs             dw xmax
_xmaxs1            dw xmax-1

_ymins             dw ymin
_ymins1            dw ymin-1
_ymaxs             dw ymax
_ymaxs1            dw ymax-1

xmit               dd xmin-tolerance        ; tolerance is max object size/ratio
xmat               dd xmax+tolerance
ymit               dd ymin-tolerance
ymat               dd ymax+tolerance

; routines for screen stretching

_make3d            dd offset _user3d        ; calculate 3d ?actual*?/z (both x and y)
_make3dx           dd offset _user3dx       ; xactual*x/z
_make3dy           dd offset _user3dy       ; yactual*y/z

; variables for icon scale routine

_bitmap            dd ?
_scale_destwidth   dw ?
_scale_destheight  dw ?
_scale_destx       dw ?
_scale_desty       dw ?

     public _bitbase
     public _xreftable

     public _xs
     public _ys
     public _zs
     public _xadds
     public _yadds
     public _zadds
     public _vxs
     public _vys
     public _vzs
     public _whatshape
     public _bitobjx
     public _vxadds
     public _vyadds
     public _vzadds

     public _eyex
     public _eyey
     public _eyez
     public _eyeax
     public _eyeay
     public _eyeaz
     public _eyexadds
     public _eyeyadds
     public _eyezadds

     public _onoff

     public _ematrix
     public _ecosx
     public _esinx
     public _ecosy
     public _esiny
     public _ecosz
     public _esinz

     public _bitmap
     public _scale_destwidth
     public _scale_destheight
     public _scale_destx
     public _scale_desty

     public _cliplt
     public _cliprt
     public _cliptp
     public _clipbt
     public _xcent
     public _ycent
     public _xmins
     public _xmins1
     public _xmaxs
     public _xmaxs1
     public _ymins
     public _ymins1
     public _ymaxs
     public _ymaxs1

     public _make3d
     public _make3dx
     public _make3dy

     public _timerq
     public _whatreal
     public _whatbase
     public _toughness
     public _type

