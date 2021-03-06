;******************************************************************
;           Test-part.lisp
; simple tests of the model partials
;-----------------------------------------------------------------------------
;                            VERSION FOR OMCHROMA 05
;                                   050304
;-----------------------------------------------------------------------------
; NB: TO USE THE CHROMA MODELS THE REPMUS LIBRARY MUST BE LOADED
;-----------------------------------------------------------------------------
(in-package cr)

;-----------------------------------------------------------------------------
;		PART 1 : SET THE GLOBAL PARAMETERS
;-----------------------------------------------------------------------------
        ; DIRECTORY WHERE THE ANALYSIS MODELS ARE TO BE FOUND
(setenv LLamod CRXdata)
;-----------------------------------------------------------------------------



;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;		PART 2C : LOAD ANALYSIS MODELS
;                     (NEW CHROMA 2005 !!)
;-----------------------------------------------------------------------------
; 2C1: CREATE AN ANALYSIS OBJECT

; AVAILABLE MODELS FOR ANALYSIS (SEE DOC-part FOR MORE INFORMATION):

;   CSEQ-DATA: CSEQ MODEL FROM AUDIOSCULPT
;   ADDITIVE-DATA: ADDITIVE MODEL FROM ADDAN OR AUDIOSCULPT
;   FO: FUNDAMENTAL FREQUENCY
;   SPECENV: SPECTRAL ENVELOPE

(format t "************************* TESTING PROCESS: SECTION 1~%")

(setf cseq-as
      (make-instance 'cseq-data 
        :file (make-pathname :directory (pathname-directory (getenv LLamod ))
                             :name "density_cseq" :type "sdif")))

(setf analysis-as 
      (make-instance 'additive-data 
        :file (make-pathname :directory (pathname-directory (getenv LLamod ))
                             :name "density_trc" :type "sdif")))

(setf analysis-aa
      (make-instance 'additive-data 
        :file (make-pathname :directory (pathname-directory (getenv LLamod ))
                             :name "density-diph_add" :type "sdif")))


; LOAD THE MARKERS INTO THE MODEL FROM THE MARKERS FILE
; SHOULD EVOLVE INTO AN OBJECT WITH SEGMENTATION POSSIBILITIES

(setf markers
      (load-markers-file
       (make-pathname :directory (pathname-directory (getenv LLamod ))
                      :name "density_mrk" :type "sdif")))


; AVAILABLE CSEQ MODELS FOR TESTING:
;   MODEL-CSEQ    : FROM A CSEQ ANALYSIS (MARKERS ARE NOT NEEDED)
;   MODEL-CSEQ-AS : FROM AN ADDITIVE ANALYSIS DONE WITH AUDIOSCULPT
;   MODEL-CSEQ-AA : FROM AN ADDITIVE ANALYSIS DONE WITH ADDAN

; THIS STRUCTURE ALLOWS FOR A MODEL COMING FROM SEVERAL ANAYSLIS FILES
;    (WHEN USING ADDITIVA ANALYSIS, MARKERS ARE NEEDED)
;-----------------------------------------------------------------------------
;                   MODEL-PARTIALS
;-----------------------------------------------------------------------------
;   KEYWORDS:
;       :cseq = WHEN IT IS THE ONLY ONE, THE ANALYSIS MUST BE A CSEQ ANALYSIS
;                  AND THE MARKERS WILL BE THE ONES CONTAINED IN THE STRUCTURE
;       :fql-list = LIST OF FQL'S
;       :add = ADDITIVE ANALYSIS OBJECT (MUST ALSO GIVE THE MARKERS)
;       :markers = LIST OF MARKERS
;       :sort (t) = SORTS THE FQL'S IN ASCENDING ORDER
;       :threshold (nil) = ELIMINATE COMPONENTS BELOW THRESHOLD [dB]
;       :threshmod (fql) = MODE OF OPERATION OF THE THRESHOLD
;           abs: ABSOLUTE AMPLITUDE (REFERENCE = 0)
;           rel: AMPLITUDE RELATIVE TO THE MAXIMUM OF A COMPONENT
;           fql: AMPLITUDE RELATIVE TO THE MAXIMUM WITHIN EACH FQL (PROBABLY
;                   BETTER FOR PSYCHOACOUSTIC REASONS)
;       :durmin (0.02) = (ADD ONLY) MINIMUM DURATION OF A COMPONENT.
;                            COMPONENTS WHOSE DURATION IS BELOW DURMIN WILL
;                            NOT BE LOADED INTO THE MODEL
;                            (SET IT TO 0.0 IF EVERYTHING IS NEEDED)



;NOT YET AVAILABLE (DOES NOT MAKE MUCH SENSE)
;(setf model-cseq (make-instance 'model-partials :cseq cseq-as))

(setf model-part-as
      (make-instance 'model-partials :add analysis-as
                     :markers markers))

(setf model-part-aa
      (make-instance 'model-partials :add analysis-aa
                     :markers markers))


; GET ALL THE FREQUENCIES
(loop for i in (fql-list model-part-as)
      collect (fql_vps i))
(loop for i in (fql-list model-part-aa)
      collect (fql_vps i))

; GET ALL THE AMPLITUDES
(loop for i in (fql-list model-part-as)
      collect (lintodb (amplitudes i)))
(loop for i in (fql-list model-part-as)
      collect (lintodb (amplitudes i)))

; GET ALL THE MAXIMUM AMPLITUDES PER FQL
(loop for i in (fql-list model-part-as)
      collect (apply #'max (lintodb (amplitudes i))))
(loop for i in (fql-list model-part-aa)
      collect (apply #'max (lintodb (amplitudes i))))

; COMPUTE THE OVERALL AMOUNT OF PARTIALS
(loop for i in (fql-list model-part-as)
      collect (length (fql_vps i)))
(loop for i in (fql-list model-part-as)
      collect (length (fql_vps i)))

(loop for i in (fql-list model-part-aa)
      collect (length (fql_vps i)))
(loop for i in (fql-list model-part-aa)
      collect (length (fql_vps i)))


(lintodb (get-max-amp model-part-aa))
(lintodb (get-max-amp model-part-as))


(format t "************************* TESTING PROCESS: SECTION 8~%")

; MODEL'S ACCESSORS
(total-duration model-part-as)
(total-duration model-part-aa)

;   RETURN THE MARKERS (ACTION TIME OF EACH SINGLE EVENT) OF THE WHOLE MODEL
(markers model-part-as)
(markers model-part-aa)

; MODEL'S METHODS
(durlist model-part-as)
(durlist model-part-aa)

(nev model-part-as)
(nev model-part-aa)


(format t "************************* TESTING PROCESS: SECTION 9~%")
; PART-MODELS'S ACCESSORS
(fql-list model-part-as)
(fql-list model-part-aa)

; PART-MODELS'S METHODS
(get-max-amp model-part-as)
(get-min-amp model-part-as)
(get-max-fq model-part-as)
(get-min-fq model-part-as)
(get-max-bw model-part-as)
(get-min-bw model-part-as)

(get-max-amp model-part-aa)
(get-min-amp model-part-aa)
(get-max-fq model-part-aa)
(get-min-fq model-part-aa)
(get-max-bw model-part-aa)
(get-min-bw model-part-aa)

(format t "************************* TESTING PROCESS: SECTION 10~%")
;  RETURN THE AMPLITUDES OF THE I'TH FQL NORMALIZED WITH RESPECT TO THE
;    WHOLE MODEL
(get-norm-amp model-part-as 1)
(get-norm-amp model-part-aa 1)

(get-fql-from-time model-part-as 1.0)
(get-fql-from-time model-part-aa 1.0)

(durlist model-part-as)
(durlist model-part-aa)

;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;		PART 3 : SPECIFY SOME AD-HOC CONTROL MODELS
;-----------------------------------------------------------------------------
; TEST OF THE TIME-VARYING PROCESSING
;-----------------------------------------------------------------------------
; THIS TEST SIMPLY TRIES TO REPRODUCE THE MODEL AS IS, WITHOUT ANY SPECIAL
;     PROCESSING
;-----------------------------------------------------------------------------
(setf ctl-a
      '(
; THIS FUNCTION DOES NOTHING, BUT IT COULD RANDOMLY VARY EACH E-DEL
        (E-DELS '(lambda(x)(ran-from 0.0 0.0)))
        
; USE AS A UNIQUE DURATION THE DURATION OF THE CURRENT MODEL
        (DURS (call get-model-ldur))
       
; MULTIPLY THE MODEL'S AMPLITUDES BY THE VALUE OF GBLAMP
        (AMP (call get-model-norm-gblamp))
; AMPLITUDE ENVELOPES
        (AENV (call get-model-amp_bpf
                    :reduction 32))    

; FETCH THE MODEL'S FREQUENCIES
        (FREQ (call get-model-fq))

; DECIMAL PRECISION IN WRITING THE CSOUND SCORE
        (lprecision 6)          

; FREQUENCY DEVIATION VALUE AND FUNCTION
        (FDEV (call get-model-dev+))
        (FENV (call get-model-transp_bpf    
                 :reduction 32
                 ))
        ))

;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;		PART 4 : COMPUTE THE ACTUAL EVENTS
;-----------------------------------------------------------------------------
; ELIMINATE ALL THE NOTES BELOW THIS DURATION
(set-gbl 'DURMIN 0.01)
;-----------------------------------------------------------------------------
; USE OM TO PERFORM THIS, EVALUATE THE LINES BELOW
;-----------------------------------------------------------------------------

(setf pl-1
      (ctl2 (make-instance 'om::add-a1) model-part-as ctl-a))

(setf pl-2
      (ctl2 (make-instance 'om::add-a1) model-part-aa ctl-a))

;******************************************************************

