(require 'package)
(require 'cl)
(package-initialize)
(setq package-check-signature nil)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("marmalade" . "http://marmalade-repo.org/packages/")
			 ("gnu" . "http://elpa.gnu.org/packages/")))


(setq make-backup-files nil)
(setq emacs-root (expand-file-name "~/.emacs.d/"))
(setq make-backup-files nil)
(global-set-key (kbd "C-a") 'mark-whole-buffer)



(defvar load-paths '("langs"
                     "downloaded"
		     "settings"
		     "myutils"
		     "themes"
		     "misc"
		     ))

(loop for location in load-paths
      do (add-to-list 'load-path (concat emacs-root location)))


(require 'use-package)
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(width . 189))
(set-face-attribute 'default nil :family "Inconsolata" :height 140) 

(setq package-enable-at-startup nil)
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar packages '(use-package
		   let-alist
		   cl
		   flycheck
		   elisp-format
		   yapfify
		   auto-complete
		   virtualenvwrapper
		   projectile
		   exec-path-from-shell
		   flymake-easy
		   py-autopep8
		   ;python-pep8
		   ;;yapfify
		   epc
		   jedi
		   neotree
		   magit
		   base16-theme
		   tramp
		   evil
		   flymake-python-pyflakes
		   ;python-pylint
		   material-theme
		   tuareg
		   yasnippet
		   evil-leader
		   paredit
		   evil-paredit
		   slime
		   ;ensime
		   helm
		   typescript-mode
		   js2-mode
		   json-mode
		   web-mode
		   web-beautify
		   exec-path-from-shell
		   feature-mode
                   ada-mode
		   slime
		   base16-theme))

(defvar all-packages-installed t)
(dolist (p packages)
  (unless (package-installed-p p)
    (setq all-packages-installed nil)))

(unless all-packages-installed
  (dolist (p packages)
    (unless (package-installed-p p)
      (package-install p))))

;; settings
(require 'py-autopep8)
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)

;; octave
(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))
		     

(autoload 'clips-mode "clips-mode" nil t)
(setq auto-mode-alist
     (cons '("\\.clp" . clips-mode) auto-mode-alist))

(setq auto-mode-alist
     (cons '("\\.newlisp" . newlisp-mode) auto-mode-alist))


;; Set your lisp system and, optionally, some contribs
(setq inferior-lisp-program "sbcl")
(setq slime-contribs '(slime-fancy))


(require 'mysettings)
(require 'myutils)
(require 'mykeybindings)
(require 'django-html-mode)
(require 'flycheck)
(require 'pyvenv)
(add-hook 'after-init-hook #'global-flycheck-mode)

(require 'flymake-python-pyflakes)
(add-hook 'python-mode-hook 'flymake-python-pyflakes-load)

(setq-default flycheck-disabled-checkers
    (append flycheck-disabled-checkers
        '(javascript-jshint)))

(flycheck-add-mode 'javascript-eslint 'web-mode)

(add-hook 'python-mode-hook 'flycheck-mode)

(setq-default flycheck-temp-prefix ".flycheck")

(setq-default flycheck-disabled-checkers
    (append flycheck-disabled-checkers
    '(json-jsonlist)))

;; pep8 options
(setq py-autopep8-options '("--max-line-length=120"))

;; install this manually

(add-to-list 'load-path (concat emacs-root "evil"))

(require 'evil)
(evil-mode 1)
(show-paren-mode)

(require 'use-package)


(defun load-ropemacs ()
  "Load pymacs and ropemacs."
  (interactive)
  (require 'pymacs)
  (pymacs-load "ropemacs" "rope-")
  ;; Automatically save project python buffers before refactorings
  (setq ropemacs-confirm-saving 'nil)
)


(global-set-key (kbd "\C-c pl") 'load-ropemacs)


(require 'ediprolog)
(global-set-key (kbd "\C-c ep") 'ediprolog-dwim)


(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(setq frame-title-format
      (list (format "emacs %s %%S: %%j " (system-name))
        '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

  
(when (eq system-type 'darwin)
  (require 'ls-lisp)
  (setq ls-lisp-use-insert-directory-program nil))

(when (eq system-type 'darwin)
  (add-to-list 'load-path "/Applications/Macaulay2-1.6/share/emacs/site-lisp")
  (load "M2-init")
  (global-set-key [f12] 'M2))

(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("34ed3e2fa4a1cb2ce7400c7f1a6c8f12931d8021435bad841fdc1192bd1cc7da" default)))
 '(package-selected-packages
   (quote
    (kubernetes-evil kubernetes yasnippet web-mode web-beautify virtualenvwrapper use-package typescript-mode tuareg slime py-autopep8 projectile neotree material-theme magit-popup magit json-mode js2-mode jedi flymake-python-pyflakes flycheck feature-mode exec-path-from-shell evil-paredit evil-leader base16-theme async))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-keyword-face ((t (:foreground "black" :weight ultra-bold)))))
