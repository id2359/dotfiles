;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-bridge.el
;;;; Author          : Frank Ritter
;;;; Created On      : Thu Mar  7 13:46:08 1991
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Jul 29 23:05:14 1992
;;;; Update Count    : 24
;;;; 
;;;; PURPOSE
;;;  Set up bridge mode, which lets soar talk asynchronously to Emacs.
;;;; 	Lets soar-mode grab stuff from the bridge link.
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;; Copyright 1991, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;;	i. 	provides and variables
;;;

(require 'bridge)
(provide 'soar-bridge)

(setq bridge-hook
      (function (lambda ()
        (setq bridge-source-insert nil) ;Don't insert in source buffer
        (setq bridge-destination-insert t) ; insert in dest buffer
        ;; Handle copy-it messages yourself
         (setq bridge-handlers
               '(("ms-hook" . soar-mode-handler))))))


;;;
;;;	I.	soar-mode-handler
;;;

(defun soar-mode-handler (process output)
 "Always stuff what you get into *match-set*."
 (if (null output)
     (setq bridge-send-to-buffer nil)  ; end of bridge, else stuff it
     (let* ( (buffer (current-buffer))
             (window (get-buffer-window buffer))
             (new-buffer (get-buffer-create "*Match-set*"))
             (headerp (string-match "ms-hook" output))
             (new-window (get-buffer-window new-buffer))  )
      (if (not bridge-send-to-buffer)
	  (setq bridge-send-to-buffer new-buffer))
      (if headerp
          (setq output (substring output (length "ms-hook"))))
      (set-buffer bridge-send-to-buffer)
      (soar-mode)
      (goto-char (point-max))
      (insert output)
      (if pop-up-cms
         (progn
           (display-buffer bridge-send-to-buffer)
           (set-window-point (get-buffer-window new-buffer) (point-max))
           )
        (unwind-protect
	   (progn
             (if (windowp new-window)
                 (set-window-point new-window (point-max))
	         (goto-char (point-max))))
           (progn )
             ))
    (message "New stuff in *Match-set*!"))   ))



(defun bridge-filter (process output)
  "Given PROCESS and some OUTPUT, check for the presence of
bridge-start-regexp.  Everything prior to this will be passed to the
normal filter function or inserted in the buffer if it is nil.  The
output up to bridge-end-regexp will be sent to the first handler on
bridge-handlers that matches the string.  If no handlers match, the
input will be sent to bridge-send-handler.  If bridge-prompt-regexp is
encountered before the bridge-end-regexp, the bridge will be cancelled."
   (let ((inhibit-quit t)
	 (match-data (match-data))
	 (old-buffer (current-buffer))
	 (process-buffer (process-buffer process))
	 (case-fold-search t)
	 (start 0) (end 0)
	 function
	 b-start b-start-end b-end)
     (set-buffer process-buffer) ;; access locals
     (setq function bridge-in-progress)

     ;; How it works:
     ;;
     ;; start, end delimit the part of string we are interested in;
     ;; initially both 0; after an iteration we move them to next string.

   ;; b-start, b-end delimit part of string to bridge (possibly whole string);
   ;; this will be string between corresponding regexps.

     ;; There are two main cases when we come into loop:

     ;;  bridge in progress
     ;;0    setq b-start = start
     ;;1    setq b-end (or end-pattern end)
     ;;4    process string
     ;;5    remove handler if end found
     
     ;;  no bridge in progress
     ;;0    setq b-start if see start-pattern
     ;;1    setq b-end if bstart to (or end-pattern end)
     ;;2    send (substring start b-start)  to normal place
     ;;3    find handler (in b-start, b-end) if not set
     ;;4    process string
     ;;5    remove handler if end found

     ;; equivalent sections have the same numbers here;
     ;; we fold them together in this code.

     (unwind-protect
	(while (< end (length output))

	  ;;0    setq b-start if find
	  (setq b-start
		(cond (bridge-in-progress
		       (setq b-start-end start)
		       start)
		      ((string-match bridge-start-regexp output start)
		       (setq b-start-end (match-end 0))
		       (match-beginning 0))
		      (t nil)))
	  ;;1    setq b-end
	  (setq b-end
		(if b-start
		    (let ((end-seen (string-match bridge-end-regexp
						  output b-start-end)))
		      (if end-seen (setq end (match-end 0)))
		      end-seen)))
	  (if (not b-end) (setq end   (length output)
				b-end (length output)))

	  ;;1.5 - if see prompt before end, remove current
	  (if b-start
	      (let ((prompt (string-match bridge-prompt-regexp
					  output b-start-end)))
		(if (and prompt (<= (match-end 0) b-end))
		    (setq b-start nil  ; b-start-end start
			  b-end   start
			  end     (match-end 0)
			  bridge-in-progress nil
			  ))))

	  ;;2    send (substring start b-start) to old filter, if any
	  (if (/= start (or b-start end)) ; don't bother on empty string
	      (let ((pass-on (substring output start (or b-start end))))
		(if bridge-old-filter
		    (let ((old bridge-old-filter))
		      (store-match-data match-data)
		      (funcall old process pass-on)
		      ;; if filter changed, re-install ourselves
		      (let ((new (process-filter process)))
			(if (not (eq new 'bridge-filter))
			    (progn (setq bridge-old-filter new)
				   (set-process-filter process 'bridge-filter)))))
                  ;; 10-Jul-91 - fer
                  ;; this burps if string immediately follows a bridge string
                  ;; b/c current buffer might not be process buffer
                    (progn (set-buffer process-buffer)
                           (bridge-insert pass-on)))))

	  ;;3 find handler (in b-start, b-end) if none current
	  (if (and b-start (not bridge-in-progress))
	      (let ((handlers bridge-handlers))
		(while (and handlers (not function))
		  (let* ((handler (car handlers))
			 (m (string-match (car handler) output b-start-end)))
		    (if (and m (< m b-end))
			(setq function (cdr handler))
			(setq handlers (cdr handlers)))))
		;; Set default handler if none
		(if (null function)
		    (setq function 'bridge-send-handler))
		(setq bridge-in-progress function)))
	  ;;4    process string
	  (if function
	      (let ((ok t))
		(if (/=  b-start-end b-end)
		    (let ((send (substring output b-start-end b-end)))
		      ;; also, insert the stuff in buffer between
		      ;; iff bridge-source-insert.
		      (if bridge-source-insert (bridge-insert send))
		      ;; call handler on string
		      (setq ok (bridge-call-handler function process send))))
		;;5    remove handler if end found
		;; if function removed then tell it that's all
		(if (or (not ok) (/= b-end end));; saw end before end-of-string
		    (progn
		      (bridge-call-handler function process nil)
		      ;; have to remove function too for next time around
		      (setq function nil
			    bridge-in-progress nil)
		      ))
		))
     
	     ;; continue looping, in case there's more string
	     (setq start end)
	     ))
       ;; protected forms:  restore buffer, match-data
       (set-buffer old-buffer)
       (store-match-data match-data)
       ))
