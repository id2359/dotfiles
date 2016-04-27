;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-header.el|new/
;;;; Author          : Frank Ritter
;;;; Created On      : Mon Jul  9 16:56:30 1990
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Sun Jan 12 23:22:52 1992
;;;; Update Count    : 26
;;;; 
;;;; PURPOSE
;;;; 	This included the local (i.e., Soar specific) functions for the header 
;;;;  code.
;;;;
;;;; TABLE OF CONTENTS
;;;;    i. 	make-header-hooks (specifies what goes on header)
;;;;               and and setup for RCS
;;;; 	I. 	soar-version and taql-versions
;;;;	II.	Erik's insert-date-string & insert-time-string
;;;;    N. 	provide soar-header
;;;; 
;;;; Copyright 1990, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(require 'header)

;;;
;;;	i.  make-header-hooks and setup for RCS
;;;

;;; Header contents:  we will use RCS, so skip header-history in favor of using
;;; an RCS log history mechanism.

(defvar soar-header-hooks 
      '(;; top line with mode  comes for free
        ;; divisor line        comes for free
        header-blank
        header-file-name
        header-author
        header-creation-date
        header-modification-author
        header-modification-date
        header-update-count
        soar-version
        taql-version
        ;;Put PURPOSE and TOC near top
        header-blank
        header-purpose
        header-toc
        header-copyright
        ;;Generally want either RCS stuff or header-history
        ;; at CMU, and else where, I guess, less people and less hackery use RCS,
        header-divisor-line
        header-status
        header-history
        ;;header-rcs-locker
        ;;;;header-rcs-header
        ;;header-rcs-log
        ;; divisor line        comes for free
        )
 "*What to use to draw the soar-header.")

(setq make-header-hooks soar-header-hooks)

;; Set up for RCS

(defun rcs-set-comment-string ()
  (let (mode)
    (save-excursion
      (set-buffer buf)
      (setq mode major-mode))
    (if (memq mode '(soar-mode lisp-mode fi:common-lisp-mode emacs-lisp-mode))
	(if (not (has-rcs-file-p fn))
	    (message (concat "No RCS file exists for " fn))
	    (let ((buf (get-buffer-create (concat "# rcs temp*"))))
	      (call-process rcs-shell-path nil buf nil "-c"
			    (concat "cd " (expand-file-name (file-name-directory fn)) "; " 
				    (find-exec-command "rcs -c';;;; ' " rcs-exec-path) (file-name-nondirectory fn)))
	      (kill-buffer buf)
	      (message "Done"))))))

(setq rcs-new-file-hooks 'rcs-set-comment-string)
(setq rcs-new-file-hook 'rcs-set-comment-string)


;;;
;;;	ii.	New variables
;;;




;;;
;;;	I. 	 soar-version and taql-versions
;;;
;;;  These two take the variables set in the user's .emacs directory 
;;; for which soar and taql they are running, and put them on the front of files.
;;;

(defun soar-version ()
  "Places the version of Soar being used."
  (if (string-match "soar" (downcase (format "%s" major-mode)) 0)
      (insert header-prefix-string "Soar Version    : " 
              soar-version "\n")))

(defun taql-version ()
  "Places the version of TAQL being used."
  (if (and (string-match "soar" (downcase (format "%s" major-mode)) 0)
           (boundp 'taql-version-number))
      (insert header-prefix-string "TAQL Version    : " 
              taql-version-number "\n")))



;;;
;;;     N.   provide soar-header
;;;

(provide 'soar-header)
