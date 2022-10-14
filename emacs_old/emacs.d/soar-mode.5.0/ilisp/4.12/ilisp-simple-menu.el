;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : ilisp-simple-menu.el
;;;; Author          : Frank Ritter
;;;; Created On      : Fri Jun 28 17:45:12 1991
;;;; Last Modified By: Thomas McGinnis
;;;; Last Modified On: Thu Jul 18 14:22:18 1991
;;;; Update Count    : 13
;;;; 
;;;; PURPOSE
;;;; 	simple menu for ilisp and lisp-mode-maps
;;;; TABLE OF CONTENTS
;;;; 	|>Contents of this module<|
;;;; 
;;;; Copyright 1991, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'simple-menu)




;; ccm: Calling where-is-internal is very slow.  Rather than doing it every
;; time, you might want to do it once when the menu is defined.
;; fer: should call it each time, aren't guarenteed keymap will be the same,
;; e.g., soar-mode call ilisp-command-menu, in which case keybindings are diffeent
;; shouldn't even do it in help.

;; ccm: There seems to be no way to clear a menu short of knowing how you put
;; it internally onto symbols.  Personally I'd prefer def-menu to
;; completely replace any existing menu and have sm-add-to-menu for
;; adding commands.
;; fer: not clear to me, what if menu may not exist yet, check if menu, and then
;; add or create? maybe.

;;;
;;;	I.	run-ilisp-menu
;;;

(defun run-ilisp-menu ()
  "Provide a menu of commands for ilisp- and lisp-modes."
  (interactive)
  (run-menu 'ilisp-command-menu))


;;;
;;;	II.	The menus
;;;

(def-menu 'ilisp-command-menu
  "Lisp"
  "These Ilisp commands are available on the menu:" ;help prompt
 '(
   ("Break        Interupt the current lisp."  
                 (progn (switch-to-lisp t t)
                        (interrupt-subjob-ilisp)))
   ("Doc          Menu of commands to get help on variables, etc."
                  documentation-lisp-command-menu)
   ("Xpand        Macroexpand s-expression beginning at point."
                    macroexpand-lisp)
   ("Eval         Eval the surrounding defun." eval-defun-lisp)
   ("1E&G         Eval defun and goto Soar." eval-defun-and-go-lisp)
   ("Rglist       Get the arglist of surrounding funcall."
                    arglist-lisp)
   (";            Comment the region."   comment-region-lisp)
   (")            find-unbalanced-lisp parens." find-unbalanced-lisp)
   ("]            close-all-lisp parens that are open." close-all-lisp)
   ("Trace        Traces the previous function symol." trace-defun-lisp)
   )
)

(def-menu 'documentation-lisp-command-menu
  "Lisp help"
  "These commands are available for examining Lisp structures:" ;help prompt
 '(
   ("Apro         Apropos on Common Lisp manual." fi:clman-apropos)
   ("CLtL         Check Common Lisp manual." fi:clman)
   ("LDoc         Get Lisp documentation string." documentation-lisp)
   ("Descr        Describe the current sexp." describe-lisp)
   ("Insp         Inspect the current sexp." inspect-lisp)
   ("QInsp        Queries for something to inspect." 
                  (let ((current-prefix-arg -4))
                    (call-interactively 'inspect-lisp)))
   ("PDescr       Prompts for something to describe." 
                  (let ((current-prefix-arg -4))
                    (call-interactively 'describe-lisp)))
   ("Rglist       Get the arglist for function." arglist-lisp)
   )
)


;;;
;;;	V.	rebind some keys in ilisp-mode-map
;;;

(ilisp-defkey ilisp-mode-map "\C-m" 'run-ilisp-menu)
(ilisp-defkey lisp-mode-map "\C-m" 'run-ilisp-menu)

(provide 'ilisp-simple-menu)
