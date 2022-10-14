(defun frug-configure-blacken ()
  (add-hook 'python-mode-hook
      'blacken-mode))
            
            
(use-package blacken
  :ensure t
  :config (frug-configure-blacken))

(provide 'frug-python)
