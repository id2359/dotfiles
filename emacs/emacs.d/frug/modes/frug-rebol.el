(defun frug-configure-rebol ()
(setq auto-mode-alist
    (cons '("\\.r" . rebol-mode) auto-mode-alist))
    (setq j-path "/home/lee/progs/j903"))
    
  )
            
(use-package rebol
  :ensure nil
  :load-path "~/.emacs.d/frug/local/rebol.el"
  :config (frug-configure-rebol))

(provide 'frug-rebol)
