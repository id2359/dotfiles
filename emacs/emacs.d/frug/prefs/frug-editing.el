(use-package evil
  :ensure t
  :config (evil-mode 1))
  
(setq inhibit-startup-message t)
(set-default 'truncate-lines t)
(setq make-backup-files nil)
(setq create-lockfiles nil)


(global-set-key (kbd "C-S-<f3>") 'magit-status)
(global-set-key (kbd "C-<f8>") 'pep8)
(global-set-key (kbd "C-<f9>") 'py-autopep8-buffer)

(global-set-key (kbd "C-<left>") 'previous-buffer)
(global-set-key (kbd "C-<right>") 'next-buffer)
(global-set-key (kbd "C-<f12>") 'kill-other-buffers)

(set-face-attribute 'region nil :background "#666")

;;(setq-default cursor-type 'bar) 
(set-cursor-color "#ff0000") 


(defun frug-neotree-config ()
   (global-set-key [f8] 'neotree-toggle))

(use-package neotree
  :ensure t
  :config (frug-neotree-config))


(use-package helm
  :ensure t)


(provide 'frug-editing)
