; OMChroma
; High-level control of sound synthesis in OM
;
;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.
;
;See file LICENSE for further informations on licensing terms.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,10 USA.
;
; (c) Ircam 2000 - 2017
;Authors: C. Agon, M. Stroppa, J. Bresson, S. Lemouton


(in-package :cr)
 

(om::defclass! cs-array (om::class-array om::timed-object)
  ((source-code :initarg :source-code :accessor source-code :initform nil :documentation "a Csound orchestra [pathname or string]")
   (cs-instr :accessor cs-instr :initform nil)
   (instr-num :initarg :instr-num :accessor instr-num :initform 1 :documentation "a csound instrument number [int]")
   ;;; repeat this slot from OM superclass, so that it appears on the box
   (om::elts :initarg :elts :accessor om::elts :initform 1 :type integer :documentation "number of elements (components) for the event")
   ;;; (orc-gens :accessor orc-gens :initform nil)
   (precision :accessor precision :initform 4 :documentation "float precision in the Csound score"))
  (:documentation 
"
CS-ARRAY is a special type of OM class-array, which initializes its fields automatically from a Csound instrument (#<instr-num>) found in <source-code>.
Each p-field in the Csound instrument #<instr-num> (starting at p2: onset) becomes a field in the array. 

In order to better initialize the array, the Csound code can contain formatted information in comment lines:

; @PARAM <i> <name> <type> <defval> <doc>

... where
- i is the Csound p-field number
- name is a string designating the corresponding name for the CS-ARRAY slot to be created
- type is a Lisp type-designator for the CS-ARRAY slot to be created
- defval is the default value for the CS-ARRAY slot to be created
- doc is a string containing some firef documentation for the CS-ARRAY slot to be created

"))


;; will appear as a keyword input (must be a valid slot)
(defmethod om::additional-class-attributes ((self cs-array)) '(precision))
;; user-defined 'extra-control' will be proposed as additional keyword
(defmethod om::allow-extra-controls ((self cs-array)) t)
;; declare existing slots of the class/subclass that are considered additional fields of the array 
(defmethod additional-slot-array-fields ((self cs-array)) nil)

;;; in a cs-array rows 0 and 1 are always onset and duration
(defmethod om::get-obj-dur ((self cs-array)) 
   (let ((duration (loop for onset in (om::get-field self 0)
                     for dur in (om::get-field self 1)
                     maximize  (+ onset dur) into max-elt-dur
                     finally (return max-elt-dur))))
     (om::sec->ms duration)   ;; + action-time
     ))


;;; in specific cases (e.g. 2D or 3D trajectories in omprisma) there can be more csoudn fields than actual array fields
;;; => 1 array fields creates 2 or 3 table-fields
(defmethod num-csound-fields ((self cs-array))
  ;(om::fields self)
  (cs-description-num-pfields (cs-instr self)))

(defmethod get-all-inits ((self cs-array))
  (append 
   (cs-description-global-vars (cs-instr self))
   (cs-description-macros (cs-instr self))
   (cs-description-opcodes (cs-instr self))
   ))

(defmethod get-cs-descriptions ((source string))
  (with-open-stream (s (make-string-input-stream source))
    (parse-csound-instruments s)))

(defmethod get-cs-descriptions ((source pathname))
  (when (om::file-exists-p source)
    (with-open-file (s source)
      (parse-csound-instruments s))))

(defmethod get-cs-descriptions ((source t)) nil)
  


(defmethod init-array-from-csound-instr ((self cs-array) (instr-data cs-description))
  
  (let ((num-pfields (cs-description-num-pfields instr-data))
        (params (cs-description-params instr-data))
        (gens (cs-description-gens instr-data)))
   
    ;;; set the fields from csound instrument (will rule data filling in class-array)
    (when (integerp num-pfields)
      (setf (slot-value self 'om::data) 
            (append 
             ;;; csound orc fields
             (loop for i from 0 to (- num-pfields 2) ;; 'useful' pfields start at p2 (p1 = instr num) 
                   collect 
                   (let* ((pn (+ i 2)) 
                          (param (find pn params :key 'cs-param-description-num))
                          (precision (if (listp (precision self)) (or (nth i (precision self))
                                                                      (car (last (precision self)))) ;; if list too short: repeat last elem
                                      (precision self)))
                          (name (if param (cs-param-description-name param)
                                  (format nil "p~D" pn))))

                     ;;; pre-set the data with meta-info in the orc files
                     ;;; the actual data will be completed/filled in the class-array's initialization
                     (om::make-array-field :name name 
                                           :type (and param (cs-param-description-type param))
                                           ;; loading text-formated cs-tables require om::omng-load
                                           :default (and param (om::omng-load (cs-param-description-defval param)))
                                           :doc (and param (cs-param-description-doc param))
                                           :decimals precision))
                   )
             
             ;;; additional 'control' fields
             (loop for additional-field in (additional-slot-array-fields self)
                   collect 
                   (let ((slot (find additional-field (om::class-slots (class-of self)) :key 'om::slot-name)))
                     (if slot 
                         (om::make-array-field 
                          :name (symbol-name (om::slot-name slot)) 
                          :type (om::slot-type slot)
                          :default (om::slot-initform slot)
                          :doc (om::slot-doc slot))
                       (om::make-array-field :name (symbol-name additional-field)))))
             )
            ))

    (setf (om::field-names self) (mapcar 'om::array-field-name (om::data self)))
              
    ;;; the gen-tables from the orc-header
    ;;; (setf (orc-gens self) gens)
             
    ))

;;; can be defined as defval in the csound orchestra
(defmethod om::om-load-from-id ((id (eql :cs-table)) data)

  (let* ((gentype (car data))
         (xy-points (om::find-value-in-arg-list (cdr data) :points))
         (split-xy (om::mat-trans xy-points))
         (size (om::find-value-in-arg-list (cdr data) :size))
         (dec (om::find-value-in-arg-list (cdr data) :decimals)))
         
    (make-instance gentype 
                   :x-points (car split-xy)
                   :y-points (cadr split-xy)
                   :size size
                   :decimals (or dec 5))
    ))



(defmethod om::om-init-instance ((self cs-array) &optional initargs)
  
  ;; INITARGS = NIL means we are loading a saved object (data is already in)
  ;; IF SOURCE CODE IS NOT IN, THEN IT IS A SUBCLASS WHERE THIS SLOT IS NOT DIRECTLY ACCESSIBLE
  (when (find :source-code initargs :key 'car) 
    (setf (cs-instr self) (find (instr-num self) 
                                (get-cs-descriptions (source-code self)) 
                                :test '= :key 'cs-description-instr-num)))
  
  (when (and (cs-instr self) 
             (null (om::data self))) ;; if data is already in, it means we're in a copy
    (init-array-from-csound-instr self (cs-instr self)))
 
  ;;; do the class-array init (fill the data with inputs)
  (call-next-method)

  self)

