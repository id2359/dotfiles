;;; -*-Emacs-Lisp-*- General command interpreter in a window stuff
;;; Copyright Olin Shivers (1988).
;;; Please imagine a long, tedious, legalistic 5-page gnu-style copyright
;;; notice appearing here to the effect that you may use this code any
;;; way you like, as long as you don't charge money for it, remove this
;;; notice, or hold me liable for its results.

;;; The changelog is at the end of this file.

;;; Please send me bug reports, bug fixes, and extensions, so that I can
;;; merge them into the master source.
;;;     - Olin Shivers (shivers@cs.cmu.edu)

;;; This hopefully generalises shell mode, lisp mode, tea mode, soar mode,...
;;; This file defines a general command-interpreter-in-a-buffer package
;;; (comint mode). The idea is that you can build specific process-in-a-buffer
;;; modes on top of comint mode -- e.g., lisp, shell, scheme, T, soar, ....
;;; This way, all these specific packages share a common base functionality, 
;;; and a common set of bindings, which makes them easier to use (and
;;; saves code, implementation time, etc., etc.).

;;; Several packages are already defined using comint mode:
;;; - cmushell.el defines a shell-in-a-buffer mode.
;;; - cmulisp.el defines a simple lisp-in-a-buffer mode.
;;; Cmushell and cmulisp mode are similar to, and intended to replace,
;;; their counterparts in the standard gnu emacs release (in shell.el). 
;;; These replacements are more featureful, robust, and uniform than the 
;;; released versions. The key bindings in lisp mode are also more compatible
;;; with the bindings of Hemlock and Zwei (the Lisp Machine emacs).
;;;
;;; - The file cmuscheme.el defines a scheme-in-a-buffer mode.
;;; - The file tea.el tunes scheme and inferior-scheme modes for T.
;;; - The file soar.el tunes lisp and inferior-lisp modes for Soar.
;;; - cmutex.el defines tex and latex modes that invoke tex, latex, bibtex,
;;;   previewers, and printers from within emacs.
;;; - background.el allows csh-like job control inside emacs.
;;; It is pretty easy to make new derived modes for other processes.

;;; For documentation on the functionality provided by comint mode, and
;;; the hooks available for customising it, see the comments below.
;;; For further information on the standard derived modes (shell, 
;;; inferior-lisp, inferior-scheme, ...), see the relevant source files.

;;; For hints on converting existing process modes (e.g., tex-mode,
;;; background, dbx, gdb, kermit, prolog, telnet) to use comint-mode
;;; instead of shell-mode, see the notes at the end of this file.

(defun provide-comint (x y)
  (+ x y)
  (eval '(provide (quote comint))))

(defconst test-comint-version "2.02")

(provide-comint 1 2)

(provide (quote comint))

(provide 'comint)

(defconst comint-version "2.02")




;;; Brief Command Documentation:
;;;============================================================================
;;; Comint Mode Commands: (common to all derived modes, like cmushell & cmulisp
;;; mode)
;;;
;;; m-p	    comint-previous-input    	    Cycle backwards in input history
;;; m-n	    comint-next-input  	    	    Cycle forwards
;;; m-s     comint-previous-similar-input   Previous similar input
;;; c-c r   comint-previous-input-matching  Search backwards in input history
;;; return  comint-send-input
;;; c-a     comint-bol                      Beginning of line; skip prompt.
;;; c-d	    comint-delchar-or-maybe-eof     Delete char unless at end of buff.
;;; c-c c-u comint-kill-input	    	    ^u
;;; c-c c-w backward-kill-word    	    ^w
;;; c-c c-c comint-interrupt-subjob 	    ^c
;;; c-c c-z comint-stop-subjob	    	    ^z
;;; c-c c-\ comint-quit-subjob	    	    ^\
;;; c-c c-o comint-kill-output		    Delete last batch of process output
;;; c-c c-r comint-show-output		    Show last batch of process output
;;;
;;; Not bound by default in comint-mode
;;; send-invisible			Read a line w/o echo, and send to proc
;;; (These are bound in shell-mode)
;;; comint-dynamic-complete		Complete filename at point.
;;; comint-dynamic-list-completions	List completions in help buffer.
;;; comint-replace-by-expanded-filename	Expand and complete filename at point;
;;;					replace with expanded/completed name.
;;; comint-kill-subjob			No mercy.
;;; comint-continue-subjob		Send CONT signal to buffer's process
;;;					group. Useful if you accidentally
;;;					suspend your process (with C-c C-z).
;;;
;;; Bound for RMS -- I prefer the input history stuff, but you might like 'em.
;;; m-P	   comint-msearch-input		Search backwards for prompt
;;; m-N    comint-psearch-input		Search forwards for prompt
;;; C-cR   comint-msearch-input-matching Search backwards for prompt & string

;;; comint-mode-hook is the comint mode hook. Basically for your keybindings.
;;; comint-load-hook is run after loading in this package.


;;; Buffer Local Variables:
;;;============================================================================
;;; Comint mode buffer local variables:
;;;     comint-prompt-regexp    - string       comint-bol uses to match prompt.
;;;     comint-last-input-end   - marker       For comint-kill-output command
;;;     input-ring-size         - integer      For the input history
;;;     input-ring              - ring             mechanism
;;;     input-ring-index        - marker           ...
;;;     comint-last-input-match - string           ...
;;;     comint-get-old-input    - function     Hooks for specific 
;;;     comint-input-sentinel   - function         process-in-a-buffer
;;;     comint-input-filter     - function         modes.
;;;     comint-input-send	- function
;;;     comint-eol-on-send	- boolean

(defvar comint-prompt-regexp "^"
  "Regexp to recognise prompts in the inferior process.
Defaults to \"^\", the null string at BOL.

Good choices:
  Canonical Lisp: \"^[^> ]*>+:? *\" (Lucid, franz, kcl, T, cscheme, oaklisp)
  Lucid Common Lisp: \"^\\(>\\|\\(->\\)+\\) *\"
  franz: \"^\\(->\\|<[0-9]*>:\\) *\"
  kcl: \"^>+ *\"
  shell: \"^[^#$%>]*[#$%>] *\"
  T: \"^>+ *\"

This is a good thing to set in mode hooks.")

(defvar input-ring-size 30
  "Size of input history ring.")

;;; Here are the per-interpreter hooks.
(defvar comint-get-old-input (function comint-get-old-input-default)
  "Function that submits old text in comint mode.
This function is called when return is typed while the point is in old text.
It returns the text to be submitted as process input.  The default is
comint-get-old-input-default, which grabs the current line, and strips off
leading text matching comint-prompt-regexp")

(defvar comint-input-sentinel (function ignore)
  "Called on each input submitted to comint mode process by comint-send-input.
Thus it can, for instance, track cd/pushd/popd commands issued to the csh.")

(defvar comint-input-filter
  (function (lambda (str) (not (string-match "\\`\\s *\\'" str))))
  "Predicate for filtering additions to input history.
Only inputs answering true to this function are saved on the input
history list. Default is to save anything that isn't all whitespace")

(defvar comint-input-sender (function comint-simple-send)
  "Function to actually send to PROCESS the STRING submitted by user.
Usually this is just 'comint-simple-send, but if your mode needs to 
massage the input string, this is your hook. This is called from
the user command comint-send-input. comint-simple-send just sends
the string plus a newline.")

(defvar comint-eol-on-send 'T
  "If non-nil, then jump to the end of the line before sending input to process.
See COMINT-SEND-INPUT")

(defvar comint-mode-hook '()
  "Called upon entry into comint-mode
This is run before the process is cranked up.")

(defvar comint-exec-hook '()
  "Called each time a process is exec'd by comint-exec.
This is called after the process is cranked up.  It is useful for things that
must be done each time a process is executed in a comint-mode buffer (e.g.,
(process-kill-without-query)). In contrast, the comint-mode-hook is only
executed once when the buffer is created.")

(defvar comint-mode-map nil)


