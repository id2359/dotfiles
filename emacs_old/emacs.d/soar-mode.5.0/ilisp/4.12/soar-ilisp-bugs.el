;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-ilisp-bugs.el
;;;; Author          : Frank Ritter
;;;; Created On      : Tue Jun 11 12:08:01 1991
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Sep 30 15:15:03 1992
;;;; Update Count    : 10
;;;; 
;;;; PURPOSE
;;;; 	Bugs in ilisp that we expect to get incorporated into ilisp.
;;;; Each ilisp release these should be checked to see if they have
;;;; been superceeded.
;;;;
;;;; TABLE OF CONTENTS
;;;;
;;;;	II.	find-file-lisp cleaner
;;;;	III.	ilisp-query-compile-on-load
;;;;	V.	ilisp-done-init
;;;;	VI.	defdialect
;;;;	VII.	smarter comment-region
;;;	N.	Do provides and stuff
;;;; 
;;;; (C) Copyright 1991, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; $Locker$
;;;; $Log$
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; new bugs in 4.12
;;; - ilisp-menu should have attribution in it, and may be revised in current
;;;   directory:  /afs/cs/user/ritter/soar-mode/soar6/ilisp-simple-menu.el
;;; - simple-menu should be provided.  revised release available in:
;;;   /afs/cs/user/ritter/soar-mode/soar6/utilities/simple-menu.el
;;; - can't get add-hook by just loading comint-ipc b/c it is dependent 
;;;   on comint's comint-mem. 
;;; - after-ilisp-hook not used in defdialect


;;;
;;;	II.	find-file-lisp cleaner
;;;



;;;
;;;	III.	ilisp-query-compile-on-load
;;;
;;; Now allows the user to not ask for compiles.  Could/should be set for 
;;; each buffer.  But this is all.
;;;
;;; send in 11 june 91, will be in next release as ilisp-load-no-compile-query
;; (defvar ilisp-query-compile-on-load t
;; "*Query the user to compile file when loading.")

;; Soar-mode doesn't need it!
(setq ilisp-load-no-compile-query t)

;; (defun load-file-lisp (file-name)
;;  "Load a lisp file into the current inferior LISP and go there."
;;   (interactive (comint-get-source "Load Lisp file: " lisp-prev-l/c-dir/file
;; 				  lisp-source-modes nil))
;;   (comint-check-source file-name)	; Check to see if buffer needs saved.
;;   (setq lisp-prev-l/c-dir/file (cons (file-name-directory    file-name)
;; 				     (file-name-nondirectory file-name)))
;;   (ilisp-init t)
;;   (let* ((extension (ilisp-value 'ilisp-binary-extension t))
;; 	 (binary (lisp-file-extension file-name extension)))
;;     (save-excursion
;;       (set-buffer (ilisp-buffer))
;;       (if (not (eq comint-send-queue comint-end-queue))
;; 	  (if (y-or-n-p "Abort commands before loading? ")
;; 	      (abort-commands-lisp)
;; 	      (message "Waiting for commands to finish")
;; 	      (while (not (eq comint-send-queue comint-end-queue))
;; 		(accept-process-output)
;; 		(sit-for 0))))
;;       (if (and (car (comint-send-variables (car comint-send-queue)))
;; 	       (y-or-n-p "Interrupt top level? "))
;; 	  (let ((result (comint-send-results (car comint-send-queue))))
;; 	    (interrupt-subjob-ilisp)
;; 	    (while (not (cdr result))
;; 	      (accept-process-output)
;; 	      (sit-for 0)))))
;;     (if (file-newer-than-file-p file-name binary)
;; 	(if (and extension 
;;                  ilisp-query-compile-on-load    ;;; change here -fer 1/91
;;                  (y-or-n-p "Compile first? "))
;; 	    ;; Load binary if just compiled
;; 	    (progn
;; 	      (message "")
;; 	      (compile-file-lisp file-name)
;; 	      (setq file-name binary)))
;; 	;; Load binary if it is current
;; 	(if (file-readable-p binary)
;; 	    (setq file-name binary)))
;;     (switch-to-lisp t t)
;;     (comint-sender
;;      (ilisp-process)
;;      (format (ilisp-value 'ilisp-load-command) file-name))
;;     (message "Loading %s" file-name)))
;; 


;;;
;;;	V.	ilisp-done-init
;;;
;;; Slightly better finish.
;;;
;;; sent in 11 june 91
;;; will be in next release after 4.11
;;; ilisp-done-init, tells dialect in finishup message

 
;;;
;;;	VI.	defdialect
;;;
;;; new version to handle after-ilisp-hook
;;; sent in 10 june 91

(defmacro defdialect (dialect full-name parent &rest body)
 "Define a new ILISP dialect.  DIALECT is the name of the function to
invoke the inferior LISP. The hook for that LISP will be called
DIALECT-hook.  
DIALECT-after-ilisp-hook holds commands to call to modify ilisp for that mode.
The default program will be DIALECT-program.  FULL-NAME
is a string that describes the inferior LISP.  PARENT is the name of
the parent dialect."
 (let ((setup (read (format "setup-%s" dialect)))
       (hook (read (format "%s-hook" dialect)))
       (after-ilisp-hook (read (format "%s-after-ilisp-hook" dialect)))
       (program (read (format "%s-program" dialect)))
       (dialects (format "%s" dialect)))
  (`
   (progn
    (defvar (, hook) nil (, (format "*Inferior %s hook." full-name)))
    (defvar (, after-ilisp-hook) nil 
       (, (format "*Inferior %s hook to run after ilisp has set up the bufer." full-name)))     
    (defvar (, program) nil
      (, (format "*Inferior %s default program." full-name)))
    (defun (, setup) (buffer)
      (, (format "Set up for interacting with %s." full-name))
      (, (read (format "(setup-%s buffer)" parent)))
      (,@ body)
      (setq ilisp-program (or (, program) ilisp-program)
            ilisp-dialect (cons '(, dialect) ilisp-dialect))
      (run-hooks '(, (read (format "%s-hook" dialect)))))
    (defun (, dialect) (&optional buffer program)
      (, (format "Create an inferior %s.  With prefix, prompt for buffer and program."
	        full-name))
      (interactive (list nil nil))
      (ilisp-start-dialect (or buffer (, dialects)) 
	       	           program 
			   '(, setup))
      (run-hooks '(, (read (format "%s-after-ilisp-hook" dialect))))
      (setq (, program) ilisp-program))
    (lisp-add-dialect (, dialects))))))


;;;
;;;	VII.	smarter comment-region
;;;

; To: Christopher.McConnell@CS.CMU.EDU
; CC: tfm@CENTRO.SOAR.CS.CMU.EDU, Erik.Altmann@CS.CMU.EDU
; Subject: ilisp: comment-region-lisp
; Date: Wed, 29 Jul 92 21:11:46 -0400
; From: Frank_Ritter@SHAMO.SOAR.CS.CMU.EDU
; 
; One of our soar-mode users noticed that comment-region will be happy
; to put ;'s all along a defun, and then, if reindent is called, will
; pull it all to the comment col.  Perhaps you could consider making
; comment-region-lisp smarter, if a whole defun was in it, it could use
; triple ;;;'s, and otherwise, the arg.
; 
; (we are running 4.11, and we know that we could pass an arg of 3, but
; it's a bother.)



;;;
;;;	N.	Do provides and stuff
;;;

(provide 'soar-ilisp-bugs)
