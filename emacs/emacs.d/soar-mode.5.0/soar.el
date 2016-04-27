;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar.el
;;;; Author          : Michael Hucka
;;;; Created On      : Sat Oct 14 14:45:09 1989
;;;; Last Modified By: Thomas McGinnis
;;;; Last Modified On: Thu Dec  3 15:57:31 1992
;;;; Update Count    : 262
;;;; 
;;;;
;;;;			     GNU Emacs Soar mode
;;;;
;;;;		  Based on CMU lisp Common Lisp interface
;;;;  Soar interface functionality from "hypersoar" mode by Frank Ritter @ CMU
;;;;       Additional code by Michael Hucka & Scott Huffman @ Univ. of Michigan
;;;;  How to set it up is in the DOC file.
;;;;
;;;; TABLE OF CONTENTS
;;;;    i.      Comments on your .emacs file
;;;; 	ii.	Critical Global variables and macros.
;;;;    iii.    General Global variables
;;;;	iv.	Buffer-specific variables
;;;;    
;;;;    I. 	Code to load the rest of the packages.
;;;;    II.	Changes to other modes to handle soar
;;;;    N.	Run user set hook and provide soar
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; $Locker:  $
;;;; $Log:	soar.el,v $
;;;; Revision 1.4  92/02/13  13:18:47  hucka
;;;; 1) Moved setting of soar-manual's pathname to soar-site.el.
;;;; 2) Moved (provide 'soar) to the top of the file.
;;;; 3) Did (require 'soar-site) instead of (load "soar-site")
;;;; 4) Fixed an erroneous document string for the soar-bug function.
;;;; 
;;;; Revision 1.3  92/01/27  11:44:06  hucka
;;;; Moved comments about things left to do to a new file in this directory,
;;;; "TODO".  I was annoyed by the clutter that this stuff caused in this file.
;;;; 
;;;; Revision 1.2  92/01/15  22:04:01  hucka
;;;; 1) Set coming-prompt-regexp to something that will recognize a prompt of the
;;;;    form "<56 soar>".
;;;; 2) Defined dialect `remote-soar'.
;;;; 3) Fixed up the appearance of some comments and indentation here and there.
;;;; Added variable soar-beep-after-setup-p.
;;;; 
;;;; Revision 1.1  92/01/15  22:02:49  hucka
;;;; 1) Set coming-prompt-regexp to something that will recognize a prompt of the
;;;;    form "<56 soar>".
;;;; 2) Defined dialect `remote-soar'.
;;;; 3) Fixed up the appearance of some comments and indentation here and there.
;;;; 
;;;; Revision 1.2  90/03/29  19:27:19  hucka
;;;; Initial release version.
;;;; 
;;;; Revision 1.1  90/02/15  14:02:15  hucka
;;;; Initial revision
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'soar)

(require 'soar-site)

(require 'soar-variables)


;;;  	ii.	YOUR .EMACS FILE
;;;===========================================================================
;;;  What you need to put in your .emacs file is in
;;;  soar-mode-defaults.el, which is also in this directory.
;;;



;;;
;;;	iii. 	Global variables
;;;---------------------------------------------------------------------------

;;;
;;; 	iii.a	Typically set by users 
;;; who should set them with setq in their .emacs file.
;;;

(defvar soar-version "6"
  "*Version of the Soar program run to put into headers, etc.")

;; Used by soar-mode, the function.
(defvar soar-mode-hook nil
  "*Hook run after invoking soar-mode, for customising the editing
 environment.")

(defvar soar-hook nil
  "*Hook run after starting up an inferior *soar* buffer, for customising
the interaction environment.  Could perhaps be called isoar-hook.")

(defvar soar-mode-load-hook nil
  "*Hook run at the end of loading this file.  This is a good place to put
keybindings.")

(defvar soar-print-into-diversion-p t 
 "*If t (default), prints descriptions into soar-diversion-buffer (*glide*)
buffer.  If nil, dump such printouts into *soar* buffer.")

(defvar soar-erase-diversion-buffer-p t
 "*If t (default), erase *glide* buffer before printing into it.")

(defvar soar-popup-diversion-buffer-p t
 "*If t (default), popup glide buffer when printing into it.")

(defvar pop-up-cms nil
  "*Pop up the CMS buffer if it is being written to (default nil).")

(defvar soar-default-drm-arg 1
  "*Default arg (1) for d, r, and macrocyle when called from soar-mode.
It is set to the last arg passed in soar-mode to soar-d, soar-r, or 
macrocycle.")

(defvar soar-pull-closing-paren-up t
  "*Bring the closing paren up to the next to last line. Default is t.")

(defvar soar-command-prefix "\C-c" "*Prefix sequence for Soar commands.")

(defvar soar-menu-prefix "\C-m" "*Prefix for putting up the menu.")

(defvar soar-bugs-to "soar-bugs@cs.cmu.edu" "Who to send bug reports to.")

(defvar soar-diversion-buffer-use-popup t
  "*If t (default), use the popper package to display the diversion buffer.")

;;; Really lives in ilisp/<ilisp-version>/popper.el , but defvar-ed 
;;; here because nobody likes the default (t) behavior.
(defvar popper-buffers-to-skip nil
  "*\\[popper-other-window] will skip over these buffers when they are
used in a temporary window.  If it is T, all popper windows will be
skipped.")


;;;
;;; 	iii.b	Typically not set by users
;;;

;; 16-Nov-92 -noticed copy in soar-variables.
;; (defconst soar-comment-char ";"
;;  "Comment character in soar-mode.")

;; 16-Nov-92 -noticed copy in soar-variables.
;; (defconst soar-mode-version "5.0-new")

;; 16-Nov-92 -noticed copy in soar-variables.
;; (defvar soar-bug-interesting-variables '(window-system
;; 					 window-system-version
;; 					 comint-output-filter
;; 					 soar-version
;; 					 comint-update-status
;; 					 soar-ilisp-subdirectory
;; 					 comint-status
;; 					 soar-print-into-diversion-p
;; 					 soar-mode-hook
;; 					 soar-hook
;; 					 ilisp-filter-length
;; 					 soar-beep-after-setup-p
;; 					 allegro-program
;; 					 ilisp-version
;; 					 soar-date-with-month-name
;; 					 soar-default-drm-arg
;; 					 soar-diversion-buffer-use-popup
;; 					 soar-image-name
;; 					 soar-*site*
;; 					 use-soar-mode-if-available
;; 					 soar-file-types
;; 					 soar-popup-diversion-buffer-p
;; 					 soar-mode-version
;; 					 soar-print-into-diversion-p
;; 					 soar-erase-diversion-buffer-p
;; 					 ilisp-prefix
;; 					 soar-command-prefix
;; 					 soar-mode-load-hook
;; 					 soar-mode-site-hook
;; 					 soar-default-tags-table
;; 					 comint-version
;; 					 comint-prompt-regexp
;; 					 soar-mode-home-directory
;; 					 ilisp-dialects
;; 					 soar-menu-prefix
;; 					 soar-header-hooks
;; 					 soar-after-ilisp-hook
;; 					 taql-ilisp-subdirectory)
;;   "Things soar-bugs wants to see when you mail to them")

;; 16-Nov-92 -FER copied over to soar-variables.
;; ;; used in recompiling soar-mode
;; (defconst *soar-file-list* '("soar-simple-menus.el"
;; 			   "soar-variables.el"
;; 			   "defdialect-soar.el"
;; 	    "ilisp/4.12/soar-ilisp-inits.el"
;; 	    "ilisp/4.12/bridge.el"
;; 	    "ilisp/4.12/symlink.el"
;; 	    "ilisp/4.12/popper.el"
;; 	    "ilisp/4.12/comint.el"
;; 	    "ilisp/4.12/comint-ipc.el"
;; 	    "ilisp/4.12/ilisp-ext.el"
;; 	    "ilisp/4.12/popper.el"
;; 	    "ilisp/4.12/ilisp-bat.el"
;; 	    "ilisp/4.12/ilisp-src.el"
;; 	    "ilisp/4.12/completer.el"
;; 	    "ilisp/4.12/ilisp.el"
;; 	    "utilities/simple-menu.el"
;; 	    "ilisp/4.12/ilisp-simple-menu.el"
;; 	    "soar-outline.el"
;; 	    "ilisp/4.12/soar-ilisp-changes.el"
;; 	    "ilisp/4.12/soar-ilisp-bugs.el"
;; 			   "soar-bridge.el"
;; 			   "soar-cmds.el"
;;                            "soar6.el"
;; 			   "soar-header.el"
;; 			   "soar-indent.el"
;; 			   "soar-mode-defaults.el"
;; 			   "soar-outline.el"
;; 			   "soar-site.el"
;; 			   "soar-tags.el"
;; 			   "soar-mouse-x.el"
;; 			   "soar.el"
;; 			   "tagify.el"
;; 			   "utilities/cl.el"
;; 			   "utilities/comment-region.el"
;; 			   "utilities/goto-manual.el"
;; 			   "utilities/header.el"
;; 			   "utilities/insert-date.el"
;; 			   "utilities/line-num.el"
;; 			   "utilities/new-dabbrevs.el"
;; 			   "utilities/ritter-math.el"
;; 			   "utilities/simple-menu.el"
;; 			   "utilities/soar-ilisp-keymap-changes.el"
;; 			   "utilities/soar-misc.el"
;; 			   "utilities/x-mouse.el")
;;   "All the files that are fit to load and compile")


;;;
;;;	iv.	Buffer-specific variables
;;;

(make-variable-buffer-local 'soar-production-names)


;;;
;;; 	I. 	Load rest of packages
;;;--------------------------------------------------------------------------
;;; User visable function are fset to names without the leading soar-
;;; 
;;; 1. Require important libraries for functions used throughout.
;;; 2. Do a (provide 'soar) at the end; this prevents providing the symbol if
;;;    attempting to load some subpart of this package fails.
;;; 3. Run hook functions at the end of this file.

;; this extends gnu-emacs-lisp so that it looks more like common-lisp
;; we carry a copy in our directory in case some sites don't have it.
(require 'cl)

;; Franz's code
;; (require 'smallfi "allegro-mode-init")

(autoload 'clman "allegro-mode-init" nil t)
(autoload 'clman-apropos "allegro-mode-init" nil t)
(autoload 'clman-mode "allegro-mode-init" nil t)
(autoload 'search-forward-see-alsos "allegro-mode-init" nil t)
(autoload 'clman-flush-doc "allegro-mode-init" nil t)


;; Olin's & Chris's modes
(require 'soar-bridge)           ;probable autoload
;; extensions and clarifications to load before ilisp
(require 'soar-ilisp-inits)
(require 'ilisp)                 ; mesage ccm to autoload ilisp's files

(require 'soar-outline)
(require 'soar-ilisp-changes)
(require 'soar-ilisp-bugs)

;; Simple menus for the user
(require 'soar-simple-menus)

;; (load "soar6" nil t)        ; load by defdialect only
(require 'soar-cmds)        ;no autoload
(require 'soar-indent)      ;no autoload
(require 'soar-misc)        ;no autoload
(require 'defdialect-soar)  ;no autoload

(require 'soar-tags)        ;probable autoload

;; where the manuals live
;(require 'goto-manual)          ;autoload
(autoload 'goto-manual "goto-manual"
	  "Get the manual out.  MANUAL is a file name, mode is the mode to put the
buffer in to start with." t)
(if (not (boundp 'doc-manual-homes))
    (setq doc-manual-homes
          (list (concat soar-mode-home-directory "/manuals/")))
    (setq doc-manual-homes
          (append doc-manual-homes
                  (list (concat soar-mode-home-directory "/manuals/")))))

(if (eq window-system 'x)        ;maybe?
    (load "soar-mouse-x" nil t))

;; This provides a nice header for soar fixes
;; if you wish to use it for other files, use an autoload in your .emacs

; (require 'soar-header)          ;autoload
(autoload 'make-header "soar-header"
	  "Makes a standard file header at the top of the buffer. A header is
   composed of a mode line, a body, and an end line.  The body is
   constructed by calling the functions in make-header-hooks.
   The mode line and end lines start and terminate block comments while the
   body lines just have to continue the comment. " t)
(autoload 'make-revision "soar-header"
	  "Inserts a revision marker after the history line.  Makes the history
   line if it does not already exist." t)
(autoload 'make-divisor "soar-header"
	  "A divisor line is the comment start, filler, and the comment end" t)
(autoload 'make-box-comment "soar-header"
	  "Inserts a box comment that is built using mode specific comment characters." t)
(autoload 'update-file-header "soar-header"
	  "If the file has been modified, searches the first header-max chars in the
   buffer using the regexps in file-header-update-alist. When a match is
   found, it applies the corresponding function with the point located just
   after the match.  The functions can use (match-beginning) and
   (match-end) calls to find out the strings that causes them to be invoked." 
)
(if (not (memq 'update-file-header write-file-hooks))
    (setq write-file-hooks (cons 'update-file-header write-file-hooks)))

(autoload 'display-line-numbers  "line-num" "Display line numbers" t)

(autoload 'insert-time-string "insert-date"
	    "Inserts an Al-like time-stamp after point." t)

(autoload 'insert-current-time-string "insert-date"
	    "Inserts a full time-stamp after point." t)

(autoload 'insert-date-string "insert-date"
	  "Inserts the current date after point, in m-d-y format.  With prefix
argument, inserts the weekday first." t)

;; David Gillespie's enhanced info mode.  Here, you can't do a (require 'info)
;; because original info.el already did a (provide 'info).

;; (load "info")				; Must load; can't (require 'info).
;; (push (concat soar-mode-home-directory "/ilisp/4.12/") Info-directory-list)


;;;
;;;  II.	Changes to other modes
;;;

;;;
;;; 	A.	To Emacs-Lisp mode
;;;

;; nothing currently, keep as placeholder 20-Aug-91 -FER


;;;
;;;	III.	Code to compile soar-mode at a remote-site
;;;

(defun soar-compile-soar-mode ()
 (interactive)
 (mapcar (function (lambda (x) 
           (load-file
             (concat soar-mode-home-directory "/" x))))
         (cdr *soar-file-list*))
 (mapcar (function (lambda (x)
           (if (file-newer-than-file-p
                    (concat soar-mode-home-directory "/" x)
                    (concat soar-mode-home-directory "/" x "c"))
            (byte-compile-file
               (concat soar-mode-home-directory "/" x))
            (message "Not compiling %s, .el not newer than .elc" x))))
          *soar-file-list*)
  (if (eq window-system 'x)
      (byte-compile-file (concat soar-mode-home-directory 
                                 "/" "soar-mouse-x.el")))
  (mapcar (function (lambda (x) 
            (byte-recompile-directory 
              (concat soar-mode-home-directory "/" x)
              t)))
          (list "allegro" "allegro/fi"))
  (make-soar-elc))

;; It's a good idea, but as far as this goes, I must point out that at 
;; least one other package, the VM mail reader from Kyle Jones, 
;; does concatenate the .elc's.  It has a makefile for doing the grunt work:
;; 
;; VM:
;; $(EMACS) -batch -q -l ./vm-message.el -l ./vm-misc.el -f batch-byte-compile .
;;  cat vm-*.elc > vm.elc
;; Hucka, 24-Nov-92


(defun make-soar-elc ()
  ;; (byte-compile-file (concat soar-mode-home-directory "/soar.el"))
  (switch-to-buffer "SOAR.ELC")
  (set-buffer "SOAR.ELC")
  (insert "(let ((gc-cons-threshold (* 6 gc-cons-threshold)))\n"
           "(message \"gc-cons-threshold temporarily increased 3x to %s\"
                    gc-cons-threshold)" "\n")
  (mapcar (function (lambda (x)
		      (insert-file (concat soar-mode-home-directory "/" x))
		      (exchange-point-and-mark)))
           *soar-file-elc-list*)
  (insert ")\n")
  (write-file (concat soar-mode-home-directory "/soar.elc"))
  (kill-buffer "soar.elc"))


;;;
;;;	IV.	Soar-bug (sets up mail message)
;;;
;;; Create way to send bugs in with all variables noted.
;;;

(defun soar-bug ()
 "Generate an soar-mode bug report."
 (interactive)
 (message "Setting up soar-bug...")
 (let ((buffer (current-buffer)))
   (mail)
   (insert soar-bugs-to)
   (search-forward (concat "\n" mail-header-separator "\n"))
   (insert "\nYour problem: \n\n")
   (insert "Type C-c C-c to send\n")
   (insert
    "\n;;;;;;;;;;;;;;;;;;;;;;;;; SOAR STATE INFO ;;;;;;;;;;;;;;;;;;;;;;;\n")
   (forward-line 1)
   (insert (emacs-version))
   (mapcar
    (function (lambda (x)
      (let (insertion-string)
	(save-excursion (set-buffer buffer)
			(if (boundp x)
			    (setq insertion-string (format "\n%s: %s" x (eval x)))))
	(if insertion-string (insert insertion-string)))))
    soar-bug-interesting-variables)
   (insert (format "\nLossage: %s" (key-description (recent-keys))))
   (goto-char (point-min))
   (re-search-forward "^Subject")
   (end-of-line)
   (message "Insert your problem.")))

; Dead code, RIP 2-Jul-92 -TFMcG
;(defun soar-bug ()
; "Generate an soar-mode bug report."
; (interactive)
; (message "Setting up soar-bug...")
; (let ( (ilisp-bugs-to soar-bugs-to) )
;  (if (fboundp 'ilisp-bug)
;      (ilisp-bug)
;      (progn
;         (mail)
;         (insert soar-bugs-to)))
;  (save-excursion  ;ilisp-bug will leave you on subject
;   (soar-bug-header))
;  (message "Insert your problem.")))
;
;(defun soar-bug-header ()
;    (search-forward "Type C-c C-c to send")
;    (forward-line 1)
;    (insert
;       "\n;;;;;;;;;;;;;;;;;;;;;;;;; SOAR STATE INFO ;;;;;;;;;;;;;;;;;;;;;;;")
;    (insert
;      (format "\nWindow System: %s %s" window-system window-system-version))
;   (insert (format "\nsoar-mode version: %s" soar-mode-version))
;   (insert (format "\nsoar-mode-home-directory: %s" soar-mode-home-directory))
;   (insert (format "\nload-path: %s" load-path))
;   (insert (format "\nsoar-mode-load-hook: %s" soar-mode-load-hook))
;   (insert (format "\nsoar-hook: %s" soar-hook))
;   (insert (format "\nGnu version: %s\n" (emacs-version)))
;)


;;;
;;;  N.	   	Run user set hook
;;;-----------------------------------------------------------------------------
;;;

;; soar-hook gets run by Ilisp
(run-hooks 'soar-mode-site-hook)
(run-hooks 'soar-mode-load-hook)

;;-----------------------------------------------------------------------------
;; End of soar.el

;; soar-mode in defdialect-soar.el will put up a nice message about the menu


; TO DO:
;================================================================

;back-trace [I] [G]        Prints a back-trace as though created by chunking. 52
;decide-trace [X]          Toggles the tracing of the decision procedure. 50
;excise P [*]              Removes productions from production memory. 55
;full-matches P [*]        Prints the most complete instantiation of a
;                          production.                                53
;init-context [G] [P] [S] [O]                                         Clears
;                          working memory and then creates an initial context.
;                          48
;init-wm [X] [*]           Calls init-soar and initializes working memory.
;                          48
;learn [A] [*]             Modifies or lists the flags that control chunking.
;                          56
;list-chunks ["filename"]  Prints all chunks, to a file, if specified.
;                          56
;list-justifications ["filename"]                                     Prints all
;                          justifications, to a file, if specified.   56
;load "filename"           Loads a file.                              49
;memories [N]              Prints the productions with the largest token
;                          memories.                                  57
;multi-attributes L        Declares multi-attributes to increase match
;                          efficiency.                                57
;op-apps L                 Declares productions to be operator-application
;                          productions.                               55
;op-apps-undo L            Undoes the effects of op-apps.             55
;pbreak [X] [*]            Sets or lists current break points.        49
;pfired [D]                Prints the number of times each production fired.
;                          54
;pi P [N]                  Prints a current instantiation of a production.
;                          54
;pm P [*]                  Prints productions; conditions are reordered by
;                          matcher.                                   54
;ppwm [X] [*]              Prints augmentations in working memory.    53
;po I                      Prints the augmentations for an identifier.
;                          52
;pop-goal [X]              Removes a goal and all objects supported by it.
;                          55
;preferences O A           Prints the preferences for a given object and
;                          attribute.                                 53
;print-stats               Prints a summary of run statistics.        54
;ptrace [X] [*]            Turns on tracing of items, or lists all items being
;                          traced.                                    50
;run [N] [X]               Runs Soar for a number of cycles or until a specified
;                          break.                                     50
;run-task [N]              Calls init-soar, init-task, and d.         50
;set-break-char X          Resets the break character when text input is on.
;                          56
;set-carriage-control X    Sets carriage-control mode for text input. 56
;set-char-mode X           Sets character mode for text input.        56
;set-input-functions L     Declares the functions to be called in the input
;                          cycle.                                     56
;set-learning-choice       Prompts user for learning mode.            49
;set-macro-character X Y Z R                                          Sets
;                          terminating characters for text input.     56
;set-output-mappings L     Declares the functions to be called in the output
;                          cycle.                                     56
;set-text-input X          Turns text input on or off.                57
;set-text-input-stream X   Redefines the text-input stream.           57
;set-text-output X         Turns text output on or off.               57

;set-text-output-stream X  Redefines the text-output stream.          57
;set-tab-settings N [*]    Redefines the tab settings used for text output.
;                          57
;set-user-select           Prompts user for user-select mode.         49
;smake X                   Adds preferences to preference memory.     55
;smatches P [*]            Prints partial instantiations of productions.
;                          54
;soar-menu "string" L      Provides a menu for the user.              49
;                          otherwise, returns NIL.                    49
;sp X                      Creates new productions.                   55
;spm P [*]                 Prints productions; conditions are not reordered.
;                          54
;spo I [* D]               Prints Soar objects in working memory.     52
;sppwm [X] [*]             Prints objects in working memory.          53
;spr X [*]                 Prints Soar objects or productions.        53
;sremove N [*]             Removes augmentations from working memory. 55
;swm N [*]                 Given time-tags, prints objects in working memory.
;                          53
;tally O A                 Runs a fake decision given object and attribute.
;                          53
;trace-attributes L        Adds attributes of context objects to the tracing of
;                          a run.                                     51
;unpbreak [X] [*]          Removes break points.                      50
;unptrace [X] [*]          Removes tracing set by unptrace.           51
;untrace-attributes L      Removes tracing set by trace-attributes.   51
;user-select [X]           Sets or displays the user-select mode.     49
;watch [N] [T]             Prints trace information about Soar's run. 51
;wm N [*]                  Given time-tags, prints augmentations in working
;                          memory.                                    53
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SILLY as emacs commands
; ;d [N]                     Runs Soar for a number of decision cycles. 49
;
; DONE as emacs commands:
;
;excise-chunks             Removes all productions created by chunking.
;                          56
;excise-task               Removes all non-default productions.       55
;init-soar                 Empties working memory and re-initializes runtime
;                          statistics.                                48
;init-task                 A user-defined Lisp function that initializes the
;                          task.                                      48
;last-chunk                Prints the last production created by chunking.
;                          56
;last-justification        Prints the last justification created.     56
;lispsyntax                Changes the readtable to use standard Lisp
;                          conventions.                               49
;ms                        Prints the instantiations and retractions in the
;                          match set.                                 53
;pgs                       Prints the goal-context stack.             52
;restart-soar              Empties production and working memory and resets all
;                          globals.                                   48
;soarnews                  Prints news about the current release.     5
;soarsyntax                Changes the readtable to use Soar conventions.
;                          49
;soarsyntaxp               Returns T if the Soar readtable is being used;
