;; Dynamic abbreviation package for GNU Emacs.
;; Copyright (C) 1985, 1986 Free Software Foundation, Inc.
;; Extensions Copyright 1991, Frank Ritter.

;; This file used to be part of GNU Emacs.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.


; DABBREVS - "Dynamic abbreviations" hack, originally written by Don Morrison
; for Twenex Emacs.  Converted to mlisp by Russ Fish.  Supports the table
; feature to avoid hitting the same expansion on re-expand, and the search
; size limit variable.  Bugs fixed from the Twenex version are flagged by
; comments starting with ;;; .
; 
; converted to elisp by Spencer Thomas.
; Thoroughly cleaned up by Richard Stallman.
; Additional changes 10/91 Frank E. Ritter
; 1) Recycles markers,
; 2) Allows substitution inserts in a way that
;    keeps markers current for symbol mode,
; 3) Smarter about matching, i.e.,  can be set not to match itself or 
;    neighbors by specifying a min limit from point to start search.
; 4) Smarter about case matching: if matched word is lower case, trys to keep
;    match to be lower case, unless matched word is capitalized or all
;    uppercase, then provides a similar insertion.
; What case matching really should mean and if this code does it right 
; are not clear.
;
; If anyone feels like hacking at it, Bob Keller (Keller@Utah-20) first
; suggested the beast, and has some good ideas for its improvement, but
; doesn't know TECO (the lucky devil...).  One thing that should definitely
; be done is adding the ability to search some other buffer(s) if you can't
; find the expansion you want in the current one.

;; (defun dabbrevs-help ()
;;   "Give help about dabbrevs."
;;   (interactive)
;;   (&info "emacs" "dabbrevs")	; Select the specific info node.
;; )

(provide 'new-dabbrevs)

(defvar dabbrevs-max-limit nil
  "*Limit region searched by dabbrevs-expand to that many chars away (local).")
(make-variable-buffer-local 'dabbrevs-max-limit)

(defvar dabbrevs-backward-only nil
  "*If non-NIL, dabbrevs-expand only looks backwards.")

;;; New user Vars based on Ritter's work  ;;; -fer
(defvar dabbrevs-min-limit 0
  "*Minumum offset from point so that you don't match yourself or neighbors.")
(make-variable-buffer-local 'dabbrevs-min-offset)

(defvar dabbrevs-insert-before nil
  "*Insert abbreviation expansions before markers rather than after.")
(make-variable-buffer-local 'dabbrevs-insert-before)

; State vars for dabbrevs-re-expand.
(defvar last-dabbrevs-table nil
  "Table of expansions seen so far. (local)")
(make-variable-buffer-local 'last-dabbrevs-table)

(defvar last-dabbrevs-abbreviation ""
  "Last string we tried to expand.  Buffer-local.")
(make-variable-buffer-local 'last-dabbrevs-abbreviation)

(defvar last-dabbrevs-direction 0
  "Direction of last dabbrevs search. (local)")
(make-variable-buffer-local 'last-dabbrevs-direction)

(defvar last-dabbrevs-abbrev-location nil
  "Location last abbreviation began (local).")
(make-variable-buffer-local 'last-dabbrevs-abbrev-location)

(defvar last-dabbrevs-expansion nil
    "Last expansion of an abbreviation. (local)")
(make-variable-buffer-local 'last-dabbrevs-expansion)

(defvar last-dabbrevs-expansion-location nil
  "Location the last expansion was found. (local)")
(make-variable-buffer-local 'last-dabbrevs-expansion-location)

;;; New system Vars based on Ritter's work -fer
(defvar start-expand-location (make-marker)
  "Remembers where search started so you know where to start forward search.")
(make-variable-buffer-local 'start-expand-location)

(defvar dabbrevs-expansion-location-marker (make-marker)
  "Marker which marks where expansion has been found.")
(make-variable-buffer-local 'dabbrevs-expansion-location-marker)

(defvar dabbrevs-case nil "Remembers the original case of the expansion.")


;;;
;;;    I. dabbrev-expand
;;;

(defun dabbrev-expand (arg)
  "(This is the New CMU version.)
Expand previous word \"dynamically\". 
Expands to the most recent, preceding word for which this is a prefix.
If no suitable preceding word is found, words following point are considered.

A positive prefix argument, N, says to take the Nth backward DISTINCT
possibility.  A negative argument says search forward.  The variable
dabbrev-backward-only may be used to limit the direction of search to
backward if set non-nil.

If the cursor has not moved from the end of the previous expansion and
no argument is given, replace the previously-made expansion
with the next possible expansion not yet tried.
If INSERT-BEFORE is T, then insert the text before any markers.
Will only search dabbrevs-max-limit away from point, starting at least 
dabbrevs-min-limit characters away."
  (interactive "*P")
  (let (abbrev expansion old which loc n pattern
        ;;            V**** c-f-s is T if case is ignored
	(nocase (and (not case-fold-search) case-replace)))
    ;; abbrev -- the abbrev to expand
    ;; expansion -- the expansion found (eventually) or nil until then
    ;; old -- the text currently in the buffer
    ;;    (the abbrev, or the previously-made expansion)
    ;; loc -- place where expansion is found
    ;;    (to start search there for next expansion if requested later)
    ;; nocase -- non-nil if should consider case significant.
    (save-excursion
      (if (and (null arg)  ;; you are repeating
	       (eq last-command this-command)
	       last-dabbrevs-abbrev-location)   
	  (progn (setq abbrev last-dabbrevs-abbreviation)
                 (setq old last-dabbrevs-expansion)
                 (setq which last-dabbrevs-direction))
        ;; else you are starting out
	(setq which (if (null arg)
			(if dabbrevs-backward-only 1 0)
		        (prefix-numeric-value arg)))
	(setq loc (point))
        (set-marker start-expand-location (point))
	(forward-word -1)
	(setq last-dabbrevs-abbrev-location (point)) ; Original location.
	(setq abbrev (buffer-substring (point) loc))
	(setq old abbrev)
        ;; V**** change here to keep track of case
        ;; note case of abbrev, capitalized, upcase, downcase
        (setq dabbrevs-case (dabbrevs-find-case old))
        ;; V**** change here to cleanup marker -fer 1/91
        (set-marker dabbrevs-expansion-location-marker nil)
	(setq last-dabbrevs-expansion-location nil)
	(setq last-dabbrev-table nil))  	; Clear table of things seen.

      (setq pattern (concat "\\b" (regexp-quote abbrev) "\\(\\sw\\|\\s_\\)+"))
      ;; Try looking backward unless inhibited.
      (if (>= which 0)
	  (progn 
           (setq n (max 1 which))
	   (while (and (> n 0)
	               (setq expansion (dabbrevs-search pattern t nocase)))
             (setq loc (set-marker dabbrevs-expansion-location-marker (point)))
	     (setq last-dabbrev-table (cons expansion last-dabbrev-table))
	     (setq n (1- n)))
           (if expansion
               nil
               ;; else   V**** change here to cleanup marker -fer 1/91
               (if (markerp last-dabbrevs-expansion-location)
                   (set-marker last-dabbrevs-expansion-location nil))
               (setq last-dabbrevs-expansion-location nil))
	    (setq last-dabbrevs-direction (min 1 which))))

      (if (and (<= which 0) (not expansion)) ; Then look forward.
	  (progn (goto-char start-expand-location)
	    (setq expansion (dabbrevs-search pattern nil nocase))
	    (setq loc (set-marker dabbrevs-expansion-location-marker (point)))
	    (setq last-dabbrev-table (cons expansion last-dabbrev-table))
            (setq last-dabbrevs-direction -1))) )

    (if (not expansion)
	(let ((first (string= abbrev old)))
	  (setq last-dabbrevs-abbrev-location nil)
	  (if (not first)
	      (progn (undo-boundary)
		     (delete-backward-char (length old))
                     ;; V**** change here to keep track of case
                     ;; V**** change here from plain insert to keep
                     ;; all markers uptodate  -fer 1/91
		     (if dabbrevs-insert-before 
                         (insert-before-markers (dabbrevs-set-case abbrev))
                         (insert (dabbrevs-set-case abbrev)))))
	  (error (if first
		     "No dynamic expansion for \"%s\" found."
		     "No further dynamic expansions for \"%s\" found.")
		 abbrev))
      ;; Success: stick it in and return.
      (undo-boundary)
      (search-backward old)  
      ;; Make case of replacement conform to case of abbreviation
      ;; provided (1) that kind of thing is enabled in this buffer
      ;; and (2) the replacement itself is all lower case
      ;; except perhaps for the first character.
      (let ((nocase (and nocase
		        (string= expansion
                                 (concat (substring expansion 0 1)
                                         (downcase (substring expansion 1)))))))
        ;(replace-match (if nocase (downcase expansion) expansion)
	;       (not nocase) ;if t, keep case of original
	;      'literal)
        (replace-match (dabbrevs-set-case expansion)
	       (not nocase) ;if t, keep case of original
	      'literal)
        (if dabbrevs-insert-before ; cut out text and reinset it
            (let ( (new-exp (buffer-substring (- (point) (length expansion)) 
                                              (point))) )
              (delete-backward-char (length expansion))  
              (insert-before-markers new-exp)))
      ;; Save state for re-expand.
      (setq last-dabbrevs-abbreviation abbrev)
      (setq last-dabbrevs-expansion expansion)
      (setq last-dabbrevs-expansion-location loc)))))

;; change here -fer
(defun dabbrevs-find-case (item)  ;(dabbrevs-find-case "Ab")
  "Compute the case type of item."
  (cond ((upcase-p item) 'upcase)
        ((capital-p item) 'capital)
        (t 'downcase)))

;; additional function -fer
(defun dabbrevs-set-case (item)  ;(dabbrevs-set-case "Ab")
  "Set the case type of item."   ;(dabbrevs-set-case "AAABB")
  (cond ((eq dabbrevs-case 'upcase) ;(dabbrevs-set-case "aaabb")
         (upcase item))
        ((upcase-p item) item)
        ((eq dabbrevs-case 'capital)
         (capitalize item))
        ((capital-p item) item)
        (t item)))

;; additional function -fer
(defun capital-p (string-or-char)   ;(capital-p ?X) (capital-p "x")
  "Returns t is string-or-char begins with a capital or is a capital letter."
  (if (stringp string-or-char)
      (setq string-or-char (substring string-or-char 0 1)))
  (if (equal string-or-char (upcase string-or-char))
      t))

;; additional function -fer
(defun upcase-p (string-or-char)  ; (upcase-p "ASF")
 (cond ((stringp string-or-char)
        (if (>= (length string-or-char) 1)
            (and (capital-p (substring string-or-char 0 1))
                 (upcase-p (substring string-or-char 
                                      1 (length string-or-char))))
            t)) ;equal to the null string
       ((char-or-string-p string-or-char)
        (capital-p string-or-char))))

;; Search function used by dabbrevs library.  
;; First arg is string to find as prefix of word.  Second arg is
;; t for reverse search, nil for forward.  Variable dabbrevs-max-limit
;; controls the maximum search region size, dabbrevs-min-limit the minimum
;; separation.

;; Table of expansions already seen is examined in buffer last-dabbrev-table,
;; so that only distinct possibilities are found by dabbrevs-re-expand.
;; Note that to prevent finding the abbrev itself it must have been
;; entered in the table.

;; Value is the expansion, or nil if not found.  After a successful
;; search, point is left right after the expansion found.

(defun dabbrevs-search (pattern reverse nocase)
  (let (missing result close-point far-point)
   (save-restriction 	    
    ;; Uses restriction for limited searches.    ** -fer 2/91
    ;; min limit *is* a number, max can be nil which means to beg/end
    (setq close-point 
          (if reverse          
              (min last-dabbrevs-abbrev-location
                   (- start-expand-location
                      (if (and (null arg)  ;you are repeating, remove abbrev length
                 	       (eq last-command this-command)
                	       last-dabbrevs-abbrev-location)
                          (length last-dabbrevs-expansion) 
                          (length abbrev)) ;abbrev is bound above
                       dabbrevs-min-limit ))
              (max last-dabbrevs-abbrev-location
                   (+ (point) dabbrevs-min-limit))))
    (setq far-point 
          (if dabbrevs-max-limit
              (+ (point) (* dabbrevs-max-limit (if reverse -1 1)))
              (if reverse 1 (point-max)) )) ;; really needs to be current-buffer-size
    (narrow-to-region  close-point far-point)
    ;; Keep looking for a distinct expansion.
    (setq result nil)
    (setq missing nil)
    (while  (and (not result) (not missing))
	; Look for it, leave loop if search fails.
	(setq missing
	      (not (if reverse
		       (re-search-backward pattern nil t)
		       (re-search-forward pattern nil t))))

	(if (not missing)
	    (progn
	      (setq result (buffer-substring (match-beginning 0)
					     (match-end 0)))
	      (let* ((test last-dabbrev-table))
		(while (and test
			    (not
			     (if nocase
				 (string= (downcase (car test)) (downcase result))
			       (string= (car test) result))))
		  (setq test (cdr test)))
		(if test (setq result nil))))))	; if already in table, ignore
      result)))


