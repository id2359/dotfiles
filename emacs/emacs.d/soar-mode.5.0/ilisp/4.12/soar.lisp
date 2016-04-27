;;;; -*- Mode: Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar.lisp
;;;; Author          : Frank Ritter
;;;; Created On      : Wed Jul 31 16:34:12 1991
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Nov 11 22:18:43 1992
;;;; Update Count    : 64
;;;; 
;;;; PURPOSE
;;;; 	This file gets loaded by ilisp when a Soar starts up.
;;;; You can put any Common lisp expressions you want in here.
;;;; The default package is the user package.
;;;;
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;; Copyright 1991, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(eval-when (load eval compile)
  (in-package "USER"))

(defun test-load-taql ()
   (if (fboundp 'soar::load-taql)
       (soar::load-taql)
     (format t "~% Load-taql not found & TAQL not loaded.
You have to run in a Soar in X image to do this.")))

;; you don't see the output, it gets saved and cherished by ilisp itself.
;; (format t "Hello Nassar!")

;;(format t "~%!! c: ~s :~s **" (find-all-symbols "CMS") *package*)

(eval-when (load eval compile)
  (soarresetsyntax))

;; (format t "~%!! d: ~s :~s **" (find-all-symbols "CMS") *package*)


;;;
;;;	i. 	Special export
;;;

(eval-when (load eval compile)
   (in-package "SX"))

(eval-when (load eval compile)
  (if (not (fboundp 'sx::continuous-ms))
   (progn
     (use-package (list (if (find-package "COMMON-LISP")
                          "COMMON-LISP"
                          "LISP")
                      "SOAR")
                     (find-package "SX"))

   (export '( ;; functions
              sx::continuous-ms
              sx::cms
              sx::matches
             )
           (find-package "SX"))

 (use-package '("SX" ;; grab abunch of other related packages for user
               )
               "USER")
)))


;;;
;;; 	ii.	Variables
;;;

(eval-when (load eval compile)
  (if (not (fboundp 'sx::continuous-ms))
      (progn

(defconstant bridge-start-regexp "")

;;  "Regular expression to match the start of a process bridge in
;; process output.  It should be followed by a buffer name, the data to
;; be sent and a bridge-end-regexp."

(defconstant bridge-end-regexp "")
  ;; "Regular expression to match the end of a process bridge in process
  ;; output."

(defparameter continuous-ms! nil)

)))


;;;
;;;	I.	Code to actually put up the CMS.
;;;

(eval-when (load eval compile)
  (if (not (fboundp 'sx::continuous-ms))
      (progn

(proclaim '(function sx-after-elaboration-hook () nil))

(defun sx-after-elaboration-hook ()
  ;; this version for the system loaded by emacs.
  (if sx::continuous-ms! (sx::emacs-ms)))
)))


;;;
;;;	II.	Changes to Soar internals
;;;

(eval-when (load eval compile)
   (in-package "SOAR"))

(eval-when (load eval compile)
  (if (not (fboundp 'sx::continuous-ms))
      (progn

(defun cycling ()
;;;****************************************************************************
;;; Function: cycling
;;; Description: Modified Soar5 function providing hook into EDT code.
;;;****************************************************************************
  (setf *cycler-status* 'cycling)
  (do ((current-cycle *current-cycle*))  ;avoid global accesses       
      (())
    ;; check the sx server every (elaboration?) cycle -fer
    (cond ((halt-p)
	   (setf *cycler-status* 'halt)
	   (setf *current-cycle* current-cycle)
	   (clear-halt)
	   (return T))
	  ((break-p) 
	   (setf *cycler-status* 'break)
	   (setf *current-cycle* current-cycle)
	   (clear-break)
	   (return T))
	  ((keyboard-break-p) 
	   (setf *cycler-status* 'break)
	   (setf *current-cycle* current-cycle)
	   (clear-keyboard-break)
	   (return T))
	  (T  ;progress, as it were, to next phase.
	   (cond ((eq current-cycle 'preference-phase)
		  (setf current-cycle 'working-memory-phase)
		  (working-memory-phase)
                  (sx::sx-after-elaboration-hook))
		 ((eq current-cycle 'working-memory-phase)
		  (setf current-cycle 'quiescence-phase)
		  (and (quiescence-phase)
                       ;; added hook to run after decision cycle -fer 2/91
                       (run-hooks 'after-dc-hook)) )
		 ((eq current-cycle 'quiescence-phase)
		  (when *edt*
		    (event-timing)) ;Hook into Soar5 for EDT code.
		  (setf current-cycle 'preference-phase)
		  (preference-phase))
		 (T   ;startup
		  (setf current-cycle 'preference-phase)
		  (preference-phase) )) )) )
  nil)
)))


;;;   
;;;	III.	send-to-emacs
;;;
;;; Assumes that soar is running in a gnu-emacs buffer.

(eval-when (load eval compile)
  (in-package "SX"))

(eval-when (load eval compile)
  (if (not (fboundp 'sx::continuous-ms))
      (progn
 
(defmacro send-to-emacs (label &body body)
;; #-release-sx"Send a string to emacs."
 `(progn
    (princ bridge-start-regexp t)
    (format t "~a" ,label)
    ,@body
    (princ bridge-end-regexp t)))


(proclaim '(ftype (function () t) emacs-ms))

(defconstant cms-leader 
  "~%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

(defun emacs-ms ()
  (send-to-emacs "ms-hook"
		 (progn (format t cms-leader)
                        (format t "~%**** Match set for ~s:~s **** (~a)"
				(soar::decision-cycle-count)
				(soar::elaboration-cycle-count)
                                (get-date))
			(or (ms) (format t "~%NIL"))
			))
  t)

(proclaim '(inline get-date))

(defun get-date (&optional (stream nil))
 (declare (stream stream))
 (multiple-value-bind (sec min hour day month year)
        (decode-universal-time (get-universal-time))
  (format stream "~a:~a.~a ~a/~a/~a" hour min sec day month year)))

(proclaim '(ftype (function () nil) continuous-ms))

(defun continuous-ms ()
  "*Toggle Always printing out ms to emacs each m-cycle"
  (cond ( (not continuous-ms!)
          (setf continuous-ms! t)
	  (format t "~%; Continuous-ms is ON.  ~a"
                    "Running emacs version, so run every elaboration."))
	(t (setf continuous-ms! nil)
           (format t "~%;; Turning OFF continuous-ms."))) )

(setf (symbol-function 'cms)
      (symbol-function 'continuous-ms))
)))


;; (format t "!! m: ~s :~s **" (find-all-symbols "CMS") *package*)

;;;
;;;	IV.	matches for compatibility with Soar6
;;;

(eval-when (load eval compile)
  (lispsyntax))

(defmacro matches (production-name &optional arg)
  (cond ((or (not arg) (eq arg 0)) `(smatches , production-name))
        ((eq arg 1) `(full-matches ,production-name))
        (t `(full-matches ,production-name))))


;;;
;;;	V.	Leave the system in a clean state.
;;;

(eval-when (load eval compile)
  (in-package "USER"))

(eval-when (load eval compile)
  (soarsyntax))
