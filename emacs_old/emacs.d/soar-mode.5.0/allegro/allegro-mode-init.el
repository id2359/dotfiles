;;;; -*- Mode: Soar -*- 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 
;;;; File            : allegro-init.el
;;;; Author          : Frank Ritter
;;;; Created On      : Tue Jul  3 15:22:46 1990
;;;; Last Modified By: Frank Ritter
;;;; Last Modified On: Wed Mar 27 13:19:20 1991
;;;; Update Count    : 7
;;;; 
;;;; 
;;;; PURPOSE
;;;; 	Load remaining allegro code in this mode.
;;;; HISTORY
;;;;    Allegro used to be basis of soar mode, only the manual entry stuff is
;;;;  carried forward.
;;;; TABLE OF CONTENTS
;;;; 	Load only stuff we want.
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(setq load-path (cons (concat soar-gnu-directory "/allegro/") load-path))

(load "fi/clman")

;;; "Export" the user visible commands used here to be easily typed in.
;;;

(fset 'clman 'fi:clman)
(fset 'clman-apropos 'fi:clman-apropos)
(fset 'clman-mode 'fi:clman-mode)
(fset 'search-forward-see-alsos 'clman:search-forward-see-alsos)
(fset 'clman-flush-doc 'clman:flush-doc)

;(load "fi/filec")
;(load "fi/keys")
;(load "fi/ltags")
;(load "fi/modes")
;(load "fi/ring")
;(load "fi/sublisp")
;(load "fi/subproc")
;(load "fi/tcplisp")
;(load "fi/utils")

;; `shell' and `rlogin' modes:
;(load "fi/shell")
;(load "fi/rlogin")

;; Default didn't account for possible space(s) between the 
;; prompt string and the ending characters.  Yeah, it's uncommon for 
;; someone to set up a prompt that does have it, but I do! --Mike
;;
;(setq fi:rlogin-prompt-pattern "^[-_.a-zA-Z0-9 ]*[#$%>] *")

;(setq fi:common-lisp-image-name inferior-lisp-program)


(setq fi:package-loaded t)

(provide 'smallfi)


;;;; probably not neccessary anymore

;;;; Special case initialization for Apollos:
;;;;
;;(let ((s (downcase (prin1-to-string system-type))))
;;  (if (and (> (length s) 5) (equal (substring s 0 6) "domain"))
;;      (let ()
;;        ;;
;;        ;; Change pathname to transaction directory to work across machines.
;;        ;; This is necessary because /tmp is actually a link to `node_data/tmp 
;;        ;; on Apollos, and if you start a remote process on another node, its \
;;idea
;;        ;; of /tmp will be local to its disk.  This assures the remote process
;;        ;; looks in the right place for /tmp.
;;        ;;
;;        (setq fi:inferior-common-lisp-mode-hook
;;              (cons (function
;;                      (lambda ()
;;                        (setq fi:emacs-to-lisp-transaction-directory 
;;                              (concat "//" (substring (system-name) 0 (string-\
;;match "\\." (system-name)))
;;                                      "/sys/node_data/tmp"))))
;;                    nil)))))
;;
