;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-mode-defaults6.el|new/
;;;; Author          : Frank Ritter
;;;; Created On      : Thu Sep 17 01:02:03 1992
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Thu Sep 17 02:55:23 1992
;;;; Update Count    : 9
;;;; 
;;;; PURPOSE
;;;; 	Changes to soar-mode that set it up for Soar6.
;;;; Not put directly into soar-mode until the big switch is thrown.
;;;;
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;; Copyright 1992, Frank E. Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Status          : Unknown, Use with caution!
;;;; HISTORY
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Load me last

(setq soar-version-number "6")

(setq soar-image-name "/../stego/usr/doorenbs/soar6")

;;; alteration to ilisp-send.  Doesn't work at all the same.
;;; by Huffman, 12-Sep-92
(defun soar6-send (string &optional message status and-go handler)
  "Send STRING (1) to the SOAR buffer, print MESSAGE (2) set STATUS (3) and
return the result if AND-GO (4) is NIL, otherwise switch to ilisp if
and-go is T and show message and results.  If AND-GO is 'dispatch,
then the command will be executed without waiting for results.  If
AND-GO is 'call, then a call will be generated. If this is the first
time an ilisp command has been executed, the Soar will also be
initialized from the files in ilisp-load-inits.  If there is an error,
comint-errorp will be T and it will be handled by HANDLER (5)."
  (let ((process (ilisp-process))
	(dispatch (eq and-go 'dispatch)))
    (if message
	(message "%s" (if dispatch
			  (concat "Started " message)
			  message)))
    ;; No completion table
    (setq ilisp-original nil)
    (if (memq and-go '(t call))
	(progn (comint-send process string nil nil status message handler)
	       (if (eq and-go 'call)
		   (call-defun-lisp nil)
		   (switch-to-lisp t t))
	       nil)
	(let* ((save nil)
	       (result
		(comint-send 
		 process
		 string
		 ;; Interrupt without waiting
		 t (if (not dispatch) 'wait) status message handler)))
	  (if save 
	      (comint-send process
                          (ilisp-value 'ilisp-restore-command t)
                          t nil 'restore "Restore" t t))
	  (if (not dispatch)
	      (progn (while (not (cdr result))
                      (sit-for 0)
                      (accept-process-output))
		(comint-remove-whitespace (car result))))))))


;; (defun soar-process () (get-buffer-process "*soar*"))

;; (defun soar-buffer () "*soar*")


;;; modified from ilisp.el
;;;%Eval/compile
(defun lisp-send-region (start end switch message status format
			       &optional handler)
  "Given START, END, SWITCH, MESSAGE, STATUS, FORMAT and optional
HANDLER send the region between START and END to the lisp buffer and
execute the command defined by FORMAT on the region, its package and
filename.  If called with a positive prefix, the results will be
inserted at the end of the region.  If SWITCH is T, the command will
be sent and the buffer switched to the inferior LISP buffer.  if
SWITCH is 'call, a call will be inserted.  If SWITCH is 'result the
result will be returned without being displayed.  Otherwise the
results will be displayed in a popup window if lisp-wait-p is T and
the current-prefix-arg is not '- or if lisp-wait-p is nil and the
current-prefix-arg is '-.  If not displayed in a pop-up window then
comint-handler will display the results in a pop-up window if they are
more than one line long, or they are from an error.  STATUS will be
the process status when the command is actually executing.  MESSAGE is
a message to let the user know what is going on."
  (if (= start end) (error "Region is empty"))
  (let ((sexp (lisp-count-pairs start end ?\( ?\)))
	(string (buffer-substring start end)))
;;    (setq string
;;    	  (format  (ilisp-value format)
;;    		  (lisp-slashify	
;;		   (if (= sexp 1)
;;		       string
;;		       (format (ilisp-value 'ilisp-block-command) string)))
;;		  (lisp-buffer-package) (buffer-file-name)))
    (let ((result 
	   (soar-send
	    string message status
	    (cond ((memq switch '(t call)) switch)
		  ((or (not (eq lisp-wait-p (lisp-minus-prefix))) 
		       current-prefix-arg
		       (eq switch 'result)) nil)
		  (t 'dispatch))
	    handler)))
      (if result
	  (if current-prefix-arg
	      (save-excursion
		(goto-char end)
		(insert ?\n)
		(insert result))
	      (if (or (ilisp-value 'comint-errorp t)
		      (string-match "\n" result))
		  (lisp-display-output result)
		  (popper-bury-output t)
		  (message "%s" result)))
	  result))))


(fset 'soar-send (symbol-function 'soar6-send))
