;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-simple-menus.el
;;;; Author          : Frank Ritter
;;;; Created On      : Fri Jul 12 14:38:57 1991
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Nov 11 22:08:43 1992
;;;; Update Count    : 40
;;;; 
;;;; PURPOSE
;;;; 	Sets up the simple menus for soar-mode.
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;; Copyright 1991, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'simple-menu)
(provide 'soar-simple-menus)

(defun run-soar-menu () 
  "Provide a menu of commands for Soar and TAQL."
  (interactive)
  (run-menu 'soar-menu "Soar"))

(def-menu
  'soar-menu
  "" ;main prompt
  "The menu key allows you to select various command options" ;help prompt
   ;123456789012345
 '(
   ("Soar/           Do primarily Soar commands." soar-command-menu)
   ("Lisp/           Do primarily Lisp commands." ilisp-command-menu)
   ("Emacs/          Do plain Emacs commands."   emacs-menu)
))


(def-menu 'soar-command-menu
  "Soar Options"
  "" ;help prompt
 '(("About        About soar-mode." describe-mode)
   ("Documents/   Examine various manuals."   soar-document-menu)
   ("Commands/    Other commands in soar-mode."   other-soar-command-menu)
   ("Prod/        Do stuff to productions." production-command-menu)
   ("TimeStamps/  Insert the date and/or time." soar-timestamp-menu)
   ("Outl/        Outline functions for Soar programs." soar-outline-menu)
   ("Switch       Switch to the running Soar buffer." switch-to-lisp)
;  ("Varset/     menu to set variables."   soar-variables-menu)
))

(def-menu
  'soar-document-menu 
  "" ;main prompt
  "The menu key allows you to select various documents to browse:" ;help prompt
  ;; all manuals should live in the manuals sub-directory
 '(("1-Man52      Main Soar manual."   
   (goto-manual "Soar5-manual.doc" 'soar-mode))
   ("3-soar-mode  soar-mode manual." (goto-manual "soar-mode.doc" 'soar-mode))
   ("5-Soar5      Soar 5 specific documents." soar-document-menu5)
   ("6-Soar6      Soar 6 specific documents." soar-document-menu6)
))

(def-menu
  'soar-document-menu5
  "" ;main prompt
  "The menu key allows you to select various documents to browse:" ;help prompt
  ;; all manuals should live in the manuals sub-directory
 '(
   ("2-521RN      5.2.1 Release notes." 
        (goto-manual "5.2.1-release-notes" 'soar-mode))
   ("4-SX         SX manual.      " (goto-manual "sx-manual.doc" 'soar-mode))
))

(def-menu
  'soar-document-menu6
  "" ;main prompt
  "The menu key allows you to select various documents to browse:" ;help prompt
  ;; all manuals should live in the manuals sub-directory
 '(
))

(def-menu 'other-soar-command-menu
  "Soar things"
  "" ;help prompt
 '(("1LoadFil    Load a file into Soar." soar-load-file)
   ("2LoadBuf    Load a buffer and go into Soar." soar-load-buffer)
   ("Headr       Make a file header." make-header)
   ("Rev         Make a revision line in header." make-revision)
   ("FindTT      Find (use) a tags-table.  W/ prompt and file name completion."
                 find-tags-table)
   ("Tag         Make a tags table for a list of files." make-tags-table)
   ("Rtag        Remake a tags table for a list of files.
                  (This is faster than Tag.)"           remake-tags-table)
   ("Count       Count the number of productions in current buffer."
                 soar-count-productions)
   ("ListPs      Soar-list-production-names" soar-list-production-names)
   ("Select      Select the Soar process for this buffer." select-ilisp)
   ("Bug         Generate a bug report"  soar-bug)
))

(def-menu 'production-command-menu
  "Production"
  "" ;help prompt

 '(("Break        Pbreak production." soar-pbreak-production)
   ("Smatch       SMatch production (matches 0)."  soar-smatches-production)
   ("FullM        Full-matches on production (matches 1)." 
                  soar-full-matches-production)
   ("RFullM       Really-Full-matches on production (matches 2)." 
                  soar-really-full-matches-production)
   ("Load         Load the production into Soar." eval-defun-lisp)
   ("2Load        Load the production into Soar and go there." 
                      eval-defun-and-go-lisp)
   ("Prin         SPR production."  soar-spr-production)
   ("Trace        Traces the previous production." soar-ptrace-production)
   ("Xcise        Excise production."     soar-excise-production)
   )
)

(def-menu 'soar-timestamp-menu
 "Time Stamps"
 ""
 '(("DateStamp       Insert a date only timestamp."  insert-date-string)
   ("TimeStamp       Insert a time only timestamp."  insert-time-string)
   ("FullTimeStamp   Insert a full day/date/hour timestamp."
    insert-current-time-string)
   )
)

(def-menu 'soar-outline-menu
  "Outline"
  "" ;help prompt
 '(("Next         Move to next visible heading." outline-next-visible-heading)
   ("Prev         Move to previous visible heading." 
                  outline-previous-visible-heading)
   ("Forw         Forward same level." outline-forward-same-level)
   ("Back         Backward same level." outline-backward-same-level)
   ("Up           Up a heading." outline-up-heading)
   ("AllShow      Show all." show-all)
   ("1head        Insert problem space header." soar-insert-ps-header)
   ("2head        Insert operator header." soar-insert-op-header)
   ("Show         Show menu." soar-outline-show-menu)
   ("Hide         Hide menu." soar-outline-hide-menu)
   )
)

(def-menu 'soar-outline-show-menu
  "Outline: SHOW"
  "" ;help prompt
 '(("SubTree      Show sub-tree." show-subtree)
   ("Child        Show children (takes arg with C-u)." show-children)
   ("Entry        Show entry." show-entry)
   ("Leaves       Show leaves." show-branches)
   )
)

(def-menu 'soar-outline-hide-menu
  "Outline: HIDE"
  "" ;help prompt
 '(("SubTree      Hide subtree." hide-subtree)
   ("Body         Hide body." hide-body)
   ("Entry        Hide entry." hide-entry)
   ("Leaves       Hide leaves." hide-leaves)
   )
)

;; example of leaving old menu format.
;(defun replace-menu ()
;  "Options for finding & replacing strings in current buffer:
; Interactive  Check each occurance before replace. [default]
; All          Replace all occurances without asking.
; -------
; Regexp   Search & replace using a regular expression.
; String   Search & replace any string of characters.
; Tags     Search & replace through all files listed in tag table.
;"
;  (interactive)
;  (let ((prompt "Replace: All Help Regexp String Tag ")
;        (opt nil)
;        (forward t)
;        (interactive t))
;    (while (not opt)
;      (message prompt)
;      (setq opt (downcase (read-char)))
;      (if (= opt ?h) (setq opt
;                           (pop-up-help 'replace-menu "Replace option: ")))
;      (cond ((= opt ?i)                 ; Set for interactive search
;             (setq interactive t)
;             (setq prompt "Replace: All Help Regexp String Tag ")
;             (setq opt nil))
;            ((= opt ?a)                 ; Set for noninteractive search
;             (setq interactive nil)
;             (setq prompt "Replace: Interactive Help Regexp String Tag ")
;             (setq opt nil))
;            ((= opt ?s)                 ; String replace
;             (if interactive (call-interactively 'query-replace)
;               (call-interactively 'replace-string)))
;            ((= opt ?r)                 ; Regexp search
;             (if interactive (call-interactively 'query-replace-regexp)
;               (call-interactively 'replace-regexp)))
;            ((= opt ?t)                 ; Tags search
;             (call-interactively 'tags-query-replace))
;            (t (ding)))))
;  )
