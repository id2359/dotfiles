(defun frug-configure-magit ()
    (global-set-key (kbd "C-S-<f3>") 'magit-status))


(use-package magit
  :ensure t
  :config (frug-configure-magit))
  
  
(provide 'frug-git)
