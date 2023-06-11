(add-to-list 'load-path "~/.emacs.d/local")
(add-to-list 'load-path "~/.emacs.d/frug/prefs")
(add-to-list 'load-path "~/.emacs.d/frug/modes")

(require 'frug-packages)
(require 'frug-editing)
(require 'frug-python)
(require 'frug-typescript)
(require 'frug-guile)
(require 'frug-git)
(require 'linum)






(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(magit use-package evil blacken)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
