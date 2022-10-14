(use-package evil
  :ensure t
  :config (evil-mode 1))
  
(setq inhibit-startup-message t)
(set-default 'truncate-lines t)
(setq make-backup-files nil)

(defun frug-neotree-config ()
   (global-set-key [f8] 'neotree-toggle))

(use-package neotree
  :ensure t
  :config (frug-neotree-config))

(provide 'frug-editing)
