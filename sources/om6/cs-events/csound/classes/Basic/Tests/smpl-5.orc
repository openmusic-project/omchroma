;=============================================================================
;		SMPL-5.ORC
; SAMPLER READING FROM A DEFERRED TABLE WITH LOOP / MONO
; AMPLITUDE ENVELOPE WITH POSCIL
; FIXED TRANSPOSITION
;=============================================================================

; Timbre:       Reading a sound file into a deferred table, with transposition
; Synthesis:    Sampler, flooper2
; Coded:     	ms 3/09

; This instrument will loop through a deferred GEN01 table (deferred tables
;   exactly match the duration of the sound file).
; If the duration in the score is longer than the file, it will read the file
;   until loop-end, then loop between loop-beg and loop-end until the end
;   of the note's duration.

; NB: NEW STRUCTURE FOR THE AMPLITUDES FROM AUGUST 2008!
;    Positive value > 0.0  : linear amplitude (>0.0-1000.0)
;    0.0 or negative value : amplitude in dB (0 = maximum value)

; The apparently arbitrary amplitude range (0-1000, rather than 0-1)
;     avoids printing small values with exponential notation

; Default SR = 96000, recommended precision: 24 bits
;-----------------------------------------------------------------------------
;	p1	= instrument number
;	p2	= action time [sec]
;	p3	= duration [sec]
;	p4	= max amplitude [linear, >0.0-1000.0 or dB, <= 0.0]
;	p5	= frequency [>=0, 1=same as original, 0.5=octave below, 2=octave above]
;	p6	= sound file [GEN01]
;	p7	= starting point in the table [sec]
;	p8	= amplitude envelope [GEN]
;	p9	= beginning of loop [sec]
;	p10	= end of loop [sec]
;	p11	= crossfade length [sec]
;	p12	= loop mode: 0=fwd, 1=bkwd, 2=fwd+bkwd
;-----------------------------------------------------------------------------
; COMPULSORY GEN FUNCTIONS :
;	f19	bell-shaped curve
;_____________________________________________________________________________

; CLASS: SMPL-5

;  GLOBAL KEYWORDS (default values within parentheses):
;	NUMROWS		: amount of rows (components) in the event (1)
;	ACTION-TIME	: start time of the whole event [sec] (0.0)
;	USER-FUN	: user-defined parsing function (nil)

;  LOCAL KEYWORDS:
;   E-DELS	: entry delays [sec] (0.0)
;	DURS	: duration [sec] (1.0)
;	AMP 	: amplitude [lin, >0.0-1000.0 or dB <- 0.0] (0.0)
;	F0  	: transposition factor [1=same freq] (2.0)
;	AFIL	: file name [int, string or pathname] (santuri_96.aiff)
;	SKIP	: starting point in the file [sec] (0.0)
;	AENV	: fun number for the amp envlp [GEN] (straight line=1)
;	LPBEG	: starting loop point [sec] (0.2)
;	LPEND	: ending loop point [sec] (0.7)
;	WIN 	: crossfade length [sec] (0.5)
;	MODE	: loop mode [0=fwd, 1=bkwd, 2=fwd+bkwd] (2)
;*****************************************************************************

sr	= 96000
kr	= 96000
ksmps	= 1
nchnls	= 1

;0dbfs = 32767	; 16 bits
0dbfs = 8388607	; 24 bits

instr 1 ; -------------------------------------------------------------

idur	= p3
idurosc	= 1/idur
iamp 	= (p4 > 0.0 ? (p4*0.001*0dbfs) : (ampdbfs (p4)))
iamp	= iamp/0dbfs ; since sfile is not normalized, reduce amp between 0 and 1
ixpf	= p5
ifile	= p6	; must be a GEN01
iskip	= p7	; secs

iaenv	= p8	; global amplitude envelope
ilpbeg	= p9
ilpend	= p10
ilpxf	= p11
ilpmode	= p12

iskp	= 0 ; do not skip initialization

isigfun	= 19	; sigmoid function
;OUTBEG
;OUTEND

; global amplitude envelope
k3	poscil	iamp, idurosc, iaenv ; file reading

;a1	lposcil	1.0, ixpf, ilpbeg, ilpend, ifile, iphs
a1	flooper2	1.0, ixpf, ilpbeg, ilpend, ilpxf, ifile, iskip, ilpmode, isigfun, iskp

asound	= a1*k3

;OUTBEG
out     asound
;OUTEND

endin