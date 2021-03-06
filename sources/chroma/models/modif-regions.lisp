;=====================================================
; CHROMA 
;=====================================================
; part of the OMChroma library
; -> High-level control of sound synthesis in OM
;=====================================================
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
;=====================================================

(in-package :cr)

;MODIFICATIONS DES REGIONS :



(defmethod tempo-map ((model regions) fun &key (mode 0) (fun2 fun) &allow-other-keys)
;&optional random

"
Modify a model's tempo using a function.
The function can be applied to the regions'
  (0) start time + duration together or separately (fun2 applied to dur)
  (1) start time only
  (2) duration only

   model = chroma model
   fun = object of type fun (1 = no change, 2 = twice as slow)
   :mode (0) = mode of action (see action above)
   :fun2 (fun) = optional function to be used
"
(let ((map-fun (copy-list fun))
      new-starts new-ends)
  
  (X-resc_fun fun2 (begin-time model) (end-time model))
  
  (case mode
    (0 (setf new-starts (mapcar (lambda (x) (y-val_fun map-fun x)) (startlist model))
             new-ends (mapcar (lambda (x)(y-val_fun map-fun x)) (endlist model))
             (region-list model) (build-region-list (namelist model) new-starts new-ends))))
  ))


