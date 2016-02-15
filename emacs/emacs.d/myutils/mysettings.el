(provide 'mysettings)
(setq inhibit-startup-message t)

(require 'color-theme)
(color-theme-initialize)
(color-theme-calm-forest)

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

    ;; neotree
    (require 'neotree)
    (global-set-key [f8] 'neotree-toggle)
    ))

