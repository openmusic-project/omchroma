(in-package :om)

(defclass cs-spat-evt (cs-evt) ()
  (:default-initargs :durs 0))

(defmethod set-data ((self cs-spat-evt))
  (call-next-method)
  (auto-dur self))

(defmethod auto-dur ((self cs-spat-evt))
  (let ((durvalue (get-control-value self "durs")))
    (when (and (get-control-value self "soundfile") 
               (or (not durvalue)
                   (and (numberp durvalue) (= durvalue 0))))
      (let ((dur-row (label2index self "durs")))
        (setf (nth dur-row (data self))
              (mapcar 'sound-dur (get-array-row self "soundfile")))
        ))
    self))


;;; PFIELDS TO IGNORE WHEN DOING SPATIAL SOUND SYNTH
(defmethod ignore-pfields ((self cs-spat-evt)) nil)
             
(defmethod merge-orchestras ((synth cs-evt) (spat cs-spat-evt))
  (let* ((synthorc (source-code synth))
         (spatorc (source-code spat))
         (p-index (length (class-direct-instance-slots (class-of synth)))) ;;; nb params (from p4)
         (intername "asound")
         (spatvars '("p4"))
         (ignore-fields (ignore-pfields spat))
         (ignore-aux nil)
         (continue t)
         (synthlines nil) (spatlines nil))
    (setf synthlines 
          (loop for sline in (om-buffer-lines (buffer-text synthorc))
                collect 
                (let ((srep (and (not (string-equal "" (delete-spaces sline)))
                                 (let ((firstword (string-until-space sline)))
                                   (when (and (>= (length firstword) 3) 
                                              (string-equal "out" (subseq firstword 0 3)))
                                     (search "out" firstword :test 'string-equal)
                                     )))))
                  (if srep 
                      (multiple-value-bind (outword ll) (read-from-string sline nil nil :start srep)
                        (let ((outval (subseq sline ll (position #\, sline))))
                          (string+ intername "  =  " outval)))
                    sline)
                  )))
    (setf spatlines 
          (loop for sline in (om-buffer-lines (buffer-text spatorc))
                collect 
                (let ((tokens (start-at-first (tokenize-line sline))))
                  ;(print (list tokens spatvars ignore-aux))
                  (loop for spatvar in spatvars do
                        (when (find spatvar tokens :test 'string-equal)
                          ;;; one of the variables containing input is in this line
                          (let ((pos (position spatvar tokens :test 'string-equal)))
                            ;(print tokens)
                            (if (> pos 0) 
                                ;; something is probably set using a "spatvar"
                                (let* ((oppos (if (string-equal (delete-spaces (nth (- pos 1) tokens)) "") 2 1))
                                       (op (nth (- pos oppos) tokens))
                                       (varpos (if (string-equal (delete-spaces (nth (- pos oppos 1) tokens)) "")
                                                   (+ oppos 2) (+ oppos 1)))
                                       (var (nth (- pos varpos) tokens)))

                                  (if (and continue 
                                           (or (string-equal op "=")
                                               (search "diskin" op :test 'string-equal)))
                                      (setf spatvars (append spatvars (list var))
                                            tokens nil)
                                    (setf tokens (substitute intername spatvar tokens :test 'string-equal))
                                    )
                                  (when (search "diskin" op :test 'string-equal)
                                    (setf continue nil))
                                  )
                              ;; the spatvar is set to something else
                              ;(setf (nth pos tokens) intername)
                              (setf tokens (substitute intername spatvar tokens :test 'string-equal))
                              ))
                          ))
                  ;(print (list ignore-fields ignore-aux))
                  (loop for ig in (append ignore-fields ignore-aux)
                        while tokens do
                        (when (find ig tokens :test 'string-equal)
                          ;(print (list ig tokens))
                          (let ((pos (position ig tokens :test 'string-equal))
                                (vvv nil))
                            (when (> pos 0) 
                              (loop for spatvar in spatvars while (not vvv) do
                                    (setf vvv (find spatvar tokens :test 'string-equal)))
                              (if vvv 
                                  (push (car tokens) spatvars)
                                (unless (or (member (car tokens) (cons intername spatvars) :test 'string-equal)
                                            (member (car tokens) *csound-separators* :test 'string-equal :key 'string))
                                  (push (car tokens) ignore-aux)))
                                (setf tokens nil)))
                          ))
                  
                  (when tokens (loop for pfield in (find-pn tokens) do
                                     (when (> (cadr pfield) 3) 
                                       (setf (nth (car pfield) tokens) 
                                             (format nil "p~D" (- (+ p-index (cadr pfield)) 
                                                                  (length ignore-fields) 
                                                                  1)))))) ;; -1 because p4 disappears
                  (reduce 'string+ tokens :initial-value "")
                  )))

    (append synthlines spatlines)
    ))


(defparameter *csound-separators* '(#\) #\( #\[ #\] #\{ #\} #\, #\* #\+ #\- #\/ #\? #\: #\< #\> #\= #\;))

(defun tokenize-line (line)
  (let* ((str line))
    (remove nil 
            (loop while (not (string-equal str ""))
                  collect
                  (let ((cc (elt str 0)))
                    (cond ((or (char-equal cc #\Space) (char-equal cc #\Tab))
                           (let ((token ""))
                             (loop while (and (not (string-equal str ""))
                                              (or (char-equal cc #\Space) (char-equal cc #\Tab)))
                                   do
                                   (setf token (concatenate 'string token (string cc)))
                                   (setf str (subseq str 1))
                                   (unless (string-equal str "") (setf cc (elt str 0)))
                                   )
                             token))
                          ((member cc *csound-separators*)
                           (setf str (subseq str 1))
                           (string cc))
                          (t (let ((token ""))
                               (loop while (and (not (string-equal str ""))
                                                (not (char-equal cc #\Space))
                                                (not (char-equal cc #\Tab))
                                                (not (member cc *csound-separators*))) do
                                     (setf token (concatenate 'string token (string cc)))
                                     (setf str (subseq str 1))
                                     (unless (string-equal str "") (setf cc (elt str 0)))
                                     )
                               token)))))
            )))


(defun start-at-first (token) 
  (if (string-equal (delete-spaces (car token)) "")
      (cdr token)
    token))

(defun find-pn (tokens)
  (let ((rep nil))
    (loop for item in tokens 
          for pos = 0 then (+ pos 1) do
          (when (and (char-equal (elt item 0) #\p)
                     (> (length item) 1)
                     (numberp (read-from-string (subseq item 1))))
            (pushr (list pos (read-from-string (subseq item 1))) rep)))
    rep))


(defparameter *prisma-spat-classes* nil)

(defmethod merged-class-superclass (class)
  (let ((clist (mapcar 'class-name (get-class-precedence-list class))))
    (or (remove nil 
                (list (find-if #'(lambda (class) (find class *prisma-spat-classes*)) clist)
                      (find 'spat-trajectory-evt-3D clist)
                      (find 'spat-trajectory-evt-2D clist)
                      (find 'cs-spat-evt clist)))
        'cs-evt)))


;;; ADD e-dels, durs, and soundfile
(defmethod number-of-ignored-slots-in-merge ((self cs-spat-evt))
  (+ (length (ignore-pfields self)) 3))


(defmethod merge-get-define-slot ((Self Omslot) newname)
  (let ((name (or newname (name self))))
    (list (internp name (slot-package self)) ':initform  (theinitform self)  
          ':initarg (string2initarg name)
          ':type (read-thetype self) ':allocation (alloc self) ':documentation (doc self)
          ':accessor (internp name (slot-package self)))))
     
(defmethod! chroma-spat-defclass (classname (synth cs-evt) (spat cs-spat-evt))
  :icon 322
  (let ((orc (merge-orchestras synth spat))
        (nout (numchan spat))
        ;(globals (append (globals-list synth) (globals-list spat)))
        ;(macros (append (macros-list synth) (macros-list spat)))
        (inits (append (cs-inits synth) (cs-inits spat)))
        (gens (append (orc-header synth) (orc-header spat)))
        (superclasses (merged-class-superclass (class-of spat)))
        classdef class)
    
      (let ((newinits (solve-init-duplicates inits))
            ;(macs (resoudre-duplicatas macros :macro))
            ;(globs (resoudre-duplicatas globals :global))
            )
            
        (setf classdef
              (print `(defclass! ,classname (,.superclasses)
                          ((source-code :initform 
                                       (let ((orcbuffer (make-instance 'textfile)))
                                         (add/replace-to-buffer orcbuffer ',orc)
                                         orcbuffer)
                                       :allocation :class :type textfile :accessor source-code)
                          (numchan :initform ,nout :allocation :class  :accessor numchan)
                          ;(globals-list :initform ',globs :allocation :class :type list :accessor globals-list)
                          ;(macros-list :initform ',macs :allocation :class :type list :accessor macros-list)
                          (cs-inits :initform ',newinits :allocation :class :type list :accessor cs-inits)
                          (orc-header :initform ',gens :allocation :class :type list :accessor orc-header)
                          (InstID :initform 1  :allocation :class  :accessor InstID)
                          ,.(mapcar #'(lambda (slot) `(,(slot-name slot) :accessor ,(slot-name slot) :initarg ,(slot-name slot) 
                                                                         :type ,(slot-definition-type slot) :initform ,(slot-definition-initform slot)))
                                    (class-direct-instance-slots (class-of synth)))
                          ;,.(mapcar #'(lambda (slot) `(,(slot-name slot) :accessor ,(slot-name slot) :initarg ,(slot-name slot) 
                          ;                                               :type ,(slot-definition-type slot) :initform ,(slot-definition-initform slot)))
                          ;          (nthcdr (+ 1 (length (ignore-pfields spat))) 
                          ;                  (class-direct-instance-slots (class-of spat))
                          ;                  ))
                          ,.(mapcar #'(lambda (slot) 
                                        (let ((newname (name slot)))
                                          (loop while (find newname (class-direct-instance-slots (class-of synth)) :test 'string-equal :key 'slot-name) do
                                                (setf newname (string+ newname "_+")))
                                          (merge-get-define-slot slot newname)))
                                    (nthcdr (number-of-ignored-slots-in-merge spat)
                                            (get-all-instance-initargs (type-of spat))
                                            ))
                          
                          ))))
        (setf class (eval classdef))
        (let ((instance (make-instance class)))
          (setf (source-code instance) (let ((orcbuffer (make-instance 'textfile)))
                                         (add/replace-to-buffer orcbuffer orc)
                                         orcbuffer))
          (setf (numchan instance) nout)
          ;(setf (globals-list instance) globs)
          ;(setf (macros-list instance) macs)
          (setf (cs-inits instance) newinits)
          (setf (orc-header instance) gens)
          )
        
        class)))



(defmethod! chroma-prisma ((synth cs-evt) (spat cs-spat-evt) &key name force-redefine)
  :icon 322
  (let ((classname (or name 
                       (intern (concatenate 'string 
                                            (string (name (class-of synth))) 
                                            ">>"
                                            (string (name (class-of spat)))) :om)))
        (ncols (max (numcols synth) (numcols spat)))
        (onset (action-time synth))
        (pfun (or (and (get-parsing-fun synth) (get-parsing-fun spat)
                                          #'(lambda (self i)
                                              (when (functionp (get-parsing-fun synth))
                                                (funcall (get-parsing-fun synth) self i))
                                              (when (functionp (get-parsing-fun spat))
                                                (funcall (get-parsing-fun spat) self i))))
                  (get-parsing-fun synth) (get-parsing-fun spat)))
        (instance nil))
    (when (or (not (find-class classname nil)) force-redefine)
      (chroma-spat-defclass classname synth spat))
    (setf instance (make-instance classname :numcols ncols))
    (setf rep (cons-array instance 
                    (list nil ncols onset pfun)
                    (append 
                      (list 'e-dels (slot-value synth 'e-dels)
                            'durs (slot-value synth 'durs))
                      (loop for s1 in (class-direct-instance-slots (class-of synth)) append
                            (list (slot-name s1) (slot-value synth (slot-name s1))))
                      (loop for s2 in 
                            ;;;(nthcdr (+ 1 (length (ignore-pfields spat))) (class-direct-instance-slots (class-of spat))) 
                            ;;;append
                            ;;;(list (slot-name s2) (slot-value spat (slot-name s2)))
                            (nthcdr (number-of-ignored-slots-in-merge spat)
                                    (get-all-instance-initargs (type-of spat)))
                            append
                            (let ((sl-name (internp (name s2) (slot-package s2))))
                              (list sl-name (slot-value spat sl-name)))
                            )
                      )
                     ))
    (setf (Lcontrols rep) (clone (append (Lcontrols synth) (Lcontrols spat))))
    (setf (precision rep) (max (list-max (list! (precision synth))) (list-max (list! (precision spat)))))
    (set-data rep)
    rep
    ))

;;; compat 
(defmethod! chroma-spat ((synth cs-evt) (spat cs-spat-evt) &key name force-redefine)
  (chroma-prisma synth spat :name name :force-redefine force-redefine))



