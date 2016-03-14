(provide 'mysettings)
(setq inhibit-startup-message t)
(set-default 'truncate-lines t) 
(require 'color-theme)
(color-theme-initialize)
;(color-theme-calm-forest)


; try material ui theme
(load-theme 'material t)

(add-hook
 'after-init-hook
 '(lambda ()
    
    ;; ido mode
    (require 'ido)
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

    ;; J
    (autoload 'j-mode "j-mode.el"  "Major mode for J." t)
    (autoload 'j-shell "j-mode.el" "Run J from emacs." t)
    (setq auto-mode-alist
	  (cons '("\\.ij[rstp]" . j-mode) auto-mode-alist))

    ;; neotree
    (require 'neotree)
    (global-set-key [f8] 'neotree-toggle)

    ;; yasnippet
    (require 'yasnippet)
    (yas-global-mode 1)
    ))

