;;; mysettings -- Summary

;;; Commentary:
;;; after loading packages init them

;;; Code:
(setq inhibit-startup-message t)
(set-default 'truncate-lines t)

(add-hook
 'after-init-hook
 '(lambda ()

    ;; virtual envs
    ;;(require 'virtualenvwrapper)
    ;;(venv-initialize-interactive-shells) ;; if you want interactive shell support
    ;;(venv-initialize-eshell) ;; if you want eshell support
    ;; note that setting `venv-location` is not necessary if you
    ;; use the default location (`~/.virtualenvs`), or if the
    ;; the environment variable `WORKON_HOME` points to the right place
    ;;(setq venv-location "/home/lee/.virtual-envs")
    (if (string= (getenv "PROJECT") "PEAKPROJECT")
	(venv-workon "peak")
    (venv-workon "emacsvenv"))
	
    
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
    ;;Standard Jedi.el setting
    (setq jedi:environment-root "/home/lee/.virtual-envs/emacsvenv")
    
    (add-hook 'python-mode-hook 'jedi:setup)
    (setq jedi:complete-on-dot t)


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
    ;;(pymacs-load "ropemacs" "rope-")

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

    ;; typescript-mode
    (require 'typescript-mode)
    (add-to-list 'auto-mode-alist '("\.ts$" . typescript-mode))
    (add-to-list 'auto-mode-alist '("\.tsx$" . typescript-mode))


    (require 'py-autopep8)
    (add-hook 'python-mode-hook 'py-autopep8-enable-on-save)
    
    

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

    ;(color-theme-calm-forest)
    ;(load-theme 'material t)

    ;; Web beautify
    (eval-after-load 'js2-mode
      '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
    ;; Or if you're using 'js-mode' (a.k.a 'javascript-mode')
    (eval-after-load 'js
      '(define-key js-mode-map (kbd "C-c b") 'web-beautify-js))

    (eval-after-load 'json-mode
      '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))

    (eval-after-load 'sgml-mode
      '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))

    (eval-after-load 'web-mode
      '(define-key web-mode-map (kbd "C-c b") 'web-beautify-html))

    (eval-after-load 'css-mode
      '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))



    )
 )

(provide 'mysettings)
;;; mysettings ends here
