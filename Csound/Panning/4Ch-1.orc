;;=============================================================================
;;			4CH-1.ORC : panning with 4 channels
;;-----------------------------------------------------------------------------
;;
;; Speakers position (azimuth):
;;  1: 0 
;;  2: 90 
;;  3: 180
;;  4: 270

;-----------------------------------------------------------------------------
; PARAM DESCRIPTION :
; @PARAM 2 "e-dels" number 0.0 "action time [sec]"
; @PARAM 3 "durs" number 1.0 "duration [sec]"
; @PARAM 4 "afil" t nil "sound input"
; @PARAM 5 "bal" number 0.0 "panning, equal power [Azimuth, degree]"
;-----------------------------------------------------------------------------

;	p1	= instrument number
;	p2	= action time [sec]
;	p3	= duration [sec]
;	p4 	= input (file)
;	p5	= panning, equal power [Azimuth, degrees; 0=1, 90=2, 180=3, 270=4]


sr	= 96000
kr	= 96000
ksmps	= 1
nchnls	= 4

;0dbfs = 32767  ; 16 bits
0dbfs = 8388697 ; 24 bits


instr 1 ; -------------------------------------------------------------
 isp_dur		= p3
 isp_file		= p4
 isp_bal		= p5 % 360 ;reduce to 0-360º
 isp_bal		= (isp_bal < 0.0 ? (360+isp_bal) : isp_bal) ; turn negative vals into positive ones
 isp_mode		= 0 ; equal power (harmonic) panning
 isp_pch		= 1 ; no transposition
 isp_skptim		= 0 ; no skip time
 isp_wrap		= 0 ; no wrapping around file
 isp_format		= 0 ; 16-bit short integers (for headerless files)
 isp_wsize		= 128 ; point sinc interpolation with anti-aliasing (slow)
 isp_bufsize	= 262144 ; buffer size (larger values improve the efficiency of disk reads)
 isp_skpinit	= 0 ; do not skip initialization

aut1 init 0.0
aut2 init 0.0
aut3 init 0.0
aut4 init 0.0

 asound		diskin2	isp_file, isp_pch, isp_skptim, isp_wrap, isp_format, isp_wsize, isp_bufsize, isp_skpinit

; PANNING BEG
if ((isp_bal >= 0.0) && (isp_bal < 90.0)) goto quad1

if ((isp_bal >= 90.0) && (isp_bal < 180.0)) goto quad2

if ((isp_bal >= 180.0) && (isp_bal < 270.0)) goto quad3

if ((isp_bal >= 270.0) && (isp_bal < 360.0)) goto quad4

quad1:
aut1, aut2	pan2	asound, ((isp_bal % 90.0) / 90.0)
goto end

quad2:
aut2, aut3	pan2	asound, ((isp_bal % 90.0) / 90.0)
goto end

quad3:
aut3, aut4	pan2	asound, ((isp_bal % 90.0) / 90.0)
goto end

quad4:
aut4, aut1	pan2	asound, ((isp_bal % 90.0) / 90.0)

end:
         outq     aut1, aut2, aut3, aut4

; PANNING END


endin
