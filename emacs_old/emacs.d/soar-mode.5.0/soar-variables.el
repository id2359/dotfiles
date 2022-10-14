;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-variables.el
;;;; Author          : Thomas McGinnis
;;;; Created On      : Wed Oct 21 22:57:36 1992
;;;; Last Modified By: Thomas McGinnis
;;;; Last Modified On: Thu Dec 10 14:57:20 1992
;;;; Update Count    : 12
;;;; 
;;;; PURPOSE
;;;; 	To place all defvar's and the like at the beginning of a (load)
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Status          : Unknown, Use with caution!
;;;; HISTORY
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'soar-variables)


;;;
;;;	I.	Set up the site dependent load paths and such
;;;
;;;
;;; This sets up site specific items such as path to this file.
;;; This load requires that soar-mode-defaults.el or its equivalent be loaded 
;;; first.  Once loaded, we can set up our relative loadpath, and dig in.

;; presumably only a few will use this....
;; actively used by soar-site.el
(defvar soar-mode-site-hook nil
 "Hook that gets run  to set up site stuff that depends on soar-mode being
 loaded (such as manual menus).")

(pushnew soar-mode-home-directory load-path)
(pushnew (concat soar-mode-home-directory "/utilities") load-path)
(pushnew (concat soar-mode-home-directory "/" soar-ilisp-subdirectory) load-path)
(pushnew (concat soar-mode-home-directory "/allegro") load-path)


;;;
;;; 	iii.a	Typically set by users 
;;; who should set them with setq in their .emacs file.
;;;

(defvar soar-version "5.2.2"
  "*Version of the Soar program run to put into headers, etc.")

;; Replaced by soar-hook.
;; (defvar soar-mode-hook nil
;;  "*Hook run after invoking soar-mode, for customising the editing
;; environment.")

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

(defconst soar-comment-char ";"
  "Comment character in soar-mode.")

(defconst soar-mode-version "5.0")

(defvar soar-bug-interesting-variables '(window-system
					 window-system-version
					 comint-output-filter
					 soar-version
					 comint-update-status
					 soar-ilisp-subdirectory
					 comint-status
					 soar-print-into-diversion-p
					 soar-mode-hook
					 soar-hook
					 ilisp-filter-length
					 soar-beep-after-setup-p
					 allegro-program
					 ilisp-version
					 soar-date-with-month-name
					 soar-default-drm-arg
					 soar-diversion-buffer-use-popup
					 soar-image-name
					 soar-*site*
					 use-soar-mode-if-available
					 soar-file-types
					 soar-popup-diversion-buffer-p
					 soar-mode-version
					 soar-print-into-diversion-p
					 soar-erase-diversion-buffer-p
					 ilisp-prefix
					 soar-command-prefix
					 soar-mode-load-hook
					 soar-mode-site-hook
					 soar-default-tags-table
					 comint-version
					 comint-prompt-regexp
					 soar-mode-home-directory
					 ilisp-dialects
					 soar-menu-prefix
					 soar-header-hooks
					 soar-after-ilisp-hook
					 taql-ilisp-subdirectory)
  "Things soar-bugs wants to see when you mail to them")

;; 16-Nov-92 -FER replaced with what was in soar.el, below.
;; used in recompiling soar-mode
;; (defconst *soar-file-list* '("soar-simple-menus.el"
;; 			   "soar-variables.el"
;; 			   "defdialect-soar.el"
;; 			   "soar-bridge.el"
;; 			   "soar-cmds.el"
;;                            "soar6.el"
;; 			   "soar-header.el"
;; 			   "soar-indent.el"
;; 			   "soar-mode-defaults.el"
;; 			   "soar-site.el"
;; 			   "soar-tags.el"
;; 			   "soar-mouse-x.el"
;; 			   "soar-variables.el"
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

(defconst *soar-file-list* '( 
			   "utilities/cl.el"
			   "utilities/comment-region.el"
			   "utilities/goto-manual.el"
			   "utilities/header.el"
			   "utilities/insert-date.el"
			   "utilities/line-num.el"
			   "utilities/new-dabbrevs.el"
			   "utilities/ritter-math.el"
			   "utilities/simple-menu.el"
           "soar-simple-menus.el"
	   "soar-site.el"
	   "soar-variables.el"
	    "ilisp/4.12/soar-ilisp-inits.el"
	    "ilisp/4.12/bridge.el"
	    "ilisp/4.12/symlink.el"
	    "ilisp/4.12/popper.el"
	    "ilisp/4.12/comint.el"
	    "ilisp/4.12/comint-ipc.el"
	    "ilisp/4.12/ilisp-ext.el"
	    "ilisp/4.12/ilisp-bat.el"
	    "ilisp/4.12/ilisp-src.el"
	    "ilisp/4.12/completer.el"
	    "ilisp/4.12/ilisp.el"
	    "ilisp/4.12/ilisp-simple-menu.el"
	    "soar-outline.el"
	    "ilisp/4.12/soar-ilisp-changes.el"
	    "ilisp/4.12/soar-ilisp-bugs.el"
  	   "defdialect-soar.el"
			   "soar-bridge.el"
			   "soar-cmds.el"
                           "soar6.el"
			   "soar-header.el"
			   "soar-indent.el"
			   "soar-mode-defaults.el"
			   "soar-outline.el"
			   "soar-tags.el"
			   "soar-mouse-x.el"
			   "soar.el"
			   "tagify.el"
			   "utilities/soar-ilisp-keymap-changes.el"
			   "utilities/soar-misc.el"
			   "utilities/x-mouse.el")
  "All the files that are fit to load and compile")

(defconst *soar-file-elc-list* '( 
			   "utilities/cl.elc"
			   "utilities/comment-region.elc"
			   "utilities/goto-manual.elc"
			   "utilities/header.elc"
			   "utilities/insert-date.elc"
			   "utilities/line-num.elc"
			   "utilities/new-dabbrevs.elc"
			   "utilities/ritter-math.elc"
			   "utilities/simple-menu.elc"
           "soar-simple-menus.elc"
	   "soar-site.elc"
	   "soar-variables.elc"
	    "ilisp/4.12/soar-ilisp-inits.elc"
	    "ilisp/4.12/bridge.elc"
	    "ilisp/4.12/symlink.elc"
	    "ilisp/4.12/popper.elc"
	    "ilisp/4.12/comint.elc"
	    "ilisp/4.12/comint-ipc.elc"
	    "ilisp/4.12/ilisp-ext.elc"
	    "ilisp/4.12/ilisp-bat.elc"
	    "ilisp/4.12/ilisp-src.elc"
	    "ilisp/4.12/completer.elc"
	    "ilisp/4.12/ilisp.elc"
	    "ilisp/4.12/ilisp-simple-menu.elc"
	    "soar-outline.elc"
	    "ilisp/4.12/soar-ilisp-changes.elc"
	    "ilisp/4.12/soar-ilisp-bugs.elc"
  	   "defdialect-soar.elc"
			   "soar-bridge.elc"
			   "soar-cmds.elc"
                           "soar6.elc"
			   "soar-header.elc"
			   "soar-indent.elc"
			   "soar-outline.elc"
			   "soar-tags.elc"
			   "soar.elc"
			   "tagify.elc"
			   "utilities/soar-ilisp-keymap-changes.elc"
			   "utilities/soar-misc.elc"
			   ;; "utilities/x-mouse.el"
                           )
  "All the files that are fit to put into the big .elc")

;; old version, 21-Nov-92 -fer
;	  '("soar-variables.elc"
;	    "soar-site.elc"
;	    "ilisp/4.12/bridge.elc"
;	    "soar-bridge.elc"
;	    "ilisp/4.12/soar-ilisp-inits.elc"
;	    "ilisp/4.12/popper.elc"
;	    "ilisp/4.12/symlink.elc"
;	    "ilisp/4.12/comint.elc"
;	    "ilisp/4.12/comint-ipc.elc"
;	    "ilisp/4.12/ilisp-ext.elc"
;	    "ilisp/4.12/ilisp.elc"
;	    "utilities/simple-menu.elc"
;	    "ilisp/4.12/ilisp-simple-menu.elc"
;	    "soar-outline.elc"
;	    "ilisp/4.12/soar-ilisp-changes.elc"
;	    "ilisp/4.12/soar-ilisp-bugs.elc"
;	    "soar-simple-menus.elc"
;	    "soar-cmds.elc"
;	    "soar-indent.elc"
;	    "utilities/soar-misc.elc"
;	    "defdialect-soar.elc"
;	    "soar-tags.elc"
;	    "soar.elc")
