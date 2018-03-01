;;; mysettings -- Summary
;;; Commentary:
;;; after loading packages init them

;;; Code:
(setq inhibit-startup-message t)
(set-default 'truncate-lines t)
(require 'color-theme)
(color-theme-initialize)
;(color-theme-calm-forest)


; try material ui theme
;(load-theme 'material t)

(add-hook
 'after-init-hook
 '(lambda ()
    
    ;; ido mode
    (require 'ido)
    (setq ad-redefinition-action 'accept)
    (require 'evil)
    
    (setq ido-enable-flex-matching t)
    (setq ido-everywhere t)
    (ido-mode t)

    ;; autocomplete

    (require 'auto-complete)

    (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
    (require 'auto-complete-config)
    (ac-config-default)
    (global-auto-complete-mode t)

    ;; projectile
    (require 'projectile)
    (projectile-global-mode)

    ;; Jedi
    (require 'jedi)
    ;; Standard Jedi.el setting
    (add-hook 'python-mode-hook 'jedi:setup)
    (setq jedi:complete-on-dot t)

    (require 'julia-shell)
    (defun my-julia-mode-hooks ()
      (require 'julia-shell))
    (add-hook 'julia-mode-hook 'my-julia-mode-hooks)
    (define-key julia-mode-map (kbd "C-c C-j") 'julia-shell-run-region-or-line)
    (define-key julia-mode-map (kbd "C-c C-s") 'julia-shell-save-and-go)
    

    ;; J
    (autoload 'j-mode "j-mode.el"  "Major mode for J." t)
    (autoload 'j-shell "j-mode.el" "Run J from emacs." t)
    (setq auto-mode-alist
	  (cons '("\\.ij[rstp]" . j-mode) auto-mode-alist))

    ;; neotree
    (require 'neotree)
    (global-set-key [f8] 'neotree-toggle)

    ;; flycheck
    (global-flycheck-mode)

    ;; slime
    (cond
     ((eq system-type 'darwin) (setq inferior-lisp-program "/usr/local/bin/sbcl"))
     (t (setq inferior-lisp-program "/usr/bin/sbcl")))


    ;; Pymacs
    (if (eq system-type 'darwin)
        (add-to-list 'load-path "/usr/local/lib/python2.7/site-packages/Pymacs")
       (add-to-list 'load-path (expand-file-name "Pymacs" "/usr/lib/python2.7/dist-packages")))
    
    
    (require 'pymacs)
    (autoload 'pymacs-apply "pymacs")
    (autoload 'pymacs-call "pymacs")
    (autoload 'pymacs-eval "pymacs" nil t)
    (autoload 'pymacs-exec "pymacs" nil t)
    (autoload 'pymacs-load "pymacs" nil t)
    (autoload 'pymacs-autoload "pymacs")


    ;; Rope
    (pymacs-load "ropemacs" "rope-")

    ;; base16

    (if (evening)
	(color-theme-blippblopp)
      (progn
	(require 'base16-theme)
	(load-theme 'base16-oceanicnext)))
    ;; helm
    (require 'helm)
    (require 'helm-config)

    ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
    ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
    ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
    (global-set-key (kbd "C-c h") 'helm-command-prefix)
    (global-unset-key (kbd "C-x c"))

    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
    (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

    (when (executable-find "curl")
      (setq helm-google-suggest-use-curl-p t))

    (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)

    (helm-mode 1)


    ;; feature-mode
    (setq feature-default-language "en")
    (require 'feature-mode)
    (add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))
    

    (add-hook 'python-mode-hook
      (lambda ()
        (setq indent-tabs-mode nil)
        (setq tab-width 4)
        (setq python-indent 4)))

    ;; yasnippet
    (require 'yasnippet)
    (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
    (yas-global-mode 1)
    ;; paredit
    (add-hook 'emacs-lisp-mode-hook 'evil-paredit-mode)
    ))

(provide 'mysettings)
;;; mysettings ends here
