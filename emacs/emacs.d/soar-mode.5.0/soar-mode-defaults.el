;;;; -*- Mode: Emacs-Lisp -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-mode-defaults.el
;;;; Author          : Frank Ritter
;;;; Created On      : Wed Jun 20
;;;; Last Modified By: Thomas McGinnis
;;;; Last Modified On: Wed Nov 18 15:14:13 1992
;;;; Update Count    : 99
;;;; 
;;;;
;;;;		     How to load GNU Emacs Soar mode
;;;;
;;;; This file contains details on a default set of commands to load and use
;;;; soar mode.  Novice users with vanilla tastes can just always load this, 
;;;; more advanced users will want to cut and paste the commands out of this
;;;; into their .emacs files
;;;;
;;;; To use Soar6, merely set the image name you want to use as
;;;; soar6-image-name, and call the function Soar6 instead of Soar.
;;;;
;;;; Loading this file will cause the following major changes to Emacs to
;;;; take place:
;;;;
;;;; a) The file cl.el will be loaded if was not already loaded.
;;;; b) Many configuration variables will have been set.  These affect
;;;;    the behavior of Soar mode and the code on top of which it is built.
;;;; c) The following packages will be autoloaded when the listed functions
;;;;    are called:
;;;;         Package            Function
;;;;         -------            ---------
;;;;          ILISP             run-ilisp
;;;;          ILISP             allegro
;;;;          soar              soar
;;;;
;;;; d) The following mappings between buffer modes and file name patterns
;;;;    will be established, causing Emacs to put buffers that have these
;;;;    file extensions be put into the specified mode automatically:
;;;;       File name suffix     Mode
;;;;       ----------------     ----
;;;;          .soar             soar
;;;;          .lisp             lisp-mode (ilisp-version)
;;;;
;;;;
;;;; TABLE OF CONTENTS
;;;;	i.	Variables that must be set
;;;; 	ii.	How to set keybindings and hooks
;;;;	iii.	Load associated code
;;;;	iv.	Grungy things you have to do
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; changed auto-mode-alist to ignore .soar-aliases 27-Jul-92 -FER

(require 'cl)				; Loaded often-used CL extensions.
                                        ; we will use things here like pushnew


;;;
;;;	i.	Variables that must be set
;;;
;;; If you insert this into your .emacs, this is a section of active code that 
;;; you can not comment out or remove.

;; This says where soar-mode lives.  Do not end the pathname with '/'.
(setq soar-mode-home-directory
      "/afs/cs/project/soar/5.2/emacs/soar/5.0")
;(setq soar-image-name "/../stego/usr/doorenbs/soar6")
(setq soar-image-name "/afs/cs/project/soar/5.2/2/bin/pmax/mach/franz/Soar5")
(setq soar6-image-name "/afs/cs/project/soar/5.2/emacs/soar/5.0/soar6")


;; Relative pathname off of soar-mode for ilisp-mode
(setq soar-ilisp-subdirectory "ilisp/4.12")

;; tags should include taql code too...
(setq soar-default-tags-table "DEFAULT-TAGS")


;;;
;;;	ii.	Variables that can be set
;;;
;;;  These variables are shown with their default values.  If you want to 
;;;  change their values, copy this file (or portions of this file) to your
;;;  directory or insert it into your .emacs file.

;; The variable `soar-image-name' must contain the name of the Soar
;; executable or be an alias which runs Soar.  It must be something which is
;; in your normal command execution path, or Emacs will not be able to find
;; it.  If you are NOT using the site default (set in `soar.el'), then you
;; must set this variable manually.

;; (setq soar-image-name "Soar5")

;; If t, soar commands print descriptions into soar-diversion-buffer (*glide*) 
;; buffer.  If nil, dumps into *soar* buffer.
;; (setq soar-print-into-diversion-p t)

;; Set `lisp-no-popper' to `t' if you want all Lisp loading output (as opposed
;; to that of Soar productions) to go to the inferior Soar buffer rather than
;; into a pop-up window.  You should probably also set `comint-always-scroll'
;; to `t' as well so that output is always visible.

;; (setq lisp-no-popper nil)  ;default is nil
;; (setq comint-always-scroll nil) ;default is nil

;; Set the following to `t' to print out the month in `insert-date-string' as
;; letters, and in 30-Oct-91 order, rather than as 10-30-91.
;; (setq insert-date-with-month-name nil)  ; default is nil

;; Set to `nil' if you don't want `C-x o' to skip pop-up buffers, such
;; as `*Buffer Menu*' or `*Help*'.  Default is `t'.
;; Can also be set to a list of pop-up buffers you want to skip.

(setq popper-buffers-to-skip nil)

;; Pop to the CMS (continuous match set) buffer if it is being written 
;; to (default `nil').

;; (setq pop-to-cms nil)

;; if this is C-^, it is also C-6 unshifted
;; (setq soar-command-prefix "\C-c")

;; The outline commands are bound on C-c then this prefix char.
;; (setq outline-prefix-char "\C-z")

;; If soar-erase-diversion-buffer-p is t (default), erase the diversion
;; buffer each time you use it.
;; (setq soar-erase-diversion-buffer-p t)

;; Name of the diversion buffer.
;; (setq soar-diversion-buffer-name "*glide*")

;; Popup the diversion buffer if t (the default) something gets put in there.
;; (setq soar-popup-diversion-buffer-p t)

;; soar-header-hooks contains a list of what to put on the header when
;; make-header is called.  The default is shown below.
;;
;; (setq soar-header-hooks 
;;       '(;; a top line with mode  comes for free
;;         ;; a divisor line        comes for free
;;         header-blank
;;         header-file-name
;;         header-author
;;         header-creation-date
;;         header-modification-author
;;         header-modification-date
;;         header-update-count
;;         soar-version
;;         taql-version
;;         ;;Put PURPOSE and TOC near top
;;         header-blank
;;         header-purpose
;;         header-toc
;;         header-copyright
;;         ;;Generally want either RCS stuff or header-history
;;         ;;at CMU and elsewhere, fewer users and fewer non-hacky use RCS,
;;         header-divisor-line
;;         header-status
;;         header-history
;;         ;;header-rcs-locker
;;         ;;;;header-rcs-header
;;         ;;header-rcs-log
;;         ;; divisor line        comes for free
;;         ))

;; Soar will beep when initialized if t.
;; (setq soar-beep-after-setup-p t)


;;;
;;; 	ii.	How to set keybindings and hooks
;;;
;;; If you wish to change the keybindings or add to them for buffers in
;;; soar-mode, put the changes on the `soar-hook' in your .emacs file
;;; with code comparable to the code below.  Similar code could be put on
;;; the `inferior-soar-mode-hook' for buffers running Soar.
;;;
;;; Here is an example of a soar-hook function which defines `C-c C-t'
;;; to run function `favorite-cmd' in both Soar mode buffers and Soar process
;;; buffers; and redefines a mouse button.
;;; Further information on how to reset the mouse keys are available in the
;;; soar-mouse-x.el file.
;;;

;; Example set up for stuff to do when putting a buffer into soar-mode
;(setq soar-mode-hook
;     '((lambda ()
;         (visit-tags-table soar-default-tags-table)
;         ;; works for code buffers
;         (define-key soar-mode-map "\C-z" 'favorite-cmd2)
;         ;; this command rebinds the control middle mouse to what it was 
;         ;; originally.  
;         (define-key mouse-map x-button-c-middle-up 'x-cut-and-wipe-text)
;        )))

;;; works for running Soar buffers
;(setq soar-mode-hook
;     '((lambda ()
;         (visit-tags-table soar-default-tags-table)
;         (define-key isoar-mode-map "\C-z" 'favorite-cmd)
;         ;; this command rebinds the control middle mouse to what it was 
;         ;; originally.  
;         (define-key mouse-map x-button-c-middle-up 'x-cut-and-wipe-text)
;        )))


;;; Example of how to set soar-hook, and what you can put on it, which gets
;;; gets called when an inferior (running) Soar starts up.
;;;

;(if (not (boundp 'soar-hook)) (setq soar-hook nil))
;;; soar-hook gets called after ilisp inits, but before soar gets called
;(setq soar-hook
;   (append soar-hook
;      '((lambda () 
;         ;; use C-6 instead of C-c as command prefix
;         (setq soar-command-prefix "\C-6")
;         ;; start by visiting a tags table
;         (visit-tags-table "/afs/cs/project/soar/5.2/2/lib/TAGS")
;         ;; ask which soar I want iff don't have a live one
;         (if (and (not (comint-check-proc "*soar*"))
;                (y-or-n-p
;                 "Use (perhaps) local copy of Soar5+sx(y) or Soar5 (n)? "))
;             (setq ilisp-program 
;                   "/afs/cs/project/soar/5.2/src/sx/new/Soar5+sx.acli"))
;
;        ;; or just always use a single version
;        (setq ilisp-program
;           "/afs/cs.cmu.edu/project/soar/5.2/2/bin/pmax/mach/franz/Soar5")))
;           ;; set my header notice
;        (setq header-copyright-notice "Copyright 1991, Frank Ritter.")
;     ))))


;;;
;;;	iii.	Load associated code
;;;
;;; `utilities/taql-indent-line.el' provides code to indent TC's correctly
;;; when using soar- or taql-mode (but is not automatically loaded by
;;; soar-mode).
;;; 
;;; (e.g., Set up ilisp so you can find it w/o soar-mode.)
;;; We believe that if you don't use ilisp alone, that you could comment or
;;; cut this out to save space. (But I wouldn't do that if I were you.)
;;;

;; Establish path to the home directory of Soar mode and ILISP mode.
;; The latter is set here so that you can use ILISP mode independently
;; of Soar mode:

(pushnew soar-mode-home-directory load-path)
(pushnew (concat soar-mode-home-directory "/" soar-ilisp-subdirectory)
         load-path)

;; To load `utilities/taql-indent-line' iff it has not been loaded.
;; Cut this into your soar-mode-hook, if you wish.
;; (require 'taql-indent-line)

;; Some handy things for working on just lisp that you are carrying around
;; too, let's not let them go to waste:

(autoload 'run-ilisp "ilisp" "Select a new inferior LISP." t)
(autoload 'allegro   "ilisp" "Inferior Allegro Common LISP." t)

;; Additional useful functions.

(autoload 'comint-mem "comint"
  "Test to see if ITEM is equal to an item in LIST.
Option comparison function ELT= defaults to equal." t)

(autoload 'add-hook "comint-ipc"
	  "Add a function to a hook if not already present." t)

(autoload 'soar-manual "utilities/soar-manual"
	  "Read an online manual, such as for Soar or soar-mode." t)

(autoload 'clman "allegro/allegro-mode-init"
	  "Read about a specific topic in the online CL manual." t)

(autoload 'clman-apropos "allegro/allegro-mode-init"
	  "List topics matching a subexpression in the online CL manual." t)

;; set the ilisp-command-prefix in case you are headed into ilisp first
(setq ilisp-prefix "\C-c")

;;; Emacs would normally put .lisp files in it's default simple lisp-mode.
;;; This makes reading a lisp file load in ilisp.
(add-hook 'lisp-mode-hook
	  (function
	   (lambda ()
	    (require 'ilisp))))

;;;
;;;	iv.	Grungy things you have to do
;;;
;;; This is live code that you have to have, but that you don't have to
;;; understand if you leave it alone.
;;;

;; Put files that end in .soar into soar-mode
;; remove comment to do it for .Soar files too

(defvar soar-file-types
   '("\\.soar$"
     ;; "\\.Soar$"
     "\\.soar5$"
     "\\.soar6$"))

(dolist (suffix soar-file-types)
  (if (not (assoc suffix auto-mode-alist))
      (push (cons suffix 'soar-mode) auto-mode-alist)))

;;; make calling  {run-soar, soar, soar-mode} load the mode code.
(mapcar 
 (function (lambda (x) (autoload (car x) "soar" (car (cdr x)) t)))
 '((run-soar  "Starting up an inferior (buffer) soar process.")
   (soar  "Another way to start up an inferior (buffer) soar process.")
   (soar6  "Another way to start up an inferior (buffer) soar process.")
   (soar-mode "When editing a file of Soar productions or lisp code.")
   ))

(defun Soar ()
  (interactive)
  (soar))

;;;; This should be covered by the new  use-soar-mode-if-available  variable.
;;; If taql-mode is around, put .taql files into soar-mode as the major
;;; mode when they start up, with taql-mode behind
;;; This works if soar-mode is loaded second.
;(if (assoc "\\.taql" auto-mode-alist)
;    (set-default 'auto-mode-alist
;             (append
;                (mapcar '(lambda (x)
;                           (cons x 'soar-and-taql-mode))
;                         '("\\.taql$"))
;                auto-mode-alist)
;    ))
