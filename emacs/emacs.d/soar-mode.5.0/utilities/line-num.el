; -*-Emacs-Lisp-*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File:         line-num.el
; RCS:          $Header: line-num.el,v 2.1 89/04/24 18:37:54 darrylo Exp $
; Description:  Temporarily displays line numbers in a buffer
; Author:       Unknown
; Created:      Sat Apr  8 13:56:19 1989
; Modified:     Sat Apr  8 14:10:25 1989 (Darryl Okahata) darrylo@hpsrdmo
; Language:     Emacs-Lisp
; Package:      N/A
; Status:       Experimental (Do Not Distribute)
;
; (C) Copyright 1989, Hewlett-Packard, all rights reserved.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Origin unknown.
;;	This copy was obtained from Rick Kunin (rickk@sperdk).
;;


;;>> Problem:  Tabs at beginning of lines

(defun display-line-numbers ()
  (interactive)
  (or (eq (current-buffer) (window-buffer (selected-window)))
      (error "%s is not the selected window's buffer."))
  (let ((buffer-read-only nil)
	(modified (buffer-modified-p))
	(name buffer-file-name)
	(point (point-marker))
	format-string
	line-number
	(count 0)
	nlines
	first-line)
    (save-restriction
      (widen)
      (save-excursion
	(setq first-line (window-start (selected-window)))
	(goto-char first-line)
	(setq line-number (1+ (count-lines (point-min) (point))))
	(move-to-window-line -1)
	(beginning-of-line)
	(setq nlines (count-lines first-line (point)))
	(let ((max (+ line-number nlines)))
	  (setq format-string (cond ((< max 100) "%2d ")
				    ((< max 1000) "%3d ")
				    ((< max 10000) "%4d ")
				    (t "%7d "))))))
    (save-excursion
      (unwind-protect
	  (progn
	    (goto-char first-line)
	    ;; defeat file locking... don't try this at home, kids!
	    (setq buffer-file-name nil)
	    (while (<= count nlines)
	      (insert-before-markers (format format-string line-number))
	      (setq insert-end (point))
	      (setq line-number (1+ line-number)
		    count (1+ count))
	      (forward-line 1))
	    (set-window-start (selected-window) first-line)
	    (goto-char point)
	    (set-buffer-modified-p modified)
	    (message "<<< Press SPACE to continue >>>")
	    (let ((char (read-char)))
	      (or (eql char ?\ )
		  (setq unread-command-char char))))
	(goto-char first-line)
	(let ((n (1+ (- (aref format-string 1) ?0))))
	  (while (> count 0)
	    (setq count (1- count))
	    (delete-char n)
	    (forward-line 1)))
	(setq buffer-file-name name)
	(set-buffer-modified-p modified)))))
