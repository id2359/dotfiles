;;; sml-poly-ml.el: Modifies inferior-sml-mode defaults for Poly/ML.

;; Copyright (C) 1994, Matthew J. Morley

;; This file is not part of GNU Emacs, but it is distributed under the
;; same conditions.

;; ====================================================================

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to the
;; Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;; ====================================================================

;;; DESCRIPTION

;; To use this library just put

;;(autoload 'sml-poly-ml "sml-poly-ml" "Set up and run Poly/ML." t)

;; in your .emacs file. If you only ever use Poly/ML then you might as
;; well put something like

;;(setq sml-mode-hook
;;      '(lambda() "SML mode defaults to Poly/ML"
;;	 (define-key  sml-mode-map "\C-cp" 'sml-poly-ml)))

;; for your sml-mode-hook. The command prompts for the program name
;; and the database to use, if any. 

;;; CODE

(require 'sml-proc)

(defvar sml-poly-ml-error-regexp
  "^\\(Error\\|Warning\\) in \"\\(.*\\)\", line \\([0-9]+\\)"
  "*Default regexp matching Poly/ML error messages.")

;; The reg-expression used when looking for errors. Poly/ML errors:

;; Warning in "puzz.sml", line 28
;; Matches are not exhaustive.

;; Error
;; Value or constructor (tl) has not been declared
;; Found near tl(tl(tl(tl(N))))

;; (when input is from std_in -- i.e. entered directly at the prompt).

(defun sml-poly-ml-error-parser (pt) 
 "This function parses a Poly/ML error message into a 3 element list.
  (file start-line start-col)"
 (save-excursion
   (goto-char pt)
   (re-search-forward sml-poly-ml-error-regexp)      
   (list (buffer-substring (match-beginning 2) ; file
			   (match-end 2))
	 (string-to-int (buffer-substring      ; start line
			 (match-beginning 3)
			 (match-end 3)))
	 0))) 		                       ; start col

(defun sml-poly-ml ()
   "Set up and run Poly/ML.
Note: defaults set here will be clobbered if you setq them in the
{inferior-}sml-mode-hook.

 sml-program-name  <option>
 sml-default-arg   <option dbase>
 sml-use-command   \"PolyML.use \\\"%s\\\"\"
 sml-cd-command    \"PolyML.cd \\\"%s\\\"\"
 sml-prompt-regexp \"^[>#] *\"
 sml-error-regexp  sml-poly-ml-error-regexp
 sml-error-parser  'sml-poly-ml-error-parser"

   (interactive)
   (let ((cmd (read-string "Command name: " "poly"))
	 (dbase (read-file-name "Poly database? (may be none): " "" "")))
     (setq sml-program-name  cmd
	   sml-default-arg   (if (equal dbase "")
				 ""
			       (expand-file-name dbase))
	   sml-use-command   "PolyML.use \"%s\""
	   sml-cd-command    "PolyML.cd \"%s\""
	   sml-prompt-regexp "^[>#] *"
	   sml-error-regexp  sml-poly-ml-error-regexp
	   sml-error-parser  'sml-poly-ml-error-parser)
     (sml-run cmd sml-default-arg)))

(setq sml-program-name  "poly"
      sml-default-arg   ""
      sml-use-command   "PolyML.use \"%s\""
      sml-cd-command    "PolyML.cd \"%s\""
      sml-prompt-regexp "^[>#] *"
      sml-error-regexp  sml-poly-ml-error-regexp
      sml-error-parser  'sml-poly-ml-error-parser)

;;; sml-poly-ml.el ended just there
