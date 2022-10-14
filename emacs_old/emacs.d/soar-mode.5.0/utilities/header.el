;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : header.el
;;;; Author          : Michael Hucka
;;;; Created On      : Sun Oct 15 01:29:12 1989
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Tue Jan 14 18:23:43 1992
;;;; Update Count    : 40
;;;; 
;;;; PURPOSE
;;;; 	Soar file header facility, based on code from Lynn Slater for Ada code.
;;;; TABLE OF CONTENTS
;;;;  User Commands:
;;;;   M-x make-header
;;;;   M-x make-revision
;;;;   M-x make-divisor
;;;;   M-x make-box-comment
;;;; Customizer commands
;;;;   register-file-header-action
;;;; Customizer variables
;;;;   header-copyright-notice
;;;;   make-header-hooks
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; $Locker:  $
;;;; $Log:	soar-header.el,v $
;;;; Revision 1.5  90/02/15  14:27:36  hucka
;;;; Fixed up header-make-toc.
;;;; 
;;;;
;;;; 4-Sep-91 - Frank Ritter fixed update-file-name
;;;; 3-Jun-1991 - Frank Ritter  changed header title on file
;;;; desciption to describe file's purpose.
;;;; 31-Oct-1989		Michael Hucka	(on osprey.eecs.umich.edu)
;;;;    Last Modified: Tue Oct 31 00:34:19 1989 #15 (Michael Hucka)
;;;;    Created functions header-rcs-locker, header-rcs-header; fiddled with
;;;;    comment settings; made default header info something which I think
;;;;    is general for most users, not just Soar people, with the intent that
;;;;    package-specific settings like for Soar mode will go into a separate
;;;;    site initialization package, so that this header package can remain
;;;;    generic.
;;;; 15-Oct-1989		Michael Hucka	(on eagle.eecs.umich.edu)
;;;;    Last Modified: Sun Oct 15 01:31:54 1989 #1 (Michael Hucka)
;;;;    Fixed up header-prefix-string function to handle modes in a more
;;;;    general manner, and also set header-prefix-string properly (i.e.,
;;;;    according to accepted Lisp convention) for lisp code files. 
;;;; 14-Oct-1989		Michael Hucka	(on eagle.eecs.umich.edu)
;;;;    Hacked various little details to fit my conception of a good file
;;;;    header . . .
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; TO DO:
;;;; 1) fix problem with searching for "Update count" reaching eof & failing.
;;;; 2) Fix make-divisor
;;;; 3) Fix make-box-comment
;;;; 4) Integrate with Slater's file declarations package.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; header.el --- Support for creation and automatic update of file headers
;; Author          : Lynn Slater
;; Created On      : Tue Aug  4 17:06:46 1987
;; Last Modified By: Michael Hucka
;; Last Modified On: Sat Oct 14 14:50:19 1989
;; Update Count    : 125
;; Status          : OK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (C) 1988 Lynn Randolph Slater, Jr.
;; Copyright (C) 1989 Free Software Foundation, Inc.
;; This file is compatable with GNU Emacs but is not part of the official
;; distribution (yet).
;;
;; This file is distributed in the hope that it will be useful,
;; but without any warranty.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.
;;
;; Everyone is granted permission to copy, modify and redistribute
;; this file, but only under the conditions described in the
;; document "GNU Emacs copying permission notice".   An exact copy
;; of the document is supposed to have been given to you along with
;; this file so that you can know how you may redistribute it all.
;; It should be in a file named COPYING.  Among other things, the
;; copyright notice and this notice must be preserved on all copies.

;; This file adds support for the creation and automatic maintenence of file
;; headers such as the one above.
;;  User Commands:
;;   M-x make-header
;;   M-x make-revision
;;   M-x make-divisor
;;   M-x make-box-comment
;; Customizer commands
;;   register-file-header-action
;; Customizer variables
;;   header-copyright-notice
;;   make-header-hooks
;;
;; This file is particularly useful with the file-declarations package also
;;   by Lynn Slater.
;; Make this file header.el, byte-compile it in your path
;;
;; Read the first 20% of this file to learn how to customize.

;; History 		
;; 8-Aug-1989		Lynn Slater	
;;    Last Modified: Thu Aug  3 08:04:06 1989 #88 (Lynn Slater)
;;    Changed structure to allow site/user customized headers
;; 24-Jun-1989		Lynn Slater	
;;    Last Modified: Thu Jun 22 12:52:24 1989 #84 (Lynn Slater)
;;    restructured file, made the order of header actions not be significant.
;; 22-Jun-1989		Lynn Slater	
;;    Last Modified: Thu Jun 22 11:40:53 1989 #82 (Lynn Slater)
;;    Made file header actions easier to declare
;;    Made sccs and rcs support be user settable.
;;    Added c-style support
;; 25-Jan-1989		Lynn Slater	
;;    Last Modified: Wed Jan 25 12:03:23 1989 #78 (Lynn Slater)
;;    Added make-doc command
;; 25-Jan-1989		Lynn Slater	
;;    Last Modified: Tue Sep  6 07:57:22 1988 #77 (Lynn Slater)
;;    made the make-revision command include the last-modified data
;; 31-Aug-1988		Lynn Slater	
;;    Made the make-revision work in most modes
;;    Added the update-file-name command
;; 1-Mar-1988		Lynn Slater
;;   made the headers be as sensitive as possible to the proper
;;   comment chars.
;; 1-Mar-1988		Lynn Slater
;;   Made the mode be declared in each header
;; 26-Feb-1988		Lynn Slater
;;   added the make-revision call
(provide 'header)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User/Site Customizable Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar header-max 1000
  "Is the number of characters at the start of a buffer that will be
   searched for header info to automatically update.")

(defvar header-copyright-notice nil
  "A string containing a copyright disclaimer to be inserted into all headers.
   This string needs no leading blanks and may contain any number of lines.
   May be nil.")

(defvar make-header-hooks '(
			    header-blank
			    header-file-name
			    header-author
			    header-creation-date
			    header-modification-author
			    header-modification-date
			    header-update-count
			    ;;General want either RCS stuff or header-history
			    ;;header-status
			    ;;header-rcs-locker
			    ;;header-rcs-header
			    ;;header-rcs-log
			    header-blank
			    header-copyright
			    header-blank
			    header-purpose
			    header-history
			    header-toc
			    )

  "A list of functions which will insert the various header elements.
   Each function is started on a new line and is expected to end in a new line.
   Each function may insert any number of lines, but each line, including
   the first, must be started with the value of the header-prefix-string
   variable. (This variable holds the same value as would be returned by
   calling 'header-prefix-string but is faster to access.)
   Each function may set the following dynamically bound values:
     header-prefix-string -- mode specific comment sequence
     return-to        -- character position to which point will be moved
                         after all header functions are processed. Any
                         header function may set this, but only the last
                         set will take effect.

   It would be reasonable to locally set these hooks according to certain
   modes. For example, a table of contents may only apply to code development
   modes.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; System Variables -- Do not modify. Instead, call the functions that modify.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar file-header-update-alist ()
  "Used by update file header to know what to do in the file. Is a list of
   sets of cons cells where the car is a regexp string and the cdr is the
   fcn to call if the string is found near the start of the file.")  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define the individual header elements.  THESE ARE THE BUILDING BLOCKS
;; used to construct a site specific header.  You may add your own
;; functions either in this file or in your .emacs file.  The variable
;; make-header-hooks specifies the functions that will actually be called.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun header-blank ()
  "Places a blank line into a file header"
  (insert header-prefix-string  "\n"))

(defun header-divisor-line ()
  "Insert a divisor line (comment start, filler + comment end) into file header."
  (make-divisor))

(defun header-file-name ()
  "Places the buffer's file name."
  (insert header-prefix-string "File            : "
          (if buffer-file-name
             (file-name-nondirectory buffer-file-name)
             (buffer-name))
          "\n")
  ;; 14-Jan-92 -FER had been (buffer-name), but this is wrong sometimes.
  (setq return-to (1- (point))))

(defun header-author ()
  "Inserts the current user's name as the module's author."
  (insert header-prefix-string "Author          : " (user-full-name) "\n"))

(defun header-creation-date ()
  "Places today's data as the file creation date."
  (insert header-prefix-string "Created On      : "  (current-time-string) "\n"))

(defun header-modification-author ()
  "Inserts the current user's name as the one who last modified the module.
   This will be overwritten with each file save if all the
   file-header-actions in the default header.el file are registered."
  (insert header-prefix-string  "Last Modified By: \n"))

(defun header-modification-date ()
  "Inserts todays date as the time of last modification.
   This will be overwritten with each file save if all the
   file-header-actions in the default header.el file are registered."
  (insert header-prefix-string  "Last Modified On: \n"))

(defun header-update-count ()
  "Inserts a count of the number of times the file has been saved.  This is
  often a more useful measure of 'age' and 'modifications' than dates
  recorded in the file system.  It is a handy code metric that is a
  surprizingly good indication of file complexity and can often help
  indicate which modules have been changed so much that they need a rethink.
  It also assist recovery from source control mixups."  
  (insert header-prefix-string  "Update Count    : 0\n"))

(defun header-status ()
  "Inserts a status line that should be manually edited to reflect the
   general condition of the entire module."
  (insert header-prefix-string
	  "Status          : Unknown, Use with caution!\n"))


(defun header-history ()
  "Inserts HISTORY line into header for later use by make-revision.
   Without this, make history will insert after the header."
  (insert header-prefix-string  "HISTORY\n")
  (insert header-prefix-string "\n"))


(defun header-purpose ()
  "Inserts a line that starts a section that should describe the purpose of
   the file/module."
  (insert header-prefix-string  "PURPOSE\n"
	  header-prefix-string "	|>Describe module's purpose<|")
  (setq return-to (- (point) 35))
  (insert "\n"))


(defun header-toc ()
  "Inserts a line that starts a section that should describe each function
   defined in the module that is significant to external users."
  (insert header-prefix-string  "TABLE OF CONTENTS\n"
	  header-prefix-string "	|>Contents of this module<|\n" 
	  header-prefix-string "\n"))


;;;
;;; RCS functions.
;;; Updated Tue Oct 17 14:22:45 1989 -- Michael Hucka
;;;  Separated into individual functions for Log, Header, and Locker fields.
;;;

(defun header-rcs-log ()
  "Inserts lines to record RCS 'Log' information."
  (insert header-prefix-string
	  ;; This is stupid but necessary:  if you leave the RCS header here
	  ;; immediately surrounded by dollar signs, guess what happens?
	  ;; Yup, when you run RCS on *this* file, it gets updated right here
	  ;; too.  So, break it up into individual substrings.  Sigh.
	  "$" "Log" "$\n"))


(defun header-rcs-header ()
  "Inserts lines to record RCS 'Header' information."
  (insert header-prefix-string
	  "$" "Header" "$\n"))


(defun header-rcs-locker ()
  "Inserts lines to record RCS 'Locker' information."
  (insert header-prefix-string
	  "$" "Locker" "$\n"))


(defun header-sccs ()
  "Inserts a line to record sccs information."
  (insert header-prefix-string "SCCS Status     : %W%\t%G%\n"))


(defun header-copyright ()
  "Inserts the copyright notice stored in the variable  header-copyright-notice.
   This value may be nil."
  (if header-copyright-notice
      (let ((start (point)))
	(insert header-copyright-notice)
	(save-restriction
	  (narrow-to-region start (point))
	  (goto-char (point-min))
	  ;; I must now insert the header prefix.  I cannot just do a
	  ;; replace string because that would cause too many undo boundries.
	  (insert header-prefix-string)
	  (while (progn (skip-chars-forward "^\n") (looking-at "\n"))
	    (forward-char 1)
	    (insert header-prefix-string))
	  (goto-char (point-max)))
	(insert "\n"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User function to declare header actions on a save file.
;;   See examples at the end of this file.
;; Modify here, in site-init.el, or in .emacs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun register-file-header-action (regexp function-to-call)
  "Accepts REGEXP and FUNCTION-TO-CALL. Records 
   FUNCTION-TO-CALL as the appropiate action to take if the REGEXP is
   found in the file header when a file is written.  The function will be
   called with the cursor located just after the matched regexp.

   Calling this fcn twice with the same arguments overwrites
   the previous FUNCTION-TO-CALL"
  (let ((ml (assoc regexp file-header-update-alist)))
    (if ml
	(setcdr ml function-to-call);; overwrite old defn
      ;; This is new to us. Add to the master alist
      (setq file-header-update-alist
	    (cons (cons regexp function-to-call)
		  file-header-update-alist)))))

      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Header and file division header creation code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun true-mode-name ()
  "Returns the name of the mode in such a form that the mode may be
  re-established by calling the function named by appending '-name' to
  this string.  This differs from the variable called mode-name in that
  this is guaranteed to work while the values held by the variable may
  have embedded spaces or other junk.

  THIS MODE NAME IS GUARANTEED OK TO USE IN THE MODE LINE."
  (let ((major-mode-name (symbol-name major-mode)))
    (capitalize (substring major-mode-name 0
			   (or   (string-match "-mode" major-mode-name)
				 (length major-mode-name))))))


(defun header-prefix-string ()
  "Returns a mode specific prefix string for use in headers. Is sensitive
   to the various language dependent comment coventions."
  (let ((comment-end-p (and comment-end
			    (not (string-equal comment-end "")))))
    (cond
      ((eq major-mode 'c-mode)
       (concat comment-start " "))
      ((eq major-mode 'fundamental-mode)
       " ")
      ((string-match "lisp" (downcase (format "%s" major-mode)) 0)
       ";;;; ")
      ((string-match "soar" (downcase (format "%s" major-mode)) 0)
       ";;;; ")
      ((and comment-start (= (length comment-start) 1))
       (concat comment-start comment-start " "))
      ;; Special case, three letter comment starts where the first and
      ;; second letters are the same. (i.e. c++ and ada)
      ((and comment-start (= (length comment-start) 3)
	    (equal (aref comment-start 1) (aref comment-start 0)))
       comment-start)
      ;; Other three letter comment starts -> grab the middle character
      ((and comment-start (= (length comment-start) 3))
       (concat " " (list (aref comment-start 1)) " "))
      ;; 
      ((and comment-start (not comment-end-p))
       ;; Note: no comment end implies that the full comment start must be
       ;; used on each line.
       comment-start)
      (t				; I have no idea what is a good block 
					; start character.  Punt.  Make it pretty.
       ";; "))
    ))

(defun make-header ()
  "Makes a standard file header at the top of the buffer. A header is
   composed of a mode line, a body, and an end line.  The body is
   constructed by calling the functions in make-header-hooks.
   The mode line and end lines start and terminate block comments while the
   body lines just have to continue the comment. "
  (interactive)
  (beginning-of-buffer)
  (let ((return-to nil)       ;;; to be set by make-header-hooks functions
	(header-prefix-string (header-prefix-string)) ;;; cache the result
	(comment-start-p
	 (and comment-start (not (string-equal comment-start ""))))
	(comment-end-p (and comment-end (not (string-equal comment-end "")))))

    ;; Start the header
    (insert (concat header-prefix-string
	            "-*- Mode: " (true-mode-name)
		    (if (assoc 'c-style (buffer-local-variables))
			(concat "; C-Style: " (symbol-name c-style))
			"")
		    " -*- ")
	    (if comment-end-p
		comment-end
		"")
	    "\n")

    ;; Insert a line of comments:
    (make-divisor)

    ;; Do the header body
    (mapcar 'funcall make-header-hooks)

    ;; Finish the header
    (make-divisor)
    (insert "\n")

    ;; Move to wherever return-to was set
    (if return-to (goto-char return-to))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun current-d-m-y-string ()
  (let ((str (current-time-string)))
    (concat (if (equal ?\  (aref str 8))
		       (substring str 9 10)
		       (substring str 8 10))
	    "-"
	    (substring str 4 7)
	    "-"
	    (substring str 20 24))))

(defun make-revision ()
  "Inserts a revision marker after the history line.  Makes the history
   line if it does not already exist."
  (interactive)
  (let ((header-prefix-string (header-prefix-string))
	(logical-comment-start
	 (if (= (length comment-start) 1)
	     (concat comment-start comment-start " ")
	   comment-start)))

    ;; Look for the History line
    (beginning-of-buffer)
    (if (re-search-forward (concat "^\\("
				   (regexp-quote (header-prefix-string))
				   "\\|"
				   (if (and comment-start
					    (not (string-equal comment-start "")))
				       (concat
					"\\|" (regexp-quote comment-start))
				     "")
				   "\\)"
				   " *History")
			   header-max t)
	(progn (end-of-line))
      (progn
	;; We did not find a history line, add one
	(beginning-of-buffer)
	;; find the first line that is not part of the header
	(while (and (< (point) header-max)
		    (looking-at
		     (concat "[ \t]*\\("
			     (regexp-quote (header-prefix-string))
			     (if (and comment-start
				      (not (string-equal comment-start "")))
				 (concat
				  "\\|" (regexp-quote comment-start))
			       "")
			     (if (and comment-end
				      (not (string-equal comment-end "")))
				 (concat "\\|" (regexp-quote comment-end))
			       "")
			     "\\)")))
	  (forward-line 1))
	(insert "\n" logical-comment-start
		"HISTORY ")
	(save-excursion (insert "\n" comment-end))))

    ;; We are now on the line with the history marker
    
    (insert "\n"
	    header-prefix-string
	    (current-d-m-y-string)
	    "\t\t"
	    (user-full-name)
	    "\t"
	    "(on " (system-name) ")"
	    "\n"
	    header-prefix-string
	    "   "
	    )
    ;; Now, add details about the history of the file before its modification
    (if (save-excursion
	  (re-search-backward "Last Modified On: \\(.+\\)$" nil t))
	(progn
	  (insert "Last Modified: " (buffer-substring (match-beginning 1)
						      (match-end 1)))
	  (if (save-excursion
		(re-search-backward "Update Count[ \t]*: \\([0-9]+\\)$" nil t))
	      (insert " #" (buffer-substring (match-beginning 1)
					     (match-end 1))))
	  (if (save-excursion
		(re-search-backward "Last Modified By[ \t]*: \\(.+\\)$" nil t))
	      (insert " (" (buffer-substring (match-beginning 1)
					     (match-end 1))
		      ")"))
	  (insert "\n" header-prefix-string "   ")))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun make-divisor ()
  "A divisor line is the comment start, filler, and the comment end"
  (interactive)
  (let* ((comment-start (or comment-start ";"))
         (comment-start-p
	  (and comment-start (not (string-equal comment-start ""))))
	 (comment-end-p (and comment-end (not (string-equal comment-end ""))))
	 (two-char-comment (if (> (length comment-start) 1) t nil))
	 (filler (if two-char-comment
		     (aref comment-start 1)
		     ;;else
                     (aref comment-start 0))) )
    ;;First char of comment
    (insert (aref comment-start 0))	
    ;;Second char of comment if comment-start is longer than 1 char
    (if two-char-comment
	(insert (aref comment-start 1)))
    ;;Insert filler
    (insert (make-string (- 79
			    (if comment-end-p (length comment-end) 0)
			    (if comment-start-p (length comment-start) 0))
			 filler))
    ;;If the first char of comment-end is a space, ignore it and take the
    ;; rest of the comment-end string.
    (if (and comment-end-p (char-equal (aref comment-end 0) ? ))
	(insert (substring comment-end 1) "\n")
	;;else
	(insert (if comment-end-p comment-end "") "\n"))))


(defun make-box-comment (&optional end-col)
  "Inserts a box comment that is built using mode specific comment characters."
  (interactive)
  (if (not (= 0 (current-column))) (forward-line 1))
  (insert comment-start)
  (if (= 1 (length comment-start))
      (insert comment-start))
  (if (not (char-equal (preceding-char) ? )) (insert ? )) 
  (insert (make-string (max 2
			    (- (or end-col fill-column ) (length
							       comment-end)
			       2 (current-column)))
                       (aref comment-start
			     (if (= 1 (length comment-start)) 0 1))
		       ))
  (insert "\n" (header-prefix-string) )
  (save-excursion
    (insert "\n" (header-prefix-string)
	    (make-string (max 2
			      (- (or end-col fill-column) (length
								 comment-end)
				 2 (current-column)))
			 (aref comment-start
			       (if (= 1 (length comment-start)) 0 1))
			 )
	    comment-end "\n")))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatic Header update code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun update-file-header ()
  "If the file has been modified, searches the first header-max chars in the
   buffer using the regexps in file-header-update-alist. When a match is
   found, it applies the corresponding function with the point located just
   after the match.  The functions can use (match-beginning) and
   (match-end) calls to find out the strings that causes them to be invoked." 
  (interactive)
  (if (and (> (buffer-size) 100) (buffer-modified-p) (not buffer-read-only))
      (save-excursion
	(save-restriction ;; only search the header-max number of characters
	  (narrow-to-region 1 (min header-max (- (buffer-size) 1)))
	  (let ((patterns file-header-update-alist))
	    ;; do not record this call as a command in the command history
	    (setq last-command nil)
	    (while patterns
	      (goto-char (point-min))
	      (if (re-search-forward (car (car patterns)) nil t)
		  (progn
		    ;; position the cursor at the end of the match
		    (goto-char (match-end 0))
		    ;;(message "do")
		    (funcall (cdr (car patterns)))))
	      (setq patterns (cdr patterns))
	      )
	    )))))

;; Place the header update function as a write file action
(if (not (memq 'update-file-header write-file-hooks))
    (setq write-file-hooks (cons 'update-file-header write-file-hooks)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Now, define the individual file header actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun delete-and-forget-line ()
  ;; does not place the line in the kill-ring
  (let* ((start (point))
	 (stop  (progn (end-of-line) (point)))
	 (str   (buffer-substring start stop))
	 )
  (delete-region start stop)
  str))

(defun update-write-count ()
  (let ((num)
	(str  (delete-and-forget-line)))
    (setq num (car (read-from-string str)))
    (if (not (numberp num))
	(progn
	  (insert str)
	  (error "invalid number for update count '%s'" str))
      (progn
	;;(message "New write count=%s" num)
	(insert (format "%s" (+ 1 num)))))
    ))

(defun update-last-modifier ()
  (delete-and-forget-line)
  (insert (format "%s" (user-full-name)))
  )

(defun update-last-modified-date ()
  (delete-and-forget-line)
  (insert (format "%s" (current-time-string)))
  )

(defun update-file-name ()
  (let ((header-prefix-string (header-prefix-string)))
    (delete-and-forget-line)
    (insert (format "%s" (buffer-name)))
))


;;(setq file-header-update-alist nil)
;;(setq file-header-update-alist (cdr file-header-update-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Register the automatic actions to take for file headers during a save
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(progn
  (register-file-header-action "[ \t]Update Count[ \t]*: "  'update-write-count)
  (register-file-header-action "[ \t]Last Modified By: "  'update-last-modifier)
  (register-file-header-action "[ \t]Last Modified On: "  'update-last-modified-date)
  (register-file-header-action "[ \t]File[ \t]*: " 'update-file-name)
  ;;(register-file-header-action "^.* *\\(.*\\) *\\-\\-" 'update-file-name)
  )

;(re-search-forward "[ \t]File[ \t]*:"  nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Things still to do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; need ez access to values in the header 
;; need a headerp fcn

