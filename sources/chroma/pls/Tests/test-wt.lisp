;-----------------------------------------------------------------------------
; WTDIR: directory where the WT sounds are to be found

(setenv WTdir
        (make-pathname :directory
                       '(:absolute "Users-S1" "Marco-sons" "WT")))

;-----------------------------------------------------------------------------
;wtest1 = Cb-104	          arco,soave,mult
;bass-104_44m.aiff      44100 1 1.91997s 84671 aiff short
;main pitches: 931 (Sib5), 376.5 Hz

(setf t1 (make_wt "test1_44m.aiff" (getenv 'WTdir)))
(set-freq_wt t1 `(,(pch-sp "SIb5") 376.5))
(set-beg-off_wt t1 0.0)
(set-end-off_wt t1 1.73)
(set-dur-att_wt t1 0.0)
;-----------------------------------------------------------------------------
;wtest2 = Cb-106	        arco,soave,mult (componentes menos agudas que I4)
;bass-106_44m.aiff      44100 1 2.3657s 104328 aiff short

(setf t2 (make_wt "test2_44m.aiff" (getenv 'WTdir)))
(set-freq_wt t2 `(,(pch-sp "LA5") ,(pch-sp "RE4") ,(pch-sp "SI5") ))
(set-beg-off_wt t2 0.0)
(set-end-off_wt t2 2.3657)
(set-dur-att_wt t2 0.0)
;-----------------------------------------------------------------------------
;wtest3 = Cb-72	               rough ribattuto
;bass-72_44m.aiff      44100 1 4.4023s 194144 aiff short

(setf t3 (make_wt "test3_44m.aiff" (getenv 'WTdir)))
(set-freq_wt t3 '(1))
(set-beg-off_wt t3 0.0)
(set-end-off_wt t3 4.4023)
(set-dur-att_wt t3 0.0)
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
(add-field_wt t1 'NEW 100)
(field_wt t1 'NEW)
(set-field_wt t1 'NEW 200)
(rm-field_wt t1 'NEW)

(is-field_wt t1 'NEW)

(prnt t1)
(short-prnt t1)
;-----------------------------------------------------------------------------
(file-name_wt t1)
(dir_wt t1)
(abs-file_wt t1)

(n-ch_wt t1)
(sr_wt t1)
(pk-mode_wt t1)
(n-smpls_wt t1)
;-----------------------------------------------------------------------------
(freq_wt t1)
(nth-freq_wt t1 2)
(nth-freq_wt t1 -2) ; first fq nevertheless
(nth-freq_wt t1 20) ; ()
(last-freq_wt t1)
(close-freq_wt t1 500)

(set-freq_wt t1 `(,(pch-sp "SIb5") 376.5))
(set-si_wt t1 '(2 1 3 4 5))
(is-si_wt t1)

;-----------------------------------------------------------------------------
(set-beg-off_wt t1 0.5)
(set-end-off_wt t1 1.5)
(beg-off_wt t1)
(end-off_wt t1)

(dur_wt t1)
(phys-dur_wt t1)

; DURATION WITH SI = 0.5
(dur_wt t1 0.5)

; DURATION WHEN PLAYING A FQ OF 500HZ WITH REFERENCE FROM THE
;    CLOSEST FQ TO IT IN THE FQ LIST OF THE WT-OBJECT
(dur_wt t1 (si_wt 500.0 (close-freq_wt t1 500)))
(dur_wt t1 (si_wt 500.0 (nth-freq_wt t1 1)))

(phys-dur_wt t1 0.1)

;-----------------------------------------------------------------------------
; ATTACK PORTION OF THE SOUND
(set-dur-att_wt t1 0.1)
(dur-att_wt t1)
(phys-dur-att_wt t1)
(phys-dur-att_wt t1 0.5)

(att_wt t1)

; RANDOM VARIATION [SEC] AROUND ATT APPLIED WHEN CALLING att_wt
;    CLIPPED TO 0.0 IF BELOW 0.0
(set-var-att_wt t1 0.6)
(var-att_wt t1)

(set-beg-off_wt t1 0.999)
(set-dur-att_wt t1 10.1)

;-----------------------------------------------------------------------------
; WINDOW
(set-win-from_wt t1 10.1)
(set-win-phys-from_wt t1 10.1)
(win-from_wt t1)
(win-phys-from_wt t1)

(win-size_wt t1 0.5)

; CLIPPED TO THE VALUE OF MIN-SIZE
(set-win-size_wt t1 0.01)
(set-win-size_wt t1 0.9)

(win-min-size_wt t1)
(set-win-min-size_wt t1 0.1)

(win-from_wt t1)
(win-size_wt t1)
(win-to_wt t1)
(win-phys-from_wt t1)
(win-phys-to_wt t1)

; RETURN A CONS WITH STARTING POINT AND VALUE OF SIZE
(win_wt t1)
(phys-win_wt t1)

; ARGS - STARTING AND ENDING POINT OF WINDOW FROM BEGOFF OR BEG OF FILE
(set-win_wt t1 0.1 1.1)
(set-phys-win_wt t1 0.1 1.1)


;-----------------------------------------------------------------------------
; FILTER/FADE
(set-flt_wt t1 10000.0)
(flt_wt t1)

(set-fade_wt t1 '(0.1 0.2))
(fade_wt t1)
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
