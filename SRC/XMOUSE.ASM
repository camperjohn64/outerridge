;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Filename     : More.inc
; Included from: Main assembley module
; Description  : X mode Mouse routines
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

         .386p
         jumps

code32   segment para public use32
         assume cs:code32, ds:code32

         include pmode.ext                  ; protected mode externals
         include xmode.ext                  ; include externals for xmode routines
         include clear.ext
         include macros.inc

         public _show_mouse
         public _get_mouse_position
         public _mousex
         public _mousey
         public _mousebuttons

         public _ismouse
         public _mousex1
         public _mousex2
         public _mousey1
         public _mousey2

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; x-mode mouse routines in protected mode for 3d vectors source
;
; _show_mouse (int x, int y, int xclipl, int xclipr, int yclipt, int yclipb)
; _get_mouse_position
; _plot_mouse
; _remove_mouse
; _instant_mouse
;
; after ploting mouse, _sync_display is not called
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_ismouse      db -1  ; is mouse present?
_mousex1      dw ?
_mousex2      dw ?   ; clipping parameters
_mousey1      dw ?
_mousey2      dw ?
_mousex       dw 0   ; mouse location, buttons
_mousey       dw 0
_mousebuttons dw 0

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; _show_mouse (int x, int y, int xclipl, int xclipr, int yclipt, int yclipb)
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

sm_stack struc
         dd ?                               ; ebp
         dd ?                               ; caller
         my2       dw ?
         my1       dw ?
         mx2       dw ?
         mx1       dw ?                     ; clipping parameters of mouse
         setm_ypos dw ?                     ; y pos of mouse
         setm_xpos dw ?                     ; x pos of mouse
sm_stack ends

_show_mouse:
         push ebp
         mov v86r_ax,0                      ; enable mouse
         mov al,33h
         int 33h
         mov ah,v86r_ah                     ; check if hardware/driver installed
         xor ah,255
         mov _ismouse, ah
         jne sm_nomouse                     ; no mouse, exit

         mov ebp, esp                       ; set up stack frame
         mov cx, [ebp].setm_xpos
         mov dx, [ebp].setm_ypos

         mov v86r_ax,4                      ; position mouse
         mov v86r_cx,cx
         mov v86r_dx,dx
         int 33h

         mov ebp, esp                       ; set up stack frame
         mov cx, [ebp].mx1
         mov dx, [ebp].mx2

         mov v86r_ax,7                      ; set screen size
         mov v86r_cx,cx
         mov v86r_dx,dx
         int 33h                            ; *2 gives greater resolution!!!!!

         mov ebp, esp                       ; set up stack frame
         mov cx, [ebp].my1
         mov dx, [ebp].my2

         mov v86r_ax,8
         mov v86r_cx,cx
         mov v86r_dx,dx
         int 33h

         mov v86r_ax,15                     ; set mouse mickeys (8 = default)
         mov v86r_cx,8
         mov v86r_dx,8
         int 33h

sm_nomouse:
         pop ebp
         ret 12

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; Guess what this does?
; In = none
; Out = cx = mouse x
;       dx = mouse y
;       bx = mouse buttons
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

_get_mouse_position:
         cmp _ismouse,0
         jne _ret
         mov v86r_ax,3                      ; call bios routines
         mov al,33h
         int 33h
         mov bx,v86r_bx                     ; button status, mid right left=%111
         mov cx,v86r_cx                     ; coloum
         mov dx,v86r_dx                     ; row
         mov _mousebuttons,bx               ; save button status
         mov _mousex,cx
         mov _mousey,dx

         ret

code32   ends
         end
