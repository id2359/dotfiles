;;;; -*- Mode: Emacs-Lisp -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            :soar-cmds.el
;;;; Author          : Frank Ritter, Michael Hucka
;;;; Created On      : Sun Dec  3 17:04:10 1989
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Nov 11 21:45:13 1992
;;;; Update Count    : 276
;;;; 
;;;; PURPOSE
;;;; 	Main commands for Soar mode.
;;;; CONTENTS
;;;; 	i.	Global variables reset by this file: soar-cmds.el
;;;;	I.	Basic interactive functions
;;;;	II.	Counting and listing soar productions
;;;;	III.	Argumentless DSI Commands
;;;;	IV.	Argumentless Soar Commands
;;;;	V.	Extracting elements from buffer text
;;;;	VI.	Soar production editing
;;;; 	VII.	General utility functions
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; NOTES:
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; add toggle-soar-syntax
; add to soar mode
; 5.1.6. verbose [:on | :off]
;  Verbose enables and disables run-time monitoring.  Initially,  monitoring  is
;enabled.    With  no  argument,  verbose  returns  the current enabled/disabled
;status.
; e.g.    (verbose :off)
(provide 'soar-cmds)


;;;
;;; 	i.	Requires and global variables reset by this file:
;;;

(require 'cl)

(defvar soar-diversion-buffer-name "*glide*")

(fset 'soar-send 'ilisp-send)


;;;
;;;	I.	 Basic interactive functions
;;;------------------------------------------------------------------------

;;(defun soar-show-preferences (&optional name)
;;  (interactive)
;;  (let ((string (format "(preferences %s 3)"     
;;                        (or name (soar-symbol-under-cursor))))
;;        (lisp-no-popper t))
;;    (soar-do-in-diversion-buffer string)))

(defun soar-spr-production (&optional name)
  "Run SPR on the production under the cursor.  If optional arg NAME is
supplied, use that as the name of the production instead."
  (interactive)
  ;; changed do-prompt to nil so that we dont query on getting a thing to print
  (soar-do-to-production
    (or name (soar-symbol-under-cursor nil "SPR production named" nil))
              ;soar-extract-production-name
    "spr"
    t))

(defun soar-excise-production (&optional name)
  "Excise the production under the cursor.  If optional arg NAME is
supplied, use that as the name of the production instead."
  (interactive)
  (soar-do-to-production
    (or name (soar-extract-production-name t "Excise production named" t))
             ;soar-symbol-under-cursor
    "excise"))

(defun soar-load-production ()
  "Load the production under the cursor."
  (interactive)
  (save-window-excursion
  (save-excursion
  (let ((string (buffer-substring (progn (beginning-of-defun-lisp) 
                                         (point))
                                  (progn (forward-sexp) (point))))
        (lisp-no-popper t))
   (ilisp-send string nil ':sending t)))))

(defun soar-full-matches-production (&optional name)
  "Run full-matches on the production under the cursor.  If optional arg NAME is
supplied, use that as the name of the production instead."
  (interactive)
  (soar-do-to-production
    (concat (or name (soar-extract-production-name t "Do full-matches on" t))
                      ;soar-symbol-under-cursor
            " 1")
    "matches"
    t))

(defun soar-really-full-matches-production (&optional name)
  "Run full-matches on the production under the cursor.  If optional arg NAME is
supplied, use that as the name of the production instead."
  (interactive)
  (soar-do-to-production
    (concat (or name (soar-extract-production-name t "Do full-matches on" t))
                      ;soar-symbol-under-cursor
            " 2")
    "matches"
    t))


;;;; #118) (2) Erik/Wed, 15 Jul 92
;;;;   ==8: Faster soar gensym printing

;; 6-16-92 - ema - new function; sprs objects quicker than
;; soar-spr-production.  i have it bound to C-co.  Augments, does not
;; replace, soar-spr-production, because this won't do the right thing
;; when somewhere in the middle in a production or SP.

(defun soar-spr-symbol ()
  "Sprs a Soar gensym.  Useful in both *soar* and *glide*.
With no prefix arg, searches forward if no symbol under cursor.
With ^U prefix arg, searches backward if no symbol under cursor.
With ^U^U prefix arg, prompts user for a gensym, blank-terminated (fast).
With ^U- prefix arg, prompts user for a string (any number of gensyms)."
  (interactive)
  (let* ((search-string "\\([a-zA-Z][0-9]+[<>0-9-]*\\)")
         ;; begin after bol or whitespace; a leading letter,
         ;; followed by numbers, then optionally characters
         ;; from erik's timestamp chunk names.
         (gensym nil)
         (command nil))

    (cond ((eq '- current-prefix-arg)
           (setq gensym (read-string "Do spr on string: ")))

          ((eq 4 (car current-prefix-arg))      ; ^U: search backward
           (setq gensym
                 (save-excursion
                   ;; get to whitespace:
                   (if (not (looking-at "[\t\n ]"))
                       (re-search-forward " \\|\t\\|\n" nil 'not-t-or-nil))
                       ;; (forward-sexp 1)
                   ;; find next symbol:
                   (if (re-search-backward search-string nil t)
                       (buffer-substring (match-beginning 1)
                                         (match-end 1))))))

          ((eq 16 (car current-prefix-arg))     ; ^U^U: enter symbol manually
           (setq gensym (read-no-blanks-input "Do spr on symbol: " "")))

          (t                            ; no prefix arg: search forward
           (setq gensym
                 (save-excursion
                   (if (not (looking-at "[\t\n ]"))
                       (re-search-backward " \\|\t\\|\n" nil 'not-t-or-nil))
                       ;; (backward-sexp 1)
                   (if (re-search-forward search-string nil t)
                       (buffer-substring (match-beginning 1)
                                         (match-end 1)))))))

    (if (not gensym)                    ; search failed
        (setq gensym 
              (read-no-blanks-input "No symbol found.  Do spr on: " "")))
    (setq command (concat "(spr " gensym ")"))
    (if soar-print-into-diversion-p
        (soar-do-in-diversion-buffer command)
      (soar-do-in-soar-buffer gensym "spr" t))))

(defun soar-smatches-production (&optional name)
  "Run smatches on the production under the cursor.  If optional arg NAME is
supplied, use that as the name of the production instead."
  (interactive)
  (soar-do-to-production
    (concat (or name (soar-extract-production-name t "Do smatches on" t))
                ;soar-symbol-under-cursor
            " 0")
    "matches"
    t))


(defun soar-pbreak-production (&optional name)
  "Run pbreak on the production under the cursor.  If optional arg NAME is
supplied interactively, unpbreak.  If it is a symbol, use that as the name of
the production to break."
;; could break on a augmentation, so don't require a sp or tc
  (interactive "P")
  (soar-do-to-production
    (or (if (and name (symbolp name)) name)
        (soar-extract-production-name t "pbreak production"))
         ;soar-symbol-under-cursor
    (if (soar-reversing-arg name)
        "unpbreak"
        "pbreak")))

(defun soar-reversing-arg (arg)
  (or (numberp arg)
      (and (listp arg)
           arg)))

(defun soar-ptrace-production (&optional name)
  "Run ptrace on the production under the cursor.  If optional arg NAME is
supplied, use that as the name of the production instead."
  (interactive)
  (soar-do-to-production
    (or (if (and name (symbolp name)) name)
        (soar-extract-production-name t "ptrace production" t))
             ;soar-symbol-under-cursor
    (if (soar-reversing-arg name)
        "unptrace"
        "ptrace")))

(defun soar-pclass (&optional name)
  "Run pclass on the production under the cursor.  If optional arg NAME is
supplied, use that as the name of the production instead."
  (interactive)
  (soar-do-to-production
    (or name (soar-extract-production-name t "Find class of production" t))
             ;soar-symbol-under-cursor
    "pclass"
    t))


(defun soar-load-file (file-name)
  "later may take advantage of soarsyntax, etc."
  (interactive (comint-get-source "Load Soar file: " lisp-prev-l/c-dir/file
				  lisp-source-modes t))
  (soar-annotate-trace (format ";; Loaded file %s\n" file-name))
  (load-file-lisp file-name))

(defun soar-load-buffer (buffer)
  "Loads a buffer into *soar* and goes there"
  (interactive "b")
    (set-buffer buffer)
    (soar-annotate-trace (format ";; Loaded buffer %s\n" (buffer-name)))
    (eval-region-and-go-lisp (point-min) (point-max)))

;; this is a useful little function for noting things in the trace
;; that happened quietly.
;; 15-Oct-92 -FER
(defun soar-annotate-trace (annotation)
  (save-excursion
     (set-buffer (ilisp-buffer))
     (goto-char (point-max))
     (insert-before-markers annotation)))

;; #92) (3) 22 Jun 1992: "Joseph S. Mertz" <jm7l+@andrew.cmu.edu>
;; [If we have bindings for them, why not?  The search string should be
;; our regexp though...10-Jul-92 -FER]

;; in case you might be interested in this, i am forwarding a little
;; addition to soar mode that i've found helpful.  the two defun's simply
;; scroll the *soar* window forward and back a "<cl>" at a time.  each
;; time the line is centered at the top of the emacs window.  i have
;; found it useful for scrolling back through a trace.

(defun last-cl-top-window ()
  (interactive)
  ;; (push-mark)  ; no push mark, a no-no
  (beginning-of-line)
  (re-search-backward comint-prompt-regexp)
  (recenter 0)
  (indent-line-ilisp)  )

(defun next-cl-top-window ()
  (interactive)
  ;; (push-mark)  ; no push mark, a no-no
  (end-of-line)
  (re-search-forward comint-prompt-regexp)
  (recenter 0)
  (indent-line-ilisp)  )


;;;
;;;	II.	counting and listing soar productions
;;;

;;; Count productions in a file
;;;-------------------------------------------------------------------------

(defun soar-count-productions ()
  "Count the number of times an sp (-->) appears in the buffer"
  (interactive)
  (message "Counting soar productions...")
  (let ((count 0))
      (goto-char (point-min))
      ;; --> is most distinct to productions, and we guard it with \n
      (while (re-search-forward "[\n][ ]*-->" (point-max) t)
	(and (line-not-commented) (setq count (1+ count))))
      (pop-to-buffer "*PRODUCTION-COUNT*")
      (erase-buffer)
      (insert (concat "Counted " count 
                 " productions (occurences of \n -->) in this buffer.")))
  (message "Counting soar productions...Done."))

(popper-wrap 'soar-count-productions "*PRODUCTION-COUNT*")

;;; List productions in a file
;;;------------------------------------------------------------------------
(defun soar-make-productions-list ()
  (save-excursion
    (let (tmp)
      (goto-char (point-min))
      (while (re-search-forward "^(sp" nil 0)
	(push (string-trim '(?\ ?\TAB) ;SPC & TAB
                           (buffer-substring (point) (eol-point)))
	      tmp))
      (nreverse tmp))))

(defun soar-list-production-names ()
 "Make a list of the production names in the current buffer."
  (interactive)
  (let ((l (soar-make-productions-list)))
    (pop-to-buffer "*PRODUCTIONS*")
    (soar-mode)
    (erase-buffer)
    (dolist (p l)
      (insert p "\n"))))

(popper-wrap 'soar-list-production-names "*PRODUCTIONS*")

(defun eol-point ()
 (save-excursion (end-of-line) (point)))


;;;
;;;	III.	Argumentless DSI Commands
;;;

(defun load-taql ()
  "Load taql."
  (interactive)
  (soar-do-in-soar-buffer nil
           'test-load-taql))


(defun cms ()
  "Starts cms."
  (interactive)
  (soar-do-in-diversion-buffer "(if (fboundp 'sx::continuous-ms)
                                    (sx::continuous-ms)
                                    \"Can't, DSI not loaded.\")"))

(defun sx ()
  (interactive)
  (soar-do-in-diversion-buffer "(if (fboundp 'sx::sx)
                                    (sx::sx)
                                    \"Can't, SX not loaded.\")"))


;;;
;;;	IV.	Argumentless Soar Commands
;;;

(defun learn ()
  (interactive)
  (soar-do-in-diversion-buffer "(learn)"))

(defun ms ()
  "Print the match set."
  (interactive)
  (soar-do-in-diversion-buffer "(ms)"))

(defun pgs ()
 "Print out the goal stack."
 (interactive)
 (soar-do-in-diversion-buffer "(pgs)"))
 
(defun excise-chunks ()
  "Excise all chunks."
  (interactive)
  (soar-do-in-soar-buffer nil 'excise-chunks))

(defun excise-task ()
  "Excise all task productions."
 (interactive)
 (soar-do-in-soar-buffer nil 'excise-task))

(defun init-soar ()
  "Empties working memory and re-initializes runtime statistics."
  (interactive)
  (soar-do-in-soar-buffer nil  'init-soar t))

(defun init-task ()
  "A user-defined Lisp function that initializes the task."
  (interactive)
  (soar-do-in-soar-buffer nil 'init-task t))

(defun last-chunk ()
  "Prints the last production created by chunking."
  (interactive)
  (soar-do-in-diversion-buffer "(last-chunk)"))

(defun last-justification ()
  "Prints the last justification created by chunking."
  (interactive)
  (soar-do-in-diversion-buffer "(last-justification)"))

(defun list-chunks (file)
  "Prints all productions created by chunking."
  (interactive "sFile to list chunks in: ")
  (soar-do-in-soar-buffer 
     (if file
        (format "\"%s\"" file)
        nil)
     "list-chunks" 'show))

(defun memories ()
 "Print out the big RETE memory hogs."
 (interactive)
 (soar-do-in-diversion-buffer "(memories)"))

(defun restart-soar ()
  "Empties production and working memory and resets all globals."
  (interactive)
  (soar-do-in-soar-buffer nil  'restart-soar t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun parse-soar-arg (raw-arg)
 (if raw-arg
      (setq soar-default-drm-arg
	    (cond ((listp raw-arg) (car raw-arg))
		  ((>= 0 raw-arg) nil)
		  (t raw-arg))))
  soar-default-drm-arg)
; (parse-soar-arg nil)

(defun d (arg)
  "Calls d in Soar."
  (interactive "P")
  (soar-do-in-soar-buffer (parse-soar-arg arg) 'd nil 'scroll))

(defun r (arg)
  "Calls run in Soar."
  (interactive "P")
  (soar-do-in-soar-buffer (parse-soar-arg arg) 'run nil 'scroll))

(defun run-task (arg)
  (interactive "P")
  (soar-do-in-soar-buffer (parse-soar-arg arg)  'run-task))

(defun macrocycle (arg)
  (interactive "P")
  (soar-do-in-soar-buffer (parse-soar-arg arg)  'macrocycle))

;; this should be expanded and fleshed out, the naming is inconsistent
;; this makes functions also appear as soar-<function>
;; e.g., soar-r, soar-d, soar-macrocycle, soar-run-task
(mapcar (function (lambda (x)
          (fset (intern (format "soar-%s" x))
                x)))
        '(d r macrocycle run-task))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun soar-news ()
  "Show the Soar news."
  (interactive)
  (soar-do-in-diversion-buffer "(soar-news)"))

;; many can go away in post Soar6 versions
(defun lispsyntax ()
  "Changes the readtable to use standard Lisp conventions."
  (interactive)
  (soar-do-in-diversion-buffer "(lispsyntax)"))

(defun soarsyntax ()
  "Changes the readtable to use Soar conventions."
  (interactive)
  (soar-do-in-diversion-buffer "(soarsyntax)"))

(defun soarsyntaxp ()
  "Returns T if the Soar readtable is being used."
  (interactive)
  (soar-do-in-diversion-buffer "(soarsyntaxp)"))

(defun start-default ()
  "New productions will be considered default productions."
  (interactive)
  (soar-do-in-diversion-buffer "(start-default)"))

(defun stop-default ()
  "New productions will not be considered default productions."
  (interactive)
  (soar-do-in-diversion-buffer "(stop-default)"))


;;;
;;;	V.	 Extracting elements from buffer text
;;;----------------------------------------------------------------------------

(defun find-production-in-other-window ()
 "Search for production surrounding point in the other window."
 (interactive)
 (let ((search-thing (soar-extract-production-name t "Prod to find")))
   (other-window 1)
   (setq search-last-string search-thing)
   (cond ((search-forward search-thing nil t)
          (message "Found %s by looking forward." search-thing))
         ((search-backward search-thing nil t)
          (message "Found %s by looking backward." search-thing))
         (t (other-window -1)
            (message "Didn't find: %s." search-thing)))))

;; (soar-symbol-under-cursor nil "SPR production named" nil)
(defun soar-symbol-under-cursor (&optional do-prompt prompt-str
                                           must-be-sp-or-tc)
  "Extract the symbol (such as a production name) under the cursor.  If
optional arg DO-PROMPT is non-nil, prompt the user with a query constructed
from the optional second arg PROMPT-STRING and the extracted symbol as a
default answer which the user can select just by typing return.  Returns
either the default, or a new string typed by the user."
  (interactive)
  (if (null prompt-str) (setf prompt-str "SP/TC name"))
  (let ((old-syntax-table (syntax-table)))
  (set-syntax-table soar-symbol-syntax-table)
  (let ((symbol-at-point
	  (condition-case ()
	      (save-excursion
		(forward-sexp 1)
		(if (= (preceding-char) ?:)
		    (forward-char -1))
		(buffer-substring
		  (point)
		  (progn (forward-sexp -1)
			 (while (looking-at "\\s'")
			   (forward-char 1))
			 (point))))
	    (error nil))))
    (set-syntax-table old-syntax-table)
    (if (or (null symbol-at-point)
            (not (symbolp (car (read-from-string symbol-at-point))) )
            (equal '--> (car (read-from-string symbol-at-point)))
            (if (and must-be-sp-or-tc
                     (comint-check-proc "*soar*"))
                (string= "NIL"
                         (soar-send (format "(sp-or-tc? '%s)" 
                                            symbol-at-point))))
             )
        ;; symbol-at-point-is deficient somehow
        (setq symbol-at-point (soar-extract-production-name)))
    (cond ((null symbol-at-point)
	   ;; Couldn't extract symbol; prompt user
	   (read-string (format "%s: " prompt-str)))
	  (do-prompt
            ;; Extracted symbol, but have to check with user
	    (let ((ans (read-string (format "%s [%s]: " 
                                             prompt-str symbol-at-point))))
	      (if (string= "" ans)
		  symbol-at-point
		  ans)))
	  (t
	   ;; Extract symbol & we're not supposd to ask
	   (string-trim '(?\ ) symbol-at-point))))))

 ; (soar-extract-production-name)
(defun soar-extract-production-name (&optional do-prompt prompt-str
                                               must-be-sp-or-tc)
  "Returns the Soar production or TC name that point is in."
  (interactive)
  (cond ((eobp) ;if end of buffer, back up and retry
         (save-excursion
         (backward-char 1)
         (soar-extract-production-name do-prompt prompt-str)))
        ((and (not (equal mode-name "ILISP")) (not (equal mode-name "ISOAR")))
         ;; you are not in the process buffer
         (save-excursion (end-of-line)
                  (beginning-of-defun)
                  (forward-char 1)
                  (forward-sexp 1)
                  (forward-char 1)
                  (buffer-substring (point) (progn (end-of-line) (point)))) )
        (t ; you may be in the process buffer
         (soar-symbol-under-cursor do-prompt (or prompt-str "Do you mean")) )))
 

(defun soar-extract-TC-type ()   ; (soar-extract-production-name)
 "Return the TC type."
 (interactive)
 (cond ((eobp) ;if end of buffer, back up and retry   (eobp)
        (save-excursion
         (backward-char 1)
         (soar-extract-production-name)))
       ((equal mode-name "Soar") ;; you are not? in the process buffer
        (save-excursion 
           (end-of-line)
           (beginning-of-defun)
           (forward-char 1)
           (buffer-substring (point) 
                             (progn (forward-sexp 1) (point)))) )
       (t ; you may be in the process buffer
        (soar-extract-production-name t "No match found; TC type"))))
             ;soar-symbol-under-cursor


;;;
;;;	VI.	 Soar production editing
;;;-----------------------------------------------------------------------------
;;; It appears that most Lisp-oriented functions such as beginning-of-defun,
;;; etc., will also work with Soar productions.  Thus we can save ourselves
;;; a lot of work.  The following redefinitions are 1) for mnemonic purposes
;;; and 2) so that, if at some point it's determined that the elisp sexp 
;;; functions used are indeed not sufficient for Soar, they can just be
;;; redefined here instead of all over the place.

(defun soar-beginning-of-sp (&optional arg)
  (beginning-of-defun arg))

(defun soar-end-of-sp (&optional arg)
  (end-of-defun arg))


(defun soar-mark-sp ()
  "Put mark at end of defun, point at beginning."
  (interactive)
  (push-mark (point))
  (soar-end-of-sp)
  (push-mark (point))
  (soar-beginning-of-sp)
  (re-search-backward "^\n" (- (point) 1) t))


(defun soar-copy-sp ()
  "Copy production to kill buffer."
  (interactive)
  (save-excursion
    (soar-mark-sp)
    (copy-region-as-kill (point) (mark)))
  (message "Copied production to kill buffer."))
    


;;;
;;; 	VII.	General utility functions
;;;---------------------------------------------------------------------------

(defun soar-do-to-production (name op &optional diversion-bufferp)
  (let ((string (format "(%s %s)" op name))
        (lisp-no-popper t))
    (if diversion-bufferp
	(soar-do-in-diversion-buffer string)
	(soar-do-in-soar-buffer name op t))))
	; (ilisp-send string nil ':sending t)

;(defun soar-do-in-soar-buffer (name op &optional showp)
;  ;; this is interuptable by the user b/c it uses comint-send
;  ;; if showp, put command in buffer and on input ring
;  (let* ((stringn (if name
;		     (format "(%s %s)\n" op name)
;		   (format "(%s)\n" op)))
;	 (lisp-no-popper t))
;    (if showp
;         (save-excursion
;	    (set-buffer (ilisp-buffer))
;	    (ring-insert input-ring stringn)
;	    (comint-insert stringn)))
;    (comint-send-string (ilisp-process) stringn)))

(defun soar-do-in-soar-buffer (arg command &optional showp jump-n-scroll)
  ;; this is interuptable by the user b/c it uses comint-send
  ;; if showp, put command in buffer and on input ring
  ;; is jump-n-scroll, do what you can to scroll stuff up
  (message "Doing %s with %s" command arg)
  (let* ((stringn (if arg
                      (format "(%s %s)\n" command arg)
		   (format "(%s)\n" command)))
	 (lisp-no-popper t)
         (old-buffer (current-buffer)))
    (if jump-n-scroll
        (pop-to-buffer (ilisp-buffer)))
    (if showp
        (save-excursion
	    (set-buffer (ilisp-buffer))
	    (ring-insert input-ring stringn)
	    (comint-insert stringn)))
    (if jump-n-scroll
        (progn
          ;(scroll-up-in-place )
          ;(- (window-height (get-buffer-window (ilisp-buffer))) 2)
          (goto-char (point-max))
          (scroll-up 2)
          (pop-to-buffer old-buffer)))
    (comint-send-string (ilisp-process) stringn)))


;(defun soar-do-in-diversion-buffer (command)
;  "Do command, and put the output in the diversion buffer iff
;soar-print-into-glide-p is t.
;If soar-erase-diversion-buffer-p is true, the buffer is first erased;
;if soar-popup-diversion-buffer-p is true, the buffer is popup-ed."
;   (let* ((string (format "%s" command))
;          (output (ilisp-send string "" ))
;	  (buf (get-buffer-create *soar-diversion-buffer*)) )
;   (save-window-excursion
;      (set-buffer buf)
;      (if (or (not (eq major-mode 'soar-mode))
;              (not (eq mode-name 'ilisp-mode)))
;          (soar-mode))
;      (if soar-erase-diversion-buffer-p
;          (erase-buffer))
;      (goto-char (point-max))
;      (display-buffer buf)
;      (insert output))
;   (if soar-popup-diversion-buffer-p
;       (pop-to-buffer buf))
;      ))

;; 6-16-92 - ema - modified; when we're not erasing *glide*, keeps the
;; most recent output current by putting it at the top.  also, when
;; it's called from within *glide* when we're not erasing, no longer
;; spawns a new *glide*, just scrolls the current one up.  doing this
;; meant dispensing with the popper wrap and calling popper functions
;; directly, because we need finer control.
;;
;; FYI, here's what popper-wrap produces.  temp-buffer-show-hook is
;; popper-show.  note that it only does popper stuff to a window
;; that's already shown.

;
;(symbol-function 'soar-do-in-diversion-buffer)
;(lambda (command) "Do command, and put the output in the diversion buffer iff
;soar-print-into-diversion-p is t.
;If soar-erase-diversion-buffer-p is true, the buffer is first erased;
;if soar-popup-diversion-buffer-p is true, the buffer is popup-ed."
;        (let ((shown nil))
;          (save-window-excursion
;            (funcall popper-soar-do-in-diversion-buffer command)
;            (setq shown (get-buffer-window soar-diversion-buffer-name)))
;          (if shown
;              (funcall temp-buffer-show-hook soar-diversion-buffer-name))))

(defun soar-do-in-diversion-buffer (command)
  "Do command, and put the output in the diversion buffer iff
soar-print-into-diversion-p is t.
If soar-erase-diversion-buffer-p is true, the buffer is first erased;
if soar-popup-diversion-buffer-p is true, the buffer is popup-ed."
   (let* ((astring (format "%s" command))
          output
          (old-buffer (current-buffer))
	  (buf (get-buffer-create soar-diversion-buffer-name)) )
     (message "Doing %s..." astring)
     (if soar-print-into-diversion-p
         (progn
          (setq output (soar-send astring ""))
          (save-excursion
           (set-buffer buf)
           (if (or (not (eq major-mode 'soar-mode))
                   (not (eq mode-name 'ilisp-mode)))
               (soar-mode))
           (if soar-erase-diversion-buffer-p
               (erase-buffer))
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           ;; ema - insert stuff at the top rather than bottom:
           ;;(goto-char (point-max))       
           (goto-char (point-min))
           (insert output)
           (insert "\n"))
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;; ema - replaced if with cond:
          ;;(if soar-popup-diversion-buffer-p
          ;;  (progn (display-buffer buf)
          ;;         (pop-to-buffer buf)
          ;;         (pop-to-buffer old-buffer)))
          (cond ((and soar-popup-diversion-buffer-p
                      (not (eq old-buffer buf))) ; per joe mertz
                 (popper-show buf)      ; value of temp-buffer-show-hook
                 )
                (soar-popup-diversion-buffer-p
                 (set-window-point (selected-window) 0) ; just realign
                 ))
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          )
     (let ((lisp-no-popper t)
           (astringn (concat astring "\n"))  )
         (set-buffer (ilisp-buffer))
         (ring-insert input-ring astring)
         (funcall comint-input-sender (ilisp-process)
                  astring)
         (goto-char (point-max))            ))
     (message "Doing %s...Done." astring)     ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6-17-92 - ema - dispense with popper wrap:
;(if soar-diversion-buffer-use-popup
;    (popper-wrap soar-do-in-diversion-buffer soar-diversion-buffer-name))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


