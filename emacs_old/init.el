(require 'package)
(setq package-check-signature nil)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                     ("marmalade" . "http://marmalade-repo.org/packages/")
                     ("melpa" . "http://melpa.org/packages/")))



(setq make-backup-files nil)
(setq emacs-root (expand-file-name "~/.emacs.d/"))
(message emacs-root)
(setq make-backup-files nil)
(global-set-key (kbd "C-a") 'mark-whole-buffer)



(defvar load-paths '("langs"
                     "downloaded"
		     "settings"
		     "myutils"
		     "themes"
		     "misc"
		     ))

(cl-loop for location in load-paths
      do (add-to-list 'load-path (concat emacs-root location)))


(require 'use-package)
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(width . 189))
(set-face-attribute 'default nil :family "Inconsolata" :height 140) 

(setq package-enable-at-startup nil)


(when (not package-archive-contents)
  (package-refresh-contents))

(defvar packages '(let-alist
		   flycheck
		   elisp-format
		   yapfify
		   auto-complete
		   virtualenvwrapper
		   projectile
		   exec-path-from-shell
		   flymake-easy
		   py-autopep8
		   ;;python-pep8
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
		   base16-theme
		   python-black))

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
;(add-hook 'python-mode-hook 'flymake-python-pyflakes-load)

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

  
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-keyword-face ((t (:foreground "black" :weight ultra-bold)))))
