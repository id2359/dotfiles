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
(global-set-key (kbd "M-i") #'completion-at-point)


(setq python-shell-interpreter "/usr/bin/python3")
(setq py-python-command "/usr/bin/python3") 
(setq python-python-command "/usr/bin/python3")

(set-face-attribute 'region nil :background "#666")

;;(setq-default cursor-type 'bar) 
(set-cursor-color "#ff0000") 
;;(add-hook 'python-mode-hook 'auto-complete-mode)


(defun frug-neotree-config ()
   (global-set-key [f8] 'neotree-toggle))

(use-package neotree
  :ensure t
  :config (frug-neotree-config))

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))



(use-package helm
  :ensure t)

;(use-package lsp-mode
;  :ensure t
;  :config
;  ;;(add-hook 'c++-mode-hook #'lsp)
;  ;;(add-hook 'rust-mode-hook #'lsp)
;  (add-hook 'python-mode-hook #'lsp))


;(use-package lsp-mode
; :ensure t
; :config
;  (lsp-register-custom-settings
;   '(("pyls.plugins.pyls_mypy.enabled" t t)
;     ("pyls.plugins.pyls_mypy.live_mode" nil t)
;     ("pyls.plugins.pyls_black.enabled" t t)
;     ("pyls.plugins.pyls_isort.enabled" t t)))
;  :hook
;  ((python-mode . lsp)));

;(use-package lsp-ui
;  :ensure t
;  :commands lsp-ui-mode)


(use-package eglot
  :ensure t
  :config
  (add-hook 'python-mode-hook 'eglot-ensure))
  

(use-package corfu
  :ensure t
  :config
  ;; Optional customizations
  :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-excluded-modes'.
  :init
  (global-corfu-mode))

(provide 'frug-editing)
