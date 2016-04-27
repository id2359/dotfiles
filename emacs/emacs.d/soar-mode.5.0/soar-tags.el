;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-tags.el
;;;; Author          : Michael Hucka
;;;; Created On      : Wed Feb 21 12:35:50 1990
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Tue Oct 13 00:05:07 1992
;;;; Update Count    : 22
;;;; 
;;;; PURPOSE
;;;; 	|>Description of module's purpose<|
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;; Copyright 1990, Mike Hucka.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; $Locker: hucka $
;;;; $Log:	soar-tags.el,v $
;;;; Revision 1.1  90/03/29  19:26:57  hucka
;;;; Initial revision
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'soar-tags)

;;;
;;; The package "tagify.el" posted to the unix-emacs newsgroup by Daniel
;;; LaLiberte in 1989 provides most of the functionality we need to implement
;;; the creation of tags tables for Soar.  tagify.el defines the following:
;;;
;;;   tagify-mode-list [variable]
;;;       "Association list between major modes and tag matching functions.
;;;       The function should find the next tag and return it, or return nil
;;;       if there are no more tags for the current buffer.  The tag is only
;;;       used to sort the entries for each file.  The function should leave
;;;       point after the tag."
;;;
;;;   tagify-files [function]
;;;       "Make a tags file from files listed in FILENAMES.  
;;;       The existing tags file, if any, is replaced.
;;;       FILENAMES are files to search for tags.  The FILENAMES argument may
;;;       actually specify several files, with shell wildcards, e.g. \"*.c
;;;       *.h\". Paths may be either absolute or relative to the current
;;;       directory. How to make tags is determined from tagify-mode-alist
;;;       and the major mode of each file."
;;;   
;;;   retagify-files [function]
;;;       "Update the TAGS file replacing entries only for files that
;;;       have changed since the TAGS file was saved."
;;;

(require 'tags)
(require 'tagify)			; Get Dan LaLiberte's tagify package


;;; Modifications for using tagify.el
;;;-----------------------------------------------------------------------------

;; 6-13-92 - redefine to deal with TAQL source as well as sps.  the
;; prefixes account for all TCs, and last pattern for the data-model
;; constructs.  see also the list of TCs in utilities/taql*indent*.el.

(defun make-soar-tag ()
  (interactive)
  (if (re-search-forward
       "^ ?(\\(sp\\|propose\\|prefer\\|compare\\|operator\\|apply\\|result\\|g\
oal\\|evaluat\\|augment\\|trace-attributes\\|untrace-atributes\\|defo\\)[^ ]* \
\\([^ \n]+\\) ?" nil t)
      (buffer-substring (match-beginning 2)
                        (match-end 2))))

;; (defun make-soar-tag ()
;;   (if (re-search-forward
;;        "^ ?(sp \\([^ \n]+\\) ?" nil t)
;;       (buffer-substring (match-beginning 1)
;; 			(match-end 1))))
;; 

(push (cons 'soar-mode 'make-soar-tag) tagify-mode-alist)

;; For mnemonic ease:

(fset 'make-tags-table (symbol-function 'tagify-files))
(fset 'remake-tags-table (symbol-function 'retagify-files))

(defun soar-find-tag ()
  (interactive)
 (find-tag (soar-symbol-under-cursor t "Find tag"))
)

;; From Segre's clisp.el:

(defun soar-list-tag-files ()
  "Lists all files currently in tag table."
  (interactive)
  (or tags-file-name
      (visit-tags-table "TAGS"))
  (tag-table-files)
  (with-output-to-temp-buffer "*Help*"
    (princ "Current tag table: ")
    (princ tags-file-name)
    (princ "\nFiles indexed by tag table:")
    (mapcar (function (lambda (file) 
	      (terpri)(princ " ")(princ file)))
	    tag-table-files)))
