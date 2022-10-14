;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : soar-ilisp-keymap-changes.el
;;;; Author          : Frank Ritter
;;;; Created On      : Thu Jan 31 19:03:21 1991
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Nov 13 15:32:50 1991
;;;; Update Count    : 3
;;;; 
;;;; PURPOSE
;;;; 	|>Description of module's purpose<|
;;;; TABLE OF CONTENTS
;;;;	I. 	ilisp-defkey takes an arg
;;;; 
;;;; Copyright 1990, Frank Ritter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;;	I. 	ilisp-defkey takes an arg
;;;
;;; makes prefix an arg that can be passed in
;;;
(defun ilisp-defkey (keymap key command &optional prefix)
  "Define KEYMAP ilisp-prefix+KEY as command."
  (setq prefix (or prefix ilisp-prefix))
  (let ((prefix-map (lookup-key keymap prefix)))
    (if (not (keymapp prefix-map))
	(setq prefix-map (define-key keymap prefix (make-keymap))))
    (define-key prefix-map key command)))

(provide 'soar-ilisp-keymap-changes)
