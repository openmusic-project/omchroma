;;;;;;;;;;;;;;
;test de tbl
;;;;;;;;;;;;;;
(in-package :cr)

(setf pl '(hello serge!))
(setf lp (make_tbl))
(insert_tbl lp 'a 1)
(insert_tbl lp 'b 2)
(insert_tbl lp 'c 'a 11)
(insert_tbl lp 'c 'b pl)
(insert_tbl lp 'd 'pippo)

(setf lpp (make_tbl))

(key-list_tbl lp)

(lookup_tbl lp 'c 'c)
(lookup_tbl lp 'a)
(lookup_tbl lp 'c)

(insert_tbl lp 'd 'pippo)
(print_tbl lp)
(prnt lp)
(print lp)
(short-prnt lp)
(short-print_tbl lp)

(setf lpp (make_tbl))

(is-empty lpp)
(is-empty lp)
(is_tbl lp)
(is_tbl pl)
(is_tbl lpp)
(is-key_tbl lp `b)
(rm_tbl lp ())
(rm_tbl lp 'c 'b)
(rm_tbl lp 'z)
(is-key_tbl lp `b)
(short-prnt lp)
(prnt lp)
(is-empty lp)

;;;;;;;;;;;;;;
;test de ctl
;;;;;;;;;;;;;;

(setf dd (make_ctl))

(setf dd2 (make_ctl '(a 1) '(b 2) '(c 3)) )

(set_ctl dd 'a 1)
(set_ctl dd 'b 2)
(set_ctl lp 'c 3 )

(get_ctl dd 'a)
(get_ctl dd 'b)
(prnt dd)
(short-prnt dd)
(list_ctl dd)
(rm_ctl dd 'c) ;;?
(is-key_ctl dd 'a)

;;;;;;;;;;;;;;
;test de fun
;;;;;;;;;;;;;;
; pb
(setf sdd (make_fun '(-1 0)))
; pb
(setf sdd (make_fun '(-1 0  1 1  0 2  1 3
                      -1 4  5)))
; pb
(setf sdd (make_fun '(-1 0 1 1 0 'd 1 3 -1 4)))
; pb
(setf sdd (make_fun '(-1 0 1 1 0 -2 1 3 -1 4)))

(setf sdd (make_fun '(-1 0 1 1 0 2 2 3 -2 5)))
(setf f1 (make_fun '(0 0 1 1)))
(is_fun sdd)
(prnt sdd)
(short-print_fun sdd)
(x-beg_fun sdd)
(y-beg_fun sdd)
(x-end_fun sdd)
(y-end_fun sdd)

(y-val_fun sdd 30.59)
(y-val_fun sdd 3)

;test exponential interpolation (serge avril 97)
(y-val_fun sdd .6)
(y-val_fun sdd .5 -1)
(lkp 10 f1 -0.5)


; pb
(y-val_fun sdd 3.5 'e)

(resc_fun sdd -100 20 50 50)

(resc_fun sdd -100 -100 50 60)
(y-resc_fun sdd 100 200)

;;;;;;;;;;;;;;
;test de ve
;;;;;;;;;;;;;;

(setf sdf (make_ve sdd 10))
(is_ve sdf)
(print_ve sdf)
(fun_ve sdf)
(name_ve sdf)
(num_ve sdf)
(s_ve sdf 'dfgdfgd)

;;;;;;;;;;;;;;
;test de wt
;;;;;;;;;;;;;;
(setf op1 (make_wt 'test-file))
(setf op2 (make_wt 'test-file 'test-dir))

(prnt op1)
(short-prnt op2)

(reinit_wt op1 'pippo-file 'my-dir)

(add-field_wt op1 'my-field 'this-is-me)
(add-field_wt op1 'my-field2 'this-is-you)

(rm-field_wt op1 'my-field)

(file-name_wt op1)
(set-file-name_wt op1 'new-name)

(freq_wt op1)
(set-freq_wt op1 '(2.0 3.0))

(set-si_wt op1 1.0)

(dur