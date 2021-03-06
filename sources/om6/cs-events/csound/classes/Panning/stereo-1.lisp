(in-package :om)

;;;===================================
;;; SPAT CLASSES
;;;===================================

(defclass! stereo-1
  (cs-spat-evt) 			
  (
   (source-code :initform
                 (load-buffer-textfile
                  (get-orc-source (get-orc "stereo-1"))
                  'textfile "append")
                 :allocation :class :type textfile :accessor source-code)
   (numchan :initform (or (get-orc-channels (get-orc "stereo-1")) 2) :allocation :class  :accessor numchan)
   (globals-list :initform (get-orc-globals (get-orc "stereo-1")) :allocation :class :type list :accessor globals-list)
   (macros-list :initform nil :allocation :class :type list :accessor macros-list)
   (orc-header :initform nil :allocation :class :type list :accessor orc-header)
   (InstID :initform 1  :allocation :class  :accessor InstID)
   
   ( afil	:type t
        	:initarg :afil 
        	:initform nil
        	:accessor afil)
   
   ( bal	:type number
        	:initarg :bal 
        	:initform 0.
        	:accessor bal)
   )
  (:documentation "
;=============================================================================
;		STEREO-1.orc
; STEREO PANNING WITH EQUAL POWER (HARMONIC)
;-----------------------------------------------------------------------------

;	p1	= instrument number
;	p2	= action time [sec]
;	p3	= duration [sec]
;	p4 	= input (file)
;	p5	= stereo panning, equal power [-1=L, 1=R]

;	AFIL	= filename
;	BAL	= panning [-1=L, 1=R]

")
  (:icon 3001)
  )




