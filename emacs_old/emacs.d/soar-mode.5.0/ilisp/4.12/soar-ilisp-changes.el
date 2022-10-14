;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-ilisp-changes.el
;;;; Author          : Frank Ritter
;;;; Created On      : Tue Oct  2 17:10:39 1990
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Oct 21 22:31:28 1992
;;;; Update Count    : 110
;;;; 
;;;; PURPOSE
;;;; 	Changes to ilisp for DSI/Soar-mode to use.  These represent
;;;; permanent additions to ilisp that we do not expect them to support.
;;;; Each release of ilisp, we have to update the stuff we don't change in 
;;;; each file.
;;;;
;;;; TABLE OF CONTENTS
;;;;	i.	inits and reloads
;;;;	I.	lisp-send-region
;;;;	III.	describe- and inspect-lisp 
;;;;	IV.	ilisp-compile-inits
;;;;	V.	rebind some keys in ilisp-mode-map
;;;;	VI.	ilisp-bug
;;;;	VII.	ilisp-compile-inits
;;;;    VIII.   edit-definitions-lisp
;;;;    IX.     lisp-region-name
;;;;	X.	popper-other-window and a new variable
;;;;    XI.     defdialect clisp
;;;;	N.	Do provides and stuff
;;;; 
;;;; (C) Copyright 1990, Carnegie Mellon University, all rights reserved.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; requested hooks for new byte-compiler 30-jul-92- fer


;;;
;;;	i.	inits and reloads
;;;

; old comint might have been loaded, we want ours!
(if (not (string= comint-version "2.02"))
    (load "comint"))

;; this should be done with regexp
;; -fer
(defun lisp-is-really-soar ()
  (string= (substring (format "%s" (ilisp-process))
                      0
                      (length "#<process soar"))
           "#<process soar"))


;;;
;;;	I.	lisp-send-region
;;;
;;;  changed to know about soarsyntax

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
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; correct for soar-syntax here:  -fer
  (setq soar-syntax
        (car (read-from-string (ilisp-send "(soarsyntaxp)" 
                                           "" nil 'result nil))))
  (cond ;; soar process, lisp code:
        ((and (lisp-is-really-soar)
              (eq major-mode 'lisp-mode))
         (ilisp-send "(lispsyntax)" "Using lispsyntax.") )
        ;; soar process, soar code: 
        ((eq major-mode 'soar-mode)
         (ilisp-send "(soarsyntax)" "Using soarsyntax."))
        ;; lisp process, lisp code (the original definition):
        ((not (lisp-is-really-soar))) )
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (let ((sexp (lisp-count-pairs start end ?\( ?\)))
	(string (buffer-substring start end)))
    (setq string
	  (format (ilisp-value format)
		  (lisp-slashify
		   (if (= sexp 1)
		       string
		       (format (ilisp-value 'ilisp-block-command) string)))
		  (lisp-buffer-package) (buffer-file-name)))
    (let ((result 
	   (ilisp-send
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
	  result)))
  (if soar-syntax
      (ilisp-send "(soarsyntax)" "Resetting to soarsyntax.")
      (ilisp-send "(lispsyntax)" "Resetting to lispsyntax.")))


;;;
;;;	III.	describe- and inspect-lisp 
;;;
;;; just checks for arg now, not neg arg.
;;;

(defun describe-lisp (sexp)
  "Describe the current sexp using ilisp-describe-command.  With a
negative prefix, prompt for the expression.  If in an ILISP buffer,
and there is no current sexp, describe ilisp-last-command."
  (interactive
   (list
    (if current-prefix-arg   ; -fer
	(ilisp-read "Describe: " (lisp-previous-sexp t))
	(if (memq major-mode ilisp-modes)
	    (if (= (point)
		   (process-mark (get-buffer-process (current-buffer))))
		(or (ilisp-value 'ilisp-last-command t)
		    (error "No sexp to describe."))
		(lisp-previous-sexp t))
	    (lisp-previous-sexp t)))))
  (let ((result
	 (ilisp-send
	  (format (ilisp-value 'ilisp-describe-command) 
		  (lisp-slashify sexp) (lisp-buffer-package))
	  (concat "Describe " sexp)
	  'describe)))
    (lisp-display-output result)))

(defun inspect-lisp (sexp)
  "Inspect the current sexp using ilisp-inspect-command.  With a
negative prefix, prompt for the expression.  If in an ILISP buffer,
and there is no current sexp, inspect ilisp-last-command."
  (interactive
   (list
    (if current-prefix-arg
	(ilisp-read "Inspect: " (lisp-previous-sexp t))
	(if (memq major-mode ilisp-modes)
	    (if (= (point)
		   (process-mark (get-buffer-process (current-buffer))))
		(or (ilisp-value 'ilisp-last-command t)
		    (error "No sexp to inspect."))
		(lisp-previous-sexp t))
	    (lisp-previous-sexp t)))))
  (ilisp-send
   (format (ilisp-value 'ilisp-inspect-command) 
	   (lisp-slashify sexp) (lisp-buffer-package))
   (concat "Inspect " sexp)
   'inspect t))


;;;
;;;	IV.	ilisp-compile-inits
;;;
;;; Changed to make sure that soarsyntax doesn't get in our way.
;;;

(defun ilisp-compile-inits ()
  "Compile the initialization files for the current inferior LISP
dialect."
  (interactive)
  (ilisp-init t)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; make read (soar) syntax be right for ilisp -fer 
  (setq soar-syntax
        (car (read-from-string (ilisp-send "(soarsyntaxp)" 
                                           "" nil 'result nil))))
  (ilisp-send "(lispsyntax)" "Using lispsyntax.")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (let ((files (ilisp-value 'ilisp-load-inits t)))
    (while files
      (load-file-lisp (expand-file-name (cdr (car files)) ilisp-directory))
      (compile-file-lisp (expand-file-name (cdr (car files)) ilisp-directory)
			 (ilisp-value 'ilisp-init-binary-extension t))
      (setq files (cdr files))))
  (if soar-syntax
      (ilisp-send "(soarsyntax)" "Resetting to soarsyntax.")
      (ilisp-send "(lispsyntax)" "Resetting to lispsyntax.")))


;;;
;;;	V.	ilisp-init-internal
;;;

;;; New variables for the 5->6 conversion
(defvar ilisp-send-start-sync "\"Start sync\"")
(defvar ilisp-receive-start-sync "[ \t\n]*\"Start sync\"")
(defvar ilisp-send-end-sync "\"End sync\"")
(defvar ilisp-receive-end-sync "\"End sync\"")

(defun ilisp-init-internal (&optional sync)
  "Send all of the stuff necessary to initialize."
  (unwind-protect
       (progn
	 (if sync
	     (comint-sync
	      (ilisp-process)
	      ilisp-send-start-sync ilisp-receive-start-sync
	      ilisp-send-end-sync ilisp-receive-end-sync))
	 (ilisp-binary 'ilisp-binary-command 'ilisp-binary-extension)
	 (ilisp-binary 'ilisp-init-binary-command 'ilisp-init-binary-extension)
	 ;; This gets executed in the process buffer
	 (comint-send-code
	  (ilisp-process)
	  (function (lambda ()
	    (let ((files ilisp-load-inits)
		  (done nil))
	      (unwind-protect
		   (progn
		     (if (not ilisp-init-binary-extension)
			 (setq ilisp-init-binary-extension 
			       ilisp-binary-extension))
		     (while files
		       (ilisp-load-or-send
			(expand-file-name 
			 (cdr (car files)) ilisp-directory))
		       (setq files (cdr files)))
		     (comint-send-code (ilisp-process)
				       'ilisp-done-init)
		     (setq done t))
		(if (not done)
		    (progn
		      (setq ilisp-initializing nil)
		      (abort-commands-lisp))))))))
	 (set-ilisp-value 'ilisp-initializing t))
    (if (not (ilisp-value 'ilisp-initializing t))
	(abort-commands-lisp))))

;(defun ilisp-init-internal ()
;  "Send all of the stuff necessary to initialize."
;  (unwind-protect
;       (progn
;	 (comint-sync
;	  (ilisp-process)
;	  "\"Start sync\""  "[ \t\n]*\"Start sync\""
;	  "\"End sync\""    "\"End sync\"")
;         ;; only change right here 18-Jul-91 - fer
;	 (ilisp-binary 'ilisp-binary-command 'ilisp-binary-extension)
;	 (ilisp-binary 'ilisp-init-binary-command 'ilisp-init-binary-extension)
;	 ;; This gets executed in the process buffer
;	 (comint-send-code
;	  (ilisp-process)
;	  (function (lambda ()
;	    (let ((files ilisp-load-inits)
;		  (done nil))
;	      (unwind-protect
;		   (progn
;		     (if (not ilisp-init-binary-extension)
;			 (setq ilisp-init-binary-extension 
;			       ilisp-binary-extension))
;		     (while files
;		       (ilisp-load-or-send
;			(expand-file-name 
;			 (cdr (car files)) ilisp-directory))
;		       (setq files (cdr files)))
;		     (comint-send-code (ilisp-process)
;				       'ilisp-done-init)
;		     (setq done t))
;		(if (not done)
;		    (progn
;		      (setq ilisp-initializing nil)
;		      (abort-commands-lisp))))))))
;	 (set-ilisp-value 'ilisp-initializing t))
;    (if (not (ilisp-value 'ilisp-initializing t))
;	(abort-commands-lisp))))


;;;
;;;	VI.	ilisp-bug
;;;
;;; and less noise:

;Date: Wed,  4 Sep 1991 18:24:11 -0400 (EDT)
;From: Frank Ritter <fr07+@andrew.cmu.edu>
;To: Christopher.McConnell@CS.CMU.EDU
;Subject: ilisp-bug bug
;
;Your problem: 
;
;ilisp-bug croaks if it is called when there is no ilisp running.  Soar
;mode, and ilisp's lisp-mode may be used when there is no lisp (or at
;least not yet).  I include a fixed up version  that does not croak,
;with/or w/o an ilisp-buffer around.
;
;Frank

(defun ilisp-bug ()
  "Generate an ilisp bug report."
  (interactive)
  (let ((buffer (current-buffer)))
    (mail)
    (insert ilisp-bugs-to)
    (search-forward (concat "\n" mail-header-separator "\n"))
    (insert "\nYour problem: \n\n")
    (insert "Type C-c C-c to send\n")
    (insert "============= Emacs state below: for office use only ===========\n")
    (forward-line 1)
    (insert (emacs-version))
    (insert 
     (format "\nWindow System: %s %s" window-system window-system-version))
    (let ((mode (save-excursion (set-buffer buffer) major-mode))
	  (match "popper-\\|completer-")
	  (val-buffer buffer)
	  string)
      (if (or (memq mode lisp-source-modes) (memq mode ilisp-modes))
	  (progn
	    (setq match (concat "ilisp-\\|comint-\\|lisp-" match)
		  val-buffer (save-excursion (set-buffer buffer)
					     (or (if ilisp-buffer  ;-fer
                                                     (ilisp-buffer))
                                                 buffer)))
	    (mapcar (function (lambda (dialect)
		      (setq match (concat (format "%s-\\|" (car dialect))
					  match))))
		    ilisp-dialects)
	    (save-excursion
	      (set-buffer buffer)
	      (let ((point (point))
		    (start (lisp-defun-begin))
		    (end (lisp-end-defun-text t)))
		(setq string
		      (format "
Mode: %s
Start: %s
End: %s
Point: %s
Point-max: %s
Code: %s\n"
			      major-mode start end point (point-max)
			      (buffer-substring start end)))))
	    (insert string)))
      (mapatoms
       (function (lambda (symbol)
		   (if (and (boundp symbol)
			    (string-match match (format "%s" symbol))
                            ;; -fer
			    (not (memq symbol '(ilisp-documentation
                                                inferior-soar-documentation
                                                other-soar-command-menu))))
		       (let ((val (save-excursion
				    (set-buffer val-buffer) 
				    (symbol-value symbol))))
			 (if val
			     (insert (format "%s: %s\n" symbol val))))))))
      (insert (format "\nLossage: %s" (key-description (recent-keys))))
    (if (and (or (memq mode lisp-source-modes)
		 (memq mode ilisp-modes))
	       ilisp-buffer    ;-fer change here too
               (ilisp-buffer)  ;-fer change here too
	       (memq 'clisp (ilisp-value 'ilisp-dialect t))
	       (not (cdr (ilisp-value 'comint-send-queue))))
	  (insert (format "\nLISP: %s"
			  (comint-remove-whitespace
			   (car (comint-send
				 (save-excursion
				   (set-buffer buffer)
				   (ilisp-process))
				 "(lisp-implementation-version)"
				 t t 'version))))))
    (insert "\n") ;end with a newline -FER
    (goto-char (point-min))
    (re-search-forward "^Subject")
    (end-of-line)
    (message "Send with sendmail or your favorite mail program."))))


;;;
;;;	VII.	ilisp-compile-inits
;;;

;; defined above
;; (defun ilisp-compile-inits ()
;;   "Compile the initialization files for the current inferior LISP
;; dialect."
;;   (interactive)
;;   (beep t)
;;   (ilisp-init t) (beep t)
;;   (let ((files (ilisp-value 'ilisp-load-inits t)))
;;     (while files
;;       (compile-file-lisp (expand-file-name (cdr (car files)) ilisp-directory)
;; 			 (ilisp-value 'ilisp-init-binary-extension t))
;;       (setq files (cdr files)))))


;;;
;;;     VIII.   edit-definitions-lisp
;;;

;(defun edit-definitions-lisp (symbol type &optional stay search locator)
;  "Find the source files for the TYPE definitions of SYMBOL.  If STAY,
;use the same window.  If SEARCH, do not look for symbol in inferior
;LISP.  The definition will be searched for through the inferior LISP
;and if not found it will be searched for in the current tags file and
;if not found in the files in lisp-edit-files set up by
;\(\\[lisp-directory]) or the buffers in one of lisp-source-modes if
;lisp-edit-files is T.  If lisp-edit-files is nil, no search will be
;done if not found through the inferior LISP.  TYPES are from
;ilisp-source-types which is an alist of symbol strings or list
;strings.  With a negative prefix, look for the current symbol as the
;first type in ilisp-source-types."
;  (interactive 
;   (let* ((use-ilisp-buffer (comint-check-proc ilisp-buffer))
;          (types (and use-ilisp-buffer
;                      (ilisp-value 'ilisp-source-types t)))
;          (default (if types (car (car types))))
;          (function (and use-ilisp-buffer
;                         (lisp-function-name)))
;          (symbol (and use-ilisp-buffer
;                       (lisp-buffer-symbol function))))
;     (if (lisp-minus-prefix)
;         (list function default)
;         (list (ilisp-read-symbol 
;                (format "Edit Definition [%s]: " symbol)
;                function
;                nil
;                t)
;               (if types 
;                   (ilisp-completing-read
;                    (format "Type [%s]: " default)
;                    types default))))))
;  (if (comint-check-proc ilisp-buffer)
;  (let* ((name (lisp-buffer-symbol symbol))
;         (symbol-name (lisp-symbol-name symbol))
;         (command (and (comint-check-proc ilisp-buffer)
;                       (ilisp-value 'ilisp-find-source-command t)))
;         (source
;          (if (and command (not search) (comint-check-proc ilisp-buffer))
;              (ilisp-send
;               (format command symbol-name
;                       (lisp-symbol-package symbol)
;                       type)
;               (concat "Finding " type " " name " definitions")
;               'source)
;              "nil"))
;         (result (lisp-last-line source))
;         (case-fold-search t)
;         (source-ok (and (comint-check-proc ilisp-buffer)
;                         (not (or (ilisp-value 'comint-errorp t)
;                             (string-match "nil" (car result))))))
;         (tagged nil))
;    (unwind-protect
;         (if (and tags-file-name (not source-ok))
;             (progn (setq lisp-using-tags t)
;                    (find-tag symbol-name nil stay)
;                    (setq tagged t)))
;      (if (not tagged)
;          (progn
;            (setq lisp-last-definition (cons symbol type)
;                  lisp-last-file nil
;                  lisp-last-locator (or locator
;                                        (and (comint-check-proc ilisp-buffer)
;                                             (ilisp-value 'ilisp-locator))))
;            (lisp-setup-edit-definitions
;             (format "%s %s definitions:" type name)
;             (if source-ok (cdr result) lisp-edit-files))
;            (next-definition-lisp nil t)))))
;  (unwind-protect
;         (if tags-file-name
;             (progn (setq lisp-using-tags t)
;                    (find-tag symbol-name nil stay))))))



;;;
;;;     IX.   lisp-region-name
;;;
;;; 25-Jun-92 -Added (buffer-name) to the result -- TFMcG

(defun lisp-region-name (start end)
  "Return a name for the region from START to END."
  (save-excursion
    (goto-char start)
    (if (re-search-forward "^[ \t]*[^;\n]" end t)
	(forward-char -1))
    (setq start (point))
    (goto-char end)
    (re-search-backward "^[ \t]*[^;\n]" start 'move)
    (end-of-line)
    (skip-chars-backward " \t")
    (setq end (min (point) end))
    (goto-char start)
    (let ((from
	   (if (= (char-after (point)) ?\()
	       (lisp-def-name)
	       (buffer-substring (point) 
				 (progn (forward-sexp) (point))))))
      (goto-char end)
      (if (= (char-after (1- (point))) ?\))
	  (progn
	    (backward-sexp)
	    (if (= (point) start)
		from
		(concat (buffer-name) " from " from " to " (lisp-def-name))))
	  (concat (buffer-name) " from " from " to " 
		  (buffer-substring (save-excursion
				      (backward-sexp)
				      (point)) 
				    (1- (point))))))))


;;;
;;;	X.	popper-other-window and a new variable
;;;
;;; sent into CCM 31-Jul-92 -FER
;;; revised later 31-Jul-92

(defvar popper-skip-popper-buffers t
  "*When t (the default), don't select popper windows with popper-other-window
unless an argument is given.")

(setq popper-skip-popper-buffers nil)

(defun popper-other-window (arg)
  "Select the arg'th other window.  If arg is a C-u prefix or 
popper-skip-popper-buffers is T, the popper window will be selected.  
Otherwise, windows that contain buffers in popper-buffers-to-skip will 
be skipped."
  (interactive "P")
  (if (not popper-skip-popper-buffers)
      (other-window (if (eq arg '-) -1 (or arg 1)))
  (if (consp arg)
      (let* ((buffer (popper-output-buffer))
	     (window (and buffer (get-buffer-window buffer))))
	(if window (select-window window)))
      (setq arg (if (eq arg '-) -1 (or arg 1)))
      (other-window arg)
      (if (eq popper-buffers-to-skip t)
	  (if (eq (popper-output-buffer) (current-buffer))
	      (other-window arg))
	  (if (popper-mem (buffer-name (current-buffer))
			  popper-buffers-to-skip)
	      (other-window arg))))))


;;;
;;;     XI.     defdilect clisp
;;;
(defdialect clisp "Common LISP"
  ilisp
  (if (not (fboundp 'common-lisp-indent-hook))
      (load "cl-indent"))
  (setq lisp-indent-hook 'common-lisp-indent-hook)
  (setq ilisp-load-or-send-command 
	"(or (and (load \"%s\" :if-does-not-exist nil) t)
             (and (load \"%s\" :if-does-not-exist nil) t))")
    (setq ilisp-send-start-sync "\"Start sync\"")
    (setq ilisp-receive-start-sync "[ \t\n]*\"Start sync\"")
    (setq ilisp-send-end-sync "\"End sync\"")
    (setq ilisp-receive-end-sync "\"End sync\"")
  (ilisp-load-init 'clisp "clisp.lisp")
  (setq ilisp-package-regexp "^[ \t]*(in-package[ \t\n]*"
	ilisp-package-command "(let ((*package* *package*)) %s (package-name *package*))"
	ilisp-package-name-command "(package-name *package*)"
	ilisp-in-package-command "(in-package \"%s\")"
	ilisp-last-command "*"
	ilisp-save-command "(progn (ILISP:ilisp-save) %s\n)"
	ilisp-restore-command "(ILISP:ilisp-restore)"
	ilisp-block-command "(progn %s\n)"
	ilisp-eval-command "(ILISP:ilisp-eval \"%s\" \"%s\" \"%s\")"
	ilisp-defvar-regexp "(defvar[ \t\n]")
  (setq ilisp-defvar-command 
	"(ILISP:ilisp-eval \"(let ((form '%s)) (progn (makunbound (second form)) (eval form)))\" \"%s\" \"%s\")")
  (setq ilisp-compile-command "(ILISP:ilisp-compile \"%s\" \"%s\" \"%s\")"
	ilisp-describe-command "(ILISP:ilisp-describe \"%s\" \"%s\")"
	ilisp-inspect-command "(ILISP:ilisp-inspect \"%s\" \"%s\")"
	ilisp-arglist-command "(ILISP:ilisp-arglist \"%s\" \"%s\")")
  (setq ilisp-documentation-types
	'(("function") ("variable")
	  ("structure") ("type")
	  ("setf") ("class")
	  ("(qualifiers* (class ...))")))
  (setq ilisp-documentation-command
	"(ILISP:ilisp-documentation \"%s\" \"%s\" \"%s\")")
  (setq ilisp-macroexpand-1-command 
	"(ILISP:ilisp-macroexpand-1 \"%s\" \"%s\")")
  (setq ilisp-macroexpand-command "(ILISP:ilisp-macroexpand \"%s\" \"%s\")")
  (setq ilisp-complete-command 
	"(ILISP:ilisp-matching-symbols \"%s\" \"%s\" %s %s %s)")
  (setq ilisp-locator 'lisp-locate-clisp)
  (setq ilisp-source-types 
	'(("function") ("macro") ("variable")
	  ("structure") ("type")
	  ("setf") ("class")
	  ("(qualifiers* (class ...))")))
  (setq ilisp-callers-command "(ILISP:ilisp-callers \"%s\" \"%s\")"
	ilisp-trace-command "(ILISP:ilisp-trace \"%s\" \"%s\")"
	ilisp-untrace-command "(ILISP:ilisp-untrace \"%s\" \"%s\")")
  (setq ilisp-directory-command "(namestring *default-pathname-defaults*)"
	ilisp-set-directory-command
	"(setq *default-pathname-defaults* (parse-namestring \"%s\"))")
  (setq ilisp-load-command "(load \"%s\")")
  (setq ilisp-compile-file-command 
	"(ILISP:ilisp-compile-file \"%s\" \"%s\")"))

;;;
;;;	N.	Do provides and stuff
;;;

;; (require 'soar-ilisp-keymap-changes "soar-ilisp-keymap-changes")
;; no longer required

(provide 'soar-ilisp-changes)

(require 'ilisp-simple-menu)
