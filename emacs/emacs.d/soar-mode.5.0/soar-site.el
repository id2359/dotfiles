;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-site.el
;;;; Author          : Frank Ritter
;;;; Created On      : Fri Jul 6, 1990
;;;; Last Modified By: Thomas McGinnis
;;;; Last Modified On: Wed Nov 18 15:16:15 1992
;;;; Update Count    : 61
;;;; 
;;;; PURPOSE
;;;; 	Site initialization file for the CMU Soar group
;;;; 
;;;; HISTORY
;;;;   started at mich, copied and redited for v3.
;;;; TABLE OF CONTENTS
;;;;
;;;;	I.	General global site variables
;;;;	II.	Set up for comment-region.el
;;;;	III.	Set up where manuals are 
;;;;
;;;; Copyright 1990, Frank Ritter.
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'soar-site)


;;; 	I.	CRITICAL, site dependent, GLOBAL path VARIABLES 
;;;                 -- DON'T FORGET TO SET THESE!
;;;-----------------------------------------------------------------------------
;;; NB: Direcories do not get ending "/"
;;;

(defvar soar-mode-home-directory
  (expand-file-name "/afs/cs/project/soar/5.2/emacs/soar/5.0")
  "Explicit pathname to the directory containing this and other files of the
Soar Emacs mode.")

;; Note: no leading / in this case either
(defvar soar-ilisp-subdirectory "ilisp/4.12"
  "Subdirectory to soar-mode-home-directory that ilisp lives in.")

(defvar soar-image-name
  "Soar5"
  "*Default Soar image to invoke from `run-soar'.  If the value is a string
then it names the image file or image path that `run-soar' invokes.
Otherwise, if the value of this variable is a list rather than a string, the
value is given to funcall, the result of which should yield a string which is
the image name or path.")


;;;
;;;    II.  	General global site variables
;;;

(setq soar-*site* 'cmu)

(setq-default header-copyright-notice "Copyright 1992, Carnegie Mellon University.")


;;; 
;;; III.      Set up for comment-region.el
;;;
; ilisp does this for us now...
;
;(setq comment-region-alist
;      (cons (cons 'soar-mode 'lisp-mode-comment-region) 
;            comment-region-alist))
;
;(setq uncomment-region-alist
;      (cons (cons 'soar-mode 'lisp-mode-uncomment-region) 
;            uncomment-region-alist))



;;;--------------------------------------------------------------------------
;;;  IV.      Set up manuals and soar-mode-site-hook
;;;--------------------------------------------------------------------------

;;; The first shall be last...   Each file is copied into version/manuals so 
;;; they get tar'ed up.  Later we could use links or direct references to
;;; save space.

;; we allow that some sites may keep their own manuals in different places due 
;; to disk space problems
(setq man-manual-home (concat soar-mode-home-directory "/manuals/"))

;; These are too large to ship, change the paths locally to your own paths.
;; These are put on this hook so they can be defered until after the menu
;; has been created.

(add-hook 'soar-mode-site-hook
     (function (lambda ()
 (add-to-menu  'soar-document-menu  '(
   ("8-bib        Soar bibliography.     "
     (goto-manual "/afs/cs/project/soar/member/biblio/soar.bib"
                  'scribe-mode))
   ("9-Intro      Intro to CMU site      "
     (goto-manual 
          "/afs/cs.cmu.edu/project/soar/5.2/emacs/soar/5.0/manuals/cmu-intro.txt"
            'text-mode))
   ("Dbase        Database of Soar community members."
     (goto-manual 
            "/afs/cs/project/soar/5.2/emacs/soar/5.0/manuals/database.txt"
            'text-mode))
  ))
(add-to-menu  'soar-document-menu5  '(
   ("5-deflt      default productions.   "
    (goto-manual "/afs/cs.cmu.edu/project/soar/5.2/2/lib/default/default.soar"
                 'soar-mode))
   ("7-src        Soar5 source.   "
     (goto-manual "/usr/misc/.Soar5/lib/Soar5.lisp"
                  'lisp-mode))
   ("Sim          Soar-Sim documentation.      "
     (goto-manual 
            "/afs/cs.cmu.edu/project/soar/5.2/2/lib/soarsim/doc/manual.tex"
            'text-mode))
  ))
(add-to-menu  'soar-document-menu6  '(
   ("6-deflt      default productions.   "
    (goto-manual 
     "/afs/cs.cmu.edu/project/soar/member/soar6/gamma/default/default.soar6"
                 'soar-mode))
   ("7-src        Soar6 source.   "
     (goto-manual 
        "/afs/cs.cmu.edu/project/soar/member/soar6/gamma/src/soar.h"
                  'lisp-mode))
  ))

)))








