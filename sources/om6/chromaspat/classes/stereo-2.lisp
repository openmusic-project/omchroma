(in-package :om)

;;;===================================
;;; SPAT CLASSES
;;;===================================

(defclass! stereo-2
  (cs-spat-evt) 			
  (
   (source-code :initform
                 (load-buffer-textfile
                  (get-orc-source (get-orc "stereo-2" :local))
                  'textfile "append")
                 :allocation :class :type textfile :accessor source-code)
   (numchan :initform (or (get-orc-channels (get-orc "stereo-2")) 2) :allocation :class  :accessor numchan)
   (globals-list :initform (get-orc-globals (get-orc "stereo-2")) :allocation :class :type list :accessor globals-list)
   (macros-list :initform nil :allocation :class :type list :accessor macros-list)
   (orc-header :initform nil :allocation :class :type list :accessor orc-header)
   (InstID :initform 1  :allocation :class  :accessor InstID)
   
   ( afil	:type t
        	:initarg :afil 
        	:initform nil
        	:accessor afil)
   
   ( Channel1	:type number
        	:initarg :Channel1 
        	:initform 1.0
        	:accessor Channel1)
   ( Channel2	:type number
        	:initarg :Channel2 
        	:initform 0.0
        	:accessor Channel2)
   )
  (:documentation "
;=============================================================================
;		STEREO-2.ORC
; INDEPENDENT PANNING, 1 SLOT/CHANNEL
;-----------------------------------------------------------------------------

;	p1	= instrument number
;	p2	= action time [sec]
;	p3	= duration [sec]
;	p4 	= input (file)
;	p5	= Ch 1 level [0-1]
;	p6	= Ch 2 level [0-1]

;	AFIL		= filename
;	CHANNEL1	= amplitude [0-1, 1]
;	CHANNEL2	= amplitude [0-1, 0]

")
  (:icon 3001)
  )




