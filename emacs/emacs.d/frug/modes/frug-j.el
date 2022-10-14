(defun frug-configure-j ()
    (autoload 'j-mode "j-mode.el"  "Major mode for J." t)
    (autoload 'j-shell "j-mode.el" "Run J from emacs." t)
    (setq auto-mode-alist (cons '("\\.ij[rstp]" . j-mode) auto-mode-alist))
    (setq j-path "/home/lee/progs/j903"))
            
(use-package j-mode
  :ensure nil
  :load-path "~/.emacs.d/frug/local/j-mode.el"
  :config (frug-configure-j))
  
(provide 'frug-j)
