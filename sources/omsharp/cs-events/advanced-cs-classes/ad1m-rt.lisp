;******************************************************************
;		     CLASS AD1M
;******************************************************************
; Example of advanced class

(in-package :cr)

;;; Define base class from Csound ORC
(defclass-from-cs-orc (merge-pathnames "ad1m.orc" *load-pathname*))

;;; Extension with additional global slots and array fields
;;; additional fields are used for the some parsing predefined-methods

(defclass! ad1m-x (ad1m)
  
  (;; redefinition (identical) of some slots so that they appear on the box
   (om::elts :initarg :elts :accessor om::elts :initform 1 :documentation "number of elements (csound 'notes')")
   (action-time :initarg :action-time :accessor action-time :initform 0 :documentation "an offset used to time several events together")
   (user-fun :initarg :user-fun :accessor user-fun :initform nil 
             :documentation "a lambda patch or function to process internal elements at synthesis time")
            
   ;; additional 'global' slots
   ( durtot :type number 
            :initform 1.0
            :accessor durtot :initarg :durtot
            :documentation "Total duration for the whole event [sec]")
   ( amptot :type number
            :initform -6.0
            :accessor amptot :initarg :amptot
            :documentation "Global amplitude scaler [0-1]")
   
   ;; additiopnal array fields, not for csound!
   ( npart :type number
           :initform 3
           :accessor npart)
   ( ston :type number
          :initform 0.06
          :accessor ston)
   ( ed2 :type number
         :initform 0.01
         :accessor ed2)
   ( dur2 :type number
          :initform -1
          :accessor dur2)
   ( amp2 :type number
          :initform -1
          :accessor amp2))
  
  (:documentation
   "
Extension of the instrument ADD1m, class ad1m-rt.

Added global slots:
  durtot [sec] = total duration of the whole event
  amptot [0-1000 or dB] = global amplitude scaler

Added local slots:
  npart [int] = number of sub-components
  ston [0-1]  = maximum frequency deviation for the sub-components
		positive = linear distribution (value in %)
		negative = logarithmic distribution (value in semitones)
  ed2 [sec]   = entry delay of each sub-component (cumulative effect) 
  dur2 [0-1]  = duration of each sub-component (scaler of DURTOT) (-1)
                   (if <0, use the value of the main component)
  amp2 [0-1]  = amplitude of each sub-component (scaler of AMPTOT) (-1)
                   (if <0, use the value of the main component)
"
   )
  )


;;; declare the additional fields:
(defmethod additional-slot-array-fields ((self ad1m-x)) '(npart ston ed2 dur2 amp2))
